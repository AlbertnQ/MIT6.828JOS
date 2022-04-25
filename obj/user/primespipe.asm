
obj/user/primespipe.debug:     file format elf32-i386


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
  80002c:	e8 07 02 00 00       	call   800238 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(int fd)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
  80003c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i, id, p, pfd[2], wfd, r;

	// fetch a prime from our left neighbor
top:
	if ((r = readn(fd, &p, 4)) != 4)
  80003f:	8d 75 e0             	lea    -0x20(%ebp),%esi
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);

	cprintf("%d\n", p);

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  800042:	8d 7d d8             	lea    -0x28(%ebp),%edi
{
	int i, id, p, pfd[2], wfd, r;

	// fetch a prime from our left neighbor
top:
	if ((r = readn(fd, &p, 4)) != 4)
  800045:	83 ec 04             	sub    $0x4,%esp
  800048:	6a 04                	push   $0x4
  80004a:	56                   	push   %esi
  80004b:	53                   	push   %ebx
  80004c:	e8 34 15 00 00       	call   801585 <readn>
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	83 f8 04             	cmp    $0x4,%eax
  800057:	74 20                	je     800079 <primeproc+0x46>
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);
  800059:	83 ec 0c             	sub    $0xc,%esp
  80005c:	85 c0                	test   %eax,%eax
  80005e:	ba 00 00 00 00       	mov    $0x0,%edx
  800063:	0f 4e d0             	cmovle %eax,%edx
  800066:	52                   	push   %edx
  800067:	50                   	push   %eax
  800068:	68 40 23 80 00       	push   $0x802340
  80006d:	6a 15                	push   $0x15
  80006f:	68 6f 23 80 00       	push   $0x80236f
  800074:	e8 1f 02 00 00       	call   800298 <_panic>

	cprintf("%d\n", p);
  800079:	83 ec 08             	sub    $0x8,%esp
  80007c:	ff 75 e0             	pushl  -0x20(%ebp)
  80007f:	68 81 23 80 00       	push   $0x802381
  800084:	e8 e8 02 00 00       	call   800371 <cprintf>

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  800089:	89 3c 24             	mov    %edi,(%esp)
  80008c:	e8 68 1b 00 00       	call   801bf9 <pipe>
  800091:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800094:	83 c4 10             	add    $0x10,%esp
  800097:	85 c0                	test   %eax,%eax
  800099:	79 12                	jns    8000ad <primeproc+0x7a>
		panic("pipe: %e", i);
  80009b:	50                   	push   %eax
  80009c:	68 85 23 80 00       	push   $0x802385
  8000a1:	6a 1b                	push   $0x1b
  8000a3:	68 6f 23 80 00       	push   $0x80236f
  8000a8:	e8 eb 01 00 00       	call   800298 <_panic>
	if ((id = fork()) < 0)
  8000ad:	e8 2a 10 00 00       	call   8010dc <fork>
  8000b2:	85 c0                	test   %eax,%eax
  8000b4:	79 12                	jns    8000c8 <primeproc+0x95>
		panic("fork: %e", id);
  8000b6:	50                   	push   %eax
  8000b7:	68 8e 23 80 00       	push   $0x80238e
  8000bc:	6a 1d                	push   $0x1d
  8000be:	68 6f 23 80 00       	push   $0x80236f
  8000c3:	e8 d0 01 00 00       	call   800298 <_panic>
	if (id == 0) {
  8000c8:	85 c0                	test   %eax,%eax
  8000ca:	75 1f                	jne    8000eb <primeproc+0xb8>
		close(fd);
  8000cc:	83 ec 0c             	sub    $0xc,%esp
  8000cf:	53                   	push   %ebx
  8000d0:	e8 e3 12 00 00       	call   8013b8 <close>
		close(pfd[1]);
  8000d5:	83 c4 04             	add    $0x4,%esp
  8000d8:	ff 75 dc             	pushl  -0x24(%ebp)
  8000db:	e8 d8 12 00 00       	call   8013b8 <close>
		fd = pfd[0];
  8000e0:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		goto top;
  8000e3:	83 c4 10             	add    $0x10,%esp
  8000e6:	e9 5a ff ff ff       	jmp    800045 <primeproc+0x12>
	}

	close(pfd[0]);
  8000eb:	83 ec 0c             	sub    $0xc,%esp
  8000ee:	ff 75 d8             	pushl  -0x28(%ebp)
  8000f1:	e8 c2 12 00 00       	call   8013b8 <close>
	wfd = pfd[1];
  8000f6:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8000f9:	83 c4 10             	add    $0x10,%esp

	// filter out multiples of our prime
	for (;;) {
		if ((r=readn(fd, &i, 4)) != 4)
  8000fc:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  8000ff:	83 ec 04             	sub    $0x4,%esp
  800102:	6a 04                	push   $0x4
  800104:	56                   	push   %esi
  800105:	53                   	push   %ebx
  800106:	e8 7a 14 00 00       	call   801585 <readn>
  80010b:	83 c4 10             	add    $0x10,%esp
  80010e:	83 f8 04             	cmp    $0x4,%eax
  800111:	74 24                	je     800137 <primeproc+0x104>
			panic("primeproc %d readn %d %d %e", p, fd, r, r >= 0 ? 0 : r);
  800113:	83 ec 04             	sub    $0x4,%esp
  800116:	85 c0                	test   %eax,%eax
  800118:	ba 00 00 00 00       	mov    $0x0,%edx
  80011d:	0f 4e d0             	cmovle %eax,%edx
  800120:	52                   	push   %edx
  800121:	50                   	push   %eax
  800122:	53                   	push   %ebx
  800123:	ff 75 e0             	pushl  -0x20(%ebp)
  800126:	68 97 23 80 00       	push   $0x802397
  80012b:	6a 2b                	push   $0x2b
  80012d:	68 6f 23 80 00       	push   $0x80236f
  800132:	e8 61 01 00 00       	call   800298 <_panic>
		if (i%p)
  800137:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80013a:	99                   	cltd   
  80013b:	f7 7d e0             	idivl  -0x20(%ebp)
  80013e:	85 d2                	test   %edx,%edx
  800140:	74 bd                	je     8000ff <primeproc+0xcc>
			if ((r=write(wfd, &i, 4)) != 4)
  800142:	83 ec 04             	sub    $0x4,%esp
  800145:	6a 04                	push   $0x4
  800147:	56                   	push   %esi
  800148:	57                   	push   %edi
  800149:	e8 80 14 00 00       	call   8015ce <write>
  80014e:	83 c4 10             	add    $0x10,%esp
  800151:	83 f8 04             	cmp    $0x4,%eax
  800154:	74 a9                	je     8000ff <primeproc+0xcc>
				panic("primeproc %d write: %d %e", p, r, r >= 0 ? 0 : r);
  800156:	83 ec 08             	sub    $0x8,%esp
  800159:	85 c0                	test   %eax,%eax
  80015b:	ba 00 00 00 00       	mov    $0x0,%edx
  800160:	0f 4e d0             	cmovle %eax,%edx
  800163:	52                   	push   %edx
  800164:	50                   	push   %eax
  800165:	ff 75 e0             	pushl  -0x20(%ebp)
  800168:	68 b3 23 80 00       	push   $0x8023b3
  80016d:	6a 2e                	push   $0x2e
  80016f:	68 6f 23 80 00       	push   $0x80236f
  800174:	e8 1f 01 00 00       	call   800298 <_panic>

00800179 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	53                   	push   %ebx
  80017d:	83 ec 20             	sub    $0x20,%esp
	int i, id, p[2], r;

	binaryname = "primespipe";
  800180:	c7 05 00 30 80 00 cd 	movl   $0x8023cd,0x803000
  800187:	23 80 00 

	if ((i=pipe(p)) < 0)
  80018a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80018d:	50                   	push   %eax
  80018e:	e8 66 1a 00 00       	call   801bf9 <pipe>
  800193:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800196:	83 c4 10             	add    $0x10,%esp
  800199:	85 c0                	test   %eax,%eax
  80019b:	79 12                	jns    8001af <umain+0x36>
		panic("pipe: %e", i);
  80019d:	50                   	push   %eax
  80019e:	68 85 23 80 00       	push   $0x802385
  8001a3:	6a 3a                	push   $0x3a
  8001a5:	68 6f 23 80 00       	push   $0x80236f
  8001aa:	e8 e9 00 00 00       	call   800298 <_panic>

	// fork the first prime process in the chain
	if ((id=fork()) < 0)
  8001af:	e8 28 0f 00 00       	call   8010dc <fork>
  8001b4:	85 c0                	test   %eax,%eax
  8001b6:	79 12                	jns    8001ca <umain+0x51>
		panic("fork: %e", id);
  8001b8:	50                   	push   %eax
  8001b9:	68 8e 23 80 00       	push   $0x80238e
  8001be:	6a 3e                	push   $0x3e
  8001c0:	68 6f 23 80 00       	push   $0x80236f
  8001c5:	e8 ce 00 00 00       	call   800298 <_panic>

	if (id == 0) {
  8001ca:	85 c0                	test   %eax,%eax
  8001cc:	75 16                	jne    8001e4 <umain+0x6b>
		close(p[1]);
  8001ce:	83 ec 0c             	sub    $0xc,%esp
  8001d1:	ff 75 f0             	pushl  -0x10(%ebp)
  8001d4:	e8 df 11 00 00       	call   8013b8 <close>
		primeproc(p[0]);
  8001d9:	83 c4 04             	add    $0x4,%esp
  8001dc:	ff 75 ec             	pushl  -0x14(%ebp)
  8001df:	e8 4f fe ff ff       	call   800033 <primeproc>
	}

	close(p[0]);
  8001e4:	83 ec 0c             	sub    $0xc,%esp
  8001e7:	ff 75 ec             	pushl  -0x14(%ebp)
  8001ea:	e8 c9 11 00 00       	call   8013b8 <close>

	// feed all the integers through
	for (i=2;; i++)
  8001ef:	c7 45 f4 02 00 00 00 	movl   $0x2,-0xc(%ebp)
  8001f6:	83 c4 10             	add    $0x10,%esp
		if ((r=write(p[1], &i, 4)) != 4)
  8001f9:	8d 5d f4             	lea    -0xc(%ebp),%ebx
  8001fc:	83 ec 04             	sub    $0x4,%esp
  8001ff:	6a 04                	push   $0x4
  800201:	53                   	push   %ebx
  800202:	ff 75 f0             	pushl  -0x10(%ebp)
  800205:	e8 c4 13 00 00       	call   8015ce <write>
  80020a:	83 c4 10             	add    $0x10,%esp
  80020d:	83 f8 04             	cmp    $0x4,%eax
  800210:	74 20                	je     800232 <umain+0xb9>
			panic("generator write: %d, %e", r, r >= 0 ? 0 : r);
  800212:	83 ec 0c             	sub    $0xc,%esp
  800215:	85 c0                	test   %eax,%eax
  800217:	ba 00 00 00 00       	mov    $0x0,%edx
  80021c:	0f 4e d0             	cmovle %eax,%edx
  80021f:	52                   	push   %edx
  800220:	50                   	push   %eax
  800221:	68 d8 23 80 00       	push   $0x8023d8
  800226:	6a 4a                	push   $0x4a
  800228:	68 6f 23 80 00       	push   $0x80236f
  80022d:	e8 66 00 00 00       	call   800298 <_panic>
	}

	close(p[0]);

	// feed all the integers through
	for (i=2;; i++)
  800232:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
		if ((r=write(p[1], &i, 4)) != 4)
			panic("generator write: %d, %e", r, r >= 0 ? 0 : r);
}
  800236:	eb c4                	jmp    8001fc <umain+0x83>

00800238 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
  80023b:	56                   	push   %esi
  80023c:	53                   	push   %ebx
  80023d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800240:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  800243:	e8 91 0a 00 00       	call   800cd9 <sys_getenvid>
  800248:	25 ff 03 00 00       	and    $0x3ff,%eax
  80024d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800250:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800255:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80025a:	85 db                	test   %ebx,%ebx
  80025c:	7e 07                	jle    800265 <libmain+0x2d>
		binaryname = argv[0];
  80025e:	8b 06                	mov    (%esi),%eax
  800260:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800265:	83 ec 08             	sub    $0x8,%esp
  800268:	56                   	push   %esi
  800269:	53                   	push   %ebx
  80026a:	e8 0a ff ff ff       	call   800179 <umain>

	// exit gracefully
	exit();
  80026f:	e8 0a 00 00 00       	call   80027e <exit>
}
  800274:	83 c4 10             	add    $0x10,%esp
  800277:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80027a:	5b                   	pop    %ebx
  80027b:	5e                   	pop    %esi
  80027c:	5d                   	pop    %ebp
  80027d:	c3                   	ret    

0080027e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80027e:	55                   	push   %ebp
  80027f:	89 e5                	mov    %esp,%ebp
  800281:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800284:	e8 5a 11 00 00       	call   8013e3 <close_all>
	sys_env_destroy(0);
  800289:	83 ec 0c             	sub    $0xc,%esp
  80028c:	6a 00                	push   $0x0
  80028e:	e8 05 0a 00 00       	call   800c98 <sys_env_destroy>
}
  800293:	83 c4 10             	add    $0x10,%esp
  800296:	c9                   	leave  
  800297:	c3                   	ret    

00800298 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800298:	55                   	push   %ebp
  800299:	89 e5                	mov    %esp,%ebp
  80029b:	56                   	push   %esi
  80029c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80029d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002a0:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8002a6:	e8 2e 0a 00 00       	call   800cd9 <sys_getenvid>
  8002ab:	83 ec 0c             	sub    $0xc,%esp
  8002ae:	ff 75 0c             	pushl  0xc(%ebp)
  8002b1:	ff 75 08             	pushl  0x8(%ebp)
  8002b4:	56                   	push   %esi
  8002b5:	50                   	push   %eax
  8002b6:	68 fc 23 80 00       	push   $0x8023fc
  8002bb:	e8 b1 00 00 00       	call   800371 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002c0:	83 c4 18             	add    $0x18,%esp
  8002c3:	53                   	push   %ebx
  8002c4:	ff 75 10             	pushl  0x10(%ebp)
  8002c7:	e8 54 00 00 00       	call   800320 <vcprintf>
	cprintf("\n");
  8002cc:	c7 04 24 83 23 80 00 	movl   $0x802383,(%esp)
  8002d3:	e8 99 00 00 00       	call   800371 <cprintf>
  8002d8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002db:	cc                   	int3   
  8002dc:	eb fd                	jmp    8002db <_panic+0x43>

008002de <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002de:	55                   	push   %ebp
  8002df:	89 e5                	mov    %esp,%ebp
  8002e1:	53                   	push   %ebx
  8002e2:	83 ec 04             	sub    $0x4,%esp
  8002e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002e8:	8b 13                	mov    (%ebx),%edx
  8002ea:	8d 42 01             	lea    0x1(%edx),%eax
  8002ed:	89 03                	mov    %eax,(%ebx)
  8002ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002f2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002f6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002fb:	75 1a                	jne    800317 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002fd:	83 ec 08             	sub    $0x8,%esp
  800300:	68 ff 00 00 00       	push   $0xff
  800305:	8d 43 08             	lea    0x8(%ebx),%eax
  800308:	50                   	push   %eax
  800309:	e8 4d 09 00 00       	call   800c5b <sys_cputs>
		b->idx = 0;
  80030e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800314:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800317:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80031b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80031e:	c9                   	leave  
  80031f:	c3                   	ret    

00800320 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800329:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800330:	00 00 00 
	b.cnt = 0;
  800333:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80033a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80033d:	ff 75 0c             	pushl  0xc(%ebp)
  800340:	ff 75 08             	pushl  0x8(%ebp)
  800343:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800349:	50                   	push   %eax
  80034a:	68 de 02 80 00       	push   $0x8002de
  80034f:	e8 54 01 00 00       	call   8004a8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800354:	83 c4 08             	add    $0x8,%esp
  800357:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80035d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800363:	50                   	push   %eax
  800364:	e8 f2 08 00 00       	call   800c5b <sys_cputs>

	return b.cnt;
}
  800369:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80036f:	c9                   	leave  
  800370:	c3                   	ret    

00800371 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800371:	55                   	push   %ebp
  800372:	89 e5                	mov    %esp,%ebp
  800374:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800377:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80037a:	50                   	push   %eax
  80037b:	ff 75 08             	pushl  0x8(%ebp)
  80037e:	e8 9d ff ff ff       	call   800320 <vcprintf>
	va_end(ap);

	return cnt;
}
  800383:	c9                   	leave  
  800384:	c3                   	ret    

00800385 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800385:	55                   	push   %ebp
  800386:	89 e5                	mov    %esp,%ebp
  800388:	57                   	push   %edi
  800389:	56                   	push   %esi
  80038a:	53                   	push   %ebx
  80038b:	83 ec 1c             	sub    $0x1c,%esp
  80038e:	89 c7                	mov    %eax,%edi
  800390:	89 d6                	mov    %edx,%esi
  800392:	8b 45 08             	mov    0x8(%ebp),%eax
  800395:	8b 55 0c             	mov    0xc(%ebp),%edx
  800398:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80039b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80039e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8003a1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003a6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8003a9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8003ac:	39 d3                	cmp    %edx,%ebx
  8003ae:	72 05                	jb     8003b5 <printnum+0x30>
  8003b0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003b3:	77 45                	ja     8003fa <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003b5:	83 ec 0c             	sub    $0xc,%esp
  8003b8:	ff 75 18             	pushl  0x18(%ebp)
  8003bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003be:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8003c1:	53                   	push   %ebx
  8003c2:	ff 75 10             	pushl  0x10(%ebp)
  8003c5:	83 ec 08             	sub    $0x8,%esp
  8003c8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003cb:	ff 75 e0             	pushl  -0x20(%ebp)
  8003ce:	ff 75 dc             	pushl  -0x24(%ebp)
  8003d1:	ff 75 d8             	pushl  -0x28(%ebp)
  8003d4:	e8 d7 1c 00 00       	call   8020b0 <__udivdi3>
  8003d9:	83 c4 18             	add    $0x18,%esp
  8003dc:	52                   	push   %edx
  8003dd:	50                   	push   %eax
  8003de:	89 f2                	mov    %esi,%edx
  8003e0:	89 f8                	mov    %edi,%eax
  8003e2:	e8 9e ff ff ff       	call   800385 <printnum>
  8003e7:	83 c4 20             	add    $0x20,%esp
  8003ea:	eb 18                	jmp    800404 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003ec:	83 ec 08             	sub    $0x8,%esp
  8003ef:	56                   	push   %esi
  8003f0:	ff 75 18             	pushl  0x18(%ebp)
  8003f3:	ff d7                	call   *%edi
  8003f5:	83 c4 10             	add    $0x10,%esp
  8003f8:	eb 03                	jmp    8003fd <printnum+0x78>
  8003fa:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003fd:	83 eb 01             	sub    $0x1,%ebx
  800400:	85 db                	test   %ebx,%ebx
  800402:	7f e8                	jg     8003ec <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800404:	83 ec 08             	sub    $0x8,%esp
  800407:	56                   	push   %esi
  800408:	83 ec 04             	sub    $0x4,%esp
  80040b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80040e:	ff 75 e0             	pushl  -0x20(%ebp)
  800411:	ff 75 dc             	pushl  -0x24(%ebp)
  800414:	ff 75 d8             	pushl  -0x28(%ebp)
  800417:	e8 c4 1d 00 00       	call   8021e0 <__umoddi3>
  80041c:	83 c4 14             	add    $0x14,%esp
  80041f:	0f be 80 1f 24 80 00 	movsbl 0x80241f(%eax),%eax
  800426:	50                   	push   %eax
  800427:	ff d7                	call   *%edi
}
  800429:	83 c4 10             	add    $0x10,%esp
  80042c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80042f:	5b                   	pop    %ebx
  800430:	5e                   	pop    %esi
  800431:	5f                   	pop    %edi
  800432:	5d                   	pop    %ebp
  800433:	c3                   	ret    

00800434 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800434:	55                   	push   %ebp
  800435:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800437:	83 fa 01             	cmp    $0x1,%edx
  80043a:	7e 0e                	jle    80044a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80043c:	8b 10                	mov    (%eax),%edx
  80043e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800441:	89 08                	mov    %ecx,(%eax)
  800443:	8b 02                	mov    (%edx),%eax
  800445:	8b 52 04             	mov    0x4(%edx),%edx
  800448:	eb 22                	jmp    80046c <getuint+0x38>
	else if (lflag)
  80044a:	85 d2                	test   %edx,%edx
  80044c:	74 10                	je     80045e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80044e:	8b 10                	mov    (%eax),%edx
  800450:	8d 4a 04             	lea    0x4(%edx),%ecx
  800453:	89 08                	mov    %ecx,(%eax)
  800455:	8b 02                	mov    (%edx),%eax
  800457:	ba 00 00 00 00       	mov    $0x0,%edx
  80045c:	eb 0e                	jmp    80046c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80045e:	8b 10                	mov    (%eax),%edx
  800460:	8d 4a 04             	lea    0x4(%edx),%ecx
  800463:	89 08                	mov    %ecx,(%eax)
  800465:	8b 02                	mov    (%edx),%eax
  800467:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80046c:	5d                   	pop    %ebp
  80046d:	c3                   	ret    

0080046e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80046e:	55                   	push   %ebp
  80046f:	89 e5                	mov    %esp,%ebp
  800471:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800474:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800478:	8b 10                	mov    (%eax),%edx
  80047a:	3b 50 04             	cmp    0x4(%eax),%edx
  80047d:	73 0a                	jae    800489 <sprintputch+0x1b>
		*b->buf++ = ch;
  80047f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800482:	89 08                	mov    %ecx,(%eax)
  800484:	8b 45 08             	mov    0x8(%ebp),%eax
  800487:	88 02                	mov    %al,(%edx)
}
  800489:	5d                   	pop    %ebp
  80048a:	c3                   	ret    

0080048b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80048b:	55                   	push   %ebp
  80048c:	89 e5                	mov    %esp,%ebp
  80048e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800491:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800494:	50                   	push   %eax
  800495:	ff 75 10             	pushl  0x10(%ebp)
  800498:	ff 75 0c             	pushl  0xc(%ebp)
  80049b:	ff 75 08             	pushl  0x8(%ebp)
  80049e:	e8 05 00 00 00       	call   8004a8 <vprintfmt>
	va_end(ap);
}
  8004a3:	83 c4 10             	add    $0x10,%esp
  8004a6:	c9                   	leave  
  8004a7:	c3                   	ret    

008004a8 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004a8:	55                   	push   %ebp
  8004a9:	89 e5                	mov    %esp,%ebp
  8004ab:	57                   	push   %edi
  8004ac:	56                   	push   %esi
  8004ad:	53                   	push   %ebx
  8004ae:	83 ec 2c             	sub    $0x2c,%esp
  8004b1:	8b 75 08             	mov    0x8(%ebp),%esi
  8004b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004b7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004ba:	eb 12                	jmp    8004ce <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004bc:	85 c0                	test   %eax,%eax
  8004be:	0f 84 a7 03 00 00    	je     80086b <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
  8004c4:	83 ec 08             	sub    $0x8,%esp
  8004c7:	53                   	push   %ebx
  8004c8:	50                   	push   %eax
  8004c9:	ff d6                	call   *%esi
  8004cb:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004ce:	83 c7 01             	add    $0x1,%edi
  8004d1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004d5:	83 f8 25             	cmp    $0x25,%eax
  8004d8:	75 e2                	jne    8004bc <vprintfmt+0x14>
  8004da:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8004de:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004e5:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8004ec:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8004f3:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8004fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004ff:	eb 07                	jmp    800508 <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800501:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800504:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800508:	8d 47 01             	lea    0x1(%edi),%eax
  80050b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80050e:	0f b6 07             	movzbl (%edi),%eax
  800511:	0f b6 d0             	movzbl %al,%edx
  800514:	83 e8 23             	sub    $0x23,%eax
  800517:	3c 55                	cmp    $0x55,%al
  800519:	0f 87 31 03 00 00    	ja     800850 <vprintfmt+0x3a8>
  80051f:	0f b6 c0             	movzbl %al,%eax
  800522:	ff 24 85 60 25 80 00 	jmp    *0x802560(,%eax,4)
  800529:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80052c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800530:	eb d6                	jmp    800508 <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800532:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800535:	b8 00 00 00 00       	mov    $0x0,%eax
  80053a:	89 75 08             	mov    %esi,0x8(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80053d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800540:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800544:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800547:	8d 72 d0             	lea    -0x30(%edx),%esi
  80054a:	83 fe 09             	cmp    $0x9,%esi
  80054d:	77 34                	ja     800583 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80054f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800552:	eb e9                	jmp    80053d <vprintfmt+0x95>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800554:	8b 45 14             	mov    0x14(%ebp),%eax
  800557:	8d 50 04             	lea    0x4(%eax),%edx
  80055a:	89 55 14             	mov    %edx,0x14(%ebp)
  80055d:	8b 00                	mov    (%eax),%eax
  80055f:	89 45 cc             	mov    %eax,-0x34(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800562:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800565:	eb 22                	jmp    800589 <vprintfmt+0xe1>
  800567:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80056a:	85 c0                	test   %eax,%eax
  80056c:	0f 48 c1             	cmovs  %ecx,%eax
  80056f:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800572:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800575:	eb 91                	jmp    800508 <vprintfmt+0x60>
  800577:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80057a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800581:	eb 85                	jmp    800508 <vprintfmt+0x60>
  800583:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800586:	8b 75 08             	mov    0x8(%ebp),%esi

		process_precision:
			if (width < 0)
  800589:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80058d:	0f 89 75 ff ff ff    	jns    800508 <vprintfmt+0x60>
				width = precision, precision = -1;
  800593:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800596:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800599:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8005a0:	e9 63 ff ff ff       	jmp    800508 <vprintfmt+0x60>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005a5:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005ac:	e9 57 ff ff ff       	jmp    800508 <vprintfmt+0x60>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b4:	8d 50 04             	lea    0x4(%eax),%edx
  8005b7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ba:	83 ec 08             	sub    $0x8,%esp
  8005bd:	53                   	push   %ebx
  8005be:	ff 30                	pushl  (%eax)
  8005c0:	ff d6                	call   *%esi
			break;
  8005c2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005c8:	e9 01 ff ff ff       	jmp    8004ce <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d0:	8d 50 04             	lea    0x4(%eax),%edx
  8005d3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d6:	8b 00                	mov    (%eax),%eax
  8005d8:	99                   	cltd   
  8005d9:	31 d0                	xor    %edx,%eax
  8005db:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005dd:	83 f8 0f             	cmp    $0xf,%eax
  8005e0:	7f 0b                	jg     8005ed <vprintfmt+0x145>
  8005e2:	8b 14 85 c0 26 80 00 	mov    0x8026c0(,%eax,4),%edx
  8005e9:	85 d2                	test   %edx,%edx
  8005eb:	75 18                	jne    800605 <vprintfmt+0x15d>
				printfmt(putch, putdat, "error %d", err);
  8005ed:	50                   	push   %eax
  8005ee:	68 37 24 80 00       	push   $0x802437
  8005f3:	53                   	push   %ebx
  8005f4:	56                   	push   %esi
  8005f5:	e8 91 fe ff ff       	call   80048b <printfmt>
  8005fa:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800600:	e9 c9 fe ff ff       	jmp    8004ce <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800605:	52                   	push   %edx
  800606:	68 19 29 80 00       	push   $0x802919
  80060b:	53                   	push   %ebx
  80060c:	56                   	push   %esi
  80060d:	e8 79 fe ff ff       	call   80048b <printfmt>
  800612:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800615:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800618:	e9 b1 fe ff ff       	jmp    8004ce <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80061d:	8b 45 14             	mov    0x14(%ebp),%eax
  800620:	8d 50 04             	lea    0x4(%eax),%edx
  800623:	89 55 14             	mov    %edx,0x14(%ebp)
  800626:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800628:	85 ff                	test   %edi,%edi
  80062a:	b8 30 24 80 00       	mov    $0x802430,%eax
  80062f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800632:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800636:	0f 8e 94 00 00 00    	jle    8006d0 <vprintfmt+0x228>
  80063c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800640:	0f 84 98 00 00 00    	je     8006de <vprintfmt+0x236>
				for (width -= strnlen(p, precision); width > 0; width--)
  800646:	83 ec 08             	sub    $0x8,%esp
  800649:	ff 75 cc             	pushl  -0x34(%ebp)
  80064c:	57                   	push   %edi
  80064d:	e8 a1 02 00 00       	call   8008f3 <strnlen>
  800652:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800655:	29 c1                	sub    %eax,%ecx
  800657:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80065a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80065d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800661:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800664:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800667:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800669:	eb 0f                	jmp    80067a <vprintfmt+0x1d2>
					putch(padc, putdat);
  80066b:	83 ec 08             	sub    $0x8,%esp
  80066e:	53                   	push   %ebx
  80066f:	ff 75 e0             	pushl  -0x20(%ebp)
  800672:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800674:	83 ef 01             	sub    $0x1,%edi
  800677:	83 c4 10             	add    $0x10,%esp
  80067a:	85 ff                	test   %edi,%edi
  80067c:	7f ed                	jg     80066b <vprintfmt+0x1c3>
  80067e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800681:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800684:	85 c9                	test   %ecx,%ecx
  800686:	b8 00 00 00 00       	mov    $0x0,%eax
  80068b:	0f 49 c1             	cmovns %ecx,%eax
  80068e:	29 c1                	sub    %eax,%ecx
  800690:	89 75 08             	mov    %esi,0x8(%ebp)
  800693:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800696:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800699:	89 cb                	mov    %ecx,%ebx
  80069b:	eb 4d                	jmp    8006ea <vprintfmt+0x242>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80069d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006a1:	74 1b                	je     8006be <vprintfmt+0x216>
  8006a3:	0f be c0             	movsbl %al,%eax
  8006a6:	83 e8 20             	sub    $0x20,%eax
  8006a9:	83 f8 5e             	cmp    $0x5e,%eax
  8006ac:	76 10                	jbe    8006be <vprintfmt+0x216>
					putch('?', putdat);
  8006ae:	83 ec 08             	sub    $0x8,%esp
  8006b1:	ff 75 0c             	pushl  0xc(%ebp)
  8006b4:	6a 3f                	push   $0x3f
  8006b6:	ff 55 08             	call   *0x8(%ebp)
  8006b9:	83 c4 10             	add    $0x10,%esp
  8006bc:	eb 0d                	jmp    8006cb <vprintfmt+0x223>
				else
					putch(ch, putdat);
  8006be:	83 ec 08             	sub    $0x8,%esp
  8006c1:	ff 75 0c             	pushl  0xc(%ebp)
  8006c4:	52                   	push   %edx
  8006c5:	ff 55 08             	call   *0x8(%ebp)
  8006c8:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006cb:	83 eb 01             	sub    $0x1,%ebx
  8006ce:	eb 1a                	jmp    8006ea <vprintfmt+0x242>
  8006d0:	89 75 08             	mov    %esi,0x8(%ebp)
  8006d3:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8006d6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006d9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006dc:	eb 0c                	jmp    8006ea <vprintfmt+0x242>
  8006de:	89 75 08             	mov    %esi,0x8(%ebp)
  8006e1:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8006e4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006e7:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006ea:	83 c7 01             	add    $0x1,%edi
  8006ed:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006f1:	0f be d0             	movsbl %al,%edx
  8006f4:	85 d2                	test   %edx,%edx
  8006f6:	74 23                	je     80071b <vprintfmt+0x273>
  8006f8:	85 f6                	test   %esi,%esi
  8006fa:	78 a1                	js     80069d <vprintfmt+0x1f5>
  8006fc:	83 ee 01             	sub    $0x1,%esi
  8006ff:	79 9c                	jns    80069d <vprintfmt+0x1f5>
  800701:	89 df                	mov    %ebx,%edi
  800703:	8b 75 08             	mov    0x8(%ebp),%esi
  800706:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800709:	eb 18                	jmp    800723 <vprintfmt+0x27b>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80070b:	83 ec 08             	sub    $0x8,%esp
  80070e:	53                   	push   %ebx
  80070f:	6a 20                	push   $0x20
  800711:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800713:	83 ef 01             	sub    $0x1,%edi
  800716:	83 c4 10             	add    $0x10,%esp
  800719:	eb 08                	jmp    800723 <vprintfmt+0x27b>
  80071b:	89 df                	mov    %ebx,%edi
  80071d:	8b 75 08             	mov    0x8(%ebp),%esi
  800720:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800723:	85 ff                	test   %edi,%edi
  800725:	7f e4                	jg     80070b <vprintfmt+0x263>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800727:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80072a:	e9 9f fd ff ff       	jmp    8004ce <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80072f:	83 7d d0 01          	cmpl   $0x1,-0x30(%ebp)
  800733:	7e 16                	jle    80074b <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  800735:	8b 45 14             	mov    0x14(%ebp),%eax
  800738:	8d 50 08             	lea    0x8(%eax),%edx
  80073b:	89 55 14             	mov    %edx,0x14(%ebp)
  80073e:	8b 50 04             	mov    0x4(%eax),%edx
  800741:	8b 00                	mov    (%eax),%eax
  800743:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800746:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800749:	eb 34                	jmp    80077f <vprintfmt+0x2d7>
	else if (lflag)
  80074b:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80074f:	74 18                	je     800769 <vprintfmt+0x2c1>
		return va_arg(*ap, long);
  800751:	8b 45 14             	mov    0x14(%ebp),%eax
  800754:	8d 50 04             	lea    0x4(%eax),%edx
  800757:	89 55 14             	mov    %edx,0x14(%ebp)
  80075a:	8b 00                	mov    (%eax),%eax
  80075c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80075f:	89 c1                	mov    %eax,%ecx
  800761:	c1 f9 1f             	sar    $0x1f,%ecx
  800764:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800767:	eb 16                	jmp    80077f <vprintfmt+0x2d7>
	else
		return va_arg(*ap, int);
  800769:	8b 45 14             	mov    0x14(%ebp),%eax
  80076c:	8d 50 04             	lea    0x4(%eax),%edx
  80076f:	89 55 14             	mov    %edx,0x14(%ebp)
  800772:	8b 00                	mov    (%eax),%eax
  800774:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800777:	89 c1                	mov    %eax,%ecx
  800779:	c1 f9 1f             	sar    $0x1f,%ecx
  80077c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80077f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800782:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800785:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80078a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80078e:	0f 89 88 00 00 00    	jns    80081c <vprintfmt+0x374>
				putch('-', putdat);
  800794:	83 ec 08             	sub    $0x8,%esp
  800797:	53                   	push   %ebx
  800798:	6a 2d                	push   $0x2d
  80079a:	ff d6                	call   *%esi
				num = -(long long) num;
  80079c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80079f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8007a2:	f7 d8                	neg    %eax
  8007a4:	83 d2 00             	adc    $0x0,%edx
  8007a7:	f7 da                	neg    %edx
  8007a9:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8007ac:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007b1:	eb 69                	jmp    80081c <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007b3:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8007b6:	8d 45 14             	lea    0x14(%ebp),%eax
  8007b9:	e8 76 fc ff ff       	call   800434 <getuint>
			base = 10;
  8007be:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8007c3:	eb 57                	jmp    80081c <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  8007c5:	83 ec 08             	sub    $0x8,%esp
  8007c8:	53                   	push   %ebx
  8007c9:	6a 30                	push   $0x30
  8007cb:	ff d6                	call   *%esi
			num = getuint(&ap, lflag);
  8007cd:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8007d0:	8d 45 14             	lea    0x14(%ebp),%eax
  8007d3:	e8 5c fc ff ff       	call   800434 <getuint>
			base = 8;
			goto number;
  8007d8:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  8007db:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8007e0:	eb 3a                	jmp    80081c <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  8007e2:	83 ec 08             	sub    $0x8,%esp
  8007e5:	53                   	push   %ebx
  8007e6:	6a 30                	push   $0x30
  8007e8:	ff d6                	call   *%esi
			putch('x', putdat);
  8007ea:	83 c4 08             	add    $0x8,%esp
  8007ed:	53                   	push   %ebx
  8007ee:	6a 78                	push   $0x78
  8007f0:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f5:	8d 50 04             	lea    0x4(%eax),%edx
  8007f8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007fb:	8b 00                	mov    (%eax),%eax
  8007fd:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800802:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800805:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80080a:	eb 10                	jmp    80081c <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80080c:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80080f:	8d 45 14             	lea    0x14(%ebp),%eax
  800812:	e8 1d fc ff ff       	call   800434 <getuint>
			base = 16;
  800817:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80081c:	83 ec 0c             	sub    $0xc,%esp
  80081f:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800823:	57                   	push   %edi
  800824:	ff 75 e0             	pushl  -0x20(%ebp)
  800827:	51                   	push   %ecx
  800828:	52                   	push   %edx
  800829:	50                   	push   %eax
  80082a:	89 da                	mov    %ebx,%edx
  80082c:	89 f0                	mov    %esi,%eax
  80082e:	e8 52 fb ff ff       	call   800385 <printnum>
			break;
  800833:	83 c4 20             	add    $0x20,%esp
  800836:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800839:	e9 90 fc ff ff       	jmp    8004ce <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80083e:	83 ec 08             	sub    $0x8,%esp
  800841:	53                   	push   %ebx
  800842:	52                   	push   %edx
  800843:	ff d6                	call   *%esi
			break;
  800845:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800848:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80084b:	e9 7e fc ff ff       	jmp    8004ce <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800850:	83 ec 08             	sub    $0x8,%esp
  800853:	53                   	push   %ebx
  800854:	6a 25                	push   $0x25
  800856:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800858:	83 c4 10             	add    $0x10,%esp
  80085b:	eb 03                	jmp    800860 <vprintfmt+0x3b8>
  80085d:	83 ef 01             	sub    $0x1,%edi
  800860:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800864:	75 f7                	jne    80085d <vprintfmt+0x3b5>
  800866:	e9 63 fc ff ff       	jmp    8004ce <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80086b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80086e:	5b                   	pop    %ebx
  80086f:	5e                   	pop    %esi
  800870:	5f                   	pop    %edi
  800871:	5d                   	pop    %ebp
  800872:	c3                   	ret    

00800873 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800873:	55                   	push   %ebp
  800874:	89 e5                	mov    %esp,%ebp
  800876:	83 ec 18             	sub    $0x18,%esp
  800879:	8b 45 08             	mov    0x8(%ebp),%eax
  80087c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80087f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800882:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800886:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800889:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800890:	85 c0                	test   %eax,%eax
  800892:	74 26                	je     8008ba <vsnprintf+0x47>
  800894:	85 d2                	test   %edx,%edx
  800896:	7e 22                	jle    8008ba <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800898:	ff 75 14             	pushl  0x14(%ebp)
  80089b:	ff 75 10             	pushl  0x10(%ebp)
  80089e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008a1:	50                   	push   %eax
  8008a2:	68 6e 04 80 00       	push   $0x80046e
  8008a7:	e8 fc fb ff ff       	call   8004a8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008af:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008b5:	83 c4 10             	add    $0x10,%esp
  8008b8:	eb 05                	jmp    8008bf <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008ba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008bf:	c9                   	leave  
  8008c0:	c3                   	ret    

008008c1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008c1:	55                   	push   %ebp
  8008c2:	89 e5                	mov    %esp,%ebp
  8008c4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008c7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008ca:	50                   	push   %eax
  8008cb:	ff 75 10             	pushl  0x10(%ebp)
  8008ce:	ff 75 0c             	pushl  0xc(%ebp)
  8008d1:	ff 75 08             	pushl  0x8(%ebp)
  8008d4:	e8 9a ff ff ff       	call   800873 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008d9:	c9                   	leave  
  8008da:	c3                   	ret    

008008db <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8008e6:	eb 03                	jmp    8008eb <strlen+0x10>
		n++;
  8008e8:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008eb:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008ef:	75 f7                	jne    8008e8 <strlen+0xd>
		n++;
	return n;
}
  8008f1:	5d                   	pop    %ebp
  8008f2:	c3                   	ret    

008008f3 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008f3:	55                   	push   %ebp
  8008f4:	89 e5                	mov    %esp,%ebp
  8008f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008f9:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008fc:	ba 00 00 00 00       	mov    $0x0,%edx
  800901:	eb 03                	jmp    800906 <strnlen+0x13>
		n++;
  800903:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800906:	39 c2                	cmp    %eax,%edx
  800908:	74 08                	je     800912 <strnlen+0x1f>
  80090a:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80090e:	75 f3                	jne    800903 <strnlen+0x10>
  800910:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800912:	5d                   	pop    %ebp
  800913:	c3                   	ret    

00800914 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800914:	55                   	push   %ebp
  800915:	89 e5                	mov    %esp,%ebp
  800917:	53                   	push   %ebx
  800918:	8b 45 08             	mov    0x8(%ebp),%eax
  80091b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80091e:	89 c2                	mov    %eax,%edx
  800920:	83 c2 01             	add    $0x1,%edx
  800923:	83 c1 01             	add    $0x1,%ecx
  800926:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80092a:	88 5a ff             	mov    %bl,-0x1(%edx)
  80092d:	84 db                	test   %bl,%bl
  80092f:	75 ef                	jne    800920 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800931:	5b                   	pop    %ebx
  800932:	5d                   	pop    %ebp
  800933:	c3                   	ret    

00800934 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800934:	55                   	push   %ebp
  800935:	89 e5                	mov    %esp,%ebp
  800937:	53                   	push   %ebx
  800938:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80093b:	53                   	push   %ebx
  80093c:	e8 9a ff ff ff       	call   8008db <strlen>
  800941:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800944:	ff 75 0c             	pushl  0xc(%ebp)
  800947:	01 d8                	add    %ebx,%eax
  800949:	50                   	push   %eax
  80094a:	e8 c5 ff ff ff       	call   800914 <strcpy>
	return dst;
}
  80094f:	89 d8                	mov    %ebx,%eax
  800951:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800954:	c9                   	leave  
  800955:	c3                   	ret    

00800956 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800956:	55                   	push   %ebp
  800957:	89 e5                	mov    %esp,%ebp
  800959:	56                   	push   %esi
  80095a:	53                   	push   %ebx
  80095b:	8b 75 08             	mov    0x8(%ebp),%esi
  80095e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800961:	89 f3                	mov    %esi,%ebx
  800963:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800966:	89 f2                	mov    %esi,%edx
  800968:	eb 0f                	jmp    800979 <strncpy+0x23>
		*dst++ = *src;
  80096a:	83 c2 01             	add    $0x1,%edx
  80096d:	0f b6 01             	movzbl (%ecx),%eax
  800970:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800973:	80 39 01             	cmpb   $0x1,(%ecx)
  800976:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800979:	39 da                	cmp    %ebx,%edx
  80097b:	75 ed                	jne    80096a <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80097d:	89 f0                	mov    %esi,%eax
  80097f:	5b                   	pop    %ebx
  800980:	5e                   	pop    %esi
  800981:	5d                   	pop    %ebp
  800982:	c3                   	ret    

00800983 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800983:	55                   	push   %ebp
  800984:	89 e5                	mov    %esp,%ebp
  800986:	56                   	push   %esi
  800987:	53                   	push   %ebx
  800988:	8b 75 08             	mov    0x8(%ebp),%esi
  80098b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80098e:	8b 55 10             	mov    0x10(%ebp),%edx
  800991:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800993:	85 d2                	test   %edx,%edx
  800995:	74 21                	je     8009b8 <strlcpy+0x35>
  800997:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80099b:	89 f2                	mov    %esi,%edx
  80099d:	eb 09                	jmp    8009a8 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80099f:	83 c2 01             	add    $0x1,%edx
  8009a2:	83 c1 01             	add    $0x1,%ecx
  8009a5:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009a8:	39 c2                	cmp    %eax,%edx
  8009aa:	74 09                	je     8009b5 <strlcpy+0x32>
  8009ac:	0f b6 19             	movzbl (%ecx),%ebx
  8009af:	84 db                	test   %bl,%bl
  8009b1:	75 ec                	jne    80099f <strlcpy+0x1c>
  8009b3:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009b5:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009b8:	29 f0                	sub    %esi,%eax
}
  8009ba:	5b                   	pop    %ebx
  8009bb:	5e                   	pop    %esi
  8009bc:	5d                   	pop    %ebp
  8009bd:	c3                   	ret    

008009be <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009be:	55                   	push   %ebp
  8009bf:	89 e5                	mov    %esp,%ebp
  8009c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009c4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009c7:	eb 06                	jmp    8009cf <strcmp+0x11>
		p++, q++;
  8009c9:	83 c1 01             	add    $0x1,%ecx
  8009cc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009cf:	0f b6 01             	movzbl (%ecx),%eax
  8009d2:	84 c0                	test   %al,%al
  8009d4:	74 04                	je     8009da <strcmp+0x1c>
  8009d6:	3a 02                	cmp    (%edx),%al
  8009d8:	74 ef                	je     8009c9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009da:	0f b6 c0             	movzbl %al,%eax
  8009dd:	0f b6 12             	movzbl (%edx),%edx
  8009e0:	29 d0                	sub    %edx,%eax
}
  8009e2:	5d                   	pop    %ebp
  8009e3:	c3                   	ret    

008009e4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009e4:	55                   	push   %ebp
  8009e5:	89 e5                	mov    %esp,%ebp
  8009e7:	53                   	push   %ebx
  8009e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ee:	89 c3                	mov    %eax,%ebx
  8009f0:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009f3:	eb 06                	jmp    8009fb <strncmp+0x17>
		n--, p++, q++;
  8009f5:	83 c0 01             	add    $0x1,%eax
  8009f8:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009fb:	39 d8                	cmp    %ebx,%eax
  8009fd:	74 15                	je     800a14 <strncmp+0x30>
  8009ff:	0f b6 08             	movzbl (%eax),%ecx
  800a02:	84 c9                	test   %cl,%cl
  800a04:	74 04                	je     800a0a <strncmp+0x26>
  800a06:	3a 0a                	cmp    (%edx),%cl
  800a08:	74 eb                	je     8009f5 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a0a:	0f b6 00             	movzbl (%eax),%eax
  800a0d:	0f b6 12             	movzbl (%edx),%edx
  800a10:	29 d0                	sub    %edx,%eax
  800a12:	eb 05                	jmp    800a19 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a14:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a19:	5b                   	pop    %ebx
  800a1a:	5d                   	pop    %ebp
  800a1b:	c3                   	ret    

00800a1c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a1c:	55                   	push   %ebp
  800a1d:	89 e5                	mov    %esp,%ebp
  800a1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a22:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a26:	eb 07                	jmp    800a2f <strchr+0x13>
		if (*s == c)
  800a28:	38 ca                	cmp    %cl,%dl
  800a2a:	74 0f                	je     800a3b <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a2c:	83 c0 01             	add    $0x1,%eax
  800a2f:	0f b6 10             	movzbl (%eax),%edx
  800a32:	84 d2                	test   %dl,%dl
  800a34:	75 f2                	jne    800a28 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a36:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a3b:	5d                   	pop    %ebp
  800a3c:	c3                   	ret    

00800a3d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a3d:	55                   	push   %ebp
  800a3e:	89 e5                	mov    %esp,%ebp
  800a40:	8b 45 08             	mov    0x8(%ebp),%eax
  800a43:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a47:	eb 03                	jmp    800a4c <strfind+0xf>
  800a49:	83 c0 01             	add    $0x1,%eax
  800a4c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a4f:	38 ca                	cmp    %cl,%dl
  800a51:	74 04                	je     800a57 <strfind+0x1a>
  800a53:	84 d2                	test   %dl,%dl
  800a55:	75 f2                	jne    800a49 <strfind+0xc>
			break;
	return (char *) s;
}
  800a57:	5d                   	pop    %ebp
  800a58:	c3                   	ret    

00800a59 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a59:	55                   	push   %ebp
  800a5a:	89 e5                	mov    %esp,%ebp
  800a5c:	57                   	push   %edi
  800a5d:	56                   	push   %esi
  800a5e:	53                   	push   %ebx
  800a5f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a62:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a65:	85 c9                	test   %ecx,%ecx
  800a67:	74 36                	je     800a9f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a69:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a6f:	75 28                	jne    800a99 <memset+0x40>
  800a71:	f6 c1 03             	test   $0x3,%cl
  800a74:	75 23                	jne    800a99 <memset+0x40>
		c &= 0xFF;
  800a76:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a7a:	89 d3                	mov    %edx,%ebx
  800a7c:	c1 e3 08             	shl    $0x8,%ebx
  800a7f:	89 d6                	mov    %edx,%esi
  800a81:	c1 e6 18             	shl    $0x18,%esi
  800a84:	89 d0                	mov    %edx,%eax
  800a86:	c1 e0 10             	shl    $0x10,%eax
  800a89:	09 f0                	or     %esi,%eax
  800a8b:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a8d:	89 d8                	mov    %ebx,%eax
  800a8f:	09 d0                	or     %edx,%eax
  800a91:	c1 e9 02             	shr    $0x2,%ecx
  800a94:	fc                   	cld    
  800a95:	f3 ab                	rep stos %eax,%es:(%edi)
  800a97:	eb 06                	jmp    800a9f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a99:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a9c:	fc                   	cld    
  800a9d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a9f:	89 f8                	mov    %edi,%eax
  800aa1:	5b                   	pop    %ebx
  800aa2:	5e                   	pop    %esi
  800aa3:	5f                   	pop    %edi
  800aa4:	5d                   	pop    %ebp
  800aa5:	c3                   	ret    

00800aa6 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800aa6:	55                   	push   %ebp
  800aa7:	89 e5                	mov    %esp,%ebp
  800aa9:	57                   	push   %edi
  800aaa:	56                   	push   %esi
  800aab:	8b 45 08             	mov    0x8(%ebp),%eax
  800aae:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ab1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ab4:	39 c6                	cmp    %eax,%esi
  800ab6:	73 35                	jae    800aed <memmove+0x47>
  800ab8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800abb:	39 d0                	cmp    %edx,%eax
  800abd:	73 2e                	jae    800aed <memmove+0x47>
		s += n;
		d += n;
  800abf:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ac2:	89 d6                	mov    %edx,%esi
  800ac4:	09 fe                	or     %edi,%esi
  800ac6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800acc:	75 13                	jne    800ae1 <memmove+0x3b>
  800ace:	f6 c1 03             	test   $0x3,%cl
  800ad1:	75 0e                	jne    800ae1 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800ad3:	83 ef 04             	sub    $0x4,%edi
  800ad6:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ad9:	c1 e9 02             	shr    $0x2,%ecx
  800adc:	fd                   	std    
  800add:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800adf:	eb 09                	jmp    800aea <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ae1:	83 ef 01             	sub    $0x1,%edi
  800ae4:	8d 72 ff             	lea    -0x1(%edx),%esi
  800ae7:	fd                   	std    
  800ae8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aea:	fc                   	cld    
  800aeb:	eb 1d                	jmp    800b0a <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aed:	89 f2                	mov    %esi,%edx
  800aef:	09 c2                	or     %eax,%edx
  800af1:	f6 c2 03             	test   $0x3,%dl
  800af4:	75 0f                	jne    800b05 <memmove+0x5f>
  800af6:	f6 c1 03             	test   $0x3,%cl
  800af9:	75 0a                	jne    800b05 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800afb:	c1 e9 02             	shr    $0x2,%ecx
  800afe:	89 c7                	mov    %eax,%edi
  800b00:	fc                   	cld    
  800b01:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b03:	eb 05                	jmp    800b0a <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b05:	89 c7                	mov    %eax,%edi
  800b07:	fc                   	cld    
  800b08:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b0a:	5e                   	pop    %esi
  800b0b:	5f                   	pop    %edi
  800b0c:	5d                   	pop    %ebp
  800b0d:	c3                   	ret    

00800b0e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b0e:	55                   	push   %ebp
  800b0f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b11:	ff 75 10             	pushl  0x10(%ebp)
  800b14:	ff 75 0c             	pushl  0xc(%ebp)
  800b17:	ff 75 08             	pushl  0x8(%ebp)
  800b1a:	e8 87 ff ff ff       	call   800aa6 <memmove>
}
  800b1f:	c9                   	leave  
  800b20:	c3                   	ret    

00800b21 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b21:	55                   	push   %ebp
  800b22:	89 e5                	mov    %esp,%ebp
  800b24:	56                   	push   %esi
  800b25:	53                   	push   %ebx
  800b26:	8b 45 08             	mov    0x8(%ebp),%eax
  800b29:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b2c:	89 c6                	mov    %eax,%esi
  800b2e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b31:	eb 1a                	jmp    800b4d <memcmp+0x2c>
		if (*s1 != *s2)
  800b33:	0f b6 08             	movzbl (%eax),%ecx
  800b36:	0f b6 1a             	movzbl (%edx),%ebx
  800b39:	38 d9                	cmp    %bl,%cl
  800b3b:	74 0a                	je     800b47 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b3d:	0f b6 c1             	movzbl %cl,%eax
  800b40:	0f b6 db             	movzbl %bl,%ebx
  800b43:	29 d8                	sub    %ebx,%eax
  800b45:	eb 0f                	jmp    800b56 <memcmp+0x35>
		s1++, s2++;
  800b47:	83 c0 01             	add    $0x1,%eax
  800b4a:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b4d:	39 f0                	cmp    %esi,%eax
  800b4f:	75 e2                	jne    800b33 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b51:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b56:	5b                   	pop    %ebx
  800b57:	5e                   	pop    %esi
  800b58:	5d                   	pop    %ebp
  800b59:	c3                   	ret    

00800b5a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b5a:	55                   	push   %ebp
  800b5b:	89 e5                	mov    %esp,%ebp
  800b5d:	53                   	push   %ebx
  800b5e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b61:	89 c1                	mov    %eax,%ecx
  800b63:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b66:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b6a:	eb 0a                	jmp    800b76 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b6c:	0f b6 10             	movzbl (%eax),%edx
  800b6f:	39 da                	cmp    %ebx,%edx
  800b71:	74 07                	je     800b7a <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b73:	83 c0 01             	add    $0x1,%eax
  800b76:	39 c8                	cmp    %ecx,%eax
  800b78:	72 f2                	jb     800b6c <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b7a:	5b                   	pop    %ebx
  800b7b:	5d                   	pop    %ebp
  800b7c:	c3                   	ret    

00800b7d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b7d:	55                   	push   %ebp
  800b7e:	89 e5                	mov    %esp,%ebp
  800b80:	57                   	push   %edi
  800b81:	56                   	push   %esi
  800b82:	53                   	push   %ebx
  800b83:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b86:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b89:	eb 03                	jmp    800b8e <strtol+0x11>
		s++;
  800b8b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b8e:	0f b6 01             	movzbl (%ecx),%eax
  800b91:	3c 20                	cmp    $0x20,%al
  800b93:	74 f6                	je     800b8b <strtol+0xe>
  800b95:	3c 09                	cmp    $0x9,%al
  800b97:	74 f2                	je     800b8b <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b99:	3c 2b                	cmp    $0x2b,%al
  800b9b:	75 0a                	jne    800ba7 <strtol+0x2a>
		s++;
  800b9d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ba0:	bf 00 00 00 00       	mov    $0x0,%edi
  800ba5:	eb 11                	jmp    800bb8 <strtol+0x3b>
  800ba7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bac:	3c 2d                	cmp    $0x2d,%al
  800bae:	75 08                	jne    800bb8 <strtol+0x3b>
		s++, neg = 1;
  800bb0:	83 c1 01             	add    $0x1,%ecx
  800bb3:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bb8:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bbe:	75 15                	jne    800bd5 <strtol+0x58>
  800bc0:	80 39 30             	cmpb   $0x30,(%ecx)
  800bc3:	75 10                	jne    800bd5 <strtol+0x58>
  800bc5:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bc9:	75 7c                	jne    800c47 <strtol+0xca>
		s += 2, base = 16;
  800bcb:	83 c1 02             	add    $0x2,%ecx
  800bce:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bd3:	eb 16                	jmp    800beb <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800bd5:	85 db                	test   %ebx,%ebx
  800bd7:	75 12                	jne    800beb <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bd9:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bde:	80 39 30             	cmpb   $0x30,(%ecx)
  800be1:	75 08                	jne    800beb <strtol+0x6e>
		s++, base = 8;
  800be3:	83 c1 01             	add    $0x1,%ecx
  800be6:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800beb:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf0:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bf3:	0f b6 11             	movzbl (%ecx),%edx
  800bf6:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bf9:	89 f3                	mov    %esi,%ebx
  800bfb:	80 fb 09             	cmp    $0x9,%bl
  800bfe:	77 08                	ja     800c08 <strtol+0x8b>
			dig = *s - '0';
  800c00:	0f be d2             	movsbl %dl,%edx
  800c03:	83 ea 30             	sub    $0x30,%edx
  800c06:	eb 22                	jmp    800c2a <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c08:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c0b:	89 f3                	mov    %esi,%ebx
  800c0d:	80 fb 19             	cmp    $0x19,%bl
  800c10:	77 08                	ja     800c1a <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c12:	0f be d2             	movsbl %dl,%edx
  800c15:	83 ea 57             	sub    $0x57,%edx
  800c18:	eb 10                	jmp    800c2a <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c1a:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c1d:	89 f3                	mov    %esi,%ebx
  800c1f:	80 fb 19             	cmp    $0x19,%bl
  800c22:	77 16                	ja     800c3a <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c24:	0f be d2             	movsbl %dl,%edx
  800c27:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c2a:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c2d:	7d 0b                	jge    800c3a <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c2f:	83 c1 01             	add    $0x1,%ecx
  800c32:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c36:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c38:	eb b9                	jmp    800bf3 <strtol+0x76>

	if (endptr)
  800c3a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c3e:	74 0d                	je     800c4d <strtol+0xd0>
		*endptr = (char *) s;
  800c40:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c43:	89 0e                	mov    %ecx,(%esi)
  800c45:	eb 06                	jmp    800c4d <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c47:	85 db                	test   %ebx,%ebx
  800c49:	74 98                	je     800be3 <strtol+0x66>
  800c4b:	eb 9e                	jmp    800beb <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800c4d:	89 c2                	mov    %eax,%edx
  800c4f:	f7 da                	neg    %edx
  800c51:	85 ff                	test   %edi,%edi
  800c53:	0f 45 c2             	cmovne %edx,%eax
}
  800c56:	5b                   	pop    %ebx
  800c57:	5e                   	pop    %esi
  800c58:	5f                   	pop    %edi
  800c59:	5d                   	pop    %ebp
  800c5a:	c3                   	ret    

00800c5b <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c5b:	55                   	push   %ebp
  800c5c:	89 e5                	mov    %esp,%ebp
  800c5e:	57                   	push   %edi
  800c5f:	56                   	push   %esi
  800c60:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c61:	b8 00 00 00 00       	mov    $0x0,%eax
  800c66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c69:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6c:	89 c3                	mov    %eax,%ebx
  800c6e:	89 c7                	mov    %eax,%edi
  800c70:	89 c6                	mov    %eax,%esi
  800c72:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c74:	5b                   	pop    %ebx
  800c75:	5e                   	pop    %esi
  800c76:	5f                   	pop    %edi
  800c77:	5d                   	pop    %ebp
  800c78:	c3                   	ret    

00800c79 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c79:	55                   	push   %ebp
  800c7a:	89 e5                	mov    %esp,%ebp
  800c7c:	57                   	push   %edi
  800c7d:	56                   	push   %esi
  800c7e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7f:	ba 00 00 00 00       	mov    $0x0,%edx
  800c84:	b8 01 00 00 00       	mov    $0x1,%eax
  800c89:	89 d1                	mov    %edx,%ecx
  800c8b:	89 d3                	mov    %edx,%ebx
  800c8d:	89 d7                	mov    %edx,%edi
  800c8f:	89 d6                	mov    %edx,%esi
  800c91:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c93:	5b                   	pop    %ebx
  800c94:	5e                   	pop    %esi
  800c95:	5f                   	pop    %edi
  800c96:	5d                   	pop    %ebp
  800c97:	c3                   	ret    

00800c98 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
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
  800ca1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ca6:	b8 03 00 00 00       	mov    $0x3,%eax
  800cab:	8b 55 08             	mov    0x8(%ebp),%edx
  800cae:	89 cb                	mov    %ecx,%ebx
  800cb0:	89 cf                	mov    %ecx,%edi
  800cb2:	89 ce                	mov    %ecx,%esi
  800cb4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cb6:	85 c0                	test   %eax,%eax
  800cb8:	7e 17                	jle    800cd1 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cba:	83 ec 0c             	sub    $0xc,%esp
  800cbd:	50                   	push   %eax
  800cbe:	6a 03                	push   $0x3
  800cc0:	68 1f 27 80 00       	push   $0x80271f
  800cc5:	6a 23                	push   $0x23
  800cc7:	68 3c 27 80 00       	push   $0x80273c
  800ccc:	e8 c7 f5 ff ff       	call   800298 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cd1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd4:	5b                   	pop    %ebx
  800cd5:	5e                   	pop    %esi
  800cd6:	5f                   	pop    %edi
  800cd7:	5d                   	pop    %ebp
  800cd8:	c3                   	ret    

00800cd9 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cd9:	55                   	push   %ebp
  800cda:	89 e5                	mov    %esp,%ebp
  800cdc:	57                   	push   %edi
  800cdd:	56                   	push   %esi
  800cde:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cdf:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce4:	b8 02 00 00 00       	mov    $0x2,%eax
  800ce9:	89 d1                	mov    %edx,%ecx
  800ceb:	89 d3                	mov    %edx,%ebx
  800ced:	89 d7                	mov    %edx,%edi
  800cef:	89 d6                	mov    %edx,%esi
  800cf1:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cf3:	5b                   	pop    %ebx
  800cf4:	5e                   	pop    %esi
  800cf5:	5f                   	pop    %edi
  800cf6:	5d                   	pop    %ebp
  800cf7:	c3                   	ret    

00800cf8 <sys_yield>:

void
sys_yield(void)
{
  800cf8:	55                   	push   %ebp
  800cf9:	89 e5                	mov    %esp,%ebp
  800cfb:	57                   	push   %edi
  800cfc:	56                   	push   %esi
  800cfd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfe:	ba 00 00 00 00       	mov    $0x0,%edx
  800d03:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d08:	89 d1                	mov    %edx,%ecx
  800d0a:	89 d3                	mov    %edx,%ebx
  800d0c:	89 d7                	mov    %edx,%edi
  800d0e:	89 d6                	mov    %edx,%esi
  800d10:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d12:	5b                   	pop    %ebx
  800d13:	5e                   	pop    %esi
  800d14:	5f                   	pop    %edi
  800d15:	5d                   	pop    %ebp
  800d16:	c3                   	ret    

00800d17 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d17:	55                   	push   %ebp
  800d18:	89 e5                	mov    %esp,%ebp
  800d1a:	57                   	push   %edi
  800d1b:	56                   	push   %esi
  800d1c:	53                   	push   %ebx
  800d1d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d20:	be 00 00 00 00       	mov    $0x0,%esi
  800d25:	b8 04 00 00 00       	mov    $0x4,%eax
  800d2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d30:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d33:	89 f7                	mov    %esi,%edi
  800d35:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d37:	85 c0                	test   %eax,%eax
  800d39:	7e 17                	jle    800d52 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3b:	83 ec 0c             	sub    $0xc,%esp
  800d3e:	50                   	push   %eax
  800d3f:	6a 04                	push   $0x4
  800d41:	68 1f 27 80 00       	push   $0x80271f
  800d46:	6a 23                	push   $0x23
  800d48:	68 3c 27 80 00       	push   $0x80273c
  800d4d:	e8 46 f5 ff ff       	call   800298 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d52:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d55:	5b                   	pop    %ebx
  800d56:	5e                   	pop    %esi
  800d57:	5f                   	pop    %edi
  800d58:	5d                   	pop    %ebp
  800d59:	c3                   	ret    

00800d5a <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d5a:	55                   	push   %ebp
  800d5b:	89 e5                	mov    %esp,%ebp
  800d5d:	57                   	push   %edi
  800d5e:	56                   	push   %esi
  800d5f:	53                   	push   %ebx
  800d60:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d63:	b8 05 00 00 00       	mov    $0x5,%eax
  800d68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d71:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d74:	8b 75 18             	mov    0x18(%ebp),%esi
  800d77:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d79:	85 c0                	test   %eax,%eax
  800d7b:	7e 17                	jle    800d94 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7d:	83 ec 0c             	sub    $0xc,%esp
  800d80:	50                   	push   %eax
  800d81:	6a 05                	push   $0x5
  800d83:	68 1f 27 80 00       	push   $0x80271f
  800d88:	6a 23                	push   $0x23
  800d8a:	68 3c 27 80 00       	push   $0x80273c
  800d8f:	e8 04 f5 ff ff       	call   800298 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d94:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d97:	5b                   	pop    %ebx
  800d98:	5e                   	pop    %esi
  800d99:	5f                   	pop    %edi
  800d9a:	5d                   	pop    %ebp
  800d9b:	c3                   	ret    

00800d9c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d9c:	55                   	push   %ebp
  800d9d:	89 e5                	mov    %esp,%ebp
  800d9f:	57                   	push   %edi
  800da0:	56                   	push   %esi
  800da1:	53                   	push   %ebx
  800da2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800daa:	b8 06 00 00 00       	mov    $0x6,%eax
  800daf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db2:	8b 55 08             	mov    0x8(%ebp),%edx
  800db5:	89 df                	mov    %ebx,%edi
  800db7:	89 de                	mov    %ebx,%esi
  800db9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dbb:	85 c0                	test   %eax,%eax
  800dbd:	7e 17                	jle    800dd6 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dbf:	83 ec 0c             	sub    $0xc,%esp
  800dc2:	50                   	push   %eax
  800dc3:	6a 06                	push   $0x6
  800dc5:	68 1f 27 80 00       	push   $0x80271f
  800dca:	6a 23                	push   $0x23
  800dcc:	68 3c 27 80 00       	push   $0x80273c
  800dd1:	e8 c2 f4 ff ff       	call   800298 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800dd6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dd9:	5b                   	pop    %ebx
  800dda:	5e                   	pop    %esi
  800ddb:	5f                   	pop    %edi
  800ddc:	5d                   	pop    %ebp
  800ddd:	c3                   	ret    

00800dde <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dde:	55                   	push   %ebp
  800ddf:	89 e5                	mov    %esp,%ebp
  800de1:	57                   	push   %edi
  800de2:	56                   	push   %esi
  800de3:	53                   	push   %ebx
  800de4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dec:	b8 08 00 00 00       	mov    $0x8,%eax
  800df1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df4:	8b 55 08             	mov    0x8(%ebp),%edx
  800df7:	89 df                	mov    %ebx,%edi
  800df9:	89 de                	mov    %ebx,%esi
  800dfb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dfd:	85 c0                	test   %eax,%eax
  800dff:	7e 17                	jle    800e18 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e01:	83 ec 0c             	sub    $0xc,%esp
  800e04:	50                   	push   %eax
  800e05:	6a 08                	push   $0x8
  800e07:	68 1f 27 80 00       	push   $0x80271f
  800e0c:	6a 23                	push   $0x23
  800e0e:	68 3c 27 80 00       	push   $0x80273c
  800e13:	e8 80 f4 ff ff       	call   800298 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e18:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e1b:	5b                   	pop    %ebx
  800e1c:	5e                   	pop    %esi
  800e1d:	5f                   	pop    %edi
  800e1e:	5d                   	pop    %ebp
  800e1f:	c3                   	ret    

00800e20 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e20:	55                   	push   %ebp
  800e21:	89 e5                	mov    %esp,%ebp
  800e23:	57                   	push   %edi
  800e24:	56                   	push   %esi
  800e25:	53                   	push   %ebx
  800e26:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e29:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e2e:	b8 09 00 00 00       	mov    $0x9,%eax
  800e33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e36:	8b 55 08             	mov    0x8(%ebp),%edx
  800e39:	89 df                	mov    %ebx,%edi
  800e3b:	89 de                	mov    %ebx,%esi
  800e3d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e3f:	85 c0                	test   %eax,%eax
  800e41:	7e 17                	jle    800e5a <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e43:	83 ec 0c             	sub    $0xc,%esp
  800e46:	50                   	push   %eax
  800e47:	6a 09                	push   $0x9
  800e49:	68 1f 27 80 00       	push   $0x80271f
  800e4e:	6a 23                	push   $0x23
  800e50:	68 3c 27 80 00       	push   $0x80273c
  800e55:	e8 3e f4 ff ff       	call   800298 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e5d:	5b                   	pop    %ebx
  800e5e:	5e                   	pop    %esi
  800e5f:	5f                   	pop    %edi
  800e60:	5d                   	pop    %ebp
  800e61:	c3                   	ret    

00800e62 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e62:	55                   	push   %ebp
  800e63:	89 e5                	mov    %esp,%ebp
  800e65:	57                   	push   %edi
  800e66:	56                   	push   %esi
  800e67:	53                   	push   %ebx
  800e68:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e6b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e70:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e78:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7b:	89 df                	mov    %ebx,%edi
  800e7d:	89 de                	mov    %ebx,%esi
  800e7f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e81:	85 c0                	test   %eax,%eax
  800e83:	7e 17                	jle    800e9c <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e85:	83 ec 0c             	sub    $0xc,%esp
  800e88:	50                   	push   %eax
  800e89:	6a 0a                	push   $0xa
  800e8b:	68 1f 27 80 00       	push   $0x80271f
  800e90:	6a 23                	push   $0x23
  800e92:	68 3c 27 80 00       	push   $0x80273c
  800e97:	e8 fc f3 ff ff       	call   800298 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e9c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e9f:	5b                   	pop    %ebx
  800ea0:	5e                   	pop    %esi
  800ea1:	5f                   	pop    %edi
  800ea2:	5d                   	pop    %ebp
  800ea3:	c3                   	ret    

00800ea4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ea4:	55                   	push   %ebp
  800ea5:	89 e5                	mov    %esp,%ebp
  800ea7:	57                   	push   %edi
  800ea8:	56                   	push   %esi
  800ea9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eaa:	be 00 00 00 00       	mov    $0x0,%esi
  800eaf:	b8 0c 00 00 00       	mov    $0xc,%eax
  800eb4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb7:	8b 55 08             	mov    0x8(%ebp),%edx
  800eba:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ebd:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ec0:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ec2:	5b                   	pop    %ebx
  800ec3:	5e                   	pop    %esi
  800ec4:	5f                   	pop    %edi
  800ec5:	5d                   	pop    %ebp
  800ec6:	c3                   	ret    

00800ec7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ec7:	55                   	push   %ebp
  800ec8:	89 e5                	mov    %esp,%ebp
  800eca:	57                   	push   %edi
  800ecb:	56                   	push   %esi
  800ecc:	53                   	push   %ebx
  800ecd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ed5:	b8 0d 00 00 00       	mov    $0xd,%eax
  800eda:	8b 55 08             	mov    0x8(%ebp),%edx
  800edd:	89 cb                	mov    %ecx,%ebx
  800edf:	89 cf                	mov    %ecx,%edi
  800ee1:	89 ce                	mov    %ecx,%esi
  800ee3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ee5:	85 c0                	test   %eax,%eax
  800ee7:	7e 17                	jle    800f00 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee9:	83 ec 0c             	sub    $0xc,%esp
  800eec:	50                   	push   %eax
  800eed:	6a 0d                	push   $0xd
  800eef:	68 1f 27 80 00       	push   $0x80271f
  800ef4:	6a 23                	push   $0x23
  800ef6:	68 3c 27 80 00       	push   $0x80273c
  800efb:	e8 98 f3 ff ff       	call   800298 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f03:	5b                   	pop    %ebx
  800f04:	5e                   	pop    %esi
  800f05:	5f                   	pop    %edi
  800f06:	5d                   	pop    %ebp
  800f07:	c3                   	ret    

00800f08 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800f08:	55                   	push   %ebp
  800f09:	89 e5                	mov    %esp,%ebp
  800f0b:	53                   	push   %ebx
  800f0c:	83 ec 04             	sub    $0x4,%esp
	int r;
	// LAB 4: Your code here.
    	pte_t *pte;
	int ret;
	// 用户空间的地址较低
	void *addr = (void *)(pn * PGSIZE);
  800f0f:	89 d3                	mov    %edx,%ebx
  800f11:	c1 e3 0c             	shl    $0xc,%ebx
	if (uvpt[pn] & PTE_SHARE) {
  800f14:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800f1b:	f6 c5 04             	test   $0x4,%ch
  800f1e:	74 2f                	je     800f4f <duppage+0x47>
		// cprintf("dup share page :%d\n", pn);
		if ((r = sys_page_map(0, addr, envid, addr, PTE_SYSCALL)) < 0)
  800f20:	83 ec 0c             	sub    $0xc,%esp
  800f23:	68 07 0e 00 00       	push   $0xe07
  800f28:	53                   	push   %ebx
  800f29:	50                   	push   %eax
  800f2a:	53                   	push   %ebx
  800f2b:	6a 00                	push   $0x0
  800f2d:	e8 28 fe ff ff       	call   800d5a <sys_page_map>
  800f32:	83 c4 20             	add    $0x20,%esp
  800f35:	85 c0                	test   %eax,%eax
  800f37:	0f 89 a0 00 00 00    	jns    800fdd <duppage+0xd5>
			panic("duppage sys_page_map:%e", r);
  800f3d:	50                   	push   %eax
  800f3e:	68 4a 27 80 00       	push   $0x80274a
  800f43:	6a 4d                	push   $0x4d
  800f45:	68 62 27 80 00       	push   $0x802762
  800f4a:	e8 49 f3 ff ff       	call   800298 <_panic>
	} else if (uvpt[pn] & (PTE_W|PTE_COW)) {
  800f4f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f56:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800f5c:	74 57                	je     800fb5 <duppage+0xad>
		if ((r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  800f5e:	83 ec 0c             	sub    $0xc,%esp
  800f61:	68 05 08 00 00       	push   $0x805
  800f66:	53                   	push   %ebx
  800f67:	50                   	push   %eax
  800f68:	53                   	push   %ebx
  800f69:	6a 00                	push   $0x0
  800f6b:	e8 ea fd ff ff       	call   800d5a <sys_page_map>
  800f70:	83 c4 20             	add    $0x20,%esp
  800f73:	85 c0                	test   %eax,%eax
  800f75:	79 12                	jns    800f89 <duppage+0x81>
			panic("sys_page_map COW:%e", r);
  800f77:	50                   	push   %eax
  800f78:	68 6d 27 80 00       	push   $0x80276d
  800f7d:	6a 50                	push   $0x50
  800f7f:	68 62 27 80 00       	push   $0x802762
  800f84:	e8 0f f3 ff ff       	call   800298 <_panic>

		if ((r = sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  800f89:	83 ec 0c             	sub    $0xc,%esp
  800f8c:	68 05 08 00 00       	push   $0x805
  800f91:	53                   	push   %ebx
  800f92:	6a 00                	push   $0x0
  800f94:	53                   	push   %ebx
  800f95:	6a 00                	push   $0x0
  800f97:	e8 be fd ff ff       	call   800d5a <sys_page_map>
  800f9c:	83 c4 20             	add    $0x20,%esp
  800f9f:	85 c0                	test   %eax,%eax
  800fa1:	79 3a                	jns    800fdd <duppage+0xd5>
			panic("sys_page_map COW:%e", r);
  800fa3:	50                   	push   %eax
  800fa4:	68 6d 27 80 00       	push   $0x80276d
  800fa9:	6a 53                	push   $0x53
  800fab:	68 62 27 80 00       	push   $0x802762
  800fb0:	e8 e3 f2 ff ff       	call   800298 <_panic>
	} else {
		if ((r = sys_page_map(0, addr, envid, addr, PTE_U|PTE_P)) < 0)
  800fb5:	83 ec 0c             	sub    $0xc,%esp
  800fb8:	6a 05                	push   $0x5
  800fba:	53                   	push   %ebx
  800fbb:	50                   	push   %eax
  800fbc:	53                   	push   %ebx
  800fbd:	6a 00                	push   $0x0
  800fbf:	e8 96 fd ff ff       	call   800d5a <sys_page_map>
  800fc4:	83 c4 20             	add    $0x20,%esp
  800fc7:	85 c0                	test   %eax,%eax
  800fc9:	79 12                	jns    800fdd <duppage+0xd5>
			panic("sys_page_map UP:%e", r);
  800fcb:	50                   	push   %eax
  800fcc:	68 81 27 80 00       	push   $0x802781
  800fd1:	6a 56                	push   $0x56
  800fd3:	68 62 27 80 00       	push   $0x802762
  800fd8:	e8 bb f2 ff ff       	call   800298 <_panic>
	}
	return 0;
}
  800fdd:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fe5:	c9                   	leave  
  800fe6:	c3                   	ret    

00800fe7 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800fe7:	55                   	push   %ebp
  800fe8:	89 e5                	mov    %esp,%ebp
  800fea:	56                   	push   %esi
  800feb:	53                   	push   %ebx
  800fec:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800fef:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (! ( (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  800ff1:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800ff5:	74 2d                	je     801024 <pgfault+0x3d>
  800ff7:	89 d8                	mov    %ebx,%eax
  800ff9:	c1 e8 16             	shr    $0x16,%eax
  800ffc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801003:	a8 01                	test   $0x1,%al
  801005:	74 1d                	je     801024 <pgfault+0x3d>
  801007:	89 d8                	mov    %ebx,%eax
  801009:	c1 e8 0c             	shr    $0xc,%eax
  80100c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801013:	f6 c2 01             	test   $0x1,%dl
  801016:	74 0c                	je     801024 <pgfault+0x3d>
  801018:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80101f:	f6 c4 08             	test   $0x8,%ah
  801022:	75 14                	jne    801038 <pgfault+0x51>
        	panic("Neither the fault is a write nor COW page. \n");
  801024:	83 ec 04             	sub    $0x4,%esp
  801027:	68 00 28 80 00       	push   $0x802800
  80102c:	6a 1d                	push   $0x1d
  80102e:	68 62 27 80 00       	push   $0x802762
  801033:	e8 60 f2 ff ff       	call   800298 <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.
	

    	envid_t envid = sys_getenvid();
  801038:	e8 9c fc ff ff       	call   800cd9 <sys_getenvid>
  80103d:	89 c6                	mov    %eax,%esi
    	// cprintf("pgfault: envid: %d\n", ENVX(envid));
    	// 临时页暂存
    	if ((r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P| PTE_W|PTE_U)) < 0)
  80103f:	83 ec 04             	sub    $0x4,%esp
  801042:	6a 07                	push   $0x7
  801044:	68 00 f0 7f 00       	push   $0x7ff000
  801049:	50                   	push   %eax
  80104a:	e8 c8 fc ff ff       	call   800d17 <sys_page_alloc>
  80104f:	83 c4 10             	add    $0x10,%esp
  801052:	85 c0                	test   %eax,%eax
  801054:	79 12                	jns    801068 <pgfault+0x81>
        	panic("pgfault: page allocation fault:%e\n", r);
  801056:	50                   	push   %eax
  801057:	68 30 28 80 00       	push   $0x802830
  80105c:	6a 2b                	push   $0x2b
  80105e:	68 62 27 80 00       	push   $0x802762
  801063:	e8 30 f2 ff ff       	call   800298 <_panic>
    	addr = ROUNDDOWN(addr, PGSIZE);
  801068:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  80106e:	83 ec 04             	sub    $0x4,%esp
  801071:	68 00 10 00 00       	push   $0x1000
  801076:	53                   	push   %ebx
  801077:	68 00 f0 7f 00       	push   $0x7ff000
  80107c:	e8 8d fa ff ff       	call   800b0e <memcpy>
    	if ((r = sys_page_map(envid, (void *) PFTEMP, envid, addr , PTE_P|PTE_W|PTE_U)) < 0 )
  801081:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801088:	53                   	push   %ebx
  801089:	56                   	push   %esi
  80108a:	68 00 f0 7f 00       	push   $0x7ff000
  80108f:	56                   	push   %esi
  801090:	e8 c5 fc ff ff       	call   800d5a <sys_page_map>
  801095:	83 c4 20             	add    $0x20,%esp
  801098:	85 c0                	test   %eax,%eax
  80109a:	79 12                	jns    8010ae <pgfault+0xc7>
        	panic("pgfault: page map failed %e\n", r);
  80109c:	50                   	push   %eax
  80109d:	68 94 27 80 00       	push   $0x802794
  8010a2:	6a 2f                	push   $0x2f
  8010a4:	68 62 27 80 00       	push   $0x802762
  8010a9:	e8 ea f1 ff ff       	call   800298 <_panic>
    
    	if ((r = sys_page_unmap(envid, (void *) PFTEMP)) < 0)
  8010ae:	83 ec 08             	sub    $0x8,%esp
  8010b1:	68 00 f0 7f 00       	push   $0x7ff000
  8010b6:	56                   	push   %esi
  8010b7:	e8 e0 fc ff ff       	call   800d9c <sys_page_unmap>
  8010bc:	83 c4 10             	add    $0x10,%esp
  8010bf:	85 c0                	test   %eax,%eax
  8010c1:	79 12                	jns    8010d5 <pgfault+0xee>
        	panic("pgfault: page unmap failed %e\n", r);
  8010c3:	50                   	push   %eax
  8010c4:	68 54 28 80 00       	push   $0x802854
  8010c9:	6a 32                	push   $0x32
  8010cb:	68 62 27 80 00       	push   $0x802762
  8010d0:	e8 c3 f1 ff ff       	call   800298 <_panic>
	//panic("pgfault not implemented");
}
  8010d5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010d8:	5b                   	pop    %ebx
  8010d9:	5e                   	pop    %esi
  8010da:	5d                   	pop    %ebp
  8010db:	c3                   	ret    

008010dc <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8010dc:	55                   	push   %ebp
  8010dd:	89 e5                	mov    %esp,%ebp
  8010df:	56                   	push   %esi
  8010e0:	53                   	push   %ebx
  8010e1:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	set_pgfault_handler(pgfault);
  8010e4:	68 e7 0f 80 00       	push   $0x800fe7
  8010e9:	e8 14 0e 00 00       	call   801f02 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8010ee:	b8 07 00 00 00       	mov    $0x7,%eax
  8010f3:	cd 30                	int    $0x30
  8010f5:	89 c3                	mov    %eax,%ebx

	envid_t envid = sys_exofork();
	uint8_t *addr;
	if (envid < 0)
  8010f7:	83 c4 10             	add    $0x10,%esp
  8010fa:	85 c0                	test   %eax,%eax
  8010fc:	79 12                	jns    801110 <fork+0x34>
		panic("sys_exofork:%e", envid);
  8010fe:	50                   	push   %eax
  8010ff:	68 b1 27 80 00       	push   $0x8027b1
  801104:	6a 75                	push   $0x75
  801106:	68 62 27 80 00       	push   $0x802762
  80110b:	e8 88 f1 ff ff       	call   800298 <_panic>
  801110:	89 c6                	mov    %eax,%esi
	if (envid == 0) {
  801112:	85 c0                	test   %eax,%eax
  801114:	75 21                	jne    801137 <fork+0x5b>
		thisenv = &envs[ENVX(sys_getenvid())];
  801116:	e8 be fb ff ff       	call   800cd9 <sys_getenvid>
  80111b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801120:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801123:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801128:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  80112d:	b8 00 00 00 00       	mov    $0x0,%eax
  801132:	e9 c0 00 00 00       	jmp    8011f7 <fork+0x11b>
	}

	for (addr = (uint8_t *)UTEXT; addr < (uint8_t *)USTACKTOP-PGSIZE; addr += PGSIZE) {
  801137:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  80113e:	ba 00 00 80 00       	mov    $0x800000,%edx
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
  801143:	89 d0                	mov    %edx,%eax
  801145:	c1 e8 16             	shr    $0x16,%eax
  801148:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80114f:	a8 01                	test   $0x1,%al
  801151:	74 20                	je     801173 <fork+0x97>
  801153:	c1 ea 0c             	shr    $0xc,%edx
  801156:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80115d:	a8 01                	test   $0x1,%al
  80115f:	74 12                	je     801173 <fork+0x97>
				&& (uvpt[PGNUM(addr)] & PTE_U)) {
  801161:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801168:	a8 04                	test   $0x4,%al
  80116a:	74 07                	je     801173 <fork+0x97>
			duppage(envid, PGNUM(addr));
  80116c:	89 f0                	mov    %esi,%eax
  80116e:	e8 95 fd ff ff       	call   800f08 <duppage>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}

	for (addr = (uint8_t *)UTEXT; addr < (uint8_t *)USTACKTOP-PGSIZE; addr += PGSIZE) {
  801173:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801176:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
  80117c:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80117f:	81 fa ff cf bf ee    	cmp    $0xeebfcfff,%edx
  801185:	76 bc                	jbe    801143 <fork+0x67>
				&& (uvpt[PGNUM(addr)] & PTE_U)) {
			duppage(envid, PGNUM(addr));
		}
	}

	duppage(envid, PGNUM(ROUNDDOWN(&addr, PGSIZE)));
  801187:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80118a:	c1 ea 0c             	shr    $0xc,%edx
  80118d:	89 d8                	mov    %ebx,%eax
  80118f:	e8 74 fd ff ff       	call   800f08 <duppage>

	int r;
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)))
  801194:	83 ec 04             	sub    $0x4,%esp
  801197:	6a 07                	push   $0x7
  801199:	68 00 f0 bf ee       	push   $0xeebff000
  80119e:	53                   	push   %ebx
  80119f:	e8 73 fb ff ff       	call   800d17 <sys_page_alloc>
  8011a4:	83 c4 10             	add    $0x10,%esp
  8011a7:	85 c0                	test   %eax,%eax
  8011a9:	74 15                	je     8011c0 <fork+0xe4>
		panic("sys_page_alloc:%e", r);
  8011ab:	50                   	push   %eax
  8011ac:	68 c0 27 80 00       	push   $0x8027c0
  8011b1:	68 86 00 00 00       	push   $0x86
  8011b6:	68 62 27 80 00       	push   $0x802762
  8011bb:	e8 d8 f0 ff ff       	call   800298 <_panic>

	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8011c0:	83 ec 08             	sub    $0x8,%esp
  8011c3:	68 6a 1f 80 00       	push   $0x801f6a
  8011c8:	53                   	push   %ebx
  8011c9:	e8 94 fc ff ff       	call   800e62 <sys_env_set_pgfault_upcall>

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)))
  8011ce:	83 c4 08             	add    $0x8,%esp
  8011d1:	6a 02                	push   $0x2
  8011d3:	53                   	push   %ebx
  8011d4:	e8 05 fc ff ff       	call   800dde <sys_env_set_status>
  8011d9:	83 c4 10             	add    $0x10,%esp
  8011dc:	85 c0                	test   %eax,%eax
  8011de:	74 15                	je     8011f5 <fork+0x119>
		panic("sys_env_set_status:%e", r);
  8011e0:	50                   	push   %eax
  8011e1:	68 d2 27 80 00       	push   $0x8027d2
  8011e6:	68 8c 00 00 00       	push   $0x8c
  8011eb:	68 62 27 80 00       	push   $0x802762
  8011f0:	e8 a3 f0 ff ff       	call   800298 <_panic>

	return envid;
  8011f5:	89 d8                	mov    %ebx,%eax
	    
}
  8011f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011fa:	5b                   	pop    %ebx
  8011fb:	5e                   	pop    %esi
  8011fc:	5d                   	pop    %ebp
  8011fd:	c3                   	ret    

008011fe <sfork>:

// Challenge!
int
sfork(void)
{
  8011fe:	55                   	push   %ebp
  8011ff:	89 e5                	mov    %esp,%ebp
  801201:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801204:	68 e8 27 80 00       	push   $0x8027e8
  801209:	68 96 00 00 00       	push   $0x96
  80120e:	68 62 27 80 00       	push   $0x802762
  801213:	e8 80 f0 ff ff       	call   800298 <_panic>

00801218 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801218:	55                   	push   %ebp
  801219:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80121b:	8b 45 08             	mov    0x8(%ebp),%eax
  80121e:	05 00 00 00 30       	add    $0x30000000,%eax
  801223:	c1 e8 0c             	shr    $0xc,%eax
}
  801226:	5d                   	pop    %ebp
  801227:	c3                   	ret    

00801228 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801228:	55                   	push   %ebp
  801229:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80122b:	8b 45 08             	mov    0x8(%ebp),%eax
  80122e:	05 00 00 00 30       	add    $0x30000000,%eax
  801233:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801238:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80123d:	5d                   	pop    %ebp
  80123e:	c3                   	ret    

0080123f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80123f:	55                   	push   %ebp
  801240:	89 e5                	mov    %esp,%ebp
  801242:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801245:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80124a:	89 c2                	mov    %eax,%edx
  80124c:	c1 ea 16             	shr    $0x16,%edx
  80124f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801256:	f6 c2 01             	test   $0x1,%dl
  801259:	74 11                	je     80126c <fd_alloc+0x2d>
  80125b:	89 c2                	mov    %eax,%edx
  80125d:	c1 ea 0c             	shr    $0xc,%edx
  801260:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801267:	f6 c2 01             	test   $0x1,%dl
  80126a:	75 09                	jne    801275 <fd_alloc+0x36>
			*fd_store = fd;
  80126c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80126e:	b8 00 00 00 00       	mov    $0x0,%eax
  801273:	eb 17                	jmp    80128c <fd_alloc+0x4d>
  801275:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80127a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80127f:	75 c9                	jne    80124a <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801281:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801287:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80128c:	5d                   	pop    %ebp
  80128d:	c3                   	ret    

0080128e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80128e:	55                   	push   %ebp
  80128f:	89 e5                	mov    %esp,%ebp
  801291:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801294:	83 f8 1f             	cmp    $0x1f,%eax
  801297:	77 36                	ja     8012cf <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801299:	c1 e0 0c             	shl    $0xc,%eax
  80129c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012a1:	89 c2                	mov    %eax,%edx
  8012a3:	c1 ea 16             	shr    $0x16,%edx
  8012a6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012ad:	f6 c2 01             	test   $0x1,%dl
  8012b0:	74 24                	je     8012d6 <fd_lookup+0x48>
  8012b2:	89 c2                	mov    %eax,%edx
  8012b4:	c1 ea 0c             	shr    $0xc,%edx
  8012b7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012be:	f6 c2 01             	test   $0x1,%dl
  8012c1:	74 1a                	je     8012dd <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012c6:	89 02                	mov    %eax,(%edx)
	return 0;
  8012c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8012cd:	eb 13                	jmp    8012e2 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012cf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012d4:	eb 0c                	jmp    8012e2 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012d6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012db:	eb 05                	jmp    8012e2 <fd_lookup+0x54>
  8012dd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012e2:	5d                   	pop    %ebp
  8012e3:	c3                   	ret    

008012e4 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012e4:	55                   	push   %ebp
  8012e5:	89 e5                	mov    %esp,%ebp
  8012e7:	83 ec 08             	sub    $0x8,%esp
  8012ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012ed:	ba f0 28 80 00       	mov    $0x8028f0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012f2:	eb 13                	jmp    801307 <dev_lookup+0x23>
  8012f4:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8012f7:	39 08                	cmp    %ecx,(%eax)
  8012f9:	75 0c                	jne    801307 <dev_lookup+0x23>
			*dev = devtab[i];
  8012fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012fe:	89 01                	mov    %eax,(%ecx)
			return 0;
  801300:	b8 00 00 00 00       	mov    $0x0,%eax
  801305:	eb 2e                	jmp    801335 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801307:	8b 02                	mov    (%edx),%eax
  801309:	85 c0                	test   %eax,%eax
  80130b:	75 e7                	jne    8012f4 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80130d:	a1 04 40 80 00       	mov    0x804004,%eax
  801312:	8b 40 48             	mov    0x48(%eax),%eax
  801315:	83 ec 04             	sub    $0x4,%esp
  801318:	51                   	push   %ecx
  801319:	50                   	push   %eax
  80131a:	68 74 28 80 00       	push   $0x802874
  80131f:	e8 4d f0 ff ff       	call   800371 <cprintf>
	*dev = 0;
  801324:	8b 45 0c             	mov    0xc(%ebp),%eax
  801327:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80132d:	83 c4 10             	add    $0x10,%esp
  801330:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801335:	c9                   	leave  
  801336:	c3                   	ret    

00801337 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801337:	55                   	push   %ebp
  801338:	89 e5                	mov    %esp,%ebp
  80133a:	56                   	push   %esi
  80133b:	53                   	push   %ebx
  80133c:	83 ec 10             	sub    $0x10,%esp
  80133f:	8b 75 08             	mov    0x8(%ebp),%esi
  801342:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801345:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801348:	50                   	push   %eax
  801349:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80134f:	c1 e8 0c             	shr    $0xc,%eax
  801352:	50                   	push   %eax
  801353:	e8 36 ff ff ff       	call   80128e <fd_lookup>
  801358:	83 c4 08             	add    $0x8,%esp
  80135b:	85 c0                	test   %eax,%eax
  80135d:	78 05                	js     801364 <fd_close+0x2d>
	    || fd != fd2)
  80135f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801362:	74 0c                	je     801370 <fd_close+0x39>
		return (must_exist ? r : 0);
  801364:	84 db                	test   %bl,%bl
  801366:	ba 00 00 00 00       	mov    $0x0,%edx
  80136b:	0f 44 c2             	cmove  %edx,%eax
  80136e:	eb 41                	jmp    8013b1 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801370:	83 ec 08             	sub    $0x8,%esp
  801373:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801376:	50                   	push   %eax
  801377:	ff 36                	pushl  (%esi)
  801379:	e8 66 ff ff ff       	call   8012e4 <dev_lookup>
  80137e:	89 c3                	mov    %eax,%ebx
  801380:	83 c4 10             	add    $0x10,%esp
  801383:	85 c0                	test   %eax,%eax
  801385:	78 1a                	js     8013a1 <fd_close+0x6a>
		if (dev->dev_close)
  801387:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80138a:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80138d:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801392:	85 c0                	test   %eax,%eax
  801394:	74 0b                	je     8013a1 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801396:	83 ec 0c             	sub    $0xc,%esp
  801399:	56                   	push   %esi
  80139a:	ff d0                	call   *%eax
  80139c:	89 c3                	mov    %eax,%ebx
  80139e:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013a1:	83 ec 08             	sub    $0x8,%esp
  8013a4:	56                   	push   %esi
  8013a5:	6a 00                	push   $0x0
  8013a7:	e8 f0 f9 ff ff       	call   800d9c <sys_page_unmap>
	return r;
  8013ac:	83 c4 10             	add    $0x10,%esp
  8013af:	89 d8                	mov    %ebx,%eax
}
  8013b1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013b4:	5b                   	pop    %ebx
  8013b5:	5e                   	pop    %esi
  8013b6:	5d                   	pop    %ebp
  8013b7:	c3                   	ret    

008013b8 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013b8:	55                   	push   %ebp
  8013b9:	89 e5                	mov    %esp,%ebp
  8013bb:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013c1:	50                   	push   %eax
  8013c2:	ff 75 08             	pushl  0x8(%ebp)
  8013c5:	e8 c4 fe ff ff       	call   80128e <fd_lookup>
  8013ca:	83 c4 08             	add    $0x8,%esp
  8013cd:	85 c0                	test   %eax,%eax
  8013cf:	78 10                	js     8013e1 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8013d1:	83 ec 08             	sub    $0x8,%esp
  8013d4:	6a 01                	push   $0x1
  8013d6:	ff 75 f4             	pushl  -0xc(%ebp)
  8013d9:	e8 59 ff ff ff       	call   801337 <fd_close>
  8013de:	83 c4 10             	add    $0x10,%esp
}
  8013e1:	c9                   	leave  
  8013e2:	c3                   	ret    

008013e3 <close_all>:

void
close_all(void)
{
  8013e3:	55                   	push   %ebp
  8013e4:	89 e5                	mov    %esp,%ebp
  8013e6:	53                   	push   %ebx
  8013e7:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013ea:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013ef:	83 ec 0c             	sub    $0xc,%esp
  8013f2:	53                   	push   %ebx
  8013f3:	e8 c0 ff ff ff       	call   8013b8 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013f8:	83 c3 01             	add    $0x1,%ebx
  8013fb:	83 c4 10             	add    $0x10,%esp
  8013fe:	83 fb 20             	cmp    $0x20,%ebx
  801401:	75 ec                	jne    8013ef <close_all+0xc>
		close(i);
}
  801403:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801406:	c9                   	leave  
  801407:	c3                   	ret    

00801408 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801408:	55                   	push   %ebp
  801409:	89 e5                	mov    %esp,%ebp
  80140b:	57                   	push   %edi
  80140c:	56                   	push   %esi
  80140d:	53                   	push   %ebx
  80140e:	83 ec 2c             	sub    $0x2c,%esp
  801411:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801414:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801417:	50                   	push   %eax
  801418:	ff 75 08             	pushl  0x8(%ebp)
  80141b:	e8 6e fe ff ff       	call   80128e <fd_lookup>
  801420:	83 c4 08             	add    $0x8,%esp
  801423:	85 c0                	test   %eax,%eax
  801425:	0f 88 c1 00 00 00    	js     8014ec <dup+0xe4>
		return r;
	close(newfdnum);
  80142b:	83 ec 0c             	sub    $0xc,%esp
  80142e:	56                   	push   %esi
  80142f:	e8 84 ff ff ff       	call   8013b8 <close>

	newfd = INDEX2FD(newfdnum);
  801434:	89 f3                	mov    %esi,%ebx
  801436:	c1 e3 0c             	shl    $0xc,%ebx
  801439:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80143f:	83 c4 04             	add    $0x4,%esp
  801442:	ff 75 e4             	pushl  -0x1c(%ebp)
  801445:	e8 de fd ff ff       	call   801228 <fd2data>
  80144a:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80144c:	89 1c 24             	mov    %ebx,(%esp)
  80144f:	e8 d4 fd ff ff       	call   801228 <fd2data>
  801454:	83 c4 10             	add    $0x10,%esp
  801457:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80145a:	89 f8                	mov    %edi,%eax
  80145c:	c1 e8 16             	shr    $0x16,%eax
  80145f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801466:	a8 01                	test   $0x1,%al
  801468:	74 37                	je     8014a1 <dup+0x99>
  80146a:	89 f8                	mov    %edi,%eax
  80146c:	c1 e8 0c             	shr    $0xc,%eax
  80146f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801476:	f6 c2 01             	test   $0x1,%dl
  801479:	74 26                	je     8014a1 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80147b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801482:	83 ec 0c             	sub    $0xc,%esp
  801485:	25 07 0e 00 00       	and    $0xe07,%eax
  80148a:	50                   	push   %eax
  80148b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80148e:	6a 00                	push   $0x0
  801490:	57                   	push   %edi
  801491:	6a 00                	push   $0x0
  801493:	e8 c2 f8 ff ff       	call   800d5a <sys_page_map>
  801498:	89 c7                	mov    %eax,%edi
  80149a:	83 c4 20             	add    $0x20,%esp
  80149d:	85 c0                	test   %eax,%eax
  80149f:	78 2e                	js     8014cf <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014a1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014a4:	89 d0                	mov    %edx,%eax
  8014a6:	c1 e8 0c             	shr    $0xc,%eax
  8014a9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014b0:	83 ec 0c             	sub    $0xc,%esp
  8014b3:	25 07 0e 00 00       	and    $0xe07,%eax
  8014b8:	50                   	push   %eax
  8014b9:	53                   	push   %ebx
  8014ba:	6a 00                	push   $0x0
  8014bc:	52                   	push   %edx
  8014bd:	6a 00                	push   $0x0
  8014bf:	e8 96 f8 ff ff       	call   800d5a <sys_page_map>
  8014c4:	89 c7                	mov    %eax,%edi
  8014c6:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8014c9:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014cb:	85 ff                	test   %edi,%edi
  8014cd:	79 1d                	jns    8014ec <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014cf:	83 ec 08             	sub    $0x8,%esp
  8014d2:	53                   	push   %ebx
  8014d3:	6a 00                	push   $0x0
  8014d5:	e8 c2 f8 ff ff       	call   800d9c <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014da:	83 c4 08             	add    $0x8,%esp
  8014dd:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014e0:	6a 00                	push   $0x0
  8014e2:	e8 b5 f8 ff ff       	call   800d9c <sys_page_unmap>
	return r;
  8014e7:	83 c4 10             	add    $0x10,%esp
  8014ea:	89 f8                	mov    %edi,%eax
}
  8014ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014ef:	5b                   	pop    %ebx
  8014f0:	5e                   	pop    %esi
  8014f1:	5f                   	pop    %edi
  8014f2:	5d                   	pop    %ebp
  8014f3:	c3                   	ret    

008014f4 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014f4:	55                   	push   %ebp
  8014f5:	89 e5                	mov    %esp,%ebp
  8014f7:	53                   	push   %ebx
  8014f8:	83 ec 14             	sub    $0x14,%esp
  8014fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014fe:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801501:	50                   	push   %eax
  801502:	53                   	push   %ebx
  801503:	e8 86 fd ff ff       	call   80128e <fd_lookup>
  801508:	83 c4 08             	add    $0x8,%esp
  80150b:	89 c2                	mov    %eax,%edx
  80150d:	85 c0                	test   %eax,%eax
  80150f:	78 6d                	js     80157e <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801511:	83 ec 08             	sub    $0x8,%esp
  801514:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801517:	50                   	push   %eax
  801518:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80151b:	ff 30                	pushl  (%eax)
  80151d:	e8 c2 fd ff ff       	call   8012e4 <dev_lookup>
  801522:	83 c4 10             	add    $0x10,%esp
  801525:	85 c0                	test   %eax,%eax
  801527:	78 4c                	js     801575 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801529:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80152c:	8b 42 08             	mov    0x8(%edx),%eax
  80152f:	83 e0 03             	and    $0x3,%eax
  801532:	83 f8 01             	cmp    $0x1,%eax
  801535:	75 21                	jne    801558 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801537:	a1 04 40 80 00       	mov    0x804004,%eax
  80153c:	8b 40 48             	mov    0x48(%eax),%eax
  80153f:	83 ec 04             	sub    $0x4,%esp
  801542:	53                   	push   %ebx
  801543:	50                   	push   %eax
  801544:	68 b5 28 80 00       	push   $0x8028b5
  801549:	e8 23 ee ff ff       	call   800371 <cprintf>
		return -E_INVAL;
  80154e:	83 c4 10             	add    $0x10,%esp
  801551:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801556:	eb 26                	jmp    80157e <read+0x8a>
	}
	if (!dev->dev_read)
  801558:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80155b:	8b 40 08             	mov    0x8(%eax),%eax
  80155e:	85 c0                	test   %eax,%eax
  801560:	74 17                	je     801579 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801562:	83 ec 04             	sub    $0x4,%esp
  801565:	ff 75 10             	pushl  0x10(%ebp)
  801568:	ff 75 0c             	pushl  0xc(%ebp)
  80156b:	52                   	push   %edx
  80156c:	ff d0                	call   *%eax
  80156e:	89 c2                	mov    %eax,%edx
  801570:	83 c4 10             	add    $0x10,%esp
  801573:	eb 09                	jmp    80157e <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801575:	89 c2                	mov    %eax,%edx
  801577:	eb 05                	jmp    80157e <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801579:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80157e:	89 d0                	mov    %edx,%eax
  801580:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801583:	c9                   	leave  
  801584:	c3                   	ret    

00801585 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801585:	55                   	push   %ebp
  801586:	89 e5                	mov    %esp,%ebp
  801588:	57                   	push   %edi
  801589:	56                   	push   %esi
  80158a:	53                   	push   %ebx
  80158b:	83 ec 0c             	sub    $0xc,%esp
  80158e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801591:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801594:	bb 00 00 00 00       	mov    $0x0,%ebx
  801599:	eb 21                	jmp    8015bc <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80159b:	83 ec 04             	sub    $0x4,%esp
  80159e:	89 f0                	mov    %esi,%eax
  8015a0:	29 d8                	sub    %ebx,%eax
  8015a2:	50                   	push   %eax
  8015a3:	89 d8                	mov    %ebx,%eax
  8015a5:	03 45 0c             	add    0xc(%ebp),%eax
  8015a8:	50                   	push   %eax
  8015a9:	57                   	push   %edi
  8015aa:	e8 45 ff ff ff       	call   8014f4 <read>
		if (m < 0)
  8015af:	83 c4 10             	add    $0x10,%esp
  8015b2:	85 c0                	test   %eax,%eax
  8015b4:	78 10                	js     8015c6 <readn+0x41>
			return m;
		if (m == 0)
  8015b6:	85 c0                	test   %eax,%eax
  8015b8:	74 0a                	je     8015c4 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015ba:	01 c3                	add    %eax,%ebx
  8015bc:	39 f3                	cmp    %esi,%ebx
  8015be:	72 db                	jb     80159b <readn+0x16>
  8015c0:	89 d8                	mov    %ebx,%eax
  8015c2:	eb 02                	jmp    8015c6 <readn+0x41>
  8015c4:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8015c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015c9:	5b                   	pop    %ebx
  8015ca:	5e                   	pop    %esi
  8015cb:	5f                   	pop    %edi
  8015cc:	5d                   	pop    %ebp
  8015cd:	c3                   	ret    

008015ce <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015ce:	55                   	push   %ebp
  8015cf:	89 e5                	mov    %esp,%ebp
  8015d1:	53                   	push   %ebx
  8015d2:	83 ec 14             	sub    $0x14,%esp
  8015d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015d8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015db:	50                   	push   %eax
  8015dc:	53                   	push   %ebx
  8015dd:	e8 ac fc ff ff       	call   80128e <fd_lookup>
  8015e2:	83 c4 08             	add    $0x8,%esp
  8015e5:	89 c2                	mov    %eax,%edx
  8015e7:	85 c0                	test   %eax,%eax
  8015e9:	78 68                	js     801653 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015eb:	83 ec 08             	sub    $0x8,%esp
  8015ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015f1:	50                   	push   %eax
  8015f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015f5:	ff 30                	pushl  (%eax)
  8015f7:	e8 e8 fc ff ff       	call   8012e4 <dev_lookup>
  8015fc:	83 c4 10             	add    $0x10,%esp
  8015ff:	85 c0                	test   %eax,%eax
  801601:	78 47                	js     80164a <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801603:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801606:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80160a:	75 21                	jne    80162d <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80160c:	a1 04 40 80 00       	mov    0x804004,%eax
  801611:	8b 40 48             	mov    0x48(%eax),%eax
  801614:	83 ec 04             	sub    $0x4,%esp
  801617:	53                   	push   %ebx
  801618:	50                   	push   %eax
  801619:	68 d1 28 80 00       	push   $0x8028d1
  80161e:	e8 4e ed ff ff       	call   800371 <cprintf>
		return -E_INVAL;
  801623:	83 c4 10             	add    $0x10,%esp
  801626:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80162b:	eb 26                	jmp    801653 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80162d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801630:	8b 52 0c             	mov    0xc(%edx),%edx
  801633:	85 d2                	test   %edx,%edx
  801635:	74 17                	je     80164e <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801637:	83 ec 04             	sub    $0x4,%esp
  80163a:	ff 75 10             	pushl  0x10(%ebp)
  80163d:	ff 75 0c             	pushl  0xc(%ebp)
  801640:	50                   	push   %eax
  801641:	ff d2                	call   *%edx
  801643:	89 c2                	mov    %eax,%edx
  801645:	83 c4 10             	add    $0x10,%esp
  801648:	eb 09                	jmp    801653 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80164a:	89 c2                	mov    %eax,%edx
  80164c:	eb 05                	jmp    801653 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80164e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801653:	89 d0                	mov    %edx,%eax
  801655:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801658:	c9                   	leave  
  801659:	c3                   	ret    

0080165a <seek>:

int
seek(int fdnum, off_t offset)
{
  80165a:	55                   	push   %ebp
  80165b:	89 e5                	mov    %esp,%ebp
  80165d:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801660:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801663:	50                   	push   %eax
  801664:	ff 75 08             	pushl  0x8(%ebp)
  801667:	e8 22 fc ff ff       	call   80128e <fd_lookup>
  80166c:	83 c4 08             	add    $0x8,%esp
  80166f:	85 c0                	test   %eax,%eax
  801671:	78 0e                	js     801681 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801673:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801676:	8b 55 0c             	mov    0xc(%ebp),%edx
  801679:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80167c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801681:	c9                   	leave  
  801682:	c3                   	ret    

00801683 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801683:	55                   	push   %ebp
  801684:	89 e5                	mov    %esp,%ebp
  801686:	53                   	push   %ebx
  801687:	83 ec 14             	sub    $0x14,%esp
  80168a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80168d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801690:	50                   	push   %eax
  801691:	53                   	push   %ebx
  801692:	e8 f7 fb ff ff       	call   80128e <fd_lookup>
  801697:	83 c4 08             	add    $0x8,%esp
  80169a:	89 c2                	mov    %eax,%edx
  80169c:	85 c0                	test   %eax,%eax
  80169e:	78 65                	js     801705 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a0:	83 ec 08             	sub    $0x8,%esp
  8016a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a6:	50                   	push   %eax
  8016a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016aa:	ff 30                	pushl  (%eax)
  8016ac:	e8 33 fc ff ff       	call   8012e4 <dev_lookup>
  8016b1:	83 c4 10             	add    $0x10,%esp
  8016b4:	85 c0                	test   %eax,%eax
  8016b6:	78 44                	js     8016fc <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016bb:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016bf:	75 21                	jne    8016e2 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016c1:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016c6:	8b 40 48             	mov    0x48(%eax),%eax
  8016c9:	83 ec 04             	sub    $0x4,%esp
  8016cc:	53                   	push   %ebx
  8016cd:	50                   	push   %eax
  8016ce:	68 94 28 80 00       	push   $0x802894
  8016d3:	e8 99 ec ff ff       	call   800371 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016d8:	83 c4 10             	add    $0x10,%esp
  8016db:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016e0:	eb 23                	jmp    801705 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8016e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016e5:	8b 52 18             	mov    0x18(%edx),%edx
  8016e8:	85 d2                	test   %edx,%edx
  8016ea:	74 14                	je     801700 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016ec:	83 ec 08             	sub    $0x8,%esp
  8016ef:	ff 75 0c             	pushl  0xc(%ebp)
  8016f2:	50                   	push   %eax
  8016f3:	ff d2                	call   *%edx
  8016f5:	89 c2                	mov    %eax,%edx
  8016f7:	83 c4 10             	add    $0x10,%esp
  8016fa:	eb 09                	jmp    801705 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016fc:	89 c2                	mov    %eax,%edx
  8016fe:	eb 05                	jmp    801705 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801700:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801705:	89 d0                	mov    %edx,%eax
  801707:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80170a:	c9                   	leave  
  80170b:	c3                   	ret    

0080170c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80170c:	55                   	push   %ebp
  80170d:	89 e5                	mov    %esp,%ebp
  80170f:	53                   	push   %ebx
  801710:	83 ec 14             	sub    $0x14,%esp
  801713:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801716:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801719:	50                   	push   %eax
  80171a:	ff 75 08             	pushl  0x8(%ebp)
  80171d:	e8 6c fb ff ff       	call   80128e <fd_lookup>
  801722:	83 c4 08             	add    $0x8,%esp
  801725:	89 c2                	mov    %eax,%edx
  801727:	85 c0                	test   %eax,%eax
  801729:	78 58                	js     801783 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80172b:	83 ec 08             	sub    $0x8,%esp
  80172e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801731:	50                   	push   %eax
  801732:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801735:	ff 30                	pushl  (%eax)
  801737:	e8 a8 fb ff ff       	call   8012e4 <dev_lookup>
  80173c:	83 c4 10             	add    $0x10,%esp
  80173f:	85 c0                	test   %eax,%eax
  801741:	78 37                	js     80177a <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801743:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801746:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80174a:	74 32                	je     80177e <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80174c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80174f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801756:	00 00 00 
	stat->st_isdir = 0;
  801759:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801760:	00 00 00 
	stat->st_dev = dev;
  801763:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801769:	83 ec 08             	sub    $0x8,%esp
  80176c:	53                   	push   %ebx
  80176d:	ff 75 f0             	pushl  -0x10(%ebp)
  801770:	ff 50 14             	call   *0x14(%eax)
  801773:	89 c2                	mov    %eax,%edx
  801775:	83 c4 10             	add    $0x10,%esp
  801778:	eb 09                	jmp    801783 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80177a:	89 c2                	mov    %eax,%edx
  80177c:	eb 05                	jmp    801783 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80177e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801783:	89 d0                	mov    %edx,%eax
  801785:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801788:	c9                   	leave  
  801789:	c3                   	ret    

0080178a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80178a:	55                   	push   %ebp
  80178b:	89 e5                	mov    %esp,%ebp
  80178d:	56                   	push   %esi
  80178e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80178f:	83 ec 08             	sub    $0x8,%esp
  801792:	6a 00                	push   $0x0
  801794:	ff 75 08             	pushl  0x8(%ebp)
  801797:	e8 e3 01 00 00       	call   80197f <open>
  80179c:	89 c3                	mov    %eax,%ebx
  80179e:	83 c4 10             	add    $0x10,%esp
  8017a1:	85 c0                	test   %eax,%eax
  8017a3:	78 1b                	js     8017c0 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017a5:	83 ec 08             	sub    $0x8,%esp
  8017a8:	ff 75 0c             	pushl  0xc(%ebp)
  8017ab:	50                   	push   %eax
  8017ac:	e8 5b ff ff ff       	call   80170c <fstat>
  8017b1:	89 c6                	mov    %eax,%esi
	close(fd);
  8017b3:	89 1c 24             	mov    %ebx,(%esp)
  8017b6:	e8 fd fb ff ff       	call   8013b8 <close>
	return r;
  8017bb:	83 c4 10             	add    $0x10,%esp
  8017be:	89 f0                	mov    %esi,%eax
}
  8017c0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017c3:	5b                   	pop    %ebx
  8017c4:	5e                   	pop    %esi
  8017c5:	5d                   	pop    %ebp
  8017c6:	c3                   	ret    

008017c7 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017c7:	55                   	push   %ebp
  8017c8:	89 e5                	mov    %esp,%ebp
  8017ca:	56                   	push   %esi
  8017cb:	53                   	push   %ebx
  8017cc:	89 c6                	mov    %eax,%esi
  8017ce:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017d0:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017d7:	75 12                	jne    8017eb <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017d9:	83 ec 0c             	sub    $0xc,%esp
  8017dc:	6a 01                	push   $0x1
  8017de:	e8 54 08 00 00       	call   802037 <ipc_find_env>
  8017e3:	a3 00 40 80 00       	mov    %eax,0x804000
  8017e8:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017eb:	6a 07                	push   $0x7
  8017ed:	68 00 50 80 00       	push   $0x805000
  8017f2:	56                   	push   %esi
  8017f3:	ff 35 00 40 80 00    	pushl  0x804000
  8017f9:	e8 e5 07 00 00       	call   801fe3 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017fe:	83 c4 0c             	add    $0xc,%esp
  801801:	6a 00                	push   $0x0
  801803:	53                   	push   %ebx
  801804:	6a 00                	push   $0x0
  801806:	e8 83 07 00 00       	call   801f8e <ipc_recv>
}
  80180b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80180e:	5b                   	pop    %ebx
  80180f:	5e                   	pop    %esi
  801810:	5d                   	pop    %ebp
  801811:	c3                   	ret    

00801812 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801812:	55                   	push   %ebp
  801813:	89 e5                	mov    %esp,%ebp
  801815:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801818:	8b 45 08             	mov    0x8(%ebp),%eax
  80181b:	8b 40 0c             	mov    0xc(%eax),%eax
  80181e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801823:	8b 45 0c             	mov    0xc(%ebp),%eax
  801826:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80182b:	ba 00 00 00 00       	mov    $0x0,%edx
  801830:	b8 02 00 00 00       	mov    $0x2,%eax
  801835:	e8 8d ff ff ff       	call   8017c7 <fsipc>
}
  80183a:	c9                   	leave  
  80183b:	c3                   	ret    

0080183c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80183c:	55                   	push   %ebp
  80183d:	89 e5                	mov    %esp,%ebp
  80183f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801842:	8b 45 08             	mov    0x8(%ebp),%eax
  801845:	8b 40 0c             	mov    0xc(%eax),%eax
  801848:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80184d:	ba 00 00 00 00       	mov    $0x0,%edx
  801852:	b8 06 00 00 00       	mov    $0x6,%eax
  801857:	e8 6b ff ff ff       	call   8017c7 <fsipc>
}
  80185c:	c9                   	leave  
  80185d:	c3                   	ret    

0080185e <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80185e:	55                   	push   %ebp
  80185f:	89 e5                	mov    %esp,%ebp
  801861:	53                   	push   %ebx
  801862:	83 ec 04             	sub    $0x4,%esp
  801865:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801868:	8b 45 08             	mov    0x8(%ebp),%eax
  80186b:	8b 40 0c             	mov    0xc(%eax),%eax
  80186e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801873:	ba 00 00 00 00       	mov    $0x0,%edx
  801878:	b8 05 00 00 00       	mov    $0x5,%eax
  80187d:	e8 45 ff ff ff       	call   8017c7 <fsipc>
  801882:	85 c0                	test   %eax,%eax
  801884:	78 2c                	js     8018b2 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801886:	83 ec 08             	sub    $0x8,%esp
  801889:	68 00 50 80 00       	push   $0x805000
  80188e:	53                   	push   %ebx
  80188f:	e8 80 f0 ff ff       	call   800914 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801894:	a1 80 50 80 00       	mov    0x805080,%eax
  801899:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80189f:	a1 84 50 80 00       	mov    0x805084,%eax
  8018a4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018aa:	83 c4 10             	add    $0x10,%esp
  8018ad:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018b5:	c9                   	leave  
  8018b6:	c3                   	ret    

008018b7 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018b7:	55                   	push   %ebp
  8018b8:	89 e5                	mov    %esp,%ebp
  8018ba:	83 ec 0c             	sub    $0xc,%esp
  8018bd:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
    
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8018c3:	8b 52 0c             	mov    0xc(%edx),%edx
  8018c6:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = MIN(n, PGSIZE);
  8018cc:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018d1:	ba 00 10 00 00       	mov    $0x1000,%edx
  8018d6:	0f 47 c2             	cmova  %edx,%eax
  8018d9:	a3 04 50 80 00       	mov    %eax,0x805004
    memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8018de:	50                   	push   %eax
  8018df:	ff 75 0c             	pushl  0xc(%ebp)
  8018e2:	68 08 50 80 00       	push   $0x805008
  8018e7:	e8 ba f1 ff ff       	call   800aa6 <memmove>
    int r = fsipc(FSREQ_WRITE, NULL);
  8018ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8018f1:	b8 04 00 00 00       	mov    $0x4,%eax
  8018f6:	e8 cc fe ff ff       	call   8017c7 <fsipc>
    return r;
}
  8018fb:	c9                   	leave  
  8018fc:	c3                   	ret    

008018fd <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018fd:	55                   	push   %ebp
  8018fe:	89 e5                	mov    %esp,%ebp
  801900:	56                   	push   %esi
  801901:	53                   	push   %ebx
  801902:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801905:	8b 45 08             	mov    0x8(%ebp),%eax
  801908:	8b 40 0c             	mov    0xc(%eax),%eax
  80190b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801910:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801916:	ba 00 00 00 00       	mov    $0x0,%edx
  80191b:	b8 03 00 00 00       	mov    $0x3,%eax
  801920:	e8 a2 fe ff ff       	call   8017c7 <fsipc>
  801925:	89 c3                	mov    %eax,%ebx
  801927:	85 c0                	test   %eax,%eax
  801929:	78 4b                	js     801976 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80192b:	39 c6                	cmp    %eax,%esi
  80192d:	73 16                	jae    801945 <devfile_read+0x48>
  80192f:	68 00 29 80 00       	push   $0x802900
  801934:	68 07 29 80 00       	push   $0x802907
  801939:	6a 7c                	push   $0x7c
  80193b:	68 1c 29 80 00       	push   $0x80291c
  801940:	e8 53 e9 ff ff       	call   800298 <_panic>
	assert(r <= PGSIZE);
  801945:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80194a:	7e 16                	jle    801962 <devfile_read+0x65>
  80194c:	68 27 29 80 00       	push   $0x802927
  801951:	68 07 29 80 00       	push   $0x802907
  801956:	6a 7d                	push   $0x7d
  801958:	68 1c 29 80 00       	push   $0x80291c
  80195d:	e8 36 e9 ff ff       	call   800298 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801962:	83 ec 04             	sub    $0x4,%esp
  801965:	50                   	push   %eax
  801966:	68 00 50 80 00       	push   $0x805000
  80196b:	ff 75 0c             	pushl  0xc(%ebp)
  80196e:	e8 33 f1 ff ff       	call   800aa6 <memmove>
	return r;
  801973:	83 c4 10             	add    $0x10,%esp
}
  801976:	89 d8                	mov    %ebx,%eax
  801978:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80197b:	5b                   	pop    %ebx
  80197c:	5e                   	pop    %esi
  80197d:	5d                   	pop    %ebp
  80197e:	c3                   	ret    

0080197f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80197f:	55                   	push   %ebp
  801980:	89 e5                	mov    %esp,%ebp
  801982:	53                   	push   %ebx
  801983:	83 ec 20             	sub    $0x20,%esp
  801986:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801989:	53                   	push   %ebx
  80198a:	e8 4c ef ff ff       	call   8008db <strlen>
  80198f:	83 c4 10             	add    $0x10,%esp
  801992:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801997:	7f 67                	jg     801a00 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801999:	83 ec 0c             	sub    $0xc,%esp
  80199c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80199f:	50                   	push   %eax
  8019a0:	e8 9a f8 ff ff       	call   80123f <fd_alloc>
  8019a5:	83 c4 10             	add    $0x10,%esp
		return r;
  8019a8:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019aa:	85 c0                	test   %eax,%eax
  8019ac:	78 57                	js     801a05 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019ae:	83 ec 08             	sub    $0x8,%esp
  8019b1:	53                   	push   %ebx
  8019b2:	68 00 50 80 00       	push   $0x805000
  8019b7:	e8 58 ef ff ff       	call   800914 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019bf:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019c4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019c7:	b8 01 00 00 00       	mov    $0x1,%eax
  8019cc:	e8 f6 fd ff ff       	call   8017c7 <fsipc>
  8019d1:	89 c3                	mov    %eax,%ebx
  8019d3:	83 c4 10             	add    $0x10,%esp
  8019d6:	85 c0                	test   %eax,%eax
  8019d8:	79 14                	jns    8019ee <open+0x6f>
		fd_close(fd, 0);
  8019da:	83 ec 08             	sub    $0x8,%esp
  8019dd:	6a 00                	push   $0x0
  8019df:	ff 75 f4             	pushl  -0xc(%ebp)
  8019e2:	e8 50 f9 ff ff       	call   801337 <fd_close>
		return r;
  8019e7:	83 c4 10             	add    $0x10,%esp
  8019ea:	89 da                	mov    %ebx,%edx
  8019ec:	eb 17                	jmp    801a05 <open+0x86>
	}

	return fd2num(fd);
  8019ee:	83 ec 0c             	sub    $0xc,%esp
  8019f1:	ff 75 f4             	pushl  -0xc(%ebp)
  8019f4:	e8 1f f8 ff ff       	call   801218 <fd2num>
  8019f9:	89 c2                	mov    %eax,%edx
  8019fb:	83 c4 10             	add    $0x10,%esp
  8019fe:	eb 05                	jmp    801a05 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a00:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a05:	89 d0                	mov    %edx,%eax
  801a07:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a0a:	c9                   	leave  
  801a0b:	c3                   	ret    

00801a0c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a0c:	55                   	push   %ebp
  801a0d:	89 e5                	mov    %esp,%ebp
  801a0f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a12:	ba 00 00 00 00       	mov    $0x0,%edx
  801a17:	b8 08 00 00 00       	mov    $0x8,%eax
  801a1c:	e8 a6 fd ff ff       	call   8017c7 <fsipc>
}
  801a21:	c9                   	leave  
  801a22:	c3                   	ret    

00801a23 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a23:	55                   	push   %ebp
  801a24:	89 e5                	mov    %esp,%ebp
  801a26:	56                   	push   %esi
  801a27:	53                   	push   %ebx
  801a28:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a2b:	83 ec 0c             	sub    $0xc,%esp
  801a2e:	ff 75 08             	pushl  0x8(%ebp)
  801a31:	e8 f2 f7 ff ff       	call   801228 <fd2data>
  801a36:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a38:	83 c4 08             	add    $0x8,%esp
  801a3b:	68 33 29 80 00       	push   $0x802933
  801a40:	53                   	push   %ebx
  801a41:	e8 ce ee ff ff       	call   800914 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a46:	8b 46 04             	mov    0x4(%esi),%eax
  801a49:	2b 06                	sub    (%esi),%eax
  801a4b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a51:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a58:	00 00 00 
	stat->st_dev = &devpipe;
  801a5b:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a62:	30 80 00 
	return 0;
}
  801a65:	b8 00 00 00 00       	mov    $0x0,%eax
  801a6a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a6d:	5b                   	pop    %ebx
  801a6e:	5e                   	pop    %esi
  801a6f:	5d                   	pop    %ebp
  801a70:	c3                   	ret    

00801a71 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a71:	55                   	push   %ebp
  801a72:	89 e5                	mov    %esp,%ebp
  801a74:	53                   	push   %ebx
  801a75:	83 ec 0c             	sub    $0xc,%esp
  801a78:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a7b:	53                   	push   %ebx
  801a7c:	6a 00                	push   $0x0
  801a7e:	e8 19 f3 ff ff       	call   800d9c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a83:	89 1c 24             	mov    %ebx,(%esp)
  801a86:	e8 9d f7 ff ff       	call   801228 <fd2data>
  801a8b:	83 c4 08             	add    $0x8,%esp
  801a8e:	50                   	push   %eax
  801a8f:	6a 00                	push   $0x0
  801a91:	e8 06 f3 ff ff       	call   800d9c <sys_page_unmap>
}
  801a96:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a99:	c9                   	leave  
  801a9a:	c3                   	ret    

00801a9b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a9b:	55                   	push   %ebp
  801a9c:	89 e5                	mov    %esp,%ebp
  801a9e:	57                   	push   %edi
  801a9f:	56                   	push   %esi
  801aa0:	53                   	push   %ebx
  801aa1:	83 ec 1c             	sub    $0x1c,%esp
  801aa4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801aa7:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801aa9:	a1 04 40 80 00       	mov    0x804004,%eax
  801aae:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801ab1:	83 ec 0c             	sub    $0xc,%esp
  801ab4:	ff 75 e0             	pushl  -0x20(%ebp)
  801ab7:	e8 b4 05 00 00       	call   802070 <pageref>
  801abc:	89 c3                	mov    %eax,%ebx
  801abe:	89 3c 24             	mov    %edi,(%esp)
  801ac1:	e8 aa 05 00 00       	call   802070 <pageref>
  801ac6:	83 c4 10             	add    $0x10,%esp
  801ac9:	39 c3                	cmp    %eax,%ebx
  801acb:	0f 94 c1             	sete   %cl
  801ace:	0f b6 c9             	movzbl %cl,%ecx
  801ad1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801ad4:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801ada:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801add:	39 ce                	cmp    %ecx,%esi
  801adf:	74 1b                	je     801afc <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801ae1:	39 c3                	cmp    %eax,%ebx
  801ae3:	75 c4                	jne    801aa9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ae5:	8b 42 58             	mov    0x58(%edx),%eax
  801ae8:	ff 75 e4             	pushl  -0x1c(%ebp)
  801aeb:	50                   	push   %eax
  801aec:	56                   	push   %esi
  801aed:	68 3a 29 80 00       	push   $0x80293a
  801af2:	e8 7a e8 ff ff       	call   800371 <cprintf>
  801af7:	83 c4 10             	add    $0x10,%esp
  801afa:	eb ad                	jmp    801aa9 <_pipeisclosed+0xe>
	}
}
  801afc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801aff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b02:	5b                   	pop    %ebx
  801b03:	5e                   	pop    %esi
  801b04:	5f                   	pop    %edi
  801b05:	5d                   	pop    %ebp
  801b06:	c3                   	ret    

00801b07 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b07:	55                   	push   %ebp
  801b08:	89 e5                	mov    %esp,%ebp
  801b0a:	57                   	push   %edi
  801b0b:	56                   	push   %esi
  801b0c:	53                   	push   %ebx
  801b0d:	83 ec 28             	sub    $0x28,%esp
  801b10:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b13:	56                   	push   %esi
  801b14:	e8 0f f7 ff ff       	call   801228 <fd2data>
  801b19:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b1b:	83 c4 10             	add    $0x10,%esp
  801b1e:	bf 00 00 00 00       	mov    $0x0,%edi
  801b23:	eb 4b                	jmp    801b70 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b25:	89 da                	mov    %ebx,%edx
  801b27:	89 f0                	mov    %esi,%eax
  801b29:	e8 6d ff ff ff       	call   801a9b <_pipeisclosed>
  801b2e:	85 c0                	test   %eax,%eax
  801b30:	75 48                	jne    801b7a <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b32:	e8 c1 f1 ff ff       	call   800cf8 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b37:	8b 43 04             	mov    0x4(%ebx),%eax
  801b3a:	8b 0b                	mov    (%ebx),%ecx
  801b3c:	8d 51 20             	lea    0x20(%ecx),%edx
  801b3f:	39 d0                	cmp    %edx,%eax
  801b41:	73 e2                	jae    801b25 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b46:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b4a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b4d:	89 c2                	mov    %eax,%edx
  801b4f:	c1 fa 1f             	sar    $0x1f,%edx
  801b52:	89 d1                	mov    %edx,%ecx
  801b54:	c1 e9 1b             	shr    $0x1b,%ecx
  801b57:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b5a:	83 e2 1f             	and    $0x1f,%edx
  801b5d:	29 ca                	sub    %ecx,%edx
  801b5f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b63:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b67:	83 c0 01             	add    $0x1,%eax
  801b6a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b6d:	83 c7 01             	add    $0x1,%edi
  801b70:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b73:	75 c2                	jne    801b37 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b75:	8b 45 10             	mov    0x10(%ebp),%eax
  801b78:	eb 05                	jmp    801b7f <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b7a:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b82:	5b                   	pop    %ebx
  801b83:	5e                   	pop    %esi
  801b84:	5f                   	pop    %edi
  801b85:	5d                   	pop    %ebp
  801b86:	c3                   	ret    

00801b87 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b87:	55                   	push   %ebp
  801b88:	89 e5                	mov    %esp,%ebp
  801b8a:	57                   	push   %edi
  801b8b:	56                   	push   %esi
  801b8c:	53                   	push   %ebx
  801b8d:	83 ec 18             	sub    $0x18,%esp
  801b90:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b93:	57                   	push   %edi
  801b94:	e8 8f f6 ff ff       	call   801228 <fd2data>
  801b99:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b9b:	83 c4 10             	add    $0x10,%esp
  801b9e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ba3:	eb 3d                	jmp    801be2 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ba5:	85 db                	test   %ebx,%ebx
  801ba7:	74 04                	je     801bad <devpipe_read+0x26>
				return i;
  801ba9:	89 d8                	mov    %ebx,%eax
  801bab:	eb 44                	jmp    801bf1 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801bad:	89 f2                	mov    %esi,%edx
  801baf:	89 f8                	mov    %edi,%eax
  801bb1:	e8 e5 fe ff ff       	call   801a9b <_pipeisclosed>
  801bb6:	85 c0                	test   %eax,%eax
  801bb8:	75 32                	jne    801bec <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801bba:	e8 39 f1 ff ff       	call   800cf8 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801bbf:	8b 06                	mov    (%esi),%eax
  801bc1:	3b 46 04             	cmp    0x4(%esi),%eax
  801bc4:	74 df                	je     801ba5 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801bc6:	99                   	cltd   
  801bc7:	c1 ea 1b             	shr    $0x1b,%edx
  801bca:	01 d0                	add    %edx,%eax
  801bcc:	83 e0 1f             	and    $0x1f,%eax
  801bcf:	29 d0                	sub    %edx,%eax
  801bd1:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801bd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bd9:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801bdc:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bdf:	83 c3 01             	add    $0x1,%ebx
  801be2:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801be5:	75 d8                	jne    801bbf <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801be7:	8b 45 10             	mov    0x10(%ebp),%eax
  801bea:	eb 05                	jmp    801bf1 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bec:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801bf1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bf4:	5b                   	pop    %ebx
  801bf5:	5e                   	pop    %esi
  801bf6:	5f                   	pop    %edi
  801bf7:	5d                   	pop    %ebp
  801bf8:	c3                   	ret    

00801bf9 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801bf9:	55                   	push   %ebp
  801bfa:	89 e5                	mov    %esp,%ebp
  801bfc:	56                   	push   %esi
  801bfd:	53                   	push   %ebx
  801bfe:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c01:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c04:	50                   	push   %eax
  801c05:	e8 35 f6 ff ff       	call   80123f <fd_alloc>
  801c0a:	83 c4 10             	add    $0x10,%esp
  801c0d:	89 c2                	mov    %eax,%edx
  801c0f:	85 c0                	test   %eax,%eax
  801c11:	0f 88 2c 01 00 00    	js     801d43 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c17:	83 ec 04             	sub    $0x4,%esp
  801c1a:	68 07 04 00 00       	push   $0x407
  801c1f:	ff 75 f4             	pushl  -0xc(%ebp)
  801c22:	6a 00                	push   $0x0
  801c24:	e8 ee f0 ff ff       	call   800d17 <sys_page_alloc>
  801c29:	83 c4 10             	add    $0x10,%esp
  801c2c:	89 c2                	mov    %eax,%edx
  801c2e:	85 c0                	test   %eax,%eax
  801c30:	0f 88 0d 01 00 00    	js     801d43 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c36:	83 ec 0c             	sub    $0xc,%esp
  801c39:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c3c:	50                   	push   %eax
  801c3d:	e8 fd f5 ff ff       	call   80123f <fd_alloc>
  801c42:	89 c3                	mov    %eax,%ebx
  801c44:	83 c4 10             	add    $0x10,%esp
  801c47:	85 c0                	test   %eax,%eax
  801c49:	0f 88 e2 00 00 00    	js     801d31 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c4f:	83 ec 04             	sub    $0x4,%esp
  801c52:	68 07 04 00 00       	push   $0x407
  801c57:	ff 75 f0             	pushl  -0x10(%ebp)
  801c5a:	6a 00                	push   $0x0
  801c5c:	e8 b6 f0 ff ff       	call   800d17 <sys_page_alloc>
  801c61:	89 c3                	mov    %eax,%ebx
  801c63:	83 c4 10             	add    $0x10,%esp
  801c66:	85 c0                	test   %eax,%eax
  801c68:	0f 88 c3 00 00 00    	js     801d31 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c6e:	83 ec 0c             	sub    $0xc,%esp
  801c71:	ff 75 f4             	pushl  -0xc(%ebp)
  801c74:	e8 af f5 ff ff       	call   801228 <fd2data>
  801c79:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c7b:	83 c4 0c             	add    $0xc,%esp
  801c7e:	68 07 04 00 00       	push   $0x407
  801c83:	50                   	push   %eax
  801c84:	6a 00                	push   $0x0
  801c86:	e8 8c f0 ff ff       	call   800d17 <sys_page_alloc>
  801c8b:	89 c3                	mov    %eax,%ebx
  801c8d:	83 c4 10             	add    $0x10,%esp
  801c90:	85 c0                	test   %eax,%eax
  801c92:	0f 88 89 00 00 00    	js     801d21 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c98:	83 ec 0c             	sub    $0xc,%esp
  801c9b:	ff 75 f0             	pushl  -0x10(%ebp)
  801c9e:	e8 85 f5 ff ff       	call   801228 <fd2data>
  801ca3:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801caa:	50                   	push   %eax
  801cab:	6a 00                	push   $0x0
  801cad:	56                   	push   %esi
  801cae:	6a 00                	push   $0x0
  801cb0:	e8 a5 f0 ff ff       	call   800d5a <sys_page_map>
  801cb5:	89 c3                	mov    %eax,%ebx
  801cb7:	83 c4 20             	add    $0x20,%esp
  801cba:	85 c0                	test   %eax,%eax
  801cbc:	78 55                	js     801d13 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801cbe:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cc7:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801cc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ccc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801cd3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cd9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cdc:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801cde:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ce1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801ce8:	83 ec 0c             	sub    $0xc,%esp
  801ceb:	ff 75 f4             	pushl  -0xc(%ebp)
  801cee:	e8 25 f5 ff ff       	call   801218 <fd2num>
  801cf3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cf6:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801cf8:	83 c4 04             	add    $0x4,%esp
  801cfb:	ff 75 f0             	pushl  -0x10(%ebp)
  801cfe:	e8 15 f5 ff ff       	call   801218 <fd2num>
  801d03:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d06:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d09:	83 c4 10             	add    $0x10,%esp
  801d0c:	ba 00 00 00 00       	mov    $0x0,%edx
  801d11:	eb 30                	jmp    801d43 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d13:	83 ec 08             	sub    $0x8,%esp
  801d16:	56                   	push   %esi
  801d17:	6a 00                	push   $0x0
  801d19:	e8 7e f0 ff ff       	call   800d9c <sys_page_unmap>
  801d1e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d21:	83 ec 08             	sub    $0x8,%esp
  801d24:	ff 75 f0             	pushl  -0x10(%ebp)
  801d27:	6a 00                	push   $0x0
  801d29:	e8 6e f0 ff ff       	call   800d9c <sys_page_unmap>
  801d2e:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d31:	83 ec 08             	sub    $0x8,%esp
  801d34:	ff 75 f4             	pushl  -0xc(%ebp)
  801d37:	6a 00                	push   $0x0
  801d39:	e8 5e f0 ff ff       	call   800d9c <sys_page_unmap>
  801d3e:	83 c4 10             	add    $0x10,%esp
  801d41:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d43:	89 d0                	mov    %edx,%eax
  801d45:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d48:	5b                   	pop    %ebx
  801d49:	5e                   	pop    %esi
  801d4a:	5d                   	pop    %ebp
  801d4b:	c3                   	ret    

00801d4c <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d4c:	55                   	push   %ebp
  801d4d:	89 e5                	mov    %esp,%ebp
  801d4f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d52:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d55:	50                   	push   %eax
  801d56:	ff 75 08             	pushl  0x8(%ebp)
  801d59:	e8 30 f5 ff ff       	call   80128e <fd_lookup>
  801d5e:	83 c4 10             	add    $0x10,%esp
  801d61:	85 c0                	test   %eax,%eax
  801d63:	78 18                	js     801d7d <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d65:	83 ec 0c             	sub    $0xc,%esp
  801d68:	ff 75 f4             	pushl  -0xc(%ebp)
  801d6b:	e8 b8 f4 ff ff       	call   801228 <fd2data>
	return _pipeisclosed(fd, p);
  801d70:	89 c2                	mov    %eax,%edx
  801d72:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d75:	e8 21 fd ff ff       	call   801a9b <_pipeisclosed>
  801d7a:	83 c4 10             	add    $0x10,%esp
}
  801d7d:	c9                   	leave  
  801d7e:	c3                   	ret    

00801d7f <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d7f:	55                   	push   %ebp
  801d80:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d82:	b8 00 00 00 00       	mov    $0x0,%eax
  801d87:	5d                   	pop    %ebp
  801d88:	c3                   	ret    

00801d89 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d89:	55                   	push   %ebp
  801d8a:	89 e5                	mov    %esp,%ebp
  801d8c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d8f:	68 4d 29 80 00       	push   $0x80294d
  801d94:	ff 75 0c             	pushl  0xc(%ebp)
  801d97:	e8 78 eb ff ff       	call   800914 <strcpy>
	return 0;
}
  801d9c:	b8 00 00 00 00       	mov    $0x0,%eax
  801da1:	c9                   	leave  
  801da2:	c3                   	ret    

00801da3 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801da3:	55                   	push   %ebp
  801da4:	89 e5                	mov    %esp,%ebp
  801da6:	57                   	push   %edi
  801da7:	56                   	push   %esi
  801da8:	53                   	push   %ebx
  801da9:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801daf:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801db4:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dba:	eb 2d                	jmp    801de9 <devcons_write+0x46>
		m = n - tot;
  801dbc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801dbf:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801dc1:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801dc4:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801dc9:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801dcc:	83 ec 04             	sub    $0x4,%esp
  801dcf:	53                   	push   %ebx
  801dd0:	03 45 0c             	add    0xc(%ebp),%eax
  801dd3:	50                   	push   %eax
  801dd4:	57                   	push   %edi
  801dd5:	e8 cc ec ff ff       	call   800aa6 <memmove>
		sys_cputs(buf, m);
  801dda:	83 c4 08             	add    $0x8,%esp
  801ddd:	53                   	push   %ebx
  801dde:	57                   	push   %edi
  801ddf:	e8 77 ee ff ff       	call   800c5b <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801de4:	01 de                	add    %ebx,%esi
  801de6:	83 c4 10             	add    $0x10,%esp
  801de9:	89 f0                	mov    %esi,%eax
  801deb:	3b 75 10             	cmp    0x10(%ebp),%esi
  801dee:	72 cc                	jb     801dbc <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801df0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801df3:	5b                   	pop    %ebx
  801df4:	5e                   	pop    %esi
  801df5:	5f                   	pop    %edi
  801df6:	5d                   	pop    %ebp
  801df7:	c3                   	ret    

00801df8 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801df8:	55                   	push   %ebp
  801df9:	89 e5                	mov    %esp,%ebp
  801dfb:	83 ec 08             	sub    $0x8,%esp
  801dfe:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e03:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e07:	74 2a                	je     801e33 <devcons_read+0x3b>
  801e09:	eb 05                	jmp    801e10 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e0b:	e8 e8 ee ff ff       	call   800cf8 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e10:	e8 64 ee ff ff       	call   800c79 <sys_cgetc>
  801e15:	85 c0                	test   %eax,%eax
  801e17:	74 f2                	je     801e0b <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e19:	85 c0                	test   %eax,%eax
  801e1b:	78 16                	js     801e33 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e1d:	83 f8 04             	cmp    $0x4,%eax
  801e20:	74 0c                	je     801e2e <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e22:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e25:	88 02                	mov    %al,(%edx)
	return 1;
  801e27:	b8 01 00 00 00       	mov    $0x1,%eax
  801e2c:	eb 05                	jmp    801e33 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e2e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e33:	c9                   	leave  
  801e34:	c3                   	ret    

00801e35 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e35:	55                   	push   %ebp
  801e36:	89 e5                	mov    %esp,%ebp
  801e38:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e3b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e3e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e41:	6a 01                	push   $0x1
  801e43:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e46:	50                   	push   %eax
  801e47:	e8 0f ee ff ff       	call   800c5b <sys_cputs>
}
  801e4c:	83 c4 10             	add    $0x10,%esp
  801e4f:	c9                   	leave  
  801e50:	c3                   	ret    

00801e51 <getchar>:

int
getchar(void)
{
  801e51:	55                   	push   %ebp
  801e52:	89 e5                	mov    %esp,%ebp
  801e54:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e57:	6a 01                	push   $0x1
  801e59:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e5c:	50                   	push   %eax
  801e5d:	6a 00                	push   $0x0
  801e5f:	e8 90 f6 ff ff       	call   8014f4 <read>
	if (r < 0)
  801e64:	83 c4 10             	add    $0x10,%esp
  801e67:	85 c0                	test   %eax,%eax
  801e69:	78 0f                	js     801e7a <getchar+0x29>
		return r;
	if (r < 1)
  801e6b:	85 c0                	test   %eax,%eax
  801e6d:	7e 06                	jle    801e75 <getchar+0x24>
		return -E_EOF;
	return c;
  801e6f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e73:	eb 05                	jmp    801e7a <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e75:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e7a:	c9                   	leave  
  801e7b:	c3                   	ret    

00801e7c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e7c:	55                   	push   %ebp
  801e7d:	89 e5                	mov    %esp,%ebp
  801e7f:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e82:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e85:	50                   	push   %eax
  801e86:	ff 75 08             	pushl  0x8(%ebp)
  801e89:	e8 00 f4 ff ff       	call   80128e <fd_lookup>
  801e8e:	83 c4 10             	add    $0x10,%esp
  801e91:	85 c0                	test   %eax,%eax
  801e93:	78 11                	js     801ea6 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e95:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e98:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e9e:	39 10                	cmp    %edx,(%eax)
  801ea0:	0f 94 c0             	sete   %al
  801ea3:	0f b6 c0             	movzbl %al,%eax
}
  801ea6:	c9                   	leave  
  801ea7:	c3                   	ret    

00801ea8 <opencons>:

int
opencons(void)
{
  801ea8:	55                   	push   %ebp
  801ea9:	89 e5                	mov    %esp,%ebp
  801eab:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801eae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eb1:	50                   	push   %eax
  801eb2:	e8 88 f3 ff ff       	call   80123f <fd_alloc>
  801eb7:	83 c4 10             	add    $0x10,%esp
		return r;
  801eba:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ebc:	85 c0                	test   %eax,%eax
  801ebe:	78 3e                	js     801efe <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ec0:	83 ec 04             	sub    $0x4,%esp
  801ec3:	68 07 04 00 00       	push   $0x407
  801ec8:	ff 75 f4             	pushl  -0xc(%ebp)
  801ecb:	6a 00                	push   $0x0
  801ecd:	e8 45 ee ff ff       	call   800d17 <sys_page_alloc>
  801ed2:	83 c4 10             	add    $0x10,%esp
		return r;
  801ed5:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ed7:	85 c0                	test   %eax,%eax
  801ed9:	78 23                	js     801efe <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801edb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ee1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ee4:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ee6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ee9:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ef0:	83 ec 0c             	sub    $0xc,%esp
  801ef3:	50                   	push   %eax
  801ef4:	e8 1f f3 ff ff       	call   801218 <fd2num>
  801ef9:	89 c2                	mov    %eax,%edx
  801efb:	83 c4 10             	add    $0x10,%esp
}
  801efe:	89 d0                	mov    %edx,%eax
  801f00:	c9                   	leave  
  801f01:	c3                   	ret    

00801f02 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f02:	55                   	push   %ebp
  801f03:	89 e5                	mov    %esp,%ebp
  801f05:	83 ec 08             	sub    $0x8,%esp
	int r;
	int ret;
	if (_pgfault_handler == 0) {
  801f08:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f0f:	75 36                	jne    801f47 <set_pgfault_handler+0x45>
		// First time through!
		// LAB 4: Your code here.
        
        	ret = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  801f11:	a1 04 40 80 00       	mov    0x804004,%eax
  801f16:	8b 40 48             	mov    0x48(%eax),%eax
  801f19:	83 ec 04             	sub    $0x4,%esp
  801f1c:	68 07 0e 00 00       	push   $0xe07
  801f21:	68 00 f0 bf ee       	push   $0xeebff000
  801f26:	50                   	push   %eax
  801f27:	e8 eb ed ff ff       	call   800d17 <sys_page_alloc>
		if (ret < 0) {
  801f2c:	83 c4 10             	add    $0x10,%esp
  801f2f:	85 c0                	test   %eax,%eax
  801f31:	79 14                	jns    801f47 <set_pgfault_handler+0x45>
		    panic("Allocate user exception stack failed!\n");
  801f33:	83 ec 04             	sub    $0x4,%esp
  801f36:	68 5c 29 80 00       	push   $0x80295c
  801f3b:	6a 23                	push   $0x23
  801f3d:	68 84 29 80 00       	push   $0x802984
  801f42:	e8 51 e3 ff ff       	call   800298 <_panic>
		}
	}
	sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  801f47:	a1 04 40 80 00       	mov    0x804004,%eax
  801f4c:	8b 40 48             	mov    0x48(%eax),%eax
  801f4f:	83 ec 08             	sub    $0x8,%esp
  801f52:	68 6a 1f 80 00       	push   $0x801f6a
  801f57:	50                   	push   %eax
  801f58:	e8 05 ef ff ff       	call   800e62 <sys_env_set_pgfault_upcall>
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f5d:	8b 45 08             	mov    0x8(%ebp),%eax
  801f60:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801f65:	83 c4 10             	add    $0x10,%esp
  801f68:	c9                   	leave  
  801f69:	c3                   	ret    

00801f6a <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f6a:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f6b:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f70:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f72:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 0x28(%esp), %ebx  # trap-time eip
  801f75:	8b 5c 24 28          	mov    0x28(%esp),%ebx
        subl $0x4, 0x30(%esp)  # trap-time esp minus 4
  801f79:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax 
  801f7e:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl %ebx, (%eax)      # trap-time esp store trap-time eip
  801f82:	89 18                	mov    %ebx,(%eax)
        addl $0x8, %esp
  801f84:	83 c4 08             	add    $0x8,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  801f87:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  801f88:	83 c4 04             	add    $0x4,%esp
        popfl
  801f8b:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  801f8c:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  801f8d:	c3                   	ret    

00801f8e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f8e:	55                   	push   %ebp
  801f8f:	89 e5                	mov    %esp,%ebp
  801f91:	56                   	push   %esi
  801f92:	53                   	push   %ebx
  801f93:	8b 75 08             	mov    0x8(%ebp),%esi
  801f96:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f99:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_recv not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  801f9c:	85 c0                	test   %eax,%eax
  801f9e:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801fa3:	0f 44 c2             	cmove  %edx,%eax

    int r = sys_ipc_recv(pg);
  801fa6:	83 ec 0c             	sub    $0xc,%esp
  801fa9:	50                   	push   %eax
  801faa:	e8 18 ef ff ff       	call   800ec7 <sys_ipc_recv>
    int from_env = 0, perm = 0;
    if (r == 0) {
  801faf:	83 c4 10             	add    $0x10,%esp
  801fb2:	85 c0                	test   %eax,%eax
  801fb4:	75 10                	jne    801fc6 <ipc_recv+0x38>
        from_env = thisenv->env_ipc_from;
  801fb6:	a1 04 40 80 00       	mov    0x804004,%eax
  801fbb:	8b 48 74             	mov    0x74(%eax),%ecx
        perm = thisenv->env_ipc_perm;
  801fbe:	8b 50 78             	mov    0x78(%eax),%edx
        r = thisenv->env_ipc_value;
  801fc1:	8b 40 70             	mov    0x70(%eax),%eax
  801fc4:	eb 0a                	jmp    801fd0 <ipc_recv+0x42>
    } else {
        from_env = 0;
        perm = 0;
  801fc6:	ba 00 00 00 00       	mov    $0x0,%edx
    if (r == 0) {
        from_env = thisenv->env_ipc_from;
        perm = thisenv->env_ipc_perm;
        r = thisenv->env_ipc_value;
    } else {
        from_env = 0;
  801fcb:	b9 00 00 00 00       	mov    $0x0,%ecx
        perm = 0;
    }

    if (from_env_store) *from_env_store = from_env;
  801fd0:	85 f6                	test   %esi,%esi
  801fd2:	74 02                	je     801fd6 <ipc_recv+0x48>
  801fd4:	89 0e                	mov    %ecx,(%esi)
    if (perm_store) *perm_store = perm;
  801fd6:	85 db                	test   %ebx,%ebx
  801fd8:	74 02                	je     801fdc <ipc_recv+0x4e>
  801fda:	89 13                	mov    %edx,(%ebx)

    return r;
}
  801fdc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fdf:	5b                   	pop    %ebx
  801fe0:	5e                   	pop    %esi
  801fe1:	5d                   	pop    %ebp
  801fe2:	c3                   	ret    

00801fe3 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fe3:	55                   	push   %ebp
  801fe4:	89 e5                	mov    %esp,%ebp
  801fe6:	57                   	push   %edi
  801fe7:	56                   	push   %esi
  801fe8:	53                   	push   %ebx
  801fe9:	83 ec 0c             	sub    $0xc,%esp
  801fec:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fef:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ff2:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  801ff5:	85 db                	test   %ebx,%ebx
  801ff7:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801ffc:	0f 44 d8             	cmove  %eax,%ebx
  801fff:	eb 1c                	jmp    80201d <ipc_send+0x3a>

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        if (ret != -E_IPC_NOT_RECV)
  802001:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802004:	74 12                	je     802018 <ipc_send+0x35>
            panic("ipc_send error %e", ret);
  802006:	50                   	push   %eax
  802007:	68 92 29 80 00       	push   $0x802992
  80200c:	6a 40                	push   $0x40
  80200e:	68 a4 29 80 00       	push   $0x8029a4
  802013:	e8 80 e2 ff ff       	call   800298 <_panic>
        sys_yield();
  802018:	e8 db ec ff ff       	call   800cf8 <sys_yield>
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  80201d:	ff 75 14             	pushl  0x14(%ebp)
  802020:	53                   	push   %ebx
  802021:	56                   	push   %esi
  802022:	57                   	push   %edi
  802023:	e8 7c ee ff ff       	call   800ea4 <sys_ipc_try_send>
  802028:	83 c4 10             	add    $0x10,%esp
  80202b:	85 c0                	test   %eax,%eax
  80202d:	75 d2                	jne    802001 <ipc_send+0x1e>
        if (ret != -E_IPC_NOT_RECV)
            panic("ipc_send error %e", ret);
        sys_yield();
    }
}
  80202f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802032:	5b                   	pop    %ebx
  802033:	5e                   	pop    %esi
  802034:	5f                   	pop    %edi
  802035:	5d                   	pop    %ebp
  802036:	c3                   	ret    

00802037 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802037:	55                   	push   %ebp
  802038:	89 e5                	mov    %esp,%ebp
  80203a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80203d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802042:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802045:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80204b:	8b 52 50             	mov    0x50(%edx),%edx
  80204e:	39 ca                	cmp    %ecx,%edx
  802050:	75 0d                	jne    80205f <ipc_find_env+0x28>
			return envs[i].env_id;
  802052:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802055:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80205a:	8b 40 48             	mov    0x48(%eax),%eax
  80205d:	eb 0f                	jmp    80206e <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80205f:	83 c0 01             	add    $0x1,%eax
  802062:	3d 00 04 00 00       	cmp    $0x400,%eax
  802067:	75 d9                	jne    802042 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802069:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80206e:	5d                   	pop    %ebp
  80206f:	c3                   	ret    

00802070 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802070:	55                   	push   %ebp
  802071:	89 e5                	mov    %esp,%ebp
  802073:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802076:	89 d0                	mov    %edx,%eax
  802078:	c1 e8 16             	shr    $0x16,%eax
  80207b:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802082:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802087:	f6 c1 01             	test   $0x1,%cl
  80208a:	74 1d                	je     8020a9 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80208c:	c1 ea 0c             	shr    $0xc,%edx
  80208f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802096:	f6 c2 01             	test   $0x1,%dl
  802099:	74 0e                	je     8020a9 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80209b:	c1 ea 0c             	shr    $0xc,%edx
  80209e:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8020a5:	ef 
  8020a6:	0f b7 c0             	movzwl %ax,%eax
}
  8020a9:	5d                   	pop    %ebp
  8020aa:	c3                   	ret    
  8020ab:	66 90                	xchg   %ax,%ax
  8020ad:	66 90                	xchg   %ax,%ax
  8020af:	90                   	nop

008020b0 <__udivdi3>:
  8020b0:	55                   	push   %ebp
  8020b1:	57                   	push   %edi
  8020b2:	56                   	push   %esi
  8020b3:	53                   	push   %ebx
  8020b4:	83 ec 1c             	sub    $0x1c,%esp
  8020b7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8020bb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8020bf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8020c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020c7:	85 f6                	test   %esi,%esi
  8020c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020cd:	89 ca                	mov    %ecx,%edx
  8020cf:	89 f8                	mov    %edi,%eax
  8020d1:	75 3d                	jne    802110 <__udivdi3+0x60>
  8020d3:	39 cf                	cmp    %ecx,%edi
  8020d5:	0f 87 c5 00 00 00    	ja     8021a0 <__udivdi3+0xf0>
  8020db:	85 ff                	test   %edi,%edi
  8020dd:	89 fd                	mov    %edi,%ebp
  8020df:	75 0b                	jne    8020ec <__udivdi3+0x3c>
  8020e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020e6:	31 d2                	xor    %edx,%edx
  8020e8:	f7 f7                	div    %edi
  8020ea:	89 c5                	mov    %eax,%ebp
  8020ec:	89 c8                	mov    %ecx,%eax
  8020ee:	31 d2                	xor    %edx,%edx
  8020f0:	f7 f5                	div    %ebp
  8020f2:	89 c1                	mov    %eax,%ecx
  8020f4:	89 d8                	mov    %ebx,%eax
  8020f6:	89 cf                	mov    %ecx,%edi
  8020f8:	f7 f5                	div    %ebp
  8020fa:	89 c3                	mov    %eax,%ebx
  8020fc:	89 d8                	mov    %ebx,%eax
  8020fe:	89 fa                	mov    %edi,%edx
  802100:	83 c4 1c             	add    $0x1c,%esp
  802103:	5b                   	pop    %ebx
  802104:	5e                   	pop    %esi
  802105:	5f                   	pop    %edi
  802106:	5d                   	pop    %ebp
  802107:	c3                   	ret    
  802108:	90                   	nop
  802109:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802110:	39 ce                	cmp    %ecx,%esi
  802112:	77 74                	ja     802188 <__udivdi3+0xd8>
  802114:	0f bd fe             	bsr    %esi,%edi
  802117:	83 f7 1f             	xor    $0x1f,%edi
  80211a:	0f 84 98 00 00 00    	je     8021b8 <__udivdi3+0x108>
  802120:	bb 20 00 00 00       	mov    $0x20,%ebx
  802125:	89 f9                	mov    %edi,%ecx
  802127:	89 c5                	mov    %eax,%ebp
  802129:	29 fb                	sub    %edi,%ebx
  80212b:	d3 e6                	shl    %cl,%esi
  80212d:	89 d9                	mov    %ebx,%ecx
  80212f:	d3 ed                	shr    %cl,%ebp
  802131:	89 f9                	mov    %edi,%ecx
  802133:	d3 e0                	shl    %cl,%eax
  802135:	09 ee                	or     %ebp,%esi
  802137:	89 d9                	mov    %ebx,%ecx
  802139:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80213d:	89 d5                	mov    %edx,%ebp
  80213f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802143:	d3 ed                	shr    %cl,%ebp
  802145:	89 f9                	mov    %edi,%ecx
  802147:	d3 e2                	shl    %cl,%edx
  802149:	89 d9                	mov    %ebx,%ecx
  80214b:	d3 e8                	shr    %cl,%eax
  80214d:	09 c2                	or     %eax,%edx
  80214f:	89 d0                	mov    %edx,%eax
  802151:	89 ea                	mov    %ebp,%edx
  802153:	f7 f6                	div    %esi
  802155:	89 d5                	mov    %edx,%ebp
  802157:	89 c3                	mov    %eax,%ebx
  802159:	f7 64 24 0c          	mull   0xc(%esp)
  80215d:	39 d5                	cmp    %edx,%ebp
  80215f:	72 10                	jb     802171 <__udivdi3+0xc1>
  802161:	8b 74 24 08          	mov    0x8(%esp),%esi
  802165:	89 f9                	mov    %edi,%ecx
  802167:	d3 e6                	shl    %cl,%esi
  802169:	39 c6                	cmp    %eax,%esi
  80216b:	73 07                	jae    802174 <__udivdi3+0xc4>
  80216d:	39 d5                	cmp    %edx,%ebp
  80216f:	75 03                	jne    802174 <__udivdi3+0xc4>
  802171:	83 eb 01             	sub    $0x1,%ebx
  802174:	31 ff                	xor    %edi,%edi
  802176:	89 d8                	mov    %ebx,%eax
  802178:	89 fa                	mov    %edi,%edx
  80217a:	83 c4 1c             	add    $0x1c,%esp
  80217d:	5b                   	pop    %ebx
  80217e:	5e                   	pop    %esi
  80217f:	5f                   	pop    %edi
  802180:	5d                   	pop    %ebp
  802181:	c3                   	ret    
  802182:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802188:	31 ff                	xor    %edi,%edi
  80218a:	31 db                	xor    %ebx,%ebx
  80218c:	89 d8                	mov    %ebx,%eax
  80218e:	89 fa                	mov    %edi,%edx
  802190:	83 c4 1c             	add    $0x1c,%esp
  802193:	5b                   	pop    %ebx
  802194:	5e                   	pop    %esi
  802195:	5f                   	pop    %edi
  802196:	5d                   	pop    %ebp
  802197:	c3                   	ret    
  802198:	90                   	nop
  802199:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021a0:	89 d8                	mov    %ebx,%eax
  8021a2:	f7 f7                	div    %edi
  8021a4:	31 ff                	xor    %edi,%edi
  8021a6:	89 c3                	mov    %eax,%ebx
  8021a8:	89 d8                	mov    %ebx,%eax
  8021aa:	89 fa                	mov    %edi,%edx
  8021ac:	83 c4 1c             	add    $0x1c,%esp
  8021af:	5b                   	pop    %ebx
  8021b0:	5e                   	pop    %esi
  8021b1:	5f                   	pop    %edi
  8021b2:	5d                   	pop    %ebp
  8021b3:	c3                   	ret    
  8021b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021b8:	39 ce                	cmp    %ecx,%esi
  8021ba:	72 0c                	jb     8021c8 <__udivdi3+0x118>
  8021bc:	31 db                	xor    %ebx,%ebx
  8021be:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8021c2:	0f 87 34 ff ff ff    	ja     8020fc <__udivdi3+0x4c>
  8021c8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8021cd:	e9 2a ff ff ff       	jmp    8020fc <__udivdi3+0x4c>
  8021d2:	66 90                	xchg   %ax,%ax
  8021d4:	66 90                	xchg   %ax,%ax
  8021d6:	66 90                	xchg   %ax,%ax
  8021d8:	66 90                	xchg   %ax,%ax
  8021da:	66 90                	xchg   %ax,%ax
  8021dc:	66 90                	xchg   %ax,%ax
  8021de:	66 90                	xchg   %ax,%ax

008021e0 <__umoddi3>:
  8021e0:	55                   	push   %ebp
  8021e1:	57                   	push   %edi
  8021e2:	56                   	push   %esi
  8021e3:	53                   	push   %ebx
  8021e4:	83 ec 1c             	sub    $0x1c,%esp
  8021e7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021eb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021ef:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021f7:	85 d2                	test   %edx,%edx
  8021f9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8021fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802201:	89 f3                	mov    %esi,%ebx
  802203:	89 3c 24             	mov    %edi,(%esp)
  802206:	89 74 24 04          	mov    %esi,0x4(%esp)
  80220a:	75 1c                	jne    802228 <__umoddi3+0x48>
  80220c:	39 f7                	cmp    %esi,%edi
  80220e:	76 50                	jbe    802260 <__umoddi3+0x80>
  802210:	89 c8                	mov    %ecx,%eax
  802212:	89 f2                	mov    %esi,%edx
  802214:	f7 f7                	div    %edi
  802216:	89 d0                	mov    %edx,%eax
  802218:	31 d2                	xor    %edx,%edx
  80221a:	83 c4 1c             	add    $0x1c,%esp
  80221d:	5b                   	pop    %ebx
  80221e:	5e                   	pop    %esi
  80221f:	5f                   	pop    %edi
  802220:	5d                   	pop    %ebp
  802221:	c3                   	ret    
  802222:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802228:	39 f2                	cmp    %esi,%edx
  80222a:	89 d0                	mov    %edx,%eax
  80222c:	77 52                	ja     802280 <__umoddi3+0xa0>
  80222e:	0f bd ea             	bsr    %edx,%ebp
  802231:	83 f5 1f             	xor    $0x1f,%ebp
  802234:	75 5a                	jne    802290 <__umoddi3+0xb0>
  802236:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80223a:	0f 82 e0 00 00 00    	jb     802320 <__umoddi3+0x140>
  802240:	39 0c 24             	cmp    %ecx,(%esp)
  802243:	0f 86 d7 00 00 00    	jbe    802320 <__umoddi3+0x140>
  802249:	8b 44 24 08          	mov    0x8(%esp),%eax
  80224d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802251:	83 c4 1c             	add    $0x1c,%esp
  802254:	5b                   	pop    %ebx
  802255:	5e                   	pop    %esi
  802256:	5f                   	pop    %edi
  802257:	5d                   	pop    %ebp
  802258:	c3                   	ret    
  802259:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802260:	85 ff                	test   %edi,%edi
  802262:	89 fd                	mov    %edi,%ebp
  802264:	75 0b                	jne    802271 <__umoddi3+0x91>
  802266:	b8 01 00 00 00       	mov    $0x1,%eax
  80226b:	31 d2                	xor    %edx,%edx
  80226d:	f7 f7                	div    %edi
  80226f:	89 c5                	mov    %eax,%ebp
  802271:	89 f0                	mov    %esi,%eax
  802273:	31 d2                	xor    %edx,%edx
  802275:	f7 f5                	div    %ebp
  802277:	89 c8                	mov    %ecx,%eax
  802279:	f7 f5                	div    %ebp
  80227b:	89 d0                	mov    %edx,%eax
  80227d:	eb 99                	jmp    802218 <__umoddi3+0x38>
  80227f:	90                   	nop
  802280:	89 c8                	mov    %ecx,%eax
  802282:	89 f2                	mov    %esi,%edx
  802284:	83 c4 1c             	add    $0x1c,%esp
  802287:	5b                   	pop    %ebx
  802288:	5e                   	pop    %esi
  802289:	5f                   	pop    %edi
  80228a:	5d                   	pop    %ebp
  80228b:	c3                   	ret    
  80228c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802290:	8b 34 24             	mov    (%esp),%esi
  802293:	bf 20 00 00 00       	mov    $0x20,%edi
  802298:	89 e9                	mov    %ebp,%ecx
  80229a:	29 ef                	sub    %ebp,%edi
  80229c:	d3 e0                	shl    %cl,%eax
  80229e:	89 f9                	mov    %edi,%ecx
  8022a0:	89 f2                	mov    %esi,%edx
  8022a2:	d3 ea                	shr    %cl,%edx
  8022a4:	89 e9                	mov    %ebp,%ecx
  8022a6:	09 c2                	or     %eax,%edx
  8022a8:	89 d8                	mov    %ebx,%eax
  8022aa:	89 14 24             	mov    %edx,(%esp)
  8022ad:	89 f2                	mov    %esi,%edx
  8022af:	d3 e2                	shl    %cl,%edx
  8022b1:	89 f9                	mov    %edi,%ecx
  8022b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022b7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8022bb:	d3 e8                	shr    %cl,%eax
  8022bd:	89 e9                	mov    %ebp,%ecx
  8022bf:	89 c6                	mov    %eax,%esi
  8022c1:	d3 e3                	shl    %cl,%ebx
  8022c3:	89 f9                	mov    %edi,%ecx
  8022c5:	89 d0                	mov    %edx,%eax
  8022c7:	d3 e8                	shr    %cl,%eax
  8022c9:	89 e9                	mov    %ebp,%ecx
  8022cb:	09 d8                	or     %ebx,%eax
  8022cd:	89 d3                	mov    %edx,%ebx
  8022cf:	89 f2                	mov    %esi,%edx
  8022d1:	f7 34 24             	divl   (%esp)
  8022d4:	89 d6                	mov    %edx,%esi
  8022d6:	d3 e3                	shl    %cl,%ebx
  8022d8:	f7 64 24 04          	mull   0x4(%esp)
  8022dc:	39 d6                	cmp    %edx,%esi
  8022de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022e2:	89 d1                	mov    %edx,%ecx
  8022e4:	89 c3                	mov    %eax,%ebx
  8022e6:	72 08                	jb     8022f0 <__umoddi3+0x110>
  8022e8:	75 11                	jne    8022fb <__umoddi3+0x11b>
  8022ea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8022ee:	73 0b                	jae    8022fb <__umoddi3+0x11b>
  8022f0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8022f4:	1b 14 24             	sbb    (%esp),%edx
  8022f7:	89 d1                	mov    %edx,%ecx
  8022f9:	89 c3                	mov    %eax,%ebx
  8022fb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8022ff:	29 da                	sub    %ebx,%edx
  802301:	19 ce                	sbb    %ecx,%esi
  802303:	89 f9                	mov    %edi,%ecx
  802305:	89 f0                	mov    %esi,%eax
  802307:	d3 e0                	shl    %cl,%eax
  802309:	89 e9                	mov    %ebp,%ecx
  80230b:	d3 ea                	shr    %cl,%edx
  80230d:	89 e9                	mov    %ebp,%ecx
  80230f:	d3 ee                	shr    %cl,%esi
  802311:	09 d0                	or     %edx,%eax
  802313:	89 f2                	mov    %esi,%edx
  802315:	83 c4 1c             	add    $0x1c,%esp
  802318:	5b                   	pop    %ebx
  802319:	5e                   	pop    %esi
  80231a:	5f                   	pop    %edi
  80231b:	5d                   	pop    %ebp
  80231c:	c3                   	ret    
  80231d:	8d 76 00             	lea    0x0(%esi),%esi
  802320:	29 f9                	sub    %edi,%ecx
  802322:	19 d6                	sbb    %edx,%esi
  802324:	89 74 24 04          	mov    %esi,0x4(%esp)
  802328:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80232c:	e9 18 ff ff ff       	jmp    802249 <__umoddi3+0x69>
