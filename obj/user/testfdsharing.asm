
obj/user/testfdsharing.debug:     file format elf32-i386


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
  80002c:	e8 87 01 00 00       	call   8001b8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

char buf[512], buf2[512];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 14             	sub    $0x14,%esp
	int fd, r, n, n2;

	if ((fd = open("motd", O_RDONLY)) < 0)
  80003c:	6a 00                	push   $0x0
  80003e:	68 20 23 80 00       	push   $0x802320
  800043:	e8 b7 18 00 00       	call   8018ff <open>
  800048:	89 c3                	mov    %eax,%ebx
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	79 12                	jns    800063 <umain+0x30>
		panic("open motd: %e", fd);
  800051:	50                   	push   %eax
  800052:	68 25 23 80 00       	push   $0x802325
  800057:	6a 0c                	push   $0xc
  800059:	68 33 23 80 00       	push   $0x802333
  80005e:	e8 b5 01 00 00       	call   800218 <_panic>
	seek(fd, 0);
  800063:	83 ec 08             	sub    $0x8,%esp
  800066:	6a 00                	push   $0x0
  800068:	50                   	push   %eax
  800069:	e8 6c 15 00 00       	call   8015da <seek>
	if ((n = readn(fd, buf, sizeof buf)) <= 0)
  80006e:	83 c4 0c             	add    $0xc,%esp
  800071:	68 00 02 00 00       	push   $0x200
  800076:	68 20 42 80 00       	push   $0x804220
  80007b:	53                   	push   %ebx
  80007c:	e8 84 14 00 00       	call   801505 <readn>
  800081:	89 c6                	mov    %eax,%esi
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	85 c0                	test   %eax,%eax
  800088:	7f 12                	jg     80009c <umain+0x69>
		panic("readn: %e", n);
  80008a:	50                   	push   %eax
  80008b:	68 48 23 80 00       	push   $0x802348
  800090:	6a 0f                	push   $0xf
  800092:	68 33 23 80 00       	push   $0x802333
  800097:	e8 7c 01 00 00       	call   800218 <_panic>

	if ((r = fork()) < 0)
  80009c:	e8 bb 0f 00 00       	call   80105c <fork>
  8000a1:	89 c7                	mov    %eax,%edi
  8000a3:	85 c0                	test   %eax,%eax
  8000a5:	79 12                	jns    8000b9 <umain+0x86>
		panic("fork: %e", r);
  8000a7:	50                   	push   %eax
  8000a8:	68 52 23 80 00       	push   $0x802352
  8000ad:	6a 12                	push   $0x12
  8000af:	68 33 23 80 00       	push   $0x802333
  8000b4:	e8 5f 01 00 00       	call   800218 <_panic>
	if (r == 0) {
  8000b9:	85 c0                	test   %eax,%eax
  8000bb:	0f 85 9d 00 00 00    	jne    80015e <umain+0x12b>
		seek(fd, 0);
  8000c1:	83 ec 08             	sub    $0x8,%esp
  8000c4:	6a 00                	push   $0x0
  8000c6:	53                   	push   %ebx
  8000c7:	e8 0e 15 00 00       	call   8015da <seek>
		cprintf("going to read in child (might page fault if your sharing is buggy)\n");
  8000cc:	c7 04 24 90 23 80 00 	movl   $0x802390,(%esp)
  8000d3:	e8 19 02 00 00       	call   8002f1 <cprintf>
		if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  8000d8:	83 c4 0c             	add    $0xc,%esp
  8000db:	68 00 02 00 00       	push   $0x200
  8000e0:	68 20 40 80 00       	push   $0x804020
  8000e5:	53                   	push   %ebx
  8000e6:	e8 1a 14 00 00       	call   801505 <readn>
  8000eb:	83 c4 10             	add    $0x10,%esp
  8000ee:	39 c6                	cmp    %eax,%esi
  8000f0:	74 16                	je     800108 <umain+0xd5>
			panic("read in parent got %d, read in child got %d", n, n2);
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	50                   	push   %eax
  8000f6:	56                   	push   %esi
  8000f7:	68 d4 23 80 00       	push   $0x8023d4
  8000fc:	6a 17                	push   $0x17
  8000fe:	68 33 23 80 00       	push   $0x802333
  800103:	e8 10 01 00 00       	call   800218 <_panic>
		if (memcmp(buf, buf2, n) != 0)
  800108:	83 ec 04             	sub    $0x4,%esp
  80010b:	56                   	push   %esi
  80010c:	68 20 40 80 00       	push   $0x804020
  800111:	68 20 42 80 00       	push   $0x804220
  800116:	e8 86 09 00 00       	call   800aa1 <memcmp>
  80011b:	83 c4 10             	add    $0x10,%esp
  80011e:	85 c0                	test   %eax,%eax
  800120:	74 14                	je     800136 <umain+0x103>
			panic("read in parent got different bytes from read in child");
  800122:	83 ec 04             	sub    $0x4,%esp
  800125:	68 00 24 80 00       	push   $0x802400
  80012a:	6a 19                	push   $0x19
  80012c:	68 33 23 80 00       	push   $0x802333
  800131:	e8 e2 00 00 00       	call   800218 <_panic>
		cprintf("read in child succeeded\n");
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	68 5b 23 80 00       	push   $0x80235b
  80013e:	e8 ae 01 00 00       	call   8002f1 <cprintf>
		seek(fd, 0);
  800143:	83 c4 08             	add    $0x8,%esp
  800146:	6a 00                	push   $0x0
  800148:	53                   	push   %ebx
  800149:	e8 8c 14 00 00       	call   8015da <seek>
		close(fd);
  80014e:	89 1c 24             	mov    %ebx,(%esp)
  800151:	e8 e2 11 00 00       	call   801338 <close>
		exit();
  800156:	e8 a3 00 00 00       	call   8001fe <exit>
  80015b:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  80015e:	83 ec 0c             	sub    $0xc,%esp
  800161:	57                   	push   %edi
  800162:	e8 98 1b 00 00       	call   801cff <wait>
	if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  800167:	83 c4 0c             	add    $0xc,%esp
  80016a:	68 00 02 00 00       	push   $0x200
  80016f:	68 20 40 80 00       	push   $0x804020
  800174:	53                   	push   %ebx
  800175:	e8 8b 13 00 00       	call   801505 <readn>
  80017a:	83 c4 10             	add    $0x10,%esp
  80017d:	39 c6                	cmp    %eax,%esi
  80017f:	74 16                	je     800197 <umain+0x164>
		panic("read in parent got %d, then got %d", n, n2);
  800181:	83 ec 0c             	sub    $0xc,%esp
  800184:	50                   	push   %eax
  800185:	56                   	push   %esi
  800186:	68 38 24 80 00       	push   $0x802438
  80018b:	6a 21                	push   $0x21
  80018d:	68 33 23 80 00       	push   $0x802333
  800192:	e8 81 00 00 00       	call   800218 <_panic>
	cprintf("read in parent succeeded\n");
  800197:	83 ec 0c             	sub    $0xc,%esp
  80019a:	68 74 23 80 00       	push   $0x802374
  80019f:	e8 4d 01 00 00       	call   8002f1 <cprintf>
	close(fd);
  8001a4:	89 1c 24             	mov    %ebx,(%esp)
  8001a7:	e8 8c 11 00 00       	call   801338 <close>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  8001ac:	cc                   	int3   

	breakpoint();
}
  8001ad:	83 c4 10             	add    $0x10,%esp
  8001b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001b3:	5b                   	pop    %ebx
  8001b4:	5e                   	pop    %esi
  8001b5:	5f                   	pop    %edi
  8001b6:	5d                   	pop    %ebp
  8001b7:	c3                   	ret    

008001b8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	56                   	push   %esi
  8001bc:	53                   	push   %ebx
  8001bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001c0:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  8001c3:	e8 91 0a 00 00       	call   800c59 <sys_getenvid>
  8001c8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001cd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001d0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001d5:	a3 20 44 80 00       	mov    %eax,0x804420
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001da:	85 db                	test   %ebx,%ebx
  8001dc:	7e 07                	jle    8001e5 <libmain+0x2d>
		binaryname = argv[0];
  8001de:	8b 06                	mov    (%esi),%eax
  8001e0:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8001e5:	83 ec 08             	sub    $0x8,%esp
  8001e8:	56                   	push   %esi
  8001e9:	53                   	push   %ebx
  8001ea:	e8 44 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8001ef:	e8 0a 00 00 00       	call   8001fe <exit>
}
  8001f4:	83 c4 10             	add    $0x10,%esp
  8001f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001fa:	5b                   	pop    %ebx
  8001fb:	5e                   	pop    %esi
  8001fc:	5d                   	pop    %ebp
  8001fd:	c3                   	ret    

008001fe <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001fe:	55                   	push   %ebp
  8001ff:	89 e5                	mov    %esp,%ebp
  800201:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800204:	e8 5a 11 00 00       	call   801363 <close_all>
	sys_env_destroy(0);
  800209:	83 ec 0c             	sub    $0xc,%esp
  80020c:	6a 00                	push   $0x0
  80020e:	e8 05 0a 00 00       	call   800c18 <sys_env_destroy>
}
  800213:	83 c4 10             	add    $0x10,%esp
  800216:	c9                   	leave  
  800217:	c3                   	ret    

00800218 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800218:	55                   	push   %ebp
  800219:	89 e5                	mov    %esp,%ebp
  80021b:	56                   	push   %esi
  80021c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80021d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800220:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800226:	e8 2e 0a 00 00       	call   800c59 <sys_getenvid>
  80022b:	83 ec 0c             	sub    $0xc,%esp
  80022e:	ff 75 0c             	pushl  0xc(%ebp)
  800231:	ff 75 08             	pushl  0x8(%ebp)
  800234:	56                   	push   %esi
  800235:	50                   	push   %eax
  800236:	68 68 24 80 00       	push   $0x802468
  80023b:	e8 b1 00 00 00       	call   8002f1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800240:	83 c4 18             	add    $0x18,%esp
  800243:	53                   	push   %ebx
  800244:	ff 75 10             	pushl  0x10(%ebp)
  800247:	e8 54 00 00 00       	call   8002a0 <vcprintf>
	cprintf("\n");
  80024c:	c7 04 24 72 23 80 00 	movl   $0x802372,(%esp)
  800253:	e8 99 00 00 00       	call   8002f1 <cprintf>
  800258:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80025b:	cc                   	int3   
  80025c:	eb fd                	jmp    80025b <_panic+0x43>

0080025e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80025e:	55                   	push   %ebp
  80025f:	89 e5                	mov    %esp,%ebp
  800261:	53                   	push   %ebx
  800262:	83 ec 04             	sub    $0x4,%esp
  800265:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800268:	8b 13                	mov    (%ebx),%edx
  80026a:	8d 42 01             	lea    0x1(%edx),%eax
  80026d:	89 03                	mov    %eax,(%ebx)
  80026f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800272:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800276:	3d ff 00 00 00       	cmp    $0xff,%eax
  80027b:	75 1a                	jne    800297 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80027d:	83 ec 08             	sub    $0x8,%esp
  800280:	68 ff 00 00 00       	push   $0xff
  800285:	8d 43 08             	lea    0x8(%ebx),%eax
  800288:	50                   	push   %eax
  800289:	e8 4d 09 00 00       	call   800bdb <sys_cputs>
		b->idx = 0;
  80028e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800294:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800297:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80029b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80029e:	c9                   	leave  
  80029f:	c3                   	ret    

008002a0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002a9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002b0:	00 00 00 
	b.cnt = 0;
  8002b3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002ba:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002bd:	ff 75 0c             	pushl  0xc(%ebp)
  8002c0:	ff 75 08             	pushl  0x8(%ebp)
  8002c3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002c9:	50                   	push   %eax
  8002ca:	68 5e 02 80 00       	push   $0x80025e
  8002cf:	e8 54 01 00 00       	call   800428 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002d4:	83 c4 08             	add    $0x8,%esp
  8002d7:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002dd:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002e3:	50                   	push   %eax
  8002e4:	e8 f2 08 00 00       	call   800bdb <sys_cputs>

	return b.cnt;
}
  8002e9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002ef:	c9                   	leave  
  8002f0:	c3                   	ret    

008002f1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002f1:	55                   	push   %ebp
  8002f2:	89 e5                	mov    %esp,%ebp
  8002f4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002f7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002fa:	50                   	push   %eax
  8002fb:	ff 75 08             	pushl  0x8(%ebp)
  8002fe:	e8 9d ff ff ff       	call   8002a0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800303:	c9                   	leave  
  800304:	c3                   	ret    

00800305 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
  800308:	57                   	push   %edi
  800309:	56                   	push   %esi
  80030a:	53                   	push   %ebx
  80030b:	83 ec 1c             	sub    $0x1c,%esp
  80030e:	89 c7                	mov    %eax,%edi
  800310:	89 d6                	mov    %edx,%esi
  800312:	8b 45 08             	mov    0x8(%ebp),%eax
  800315:	8b 55 0c             	mov    0xc(%ebp),%edx
  800318:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80031b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80031e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800321:	bb 00 00 00 00       	mov    $0x0,%ebx
  800326:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800329:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80032c:	39 d3                	cmp    %edx,%ebx
  80032e:	72 05                	jb     800335 <printnum+0x30>
  800330:	39 45 10             	cmp    %eax,0x10(%ebp)
  800333:	77 45                	ja     80037a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800335:	83 ec 0c             	sub    $0xc,%esp
  800338:	ff 75 18             	pushl  0x18(%ebp)
  80033b:	8b 45 14             	mov    0x14(%ebp),%eax
  80033e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800341:	53                   	push   %ebx
  800342:	ff 75 10             	pushl  0x10(%ebp)
  800345:	83 ec 08             	sub    $0x8,%esp
  800348:	ff 75 e4             	pushl  -0x1c(%ebp)
  80034b:	ff 75 e0             	pushl  -0x20(%ebp)
  80034e:	ff 75 dc             	pushl  -0x24(%ebp)
  800351:	ff 75 d8             	pushl  -0x28(%ebp)
  800354:	e8 27 1d 00 00       	call   802080 <__udivdi3>
  800359:	83 c4 18             	add    $0x18,%esp
  80035c:	52                   	push   %edx
  80035d:	50                   	push   %eax
  80035e:	89 f2                	mov    %esi,%edx
  800360:	89 f8                	mov    %edi,%eax
  800362:	e8 9e ff ff ff       	call   800305 <printnum>
  800367:	83 c4 20             	add    $0x20,%esp
  80036a:	eb 18                	jmp    800384 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80036c:	83 ec 08             	sub    $0x8,%esp
  80036f:	56                   	push   %esi
  800370:	ff 75 18             	pushl  0x18(%ebp)
  800373:	ff d7                	call   *%edi
  800375:	83 c4 10             	add    $0x10,%esp
  800378:	eb 03                	jmp    80037d <printnum+0x78>
  80037a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80037d:	83 eb 01             	sub    $0x1,%ebx
  800380:	85 db                	test   %ebx,%ebx
  800382:	7f e8                	jg     80036c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800384:	83 ec 08             	sub    $0x8,%esp
  800387:	56                   	push   %esi
  800388:	83 ec 04             	sub    $0x4,%esp
  80038b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80038e:	ff 75 e0             	pushl  -0x20(%ebp)
  800391:	ff 75 dc             	pushl  -0x24(%ebp)
  800394:	ff 75 d8             	pushl  -0x28(%ebp)
  800397:	e8 14 1e 00 00       	call   8021b0 <__umoddi3>
  80039c:	83 c4 14             	add    $0x14,%esp
  80039f:	0f be 80 8b 24 80 00 	movsbl 0x80248b(%eax),%eax
  8003a6:	50                   	push   %eax
  8003a7:	ff d7                	call   *%edi
}
  8003a9:	83 c4 10             	add    $0x10,%esp
  8003ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003af:	5b                   	pop    %ebx
  8003b0:	5e                   	pop    %esi
  8003b1:	5f                   	pop    %edi
  8003b2:	5d                   	pop    %ebp
  8003b3:	c3                   	ret    

008003b4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003b4:	55                   	push   %ebp
  8003b5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003b7:	83 fa 01             	cmp    $0x1,%edx
  8003ba:	7e 0e                	jle    8003ca <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003bc:	8b 10                	mov    (%eax),%edx
  8003be:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003c1:	89 08                	mov    %ecx,(%eax)
  8003c3:	8b 02                	mov    (%edx),%eax
  8003c5:	8b 52 04             	mov    0x4(%edx),%edx
  8003c8:	eb 22                	jmp    8003ec <getuint+0x38>
	else if (lflag)
  8003ca:	85 d2                	test   %edx,%edx
  8003cc:	74 10                	je     8003de <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003ce:	8b 10                	mov    (%eax),%edx
  8003d0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003d3:	89 08                	mov    %ecx,(%eax)
  8003d5:	8b 02                	mov    (%edx),%eax
  8003d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8003dc:	eb 0e                	jmp    8003ec <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003de:	8b 10                	mov    (%eax),%edx
  8003e0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003e3:	89 08                	mov    %ecx,(%eax)
  8003e5:	8b 02                	mov    (%edx),%eax
  8003e7:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003ec:	5d                   	pop    %ebp
  8003ed:	c3                   	ret    

008003ee <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003ee:	55                   	push   %ebp
  8003ef:	89 e5                	mov    %esp,%ebp
  8003f1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003f4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003f8:	8b 10                	mov    (%eax),%edx
  8003fa:	3b 50 04             	cmp    0x4(%eax),%edx
  8003fd:	73 0a                	jae    800409 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003ff:	8d 4a 01             	lea    0x1(%edx),%ecx
  800402:	89 08                	mov    %ecx,(%eax)
  800404:	8b 45 08             	mov    0x8(%ebp),%eax
  800407:	88 02                	mov    %al,(%edx)
}
  800409:	5d                   	pop    %ebp
  80040a:	c3                   	ret    

0080040b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80040b:	55                   	push   %ebp
  80040c:	89 e5                	mov    %esp,%ebp
  80040e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800411:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800414:	50                   	push   %eax
  800415:	ff 75 10             	pushl  0x10(%ebp)
  800418:	ff 75 0c             	pushl  0xc(%ebp)
  80041b:	ff 75 08             	pushl  0x8(%ebp)
  80041e:	e8 05 00 00 00       	call   800428 <vprintfmt>
	va_end(ap);
}
  800423:	83 c4 10             	add    $0x10,%esp
  800426:	c9                   	leave  
  800427:	c3                   	ret    

00800428 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800428:	55                   	push   %ebp
  800429:	89 e5                	mov    %esp,%ebp
  80042b:	57                   	push   %edi
  80042c:	56                   	push   %esi
  80042d:	53                   	push   %ebx
  80042e:	83 ec 2c             	sub    $0x2c,%esp
  800431:	8b 75 08             	mov    0x8(%ebp),%esi
  800434:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800437:	8b 7d 10             	mov    0x10(%ebp),%edi
  80043a:	eb 12                	jmp    80044e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80043c:	85 c0                	test   %eax,%eax
  80043e:	0f 84 a7 03 00 00    	je     8007eb <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
  800444:	83 ec 08             	sub    $0x8,%esp
  800447:	53                   	push   %ebx
  800448:	50                   	push   %eax
  800449:	ff d6                	call   *%esi
  80044b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80044e:	83 c7 01             	add    $0x1,%edi
  800451:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800455:	83 f8 25             	cmp    $0x25,%eax
  800458:	75 e2                	jne    80043c <vprintfmt+0x14>
  80045a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80045e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800465:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80046c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800473:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80047a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80047f:	eb 07                	jmp    800488 <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800481:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800484:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800488:	8d 47 01             	lea    0x1(%edi),%eax
  80048b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80048e:	0f b6 07             	movzbl (%edi),%eax
  800491:	0f b6 d0             	movzbl %al,%edx
  800494:	83 e8 23             	sub    $0x23,%eax
  800497:	3c 55                	cmp    $0x55,%al
  800499:	0f 87 31 03 00 00    	ja     8007d0 <vprintfmt+0x3a8>
  80049f:	0f b6 c0             	movzbl %al,%eax
  8004a2:	ff 24 85 c0 25 80 00 	jmp    *0x8025c0(,%eax,4)
  8004a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004ac:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004b0:	eb d6                	jmp    800488 <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ba:	89 75 08             	mov    %esi,0x8(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004bd:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004c0:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8004c4:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8004c7:	8d 72 d0             	lea    -0x30(%edx),%esi
  8004ca:	83 fe 09             	cmp    $0x9,%esi
  8004cd:	77 34                	ja     800503 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004cf:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004d2:	eb e9                	jmp    8004bd <vprintfmt+0x95>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d7:	8d 50 04             	lea    0x4(%eax),%edx
  8004da:	89 55 14             	mov    %edx,0x14(%ebp)
  8004dd:	8b 00                	mov    (%eax),%eax
  8004df:	89 45 cc             	mov    %eax,-0x34(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004e5:	eb 22                	jmp    800509 <vprintfmt+0xe1>
  8004e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004ea:	85 c0                	test   %eax,%eax
  8004ec:	0f 48 c1             	cmovs  %ecx,%eax
  8004ef:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004f5:	eb 91                	jmp    800488 <vprintfmt+0x60>
  8004f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004fa:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800501:	eb 85                	jmp    800488 <vprintfmt+0x60>
  800503:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800506:	8b 75 08             	mov    0x8(%ebp),%esi

		process_precision:
			if (width < 0)
  800509:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80050d:	0f 89 75 ff ff ff    	jns    800488 <vprintfmt+0x60>
				width = precision, precision = -1;
  800513:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800516:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800519:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800520:	e9 63 ff ff ff       	jmp    800488 <vprintfmt+0x60>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800525:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800529:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80052c:	e9 57 ff ff ff       	jmp    800488 <vprintfmt+0x60>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800531:	8b 45 14             	mov    0x14(%ebp),%eax
  800534:	8d 50 04             	lea    0x4(%eax),%edx
  800537:	89 55 14             	mov    %edx,0x14(%ebp)
  80053a:	83 ec 08             	sub    $0x8,%esp
  80053d:	53                   	push   %ebx
  80053e:	ff 30                	pushl  (%eax)
  800540:	ff d6                	call   *%esi
			break;
  800542:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800545:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800548:	e9 01 ff ff ff       	jmp    80044e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80054d:	8b 45 14             	mov    0x14(%ebp),%eax
  800550:	8d 50 04             	lea    0x4(%eax),%edx
  800553:	89 55 14             	mov    %edx,0x14(%ebp)
  800556:	8b 00                	mov    (%eax),%eax
  800558:	99                   	cltd   
  800559:	31 d0                	xor    %edx,%eax
  80055b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80055d:	83 f8 0f             	cmp    $0xf,%eax
  800560:	7f 0b                	jg     80056d <vprintfmt+0x145>
  800562:	8b 14 85 20 27 80 00 	mov    0x802720(,%eax,4),%edx
  800569:	85 d2                	test   %edx,%edx
  80056b:	75 18                	jne    800585 <vprintfmt+0x15d>
				printfmt(putch, putdat, "error %d", err);
  80056d:	50                   	push   %eax
  80056e:	68 a3 24 80 00       	push   $0x8024a3
  800573:	53                   	push   %ebx
  800574:	56                   	push   %esi
  800575:	e8 91 fe ff ff       	call   80040b <printfmt>
  80057a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800580:	e9 c9 fe ff ff       	jmp    80044e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800585:	52                   	push   %edx
  800586:	68 79 29 80 00       	push   $0x802979
  80058b:	53                   	push   %ebx
  80058c:	56                   	push   %esi
  80058d:	e8 79 fe ff ff       	call   80040b <printfmt>
  800592:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800595:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800598:	e9 b1 fe ff ff       	jmp    80044e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80059d:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a0:	8d 50 04             	lea    0x4(%eax),%edx
  8005a3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a6:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005a8:	85 ff                	test   %edi,%edi
  8005aa:	b8 9c 24 80 00       	mov    $0x80249c,%eax
  8005af:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005b2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005b6:	0f 8e 94 00 00 00    	jle    800650 <vprintfmt+0x228>
  8005bc:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005c0:	0f 84 98 00 00 00    	je     80065e <vprintfmt+0x236>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c6:	83 ec 08             	sub    $0x8,%esp
  8005c9:	ff 75 cc             	pushl  -0x34(%ebp)
  8005cc:	57                   	push   %edi
  8005cd:	e8 a1 02 00 00       	call   800873 <strnlen>
  8005d2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005d5:	29 c1                	sub    %eax,%ecx
  8005d7:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8005da:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005dd:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005e1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005e4:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005e7:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e9:	eb 0f                	jmp    8005fa <vprintfmt+0x1d2>
					putch(padc, putdat);
  8005eb:	83 ec 08             	sub    $0x8,%esp
  8005ee:	53                   	push   %ebx
  8005ef:	ff 75 e0             	pushl  -0x20(%ebp)
  8005f2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f4:	83 ef 01             	sub    $0x1,%edi
  8005f7:	83 c4 10             	add    $0x10,%esp
  8005fa:	85 ff                	test   %edi,%edi
  8005fc:	7f ed                	jg     8005eb <vprintfmt+0x1c3>
  8005fe:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800601:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800604:	85 c9                	test   %ecx,%ecx
  800606:	b8 00 00 00 00       	mov    $0x0,%eax
  80060b:	0f 49 c1             	cmovns %ecx,%eax
  80060e:	29 c1                	sub    %eax,%ecx
  800610:	89 75 08             	mov    %esi,0x8(%ebp)
  800613:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800616:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800619:	89 cb                	mov    %ecx,%ebx
  80061b:	eb 4d                	jmp    80066a <vprintfmt+0x242>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80061d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800621:	74 1b                	je     80063e <vprintfmt+0x216>
  800623:	0f be c0             	movsbl %al,%eax
  800626:	83 e8 20             	sub    $0x20,%eax
  800629:	83 f8 5e             	cmp    $0x5e,%eax
  80062c:	76 10                	jbe    80063e <vprintfmt+0x216>
					putch('?', putdat);
  80062e:	83 ec 08             	sub    $0x8,%esp
  800631:	ff 75 0c             	pushl  0xc(%ebp)
  800634:	6a 3f                	push   $0x3f
  800636:	ff 55 08             	call   *0x8(%ebp)
  800639:	83 c4 10             	add    $0x10,%esp
  80063c:	eb 0d                	jmp    80064b <vprintfmt+0x223>
				else
					putch(ch, putdat);
  80063e:	83 ec 08             	sub    $0x8,%esp
  800641:	ff 75 0c             	pushl  0xc(%ebp)
  800644:	52                   	push   %edx
  800645:	ff 55 08             	call   *0x8(%ebp)
  800648:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80064b:	83 eb 01             	sub    $0x1,%ebx
  80064e:	eb 1a                	jmp    80066a <vprintfmt+0x242>
  800650:	89 75 08             	mov    %esi,0x8(%ebp)
  800653:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800656:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800659:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80065c:	eb 0c                	jmp    80066a <vprintfmt+0x242>
  80065e:	89 75 08             	mov    %esi,0x8(%ebp)
  800661:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800664:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800667:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80066a:	83 c7 01             	add    $0x1,%edi
  80066d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800671:	0f be d0             	movsbl %al,%edx
  800674:	85 d2                	test   %edx,%edx
  800676:	74 23                	je     80069b <vprintfmt+0x273>
  800678:	85 f6                	test   %esi,%esi
  80067a:	78 a1                	js     80061d <vprintfmt+0x1f5>
  80067c:	83 ee 01             	sub    $0x1,%esi
  80067f:	79 9c                	jns    80061d <vprintfmt+0x1f5>
  800681:	89 df                	mov    %ebx,%edi
  800683:	8b 75 08             	mov    0x8(%ebp),%esi
  800686:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800689:	eb 18                	jmp    8006a3 <vprintfmt+0x27b>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80068b:	83 ec 08             	sub    $0x8,%esp
  80068e:	53                   	push   %ebx
  80068f:	6a 20                	push   $0x20
  800691:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800693:	83 ef 01             	sub    $0x1,%edi
  800696:	83 c4 10             	add    $0x10,%esp
  800699:	eb 08                	jmp    8006a3 <vprintfmt+0x27b>
  80069b:	89 df                	mov    %ebx,%edi
  80069d:	8b 75 08             	mov    0x8(%ebp),%esi
  8006a0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006a3:	85 ff                	test   %edi,%edi
  8006a5:	7f e4                	jg     80068b <vprintfmt+0x263>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006aa:	e9 9f fd ff ff       	jmp    80044e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006af:	83 7d d0 01          	cmpl   $0x1,-0x30(%ebp)
  8006b3:	7e 16                	jle    8006cb <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  8006b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b8:	8d 50 08             	lea    0x8(%eax),%edx
  8006bb:	89 55 14             	mov    %edx,0x14(%ebp)
  8006be:	8b 50 04             	mov    0x4(%eax),%edx
  8006c1:	8b 00                	mov    (%eax),%eax
  8006c3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006c6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006c9:	eb 34                	jmp    8006ff <vprintfmt+0x2d7>
	else if (lflag)
  8006cb:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8006cf:	74 18                	je     8006e9 <vprintfmt+0x2c1>
		return va_arg(*ap, long);
  8006d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d4:	8d 50 04             	lea    0x4(%eax),%edx
  8006d7:	89 55 14             	mov    %edx,0x14(%ebp)
  8006da:	8b 00                	mov    (%eax),%eax
  8006dc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006df:	89 c1                	mov    %eax,%ecx
  8006e1:	c1 f9 1f             	sar    $0x1f,%ecx
  8006e4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006e7:	eb 16                	jmp    8006ff <vprintfmt+0x2d7>
	else
		return va_arg(*ap, int);
  8006e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ec:	8d 50 04             	lea    0x4(%eax),%edx
  8006ef:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f2:	8b 00                	mov    (%eax),%eax
  8006f4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006f7:	89 c1                	mov    %eax,%ecx
  8006f9:	c1 f9 1f             	sar    $0x1f,%ecx
  8006fc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006ff:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800702:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800705:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80070a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80070e:	0f 89 88 00 00 00    	jns    80079c <vprintfmt+0x374>
				putch('-', putdat);
  800714:	83 ec 08             	sub    $0x8,%esp
  800717:	53                   	push   %ebx
  800718:	6a 2d                	push   $0x2d
  80071a:	ff d6                	call   *%esi
				num = -(long long) num;
  80071c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80071f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800722:	f7 d8                	neg    %eax
  800724:	83 d2 00             	adc    $0x0,%edx
  800727:	f7 da                	neg    %edx
  800729:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80072c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800731:	eb 69                	jmp    80079c <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800733:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800736:	8d 45 14             	lea    0x14(%ebp),%eax
  800739:	e8 76 fc ff ff       	call   8003b4 <getuint>
			base = 10;
  80073e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800743:	eb 57                	jmp    80079c <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  800745:	83 ec 08             	sub    $0x8,%esp
  800748:	53                   	push   %ebx
  800749:	6a 30                	push   $0x30
  80074b:	ff d6                	call   *%esi
			num = getuint(&ap, lflag);
  80074d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800750:	8d 45 14             	lea    0x14(%ebp),%eax
  800753:	e8 5c fc ff ff       	call   8003b4 <getuint>
			base = 8;
			goto number;
  800758:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  80075b:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800760:	eb 3a                	jmp    80079c <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  800762:	83 ec 08             	sub    $0x8,%esp
  800765:	53                   	push   %ebx
  800766:	6a 30                	push   $0x30
  800768:	ff d6                	call   *%esi
			putch('x', putdat);
  80076a:	83 c4 08             	add    $0x8,%esp
  80076d:	53                   	push   %ebx
  80076e:	6a 78                	push   $0x78
  800770:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800772:	8b 45 14             	mov    0x14(%ebp),%eax
  800775:	8d 50 04             	lea    0x4(%eax),%edx
  800778:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80077b:	8b 00                	mov    (%eax),%eax
  80077d:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800782:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800785:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80078a:	eb 10                	jmp    80079c <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80078c:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80078f:	8d 45 14             	lea    0x14(%ebp),%eax
  800792:	e8 1d fc ff ff       	call   8003b4 <getuint>
			base = 16;
  800797:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80079c:	83 ec 0c             	sub    $0xc,%esp
  80079f:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007a3:	57                   	push   %edi
  8007a4:	ff 75 e0             	pushl  -0x20(%ebp)
  8007a7:	51                   	push   %ecx
  8007a8:	52                   	push   %edx
  8007a9:	50                   	push   %eax
  8007aa:	89 da                	mov    %ebx,%edx
  8007ac:	89 f0                	mov    %esi,%eax
  8007ae:	e8 52 fb ff ff       	call   800305 <printnum>
			break;
  8007b3:	83 c4 20             	add    $0x20,%esp
  8007b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007b9:	e9 90 fc ff ff       	jmp    80044e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007be:	83 ec 08             	sub    $0x8,%esp
  8007c1:	53                   	push   %ebx
  8007c2:	52                   	push   %edx
  8007c3:	ff d6                	call   *%esi
			break;
  8007c5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007cb:	e9 7e fc ff ff       	jmp    80044e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007d0:	83 ec 08             	sub    $0x8,%esp
  8007d3:	53                   	push   %ebx
  8007d4:	6a 25                	push   $0x25
  8007d6:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007d8:	83 c4 10             	add    $0x10,%esp
  8007db:	eb 03                	jmp    8007e0 <vprintfmt+0x3b8>
  8007dd:	83 ef 01             	sub    $0x1,%edi
  8007e0:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007e4:	75 f7                	jne    8007dd <vprintfmt+0x3b5>
  8007e6:	e9 63 fc ff ff       	jmp    80044e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007ee:	5b                   	pop    %ebx
  8007ef:	5e                   	pop    %esi
  8007f0:	5f                   	pop    %edi
  8007f1:	5d                   	pop    %ebp
  8007f2:	c3                   	ret    

008007f3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007f3:	55                   	push   %ebp
  8007f4:	89 e5                	mov    %esp,%ebp
  8007f6:	83 ec 18             	sub    $0x18,%esp
  8007f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800802:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800806:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800809:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800810:	85 c0                	test   %eax,%eax
  800812:	74 26                	je     80083a <vsnprintf+0x47>
  800814:	85 d2                	test   %edx,%edx
  800816:	7e 22                	jle    80083a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800818:	ff 75 14             	pushl  0x14(%ebp)
  80081b:	ff 75 10             	pushl  0x10(%ebp)
  80081e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800821:	50                   	push   %eax
  800822:	68 ee 03 80 00       	push   $0x8003ee
  800827:	e8 fc fb ff ff       	call   800428 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80082c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80082f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800832:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800835:	83 c4 10             	add    $0x10,%esp
  800838:	eb 05                	jmp    80083f <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80083a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80083f:	c9                   	leave  
  800840:	c3                   	ret    

00800841 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800841:	55                   	push   %ebp
  800842:	89 e5                	mov    %esp,%ebp
  800844:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800847:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80084a:	50                   	push   %eax
  80084b:	ff 75 10             	pushl  0x10(%ebp)
  80084e:	ff 75 0c             	pushl  0xc(%ebp)
  800851:	ff 75 08             	pushl  0x8(%ebp)
  800854:	e8 9a ff ff ff       	call   8007f3 <vsnprintf>
	va_end(ap);

	return rc;
}
  800859:	c9                   	leave  
  80085a:	c3                   	ret    

0080085b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80085b:	55                   	push   %ebp
  80085c:	89 e5                	mov    %esp,%ebp
  80085e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800861:	b8 00 00 00 00       	mov    $0x0,%eax
  800866:	eb 03                	jmp    80086b <strlen+0x10>
		n++;
  800868:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80086b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80086f:	75 f7                	jne    800868 <strlen+0xd>
		n++;
	return n;
}
  800871:	5d                   	pop    %ebp
  800872:	c3                   	ret    

00800873 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800873:	55                   	push   %ebp
  800874:	89 e5                	mov    %esp,%ebp
  800876:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800879:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80087c:	ba 00 00 00 00       	mov    $0x0,%edx
  800881:	eb 03                	jmp    800886 <strnlen+0x13>
		n++;
  800883:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800886:	39 c2                	cmp    %eax,%edx
  800888:	74 08                	je     800892 <strnlen+0x1f>
  80088a:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80088e:	75 f3                	jne    800883 <strnlen+0x10>
  800890:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800892:	5d                   	pop    %ebp
  800893:	c3                   	ret    

00800894 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800894:	55                   	push   %ebp
  800895:	89 e5                	mov    %esp,%ebp
  800897:	53                   	push   %ebx
  800898:	8b 45 08             	mov    0x8(%ebp),%eax
  80089b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80089e:	89 c2                	mov    %eax,%edx
  8008a0:	83 c2 01             	add    $0x1,%edx
  8008a3:	83 c1 01             	add    $0x1,%ecx
  8008a6:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008aa:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008ad:	84 db                	test   %bl,%bl
  8008af:	75 ef                	jne    8008a0 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008b1:	5b                   	pop    %ebx
  8008b2:	5d                   	pop    %ebp
  8008b3:	c3                   	ret    

008008b4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008b4:	55                   	push   %ebp
  8008b5:	89 e5                	mov    %esp,%ebp
  8008b7:	53                   	push   %ebx
  8008b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008bb:	53                   	push   %ebx
  8008bc:	e8 9a ff ff ff       	call   80085b <strlen>
  8008c1:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008c4:	ff 75 0c             	pushl  0xc(%ebp)
  8008c7:	01 d8                	add    %ebx,%eax
  8008c9:	50                   	push   %eax
  8008ca:	e8 c5 ff ff ff       	call   800894 <strcpy>
	return dst;
}
  8008cf:	89 d8                	mov    %ebx,%eax
  8008d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008d4:	c9                   	leave  
  8008d5:	c3                   	ret    

008008d6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008d6:	55                   	push   %ebp
  8008d7:	89 e5                	mov    %esp,%ebp
  8008d9:	56                   	push   %esi
  8008da:	53                   	push   %ebx
  8008db:	8b 75 08             	mov    0x8(%ebp),%esi
  8008de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008e1:	89 f3                	mov    %esi,%ebx
  8008e3:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008e6:	89 f2                	mov    %esi,%edx
  8008e8:	eb 0f                	jmp    8008f9 <strncpy+0x23>
		*dst++ = *src;
  8008ea:	83 c2 01             	add    $0x1,%edx
  8008ed:	0f b6 01             	movzbl (%ecx),%eax
  8008f0:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008f3:	80 39 01             	cmpb   $0x1,(%ecx)
  8008f6:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008f9:	39 da                	cmp    %ebx,%edx
  8008fb:	75 ed                	jne    8008ea <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008fd:	89 f0                	mov    %esi,%eax
  8008ff:	5b                   	pop    %ebx
  800900:	5e                   	pop    %esi
  800901:	5d                   	pop    %ebp
  800902:	c3                   	ret    

00800903 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	56                   	push   %esi
  800907:	53                   	push   %ebx
  800908:	8b 75 08             	mov    0x8(%ebp),%esi
  80090b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80090e:	8b 55 10             	mov    0x10(%ebp),%edx
  800911:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800913:	85 d2                	test   %edx,%edx
  800915:	74 21                	je     800938 <strlcpy+0x35>
  800917:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80091b:	89 f2                	mov    %esi,%edx
  80091d:	eb 09                	jmp    800928 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80091f:	83 c2 01             	add    $0x1,%edx
  800922:	83 c1 01             	add    $0x1,%ecx
  800925:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800928:	39 c2                	cmp    %eax,%edx
  80092a:	74 09                	je     800935 <strlcpy+0x32>
  80092c:	0f b6 19             	movzbl (%ecx),%ebx
  80092f:	84 db                	test   %bl,%bl
  800931:	75 ec                	jne    80091f <strlcpy+0x1c>
  800933:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800935:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800938:	29 f0                	sub    %esi,%eax
}
  80093a:	5b                   	pop    %ebx
  80093b:	5e                   	pop    %esi
  80093c:	5d                   	pop    %ebp
  80093d:	c3                   	ret    

0080093e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800944:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800947:	eb 06                	jmp    80094f <strcmp+0x11>
		p++, q++;
  800949:	83 c1 01             	add    $0x1,%ecx
  80094c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80094f:	0f b6 01             	movzbl (%ecx),%eax
  800952:	84 c0                	test   %al,%al
  800954:	74 04                	je     80095a <strcmp+0x1c>
  800956:	3a 02                	cmp    (%edx),%al
  800958:	74 ef                	je     800949 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80095a:	0f b6 c0             	movzbl %al,%eax
  80095d:	0f b6 12             	movzbl (%edx),%edx
  800960:	29 d0                	sub    %edx,%eax
}
  800962:	5d                   	pop    %ebp
  800963:	c3                   	ret    

00800964 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	53                   	push   %ebx
  800968:	8b 45 08             	mov    0x8(%ebp),%eax
  80096b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80096e:	89 c3                	mov    %eax,%ebx
  800970:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800973:	eb 06                	jmp    80097b <strncmp+0x17>
		n--, p++, q++;
  800975:	83 c0 01             	add    $0x1,%eax
  800978:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80097b:	39 d8                	cmp    %ebx,%eax
  80097d:	74 15                	je     800994 <strncmp+0x30>
  80097f:	0f b6 08             	movzbl (%eax),%ecx
  800982:	84 c9                	test   %cl,%cl
  800984:	74 04                	je     80098a <strncmp+0x26>
  800986:	3a 0a                	cmp    (%edx),%cl
  800988:	74 eb                	je     800975 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80098a:	0f b6 00             	movzbl (%eax),%eax
  80098d:	0f b6 12             	movzbl (%edx),%edx
  800990:	29 d0                	sub    %edx,%eax
  800992:	eb 05                	jmp    800999 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800994:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800999:	5b                   	pop    %ebx
  80099a:	5d                   	pop    %ebp
  80099b:	c3                   	ret    

0080099c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009a6:	eb 07                	jmp    8009af <strchr+0x13>
		if (*s == c)
  8009a8:	38 ca                	cmp    %cl,%dl
  8009aa:	74 0f                	je     8009bb <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009ac:	83 c0 01             	add    $0x1,%eax
  8009af:	0f b6 10             	movzbl (%eax),%edx
  8009b2:	84 d2                	test   %dl,%dl
  8009b4:	75 f2                	jne    8009a8 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009bb:	5d                   	pop    %ebp
  8009bc:	c3                   	ret    

008009bd <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009bd:	55                   	push   %ebp
  8009be:	89 e5                	mov    %esp,%ebp
  8009c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009c7:	eb 03                	jmp    8009cc <strfind+0xf>
  8009c9:	83 c0 01             	add    $0x1,%eax
  8009cc:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009cf:	38 ca                	cmp    %cl,%dl
  8009d1:	74 04                	je     8009d7 <strfind+0x1a>
  8009d3:	84 d2                	test   %dl,%dl
  8009d5:	75 f2                	jne    8009c9 <strfind+0xc>
			break;
	return (char *) s;
}
  8009d7:	5d                   	pop    %ebp
  8009d8:	c3                   	ret    

008009d9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009d9:	55                   	push   %ebp
  8009da:	89 e5                	mov    %esp,%ebp
  8009dc:	57                   	push   %edi
  8009dd:	56                   	push   %esi
  8009de:	53                   	push   %ebx
  8009df:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009e2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009e5:	85 c9                	test   %ecx,%ecx
  8009e7:	74 36                	je     800a1f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009e9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009ef:	75 28                	jne    800a19 <memset+0x40>
  8009f1:	f6 c1 03             	test   $0x3,%cl
  8009f4:	75 23                	jne    800a19 <memset+0x40>
		c &= 0xFF;
  8009f6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009fa:	89 d3                	mov    %edx,%ebx
  8009fc:	c1 e3 08             	shl    $0x8,%ebx
  8009ff:	89 d6                	mov    %edx,%esi
  800a01:	c1 e6 18             	shl    $0x18,%esi
  800a04:	89 d0                	mov    %edx,%eax
  800a06:	c1 e0 10             	shl    $0x10,%eax
  800a09:	09 f0                	or     %esi,%eax
  800a0b:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a0d:	89 d8                	mov    %ebx,%eax
  800a0f:	09 d0                	or     %edx,%eax
  800a11:	c1 e9 02             	shr    $0x2,%ecx
  800a14:	fc                   	cld    
  800a15:	f3 ab                	rep stos %eax,%es:(%edi)
  800a17:	eb 06                	jmp    800a1f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a19:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a1c:	fc                   	cld    
  800a1d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a1f:	89 f8                	mov    %edi,%eax
  800a21:	5b                   	pop    %ebx
  800a22:	5e                   	pop    %esi
  800a23:	5f                   	pop    %edi
  800a24:	5d                   	pop    %ebp
  800a25:	c3                   	ret    

00800a26 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a26:	55                   	push   %ebp
  800a27:	89 e5                	mov    %esp,%ebp
  800a29:	57                   	push   %edi
  800a2a:	56                   	push   %esi
  800a2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a31:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a34:	39 c6                	cmp    %eax,%esi
  800a36:	73 35                	jae    800a6d <memmove+0x47>
  800a38:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a3b:	39 d0                	cmp    %edx,%eax
  800a3d:	73 2e                	jae    800a6d <memmove+0x47>
		s += n;
		d += n;
  800a3f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a42:	89 d6                	mov    %edx,%esi
  800a44:	09 fe                	or     %edi,%esi
  800a46:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a4c:	75 13                	jne    800a61 <memmove+0x3b>
  800a4e:	f6 c1 03             	test   $0x3,%cl
  800a51:	75 0e                	jne    800a61 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a53:	83 ef 04             	sub    $0x4,%edi
  800a56:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a59:	c1 e9 02             	shr    $0x2,%ecx
  800a5c:	fd                   	std    
  800a5d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a5f:	eb 09                	jmp    800a6a <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a61:	83 ef 01             	sub    $0x1,%edi
  800a64:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a67:	fd                   	std    
  800a68:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a6a:	fc                   	cld    
  800a6b:	eb 1d                	jmp    800a8a <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a6d:	89 f2                	mov    %esi,%edx
  800a6f:	09 c2                	or     %eax,%edx
  800a71:	f6 c2 03             	test   $0x3,%dl
  800a74:	75 0f                	jne    800a85 <memmove+0x5f>
  800a76:	f6 c1 03             	test   $0x3,%cl
  800a79:	75 0a                	jne    800a85 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a7b:	c1 e9 02             	shr    $0x2,%ecx
  800a7e:	89 c7                	mov    %eax,%edi
  800a80:	fc                   	cld    
  800a81:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a83:	eb 05                	jmp    800a8a <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a85:	89 c7                	mov    %eax,%edi
  800a87:	fc                   	cld    
  800a88:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a8a:	5e                   	pop    %esi
  800a8b:	5f                   	pop    %edi
  800a8c:	5d                   	pop    %ebp
  800a8d:	c3                   	ret    

00800a8e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a8e:	55                   	push   %ebp
  800a8f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a91:	ff 75 10             	pushl  0x10(%ebp)
  800a94:	ff 75 0c             	pushl  0xc(%ebp)
  800a97:	ff 75 08             	pushl  0x8(%ebp)
  800a9a:	e8 87 ff ff ff       	call   800a26 <memmove>
}
  800a9f:	c9                   	leave  
  800aa0:	c3                   	ret    

00800aa1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aa1:	55                   	push   %ebp
  800aa2:	89 e5                	mov    %esp,%ebp
  800aa4:	56                   	push   %esi
  800aa5:	53                   	push   %ebx
  800aa6:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aac:	89 c6                	mov    %eax,%esi
  800aae:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ab1:	eb 1a                	jmp    800acd <memcmp+0x2c>
		if (*s1 != *s2)
  800ab3:	0f b6 08             	movzbl (%eax),%ecx
  800ab6:	0f b6 1a             	movzbl (%edx),%ebx
  800ab9:	38 d9                	cmp    %bl,%cl
  800abb:	74 0a                	je     800ac7 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800abd:	0f b6 c1             	movzbl %cl,%eax
  800ac0:	0f b6 db             	movzbl %bl,%ebx
  800ac3:	29 d8                	sub    %ebx,%eax
  800ac5:	eb 0f                	jmp    800ad6 <memcmp+0x35>
		s1++, s2++;
  800ac7:	83 c0 01             	add    $0x1,%eax
  800aca:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800acd:	39 f0                	cmp    %esi,%eax
  800acf:	75 e2                	jne    800ab3 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ad1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ad6:	5b                   	pop    %ebx
  800ad7:	5e                   	pop    %esi
  800ad8:	5d                   	pop    %ebp
  800ad9:	c3                   	ret    

00800ada <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ada:	55                   	push   %ebp
  800adb:	89 e5                	mov    %esp,%ebp
  800add:	53                   	push   %ebx
  800ade:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ae1:	89 c1                	mov    %eax,%ecx
  800ae3:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800ae6:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800aea:	eb 0a                	jmp    800af6 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aec:	0f b6 10             	movzbl (%eax),%edx
  800aef:	39 da                	cmp    %ebx,%edx
  800af1:	74 07                	je     800afa <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800af3:	83 c0 01             	add    $0x1,%eax
  800af6:	39 c8                	cmp    %ecx,%eax
  800af8:	72 f2                	jb     800aec <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800afa:	5b                   	pop    %ebx
  800afb:	5d                   	pop    %ebp
  800afc:	c3                   	ret    

00800afd <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800afd:	55                   	push   %ebp
  800afe:	89 e5                	mov    %esp,%ebp
  800b00:	57                   	push   %edi
  800b01:	56                   	push   %esi
  800b02:	53                   	push   %ebx
  800b03:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b06:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b09:	eb 03                	jmp    800b0e <strtol+0x11>
		s++;
  800b0b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b0e:	0f b6 01             	movzbl (%ecx),%eax
  800b11:	3c 20                	cmp    $0x20,%al
  800b13:	74 f6                	je     800b0b <strtol+0xe>
  800b15:	3c 09                	cmp    $0x9,%al
  800b17:	74 f2                	je     800b0b <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b19:	3c 2b                	cmp    $0x2b,%al
  800b1b:	75 0a                	jne    800b27 <strtol+0x2a>
		s++;
  800b1d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b20:	bf 00 00 00 00       	mov    $0x0,%edi
  800b25:	eb 11                	jmp    800b38 <strtol+0x3b>
  800b27:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b2c:	3c 2d                	cmp    $0x2d,%al
  800b2e:	75 08                	jne    800b38 <strtol+0x3b>
		s++, neg = 1;
  800b30:	83 c1 01             	add    $0x1,%ecx
  800b33:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b38:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b3e:	75 15                	jne    800b55 <strtol+0x58>
  800b40:	80 39 30             	cmpb   $0x30,(%ecx)
  800b43:	75 10                	jne    800b55 <strtol+0x58>
  800b45:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b49:	75 7c                	jne    800bc7 <strtol+0xca>
		s += 2, base = 16;
  800b4b:	83 c1 02             	add    $0x2,%ecx
  800b4e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b53:	eb 16                	jmp    800b6b <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b55:	85 db                	test   %ebx,%ebx
  800b57:	75 12                	jne    800b6b <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b59:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b5e:	80 39 30             	cmpb   $0x30,(%ecx)
  800b61:	75 08                	jne    800b6b <strtol+0x6e>
		s++, base = 8;
  800b63:	83 c1 01             	add    $0x1,%ecx
  800b66:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b6b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b70:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b73:	0f b6 11             	movzbl (%ecx),%edx
  800b76:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b79:	89 f3                	mov    %esi,%ebx
  800b7b:	80 fb 09             	cmp    $0x9,%bl
  800b7e:	77 08                	ja     800b88 <strtol+0x8b>
			dig = *s - '0';
  800b80:	0f be d2             	movsbl %dl,%edx
  800b83:	83 ea 30             	sub    $0x30,%edx
  800b86:	eb 22                	jmp    800baa <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b88:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b8b:	89 f3                	mov    %esi,%ebx
  800b8d:	80 fb 19             	cmp    $0x19,%bl
  800b90:	77 08                	ja     800b9a <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b92:	0f be d2             	movsbl %dl,%edx
  800b95:	83 ea 57             	sub    $0x57,%edx
  800b98:	eb 10                	jmp    800baa <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b9a:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b9d:	89 f3                	mov    %esi,%ebx
  800b9f:	80 fb 19             	cmp    $0x19,%bl
  800ba2:	77 16                	ja     800bba <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ba4:	0f be d2             	movsbl %dl,%edx
  800ba7:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800baa:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bad:	7d 0b                	jge    800bba <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800baf:	83 c1 01             	add    $0x1,%ecx
  800bb2:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bb6:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800bb8:	eb b9                	jmp    800b73 <strtol+0x76>

	if (endptr)
  800bba:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bbe:	74 0d                	je     800bcd <strtol+0xd0>
		*endptr = (char *) s;
  800bc0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bc3:	89 0e                	mov    %ecx,(%esi)
  800bc5:	eb 06                	jmp    800bcd <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bc7:	85 db                	test   %ebx,%ebx
  800bc9:	74 98                	je     800b63 <strtol+0x66>
  800bcb:	eb 9e                	jmp    800b6b <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800bcd:	89 c2                	mov    %eax,%edx
  800bcf:	f7 da                	neg    %edx
  800bd1:	85 ff                	test   %edi,%edi
  800bd3:	0f 45 c2             	cmovne %edx,%eax
}
  800bd6:	5b                   	pop    %ebx
  800bd7:	5e                   	pop    %esi
  800bd8:	5f                   	pop    %edi
  800bd9:	5d                   	pop    %ebp
  800bda:	c3                   	ret    

00800bdb <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bdb:	55                   	push   %ebp
  800bdc:	89 e5                	mov    %esp,%ebp
  800bde:	57                   	push   %edi
  800bdf:	56                   	push   %esi
  800be0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be1:	b8 00 00 00 00       	mov    $0x0,%eax
  800be6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bec:	89 c3                	mov    %eax,%ebx
  800bee:	89 c7                	mov    %eax,%edi
  800bf0:	89 c6                	mov    %eax,%esi
  800bf2:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bf4:	5b                   	pop    %ebx
  800bf5:	5e                   	pop    %esi
  800bf6:	5f                   	pop    %edi
  800bf7:	5d                   	pop    %ebp
  800bf8:	c3                   	ret    

00800bf9 <sys_cgetc>:

int
sys_cgetc(void)
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
  800bff:	ba 00 00 00 00       	mov    $0x0,%edx
  800c04:	b8 01 00 00 00       	mov    $0x1,%eax
  800c09:	89 d1                	mov    %edx,%ecx
  800c0b:	89 d3                	mov    %edx,%ebx
  800c0d:	89 d7                	mov    %edx,%edi
  800c0f:	89 d6                	mov    %edx,%esi
  800c11:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c13:	5b                   	pop    %ebx
  800c14:	5e                   	pop    %esi
  800c15:	5f                   	pop    %edi
  800c16:	5d                   	pop    %ebp
  800c17:	c3                   	ret    

00800c18 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c18:	55                   	push   %ebp
  800c19:	89 e5                	mov    %esp,%ebp
  800c1b:	57                   	push   %edi
  800c1c:	56                   	push   %esi
  800c1d:	53                   	push   %ebx
  800c1e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c21:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c26:	b8 03 00 00 00       	mov    $0x3,%eax
  800c2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2e:	89 cb                	mov    %ecx,%ebx
  800c30:	89 cf                	mov    %ecx,%edi
  800c32:	89 ce                	mov    %ecx,%esi
  800c34:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c36:	85 c0                	test   %eax,%eax
  800c38:	7e 17                	jle    800c51 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3a:	83 ec 0c             	sub    $0xc,%esp
  800c3d:	50                   	push   %eax
  800c3e:	6a 03                	push   $0x3
  800c40:	68 7f 27 80 00       	push   $0x80277f
  800c45:	6a 23                	push   $0x23
  800c47:	68 9c 27 80 00       	push   $0x80279c
  800c4c:	e8 c7 f5 ff ff       	call   800218 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c51:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c54:	5b                   	pop    %ebx
  800c55:	5e                   	pop    %esi
  800c56:	5f                   	pop    %edi
  800c57:	5d                   	pop    %ebp
  800c58:	c3                   	ret    

00800c59 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c59:	55                   	push   %ebp
  800c5a:	89 e5                	mov    %esp,%ebp
  800c5c:	57                   	push   %edi
  800c5d:	56                   	push   %esi
  800c5e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5f:	ba 00 00 00 00       	mov    $0x0,%edx
  800c64:	b8 02 00 00 00       	mov    $0x2,%eax
  800c69:	89 d1                	mov    %edx,%ecx
  800c6b:	89 d3                	mov    %edx,%ebx
  800c6d:	89 d7                	mov    %edx,%edi
  800c6f:	89 d6                	mov    %edx,%esi
  800c71:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c73:	5b                   	pop    %ebx
  800c74:	5e                   	pop    %esi
  800c75:	5f                   	pop    %edi
  800c76:	5d                   	pop    %ebp
  800c77:	c3                   	ret    

00800c78 <sys_yield>:

void
sys_yield(void)
{
  800c78:	55                   	push   %ebp
  800c79:	89 e5                	mov    %esp,%ebp
  800c7b:	57                   	push   %edi
  800c7c:	56                   	push   %esi
  800c7d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c83:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c88:	89 d1                	mov    %edx,%ecx
  800c8a:	89 d3                	mov    %edx,%ebx
  800c8c:	89 d7                	mov    %edx,%edi
  800c8e:	89 d6                	mov    %edx,%esi
  800c90:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c92:	5b                   	pop    %ebx
  800c93:	5e                   	pop    %esi
  800c94:	5f                   	pop    %edi
  800c95:	5d                   	pop    %ebp
  800c96:	c3                   	ret    

00800c97 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800ca0:	be 00 00 00 00       	mov    $0x0,%esi
  800ca5:	b8 04 00 00 00       	mov    $0x4,%eax
  800caa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cad:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cb3:	89 f7                	mov    %esi,%edi
  800cb5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cb7:	85 c0                	test   %eax,%eax
  800cb9:	7e 17                	jle    800cd2 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbb:	83 ec 0c             	sub    $0xc,%esp
  800cbe:	50                   	push   %eax
  800cbf:	6a 04                	push   $0x4
  800cc1:	68 7f 27 80 00       	push   $0x80277f
  800cc6:	6a 23                	push   $0x23
  800cc8:	68 9c 27 80 00       	push   $0x80279c
  800ccd:	e8 46 f5 ff ff       	call   800218 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd5:	5b                   	pop    %ebx
  800cd6:	5e                   	pop    %esi
  800cd7:	5f                   	pop    %edi
  800cd8:	5d                   	pop    %ebp
  800cd9:	c3                   	ret    

00800cda <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  800ce3:	b8 05 00 00 00       	mov    $0x5,%eax
  800ce8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ceb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cee:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cf1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cf4:	8b 75 18             	mov    0x18(%ebp),%esi
  800cf7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cf9:	85 c0                	test   %eax,%eax
  800cfb:	7e 17                	jle    800d14 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfd:	83 ec 0c             	sub    $0xc,%esp
  800d00:	50                   	push   %eax
  800d01:	6a 05                	push   $0x5
  800d03:	68 7f 27 80 00       	push   $0x80277f
  800d08:	6a 23                	push   $0x23
  800d0a:	68 9c 27 80 00       	push   $0x80279c
  800d0f:	e8 04 f5 ff ff       	call   800218 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d14:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d17:	5b                   	pop    %ebx
  800d18:	5e                   	pop    %esi
  800d19:	5f                   	pop    %edi
  800d1a:	5d                   	pop    %ebp
  800d1b:	c3                   	ret    

00800d1c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
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
  800d2a:	b8 06 00 00 00       	mov    $0x6,%eax
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
  800d3d:	7e 17                	jle    800d56 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3f:	83 ec 0c             	sub    $0xc,%esp
  800d42:	50                   	push   %eax
  800d43:	6a 06                	push   $0x6
  800d45:	68 7f 27 80 00       	push   $0x80277f
  800d4a:	6a 23                	push   $0x23
  800d4c:	68 9c 27 80 00       	push   $0x80279c
  800d51:	e8 c2 f4 ff ff       	call   800218 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d59:	5b                   	pop    %ebx
  800d5a:	5e                   	pop    %esi
  800d5b:	5f                   	pop    %edi
  800d5c:	5d                   	pop    %ebp
  800d5d:	c3                   	ret    

00800d5e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800d6c:	b8 08 00 00 00       	mov    $0x8,%eax
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
  800d7f:	7e 17                	jle    800d98 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d81:	83 ec 0c             	sub    $0xc,%esp
  800d84:	50                   	push   %eax
  800d85:	6a 08                	push   $0x8
  800d87:	68 7f 27 80 00       	push   $0x80277f
  800d8c:	6a 23                	push   $0x23
  800d8e:	68 9c 27 80 00       	push   $0x80279c
  800d93:	e8 80 f4 ff ff       	call   800218 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d9b:	5b                   	pop    %ebx
  800d9c:	5e                   	pop    %esi
  800d9d:	5f                   	pop    %edi
  800d9e:	5d                   	pop    %ebp
  800d9f:	c3                   	ret    

00800da0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800da0:	55                   	push   %ebp
  800da1:	89 e5                	mov    %esp,%ebp
  800da3:	57                   	push   %edi
  800da4:	56                   	push   %esi
  800da5:	53                   	push   %ebx
  800da6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dae:	b8 09 00 00 00       	mov    $0x9,%eax
  800db3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db6:	8b 55 08             	mov    0x8(%ebp),%edx
  800db9:	89 df                	mov    %ebx,%edi
  800dbb:	89 de                	mov    %ebx,%esi
  800dbd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dbf:	85 c0                	test   %eax,%eax
  800dc1:	7e 17                	jle    800dda <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc3:	83 ec 0c             	sub    $0xc,%esp
  800dc6:	50                   	push   %eax
  800dc7:	6a 09                	push   $0x9
  800dc9:	68 7f 27 80 00       	push   $0x80277f
  800dce:	6a 23                	push   $0x23
  800dd0:	68 9c 27 80 00       	push   $0x80279c
  800dd5:	e8 3e f4 ff ff       	call   800218 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800dda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ddd:	5b                   	pop    %ebx
  800dde:	5e                   	pop    %esi
  800ddf:	5f                   	pop    %edi
  800de0:	5d                   	pop    %ebp
  800de1:	c3                   	ret    

00800de2 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800de2:	55                   	push   %ebp
  800de3:	89 e5                	mov    %esp,%ebp
  800de5:	57                   	push   %edi
  800de6:	56                   	push   %esi
  800de7:	53                   	push   %ebx
  800de8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800deb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df0:	b8 0a 00 00 00       	mov    $0xa,%eax
  800df5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfb:	89 df                	mov    %ebx,%edi
  800dfd:	89 de                	mov    %ebx,%esi
  800dff:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e01:	85 c0                	test   %eax,%eax
  800e03:	7e 17                	jle    800e1c <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e05:	83 ec 0c             	sub    $0xc,%esp
  800e08:	50                   	push   %eax
  800e09:	6a 0a                	push   $0xa
  800e0b:	68 7f 27 80 00       	push   $0x80277f
  800e10:	6a 23                	push   $0x23
  800e12:	68 9c 27 80 00       	push   $0x80279c
  800e17:	e8 fc f3 ff ff       	call   800218 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e1f:	5b                   	pop    %ebx
  800e20:	5e                   	pop    %esi
  800e21:	5f                   	pop    %edi
  800e22:	5d                   	pop    %ebp
  800e23:	c3                   	ret    

00800e24 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e24:	55                   	push   %ebp
  800e25:	89 e5                	mov    %esp,%ebp
  800e27:	57                   	push   %edi
  800e28:	56                   	push   %esi
  800e29:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2a:	be 00 00 00 00       	mov    $0x0,%esi
  800e2f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e37:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e3d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e40:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e42:	5b                   	pop    %ebx
  800e43:	5e                   	pop    %esi
  800e44:	5f                   	pop    %edi
  800e45:	5d                   	pop    %ebp
  800e46:	c3                   	ret    

00800e47 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e47:	55                   	push   %ebp
  800e48:	89 e5                	mov    %esp,%ebp
  800e4a:	57                   	push   %edi
  800e4b:	56                   	push   %esi
  800e4c:	53                   	push   %ebx
  800e4d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e50:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e55:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5d:	89 cb                	mov    %ecx,%ebx
  800e5f:	89 cf                	mov    %ecx,%edi
  800e61:	89 ce                	mov    %ecx,%esi
  800e63:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e65:	85 c0                	test   %eax,%eax
  800e67:	7e 17                	jle    800e80 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e69:	83 ec 0c             	sub    $0xc,%esp
  800e6c:	50                   	push   %eax
  800e6d:	6a 0d                	push   $0xd
  800e6f:	68 7f 27 80 00       	push   $0x80277f
  800e74:	6a 23                	push   $0x23
  800e76:	68 9c 27 80 00       	push   $0x80279c
  800e7b:	e8 98 f3 ff ff       	call   800218 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e83:	5b                   	pop    %ebx
  800e84:	5e                   	pop    %esi
  800e85:	5f                   	pop    %edi
  800e86:	5d                   	pop    %ebp
  800e87:	c3                   	ret    

00800e88 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800e88:	55                   	push   %ebp
  800e89:	89 e5                	mov    %esp,%ebp
  800e8b:	53                   	push   %ebx
  800e8c:	83 ec 04             	sub    $0x4,%esp
	int r;
	// LAB 4: Your code here.
    	pte_t *pte;
	int ret;
	// 用户空间的地址较低
	void *addr = (void *)(pn * PGSIZE);
  800e8f:	89 d3                	mov    %edx,%ebx
  800e91:	c1 e3 0c             	shl    $0xc,%ebx
	if (uvpt[pn] & PTE_SHARE) {
  800e94:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800e9b:	f6 c5 04             	test   $0x4,%ch
  800e9e:	74 2f                	je     800ecf <duppage+0x47>
		// cprintf("dup share page :%d\n", pn);
		if ((r = sys_page_map(0, addr, envid, addr, PTE_SYSCALL)) < 0)
  800ea0:	83 ec 0c             	sub    $0xc,%esp
  800ea3:	68 07 0e 00 00       	push   $0xe07
  800ea8:	53                   	push   %ebx
  800ea9:	50                   	push   %eax
  800eaa:	53                   	push   %ebx
  800eab:	6a 00                	push   $0x0
  800ead:	e8 28 fe ff ff       	call   800cda <sys_page_map>
  800eb2:	83 c4 20             	add    $0x20,%esp
  800eb5:	85 c0                	test   %eax,%eax
  800eb7:	0f 89 a0 00 00 00    	jns    800f5d <duppage+0xd5>
			panic("duppage sys_page_map:%e", r);
  800ebd:	50                   	push   %eax
  800ebe:	68 aa 27 80 00       	push   $0x8027aa
  800ec3:	6a 4d                	push   $0x4d
  800ec5:	68 c2 27 80 00       	push   $0x8027c2
  800eca:	e8 49 f3 ff ff       	call   800218 <_panic>
	} else if (uvpt[pn] & (PTE_W|PTE_COW)) {
  800ecf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ed6:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800edc:	74 57                	je     800f35 <duppage+0xad>
		if ((r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  800ede:	83 ec 0c             	sub    $0xc,%esp
  800ee1:	68 05 08 00 00       	push   $0x805
  800ee6:	53                   	push   %ebx
  800ee7:	50                   	push   %eax
  800ee8:	53                   	push   %ebx
  800ee9:	6a 00                	push   $0x0
  800eeb:	e8 ea fd ff ff       	call   800cda <sys_page_map>
  800ef0:	83 c4 20             	add    $0x20,%esp
  800ef3:	85 c0                	test   %eax,%eax
  800ef5:	79 12                	jns    800f09 <duppage+0x81>
			panic("sys_page_map COW:%e", r);
  800ef7:	50                   	push   %eax
  800ef8:	68 cd 27 80 00       	push   $0x8027cd
  800efd:	6a 50                	push   $0x50
  800eff:	68 c2 27 80 00       	push   $0x8027c2
  800f04:	e8 0f f3 ff ff       	call   800218 <_panic>

		if ((r = sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  800f09:	83 ec 0c             	sub    $0xc,%esp
  800f0c:	68 05 08 00 00       	push   $0x805
  800f11:	53                   	push   %ebx
  800f12:	6a 00                	push   $0x0
  800f14:	53                   	push   %ebx
  800f15:	6a 00                	push   $0x0
  800f17:	e8 be fd ff ff       	call   800cda <sys_page_map>
  800f1c:	83 c4 20             	add    $0x20,%esp
  800f1f:	85 c0                	test   %eax,%eax
  800f21:	79 3a                	jns    800f5d <duppage+0xd5>
			panic("sys_page_map COW:%e", r);
  800f23:	50                   	push   %eax
  800f24:	68 cd 27 80 00       	push   $0x8027cd
  800f29:	6a 53                	push   $0x53
  800f2b:	68 c2 27 80 00       	push   $0x8027c2
  800f30:	e8 e3 f2 ff ff       	call   800218 <_panic>
	} else {
		if ((r = sys_page_map(0, addr, envid, addr, PTE_U|PTE_P)) < 0)
  800f35:	83 ec 0c             	sub    $0xc,%esp
  800f38:	6a 05                	push   $0x5
  800f3a:	53                   	push   %ebx
  800f3b:	50                   	push   %eax
  800f3c:	53                   	push   %ebx
  800f3d:	6a 00                	push   $0x0
  800f3f:	e8 96 fd ff ff       	call   800cda <sys_page_map>
  800f44:	83 c4 20             	add    $0x20,%esp
  800f47:	85 c0                	test   %eax,%eax
  800f49:	79 12                	jns    800f5d <duppage+0xd5>
			panic("sys_page_map UP:%e", r);
  800f4b:	50                   	push   %eax
  800f4c:	68 e1 27 80 00       	push   $0x8027e1
  800f51:	6a 56                	push   $0x56
  800f53:	68 c2 27 80 00       	push   $0x8027c2
  800f58:	e8 bb f2 ff ff       	call   800218 <_panic>
	}
	return 0;
}
  800f5d:	b8 00 00 00 00       	mov    $0x0,%eax
  800f62:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f65:	c9                   	leave  
  800f66:	c3                   	ret    

00800f67 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f67:	55                   	push   %ebp
  800f68:	89 e5                	mov    %esp,%ebp
  800f6a:	56                   	push   %esi
  800f6b:	53                   	push   %ebx
  800f6c:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f6f:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (! ( (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  800f71:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f75:	74 2d                	je     800fa4 <pgfault+0x3d>
  800f77:	89 d8                	mov    %ebx,%eax
  800f79:	c1 e8 16             	shr    $0x16,%eax
  800f7c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f83:	a8 01                	test   $0x1,%al
  800f85:	74 1d                	je     800fa4 <pgfault+0x3d>
  800f87:	89 d8                	mov    %ebx,%eax
  800f89:	c1 e8 0c             	shr    $0xc,%eax
  800f8c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f93:	f6 c2 01             	test   $0x1,%dl
  800f96:	74 0c                	je     800fa4 <pgfault+0x3d>
  800f98:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f9f:	f6 c4 08             	test   $0x8,%ah
  800fa2:	75 14                	jne    800fb8 <pgfault+0x51>
        	panic("Neither the fault is a write nor COW page. \n");
  800fa4:	83 ec 04             	sub    $0x4,%esp
  800fa7:	68 60 28 80 00       	push   $0x802860
  800fac:	6a 1d                	push   $0x1d
  800fae:	68 c2 27 80 00       	push   $0x8027c2
  800fb3:	e8 60 f2 ff ff       	call   800218 <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.
	

    	envid_t envid = sys_getenvid();
  800fb8:	e8 9c fc ff ff       	call   800c59 <sys_getenvid>
  800fbd:	89 c6                	mov    %eax,%esi
    	// cprintf("pgfault: envid: %d\n", ENVX(envid));
    	// 临时页暂存
    	if ((r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P| PTE_W|PTE_U)) < 0)
  800fbf:	83 ec 04             	sub    $0x4,%esp
  800fc2:	6a 07                	push   $0x7
  800fc4:	68 00 f0 7f 00       	push   $0x7ff000
  800fc9:	50                   	push   %eax
  800fca:	e8 c8 fc ff ff       	call   800c97 <sys_page_alloc>
  800fcf:	83 c4 10             	add    $0x10,%esp
  800fd2:	85 c0                	test   %eax,%eax
  800fd4:	79 12                	jns    800fe8 <pgfault+0x81>
        	panic("pgfault: page allocation fault:%e\n", r);
  800fd6:	50                   	push   %eax
  800fd7:	68 90 28 80 00       	push   $0x802890
  800fdc:	6a 2b                	push   $0x2b
  800fde:	68 c2 27 80 00       	push   $0x8027c2
  800fe3:	e8 30 f2 ff ff       	call   800218 <_panic>
    	addr = ROUNDDOWN(addr, PGSIZE);
  800fe8:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  800fee:	83 ec 04             	sub    $0x4,%esp
  800ff1:	68 00 10 00 00       	push   $0x1000
  800ff6:	53                   	push   %ebx
  800ff7:	68 00 f0 7f 00       	push   $0x7ff000
  800ffc:	e8 8d fa ff ff       	call   800a8e <memcpy>
    	if ((r = sys_page_map(envid, (void *) PFTEMP, envid, addr , PTE_P|PTE_W|PTE_U)) < 0 )
  801001:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801008:	53                   	push   %ebx
  801009:	56                   	push   %esi
  80100a:	68 00 f0 7f 00       	push   $0x7ff000
  80100f:	56                   	push   %esi
  801010:	e8 c5 fc ff ff       	call   800cda <sys_page_map>
  801015:	83 c4 20             	add    $0x20,%esp
  801018:	85 c0                	test   %eax,%eax
  80101a:	79 12                	jns    80102e <pgfault+0xc7>
        	panic("pgfault: page map failed %e\n", r);
  80101c:	50                   	push   %eax
  80101d:	68 f4 27 80 00       	push   $0x8027f4
  801022:	6a 2f                	push   $0x2f
  801024:	68 c2 27 80 00       	push   $0x8027c2
  801029:	e8 ea f1 ff ff       	call   800218 <_panic>
    
    	if ((r = sys_page_unmap(envid, (void *) PFTEMP)) < 0)
  80102e:	83 ec 08             	sub    $0x8,%esp
  801031:	68 00 f0 7f 00       	push   $0x7ff000
  801036:	56                   	push   %esi
  801037:	e8 e0 fc ff ff       	call   800d1c <sys_page_unmap>
  80103c:	83 c4 10             	add    $0x10,%esp
  80103f:	85 c0                	test   %eax,%eax
  801041:	79 12                	jns    801055 <pgfault+0xee>
        	panic("pgfault: page unmap failed %e\n", r);
  801043:	50                   	push   %eax
  801044:	68 b4 28 80 00       	push   $0x8028b4
  801049:	6a 32                	push   $0x32
  80104b:	68 c2 27 80 00       	push   $0x8027c2
  801050:	e8 c3 f1 ff ff       	call   800218 <_panic>
	//panic("pgfault not implemented");
}
  801055:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801058:	5b                   	pop    %ebx
  801059:	5e                   	pop    %esi
  80105a:	5d                   	pop    %ebp
  80105b:	c3                   	ret    

0080105c <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80105c:	55                   	push   %ebp
  80105d:	89 e5                	mov    %esp,%ebp
  80105f:	56                   	push   %esi
  801060:	53                   	push   %ebx
  801061:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	set_pgfault_handler(pgfault);
  801064:	68 67 0f 80 00       	push   $0x800f67
  801069:	e8 63 0e 00 00       	call   801ed1 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80106e:	b8 07 00 00 00       	mov    $0x7,%eax
  801073:	cd 30                	int    $0x30
  801075:	89 c3                	mov    %eax,%ebx

	envid_t envid = sys_exofork();
	uint8_t *addr;
	if (envid < 0)
  801077:	83 c4 10             	add    $0x10,%esp
  80107a:	85 c0                	test   %eax,%eax
  80107c:	79 12                	jns    801090 <fork+0x34>
		panic("sys_exofork:%e", envid);
  80107e:	50                   	push   %eax
  80107f:	68 11 28 80 00       	push   $0x802811
  801084:	6a 75                	push   $0x75
  801086:	68 c2 27 80 00       	push   $0x8027c2
  80108b:	e8 88 f1 ff ff       	call   800218 <_panic>
  801090:	89 c6                	mov    %eax,%esi
	if (envid == 0) {
  801092:	85 c0                	test   %eax,%eax
  801094:	75 21                	jne    8010b7 <fork+0x5b>
		thisenv = &envs[ENVX(sys_getenvid())];
  801096:	e8 be fb ff ff       	call   800c59 <sys_getenvid>
  80109b:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010a0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010a3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010a8:	a3 20 44 80 00       	mov    %eax,0x804420
		return 0;
  8010ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8010b2:	e9 c0 00 00 00       	jmp    801177 <fork+0x11b>
	}

	for (addr = (uint8_t *)UTEXT; addr < (uint8_t *)USTACKTOP-PGSIZE; addr += PGSIZE) {
  8010b7:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  8010be:	ba 00 00 80 00       	mov    $0x800000,%edx
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
  8010c3:	89 d0                	mov    %edx,%eax
  8010c5:	c1 e8 16             	shr    $0x16,%eax
  8010c8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010cf:	a8 01                	test   $0x1,%al
  8010d1:	74 20                	je     8010f3 <fork+0x97>
  8010d3:	c1 ea 0c             	shr    $0xc,%edx
  8010d6:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8010dd:	a8 01                	test   $0x1,%al
  8010df:	74 12                	je     8010f3 <fork+0x97>
				&& (uvpt[PGNUM(addr)] & PTE_U)) {
  8010e1:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8010e8:	a8 04                	test   $0x4,%al
  8010ea:	74 07                	je     8010f3 <fork+0x97>
			duppage(envid, PGNUM(addr));
  8010ec:	89 f0                	mov    %esi,%eax
  8010ee:	e8 95 fd ff ff       	call   800e88 <duppage>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}

	for (addr = (uint8_t *)UTEXT; addr < (uint8_t *)USTACKTOP-PGSIZE; addr += PGSIZE) {
  8010f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010f6:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
  8010fc:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8010ff:	81 fa ff cf bf ee    	cmp    $0xeebfcfff,%edx
  801105:	76 bc                	jbe    8010c3 <fork+0x67>
				&& (uvpt[PGNUM(addr)] & PTE_U)) {
			duppage(envid, PGNUM(addr));
		}
	}

	duppage(envid, PGNUM(ROUNDDOWN(&addr, PGSIZE)));
  801107:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80110a:	c1 ea 0c             	shr    $0xc,%edx
  80110d:	89 d8                	mov    %ebx,%eax
  80110f:	e8 74 fd ff ff       	call   800e88 <duppage>

	int r;
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)))
  801114:	83 ec 04             	sub    $0x4,%esp
  801117:	6a 07                	push   $0x7
  801119:	68 00 f0 bf ee       	push   $0xeebff000
  80111e:	53                   	push   %ebx
  80111f:	e8 73 fb ff ff       	call   800c97 <sys_page_alloc>
  801124:	83 c4 10             	add    $0x10,%esp
  801127:	85 c0                	test   %eax,%eax
  801129:	74 15                	je     801140 <fork+0xe4>
		panic("sys_page_alloc:%e", r);
  80112b:	50                   	push   %eax
  80112c:	68 20 28 80 00       	push   $0x802820
  801131:	68 86 00 00 00       	push   $0x86
  801136:	68 c2 27 80 00       	push   $0x8027c2
  80113b:	e8 d8 f0 ff ff       	call   800218 <_panic>

	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801140:	83 ec 08             	sub    $0x8,%esp
  801143:	68 39 1f 80 00       	push   $0x801f39
  801148:	53                   	push   %ebx
  801149:	e8 94 fc ff ff       	call   800de2 <sys_env_set_pgfault_upcall>

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)))
  80114e:	83 c4 08             	add    $0x8,%esp
  801151:	6a 02                	push   $0x2
  801153:	53                   	push   %ebx
  801154:	e8 05 fc ff ff       	call   800d5e <sys_env_set_status>
  801159:	83 c4 10             	add    $0x10,%esp
  80115c:	85 c0                	test   %eax,%eax
  80115e:	74 15                	je     801175 <fork+0x119>
		panic("sys_env_set_status:%e", r);
  801160:	50                   	push   %eax
  801161:	68 32 28 80 00       	push   $0x802832
  801166:	68 8c 00 00 00       	push   $0x8c
  80116b:	68 c2 27 80 00       	push   $0x8027c2
  801170:	e8 a3 f0 ff ff       	call   800218 <_panic>

	return envid;
  801175:	89 d8                	mov    %ebx,%eax
	    
}
  801177:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80117a:	5b                   	pop    %ebx
  80117b:	5e                   	pop    %esi
  80117c:	5d                   	pop    %ebp
  80117d:	c3                   	ret    

0080117e <sfork>:

// Challenge!
int
sfork(void)
{
  80117e:	55                   	push   %ebp
  80117f:	89 e5                	mov    %esp,%ebp
  801181:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801184:	68 48 28 80 00       	push   $0x802848
  801189:	68 96 00 00 00       	push   $0x96
  80118e:	68 c2 27 80 00       	push   $0x8027c2
  801193:	e8 80 f0 ff ff       	call   800218 <_panic>

00801198 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801198:	55                   	push   %ebp
  801199:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80119b:	8b 45 08             	mov    0x8(%ebp),%eax
  80119e:	05 00 00 00 30       	add    $0x30000000,%eax
  8011a3:	c1 e8 0c             	shr    $0xc,%eax
}
  8011a6:	5d                   	pop    %ebp
  8011a7:	c3                   	ret    

008011a8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011a8:	55                   	push   %ebp
  8011a9:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ae:	05 00 00 00 30       	add    $0x30000000,%eax
  8011b3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011b8:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011bd:	5d                   	pop    %ebp
  8011be:	c3                   	ret    

008011bf <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011bf:	55                   	push   %ebp
  8011c0:	89 e5                	mov    %esp,%ebp
  8011c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011c5:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011ca:	89 c2                	mov    %eax,%edx
  8011cc:	c1 ea 16             	shr    $0x16,%edx
  8011cf:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011d6:	f6 c2 01             	test   $0x1,%dl
  8011d9:	74 11                	je     8011ec <fd_alloc+0x2d>
  8011db:	89 c2                	mov    %eax,%edx
  8011dd:	c1 ea 0c             	shr    $0xc,%edx
  8011e0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011e7:	f6 c2 01             	test   $0x1,%dl
  8011ea:	75 09                	jne    8011f5 <fd_alloc+0x36>
			*fd_store = fd;
  8011ec:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8011f3:	eb 17                	jmp    80120c <fd_alloc+0x4d>
  8011f5:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011fa:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011ff:	75 c9                	jne    8011ca <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801201:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801207:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80120c:	5d                   	pop    %ebp
  80120d:	c3                   	ret    

0080120e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80120e:	55                   	push   %ebp
  80120f:	89 e5                	mov    %esp,%ebp
  801211:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801214:	83 f8 1f             	cmp    $0x1f,%eax
  801217:	77 36                	ja     80124f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801219:	c1 e0 0c             	shl    $0xc,%eax
  80121c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801221:	89 c2                	mov    %eax,%edx
  801223:	c1 ea 16             	shr    $0x16,%edx
  801226:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80122d:	f6 c2 01             	test   $0x1,%dl
  801230:	74 24                	je     801256 <fd_lookup+0x48>
  801232:	89 c2                	mov    %eax,%edx
  801234:	c1 ea 0c             	shr    $0xc,%edx
  801237:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80123e:	f6 c2 01             	test   $0x1,%dl
  801241:	74 1a                	je     80125d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801243:	8b 55 0c             	mov    0xc(%ebp),%edx
  801246:	89 02                	mov    %eax,(%edx)
	return 0;
  801248:	b8 00 00 00 00       	mov    $0x0,%eax
  80124d:	eb 13                	jmp    801262 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80124f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801254:	eb 0c                	jmp    801262 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801256:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80125b:	eb 05                	jmp    801262 <fd_lookup+0x54>
  80125d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801262:	5d                   	pop    %ebp
  801263:	c3                   	ret    

00801264 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801264:	55                   	push   %ebp
  801265:	89 e5                	mov    %esp,%ebp
  801267:	83 ec 08             	sub    $0x8,%esp
  80126a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80126d:	ba 50 29 80 00       	mov    $0x802950,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801272:	eb 13                	jmp    801287 <dev_lookup+0x23>
  801274:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801277:	39 08                	cmp    %ecx,(%eax)
  801279:	75 0c                	jne    801287 <dev_lookup+0x23>
			*dev = devtab[i];
  80127b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80127e:	89 01                	mov    %eax,(%ecx)
			return 0;
  801280:	b8 00 00 00 00       	mov    $0x0,%eax
  801285:	eb 2e                	jmp    8012b5 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801287:	8b 02                	mov    (%edx),%eax
  801289:	85 c0                	test   %eax,%eax
  80128b:	75 e7                	jne    801274 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80128d:	a1 20 44 80 00       	mov    0x804420,%eax
  801292:	8b 40 48             	mov    0x48(%eax),%eax
  801295:	83 ec 04             	sub    $0x4,%esp
  801298:	51                   	push   %ecx
  801299:	50                   	push   %eax
  80129a:	68 d4 28 80 00       	push   $0x8028d4
  80129f:	e8 4d f0 ff ff       	call   8002f1 <cprintf>
	*dev = 0;
  8012a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012a7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012ad:	83 c4 10             	add    $0x10,%esp
  8012b0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012b5:	c9                   	leave  
  8012b6:	c3                   	ret    

008012b7 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012b7:	55                   	push   %ebp
  8012b8:	89 e5                	mov    %esp,%ebp
  8012ba:	56                   	push   %esi
  8012bb:	53                   	push   %ebx
  8012bc:	83 ec 10             	sub    $0x10,%esp
  8012bf:	8b 75 08             	mov    0x8(%ebp),%esi
  8012c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012c8:	50                   	push   %eax
  8012c9:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012cf:	c1 e8 0c             	shr    $0xc,%eax
  8012d2:	50                   	push   %eax
  8012d3:	e8 36 ff ff ff       	call   80120e <fd_lookup>
  8012d8:	83 c4 08             	add    $0x8,%esp
  8012db:	85 c0                	test   %eax,%eax
  8012dd:	78 05                	js     8012e4 <fd_close+0x2d>
	    || fd != fd2)
  8012df:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012e2:	74 0c                	je     8012f0 <fd_close+0x39>
		return (must_exist ? r : 0);
  8012e4:	84 db                	test   %bl,%bl
  8012e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8012eb:	0f 44 c2             	cmove  %edx,%eax
  8012ee:	eb 41                	jmp    801331 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012f0:	83 ec 08             	sub    $0x8,%esp
  8012f3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012f6:	50                   	push   %eax
  8012f7:	ff 36                	pushl  (%esi)
  8012f9:	e8 66 ff ff ff       	call   801264 <dev_lookup>
  8012fe:	89 c3                	mov    %eax,%ebx
  801300:	83 c4 10             	add    $0x10,%esp
  801303:	85 c0                	test   %eax,%eax
  801305:	78 1a                	js     801321 <fd_close+0x6a>
		if (dev->dev_close)
  801307:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80130a:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80130d:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801312:	85 c0                	test   %eax,%eax
  801314:	74 0b                	je     801321 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801316:	83 ec 0c             	sub    $0xc,%esp
  801319:	56                   	push   %esi
  80131a:	ff d0                	call   *%eax
  80131c:	89 c3                	mov    %eax,%ebx
  80131e:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801321:	83 ec 08             	sub    $0x8,%esp
  801324:	56                   	push   %esi
  801325:	6a 00                	push   $0x0
  801327:	e8 f0 f9 ff ff       	call   800d1c <sys_page_unmap>
	return r;
  80132c:	83 c4 10             	add    $0x10,%esp
  80132f:	89 d8                	mov    %ebx,%eax
}
  801331:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801334:	5b                   	pop    %ebx
  801335:	5e                   	pop    %esi
  801336:	5d                   	pop    %ebp
  801337:	c3                   	ret    

00801338 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801338:	55                   	push   %ebp
  801339:	89 e5                	mov    %esp,%ebp
  80133b:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80133e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801341:	50                   	push   %eax
  801342:	ff 75 08             	pushl  0x8(%ebp)
  801345:	e8 c4 fe ff ff       	call   80120e <fd_lookup>
  80134a:	83 c4 08             	add    $0x8,%esp
  80134d:	85 c0                	test   %eax,%eax
  80134f:	78 10                	js     801361 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801351:	83 ec 08             	sub    $0x8,%esp
  801354:	6a 01                	push   $0x1
  801356:	ff 75 f4             	pushl  -0xc(%ebp)
  801359:	e8 59 ff ff ff       	call   8012b7 <fd_close>
  80135e:	83 c4 10             	add    $0x10,%esp
}
  801361:	c9                   	leave  
  801362:	c3                   	ret    

00801363 <close_all>:

void
close_all(void)
{
  801363:	55                   	push   %ebp
  801364:	89 e5                	mov    %esp,%ebp
  801366:	53                   	push   %ebx
  801367:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80136a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80136f:	83 ec 0c             	sub    $0xc,%esp
  801372:	53                   	push   %ebx
  801373:	e8 c0 ff ff ff       	call   801338 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801378:	83 c3 01             	add    $0x1,%ebx
  80137b:	83 c4 10             	add    $0x10,%esp
  80137e:	83 fb 20             	cmp    $0x20,%ebx
  801381:	75 ec                	jne    80136f <close_all+0xc>
		close(i);
}
  801383:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801386:	c9                   	leave  
  801387:	c3                   	ret    

00801388 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801388:	55                   	push   %ebp
  801389:	89 e5                	mov    %esp,%ebp
  80138b:	57                   	push   %edi
  80138c:	56                   	push   %esi
  80138d:	53                   	push   %ebx
  80138e:	83 ec 2c             	sub    $0x2c,%esp
  801391:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801394:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801397:	50                   	push   %eax
  801398:	ff 75 08             	pushl  0x8(%ebp)
  80139b:	e8 6e fe ff ff       	call   80120e <fd_lookup>
  8013a0:	83 c4 08             	add    $0x8,%esp
  8013a3:	85 c0                	test   %eax,%eax
  8013a5:	0f 88 c1 00 00 00    	js     80146c <dup+0xe4>
		return r;
	close(newfdnum);
  8013ab:	83 ec 0c             	sub    $0xc,%esp
  8013ae:	56                   	push   %esi
  8013af:	e8 84 ff ff ff       	call   801338 <close>

	newfd = INDEX2FD(newfdnum);
  8013b4:	89 f3                	mov    %esi,%ebx
  8013b6:	c1 e3 0c             	shl    $0xc,%ebx
  8013b9:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013bf:	83 c4 04             	add    $0x4,%esp
  8013c2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013c5:	e8 de fd ff ff       	call   8011a8 <fd2data>
  8013ca:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013cc:	89 1c 24             	mov    %ebx,(%esp)
  8013cf:	e8 d4 fd ff ff       	call   8011a8 <fd2data>
  8013d4:	83 c4 10             	add    $0x10,%esp
  8013d7:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013da:	89 f8                	mov    %edi,%eax
  8013dc:	c1 e8 16             	shr    $0x16,%eax
  8013df:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013e6:	a8 01                	test   $0x1,%al
  8013e8:	74 37                	je     801421 <dup+0x99>
  8013ea:	89 f8                	mov    %edi,%eax
  8013ec:	c1 e8 0c             	shr    $0xc,%eax
  8013ef:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013f6:	f6 c2 01             	test   $0x1,%dl
  8013f9:	74 26                	je     801421 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013fb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801402:	83 ec 0c             	sub    $0xc,%esp
  801405:	25 07 0e 00 00       	and    $0xe07,%eax
  80140a:	50                   	push   %eax
  80140b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80140e:	6a 00                	push   $0x0
  801410:	57                   	push   %edi
  801411:	6a 00                	push   $0x0
  801413:	e8 c2 f8 ff ff       	call   800cda <sys_page_map>
  801418:	89 c7                	mov    %eax,%edi
  80141a:	83 c4 20             	add    $0x20,%esp
  80141d:	85 c0                	test   %eax,%eax
  80141f:	78 2e                	js     80144f <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801421:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801424:	89 d0                	mov    %edx,%eax
  801426:	c1 e8 0c             	shr    $0xc,%eax
  801429:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801430:	83 ec 0c             	sub    $0xc,%esp
  801433:	25 07 0e 00 00       	and    $0xe07,%eax
  801438:	50                   	push   %eax
  801439:	53                   	push   %ebx
  80143a:	6a 00                	push   $0x0
  80143c:	52                   	push   %edx
  80143d:	6a 00                	push   $0x0
  80143f:	e8 96 f8 ff ff       	call   800cda <sys_page_map>
  801444:	89 c7                	mov    %eax,%edi
  801446:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801449:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80144b:	85 ff                	test   %edi,%edi
  80144d:	79 1d                	jns    80146c <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80144f:	83 ec 08             	sub    $0x8,%esp
  801452:	53                   	push   %ebx
  801453:	6a 00                	push   $0x0
  801455:	e8 c2 f8 ff ff       	call   800d1c <sys_page_unmap>
	sys_page_unmap(0, nva);
  80145a:	83 c4 08             	add    $0x8,%esp
  80145d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801460:	6a 00                	push   $0x0
  801462:	e8 b5 f8 ff ff       	call   800d1c <sys_page_unmap>
	return r;
  801467:	83 c4 10             	add    $0x10,%esp
  80146a:	89 f8                	mov    %edi,%eax
}
  80146c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80146f:	5b                   	pop    %ebx
  801470:	5e                   	pop    %esi
  801471:	5f                   	pop    %edi
  801472:	5d                   	pop    %ebp
  801473:	c3                   	ret    

00801474 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801474:	55                   	push   %ebp
  801475:	89 e5                	mov    %esp,%ebp
  801477:	53                   	push   %ebx
  801478:	83 ec 14             	sub    $0x14,%esp
  80147b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80147e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801481:	50                   	push   %eax
  801482:	53                   	push   %ebx
  801483:	e8 86 fd ff ff       	call   80120e <fd_lookup>
  801488:	83 c4 08             	add    $0x8,%esp
  80148b:	89 c2                	mov    %eax,%edx
  80148d:	85 c0                	test   %eax,%eax
  80148f:	78 6d                	js     8014fe <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801491:	83 ec 08             	sub    $0x8,%esp
  801494:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801497:	50                   	push   %eax
  801498:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80149b:	ff 30                	pushl  (%eax)
  80149d:	e8 c2 fd ff ff       	call   801264 <dev_lookup>
  8014a2:	83 c4 10             	add    $0x10,%esp
  8014a5:	85 c0                	test   %eax,%eax
  8014a7:	78 4c                	js     8014f5 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014a9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014ac:	8b 42 08             	mov    0x8(%edx),%eax
  8014af:	83 e0 03             	and    $0x3,%eax
  8014b2:	83 f8 01             	cmp    $0x1,%eax
  8014b5:	75 21                	jne    8014d8 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014b7:	a1 20 44 80 00       	mov    0x804420,%eax
  8014bc:	8b 40 48             	mov    0x48(%eax),%eax
  8014bf:	83 ec 04             	sub    $0x4,%esp
  8014c2:	53                   	push   %ebx
  8014c3:	50                   	push   %eax
  8014c4:	68 15 29 80 00       	push   $0x802915
  8014c9:	e8 23 ee ff ff       	call   8002f1 <cprintf>
		return -E_INVAL;
  8014ce:	83 c4 10             	add    $0x10,%esp
  8014d1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014d6:	eb 26                	jmp    8014fe <read+0x8a>
	}
	if (!dev->dev_read)
  8014d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014db:	8b 40 08             	mov    0x8(%eax),%eax
  8014de:	85 c0                	test   %eax,%eax
  8014e0:	74 17                	je     8014f9 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014e2:	83 ec 04             	sub    $0x4,%esp
  8014e5:	ff 75 10             	pushl  0x10(%ebp)
  8014e8:	ff 75 0c             	pushl  0xc(%ebp)
  8014eb:	52                   	push   %edx
  8014ec:	ff d0                	call   *%eax
  8014ee:	89 c2                	mov    %eax,%edx
  8014f0:	83 c4 10             	add    $0x10,%esp
  8014f3:	eb 09                	jmp    8014fe <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014f5:	89 c2                	mov    %eax,%edx
  8014f7:	eb 05                	jmp    8014fe <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014f9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8014fe:	89 d0                	mov    %edx,%eax
  801500:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801503:	c9                   	leave  
  801504:	c3                   	ret    

00801505 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801505:	55                   	push   %ebp
  801506:	89 e5                	mov    %esp,%ebp
  801508:	57                   	push   %edi
  801509:	56                   	push   %esi
  80150a:	53                   	push   %ebx
  80150b:	83 ec 0c             	sub    $0xc,%esp
  80150e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801511:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801514:	bb 00 00 00 00       	mov    $0x0,%ebx
  801519:	eb 21                	jmp    80153c <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80151b:	83 ec 04             	sub    $0x4,%esp
  80151e:	89 f0                	mov    %esi,%eax
  801520:	29 d8                	sub    %ebx,%eax
  801522:	50                   	push   %eax
  801523:	89 d8                	mov    %ebx,%eax
  801525:	03 45 0c             	add    0xc(%ebp),%eax
  801528:	50                   	push   %eax
  801529:	57                   	push   %edi
  80152a:	e8 45 ff ff ff       	call   801474 <read>
		if (m < 0)
  80152f:	83 c4 10             	add    $0x10,%esp
  801532:	85 c0                	test   %eax,%eax
  801534:	78 10                	js     801546 <readn+0x41>
			return m;
		if (m == 0)
  801536:	85 c0                	test   %eax,%eax
  801538:	74 0a                	je     801544 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80153a:	01 c3                	add    %eax,%ebx
  80153c:	39 f3                	cmp    %esi,%ebx
  80153e:	72 db                	jb     80151b <readn+0x16>
  801540:	89 d8                	mov    %ebx,%eax
  801542:	eb 02                	jmp    801546 <readn+0x41>
  801544:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801546:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801549:	5b                   	pop    %ebx
  80154a:	5e                   	pop    %esi
  80154b:	5f                   	pop    %edi
  80154c:	5d                   	pop    %ebp
  80154d:	c3                   	ret    

0080154e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80154e:	55                   	push   %ebp
  80154f:	89 e5                	mov    %esp,%ebp
  801551:	53                   	push   %ebx
  801552:	83 ec 14             	sub    $0x14,%esp
  801555:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801558:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80155b:	50                   	push   %eax
  80155c:	53                   	push   %ebx
  80155d:	e8 ac fc ff ff       	call   80120e <fd_lookup>
  801562:	83 c4 08             	add    $0x8,%esp
  801565:	89 c2                	mov    %eax,%edx
  801567:	85 c0                	test   %eax,%eax
  801569:	78 68                	js     8015d3 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80156b:	83 ec 08             	sub    $0x8,%esp
  80156e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801571:	50                   	push   %eax
  801572:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801575:	ff 30                	pushl  (%eax)
  801577:	e8 e8 fc ff ff       	call   801264 <dev_lookup>
  80157c:	83 c4 10             	add    $0x10,%esp
  80157f:	85 c0                	test   %eax,%eax
  801581:	78 47                	js     8015ca <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801583:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801586:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80158a:	75 21                	jne    8015ad <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80158c:	a1 20 44 80 00       	mov    0x804420,%eax
  801591:	8b 40 48             	mov    0x48(%eax),%eax
  801594:	83 ec 04             	sub    $0x4,%esp
  801597:	53                   	push   %ebx
  801598:	50                   	push   %eax
  801599:	68 31 29 80 00       	push   $0x802931
  80159e:	e8 4e ed ff ff       	call   8002f1 <cprintf>
		return -E_INVAL;
  8015a3:	83 c4 10             	add    $0x10,%esp
  8015a6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015ab:	eb 26                	jmp    8015d3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015b0:	8b 52 0c             	mov    0xc(%edx),%edx
  8015b3:	85 d2                	test   %edx,%edx
  8015b5:	74 17                	je     8015ce <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015b7:	83 ec 04             	sub    $0x4,%esp
  8015ba:	ff 75 10             	pushl  0x10(%ebp)
  8015bd:	ff 75 0c             	pushl  0xc(%ebp)
  8015c0:	50                   	push   %eax
  8015c1:	ff d2                	call   *%edx
  8015c3:	89 c2                	mov    %eax,%edx
  8015c5:	83 c4 10             	add    $0x10,%esp
  8015c8:	eb 09                	jmp    8015d3 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ca:	89 c2                	mov    %eax,%edx
  8015cc:	eb 05                	jmp    8015d3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015ce:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015d3:	89 d0                	mov    %edx,%eax
  8015d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015d8:	c9                   	leave  
  8015d9:	c3                   	ret    

008015da <seek>:

int
seek(int fdnum, off_t offset)
{
  8015da:	55                   	push   %ebp
  8015db:	89 e5                	mov    %esp,%ebp
  8015dd:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015e0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015e3:	50                   	push   %eax
  8015e4:	ff 75 08             	pushl  0x8(%ebp)
  8015e7:	e8 22 fc ff ff       	call   80120e <fd_lookup>
  8015ec:	83 c4 08             	add    $0x8,%esp
  8015ef:	85 c0                	test   %eax,%eax
  8015f1:	78 0e                	js     801601 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015f9:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015fc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801601:	c9                   	leave  
  801602:	c3                   	ret    

00801603 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801603:	55                   	push   %ebp
  801604:	89 e5                	mov    %esp,%ebp
  801606:	53                   	push   %ebx
  801607:	83 ec 14             	sub    $0x14,%esp
  80160a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80160d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801610:	50                   	push   %eax
  801611:	53                   	push   %ebx
  801612:	e8 f7 fb ff ff       	call   80120e <fd_lookup>
  801617:	83 c4 08             	add    $0x8,%esp
  80161a:	89 c2                	mov    %eax,%edx
  80161c:	85 c0                	test   %eax,%eax
  80161e:	78 65                	js     801685 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801620:	83 ec 08             	sub    $0x8,%esp
  801623:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801626:	50                   	push   %eax
  801627:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80162a:	ff 30                	pushl  (%eax)
  80162c:	e8 33 fc ff ff       	call   801264 <dev_lookup>
  801631:	83 c4 10             	add    $0x10,%esp
  801634:	85 c0                	test   %eax,%eax
  801636:	78 44                	js     80167c <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801638:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80163b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80163f:	75 21                	jne    801662 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801641:	a1 20 44 80 00       	mov    0x804420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801646:	8b 40 48             	mov    0x48(%eax),%eax
  801649:	83 ec 04             	sub    $0x4,%esp
  80164c:	53                   	push   %ebx
  80164d:	50                   	push   %eax
  80164e:	68 f4 28 80 00       	push   $0x8028f4
  801653:	e8 99 ec ff ff       	call   8002f1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801658:	83 c4 10             	add    $0x10,%esp
  80165b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801660:	eb 23                	jmp    801685 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801662:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801665:	8b 52 18             	mov    0x18(%edx),%edx
  801668:	85 d2                	test   %edx,%edx
  80166a:	74 14                	je     801680 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80166c:	83 ec 08             	sub    $0x8,%esp
  80166f:	ff 75 0c             	pushl  0xc(%ebp)
  801672:	50                   	push   %eax
  801673:	ff d2                	call   *%edx
  801675:	89 c2                	mov    %eax,%edx
  801677:	83 c4 10             	add    $0x10,%esp
  80167a:	eb 09                	jmp    801685 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80167c:	89 c2                	mov    %eax,%edx
  80167e:	eb 05                	jmp    801685 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801680:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801685:	89 d0                	mov    %edx,%eax
  801687:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80168a:	c9                   	leave  
  80168b:	c3                   	ret    

0080168c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80168c:	55                   	push   %ebp
  80168d:	89 e5                	mov    %esp,%ebp
  80168f:	53                   	push   %ebx
  801690:	83 ec 14             	sub    $0x14,%esp
  801693:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801696:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801699:	50                   	push   %eax
  80169a:	ff 75 08             	pushl  0x8(%ebp)
  80169d:	e8 6c fb ff ff       	call   80120e <fd_lookup>
  8016a2:	83 c4 08             	add    $0x8,%esp
  8016a5:	89 c2                	mov    %eax,%edx
  8016a7:	85 c0                	test   %eax,%eax
  8016a9:	78 58                	js     801703 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ab:	83 ec 08             	sub    $0x8,%esp
  8016ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016b1:	50                   	push   %eax
  8016b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016b5:	ff 30                	pushl  (%eax)
  8016b7:	e8 a8 fb ff ff       	call   801264 <dev_lookup>
  8016bc:	83 c4 10             	add    $0x10,%esp
  8016bf:	85 c0                	test   %eax,%eax
  8016c1:	78 37                	js     8016fa <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016c6:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016ca:	74 32                	je     8016fe <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016cc:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016cf:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016d6:	00 00 00 
	stat->st_isdir = 0;
  8016d9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016e0:	00 00 00 
	stat->st_dev = dev;
  8016e3:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016e9:	83 ec 08             	sub    $0x8,%esp
  8016ec:	53                   	push   %ebx
  8016ed:	ff 75 f0             	pushl  -0x10(%ebp)
  8016f0:	ff 50 14             	call   *0x14(%eax)
  8016f3:	89 c2                	mov    %eax,%edx
  8016f5:	83 c4 10             	add    $0x10,%esp
  8016f8:	eb 09                	jmp    801703 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016fa:	89 c2                	mov    %eax,%edx
  8016fc:	eb 05                	jmp    801703 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016fe:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801703:	89 d0                	mov    %edx,%eax
  801705:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801708:	c9                   	leave  
  801709:	c3                   	ret    

0080170a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80170a:	55                   	push   %ebp
  80170b:	89 e5                	mov    %esp,%ebp
  80170d:	56                   	push   %esi
  80170e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80170f:	83 ec 08             	sub    $0x8,%esp
  801712:	6a 00                	push   $0x0
  801714:	ff 75 08             	pushl  0x8(%ebp)
  801717:	e8 e3 01 00 00       	call   8018ff <open>
  80171c:	89 c3                	mov    %eax,%ebx
  80171e:	83 c4 10             	add    $0x10,%esp
  801721:	85 c0                	test   %eax,%eax
  801723:	78 1b                	js     801740 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801725:	83 ec 08             	sub    $0x8,%esp
  801728:	ff 75 0c             	pushl  0xc(%ebp)
  80172b:	50                   	push   %eax
  80172c:	e8 5b ff ff ff       	call   80168c <fstat>
  801731:	89 c6                	mov    %eax,%esi
	close(fd);
  801733:	89 1c 24             	mov    %ebx,(%esp)
  801736:	e8 fd fb ff ff       	call   801338 <close>
	return r;
  80173b:	83 c4 10             	add    $0x10,%esp
  80173e:	89 f0                	mov    %esi,%eax
}
  801740:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801743:	5b                   	pop    %ebx
  801744:	5e                   	pop    %esi
  801745:	5d                   	pop    %ebp
  801746:	c3                   	ret    

00801747 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801747:	55                   	push   %ebp
  801748:	89 e5                	mov    %esp,%ebp
  80174a:	56                   	push   %esi
  80174b:	53                   	push   %ebx
  80174c:	89 c6                	mov    %eax,%esi
  80174e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801750:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801757:	75 12                	jne    80176b <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801759:	83 ec 0c             	sub    $0xc,%esp
  80175c:	6a 01                	push   $0x1
  80175e:	e8 a3 08 00 00       	call   802006 <ipc_find_env>
  801763:	a3 00 40 80 00       	mov    %eax,0x804000
  801768:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80176b:	6a 07                	push   $0x7
  80176d:	68 00 50 80 00       	push   $0x805000
  801772:	56                   	push   %esi
  801773:	ff 35 00 40 80 00    	pushl  0x804000
  801779:	e8 34 08 00 00       	call   801fb2 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80177e:	83 c4 0c             	add    $0xc,%esp
  801781:	6a 00                	push   $0x0
  801783:	53                   	push   %ebx
  801784:	6a 00                	push   $0x0
  801786:	e8 d2 07 00 00       	call   801f5d <ipc_recv>
}
  80178b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80178e:	5b                   	pop    %ebx
  80178f:	5e                   	pop    %esi
  801790:	5d                   	pop    %ebp
  801791:	c3                   	ret    

00801792 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801792:	55                   	push   %ebp
  801793:	89 e5                	mov    %esp,%ebp
  801795:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801798:	8b 45 08             	mov    0x8(%ebp),%eax
  80179b:	8b 40 0c             	mov    0xc(%eax),%eax
  80179e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017a6:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b0:	b8 02 00 00 00       	mov    $0x2,%eax
  8017b5:	e8 8d ff ff ff       	call   801747 <fsipc>
}
  8017ba:	c9                   	leave  
  8017bb:	c3                   	ret    

008017bc <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017bc:	55                   	push   %ebp
  8017bd:	89 e5                	mov    %esp,%ebp
  8017bf:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c5:	8b 40 0c             	mov    0xc(%eax),%eax
  8017c8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d2:	b8 06 00 00 00       	mov    $0x6,%eax
  8017d7:	e8 6b ff ff ff       	call   801747 <fsipc>
}
  8017dc:	c9                   	leave  
  8017dd:	c3                   	ret    

008017de <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017de:	55                   	push   %ebp
  8017df:	89 e5                	mov    %esp,%ebp
  8017e1:	53                   	push   %ebx
  8017e2:	83 ec 04             	sub    $0x4,%esp
  8017e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017eb:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ee:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f8:	b8 05 00 00 00       	mov    $0x5,%eax
  8017fd:	e8 45 ff ff ff       	call   801747 <fsipc>
  801802:	85 c0                	test   %eax,%eax
  801804:	78 2c                	js     801832 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801806:	83 ec 08             	sub    $0x8,%esp
  801809:	68 00 50 80 00       	push   $0x805000
  80180e:	53                   	push   %ebx
  80180f:	e8 80 f0 ff ff       	call   800894 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801814:	a1 80 50 80 00       	mov    0x805080,%eax
  801819:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80181f:	a1 84 50 80 00       	mov    0x805084,%eax
  801824:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80182a:	83 c4 10             	add    $0x10,%esp
  80182d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801832:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801835:	c9                   	leave  
  801836:	c3                   	ret    

00801837 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801837:	55                   	push   %ebp
  801838:	89 e5                	mov    %esp,%ebp
  80183a:	83 ec 0c             	sub    $0xc,%esp
  80183d:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
    
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  801840:	8b 55 08             	mov    0x8(%ebp),%edx
  801843:	8b 52 0c             	mov    0xc(%edx),%edx
  801846:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = MIN(n, PGSIZE);
  80184c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801851:	ba 00 10 00 00       	mov    $0x1000,%edx
  801856:	0f 47 c2             	cmova  %edx,%eax
  801859:	a3 04 50 80 00       	mov    %eax,0x805004
    memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  80185e:	50                   	push   %eax
  80185f:	ff 75 0c             	pushl  0xc(%ebp)
  801862:	68 08 50 80 00       	push   $0x805008
  801867:	e8 ba f1 ff ff       	call   800a26 <memmove>
    int r = fsipc(FSREQ_WRITE, NULL);
  80186c:	ba 00 00 00 00       	mov    $0x0,%edx
  801871:	b8 04 00 00 00       	mov    $0x4,%eax
  801876:	e8 cc fe ff ff       	call   801747 <fsipc>
    return r;
}
  80187b:	c9                   	leave  
  80187c:	c3                   	ret    

0080187d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80187d:	55                   	push   %ebp
  80187e:	89 e5                	mov    %esp,%ebp
  801880:	56                   	push   %esi
  801881:	53                   	push   %ebx
  801882:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801885:	8b 45 08             	mov    0x8(%ebp),%eax
  801888:	8b 40 0c             	mov    0xc(%eax),%eax
  80188b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801890:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801896:	ba 00 00 00 00       	mov    $0x0,%edx
  80189b:	b8 03 00 00 00       	mov    $0x3,%eax
  8018a0:	e8 a2 fe ff ff       	call   801747 <fsipc>
  8018a5:	89 c3                	mov    %eax,%ebx
  8018a7:	85 c0                	test   %eax,%eax
  8018a9:	78 4b                	js     8018f6 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018ab:	39 c6                	cmp    %eax,%esi
  8018ad:	73 16                	jae    8018c5 <devfile_read+0x48>
  8018af:	68 60 29 80 00       	push   $0x802960
  8018b4:	68 67 29 80 00       	push   $0x802967
  8018b9:	6a 7c                	push   $0x7c
  8018bb:	68 7c 29 80 00       	push   $0x80297c
  8018c0:	e8 53 e9 ff ff       	call   800218 <_panic>
	assert(r <= PGSIZE);
  8018c5:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018ca:	7e 16                	jle    8018e2 <devfile_read+0x65>
  8018cc:	68 87 29 80 00       	push   $0x802987
  8018d1:	68 67 29 80 00       	push   $0x802967
  8018d6:	6a 7d                	push   $0x7d
  8018d8:	68 7c 29 80 00       	push   $0x80297c
  8018dd:	e8 36 e9 ff ff       	call   800218 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018e2:	83 ec 04             	sub    $0x4,%esp
  8018e5:	50                   	push   %eax
  8018e6:	68 00 50 80 00       	push   $0x805000
  8018eb:	ff 75 0c             	pushl  0xc(%ebp)
  8018ee:	e8 33 f1 ff ff       	call   800a26 <memmove>
	return r;
  8018f3:	83 c4 10             	add    $0x10,%esp
}
  8018f6:	89 d8                	mov    %ebx,%eax
  8018f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018fb:	5b                   	pop    %ebx
  8018fc:	5e                   	pop    %esi
  8018fd:	5d                   	pop    %ebp
  8018fe:	c3                   	ret    

008018ff <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018ff:	55                   	push   %ebp
  801900:	89 e5                	mov    %esp,%ebp
  801902:	53                   	push   %ebx
  801903:	83 ec 20             	sub    $0x20,%esp
  801906:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801909:	53                   	push   %ebx
  80190a:	e8 4c ef ff ff       	call   80085b <strlen>
  80190f:	83 c4 10             	add    $0x10,%esp
  801912:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801917:	7f 67                	jg     801980 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801919:	83 ec 0c             	sub    $0xc,%esp
  80191c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80191f:	50                   	push   %eax
  801920:	e8 9a f8 ff ff       	call   8011bf <fd_alloc>
  801925:	83 c4 10             	add    $0x10,%esp
		return r;
  801928:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80192a:	85 c0                	test   %eax,%eax
  80192c:	78 57                	js     801985 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80192e:	83 ec 08             	sub    $0x8,%esp
  801931:	53                   	push   %ebx
  801932:	68 00 50 80 00       	push   $0x805000
  801937:	e8 58 ef ff ff       	call   800894 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80193c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80193f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801944:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801947:	b8 01 00 00 00       	mov    $0x1,%eax
  80194c:	e8 f6 fd ff ff       	call   801747 <fsipc>
  801951:	89 c3                	mov    %eax,%ebx
  801953:	83 c4 10             	add    $0x10,%esp
  801956:	85 c0                	test   %eax,%eax
  801958:	79 14                	jns    80196e <open+0x6f>
		fd_close(fd, 0);
  80195a:	83 ec 08             	sub    $0x8,%esp
  80195d:	6a 00                	push   $0x0
  80195f:	ff 75 f4             	pushl  -0xc(%ebp)
  801962:	e8 50 f9 ff ff       	call   8012b7 <fd_close>
		return r;
  801967:	83 c4 10             	add    $0x10,%esp
  80196a:	89 da                	mov    %ebx,%edx
  80196c:	eb 17                	jmp    801985 <open+0x86>
	}

	return fd2num(fd);
  80196e:	83 ec 0c             	sub    $0xc,%esp
  801971:	ff 75 f4             	pushl  -0xc(%ebp)
  801974:	e8 1f f8 ff ff       	call   801198 <fd2num>
  801979:	89 c2                	mov    %eax,%edx
  80197b:	83 c4 10             	add    $0x10,%esp
  80197e:	eb 05                	jmp    801985 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801980:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801985:	89 d0                	mov    %edx,%eax
  801987:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80198a:	c9                   	leave  
  80198b:	c3                   	ret    

0080198c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80198c:	55                   	push   %ebp
  80198d:	89 e5                	mov    %esp,%ebp
  80198f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801992:	ba 00 00 00 00       	mov    $0x0,%edx
  801997:	b8 08 00 00 00       	mov    $0x8,%eax
  80199c:	e8 a6 fd ff ff       	call   801747 <fsipc>
}
  8019a1:	c9                   	leave  
  8019a2:	c3                   	ret    

008019a3 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019a3:	55                   	push   %ebp
  8019a4:	89 e5                	mov    %esp,%ebp
  8019a6:	56                   	push   %esi
  8019a7:	53                   	push   %ebx
  8019a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019ab:	83 ec 0c             	sub    $0xc,%esp
  8019ae:	ff 75 08             	pushl  0x8(%ebp)
  8019b1:	e8 f2 f7 ff ff       	call   8011a8 <fd2data>
  8019b6:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019b8:	83 c4 08             	add    $0x8,%esp
  8019bb:	68 93 29 80 00       	push   $0x802993
  8019c0:	53                   	push   %ebx
  8019c1:	e8 ce ee ff ff       	call   800894 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019c6:	8b 46 04             	mov    0x4(%esi),%eax
  8019c9:	2b 06                	sub    (%esi),%eax
  8019cb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019d1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019d8:	00 00 00 
	stat->st_dev = &devpipe;
  8019db:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8019e2:	30 80 00 
	return 0;
}
  8019e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8019ea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019ed:	5b                   	pop    %ebx
  8019ee:	5e                   	pop    %esi
  8019ef:	5d                   	pop    %ebp
  8019f0:	c3                   	ret    

008019f1 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019f1:	55                   	push   %ebp
  8019f2:	89 e5                	mov    %esp,%ebp
  8019f4:	53                   	push   %ebx
  8019f5:	83 ec 0c             	sub    $0xc,%esp
  8019f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019fb:	53                   	push   %ebx
  8019fc:	6a 00                	push   $0x0
  8019fe:	e8 19 f3 ff ff       	call   800d1c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a03:	89 1c 24             	mov    %ebx,(%esp)
  801a06:	e8 9d f7 ff ff       	call   8011a8 <fd2data>
  801a0b:	83 c4 08             	add    $0x8,%esp
  801a0e:	50                   	push   %eax
  801a0f:	6a 00                	push   $0x0
  801a11:	e8 06 f3 ff ff       	call   800d1c <sys_page_unmap>
}
  801a16:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a19:	c9                   	leave  
  801a1a:	c3                   	ret    

00801a1b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a1b:	55                   	push   %ebp
  801a1c:	89 e5                	mov    %esp,%ebp
  801a1e:	57                   	push   %edi
  801a1f:	56                   	push   %esi
  801a20:	53                   	push   %ebx
  801a21:	83 ec 1c             	sub    $0x1c,%esp
  801a24:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a27:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a29:	a1 20 44 80 00       	mov    0x804420,%eax
  801a2e:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a31:	83 ec 0c             	sub    $0xc,%esp
  801a34:	ff 75 e0             	pushl  -0x20(%ebp)
  801a37:	e8 03 06 00 00       	call   80203f <pageref>
  801a3c:	89 c3                	mov    %eax,%ebx
  801a3e:	89 3c 24             	mov    %edi,(%esp)
  801a41:	e8 f9 05 00 00       	call   80203f <pageref>
  801a46:	83 c4 10             	add    $0x10,%esp
  801a49:	39 c3                	cmp    %eax,%ebx
  801a4b:	0f 94 c1             	sete   %cl
  801a4e:	0f b6 c9             	movzbl %cl,%ecx
  801a51:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a54:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801a5a:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a5d:	39 ce                	cmp    %ecx,%esi
  801a5f:	74 1b                	je     801a7c <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a61:	39 c3                	cmp    %eax,%ebx
  801a63:	75 c4                	jne    801a29 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a65:	8b 42 58             	mov    0x58(%edx),%eax
  801a68:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a6b:	50                   	push   %eax
  801a6c:	56                   	push   %esi
  801a6d:	68 9a 29 80 00       	push   $0x80299a
  801a72:	e8 7a e8 ff ff       	call   8002f1 <cprintf>
  801a77:	83 c4 10             	add    $0x10,%esp
  801a7a:	eb ad                	jmp    801a29 <_pipeisclosed+0xe>
	}
}
  801a7c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a82:	5b                   	pop    %ebx
  801a83:	5e                   	pop    %esi
  801a84:	5f                   	pop    %edi
  801a85:	5d                   	pop    %ebp
  801a86:	c3                   	ret    

00801a87 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a87:	55                   	push   %ebp
  801a88:	89 e5                	mov    %esp,%ebp
  801a8a:	57                   	push   %edi
  801a8b:	56                   	push   %esi
  801a8c:	53                   	push   %ebx
  801a8d:	83 ec 28             	sub    $0x28,%esp
  801a90:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a93:	56                   	push   %esi
  801a94:	e8 0f f7 ff ff       	call   8011a8 <fd2data>
  801a99:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a9b:	83 c4 10             	add    $0x10,%esp
  801a9e:	bf 00 00 00 00       	mov    $0x0,%edi
  801aa3:	eb 4b                	jmp    801af0 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801aa5:	89 da                	mov    %ebx,%edx
  801aa7:	89 f0                	mov    %esi,%eax
  801aa9:	e8 6d ff ff ff       	call   801a1b <_pipeisclosed>
  801aae:	85 c0                	test   %eax,%eax
  801ab0:	75 48                	jne    801afa <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ab2:	e8 c1 f1 ff ff       	call   800c78 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ab7:	8b 43 04             	mov    0x4(%ebx),%eax
  801aba:	8b 0b                	mov    (%ebx),%ecx
  801abc:	8d 51 20             	lea    0x20(%ecx),%edx
  801abf:	39 d0                	cmp    %edx,%eax
  801ac1:	73 e2                	jae    801aa5 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ac3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ac6:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801aca:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801acd:	89 c2                	mov    %eax,%edx
  801acf:	c1 fa 1f             	sar    $0x1f,%edx
  801ad2:	89 d1                	mov    %edx,%ecx
  801ad4:	c1 e9 1b             	shr    $0x1b,%ecx
  801ad7:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ada:	83 e2 1f             	and    $0x1f,%edx
  801add:	29 ca                	sub    %ecx,%edx
  801adf:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ae3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ae7:	83 c0 01             	add    $0x1,%eax
  801aea:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801aed:	83 c7 01             	add    $0x1,%edi
  801af0:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801af3:	75 c2                	jne    801ab7 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801af5:	8b 45 10             	mov    0x10(%ebp),%eax
  801af8:	eb 05                	jmp    801aff <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801afa:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801aff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b02:	5b                   	pop    %ebx
  801b03:	5e                   	pop    %esi
  801b04:	5f                   	pop    %edi
  801b05:	5d                   	pop    %ebp
  801b06:	c3                   	ret    

00801b07 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b07:	55                   	push   %ebp
  801b08:	89 e5                	mov    %esp,%ebp
  801b0a:	57                   	push   %edi
  801b0b:	56                   	push   %esi
  801b0c:	53                   	push   %ebx
  801b0d:	83 ec 18             	sub    $0x18,%esp
  801b10:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b13:	57                   	push   %edi
  801b14:	e8 8f f6 ff ff       	call   8011a8 <fd2data>
  801b19:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b1b:	83 c4 10             	add    $0x10,%esp
  801b1e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b23:	eb 3d                	jmp    801b62 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b25:	85 db                	test   %ebx,%ebx
  801b27:	74 04                	je     801b2d <devpipe_read+0x26>
				return i;
  801b29:	89 d8                	mov    %ebx,%eax
  801b2b:	eb 44                	jmp    801b71 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b2d:	89 f2                	mov    %esi,%edx
  801b2f:	89 f8                	mov    %edi,%eax
  801b31:	e8 e5 fe ff ff       	call   801a1b <_pipeisclosed>
  801b36:	85 c0                	test   %eax,%eax
  801b38:	75 32                	jne    801b6c <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b3a:	e8 39 f1 ff ff       	call   800c78 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b3f:	8b 06                	mov    (%esi),%eax
  801b41:	3b 46 04             	cmp    0x4(%esi),%eax
  801b44:	74 df                	je     801b25 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b46:	99                   	cltd   
  801b47:	c1 ea 1b             	shr    $0x1b,%edx
  801b4a:	01 d0                	add    %edx,%eax
  801b4c:	83 e0 1f             	and    $0x1f,%eax
  801b4f:	29 d0                	sub    %edx,%eax
  801b51:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b59:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b5c:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b5f:	83 c3 01             	add    $0x1,%ebx
  801b62:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b65:	75 d8                	jne    801b3f <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b67:	8b 45 10             	mov    0x10(%ebp),%eax
  801b6a:	eb 05                	jmp    801b71 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b6c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b71:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b74:	5b                   	pop    %ebx
  801b75:	5e                   	pop    %esi
  801b76:	5f                   	pop    %edi
  801b77:	5d                   	pop    %ebp
  801b78:	c3                   	ret    

00801b79 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b79:	55                   	push   %ebp
  801b7a:	89 e5                	mov    %esp,%ebp
  801b7c:	56                   	push   %esi
  801b7d:	53                   	push   %ebx
  801b7e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b81:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b84:	50                   	push   %eax
  801b85:	e8 35 f6 ff ff       	call   8011bf <fd_alloc>
  801b8a:	83 c4 10             	add    $0x10,%esp
  801b8d:	89 c2                	mov    %eax,%edx
  801b8f:	85 c0                	test   %eax,%eax
  801b91:	0f 88 2c 01 00 00    	js     801cc3 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b97:	83 ec 04             	sub    $0x4,%esp
  801b9a:	68 07 04 00 00       	push   $0x407
  801b9f:	ff 75 f4             	pushl  -0xc(%ebp)
  801ba2:	6a 00                	push   $0x0
  801ba4:	e8 ee f0 ff ff       	call   800c97 <sys_page_alloc>
  801ba9:	83 c4 10             	add    $0x10,%esp
  801bac:	89 c2                	mov    %eax,%edx
  801bae:	85 c0                	test   %eax,%eax
  801bb0:	0f 88 0d 01 00 00    	js     801cc3 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801bb6:	83 ec 0c             	sub    $0xc,%esp
  801bb9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bbc:	50                   	push   %eax
  801bbd:	e8 fd f5 ff ff       	call   8011bf <fd_alloc>
  801bc2:	89 c3                	mov    %eax,%ebx
  801bc4:	83 c4 10             	add    $0x10,%esp
  801bc7:	85 c0                	test   %eax,%eax
  801bc9:	0f 88 e2 00 00 00    	js     801cb1 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bcf:	83 ec 04             	sub    $0x4,%esp
  801bd2:	68 07 04 00 00       	push   $0x407
  801bd7:	ff 75 f0             	pushl  -0x10(%ebp)
  801bda:	6a 00                	push   $0x0
  801bdc:	e8 b6 f0 ff ff       	call   800c97 <sys_page_alloc>
  801be1:	89 c3                	mov    %eax,%ebx
  801be3:	83 c4 10             	add    $0x10,%esp
  801be6:	85 c0                	test   %eax,%eax
  801be8:	0f 88 c3 00 00 00    	js     801cb1 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801bee:	83 ec 0c             	sub    $0xc,%esp
  801bf1:	ff 75 f4             	pushl  -0xc(%ebp)
  801bf4:	e8 af f5 ff ff       	call   8011a8 <fd2data>
  801bf9:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bfb:	83 c4 0c             	add    $0xc,%esp
  801bfe:	68 07 04 00 00       	push   $0x407
  801c03:	50                   	push   %eax
  801c04:	6a 00                	push   $0x0
  801c06:	e8 8c f0 ff ff       	call   800c97 <sys_page_alloc>
  801c0b:	89 c3                	mov    %eax,%ebx
  801c0d:	83 c4 10             	add    $0x10,%esp
  801c10:	85 c0                	test   %eax,%eax
  801c12:	0f 88 89 00 00 00    	js     801ca1 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c18:	83 ec 0c             	sub    $0xc,%esp
  801c1b:	ff 75 f0             	pushl  -0x10(%ebp)
  801c1e:	e8 85 f5 ff ff       	call   8011a8 <fd2data>
  801c23:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c2a:	50                   	push   %eax
  801c2b:	6a 00                	push   $0x0
  801c2d:	56                   	push   %esi
  801c2e:	6a 00                	push   $0x0
  801c30:	e8 a5 f0 ff ff       	call   800cda <sys_page_map>
  801c35:	89 c3                	mov    %eax,%ebx
  801c37:	83 c4 20             	add    $0x20,%esp
  801c3a:	85 c0                	test   %eax,%eax
  801c3c:	78 55                	js     801c93 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c3e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c44:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c47:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c49:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c4c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c53:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c59:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c5c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c61:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c68:	83 ec 0c             	sub    $0xc,%esp
  801c6b:	ff 75 f4             	pushl  -0xc(%ebp)
  801c6e:	e8 25 f5 ff ff       	call   801198 <fd2num>
  801c73:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c76:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c78:	83 c4 04             	add    $0x4,%esp
  801c7b:	ff 75 f0             	pushl  -0x10(%ebp)
  801c7e:	e8 15 f5 ff ff       	call   801198 <fd2num>
  801c83:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c86:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c89:	83 c4 10             	add    $0x10,%esp
  801c8c:	ba 00 00 00 00       	mov    $0x0,%edx
  801c91:	eb 30                	jmp    801cc3 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c93:	83 ec 08             	sub    $0x8,%esp
  801c96:	56                   	push   %esi
  801c97:	6a 00                	push   $0x0
  801c99:	e8 7e f0 ff ff       	call   800d1c <sys_page_unmap>
  801c9e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801ca1:	83 ec 08             	sub    $0x8,%esp
  801ca4:	ff 75 f0             	pushl  -0x10(%ebp)
  801ca7:	6a 00                	push   $0x0
  801ca9:	e8 6e f0 ff ff       	call   800d1c <sys_page_unmap>
  801cae:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801cb1:	83 ec 08             	sub    $0x8,%esp
  801cb4:	ff 75 f4             	pushl  -0xc(%ebp)
  801cb7:	6a 00                	push   $0x0
  801cb9:	e8 5e f0 ff ff       	call   800d1c <sys_page_unmap>
  801cbe:	83 c4 10             	add    $0x10,%esp
  801cc1:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801cc3:	89 d0                	mov    %edx,%eax
  801cc5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cc8:	5b                   	pop    %ebx
  801cc9:	5e                   	pop    %esi
  801cca:	5d                   	pop    %ebp
  801ccb:	c3                   	ret    

00801ccc <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ccc:	55                   	push   %ebp
  801ccd:	89 e5                	mov    %esp,%ebp
  801ccf:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cd2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cd5:	50                   	push   %eax
  801cd6:	ff 75 08             	pushl  0x8(%ebp)
  801cd9:	e8 30 f5 ff ff       	call   80120e <fd_lookup>
  801cde:	83 c4 10             	add    $0x10,%esp
  801ce1:	85 c0                	test   %eax,%eax
  801ce3:	78 18                	js     801cfd <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ce5:	83 ec 0c             	sub    $0xc,%esp
  801ce8:	ff 75 f4             	pushl  -0xc(%ebp)
  801ceb:	e8 b8 f4 ff ff       	call   8011a8 <fd2data>
	return _pipeisclosed(fd, p);
  801cf0:	89 c2                	mov    %eax,%edx
  801cf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf5:	e8 21 fd ff ff       	call   801a1b <_pipeisclosed>
  801cfa:	83 c4 10             	add    $0x10,%esp
}
  801cfd:	c9                   	leave  
  801cfe:	c3                   	ret    

00801cff <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801cff:	55                   	push   %ebp
  801d00:	89 e5                	mov    %esp,%ebp
  801d02:	56                   	push   %esi
  801d03:	53                   	push   %ebx
  801d04:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801d07:	85 f6                	test   %esi,%esi
  801d09:	75 16                	jne    801d21 <wait+0x22>
  801d0b:	68 b2 29 80 00       	push   $0x8029b2
  801d10:	68 67 29 80 00       	push   $0x802967
  801d15:	6a 09                	push   $0x9
  801d17:	68 bd 29 80 00       	push   $0x8029bd
  801d1c:	e8 f7 e4 ff ff       	call   800218 <_panic>
	e = &envs[ENVX(envid)];
  801d21:	89 f3                	mov    %esi,%ebx
  801d23:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801d29:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  801d2c:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  801d32:	eb 05                	jmp    801d39 <wait+0x3a>
		sys_yield();
  801d34:	e8 3f ef ff ff       	call   800c78 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801d39:	8b 43 48             	mov    0x48(%ebx),%eax
  801d3c:	39 c6                	cmp    %eax,%esi
  801d3e:	75 07                	jne    801d47 <wait+0x48>
  801d40:	8b 43 54             	mov    0x54(%ebx),%eax
  801d43:	85 c0                	test   %eax,%eax
  801d45:	75 ed                	jne    801d34 <wait+0x35>
		sys_yield();
}
  801d47:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d4a:	5b                   	pop    %ebx
  801d4b:	5e                   	pop    %esi
  801d4c:	5d                   	pop    %ebp
  801d4d:	c3                   	ret    

00801d4e <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d4e:	55                   	push   %ebp
  801d4f:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d51:	b8 00 00 00 00       	mov    $0x0,%eax
  801d56:	5d                   	pop    %ebp
  801d57:	c3                   	ret    

00801d58 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d58:	55                   	push   %ebp
  801d59:	89 e5                	mov    %esp,%ebp
  801d5b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d5e:	68 c8 29 80 00       	push   $0x8029c8
  801d63:	ff 75 0c             	pushl  0xc(%ebp)
  801d66:	e8 29 eb ff ff       	call   800894 <strcpy>
	return 0;
}
  801d6b:	b8 00 00 00 00       	mov    $0x0,%eax
  801d70:	c9                   	leave  
  801d71:	c3                   	ret    

00801d72 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d72:	55                   	push   %ebp
  801d73:	89 e5                	mov    %esp,%ebp
  801d75:	57                   	push   %edi
  801d76:	56                   	push   %esi
  801d77:	53                   	push   %ebx
  801d78:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d7e:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d83:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d89:	eb 2d                	jmp    801db8 <devcons_write+0x46>
		m = n - tot;
  801d8b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d8e:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d90:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d93:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d98:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d9b:	83 ec 04             	sub    $0x4,%esp
  801d9e:	53                   	push   %ebx
  801d9f:	03 45 0c             	add    0xc(%ebp),%eax
  801da2:	50                   	push   %eax
  801da3:	57                   	push   %edi
  801da4:	e8 7d ec ff ff       	call   800a26 <memmove>
		sys_cputs(buf, m);
  801da9:	83 c4 08             	add    $0x8,%esp
  801dac:	53                   	push   %ebx
  801dad:	57                   	push   %edi
  801dae:	e8 28 ee ff ff       	call   800bdb <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801db3:	01 de                	add    %ebx,%esi
  801db5:	83 c4 10             	add    $0x10,%esp
  801db8:	89 f0                	mov    %esi,%eax
  801dba:	3b 75 10             	cmp    0x10(%ebp),%esi
  801dbd:	72 cc                	jb     801d8b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801dbf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dc2:	5b                   	pop    %ebx
  801dc3:	5e                   	pop    %esi
  801dc4:	5f                   	pop    %edi
  801dc5:	5d                   	pop    %ebp
  801dc6:	c3                   	ret    

00801dc7 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801dc7:	55                   	push   %ebp
  801dc8:	89 e5                	mov    %esp,%ebp
  801dca:	83 ec 08             	sub    $0x8,%esp
  801dcd:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801dd2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801dd6:	74 2a                	je     801e02 <devcons_read+0x3b>
  801dd8:	eb 05                	jmp    801ddf <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801dda:	e8 99 ee ff ff       	call   800c78 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801ddf:	e8 15 ee ff ff       	call   800bf9 <sys_cgetc>
  801de4:	85 c0                	test   %eax,%eax
  801de6:	74 f2                	je     801dda <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801de8:	85 c0                	test   %eax,%eax
  801dea:	78 16                	js     801e02 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801dec:	83 f8 04             	cmp    $0x4,%eax
  801def:	74 0c                	je     801dfd <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801df1:	8b 55 0c             	mov    0xc(%ebp),%edx
  801df4:	88 02                	mov    %al,(%edx)
	return 1;
  801df6:	b8 01 00 00 00       	mov    $0x1,%eax
  801dfb:	eb 05                	jmp    801e02 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801dfd:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e02:	c9                   	leave  
  801e03:	c3                   	ret    

00801e04 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e04:	55                   	push   %ebp
  801e05:	89 e5                	mov    %esp,%ebp
  801e07:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e0a:	8b 45 08             	mov    0x8(%ebp),%eax
  801e0d:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e10:	6a 01                	push   $0x1
  801e12:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e15:	50                   	push   %eax
  801e16:	e8 c0 ed ff ff       	call   800bdb <sys_cputs>
}
  801e1b:	83 c4 10             	add    $0x10,%esp
  801e1e:	c9                   	leave  
  801e1f:	c3                   	ret    

00801e20 <getchar>:

int
getchar(void)
{
  801e20:	55                   	push   %ebp
  801e21:	89 e5                	mov    %esp,%ebp
  801e23:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e26:	6a 01                	push   $0x1
  801e28:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e2b:	50                   	push   %eax
  801e2c:	6a 00                	push   $0x0
  801e2e:	e8 41 f6 ff ff       	call   801474 <read>
	if (r < 0)
  801e33:	83 c4 10             	add    $0x10,%esp
  801e36:	85 c0                	test   %eax,%eax
  801e38:	78 0f                	js     801e49 <getchar+0x29>
		return r;
	if (r < 1)
  801e3a:	85 c0                	test   %eax,%eax
  801e3c:	7e 06                	jle    801e44 <getchar+0x24>
		return -E_EOF;
	return c;
  801e3e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e42:	eb 05                	jmp    801e49 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e44:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e49:	c9                   	leave  
  801e4a:	c3                   	ret    

00801e4b <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e4b:	55                   	push   %ebp
  801e4c:	89 e5                	mov    %esp,%ebp
  801e4e:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e51:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e54:	50                   	push   %eax
  801e55:	ff 75 08             	pushl  0x8(%ebp)
  801e58:	e8 b1 f3 ff ff       	call   80120e <fd_lookup>
  801e5d:	83 c4 10             	add    $0x10,%esp
  801e60:	85 c0                	test   %eax,%eax
  801e62:	78 11                	js     801e75 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e64:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e67:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e6d:	39 10                	cmp    %edx,(%eax)
  801e6f:	0f 94 c0             	sete   %al
  801e72:	0f b6 c0             	movzbl %al,%eax
}
  801e75:	c9                   	leave  
  801e76:	c3                   	ret    

00801e77 <opencons>:

int
opencons(void)
{
  801e77:	55                   	push   %ebp
  801e78:	89 e5                	mov    %esp,%ebp
  801e7a:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e7d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e80:	50                   	push   %eax
  801e81:	e8 39 f3 ff ff       	call   8011bf <fd_alloc>
  801e86:	83 c4 10             	add    $0x10,%esp
		return r;
  801e89:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e8b:	85 c0                	test   %eax,%eax
  801e8d:	78 3e                	js     801ecd <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e8f:	83 ec 04             	sub    $0x4,%esp
  801e92:	68 07 04 00 00       	push   $0x407
  801e97:	ff 75 f4             	pushl  -0xc(%ebp)
  801e9a:	6a 00                	push   $0x0
  801e9c:	e8 f6 ed ff ff       	call   800c97 <sys_page_alloc>
  801ea1:	83 c4 10             	add    $0x10,%esp
		return r;
  801ea4:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ea6:	85 c0                	test   %eax,%eax
  801ea8:	78 23                	js     801ecd <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801eaa:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801eb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eb3:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801eb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eb8:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ebf:	83 ec 0c             	sub    $0xc,%esp
  801ec2:	50                   	push   %eax
  801ec3:	e8 d0 f2 ff ff       	call   801198 <fd2num>
  801ec8:	89 c2                	mov    %eax,%edx
  801eca:	83 c4 10             	add    $0x10,%esp
}
  801ecd:	89 d0                	mov    %edx,%eax
  801ecf:	c9                   	leave  
  801ed0:	c3                   	ret    

00801ed1 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801ed1:	55                   	push   %ebp
  801ed2:	89 e5                	mov    %esp,%ebp
  801ed4:	83 ec 08             	sub    $0x8,%esp
	int r;
	int ret;
	if (_pgfault_handler == 0) {
  801ed7:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801ede:	75 36                	jne    801f16 <set_pgfault_handler+0x45>
		// First time through!
		// LAB 4: Your code here.
        
        	ret = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  801ee0:	a1 20 44 80 00       	mov    0x804420,%eax
  801ee5:	8b 40 48             	mov    0x48(%eax),%eax
  801ee8:	83 ec 04             	sub    $0x4,%esp
  801eeb:	68 07 0e 00 00       	push   $0xe07
  801ef0:	68 00 f0 bf ee       	push   $0xeebff000
  801ef5:	50                   	push   %eax
  801ef6:	e8 9c ed ff ff       	call   800c97 <sys_page_alloc>
		if (ret < 0) {
  801efb:	83 c4 10             	add    $0x10,%esp
  801efe:	85 c0                	test   %eax,%eax
  801f00:	79 14                	jns    801f16 <set_pgfault_handler+0x45>
		    panic("Allocate user exception stack failed!\n");
  801f02:	83 ec 04             	sub    $0x4,%esp
  801f05:	68 d4 29 80 00       	push   $0x8029d4
  801f0a:	6a 23                	push   $0x23
  801f0c:	68 fc 29 80 00       	push   $0x8029fc
  801f11:	e8 02 e3 ff ff       	call   800218 <_panic>
		}
	}
	sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  801f16:	a1 20 44 80 00       	mov    0x804420,%eax
  801f1b:	8b 40 48             	mov    0x48(%eax),%eax
  801f1e:	83 ec 08             	sub    $0x8,%esp
  801f21:	68 39 1f 80 00       	push   $0x801f39
  801f26:	50                   	push   %eax
  801f27:	e8 b6 ee ff ff       	call   800de2 <sys_env_set_pgfault_upcall>
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f2c:	8b 45 08             	mov    0x8(%ebp),%eax
  801f2f:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801f34:	83 c4 10             	add    $0x10,%esp
  801f37:	c9                   	leave  
  801f38:	c3                   	ret    

00801f39 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f39:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f3a:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f3f:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f41:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 0x28(%esp), %ebx  # trap-time eip
  801f44:	8b 5c 24 28          	mov    0x28(%esp),%ebx
        subl $0x4, 0x30(%esp)  # trap-time esp minus 4
  801f48:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax 
  801f4d:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl %ebx, (%eax)      # trap-time esp store trap-time eip
  801f51:	89 18                	mov    %ebx,(%eax)
        addl $0x8, %esp
  801f53:	83 c4 08             	add    $0x8,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  801f56:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  801f57:	83 c4 04             	add    $0x4,%esp
        popfl
  801f5a:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  801f5b:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  801f5c:	c3                   	ret    

00801f5d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f5d:	55                   	push   %ebp
  801f5e:	89 e5                	mov    %esp,%ebp
  801f60:	56                   	push   %esi
  801f61:	53                   	push   %ebx
  801f62:	8b 75 08             	mov    0x8(%ebp),%esi
  801f65:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f68:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_recv not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  801f6b:	85 c0                	test   %eax,%eax
  801f6d:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f72:	0f 44 c2             	cmove  %edx,%eax

    int r = sys_ipc_recv(pg);
  801f75:	83 ec 0c             	sub    $0xc,%esp
  801f78:	50                   	push   %eax
  801f79:	e8 c9 ee ff ff       	call   800e47 <sys_ipc_recv>
    int from_env = 0, perm = 0;
    if (r == 0) {
  801f7e:	83 c4 10             	add    $0x10,%esp
  801f81:	85 c0                	test   %eax,%eax
  801f83:	75 10                	jne    801f95 <ipc_recv+0x38>
        from_env = thisenv->env_ipc_from;
  801f85:	a1 20 44 80 00       	mov    0x804420,%eax
  801f8a:	8b 48 74             	mov    0x74(%eax),%ecx
        perm = thisenv->env_ipc_perm;
  801f8d:	8b 50 78             	mov    0x78(%eax),%edx
        r = thisenv->env_ipc_value;
  801f90:	8b 40 70             	mov    0x70(%eax),%eax
  801f93:	eb 0a                	jmp    801f9f <ipc_recv+0x42>
    } else {
        from_env = 0;
        perm = 0;
  801f95:	ba 00 00 00 00       	mov    $0x0,%edx
    if (r == 0) {
        from_env = thisenv->env_ipc_from;
        perm = thisenv->env_ipc_perm;
        r = thisenv->env_ipc_value;
    } else {
        from_env = 0;
  801f9a:	b9 00 00 00 00       	mov    $0x0,%ecx
        perm = 0;
    }

    if (from_env_store) *from_env_store = from_env;
  801f9f:	85 f6                	test   %esi,%esi
  801fa1:	74 02                	je     801fa5 <ipc_recv+0x48>
  801fa3:	89 0e                	mov    %ecx,(%esi)
    if (perm_store) *perm_store = perm;
  801fa5:	85 db                	test   %ebx,%ebx
  801fa7:	74 02                	je     801fab <ipc_recv+0x4e>
  801fa9:	89 13                	mov    %edx,(%ebx)

    return r;
}
  801fab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fae:	5b                   	pop    %ebx
  801faf:	5e                   	pop    %esi
  801fb0:	5d                   	pop    %ebp
  801fb1:	c3                   	ret    

00801fb2 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fb2:	55                   	push   %ebp
  801fb3:	89 e5                	mov    %esp,%ebp
  801fb5:	57                   	push   %edi
  801fb6:	56                   	push   %esi
  801fb7:	53                   	push   %ebx
  801fb8:	83 ec 0c             	sub    $0xc,%esp
  801fbb:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fbe:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fc1:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  801fc4:	85 db                	test   %ebx,%ebx
  801fc6:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801fcb:	0f 44 d8             	cmove  %eax,%ebx
  801fce:	eb 1c                	jmp    801fec <ipc_send+0x3a>

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        if (ret != -E_IPC_NOT_RECV)
  801fd0:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fd3:	74 12                	je     801fe7 <ipc_send+0x35>
            panic("ipc_send error %e", ret);
  801fd5:	50                   	push   %eax
  801fd6:	68 0a 2a 80 00       	push   $0x802a0a
  801fdb:	6a 40                	push   $0x40
  801fdd:	68 1c 2a 80 00       	push   $0x802a1c
  801fe2:	e8 31 e2 ff ff       	call   800218 <_panic>
        sys_yield();
  801fe7:	e8 8c ec ff ff       	call   800c78 <sys_yield>
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801fec:	ff 75 14             	pushl  0x14(%ebp)
  801fef:	53                   	push   %ebx
  801ff0:	56                   	push   %esi
  801ff1:	57                   	push   %edi
  801ff2:	e8 2d ee ff ff       	call   800e24 <sys_ipc_try_send>
  801ff7:	83 c4 10             	add    $0x10,%esp
  801ffa:	85 c0                	test   %eax,%eax
  801ffc:	75 d2                	jne    801fd0 <ipc_send+0x1e>
        if (ret != -E_IPC_NOT_RECV)
            panic("ipc_send error %e", ret);
        sys_yield();
    }
}
  801ffe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802001:	5b                   	pop    %ebx
  802002:	5e                   	pop    %esi
  802003:	5f                   	pop    %edi
  802004:	5d                   	pop    %ebp
  802005:	c3                   	ret    

00802006 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802006:	55                   	push   %ebp
  802007:	89 e5                	mov    %esp,%ebp
  802009:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80200c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802011:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802014:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80201a:	8b 52 50             	mov    0x50(%edx),%edx
  80201d:	39 ca                	cmp    %ecx,%edx
  80201f:	75 0d                	jne    80202e <ipc_find_env+0x28>
			return envs[i].env_id;
  802021:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802024:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802029:	8b 40 48             	mov    0x48(%eax),%eax
  80202c:	eb 0f                	jmp    80203d <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80202e:	83 c0 01             	add    $0x1,%eax
  802031:	3d 00 04 00 00       	cmp    $0x400,%eax
  802036:	75 d9                	jne    802011 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802038:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80203d:	5d                   	pop    %ebp
  80203e:	c3                   	ret    

0080203f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80203f:	55                   	push   %ebp
  802040:	89 e5                	mov    %esp,%ebp
  802042:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802045:	89 d0                	mov    %edx,%eax
  802047:	c1 e8 16             	shr    $0x16,%eax
  80204a:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802051:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802056:	f6 c1 01             	test   $0x1,%cl
  802059:	74 1d                	je     802078 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80205b:	c1 ea 0c             	shr    $0xc,%edx
  80205e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802065:	f6 c2 01             	test   $0x1,%dl
  802068:	74 0e                	je     802078 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80206a:	c1 ea 0c             	shr    $0xc,%edx
  80206d:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802074:	ef 
  802075:	0f b7 c0             	movzwl %ax,%eax
}
  802078:	5d                   	pop    %ebp
  802079:	c3                   	ret    
  80207a:	66 90                	xchg   %ax,%ax
  80207c:	66 90                	xchg   %ax,%ax
  80207e:	66 90                	xchg   %ax,%ax

00802080 <__udivdi3>:
  802080:	55                   	push   %ebp
  802081:	57                   	push   %edi
  802082:	56                   	push   %esi
  802083:	53                   	push   %ebx
  802084:	83 ec 1c             	sub    $0x1c,%esp
  802087:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80208b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80208f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802093:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802097:	85 f6                	test   %esi,%esi
  802099:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80209d:	89 ca                	mov    %ecx,%edx
  80209f:	89 f8                	mov    %edi,%eax
  8020a1:	75 3d                	jne    8020e0 <__udivdi3+0x60>
  8020a3:	39 cf                	cmp    %ecx,%edi
  8020a5:	0f 87 c5 00 00 00    	ja     802170 <__udivdi3+0xf0>
  8020ab:	85 ff                	test   %edi,%edi
  8020ad:	89 fd                	mov    %edi,%ebp
  8020af:	75 0b                	jne    8020bc <__udivdi3+0x3c>
  8020b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020b6:	31 d2                	xor    %edx,%edx
  8020b8:	f7 f7                	div    %edi
  8020ba:	89 c5                	mov    %eax,%ebp
  8020bc:	89 c8                	mov    %ecx,%eax
  8020be:	31 d2                	xor    %edx,%edx
  8020c0:	f7 f5                	div    %ebp
  8020c2:	89 c1                	mov    %eax,%ecx
  8020c4:	89 d8                	mov    %ebx,%eax
  8020c6:	89 cf                	mov    %ecx,%edi
  8020c8:	f7 f5                	div    %ebp
  8020ca:	89 c3                	mov    %eax,%ebx
  8020cc:	89 d8                	mov    %ebx,%eax
  8020ce:	89 fa                	mov    %edi,%edx
  8020d0:	83 c4 1c             	add    $0x1c,%esp
  8020d3:	5b                   	pop    %ebx
  8020d4:	5e                   	pop    %esi
  8020d5:	5f                   	pop    %edi
  8020d6:	5d                   	pop    %ebp
  8020d7:	c3                   	ret    
  8020d8:	90                   	nop
  8020d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020e0:	39 ce                	cmp    %ecx,%esi
  8020e2:	77 74                	ja     802158 <__udivdi3+0xd8>
  8020e4:	0f bd fe             	bsr    %esi,%edi
  8020e7:	83 f7 1f             	xor    $0x1f,%edi
  8020ea:	0f 84 98 00 00 00    	je     802188 <__udivdi3+0x108>
  8020f0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8020f5:	89 f9                	mov    %edi,%ecx
  8020f7:	89 c5                	mov    %eax,%ebp
  8020f9:	29 fb                	sub    %edi,%ebx
  8020fb:	d3 e6                	shl    %cl,%esi
  8020fd:	89 d9                	mov    %ebx,%ecx
  8020ff:	d3 ed                	shr    %cl,%ebp
  802101:	89 f9                	mov    %edi,%ecx
  802103:	d3 e0                	shl    %cl,%eax
  802105:	09 ee                	or     %ebp,%esi
  802107:	89 d9                	mov    %ebx,%ecx
  802109:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80210d:	89 d5                	mov    %edx,%ebp
  80210f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802113:	d3 ed                	shr    %cl,%ebp
  802115:	89 f9                	mov    %edi,%ecx
  802117:	d3 e2                	shl    %cl,%edx
  802119:	89 d9                	mov    %ebx,%ecx
  80211b:	d3 e8                	shr    %cl,%eax
  80211d:	09 c2                	or     %eax,%edx
  80211f:	89 d0                	mov    %edx,%eax
  802121:	89 ea                	mov    %ebp,%edx
  802123:	f7 f6                	div    %esi
  802125:	89 d5                	mov    %edx,%ebp
  802127:	89 c3                	mov    %eax,%ebx
  802129:	f7 64 24 0c          	mull   0xc(%esp)
  80212d:	39 d5                	cmp    %edx,%ebp
  80212f:	72 10                	jb     802141 <__udivdi3+0xc1>
  802131:	8b 74 24 08          	mov    0x8(%esp),%esi
  802135:	89 f9                	mov    %edi,%ecx
  802137:	d3 e6                	shl    %cl,%esi
  802139:	39 c6                	cmp    %eax,%esi
  80213b:	73 07                	jae    802144 <__udivdi3+0xc4>
  80213d:	39 d5                	cmp    %edx,%ebp
  80213f:	75 03                	jne    802144 <__udivdi3+0xc4>
  802141:	83 eb 01             	sub    $0x1,%ebx
  802144:	31 ff                	xor    %edi,%edi
  802146:	89 d8                	mov    %ebx,%eax
  802148:	89 fa                	mov    %edi,%edx
  80214a:	83 c4 1c             	add    $0x1c,%esp
  80214d:	5b                   	pop    %ebx
  80214e:	5e                   	pop    %esi
  80214f:	5f                   	pop    %edi
  802150:	5d                   	pop    %ebp
  802151:	c3                   	ret    
  802152:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802158:	31 ff                	xor    %edi,%edi
  80215a:	31 db                	xor    %ebx,%ebx
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
  802170:	89 d8                	mov    %ebx,%eax
  802172:	f7 f7                	div    %edi
  802174:	31 ff                	xor    %edi,%edi
  802176:	89 c3                	mov    %eax,%ebx
  802178:	89 d8                	mov    %ebx,%eax
  80217a:	89 fa                	mov    %edi,%edx
  80217c:	83 c4 1c             	add    $0x1c,%esp
  80217f:	5b                   	pop    %ebx
  802180:	5e                   	pop    %esi
  802181:	5f                   	pop    %edi
  802182:	5d                   	pop    %ebp
  802183:	c3                   	ret    
  802184:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802188:	39 ce                	cmp    %ecx,%esi
  80218a:	72 0c                	jb     802198 <__udivdi3+0x118>
  80218c:	31 db                	xor    %ebx,%ebx
  80218e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802192:	0f 87 34 ff ff ff    	ja     8020cc <__udivdi3+0x4c>
  802198:	bb 01 00 00 00       	mov    $0x1,%ebx
  80219d:	e9 2a ff ff ff       	jmp    8020cc <__udivdi3+0x4c>
  8021a2:	66 90                	xchg   %ax,%ax
  8021a4:	66 90                	xchg   %ax,%ax
  8021a6:	66 90                	xchg   %ax,%ax
  8021a8:	66 90                	xchg   %ax,%ax
  8021aa:	66 90                	xchg   %ax,%ax
  8021ac:	66 90                	xchg   %ax,%ax
  8021ae:	66 90                	xchg   %ax,%ax

008021b0 <__umoddi3>:
  8021b0:	55                   	push   %ebp
  8021b1:	57                   	push   %edi
  8021b2:	56                   	push   %esi
  8021b3:	53                   	push   %ebx
  8021b4:	83 ec 1c             	sub    $0x1c,%esp
  8021b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021bf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021c7:	85 d2                	test   %edx,%edx
  8021c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8021cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021d1:	89 f3                	mov    %esi,%ebx
  8021d3:	89 3c 24             	mov    %edi,(%esp)
  8021d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021da:	75 1c                	jne    8021f8 <__umoddi3+0x48>
  8021dc:	39 f7                	cmp    %esi,%edi
  8021de:	76 50                	jbe    802230 <__umoddi3+0x80>
  8021e0:	89 c8                	mov    %ecx,%eax
  8021e2:	89 f2                	mov    %esi,%edx
  8021e4:	f7 f7                	div    %edi
  8021e6:	89 d0                	mov    %edx,%eax
  8021e8:	31 d2                	xor    %edx,%edx
  8021ea:	83 c4 1c             	add    $0x1c,%esp
  8021ed:	5b                   	pop    %ebx
  8021ee:	5e                   	pop    %esi
  8021ef:	5f                   	pop    %edi
  8021f0:	5d                   	pop    %ebp
  8021f1:	c3                   	ret    
  8021f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021f8:	39 f2                	cmp    %esi,%edx
  8021fa:	89 d0                	mov    %edx,%eax
  8021fc:	77 52                	ja     802250 <__umoddi3+0xa0>
  8021fe:	0f bd ea             	bsr    %edx,%ebp
  802201:	83 f5 1f             	xor    $0x1f,%ebp
  802204:	75 5a                	jne    802260 <__umoddi3+0xb0>
  802206:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80220a:	0f 82 e0 00 00 00    	jb     8022f0 <__umoddi3+0x140>
  802210:	39 0c 24             	cmp    %ecx,(%esp)
  802213:	0f 86 d7 00 00 00    	jbe    8022f0 <__umoddi3+0x140>
  802219:	8b 44 24 08          	mov    0x8(%esp),%eax
  80221d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802221:	83 c4 1c             	add    $0x1c,%esp
  802224:	5b                   	pop    %ebx
  802225:	5e                   	pop    %esi
  802226:	5f                   	pop    %edi
  802227:	5d                   	pop    %ebp
  802228:	c3                   	ret    
  802229:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802230:	85 ff                	test   %edi,%edi
  802232:	89 fd                	mov    %edi,%ebp
  802234:	75 0b                	jne    802241 <__umoddi3+0x91>
  802236:	b8 01 00 00 00       	mov    $0x1,%eax
  80223b:	31 d2                	xor    %edx,%edx
  80223d:	f7 f7                	div    %edi
  80223f:	89 c5                	mov    %eax,%ebp
  802241:	89 f0                	mov    %esi,%eax
  802243:	31 d2                	xor    %edx,%edx
  802245:	f7 f5                	div    %ebp
  802247:	89 c8                	mov    %ecx,%eax
  802249:	f7 f5                	div    %ebp
  80224b:	89 d0                	mov    %edx,%eax
  80224d:	eb 99                	jmp    8021e8 <__umoddi3+0x38>
  80224f:	90                   	nop
  802250:	89 c8                	mov    %ecx,%eax
  802252:	89 f2                	mov    %esi,%edx
  802254:	83 c4 1c             	add    $0x1c,%esp
  802257:	5b                   	pop    %ebx
  802258:	5e                   	pop    %esi
  802259:	5f                   	pop    %edi
  80225a:	5d                   	pop    %ebp
  80225b:	c3                   	ret    
  80225c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802260:	8b 34 24             	mov    (%esp),%esi
  802263:	bf 20 00 00 00       	mov    $0x20,%edi
  802268:	89 e9                	mov    %ebp,%ecx
  80226a:	29 ef                	sub    %ebp,%edi
  80226c:	d3 e0                	shl    %cl,%eax
  80226e:	89 f9                	mov    %edi,%ecx
  802270:	89 f2                	mov    %esi,%edx
  802272:	d3 ea                	shr    %cl,%edx
  802274:	89 e9                	mov    %ebp,%ecx
  802276:	09 c2                	or     %eax,%edx
  802278:	89 d8                	mov    %ebx,%eax
  80227a:	89 14 24             	mov    %edx,(%esp)
  80227d:	89 f2                	mov    %esi,%edx
  80227f:	d3 e2                	shl    %cl,%edx
  802281:	89 f9                	mov    %edi,%ecx
  802283:	89 54 24 04          	mov    %edx,0x4(%esp)
  802287:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80228b:	d3 e8                	shr    %cl,%eax
  80228d:	89 e9                	mov    %ebp,%ecx
  80228f:	89 c6                	mov    %eax,%esi
  802291:	d3 e3                	shl    %cl,%ebx
  802293:	89 f9                	mov    %edi,%ecx
  802295:	89 d0                	mov    %edx,%eax
  802297:	d3 e8                	shr    %cl,%eax
  802299:	89 e9                	mov    %ebp,%ecx
  80229b:	09 d8                	or     %ebx,%eax
  80229d:	89 d3                	mov    %edx,%ebx
  80229f:	89 f2                	mov    %esi,%edx
  8022a1:	f7 34 24             	divl   (%esp)
  8022a4:	89 d6                	mov    %edx,%esi
  8022a6:	d3 e3                	shl    %cl,%ebx
  8022a8:	f7 64 24 04          	mull   0x4(%esp)
  8022ac:	39 d6                	cmp    %edx,%esi
  8022ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022b2:	89 d1                	mov    %edx,%ecx
  8022b4:	89 c3                	mov    %eax,%ebx
  8022b6:	72 08                	jb     8022c0 <__umoddi3+0x110>
  8022b8:	75 11                	jne    8022cb <__umoddi3+0x11b>
  8022ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8022be:	73 0b                	jae    8022cb <__umoddi3+0x11b>
  8022c0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8022c4:	1b 14 24             	sbb    (%esp),%edx
  8022c7:	89 d1                	mov    %edx,%ecx
  8022c9:	89 c3                	mov    %eax,%ebx
  8022cb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8022cf:	29 da                	sub    %ebx,%edx
  8022d1:	19 ce                	sbb    %ecx,%esi
  8022d3:	89 f9                	mov    %edi,%ecx
  8022d5:	89 f0                	mov    %esi,%eax
  8022d7:	d3 e0                	shl    %cl,%eax
  8022d9:	89 e9                	mov    %ebp,%ecx
  8022db:	d3 ea                	shr    %cl,%edx
  8022dd:	89 e9                	mov    %ebp,%ecx
  8022df:	d3 ee                	shr    %cl,%esi
  8022e1:	09 d0                	or     %edx,%eax
  8022e3:	89 f2                	mov    %esi,%edx
  8022e5:	83 c4 1c             	add    $0x1c,%esp
  8022e8:	5b                   	pop    %ebx
  8022e9:	5e                   	pop    %esi
  8022ea:	5f                   	pop    %edi
  8022eb:	5d                   	pop    %ebp
  8022ec:	c3                   	ret    
  8022ed:	8d 76 00             	lea    0x0(%esi),%esi
  8022f0:	29 f9                	sub    %edi,%ecx
  8022f2:	19 d6                	sbb    %edx,%esi
  8022f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022fc:	e9 18 ff ff ff       	jmp    802219 <__umoddi3+0x69>
