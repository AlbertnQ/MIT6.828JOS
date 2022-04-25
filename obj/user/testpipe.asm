
obj/user/testpipe.debug:     file format elf32-i386


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
  80002c:	e8 81 02 00 00       	call   8002b2 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

char *msg = "Now is the time for all good men to come to the aid of their party.";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 7c             	sub    $0x7c,%esp
	char buf[100];
	int i, pid, p[2];

	binaryname = "pipereadeof";
  80003b:	c7 05 04 30 80 00 20 	movl   $0x802420,0x803004
  800042:	24 80 00 

	if ((i = pipe(p)) < 0)
  800045:	8d 45 8c             	lea    -0x74(%ebp),%eax
  800048:	50                   	push   %eax
  800049:	e8 25 1c 00 00       	call   801c73 <pipe>
  80004e:	89 c6                	mov    %eax,%esi
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	79 12                	jns    800069 <umain+0x36>
		panic("pipe: %e", i);
  800057:	50                   	push   %eax
  800058:	68 2c 24 80 00       	push   $0x80242c
  80005d:	6a 0e                	push   $0xe
  80005f:	68 35 24 80 00       	push   $0x802435
  800064:	e8 a9 02 00 00       	call   800312 <_panic>

	if ((pid = fork()) < 0)
  800069:	e8 e8 10 00 00       	call   801156 <fork>
  80006e:	89 c3                	mov    %eax,%ebx
  800070:	85 c0                	test   %eax,%eax
  800072:	79 12                	jns    800086 <umain+0x53>
		panic("fork: %e", i);
  800074:	56                   	push   %esi
  800075:	68 45 24 80 00       	push   $0x802445
  80007a:	6a 11                	push   $0x11
  80007c:	68 35 24 80 00       	push   $0x802435
  800081:	e8 8c 02 00 00       	call   800312 <_panic>

	if (pid == 0) {
  800086:	85 c0                	test   %eax,%eax
  800088:	0f 85 b8 00 00 00    	jne    800146 <umain+0x113>
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[1]);
  80008e:	a1 04 40 80 00       	mov    0x804004,%eax
  800093:	8b 40 48             	mov    0x48(%eax),%eax
  800096:	83 ec 04             	sub    $0x4,%esp
  800099:	ff 75 90             	pushl  -0x70(%ebp)
  80009c:	50                   	push   %eax
  80009d:	68 4e 24 80 00       	push   $0x80244e
  8000a2:	e8 44 03 00 00       	call   8003eb <cprintf>
		close(p[1]);
  8000a7:	83 c4 04             	add    $0x4,%esp
  8000aa:	ff 75 90             	pushl  -0x70(%ebp)
  8000ad:	e8 80 13 00 00       	call   801432 <close>
		cprintf("[%08x] pipereadeof readn %d\n", thisenv->env_id, p[0]);
  8000b2:	a1 04 40 80 00       	mov    0x804004,%eax
  8000b7:	8b 40 48             	mov    0x48(%eax),%eax
  8000ba:	83 c4 0c             	add    $0xc,%esp
  8000bd:	ff 75 8c             	pushl  -0x74(%ebp)
  8000c0:	50                   	push   %eax
  8000c1:	68 6b 24 80 00       	push   $0x80246b
  8000c6:	e8 20 03 00 00       	call   8003eb <cprintf>
		i = readn(p[0], buf, sizeof buf-1);
  8000cb:	83 c4 0c             	add    $0xc,%esp
  8000ce:	6a 63                	push   $0x63
  8000d0:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8000d3:	50                   	push   %eax
  8000d4:	ff 75 8c             	pushl  -0x74(%ebp)
  8000d7:	e8 23 15 00 00       	call   8015ff <readn>
  8000dc:	89 c6                	mov    %eax,%esi
		if (i < 0)
  8000de:	83 c4 10             	add    $0x10,%esp
  8000e1:	85 c0                	test   %eax,%eax
  8000e3:	79 12                	jns    8000f7 <umain+0xc4>
			panic("read: %e", i);
  8000e5:	50                   	push   %eax
  8000e6:	68 88 24 80 00       	push   $0x802488
  8000eb:	6a 19                	push   $0x19
  8000ed:	68 35 24 80 00       	push   $0x802435
  8000f2:	e8 1b 02 00 00       	call   800312 <_panic>
		buf[i] = 0;
  8000f7:	c6 44 05 94 00       	movb   $0x0,-0x6c(%ebp,%eax,1)
		if (strcmp(buf, msg) == 0)
  8000fc:	83 ec 08             	sub    $0x8,%esp
  8000ff:	ff 35 00 30 80 00    	pushl  0x803000
  800105:	8d 45 94             	lea    -0x6c(%ebp),%eax
  800108:	50                   	push   %eax
  800109:	e8 2a 09 00 00       	call   800a38 <strcmp>
  80010e:	83 c4 10             	add    $0x10,%esp
  800111:	85 c0                	test   %eax,%eax
  800113:	75 12                	jne    800127 <umain+0xf4>
			cprintf("\npipe read closed properly\n");
  800115:	83 ec 0c             	sub    $0xc,%esp
  800118:	68 91 24 80 00       	push   $0x802491
  80011d:	e8 c9 02 00 00       	call   8003eb <cprintf>
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	eb 15                	jmp    80013c <umain+0x109>
		else
			cprintf("\ngot %d bytes: %s\n", i, buf);
  800127:	83 ec 04             	sub    $0x4,%esp
  80012a:	8d 45 94             	lea    -0x6c(%ebp),%eax
  80012d:	50                   	push   %eax
  80012e:	56                   	push   %esi
  80012f:	68 ad 24 80 00       	push   $0x8024ad
  800134:	e8 b2 02 00 00       	call   8003eb <cprintf>
  800139:	83 c4 10             	add    $0x10,%esp
		exit();
  80013c:	e8 b7 01 00 00       	call   8002f8 <exit>
  800141:	e9 94 00 00 00       	jmp    8001da <umain+0x1a7>
	} else {
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[0]);
  800146:	a1 04 40 80 00       	mov    0x804004,%eax
  80014b:	8b 40 48             	mov    0x48(%eax),%eax
  80014e:	83 ec 04             	sub    $0x4,%esp
  800151:	ff 75 8c             	pushl  -0x74(%ebp)
  800154:	50                   	push   %eax
  800155:	68 4e 24 80 00       	push   $0x80244e
  80015a:	e8 8c 02 00 00       	call   8003eb <cprintf>
		close(p[0]);
  80015f:	83 c4 04             	add    $0x4,%esp
  800162:	ff 75 8c             	pushl  -0x74(%ebp)
  800165:	e8 c8 12 00 00       	call   801432 <close>
		cprintf("[%08x] pipereadeof write %d\n", thisenv->env_id, p[1]);
  80016a:	a1 04 40 80 00       	mov    0x804004,%eax
  80016f:	8b 40 48             	mov    0x48(%eax),%eax
  800172:	83 c4 0c             	add    $0xc,%esp
  800175:	ff 75 90             	pushl  -0x70(%ebp)
  800178:	50                   	push   %eax
  800179:	68 c0 24 80 00       	push   $0x8024c0
  80017e:	e8 68 02 00 00       	call   8003eb <cprintf>
		if ((i = write(p[1], msg, strlen(msg))) != strlen(msg))
  800183:	83 c4 04             	add    $0x4,%esp
  800186:	ff 35 00 30 80 00    	pushl  0x803000
  80018c:	e8 c4 07 00 00       	call   800955 <strlen>
  800191:	83 c4 0c             	add    $0xc,%esp
  800194:	50                   	push   %eax
  800195:	ff 35 00 30 80 00    	pushl  0x803000
  80019b:	ff 75 90             	pushl  -0x70(%ebp)
  80019e:	e8 a5 14 00 00       	call   801648 <write>
  8001a3:	89 c6                	mov    %eax,%esi
  8001a5:	83 c4 04             	add    $0x4,%esp
  8001a8:	ff 35 00 30 80 00    	pushl  0x803000
  8001ae:	e8 a2 07 00 00       	call   800955 <strlen>
  8001b3:	83 c4 10             	add    $0x10,%esp
  8001b6:	39 c6                	cmp    %eax,%esi
  8001b8:	74 12                	je     8001cc <umain+0x199>
			panic("write: %e", i);
  8001ba:	56                   	push   %esi
  8001bb:	68 dd 24 80 00       	push   $0x8024dd
  8001c0:	6a 25                	push   $0x25
  8001c2:	68 35 24 80 00       	push   $0x802435
  8001c7:	e8 46 01 00 00       	call   800312 <_panic>
		close(p[1]);
  8001cc:	83 ec 0c             	sub    $0xc,%esp
  8001cf:	ff 75 90             	pushl  -0x70(%ebp)
  8001d2:	e8 5b 12 00 00       	call   801432 <close>
  8001d7:	83 c4 10             	add    $0x10,%esp
	}
	wait(pid);
  8001da:	83 ec 0c             	sub    $0xc,%esp
  8001dd:	53                   	push   %ebx
  8001de:	e8 16 1c 00 00       	call   801df9 <wait>

	binaryname = "pipewriteeof";
  8001e3:	c7 05 04 30 80 00 e7 	movl   $0x8024e7,0x803004
  8001ea:	24 80 00 
	if ((i = pipe(p)) < 0)
  8001ed:	8d 45 8c             	lea    -0x74(%ebp),%eax
  8001f0:	89 04 24             	mov    %eax,(%esp)
  8001f3:	e8 7b 1a 00 00       	call   801c73 <pipe>
  8001f8:	89 c6                	mov    %eax,%esi
  8001fa:	83 c4 10             	add    $0x10,%esp
  8001fd:	85 c0                	test   %eax,%eax
  8001ff:	79 12                	jns    800213 <umain+0x1e0>
		panic("pipe: %e", i);
  800201:	50                   	push   %eax
  800202:	68 2c 24 80 00       	push   $0x80242c
  800207:	6a 2c                	push   $0x2c
  800209:	68 35 24 80 00       	push   $0x802435
  80020e:	e8 ff 00 00 00       	call   800312 <_panic>

	if ((pid = fork()) < 0)
  800213:	e8 3e 0f 00 00       	call   801156 <fork>
  800218:	89 c3                	mov    %eax,%ebx
  80021a:	85 c0                	test   %eax,%eax
  80021c:	79 12                	jns    800230 <umain+0x1fd>
		panic("fork: %e", i);
  80021e:	56                   	push   %esi
  80021f:	68 45 24 80 00       	push   $0x802445
  800224:	6a 2f                	push   $0x2f
  800226:	68 35 24 80 00       	push   $0x802435
  80022b:	e8 e2 00 00 00       	call   800312 <_panic>

	if (pid == 0) {
  800230:	85 c0                	test   %eax,%eax
  800232:	75 4a                	jne    80027e <umain+0x24b>
		close(p[0]);
  800234:	83 ec 0c             	sub    $0xc,%esp
  800237:	ff 75 8c             	pushl  -0x74(%ebp)
  80023a:	e8 f3 11 00 00       	call   801432 <close>
  80023f:	83 c4 10             	add    $0x10,%esp
		while (1) {
			cprintf(".");
  800242:	83 ec 0c             	sub    $0xc,%esp
  800245:	68 f4 24 80 00       	push   $0x8024f4
  80024a:	e8 9c 01 00 00       	call   8003eb <cprintf>
			if (write(p[1], "x", 1) != 1)
  80024f:	83 c4 0c             	add    $0xc,%esp
  800252:	6a 01                	push   $0x1
  800254:	68 f6 24 80 00       	push   $0x8024f6
  800259:	ff 75 90             	pushl  -0x70(%ebp)
  80025c:	e8 e7 13 00 00       	call   801648 <write>
  800261:	83 c4 10             	add    $0x10,%esp
  800264:	83 f8 01             	cmp    $0x1,%eax
  800267:	74 d9                	je     800242 <umain+0x20f>
				break;
		}
		cprintf("\npipe write closed properly\n");
  800269:	83 ec 0c             	sub    $0xc,%esp
  80026c:	68 f8 24 80 00       	push   $0x8024f8
  800271:	e8 75 01 00 00       	call   8003eb <cprintf>
		exit();
  800276:	e8 7d 00 00 00       	call   8002f8 <exit>
  80027b:	83 c4 10             	add    $0x10,%esp
	}
	close(p[0]);
  80027e:	83 ec 0c             	sub    $0xc,%esp
  800281:	ff 75 8c             	pushl  -0x74(%ebp)
  800284:	e8 a9 11 00 00       	call   801432 <close>
	close(p[1]);
  800289:	83 c4 04             	add    $0x4,%esp
  80028c:	ff 75 90             	pushl  -0x70(%ebp)
  80028f:	e8 9e 11 00 00       	call   801432 <close>
	wait(pid);
  800294:	89 1c 24             	mov    %ebx,(%esp)
  800297:	e8 5d 1b 00 00       	call   801df9 <wait>

	cprintf("pipe tests passed\n");
  80029c:	c7 04 24 15 25 80 00 	movl   $0x802515,(%esp)
  8002a3:	e8 43 01 00 00       	call   8003eb <cprintf>
}
  8002a8:	83 c4 10             	add    $0x10,%esp
  8002ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002ae:	5b                   	pop    %ebx
  8002af:	5e                   	pop    %esi
  8002b0:	5d                   	pop    %ebp
  8002b1:	c3                   	ret    

008002b2 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8002b2:	55                   	push   %ebp
  8002b3:	89 e5                	mov    %esp,%ebp
  8002b5:	56                   	push   %esi
  8002b6:	53                   	push   %ebx
  8002b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002ba:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  8002bd:	e8 91 0a 00 00       	call   800d53 <sys_getenvid>
  8002c2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002c7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8002ca:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002cf:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002d4:	85 db                	test   %ebx,%ebx
  8002d6:	7e 07                	jle    8002df <libmain+0x2d>
		binaryname = argv[0];
  8002d8:	8b 06                	mov    (%esi),%eax
  8002da:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8002df:	83 ec 08             	sub    $0x8,%esp
  8002e2:	56                   	push   %esi
  8002e3:	53                   	push   %ebx
  8002e4:	e8 4a fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8002e9:	e8 0a 00 00 00       	call   8002f8 <exit>
}
  8002ee:	83 c4 10             	add    $0x10,%esp
  8002f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002f4:	5b                   	pop    %ebx
  8002f5:	5e                   	pop    %esi
  8002f6:	5d                   	pop    %ebp
  8002f7:	c3                   	ret    

008002f8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002f8:	55                   	push   %ebp
  8002f9:	89 e5                	mov    %esp,%ebp
  8002fb:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8002fe:	e8 5a 11 00 00       	call   80145d <close_all>
	sys_env_destroy(0);
  800303:	83 ec 0c             	sub    $0xc,%esp
  800306:	6a 00                	push   $0x0
  800308:	e8 05 0a 00 00       	call   800d12 <sys_env_destroy>
}
  80030d:	83 c4 10             	add    $0x10,%esp
  800310:	c9                   	leave  
  800311:	c3                   	ret    

00800312 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800312:	55                   	push   %ebp
  800313:	89 e5                	mov    %esp,%ebp
  800315:	56                   	push   %esi
  800316:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800317:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80031a:	8b 35 04 30 80 00    	mov    0x803004,%esi
  800320:	e8 2e 0a 00 00       	call   800d53 <sys_getenvid>
  800325:	83 ec 0c             	sub    $0xc,%esp
  800328:	ff 75 0c             	pushl  0xc(%ebp)
  80032b:	ff 75 08             	pushl  0x8(%ebp)
  80032e:	56                   	push   %esi
  80032f:	50                   	push   %eax
  800330:	68 78 25 80 00       	push   $0x802578
  800335:	e8 b1 00 00 00       	call   8003eb <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80033a:	83 c4 18             	add    $0x18,%esp
  80033d:	53                   	push   %ebx
  80033e:	ff 75 10             	pushl  0x10(%ebp)
  800341:	e8 54 00 00 00       	call   80039a <vcprintf>
	cprintf("\n");
  800346:	c7 04 24 69 24 80 00 	movl   $0x802469,(%esp)
  80034d:	e8 99 00 00 00       	call   8003eb <cprintf>
  800352:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800355:	cc                   	int3   
  800356:	eb fd                	jmp    800355 <_panic+0x43>

00800358 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800358:	55                   	push   %ebp
  800359:	89 e5                	mov    %esp,%ebp
  80035b:	53                   	push   %ebx
  80035c:	83 ec 04             	sub    $0x4,%esp
  80035f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800362:	8b 13                	mov    (%ebx),%edx
  800364:	8d 42 01             	lea    0x1(%edx),%eax
  800367:	89 03                	mov    %eax,(%ebx)
  800369:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80036c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800370:	3d ff 00 00 00       	cmp    $0xff,%eax
  800375:	75 1a                	jne    800391 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800377:	83 ec 08             	sub    $0x8,%esp
  80037a:	68 ff 00 00 00       	push   $0xff
  80037f:	8d 43 08             	lea    0x8(%ebx),%eax
  800382:	50                   	push   %eax
  800383:	e8 4d 09 00 00       	call   800cd5 <sys_cputs>
		b->idx = 0;
  800388:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80038e:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800391:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800395:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800398:	c9                   	leave  
  800399:	c3                   	ret    

0080039a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80039a:	55                   	push   %ebp
  80039b:	89 e5                	mov    %esp,%ebp
  80039d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003a3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003aa:	00 00 00 
	b.cnt = 0;
  8003ad:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003b4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003b7:	ff 75 0c             	pushl  0xc(%ebp)
  8003ba:	ff 75 08             	pushl  0x8(%ebp)
  8003bd:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003c3:	50                   	push   %eax
  8003c4:	68 58 03 80 00       	push   $0x800358
  8003c9:	e8 54 01 00 00       	call   800522 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003ce:	83 c4 08             	add    $0x8,%esp
  8003d1:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003d7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003dd:	50                   	push   %eax
  8003de:	e8 f2 08 00 00       	call   800cd5 <sys_cputs>

	return b.cnt;
}
  8003e3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003e9:	c9                   	leave  
  8003ea:	c3                   	ret    

008003eb <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003eb:	55                   	push   %ebp
  8003ec:	89 e5                	mov    %esp,%ebp
  8003ee:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003f1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003f4:	50                   	push   %eax
  8003f5:	ff 75 08             	pushl  0x8(%ebp)
  8003f8:	e8 9d ff ff ff       	call   80039a <vcprintf>
	va_end(ap);

	return cnt;
}
  8003fd:	c9                   	leave  
  8003fe:	c3                   	ret    

008003ff <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003ff:	55                   	push   %ebp
  800400:	89 e5                	mov    %esp,%ebp
  800402:	57                   	push   %edi
  800403:	56                   	push   %esi
  800404:	53                   	push   %ebx
  800405:	83 ec 1c             	sub    $0x1c,%esp
  800408:	89 c7                	mov    %eax,%edi
  80040a:	89 d6                	mov    %edx,%esi
  80040c:	8b 45 08             	mov    0x8(%ebp),%eax
  80040f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800412:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800415:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800418:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80041b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800420:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800423:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800426:	39 d3                	cmp    %edx,%ebx
  800428:	72 05                	jb     80042f <printnum+0x30>
  80042a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80042d:	77 45                	ja     800474 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80042f:	83 ec 0c             	sub    $0xc,%esp
  800432:	ff 75 18             	pushl  0x18(%ebp)
  800435:	8b 45 14             	mov    0x14(%ebp),%eax
  800438:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80043b:	53                   	push   %ebx
  80043c:	ff 75 10             	pushl  0x10(%ebp)
  80043f:	83 ec 08             	sub    $0x8,%esp
  800442:	ff 75 e4             	pushl  -0x1c(%ebp)
  800445:	ff 75 e0             	pushl  -0x20(%ebp)
  800448:	ff 75 dc             	pushl  -0x24(%ebp)
  80044b:	ff 75 d8             	pushl  -0x28(%ebp)
  80044e:	e8 2d 1d 00 00       	call   802180 <__udivdi3>
  800453:	83 c4 18             	add    $0x18,%esp
  800456:	52                   	push   %edx
  800457:	50                   	push   %eax
  800458:	89 f2                	mov    %esi,%edx
  80045a:	89 f8                	mov    %edi,%eax
  80045c:	e8 9e ff ff ff       	call   8003ff <printnum>
  800461:	83 c4 20             	add    $0x20,%esp
  800464:	eb 18                	jmp    80047e <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800466:	83 ec 08             	sub    $0x8,%esp
  800469:	56                   	push   %esi
  80046a:	ff 75 18             	pushl  0x18(%ebp)
  80046d:	ff d7                	call   *%edi
  80046f:	83 c4 10             	add    $0x10,%esp
  800472:	eb 03                	jmp    800477 <printnum+0x78>
  800474:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800477:	83 eb 01             	sub    $0x1,%ebx
  80047a:	85 db                	test   %ebx,%ebx
  80047c:	7f e8                	jg     800466 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80047e:	83 ec 08             	sub    $0x8,%esp
  800481:	56                   	push   %esi
  800482:	83 ec 04             	sub    $0x4,%esp
  800485:	ff 75 e4             	pushl  -0x1c(%ebp)
  800488:	ff 75 e0             	pushl  -0x20(%ebp)
  80048b:	ff 75 dc             	pushl  -0x24(%ebp)
  80048e:	ff 75 d8             	pushl  -0x28(%ebp)
  800491:	e8 1a 1e 00 00       	call   8022b0 <__umoddi3>
  800496:	83 c4 14             	add    $0x14,%esp
  800499:	0f be 80 9b 25 80 00 	movsbl 0x80259b(%eax),%eax
  8004a0:	50                   	push   %eax
  8004a1:	ff d7                	call   *%edi
}
  8004a3:	83 c4 10             	add    $0x10,%esp
  8004a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004a9:	5b                   	pop    %ebx
  8004aa:	5e                   	pop    %esi
  8004ab:	5f                   	pop    %edi
  8004ac:	5d                   	pop    %ebp
  8004ad:	c3                   	ret    

008004ae <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004ae:	55                   	push   %ebp
  8004af:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004b1:	83 fa 01             	cmp    $0x1,%edx
  8004b4:	7e 0e                	jle    8004c4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004b6:	8b 10                	mov    (%eax),%edx
  8004b8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004bb:	89 08                	mov    %ecx,(%eax)
  8004bd:	8b 02                	mov    (%edx),%eax
  8004bf:	8b 52 04             	mov    0x4(%edx),%edx
  8004c2:	eb 22                	jmp    8004e6 <getuint+0x38>
	else if (lflag)
  8004c4:	85 d2                	test   %edx,%edx
  8004c6:	74 10                	je     8004d8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004c8:	8b 10                	mov    (%eax),%edx
  8004ca:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004cd:	89 08                	mov    %ecx,(%eax)
  8004cf:	8b 02                	mov    (%edx),%eax
  8004d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8004d6:	eb 0e                	jmp    8004e6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004d8:	8b 10                	mov    (%eax),%edx
  8004da:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004dd:	89 08                	mov    %ecx,(%eax)
  8004df:	8b 02                	mov    (%edx),%eax
  8004e1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004e6:	5d                   	pop    %ebp
  8004e7:	c3                   	ret    

008004e8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004e8:	55                   	push   %ebp
  8004e9:	89 e5                	mov    %esp,%ebp
  8004eb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004ee:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004f2:	8b 10                	mov    (%eax),%edx
  8004f4:	3b 50 04             	cmp    0x4(%eax),%edx
  8004f7:	73 0a                	jae    800503 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004f9:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004fc:	89 08                	mov    %ecx,(%eax)
  8004fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800501:	88 02                	mov    %al,(%edx)
}
  800503:	5d                   	pop    %ebp
  800504:	c3                   	ret    

00800505 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800505:	55                   	push   %ebp
  800506:	89 e5                	mov    %esp,%ebp
  800508:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80050b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80050e:	50                   	push   %eax
  80050f:	ff 75 10             	pushl  0x10(%ebp)
  800512:	ff 75 0c             	pushl  0xc(%ebp)
  800515:	ff 75 08             	pushl  0x8(%ebp)
  800518:	e8 05 00 00 00       	call   800522 <vprintfmt>
	va_end(ap);
}
  80051d:	83 c4 10             	add    $0x10,%esp
  800520:	c9                   	leave  
  800521:	c3                   	ret    

00800522 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800522:	55                   	push   %ebp
  800523:	89 e5                	mov    %esp,%ebp
  800525:	57                   	push   %edi
  800526:	56                   	push   %esi
  800527:	53                   	push   %ebx
  800528:	83 ec 2c             	sub    $0x2c,%esp
  80052b:	8b 75 08             	mov    0x8(%ebp),%esi
  80052e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800531:	8b 7d 10             	mov    0x10(%ebp),%edi
  800534:	eb 12                	jmp    800548 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800536:	85 c0                	test   %eax,%eax
  800538:	0f 84 a7 03 00 00    	je     8008e5 <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
  80053e:	83 ec 08             	sub    $0x8,%esp
  800541:	53                   	push   %ebx
  800542:	50                   	push   %eax
  800543:	ff d6                	call   *%esi
  800545:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800548:	83 c7 01             	add    $0x1,%edi
  80054b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80054f:	83 f8 25             	cmp    $0x25,%eax
  800552:	75 e2                	jne    800536 <vprintfmt+0x14>
  800554:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800558:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80055f:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800566:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80056d:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800574:	b9 00 00 00 00       	mov    $0x0,%ecx
  800579:	eb 07                	jmp    800582 <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057b:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80057e:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800582:	8d 47 01             	lea    0x1(%edi),%eax
  800585:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800588:	0f b6 07             	movzbl (%edi),%eax
  80058b:	0f b6 d0             	movzbl %al,%edx
  80058e:	83 e8 23             	sub    $0x23,%eax
  800591:	3c 55                	cmp    $0x55,%al
  800593:	0f 87 31 03 00 00    	ja     8008ca <vprintfmt+0x3a8>
  800599:	0f b6 c0             	movzbl %al,%eax
  80059c:	ff 24 85 e0 26 80 00 	jmp    *0x8026e0(,%eax,4)
  8005a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005a6:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005aa:	eb d6                	jmp    800582 <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005af:	b8 00 00 00 00       	mov    $0x0,%eax
  8005b4:	89 75 08             	mov    %esi,0x8(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005b7:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005ba:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8005be:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8005c1:	8d 72 d0             	lea    -0x30(%edx),%esi
  8005c4:	83 fe 09             	cmp    $0x9,%esi
  8005c7:	77 34                	ja     8005fd <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005c9:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005cc:	eb e9                	jmp    8005b7 <vprintfmt+0x95>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d1:	8d 50 04             	lea    0x4(%eax),%edx
  8005d4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d7:	8b 00                	mov    (%eax),%eax
  8005d9:	89 45 cc             	mov    %eax,-0x34(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005df:	eb 22                	jmp    800603 <vprintfmt+0xe1>
  8005e1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005e4:	85 c0                	test   %eax,%eax
  8005e6:	0f 48 c1             	cmovs  %ecx,%eax
  8005e9:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ef:	eb 91                	jmp    800582 <vprintfmt+0x60>
  8005f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005f4:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005fb:	eb 85                	jmp    800582 <vprintfmt+0x60>
  8005fd:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800600:	8b 75 08             	mov    0x8(%ebp),%esi

		process_precision:
			if (width < 0)
  800603:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800607:	0f 89 75 ff ff ff    	jns    800582 <vprintfmt+0x60>
				width = precision, precision = -1;
  80060d:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800610:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800613:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80061a:	e9 63 ff ff ff       	jmp    800582 <vprintfmt+0x60>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80061f:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800623:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800626:	e9 57 ff ff ff       	jmp    800582 <vprintfmt+0x60>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80062b:	8b 45 14             	mov    0x14(%ebp),%eax
  80062e:	8d 50 04             	lea    0x4(%eax),%edx
  800631:	89 55 14             	mov    %edx,0x14(%ebp)
  800634:	83 ec 08             	sub    $0x8,%esp
  800637:	53                   	push   %ebx
  800638:	ff 30                	pushl  (%eax)
  80063a:	ff d6                	call   *%esi
			break;
  80063c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800642:	e9 01 ff ff ff       	jmp    800548 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800647:	8b 45 14             	mov    0x14(%ebp),%eax
  80064a:	8d 50 04             	lea    0x4(%eax),%edx
  80064d:	89 55 14             	mov    %edx,0x14(%ebp)
  800650:	8b 00                	mov    (%eax),%eax
  800652:	99                   	cltd   
  800653:	31 d0                	xor    %edx,%eax
  800655:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800657:	83 f8 0f             	cmp    $0xf,%eax
  80065a:	7f 0b                	jg     800667 <vprintfmt+0x145>
  80065c:	8b 14 85 40 28 80 00 	mov    0x802840(,%eax,4),%edx
  800663:	85 d2                	test   %edx,%edx
  800665:	75 18                	jne    80067f <vprintfmt+0x15d>
				printfmt(putch, putdat, "error %d", err);
  800667:	50                   	push   %eax
  800668:	68 b3 25 80 00       	push   $0x8025b3
  80066d:	53                   	push   %ebx
  80066e:	56                   	push   %esi
  80066f:	e8 91 fe ff ff       	call   800505 <printfmt>
  800674:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800677:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80067a:	e9 c9 fe ff ff       	jmp    800548 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80067f:	52                   	push   %edx
  800680:	68 99 2a 80 00       	push   $0x802a99
  800685:	53                   	push   %ebx
  800686:	56                   	push   %esi
  800687:	e8 79 fe ff ff       	call   800505 <printfmt>
  80068c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800692:	e9 b1 fe ff ff       	jmp    800548 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800697:	8b 45 14             	mov    0x14(%ebp),%eax
  80069a:	8d 50 04             	lea    0x4(%eax),%edx
  80069d:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a0:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006a2:	85 ff                	test   %edi,%edi
  8006a4:	b8 ac 25 80 00       	mov    $0x8025ac,%eax
  8006a9:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006ac:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006b0:	0f 8e 94 00 00 00    	jle    80074a <vprintfmt+0x228>
  8006b6:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006ba:	0f 84 98 00 00 00    	je     800758 <vprintfmt+0x236>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006c0:	83 ec 08             	sub    $0x8,%esp
  8006c3:	ff 75 cc             	pushl  -0x34(%ebp)
  8006c6:	57                   	push   %edi
  8006c7:	e8 a1 02 00 00       	call   80096d <strnlen>
  8006cc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006cf:	29 c1                	sub    %eax,%ecx
  8006d1:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8006d4:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006d7:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006db:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006de:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006e1:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e3:	eb 0f                	jmp    8006f4 <vprintfmt+0x1d2>
					putch(padc, putdat);
  8006e5:	83 ec 08             	sub    $0x8,%esp
  8006e8:	53                   	push   %ebx
  8006e9:	ff 75 e0             	pushl  -0x20(%ebp)
  8006ec:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006ee:	83 ef 01             	sub    $0x1,%edi
  8006f1:	83 c4 10             	add    $0x10,%esp
  8006f4:	85 ff                	test   %edi,%edi
  8006f6:	7f ed                	jg     8006e5 <vprintfmt+0x1c3>
  8006f8:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006fb:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8006fe:	85 c9                	test   %ecx,%ecx
  800700:	b8 00 00 00 00       	mov    $0x0,%eax
  800705:	0f 49 c1             	cmovns %ecx,%eax
  800708:	29 c1                	sub    %eax,%ecx
  80070a:	89 75 08             	mov    %esi,0x8(%ebp)
  80070d:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800710:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800713:	89 cb                	mov    %ecx,%ebx
  800715:	eb 4d                	jmp    800764 <vprintfmt+0x242>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800717:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80071b:	74 1b                	je     800738 <vprintfmt+0x216>
  80071d:	0f be c0             	movsbl %al,%eax
  800720:	83 e8 20             	sub    $0x20,%eax
  800723:	83 f8 5e             	cmp    $0x5e,%eax
  800726:	76 10                	jbe    800738 <vprintfmt+0x216>
					putch('?', putdat);
  800728:	83 ec 08             	sub    $0x8,%esp
  80072b:	ff 75 0c             	pushl  0xc(%ebp)
  80072e:	6a 3f                	push   $0x3f
  800730:	ff 55 08             	call   *0x8(%ebp)
  800733:	83 c4 10             	add    $0x10,%esp
  800736:	eb 0d                	jmp    800745 <vprintfmt+0x223>
				else
					putch(ch, putdat);
  800738:	83 ec 08             	sub    $0x8,%esp
  80073b:	ff 75 0c             	pushl  0xc(%ebp)
  80073e:	52                   	push   %edx
  80073f:	ff 55 08             	call   *0x8(%ebp)
  800742:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800745:	83 eb 01             	sub    $0x1,%ebx
  800748:	eb 1a                	jmp    800764 <vprintfmt+0x242>
  80074a:	89 75 08             	mov    %esi,0x8(%ebp)
  80074d:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800750:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800753:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800756:	eb 0c                	jmp    800764 <vprintfmt+0x242>
  800758:	89 75 08             	mov    %esi,0x8(%ebp)
  80075b:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80075e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800761:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800764:	83 c7 01             	add    $0x1,%edi
  800767:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80076b:	0f be d0             	movsbl %al,%edx
  80076e:	85 d2                	test   %edx,%edx
  800770:	74 23                	je     800795 <vprintfmt+0x273>
  800772:	85 f6                	test   %esi,%esi
  800774:	78 a1                	js     800717 <vprintfmt+0x1f5>
  800776:	83 ee 01             	sub    $0x1,%esi
  800779:	79 9c                	jns    800717 <vprintfmt+0x1f5>
  80077b:	89 df                	mov    %ebx,%edi
  80077d:	8b 75 08             	mov    0x8(%ebp),%esi
  800780:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800783:	eb 18                	jmp    80079d <vprintfmt+0x27b>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800785:	83 ec 08             	sub    $0x8,%esp
  800788:	53                   	push   %ebx
  800789:	6a 20                	push   $0x20
  80078b:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80078d:	83 ef 01             	sub    $0x1,%edi
  800790:	83 c4 10             	add    $0x10,%esp
  800793:	eb 08                	jmp    80079d <vprintfmt+0x27b>
  800795:	89 df                	mov    %ebx,%edi
  800797:	8b 75 08             	mov    0x8(%ebp),%esi
  80079a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80079d:	85 ff                	test   %edi,%edi
  80079f:	7f e4                	jg     800785 <vprintfmt+0x263>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007a4:	e9 9f fd ff ff       	jmp    800548 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007a9:	83 7d d0 01          	cmpl   $0x1,-0x30(%ebp)
  8007ad:	7e 16                	jle    8007c5 <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  8007af:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b2:	8d 50 08             	lea    0x8(%eax),%edx
  8007b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8007b8:	8b 50 04             	mov    0x4(%eax),%edx
  8007bb:	8b 00                	mov    (%eax),%eax
  8007bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007c0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007c3:	eb 34                	jmp    8007f9 <vprintfmt+0x2d7>
	else if (lflag)
  8007c5:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8007c9:	74 18                	je     8007e3 <vprintfmt+0x2c1>
		return va_arg(*ap, long);
  8007cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ce:	8d 50 04             	lea    0x4(%eax),%edx
  8007d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8007d4:	8b 00                	mov    (%eax),%eax
  8007d6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007d9:	89 c1                	mov    %eax,%ecx
  8007db:	c1 f9 1f             	sar    $0x1f,%ecx
  8007de:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007e1:	eb 16                	jmp    8007f9 <vprintfmt+0x2d7>
	else
		return va_arg(*ap, int);
  8007e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e6:	8d 50 04             	lea    0x4(%eax),%edx
  8007e9:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ec:	8b 00                	mov    (%eax),%eax
  8007ee:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007f1:	89 c1                	mov    %eax,%ecx
  8007f3:	c1 f9 1f             	sar    $0x1f,%ecx
  8007f6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007f9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007fc:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007ff:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800804:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800808:	0f 89 88 00 00 00    	jns    800896 <vprintfmt+0x374>
				putch('-', putdat);
  80080e:	83 ec 08             	sub    $0x8,%esp
  800811:	53                   	push   %ebx
  800812:	6a 2d                	push   $0x2d
  800814:	ff d6                	call   *%esi
				num = -(long long) num;
  800816:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800819:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80081c:	f7 d8                	neg    %eax
  80081e:	83 d2 00             	adc    $0x0,%edx
  800821:	f7 da                	neg    %edx
  800823:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800826:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80082b:	eb 69                	jmp    800896 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80082d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800830:	8d 45 14             	lea    0x14(%ebp),%eax
  800833:	e8 76 fc ff ff       	call   8004ae <getuint>
			base = 10;
  800838:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80083d:	eb 57                	jmp    800896 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  80083f:	83 ec 08             	sub    $0x8,%esp
  800842:	53                   	push   %ebx
  800843:	6a 30                	push   $0x30
  800845:	ff d6                	call   *%esi
			num = getuint(&ap, lflag);
  800847:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80084a:	8d 45 14             	lea    0x14(%ebp),%eax
  80084d:	e8 5c fc ff ff       	call   8004ae <getuint>
			base = 8;
			goto number;
  800852:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800855:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80085a:	eb 3a                	jmp    800896 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  80085c:	83 ec 08             	sub    $0x8,%esp
  80085f:	53                   	push   %ebx
  800860:	6a 30                	push   $0x30
  800862:	ff d6                	call   *%esi
			putch('x', putdat);
  800864:	83 c4 08             	add    $0x8,%esp
  800867:	53                   	push   %ebx
  800868:	6a 78                	push   $0x78
  80086a:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80086c:	8b 45 14             	mov    0x14(%ebp),%eax
  80086f:	8d 50 04             	lea    0x4(%eax),%edx
  800872:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800875:	8b 00                	mov    (%eax),%eax
  800877:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80087c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80087f:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800884:	eb 10                	jmp    800896 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800886:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800889:	8d 45 14             	lea    0x14(%ebp),%eax
  80088c:	e8 1d fc ff ff       	call   8004ae <getuint>
			base = 16;
  800891:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800896:	83 ec 0c             	sub    $0xc,%esp
  800899:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80089d:	57                   	push   %edi
  80089e:	ff 75 e0             	pushl  -0x20(%ebp)
  8008a1:	51                   	push   %ecx
  8008a2:	52                   	push   %edx
  8008a3:	50                   	push   %eax
  8008a4:	89 da                	mov    %ebx,%edx
  8008a6:	89 f0                	mov    %esi,%eax
  8008a8:	e8 52 fb ff ff       	call   8003ff <printnum>
			break;
  8008ad:	83 c4 20             	add    $0x20,%esp
  8008b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008b3:	e9 90 fc ff ff       	jmp    800548 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008b8:	83 ec 08             	sub    $0x8,%esp
  8008bb:	53                   	push   %ebx
  8008bc:	52                   	push   %edx
  8008bd:	ff d6                	call   *%esi
			break;
  8008bf:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008c5:	e9 7e fc ff ff       	jmp    800548 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008ca:	83 ec 08             	sub    $0x8,%esp
  8008cd:	53                   	push   %ebx
  8008ce:	6a 25                	push   $0x25
  8008d0:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008d2:	83 c4 10             	add    $0x10,%esp
  8008d5:	eb 03                	jmp    8008da <vprintfmt+0x3b8>
  8008d7:	83 ef 01             	sub    $0x1,%edi
  8008da:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008de:	75 f7                	jne    8008d7 <vprintfmt+0x3b5>
  8008e0:	e9 63 fc ff ff       	jmp    800548 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8008e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008e8:	5b                   	pop    %ebx
  8008e9:	5e                   	pop    %esi
  8008ea:	5f                   	pop    %edi
  8008eb:	5d                   	pop    %ebp
  8008ec:	c3                   	ret    

008008ed <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008ed:	55                   	push   %ebp
  8008ee:	89 e5                	mov    %esp,%ebp
  8008f0:	83 ec 18             	sub    $0x18,%esp
  8008f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008f9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008fc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800900:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800903:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80090a:	85 c0                	test   %eax,%eax
  80090c:	74 26                	je     800934 <vsnprintf+0x47>
  80090e:	85 d2                	test   %edx,%edx
  800910:	7e 22                	jle    800934 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800912:	ff 75 14             	pushl  0x14(%ebp)
  800915:	ff 75 10             	pushl  0x10(%ebp)
  800918:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80091b:	50                   	push   %eax
  80091c:	68 e8 04 80 00       	push   $0x8004e8
  800921:	e8 fc fb ff ff       	call   800522 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800926:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800929:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80092c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80092f:	83 c4 10             	add    $0x10,%esp
  800932:	eb 05                	jmp    800939 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800934:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800939:	c9                   	leave  
  80093a:	c3                   	ret    

0080093b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80093b:	55                   	push   %ebp
  80093c:	89 e5                	mov    %esp,%ebp
  80093e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800941:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800944:	50                   	push   %eax
  800945:	ff 75 10             	pushl  0x10(%ebp)
  800948:	ff 75 0c             	pushl  0xc(%ebp)
  80094b:	ff 75 08             	pushl  0x8(%ebp)
  80094e:	e8 9a ff ff ff       	call   8008ed <vsnprintf>
	va_end(ap);

	return rc;
}
  800953:	c9                   	leave  
  800954:	c3                   	ret    

00800955 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800955:	55                   	push   %ebp
  800956:	89 e5                	mov    %esp,%ebp
  800958:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80095b:	b8 00 00 00 00       	mov    $0x0,%eax
  800960:	eb 03                	jmp    800965 <strlen+0x10>
		n++;
  800962:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800965:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800969:	75 f7                	jne    800962 <strlen+0xd>
		n++;
	return n;
}
  80096b:	5d                   	pop    %ebp
  80096c:	c3                   	ret    

0080096d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80096d:	55                   	push   %ebp
  80096e:	89 e5                	mov    %esp,%ebp
  800970:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800973:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800976:	ba 00 00 00 00       	mov    $0x0,%edx
  80097b:	eb 03                	jmp    800980 <strnlen+0x13>
		n++;
  80097d:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800980:	39 c2                	cmp    %eax,%edx
  800982:	74 08                	je     80098c <strnlen+0x1f>
  800984:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800988:	75 f3                	jne    80097d <strnlen+0x10>
  80098a:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80098c:	5d                   	pop    %ebp
  80098d:	c3                   	ret    

0080098e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80098e:	55                   	push   %ebp
  80098f:	89 e5                	mov    %esp,%ebp
  800991:	53                   	push   %ebx
  800992:	8b 45 08             	mov    0x8(%ebp),%eax
  800995:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800998:	89 c2                	mov    %eax,%edx
  80099a:	83 c2 01             	add    $0x1,%edx
  80099d:	83 c1 01             	add    $0x1,%ecx
  8009a0:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009a4:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009a7:	84 db                	test   %bl,%bl
  8009a9:	75 ef                	jne    80099a <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009ab:	5b                   	pop    %ebx
  8009ac:	5d                   	pop    %ebp
  8009ad:	c3                   	ret    

008009ae <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009ae:	55                   	push   %ebp
  8009af:	89 e5                	mov    %esp,%ebp
  8009b1:	53                   	push   %ebx
  8009b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009b5:	53                   	push   %ebx
  8009b6:	e8 9a ff ff ff       	call   800955 <strlen>
  8009bb:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009be:	ff 75 0c             	pushl  0xc(%ebp)
  8009c1:	01 d8                	add    %ebx,%eax
  8009c3:	50                   	push   %eax
  8009c4:	e8 c5 ff ff ff       	call   80098e <strcpy>
	return dst;
}
  8009c9:	89 d8                	mov    %ebx,%eax
  8009cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009ce:	c9                   	leave  
  8009cf:	c3                   	ret    

008009d0 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009d0:	55                   	push   %ebp
  8009d1:	89 e5                	mov    %esp,%ebp
  8009d3:	56                   	push   %esi
  8009d4:	53                   	push   %ebx
  8009d5:	8b 75 08             	mov    0x8(%ebp),%esi
  8009d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009db:	89 f3                	mov    %esi,%ebx
  8009dd:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009e0:	89 f2                	mov    %esi,%edx
  8009e2:	eb 0f                	jmp    8009f3 <strncpy+0x23>
		*dst++ = *src;
  8009e4:	83 c2 01             	add    $0x1,%edx
  8009e7:	0f b6 01             	movzbl (%ecx),%eax
  8009ea:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009ed:	80 39 01             	cmpb   $0x1,(%ecx)
  8009f0:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009f3:	39 da                	cmp    %ebx,%edx
  8009f5:	75 ed                	jne    8009e4 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009f7:	89 f0                	mov    %esi,%eax
  8009f9:	5b                   	pop    %ebx
  8009fa:	5e                   	pop    %esi
  8009fb:	5d                   	pop    %ebp
  8009fc:	c3                   	ret    

008009fd <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009fd:	55                   	push   %ebp
  8009fe:	89 e5                	mov    %esp,%ebp
  800a00:	56                   	push   %esi
  800a01:	53                   	push   %ebx
  800a02:	8b 75 08             	mov    0x8(%ebp),%esi
  800a05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a08:	8b 55 10             	mov    0x10(%ebp),%edx
  800a0b:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a0d:	85 d2                	test   %edx,%edx
  800a0f:	74 21                	je     800a32 <strlcpy+0x35>
  800a11:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a15:	89 f2                	mov    %esi,%edx
  800a17:	eb 09                	jmp    800a22 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a19:	83 c2 01             	add    $0x1,%edx
  800a1c:	83 c1 01             	add    $0x1,%ecx
  800a1f:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a22:	39 c2                	cmp    %eax,%edx
  800a24:	74 09                	je     800a2f <strlcpy+0x32>
  800a26:	0f b6 19             	movzbl (%ecx),%ebx
  800a29:	84 db                	test   %bl,%bl
  800a2b:	75 ec                	jne    800a19 <strlcpy+0x1c>
  800a2d:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a2f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a32:	29 f0                	sub    %esi,%eax
}
  800a34:	5b                   	pop    %ebx
  800a35:	5e                   	pop    %esi
  800a36:	5d                   	pop    %ebp
  800a37:	c3                   	ret    

00800a38 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a38:	55                   	push   %ebp
  800a39:	89 e5                	mov    %esp,%ebp
  800a3b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a3e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a41:	eb 06                	jmp    800a49 <strcmp+0x11>
		p++, q++;
  800a43:	83 c1 01             	add    $0x1,%ecx
  800a46:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a49:	0f b6 01             	movzbl (%ecx),%eax
  800a4c:	84 c0                	test   %al,%al
  800a4e:	74 04                	je     800a54 <strcmp+0x1c>
  800a50:	3a 02                	cmp    (%edx),%al
  800a52:	74 ef                	je     800a43 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a54:	0f b6 c0             	movzbl %al,%eax
  800a57:	0f b6 12             	movzbl (%edx),%edx
  800a5a:	29 d0                	sub    %edx,%eax
}
  800a5c:	5d                   	pop    %ebp
  800a5d:	c3                   	ret    

00800a5e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a5e:	55                   	push   %ebp
  800a5f:	89 e5                	mov    %esp,%ebp
  800a61:	53                   	push   %ebx
  800a62:	8b 45 08             	mov    0x8(%ebp),%eax
  800a65:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a68:	89 c3                	mov    %eax,%ebx
  800a6a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a6d:	eb 06                	jmp    800a75 <strncmp+0x17>
		n--, p++, q++;
  800a6f:	83 c0 01             	add    $0x1,%eax
  800a72:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a75:	39 d8                	cmp    %ebx,%eax
  800a77:	74 15                	je     800a8e <strncmp+0x30>
  800a79:	0f b6 08             	movzbl (%eax),%ecx
  800a7c:	84 c9                	test   %cl,%cl
  800a7e:	74 04                	je     800a84 <strncmp+0x26>
  800a80:	3a 0a                	cmp    (%edx),%cl
  800a82:	74 eb                	je     800a6f <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a84:	0f b6 00             	movzbl (%eax),%eax
  800a87:	0f b6 12             	movzbl (%edx),%edx
  800a8a:	29 d0                	sub    %edx,%eax
  800a8c:	eb 05                	jmp    800a93 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a8e:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a93:	5b                   	pop    %ebx
  800a94:	5d                   	pop    %ebp
  800a95:	c3                   	ret    

00800a96 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a96:	55                   	push   %ebp
  800a97:	89 e5                	mov    %esp,%ebp
  800a99:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800aa0:	eb 07                	jmp    800aa9 <strchr+0x13>
		if (*s == c)
  800aa2:	38 ca                	cmp    %cl,%dl
  800aa4:	74 0f                	je     800ab5 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800aa6:	83 c0 01             	add    $0x1,%eax
  800aa9:	0f b6 10             	movzbl (%eax),%edx
  800aac:	84 d2                	test   %dl,%dl
  800aae:	75 f2                	jne    800aa2 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800ab0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ab5:	5d                   	pop    %ebp
  800ab6:	c3                   	ret    

00800ab7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ab7:	55                   	push   %ebp
  800ab8:	89 e5                	mov    %esp,%ebp
  800aba:	8b 45 08             	mov    0x8(%ebp),%eax
  800abd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ac1:	eb 03                	jmp    800ac6 <strfind+0xf>
  800ac3:	83 c0 01             	add    $0x1,%eax
  800ac6:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ac9:	38 ca                	cmp    %cl,%dl
  800acb:	74 04                	je     800ad1 <strfind+0x1a>
  800acd:	84 d2                	test   %dl,%dl
  800acf:	75 f2                	jne    800ac3 <strfind+0xc>
			break;
	return (char *) s;
}
  800ad1:	5d                   	pop    %ebp
  800ad2:	c3                   	ret    

00800ad3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ad3:	55                   	push   %ebp
  800ad4:	89 e5                	mov    %esp,%ebp
  800ad6:	57                   	push   %edi
  800ad7:	56                   	push   %esi
  800ad8:	53                   	push   %ebx
  800ad9:	8b 7d 08             	mov    0x8(%ebp),%edi
  800adc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800adf:	85 c9                	test   %ecx,%ecx
  800ae1:	74 36                	je     800b19 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ae3:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ae9:	75 28                	jne    800b13 <memset+0x40>
  800aeb:	f6 c1 03             	test   $0x3,%cl
  800aee:	75 23                	jne    800b13 <memset+0x40>
		c &= 0xFF;
  800af0:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800af4:	89 d3                	mov    %edx,%ebx
  800af6:	c1 e3 08             	shl    $0x8,%ebx
  800af9:	89 d6                	mov    %edx,%esi
  800afb:	c1 e6 18             	shl    $0x18,%esi
  800afe:	89 d0                	mov    %edx,%eax
  800b00:	c1 e0 10             	shl    $0x10,%eax
  800b03:	09 f0                	or     %esi,%eax
  800b05:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b07:	89 d8                	mov    %ebx,%eax
  800b09:	09 d0                	or     %edx,%eax
  800b0b:	c1 e9 02             	shr    $0x2,%ecx
  800b0e:	fc                   	cld    
  800b0f:	f3 ab                	rep stos %eax,%es:(%edi)
  800b11:	eb 06                	jmp    800b19 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b13:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b16:	fc                   	cld    
  800b17:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b19:	89 f8                	mov    %edi,%eax
  800b1b:	5b                   	pop    %ebx
  800b1c:	5e                   	pop    %esi
  800b1d:	5f                   	pop    %edi
  800b1e:	5d                   	pop    %ebp
  800b1f:	c3                   	ret    

00800b20 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b20:	55                   	push   %ebp
  800b21:	89 e5                	mov    %esp,%ebp
  800b23:	57                   	push   %edi
  800b24:	56                   	push   %esi
  800b25:	8b 45 08             	mov    0x8(%ebp),%eax
  800b28:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b2b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b2e:	39 c6                	cmp    %eax,%esi
  800b30:	73 35                	jae    800b67 <memmove+0x47>
  800b32:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b35:	39 d0                	cmp    %edx,%eax
  800b37:	73 2e                	jae    800b67 <memmove+0x47>
		s += n;
		d += n;
  800b39:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b3c:	89 d6                	mov    %edx,%esi
  800b3e:	09 fe                	or     %edi,%esi
  800b40:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b46:	75 13                	jne    800b5b <memmove+0x3b>
  800b48:	f6 c1 03             	test   $0x3,%cl
  800b4b:	75 0e                	jne    800b5b <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b4d:	83 ef 04             	sub    $0x4,%edi
  800b50:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b53:	c1 e9 02             	shr    $0x2,%ecx
  800b56:	fd                   	std    
  800b57:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b59:	eb 09                	jmp    800b64 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b5b:	83 ef 01             	sub    $0x1,%edi
  800b5e:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b61:	fd                   	std    
  800b62:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b64:	fc                   	cld    
  800b65:	eb 1d                	jmp    800b84 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b67:	89 f2                	mov    %esi,%edx
  800b69:	09 c2                	or     %eax,%edx
  800b6b:	f6 c2 03             	test   $0x3,%dl
  800b6e:	75 0f                	jne    800b7f <memmove+0x5f>
  800b70:	f6 c1 03             	test   $0x3,%cl
  800b73:	75 0a                	jne    800b7f <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b75:	c1 e9 02             	shr    $0x2,%ecx
  800b78:	89 c7                	mov    %eax,%edi
  800b7a:	fc                   	cld    
  800b7b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b7d:	eb 05                	jmp    800b84 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b7f:	89 c7                	mov    %eax,%edi
  800b81:	fc                   	cld    
  800b82:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b84:	5e                   	pop    %esi
  800b85:	5f                   	pop    %edi
  800b86:	5d                   	pop    %ebp
  800b87:	c3                   	ret    

00800b88 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b88:	55                   	push   %ebp
  800b89:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b8b:	ff 75 10             	pushl  0x10(%ebp)
  800b8e:	ff 75 0c             	pushl  0xc(%ebp)
  800b91:	ff 75 08             	pushl  0x8(%ebp)
  800b94:	e8 87 ff ff ff       	call   800b20 <memmove>
}
  800b99:	c9                   	leave  
  800b9a:	c3                   	ret    

00800b9b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b9b:	55                   	push   %ebp
  800b9c:	89 e5                	mov    %esp,%ebp
  800b9e:	56                   	push   %esi
  800b9f:	53                   	push   %ebx
  800ba0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ba6:	89 c6                	mov    %eax,%esi
  800ba8:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bab:	eb 1a                	jmp    800bc7 <memcmp+0x2c>
		if (*s1 != *s2)
  800bad:	0f b6 08             	movzbl (%eax),%ecx
  800bb0:	0f b6 1a             	movzbl (%edx),%ebx
  800bb3:	38 d9                	cmp    %bl,%cl
  800bb5:	74 0a                	je     800bc1 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800bb7:	0f b6 c1             	movzbl %cl,%eax
  800bba:	0f b6 db             	movzbl %bl,%ebx
  800bbd:	29 d8                	sub    %ebx,%eax
  800bbf:	eb 0f                	jmp    800bd0 <memcmp+0x35>
		s1++, s2++;
  800bc1:	83 c0 01             	add    $0x1,%eax
  800bc4:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bc7:	39 f0                	cmp    %esi,%eax
  800bc9:	75 e2                	jne    800bad <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bcb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bd0:	5b                   	pop    %ebx
  800bd1:	5e                   	pop    %esi
  800bd2:	5d                   	pop    %ebp
  800bd3:	c3                   	ret    

00800bd4 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bd4:	55                   	push   %ebp
  800bd5:	89 e5                	mov    %esp,%ebp
  800bd7:	53                   	push   %ebx
  800bd8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bdb:	89 c1                	mov    %eax,%ecx
  800bdd:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800be0:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800be4:	eb 0a                	jmp    800bf0 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800be6:	0f b6 10             	movzbl (%eax),%edx
  800be9:	39 da                	cmp    %ebx,%edx
  800beb:	74 07                	je     800bf4 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bed:	83 c0 01             	add    $0x1,%eax
  800bf0:	39 c8                	cmp    %ecx,%eax
  800bf2:	72 f2                	jb     800be6 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bf4:	5b                   	pop    %ebx
  800bf5:	5d                   	pop    %ebp
  800bf6:	c3                   	ret    

00800bf7 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bf7:	55                   	push   %ebp
  800bf8:	89 e5                	mov    %esp,%ebp
  800bfa:	57                   	push   %edi
  800bfb:	56                   	push   %esi
  800bfc:	53                   	push   %ebx
  800bfd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c00:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c03:	eb 03                	jmp    800c08 <strtol+0x11>
		s++;
  800c05:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c08:	0f b6 01             	movzbl (%ecx),%eax
  800c0b:	3c 20                	cmp    $0x20,%al
  800c0d:	74 f6                	je     800c05 <strtol+0xe>
  800c0f:	3c 09                	cmp    $0x9,%al
  800c11:	74 f2                	je     800c05 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c13:	3c 2b                	cmp    $0x2b,%al
  800c15:	75 0a                	jne    800c21 <strtol+0x2a>
		s++;
  800c17:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c1a:	bf 00 00 00 00       	mov    $0x0,%edi
  800c1f:	eb 11                	jmp    800c32 <strtol+0x3b>
  800c21:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c26:	3c 2d                	cmp    $0x2d,%al
  800c28:	75 08                	jne    800c32 <strtol+0x3b>
		s++, neg = 1;
  800c2a:	83 c1 01             	add    $0x1,%ecx
  800c2d:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c32:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c38:	75 15                	jne    800c4f <strtol+0x58>
  800c3a:	80 39 30             	cmpb   $0x30,(%ecx)
  800c3d:	75 10                	jne    800c4f <strtol+0x58>
  800c3f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c43:	75 7c                	jne    800cc1 <strtol+0xca>
		s += 2, base = 16;
  800c45:	83 c1 02             	add    $0x2,%ecx
  800c48:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c4d:	eb 16                	jmp    800c65 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c4f:	85 db                	test   %ebx,%ebx
  800c51:	75 12                	jne    800c65 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c53:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c58:	80 39 30             	cmpb   $0x30,(%ecx)
  800c5b:	75 08                	jne    800c65 <strtol+0x6e>
		s++, base = 8;
  800c5d:	83 c1 01             	add    $0x1,%ecx
  800c60:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c65:	b8 00 00 00 00       	mov    $0x0,%eax
  800c6a:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c6d:	0f b6 11             	movzbl (%ecx),%edx
  800c70:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c73:	89 f3                	mov    %esi,%ebx
  800c75:	80 fb 09             	cmp    $0x9,%bl
  800c78:	77 08                	ja     800c82 <strtol+0x8b>
			dig = *s - '0';
  800c7a:	0f be d2             	movsbl %dl,%edx
  800c7d:	83 ea 30             	sub    $0x30,%edx
  800c80:	eb 22                	jmp    800ca4 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c82:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c85:	89 f3                	mov    %esi,%ebx
  800c87:	80 fb 19             	cmp    $0x19,%bl
  800c8a:	77 08                	ja     800c94 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c8c:	0f be d2             	movsbl %dl,%edx
  800c8f:	83 ea 57             	sub    $0x57,%edx
  800c92:	eb 10                	jmp    800ca4 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c94:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c97:	89 f3                	mov    %esi,%ebx
  800c99:	80 fb 19             	cmp    $0x19,%bl
  800c9c:	77 16                	ja     800cb4 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c9e:	0f be d2             	movsbl %dl,%edx
  800ca1:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ca4:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ca7:	7d 0b                	jge    800cb4 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ca9:	83 c1 01             	add    $0x1,%ecx
  800cac:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cb0:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800cb2:	eb b9                	jmp    800c6d <strtol+0x76>

	if (endptr)
  800cb4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cb8:	74 0d                	je     800cc7 <strtol+0xd0>
		*endptr = (char *) s;
  800cba:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cbd:	89 0e                	mov    %ecx,(%esi)
  800cbf:	eb 06                	jmp    800cc7 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cc1:	85 db                	test   %ebx,%ebx
  800cc3:	74 98                	je     800c5d <strtol+0x66>
  800cc5:	eb 9e                	jmp    800c65 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800cc7:	89 c2                	mov    %eax,%edx
  800cc9:	f7 da                	neg    %edx
  800ccb:	85 ff                	test   %edi,%edi
  800ccd:	0f 45 c2             	cmovne %edx,%eax
}
  800cd0:	5b                   	pop    %ebx
  800cd1:	5e                   	pop    %esi
  800cd2:	5f                   	pop    %edi
  800cd3:	5d                   	pop    %ebp
  800cd4:	c3                   	ret    

00800cd5 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800cd5:	55                   	push   %ebp
  800cd6:	89 e5                	mov    %esp,%ebp
  800cd8:	57                   	push   %edi
  800cd9:	56                   	push   %esi
  800cda:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cdb:	b8 00 00 00 00       	mov    $0x0,%eax
  800ce0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce6:	89 c3                	mov    %eax,%ebx
  800ce8:	89 c7                	mov    %eax,%edi
  800cea:	89 c6                	mov    %eax,%esi
  800cec:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800cee:	5b                   	pop    %ebx
  800cef:	5e                   	pop    %esi
  800cf0:	5f                   	pop    %edi
  800cf1:	5d                   	pop    %ebp
  800cf2:	c3                   	ret    

00800cf3 <sys_cgetc>:

int
sys_cgetc(void)
{
  800cf3:	55                   	push   %ebp
  800cf4:	89 e5                	mov    %esp,%ebp
  800cf6:	57                   	push   %edi
  800cf7:	56                   	push   %esi
  800cf8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf9:	ba 00 00 00 00       	mov    $0x0,%edx
  800cfe:	b8 01 00 00 00       	mov    $0x1,%eax
  800d03:	89 d1                	mov    %edx,%ecx
  800d05:	89 d3                	mov    %edx,%ebx
  800d07:	89 d7                	mov    %edx,%edi
  800d09:	89 d6                	mov    %edx,%esi
  800d0b:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d0d:	5b                   	pop    %ebx
  800d0e:	5e                   	pop    %esi
  800d0f:	5f                   	pop    %edi
  800d10:	5d                   	pop    %ebp
  800d11:	c3                   	ret    

00800d12 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d12:	55                   	push   %ebp
  800d13:	89 e5                	mov    %esp,%ebp
  800d15:	57                   	push   %edi
  800d16:	56                   	push   %esi
  800d17:	53                   	push   %ebx
  800d18:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d20:	b8 03 00 00 00       	mov    $0x3,%eax
  800d25:	8b 55 08             	mov    0x8(%ebp),%edx
  800d28:	89 cb                	mov    %ecx,%ebx
  800d2a:	89 cf                	mov    %ecx,%edi
  800d2c:	89 ce                	mov    %ecx,%esi
  800d2e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d30:	85 c0                	test   %eax,%eax
  800d32:	7e 17                	jle    800d4b <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d34:	83 ec 0c             	sub    $0xc,%esp
  800d37:	50                   	push   %eax
  800d38:	6a 03                	push   $0x3
  800d3a:	68 9f 28 80 00       	push   $0x80289f
  800d3f:	6a 23                	push   $0x23
  800d41:	68 bc 28 80 00       	push   $0x8028bc
  800d46:	e8 c7 f5 ff ff       	call   800312 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4e:	5b                   	pop    %ebx
  800d4f:	5e                   	pop    %esi
  800d50:	5f                   	pop    %edi
  800d51:	5d                   	pop    %ebp
  800d52:	c3                   	ret    

00800d53 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d53:	55                   	push   %ebp
  800d54:	89 e5                	mov    %esp,%ebp
  800d56:	57                   	push   %edi
  800d57:	56                   	push   %esi
  800d58:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d59:	ba 00 00 00 00       	mov    $0x0,%edx
  800d5e:	b8 02 00 00 00       	mov    $0x2,%eax
  800d63:	89 d1                	mov    %edx,%ecx
  800d65:	89 d3                	mov    %edx,%ebx
  800d67:	89 d7                	mov    %edx,%edi
  800d69:	89 d6                	mov    %edx,%esi
  800d6b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d6d:	5b                   	pop    %ebx
  800d6e:	5e                   	pop    %esi
  800d6f:	5f                   	pop    %edi
  800d70:	5d                   	pop    %ebp
  800d71:	c3                   	ret    

00800d72 <sys_yield>:

void
sys_yield(void)
{
  800d72:	55                   	push   %ebp
  800d73:	89 e5                	mov    %esp,%ebp
  800d75:	57                   	push   %edi
  800d76:	56                   	push   %esi
  800d77:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d78:	ba 00 00 00 00       	mov    $0x0,%edx
  800d7d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d82:	89 d1                	mov    %edx,%ecx
  800d84:	89 d3                	mov    %edx,%ebx
  800d86:	89 d7                	mov    %edx,%edi
  800d88:	89 d6                	mov    %edx,%esi
  800d8a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d8c:	5b                   	pop    %ebx
  800d8d:	5e                   	pop    %esi
  800d8e:	5f                   	pop    %edi
  800d8f:	5d                   	pop    %ebp
  800d90:	c3                   	ret    

00800d91 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d91:	55                   	push   %ebp
  800d92:	89 e5                	mov    %esp,%ebp
  800d94:	57                   	push   %edi
  800d95:	56                   	push   %esi
  800d96:	53                   	push   %ebx
  800d97:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9a:	be 00 00 00 00       	mov    $0x0,%esi
  800d9f:	b8 04 00 00 00       	mov    $0x4,%eax
  800da4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da7:	8b 55 08             	mov    0x8(%ebp),%edx
  800daa:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dad:	89 f7                	mov    %esi,%edi
  800daf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800db1:	85 c0                	test   %eax,%eax
  800db3:	7e 17                	jle    800dcc <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db5:	83 ec 0c             	sub    $0xc,%esp
  800db8:	50                   	push   %eax
  800db9:	6a 04                	push   $0x4
  800dbb:	68 9f 28 80 00       	push   $0x80289f
  800dc0:	6a 23                	push   $0x23
  800dc2:	68 bc 28 80 00       	push   $0x8028bc
  800dc7:	e8 46 f5 ff ff       	call   800312 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800dcc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dcf:	5b                   	pop    %ebx
  800dd0:	5e                   	pop    %esi
  800dd1:	5f                   	pop    %edi
  800dd2:	5d                   	pop    %ebp
  800dd3:	c3                   	ret    

00800dd4 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800dd4:	55                   	push   %ebp
  800dd5:	89 e5                	mov    %esp,%ebp
  800dd7:	57                   	push   %edi
  800dd8:	56                   	push   %esi
  800dd9:	53                   	push   %ebx
  800dda:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ddd:	b8 05 00 00 00       	mov    $0x5,%eax
  800de2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de5:	8b 55 08             	mov    0x8(%ebp),%edx
  800de8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800deb:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dee:	8b 75 18             	mov    0x18(%ebp),%esi
  800df1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800df3:	85 c0                	test   %eax,%eax
  800df5:	7e 17                	jle    800e0e <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df7:	83 ec 0c             	sub    $0xc,%esp
  800dfa:	50                   	push   %eax
  800dfb:	6a 05                	push   $0x5
  800dfd:	68 9f 28 80 00       	push   $0x80289f
  800e02:	6a 23                	push   $0x23
  800e04:	68 bc 28 80 00       	push   $0x8028bc
  800e09:	e8 04 f5 ff ff       	call   800312 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e0e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e11:	5b                   	pop    %ebx
  800e12:	5e                   	pop    %esi
  800e13:	5f                   	pop    %edi
  800e14:	5d                   	pop    %ebp
  800e15:	c3                   	ret    

00800e16 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e16:	55                   	push   %ebp
  800e17:	89 e5                	mov    %esp,%ebp
  800e19:	57                   	push   %edi
  800e1a:	56                   	push   %esi
  800e1b:	53                   	push   %ebx
  800e1c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e1f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e24:	b8 06 00 00 00       	mov    $0x6,%eax
  800e29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e2c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2f:	89 df                	mov    %ebx,%edi
  800e31:	89 de                	mov    %ebx,%esi
  800e33:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e35:	85 c0                	test   %eax,%eax
  800e37:	7e 17                	jle    800e50 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e39:	83 ec 0c             	sub    $0xc,%esp
  800e3c:	50                   	push   %eax
  800e3d:	6a 06                	push   $0x6
  800e3f:	68 9f 28 80 00       	push   $0x80289f
  800e44:	6a 23                	push   $0x23
  800e46:	68 bc 28 80 00       	push   $0x8028bc
  800e4b:	e8 c2 f4 ff ff       	call   800312 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e53:	5b                   	pop    %ebx
  800e54:	5e                   	pop    %esi
  800e55:	5f                   	pop    %edi
  800e56:	5d                   	pop    %ebp
  800e57:	c3                   	ret    

00800e58 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e58:	55                   	push   %ebp
  800e59:	89 e5                	mov    %esp,%ebp
  800e5b:	57                   	push   %edi
  800e5c:	56                   	push   %esi
  800e5d:	53                   	push   %ebx
  800e5e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e61:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e66:	b8 08 00 00 00       	mov    $0x8,%eax
  800e6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e71:	89 df                	mov    %ebx,%edi
  800e73:	89 de                	mov    %ebx,%esi
  800e75:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e77:	85 c0                	test   %eax,%eax
  800e79:	7e 17                	jle    800e92 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e7b:	83 ec 0c             	sub    $0xc,%esp
  800e7e:	50                   	push   %eax
  800e7f:	6a 08                	push   $0x8
  800e81:	68 9f 28 80 00       	push   $0x80289f
  800e86:	6a 23                	push   $0x23
  800e88:	68 bc 28 80 00       	push   $0x8028bc
  800e8d:	e8 80 f4 ff ff       	call   800312 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e92:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e95:	5b                   	pop    %ebx
  800e96:	5e                   	pop    %esi
  800e97:	5f                   	pop    %edi
  800e98:	5d                   	pop    %ebp
  800e99:	c3                   	ret    

00800e9a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e9a:	55                   	push   %ebp
  800e9b:	89 e5                	mov    %esp,%ebp
  800e9d:	57                   	push   %edi
  800e9e:	56                   	push   %esi
  800e9f:	53                   	push   %ebx
  800ea0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ea8:	b8 09 00 00 00       	mov    $0x9,%eax
  800ead:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb3:	89 df                	mov    %ebx,%edi
  800eb5:	89 de                	mov    %ebx,%esi
  800eb7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800eb9:	85 c0                	test   %eax,%eax
  800ebb:	7e 17                	jle    800ed4 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ebd:	83 ec 0c             	sub    $0xc,%esp
  800ec0:	50                   	push   %eax
  800ec1:	6a 09                	push   $0x9
  800ec3:	68 9f 28 80 00       	push   $0x80289f
  800ec8:	6a 23                	push   $0x23
  800eca:	68 bc 28 80 00       	push   $0x8028bc
  800ecf:	e8 3e f4 ff ff       	call   800312 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ed4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ed7:	5b                   	pop    %ebx
  800ed8:	5e                   	pop    %esi
  800ed9:	5f                   	pop    %edi
  800eda:	5d                   	pop    %ebp
  800edb:	c3                   	ret    

00800edc <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800edc:	55                   	push   %ebp
  800edd:	89 e5                	mov    %esp,%ebp
  800edf:	57                   	push   %edi
  800ee0:	56                   	push   %esi
  800ee1:	53                   	push   %ebx
  800ee2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ee5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eea:	b8 0a 00 00 00       	mov    $0xa,%eax
  800eef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef5:	89 df                	mov    %ebx,%edi
  800ef7:	89 de                	mov    %ebx,%esi
  800ef9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800efb:	85 c0                	test   %eax,%eax
  800efd:	7e 17                	jle    800f16 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eff:	83 ec 0c             	sub    $0xc,%esp
  800f02:	50                   	push   %eax
  800f03:	6a 0a                	push   $0xa
  800f05:	68 9f 28 80 00       	push   $0x80289f
  800f0a:	6a 23                	push   $0x23
  800f0c:	68 bc 28 80 00       	push   $0x8028bc
  800f11:	e8 fc f3 ff ff       	call   800312 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f19:	5b                   	pop    %ebx
  800f1a:	5e                   	pop    %esi
  800f1b:	5f                   	pop    %edi
  800f1c:	5d                   	pop    %ebp
  800f1d:	c3                   	ret    

00800f1e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f1e:	55                   	push   %ebp
  800f1f:	89 e5                	mov    %esp,%ebp
  800f21:	57                   	push   %edi
  800f22:	56                   	push   %esi
  800f23:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f24:	be 00 00 00 00       	mov    $0x0,%esi
  800f29:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f31:	8b 55 08             	mov    0x8(%ebp),%edx
  800f34:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f37:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f3a:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f3c:	5b                   	pop    %ebx
  800f3d:	5e                   	pop    %esi
  800f3e:	5f                   	pop    %edi
  800f3f:	5d                   	pop    %ebp
  800f40:	c3                   	ret    

00800f41 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f41:	55                   	push   %ebp
  800f42:	89 e5                	mov    %esp,%ebp
  800f44:	57                   	push   %edi
  800f45:	56                   	push   %esi
  800f46:	53                   	push   %ebx
  800f47:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f4a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f4f:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f54:	8b 55 08             	mov    0x8(%ebp),%edx
  800f57:	89 cb                	mov    %ecx,%ebx
  800f59:	89 cf                	mov    %ecx,%edi
  800f5b:	89 ce                	mov    %ecx,%esi
  800f5d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f5f:	85 c0                	test   %eax,%eax
  800f61:	7e 17                	jle    800f7a <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f63:	83 ec 0c             	sub    $0xc,%esp
  800f66:	50                   	push   %eax
  800f67:	6a 0d                	push   $0xd
  800f69:	68 9f 28 80 00       	push   $0x80289f
  800f6e:	6a 23                	push   $0x23
  800f70:	68 bc 28 80 00       	push   $0x8028bc
  800f75:	e8 98 f3 ff ff       	call   800312 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f7d:	5b                   	pop    %ebx
  800f7e:	5e                   	pop    %esi
  800f7f:	5f                   	pop    %edi
  800f80:	5d                   	pop    %ebp
  800f81:	c3                   	ret    

00800f82 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800f82:	55                   	push   %ebp
  800f83:	89 e5                	mov    %esp,%ebp
  800f85:	53                   	push   %ebx
  800f86:	83 ec 04             	sub    $0x4,%esp
	int r;
	// LAB 4: Your code here.
    	pte_t *pte;
	int ret;
	// 用户空间的地址较低
	void *addr = (void *)(pn * PGSIZE);
  800f89:	89 d3                	mov    %edx,%ebx
  800f8b:	c1 e3 0c             	shl    $0xc,%ebx
	if (uvpt[pn] & PTE_SHARE) {
  800f8e:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800f95:	f6 c5 04             	test   $0x4,%ch
  800f98:	74 2f                	je     800fc9 <duppage+0x47>
		// cprintf("dup share page :%d\n", pn);
		if ((r = sys_page_map(0, addr, envid, addr, PTE_SYSCALL)) < 0)
  800f9a:	83 ec 0c             	sub    $0xc,%esp
  800f9d:	68 07 0e 00 00       	push   $0xe07
  800fa2:	53                   	push   %ebx
  800fa3:	50                   	push   %eax
  800fa4:	53                   	push   %ebx
  800fa5:	6a 00                	push   $0x0
  800fa7:	e8 28 fe ff ff       	call   800dd4 <sys_page_map>
  800fac:	83 c4 20             	add    $0x20,%esp
  800faf:	85 c0                	test   %eax,%eax
  800fb1:	0f 89 a0 00 00 00    	jns    801057 <duppage+0xd5>
			panic("duppage sys_page_map:%e", r);
  800fb7:	50                   	push   %eax
  800fb8:	68 ca 28 80 00       	push   $0x8028ca
  800fbd:	6a 4d                	push   $0x4d
  800fbf:	68 e2 28 80 00       	push   $0x8028e2
  800fc4:	e8 49 f3 ff ff       	call   800312 <_panic>
	} else if (uvpt[pn] & (PTE_W|PTE_COW)) {
  800fc9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fd0:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800fd6:	74 57                	je     80102f <duppage+0xad>
		if ((r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  800fd8:	83 ec 0c             	sub    $0xc,%esp
  800fdb:	68 05 08 00 00       	push   $0x805
  800fe0:	53                   	push   %ebx
  800fe1:	50                   	push   %eax
  800fe2:	53                   	push   %ebx
  800fe3:	6a 00                	push   $0x0
  800fe5:	e8 ea fd ff ff       	call   800dd4 <sys_page_map>
  800fea:	83 c4 20             	add    $0x20,%esp
  800fed:	85 c0                	test   %eax,%eax
  800fef:	79 12                	jns    801003 <duppage+0x81>
			panic("sys_page_map COW:%e", r);
  800ff1:	50                   	push   %eax
  800ff2:	68 ed 28 80 00       	push   $0x8028ed
  800ff7:	6a 50                	push   $0x50
  800ff9:	68 e2 28 80 00       	push   $0x8028e2
  800ffe:	e8 0f f3 ff ff       	call   800312 <_panic>

		if ((r = sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  801003:	83 ec 0c             	sub    $0xc,%esp
  801006:	68 05 08 00 00       	push   $0x805
  80100b:	53                   	push   %ebx
  80100c:	6a 00                	push   $0x0
  80100e:	53                   	push   %ebx
  80100f:	6a 00                	push   $0x0
  801011:	e8 be fd ff ff       	call   800dd4 <sys_page_map>
  801016:	83 c4 20             	add    $0x20,%esp
  801019:	85 c0                	test   %eax,%eax
  80101b:	79 3a                	jns    801057 <duppage+0xd5>
			panic("sys_page_map COW:%e", r);
  80101d:	50                   	push   %eax
  80101e:	68 ed 28 80 00       	push   $0x8028ed
  801023:	6a 53                	push   $0x53
  801025:	68 e2 28 80 00       	push   $0x8028e2
  80102a:	e8 e3 f2 ff ff       	call   800312 <_panic>
	} else {
		if ((r = sys_page_map(0, addr, envid, addr, PTE_U|PTE_P)) < 0)
  80102f:	83 ec 0c             	sub    $0xc,%esp
  801032:	6a 05                	push   $0x5
  801034:	53                   	push   %ebx
  801035:	50                   	push   %eax
  801036:	53                   	push   %ebx
  801037:	6a 00                	push   $0x0
  801039:	e8 96 fd ff ff       	call   800dd4 <sys_page_map>
  80103e:	83 c4 20             	add    $0x20,%esp
  801041:	85 c0                	test   %eax,%eax
  801043:	79 12                	jns    801057 <duppage+0xd5>
			panic("sys_page_map UP:%e", r);
  801045:	50                   	push   %eax
  801046:	68 01 29 80 00       	push   $0x802901
  80104b:	6a 56                	push   $0x56
  80104d:	68 e2 28 80 00       	push   $0x8028e2
  801052:	e8 bb f2 ff ff       	call   800312 <_panic>
	}
	return 0;
}
  801057:	b8 00 00 00 00       	mov    $0x0,%eax
  80105c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80105f:	c9                   	leave  
  801060:	c3                   	ret    

00801061 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801061:	55                   	push   %ebp
  801062:	89 e5                	mov    %esp,%ebp
  801064:	56                   	push   %esi
  801065:	53                   	push   %ebx
  801066:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801069:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (! ( (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  80106b:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  80106f:	74 2d                	je     80109e <pgfault+0x3d>
  801071:	89 d8                	mov    %ebx,%eax
  801073:	c1 e8 16             	shr    $0x16,%eax
  801076:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80107d:	a8 01                	test   $0x1,%al
  80107f:	74 1d                	je     80109e <pgfault+0x3d>
  801081:	89 d8                	mov    %ebx,%eax
  801083:	c1 e8 0c             	shr    $0xc,%eax
  801086:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80108d:	f6 c2 01             	test   $0x1,%dl
  801090:	74 0c                	je     80109e <pgfault+0x3d>
  801092:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801099:	f6 c4 08             	test   $0x8,%ah
  80109c:	75 14                	jne    8010b2 <pgfault+0x51>
        	panic("Neither the fault is a write nor COW page. \n");
  80109e:	83 ec 04             	sub    $0x4,%esp
  8010a1:	68 80 29 80 00       	push   $0x802980
  8010a6:	6a 1d                	push   $0x1d
  8010a8:	68 e2 28 80 00       	push   $0x8028e2
  8010ad:	e8 60 f2 ff ff       	call   800312 <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.
	

    	envid_t envid = sys_getenvid();
  8010b2:	e8 9c fc ff ff       	call   800d53 <sys_getenvid>
  8010b7:	89 c6                	mov    %eax,%esi
    	// cprintf("pgfault: envid: %d\n", ENVX(envid));
    	// 临时页暂存
    	if ((r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P| PTE_W|PTE_U)) < 0)
  8010b9:	83 ec 04             	sub    $0x4,%esp
  8010bc:	6a 07                	push   $0x7
  8010be:	68 00 f0 7f 00       	push   $0x7ff000
  8010c3:	50                   	push   %eax
  8010c4:	e8 c8 fc ff ff       	call   800d91 <sys_page_alloc>
  8010c9:	83 c4 10             	add    $0x10,%esp
  8010cc:	85 c0                	test   %eax,%eax
  8010ce:	79 12                	jns    8010e2 <pgfault+0x81>
        	panic("pgfault: page allocation fault:%e\n", r);
  8010d0:	50                   	push   %eax
  8010d1:	68 b0 29 80 00       	push   $0x8029b0
  8010d6:	6a 2b                	push   $0x2b
  8010d8:	68 e2 28 80 00       	push   $0x8028e2
  8010dd:	e8 30 f2 ff ff       	call   800312 <_panic>
    	addr = ROUNDDOWN(addr, PGSIZE);
  8010e2:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  8010e8:	83 ec 04             	sub    $0x4,%esp
  8010eb:	68 00 10 00 00       	push   $0x1000
  8010f0:	53                   	push   %ebx
  8010f1:	68 00 f0 7f 00       	push   $0x7ff000
  8010f6:	e8 8d fa ff ff       	call   800b88 <memcpy>
    	if ((r = sys_page_map(envid, (void *) PFTEMP, envid, addr , PTE_P|PTE_W|PTE_U)) < 0 )
  8010fb:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801102:	53                   	push   %ebx
  801103:	56                   	push   %esi
  801104:	68 00 f0 7f 00       	push   $0x7ff000
  801109:	56                   	push   %esi
  80110a:	e8 c5 fc ff ff       	call   800dd4 <sys_page_map>
  80110f:	83 c4 20             	add    $0x20,%esp
  801112:	85 c0                	test   %eax,%eax
  801114:	79 12                	jns    801128 <pgfault+0xc7>
        	panic("pgfault: page map failed %e\n", r);
  801116:	50                   	push   %eax
  801117:	68 14 29 80 00       	push   $0x802914
  80111c:	6a 2f                	push   $0x2f
  80111e:	68 e2 28 80 00       	push   $0x8028e2
  801123:	e8 ea f1 ff ff       	call   800312 <_panic>
    
    	if ((r = sys_page_unmap(envid, (void *) PFTEMP)) < 0)
  801128:	83 ec 08             	sub    $0x8,%esp
  80112b:	68 00 f0 7f 00       	push   $0x7ff000
  801130:	56                   	push   %esi
  801131:	e8 e0 fc ff ff       	call   800e16 <sys_page_unmap>
  801136:	83 c4 10             	add    $0x10,%esp
  801139:	85 c0                	test   %eax,%eax
  80113b:	79 12                	jns    80114f <pgfault+0xee>
        	panic("pgfault: page unmap failed %e\n", r);
  80113d:	50                   	push   %eax
  80113e:	68 d4 29 80 00       	push   $0x8029d4
  801143:	6a 32                	push   $0x32
  801145:	68 e2 28 80 00       	push   $0x8028e2
  80114a:	e8 c3 f1 ff ff       	call   800312 <_panic>
	//panic("pgfault not implemented");
}
  80114f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801152:	5b                   	pop    %ebx
  801153:	5e                   	pop    %esi
  801154:	5d                   	pop    %ebp
  801155:	c3                   	ret    

00801156 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801156:	55                   	push   %ebp
  801157:	89 e5                	mov    %esp,%ebp
  801159:	56                   	push   %esi
  80115a:	53                   	push   %ebx
  80115b:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	set_pgfault_handler(pgfault);
  80115e:	68 61 10 80 00       	push   $0x801061
  801163:	e8 63 0e 00 00       	call   801fcb <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801168:	b8 07 00 00 00       	mov    $0x7,%eax
  80116d:	cd 30                	int    $0x30
  80116f:	89 c3                	mov    %eax,%ebx

	envid_t envid = sys_exofork();
	uint8_t *addr;
	if (envid < 0)
  801171:	83 c4 10             	add    $0x10,%esp
  801174:	85 c0                	test   %eax,%eax
  801176:	79 12                	jns    80118a <fork+0x34>
		panic("sys_exofork:%e", envid);
  801178:	50                   	push   %eax
  801179:	68 31 29 80 00       	push   $0x802931
  80117e:	6a 75                	push   $0x75
  801180:	68 e2 28 80 00       	push   $0x8028e2
  801185:	e8 88 f1 ff ff       	call   800312 <_panic>
  80118a:	89 c6                	mov    %eax,%esi
	if (envid == 0) {
  80118c:	85 c0                	test   %eax,%eax
  80118e:	75 21                	jne    8011b1 <fork+0x5b>
		thisenv = &envs[ENVX(sys_getenvid())];
  801190:	e8 be fb ff ff       	call   800d53 <sys_getenvid>
  801195:	25 ff 03 00 00       	and    $0x3ff,%eax
  80119a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80119d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011a2:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  8011a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ac:	e9 c0 00 00 00       	jmp    801271 <fork+0x11b>
	}

	for (addr = (uint8_t *)UTEXT; addr < (uint8_t *)USTACKTOP-PGSIZE; addr += PGSIZE) {
  8011b1:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  8011b8:	ba 00 00 80 00       	mov    $0x800000,%edx
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
  8011bd:	89 d0                	mov    %edx,%eax
  8011bf:	c1 e8 16             	shr    $0x16,%eax
  8011c2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011c9:	a8 01                	test   $0x1,%al
  8011cb:	74 20                	je     8011ed <fork+0x97>
  8011cd:	c1 ea 0c             	shr    $0xc,%edx
  8011d0:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8011d7:	a8 01                	test   $0x1,%al
  8011d9:	74 12                	je     8011ed <fork+0x97>
				&& (uvpt[PGNUM(addr)] & PTE_U)) {
  8011db:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8011e2:	a8 04                	test   $0x4,%al
  8011e4:	74 07                	je     8011ed <fork+0x97>
			duppage(envid, PGNUM(addr));
  8011e6:	89 f0                	mov    %esi,%eax
  8011e8:	e8 95 fd ff ff       	call   800f82 <duppage>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}

	for (addr = (uint8_t *)UTEXT; addr < (uint8_t *)USTACKTOP-PGSIZE; addr += PGSIZE) {
  8011ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011f0:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
  8011f6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8011f9:	81 fa ff cf bf ee    	cmp    $0xeebfcfff,%edx
  8011ff:	76 bc                	jbe    8011bd <fork+0x67>
				&& (uvpt[PGNUM(addr)] & PTE_U)) {
			duppage(envid, PGNUM(addr));
		}
	}

	duppage(envid, PGNUM(ROUNDDOWN(&addr, PGSIZE)));
  801201:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801204:	c1 ea 0c             	shr    $0xc,%edx
  801207:	89 d8                	mov    %ebx,%eax
  801209:	e8 74 fd ff ff       	call   800f82 <duppage>

	int r;
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)))
  80120e:	83 ec 04             	sub    $0x4,%esp
  801211:	6a 07                	push   $0x7
  801213:	68 00 f0 bf ee       	push   $0xeebff000
  801218:	53                   	push   %ebx
  801219:	e8 73 fb ff ff       	call   800d91 <sys_page_alloc>
  80121e:	83 c4 10             	add    $0x10,%esp
  801221:	85 c0                	test   %eax,%eax
  801223:	74 15                	je     80123a <fork+0xe4>
		panic("sys_page_alloc:%e", r);
  801225:	50                   	push   %eax
  801226:	68 40 29 80 00       	push   $0x802940
  80122b:	68 86 00 00 00       	push   $0x86
  801230:	68 e2 28 80 00       	push   $0x8028e2
  801235:	e8 d8 f0 ff ff       	call   800312 <_panic>

	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80123a:	83 ec 08             	sub    $0x8,%esp
  80123d:	68 33 20 80 00       	push   $0x802033
  801242:	53                   	push   %ebx
  801243:	e8 94 fc ff ff       	call   800edc <sys_env_set_pgfault_upcall>

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)))
  801248:	83 c4 08             	add    $0x8,%esp
  80124b:	6a 02                	push   $0x2
  80124d:	53                   	push   %ebx
  80124e:	e8 05 fc ff ff       	call   800e58 <sys_env_set_status>
  801253:	83 c4 10             	add    $0x10,%esp
  801256:	85 c0                	test   %eax,%eax
  801258:	74 15                	je     80126f <fork+0x119>
		panic("sys_env_set_status:%e", r);
  80125a:	50                   	push   %eax
  80125b:	68 52 29 80 00       	push   $0x802952
  801260:	68 8c 00 00 00       	push   $0x8c
  801265:	68 e2 28 80 00       	push   $0x8028e2
  80126a:	e8 a3 f0 ff ff       	call   800312 <_panic>

	return envid;
  80126f:	89 d8                	mov    %ebx,%eax
	    
}
  801271:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801274:	5b                   	pop    %ebx
  801275:	5e                   	pop    %esi
  801276:	5d                   	pop    %ebp
  801277:	c3                   	ret    

00801278 <sfork>:

// Challenge!
int
sfork(void)
{
  801278:	55                   	push   %ebp
  801279:	89 e5                	mov    %esp,%ebp
  80127b:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80127e:	68 68 29 80 00       	push   $0x802968
  801283:	68 96 00 00 00       	push   $0x96
  801288:	68 e2 28 80 00       	push   $0x8028e2
  80128d:	e8 80 f0 ff ff       	call   800312 <_panic>

00801292 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801292:	55                   	push   %ebp
  801293:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801295:	8b 45 08             	mov    0x8(%ebp),%eax
  801298:	05 00 00 00 30       	add    $0x30000000,%eax
  80129d:	c1 e8 0c             	shr    $0xc,%eax
}
  8012a0:	5d                   	pop    %ebp
  8012a1:	c3                   	ret    

008012a2 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012a2:	55                   	push   %ebp
  8012a3:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8012a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8012a8:	05 00 00 00 30       	add    $0x30000000,%eax
  8012ad:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8012b2:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012b7:	5d                   	pop    %ebp
  8012b8:	c3                   	ret    

008012b9 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012b9:	55                   	push   %ebp
  8012ba:	89 e5                	mov    %esp,%ebp
  8012bc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012bf:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012c4:	89 c2                	mov    %eax,%edx
  8012c6:	c1 ea 16             	shr    $0x16,%edx
  8012c9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012d0:	f6 c2 01             	test   $0x1,%dl
  8012d3:	74 11                	je     8012e6 <fd_alloc+0x2d>
  8012d5:	89 c2                	mov    %eax,%edx
  8012d7:	c1 ea 0c             	shr    $0xc,%edx
  8012da:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012e1:	f6 c2 01             	test   $0x1,%dl
  8012e4:	75 09                	jne    8012ef <fd_alloc+0x36>
			*fd_store = fd;
  8012e6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8012ed:	eb 17                	jmp    801306 <fd_alloc+0x4d>
  8012ef:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012f4:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012f9:	75 c9                	jne    8012c4 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012fb:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801301:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801306:	5d                   	pop    %ebp
  801307:	c3                   	ret    

00801308 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801308:	55                   	push   %ebp
  801309:	89 e5                	mov    %esp,%ebp
  80130b:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80130e:	83 f8 1f             	cmp    $0x1f,%eax
  801311:	77 36                	ja     801349 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801313:	c1 e0 0c             	shl    $0xc,%eax
  801316:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80131b:	89 c2                	mov    %eax,%edx
  80131d:	c1 ea 16             	shr    $0x16,%edx
  801320:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801327:	f6 c2 01             	test   $0x1,%dl
  80132a:	74 24                	je     801350 <fd_lookup+0x48>
  80132c:	89 c2                	mov    %eax,%edx
  80132e:	c1 ea 0c             	shr    $0xc,%edx
  801331:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801338:	f6 c2 01             	test   $0x1,%dl
  80133b:	74 1a                	je     801357 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80133d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801340:	89 02                	mov    %eax,(%edx)
	return 0;
  801342:	b8 00 00 00 00       	mov    $0x0,%eax
  801347:	eb 13                	jmp    80135c <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801349:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80134e:	eb 0c                	jmp    80135c <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801350:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801355:	eb 05                	jmp    80135c <fd_lookup+0x54>
  801357:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80135c:	5d                   	pop    %ebp
  80135d:	c3                   	ret    

0080135e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80135e:	55                   	push   %ebp
  80135f:	89 e5                	mov    %esp,%ebp
  801361:	83 ec 08             	sub    $0x8,%esp
  801364:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801367:	ba 70 2a 80 00       	mov    $0x802a70,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80136c:	eb 13                	jmp    801381 <dev_lookup+0x23>
  80136e:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801371:	39 08                	cmp    %ecx,(%eax)
  801373:	75 0c                	jne    801381 <dev_lookup+0x23>
			*dev = devtab[i];
  801375:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801378:	89 01                	mov    %eax,(%ecx)
			return 0;
  80137a:	b8 00 00 00 00       	mov    $0x0,%eax
  80137f:	eb 2e                	jmp    8013af <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801381:	8b 02                	mov    (%edx),%eax
  801383:	85 c0                	test   %eax,%eax
  801385:	75 e7                	jne    80136e <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801387:	a1 04 40 80 00       	mov    0x804004,%eax
  80138c:	8b 40 48             	mov    0x48(%eax),%eax
  80138f:	83 ec 04             	sub    $0x4,%esp
  801392:	51                   	push   %ecx
  801393:	50                   	push   %eax
  801394:	68 f4 29 80 00       	push   $0x8029f4
  801399:	e8 4d f0 ff ff       	call   8003eb <cprintf>
	*dev = 0;
  80139e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013a1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8013a7:	83 c4 10             	add    $0x10,%esp
  8013aa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013af:	c9                   	leave  
  8013b0:	c3                   	ret    

008013b1 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013b1:	55                   	push   %ebp
  8013b2:	89 e5                	mov    %esp,%ebp
  8013b4:	56                   	push   %esi
  8013b5:	53                   	push   %ebx
  8013b6:	83 ec 10             	sub    $0x10,%esp
  8013b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8013bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013c2:	50                   	push   %eax
  8013c3:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8013c9:	c1 e8 0c             	shr    $0xc,%eax
  8013cc:	50                   	push   %eax
  8013cd:	e8 36 ff ff ff       	call   801308 <fd_lookup>
  8013d2:	83 c4 08             	add    $0x8,%esp
  8013d5:	85 c0                	test   %eax,%eax
  8013d7:	78 05                	js     8013de <fd_close+0x2d>
	    || fd != fd2)
  8013d9:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013dc:	74 0c                	je     8013ea <fd_close+0x39>
		return (must_exist ? r : 0);
  8013de:	84 db                	test   %bl,%bl
  8013e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8013e5:	0f 44 c2             	cmove  %edx,%eax
  8013e8:	eb 41                	jmp    80142b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013ea:	83 ec 08             	sub    $0x8,%esp
  8013ed:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013f0:	50                   	push   %eax
  8013f1:	ff 36                	pushl  (%esi)
  8013f3:	e8 66 ff ff ff       	call   80135e <dev_lookup>
  8013f8:	89 c3                	mov    %eax,%ebx
  8013fa:	83 c4 10             	add    $0x10,%esp
  8013fd:	85 c0                	test   %eax,%eax
  8013ff:	78 1a                	js     80141b <fd_close+0x6a>
		if (dev->dev_close)
  801401:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801404:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801407:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80140c:	85 c0                	test   %eax,%eax
  80140e:	74 0b                	je     80141b <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801410:	83 ec 0c             	sub    $0xc,%esp
  801413:	56                   	push   %esi
  801414:	ff d0                	call   *%eax
  801416:	89 c3                	mov    %eax,%ebx
  801418:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80141b:	83 ec 08             	sub    $0x8,%esp
  80141e:	56                   	push   %esi
  80141f:	6a 00                	push   $0x0
  801421:	e8 f0 f9 ff ff       	call   800e16 <sys_page_unmap>
	return r;
  801426:	83 c4 10             	add    $0x10,%esp
  801429:	89 d8                	mov    %ebx,%eax
}
  80142b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80142e:	5b                   	pop    %ebx
  80142f:	5e                   	pop    %esi
  801430:	5d                   	pop    %ebp
  801431:	c3                   	ret    

00801432 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801432:	55                   	push   %ebp
  801433:	89 e5                	mov    %esp,%ebp
  801435:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801438:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80143b:	50                   	push   %eax
  80143c:	ff 75 08             	pushl  0x8(%ebp)
  80143f:	e8 c4 fe ff ff       	call   801308 <fd_lookup>
  801444:	83 c4 08             	add    $0x8,%esp
  801447:	85 c0                	test   %eax,%eax
  801449:	78 10                	js     80145b <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80144b:	83 ec 08             	sub    $0x8,%esp
  80144e:	6a 01                	push   $0x1
  801450:	ff 75 f4             	pushl  -0xc(%ebp)
  801453:	e8 59 ff ff ff       	call   8013b1 <fd_close>
  801458:	83 c4 10             	add    $0x10,%esp
}
  80145b:	c9                   	leave  
  80145c:	c3                   	ret    

0080145d <close_all>:

void
close_all(void)
{
  80145d:	55                   	push   %ebp
  80145e:	89 e5                	mov    %esp,%ebp
  801460:	53                   	push   %ebx
  801461:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801464:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801469:	83 ec 0c             	sub    $0xc,%esp
  80146c:	53                   	push   %ebx
  80146d:	e8 c0 ff ff ff       	call   801432 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801472:	83 c3 01             	add    $0x1,%ebx
  801475:	83 c4 10             	add    $0x10,%esp
  801478:	83 fb 20             	cmp    $0x20,%ebx
  80147b:	75 ec                	jne    801469 <close_all+0xc>
		close(i);
}
  80147d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801480:	c9                   	leave  
  801481:	c3                   	ret    

00801482 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801482:	55                   	push   %ebp
  801483:	89 e5                	mov    %esp,%ebp
  801485:	57                   	push   %edi
  801486:	56                   	push   %esi
  801487:	53                   	push   %ebx
  801488:	83 ec 2c             	sub    $0x2c,%esp
  80148b:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80148e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801491:	50                   	push   %eax
  801492:	ff 75 08             	pushl  0x8(%ebp)
  801495:	e8 6e fe ff ff       	call   801308 <fd_lookup>
  80149a:	83 c4 08             	add    $0x8,%esp
  80149d:	85 c0                	test   %eax,%eax
  80149f:	0f 88 c1 00 00 00    	js     801566 <dup+0xe4>
		return r;
	close(newfdnum);
  8014a5:	83 ec 0c             	sub    $0xc,%esp
  8014a8:	56                   	push   %esi
  8014a9:	e8 84 ff ff ff       	call   801432 <close>

	newfd = INDEX2FD(newfdnum);
  8014ae:	89 f3                	mov    %esi,%ebx
  8014b0:	c1 e3 0c             	shl    $0xc,%ebx
  8014b3:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8014b9:	83 c4 04             	add    $0x4,%esp
  8014bc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014bf:	e8 de fd ff ff       	call   8012a2 <fd2data>
  8014c4:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8014c6:	89 1c 24             	mov    %ebx,(%esp)
  8014c9:	e8 d4 fd ff ff       	call   8012a2 <fd2data>
  8014ce:	83 c4 10             	add    $0x10,%esp
  8014d1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014d4:	89 f8                	mov    %edi,%eax
  8014d6:	c1 e8 16             	shr    $0x16,%eax
  8014d9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014e0:	a8 01                	test   $0x1,%al
  8014e2:	74 37                	je     80151b <dup+0x99>
  8014e4:	89 f8                	mov    %edi,%eax
  8014e6:	c1 e8 0c             	shr    $0xc,%eax
  8014e9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014f0:	f6 c2 01             	test   $0x1,%dl
  8014f3:	74 26                	je     80151b <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014f5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014fc:	83 ec 0c             	sub    $0xc,%esp
  8014ff:	25 07 0e 00 00       	and    $0xe07,%eax
  801504:	50                   	push   %eax
  801505:	ff 75 d4             	pushl  -0x2c(%ebp)
  801508:	6a 00                	push   $0x0
  80150a:	57                   	push   %edi
  80150b:	6a 00                	push   $0x0
  80150d:	e8 c2 f8 ff ff       	call   800dd4 <sys_page_map>
  801512:	89 c7                	mov    %eax,%edi
  801514:	83 c4 20             	add    $0x20,%esp
  801517:	85 c0                	test   %eax,%eax
  801519:	78 2e                	js     801549 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80151b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80151e:	89 d0                	mov    %edx,%eax
  801520:	c1 e8 0c             	shr    $0xc,%eax
  801523:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80152a:	83 ec 0c             	sub    $0xc,%esp
  80152d:	25 07 0e 00 00       	and    $0xe07,%eax
  801532:	50                   	push   %eax
  801533:	53                   	push   %ebx
  801534:	6a 00                	push   $0x0
  801536:	52                   	push   %edx
  801537:	6a 00                	push   $0x0
  801539:	e8 96 f8 ff ff       	call   800dd4 <sys_page_map>
  80153e:	89 c7                	mov    %eax,%edi
  801540:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801543:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801545:	85 ff                	test   %edi,%edi
  801547:	79 1d                	jns    801566 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801549:	83 ec 08             	sub    $0x8,%esp
  80154c:	53                   	push   %ebx
  80154d:	6a 00                	push   $0x0
  80154f:	e8 c2 f8 ff ff       	call   800e16 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801554:	83 c4 08             	add    $0x8,%esp
  801557:	ff 75 d4             	pushl  -0x2c(%ebp)
  80155a:	6a 00                	push   $0x0
  80155c:	e8 b5 f8 ff ff       	call   800e16 <sys_page_unmap>
	return r;
  801561:	83 c4 10             	add    $0x10,%esp
  801564:	89 f8                	mov    %edi,%eax
}
  801566:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801569:	5b                   	pop    %ebx
  80156a:	5e                   	pop    %esi
  80156b:	5f                   	pop    %edi
  80156c:	5d                   	pop    %ebp
  80156d:	c3                   	ret    

0080156e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80156e:	55                   	push   %ebp
  80156f:	89 e5                	mov    %esp,%ebp
  801571:	53                   	push   %ebx
  801572:	83 ec 14             	sub    $0x14,%esp
  801575:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801578:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80157b:	50                   	push   %eax
  80157c:	53                   	push   %ebx
  80157d:	e8 86 fd ff ff       	call   801308 <fd_lookup>
  801582:	83 c4 08             	add    $0x8,%esp
  801585:	89 c2                	mov    %eax,%edx
  801587:	85 c0                	test   %eax,%eax
  801589:	78 6d                	js     8015f8 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80158b:	83 ec 08             	sub    $0x8,%esp
  80158e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801591:	50                   	push   %eax
  801592:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801595:	ff 30                	pushl  (%eax)
  801597:	e8 c2 fd ff ff       	call   80135e <dev_lookup>
  80159c:	83 c4 10             	add    $0x10,%esp
  80159f:	85 c0                	test   %eax,%eax
  8015a1:	78 4c                	js     8015ef <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015a3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015a6:	8b 42 08             	mov    0x8(%edx),%eax
  8015a9:	83 e0 03             	and    $0x3,%eax
  8015ac:	83 f8 01             	cmp    $0x1,%eax
  8015af:	75 21                	jne    8015d2 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015b1:	a1 04 40 80 00       	mov    0x804004,%eax
  8015b6:	8b 40 48             	mov    0x48(%eax),%eax
  8015b9:	83 ec 04             	sub    $0x4,%esp
  8015bc:	53                   	push   %ebx
  8015bd:	50                   	push   %eax
  8015be:	68 35 2a 80 00       	push   $0x802a35
  8015c3:	e8 23 ee ff ff       	call   8003eb <cprintf>
		return -E_INVAL;
  8015c8:	83 c4 10             	add    $0x10,%esp
  8015cb:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015d0:	eb 26                	jmp    8015f8 <read+0x8a>
	}
	if (!dev->dev_read)
  8015d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015d5:	8b 40 08             	mov    0x8(%eax),%eax
  8015d8:	85 c0                	test   %eax,%eax
  8015da:	74 17                	je     8015f3 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015dc:	83 ec 04             	sub    $0x4,%esp
  8015df:	ff 75 10             	pushl  0x10(%ebp)
  8015e2:	ff 75 0c             	pushl  0xc(%ebp)
  8015e5:	52                   	push   %edx
  8015e6:	ff d0                	call   *%eax
  8015e8:	89 c2                	mov    %eax,%edx
  8015ea:	83 c4 10             	add    $0x10,%esp
  8015ed:	eb 09                	jmp    8015f8 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ef:	89 c2                	mov    %eax,%edx
  8015f1:	eb 05                	jmp    8015f8 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015f3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8015f8:	89 d0                	mov    %edx,%eax
  8015fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015fd:	c9                   	leave  
  8015fe:	c3                   	ret    

008015ff <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015ff:	55                   	push   %ebp
  801600:	89 e5                	mov    %esp,%ebp
  801602:	57                   	push   %edi
  801603:	56                   	push   %esi
  801604:	53                   	push   %ebx
  801605:	83 ec 0c             	sub    $0xc,%esp
  801608:	8b 7d 08             	mov    0x8(%ebp),%edi
  80160b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80160e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801613:	eb 21                	jmp    801636 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801615:	83 ec 04             	sub    $0x4,%esp
  801618:	89 f0                	mov    %esi,%eax
  80161a:	29 d8                	sub    %ebx,%eax
  80161c:	50                   	push   %eax
  80161d:	89 d8                	mov    %ebx,%eax
  80161f:	03 45 0c             	add    0xc(%ebp),%eax
  801622:	50                   	push   %eax
  801623:	57                   	push   %edi
  801624:	e8 45 ff ff ff       	call   80156e <read>
		if (m < 0)
  801629:	83 c4 10             	add    $0x10,%esp
  80162c:	85 c0                	test   %eax,%eax
  80162e:	78 10                	js     801640 <readn+0x41>
			return m;
		if (m == 0)
  801630:	85 c0                	test   %eax,%eax
  801632:	74 0a                	je     80163e <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801634:	01 c3                	add    %eax,%ebx
  801636:	39 f3                	cmp    %esi,%ebx
  801638:	72 db                	jb     801615 <readn+0x16>
  80163a:	89 d8                	mov    %ebx,%eax
  80163c:	eb 02                	jmp    801640 <readn+0x41>
  80163e:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801640:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801643:	5b                   	pop    %ebx
  801644:	5e                   	pop    %esi
  801645:	5f                   	pop    %edi
  801646:	5d                   	pop    %ebp
  801647:	c3                   	ret    

00801648 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801648:	55                   	push   %ebp
  801649:	89 e5                	mov    %esp,%ebp
  80164b:	53                   	push   %ebx
  80164c:	83 ec 14             	sub    $0x14,%esp
  80164f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801652:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801655:	50                   	push   %eax
  801656:	53                   	push   %ebx
  801657:	e8 ac fc ff ff       	call   801308 <fd_lookup>
  80165c:	83 c4 08             	add    $0x8,%esp
  80165f:	89 c2                	mov    %eax,%edx
  801661:	85 c0                	test   %eax,%eax
  801663:	78 68                	js     8016cd <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801665:	83 ec 08             	sub    $0x8,%esp
  801668:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80166b:	50                   	push   %eax
  80166c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80166f:	ff 30                	pushl  (%eax)
  801671:	e8 e8 fc ff ff       	call   80135e <dev_lookup>
  801676:	83 c4 10             	add    $0x10,%esp
  801679:	85 c0                	test   %eax,%eax
  80167b:	78 47                	js     8016c4 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80167d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801680:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801684:	75 21                	jne    8016a7 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801686:	a1 04 40 80 00       	mov    0x804004,%eax
  80168b:	8b 40 48             	mov    0x48(%eax),%eax
  80168e:	83 ec 04             	sub    $0x4,%esp
  801691:	53                   	push   %ebx
  801692:	50                   	push   %eax
  801693:	68 51 2a 80 00       	push   $0x802a51
  801698:	e8 4e ed ff ff       	call   8003eb <cprintf>
		return -E_INVAL;
  80169d:	83 c4 10             	add    $0x10,%esp
  8016a0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016a5:	eb 26                	jmp    8016cd <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016a7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016aa:	8b 52 0c             	mov    0xc(%edx),%edx
  8016ad:	85 d2                	test   %edx,%edx
  8016af:	74 17                	je     8016c8 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016b1:	83 ec 04             	sub    $0x4,%esp
  8016b4:	ff 75 10             	pushl  0x10(%ebp)
  8016b7:	ff 75 0c             	pushl  0xc(%ebp)
  8016ba:	50                   	push   %eax
  8016bb:	ff d2                	call   *%edx
  8016bd:	89 c2                	mov    %eax,%edx
  8016bf:	83 c4 10             	add    $0x10,%esp
  8016c2:	eb 09                	jmp    8016cd <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016c4:	89 c2                	mov    %eax,%edx
  8016c6:	eb 05                	jmp    8016cd <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8016c8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8016cd:	89 d0                	mov    %edx,%eax
  8016cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016d2:	c9                   	leave  
  8016d3:	c3                   	ret    

008016d4 <seek>:

int
seek(int fdnum, off_t offset)
{
  8016d4:	55                   	push   %ebp
  8016d5:	89 e5                	mov    %esp,%ebp
  8016d7:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016da:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016dd:	50                   	push   %eax
  8016de:	ff 75 08             	pushl  0x8(%ebp)
  8016e1:	e8 22 fc ff ff       	call   801308 <fd_lookup>
  8016e6:	83 c4 08             	add    $0x8,%esp
  8016e9:	85 c0                	test   %eax,%eax
  8016eb:	78 0e                	js     8016fb <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8016ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016f0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016f3:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016fb:	c9                   	leave  
  8016fc:	c3                   	ret    

008016fd <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016fd:	55                   	push   %ebp
  8016fe:	89 e5                	mov    %esp,%ebp
  801700:	53                   	push   %ebx
  801701:	83 ec 14             	sub    $0x14,%esp
  801704:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801707:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80170a:	50                   	push   %eax
  80170b:	53                   	push   %ebx
  80170c:	e8 f7 fb ff ff       	call   801308 <fd_lookup>
  801711:	83 c4 08             	add    $0x8,%esp
  801714:	89 c2                	mov    %eax,%edx
  801716:	85 c0                	test   %eax,%eax
  801718:	78 65                	js     80177f <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80171a:	83 ec 08             	sub    $0x8,%esp
  80171d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801720:	50                   	push   %eax
  801721:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801724:	ff 30                	pushl  (%eax)
  801726:	e8 33 fc ff ff       	call   80135e <dev_lookup>
  80172b:	83 c4 10             	add    $0x10,%esp
  80172e:	85 c0                	test   %eax,%eax
  801730:	78 44                	js     801776 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801732:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801735:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801739:	75 21                	jne    80175c <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80173b:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801740:	8b 40 48             	mov    0x48(%eax),%eax
  801743:	83 ec 04             	sub    $0x4,%esp
  801746:	53                   	push   %ebx
  801747:	50                   	push   %eax
  801748:	68 14 2a 80 00       	push   $0x802a14
  80174d:	e8 99 ec ff ff       	call   8003eb <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801752:	83 c4 10             	add    $0x10,%esp
  801755:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80175a:	eb 23                	jmp    80177f <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80175c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80175f:	8b 52 18             	mov    0x18(%edx),%edx
  801762:	85 d2                	test   %edx,%edx
  801764:	74 14                	je     80177a <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801766:	83 ec 08             	sub    $0x8,%esp
  801769:	ff 75 0c             	pushl  0xc(%ebp)
  80176c:	50                   	push   %eax
  80176d:	ff d2                	call   *%edx
  80176f:	89 c2                	mov    %eax,%edx
  801771:	83 c4 10             	add    $0x10,%esp
  801774:	eb 09                	jmp    80177f <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801776:	89 c2                	mov    %eax,%edx
  801778:	eb 05                	jmp    80177f <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80177a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80177f:	89 d0                	mov    %edx,%eax
  801781:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801784:	c9                   	leave  
  801785:	c3                   	ret    

00801786 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801786:	55                   	push   %ebp
  801787:	89 e5                	mov    %esp,%ebp
  801789:	53                   	push   %ebx
  80178a:	83 ec 14             	sub    $0x14,%esp
  80178d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801790:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801793:	50                   	push   %eax
  801794:	ff 75 08             	pushl  0x8(%ebp)
  801797:	e8 6c fb ff ff       	call   801308 <fd_lookup>
  80179c:	83 c4 08             	add    $0x8,%esp
  80179f:	89 c2                	mov    %eax,%edx
  8017a1:	85 c0                	test   %eax,%eax
  8017a3:	78 58                	js     8017fd <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017a5:	83 ec 08             	sub    $0x8,%esp
  8017a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017ab:	50                   	push   %eax
  8017ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017af:	ff 30                	pushl  (%eax)
  8017b1:	e8 a8 fb ff ff       	call   80135e <dev_lookup>
  8017b6:	83 c4 10             	add    $0x10,%esp
  8017b9:	85 c0                	test   %eax,%eax
  8017bb:	78 37                	js     8017f4 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8017bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017c0:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017c4:	74 32                	je     8017f8 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017c6:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017c9:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017d0:	00 00 00 
	stat->st_isdir = 0;
  8017d3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017da:	00 00 00 
	stat->st_dev = dev;
  8017dd:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017e3:	83 ec 08             	sub    $0x8,%esp
  8017e6:	53                   	push   %ebx
  8017e7:	ff 75 f0             	pushl  -0x10(%ebp)
  8017ea:	ff 50 14             	call   *0x14(%eax)
  8017ed:	89 c2                	mov    %eax,%edx
  8017ef:	83 c4 10             	add    $0x10,%esp
  8017f2:	eb 09                	jmp    8017fd <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017f4:	89 c2                	mov    %eax,%edx
  8017f6:	eb 05                	jmp    8017fd <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017f8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017fd:	89 d0                	mov    %edx,%eax
  8017ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801802:	c9                   	leave  
  801803:	c3                   	ret    

00801804 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801804:	55                   	push   %ebp
  801805:	89 e5                	mov    %esp,%ebp
  801807:	56                   	push   %esi
  801808:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801809:	83 ec 08             	sub    $0x8,%esp
  80180c:	6a 00                	push   $0x0
  80180e:	ff 75 08             	pushl  0x8(%ebp)
  801811:	e8 e3 01 00 00       	call   8019f9 <open>
  801816:	89 c3                	mov    %eax,%ebx
  801818:	83 c4 10             	add    $0x10,%esp
  80181b:	85 c0                	test   %eax,%eax
  80181d:	78 1b                	js     80183a <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80181f:	83 ec 08             	sub    $0x8,%esp
  801822:	ff 75 0c             	pushl  0xc(%ebp)
  801825:	50                   	push   %eax
  801826:	e8 5b ff ff ff       	call   801786 <fstat>
  80182b:	89 c6                	mov    %eax,%esi
	close(fd);
  80182d:	89 1c 24             	mov    %ebx,(%esp)
  801830:	e8 fd fb ff ff       	call   801432 <close>
	return r;
  801835:	83 c4 10             	add    $0x10,%esp
  801838:	89 f0                	mov    %esi,%eax
}
  80183a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80183d:	5b                   	pop    %ebx
  80183e:	5e                   	pop    %esi
  80183f:	5d                   	pop    %ebp
  801840:	c3                   	ret    

00801841 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801841:	55                   	push   %ebp
  801842:	89 e5                	mov    %esp,%ebp
  801844:	56                   	push   %esi
  801845:	53                   	push   %ebx
  801846:	89 c6                	mov    %eax,%esi
  801848:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80184a:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801851:	75 12                	jne    801865 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801853:	83 ec 0c             	sub    $0xc,%esp
  801856:	6a 01                	push   $0x1
  801858:	e8 a3 08 00 00       	call   802100 <ipc_find_env>
  80185d:	a3 00 40 80 00       	mov    %eax,0x804000
  801862:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801865:	6a 07                	push   $0x7
  801867:	68 00 50 80 00       	push   $0x805000
  80186c:	56                   	push   %esi
  80186d:	ff 35 00 40 80 00    	pushl  0x804000
  801873:	e8 34 08 00 00       	call   8020ac <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801878:	83 c4 0c             	add    $0xc,%esp
  80187b:	6a 00                	push   $0x0
  80187d:	53                   	push   %ebx
  80187e:	6a 00                	push   $0x0
  801880:	e8 d2 07 00 00       	call   802057 <ipc_recv>
}
  801885:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801888:	5b                   	pop    %ebx
  801889:	5e                   	pop    %esi
  80188a:	5d                   	pop    %ebp
  80188b:	c3                   	ret    

0080188c <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80188c:	55                   	push   %ebp
  80188d:	89 e5                	mov    %esp,%ebp
  80188f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801892:	8b 45 08             	mov    0x8(%ebp),%eax
  801895:	8b 40 0c             	mov    0xc(%eax),%eax
  801898:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80189d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018a0:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8018aa:	b8 02 00 00 00       	mov    $0x2,%eax
  8018af:	e8 8d ff ff ff       	call   801841 <fsipc>
}
  8018b4:	c9                   	leave  
  8018b5:	c3                   	ret    

008018b6 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018b6:	55                   	push   %ebp
  8018b7:	89 e5                	mov    %esp,%ebp
  8018b9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8018bf:	8b 40 0c             	mov    0xc(%eax),%eax
  8018c2:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8018cc:	b8 06 00 00 00       	mov    $0x6,%eax
  8018d1:	e8 6b ff ff ff       	call   801841 <fsipc>
}
  8018d6:	c9                   	leave  
  8018d7:	c3                   	ret    

008018d8 <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018d8:	55                   	push   %ebp
  8018d9:	89 e5                	mov    %esp,%ebp
  8018db:	53                   	push   %ebx
  8018dc:	83 ec 04             	sub    $0x4,%esp
  8018df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e5:	8b 40 0c             	mov    0xc(%eax),%eax
  8018e8:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8018f2:	b8 05 00 00 00       	mov    $0x5,%eax
  8018f7:	e8 45 ff ff ff       	call   801841 <fsipc>
  8018fc:	85 c0                	test   %eax,%eax
  8018fe:	78 2c                	js     80192c <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801900:	83 ec 08             	sub    $0x8,%esp
  801903:	68 00 50 80 00       	push   $0x805000
  801908:	53                   	push   %ebx
  801909:	e8 80 f0 ff ff       	call   80098e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80190e:	a1 80 50 80 00       	mov    0x805080,%eax
  801913:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801919:	a1 84 50 80 00       	mov    0x805084,%eax
  80191e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801924:	83 c4 10             	add    $0x10,%esp
  801927:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80192c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80192f:	c9                   	leave  
  801930:	c3                   	ret    

00801931 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801931:	55                   	push   %ebp
  801932:	89 e5                	mov    %esp,%ebp
  801934:	83 ec 0c             	sub    $0xc,%esp
  801937:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
    
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  80193a:	8b 55 08             	mov    0x8(%ebp),%edx
  80193d:	8b 52 0c             	mov    0xc(%edx),%edx
  801940:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = MIN(n, PGSIZE);
  801946:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80194b:	ba 00 10 00 00       	mov    $0x1000,%edx
  801950:	0f 47 c2             	cmova  %edx,%eax
  801953:	a3 04 50 80 00       	mov    %eax,0x805004
    memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801958:	50                   	push   %eax
  801959:	ff 75 0c             	pushl  0xc(%ebp)
  80195c:	68 08 50 80 00       	push   $0x805008
  801961:	e8 ba f1 ff ff       	call   800b20 <memmove>
    int r = fsipc(FSREQ_WRITE, NULL);
  801966:	ba 00 00 00 00       	mov    $0x0,%edx
  80196b:	b8 04 00 00 00       	mov    $0x4,%eax
  801970:	e8 cc fe ff ff       	call   801841 <fsipc>
    return r;
}
  801975:	c9                   	leave  
  801976:	c3                   	ret    

00801977 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801977:	55                   	push   %ebp
  801978:	89 e5                	mov    %esp,%ebp
  80197a:	56                   	push   %esi
  80197b:	53                   	push   %ebx
  80197c:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80197f:	8b 45 08             	mov    0x8(%ebp),%eax
  801982:	8b 40 0c             	mov    0xc(%eax),%eax
  801985:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80198a:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801990:	ba 00 00 00 00       	mov    $0x0,%edx
  801995:	b8 03 00 00 00       	mov    $0x3,%eax
  80199a:	e8 a2 fe ff ff       	call   801841 <fsipc>
  80199f:	89 c3                	mov    %eax,%ebx
  8019a1:	85 c0                	test   %eax,%eax
  8019a3:	78 4b                	js     8019f0 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8019a5:	39 c6                	cmp    %eax,%esi
  8019a7:	73 16                	jae    8019bf <devfile_read+0x48>
  8019a9:	68 80 2a 80 00       	push   $0x802a80
  8019ae:	68 87 2a 80 00       	push   $0x802a87
  8019b3:	6a 7c                	push   $0x7c
  8019b5:	68 9c 2a 80 00       	push   $0x802a9c
  8019ba:	e8 53 e9 ff ff       	call   800312 <_panic>
	assert(r <= PGSIZE);
  8019bf:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019c4:	7e 16                	jle    8019dc <devfile_read+0x65>
  8019c6:	68 a7 2a 80 00       	push   $0x802aa7
  8019cb:	68 87 2a 80 00       	push   $0x802a87
  8019d0:	6a 7d                	push   $0x7d
  8019d2:	68 9c 2a 80 00       	push   $0x802a9c
  8019d7:	e8 36 e9 ff ff       	call   800312 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019dc:	83 ec 04             	sub    $0x4,%esp
  8019df:	50                   	push   %eax
  8019e0:	68 00 50 80 00       	push   $0x805000
  8019e5:	ff 75 0c             	pushl  0xc(%ebp)
  8019e8:	e8 33 f1 ff ff       	call   800b20 <memmove>
	return r;
  8019ed:	83 c4 10             	add    $0x10,%esp
}
  8019f0:	89 d8                	mov    %ebx,%eax
  8019f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019f5:	5b                   	pop    %ebx
  8019f6:	5e                   	pop    %esi
  8019f7:	5d                   	pop    %ebp
  8019f8:	c3                   	ret    

008019f9 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019f9:	55                   	push   %ebp
  8019fa:	89 e5                	mov    %esp,%ebp
  8019fc:	53                   	push   %ebx
  8019fd:	83 ec 20             	sub    $0x20,%esp
  801a00:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a03:	53                   	push   %ebx
  801a04:	e8 4c ef ff ff       	call   800955 <strlen>
  801a09:	83 c4 10             	add    $0x10,%esp
  801a0c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a11:	7f 67                	jg     801a7a <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a13:	83 ec 0c             	sub    $0xc,%esp
  801a16:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a19:	50                   	push   %eax
  801a1a:	e8 9a f8 ff ff       	call   8012b9 <fd_alloc>
  801a1f:	83 c4 10             	add    $0x10,%esp
		return r;
  801a22:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a24:	85 c0                	test   %eax,%eax
  801a26:	78 57                	js     801a7f <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a28:	83 ec 08             	sub    $0x8,%esp
  801a2b:	53                   	push   %ebx
  801a2c:	68 00 50 80 00       	push   $0x805000
  801a31:	e8 58 ef ff ff       	call   80098e <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a36:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a39:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a3e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a41:	b8 01 00 00 00       	mov    $0x1,%eax
  801a46:	e8 f6 fd ff ff       	call   801841 <fsipc>
  801a4b:	89 c3                	mov    %eax,%ebx
  801a4d:	83 c4 10             	add    $0x10,%esp
  801a50:	85 c0                	test   %eax,%eax
  801a52:	79 14                	jns    801a68 <open+0x6f>
		fd_close(fd, 0);
  801a54:	83 ec 08             	sub    $0x8,%esp
  801a57:	6a 00                	push   $0x0
  801a59:	ff 75 f4             	pushl  -0xc(%ebp)
  801a5c:	e8 50 f9 ff ff       	call   8013b1 <fd_close>
		return r;
  801a61:	83 c4 10             	add    $0x10,%esp
  801a64:	89 da                	mov    %ebx,%edx
  801a66:	eb 17                	jmp    801a7f <open+0x86>
	}

	return fd2num(fd);
  801a68:	83 ec 0c             	sub    $0xc,%esp
  801a6b:	ff 75 f4             	pushl  -0xc(%ebp)
  801a6e:	e8 1f f8 ff ff       	call   801292 <fd2num>
  801a73:	89 c2                	mov    %eax,%edx
  801a75:	83 c4 10             	add    $0x10,%esp
  801a78:	eb 05                	jmp    801a7f <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a7a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a7f:	89 d0                	mov    %edx,%eax
  801a81:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a84:	c9                   	leave  
  801a85:	c3                   	ret    

00801a86 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a86:	55                   	push   %ebp
  801a87:	89 e5                	mov    %esp,%ebp
  801a89:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a8c:	ba 00 00 00 00       	mov    $0x0,%edx
  801a91:	b8 08 00 00 00       	mov    $0x8,%eax
  801a96:	e8 a6 fd ff ff       	call   801841 <fsipc>
}
  801a9b:	c9                   	leave  
  801a9c:	c3                   	ret    

00801a9d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a9d:	55                   	push   %ebp
  801a9e:	89 e5                	mov    %esp,%ebp
  801aa0:	56                   	push   %esi
  801aa1:	53                   	push   %ebx
  801aa2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801aa5:	83 ec 0c             	sub    $0xc,%esp
  801aa8:	ff 75 08             	pushl  0x8(%ebp)
  801aab:	e8 f2 f7 ff ff       	call   8012a2 <fd2data>
  801ab0:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801ab2:	83 c4 08             	add    $0x8,%esp
  801ab5:	68 b3 2a 80 00       	push   $0x802ab3
  801aba:	53                   	push   %ebx
  801abb:	e8 ce ee ff ff       	call   80098e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ac0:	8b 46 04             	mov    0x4(%esi),%eax
  801ac3:	2b 06                	sub    (%esi),%eax
  801ac5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801acb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ad2:	00 00 00 
	stat->st_dev = &devpipe;
  801ad5:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  801adc:	30 80 00 
	return 0;
}
  801adf:	b8 00 00 00 00       	mov    $0x0,%eax
  801ae4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ae7:	5b                   	pop    %ebx
  801ae8:	5e                   	pop    %esi
  801ae9:	5d                   	pop    %ebp
  801aea:	c3                   	ret    

00801aeb <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801aeb:	55                   	push   %ebp
  801aec:	89 e5                	mov    %esp,%ebp
  801aee:	53                   	push   %ebx
  801aef:	83 ec 0c             	sub    $0xc,%esp
  801af2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801af5:	53                   	push   %ebx
  801af6:	6a 00                	push   $0x0
  801af8:	e8 19 f3 ff ff       	call   800e16 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801afd:	89 1c 24             	mov    %ebx,(%esp)
  801b00:	e8 9d f7 ff ff       	call   8012a2 <fd2data>
  801b05:	83 c4 08             	add    $0x8,%esp
  801b08:	50                   	push   %eax
  801b09:	6a 00                	push   $0x0
  801b0b:	e8 06 f3 ff ff       	call   800e16 <sys_page_unmap>
}
  801b10:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b13:	c9                   	leave  
  801b14:	c3                   	ret    

00801b15 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b15:	55                   	push   %ebp
  801b16:	89 e5                	mov    %esp,%ebp
  801b18:	57                   	push   %edi
  801b19:	56                   	push   %esi
  801b1a:	53                   	push   %ebx
  801b1b:	83 ec 1c             	sub    $0x1c,%esp
  801b1e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b21:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b23:	a1 04 40 80 00       	mov    0x804004,%eax
  801b28:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b2b:	83 ec 0c             	sub    $0xc,%esp
  801b2e:	ff 75 e0             	pushl  -0x20(%ebp)
  801b31:	e8 03 06 00 00       	call   802139 <pageref>
  801b36:	89 c3                	mov    %eax,%ebx
  801b38:	89 3c 24             	mov    %edi,(%esp)
  801b3b:	e8 f9 05 00 00       	call   802139 <pageref>
  801b40:	83 c4 10             	add    $0x10,%esp
  801b43:	39 c3                	cmp    %eax,%ebx
  801b45:	0f 94 c1             	sete   %cl
  801b48:	0f b6 c9             	movzbl %cl,%ecx
  801b4b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b4e:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801b54:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b57:	39 ce                	cmp    %ecx,%esi
  801b59:	74 1b                	je     801b76 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801b5b:	39 c3                	cmp    %eax,%ebx
  801b5d:	75 c4                	jne    801b23 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b5f:	8b 42 58             	mov    0x58(%edx),%eax
  801b62:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b65:	50                   	push   %eax
  801b66:	56                   	push   %esi
  801b67:	68 ba 2a 80 00       	push   $0x802aba
  801b6c:	e8 7a e8 ff ff       	call   8003eb <cprintf>
  801b71:	83 c4 10             	add    $0x10,%esp
  801b74:	eb ad                	jmp    801b23 <_pipeisclosed+0xe>
	}
}
  801b76:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b79:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b7c:	5b                   	pop    %ebx
  801b7d:	5e                   	pop    %esi
  801b7e:	5f                   	pop    %edi
  801b7f:	5d                   	pop    %ebp
  801b80:	c3                   	ret    

00801b81 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b81:	55                   	push   %ebp
  801b82:	89 e5                	mov    %esp,%ebp
  801b84:	57                   	push   %edi
  801b85:	56                   	push   %esi
  801b86:	53                   	push   %ebx
  801b87:	83 ec 28             	sub    $0x28,%esp
  801b8a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b8d:	56                   	push   %esi
  801b8e:	e8 0f f7 ff ff       	call   8012a2 <fd2data>
  801b93:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b95:	83 c4 10             	add    $0x10,%esp
  801b98:	bf 00 00 00 00       	mov    $0x0,%edi
  801b9d:	eb 4b                	jmp    801bea <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b9f:	89 da                	mov    %ebx,%edx
  801ba1:	89 f0                	mov    %esi,%eax
  801ba3:	e8 6d ff ff ff       	call   801b15 <_pipeisclosed>
  801ba8:	85 c0                	test   %eax,%eax
  801baa:	75 48                	jne    801bf4 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801bac:	e8 c1 f1 ff ff       	call   800d72 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801bb1:	8b 43 04             	mov    0x4(%ebx),%eax
  801bb4:	8b 0b                	mov    (%ebx),%ecx
  801bb6:	8d 51 20             	lea    0x20(%ecx),%edx
  801bb9:	39 d0                	cmp    %edx,%eax
  801bbb:	73 e2                	jae    801b9f <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801bbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bc0:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801bc4:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801bc7:	89 c2                	mov    %eax,%edx
  801bc9:	c1 fa 1f             	sar    $0x1f,%edx
  801bcc:	89 d1                	mov    %edx,%ecx
  801bce:	c1 e9 1b             	shr    $0x1b,%ecx
  801bd1:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801bd4:	83 e2 1f             	and    $0x1f,%edx
  801bd7:	29 ca                	sub    %ecx,%edx
  801bd9:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801bdd:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801be1:	83 c0 01             	add    $0x1,%eax
  801be4:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801be7:	83 c7 01             	add    $0x1,%edi
  801bea:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801bed:	75 c2                	jne    801bb1 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801bef:	8b 45 10             	mov    0x10(%ebp),%eax
  801bf2:	eb 05                	jmp    801bf9 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bf4:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801bf9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bfc:	5b                   	pop    %ebx
  801bfd:	5e                   	pop    %esi
  801bfe:	5f                   	pop    %edi
  801bff:	5d                   	pop    %ebp
  801c00:	c3                   	ret    

00801c01 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c01:	55                   	push   %ebp
  801c02:	89 e5                	mov    %esp,%ebp
  801c04:	57                   	push   %edi
  801c05:	56                   	push   %esi
  801c06:	53                   	push   %ebx
  801c07:	83 ec 18             	sub    $0x18,%esp
  801c0a:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c0d:	57                   	push   %edi
  801c0e:	e8 8f f6 ff ff       	call   8012a2 <fd2data>
  801c13:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c15:	83 c4 10             	add    $0x10,%esp
  801c18:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c1d:	eb 3d                	jmp    801c5c <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c1f:	85 db                	test   %ebx,%ebx
  801c21:	74 04                	je     801c27 <devpipe_read+0x26>
				return i;
  801c23:	89 d8                	mov    %ebx,%eax
  801c25:	eb 44                	jmp    801c6b <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c27:	89 f2                	mov    %esi,%edx
  801c29:	89 f8                	mov    %edi,%eax
  801c2b:	e8 e5 fe ff ff       	call   801b15 <_pipeisclosed>
  801c30:	85 c0                	test   %eax,%eax
  801c32:	75 32                	jne    801c66 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c34:	e8 39 f1 ff ff       	call   800d72 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c39:	8b 06                	mov    (%esi),%eax
  801c3b:	3b 46 04             	cmp    0x4(%esi),%eax
  801c3e:	74 df                	je     801c1f <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c40:	99                   	cltd   
  801c41:	c1 ea 1b             	shr    $0x1b,%edx
  801c44:	01 d0                	add    %edx,%eax
  801c46:	83 e0 1f             	and    $0x1f,%eax
  801c49:	29 d0                	sub    %edx,%eax
  801c4b:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c53:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c56:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c59:	83 c3 01             	add    $0x1,%ebx
  801c5c:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c5f:	75 d8                	jne    801c39 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c61:	8b 45 10             	mov    0x10(%ebp),%eax
  801c64:	eb 05                	jmp    801c6b <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c66:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c6b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c6e:	5b                   	pop    %ebx
  801c6f:	5e                   	pop    %esi
  801c70:	5f                   	pop    %edi
  801c71:	5d                   	pop    %ebp
  801c72:	c3                   	ret    

00801c73 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c73:	55                   	push   %ebp
  801c74:	89 e5                	mov    %esp,%ebp
  801c76:	56                   	push   %esi
  801c77:	53                   	push   %ebx
  801c78:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c7b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c7e:	50                   	push   %eax
  801c7f:	e8 35 f6 ff ff       	call   8012b9 <fd_alloc>
  801c84:	83 c4 10             	add    $0x10,%esp
  801c87:	89 c2                	mov    %eax,%edx
  801c89:	85 c0                	test   %eax,%eax
  801c8b:	0f 88 2c 01 00 00    	js     801dbd <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c91:	83 ec 04             	sub    $0x4,%esp
  801c94:	68 07 04 00 00       	push   $0x407
  801c99:	ff 75 f4             	pushl  -0xc(%ebp)
  801c9c:	6a 00                	push   $0x0
  801c9e:	e8 ee f0 ff ff       	call   800d91 <sys_page_alloc>
  801ca3:	83 c4 10             	add    $0x10,%esp
  801ca6:	89 c2                	mov    %eax,%edx
  801ca8:	85 c0                	test   %eax,%eax
  801caa:	0f 88 0d 01 00 00    	js     801dbd <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801cb0:	83 ec 0c             	sub    $0xc,%esp
  801cb3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801cb6:	50                   	push   %eax
  801cb7:	e8 fd f5 ff ff       	call   8012b9 <fd_alloc>
  801cbc:	89 c3                	mov    %eax,%ebx
  801cbe:	83 c4 10             	add    $0x10,%esp
  801cc1:	85 c0                	test   %eax,%eax
  801cc3:	0f 88 e2 00 00 00    	js     801dab <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cc9:	83 ec 04             	sub    $0x4,%esp
  801ccc:	68 07 04 00 00       	push   $0x407
  801cd1:	ff 75 f0             	pushl  -0x10(%ebp)
  801cd4:	6a 00                	push   $0x0
  801cd6:	e8 b6 f0 ff ff       	call   800d91 <sys_page_alloc>
  801cdb:	89 c3                	mov    %eax,%ebx
  801cdd:	83 c4 10             	add    $0x10,%esp
  801ce0:	85 c0                	test   %eax,%eax
  801ce2:	0f 88 c3 00 00 00    	js     801dab <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ce8:	83 ec 0c             	sub    $0xc,%esp
  801ceb:	ff 75 f4             	pushl  -0xc(%ebp)
  801cee:	e8 af f5 ff ff       	call   8012a2 <fd2data>
  801cf3:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cf5:	83 c4 0c             	add    $0xc,%esp
  801cf8:	68 07 04 00 00       	push   $0x407
  801cfd:	50                   	push   %eax
  801cfe:	6a 00                	push   $0x0
  801d00:	e8 8c f0 ff ff       	call   800d91 <sys_page_alloc>
  801d05:	89 c3                	mov    %eax,%ebx
  801d07:	83 c4 10             	add    $0x10,%esp
  801d0a:	85 c0                	test   %eax,%eax
  801d0c:	0f 88 89 00 00 00    	js     801d9b <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d12:	83 ec 0c             	sub    $0xc,%esp
  801d15:	ff 75 f0             	pushl  -0x10(%ebp)
  801d18:	e8 85 f5 ff ff       	call   8012a2 <fd2data>
  801d1d:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d24:	50                   	push   %eax
  801d25:	6a 00                	push   $0x0
  801d27:	56                   	push   %esi
  801d28:	6a 00                	push   $0x0
  801d2a:	e8 a5 f0 ff ff       	call   800dd4 <sys_page_map>
  801d2f:	89 c3                	mov    %eax,%ebx
  801d31:	83 c4 20             	add    $0x20,%esp
  801d34:	85 c0                	test   %eax,%eax
  801d36:	78 55                	js     801d8d <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d38:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801d3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d41:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d43:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d46:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d4d:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801d53:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d56:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d58:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d5b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d62:	83 ec 0c             	sub    $0xc,%esp
  801d65:	ff 75 f4             	pushl  -0xc(%ebp)
  801d68:	e8 25 f5 ff ff       	call   801292 <fd2num>
  801d6d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d70:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d72:	83 c4 04             	add    $0x4,%esp
  801d75:	ff 75 f0             	pushl  -0x10(%ebp)
  801d78:	e8 15 f5 ff ff       	call   801292 <fd2num>
  801d7d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d80:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d83:	83 c4 10             	add    $0x10,%esp
  801d86:	ba 00 00 00 00       	mov    $0x0,%edx
  801d8b:	eb 30                	jmp    801dbd <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d8d:	83 ec 08             	sub    $0x8,%esp
  801d90:	56                   	push   %esi
  801d91:	6a 00                	push   $0x0
  801d93:	e8 7e f0 ff ff       	call   800e16 <sys_page_unmap>
  801d98:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d9b:	83 ec 08             	sub    $0x8,%esp
  801d9e:	ff 75 f0             	pushl  -0x10(%ebp)
  801da1:	6a 00                	push   $0x0
  801da3:	e8 6e f0 ff ff       	call   800e16 <sys_page_unmap>
  801da8:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801dab:	83 ec 08             	sub    $0x8,%esp
  801dae:	ff 75 f4             	pushl  -0xc(%ebp)
  801db1:	6a 00                	push   $0x0
  801db3:	e8 5e f0 ff ff       	call   800e16 <sys_page_unmap>
  801db8:	83 c4 10             	add    $0x10,%esp
  801dbb:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801dbd:	89 d0                	mov    %edx,%eax
  801dbf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dc2:	5b                   	pop    %ebx
  801dc3:	5e                   	pop    %esi
  801dc4:	5d                   	pop    %ebp
  801dc5:	c3                   	ret    

00801dc6 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801dc6:	55                   	push   %ebp
  801dc7:	89 e5                	mov    %esp,%ebp
  801dc9:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dcc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dcf:	50                   	push   %eax
  801dd0:	ff 75 08             	pushl  0x8(%ebp)
  801dd3:	e8 30 f5 ff ff       	call   801308 <fd_lookup>
  801dd8:	83 c4 10             	add    $0x10,%esp
  801ddb:	85 c0                	test   %eax,%eax
  801ddd:	78 18                	js     801df7 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ddf:	83 ec 0c             	sub    $0xc,%esp
  801de2:	ff 75 f4             	pushl  -0xc(%ebp)
  801de5:	e8 b8 f4 ff ff       	call   8012a2 <fd2data>
	return _pipeisclosed(fd, p);
  801dea:	89 c2                	mov    %eax,%edx
  801dec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801def:	e8 21 fd ff ff       	call   801b15 <_pipeisclosed>
  801df4:	83 c4 10             	add    $0x10,%esp
}
  801df7:	c9                   	leave  
  801df8:	c3                   	ret    

00801df9 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801df9:	55                   	push   %ebp
  801dfa:	89 e5                	mov    %esp,%ebp
  801dfc:	56                   	push   %esi
  801dfd:	53                   	push   %ebx
  801dfe:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801e01:	85 f6                	test   %esi,%esi
  801e03:	75 16                	jne    801e1b <wait+0x22>
  801e05:	68 d2 2a 80 00       	push   $0x802ad2
  801e0a:	68 87 2a 80 00       	push   $0x802a87
  801e0f:	6a 09                	push   $0x9
  801e11:	68 dd 2a 80 00       	push   $0x802add
  801e16:	e8 f7 e4 ff ff       	call   800312 <_panic>
	e = &envs[ENVX(envid)];
  801e1b:	89 f3                	mov    %esi,%ebx
  801e1d:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801e23:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  801e26:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  801e2c:	eb 05                	jmp    801e33 <wait+0x3a>
		sys_yield();
  801e2e:	e8 3f ef ff ff       	call   800d72 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801e33:	8b 43 48             	mov    0x48(%ebx),%eax
  801e36:	39 c6                	cmp    %eax,%esi
  801e38:	75 07                	jne    801e41 <wait+0x48>
  801e3a:	8b 43 54             	mov    0x54(%ebx),%eax
  801e3d:	85 c0                	test   %eax,%eax
  801e3f:	75 ed                	jne    801e2e <wait+0x35>
		sys_yield();
}
  801e41:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e44:	5b                   	pop    %ebx
  801e45:	5e                   	pop    %esi
  801e46:	5d                   	pop    %ebp
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
  801e58:	68 e8 2a 80 00       	push   $0x802ae8
  801e5d:	ff 75 0c             	pushl  0xc(%ebp)
  801e60:	e8 29 eb ff ff       	call   80098e <strcpy>
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
  801e9e:	e8 7d ec ff ff       	call   800b20 <memmove>
		sys_cputs(buf, m);
  801ea3:	83 c4 08             	add    $0x8,%esp
  801ea6:	53                   	push   %ebx
  801ea7:	57                   	push   %edi
  801ea8:	e8 28 ee ff ff       	call   800cd5 <sys_cputs>
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
  801ed4:	e8 99 ee ff ff       	call   800d72 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801ed9:	e8 15 ee ff ff       	call   800cf3 <sys_cgetc>
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
  801f10:	e8 c0 ed ff ff       	call   800cd5 <sys_cputs>
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
  801f28:	e8 41 f6 ff ff       	call   80156e <read>
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
  801f52:	e8 b1 f3 ff ff       	call   801308 <fd_lookup>
  801f57:	83 c4 10             	add    $0x10,%esp
  801f5a:	85 c0                	test   %eax,%eax
  801f5c:	78 11                	js     801f6f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f61:	8b 15 40 30 80 00    	mov    0x803040,%edx
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
  801f7b:	e8 39 f3 ff ff       	call   8012b9 <fd_alloc>
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
  801f96:	e8 f6 ed ff ff       	call   800d91 <sys_page_alloc>
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
  801fa4:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801faa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fad:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801faf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fb2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801fb9:	83 ec 0c             	sub    $0xc,%esp
  801fbc:	50                   	push   %eax
  801fbd:	e8 d0 f2 ff ff       	call   801292 <fd2num>
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
  801ff0:	e8 9c ed ff ff       	call   800d91 <sys_page_alloc>
		if (ret < 0) {
  801ff5:	83 c4 10             	add    $0x10,%esp
  801ff8:	85 c0                	test   %eax,%eax
  801ffa:	79 14                	jns    802010 <set_pgfault_handler+0x45>
		    panic("Allocate user exception stack failed!\n");
  801ffc:	83 ec 04             	sub    $0x4,%esp
  801fff:	68 f4 2a 80 00       	push   $0x802af4
  802004:	6a 23                	push   $0x23
  802006:	68 1c 2b 80 00       	push   $0x802b1c
  80200b:	e8 02 e3 ff ff       	call   800312 <_panic>
		}
	}
	sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  802010:	a1 04 40 80 00       	mov    0x804004,%eax
  802015:	8b 40 48             	mov    0x48(%eax),%eax
  802018:	83 ec 08             	sub    $0x8,%esp
  80201b:	68 33 20 80 00       	push   $0x802033
  802020:	50                   	push   %eax
  802021:	e8 b6 ee ff ff       	call   800edc <sys_env_set_pgfault_upcall>
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

00802057 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802057:	55                   	push   %ebp
  802058:	89 e5                	mov    %esp,%ebp
  80205a:	56                   	push   %esi
  80205b:	53                   	push   %ebx
  80205c:	8b 75 08             	mov    0x8(%ebp),%esi
  80205f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802062:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_recv not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  802065:	85 c0                	test   %eax,%eax
  802067:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80206c:	0f 44 c2             	cmove  %edx,%eax

    int r = sys_ipc_recv(pg);
  80206f:	83 ec 0c             	sub    $0xc,%esp
  802072:	50                   	push   %eax
  802073:	e8 c9 ee ff ff       	call   800f41 <sys_ipc_recv>
    int from_env = 0, perm = 0;
    if (r == 0) {
  802078:	83 c4 10             	add    $0x10,%esp
  80207b:	85 c0                	test   %eax,%eax
  80207d:	75 10                	jne    80208f <ipc_recv+0x38>
        from_env = thisenv->env_ipc_from;
  80207f:	a1 04 40 80 00       	mov    0x804004,%eax
  802084:	8b 48 74             	mov    0x74(%eax),%ecx
        perm = thisenv->env_ipc_perm;
  802087:	8b 50 78             	mov    0x78(%eax),%edx
        r = thisenv->env_ipc_value;
  80208a:	8b 40 70             	mov    0x70(%eax),%eax
  80208d:	eb 0a                	jmp    802099 <ipc_recv+0x42>
    } else {
        from_env = 0;
        perm = 0;
  80208f:	ba 00 00 00 00       	mov    $0x0,%edx
    if (r == 0) {
        from_env = thisenv->env_ipc_from;
        perm = thisenv->env_ipc_perm;
        r = thisenv->env_ipc_value;
    } else {
        from_env = 0;
  802094:	b9 00 00 00 00       	mov    $0x0,%ecx
        perm = 0;
    }

    if (from_env_store) *from_env_store = from_env;
  802099:	85 f6                	test   %esi,%esi
  80209b:	74 02                	je     80209f <ipc_recv+0x48>
  80209d:	89 0e                	mov    %ecx,(%esi)
    if (perm_store) *perm_store = perm;
  80209f:	85 db                	test   %ebx,%ebx
  8020a1:	74 02                	je     8020a5 <ipc_recv+0x4e>
  8020a3:	89 13                	mov    %edx,(%ebx)

    return r;
}
  8020a5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020a8:	5b                   	pop    %ebx
  8020a9:	5e                   	pop    %esi
  8020aa:	5d                   	pop    %ebp
  8020ab:	c3                   	ret    

008020ac <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8020ac:	55                   	push   %ebp
  8020ad:	89 e5                	mov    %esp,%ebp
  8020af:	57                   	push   %edi
  8020b0:	56                   	push   %esi
  8020b1:	53                   	push   %ebx
  8020b2:	83 ec 0c             	sub    $0xc,%esp
  8020b5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020b8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8020bb:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  8020be:	85 db                	test   %ebx,%ebx
  8020c0:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8020c5:	0f 44 d8             	cmove  %eax,%ebx
  8020c8:	eb 1c                	jmp    8020e6 <ipc_send+0x3a>

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        if (ret != -E_IPC_NOT_RECV)
  8020ca:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020cd:	74 12                	je     8020e1 <ipc_send+0x35>
            panic("ipc_send error %e", ret);
  8020cf:	50                   	push   %eax
  8020d0:	68 2a 2b 80 00       	push   $0x802b2a
  8020d5:	6a 40                	push   $0x40
  8020d7:	68 3c 2b 80 00       	push   $0x802b3c
  8020dc:	e8 31 e2 ff ff       	call   800312 <_panic>
        sys_yield();
  8020e1:	e8 8c ec ff ff       	call   800d72 <sys_yield>
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  8020e6:	ff 75 14             	pushl  0x14(%ebp)
  8020e9:	53                   	push   %ebx
  8020ea:	56                   	push   %esi
  8020eb:	57                   	push   %edi
  8020ec:	e8 2d ee ff ff       	call   800f1e <sys_ipc_try_send>
  8020f1:	83 c4 10             	add    $0x10,%esp
  8020f4:	85 c0                	test   %eax,%eax
  8020f6:	75 d2                	jne    8020ca <ipc_send+0x1e>
        if (ret != -E_IPC_NOT_RECV)
            panic("ipc_send error %e", ret);
        sys_yield();
    }
}
  8020f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020fb:	5b                   	pop    %ebx
  8020fc:	5e                   	pop    %esi
  8020fd:	5f                   	pop    %edi
  8020fe:	5d                   	pop    %ebp
  8020ff:	c3                   	ret    

00802100 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802100:	55                   	push   %ebp
  802101:	89 e5                	mov    %esp,%ebp
  802103:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802106:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80210b:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80210e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802114:	8b 52 50             	mov    0x50(%edx),%edx
  802117:	39 ca                	cmp    %ecx,%edx
  802119:	75 0d                	jne    802128 <ipc_find_env+0x28>
			return envs[i].env_id;
  80211b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80211e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802123:	8b 40 48             	mov    0x48(%eax),%eax
  802126:	eb 0f                	jmp    802137 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802128:	83 c0 01             	add    $0x1,%eax
  80212b:	3d 00 04 00 00       	cmp    $0x400,%eax
  802130:	75 d9                	jne    80210b <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802132:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802137:	5d                   	pop    %ebp
  802138:	c3                   	ret    

00802139 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802139:	55                   	push   %ebp
  80213a:	89 e5                	mov    %esp,%ebp
  80213c:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80213f:	89 d0                	mov    %edx,%eax
  802141:	c1 e8 16             	shr    $0x16,%eax
  802144:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80214b:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802150:	f6 c1 01             	test   $0x1,%cl
  802153:	74 1d                	je     802172 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802155:	c1 ea 0c             	shr    $0xc,%edx
  802158:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80215f:	f6 c2 01             	test   $0x1,%dl
  802162:	74 0e                	je     802172 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802164:	c1 ea 0c             	shr    $0xc,%edx
  802167:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80216e:	ef 
  80216f:	0f b7 c0             	movzwl %ax,%eax
}
  802172:	5d                   	pop    %ebp
  802173:	c3                   	ret    
  802174:	66 90                	xchg   %ax,%ax
  802176:	66 90                	xchg   %ax,%ax
  802178:	66 90                	xchg   %ax,%ax
  80217a:	66 90                	xchg   %ax,%ax
  80217c:	66 90                	xchg   %ax,%ax
  80217e:	66 90                	xchg   %ax,%ax

00802180 <__udivdi3>:
  802180:	55                   	push   %ebp
  802181:	57                   	push   %edi
  802182:	56                   	push   %esi
  802183:	53                   	push   %ebx
  802184:	83 ec 1c             	sub    $0x1c,%esp
  802187:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80218b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80218f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802193:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802197:	85 f6                	test   %esi,%esi
  802199:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80219d:	89 ca                	mov    %ecx,%edx
  80219f:	89 f8                	mov    %edi,%eax
  8021a1:	75 3d                	jne    8021e0 <__udivdi3+0x60>
  8021a3:	39 cf                	cmp    %ecx,%edi
  8021a5:	0f 87 c5 00 00 00    	ja     802270 <__udivdi3+0xf0>
  8021ab:	85 ff                	test   %edi,%edi
  8021ad:	89 fd                	mov    %edi,%ebp
  8021af:	75 0b                	jne    8021bc <__udivdi3+0x3c>
  8021b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8021b6:	31 d2                	xor    %edx,%edx
  8021b8:	f7 f7                	div    %edi
  8021ba:	89 c5                	mov    %eax,%ebp
  8021bc:	89 c8                	mov    %ecx,%eax
  8021be:	31 d2                	xor    %edx,%edx
  8021c0:	f7 f5                	div    %ebp
  8021c2:	89 c1                	mov    %eax,%ecx
  8021c4:	89 d8                	mov    %ebx,%eax
  8021c6:	89 cf                	mov    %ecx,%edi
  8021c8:	f7 f5                	div    %ebp
  8021ca:	89 c3                	mov    %eax,%ebx
  8021cc:	89 d8                	mov    %ebx,%eax
  8021ce:	89 fa                	mov    %edi,%edx
  8021d0:	83 c4 1c             	add    $0x1c,%esp
  8021d3:	5b                   	pop    %ebx
  8021d4:	5e                   	pop    %esi
  8021d5:	5f                   	pop    %edi
  8021d6:	5d                   	pop    %ebp
  8021d7:	c3                   	ret    
  8021d8:	90                   	nop
  8021d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021e0:	39 ce                	cmp    %ecx,%esi
  8021e2:	77 74                	ja     802258 <__udivdi3+0xd8>
  8021e4:	0f bd fe             	bsr    %esi,%edi
  8021e7:	83 f7 1f             	xor    $0x1f,%edi
  8021ea:	0f 84 98 00 00 00    	je     802288 <__udivdi3+0x108>
  8021f0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8021f5:	89 f9                	mov    %edi,%ecx
  8021f7:	89 c5                	mov    %eax,%ebp
  8021f9:	29 fb                	sub    %edi,%ebx
  8021fb:	d3 e6                	shl    %cl,%esi
  8021fd:	89 d9                	mov    %ebx,%ecx
  8021ff:	d3 ed                	shr    %cl,%ebp
  802201:	89 f9                	mov    %edi,%ecx
  802203:	d3 e0                	shl    %cl,%eax
  802205:	09 ee                	or     %ebp,%esi
  802207:	89 d9                	mov    %ebx,%ecx
  802209:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80220d:	89 d5                	mov    %edx,%ebp
  80220f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802213:	d3 ed                	shr    %cl,%ebp
  802215:	89 f9                	mov    %edi,%ecx
  802217:	d3 e2                	shl    %cl,%edx
  802219:	89 d9                	mov    %ebx,%ecx
  80221b:	d3 e8                	shr    %cl,%eax
  80221d:	09 c2                	or     %eax,%edx
  80221f:	89 d0                	mov    %edx,%eax
  802221:	89 ea                	mov    %ebp,%edx
  802223:	f7 f6                	div    %esi
  802225:	89 d5                	mov    %edx,%ebp
  802227:	89 c3                	mov    %eax,%ebx
  802229:	f7 64 24 0c          	mull   0xc(%esp)
  80222d:	39 d5                	cmp    %edx,%ebp
  80222f:	72 10                	jb     802241 <__udivdi3+0xc1>
  802231:	8b 74 24 08          	mov    0x8(%esp),%esi
  802235:	89 f9                	mov    %edi,%ecx
  802237:	d3 e6                	shl    %cl,%esi
  802239:	39 c6                	cmp    %eax,%esi
  80223b:	73 07                	jae    802244 <__udivdi3+0xc4>
  80223d:	39 d5                	cmp    %edx,%ebp
  80223f:	75 03                	jne    802244 <__udivdi3+0xc4>
  802241:	83 eb 01             	sub    $0x1,%ebx
  802244:	31 ff                	xor    %edi,%edi
  802246:	89 d8                	mov    %ebx,%eax
  802248:	89 fa                	mov    %edi,%edx
  80224a:	83 c4 1c             	add    $0x1c,%esp
  80224d:	5b                   	pop    %ebx
  80224e:	5e                   	pop    %esi
  80224f:	5f                   	pop    %edi
  802250:	5d                   	pop    %ebp
  802251:	c3                   	ret    
  802252:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802258:	31 ff                	xor    %edi,%edi
  80225a:	31 db                	xor    %ebx,%ebx
  80225c:	89 d8                	mov    %ebx,%eax
  80225e:	89 fa                	mov    %edi,%edx
  802260:	83 c4 1c             	add    $0x1c,%esp
  802263:	5b                   	pop    %ebx
  802264:	5e                   	pop    %esi
  802265:	5f                   	pop    %edi
  802266:	5d                   	pop    %ebp
  802267:	c3                   	ret    
  802268:	90                   	nop
  802269:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802270:	89 d8                	mov    %ebx,%eax
  802272:	f7 f7                	div    %edi
  802274:	31 ff                	xor    %edi,%edi
  802276:	89 c3                	mov    %eax,%ebx
  802278:	89 d8                	mov    %ebx,%eax
  80227a:	89 fa                	mov    %edi,%edx
  80227c:	83 c4 1c             	add    $0x1c,%esp
  80227f:	5b                   	pop    %ebx
  802280:	5e                   	pop    %esi
  802281:	5f                   	pop    %edi
  802282:	5d                   	pop    %ebp
  802283:	c3                   	ret    
  802284:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802288:	39 ce                	cmp    %ecx,%esi
  80228a:	72 0c                	jb     802298 <__udivdi3+0x118>
  80228c:	31 db                	xor    %ebx,%ebx
  80228e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802292:	0f 87 34 ff ff ff    	ja     8021cc <__udivdi3+0x4c>
  802298:	bb 01 00 00 00       	mov    $0x1,%ebx
  80229d:	e9 2a ff ff ff       	jmp    8021cc <__udivdi3+0x4c>
  8022a2:	66 90                	xchg   %ax,%ax
  8022a4:	66 90                	xchg   %ax,%ax
  8022a6:	66 90                	xchg   %ax,%ax
  8022a8:	66 90                	xchg   %ax,%ax
  8022aa:	66 90                	xchg   %ax,%ax
  8022ac:	66 90                	xchg   %ax,%ax
  8022ae:	66 90                	xchg   %ax,%ax

008022b0 <__umoddi3>:
  8022b0:	55                   	push   %ebp
  8022b1:	57                   	push   %edi
  8022b2:	56                   	push   %esi
  8022b3:	53                   	push   %ebx
  8022b4:	83 ec 1c             	sub    $0x1c,%esp
  8022b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8022bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8022bf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8022c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022c7:	85 d2                	test   %edx,%edx
  8022c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8022cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022d1:	89 f3                	mov    %esi,%ebx
  8022d3:	89 3c 24             	mov    %edi,(%esp)
  8022d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022da:	75 1c                	jne    8022f8 <__umoddi3+0x48>
  8022dc:	39 f7                	cmp    %esi,%edi
  8022de:	76 50                	jbe    802330 <__umoddi3+0x80>
  8022e0:	89 c8                	mov    %ecx,%eax
  8022e2:	89 f2                	mov    %esi,%edx
  8022e4:	f7 f7                	div    %edi
  8022e6:	89 d0                	mov    %edx,%eax
  8022e8:	31 d2                	xor    %edx,%edx
  8022ea:	83 c4 1c             	add    $0x1c,%esp
  8022ed:	5b                   	pop    %ebx
  8022ee:	5e                   	pop    %esi
  8022ef:	5f                   	pop    %edi
  8022f0:	5d                   	pop    %ebp
  8022f1:	c3                   	ret    
  8022f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022f8:	39 f2                	cmp    %esi,%edx
  8022fa:	89 d0                	mov    %edx,%eax
  8022fc:	77 52                	ja     802350 <__umoddi3+0xa0>
  8022fe:	0f bd ea             	bsr    %edx,%ebp
  802301:	83 f5 1f             	xor    $0x1f,%ebp
  802304:	75 5a                	jne    802360 <__umoddi3+0xb0>
  802306:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80230a:	0f 82 e0 00 00 00    	jb     8023f0 <__umoddi3+0x140>
  802310:	39 0c 24             	cmp    %ecx,(%esp)
  802313:	0f 86 d7 00 00 00    	jbe    8023f0 <__umoddi3+0x140>
  802319:	8b 44 24 08          	mov    0x8(%esp),%eax
  80231d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802321:	83 c4 1c             	add    $0x1c,%esp
  802324:	5b                   	pop    %ebx
  802325:	5e                   	pop    %esi
  802326:	5f                   	pop    %edi
  802327:	5d                   	pop    %ebp
  802328:	c3                   	ret    
  802329:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802330:	85 ff                	test   %edi,%edi
  802332:	89 fd                	mov    %edi,%ebp
  802334:	75 0b                	jne    802341 <__umoddi3+0x91>
  802336:	b8 01 00 00 00       	mov    $0x1,%eax
  80233b:	31 d2                	xor    %edx,%edx
  80233d:	f7 f7                	div    %edi
  80233f:	89 c5                	mov    %eax,%ebp
  802341:	89 f0                	mov    %esi,%eax
  802343:	31 d2                	xor    %edx,%edx
  802345:	f7 f5                	div    %ebp
  802347:	89 c8                	mov    %ecx,%eax
  802349:	f7 f5                	div    %ebp
  80234b:	89 d0                	mov    %edx,%eax
  80234d:	eb 99                	jmp    8022e8 <__umoddi3+0x38>
  80234f:	90                   	nop
  802350:	89 c8                	mov    %ecx,%eax
  802352:	89 f2                	mov    %esi,%edx
  802354:	83 c4 1c             	add    $0x1c,%esp
  802357:	5b                   	pop    %ebx
  802358:	5e                   	pop    %esi
  802359:	5f                   	pop    %edi
  80235a:	5d                   	pop    %ebp
  80235b:	c3                   	ret    
  80235c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802360:	8b 34 24             	mov    (%esp),%esi
  802363:	bf 20 00 00 00       	mov    $0x20,%edi
  802368:	89 e9                	mov    %ebp,%ecx
  80236a:	29 ef                	sub    %ebp,%edi
  80236c:	d3 e0                	shl    %cl,%eax
  80236e:	89 f9                	mov    %edi,%ecx
  802370:	89 f2                	mov    %esi,%edx
  802372:	d3 ea                	shr    %cl,%edx
  802374:	89 e9                	mov    %ebp,%ecx
  802376:	09 c2                	or     %eax,%edx
  802378:	89 d8                	mov    %ebx,%eax
  80237a:	89 14 24             	mov    %edx,(%esp)
  80237d:	89 f2                	mov    %esi,%edx
  80237f:	d3 e2                	shl    %cl,%edx
  802381:	89 f9                	mov    %edi,%ecx
  802383:	89 54 24 04          	mov    %edx,0x4(%esp)
  802387:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80238b:	d3 e8                	shr    %cl,%eax
  80238d:	89 e9                	mov    %ebp,%ecx
  80238f:	89 c6                	mov    %eax,%esi
  802391:	d3 e3                	shl    %cl,%ebx
  802393:	89 f9                	mov    %edi,%ecx
  802395:	89 d0                	mov    %edx,%eax
  802397:	d3 e8                	shr    %cl,%eax
  802399:	89 e9                	mov    %ebp,%ecx
  80239b:	09 d8                	or     %ebx,%eax
  80239d:	89 d3                	mov    %edx,%ebx
  80239f:	89 f2                	mov    %esi,%edx
  8023a1:	f7 34 24             	divl   (%esp)
  8023a4:	89 d6                	mov    %edx,%esi
  8023a6:	d3 e3                	shl    %cl,%ebx
  8023a8:	f7 64 24 04          	mull   0x4(%esp)
  8023ac:	39 d6                	cmp    %edx,%esi
  8023ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023b2:	89 d1                	mov    %edx,%ecx
  8023b4:	89 c3                	mov    %eax,%ebx
  8023b6:	72 08                	jb     8023c0 <__umoddi3+0x110>
  8023b8:	75 11                	jne    8023cb <__umoddi3+0x11b>
  8023ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8023be:	73 0b                	jae    8023cb <__umoddi3+0x11b>
  8023c0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8023c4:	1b 14 24             	sbb    (%esp),%edx
  8023c7:	89 d1                	mov    %edx,%ecx
  8023c9:	89 c3                	mov    %eax,%ebx
  8023cb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8023cf:	29 da                	sub    %ebx,%edx
  8023d1:	19 ce                	sbb    %ecx,%esi
  8023d3:	89 f9                	mov    %edi,%ecx
  8023d5:	89 f0                	mov    %esi,%eax
  8023d7:	d3 e0                	shl    %cl,%eax
  8023d9:	89 e9                	mov    %ebp,%ecx
  8023db:	d3 ea                	shr    %cl,%edx
  8023dd:	89 e9                	mov    %ebp,%ecx
  8023df:	d3 ee                	shr    %cl,%esi
  8023e1:	09 d0                	or     %edx,%eax
  8023e3:	89 f2                	mov    %esi,%edx
  8023e5:	83 c4 1c             	add    $0x1c,%esp
  8023e8:	5b                   	pop    %ebx
  8023e9:	5e                   	pop    %esi
  8023ea:	5f                   	pop    %edi
  8023eb:	5d                   	pop    %ebp
  8023ec:	c3                   	ret    
  8023ed:	8d 76 00             	lea    0x0(%esi),%esi
  8023f0:	29 f9                	sub    %edi,%ecx
  8023f2:	19 d6                	sbb    %edx,%esi
  8023f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023fc:	e9 18 ff ff ff       	jmp    802319 <__umoddi3+0x69>
