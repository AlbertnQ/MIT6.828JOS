
obj/user/testpiperace.debug:     file format elf32-i386


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
  80002c:	e8 b3 01 00 00       	call   8001e4 <libmain>
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
  800038:	83 ec 1c             	sub    $0x1c,%esp
	int p[2], r, pid, i, max;
	void *va;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for dup race...\n");
  80003b:	68 00 23 80 00       	push   $0x802300
  800040:	e8 d8 02 00 00       	call   80031d <cprintf>
	if ((r = pipe(p)) < 0)
  800045:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800048:	89 04 24             	mov    %eax,(%esp)
  80004b:	e8 72 1c 00 00       	call   801cc2 <pipe>
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	79 12                	jns    800069 <umain+0x36>
		panic("pipe: %e", r);
  800057:	50                   	push   %eax
  800058:	68 19 23 80 00       	push   $0x802319
  80005d:	6a 0d                	push   $0xd
  80005f:	68 22 23 80 00       	push   $0x802322
  800064:	e8 db 01 00 00       	call   800244 <_panic>
	max = 200;
	if ((r = fork()) < 0)
  800069:	e8 1a 10 00 00       	call   801088 <fork>
  80006e:	89 c6                	mov    %eax,%esi
  800070:	85 c0                	test   %eax,%eax
  800072:	79 12                	jns    800086 <umain+0x53>
		panic("fork: %e", r);
  800074:	50                   	push   %eax
  800075:	68 36 23 80 00       	push   $0x802336
  80007a:	6a 10                	push   $0x10
  80007c:	68 22 23 80 00       	push   $0x802322
  800081:	e8 be 01 00 00       	call   800244 <_panic>
	if (r == 0) {
  800086:	85 c0                	test   %eax,%eax
  800088:	75 55                	jne    8000df <umain+0xac>
		close(p[1]);
  80008a:	83 ec 0c             	sub    $0xc,%esp
  80008d:	ff 75 f4             	pushl  -0xc(%ebp)
  800090:	e8 b1 13 00 00       	call   801446 <close>
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	bb c8 00 00 00       	mov    $0xc8,%ebx
		// If a clock interrupt catches dup between mapping the
		// fd and mapping the pipe structure, we'll have the same
		// ref counts, still a no-no.
		//
		for (i=0; i<max; i++) {
			if(pipeisclosed(p[0])){
  80009d:	83 ec 0c             	sub    $0xc,%esp
  8000a0:	ff 75 f0             	pushl  -0x10(%ebp)
  8000a3:	e8 6d 1d 00 00       	call   801e15 <pipeisclosed>
  8000a8:	83 c4 10             	add    $0x10,%esp
  8000ab:	85 c0                	test   %eax,%eax
  8000ad:	74 15                	je     8000c4 <umain+0x91>
				cprintf("RACE: pipe appears closed\n");
  8000af:	83 ec 0c             	sub    $0xc,%esp
  8000b2:	68 3f 23 80 00       	push   $0x80233f
  8000b7:	e8 61 02 00 00       	call   80031d <cprintf>
				exit();
  8000bc:	e8 69 01 00 00       	call   80022a <exit>
  8000c1:	83 c4 10             	add    $0x10,%esp
			}
			sys_yield();
  8000c4:	e8 db 0b 00 00       	call   800ca4 <sys_yield>
		//
		// If a clock interrupt catches dup between mapping the
		// fd and mapping the pipe structure, we'll have the same
		// ref counts, still a no-no.
		//
		for (i=0; i<max; i++) {
  8000c9:	83 eb 01             	sub    $0x1,%ebx
  8000cc:	75 cf                	jne    80009d <umain+0x6a>
				exit();
			}
			sys_yield();
		}
		// do something to be not runnable besides exiting
		ipc_recv(0,0,0);
  8000ce:	83 ec 04             	sub    $0x4,%esp
  8000d1:	6a 00                	push   $0x0
  8000d3:	6a 00                	push   $0x0
  8000d5:	6a 00                	push   $0x0
  8000d7:	e8 e8 10 00 00       	call   8011c4 <ipc_recv>
  8000dc:	83 c4 10             	add    $0x10,%esp
	}
	pid = r;
	cprintf("pid is %d\n", pid);
  8000df:	83 ec 08             	sub    $0x8,%esp
  8000e2:	56                   	push   %esi
  8000e3:	68 5a 23 80 00       	push   $0x80235a
  8000e8:	e8 30 02 00 00       	call   80031d <cprintf>
	va = 0;
	kid = &envs[ENVX(pid)];
  8000ed:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	cprintf("kid is %d\n", kid-envs);
  8000f3:	83 c4 08             	add    $0x8,%esp
  8000f6:	6b c6 7c             	imul   $0x7c,%esi,%eax
  8000f9:	c1 f8 02             	sar    $0x2,%eax
  8000fc:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
  800102:	50                   	push   %eax
  800103:	68 65 23 80 00       	push   $0x802365
  800108:	e8 10 02 00 00       	call   80031d <cprintf>
	dup(p[0], 10);
  80010d:	83 c4 08             	add    $0x8,%esp
  800110:	6a 0a                	push   $0xa
  800112:	ff 75 f0             	pushl  -0x10(%ebp)
  800115:	e8 7c 13 00 00       	call   801496 <dup>
	while (kid->env_status == ENV_RUNNABLE)
  80011a:	83 c4 10             	add    $0x10,%esp
  80011d:	6b de 7c             	imul   $0x7c,%esi,%ebx
  800120:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  800126:	eb 10                	jmp    800138 <umain+0x105>
		dup(p[0], 10);
  800128:	83 ec 08             	sub    $0x8,%esp
  80012b:	6a 0a                	push   $0xa
  80012d:	ff 75 f0             	pushl  -0x10(%ebp)
  800130:	e8 61 13 00 00       	call   801496 <dup>
  800135:	83 c4 10             	add    $0x10,%esp
	cprintf("pid is %d\n", pid);
	va = 0;
	kid = &envs[ENVX(pid)];
	cprintf("kid is %d\n", kid-envs);
	dup(p[0], 10);
	while (kid->env_status == ENV_RUNNABLE)
  800138:	8b 53 54             	mov    0x54(%ebx),%edx
  80013b:	83 fa 02             	cmp    $0x2,%edx
  80013e:	74 e8                	je     800128 <umain+0xf5>
		dup(p[0], 10);

	cprintf("child done with loop\n");
  800140:	83 ec 0c             	sub    $0xc,%esp
  800143:	68 70 23 80 00       	push   $0x802370
  800148:	e8 d0 01 00 00       	call   80031d <cprintf>
	if (pipeisclosed(p[0]))
  80014d:	83 c4 04             	add    $0x4,%esp
  800150:	ff 75 f0             	pushl  -0x10(%ebp)
  800153:	e8 bd 1c 00 00       	call   801e15 <pipeisclosed>
  800158:	83 c4 10             	add    $0x10,%esp
  80015b:	85 c0                	test   %eax,%eax
  80015d:	74 14                	je     800173 <umain+0x140>
		panic("somehow the other end of p[0] got closed!");
  80015f:	83 ec 04             	sub    $0x4,%esp
  800162:	68 cc 23 80 00       	push   $0x8023cc
  800167:	6a 3a                	push   $0x3a
  800169:	68 22 23 80 00       	push   $0x802322
  80016e:	e8 d1 00 00 00       	call   800244 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  800173:	83 ec 08             	sub    $0x8,%esp
  800176:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800179:	50                   	push   %eax
  80017a:	ff 75 f0             	pushl  -0x10(%ebp)
  80017d:	e8 9a 11 00 00       	call   80131c <fd_lookup>
  800182:	83 c4 10             	add    $0x10,%esp
  800185:	85 c0                	test   %eax,%eax
  800187:	79 12                	jns    80019b <umain+0x168>
		panic("cannot look up p[0]: %e", r);
  800189:	50                   	push   %eax
  80018a:	68 86 23 80 00       	push   $0x802386
  80018f:	6a 3c                	push   $0x3c
  800191:	68 22 23 80 00       	push   $0x802322
  800196:	e8 a9 00 00 00       	call   800244 <_panic>
	va = fd2data(fd);
  80019b:	83 ec 0c             	sub    $0xc,%esp
  80019e:	ff 75 ec             	pushl  -0x14(%ebp)
  8001a1:	e8 10 11 00 00       	call   8012b6 <fd2data>
	if (pageref(va) != 3+1)
  8001a6:	89 04 24             	mov    %eax,(%esp)
  8001a9:	e8 03 19 00 00       	call   801ab1 <pageref>
  8001ae:	83 c4 10             	add    $0x10,%esp
  8001b1:	83 f8 04             	cmp    $0x4,%eax
  8001b4:	74 12                	je     8001c8 <umain+0x195>
		cprintf("\nchild detected race\n");
  8001b6:	83 ec 0c             	sub    $0xc,%esp
  8001b9:	68 9e 23 80 00       	push   $0x80239e
  8001be:	e8 5a 01 00 00       	call   80031d <cprintf>
  8001c3:	83 c4 10             	add    $0x10,%esp
  8001c6:	eb 15                	jmp    8001dd <umain+0x1aa>
	else
		cprintf("\nrace didn't happen\n", max);
  8001c8:	83 ec 08             	sub    $0x8,%esp
  8001cb:	68 c8 00 00 00       	push   $0xc8
  8001d0:	68 b4 23 80 00       	push   $0x8023b4
  8001d5:	e8 43 01 00 00       	call   80031d <cprintf>
  8001da:	83 c4 10             	add    $0x10,%esp
}
  8001dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001e0:	5b                   	pop    %ebx
  8001e1:	5e                   	pop    %esi
  8001e2:	5d                   	pop    %ebp
  8001e3:	c3                   	ret    

008001e4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001e4:	55                   	push   %ebp
  8001e5:	89 e5                	mov    %esp,%ebp
  8001e7:	56                   	push   %esi
  8001e8:	53                   	push   %ebx
  8001e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001ec:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  8001ef:	e8 91 0a 00 00       	call   800c85 <sys_getenvid>
  8001f4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001f9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001fc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800201:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800206:	85 db                	test   %ebx,%ebx
  800208:	7e 07                	jle    800211 <libmain+0x2d>
		binaryname = argv[0];
  80020a:	8b 06                	mov    (%esi),%eax
  80020c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800211:	83 ec 08             	sub    $0x8,%esp
  800214:	56                   	push   %esi
  800215:	53                   	push   %ebx
  800216:	e8 18 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80021b:	e8 0a 00 00 00       	call   80022a <exit>
}
  800220:	83 c4 10             	add    $0x10,%esp
  800223:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800226:	5b                   	pop    %ebx
  800227:	5e                   	pop    %esi
  800228:	5d                   	pop    %ebp
  800229:	c3                   	ret    

0080022a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80022a:	55                   	push   %ebp
  80022b:	89 e5                	mov    %esp,%ebp
  80022d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800230:	e8 3c 12 00 00       	call   801471 <close_all>
	sys_env_destroy(0);
  800235:	83 ec 0c             	sub    $0xc,%esp
  800238:	6a 00                	push   $0x0
  80023a:	e8 05 0a 00 00       	call   800c44 <sys_env_destroy>
}
  80023f:	83 c4 10             	add    $0x10,%esp
  800242:	c9                   	leave  
  800243:	c3                   	ret    

00800244 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800244:	55                   	push   %ebp
  800245:	89 e5                	mov    %esp,%ebp
  800247:	56                   	push   %esi
  800248:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800249:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80024c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800252:	e8 2e 0a 00 00       	call   800c85 <sys_getenvid>
  800257:	83 ec 0c             	sub    $0xc,%esp
  80025a:	ff 75 0c             	pushl  0xc(%ebp)
  80025d:	ff 75 08             	pushl  0x8(%ebp)
  800260:	56                   	push   %esi
  800261:	50                   	push   %eax
  800262:	68 00 24 80 00       	push   $0x802400
  800267:	e8 b1 00 00 00       	call   80031d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80026c:	83 c4 18             	add    $0x18,%esp
  80026f:	53                   	push   %ebx
  800270:	ff 75 10             	pushl  0x10(%ebp)
  800273:	e8 54 00 00 00       	call   8002cc <vcprintf>
	cprintf("\n");
  800278:	c7 04 24 17 23 80 00 	movl   $0x802317,(%esp)
  80027f:	e8 99 00 00 00       	call   80031d <cprintf>
  800284:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800287:	cc                   	int3   
  800288:	eb fd                	jmp    800287 <_panic+0x43>

0080028a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	53                   	push   %ebx
  80028e:	83 ec 04             	sub    $0x4,%esp
  800291:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800294:	8b 13                	mov    (%ebx),%edx
  800296:	8d 42 01             	lea    0x1(%edx),%eax
  800299:	89 03                	mov    %eax,(%ebx)
  80029b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80029e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002a2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002a7:	75 1a                	jne    8002c3 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002a9:	83 ec 08             	sub    $0x8,%esp
  8002ac:	68 ff 00 00 00       	push   $0xff
  8002b1:	8d 43 08             	lea    0x8(%ebx),%eax
  8002b4:	50                   	push   %eax
  8002b5:	e8 4d 09 00 00       	call   800c07 <sys_cputs>
		b->idx = 0;
  8002ba:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002c0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002c3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002ca:	c9                   	leave  
  8002cb:	c3                   	ret    

008002cc <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002d5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002dc:	00 00 00 
	b.cnt = 0;
  8002df:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002e6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002e9:	ff 75 0c             	pushl  0xc(%ebp)
  8002ec:	ff 75 08             	pushl  0x8(%ebp)
  8002ef:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002f5:	50                   	push   %eax
  8002f6:	68 8a 02 80 00       	push   $0x80028a
  8002fb:	e8 54 01 00 00       	call   800454 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800300:	83 c4 08             	add    $0x8,%esp
  800303:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800309:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80030f:	50                   	push   %eax
  800310:	e8 f2 08 00 00       	call   800c07 <sys_cputs>

	return b.cnt;
}
  800315:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80031b:	c9                   	leave  
  80031c:	c3                   	ret    

0080031d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80031d:	55                   	push   %ebp
  80031e:	89 e5                	mov    %esp,%ebp
  800320:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800323:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800326:	50                   	push   %eax
  800327:	ff 75 08             	pushl  0x8(%ebp)
  80032a:	e8 9d ff ff ff       	call   8002cc <vcprintf>
	va_end(ap);

	return cnt;
}
  80032f:	c9                   	leave  
  800330:	c3                   	ret    

00800331 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800331:	55                   	push   %ebp
  800332:	89 e5                	mov    %esp,%ebp
  800334:	57                   	push   %edi
  800335:	56                   	push   %esi
  800336:	53                   	push   %ebx
  800337:	83 ec 1c             	sub    $0x1c,%esp
  80033a:	89 c7                	mov    %eax,%edi
  80033c:	89 d6                	mov    %edx,%esi
  80033e:	8b 45 08             	mov    0x8(%ebp),%eax
  800341:	8b 55 0c             	mov    0xc(%ebp),%edx
  800344:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800347:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80034a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80034d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800352:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800355:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800358:	39 d3                	cmp    %edx,%ebx
  80035a:	72 05                	jb     800361 <printnum+0x30>
  80035c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80035f:	77 45                	ja     8003a6 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800361:	83 ec 0c             	sub    $0xc,%esp
  800364:	ff 75 18             	pushl  0x18(%ebp)
  800367:	8b 45 14             	mov    0x14(%ebp),%eax
  80036a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80036d:	53                   	push   %ebx
  80036e:	ff 75 10             	pushl  0x10(%ebp)
  800371:	83 ec 08             	sub    $0x8,%esp
  800374:	ff 75 e4             	pushl  -0x1c(%ebp)
  800377:	ff 75 e0             	pushl  -0x20(%ebp)
  80037a:	ff 75 dc             	pushl  -0x24(%ebp)
  80037d:	ff 75 d8             	pushl  -0x28(%ebp)
  800380:	e8 db 1c 00 00       	call   802060 <__udivdi3>
  800385:	83 c4 18             	add    $0x18,%esp
  800388:	52                   	push   %edx
  800389:	50                   	push   %eax
  80038a:	89 f2                	mov    %esi,%edx
  80038c:	89 f8                	mov    %edi,%eax
  80038e:	e8 9e ff ff ff       	call   800331 <printnum>
  800393:	83 c4 20             	add    $0x20,%esp
  800396:	eb 18                	jmp    8003b0 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800398:	83 ec 08             	sub    $0x8,%esp
  80039b:	56                   	push   %esi
  80039c:	ff 75 18             	pushl  0x18(%ebp)
  80039f:	ff d7                	call   *%edi
  8003a1:	83 c4 10             	add    $0x10,%esp
  8003a4:	eb 03                	jmp    8003a9 <printnum+0x78>
  8003a6:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003a9:	83 eb 01             	sub    $0x1,%ebx
  8003ac:	85 db                	test   %ebx,%ebx
  8003ae:	7f e8                	jg     800398 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003b0:	83 ec 08             	sub    $0x8,%esp
  8003b3:	56                   	push   %esi
  8003b4:	83 ec 04             	sub    $0x4,%esp
  8003b7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003ba:	ff 75 e0             	pushl  -0x20(%ebp)
  8003bd:	ff 75 dc             	pushl  -0x24(%ebp)
  8003c0:	ff 75 d8             	pushl  -0x28(%ebp)
  8003c3:	e8 c8 1d 00 00       	call   802190 <__umoddi3>
  8003c8:	83 c4 14             	add    $0x14,%esp
  8003cb:	0f be 80 23 24 80 00 	movsbl 0x802423(%eax),%eax
  8003d2:	50                   	push   %eax
  8003d3:	ff d7                	call   *%edi
}
  8003d5:	83 c4 10             	add    $0x10,%esp
  8003d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003db:	5b                   	pop    %ebx
  8003dc:	5e                   	pop    %esi
  8003dd:	5f                   	pop    %edi
  8003de:	5d                   	pop    %ebp
  8003df:	c3                   	ret    

008003e0 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003e0:	55                   	push   %ebp
  8003e1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003e3:	83 fa 01             	cmp    $0x1,%edx
  8003e6:	7e 0e                	jle    8003f6 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003e8:	8b 10                	mov    (%eax),%edx
  8003ea:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003ed:	89 08                	mov    %ecx,(%eax)
  8003ef:	8b 02                	mov    (%edx),%eax
  8003f1:	8b 52 04             	mov    0x4(%edx),%edx
  8003f4:	eb 22                	jmp    800418 <getuint+0x38>
	else if (lflag)
  8003f6:	85 d2                	test   %edx,%edx
  8003f8:	74 10                	je     80040a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003fa:	8b 10                	mov    (%eax),%edx
  8003fc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ff:	89 08                	mov    %ecx,(%eax)
  800401:	8b 02                	mov    (%edx),%eax
  800403:	ba 00 00 00 00       	mov    $0x0,%edx
  800408:	eb 0e                	jmp    800418 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80040a:	8b 10                	mov    (%eax),%edx
  80040c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80040f:	89 08                	mov    %ecx,(%eax)
  800411:	8b 02                	mov    (%edx),%eax
  800413:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800418:	5d                   	pop    %ebp
  800419:	c3                   	ret    

0080041a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80041a:	55                   	push   %ebp
  80041b:	89 e5                	mov    %esp,%ebp
  80041d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800420:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800424:	8b 10                	mov    (%eax),%edx
  800426:	3b 50 04             	cmp    0x4(%eax),%edx
  800429:	73 0a                	jae    800435 <sprintputch+0x1b>
		*b->buf++ = ch;
  80042b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80042e:	89 08                	mov    %ecx,(%eax)
  800430:	8b 45 08             	mov    0x8(%ebp),%eax
  800433:	88 02                	mov    %al,(%edx)
}
  800435:	5d                   	pop    %ebp
  800436:	c3                   	ret    

00800437 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800437:	55                   	push   %ebp
  800438:	89 e5                	mov    %esp,%ebp
  80043a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80043d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800440:	50                   	push   %eax
  800441:	ff 75 10             	pushl  0x10(%ebp)
  800444:	ff 75 0c             	pushl  0xc(%ebp)
  800447:	ff 75 08             	pushl  0x8(%ebp)
  80044a:	e8 05 00 00 00       	call   800454 <vprintfmt>
	va_end(ap);
}
  80044f:	83 c4 10             	add    $0x10,%esp
  800452:	c9                   	leave  
  800453:	c3                   	ret    

00800454 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800454:	55                   	push   %ebp
  800455:	89 e5                	mov    %esp,%ebp
  800457:	57                   	push   %edi
  800458:	56                   	push   %esi
  800459:	53                   	push   %ebx
  80045a:	83 ec 2c             	sub    $0x2c,%esp
  80045d:	8b 75 08             	mov    0x8(%ebp),%esi
  800460:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800463:	8b 7d 10             	mov    0x10(%ebp),%edi
  800466:	eb 12                	jmp    80047a <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800468:	85 c0                	test   %eax,%eax
  80046a:	0f 84 a7 03 00 00    	je     800817 <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
  800470:	83 ec 08             	sub    $0x8,%esp
  800473:	53                   	push   %ebx
  800474:	50                   	push   %eax
  800475:	ff d6                	call   *%esi
  800477:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80047a:	83 c7 01             	add    $0x1,%edi
  80047d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800481:	83 f8 25             	cmp    $0x25,%eax
  800484:	75 e2                	jne    800468 <vprintfmt+0x14>
  800486:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80048a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800491:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800498:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80049f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8004a6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004ab:	eb 07                	jmp    8004b4 <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004b0:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b4:	8d 47 01             	lea    0x1(%edi),%eax
  8004b7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004ba:	0f b6 07             	movzbl (%edi),%eax
  8004bd:	0f b6 d0             	movzbl %al,%edx
  8004c0:	83 e8 23             	sub    $0x23,%eax
  8004c3:	3c 55                	cmp    $0x55,%al
  8004c5:	0f 87 31 03 00 00    	ja     8007fc <vprintfmt+0x3a8>
  8004cb:	0f b6 c0             	movzbl %al,%eax
  8004ce:	ff 24 85 60 25 80 00 	jmp    *0x802560(,%eax,4)
  8004d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004d8:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004dc:	eb d6                	jmp    8004b4 <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8004e6:	89 75 08             	mov    %esi,0x8(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004e9:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004ec:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8004f0:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8004f3:	8d 72 d0             	lea    -0x30(%edx),%esi
  8004f6:	83 fe 09             	cmp    $0x9,%esi
  8004f9:	77 34                	ja     80052f <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004fb:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004fe:	eb e9                	jmp    8004e9 <vprintfmt+0x95>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800500:	8b 45 14             	mov    0x14(%ebp),%eax
  800503:	8d 50 04             	lea    0x4(%eax),%edx
  800506:	89 55 14             	mov    %edx,0x14(%ebp)
  800509:	8b 00                	mov    (%eax),%eax
  80050b:	89 45 cc             	mov    %eax,-0x34(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800511:	eb 22                	jmp    800535 <vprintfmt+0xe1>
  800513:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800516:	85 c0                	test   %eax,%eax
  800518:	0f 48 c1             	cmovs  %ecx,%eax
  80051b:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800521:	eb 91                	jmp    8004b4 <vprintfmt+0x60>
  800523:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800526:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80052d:	eb 85                	jmp    8004b4 <vprintfmt+0x60>
  80052f:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800532:	8b 75 08             	mov    0x8(%ebp),%esi

		process_precision:
			if (width < 0)
  800535:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800539:	0f 89 75 ff ff ff    	jns    8004b4 <vprintfmt+0x60>
				width = precision, precision = -1;
  80053f:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800542:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800545:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80054c:	e9 63 ff ff ff       	jmp    8004b4 <vprintfmt+0x60>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800551:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800555:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800558:	e9 57 ff ff ff       	jmp    8004b4 <vprintfmt+0x60>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80055d:	8b 45 14             	mov    0x14(%ebp),%eax
  800560:	8d 50 04             	lea    0x4(%eax),%edx
  800563:	89 55 14             	mov    %edx,0x14(%ebp)
  800566:	83 ec 08             	sub    $0x8,%esp
  800569:	53                   	push   %ebx
  80056a:	ff 30                	pushl  (%eax)
  80056c:	ff d6                	call   *%esi
			break;
  80056e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800571:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800574:	e9 01 ff ff ff       	jmp    80047a <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800579:	8b 45 14             	mov    0x14(%ebp),%eax
  80057c:	8d 50 04             	lea    0x4(%eax),%edx
  80057f:	89 55 14             	mov    %edx,0x14(%ebp)
  800582:	8b 00                	mov    (%eax),%eax
  800584:	99                   	cltd   
  800585:	31 d0                	xor    %edx,%eax
  800587:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800589:	83 f8 0f             	cmp    $0xf,%eax
  80058c:	7f 0b                	jg     800599 <vprintfmt+0x145>
  80058e:	8b 14 85 c0 26 80 00 	mov    0x8026c0(,%eax,4),%edx
  800595:	85 d2                	test   %edx,%edx
  800597:	75 18                	jne    8005b1 <vprintfmt+0x15d>
				printfmt(putch, putdat, "error %d", err);
  800599:	50                   	push   %eax
  80059a:	68 3b 24 80 00       	push   $0x80243b
  80059f:	53                   	push   %ebx
  8005a0:	56                   	push   %esi
  8005a1:	e8 91 fe ff ff       	call   800437 <printfmt>
  8005a6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005ac:	e9 c9 fe ff ff       	jmp    80047a <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8005b1:	52                   	push   %edx
  8005b2:	68 35 29 80 00       	push   $0x802935
  8005b7:	53                   	push   %ebx
  8005b8:	56                   	push   %esi
  8005b9:	e8 79 fe ff ff       	call   800437 <printfmt>
  8005be:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005c4:	e9 b1 fe ff ff       	jmp    80047a <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cc:	8d 50 04             	lea    0x4(%eax),%edx
  8005cf:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d2:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005d4:	85 ff                	test   %edi,%edi
  8005d6:	b8 34 24 80 00       	mov    $0x802434,%eax
  8005db:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005de:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005e2:	0f 8e 94 00 00 00    	jle    80067c <vprintfmt+0x228>
  8005e8:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005ec:	0f 84 98 00 00 00    	je     80068a <vprintfmt+0x236>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f2:	83 ec 08             	sub    $0x8,%esp
  8005f5:	ff 75 cc             	pushl  -0x34(%ebp)
  8005f8:	57                   	push   %edi
  8005f9:	e8 a1 02 00 00       	call   80089f <strnlen>
  8005fe:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800601:	29 c1                	sub    %eax,%ecx
  800603:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800606:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800609:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80060d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800610:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800613:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800615:	eb 0f                	jmp    800626 <vprintfmt+0x1d2>
					putch(padc, putdat);
  800617:	83 ec 08             	sub    $0x8,%esp
  80061a:	53                   	push   %ebx
  80061b:	ff 75 e0             	pushl  -0x20(%ebp)
  80061e:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800620:	83 ef 01             	sub    $0x1,%edi
  800623:	83 c4 10             	add    $0x10,%esp
  800626:	85 ff                	test   %edi,%edi
  800628:	7f ed                	jg     800617 <vprintfmt+0x1c3>
  80062a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80062d:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800630:	85 c9                	test   %ecx,%ecx
  800632:	b8 00 00 00 00       	mov    $0x0,%eax
  800637:	0f 49 c1             	cmovns %ecx,%eax
  80063a:	29 c1                	sub    %eax,%ecx
  80063c:	89 75 08             	mov    %esi,0x8(%ebp)
  80063f:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800642:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800645:	89 cb                	mov    %ecx,%ebx
  800647:	eb 4d                	jmp    800696 <vprintfmt+0x242>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800649:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80064d:	74 1b                	je     80066a <vprintfmt+0x216>
  80064f:	0f be c0             	movsbl %al,%eax
  800652:	83 e8 20             	sub    $0x20,%eax
  800655:	83 f8 5e             	cmp    $0x5e,%eax
  800658:	76 10                	jbe    80066a <vprintfmt+0x216>
					putch('?', putdat);
  80065a:	83 ec 08             	sub    $0x8,%esp
  80065d:	ff 75 0c             	pushl  0xc(%ebp)
  800660:	6a 3f                	push   $0x3f
  800662:	ff 55 08             	call   *0x8(%ebp)
  800665:	83 c4 10             	add    $0x10,%esp
  800668:	eb 0d                	jmp    800677 <vprintfmt+0x223>
				else
					putch(ch, putdat);
  80066a:	83 ec 08             	sub    $0x8,%esp
  80066d:	ff 75 0c             	pushl  0xc(%ebp)
  800670:	52                   	push   %edx
  800671:	ff 55 08             	call   *0x8(%ebp)
  800674:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800677:	83 eb 01             	sub    $0x1,%ebx
  80067a:	eb 1a                	jmp    800696 <vprintfmt+0x242>
  80067c:	89 75 08             	mov    %esi,0x8(%ebp)
  80067f:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800682:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800685:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800688:	eb 0c                	jmp    800696 <vprintfmt+0x242>
  80068a:	89 75 08             	mov    %esi,0x8(%ebp)
  80068d:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800690:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800693:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800696:	83 c7 01             	add    $0x1,%edi
  800699:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80069d:	0f be d0             	movsbl %al,%edx
  8006a0:	85 d2                	test   %edx,%edx
  8006a2:	74 23                	je     8006c7 <vprintfmt+0x273>
  8006a4:	85 f6                	test   %esi,%esi
  8006a6:	78 a1                	js     800649 <vprintfmt+0x1f5>
  8006a8:	83 ee 01             	sub    $0x1,%esi
  8006ab:	79 9c                	jns    800649 <vprintfmt+0x1f5>
  8006ad:	89 df                	mov    %ebx,%edi
  8006af:	8b 75 08             	mov    0x8(%ebp),%esi
  8006b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006b5:	eb 18                	jmp    8006cf <vprintfmt+0x27b>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006b7:	83 ec 08             	sub    $0x8,%esp
  8006ba:	53                   	push   %ebx
  8006bb:	6a 20                	push   $0x20
  8006bd:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006bf:	83 ef 01             	sub    $0x1,%edi
  8006c2:	83 c4 10             	add    $0x10,%esp
  8006c5:	eb 08                	jmp    8006cf <vprintfmt+0x27b>
  8006c7:	89 df                	mov    %ebx,%edi
  8006c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8006cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006cf:	85 ff                	test   %edi,%edi
  8006d1:	7f e4                	jg     8006b7 <vprintfmt+0x263>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006d6:	e9 9f fd ff ff       	jmp    80047a <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006db:	83 7d d0 01          	cmpl   $0x1,-0x30(%ebp)
  8006df:	7e 16                	jle    8006f7 <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  8006e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e4:	8d 50 08             	lea    0x8(%eax),%edx
  8006e7:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ea:	8b 50 04             	mov    0x4(%eax),%edx
  8006ed:	8b 00                	mov    (%eax),%eax
  8006ef:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006f2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006f5:	eb 34                	jmp    80072b <vprintfmt+0x2d7>
	else if (lflag)
  8006f7:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8006fb:	74 18                	je     800715 <vprintfmt+0x2c1>
		return va_arg(*ap, long);
  8006fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800700:	8d 50 04             	lea    0x4(%eax),%edx
  800703:	89 55 14             	mov    %edx,0x14(%ebp)
  800706:	8b 00                	mov    (%eax),%eax
  800708:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80070b:	89 c1                	mov    %eax,%ecx
  80070d:	c1 f9 1f             	sar    $0x1f,%ecx
  800710:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800713:	eb 16                	jmp    80072b <vprintfmt+0x2d7>
	else
		return va_arg(*ap, int);
  800715:	8b 45 14             	mov    0x14(%ebp),%eax
  800718:	8d 50 04             	lea    0x4(%eax),%edx
  80071b:	89 55 14             	mov    %edx,0x14(%ebp)
  80071e:	8b 00                	mov    (%eax),%eax
  800720:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800723:	89 c1                	mov    %eax,%ecx
  800725:	c1 f9 1f             	sar    $0x1f,%ecx
  800728:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80072b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80072e:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800731:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800736:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80073a:	0f 89 88 00 00 00    	jns    8007c8 <vprintfmt+0x374>
				putch('-', putdat);
  800740:	83 ec 08             	sub    $0x8,%esp
  800743:	53                   	push   %ebx
  800744:	6a 2d                	push   $0x2d
  800746:	ff d6                	call   *%esi
				num = -(long long) num;
  800748:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80074b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80074e:	f7 d8                	neg    %eax
  800750:	83 d2 00             	adc    $0x0,%edx
  800753:	f7 da                	neg    %edx
  800755:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800758:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80075d:	eb 69                	jmp    8007c8 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80075f:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800762:	8d 45 14             	lea    0x14(%ebp),%eax
  800765:	e8 76 fc ff ff       	call   8003e0 <getuint>
			base = 10;
  80076a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80076f:	eb 57                	jmp    8007c8 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  800771:	83 ec 08             	sub    $0x8,%esp
  800774:	53                   	push   %ebx
  800775:	6a 30                	push   $0x30
  800777:	ff d6                	call   *%esi
			num = getuint(&ap, lflag);
  800779:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80077c:	8d 45 14             	lea    0x14(%ebp),%eax
  80077f:	e8 5c fc ff ff       	call   8003e0 <getuint>
			base = 8;
			goto number;
  800784:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800787:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80078c:	eb 3a                	jmp    8007c8 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  80078e:	83 ec 08             	sub    $0x8,%esp
  800791:	53                   	push   %ebx
  800792:	6a 30                	push   $0x30
  800794:	ff d6                	call   *%esi
			putch('x', putdat);
  800796:	83 c4 08             	add    $0x8,%esp
  800799:	53                   	push   %ebx
  80079a:	6a 78                	push   $0x78
  80079c:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80079e:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a1:	8d 50 04             	lea    0x4(%eax),%edx
  8007a4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007a7:	8b 00                	mov    (%eax),%eax
  8007a9:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007ae:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007b1:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8007b6:	eb 10                	jmp    8007c8 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007b8:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8007bb:	8d 45 14             	lea    0x14(%ebp),%eax
  8007be:	e8 1d fc ff ff       	call   8003e0 <getuint>
			base = 16;
  8007c3:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007c8:	83 ec 0c             	sub    $0xc,%esp
  8007cb:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007cf:	57                   	push   %edi
  8007d0:	ff 75 e0             	pushl  -0x20(%ebp)
  8007d3:	51                   	push   %ecx
  8007d4:	52                   	push   %edx
  8007d5:	50                   	push   %eax
  8007d6:	89 da                	mov    %ebx,%edx
  8007d8:	89 f0                	mov    %esi,%eax
  8007da:	e8 52 fb ff ff       	call   800331 <printnum>
			break;
  8007df:	83 c4 20             	add    $0x20,%esp
  8007e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007e5:	e9 90 fc ff ff       	jmp    80047a <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007ea:	83 ec 08             	sub    $0x8,%esp
  8007ed:	53                   	push   %ebx
  8007ee:	52                   	push   %edx
  8007ef:	ff d6                	call   *%esi
			break;
  8007f1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007f7:	e9 7e fc ff ff       	jmp    80047a <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007fc:	83 ec 08             	sub    $0x8,%esp
  8007ff:	53                   	push   %ebx
  800800:	6a 25                	push   $0x25
  800802:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800804:	83 c4 10             	add    $0x10,%esp
  800807:	eb 03                	jmp    80080c <vprintfmt+0x3b8>
  800809:	83 ef 01             	sub    $0x1,%edi
  80080c:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800810:	75 f7                	jne    800809 <vprintfmt+0x3b5>
  800812:	e9 63 fc ff ff       	jmp    80047a <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800817:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80081a:	5b                   	pop    %ebx
  80081b:	5e                   	pop    %esi
  80081c:	5f                   	pop    %edi
  80081d:	5d                   	pop    %ebp
  80081e:	c3                   	ret    

0080081f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80081f:	55                   	push   %ebp
  800820:	89 e5                	mov    %esp,%ebp
  800822:	83 ec 18             	sub    $0x18,%esp
  800825:	8b 45 08             	mov    0x8(%ebp),%eax
  800828:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80082b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80082e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800832:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800835:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80083c:	85 c0                	test   %eax,%eax
  80083e:	74 26                	je     800866 <vsnprintf+0x47>
  800840:	85 d2                	test   %edx,%edx
  800842:	7e 22                	jle    800866 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800844:	ff 75 14             	pushl  0x14(%ebp)
  800847:	ff 75 10             	pushl  0x10(%ebp)
  80084a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80084d:	50                   	push   %eax
  80084e:	68 1a 04 80 00       	push   $0x80041a
  800853:	e8 fc fb ff ff       	call   800454 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800858:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80085b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80085e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800861:	83 c4 10             	add    $0x10,%esp
  800864:	eb 05                	jmp    80086b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800866:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80086b:	c9                   	leave  
  80086c:	c3                   	ret    

0080086d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80086d:	55                   	push   %ebp
  80086e:	89 e5                	mov    %esp,%ebp
  800870:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800873:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800876:	50                   	push   %eax
  800877:	ff 75 10             	pushl  0x10(%ebp)
  80087a:	ff 75 0c             	pushl  0xc(%ebp)
  80087d:	ff 75 08             	pushl  0x8(%ebp)
  800880:	e8 9a ff ff ff       	call   80081f <vsnprintf>
	va_end(ap);

	return rc;
}
  800885:	c9                   	leave  
  800886:	c3                   	ret    

00800887 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800887:	55                   	push   %ebp
  800888:	89 e5                	mov    %esp,%ebp
  80088a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80088d:	b8 00 00 00 00       	mov    $0x0,%eax
  800892:	eb 03                	jmp    800897 <strlen+0x10>
		n++;
  800894:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800897:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80089b:	75 f7                	jne    800894 <strlen+0xd>
		n++;
	return n;
}
  80089d:	5d                   	pop    %ebp
  80089e:	c3                   	ret    

0080089f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80089f:	55                   	push   %ebp
  8008a0:	89 e5                	mov    %esp,%ebp
  8008a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a5:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8008ad:	eb 03                	jmp    8008b2 <strnlen+0x13>
		n++;
  8008af:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008b2:	39 c2                	cmp    %eax,%edx
  8008b4:	74 08                	je     8008be <strnlen+0x1f>
  8008b6:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8008ba:	75 f3                	jne    8008af <strnlen+0x10>
  8008bc:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8008be:	5d                   	pop    %ebp
  8008bf:	c3                   	ret    

008008c0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
  8008c3:	53                   	push   %ebx
  8008c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008ca:	89 c2                	mov    %eax,%edx
  8008cc:	83 c2 01             	add    $0x1,%edx
  8008cf:	83 c1 01             	add    $0x1,%ecx
  8008d2:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008d6:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008d9:	84 db                	test   %bl,%bl
  8008db:	75 ef                	jne    8008cc <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008dd:	5b                   	pop    %ebx
  8008de:	5d                   	pop    %ebp
  8008df:	c3                   	ret    

008008e0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	53                   	push   %ebx
  8008e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008e7:	53                   	push   %ebx
  8008e8:	e8 9a ff ff ff       	call   800887 <strlen>
  8008ed:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008f0:	ff 75 0c             	pushl  0xc(%ebp)
  8008f3:	01 d8                	add    %ebx,%eax
  8008f5:	50                   	push   %eax
  8008f6:	e8 c5 ff ff ff       	call   8008c0 <strcpy>
	return dst;
}
  8008fb:	89 d8                	mov    %ebx,%eax
  8008fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800900:	c9                   	leave  
  800901:	c3                   	ret    

00800902 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800902:	55                   	push   %ebp
  800903:	89 e5                	mov    %esp,%ebp
  800905:	56                   	push   %esi
  800906:	53                   	push   %ebx
  800907:	8b 75 08             	mov    0x8(%ebp),%esi
  80090a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80090d:	89 f3                	mov    %esi,%ebx
  80090f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800912:	89 f2                	mov    %esi,%edx
  800914:	eb 0f                	jmp    800925 <strncpy+0x23>
		*dst++ = *src;
  800916:	83 c2 01             	add    $0x1,%edx
  800919:	0f b6 01             	movzbl (%ecx),%eax
  80091c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80091f:	80 39 01             	cmpb   $0x1,(%ecx)
  800922:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800925:	39 da                	cmp    %ebx,%edx
  800927:	75 ed                	jne    800916 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800929:	89 f0                	mov    %esi,%eax
  80092b:	5b                   	pop    %ebx
  80092c:	5e                   	pop    %esi
  80092d:	5d                   	pop    %ebp
  80092e:	c3                   	ret    

0080092f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
  800932:	56                   	push   %esi
  800933:	53                   	push   %ebx
  800934:	8b 75 08             	mov    0x8(%ebp),%esi
  800937:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80093a:	8b 55 10             	mov    0x10(%ebp),%edx
  80093d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80093f:	85 d2                	test   %edx,%edx
  800941:	74 21                	je     800964 <strlcpy+0x35>
  800943:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800947:	89 f2                	mov    %esi,%edx
  800949:	eb 09                	jmp    800954 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80094b:	83 c2 01             	add    $0x1,%edx
  80094e:	83 c1 01             	add    $0x1,%ecx
  800951:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800954:	39 c2                	cmp    %eax,%edx
  800956:	74 09                	je     800961 <strlcpy+0x32>
  800958:	0f b6 19             	movzbl (%ecx),%ebx
  80095b:	84 db                	test   %bl,%bl
  80095d:	75 ec                	jne    80094b <strlcpy+0x1c>
  80095f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800961:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800964:	29 f0                	sub    %esi,%eax
}
  800966:	5b                   	pop    %ebx
  800967:	5e                   	pop    %esi
  800968:	5d                   	pop    %ebp
  800969:	c3                   	ret    

0080096a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
  80096d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800970:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800973:	eb 06                	jmp    80097b <strcmp+0x11>
		p++, q++;
  800975:	83 c1 01             	add    $0x1,%ecx
  800978:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80097b:	0f b6 01             	movzbl (%ecx),%eax
  80097e:	84 c0                	test   %al,%al
  800980:	74 04                	je     800986 <strcmp+0x1c>
  800982:	3a 02                	cmp    (%edx),%al
  800984:	74 ef                	je     800975 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800986:	0f b6 c0             	movzbl %al,%eax
  800989:	0f b6 12             	movzbl (%edx),%edx
  80098c:	29 d0                	sub    %edx,%eax
}
  80098e:	5d                   	pop    %ebp
  80098f:	c3                   	ret    

00800990 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800990:	55                   	push   %ebp
  800991:	89 e5                	mov    %esp,%ebp
  800993:	53                   	push   %ebx
  800994:	8b 45 08             	mov    0x8(%ebp),%eax
  800997:	8b 55 0c             	mov    0xc(%ebp),%edx
  80099a:	89 c3                	mov    %eax,%ebx
  80099c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80099f:	eb 06                	jmp    8009a7 <strncmp+0x17>
		n--, p++, q++;
  8009a1:	83 c0 01             	add    $0x1,%eax
  8009a4:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009a7:	39 d8                	cmp    %ebx,%eax
  8009a9:	74 15                	je     8009c0 <strncmp+0x30>
  8009ab:	0f b6 08             	movzbl (%eax),%ecx
  8009ae:	84 c9                	test   %cl,%cl
  8009b0:	74 04                	je     8009b6 <strncmp+0x26>
  8009b2:	3a 0a                	cmp    (%edx),%cl
  8009b4:	74 eb                	je     8009a1 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009b6:	0f b6 00             	movzbl (%eax),%eax
  8009b9:	0f b6 12             	movzbl (%edx),%edx
  8009bc:	29 d0                	sub    %edx,%eax
  8009be:	eb 05                	jmp    8009c5 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009c0:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009c5:	5b                   	pop    %ebx
  8009c6:	5d                   	pop    %ebp
  8009c7:	c3                   	ret    

008009c8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009c8:	55                   	push   %ebp
  8009c9:	89 e5                	mov    %esp,%ebp
  8009cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ce:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009d2:	eb 07                	jmp    8009db <strchr+0x13>
		if (*s == c)
  8009d4:	38 ca                	cmp    %cl,%dl
  8009d6:	74 0f                	je     8009e7 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009d8:	83 c0 01             	add    $0x1,%eax
  8009db:	0f b6 10             	movzbl (%eax),%edx
  8009de:	84 d2                	test   %dl,%dl
  8009e0:	75 f2                	jne    8009d4 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009e2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e7:	5d                   	pop    %ebp
  8009e8:	c3                   	ret    

008009e9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009e9:	55                   	push   %ebp
  8009ea:	89 e5                	mov    %esp,%ebp
  8009ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ef:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009f3:	eb 03                	jmp    8009f8 <strfind+0xf>
  8009f5:	83 c0 01             	add    $0x1,%eax
  8009f8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009fb:	38 ca                	cmp    %cl,%dl
  8009fd:	74 04                	je     800a03 <strfind+0x1a>
  8009ff:	84 d2                	test   %dl,%dl
  800a01:	75 f2                	jne    8009f5 <strfind+0xc>
			break;
	return (char *) s;
}
  800a03:	5d                   	pop    %ebp
  800a04:	c3                   	ret    

00800a05 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a05:	55                   	push   %ebp
  800a06:	89 e5                	mov    %esp,%ebp
  800a08:	57                   	push   %edi
  800a09:	56                   	push   %esi
  800a0a:	53                   	push   %ebx
  800a0b:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a0e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a11:	85 c9                	test   %ecx,%ecx
  800a13:	74 36                	je     800a4b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a15:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a1b:	75 28                	jne    800a45 <memset+0x40>
  800a1d:	f6 c1 03             	test   $0x3,%cl
  800a20:	75 23                	jne    800a45 <memset+0x40>
		c &= 0xFF;
  800a22:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a26:	89 d3                	mov    %edx,%ebx
  800a28:	c1 e3 08             	shl    $0x8,%ebx
  800a2b:	89 d6                	mov    %edx,%esi
  800a2d:	c1 e6 18             	shl    $0x18,%esi
  800a30:	89 d0                	mov    %edx,%eax
  800a32:	c1 e0 10             	shl    $0x10,%eax
  800a35:	09 f0                	or     %esi,%eax
  800a37:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a39:	89 d8                	mov    %ebx,%eax
  800a3b:	09 d0                	or     %edx,%eax
  800a3d:	c1 e9 02             	shr    $0x2,%ecx
  800a40:	fc                   	cld    
  800a41:	f3 ab                	rep stos %eax,%es:(%edi)
  800a43:	eb 06                	jmp    800a4b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a45:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a48:	fc                   	cld    
  800a49:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a4b:	89 f8                	mov    %edi,%eax
  800a4d:	5b                   	pop    %ebx
  800a4e:	5e                   	pop    %esi
  800a4f:	5f                   	pop    %edi
  800a50:	5d                   	pop    %ebp
  800a51:	c3                   	ret    

00800a52 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a52:	55                   	push   %ebp
  800a53:	89 e5                	mov    %esp,%ebp
  800a55:	57                   	push   %edi
  800a56:	56                   	push   %esi
  800a57:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a5d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a60:	39 c6                	cmp    %eax,%esi
  800a62:	73 35                	jae    800a99 <memmove+0x47>
  800a64:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a67:	39 d0                	cmp    %edx,%eax
  800a69:	73 2e                	jae    800a99 <memmove+0x47>
		s += n;
		d += n;
  800a6b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a6e:	89 d6                	mov    %edx,%esi
  800a70:	09 fe                	or     %edi,%esi
  800a72:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a78:	75 13                	jne    800a8d <memmove+0x3b>
  800a7a:	f6 c1 03             	test   $0x3,%cl
  800a7d:	75 0e                	jne    800a8d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a7f:	83 ef 04             	sub    $0x4,%edi
  800a82:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a85:	c1 e9 02             	shr    $0x2,%ecx
  800a88:	fd                   	std    
  800a89:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a8b:	eb 09                	jmp    800a96 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a8d:	83 ef 01             	sub    $0x1,%edi
  800a90:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a93:	fd                   	std    
  800a94:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a96:	fc                   	cld    
  800a97:	eb 1d                	jmp    800ab6 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a99:	89 f2                	mov    %esi,%edx
  800a9b:	09 c2                	or     %eax,%edx
  800a9d:	f6 c2 03             	test   $0x3,%dl
  800aa0:	75 0f                	jne    800ab1 <memmove+0x5f>
  800aa2:	f6 c1 03             	test   $0x3,%cl
  800aa5:	75 0a                	jne    800ab1 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800aa7:	c1 e9 02             	shr    $0x2,%ecx
  800aaa:	89 c7                	mov    %eax,%edi
  800aac:	fc                   	cld    
  800aad:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aaf:	eb 05                	jmp    800ab6 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ab1:	89 c7                	mov    %eax,%edi
  800ab3:	fc                   	cld    
  800ab4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ab6:	5e                   	pop    %esi
  800ab7:	5f                   	pop    %edi
  800ab8:	5d                   	pop    %ebp
  800ab9:	c3                   	ret    

00800aba <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aba:	55                   	push   %ebp
  800abb:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800abd:	ff 75 10             	pushl  0x10(%ebp)
  800ac0:	ff 75 0c             	pushl  0xc(%ebp)
  800ac3:	ff 75 08             	pushl  0x8(%ebp)
  800ac6:	e8 87 ff ff ff       	call   800a52 <memmove>
}
  800acb:	c9                   	leave  
  800acc:	c3                   	ret    

00800acd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800acd:	55                   	push   %ebp
  800ace:	89 e5                	mov    %esp,%ebp
  800ad0:	56                   	push   %esi
  800ad1:	53                   	push   %ebx
  800ad2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ad8:	89 c6                	mov    %eax,%esi
  800ada:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800add:	eb 1a                	jmp    800af9 <memcmp+0x2c>
		if (*s1 != *s2)
  800adf:	0f b6 08             	movzbl (%eax),%ecx
  800ae2:	0f b6 1a             	movzbl (%edx),%ebx
  800ae5:	38 d9                	cmp    %bl,%cl
  800ae7:	74 0a                	je     800af3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ae9:	0f b6 c1             	movzbl %cl,%eax
  800aec:	0f b6 db             	movzbl %bl,%ebx
  800aef:	29 d8                	sub    %ebx,%eax
  800af1:	eb 0f                	jmp    800b02 <memcmp+0x35>
		s1++, s2++;
  800af3:	83 c0 01             	add    $0x1,%eax
  800af6:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800af9:	39 f0                	cmp    %esi,%eax
  800afb:	75 e2                	jne    800adf <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800afd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b02:	5b                   	pop    %ebx
  800b03:	5e                   	pop    %esi
  800b04:	5d                   	pop    %ebp
  800b05:	c3                   	ret    

00800b06 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b06:	55                   	push   %ebp
  800b07:	89 e5                	mov    %esp,%ebp
  800b09:	53                   	push   %ebx
  800b0a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b0d:	89 c1                	mov    %eax,%ecx
  800b0f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b12:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b16:	eb 0a                	jmp    800b22 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b18:	0f b6 10             	movzbl (%eax),%edx
  800b1b:	39 da                	cmp    %ebx,%edx
  800b1d:	74 07                	je     800b26 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b1f:	83 c0 01             	add    $0x1,%eax
  800b22:	39 c8                	cmp    %ecx,%eax
  800b24:	72 f2                	jb     800b18 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b26:	5b                   	pop    %ebx
  800b27:	5d                   	pop    %ebp
  800b28:	c3                   	ret    

00800b29 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b29:	55                   	push   %ebp
  800b2a:	89 e5                	mov    %esp,%ebp
  800b2c:	57                   	push   %edi
  800b2d:	56                   	push   %esi
  800b2e:	53                   	push   %ebx
  800b2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b32:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b35:	eb 03                	jmp    800b3a <strtol+0x11>
		s++;
  800b37:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b3a:	0f b6 01             	movzbl (%ecx),%eax
  800b3d:	3c 20                	cmp    $0x20,%al
  800b3f:	74 f6                	je     800b37 <strtol+0xe>
  800b41:	3c 09                	cmp    $0x9,%al
  800b43:	74 f2                	je     800b37 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b45:	3c 2b                	cmp    $0x2b,%al
  800b47:	75 0a                	jne    800b53 <strtol+0x2a>
		s++;
  800b49:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b4c:	bf 00 00 00 00       	mov    $0x0,%edi
  800b51:	eb 11                	jmp    800b64 <strtol+0x3b>
  800b53:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b58:	3c 2d                	cmp    $0x2d,%al
  800b5a:	75 08                	jne    800b64 <strtol+0x3b>
		s++, neg = 1;
  800b5c:	83 c1 01             	add    $0x1,%ecx
  800b5f:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b64:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b6a:	75 15                	jne    800b81 <strtol+0x58>
  800b6c:	80 39 30             	cmpb   $0x30,(%ecx)
  800b6f:	75 10                	jne    800b81 <strtol+0x58>
  800b71:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b75:	75 7c                	jne    800bf3 <strtol+0xca>
		s += 2, base = 16;
  800b77:	83 c1 02             	add    $0x2,%ecx
  800b7a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b7f:	eb 16                	jmp    800b97 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b81:	85 db                	test   %ebx,%ebx
  800b83:	75 12                	jne    800b97 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b85:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b8a:	80 39 30             	cmpb   $0x30,(%ecx)
  800b8d:	75 08                	jne    800b97 <strtol+0x6e>
		s++, base = 8;
  800b8f:	83 c1 01             	add    $0x1,%ecx
  800b92:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b97:	b8 00 00 00 00       	mov    $0x0,%eax
  800b9c:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b9f:	0f b6 11             	movzbl (%ecx),%edx
  800ba2:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ba5:	89 f3                	mov    %esi,%ebx
  800ba7:	80 fb 09             	cmp    $0x9,%bl
  800baa:	77 08                	ja     800bb4 <strtol+0x8b>
			dig = *s - '0';
  800bac:	0f be d2             	movsbl %dl,%edx
  800baf:	83 ea 30             	sub    $0x30,%edx
  800bb2:	eb 22                	jmp    800bd6 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800bb4:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bb7:	89 f3                	mov    %esi,%ebx
  800bb9:	80 fb 19             	cmp    $0x19,%bl
  800bbc:	77 08                	ja     800bc6 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800bbe:	0f be d2             	movsbl %dl,%edx
  800bc1:	83 ea 57             	sub    $0x57,%edx
  800bc4:	eb 10                	jmp    800bd6 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800bc6:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bc9:	89 f3                	mov    %esi,%ebx
  800bcb:	80 fb 19             	cmp    $0x19,%bl
  800bce:	77 16                	ja     800be6 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800bd0:	0f be d2             	movsbl %dl,%edx
  800bd3:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800bd6:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bd9:	7d 0b                	jge    800be6 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800bdb:	83 c1 01             	add    $0x1,%ecx
  800bde:	0f af 45 10          	imul   0x10(%ebp),%eax
  800be2:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800be4:	eb b9                	jmp    800b9f <strtol+0x76>

	if (endptr)
  800be6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bea:	74 0d                	je     800bf9 <strtol+0xd0>
		*endptr = (char *) s;
  800bec:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bef:	89 0e                	mov    %ecx,(%esi)
  800bf1:	eb 06                	jmp    800bf9 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bf3:	85 db                	test   %ebx,%ebx
  800bf5:	74 98                	je     800b8f <strtol+0x66>
  800bf7:	eb 9e                	jmp    800b97 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800bf9:	89 c2                	mov    %eax,%edx
  800bfb:	f7 da                	neg    %edx
  800bfd:	85 ff                	test   %edi,%edi
  800bff:	0f 45 c2             	cmovne %edx,%eax
}
  800c02:	5b                   	pop    %ebx
  800c03:	5e                   	pop    %esi
  800c04:	5f                   	pop    %edi
  800c05:	5d                   	pop    %ebp
  800c06:	c3                   	ret    

00800c07 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c07:	55                   	push   %ebp
  800c08:	89 e5                	mov    %esp,%ebp
  800c0a:	57                   	push   %edi
  800c0b:	56                   	push   %esi
  800c0c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0d:	b8 00 00 00 00       	mov    $0x0,%eax
  800c12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c15:	8b 55 08             	mov    0x8(%ebp),%edx
  800c18:	89 c3                	mov    %eax,%ebx
  800c1a:	89 c7                	mov    %eax,%edi
  800c1c:	89 c6                	mov    %eax,%esi
  800c1e:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c20:	5b                   	pop    %ebx
  800c21:	5e                   	pop    %esi
  800c22:	5f                   	pop    %edi
  800c23:	5d                   	pop    %ebp
  800c24:	c3                   	ret    

00800c25 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c25:	55                   	push   %ebp
  800c26:	89 e5                	mov    %esp,%ebp
  800c28:	57                   	push   %edi
  800c29:	56                   	push   %esi
  800c2a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c30:	b8 01 00 00 00       	mov    $0x1,%eax
  800c35:	89 d1                	mov    %edx,%ecx
  800c37:	89 d3                	mov    %edx,%ebx
  800c39:	89 d7                	mov    %edx,%edi
  800c3b:	89 d6                	mov    %edx,%esi
  800c3d:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c3f:	5b                   	pop    %ebx
  800c40:	5e                   	pop    %esi
  800c41:	5f                   	pop    %edi
  800c42:	5d                   	pop    %ebp
  800c43:	c3                   	ret    

00800c44 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c44:	55                   	push   %ebp
  800c45:	89 e5                	mov    %esp,%ebp
  800c47:	57                   	push   %edi
  800c48:	56                   	push   %esi
  800c49:	53                   	push   %ebx
  800c4a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c52:	b8 03 00 00 00       	mov    $0x3,%eax
  800c57:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5a:	89 cb                	mov    %ecx,%ebx
  800c5c:	89 cf                	mov    %ecx,%edi
  800c5e:	89 ce                	mov    %ecx,%esi
  800c60:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c62:	85 c0                	test   %eax,%eax
  800c64:	7e 17                	jle    800c7d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c66:	83 ec 0c             	sub    $0xc,%esp
  800c69:	50                   	push   %eax
  800c6a:	6a 03                	push   $0x3
  800c6c:	68 1f 27 80 00       	push   $0x80271f
  800c71:	6a 23                	push   $0x23
  800c73:	68 3c 27 80 00       	push   $0x80273c
  800c78:	e8 c7 f5 ff ff       	call   800244 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c80:	5b                   	pop    %ebx
  800c81:	5e                   	pop    %esi
  800c82:	5f                   	pop    %edi
  800c83:	5d                   	pop    %ebp
  800c84:	c3                   	ret    

00800c85 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c85:	55                   	push   %ebp
  800c86:	89 e5                	mov    %esp,%ebp
  800c88:	57                   	push   %edi
  800c89:	56                   	push   %esi
  800c8a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c90:	b8 02 00 00 00       	mov    $0x2,%eax
  800c95:	89 d1                	mov    %edx,%ecx
  800c97:	89 d3                	mov    %edx,%ebx
  800c99:	89 d7                	mov    %edx,%edi
  800c9b:	89 d6                	mov    %edx,%esi
  800c9d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c9f:	5b                   	pop    %ebx
  800ca0:	5e                   	pop    %esi
  800ca1:	5f                   	pop    %edi
  800ca2:	5d                   	pop    %ebp
  800ca3:	c3                   	ret    

00800ca4 <sys_yield>:

void
sys_yield(void)
{
  800ca4:	55                   	push   %ebp
  800ca5:	89 e5                	mov    %esp,%ebp
  800ca7:	57                   	push   %edi
  800ca8:	56                   	push   %esi
  800ca9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800caa:	ba 00 00 00 00       	mov    $0x0,%edx
  800caf:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cb4:	89 d1                	mov    %edx,%ecx
  800cb6:	89 d3                	mov    %edx,%ebx
  800cb8:	89 d7                	mov    %edx,%edi
  800cba:	89 d6                	mov    %edx,%esi
  800cbc:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cbe:	5b                   	pop    %ebx
  800cbf:	5e                   	pop    %esi
  800cc0:	5f                   	pop    %edi
  800cc1:	5d                   	pop    %ebp
  800cc2:	c3                   	ret    

00800cc3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cc3:	55                   	push   %ebp
  800cc4:	89 e5                	mov    %esp,%ebp
  800cc6:	57                   	push   %edi
  800cc7:	56                   	push   %esi
  800cc8:	53                   	push   %ebx
  800cc9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccc:	be 00 00 00 00       	mov    $0x0,%esi
  800cd1:	b8 04 00 00 00       	mov    $0x4,%eax
  800cd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cdf:	89 f7                	mov    %esi,%edi
  800ce1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce3:	85 c0                	test   %eax,%eax
  800ce5:	7e 17                	jle    800cfe <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce7:	83 ec 0c             	sub    $0xc,%esp
  800cea:	50                   	push   %eax
  800ceb:	6a 04                	push   $0x4
  800ced:	68 1f 27 80 00       	push   $0x80271f
  800cf2:	6a 23                	push   $0x23
  800cf4:	68 3c 27 80 00       	push   $0x80273c
  800cf9:	e8 46 f5 ff ff       	call   800244 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d01:	5b                   	pop    %ebx
  800d02:	5e                   	pop    %esi
  800d03:	5f                   	pop    %edi
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    

00800d06 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	57                   	push   %edi
  800d0a:	56                   	push   %esi
  800d0b:	53                   	push   %ebx
  800d0c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0f:	b8 05 00 00 00       	mov    $0x5,%eax
  800d14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d17:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d1d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d20:	8b 75 18             	mov    0x18(%ebp),%esi
  800d23:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d25:	85 c0                	test   %eax,%eax
  800d27:	7e 17                	jle    800d40 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d29:	83 ec 0c             	sub    $0xc,%esp
  800d2c:	50                   	push   %eax
  800d2d:	6a 05                	push   $0x5
  800d2f:	68 1f 27 80 00       	push   $0x80271f
  800d34:	6a 23                	push   $0x23
  800d36:	68 3c 27 80 00       	push   $0x80273c
  800d3b:	e8 04 f5 ff ff       	call   800244 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d43:	5b                   	pop    %ebx
  800d44:	5e                   	pop    %esi
  800d45:	5f                   	pop    %edi
  800d46:	5d                   	pop    %ebp
  800d47:	c3                   	ret    

00800d48 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d48:	55                   	push   %ebp
  800d49:	89 e5                	mov    %esp,%ebp
  800d4b:	57                   	push   %edi
  800d4c:	56                   	push   %esi
  800d4d:	53                   	push   %ebx
  800d4e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d51:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d56:	b8 06 00 00 00       	mov    $0x6,%eax
  800d5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d61:	89 df                	mov    %ebx,%edi
  800d63:	89 de                	mov    %ebx,%esi
  800d65:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d67:	85 c0                	test   %eax,%eax
  800d69:	7e 17                	jle    800d82 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6b:	83 ec 0c             	sub    $0xc,%esp
  800d6e:	50                   	push   %eax
  800d6f:	6a 06                	push   $0x6
  800d71:	68 1f 27 80 00       	push   $0x80271f
  800d76:	6a 23                	push   $0x23
  800d78:	68 3c 27 80 00       	push   $0x80273c
  800d7d:	e8 c2 f4 ff ff       	call   800244 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d82:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d85:	5b                   	pop    %ebx
  800d86:	5e                   	pop    %esi
  800d87:	5f                   	pop    %edi
  800d88:	5d                   	pop    %ebp
  800d89:	c3                   	ret    

00800d8a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d8a:	55                   	push   %ebp
  800d8b:	89 e5                	mov    %esp,%ebp
  800d8d:	57                   	push   %edi
  800d8e:	56                   	push   %esi
  800d8f:	53                   	push   %ebx
  800d90:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d93:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d98:	b8 08 00 00 00       	mov    $0x8,%eax
  800d9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da0:	8b 55 08             	mov    0x8(%ebp),%edx
  800da3:	89 df                	mov    %ebx,%edi
  800da5:	89 de                	mov    %ebx,%esi
  800da7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800da9:	85 c0                	test   %eax,%eax
  800dab:	7e 17                	jle    800dc4 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dad:	83 ec 0c             	sub    $0xc,%esp
  800db0:	50                   	push   %eax
  800db1:	6a 08                	push   $0x8
  800db3:	68 1f 27 80 00       	push   $0x80271f
  800db8:	6a 23                	push   $0x23
  800dba:	68 3c 27 80 00       	push   $0x80273c
  800dbf:	e8 80 f4 ff ff       	call   800244 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dc4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc7:	5b                   	pop    %ebx
  800dc8:	5e                   	pop    %esi
  800dc9:	5f                   	pop    %edi
  800dca:	5d                   	pop    %ebp
  800dcb:	c3                   	ret    

00800dcc <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dcc:	55                   	push   %ebp
  800dcd:	89 e5                	mov    %esp,%ebp
  800dcf:	57                   	push   %edi
  800dd0:	56                   	push   %esi
  800dd1:	53                   	push   %ebx
  800dd2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dda:	b8 09 00 00 00       	mov    $0x9,%eax
  800ddf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de2:	8b 55 08             	mov    0x8(%ebp),%edx
  800de5:	89 df                	mov    %ebx,%edi
  800de7:	89 de                	mov    %ebx,%esi
  800de9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800deb:	85 c0                	test   %eax,%eax
  800ded:	7e 17                	jle    800e06 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800def:	83 ec 0c             	sub    $0xc,%esp
  800df2:	50                   	push   %eax
  800df3:	6a 09                	push   $0x9
  800df5:	68 1f 27 80 00       	push   $0x80271f
  800dfa:	6a 23                	push   $0x23
  800dfc:	68 3c 27 80 00       	push   $0x80273c
  800e01:	e8 3e f4 ff ff       	call   800244 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e06:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e09:	5b                   	pop    %ebx
  800e0a:	5e                   	pop    %esi
  800e0b:	5f                   	pop    %edi
  800e0c:	5d                   	pop    %ebp
  800e0d:	c3                   	ret    

00800e0e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e0e:	55                   	push   %ebp
  800e0f:	89 e5                	mov    %esp,%ebp
  800e11:	57                   	push   %edi
  800e12:	56                   	push   %esi
  800e13:	53                   	push   %ebx
  800e14:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e17:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e1c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e21:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e24:	8b 55 08             	mov    0x8(%ebp),%edx
  800e27:	89 df                	mov    %ebx,%edi
  800e29:	89 de                	mov    %ebx,%esi
  800e2b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e2d:	85 c0                	test   %eax,%eax
  800e2f:	7e 17                	jle    800e48 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e31:	83 ec 0c             	sub    $0xc,%esp
  800e34:	50                   	push   %eax
  800e35:	6a 0a                	push   $0xa
  800e37:	68 1f 27 80 00       	push   $0x80271f
  800e3c:	6a 23                	push   $0x23
  800e3e:	68 3c 27 80 00       	push   $0x80273c
  800e43:	e8 fc f3 ff ff       	call   800244 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e48:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e4b:	5b                   	pop    %ebx
  800e4c:	5e                   	pop    %esi
  800e4d:	5f                   	pop    %edi
  800e4e:	5d                   	pop    %ebp
  800e4f:	c3                   	ret    

00800e50 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e50:	55                   	push   %ebp
  800e51:	89 e5                	mov    %esp,%ebp
  800e53:	57                   	push   %edi
  800e54:	56                   	push   %esi
  800e55:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e56:	be 00 00 00 00       	mov    $0x0,%esi
  800e5b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e63:	8b 55 08             	mov    0x8(%ebp),%edx
  800e66:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e69:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e6c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e6e:	5b                   	pop    %ebx
  800e6f:	5e                   	pop    %esi
  800e70:	5f                   	pop    %edi
  800e71:	5d                   	pop    %ebp
  800e72:	c3                   	ret    

00800e73 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e73:	55                   	push   %ebp
  800e74:	89 e5                	mov    %esp,%ebp
  800e76:	57                   	push   %edi
  800e77:	56                   	push   %esi
  800e78:	53                   	push   %ebx
  800e79:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e7c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e81:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e86:	8b 55 08             	mov    0x8(%ebp),%edx
  800e89:	89 cb                	mov    %ecx,%ebx
  800e8b:	89 cf                	mov    %ecx,%edi
  800e8d:	89 ce                	mov    %ecx,%esi
  800e8f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e91:	85 c0                	test   %eax,%eax
  800e93:	7e 17                	jle    800eac <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e95:	83 ec 0c             	sub    $0xc,%esp
  800e98:	50                   	push   %eax
  800e99:	6a 0d                	push   $0xd
  800e9b:	68 1f 27 80 00       	push   $0x80271f
  800ea0:	6a 23                	push   $0x23
  800ea2:	68 3c 27 80 00       	push   $0x80273c
  800ea7:	e8 98 f3 ff ff       	call   800244 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800eac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eaf:	5b                   	pop    %ebx
  800eb0:	5e                   	pop    %esi
  800eb1:	5f                   	pop    %edi
  800eb2:	5d                   	pop    %ebp
  800eb3:	c3                   	ret    

00800eb4 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800eb4:	55                   	push   %ebp
  800eb5:	89 e5                	mov    %esp,%ebp
  800eb7:	53                   	push   %ebx
  800eb8:	83 ec 04             	sub    $0x4,%esp
	int r;
	// LAB 4: Your code here.
    	pte_t *pte;
	int ret;
	// 用户空间的地址较低
	void *addr = (void *)(pn * PGSIZE);
  800ebb:	89 d3                	mov    %edx,%ebx
  800ebd:	c1 e3 0c             	shl    $0xc,%ebx
	if (uvpt[pn] & PTE_SHARE) {
  800ec0:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800ec7:	f6 c5 04             	test   $0x4,%ch
  800eca:	74 2f                	je     800efb <duppage+0x47>
		// cprintf("dup share page :%d\n", pn);
		if ((r = sys_page_map(0, addr, envid, addr, PTE_SYSCALL)) < 0)
  800ecc:	83 ec 0c             	sub    $0xc,%esp
  800ecf:	68 07 0e 00 00       	push   $0xe07
  800ed4:	53                   	push   %ebx
  800ed5:	50                   	push   %eax
  800ed6:	53                   	push   %ebx
  800ed7:	6a 00                	push   $0x0
  800ed9:	e8 28 fe ff ff       	call   800d06 <sys_page_map>
  800ede:	83 c4 20             	add    $0x20,%esp
  800ee1:	85 c0                	test   %eax,%eax
  800ee3:	0f 89 a0 00 00 00    	jns    800f89 <duppage+0xd5>
			panic("duppage sys_page_map:%e", r);
  800ee9:	50                   	push   %eax
  800eea:	68 4a 27 80 00       	push   $0x80274a
  800eef:	6a 4d                	push   $0x4d
  800ef1:	68 62 27 80 00       	push   $0x802762
  800ef6:	e8 49 f3 ff ff       	call   800244 <_panic>
	} else if (uvpt[pn] & (PTE_W|PTE_COW)) {
  800efb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f02:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800f08:	74 57                	je     800f61 <duppage+0xad>
		if ((r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  800f0a:	83 ec 0c             	sub    $0xc,%esp
  800f0d:	68 05 08 00 00       	push   $0x805
  800f12:	53                   	push   %ebx
  800f13:	50                   	push   %eax
  800f14:	53                   	push   %ebx
  800f15:	6a 00                	push   $0x0
  800f17:	e8 ea fd ff ff       	call   800d06 <sys_page_map>
  800f1c:	83 c4 20             	add    $0x20,%esp
  800f1f:	85 c0                	test   %eax,%eax
  800f21:	79 12                	jns    800f35 <duppage+0x81>
			panic("sys_page_map COW:%e", r);
  800f23:	50                   	push   %eax
  800f24:	68 6d 27 80 00       	push   $0x80276d
  800f29:	6a 50                	push   $0x50
  800f2b:	68 62 27 80 00       	push   $0x802762
  800f30:	e8 0f f3 ff ff       	call   800244 <_panic>

		if ((r = sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  800f35:	83 ec 0c             	sub    $0xc,%esp
  800f38:	68 05 08 00 00       	push   $0x805
  800f3d:	53                   	push   %ebx
  800f3e:	6a 00                	push   $0x0
  800f40:	53                   	push   %ebx
  800f41:	6a 00                	push   $0x0
  800f43:	e8 be fd ff ff       	call   800d06 <sys_page_map>
  800f48:	83 c4 20             	add    $0x20,%esp
  800f4b:	85 c0                	test   %eax,%eax
  800f4d:	79 3a                	jns    800f89 <duppage+0xd5>
			panic("sys_page_map COW:%e", r);
  800f4f:	50                   	push   %eax
  800f50:	68 6d 27 80 00       	push   $0x80276d
  800f55:	6a 53                	push   $0x53
  800f57:	68 62 27 80 00       	push   $0x802762
  800f5c:	e8 e3 f2 ff ff       	call   800244 <_panic>
	} else {
		if ((r = sys_page_map(0, addr, envid, addr, PTE_U|PTE_P)) < 0)
  800f61:	83 ec 0c             	sub    $0xc,%esp
  800f64:	6a 05                	push   $0x5
  800f66:	53                   	push   %ebx
  800f67:	50                   	push   %eax
  800f68:	53                   	push   %ebx
  800f69:	6a 00                	push   $0x0
  800f6b:	e8 96 fd ff ff       	call   800d06 <sys_page_map>
  800f70:	83 c4 20             	add    $0x20,%esp
  800f73:	85 c0                	test   %eax,%eax
  800f75:	79 12                	jns    800f89 <duppage+0xd5>
			panic("sys_page_map UP:%e", r);
  800f77:	50                   	push   %eax
  800f78:	68 81 27 80 00       	push   $0x802781
  800f7d:	6a 56                	push   $0x56
  800f7f:	68 62 27 80 00       	push   $0x802762
  800f84:	e8 bb f2 ff ff       	call   800244 <_panic>
	}
	return 0;
}
  800f89:	b8 00 00 00 00       	mov    $0x0,%eax
  800f8e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f91:	c9                   	leave  
  800f92:	c3                   	ret    

00800f93 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f93:	55                   	push   %ebp
  800f94:	89 e5                	mov    %esp,%ebp
  800f96:	56                   	push   %esi
  800f97:	53                   	push   %ebx
  800f98:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f9b:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (! ( (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  800f9d:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800fa1:	74 2d                	je     800fd0 <pgfault+0x3d>
  800fa3:	89 d8                	mov    %ebx,%eax
  800fa5:	c1 e8 16             	shr    $0x16,%eax
  800fa8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800faf:	a8 01                	test   $0x1,%al
  800fb1:	74 1d                	je     800fd0 <pgfault+0x3d>
  800fb3:	89 d8                	mov    %ebx,%eax
  800fb5:	c1 e8 0c             	shr    $0xc,%eax
  800fb8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fbf:	f6 c2 01             	test   $0x1,%dl
  800fc2:	74 0c                	je     800fd0 <pgfault+0x3d>
  800fc4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fcb:	f6 c4 08             	test   $0x8,%ah
  800fce:	75 14                	jne    800fe4 <pgfault+0x51>
        	panic("Neither the fault is a write nor COW page. \n");
  800fd0:	83 ec 04             	sub    $0x4,%esp
  800fd3:	68 00 28 80 00       	push   $0x802800
  800fd8:	6a 1d                	push   $0x1d
  800fda:	68 62 27 80 00       	push   $0x802762
  800fdf:	e8 60 f2 ff ff       	call   800244 <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.
	

    	envid_t envid = sys_getenvid();
  800fe4:	e8 9c fc ff ff       	call   800c85 <sys_getenvid>
  800fe9:	89 c6                	mov    %eax,%esi
    	// cprintf("pgfault: envid: %d\n", ENVX(envid));
    	// 临时页暂存
    	if ((r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P| PTE_W|PTE_U)) < 0)
  800feb:	83 ec 04             	sub    $0x4,%esp
  800fee:	6a 07                	push   $0x7
  800ff0:	68 00 f0 7f 00       	push   $0x7ff000
  800ff5:	50                   	push   %eax
  800ff6:	e8 c8 fc ff ff       	call   800cc3 <sys_page_alloc>
  800ffb:	83 c4 10             	add    $0x10,%esp
  800ffe:	85 c0                	test   %eax,%eax
  801000:	79 12                	jns    801014 <pgfault+0x81>
        	panic("pgfault: page allocation fault:%e\n", r);
  801002:	50                   	push   %eax
  801003:	68 30 28 80 00       	push   $0x802830
  801008:	6a 2b                	push   $0x2b
  80100a:	68 62 27 80 00       	push   $0x802762
  80100f:	e8 30 f2 ff ff       	call   800244 <_panic>
    	addr = ROUNDDOWN(addr, PGSIZE);
  801014:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  80101a:	83 ec 04             	sub    $0x4,%esp
  80101d:	68 00 10 00 00       	push   $0x1000
  801022:	53                   	push   %ebx
  801023:	68 00 f0 7f 00       	push   $0x7ff000
  801028:	e8 8d fa ff ff       	call   800aba <memcpy>
    	if ((r = sys_page_map(envid, (void *) PFTEMP, envid, addr , PTE_P|PTE_W|PTE_U)) < 0 )
  80102d:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801034:	53                   	push   %ebx
  801035:	56                   	push   %esi
  801036:	68 00 f0 7f 00       	push   $0x7ff000
  80103b:	56                   	push   %esi
  80103c:	e8 c5 fc ff ff       	call   800d06 <sys_page_map>
  801041:	83 c4 20             	add    $0x20,%esp
  801044:	85 c0                	test   %eax,%eax
  801046:	79 12                	jns    80105a <pgfault+0xc7>
        	panic("pgfault: page map failed %e\n", r);
  801048:	50                   	push   %eax
  801049:	68 94 27 80 00       	push   $0x802794
  80104e:	6a 2f                	push   $0x2f
  801050:	68 62 27 80 00       	push   $0x802762
  801055:	e8 ea f1 ff ff       	call   800244 <_panic>
    
    	if ((r = sys_page_unmap(envid, (void *) PFTEMP)) < 0)
  80105a:	83 ec 08             	sub    $0x8,%esp
  80105d:	68 00 f0 7f 00       	push   $0x7ff000
  801062:	56                   	push   %esi
  801063:	e8 e0 fc ff ff       	call   800d48 <sys_page_unmap>
  801068:	83 c4 10             	add    $0x10,%esp
  80106b:	85 c0                	test   %eax,%eax
  80106d:	79 12                	jns    801081 <pgfault+0xee>
        	panic("pgfault: page unmap failed %e\n", r);
  80106f:	50                   	push   %eax
  801070:	68 54 28 80 00       	push   $0x802854
  801075:	6a 32                	push   $0x32
  801077:	68 62 27 80 00       	push   $0x802762
  80107c:	e8 c3 f1 ff ff       	call   800244 <_panic>
	//panic("pgfault not implemented");
}
  801081:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801084:	5b                   	pop    %ebx
  801085:	5e                   	pop    %esi
  801086:	5d                   	pop    %ebp
  801087:	c3                   	ret    

00801088 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801088:	55                   	push   %ebp
  801089:	89 e5                	mov    %esp,%ebp
  80108b:	56                   	push   %esi
  80108c:	53                   	push   %ebx
  80108d:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	set_pgfault_handler(pgfault);
  801090:	68 93 0f 80 00       	push   $0x800f93
  801095:	e8 31 0f 00 00       	call   801fcb <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80109a:	b8 07 00 00 00       	mov    $0x7,%eax
  80109f:	cd 30                	int    $0x30
  8010a1:	89 c3                	mov    %eax,%ebx

	envid_t envid = sys_exofork();
	uint8_t *addr;
	if (envid < 0)
  8010a3:	83 c4 10             	add    $0x10,%esp
  8010a6:	85 c0                	test   %eax,%eax
  8010a8:	79 12                	jns    8010bc <fork+0x34>
		panic("sys_exofork:%e", envid);
  8010aa:	50                   	push   %eax
  8010ab:	68 b1 27 80 00       	push   $0x8027b1
  8010b0:	6a 75                	push   $0x75
  8010b2:	68 62 27 80 00       	push   $0x802762
  8010b7:	e8 88 f1 ff ff       	call   800244 <_panic>
  8010bc:	89 c6                	mov    %eax,%esi
	if (envid == 0) {
  8010be:	85 c0                	test   %eax,%eax
  8010c0:	75 21                	jne    8010e3 <fork+0x5b>
		thisenv = &envs[ENVX(sys_getenvid())];
  8010c2:	e8 be fb ff ff       	call   800c85 <sys_getenvid>
  8010c7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010cc:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010cf:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010d4:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  8010d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8010de:	e9 c0 00 00 00       	jmp    8011a3 <fork+0x11b>
	}

	for (addr = (uint8_t *)UTEXT; addr < (uint8_t *)USTACKTOP-PGSIZE; addr += PGSIZE) {
  8010e3:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  8010ea:	ba 00 00 80 00       	mov    $0x800000,%edx
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
  8010ef:	89 d0                	mov    %edx,%eax
  8010f1:	c1 e8 16             	shr    $0x16,%eax
  8010f4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010fb:	a8 01                	test   $0x1,%al
  8010fd:	74 20                	je     80111f <fork+0x97>
  8010ff:	c1 ea 0c             	shr    $0xc,%edx
  801102:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801109:	a8 01                	test   $0x1,%al
  80110b:	74 12                	je     80111f <fork+0x97>
				&& (uvpt[PGNUM(addr)] & PTE_U)) {
  80110d:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801114:	a8 04                	test   $0x4,%al
  801116:	74 07                	je     80111f <fork+0x97>
			duppage(envid, PGNUM(addr));
  801118:	89 f0                	mov    %esi,%eax
  80111a:	e8 95 fd ff ff       	call   800eb4 <duppage>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}

	for (addr = (uint8_t *)UTEXT; addr < (uint8_t *)USTACKTOP-PGSIZE; addr += PGSIZE) {
  80111f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801122:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
  801128:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80112b:	81 fa ff cf bf ee    	cmp    $0xeebfcfff,%edx
  801131:	76 bc                	jbe    8010ef <fork+0x67>
				&& (uvpt[PGNUM(addr)] & PTE_U)) {
			duppage(envid, PGNUM(addr));
		}
	}

	duppage(envid, PGNUM(ROUNDDOWN(&addr, PGSIZE)));
  801133:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801136:	c1 ea 0c             	shr    $0xc,%edx
  801139:	89 d8                	mov    %ebx,%eax
  80113b:	e8 74 fd ff ff       	call   800eb4 <duppage>

	int r;
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)))
  801140:	83 ec 04             	sub    $0x4,%esp
  801143:	6a 07                	push   $0x7
  801145:	68 00 f0 bf ee       	push   $0xeebff000
  80114a:	53                   	push   %ebx
  80114b:	e8 73 fb ff ff       	call   800cc3 <sys_page_alloc>
  801150:	83 c4 10             	add    $0x10,%esp
  801153:	85 c0                	test   %eax,%eax
  801155:	74 15                	je     80116c <fork+0xe4>
		panic("sys_page_alloc:%e", r);
  801157:	50                   	push   %eax
  801158:	68 c0 27 80 00       	push   $0x8027c0
  80115d:	68 86 00 00 00       	push   $0x86
  801162:	68 62 27 80 00       	push   $0x802762
  801167:	e8 d8 f0 ff ff       	call   800244 <_panic>

	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80116c:	83 ec 08             	sub    $0x8,%esp
  80116f:	68 33 20 80 00       	push   $0x802033
  801174:	53                   	push   %ebx
  801175:	e8 94 fc ff ff       	call   800e0e <sys_env_set_pgfault_upcall>

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)))
  80117a:	83 c4 08             	add    $0x8,%esp
  80117d:	6a 02                	push   $0x2
  80117f:	53                   	push   %ebx
  801180:	e8 05 fc ff ff       	call   800d8a <sys_env_set_status>
  801185:	83 c4 10             	add    $0x10,%esp
  801188:	85 c0                	test   %eax,%eax
  80118a:	74 15                	je     8011a1 <fork+0x119>
		panic("sys_env_set_status:%e", r);
  80118c:	50                   	push   %eax
  80118d:	68 d2 27 80 00       	push   $0x8027d2
  801192:	68 8c 00 00 00       	push   $0x8c
  801197:	68 62 27 80 00       	push   $0x802762
  80119c:	e8 a3 f0 ff ff       	call   800244 <_panic>

	return envid;
  8011a1:	89 d8                	mov    %ebx,%eax
	    
}
  8011a3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011a6:	5b                   	pop    %ebx
  8011a7:	5e                   	pop    %esi
  8011a8:	5d                   	pop    %ebp
  8011a9:	c3                   	ret    

008011aa <sfork>:

// Challenge!
int
sfork(void)
{
  8011aa:	55                   	push   %ebp
  8011ab:	89 e5                	mov    %esp,%ebp
  8011ad:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8011b0:	68 e8 27 80 00       	push   $0x8027e8
  8011b5:	68 96 00 00 00       	push   $0x96
  8011ba:	68 62 27 80 00       	push   $0x802762
  8011bf:	e8 80 f0 ff ff       	call   800244 <_panic>

008011c4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8011c4:	55                   	push   %ebp
  8011c5:	89 e5                	mov    %esp,%ebp
  8011c7:	56                   	push   %esi
  8011c8:	53                   	push   %ebx
  8011c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8011cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011cf:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_recv not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  8011d2:	85 c0                	test   %eax,%eax
  8011d4:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8011d9:	0f 44 c2             	cmove  %edx,%eax

    int r = sys_ipc_recv(pg);
  8011dc:	83 ec 0c             	sub    $0xc,%esp
  8011df:	50                   	push   %eax
  8011e0:	e8 8e fc ff ff       	call   800e73 <sys_ipc_recv>
    int from_env = 0, perm = 0;
    if (r == 0) {
  8011e5:	83 c4 10             	add    $0x10,%esp
  8011e8:	85 c0                	test   %eax,%eax
  8011ea:	75 10                	jne    8011fc <ipc_recv+0x38>
        from_env = thisenv->env_ipc_from;
  8011ec:	a1 04 40 80 00       	mov    0x804004,%eax
  8011f1:	8b 48 74             	mov    0x74(%eax),%ecx
        perm = thisenv->env_ipc_perm;
  8011f4:	8b 50 78             	mov    0x78(%eax),%edx
        r = thisenv->env_ipc_value;
  8011f7:	8b 40 70             	mov    0x70(%eax),%eax
  8011fa:	eb 0a                	jmp    801206 <ipc_recv+0x42>
    } else {
        from_env = 0;
        perm = 0;
  8011fc:	ba 00 00 00 00       	mov    $0x0,%edx
    if (r == 0) {
        from_env = thisenv->env_ipc_from;
        perm = thisenv->env_ipc_perm;
        r = thisenv->env_ipc_value;
    } else {
        from_env = 0;
  801201:	b9 00 00 00 00       	mov    $0x0,%ecx
        perm = 0;
    }

    if (from_env_store) *from_env_store = from_env;
  801206:	85 f6                	test   %esi,%esi
  801208:	74 02                	je     80120c <ipc_recv+0x48>
  80120a:	89 0e                	mov    %ecx,(%esi)
    if (perm_store) *perm_store = perm;
  80120c:	85 db                	test   %ebx,%ebx
  80120e:	74 02                	je     801212 <ipc_recv+0x4e>
  801210:	89 13                	mov    %edx,(%ebx)

    return r;
}
  801212:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801215:	5b                   	pop    %ebx
  801216:	5e                   	pop    %esi
  801217:	5d                   	pop    %ebp
  801218:	c3                   	ret    

00801219 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801219:	55                   	push   %ebp
  80121a:	89 e5                	mov    %esp,%ebp
  80121c:	57                   	push   %edi
  80121d:	56                   	push   %esi
  80121e:	53                   	push   %ebx
  80121f:	83 ec 0c             	sub    $0xc,%esp
  801222:	8b 7d 08             	mov    0x8(%ebp),%edi
  801225:	8b 75 0c             	mov    0xc(%ebp),%esi
  801228:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  80122b:	85 db                	test   %ebx,%ebx
  80122d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801232:	0f 44 d8             	cmove  %eax,%ebx
  801235:	eb 1c                	jmp    801253 <ipc_send+0x3a>

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        if (ret != -E_IPC_NOT_RECV)
  801237:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80123a:	74 12                	je     80124e <ipc_send+0x35>
            panic("ipc_send error %e", ret);
  80123c:	50                   	push   %eax
  80123d:	68 73 28 80 00       	push   $0x802873
  801242:	6a 40                	push   $0x40
  801244:	68 85 28 80 00       	push   $0x802885
  801249:	e8 f6 ef ff ff       	call   800244 <_panic>
        sys_yield();
  80124e:	e8 51 fa ff ff       	call   800ca4 <sys_yield>
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801253:	ff 75 14             	pushl  0x14(%ebp)
  801256:	53                   	push   %ebx
  801257:	56                   	push   %esi
  801258:	57                   	push   %edi
  801259:	e8 f2 fb ff ff       	call   800e50 <sys_ipc_try_send>
  80125e:	83 c4 10             	add    $0x10,%esp
  801261:	85 c0                	test   %eax,%eax
  801263:	75 d2                	jne    801237 <ipc_send+0x1e>
        if (ret != -E_IPC_NOT_RECV)
            panic("ipc_send error %e", ret);
        sys_yield();
    }
}
  801265:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801268:	5b                   	pop    %ebx
  801269:	5e                   	pop    %esi
  80126a:	5f                   	pop    %edi
  80126b:	5d                   	pop    %ebp
  80126c:	c3                   	ret    

0080126d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80126d:	55                   	push   %ebp
  80126e:	89 e5                	mov    %esp,%ebp
  801270:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801273:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801278:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80127b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801281:	8b 52 50             	mov    0x50(%edx),%edx
  801284:	39 ca                	cmp    %ecx,%edx
  801286:	75 0d                	jne    801295 <ipc_find_env+0x28>
			return envs[i].env_id;
  801288:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80128b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801290:	8b 40 48             	mov    0x48(%eax),%eax
  801293:	eb 0f                	jmp    8012a4 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801295:	83 c0 01             	add    $0x1,%eax
  801298:	3d 00 04 00 00       	cmp    $0x400,%eax
  80129d:	75 d9                	jne    801278 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80129f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012a4:	5d                   	pop    %ebp
  8012a5:	c3                   	ret    

008012a6 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012a6:	55                   	push   %ebp
  8012a7:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ac:	05 00 00 00 30       	add    $0x30000000,%eax
  8012b1:	c1 e8 0c             	shr    $0xc,%eax
}
  8012b4:	5d                   	pop    %ebp
  8012b5:	c3                   	ret    

008012b6 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012b6:	55                   	push   %ebp
  8012b7:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8012b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8012bc:	05 00 00 00 30       	add    $0x30000000,%eax
  8012c1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8012c6:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012cb:	5d                   	pop    %ebp
  8012cc:	c3                   	ret    

008012cd <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012cd:	55                   	push   %ebp
  8012ce:	89 e5                	mov    %esp,%ebp
  8012d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012d3:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012d8:	89 c2                	mov    %eax,%edx
  8012da:	c1 ea 16             	shr    $0x16,%edx
  8012dd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012e4:	f6 c2 01             	test   $0x1,%dl
  8012e7:	74 11                	je     8012fa <fd_alloc+0x2d>
  8012e9:	89 c2                	mov    %eax,%edx
  8012eb:	c1 ea 0c             	shr    $0xc,%edx
  8012ee:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012f5:	f6 c2 01             	test   $0x1,%dl
  8012f8:	75 09                	jne    801303 <fd_alloc+0x36>
			*fd_store = fd;
  8012fa:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012fc:	b8 00 00 00 00       	mov    $0x0,%eax
  801301:	eb 17                	jmp    80131a <fd_alloc+0x4d>
  801303:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801308:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80130d:	75 c9                	jne    8012d8 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80130f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801315:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80131a:	5d                   	pop    %ebp
  80131b:	c3                   	ret    

0080131c <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80131c:	55                   	push   %ebp
  80131d:	89 e5                	mov    %esp,%ebp
  80131f:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801322:	83 f8 1f             	cmp    $0x1f,%eax
  801325:	77 36                	ja     80135d <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801327:	c1 e0 0c             	shl    $0xc,%eax
  80132a:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80132f:	89 c2                	mov    %eax,%edx
  801331:	c1 ea 16             	shr    $0x16,%edx
  801334:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80133b:	f6 c2 01             	test   $0x1,%dl
  80133e:	74 24                	je     801364 <fd_lookup+0x48>
  801340:	89 c2                	mov    %eax,%edx
  801342:	c1 ea 0c             	shr    $0xc,%edx
  801345:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80134c:	f6 c2 01             	test   $0x1,%dl
  80134f:	74 1a                	je     80136b <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801351:	8b 55 0c             	mov    0xc(%ebp),%edx
  801354:	89 02                	mov    %eax,(%edx)
	return 0;
  801356:	b8 00 00 00 00       	mov    $0x0,%eax
  80135b:	eb 13                	jmp    801370 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80135d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801362:	eb 0c                	jmp    801370 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801364:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801369:	eb 05                	jmp    801370 <fd_lookup+0x54>
  80136b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801370:	5d                   	pop    %ebp
  801371:	c3                   	ret    

00801372 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801372:	55                   	push   %ebp
  801373:	89 e5                	mov    %esp,%ebp
  801375:	83 ec 08             	sub    $0x8,%esp
  801378:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80137b:	ba 0c 29 80 00       	mov    $0x80290c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801380:	eb 13                	jmp    801395 <dev_lookup+0x23>
  801382:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801385:	39 08                	cmp    %ecx,(%eax)
  801387:	75 0c                	jne    801395 <dev_lookup+0x23>
			*dev = devtab[i];
  801389:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80138c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80138e:	b8 00 00 00 00       	mov    $0x0,%eax
  801393:	eb 2e                	jmp    8013c3 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801395:	8b 02                	mov    (%edx),%eax
  801397:	85 c0                	test   %eax,%eax
  801399:	75 e7                	jne    801382 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80139b:	a1 04 40 80 00       	mov    0x804004,%eax
  8013a0:	8b 40 48             	mov    0x48(%eax),%eax
  8013a3:	83 ec 04             	sub    $0x4,%esp
  8013a6:	51                   	push   %ecx
  8013a7:	50                   	push   %eax
  8013a8:	68 90 28 80 00       	push   $0x802890
  8013ad:	e8 6b ef ff ff       	call   80031d <cprintf>
	*dev = 0;
  8013b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013b5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8013bb:	83 c4 10             	add    $0x10,%esp
  8013be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013c3:	c9                   	leave  
  8013c4:	c3                   	ret    

008013c5 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013c5:	55                   	push   %ebp
  8013c6:	89 e5                	mov    %esp,%ebp
  8013c8:	56                   	push   %esi
  8013c9:	53                   	push   %ebx
  8013ca:	83 ec 10             	sub    $0x10,%esp
  8013cd:	8b 75 08             	mov    0x8(%ebp),%esi
  8013d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013d6:	50                   	push   %eax
  8013d7:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8013dd:	c1 e8 0c             	shr    $0xc,%eax
  8013e0:	50                   	push   %eax
  8013e1:	e8 36 ff ff ff       	call   80131c <fd_lookup>
  8013e6:	83 c4 08             	add    $0x8,%esp
  8013e9:	85 c0                	test   %eax,%eax
  8013eb:	78 05                	js     8013f2 <fd_close+0x2d>
	    || fd != fd2)
  8013ed:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013f0:	74 0c                	je     8013fe <fd_close+0x39>
		return (must_exist ? r : 0);
  8013f2:	84 db                	test   %bl,%bl
  8013f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8013f9:	0f 44 c2             	cmove  %edx,%eax
  8013fc:	eb 41                	jmp    80143f <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013fe:	83 ec 08             	sub    $0x8,%esp
  801401:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801404:	50                   	push   %eax
  801405:	ff 36                	pushl  (%esi)
  801407:	e8 66 ff ff ff       	call   801372 <dev_lookup>
  80140c:	89 c3                	mov    %eax,%ebx
  80140e:	83 c4 10             	add    $0x10,%esp
  801411:	85 c0                	test   %eax,%eax
  801413:	78 1a                	js     80142f <fd_close+0x6a>
		if (dev->dev_close)
  801415:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801418:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80141b:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801420:	85 c0                	test   %eax,%eax
  801422:	74 0b                	je     80142f <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801424:	83 ec 0c             	sub    $0xc,%esp
  801427:	56                   	push   %esi
  801428:	ff d0                	call   *%eax
  80142a:	89 c3                	mov    %eax,%ebx
  80142c:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80142f:	83 ec 08             	sub    $0x8,%esp
  801432:	56                   	push   %esi
  801433:	6a 00                	push   $0x0
  801435:	e8 0e f9 ff ff       	call   800d48 <sys_page_unmap>
	return r;
  80143a:	83 c4 10             	add    $0x10,%esp
  80143d:	89 d8                	mov    %ebx,%eax
}
  80143f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801442:	5b                   	pop    %ebx
  801443:	5e                   	pop    %esi
  801444:	5d                   	pop    %ebp
  801445:	c3                   	ret    

00801446 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801446:	55                   	push   %ebp
  801447:	89 e5                	mov    %esp,%ebp
  801449:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80144c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80144f:	50                   	push   %eax
  801450:	ff 75 08             	pushl  0x8(%ebp)
  801453:	e8 c4 fe ff ff       	call   80131c <fd_lookup>
  801458:	83 c4 08             	add    $0x8,%esp
  80145b:	85 c0                	test   %eax,%eax
  80145d:	78 10                	js     80146f <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80145f:	83 ec 08             	sub    $0x8,%esp
  801462:	6a 01                	push   $0x1
  801464:	ff 75 f4             	pushl  -0xc(%ebp)
  801467:	e8 59 ff ff ff       	call   8013c5 <fd_close>
  80146c:	83 c4 10             	add    $0x10,%esp
}
  80146f:	c9                   	leave  
  801470:	c3                   	ret    

00801471 <close_all>:

void
close_all(void)
{
  801471:	55                   	push   %ebp
  801472:	89 e5                	mov    %esp,%ebp
  801474:	53                   	push   %ebx
  801475:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801478:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80147d:	83 ec 0c             	sub    $0xc,%esp
  801480:	53                   	push   %ebx
  801481:	e8 c0 ff ff ff       	call   801446 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801486:	83 c3 01             	add    $0x1,%ebx
  801489:	83 c4 10             	add    $0x10,%esp
  80148c:	83 fb 20             	cmp    $0x20,%ebx
  80148f:	75 ec                	jne    80147d <close_all+0xc>
		close(i);
}
  801491:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801494:	c9                   	leave  
  801495:	c3                   	ret    

00801496 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801496:	55                   	push   %ebp
  801497:	89 e5                	mov    %esp,%ebp
  801499:	57                   	push   %edi
  80149a:	56                   	push   %esi
  80149b:	53                   	push   %ebx
  80149c:	83 ec 2c             	sub    $0x2c,%esp
  80149f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014a2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014a5:	50                   	push   %eax
  8014a6:	ff 75 08             	pushl  0x8(%ebp)
  8014a9:	e8 6e fe ff ff       	call   80131c <fd_lookup>
  8014ae:	83 c4 08             	add    $0x8,%esp
  8014b1:	85 c0                	test   %eax,%eax
  8014b3:	0f 88 c1 00 00 00    	js     80157a <dup+0xe4>
		return r;
	close(newfdnum);
  8014b9:	83 ec 0c             	sub    $0xc,%esp
  8014bc:	56                   	push   %esi
  8014bd:	e8 84 ff ff ff       	call   801446 <close>

	newfd = INDEX2FD(newfdnum);
  8014c2:	89 f3                	mov    %esi,%ebx
  8014c4:	c1 e3 0c             	shl    $0xc,%ebx
  8014c7:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8014cd:	83 c4 04             	add    $0x4,%esp
  8014d0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014d3:	e8 de fd ff ff       	call   8012b6 <fd2data>
  8014d8:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8014da:	89 1c 24             	mov    %ebx,(%esp)
  8014dd:	e8 d4 fd ff ff       	call   8012b6 <fd2data>
  8014e2:	83 c4 10             	add    $0x10,%esp
  8014e5:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014e8:	89 f8                	mov    %edi,%eax
  8014ea:	c1 e8 16             	shr    $0x16,%eax
  8014ed:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014f4:	a8 01                	test   $0x1,%al
  8014f6:	74 37                	je     80152f <dup+0x99>
  8014f8:	89 f8                	mov    %edi,%eax
  8014fa:	c1 e8 0c             	shr    $0xc,%eax
  8014fd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801504:	f6 c2 01             	test   $0x1,%dl
  801507:	74 26                	je     80152f <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801509:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801510:	83 ec 0c             	sub    $0xc,%esp
  801513:	25 07 0e 00 00       	and    $0xe07,%eax
  801518:	50                   	push   %eax
  801519:	ff 75 d4             	pushl  -0x2c(%ebp)
  80151c:	6a 00                	push   $0x0
  80151e:	57                   	push   %edi
  80151f:	6a 00                	push   $0x0
  801521:	e8 e0 f7 ff ff       	call   800d06 <sys_page_map>
  801526:	89 c7                	mov    %eax,%edi
  801528:	83 c4 20             	add    $0x20,%esp
  80152b:	85 c0                	test   %eax,%eax
  80152d:	78 2e                	js     80155d <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80152f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801532:	89 d0                	mov    %edx,%eax
  801534:	c1 e8 0c             	shr    $0xc,%eax
  801537:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80153e:	83 ec 0c             	sub    $0xc,%esp
  801541:	25 07 0e 00 00       	and    $0xe07,%eax
  801546:	50                   	push   %eax
  801547:	53                   	push   %ebx
  801548:	6a 00                	push   $0x0
  80154a:	52                   	push   %edx
  80154b:	6a 00                	push   $0x0
  80154d:	e8 b4 f7 ff ff       	call   800d06 <sys_page_map>
  801552:	89 c7                	mov    %eax,%edi
  801554:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801557:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801559:	85 ff                	test   %edi,%edi
  80155b:	79 1d                	jns    80157a <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80155d:	83 ec 08             	sub    $0x8,%esp
  801560:	53                   	push   %ebx
  801561:	6a 00                	push   $0x0
  801563:	e8 e0 f7 ff ff       	call   800d48 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801568:	83 c4 08             	add    $0x8,%esp
  80156b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80156e:	6a 00                	push   $0x0
  801570:	e8 d3 f7 ff ff       	call   800d48 <sys_page_unmap>
	return r;
  801575:	83 c4 10             	add    $0x10,%esp
  801578:	89 f8                	mov    %edi,%eax
}
  80157a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80157d:	5b                   	pop    %ebx
  80157e:	5e                   	pop    %esi
  80157f:	5f                   	pop    %edi
  801580:	5d                   	pop    %ebp
  801581:	c3                   	ret    

00801582 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801582:	55                   	push   %ebp
  801583:	89 e5                	mov    %esp,%ebp
  801585:	53                   	push   %ebx
  801586:	83 ec 14             	sub    $0x14,%esp
  801589:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80158c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80158f:	50                   	push   %eax
  801590:	53                   	push   %ebx
  801591:	e8 86 fd ff ff       	call   80131c <fd_lookup>
  801596:	83 c4 08             	add    $0x8,%esp
  801599:	89 c2                	mov    %eax,%edx
  80159b:	85 c0                	test   %eax,%eax
  80159d:	78 6d                	js     80160c <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80159f:	83 ec 08             	sub    $0x8,%esp
  8015a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015a5:	50                   	push   %eax
  8015a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015a9:	ff 30                	pushl  (%eax)
  8015ab:	e8 c2 fd ff ff       	call   801372 <dev_lookup>
  8015b0:	83 c4 10             	add    $0x10,%esp
  8015b3:	85 c0                	test   %eax,%eax
  8015b5:	78 4c                	js     801603 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015b7:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015ba:	8b 42 08             	mov    0x8(%edx),%eax
  8015bd:	83 e0 03             	and    $0x3,%eax
  8015c0:	83 f8 01             	cmp    $0x1,%eax
  8015c3:	75 21                	jne    8015e6 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015c5:	a1 04 40 80 00       	mov    0x804004,%eax
  8015ca:	8b 40 48             	mov    0x48(%eax),%eax
  8015cd:	83 ec 04             	sub    $0x4,%esp
  8015d0:	53                   	push   %ebx
  8015d1:	50                   	push   %eax
  8015d2:	68 d1 28 80 00       	push   $0x8028d1
  8015d7:	e8 41 ed ff ff       	call   80031d <cprintf>
		return -E_INVAL;
  8015dc:	83 c4 10             	add    $0x10,%esp
  8015df:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015e4:	eb 26                	jmp    80160c <read+0x8a>
	}
	if (!dev->dev_read)
  8015e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015e9:	8b 40 08             	mov    0x8(%eax),%eax
  8015ec:	85 c0                	test   %eax,%eax
  8015ee:	74 17                	je     801607 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015f0:	83 ec 04             	sub    $0x4,%esp
  8015f3:	ff 75 10             	pushl  0x10(%ebp)
  8015f6:	ff 75 0c             	pushl  0xc(%ebp)
  8015f9:	52                   	push   %edx
  8015fa:	ff d0                	call   *%eax
  8015fc:	89 c2                	mov    %eax,%edx
  8015fe:	83 c4 10             	add    $0x10,%esp
  801601:	eb 09                	jmp    80160c <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801603:	89 c2                	mov    %eax,%edx
  801605:	eb 05                	jmp    80160c <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801607:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80160c:	89 d0                	mov    %edx,%eax
  80160e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801611:	c9                   	leave  
  801612:	c3                   	ret    

00801613 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801613:	55                   	push   %ebp
  801614:	89 e5                	mov    %esp,%ebp
  801616:	57                   	push   %edi
  801617:	56                   	push   %esi
  801618:	53                   	push   %ebx
  801619:	83 ec 0c             	sub    $0xc,%esp
  80161c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80161f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801622:	bb 00 00 00 00       	mov    $0x0,%ebx
  801627:	eb 21                	jmp    80164a <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801629:	83 ec 04             	sub    $0x4,%esp
  80162c:	89 f0                	mov    %esi,%eax
  80162e:	29 d8                	sub    %ebx,%eax
  801630:	50                   	push   %eax
  801631:	89 d8                	mov    %ebx,%eax
  801633:	03 45 0c             	add    0xc(%ebp),%eax
  801636:	50                   	push   %eax
  801637:	57                   	push   %edi
  801638:	e8 45 ff ff ff       	call   801582 <read>
		if (m < 0)
  80163d:	83 c4 10             	add    $0x10,%esp
  801640:	85 c0                	test   %eax,%eax
  801642:	78 10                	js     801654 <readn+0x41>
			return m;
		if (m == 0)
  801644:	85 c0                	test   %eax,%eax
  801646:	74 0a                	je     801652 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801648:	01 c3                	add    %eax,%ebx
  80164a:	39 f3                	cmp    %esi,%ebx
  80164c:	72 db                	jb     801629 <readn+0x16>
  80164e:	89 d8                	mov    %ebx,%eax
  801650:	eb 02                	jmp    801654 <readn+0x41>
  801652:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801654:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801657:	5b                   	pop    %ebx
  801658:	5e                   	pop    %esi
  801659:	5f                   	pop    %edi
  80165a:	5d                   	pop    %ebp
  80165b:	c3                   	ret    

0080165c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80165c:	55                   	push   %ebp
  80165d:	89 e5                	mov    %esp,%ebp
  80165f:	53                   	push   %ebx
  801660:	83 ec 14             	sub    $0x14,%esp
  801663:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801666:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801669:	50                   	push   %eax
  80166a:	53                   	push   %ebx
  80166b:	e8 ac fc ff ff       	call   80131c <fd_lookup>
  801670:	83 c4 08             	add    $0x8,%esp
  801673:	89 c2                	mov    %eax,%edx
  801675:	85 c0                	test   %eax,%eax
  801677:	78 68                	js     8016e1 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801679:	83 ec 08             	sub    $0x8,%esp
  80167c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80167f:	50                   	push   %eax
  801680:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801683:	ff 30                	pushl  (%eax)
  801685:	e8 e8 fc ff ff       	call   801372 <dev_lookup>
  80168a:	83 c4 10             	add    $0x10,%esp
  80168d:	85 c0                	test   %eax,%eax
  80168f:	78 47                	js     8016d8 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801691:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801694:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801698:	75 21                	jne    8016bb <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80169a:	a1 04 40 80 00       	mov    0x804004,%eax
  80169f:	8b 40 48             	mov    0x48(%eax),%eax
  8016a2:	83 ec 04             	sub    $0x4,%esp
  8016a5:	53                   	push   %ebx
  8016a6:	50                   	push   %eax
  8016a7:	68 ed 28 80 00       	push   $0x8028ed
  8016ac:	e8 6c ec ff ff       	call   80031d <cprintf>
		return -E_INVAL;
  8016b1:	83 c4 10             	add    $0x10,%esp
  8016b4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016b9:	eb 26                	jmp    8016e1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016bb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016be:	8b 52 0c             	mov    0xc(%edx),%edx
  8016c1:	85 d2                	test   %edx,%edx
  8016c3:	74 17                	je     8016dc <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016c5:	83 ec 04             	sub    $0x4,%esp
  8016c8:	ff 75 10             	pushl  0x10(%ebp)
  8016cb:	ff 75 0c             	pushl  0xc(%ebp)
  8016ce:	50                   	push   %eax
  8016cf:	ff d2                	call   *%edx
  8016d1:	89 c2                	mov    %eax,%edx
  8016d3:	83 c4 10             	add    $0x10,%esp
  8016d6:	eb 09                	jmp    8016e1 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016d8:	89 c2                	mov    %eax,%edx
  8016da:	eb 05                	jmp    8016e1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8016dc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8016e1:	89 d0                	mov    %edx,%eax
  8016e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016e6:	c9                   	leave  
  8016e7:	c3                   	ret    

008016e8 <seek>:

int
seek(int fdnum, off_t offset)
{
  8016e8:	55                   	push   %ebp
  8016e9:	89 e5                	mov    %esp,%ebp
  8016eb:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016ee:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016f1:	50                   	push   %eax
  8016f2:	ff 75 08             	pushl  0x8(%ebp)
  8016f5:	e8 22 fc ff ff       	call   80131c <fd_lookup>
  8016fa:	83 c4 08             	add    $0x8,%esp
  8016fd:	85 c0                	test   %eax,%eax
  8016ff:	78 0e                	js     80170f <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801701:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801704:	8b 55 0c             	mov    0xc(%ebp),%edx
  801707:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80170a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80170f:	c9                   	leave  
  801710:	c3                   	ret    

00801711 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801711:	55                   	push   %ebp
  801712:	89 e5                	mov    %esp,%ebp
  801714:	53                   	push   %ebx
  801715:	83 ec 14             	sub    $0x14,%esp
  801718:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80171b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80171e:	50                   	push   %eax
  80171f:	53                   	push   %ebx
  801720:	e8 f7 fb ff ff       	call   80131c <fd_lookup>
  801725:	83 c4 08             	add    $0x8,%esp
  801728:	89 c2                	mov    %eax,%edx
  80172a:	85 c0                	test   %eax,%eax
  80172c:	78 65                	js     801793 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80172e:	83 ec 08             	sub    $0x8,%esp
  801731:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801734:	50                   	push   %eax
  801735:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801738:	ff 30                	pushl  (%eax)
  80173a:	e8 33 fc ff ff       	call   801372 <dev_lookup>
  80173f:	83 c4 10             	add    $0x10,%esp
  801742:	85 c0                	test   %eax,%eax
  801744:	78 44                	js     80178a <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801746:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801749:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80174d:	75 21                	jne    801770 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80174f:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801754:	8b 40 48             	mov    0x48(%eax),%eax
  801757:	83 ec 04             	sub    $0x4,%esp
  80175a:	53                   	push   %ebx
  80175b:	50                   	push   %eax
  80175c:	68 b0 28 80 00       	push   $0x8028b0
  801761:	e8 b7 eb ff ff       	call   80031d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801766:	83 c4 10             	add    $0x10,%esp
  801769:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80176e:	eb 23                	jmp    801793 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801770:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801773:	8b 52 18             	mov    0x18(%edx),%edx
  801776:	85 d2                	test   %edx,%edx
  801778:	74 14                	je     80178e <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80177a:	83 ec 08             	sub    $0x8,%esp
  80177d:	ff 75 0c             	pushl  0xc(%ebp)
  801780:	50                   	push   %eax
  801781:	ff d2                	call   *%edx
  801783:	89 c2                	mov    %eax,%edx
  801785:	83 c4 10             	add    $0x10,%esp
  801788:	eb 09                	jmp    801793 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80178a:	89 c2                	mov    %eax,%edx
  80178c:	eb 05                	jmp    801793 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80178e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801793:	89 d0                	mov    %edx,%eax
  801795:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801798:	c9                   	leave  
  801799:	c3                   	ret    

0080179a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80179a:	55                   	push   %ebp
  80179b:	89 e5                	mov    %esp,%ebp
  80179d:	53                   	push   %ebx
  80179e:	83 ec 14             	sub    $0x14,%esp
  8017a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017a4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017a7:	50                   	push   %eax
  8017a8:	ff 75 08             	pushl  0x8(%ebp)
  8017ab:	e8 6c fb ff ff       	call   80131c <fd_lookup>
  8017b0:	83 c4 08             	add    $0x8,%esp
  8017b3:	89 c2                	mov    %eax,%edx
  8017b5:	85 c0                	test   %eax,%eax
  8017b7:	78 58                	js     801811 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017b9:	83 ec 08             	sub    $0x8,%esp
  8017bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017bf:	50                   	push   %eax
  8017c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017c3:	ff 30                	pushl  (%eax)
  8017c5:	e8 a8 fb ff ff       	call   801372 <dev_lookup>
  8017ca:	83 c4 10             	add    $0x10,%esp
  8017cd:	85 c0                	test   %eax,%eax
  8017cf:	78 37                	js     801808 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8017d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017d4:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017d8:	74 32                	je     80180c <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017da:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017dd:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017e4:	00 00 00 
	stat->st_isdir = 0;
  8017e7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017ee:	00 00 00 
	stat->st_dev = dev;
  8017f1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017f7:	83 ec 08             	sub    $0x8,%esp
  8017fa:	53                   	push   %ebx
  8017fb:	ff 75 f0             	pushl  -0x10(%ebp)
  8017fe:	ff 50 14             	call   *0x14(%eax)
  801801:	89 c2                	mov    %eax,%edx
  801803:	83 c4 10             	add    $0x10,%esp
  801806:	eb 09                	jmp    801811 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801808:	89 c2                	mov    %eax,%edx
  80180a:	eb 05                	jmp    801811 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80180c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801811:	89 d0                	mov    %edx,%eax
  801813:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801816:	c9                   	leave  
  801817:	c3                   	ret    

00801818 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801818:	55                   	push   %ebp
  801819:	89 e5                	mov    %esp,%ebp
  80181b:	56                   	push   %esi
  80181c:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80181d:	83 ec 08             	sub    $0x8,%esp
  801820:	6a 00                	push   $0x0
  801822:	ff 75 08             	pushl  0x8(%ebp)
  801825:	e8 e3 01 00 00       	call   801a0d <open>
  80182a:	89 c3                	mov    %eax,%ebx
  80182c:	83 c4 10             	add    $0x10,%esp
  80182f:	85 c0                	test   %eax,%eax
  801831:	78 1b                	js     80184e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801833:	83 ec 08             	sub    $0x8,%esp
  801836:	ff 75 0c             	pushl  0xc(%ebp)
  801839:	50                   	push   %eax
  80183a:	e8 5b ff ff ff       	call   80179a <fstat>
  80183f:	89 c6                	mov    %eax,%esi
	close(fd);
  801841:	89 1c 24             	mov    %ebx,(%esp)
  801844:	e8 fd fb ff ff       	call   801446 <close>
	return r;
  801849:	83 c4 10             	add    $0x10,%esp
  80184c:	89 f0                	mov    %esi,%eax
}
  80184e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801851:	5b                   	pop    %ebx
  801852:	5e                   	pop    %esi
  801853:	5d                   	pop    %ebp
  801854:	c3                   	ret    

00801855 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801855:	55                   	push   %ebp
  801856:	89 e5                	mov    %esp,%ebp
  801858:	56                   	push   %esi
  801859:	53                   	push   %ebx
  80185a:	89 c6                	mov    %eax,%esi
  80185c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80185e:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801865:	75 12                	jne    801879 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801867:	83 ec 0c             	sub    $0xc,%esp
  80186a:	6a 01                	push   $0x1
  80186c:	e8 fc f9 ff ff       	call   80126d <ipc_find_env>
  801871:	a3 00 40 80 00       	mov    %eax,0x804000
  801876:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801879:	6a 07                	push   $0x7
  80187b:	68 00 50 80 00       	push   $0x805000
  801880:	56                   	push   %esi
  801881:	ff 35 00 40 80 00    	pushl  0x804000
  801887:	e8 8d f9 ff ff       	call   801219 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80188c:	83 c4 0c             	add    $0xc,%esp
  80188f:	6a 00                	push   $0x0
  801891:	53                   	push   %ebx
  801892:	6a 00                	push   $0x0
  801894:	e8 2b f9 ff ff       	call   8011c4 <ipc_recv>
}
  801899:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80189c:	5b                   	pop    %ebx
  80189d:	5e                   	pop    %esi
  80189e:	5d                   	pop    %ebp
  80189f:	c3                   	ret    

008018a0 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8018a0:	55                   	push   %ebp
  8018a1:	89 e5                	mov    %esp,%ebp
  8018a3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8018a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a9:	8b 40 0c             	mov    0xc(%eax),%eax
  8018ac:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8018b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018b4:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8018be:	b8 02 00 00 00       	mov    $0x2,%eax
  8018c3:	e8 8d ff ff ff       	call   801855 <fsipc>
}
  8018c8:	c9                   	leave  
  8018c9:	c3                   	ret    

008018ca <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018ca:	55                   	push   %ebp
  8018cb:	89 e5                	mov    %esp,%ebp
  8018cd:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d3:	8b 40 0c             	mov    0xc(%eax),%eax
  8018d6:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018db:	ba 00 00 00 00       	mov    $0x0,%edx
  8018e0:	b8 06 00 00 00       	mov    $0x6,%eax
  8018e5:	e8 6b ff ff ff       	call   801855 <fsipc>
}
  8018ea:	c9                   	leave  
  8018eb:	c3                   	ret    

008018ec <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018ec:	55                   	push   %ebp
  8018ed:	89 e5                	mov    %esp,%ebp
  8018ef:	53                   	push   %ebx
  8018f0:	83 ec 04             	sub    $0x4,%esp
  8018f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f9:	8b 40 0c             	mov    0xc(%eax),%eax
  8018fc:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801901:	ba 00 00 00 00       	mov    $0x0,%edx
  801906:	b8 05 00 00 00       	mov    $0x5,%eax
  80190b:	e8 45 ff ff ff       	call   801855 <fsipc>
  801910:	85 c0                	test   %eax,%eax
  801912:	78 2c                	js     801940 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801914:	83 ec 08             	sub    $0x8,%esp
  801917:	68 00 50 80 00       	push   $0x805000
  80191c:	53                   	push   %ebx
  80191d:	e8 9e ef ff ff       	call   8008c0 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801922:	a1 80 50 80 00       	mov    0x805080,%eax
  801927:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80192d:	a1 84 50 80 00       	mov    0x805084,%eax
  801932:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801938:	83 c4 10             	add    $0x10,%esp
  80193b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801940:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801943:	c9                   	leave  
  801944:	c3                   	ret    

00801945 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801945:	55                   	push   %ebp
  801946:	89 e5                	mov    %esp,%ebp
  801948:	83 ec 0c             	sub    $0xc,%esp
  80194b:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
    
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  80194e:	8b 55 08             	mov    0x8(%ebp),%edx
  801951:	8b 52 0c             	mov    0xc(%edx),%edx
  801954:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = MIN(n, PGSIZE);
  80195a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80195f:	ba 00 10 00 00       	mov    $0x1000,%edx
  801964:	0f 47 c2             	cmova  %edx,%eax
  801967:	a3 04 50 80 00       	mov    %eax,0x805004
    memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  80196c:	50                   	push   %eax
  80196d:	ff 75 0c             	pushl  0xc(%ebp)
  801970:	68 08 50 80 00       	push   $0x805008
  801975:	e8 d8 f0 ff ff       	call   800a52 <memmove>
    int r = fsipc(FSREQ_WRITE, NULL);
  80197a:	ba 00 00 00 00       	mov    $0x0,%edx
  80197f:	b8 04 00 00 00       	mov    $0x4,%eax
  801984:	e8 cc fe ff ff       	call   801855 <fsipc>
    return r;
}
  801989:	c9                   	leave  
  80198a:	c3                   	ret    

0080198b <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80198b:	55                   	push   %ebp
  80198c:	89 e5                	mov    %esp,%ebp
  80198e:	56                   	push   %esi
  80198f:	53                   	push   %ebx
  801990:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801993:	8b 45 08             	mov    0x8(%ebp),%eax
  801996:	8b 40 0c             	mov    0xc(%eax),%eax
  801999:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80199e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8019a9:	b8 03 00 00 00       	mov    $0x3,%eax
  8019ae:	e8 a2 fe ff ff       	call   801855 <fsipc>
  8019b3:	89 c3                	mov    %eax,%ebx
  8019b5:	85 c0                	test   %eax,%eax
  8019b7:	78 4b                	js     801a04 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8019b9:	39 c6                	cmp    %eax,%esi
  8019bb:	73 16                	jae    8019d3 <devfile_read+0x48>
  8019bd:	68 1c 29 80 00       	push   $0x80291c
  8019c2:	68 23 29 80 00       	push   $0x802923
  8019c7:	6a 7c                	push   $0x7c
  8019c9:	68 38 29 80 00       	push   $0x802938
  8019ce:	e8 71 e8 ff ff       	call   800244 <_panic>
	assert(r <= PGSIZE);
  8019d3:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019d8:	7e 16                	jle    8019f0 <devfile_read+0x65>
  8019da:	68 43 29 80 00       	push   $0x802943
  8019df:	68 23 29 80 00       	push   $0x802923
  8019e4:	6a 7d                	push   $0x7d
  8019e6:	68 38 29 80 00       	push   $0x802938
  8019eb:	e8 54 e8 ff ff       	call   800244 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019f0:	83 ec 04             	sub    $0x4,%esp
  8019f3:	50                   	push   %eax
  8019f4:	68 00 50 80 00       	push   $0x805000
  8019f9:	ff 75 0c             	pushl  0xc(%ebp)
  8019fc:	e8 51 f0 ff ff       	call   800a52 <memmove>
	return r;
  801a01:	83 c4 10             	add    $0x10,%esp
}
  801a04:	89 d8                	mov    %ebx,%eax
  801a06:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a09:	5b                   	pop    %ebx
  801a0a:	5e                   	pop    %esi
  801a0b:	5d                   	pop    %ebp
  801a0c:	c3                   	ret    

00801a0d <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a0d:	55                   	push   %ebp
  801a0e:	89 e5                	mov    %esp,%ebp
  801a10:	53                   	push   %ebx
  801a11:	83 ec 20             	sub    $0x20,%esp
  801a14:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a17:	53                   	push   %ebx
  801a18:	e8 6a ee ff ff       	call   800887 <strlen>
  801a1d:	83 c4 10             	add    $0x10,%esp
  801a20:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a25:	7f 67                	jg     801a8e <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a27:	83 ec 0c             	sub    $0xc,%esp
  801a2a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a2d:	50                   	push   %eax
  801a2e:	e8 9a f8 ff ff       	call   8012cd <fd_alloc>
  801a33:	83 c4 10             	add    $0x10,%esp
		return r;
  801a36:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a38:	85 c0                	test   %eax,%eax
  801a3a:	78 57                	js     801a93 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a3c:	83 ec 08             	sub    $0x8,%esp
  801a3f:	53                   	push   %ebx
  801a40:	68 00 50 80 00       	push   $0x805000
  801a45:	e8 76 ee ff ff       	call   8008c0 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a4a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a4d:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a52:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a55:	b8 01 00 00 00       	mov    $0x1,%eax
  801a5a:	e8 f6 fd ff ff       	call   801855 <fsipc>
  801a5f:	89 c3                	mov    %eax,%ebx
  801a61:	83 c4 10             	add    $0x10,%esp
  801a64:	85 c0                	test   %eax,%eax
  801a66:	79 14                	jns    801a7c <open+0x6f>
		fd_close(fd, 0);
  801a68:	83 ec 08             	sub    $0x8,%esp
  801a6b:	6a 00                	push   $0x0
  801a6d:	ff 75 f4             	pushl  -0xc(%ebp)
  801a70:	e8 50 f9 ff ff       	call   8013c5 <fd_close>
		return r;
  801a75:	83 c4 10             	add    $0x10,%esp
  801a78:	89 da                	mov    %ebx,%edx
  801a7a:	eb 17                	jmp    801a93 <open+0x86>
	}

	return fd2num(fd);
  801a7c:	83 ec 0c             	sub    $0xc,%esp
  801a7f:	ff 75 f4             	pushl  -0xc(%ebp)
  801a82:	e8 1f f8 ff ff       	call   8012a6 <fd2num>
  801a87:	89 c2                	mov    %eax,%edx
  801a89:	83 c4 10             	add    $0x10,%esp
  801a8c:	eb 05                	jmp    801a93 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a8e:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a93:	89 d0                	mov    %edx,%eax
  801a95:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a98:	c9                   	leave  
  801a99:	c3                   	ret    

00801a9a <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a9a:	55                   	push   %ebp
  801a9b:	89 e5                	mov    %esp,%ebp
  801a9d:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801aa0:	ba 00 00 00 00       	mov    $0x0,%edx
  801aa5:	b8 08 00 00 00       	mov    $0x8,%eax
  801aaa:	e8 a6 fd ff ff       	call   801855 <fsipc>
}
  801aaf:	c9                   	leave  
  801ab0:	c3                   	ret    

00801ab1 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ab1:	55                   	push   %ebp
  801ab2:	89 e5                	mov    %esp,%ebp
  801ab4:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ab7:	89 d0                	mov    %edx,%eax
  801ab9:	c1 e8 16             	shr    $0x16,%eax
  801abc:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801ac3:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ac8:	f6 c1 01             	test   $0x1,%cl
  801acb:	74 1d                	je     801aea <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801acd:	c1 ea 0c             	shr    $0xc,%edx
  801ad0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801ad7:	f6 c2 01             	test   $0x1,%dl
  801ada:	74 0e                	je     801aea <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801adc:	c1 ea 0c             	shr    $0xc,%edx
  801adf:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801ae6:	ef 
  801ae7:	0f b7 c0             	movzwl %ax,%eax
}
  801aea:	5d                   	pop    %ebp
  801aeb:	c3                   	ret    

00801aec <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801aec:	55                   	push   %ebp
  801aed:	89 e5                	mov    %esp,%ebp
  801aef:	56                   	push   %esi
  801af0:	53                   	push   %ebx
  801af1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801af4:	83 ec 0c             	sub    $0xc,%esp
  801af7:	ff 75 08             	pushl  0x8(%ebp)
  801afa:	e8 b7 f7 ff ff       	call   8012b6 <fd2data>
  801aff:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b01:	83 c4 08             	add    $0x8,%esp
  801b04:	68 4f 29 80 00       	push   $0x80294f
  801b09:	53                   	push   %ebx
  801b0a:	e8 b1 ed ff ff       	call   8008c0 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b0f:	8b 46 04             	mov    0x4(%esi),%eax
  801b12:	2b 06                	sub    (%esi),%eax
  801b14:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b1a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b21:	00 00 00 
	stat->st_dev = &devpipe;
  801b24:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801b2b:	30 80 00 
	return 0;
}
  801b2e:	b8 00 00 00 00       	mov    $0x0,%eax
  801b33:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b36:	5b                   	pop    %ebx
  801b37:	5e                   	pop    %esi
  801b38:	5d                   	pop    %ebp
  801b39:	c3                   	ret    

00801b3a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b3a:	55                   	push   %ebp
  801b3b:	89 e5                	mov    %esp,%ebp
  801b3d:	53                   	push   %ebx
  801b3e:	83 ec 0c             	sub    $0xc,%esp
  801b41:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b44:	53                   	push   %ebx
  801b45:	6a 00                	push   $0x0
  801b47:	e8 fc f1 ff ff       	call   800d48 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b4c:	89 1c 24             	mov    %ebx,(%esp)
  801b4f:	e8 62 f7 ff ff       	call   8012b6 <fd2data>
  801b54:	83 c4 08             	add    $0x8,%esp
  801b57:	50                   	push   %eax
  801b58:	6a 00                	push   $0x0
  801b5a:	e8 e9 f1 ff ff       	call   800d48 <sys_page_unmap>
}
  801b5f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b62:	c9                   	leave  
  801b63:	c3                   	ret    

00801b64 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b64:	55                   	push   %ebp
  801b65:	89 e5                	mov    %esp,%ebp
  801b67:	57                   	push   %edi
  801b68:	56                   	push   %esi
  801b69:	53                   	push   %ebx
  801b6a:	83 ec 1c             	sub    $0x1c,%esp
  801b6d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b70:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b72:	a1 04 40 80 00       	mov    0x804004,%eax
  801b77:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b7a:	83 ec 0c             	sub    $0xc,%esp
  801b7d:	ff 75 e0             	pushl  -0x20(%ebp)
  801b80:	e8 2c ff ff ff       	call   801ab1 <pageref>
  801b85:	89 c3                	mov    %eax,%ebx
  801b87:	89 3c 24             	mov    %edi,(%esp)
  801b8a:	e8 22 ff ff ff       	call   801ab1 <pageref>
  801b8f:	83 c4 10             	add    $0x10,%esp
  801b92:	39 c3                	cmp    %eax,%ebx
  801b94:	0f 94 c1             	sete   %cl
  801b97:	0f b6 c9             	movzbl %cl,%ecx
  801b9a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b9d:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801ba3:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ba6:	39 ce                	cmp    %ecx,%esi
  801ba8:	74 1b                	je     801bc5 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801baa:	39 c3                	cmp    %eax,%ebx
  801bac:	75 c4                	jne    801b72 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801bae:	8b 42 58             	mov    0x58(%edx),%eax
  801bb1:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bb4:	50                   	push   %eax
  801bb5:	56                   	push   %esi
  801bb6:	68 56 29 80 00       	push   $0x802956
  801bbb:	e8 5d e7 ff ff       	call   80031d <cprintf>
  801bc0:	83 c4 10             	add    $0x10,%esp
  801bc3:	eb ad                	jmp    801b72 <_pipeisclosed+0xe>
	}
}
  801bc5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bc8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bcb:	5b                   	pop    %ebx
  801bcc:	5e                   	pop    %esi
  801bcd:	5f                   	pop    %edi
  801bce:	5d                   	pop    %ebp
  801bcf:	c3                   	ret    

00801bd0 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bd0:	55                   	push   %ebp
  801bd1:	89 e5                	mov    %esp,%ebp
  801bd3:	57                   	push   %edi
  801bd4:	56                   	push   %esi
  801bd5:	53                   	push   %ebx
  801bd6:	83 ec 28             	sub    $0x28,%esp
  801bd9:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801bdc:	56                   	push   %esi
  801bdd:	e8 d4 f6 ff ff       	call   8012b6 <fd2data>
  801be2:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801be4:	83 c4 10             	add    $0x10,%esp
  801be7:	bf 00 00 00 00       	mov    $0x0,%edi
  801bec:	eb 4b                	jmp    801c39 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801bee:	89 da                	mov    %ebx,%edx
  801bf0:	89 f0                	mov    %esi,%eax
  801bf2:	e8 6d ff ff ff       	call   801b64 <_pipeisclosed>
  801bf7:	85 c0                	test   %eax,%eax
  801bf9:	75 48                	jne    801c43 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801bfb:	e8 a4 f0 ff ff       	call   800ca4 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c00:	8b 43 04             	mov    0x4(%ebx),%eax
  801c03:	8b 0b                	mov    (%ebx),%ecx
  801c05:	8d 51 20             	lea    0x20(%ecx),%edx
  801c08:	39 d0                	cmp    %edx,%eax
  801c0a:	73 e2                	jae    801bee <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c0f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c13:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c16:	89 c2                	mov    %eax,%edx
  801c18:	c1 fa 1f             	sar    $0x1f,%edx
  801c1b:	89 d1                	mov    %edx,%ecx
  801c1d:	c1 e9 1b             	shr    $0x1b,%ecx
  801c20:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c23:	83 e2 1f             	and    $0x1f,%edx
  801c26:	29 ca                	sub    %ecx,%edx
  801c28:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c2c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c30:	83 c0 01             	add    $0x1,%eax
  801c33:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c36:	83 c7 01             	add    $0x1,%edi
  801c39:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c3c:	75 c2                	jne    801c00 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c3e:	8b 45 10             	mov    0x10(%ebp),%eax
  801c41:	eb 05                	jmp    801c48 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c43:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c48:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c4b:	5b                   	pop    %ebx
  801c4c:	5e                   	pop    %esi
  801c4d:	5f                   	pop    %edi
  801c4e:	5d                   	pop    %ebp
  801c4f:	c3                   	ret    

00801c50 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c50:	55                   	push   %ebp
  801c51:	89 e5                	mov    %esp,%ebp
  801c53:	57                   	push   %edi
  801c54:	56                   	push   %esi
  801c55:	53                   	push   %ebx
  801c56:	83 ec 18             	sub    $0x18,%esp
  801c59:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c5c:	57                   	push   %edi
  801c5d:	e8 54 f6 ff ff       	call   8012b6 <fd2data>
  801c62:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c64:	83 c4 10             	add    $0x10,%esp
  801c67:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c6c:	eb 3d                	jmp    801cab <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c6e:	85 db                	test   %ebx,%ebx
  801c70:	74 04                	je     801c76 <devpipe_read+0x26>
				return i;
  801c72:	89 d8                	mov    %ebx,%eax
  801c74:	eb 44                	jmp    801cba <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c76:	89 f2                	mov    %esi,%edx
  801c78:	89 f8                	mov    %edi,%eax
  801c7a:	e8 e5 fe ff ff       	call   801b64 <_pipeisclosed>
  801c7f:	85 c0                	test   %eax,%eax
  801c81:	75 32                	jne    801cb5 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c83:	e8 1c f0 ff ff       	call   800ca4 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c88:	8b 06                	mov    (%esi),%eax
  801c8a:	3b 46 04             	cmp    0x4(%esi),%eax
  801c8d:	74 df                	je     801c6e <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c8f:	99                   	cltd   
  801c90:	c1 ea 1b             	shr    $0x1b,%edx
  801c93:	01 d0                	add    %edx,%eax
  801c95:	83 e0 1f             	and    $0x1f,%eax
  801c98:	29 d0                	sub    %edx,%eax
  801c9a:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ca2:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801ca5:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ca8:	83 c3 01             	add    $0x1,%ebx
  801cab:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801cae:	75 d8                	jne    801c88 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801cb0:	8b 45 10             	mov    0x10(%ebp),%eax
  801cb3:	eb 05                	jmp    801cba <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cb5:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801cba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cbd:	5b                   	pop    %ebx
  801cbe:	5e                   	pop    %esi
  801cbf:	5f                   	pop    %edi
  801cc0:	5d                   	pop    %ebp
  801cc1:	c3                   	ret    

00801cc2 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801cc2:	55                   	push   %ebp
  801cc3:	89 e5                	mov    %esp,%ebp
  801cc5:	56                   	push   %esi
  801cc6:	53                   	push   %ebx
  801cc7:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801cca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ccd:	50                   	push   %eax
  801cce:	e8 fa f5 ff ff       	call   8012cd <fd_alloc>
  801cd3:	83 c4 10             	add    $0x10,%esp
  801cd6:	89 c2                	mov    %eax,%edx
  801cd8:	85 c0                	test   %eax,%eax
  801cda:	0f 88 2c 01 00 00    	js     801e0c <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ce0:	83 ec 04             	sub    $0x4,%esp
  801ce3:	68 07 04 00 00       	push   $0x407
  801ce8:	ff 75 f4             	pushl  -0xc(%ebp)
  801ceb:	6a 00                	push   $0x0
  801ced:	e8 d1 ef ff ff       	call   800cc3 <sys_page_alloc>
  801cf2:	83 c4 10             	add    $0x10,%esp
  801cf5:	89 c2                	mov    %eax,%edx
  801cf7:	85 c0                	test   %eax,%eax
  801cf9:	0f 88 0d 01 00 00    	js     801e0c <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801cff:	83 ec 0c             	sub    $0xc,%esp
  801d02:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d05:	50                   	push   %eax
  801d06:	e8 c2 f5 ff ff       	call   8012cd <fd_alloc>
  801d0b:	89 c3                	mov    %eax,%ebx
  801d0d:	83 c4 10             	add    $0x10,%esp
  801d10:	85 c0                	test   %eax,%eax
  801d12:	0f 88 e2 00 00 00    	js     801dfa <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d18:	83 ec 04             	sub    $0x4,%esp
  801d1b:	68 07 04 00 00       	push   $0x407
  801d20:	ff 75 f0             	pushl  -0x10(%ebp)
  801d23:	6a 00                	push   $0x0
  801d25:	e8 99 ef ff ff       	call   800cc3 <sys_page_alloc>
  801d2a:	89 c3                	mov    %eax,%ebx
  801d2c:	83 c4 10             	add    $0x10,%esp
  801d2f:	85 c0                	test   %eax,%eax
  801d31:	0f 88 c3 00 00 00    	js     801dfa <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d37:	83 ec 0c             	sub    $0xc,%esp
  801d3a:	ff 75 f4             	pushl  -0xc(%ebp)
  801d3d:	e8 74 f5 ff ff       	call   8012b6 <fd2data>
  801d42:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d44:	83 c4 0c             	add    $0xc,%esp
  801d47:	68 07 04 00 00       	push   $0x407
  801d4c:	50                   	push   %eax
  801d4d:	6a 00                	push   $0x0
  801d4f:	e8 6f ef ff ff       	call   800cc3 <sys_page_alloc>
  801d54:	89 c3                	mov    %eax,%ebx
  801d56:	83 c4 10             	add    $0x10,%esp
  801d59:	85 c0                	test   %eax,%eax
  801d5b:	0f 88 89 00 00 00    	js     801dea <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d61:	83 ec 0c             	sub    $0xc,%esp
  801d64:	ff 75 f0             	pushl  -0x10(%ebp)
  801d67:	e8 4a f5 ff ff       	call   8012b6 <fd2data>
  801d6c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d73:	50                   	push   %eax
  801d74:	6a 00                	push   $0x0
  801d76:	56                   	push   %esi
  801d77:	6a 00                	push   $0x0
  801d79:	e8 88 ef ff ff       	call   800d06 <sys_page_map>
  801d7e:	89 c3                	mov    %eax,%ebx
  801d80:	83 c4 20             	add    $0x20,%esp
  801d83:	85 c0                	test   %eax,%eax
  801d85:	78 55                	js     801ddc <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d87:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d90:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d92:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d95:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d9c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801da2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801da5:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801da7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801daa:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801db1:	83 ec 0c             	sub    $0xc,%esp
  801db4:	ff 75 f4             	pushl  -0xc(%ebp)
  801db7:	e8 ea f4 ff ff       	call   8012a6 <fd2num>
  801dbc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dbf:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801dc1:	83 c4 04             	add    $0x4,%esp
  801dc4:	ff 75 f0             	pushl  -0x10(%ebp)
  801dc7:	e8 da f4 ff ff       	call   8012a6 <fd2num>
  801dcc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dcf:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801dd2:	83 c4 10             	add    $0x10,%esp
  801dd5:	ba 00 00 00 00       	mov    $0x0,%edx
  801dda:	eb 30                	jmp    801e0c <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801ddc:	83 ec 08             	sub    $0x8,%esp
  801ddf:	56                   	push   %esi
  801de0:	6a 00                	push   $0x0
  801de2:	e8 61 ef ff ff       	call   800d48 <sys_page_unmap>
  801de7:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801dea:	83 ec 08             	sub    $0x8,%esp
  801ded:	ff 75 f0             	pushl  -0x10(%ebp)
  801df0:	6a 00                	push   $0x0
  801df2:	e8 51 ef ff ff       	call   800d48 <sys_page_unmap>
  801df7:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801dfa:	83 ec 08             	sub    $0x8,%esp
  801dfd:	ff 75 f4             	pushl  -0xc(%ebp)
  801e00:	6a 00                	push   $0x0
  801e02:	e8 41 ef ff ff       	call   800d48 <sys_page_unmap>
  801e07:	83 c4 10             	add    $0x10,%esp
  801e0a:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e0c:	89 d0                	mov    %edx,%eax
  801e0e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e11:	5b                   	pop    %ebx
  801e12:	5e                   	pop    %esi
  801e13:	5d                   	pop    %ebp
  801e14:	c3                   	ret    

00801e15 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e15:	55                   	push   %ebp
  801e16:	89 e5                	mov    %esp,%ebp
  801e18:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e1b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e1e:	50                   	push   %eax
  801e1f:	ff 75 08             	pushl  0x8(%ebp)
  801e22:	e8 f5 f4 ff ff       	call   80131c <fd_lookup>
  801e27:	83 c4 10             	add    $0x10,%esp
  801e2a:	85 c0                	test   %eax,%eax
  801e2c:	78 18                	js     801e46 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e2e:	83 ec 0c             	sub    $0xc,%esp
  801e31:	ff 75 f4             	pushl  -0xc(%ebp)
  801e34:	e8 7d f4 ff ff       	call   8012b6 <fd2data>
	return _pipeisclosed(fd, p);
  801e39:	89 c2                	mov    %eax,%edx
  801e3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e3e:	e8 21 fd ff ff       	call   801b64 <_pipeisclosed>
  801e43:	83 c4 10             	add    $0x10,%esp
}
  801e46:	c9                   	leave  
  801e47:	c3                   	ret    

00801e48 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e48:	55                   	push   %ebp
  801e49:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e4b:	b8 00 00 00 00       	mov    $0x0,%eax
  801e50:	5d                   	pop    %ebp
  801e51:	c3                   	ret    

00801e52 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e52:	55                   	push   %ebp
  801e53:	89 e5                	mov    %esp,%ebp
  801e55:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e58:	68 6e 29 80 00       	push   $0x80296e
  801e5d:	ff 75 0c             	pushl  0xc(%ebp)
  801e60:	e8 5b ea ff ff       	call   8008c0 <strcpy>
	return 0;
}
  801e65:	b8 00 00 00 00       	mov    $0x0,%eax
  801e6a:	c9                   	leave  
  801e6b:	c3                   	ret    

00801e6c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e6c:	55                   	push   %ebp
  801e6d:	89 e5                	mov    %esp,%ebp
  801e6f:	57                   	push   %edi
  801e70:	56                   	push   %esi
  801e71:	53                   	push   %ebx
  801e72:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e78:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e7d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e83:	eb 2d                	jmp    801eb2 <devcons_write+0x46>
		m = n - tot;
  801e85:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e88:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e8a:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e8d:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e92:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e95:	83 ec 04             	sub    $0x4,%esp
  801e98:	53                   	push   %ebx
  801e99:	03 45 0c             	add    0xc(%ebp),%eax
  801e9c:	50                   	push   %eax
  801e9d:	57                   	push   %edi
  801e9e:	e8 af eb ff ff       	call   800a52 <memmove>
		sys_cputs(buf, m);
  801ea3:	83 c4 08             	add    $0x8,%esp
  801ea6:	53                   	push   %ebx
  801ea7:	57                   	push   %edi
  801ea8:	e8 5a ed ff ff       	call   800c07 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ead:	01 de                	add    %ebx,%esi
  801eaf:	83 c4 10             	add    $0x10,%esp
  801eb2:	89 f0                	mov    %esi,%eax
  801eb4:	3b 75 10             	cmp    0x10(%ebp),%esi
  801eb7:	72 cc                	jb     801e85 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801eb9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ebc:	5b                   	pop    %ebx
  801ebd:	5e                   	pop    %esi
  801ebe:	5f                   	pop    %edi
  801ebf:	5d                   	pop    %ebp
  801ec0:	c3                   	ret    

00801ec1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ec1:	55                   	push   %ebp
  801ec2:	89 e5                	mov    %esp,%ebp
  801ec4:	83 ec 08             	sub    $0x8,%esp
  801ec7:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801ecc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ed0:	74 2a                	je     801efc <devcons_read+0x3b>
  801ed2:	eb 05                	jmp    801ed9 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801ed4:	e8 cb ed ff ff       	call   800ca4 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801ed9:	e8 47 ed ff ff       	call   800c25 <sys_cgetc>
  801ede:	85 c0                	test   %eax,%eax
  801ee0:	74 f2                	je     801ed4 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801ee2:	85 c0                	test   %eax,%eax
  801ee4:	78 16                	js     801efc <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ee6:	83 f8 04             	cmp    $0x4,%eax
  801ee9:	74 0c                	je     801ef7 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801eeb:	8b 55 0c             	mov    0xc(%ebp),%edx
  801eee:	88 02                	mov    %al,(%edx)
	return 1;
  801ef0:	b8 01 00 00 00       	mov    $0x1,%eax
  801ef5:	eb 05                	jmp    801efc <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ef7:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801efc:	c9                   	leave  
  801efd:	c3                   	ret    

00801efe <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801efe:	55                   	push   %ebp
  801eff:	89 e5                	mov    %esp,%ebp
  801f01:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f04:	8b 45 08             	mov    0x8(%ebp),%eax
  801f07:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f0a:	6a 01                	push   $0x1
  801f0c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f0f:	50                   	push   %eax
  801f10:	e8 f2 ec ff ff       	call   800c07 <sys_cputs>
}
  801f15:	83 c4 10             	add    $0x10,%esp
  801f18:	c9                   	leave  
  801f19:	c3                   	ret    

00801f1a <getchar>:

int
getchar(void)
{
  801f1a:	55                   	push   %ebp
  801f1b:	89 e5                	mov    %esp,%ebp
  801f1d:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f20:	6a 01                	push   $0x1
  801f22:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f25:	50                   	push   %eax
  801f26:	6a 00                	push   $0x0
  801f28:	e8 55 f6 ff ff       	call   801582 <read>
	if (r < 0)
  801f2d:	83 c4 10             	add    $0x10,%esp
  801f30:	85 c0                	test   %eax,%eax
  801f32:	78 0f                	js     801f43 <getchar+0x29>
		return r;
	if (r < 1)
  801f34:	85 c0                	test   %eax,%eax
  801f36:	7e 06                	jle    801f3e <getchar+0x24>
		return -E_EOF;
	return c;
  801f38:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f3c:	eb 05                	jmp    801f43 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f3e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f43:	c9                   	leave  
  801f44:	c3                   	ret    

00801f45 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f45:	55                   	push   %ebp
  801f46:	89 e5                	mov    %esp,%ebp
  801f48:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f4b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f4e:	50                   	push   %eax
  801f4f:	ff 75 08             	pushl  0x8(%ebp)
  801f52:	e8 c5 f3 ff ff       	call   80131c <fd_lookup>
  801f57:	83 c4 10             	add    $0x10,%esp
  801f5a:	85 c0                	test   %eax,%eax
  801f5c:	78 11                	js     801f6f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f61:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f67:	39 10                	cmp    %edx,(%eax)
  801f69:	0f 94 c0             	sete   %al
  801f6c:	0f b6 c0             	movzbl %al,%eax
}
  801f6f:	c9                   	leave  
  801f70:	c3                   	ret    

00801f71 <opencons>:

int
opencons(void)
{
  801f71:	55                   	push   %ebp
  801f72:	89 e5                	mov    %esp,%ebp
  801f74:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f77:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f7a:	50                   	push   %eax
  801f7b:	e8 4d f3 ff ff       	call   8012cd <fd_alloc>
  801f80:	83 c4 10             	add    $0x10,%esp
		return r;
  801f83:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f85:	85 c0                	test   %eax,%eax
  801f87:	78 3e                	js     801fc7 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f89:	83 ec 04             	sub    $0x4,%esp
  801f8c:	68 07 04 00 00       	push   $0x407
  801f91:	ff 75 f4             	pushl  -0xc(%ebp)
  801f94:	6a 00                	push   $0x0
  801f96:	e8 28 ed ff ff       	call   800cc3 <sys_page_alloc>
  801f9b:	83 c4 10             	add    $0x10,%esp
		return r;
  801f9e:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fa0:	85 c0                	test   %eax,%eax
  801fa2:	78 23                	js     801fc7 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801fa4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801faa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fad:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801faf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fb2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801fb9:	83 ec 0c             	sub    $0xc,%esp
  801fbc:	50                   	push   %eax
  801fbd:	e8 e4 f2 ff ff       	call   8012a6 <fd2num>
  801fc2:	89 c2                	mov    %eax,%edx
  801fc4:	83 c4 10             	add    $0x10,%esp
}
  801fc7:	89 d0                	mov    %edx,%eax
  801fc9:	c9                   	leave  
  801fca:	c3                   	ret    

00801fcb <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801fcb:	55                   	push   %ebp
  801fcc:	89 e5                	mov    %esp,%ebp
  801fce:	83 ec 08             	sub    $0x8,%esp
	int r;
	int ret;
	if (_pgfault_handler == 0) {
  801fd1:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801fd8:	75 36                	jne    802010 <set_pgfault_handler+0x45>
		// First time through!
		// LAB 4: Your code here.
        
        	ret = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  801fda:	a1 04 40 80 00       	mov    0x804004,%eax
  801fdf:	8b 40 48             	mov    0x48(%eax),%eax
  801fe2:	83 ec 04             	sub    $0x4,%esp
  801fe5:	68 07 0e 00 00       	push   $0xe07
  801fea:	68 00 f0 bf ee       	push   $0xeebff000
  801fef:	50                   	push   %eax
  801ff0:	e8 ce ec ff ff       	call   800cc3 <sys_page_alloc>
		if (ret < 0) {
  801ff5:	83 c4 10             	add    $0x10,%esp
  801ff8:	85 c0                	test   %eax,%eax
  801ffa:	79 14                	jns    802010 <set_pgfault_handler+0x45>
		    panic("Allocate user exception stack failed!\n");
  801ffc:	83 ec 04             	sub    $0x4,%esp
  801fff:	68 7c 29 80 00       	push   $0x80297c
  802004:	6a 23                	push   $0x23
  802006:	68 a4 29 80 00       	push   $0x8029a4
  80200b:	e8 34 e2 ff ff       	call   800244 <_panic>
		}
	}
	sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  802010:	a1 04 40 80 00       	mov    0x804004,%eax
  802015:	8b 40 48             	mov    0x48(%eax),%eax
  802018:	83 ec 08             	sub    $0x8,%esp
  80201b:	68 33 20 80 00       	push   $0x802033
  802020:	50                   	push   %eax
  802021:	e8 e8 ed ff ff       	call   800e0e <sys_env_set_pgfault_upcall>
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802026:	8b 45 08             	mov    0x8(%ebp),%eax
  802029:	a3 00 60 80 00       	mov    %eax,0x806000
}
  80202e:	83 c4 10             	add    $0x10,%esp
  802031:	c9                   	leave  
  802032:	c3                   	ret    

00802033 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802033:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802034:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802039:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80203b:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 0x28(%esp), %ebx  # trap-time eip
  80203e:	8b 5c 24 28          	mov    0x28(%esp),%ebx
        subl $0x4, 0x30(%esp)  # trap-time esp minus 4
  802042:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax 
  802047:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl %ebx, (%eax)      # trap-time esp store trap-time eip
  80204b:	89 18                	mov    %ebx,(%eax)
        addl $0x8, %esp
  80204d:	83 c4 08             	add    $0x8,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  802050:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  802051:	83 c4 04             	add    $0x4,%esp
        popfl
  802054:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  802055:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  802056:	c3                   	ret    
  802057:	66 90                	xchg   %ax,%ax
  802059:	66 90                	xchg   %ax,%ax
  80205b:	66 90                	xchg   %ax,%ax
  80205d:	66 90                	xchg   %ax,%ax
  80205f:	90                   	nop

00802060 <__udivdi3>:
  802060:	55                   	push   %ebp
  802061:	57                   	push   %edi
  802062:	56                   	push   %esi
  802063:	53                   	push   %ebx
  802064:	83 ec 1c             	sub    $0x1c,%esp
  802067:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80206b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80206f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802073:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802077:	85 f6                	test   %esi,%esi
  802079:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80207d:	89 ca                	mov    %ecx,%edx
  80207f:	89 f8                	mov    %edi,%eax
  802081:	75 3d                	jne    8020c0 <__udivdi3+0x60>
  802083:	39 cf                	cmp    %ecx,%edi
  802085:	0f 87 c5 00 00 00    	ja     802150 <__udivdi3+0xf0>
  80208b:	85 ff                	test   %edi,%edi
  80208d:	89 fd                	mov    %edi,%ebp
  80208f:	75 0b                	jne    80209c <__udivdi3+0x3c>
  802091:	b8 01 00 00 00       	mov    $0x1,%eax
  802096:	31 d2                	xor    %edx,%edx
  802098:	f7 f7                	div    %edi
  80209a:	89 c5                	mov    %eax,%ebp
  80209c:	89 c8                	mov    %ecx,%eax
  80209e:	31 d2                	xor    %edx,%edx
  8020a0:	f7 f5                	div    %ebp
  8020a2:	89 c1                	mov    %eax,%ecx
  8020a4:	89 d8                	mov    %ebx,%eax
  8020a6:	89 cf                	mov    %ecx,%edi
  8020a8:	f7 f5                	div    %ebp
  8020aa:	89 c3                	mov    %eax,%ebx
  8020ac:	89 d8                	mov    %ebx,%eax
  8020ae:	89 fa                	mov    %edi,%edx
  8020b0:	83 c4 1c             	add    $0x1c,%esp
  8020b3:	5b                   	pop    %ebx
  8020b4:	5e                   	pop    %esi
  8020b5:	5f                   	pop    %edi
  8020b6:	5d                   	pop    %ebp
  8020b7:	c3                   	ret    
  8020b8:	90                   	nop
  8020b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020c0:	39 ce                	cmp    %ecx,%esi
  8020c2:	77 74                	ja     802138 <__udivdi3+0xd8>
  8020c4:	0f bd fe             	bsr    %esi,%edi
  8020c7:	83 f7 1f             	xor    $0x1f,%edi
  8020ca:	0f 84 98 00 00 00    	je     802168 <__udivdi3+0x108>
  8020d0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8020d5:	89 f9                	mov    %edi,%ecx
  8020d7:	89 c5                	mov    %eax,%ebp
  8020d9:	29 fb                	sub    %edi,%ebx
  8020db:	d3 e6                	shl    %cl,%esi
  8020dd:	89 d9                	mov    %ebx,%ecx
  8020df:	d3 ed                	shr    %cl,%ebp
  8020e1:	89 f9                	mov    %edi,%ecx
  8020e3:	d3 e0                	shl    %cl,%eax
  8020e5:	09 ee                	or     %ebp,%esi
  8020e7:	89 d9                	mov    %ebx,%ecx
  8020e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020ed:	89 d5                	mov    %edx,%ebp
  8020ef:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020f3:	d3 ed                	shr    %cl,%ebp
  8020f5:	89 f9                	mov    %edi,%ecx
  8020f7:	d3 e2                	shl    %cl,%edx
  8020f9:	89 d9                	mov    %ebx,%ecx
  8020fb:	d3 e8                	shr    %cl,%eax
  8020fd:	09 c2                	or     %eax,%edx
  8020ff:	89 d0                	mov    %edx,%eax
  802101:	89 ea                	mov    %ebp,%edx
  802103:	f7 f6                	div    %esi
  802105:	89 d5                	mov    %edx,%ebp
  802107:	89 c3                	mov    %eax,%ebx
  802109:	f7 64 24 0c          	mull   0xc(%esp)
  80210d:	39 d5                	cmp    %edx,%ebp
  80210f:	72 10                	jb     802121 <__udivdi3+0xc1>
  802111:	8b 74 24 08          	mov    0x8(%esp),%esi
  802115:	89 f9                	mov    %edi,%ecx
  802117:	d3 e6                	shl    %cl,%esi
  802119:	39 c6                	cmp    %eax,%esi
  80211b:	73 07                	jae    802124 <__udivdi3+0xc4>
  80211d:	39 d5                	cmp    %edx,%ebp
  80211f:	75 03                	jne    802124 <__udivdi3+0xc4>
  802121:	83 eb 01             	sub    $0x1,%ebx
  802124:	31 ff                	xor    %edi,%edi
  802126:	89 d8                	mov    %ebx,%eax
  802128:	89 fa                	mov    %edi,%edx
  80212a:	83 c4 1c             	add    $0x1c,%esp
  80212d:	5b                   	pop    %ebx
  80212e:	5e                   	pop    %esi
  80212f:	5f                   	pop    %edi
  802130:	5d                   	pop    %ebp
  802131:	c3                   	ret    
  802132:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802138:	31 ff                	xor    %edi,%edi
  80213a:	31 db                	xor    %ebx,%ebx
  80213c:	89 d8                	mov    %ebx,%eax
  80213e:	89 fa                	mov    %edi,%edx
  802140:	83 c4 1c             	add    $0x1c,%esp
  802143:	5b                   	pop    %ebx
  802144:	5e                   	pop    %esi
  802145:	5f                   	pop    %edi
  802146:	5d                   	pop    %ebp
  802147:	c3                   	ret    
  802148:	90                   	nop
  802149:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802150:	89 d8                	mov    %ebx,%eax
  802152:	f7 f7                	div    %edi
  802154:	31 ff                	xor    %edi,%edi
  802156:	89 c3                	mov    %eax,%ebx
  802158:	89 d8                	mov    %ebx,%eax
  80215a:	89 fa                	mov    %edi,%edx
  80215c:	83 c4 1c             	add    $0x1c,%esp
  80215f:	5b                   	pop    %ebx
  802160:	5e                   	pop    %esi
  802161:	5f                   	pop    %edi
  802162:	5d                   	pop    %ebp
  802163:	c3                   	ret    
  802164:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802168:	39 ce                	cmp    %ecx,%esi
  80216a:	72 0c                	jb     802178 <__udivdi3+0x118>
  80216c:	31 db                	xor    %ebx,%ebx
  80216e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802172:	0f 87 34 ff ff ff    	ja     8020ac <__udivdi3+0x4c>
  802178:	bb 01 00 00 00       	mov    $0x1,%ebx
  80217d:	e9 2a ff ff ff       	jmp    8020ac <__udivdi3+0x4c>
  802182:	66 90                	xchg   %ax,%ax
  802184:	66 90                	xchg   %ax,%ax
  802186:	66 90                	xchg   %ax,%ax
  802188:	66 90                	xchg   %ax,%ax
  80218a:	66 90                	xchg   %ax,%ax
  80218c:	66 90                	xchg   %ax,%ax
  80218e:	66 90                	xchg   %ax,%ax

00802190 <__umoddi3>:
  802190:	55                   	push   %ebp
  802191:	57                   	push   %edi
  802192:	56                   	push   %esi
  802193:	53                   	push   %ebx
  802194:	83 ec 1c             	sub    $0x1c,%esp
  802197:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80219b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80219f:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021a7:	85 d2                	test   %edx,%edx
  8021a9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8021ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021b1:	89 f3                	mov    %esi,%ebx
  8021b3:	89 3c 24             	mov    %edi,(%esp)
  8021b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021ba:	75 1c                	jne    8021d8 <__umoddi3+0x48>
  8021bc:	39 f7                	cmp    %esi,%edi
  8021be:	76 50                	jbe    802210 <__umoddi3+0x80>
  8021c0:	89 c8                	mov    %ecx,%eax
  8021c2:	89 f2                	mov    %esi,%edx
  8021c4:	f7 f7                	div    %edi
  8021c6:	89 d0                	mov    %edx,%eax
  8021c8:	31 d2                	xor    %edx,%edx
  8021ca:	83 c4 1c             	add    $0x1c,%esp
  8021cd:	5b                   	pop    %ebx
  8021ce:	5e                   	pop    %esi
  8021cf:	5f                   	pop    %edi
  8021d0:	5d                   	pop    %ebp
  8021d1:	c3                   	ret    
  8021d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021d8:	39 f2                	cmp    %esi,%edx
  8021da:	89 d0                	mov    %edx,%eax
  8021dc:	77 52                	ja     802230 <__umoddi3+0xa0>
  8021de:	0f bd ea             	bsr    %edx,%ebp
  8021e1:	83 f5 1f             	xor    $0x1f,%ebp
  8021e4:	75 5a                	jne    802240 <__umoddi3+0xb0>
  8021e6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8021ea:	0f 82 e0 00 00 00    	jb     8022d0 <__umoddi3+0x140>
  8021f0:	39 0c 24             	cmp    %ecx,(%esp)
  8021f3:	0f 86 d7 00 00 00    	jbe    8022d0 <__umoddi3+0x140>
  8021f9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021fd:	8b 54 24 04          	mov    0x4(%esp),%edx
  802201:	83 c4 1c             	add    $0x1c,%esp
  802204:	5b                   	pop    %ebx
  802205:	5e                   	pop    %esi
  802206:	5f                   	pop    %edi
  802207:	5d                   	pop    %ebp
  802208:	c3                   	ret    
  802209:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802210:	85 ff                	test   %edi,%edi
  802212:	89 fd                	mov    %edi,%ebp
  802214:	75 0b                	jne    802221 <__umoddi3+0x91>
  802216:	b8 01 00 00 00       	mov    $0x1,%eax
  80221b:	31 d2                	xor    %edx,%edx
  80221d:	f7 f7                	div    %edi
  80221f:	89 c5                	mov    %eax,%ebp
  802221:	89 f0                	mov    %esi,%eax
  802223:	31 d2                	xor    %edx,%edx
  802225:	f7 f5                	div    %ebp
  802227:	89 c8                	mov    %ecx,%eax
  802229:	f7 f5                	div    %ebp
  80222b:	89 d0                	mov    %edx,%eax
  80222d:	eb 99                	jmp    8021c8 <__umoddi3+0x38>
  80222f:	90                   	nop
  802230:	89 c8                	mov    %ecx,%eax
  802232:	89 f2                	mov    %esi,%edx
  802234:	83 c4 1c             	add    $0x1c,%esp
  802237:	5b                   	pop    %ebx
  802238:	5e                   	pop    %esi
  802239:	5f                   	pop    %edi
  80223a:	5d                   	pop    %ebp
  80223b:	c3                   	ret    
  80223c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802240:	8b 34 24             	mov    (%esp),%esi
  802243:	bf 20 00 00 00       	mov    $0x20,%edi
  802248:	89 e9                	mov    %ebp,%ecx
  80224a:	29 ef                	sub    %ebp,%edi
  80224c:	d3 e0                	shl    %cl,%eax
  80224e:	89 f9                	mov    %edi,%ecx
  802250:	89 f2                	mov    %esi,%edx
  802252:	d3 ea                	shr    %cl,%edx
  802254:	89 e9                	mov    %ebp,%ecx
  802256:	09 c2                	or     %eax,%edx
  802258:	89 d8                	mov    %ebx,%eax
  80225a:	89 14 24             	mov    %edx,(%esp)
  80225d:	89 f2                	mov    %esi,%edx
  80225f:	d3 e2                	shl    %cl,%edx
  802261:	89 f9                	mov    %edi,%ecx
  802263:	89 54 24 04          	mov    %edx,0x4(%esp)
  802267:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80226b:	d3 e8                	shr    %cl,%eax
  80226d:	89 e9                	mov    %ebp,%ecx
  80226f:	89 c6                	mov    %eax,%esi
  802271:	d3 e3                	shl    %cl,%ebx
  802273:	89 f9                	mov    %edi,%ecx
  802275:	89 d0                	mov    %edx,%eax
  802277:	d3 e8                	shr    %cl,%eax
  802279:	89 e9                	mov    %ebp,%ecx
  80227b:	09 d8                	or     %ebx,%eax
  80227d:	89 d3                	mov    %edx,%ebx
  80227f:	89 f2                	mov    %esi,%edx
  802281:	f7 34 24             	divl   (%esp)
  802284:	89 d6                	mov    %edx,%esi
  802286:	d3 e3                	shl    %cl,%ebx
  802288:	f7 64 24 04          	mull   0x4(%esp)
  80228c:	39 d6                	cmp    %edx,%esi
  80228e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802292:	89 d1                	mov    %edx,%ecx
  802294:	89 c3                	mov    %eax,%ebx
  802296:	72 08                	jb     8022a0 <__umoddi3+0x110>
  802298:	75 11                	jne    8022ab <__umoddi3+0x11b>
  80229a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80229e:	73 0b                	jae    8022ab <__umoddi3+0x11b>
  8022a0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8022a4:	1b 14 24             	sbb    (%esp),%edx
  8022a7:	89 d1                	mov    %edx,%ecx
  8022a9:	89 c3                	mov    %eax,%ebx
  8022ab:	8b 54 24 08          	mov    0x8(%esp),%edx
  8022af:	29 da                	sub    %ebx,%edx
  8022b1:	19 ce                	sbb    %ecx,%esi
  8022b3:	89 f9                	mov    %edi,%ecx
  8022b5:	89 f0                	mov    %esi,%eax
  8022b7:	d3 e0                	shl    %cl,%eax
  8022b9:	89 e9                	mov    %ebp,%ecx
  8022bb:	d3 ea                	shr    %cl,%edx
  8022bd:	89 e9                	mov    %ebp,%ecx
  8022bf:	d3 ee                	shr    %cl,%esi
  8022c1:	09 d0                	or     %edx,%eax
  8022c3:	89 f2                	mov    %esi,%edx
  8022c5:	83 c4 1c             	add    $0x1c,%esp
  8022c8:	5b                   	pop    %ebx
  8022c9:	5e                   	pop    %esi
  8022ca:	5f                   	pop    %edi
  8022cb:	5d                   	pop    %ebp
  8022cc:	c3                   	ret    
  8022cd:	8d 76 00             	lea    0x0(%esi),%esi
  8022d0:	29 f9                	sub    %edi,%ecx
  8022d2:	19 d6                	sbb    %edx,%esi
  8022d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022dc:	e9 18 ff ff ff       	jmp    8021f9 <__umoddi3+0x69>
