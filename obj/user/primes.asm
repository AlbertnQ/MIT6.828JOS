
obj/user/primes.debug:     file format elf32-i386


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
  80002c:	e8 c7 00 00 00       	call   8000f8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003c:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80003f:	83 ec 04             	sub    $0x4,%esp
  800042:	6a 00                	push   $0x0
  800044:	6a 00                	push   $0x0
  800046:	56                   	push   %esi
  800047:	e8 8c 10 00 00       	call   8010d8 <ipc_recv>
  80004c:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80004e:	a1 04 40 80 00       	mov    0x804004,%eax
  800053:	8b 40 5c             	mov    0x5c(%eax),%eax
  800056:	83 c4 0c             	add    $0xc,%esp
  800059:	53                   	push   %ebx
  80005a:	50                   	push   %eax
  80005b:	68 00 22 80 00       	push   $0x802200
  800060:	e8 cc 01 00 00       	call   800231 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800065:	e8 32 0f 00 00       	call   800f9c <fork>
  80006a:	89 c7                	mov    %eax,%edi
  80006c:	83 c4 10             	add    $0x10,%esp
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 12                	jns    800085 <primeproc+0x52>
		panic("fork: %e", id);
  800073:	50                   	push   %eax
  800074:	68 0c 22 80 00       	push   $0x80220c
  800079:	6a 1a                	push   $0x1a
  80007b:	68 15 22 80 00       	push   $0x802215
  800080:	e8 d3 00 00 00       	call   800158 <_panic>
	if (id == 0)
  800085:	85 c0                	test   %eax,%eax
  800087:	74 b6                	je     80003f <primeproc+0xc>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  800089:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80008c:	83 ec 04             	sub    $0x4,%esp
  80008f:	6a 00                	push   $0x0
  800091:	6a 00                	push   $0x0
  800093:	56                   	push   %esi
  800094:	e8 3f 10 00 00       	call   8010d8 <ipc_recv>
  800099:	89 c1                	mov    %eax,%ecx
		if (i % p)
  80009b:	99                   	cltd   
  80009c:	f7 fb                	idiv   %ebx
  80009e:	83 c4 10             	add    $0x10,%esp
  8000a1:	85 d2                	test   %edx,%edx
  8000a3:	74 e7                	je     80008c <primeproc+0x59>
			ipc_send(id, i, 0, 0);
  8000a5:	6a 00                	push   $0x0
  8000a7:	6a 00                	push   $0x0
  8000a9:	51                   	push   %ecx
  8000aa:	57                   	push   %edi
  8000ab:	e8 7d 10 00 00       	call   80112d <ipc_send>
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	eb d7                	jmp    80008c <primeproc+0x59>

008000b5 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000ba:	e8 dd 0e 00 00       	call   800f9c <fork>
  8000bf:	89 c6                	mov    %eax,%esi
  8000c1:	85 c0                	test   %eax,%eax
  8000c3:	79 12                	jns    8000d7 <umain+0x22>
		panic("fork: %e", id);
  8000c5:	50                   	push   %eax
  8000c6:	68 0c 22 80 00       	push   $0x80220c
  8000cb:	6a 2d                	push   $0x2d
  8000cd:	68 15 22 80 00       	push   $0x802215
  8000d2:	e8 81 00 00 00       	call   800158 <_panic>
  8000d7:	bb 02 00 00 00       	mov    $0x2,%ebx
	if (id == 0)
  8000dc:	85 c0                	test   %eax,%eax
  8000de:	75 05                	jne    8000e5 <umain+0x30>
		primeproc();
  8000e0:	e8 4e ff ff ff       	call   800033 <primeproc>

	// feed all the integers through
	for (i = 2; ; i++)
		ipc_send(id, i, 0, 0);
  8000e5:	6a 00                	push   $0x0
  8000e7:	6a 00                	push   $0x0
  8000e9:	53                   	push   %ebx
  8000ea:	56                   	push   %esi
  8000eb:	e8 3d 10 00 00       	call   80112d <ipc_send>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  8000f0:	83 c3 01             	add    $0x1,%ebx
  8000f3:	83 c4 10             	add    $0x10,%esp
  8000f6:	eb ed                	jmp    8000e5 <umain+0x30>

008000f8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	56                   	push   %esi
  8000fc:	53                   	push   %ebx
  8000fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800100:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  800103:	e8 91 0a 00 00       	call   800b99 <sys_getenvid>
  800108:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800110:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800115:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80011a:	85 db                	test   %ebx,%ebx
  80011c:	7e 07                	jle    800125 <libmain+0x2d>
		binaryname = argv[0];
  80011e:	8b 06                	mov    (%esi),%eax
  800120:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800125:	83 ec 08             	sub    $0x8,%esp
  800128:	56                   	push   %esi
  800129:	53                   	push   %ebx
  80012a:	e8 86 ff ff ff       	call   8000b5 <umain>

	// exit gracefully
	exit();
  80012f:	e8 0a 00 00 00       	call   80013e <exit>
}
  800134:	83 c4 10             	add    $0x10,%esp
  800137:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80013a:	5b                   	pop    %ebx
  80013b:	5e                   	pop    %esi
  80013c:	5d                   	pop    %ebp
  80013d:	c3                   	ret    

0080013e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80013e:	55                   	push   %ebp
  80013f:	89 e5                	mov    %esp,%ebp
  800141:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800144:	e8 3c 12 00 00       	call   801385 <close_all>
	sys_env_destroy(0);
  800149:	83 ec 0c             	sub    $0xc,%esp
  80014c:	6a 00                	push   $0x0
  80014e:	e8 05 0a 00 00       	call   800b58 <sys_env_destroy>
}
  800153:	83 c4 10             	add    $0x10,%esp
  800156:	c9                   	leave  
  800157:	c3                   	ret    

00800158 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800158:	55                   	push   %ebp
  800159:	89 e5                	mov    %esp,%ebp
  80015b:	56                   	push   %esi
  80015c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80015d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800160:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800166:	e8 2e 0a 00 00       	call   800b99 <sys_getenvid>
  80016b:	83 ec 0c             	sub    $0xc,%esp
  80016e:	ff 75 0c             	pushl  0xc(%ebp)
  800171:	ff 75 08             	pushl  0x8(%ebp)
  800174:	56                   	push   %esi
  800175:	50                   	push   %eax
  800176:	68 30 22 80 00       	push   $0x802230
  80017b:	e8 b1 00 00 00       	call   800231 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800180:	83 c4 18             	add    $0x18,%esp
  800183:	53                   	push   %ebx
  800184:	ff 75 10             	pushl  0x10(%ebp)
  800187:	e8 54 00 00 00       	call   8001e0 <vcprintf>
	cprintf("\n");
  80018c:	c7 04 24 a7 27 80 00 	movl   $0x8027a7,(%esp)
  800193:	e8 99 00 00 00       	call   800231 <cprintf>
  800198:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80019b:	cc                   	int3   
  80019c:	eb fd                	jmp    80019b <_panic+0x43>

0080019e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80019e:	55                   	push   %ebp
  80019f:	89 e5                	mov    %esp,%ebp
  8001a1:	53                   	push   %ebx
  8001a2:	83 ec 04             	sub    $0x4,%esp
  8001a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001a8:	8b 13                	mov    (%ebx),%edx
  8001aa:	8d 42 01             	lea    0x1(%edx),%eax
  8001ad:	89 03                	mov    %eax,(%ebx)
  8001af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001b2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001b6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001bb:	75 1a                	jne    8001d7 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001bd:	83 ec 08             	sub    $0x8,%esp
  8001c0:	68 ff 00 00 00       	push   $0xff
  8001c5:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c8:	50                   	push   %eax
  8001c9:	e8 4d 09 00 00       	call   800b1b <sys_cputs>
		b->idx = 0;
  8001ce:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001d4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001d7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001de:	c9                   	leave  
  8001df:	c3                   	ret    

008001e0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001e9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f0:	00 00 00 
	b.cnt = 0;
  8001f3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001fa:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001fd:	ff 75 0c             	pushl  0xc(%ebp)
  800200:	ff 75 08             	pushl  0x8(%ebp)
  800203:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800209:	50                   	push   %eax
  80020a:	68 9e 01 80 00       	push   $0x80019e
  80020f:	e8 54 01 00 00       	call   800368 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800214:	83 c4 08             	add    $0x8,%esp
  800217:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80021d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800223:	50                   	push   %eax
  800224:	e8 f2 08 00 00       	call   800b1b <sys_cputs>

	return b.cnt;
}
  800229:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80022f:	c9                   	leave  
  800230:	c3                   	ret    

00800231 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800231:	55                   	push   %ebp
  800232:	89 e5                	mov    %esp,%ebp
  800234:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800237:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80023a:	50                   	push   %eax
  80023b:	ff 75 08             	pushl  0x8(%ebp)
  80023e:	e8 9d ff ff ff       	call   8001e0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800243:	c9                   	leave  
  800244:	c3                   	ret    

00800245 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800245:	55                   	push   %ebp
  800246:	89 e5                	mov    %esp,%ebp
  800248:	57                   	push   %edi
  800249:	56                   	push   %esi
  80024a:	53                   	push   %ebx
  80024b:	83 ec 1c             	sub    $0x1c,%esp
  80024e:	89 c7                	mov    %eax,%edi
  800250:	89 d6                	mov    %edx,%esi
  800252:	8b 45 08             	mov    0x8(%ebp),%eax
  800255:	8b 55 0c             	mov    0xc(%ebp),%edx
  800258:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80025b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80025e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800261:	bb 00 00 00 00       	mov    $0x0,%ebx
  800266:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800269:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80026c:	39 d3                	cmp    %edx,%ebx
  80026e:	72 05                	jb     800275 <printnum+0x30>
  800270:	39 45 10             	cmp    %eax,0x10(%ebp)
  800273:	77 45                	ja     8002ba <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800275:	83 ec 0c             	sub    $0xc,%esp
  800278:	ff 75 18             	pushl  0x18(%ebp)
  80027b:	8b 45 14             	mov    0x14(%ebp),%eax
  80027e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800281:	53                   	push   %ebx
  800282:	ff 75 10             	pushl  0x10(%ebp)
  800285:	83 ec 08             	sub    $0x8,%esp
  800288:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028b:	ff 75 e0             	pushl  -0x20(%ebp)
  80028e:	ff 75 dc             	pushl  -0x24(%ebp)
  800291:	ff 75 d8             	pushl  -0x28(%ebp)
  800294:	e8 d7 1c 00 00       	call   801f70 <__udivdi3>
  800299:	83 c4 18             	add    $0x18,%esp
  80029c:	52                   	push   %edx
  80029d:	50                   	push   %eax
  80029e:	89 f2                	mov    %esi,%edx
  8002a0:	89 f8                	mov    %edi,%eax
  8002a2:	e8 9e ff ff ff       	call   800245 <printnum>
  8002a7:	83 c4 20             	add    $0x20,%esp
  8002aa:	eb 18                	jmp    8002c4 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002ac:	83 ec 08             	sub    $0x8,%esp
  8002af:	56                   	push   %esi
  8002b0:	ff 75 18             	pushl  0x18(%ebp)
  8002b3:	ff d7                	call   *%edi
  8002b5:	83 c4 10             	add    $0x10,%esp
  8002b8:	eb 03                	jmp    8002bd <printnum+0x78>
  8002ba:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002bd:	83 eb 01             	sub    $0x1,%ebx
  8002c0:	85 db                	test   %ebx,%ebx
  8002c2:	7f e8                	jg     8002ac <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002c4:	83 ec 08             	sub    $0x8,%esp
  8002c7:	56                   	push   %esi
  8002c8:	83 ec 04             	sub    $0x4,%esp
  8002cb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002ce:	ff 75 e0             	pushl  -0x20(%ebp)
  8002d1:	ff 75 dc             	pushl  -0x24(%ebp)
  8002d4:	ff 75 d8             	pushl  -0x28(%ebp)
  8002d7:	e8 c4 1d 00 00       	call   8020a0 <__umoddi3>
  8002dc:	83 c4 14             	add    $0x14,%esp
  8002df:	0f be 80 53 22 80 00 	movsbl 0x802253(%eax),%eax
  8002e6:	50                   	push   %eax
  8002e7:	ff d7                	call   *%edi
}
  8002e9:	83 c4 10             	add    $0x10,%esp
  8002ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ef:	5b                   	pop    %ebx
  8002f0:	5e                   	pop    %esi
  8002f1:	5f                   	pop    %edi
  8002f2:	5d                   	pop    %ebp
  8002f3:	c3                   	ret    

008002f4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002f4:	55                   	push   %ebp
  8002f5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002f7:	83 fa 01             	cmp    $0x1,%edx
  8002fa:	7e 0e                	jle    80030a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002fc:	8b 10                	mov    (%eax),%edx
  8002fe:	8d 4a 08             	lea    0x8(%edx),%ecx
  800301:	89 08                	mov    %ecx,(%eax)
  800303:	8b 02                	mov    (%edx),%eax
  800305:	8b 52 04             	mov    0x4(%edx),%edx
  800308:	eb 22                	jmp    80032c <getuint+0x38>
	else if (lflag)
  80030a:	85 d2                	test   %edx,%edx
  80030c:	74 10                	je     80031e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80030e:	8b 10                	mov    (%eax),%edx
  800310:	8d 4a 04             	lea    0x4(%edx),%ecx
  800313:	89 08                	mov    %ecx,(%eax)
  800315:	8b 02                	mov    (%edx),%eax
  800317:	ba 00 00 00 00       	mov    $0x0,%edx
  80031c:	eb 0e                	jmp    80032c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80031e:	8b 10                	mov    (%eax),%edx
  800320:	8d 4a 04             	lea    0x4(%edx),%ecx
  800323:	89 08                	mov    %ecx,(%eax)
  800325:	8b 02                	mov    (%edx),%eax
  800327:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80032c:	5d                   	pop    %ebp
  80032d:	c3                   	ret    

0080032e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80032e:	55                   	push   %ebp
  80032f:	89 e5                	mov    %esp,%ebp
  800331:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800334:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800338:	8b 10                	mov    (%eax),%edx
  80033a:	3b 50 04             	cmp    0x4(%eax),%edx
  80033d:	73 0a                	jae    800349 <sprintputch+0x1b>
		*b->buf++ = ch;
  80033f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800342:	89 08                	mov    %ecx,(%eax)
  800344:	8b 45 08             	mov    0x8(%ebp),%eax
  800347:	88 02                	mov    %al,(%edx)
}
  800349:	5d                   	pop    %ebp
  80034a:	c3                   	ret    

0080034b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80034b:	55                   	push   %ebp
  80034c:	89 e5                	mov    %esp,%ebp
  80034e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800351:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800354:	50                   	push   %eax
  800355:	ff 75 10             	pushl  0x10(%ebp)
  800358:	ff 75 0c             	pushl  0xc(%ebp)
  80035b:	ff 75 08             	pushl  0x8(%ebp)
  80035e:	e8 05 00 00 00       	call   800368 <vprintfmt>
	va_end(ap);
}
  800363:	83 c4 10             	add    $0x10,%esp
  800366:	c9                   	leave  
  800367:	c3                   	ret    

00800368 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800368:	55                   	push   %ebp
  800369:	89 e5                	mov    %esp,%ebp
  80036b:	57                   	push   %edi
  80036c:	56                   	push   %esi
  80036d:	53                   	push   %ebx
  80036e:	83 ec 2c             	sub    $0x2c,%esp
  800371:	8b 75 08             	mov    0x8(%ebp),%esi
  800374:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800377:	8b 7d 10             	mov    0x10(%ebp),%edi
  80037a:	eb 12                	jmp    80038e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80037c:	85 c0                	test   %eax,%eax
  80037e:	0f 84 a7 03 00 00    	je     80072b <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
  800384:	83 ec 08             	sub    $0x8,%esp
  800387:	53                   	push   %ebx
  800388:	50                   	push   %eax
  800389:	ff d6                	call   *%esi
  80038b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80038e:	83 c7 01             	add    $0x1,%edi
  800391:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800395:	83 f8 25             	cmp    $0x25,%eax
  800398:	75 e2                	jne    80037c <vprintfmt+0x14>
  80039a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80039e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003a5:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8003ac:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003b3:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8003ba:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003bf:	eb 07                	jmp    8003c8 <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003c4:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c8:	8d 47 01             	lea    0x1(%edi),%eax
  8003cb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003ce:	0f b6 07             	movzbl (%edi),%eax
  8003d1:	0f b6 d0             	movzbl %al,%edx
  8003d4:	83 e8 23             	sub    $0x23,%eax
  8003d7:	3c 55                	cmp    $0x55,%al
  8003d9:	0f 87 31 03 00 00    	ja     800710 <vprintfmt+0x3a8>
  8003df:	0f b6 c0             	movzbl %al,%eax
  8003e2:	ff 24 85 a0 23 80 00 	jmp    *0x8023a0(,%eax,4)
  8003e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003ec:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003f0:	eb d6                	jmp    8003c8 <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8003fa:	89 75 08             	mov    %esi,0x8(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003fd:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800400:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800404:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800407:	8d 72 d0             	lea    -0x30(%edx),%esi
  80040a:	83 fe 09             	cmp    $0x9,%esi
  80040d:	77 34                	ja     800443 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80040f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800412:	eb e9                	jmp    8003fd <vprintfmt+0x95>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800414:	8b 45 14             	mov    0x14(%ebp),%eax
  800417:	8d 50 04             	lea    0x4(%eax),%edx
  80041a:	89 55 14             	mov    %edx,0x14(%ebp)
  80041d:	8b 00                	mov    (%eax),%eax
  80041f:	89 45 cc             	mov    %eax,-0x34(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800422:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800425:	eb 22                	jmp    800449 <vprintfmt+0xe1>
  800427:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80042a:	85 c0                	test   %eax,%eax
  80042c:	0f 48 c1             	cmovs  %ecx,%eax
  80042f:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800432:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800435:	eb 91                	jmp    8003c8 <vprintfmt+0x60>
  800437:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80043a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800441:	eb 85                	jmp    8003c8 <vprintfmt+0x60>
  800443:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800446:	8b 75 08             	mov    0x8(%ebp),%esi

		process_precision:
			if (width < 0)
  800449:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80044d:	0f 89 75 ff ff ff    	jns    8003c8 <vprintfmt+0x60>
				width = precision, precision = -1;
  800453:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800456:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800459:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800460:	e9 63 ff ff ff       	jmp    8003c8 <vprintfmt+0x60>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800465:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800469:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80046c:	e9 57 ff ff ff       	jmp    8003c8 <vprintfmt+0x60>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800471:	8b 45 14             	mov    0x14(%ebp),%eax
  800474:	8d 50 04             	lea    0x4(%eax),%edx
  800477:	89 55 14             	mov    %edx,0x14(%ebp)
  80047a:	83 ec 08             	sub    $0x8,%esp
  80047d:	53                   	push   %ebx
  80047e:	ff 30                	pushl  (%eax)
  800480:	ff d6                	call   *%esi
			break;
  800482:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800485:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800488:	e9 01 ff ff ff       	jmp    80038e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80048d:	8b 45 14             	mov    0x14(%ebp),%eax
  800490:	8d 50 04             	lea    0x4(%eax),%edx
  800493:	89 55 14             	mov    %edx,0x14(%ebp)
  800496:	8b 00                	mov    (%eax),%eax
  800498:	99                   	cltd   
  800499:	31 d0                	xor    %edx,%eax
  80049b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80049d:	83 f8 0f             	cmp    $0xf,%eax
  8004a0:	7f 0b                	jg     8004ad <vprintfmt+0x145>
  8004a2:	8b 14 85 00 25 80 00 	mov    0x802500(,%eax,4),%edx
  8004a9:	85 d2                	test   %edx,%edx
  8004ab:	75 18                	jne    8004c5 <vprintfmt+0x15d>
				printfmt(putch, putdat, "error %d", err);
  8004ad:	50                   	push   %eax
  8004ae:	68 6b 22 80 00       	push   $0x80226b
  8004b3:	53                   	push   %ebx
  8004b4:	56                   	push   %esi
  8004b5:	e8 91 fe ff ff       	call   80034b <printfmt>
  8004ba:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004c0:	e9 c9 fe ff ff       	jmp    80038e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004c5:	52                   	push   %edx
  8004c6:	68 75 27 80 00       	push   $0x802775
  8004cb:	53                   	push   %ebx
  8004cc:	56                   	push   %esi
  8004cd:	e8 79 fe ff ff       	call   80034b <printfmt>
  8004d2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004d8:	e9 b1 fe ff ff       	jmp    80038e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e0:	8d 50 04             	lea    0x4(%eax),%edx
  8004e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e6:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004e8:	85 ff                	test   %edi,%edi
  8004ea:	b8 64 22 80 00       	mov    $0x802264,%eax
  8004ef:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004f2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004f6:	0f 8e 94 00 00 00    	jle    800590 <vprintfmt+0x228>
  8004fc:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800500:	0f 84 98 00 00 00    	je     80059e <vprintfmt+0x236>
				for (width -= strnlen(p, precision); width > 0; width--)
  800506:	83 ec 08             	sub    $0x8,%esp
  800509:	ff 75 cc             	pushl  -0x34(%ebp)
  80050c:	57                   	push   %edi
  80050d:	e8 a1 02 00 00       	call   8007b3 <strnlen>
  800512:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800515:	29 c1                	sub    %eax,%ecx
  800517:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80051a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80051d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800521:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800524:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800527:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800529:	eb 0f                	jmp    80053a <vprintfmt+0x1d2>
					putch(padc, putdat);
  80052b:	83 ec 08             	sub    $0x8,%esp
  80052e:	53                   	push   %ebx
  80052f:	ff 75 e0             	pushl  -0x20(%ebp)
  800532:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800534:	83 ef 01             	sub    $0x1,%edi
  800537:	83 c4 10             	add    $0x10,%esp
  80053a:	85 ff                	test   %edi,%edi
  80053c:	7f ed                	jg     80052b <vprintfmt+0x1c3>
  80053e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800541:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800544:	85 c9                	test   %ecx,%ecx
  800546:	b8 00 00 00 00       	mov    $0x0,%eax
  80054b:	0f 49 c1             	cmovns %ecx,%eax
  80054e:	29 c1                	sub    %eax,%ecx
  800550:	89 75 08             	mov    %esi,0x8(%ebp)
  800553:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800556:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800559:	89 cb                	mov    %ecx,%ebx
  80055b:	eb 4d                	jmp    8005aa <vprintfmt+0x242>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80055d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800561:	74 1b                	je     80057e <vprintfmt+0x216>
  800563:	0f be c0             	movsbl %al,%eax
  800566:	83 e8 20             	sub    $0x20,%eax
  800569:	83 f8 5e             	cmp    $0x5e,%eax
  80056c:	76 10                	jbe    80057e <vprintfmt+0x216>
					putch('?', putdat);
  80056e:	83 ec 08             	sub    $0x8,%esp
  800571:	ff 75 0c             	pushl  0xc(%ebp)
  800574:	6a 3f                	push   $0x3f
  800576:	ff 55 08             	call   *0x8(%ebp)
  800579:	83 c4 10             	add    $0x10,%esp
  80057c:	eb 0d                	jmp    80058b <vprintfmt+0x223>
				else
					putch(ch, putdat);
  80057e:	83 ec 08             	sub    $0x8,%esp
  800581:	ff 75 0c             	pushl  0xc(%ebp)
  800584:	52                   	push   %edx
  800585:	ff 55 08             	call   *0x8(%ebp)
  800588:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80058b:	83 eb 01             	sub    $0x1,%ebx
  80058e:	eb 1a                	jmp    8005aa <vprintfmt+0x242>
  800590:	89 75 08             	mov    %esi,0x8(%ebp)
  800593:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800596:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800599:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80059c:	eb 0c                	jmp    8005aa <vprintfmt+0x242>
  80059e:	89 75 08             	mov    %esi,0x8(%ebp)
  8005a1:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8005a4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005a7:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005aa:	83 c7 01             	add    $0x1,%edi
  8005ad:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005b1:	0f be d0             	movsbl %al,%edx
  8005b4:	85 d2                	test   %edx,%edx
  8005b6:	74 23                	je     8005db <vprintfmt+0x273>
  8005b8:	85 f6                	test   %esi,%esi
  8005ba:	78 a1                	js     80055d <vprintfmt+0x1f5>
  8005bc:	83 ee 01             	sub    $0x1,%esi
  8005bf:	79 9c                	jns    80055d <vprintfmt+0x1f5>
  8005c1:	89 df                	mov    %ebx,%edi
  8005c3:	8b 75 08             	mov    0x8(%ebp),%esi
  8005c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005c9:	eb 18                	jmp    8005e3 <vprintfmt+0x27b>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005cb:	83 ec 08             	sub    $0x8,%esp
  8005ce:	53                   	push   %ebx
  8005cf:	6a 20                	push   $0x20
  8005d1:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005d3:	83 ef 01             	sub    $0x1,%edi
  8005d6:	83 c4 10             	add    $0x10,%esp
  8005d9:	eb 08                	jmp    8005e3 <vprintfmt+0x27b>
  8005db:	89 df                	mov    %ebx,%edi
  8005dd:	8b 75 08             	mov    0x8(%ebp),%esi
  8005e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005e3:	85 ff                	test   %edi,%edi
  8005e5:	7f e4                	jg     8005cb <vprintfmt+0x263>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ea:	e9 9f fd ff ff       	jmp    80038e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ef:	83 7d d0 01          	cmpl   $0x1,-0x30(%ebp)
  8005f3:	7e 16                	jle    80060b <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  8005f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f8:	8d 50 08             	lea    0x8(%eax),%edx
  8005fb:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fe:	8b 50 04             	mov    0x4(%eax),%edx
  800601:	8b 00                	mov    (%eax),%eax
  800603:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800606:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800609:	eb 34                	jmp    80063f <vprintfmt+0x2d7>
	else if (lflag)
  80060b:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80060f:	74 18                	je     800629 <vprintfmt+0x2c1>
		return va_arg(*ap, long);
  800611:	8b 45 14             	mov    0x14(%ebp),%eax
  800614:	8d 50 04             	lea    0x4(%eax),%edx
  800617:	89 55 14             	mov    %edx,0x14(%ebp)
  80061a:	8b 00                	mov    (%eax),%eax
  80061c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80061f:	89 c1                	mov    %eax,%ecx
  800621:	c1 f9 1f             	sar    $0x1f,%ecx
  800624:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800627:	eb 16                	jmp    80063f <vprintfmt+0x2d7>
	else
		return va_arg(*ap, int);
  800629:	8b 45 14             	mov    0x14(%ebp),%eax
  80062c:	8d 50 04             	lea    0x4(%eax),%edx
  80062f:	89 55 14             	mov    %edx,0x14(%ebp)
  800632:	8b 00                	mov    (%eax),%eax
  800634:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800637:	89 c1                	mov    %eax,%ecx
  800639:	c1 f9 1f             	sar    $0x1f,%ecx
  80063c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80063f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800642:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800645:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80064a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80064e:	0f 89 88 00 00 00    	jns    8006dc <vprintfmt+0x374>
				putch('-', putdat);
  800654:	83 ec 08             	sub    $0x8,%esp
  800657:	53                   	push   %ebx
  800658:	6a 2d                	push   $0x2d
  80065a:	ff d6                	call   *%esi
				num = -(long long) num;
  80065c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80065f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800662:	f7 d8                	neg    %eax
  800664:	83 d2 00             	adc    $0x0,%edx
  800667:	f7 da                	neg    %edx
  800669:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80066c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800671:	eb 69                	jmp    8006dc <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800673:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800676:	8d 45 14             	lea    0x14(%ebp),%eax
  800679:	e8 76 fc ff ff       	call   8002f4 <getuint>
			base = 10;
  80067e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800683:	eb 57                	jmp    8006dc <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  800685:	83 ec 08             	sub    $0x8,%esp
  800688:	53                   	push   %ebx
  800689:	6a 30                	push   $0x30
  80068b:	ff d6                	call   *%esi
			num = getuint(&ap, lflag);
  80068d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800690:	8d 45 14             	lea    0x14(%ebp),%eax
  800693:	e8 5c fc ff ff       	call   8002f4 <getuint>
			base = 8;
			goto number;
  800698:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  80069b:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8006a0:	eb 3a                	jmp    8006dc <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  8006a2:	83 ec 08             	sub    $0x8,%esp
  8006a5:	53                   	push   %ebx
  8006a6:	6a 30                	push   $0x30
  8006a8:	ff d6                	call   *%esi
			putch('x', putdat);
  8006aa:	83 c4 08             	add    $0x8,%esp
  8006ad:	53                   	push   %ebx
  8006ae:	6a 78                	push   $0x78
  8006b0:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b5:	8d 50 04             	lea    0x4(%eax),%edx
  8006b8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006bb:	8b 00                	mov    (%eax),%eax
  8006bd:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006c2:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006c5:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006ca:	eb 10                	jmp    8006dc <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006cc:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8006cf:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d2:	e8 1d fc ff ff       	call   8002f4 <getuint>
			base = 16;
  8006d7:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006dc:	83 ec 0c             	sub    $0xc,%esp
  8006df:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006e3:	57                   	push   %edi
  8006e4:	ff 75 e0             	pushl  -0x20(%ebp)
  8006e7:	51                   	push   %ecx
  8006e8:	52                   	push   %edx
  8006e9:	50                   	push   %eax
  8006ea:	89 da                	mov    %ebx,%edx
  8006ec:	89 f0                	mov    %esi,%eax
  8006ee:	e8 52 fb ff ff       	call   800245 <printnum>
			break;
  8006f3:	83 c4 20             	add    $0x20,%esp
  8006f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006f9:	e9 90 fc ff ff       	jmp    80038e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006fe:	83 ec 08             	sub    $0x8,%esp
  800701:	53                   	push   %ebx
  800702:	52                   	push   %edx
  800703:	ff d6                	call   *%esi
			break;
  800705:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800708:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80070b:	e9 7e fc ff ff       	jmp    80038e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800710:	83 ec 08             	sub    $0x8,%esp
  800713:	53                   	push   %ebx
  800714:	6a 25                	push   $0x25
  800716:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800718:	83 c4 10             	add    $0x10,%esp
  80071b:	eb 03                	jmp    800720 <vprintfmt+0x3b8>
  80071d:	83 ef 01             	sub    $0x1,%edi
  800720:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800724:	75 f7                	jne    80071d <vprintfmt+0x3b5>
  800726:	e9 63 fc ff ff       	jmp    80038e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80072b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80072e:	5b                   	pop    %ebx
  80072f:	5e                   	pop    %esi
  800730:	5f                   	pop    %edi
  800731:	5d                   	pop    %ebp
  800732:	c3                   	ret    

00800733 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800733:	55                   	push   %ebp
  800734:	89 e5                	mov    %esp,%ebp
  800736:	83 ec 18             	sub    $0x18,%esp
  800739:	8b 45 08             	mov    0x8(%ebp),%eax
  80073c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80073f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800742:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800746:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800749:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800750:	85 c0                	test   %eax,%eax
  800752:	74 26                	je     80077a <vsnprintf+0x47>
  800754:	85 d2                	test   %edx,%edx
  800756:	7e 22                	jle    80077a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800758:	ff 75 14             	pushl  0x14(%ebp)
  80075b:	ff 75 10             	pushl  0x10(%ebp)
  80075e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800761:	50                   	push   %eax
  800762:	68 2e 03 80 00       	push   $0x80032e
  800767:	e8 fc fb ff ff       	call   800368 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80076c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80076f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800772:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800775:	83 c4 10             	add    $0x10,%esp
  800778:	eb 05                	jmp    80077f <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80077a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80077f:	c9                   	leave  
  800780:	c3                   	ret    

00800781 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800781:	55                   	push   %ebp
  800782:	89 e5                	mov    %esp,%ebp
  800784:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800787:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80078a:	50                   	push   %eax
  80078b:	ff 75 10             	pushl  0x10(%ebp)
  80078e:	ff 75 0c             	pushl  0xc(%ebp)
  800791:	ff 75 08             	pushl  0x8(%ebp)
  800794:	e8 9a ff ff ff       	call   800733 <vsnprintf>
	va_end(ap);

	return rc;
}
  800799:	c9                   	leave  
  80079a:	c3                   	ret    

0080079b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80079b:	55                   	push   %ebp
  80079c:	89 e5                	mov    %esp,%ebp
  80079e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a6:	eb 03                	jmp    8007ab <strlen+0x10>
		n++;
  8007a8:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ab:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007af:	75 f7                	jne    8007a8 <strlen+0xd>
		n++;
	return n;
}
  8007b1:	5d                   	pop    %ebp
  8007b2:	c3                   	ret    

008007b3 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007b3:	55                   	push   %ebp
  8007b4:	89 e5                	mov    %esp,%ebp
  8007b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b9:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8007c1:	eb 03                	jmp    8007c6 <strnlen+0x13>
		n++;
  8007c3:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c6:	39 c2                	cmp    %eax,%edx
  8007c8:	74 08                	je     8007d2 <strnlen+0x1f>
  8007ca:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007ce:	75 f3                	jne    8007c3 <strnlen+0x10>
  8007d0:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007d2:	5d                   	pop    %ebp
  8007d3:	c3                   	ret    

008007d4 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007d4:	55                   	push   %ebp
  8007d5:	89 e5                	mov    %esp,%ebp
  8007d7:	53                   	push   %ebx
  8007d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007de:	89 c2                	mov    %eax,%edx
  8007e0:	83 c2 01             	add    $0x1,%edx
  8007e3:	83 c1 01             	add    $0x1,%ecx
  8007e6:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007ea:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007ed:	84 db                	test   %bl,%bl
  8007ef:	75 ef                	jne    8007e0 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007f1:	5b                   	pop    %ebx
  8007f2:	5d                   	pop    %ebp
  8007f3:	c3                   	ret    

008007f4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007f4:	55                   	push   %ebp
  8007f5:	89 e5                	mov    %esp,%ebp
  8007f7:	53                   	push   %ebx
  8007f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007fb:	53                   	push   %ebx
  8007fc:	e8 9a ff ff ff       	call   80079b <strlen>
  800801:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800804:	ff 75 0c             	pushl  0xc(%ebp)
  800807:	01 d8                	add    %ebx,%eax
  800809:	50                   	push   %eax
  80080a:	e8 c5 ff ff ff       	call   8007d4 <strcpy>
	return dst;
}
  80080f:	89 d8                	mov    %ebx,%eax
  800811:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800814:	c9                   	leave  
  800815:	c3                   	ret    

00800816 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800816:	55                   	push   %ebp
  800817:	89 e5                	mov    %esp,%ebp
  800819:	56                   	push   %esi
  80081a:	53                   	push   %ebx
  80081b:	8b 75 08             	mov    0x8(%ebp),%esi
  80081e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800821:	89 f3                	mov    %esi,%ebx
  800823:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800826:	89 f2                	mov    %esi,%edx
  800828:	eb 0f                	jmp    800839 <strncpy+0x23>
		*dst++ = *src;
  80082a:	83 c2 01             	add    $0x1,%edx
  80082d:	0f b6 01             	movzbl (%ecx),%eax
  800830:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800833:	80 39 01             	cmpb   $0x1,(%ecx)
  800836:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800839:	39 da                	cmp    %ebx,%edx
  80083b:	75 ed                	jne    80082a <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80083d:	89 f0                	mov    %esi,%eax
  80083f:	5b                   	pop    %ebx
  800840:	5e                   	pop    %esi
  800841:	5d                   	pop    %ebp
  800842:	c3                   	ret    

00800843 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800843:	55                   	push   %ebp
  800844:	89 e5                	mov    %esp,%ebp
  800846:	56                   	push   %esi
  800847:	53                   	push   %ebx
  800848:	8b 75 08             	mov    0x8(%ebp),%esi
  80084b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80084e:	8b 55 10             	mov    0x10(%ebp),%edx
  800851:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800853:	85 d2                	test   %edx,%edx
  800855:	74 21                	je     800878 <strlcpy+0x35>
  800857:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80085b:	89 f2                	mov    %esi,%edx
  80085d:	eb 09                	jmp    800868 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80085f:	83 c2 01             	add    $0x1,%edx
  800862:	83 c1 01             	add    $0x1,%ecx
  800865:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800868:	39 c2                	cmp    %eax,%edx
  80086a:	74 09                	je     800875 <strlcpy+0x32>
  80086c:	0f b6 19             	movzbl (%ecx),%ebx
  80086f:	84 db                	test   %bl,%bl
  800871:	75 ec                	jne    80085f <strlcpy+0x1c>
  800873:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800875:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800878:	29 f0                	sub    %esi,%eax
}
  80087a:	5b                   	pop    %ebx
  80087b:	5e                   	pop    %esi
  80087c:	5d                   	pop    %ebp
  80087d:	c3                   	ret    

0080087e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80087e:	55                   	push   %ebp
  80087f:	89 e5                	mov    %esp,%ebp
  800881:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800884:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800887:	eb 06                	jmp    80088f <strcmp+0x11>
		p++, q++;
  800889:	83 c1 01             	add    $0x1,%ecx
  80088c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80088f:	0f b6 01             	movzbl (%ecx),%eax
  800892:	84 c0                	test   %al,%al
  800894:	74 04                	je     80089a <strcmp+0x1c>
  800896:	3a 02                	cmp    (%edx),%al
  800898:	74 ef                	je     800889 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80089a:	0f b6 c0             	movzbl %al,%eax
  80089d:	0f b6 12             	movzbl (%edx),%edx
  8008a0:	29 d0                	sub    %edx,%eax
}
  8008a2:	5d                   	pop    %ebp
  8008a3:	c3                   	ret    

008008a4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008a4:	55                   	push   %ebp
  8008a5:	89 e5                	mov    %esp,%ebp
  8008a7:	53                   	push   %ebx
  8008a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ae:	89 c3                	mov    %eax,%ebx
  8008b0:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008b3:	eb 06                	jmp    8008bb <strncmp+0x17>
		n--, p++, q++;
  8008b5:	83 c0 01             	add    $0x1,%eax
  8008b8:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008bb:	39 d8                	cmp    %ebx,%eax
  8008bd:	74 15                	je     8008d4 <strncmp+0x30>
  8008bf:	0f b6 08             	movzbl (%eax),%ecx
  8008c2:	84 c9                	test   %cl,%cl
  8008c4:	74 04                	je     8008ca <strncmp+0x26>
  8008c6:	3a 0a                	cmp    (%edx),%cl
  8008c8:	74 eb                	je     8008b5 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ca:	0f b6 00             	movzbl (%eax),%eax
  8008cd:	0f b6 12             	movzbl (%edx),%edx
  8008d0:	29 d0                	sub    %edx,%eax
  8008d2:	eb 05                	jmp    8008d9 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008d4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008d9:	5b                   	pop    %ebx
  8008da:	5d                   	pop    %ebp
  8008db:	c3                   	ret    

008008dc <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008dc:	55                   	push   %ebp
  8008dd:	89 e5                	mov    %esp,%ebp
  8008df:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008e6:	eb 07                	jmp    8008ef <strchr+0x13>
		if (*s == c)
  8008e8:	38 ca                	cmp    %cl,%dl
  8008ea:	74 0f                	je     8008fb <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008ec:	83 c0 01             	add    $0x1,%eax
  8008ef:	0f b6 10             	movzbl (%eax),%edx
  8008f2:	84 d2                	test   %dl,%dl
  8008f4:	75 f2                	jne    8008e8 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008fb:	5d                   	pop    %ebp
  8008fc:	c3                   	ret    

008008fd <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008fd:	55                   	push   %ebp
  8008fe:	89 e5                	mov    %esp,%ebp
  800900:	8b 45 08             	mov    0x8(%ebp),%eax
  800903:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800907:	eb 03                	jmp    80090c <strfind+0xf>
  800909:	83 c0 01             	add    $0x1,%eax
  80090c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80090f:	38 ca                	cmp    %cl,%dl
  800911:	74 04                	je     800917 <strfind+0x1a>
  800913:	84 d2                	test   %dl,%dl
  800915:	75 f2                	jne    800909 <strfind+0xc>
			break;
	return (char *) s;
}
  800917:	5d                   	pop    %ebp
  800918:	c3                   	ret    

00800919 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800919:	55                   	push   %ebp
  80091a:	89 e5                	mov    %esp,%ebp
  80091c:	57                   	push   %edi
  80091d:	56                   	push   %esi
  80091e:	53                   	push   %ebx
  80091f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800922:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800925:	85 c9                	test   %ecx,%ecx
  800927:	74 36                	je     80095f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800929:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80092f:	75 28                	jne    800959 <memset+0x40>
  800931:	f6 c1 03             	test   $0x3,%cl
  800934:	75 23                	jne    800959 <memset+0x40>
		c &= 0xFF;
  800936:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80093a:	89 d3                	mov    %edx,%ebx
  80093c:	c1 e3 08             	shl    $0x8,%ebx
  80093f:	89 d6                	mov    %edx,%esi
  800941:	c1 e6 18             	shl    $0x18,%esi
  800944:	89 d0                	mov    %edx,%eax
  800946:	c1 e0 10             	shl    $0x10,%eax
  800949:	09 f0                	or     %esi,%eax
  80094b:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80094d:	89 d8                	mov    %ebx,%eax
  80094f:	09 d0                	or     %edx,%eax
  800951:	c1 e9 02             	shr    $0x2,%ecx
  800954:	fc                   	cld    
  800955:	f3 ab                	rep stos %eax,%es:(%edi)
  800957:	eb 06                	jmp    80095f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800959:	8b 45 0c             	mov    0xc(%ebp),%eax
  80095c:	fc                   	cld    
  80095d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80095f:	89 f8                	mov    %edi,%eax
  800961:	5b                   	pop    %ebx
  800962:	5e                   	pop    %esi
  800963:	5f                   	pop    %edi
  800964:	5d                   	pop    %ebp
  800965:	c3                   	ret    

00800966 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800966:	55                   	push   %ebp
  800967:	89 e5                	mov    %esp,%ebp
  800969:	57                   	push   %edi
  80096a:	56                   	push   %esi
  80096b:	8b 45 08             	mov    0x8(%ebp),%eax
  80096e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800971:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800974:	39 c6                	cmp    %eax,%esi
  800976:	73 35                	jae    8009ad <memmove+0x47>
  800978:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80097b:	39 d0                	cmp    %edx,%eax
  80097d:	73 2e                	jae    8009ad <memmove+0x47>
		s += n;
		d += n;
  80097f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800982:	89 d6                	mov    %edx,%esi
  800984:	09 fe                	or     %edi,%esi
  800986:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80098c:	75 13                	jne    8009a1 <memmove+0x3b>
  80098e:	f6 c1 03             	test   $0x3,%cl
  800991:	75 0e                	jne    8009a1 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800993:	83 ef 04             	sub    $0x4,%edi
  800996:	8d 72 fc             	lea    -0x4(%edx),%esi
  800999:	c1 e9 02             	shr    $0x2,%ecx
  80099c:	fd                   	std    
  80099d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80099f:	eb 09                	jmp    8009aa <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009a1:	83 ef 01             	sub    $0x1,%edi
  8009a4:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009a7:	fd                   	std    
  8009a8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009aa:	fc                   	cld    
  8009ab:	eb 1d                	jmp    8009ca <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ad:	89 f2                	mov    %esi,%edx
  8009af:	09 c2                	or     %eax,%edx
  8009b1:	f6 c2 03             	test   $0x3,%dl
  8009b4:	75 0f                	jne    8009c5 <memmove+0x5f>
  8009b6:	f6 c1 03             	test   $0x3,%cl
  8009b9:	75 0a                	jne    8009c5 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009bb:	c1 e9 02             	shr    $0x2,%ecx
  8009be:	89 c7                	mov    %eax,%edi
  8009c0:	fc                   	cld    
  8009c1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c3:	eb 05                	jmp    8009ca <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009c5:	89 c7                	mov    %eax,%edi
  8009c7:	fc                   	cld    
  8009c8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ca:	5e                   	pop    %esi
  8009cb:	5f                   	pop    %edi
  8009cc:	5d                   	pop    %ebp
  8009cd:	c3                   	ret    

008009ce <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ce:	55                   	push   %ebp
  8009cf:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009d1:	ff 75 10             	pushl  0x10(%ebp)
  8009d4:	ff 75 0c             	pushl  0xc(%ebp)
  8009d7:	ff 75 08             	pushl  0x8(%ebp)
  8009da:	e8 87 ff ff ff       	call   800966 <memmove>
}
  8009df:	c9                   	leave  
  8009e0:	c3                   	ret    

008009e1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009e1:	55                   	push   %ebp
  8009e2:	89 e5                	mov    %esp,%ebp
  8009e4:	56                   	push   %esi
  8009e5:	53                   	push   %ebx
  8009e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ec:	89 c6                	mov    %eax,%esi
  8009ee:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f1:	eb 1a                	jmp    800a0d <memcmp+0x2c>
		if (*s1 != *s2)
  8009f3:	0f b6 08             	movzbl (%eax),%ecx
  8009f6:	0f b6 1a             	movzbl (%edx),%ebx
  8009f9:	38 d9                	cmp    %bl,%cl
  8009fb:	74 0a                	je     800a07 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009fd:	0f b6 c1             	movzbl %cl,%eax
  800a00:	0f b6 db             	movzbl %bl,%ebx
  800a03:	29 d8                	sub    %ebx,%eax
  800a05:	eb 0f                	jmp    800a16 <memcmp+0x35>
		s1++, s2++;
  800a07:	83 c0 01             	add    $0x1,%eax
  800a0a:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a0d:	39 f0                	cmp    %esi,%eax
  800a0f:	75 e2                	jne    8009f3 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a11:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a16:	5b                   	pop    %ebx
  800a17:	5e                   	pop    %esi
  800a18:	5d                   	pop    %ebp
  800a19:	c3                   	ret    

00800a1a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a1a:	55                   	push   %ebp
  800a1b:	89 e5                	mov    %esp,%ebp
  800a1d:	53                   	push   %ebx
  800a1e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a21:	89 c1                	mov    %eax,%ecx
  800a23:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a26:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a2a:	eb 0a                	jmp    800a36 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a2c:	0f b6 10             	movzbl (%eax),%edx
  800a2f:	39 da                	cmp    %ebx,%edx
  800a31:	74 07                	je     800a3a <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a33:	83 c0 01             	add    $0x1,%eax
  800a36:	39 c8                	cmp    %ecx,%eax
  800a38:	72 f2                	jb     800a2c <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a3a:	5b                   	pop    %ebx
  800a3b:	5d                   	pop    %ebp
  800a3c:	c3                   	ret    

00800a3d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a3d:	55                   	push   %ebp
  800a3e:	89 e5                	mov    %esp,%ebp
  800a40:	57                   	push   %edi
  800a41:	56                   	push   %esi
  800a42:	53                   	push   %ebx
  800a43:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a46:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a49:	eb 03                	jmp    800a4e <strtol+0x11>
		s++;
  800a4b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a4e:	0f b6 01             	movzbl (%ecx),%eax
  800a51:	3c 20                	cmp    $0x20,%al
  800a53:	74 f6                	je     800a4b <strtol+0xe>
  800a55:	3c 09                	cmp    $0x9,%al
  800a57:	74 f2                	je     800a4b <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a59:	3c 2b                	cmp    $0x2b,%al
  800a5b:	75 0a                	jne    800a67 <strtol+0x2a>
		s++;
  800a5d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a60:	bf 00 00 00 00       	mov    $0x0,%edi
  800a65:	eb 11                	jmp    800a78 <strtol+0x3b>
  800a67:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a6c:	3c 2d                	cmp    $0x2d,%al
  800a6e:	75 08                	jne    800a78 <strtol+0x3b>
		s++, neg = 1;
  800a70:	83 c1 01             	add    $0x1,%ecx
  800a73:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a78:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a7e:	75 15                	jne    800a95 <strtol+0x58>
  800a80:	80 39 30             	cmpb   $0x30,(%ecx)
  800a83:	75 10                	jne    800a95 <strtol+0x58>
  800a85:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a89:	75 7c                	jne    800b07 <strtol+0xca>
		s += 2, base = 16;
  800a8b:	83 c1 02             	add    $0x2,%ecx
  800a8e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a93:	eb 16                	jmp    800aab <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a95:	85 db                	test   %ebx,%ebx
  800a97:	75 12                	jne    800aab <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a99:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a9e:	80 39 30             	cmpb   $0x30,(%ecx)
  800aa1:	75 08                	jne    800aab <strtol+0x6e>
		s++, base = 8;
  800aa3:	83 c1 01             	add    $0x1,%ecx
  800aa6:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800aab:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab0:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ab3:	0f b6 11             	movzbl (%ecx),%edx
  800ab6:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ab9:	89 f3                	mov    %esi,%ebx
  800abb:	80 fb 09             	cmp    $0x9,%bl
  800abe:	77 08                	ja     800ac8 <strtol+0x8b>
			dig = *s - '0';
  800ac0:	0f be d2             	movsbl %dl,%edx
  800ac3:	83 ea 30             	sub    $0x30,%edx
  800ac6:	eb 22                	jmp    800aea <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ac8:	8d 72 9f             	lea    -0x61(%edx),%esi
  800acb:	89 f3                	mov    %esi,%ebx
  800acd:	80 fb 19             	cmp    $0x19,%bl
  800ad0:	77 08                	ja     800ada <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ad2:	0f be d2             	movsbl %dl,%edx
  800ad5:	83 ea 57             	sub    $0x57,%edx
  800ad8:	eb 10                	jmp    800aea <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ada:	8d 72 bf             	lea    -0x41(%edx),%esi
  800add:	89 f3                	mov    %esi,%ebx
  800adf:	80 fb 19             	cmp    $0x19,%bl
  800ae2:	77 16                	ja     800afa <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ae4:	0f be d2             	movsbl %dl,%edx
  800ae7:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800aea:	3b 55 10             	cmp    0x10(%ebp),%edx
  800aed:	7d 0b                	jge    800afa <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800aef:	83 c1 01             	add    $0x1,%ecx
  800af2:	0f af 45 10          	imul   0x10(%ebp),%eax
  800af6:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800af8:	eb b9                	jmp    800ab3 <strtol+0x76>

	if (endptr)
  800afa:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800afe:	74 0d                	je     800b0d <strtol+0xd0>
		*endptr = (char *) s;
  800b00:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b03:	89 0e                	mov    %ecx,(%esi)
  800b05:	eb 06                	jmp    800b0d <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b07:	85 db                	test   %ebx,%ebx
  800b09:	74 98                	je     800aa3 <strtol+0x66>
  800b0b:	eb 9e                	jmp    800aab <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b0d:	89 c2                	mov    %eax,%edx
  800b0f:	f7 da                	neg    %edx
  800b11:	85 ff                	test   %edi,%edi
  800b13:	0f 45 c2             	cmovne %edx,%eax
}
  800b16:	5b                   	pop    %ebx
  800b17:	5e                   	pop    %esi
  800b18:	5f                   	pop    %edi
  800b19:	5d                   	pop    %ebp
  800b1a:	c3                   	ret    

00800b1b <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b1b:	55                   	push   %ebp
  800b1c:	89 e5                	mov    %esp,%ebp
  800b1e:	57                   	push   %edi
  800b1f:	56                   	push   %esi
  800b20:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b21:	b8 00 00 00 00       	mov    $0x0,%eax
  800b26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b29:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2c:	89 c3                	mov    %eax,%ebx
  800b2e:	89 c7                	mov    %eax,%edi
  800b30:	89 c6                	mov    %eax,%esi
  800b32:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b34:	5b                   	pop    %ebx
  800b35:	5e                   	pop    %esi
  800b36:	5f                   	pop    %edi
  800b37:	5d                   	pop    %ebp
  800b38:	c3                   	ret    

00800b39 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b39:	55                   	push   %ebp
  800b3a:	89 e5                	mov    %esp,%ebp
  800b3c:	57                   	push   %edi
  800b3d:	56                   	push   %esi
  800b3e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b44:	b8 01 00 00 00       	mov    $0x1,%eax
  800b49:	89 d1                	mov    %edx,%ecx
  800b4b:	89 d3                	mov    %edx,%ebx
  800b4d:	89 d7                	mov    %edx,%edi
  800b4f:	89 d6                	mov    %edx,%esi
  800b51:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b53:	5b                   	pop    %ebx
  800b54:	5e                   	pop    %esi
  800b55:	5f                   	pop    %edi
  800b56:	5d                   	pop    %ebp
  800b57:	c3                   	ret    

00800b58 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b58:	55                   	push   %ebp
  800b59:	89 e5                	mov    %esp,%ebp
  800b5b:	57                   	push   %edi
  800b5c:	56                   	push   %esi
  800b5d:	53                   	push   %ebx
  800b5e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b61:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b66:	b8 03 00 00 00       	mov    $0x3,%eax
  800b6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6e:	89 cb                	mov    %ecx,%ebx
  800b70:	89 cf                	mov    %ecx,%edi
  800b72:	89 ce                	mov    %ecx,%esi
  800b74:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b76:	85 c0                	test   %eax,%eax
  800b78:	7e 17                	jle    800b91 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b7a:	83 ec 0c             	sub    $0xc,%esp
  800b7d:	50                   	push   %eax
  800b7e:	6a 03                	push   $0x3
  800b80:	68 5f 25 80 00       	push   $0x80255f
  800b85:	6a 23                	push   $0x23
  800b87:	68 7c 25 80 00       	push   $0x80257c
  800b8c:	e8 c7 f5 ff ff       	call   800158 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b91:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b94:	5b                   	pop    %ebx
  800b95:	5e                   	pop    %esi
  800b96:	5f                   	pop    %edi
  800b97:	5d                   	pop    %ebp
  800b98:	c3                   	ret    

00800b99 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b99:	55                   	push   %ebp
  800b9a:	89 e5                	mov    %esp,%ebp
  800b9c:	57                   	push   %edi
  800b9d:	56                   	push   %esi
  800b9e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9f:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba4:	b8 02 00 00 00       	mov    $0x2,%eax
  800ba9:	89 d1                	mov    %edx,%ecx
  800bab:	89 d3                	mov    %edx,%ebx
  800bad:	89 d7                	mov    %edx,%edi
  800baf:	89 d6                	mov    %edx,%esi
  800bb1:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bb3:	5b                   	pop    %ebx
  800bb4:	5e                   	pop    %esi
  800bb5:	5f                   	pop    %edi
  800bb6:	5d                   	pop    %ebp
  800bb7:	c3                   	ret    

00800bb8 <sys_yield>:

void
sys_yield(void)
{
  800bb8:	55                   	push   %ebp
  800bb9:	89 e5                	mov    %esp,%ebp
  800bbb:	57                   	push   %edi
  800bbc:	56                   	push   %esi
  800bbd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbe:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc3:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bc8:	89 d1                	mov    %edx,%ecx
  800bca:	89 d3                	mov    %edx,%ebx
  800bcc:	89 d7                	mov    %edx,%edi
  800bce:	89 d6                	mov    %edx,%esi
  800bd0:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bd2:	5b                   	pop    %ebx
  800bd3:	5e                   	pop    %esi
  800bd4:	5f                   	pop    %edi
  800bd5:	5d                   	pop    %ebp
  800bd6:	c3                   	ret    

00800bd7 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bd7:	55                   	push   %ebp
  800bd8:	89 e5                	mov    %esp,%ebp
  800bda:	57                   	push   %edi
  800bdb:	56                   	push   %esi
  800bdc:	53                   	push   %ebx
  800bdd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be0:	be 00 00 00 00       	mov    $0x0,%esi
  800be5:	b8 04 00 00 00       	mov    $0x4,%eax
  800bea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bed:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bf3:	89 f7                	mov    %esi,%edi
  800bf5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bf7:	85 c0                	test   %eax,%eax
  800bf9:	7e 17                	jle    800c12 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bfb:	83 ec 0c             	sub    $0xc,%esp
  800bfe:	50                   	push   %eax
  800bff:	6a 04                	push   $0x4
  800c01:	68 5f 25 80 00       	push   $0x80255f
  800c06:	6a 23                	push   $0x23
  800c08:	68 7c 25 80 00       	push   $0x80257c
  800c0d:	e8 46 f5 ff ff       	call   800158 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c12:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c15:	5b                   	pop    %ebx
  800c16:	5e                   	pop    %esi
  800c17:	5f                   	pop    %edi
  800c18:	5d                   	pop    %ebp
  800c19:	c3                   	ret    

00800c1a <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c1a:	55                   	push   %ebp
  800c1b:	89 e5                	mov    %esp,%ebp
  800c1d:	57                   	push   %edi
  800c1e:	56                   	push   %esi
  800c1f:	53                   	push   %ebx
  800c20:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c23:	b8 05 00 00 00       	mov    $0x5,%eax
  800c28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c31:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c34:	8b 75 18             	mov    0x18(%ebp),%esi
  800c37:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c39:	85 c0                	test   %eax,%eax
  800c3b:	7e 17                	jle    800c54 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3d:	83 ec 0c             	sub    $0xc,%esp
  800c40:	50                   	push   %eax
  800c41:	6a 05                	push   $0x5
  800c43:	68 5f 25 80 00       	push   $0x80255f
  800c48:	6a 23                	push   $0x23
  800c4a:	68 7c 25 80 00       	push   $0x80257c
  800c4f:	e8 04 f5 ff ff       	call   800158 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c54:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c57:	5b                   	pop    %ebx
  800c58:	5e                   	pop    %esi
  800c59:	5f                   	pop    %edi
  800c5a:	5d                   	pop    %ebp
  800c5b:	c3                   	ret    

00800c5c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c5c:	55                   	push   %ebp
  800c5d:	89 e5                	mov    %esp,%ebp
  800c5f:	57                   	push   %edi
  800c60:	56                   	push   %esi
  800c61:	53                   	push   %ebx
  800c62:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c65:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c6a:	b8 06 00 00 00       	mov    $0x6,%eax
  800c6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c72:	8b 55 08             	mov    0x8(%ebp),%edx
  800c75:	89 df                	mov    %ebx,%edi
  800c77:	89 de                	mov    %ebx,%esi
  800c79:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c7b:	85 c0                	test   %eax,%eax
  800c7d:	7e 17                	jle    800c96 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7f:	83 ec 0c             	sub    $0xc,%esp
  800c82:	50                   	push   %eax
  800c83:	6a 06                	push   $0x6
  800c85:	68 5f 25 80 00       	push   $0x80255f
  800c8a:	6a 23                	push   $0x23
  800c8c:	68 7c 25 80 00       	push   $0x80257c
  800c91:	e8 c2 f4 ff ff       	call   800158 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c96:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c99:	5b                   	pop    %ebx
  800c9a:	5e                   	pop    %esi
  800c9b:	5f                   	pop    %edi
  800c9c:	5d                   	pop    %ebp
  800c9d:	c3                   	ret    

00800c9e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c9e:	55                   	push   %ebp
  800c9f:	89 e5                	mov    %esp,%ebp
  800ca1:	57                   	push   %edi
  800ca2:	56                   	push   %esi
  800ca3:	53                   	push   %ebx
  800ca4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cac:	b8 08 00 00 00       	mov    $0x8,%eax
  800cb1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb7:	89 df                	mov    %ebx,%edi
  800cb9:	89 de                	mov    %ebx,%esi
  800cbb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cbd:	85 c0                	test   %eax,%eax
  800cbf:	7e 17                	jle    800cd8 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc1:	83 ec 0c             	sub    $0xc,%esp
  800cc4:	50                   	push   %eax
  800cc5:	6a 08                	push   $0x8
  800cc7:	68 5f 25 80 00       	push   $0x80255f
  800ccc:	6a 23                	push   $0x23
  800cce:	68 7c 25 80 00       	push   $0x80257c
  800cd3:	e8 80 f4 ff ff       	call   800158 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cdb:	5b                   	pop    %ebx
  800cdc:	5e                   	pop    %esi
  800cdd:	5f                   	pop    %edi
  800cde:	5d                   	pop    %ebp
  800cdf:	c3                   	ret    

00800ce0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ce0:	55                   	push   %ebp
  800ce1:	89 e5                	mov    %esp,%ebp
  800ce3:	57                   	push   %edi
  800ce4:	56                   	push   %esi
  800ce5:	53                   	push   %ebx
  800ce6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cee:	b8 09 00 00 00       	mov    $0x9,%eax
  800cf3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf9:	89 df                	mov    %ebx,%edi
  800cfb:	89 de                	mov    %ebx,%esi
  800cfd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cff:	85 c0                	test   %eax,%eax
  800d01:	7e 17                	jle    800d1a <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d03:	83 ec 0c             	sub    $0xc,%esp
  800d06:	50                   	push   %eax
  800d07:	6a 09                	push   $0x9
  800d09:	68 5f 25 80 00       	push   $0x80255f
  800d0e:	6a 23                	push   $0x23
  800d10:	68 7c 25 80 00       	push   $0x80257c
  800d15:	e8 3e f4 ff ff       	call   800158 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1d:	5b                   	pop    %ebx
  800d1e:	5e                   	pop    %esi
  800d1f:	5f                   	pop    %edi
  800d20:	5d                   	pop    %ebp
  800d21:	c3                   	ret    

00800d22 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d22:	55                   	push   %ebp
  800d23:	89 e5                	mov    %esp,%ebp
  800d25:	57                   	push   %edi
  800d26:	56                   	push   %esi
  800d27:	53                   	push   %ebx
  800d28:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d30:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d38:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3b:	89 df                	mov    %ebx,%edi
  800d3d:	89 de                	mov    %ebx,%esi
  800d3f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d41:	85 c0                	test   %eax,%eax
  800d43:	7e 17                	jle    800d5c <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d45:	83 ec 0c             	sub    $0xc,%esp
  800d48:	50                   	push   %eax
  800d49:	6a 0a                	push   $0xa
  800d4b:	68 5f 25 80 00       	push   $0x80255f
  800d50:	6a 23                	push   $0x23
  800d52:	68 7c 25 80 00       	push   $0x80257c
  800d57:	e8 fc f3 ff ff       	call   800158 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5f:	5b                   	pop    %ebx
  800d60:	5e                   	pop    %esi
  800d61:	5f                   	pop    %edi
  800d62:	5d                   	pop    %ebp
  800d63:	c3                   	ret    

00800d64 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d64:	55                   	push   %ebp
  800d65:	89 e5                	mov    %esp,%ebp
  800d67:	57                   	push   %edi
  800d68:	56                   	push   %esi
  800d69:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6a:	be 00 00 00 00       	mov    $0x0,%esi
  800d6f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d77:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d7d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d80:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d82:	5b                   	pop    %ebx
  800d83:	5e                   	pop    %esi
  800d84:	5f                   	pop    %edi
  800d85:	5d                   	pop    %ebp
  800d86:	c3                   	ret    

00800d87 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d87:	55                   	push   %ebp
  800d88:	89 e5                	mov    %esp,%ebp
  800d8a:	57                   	push   %edi
  800d8b:	56                   	push   %esi
  800d8c:	53                   	push   %ebx
  800d8d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d90:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d95:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9d:	89 cb                	mov    %ecx,%ebx
  800d9f:	89 cf                	mov    %ecx,%edi
  800da1:	89 ce                	mov    %ecx,%esi
  800da3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800da5:	85 c0                	test   %eax,%eax
  800da7:	7e 17                	jle    800dc0 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da9:	83 ec 0c             	sub    $0xc,%esp
  800dac:	50                   	push   %eax
  800dad:	6a 0d                	push   $0xd
  800daf:	68 5f 25 80 00       	push   $0x80255f
  800db4:	6a 23                	push   $0x23
  800db6:	68 7c 25 80 00       	push   $0x80257c
  800dbb:	e8 98 f3 ff ff       	call   800158 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dc0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc3:	5b                   	pop    %ebx
  800dc4:	5e                   	pop    %esi
  800dc5:	5f                   	pop    %edi
  800dc6:	5d                   	pop    %ebp
  800dc7:	c3                   	ret    

00800dc8 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800dc8:	55                   	push   %ebp
  800dc9:	89 e5                	mov    %esp,%ebp
  800dcb:	53                   	push   %ebx
  800dcc:	83 ec 04             	sub    $0x4,%esp
	int r;
	// LAB 4: Your code here.
    	pte_t *pte;
	int ret;
	// 用户空间的地址较低
	void *addr = (void *)(pn * PGSIZE);
  800dcf:	89 d3                	mov    %edx,%ebx
  800dd1:	c1 e3 0c             	shl    $0xc,%ebx
	if (uvpt[pn] & PTE_SHARE) {
  800dd4:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800ddb:	f6 c5 04             	test   $0x4,%ch
  800dde:	74 2f                	je     800e0f <duppage+0x47>
		// cprintf("dup share page :%d\n", pn);
		if ((r = sys_page_map(0, addr, envid, addr, PTE_SYSCALL)) < 0)
  800de0:	83 ec 0c             	sub    $0xc,%esp
  800de3:	68 07 0e 00 00       	push   $0xe07
  800de8:	53                   	push   %ebx
  800de9:	50                   	push   %eax
  800dea:	53                   	push   %ebx
  800deb:	6a 00                	push   $0x0
  800ded:	e8 28 fe ff ff       	call   800c1a <sys_page_map>
  800df2:	83 c4 20             	add    $0x20,%esp
  800df5:	85 c0                	test   %eax,%eax
  800df7:	0f 89 a0 00 00 00    	jns    800e9d <duppage+0xd5>
			panic("duppage sys_page_map:%e", r);
  800dfd:	50                   	push   %eax
  800dfe:	68 8a 25 80 00       	push   $0x80258a
  800e03:	6a 4d                	push   $0x4d
  800e05:	68 a2 25 80 00       	push   $0x8025a2
  800e0a:	e8 49 f3 ff ff       	call   800158 <_panic>
	} else if (uvpt[pn] & (PTE_W|PTE_COW)) {
  800e0f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e16:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800e1c:	74 57                	je     800e75 <duppage+0xad>
		if ((r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  800e1e:	83 ec 0c             	sub    $0xc,%esp
  800e21:	68 05 08 00 00       	push   $0x805
  800e26:	53                   	push   %ebx
  800e27:	50                   	push   %eax
  800e28:	53                   	push   %ebx
  800e29:	6a 00                	push   $0x0
  800e2b:	e8 ea fd ff ff       	call   800c1a <sys_page_map>
  800e30:	83 c4 20             	add    $0x20,%esp
  800e33:	85 c0                	test   %eax,%eax
  800e35:	79 12                	jns    800e49 <duppage+0x81>
			panic("sys_page_map COW:%e", r);
  800e37:	50                   	push   %eax
  800e38:	68 ad 25 80 00       	push   $0x8025ad
  800e3d:	6a 50                	push   $0x50
  800e3f:	68 a2 25 80 00       	push   $0x8025a2
  800e44:	e8 0f f3 ff ff       	call   800158 <_panic>

		if ((r = sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  800e49:	83 ec 0c             	sub    $0xc,%esp
  800e4c:	68 05 08 00 00       	push   $0x805
  800e51:	53                   	push   %ebx
  800e52:	6a 00                	push   $0x0
  800e54:	53                   	push   %ebx
  800e55:	6a 00                	push   $0x0
  800e57:	e8 be fd ff ff       	call   800c1a <sys_page_map>
  800e5c:	83 c4 20             	add    $0x20,%esp
  800e5f:	85 c0                	test   %eax,%eax
  800e61:	79 3a                	jns    800e9d <duppage+0xd5>
			panic("sys_page_map COW:%e", r);
  800e63:	50                   	push   %eax
  800e64:	68 ad 25 80 00       	push   $0x8025ad
  800e69:	6a 53                	push   $0x53
  800e6b:	68 a2 25 80 00       	push   $0x8025a2
  800e70:	e8 e3 f2 ff ff       	call   800158 <_panic>
	} else {
		if ((r = sys_page_map(0, addr, envid, addr, PTE_U|PTE_P)) < 0)
  800e75:	83 ec 0c             	sub    $0xc,%esp
  800e78:	6a 05                	push   $0x5
  800e7a:	53                   	push   %ebx
  800e7b:	50                   	push   %eax
  800e7c:	53                   	push   %ebx
  800e7d:	6a 00                	push   $0x0
  800e7f:	e8 96 fd ff ff       	call   800c1a <sys_page_map>
  800e84:	83 c4 20             	add    $0x20,%esp
  800e87:	85 c0                	test   %eax,%eax
  800e89:	79 12                	jns    800e9d <duppage+0xd5>
			panic("sys_page_map UP:%e", r);
  800e8b:	50                   	push   %eax
  800e8c:	68 c1 25 80 00       	push   $0x8025c1
  800e91:	6a 56                	push   $0x56
  800e93:	68 a2 25 80 00       	push   $0x8025a2
  800e98:	e8 bb f2 ff ff       	call   800158 <_panic>
	}
	return 0;
}
  800e9d:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ea5:	c9                   	leave  
  800ea6:	c3                   	ret    

00800ea7 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ea7:	55                   	push   %ebp
  800ea8:	89 e5                	mov    %esp,%ebp
  800eaa:	56                   	push   %esi
  800eab:	53                   	push   %ebx
  800eac:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800eaf:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (! ( (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  800eb1:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800eb5:	74 2d                	je     800ee4 <pgfault+0x3d>
  800eb7:	89 d8                	mov    %ebx,%eax
  800eb9:	c1 e8 16             	shr    $0x16,%eax
  800ebc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ec3:	a8 01                	test   $0x1,%al
  800ec5:	74 1d                	je     800ee4 <pgfault+0x3d>
  800ec7:	89 d8                	mov    %ebx,%eax
  800ec9:	c1 e8 0c             	shr    $0xc,%eax
  800ecc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ed3:	f6 c2 01             	test   $0x1,%dl
  800ed6:	74 0c                	je     800ee4 <pgfault+0x3d>
  800ed8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800edf:	f6 c4 08             	test   $0x8,%ah
  800ee2:	75 14                	jne    800ef8 <pgfault+0x51>
        	panic("Neither the fault is a write nor COW page. \n");
  800ee4:	83 ec 04             	sub    $0x4,%esp
  800ee7:	68 40 26 80 00       	push   $0x802640
  800eec:	6a 1d                	push   $0x1d
  800eee:	68 a2 25 80 00       	push   $0x8025a2
  800ef3:	e8 60 f2 ff ff       	call   800158 <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.
	

    	envid_t envid = sys_getenvid();
  800ef8:	e8 9c fc ff ff       	call   800b99 <sys_getenvid>
  800efd:	89 c6                	mov    %eax,%esi
    	// cprintf("pgfault: envid: %d\n", ENVX(envid));
    	// 临时页暂存
    	if ((r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P| PTE_W|PTE_U)) < 0)
  800eff:	83 ec 04             	sub    $0x4,%esp
  800f02:	6a 07                	push   $0x7
  800f04:	68 00 f0 7f 00       	push   $0x7ff000
  800f09:	50                   	push   %eax
  800f0a:	e8 c8 fc ff ff       	call   800bd7 <sys_page_alloc>
  800f0f:	83 c4 10             	add    $0x10,%esp
  800f12:	85 c0                	test   %eax,%eax
  800f14:	79 12                	jns    800f28 <pgfault+0x81>
        	panic("pgfault: page allocation fault:%e\n", r);
  800f16:	50                   	push   %eax
  800f17:	68 70 26 80 00       	push   $0x802670
  800f1c:	6a 2b                	push   $0x2b
  800f1e:	68 a2 25 80 00       	push   $0x8025a2
  800f23:	e8 30 f2 ff ff       	call   800158 <_panic>
    	addr = ROUNDDOWN(addr, PGSIZE);
  800f28:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  800f2e:	83 ec 04             	sub    $0x4,%esp
  800f31:	68 00 10 00 00       	push   $0x1000
  800f36:	53                   	push   %ebx
  800f37:	68 00 f0 7f 00       	push   $0x7ff000
  800f3c:	e8 8d fa ff ff       	call   8009ce <memcpy>
    	if ((r = sys_page_map(envid, (void *) PFTEMP, envid, addr , PTE_P|PTE_W|PTE_U)) < 0 )
  800f41:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f48:	53                   	push   %ebx
  800f49:	56                   	push   %esi
  800f4a:	68 00 f0 7f 00       	push   $0x7ff000
  800f4f:	56                   	push   %esi
  800f50:	e8 c5 fc ff ff       	call   800c1a <sys_page_map>
  800f55:	83 c4 20             	add    $0x20,%esp
  800f58:	85 c0                	test   %eax,%eax
  800f5a:	79 12                	jns    800f6e <pgfault+0xc7>
        	panic("pgfault: page map failed %e\n", r);
  800f5c:	50                   	push   %eax
  800f5d:	68 d4 25 80 00       	push   $0x8025d4
  800f62:	6a 2f                	push   $0x2f
  800f64:	68 a2 25 80 00       	push   $0x8025a2
  800f69:	e8 ea f1 ff ff       	call   800158 <_panic>
    
    	if ((r = sys_page_unmap(envid, (void *) PFTEMP)) < 0)
  800f6e:	83 ec 08             	sub    $0x8,%esp
  800f71:	68 00 f0 7f 00       	push   $0x7ff000
  800f76:	56                   	push   %esi
  800f77:	e8 e0 fc ff ff       	call   800c5c <sys_page_unmap>
  800f7c:	83 c4 10             	add    $0x10,%esp
  800f7f:	85 c0                	test   %eax,%eax
  800f81:	79 12                	jns    800f95 <pgfault+0xee>
        	panic("pgfault: page unmap failed %e\n", r);
  800f83:	50                   	push   %eax
  800f84:	68 94 26 80 00       	push   $0x802694
  800f89:	6a 32                	push   $0x32
  800f8b:	68 a2 25 80 00       	push   $0x8025a2
  800f90:	e8 c3 f1 ff ff       	call   800158 <_panic>
	//panic("pgfault not implemented");
}
  800f95:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f98:	5b                   	pop    %ebx
  800f99:	5e                   	pop    %esi
  800f9a:	5d                   	pop    %ebp
  800f9b:	c3                   	ret    

00800f9c <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f9c:	55                   	push   %ebp
  800f9d:	89 e5                	mov    %esp,%ebp
  800f9f:	56                   	push   %esi
  800fa0:	53                   	push   %ebx
  800fa1:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	set_pgfault_handler(pgfault);
  800fa4:	68 a7 0e 80 00       	push   $0x800ea7
  800fa9:	e8 f6 0e 00 00       	call   801ea4 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800fae:	b8 07 00 00 00       	mov    $0x7,%eax
  800fb3:	cd 30                	int    $0x30
  800fb5:	89 c3                	mov    %eax,%ebx

	envid_t envid = sys_exofork();
	uint8_t *addr;
	if (envid < 0)
  800fb7:	83 c4 10             	add    $0x10,%esp
  800fba:	85 c0                	test   %eax,%eax
  800fbc:	79 12                	jns    800fd0 <fork+0x34>
		panic("sys_exofork:%e", envid);
  800fbe:	50                   	push   %eax
  800fbf:	68 f1 25 80 00       	push   $0x8025f1
  800fc4:	6a 75                	push   $0x75
  800fc6:	68 a2 25 80 00       	push   $0x8025a2
  800fcb:	e8 88 f1 ff ff       	call   800158 <_panic>
  800fd0:	89 c6                	mov    %eax,%esi
	if (envid == 0) {
  800fd2:	85 c0                	test   %eax,%eax
  800fd4:	75 21                	jne    800ff7 <fork+0x5b>
		thisenv = &envs[ENVX(sys_getenvid())];
  800fd6:	e8 be fb ff ff       	call   800b99 <sys_getenvid>
  800fdb:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fe0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fe3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fe8:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800fed:	b8 00 00 00 00       	mov    $0x0,%eax
  800ff2:	e9 c0 00 00 00       	jmp    8010b7 <fork+0x11b>
	}

	for (addr = (uint8_t *)UTEXT; addr < (uint8_t *)USTACKTOP-PGSIZE; addr += PGSIZE) {
  800ff7:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  800ffe:	ba 00 00 80 00       	mov    $0x800000,%edx
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
  801003:	89 d0                	mov    %edx,%eax
  801005:	c1 e8 16             	shr    $0x16,%eax
  801008:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80100f:	a8 01                	test   $0x1,%al
  801011:	74 20                	je     801033 <fork+0x97>
  801013:	c1 ea 0c             	shr    $0xc,%edx
  801016:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80101d:	a8 01                	test   $0x1,%al
  80101f:	74 12                	je     801033 <fork+0x97>
				&& (uvpt[PGNUM(addr)] & PTE_U)) {
  801021:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801028:	a8 04                	test   $0x4,%al
  80102a:	74 07                	je     801033 <fork+0x97>
			duppage(envid, PGNUM(addr));
  80102c:	89 f0                	mov    %esi,%eax
  80102e:	e8 95 fd ff ff       	call   800dc8 <duppage>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}

	for (addr = (uint8_t *)UTEXT; addr < (uint8_t *)USTACKTOP-PGSIZE; addr += PGSIZE) {
  801033:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801036:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
  80103c:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80103f:	81 fa ff cf bf ee    	cmp    $0xeebfcfff,%edx
  801045:	76 bc                	jbe    801003 <fork+0x67>
				&& (uvpt[PGNUM(addr)] & PTE_U)) {
			duppage(envid, PGNUM(addr));
		}
	}

	duppage(envid, PGNUM(ROUNDDOWN(&addr, PGSIZE)));
  801047:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80104a:	c1 ea 0c             	shr    $0xc,%edx
  80104d:	89 d8                	mov    %ebx,%eax
  80104f:	e8 74 fd ff ff       	call   800dc8 <duppage>

	int r;
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)))
  801054:	83 ec 04             	sub    $0x4,%esp
  801057:	6a 07                	push   $0x7
  801059:	68 00 f0 bf ee       	push   $0xeebff000
  80105e:	53                   	push   %ebx
  80105f:	e8 73 fb ff ff       	call   800bd7 <sys_page_alloc>
  801064:	83 c4 10             	add    $0x10,%esp
  801067:	85 c0                	test   %eax,%eax
  801069:	74 15                	je     801080 <fork+0xe4>
		panic("sys_page_alloc:%e", r);
  80106b:	50                   	push   %eax
  80106c:	68 00 26 80 00       	push   $0x802600
  801071:	68 86 00 00 00       	push   $0x86
  801076:	68 a2 25 80 00       	push   $0x8025a2
  80107b:	e8 d8 f0 ff ff       	call   800158 <_panic>

	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801080:	83 ec 08             	sub    $0x8,%esp
  801083:	68 0c 1f 80 00       	push   $0x801f0c
  801088:	53                   	push   %ebx
  801089:	e8 94 fc ff ff       	call   800d22 <sys_env_set_pgfault_upcall>

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)))
  80108e:	83 c4 08             	add    $0x8,%esp
  801091:	6a 02                	push   $0x2
  801093:	53                   	push   %ebx
  801094:	e8 05 fc ff ff       	call   800c9e <sys_env_set_status>
  801099:	83 c4 10             	add    $0x10,%esp
  80109c:	85 c0                	test   %eax,%eax
  80109e:	74 15                	je     8010b5 <fork+0x119>
		panic("sys_env_set_status:%e", r);
  8010a0:	50                   	push   %eax
  8010a1:	68 12 26 80 00       	push   $0x802612
  8010a6:	68 8c 00 00 00       	push   $0x8c
  8010ab:	68 a2 25 80 00       	push   $0x8025a2
  8010b0:	e8 a3 f0 ff ff       	call   800158 <_panic>

	return envid;
  8010b5:	89 d8                	mov    %ebx,%eax
	    
}
  8010b7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010ba:	5b                   	pop    %ebx
  8010bb:	5e                   	pop    %esi
  8010bc:	5d                   	pop    %ebp
  8010bd:	c3                   	ret    

008010be <sfork>:

// Challenge!
int
sfork(void)
{
  8010be:	55                   	push   %ebp
  8010bf:	89 e5                	mov    %esp,%ebp
  8010c1:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010c4:	68 28 26 80 00       	push   $0x802628
  8010c9:	68 96 00 00 00       	push   $0x96
  8010ce:	68 a2 25 80 00       	push   $0x8025a2
  8010d3:	e8 80 f0 ff ff       	call   800158 <_panic>

008010d8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8010d8:	55                   	push   %ebp
  8010d9:	89 e5                	mov    %esp,%ebp
  8010db:	56                   	push   %esi
  8010dc:	53                   	push   %ebx
  8010dd:	8b 75 08             	mov    0x8(%ebp),%esi
  8010e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010e3:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_recv not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  8010e6:	85 c0                	test   %eax,%eax
  8010e8:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8010ed:	0f 44 c2             	cmove  %edx,%eax

    int r = sys_ipc_recv(pg);
  8010f0:	83 ec 0c             	sub    $0xc,%esp
  8010f3:	50                   	push   %eax
  8010f4:	e8 8e fc ff ff       	call   800d87 <sys_ipc_recv>
    int from_env = 0, perm = 0;
    if (r == 0) {
  8010f9:	83 c4 10             	add    $0x10,%esp
  8010fc:	85 c0                	test   %eax,%eax
  8010fe:	75 10                	jne    801110 <ipc_recv+0x38>
        from_env = thisenv->env_ipc_from;
  801100:	a1 04 40 80 00       	mov    0x804004,%eax
  801105:	8b 48 74             	mov    0x74(%eax),%ecx
        perm = thisenv->env_ipc_perm;
  801108:	8b 50 78             	mov    0x78(%eax),%edx
        r = thisenv->env_ipc_value;
  80110b:	8b 40 70             	mov    0x70(%eax),%eax
  80110e:	eb 0a                	jmp    80111a <ipc_recv+0x42>
    } else {
        from_env = 0;
        perm = 0;
  801110:	ba 00 00 00 00       	mov    $0x0,%edx
    if (r == 0) {
        from_env = thisenv->env_ipc_from;
        perm = thisenv->env_ipc_perm;
        r = thisenv->env_ipc_value;
    } else {
        from_env = 0;
  801115:	b9 00 00 00 00       	mov    $0x0,%ecx
        perm = 0;
    }

    if (from_env_store) *from_env_store = from_env;
  80111a:	85 f6                	test   %esi,%esi
  80111c:	74 02                	je     801120 <ipc_recv+0x48>
  80111e:	89 0e                	mov    %ecx,(%esi)
    if (perm_store) *perm_store = perm;
  801120:	85 db                	test   %ebx,%ebx
  801122:	74 02                	je     801126 <ipc_recv+0x4e>
  801124:	89 13                	mov    %edx,(%ebx)

    return r;
}
  801126:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801129:	5b                   	pop    %ebx
  80112a:	5e                   	pop    %esi
  80112b:	5d                   	pop    %ebp
  80112c:	c3                   	ret    

0080112d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80112d:	55                   	push   %ebp
  80112e:	89 e5                	mov    %esp,%ebp
  801130:	57                   	push   %edi
  801131:	56                   	push   %esi
  801132:	53                   	push   %ebx
  801133:	83 ec 0c             	sub    $0xc,%esp
  801136:	8b 7d 08             	mov    0x8(%ebp),%edi
  801139:	8b 75 0c             	mov    0xc(%ebp),%esi
  80113c:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  80113f:	85 db                	test   %ebx,%ebx
  801141:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801146:	0f 44 d8             	cmove  %eax,%ebx
  801149:	eb 1c                	jmp    801167 <ipc_send+0x3a>

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        if (ret != -E_IPC_NOT_RECV)
  80114b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80114e:	74 12                	je     801162 <ipc_send+0x35>
            panic("ipc_send error %e", ret);
  801150:	50                   	push   %eax
  801151:	68 b3 26 80 00       	push   $0x8026b3
  801156:	6a 40                	push   $0x40
  801158:	68 c5 26 80 00       	push   $0x8026c5
  80115d:	e8 f6 ef ff ff       	call   800158 <_panic>
        sys_yield();
  801162:	e8 51 fa ff ff       	call   800bb8 <sys_yield>
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801167:	ff 75 14             	pushl  0x14(%ebp)
  80116a:	53                   	push   %ebx
  80116b:	56                   	push   %esi
  80116c:	57                   	push   %edi
  80116d:	e8 f2 fb ff ff       	call   800d64 <sys_ipc_try_send>
  801172:	83 c4 10             	add    $0x10,%esp
  801175:	85 c0                	test   %eax,%eax
  801177:	75 d2                	jne    80114b <ipc_send+0x1e>
        if (ret != -E_IPC_NOT_RECV)
            panic("ipc_send error %e", ret);
        sys_yield();
    }
}
  801179:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80117c:	5b                   	pop    %ebx
  80117d:	5e                   	pop    %esi
  80117e:	5f                   	pop    %edi
  80117f:	5d                   	pop    %ebp
  801180:	c3                   	ret    

00801181 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801181:	55                   	push   %ebp
  801182:	89 e5                	mov    %esp,%ebp
  801184:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801187:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80118c:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80118f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801195:	8b 52 50             	mov    0x50(%edx),%edx
  801198:	39 ca                	cmp    %ecx,%edx
  80119a:	75 0d                	jne    8011a9 <ipc_find_env+0x28>
			return envs[i].env_id;
  80119c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80119f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011a4:	8b 40 48             	mov    0x48(%eax),%eax
  8011a7:	eb 0f                	jmp    8011b8 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8011a9:	83 c0 01             	add    $0x1,%eax
  8011ac:	3d 00 04 00 00       	cmp    $0x400,%eax
  8011b1:	75 d9                	jne    80118c <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8011b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011b8:	5d                   	pop    %ebp
  8011b9:	c3                   	ret    

008011ba <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011ba:	55                   	push   %ebp
  8011bb:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c0:	05 00 00 00 30       	add    $0x30000000,%eax
  8011c5:	c1 e8 0c             	shr    $0xc,%eax
}
  8011c8:	5d                   	pop    %ebp
  8011c9:	c3                   	ret    

008011ca <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011ca:	55                   	push   %ebp
  8011cb:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d0:	05 00 00 00 30       	add    $0x30000000,%eax
  8011d5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011da:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011df:	5d                   	pop    %ebp
  8011e0:	c3                   	ret    

008011e1 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011e1:	55                   	push   %ebp
  8011e2:	89 e5                	mov    %esp,%ebp
  8011e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011e7:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011ec:	89 c2                	mov    %eax,%edx
  8011ee:	c1 ea 16             	shr    $0x16,%edx
  8011f1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011f8:	f6 c2 01             	test   $0x1,%dl
  8011fb:	74 11                	je     80120e <fd_alloc+0x2d>
  8011fd:	89 c2                	mov    %eax,%edx
  8011ff:	c1 ea 0c             	shr    $0xc,%edx
  801202:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801209:	f6 c2 01             	test   $0x1,%dl
  80120c:	75 09                	jne    801217 <fd_alloc+0x36>
			*fd_store = fd;
  80120e:	89 01                	mov    %eax,(%ecx)
			return 0;
  801210:	b8 00 00 00 00       	mov    $0x0,%eax
  801215:	eb 17                	jmp    80122e <fd_alloc+0x4d>
  801217:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80121c:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801221:	75 c9                	jne    8011ec <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801223:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801229:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80122e:	5d                   	pop    %ebp
  80122f:	c3                   	ret    

00801230 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801230:	55                   	push   %ebp
  801231:	89 e5                	mov    %esp,%ebp
  801233:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801236:	83 f8 1f             	cmp    $0x1f,%eax
  801239:	77 36                	ja     801271 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80123b:	c1 e0 0c             	shl    $0xc,%eax
  80123e:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801243:	89 c2                	mov    %eax,%edx
  801245:	c1 ea 16             	shr    $0x16,%edx
  801248:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80124f:	f6 c2 01             	test   $0x1,%dl
  801252:	74 24                	je     801278 <fd_lookup+0x48>
  801254:	89 c2                	mov    %eax,%edx
  801256:	c1 ea 0c             	shr    $0xc,%edx
  801259:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801260:	f6 c2 01             	test   $0x1,%dl
  801263:	74 1a                	je     80127f <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801265:	8b 55 0c             	mov    0xc(%ebp),%edx
  801268:	89 02                	mov    %eax,(%edx)
	return 0;
  80126a:	b8 00 00 00 00       	mov    $0x0,%eax
  80126f:	eb 13                	jmp    801284 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801271:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801276:	eb 0c                	jmp    801284 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801278:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80127d:	eb 05                	jmp    801284 <fd_lookup+0x54>
  80127f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801284:	5d                   	pop    %ebp
  801285:	c3                   	ret    

00801286 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801286:	55                   	push   %ebp
  801287:	89 e5                	mov    %esp,%ebp
  801289:	83 ec 08             	sub    $0x8,%esp
  80128c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80128f:	ba 4c 27 80 00       	mov    $0x80274c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801294:	eb 13                	jmp    8012a9 <dev_lookup+0x23>
  801296:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801299:	39 08                	cmp    %ecx,(%eax)
  80129b:	75 0c                	jne    8012a9 <dev_lookup+0x23>
			*dev = devtab[i];
  80129d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012a0:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8012a7:	eb 2e                	jmp    8012d7 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012a9:	8b 02                	mov    (%edx),%eax
  8012ab:	85 c0                	test   %eax,%eax
  8012ad:	75 e7                	jne    801296 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012af:	a1 04 40 80 00       	mov    0x804004,%eax
  8012b4:	8b 40 48             	mov    0x48(%eax),%eax
  8012b7:	83 ec 04             	sub    $0x4,%esp
  8012ba:	51                   	push   %ecx
  8012bb:	50                   	push   %eax
  8012bc:	68 d0 26 80 00       	push   $0x8026d0
  8012c1:	e8 6b ef ff ff       	call   800231 <cprintf>
	*dev = 0;
  8012c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012c9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012cf:	83 c4 10             	add    $0x10,%esp
  8012d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012d7:	c9                   	leave  
  8012d8:	c3                   	ret    

008012d9 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012d9:	55                   	push   %ebp
  8012da:	89 e5                	mov    %esp,%ebp
  8012dc:	56                   	push   %esi
  8012dd:	53                   	push   %ebx
  8012de:	83 ec 10             	sub    $0x10,%esp
  8012e1:	8b 75 08             	mov    0x8(%ebp),%esi
  8012e4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012ea:	50                   	push   %eax
  8012eb:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012f1:	c1 e8 0c             	shr    $0xc,%eax
  8012f4:	50                   	push   %eax
  8012f5:	e8 36 ff ff ff       	call   801230 <fd_lookup>
  8012fa:	83 c4 08             	add    $0x8,%esp
  8012fd:	85 c0                	test   %eax,%eax
  8012ff:	78 05                	js     801306 <fd_close+0x2d>
	    || fd != fd2)
  801301:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801304:	74 0c                	je     801312 <fd_close+0x39>
		return (must_exist ? r : 0);
  801306:	84 db                	test   %bl,%bl
  801308:	ba 00 00 00 00       	mov    $0x0,%edx
  80130d:	0f 44 c2             	cmove  %edx,%eax
  801310:	eb 41                	jmp    801353 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801312:	83 ec 08             	sub    $0x8,%esp
  801315:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801318:	50                   	push   %eax
  801319:	ff 36                	pushl  (%esi)
  80131b:	e8 66 ff ff ff       	call   801286 <dev_lookup>
  801320:	89 c3                	mov    %eax,%ebx
  801322:	83 c4 10             	add    $0x10,%esp
  801325:	85 c0                	test   %eax,%eax
  801327:	78 1a                	js     801343 <fd_close+0x6a>
		if (dev->dev_close)
  801329:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80132c:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80132f:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801334:	85 c0                	test   %eax,%eax
  801336:	74 0b                	je     801343 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801338:	83 ec 0c             	sub    $0xc,%esp
  80133b:	56                   	push   %esi
  80133c:	ff d0                	call   *%eax
  80133e:	89 c3                	mov    %eax,%ebx
  801340:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801343:	83 ec 08             	sub    $0x8,%esp
  801346:	56                   	push   %esi
  801347:	6a 00                	push   $0x0
  801349:	e8 0e f9 ff ff       	call   800c5c <sys_page_unmap>
	return r;
  80134e:	83 c4 10             	add    $0x10,%esp
  801351:	89 d8                	mov    %ebx,%eax
}
  801353:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801356:	5b                   	pop    %ebx
  801357:	5e                   	pop    %esi
  801358:	5d                   	pop    %ebp
  801359:	c3                   	ret    

0080135a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80135a:	55                   	push   %ebp
  80135b:	89 e5                	mov    %esp,%ebp
  80135d:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801360:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801363:	50                   	push   %eax
  801364:	ff 75 08             	pushl  0x8(%ebp)
  801367:	e8 c4 fe ff ff       	call   801230 <fd_lookup>
  80136c:	83 c4 08             	add    $0x8,%esp
  80136f:	85 c0                	test   %eax,%eax
  801371:	78 10                	js     801383 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801373:	83 ec 08             	sub    $0x8,%esp
  801376:	6a 01                	push   $0x1
  801378:	ff 75 f4             	pushl  -0xc(%ebp)
  80137b:	e8 59 ff ff ff       	call   8012d9 <fd_close>
  801380:	83 c4 10             	add    $0x10,%esp
}
  801383:	c9                   	leave  
  801384:	c3                   	ret    

00801385 <close_all>:

void
close_all(void)
{
  801385:	55                   	push   %ebp
  801386:	89 e5                	mov    %esp,%ebp
  801388:	53                   	push   %ebx
  801389:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80138c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801391:	83 ec 0c             	sub    $0xc,%esp
  801394:	53                   	push   %ebx
  801395:	e8 c0 ff ff ff       	call   80135a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80139a:	83 c3 01             	add    $0x1,%ebx
  80139d:	83 c4 10             	add    $0x10,%esp
  8013a0:	83 fb 20             	cmp    $0x20,%ebx
  8013a3:	75 ec                	jne    801391 <close_all+0xc>
		close(i);
}
  8013a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013a8:	c9                   	leave  
  8013a9:	c3                   	ret    

008013aa <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013aa:	55                   	push   %ebp
  8013ab:	89 e5                	mov    %esp,%ebp
  8013ad:	57                   	push   %edi
  8013ae:	56                   	push   %esi
  8013af:	53                   	push   %ebx
  8013b0:	83 ec 2c             	sub    $0x2c,%esp
  8013b3:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013b6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013b9:	50                   	push   %eax
  8013ba:	ff 75 08             	pushl  0x8(%ebp)
  8013bd:	e8 6e fe ff ff       	call   801230 <fd_lookup>
  8013c2:	83 c4 08             	add    $0x8,%esp
  8013c5:	85 c0                	test   %eax,%eax
  8013c7:	0f 88 c1 00 00 00    	js     80148e <dup+0xe4>
		return r;
	close(newfdnum);
  8013cd:	83 ec 0c             	sub    $0xc,%esp
  8013d0:	56                   	push   %esi
  8013d1:	e8 84 ff ff ff       	call   80135a <close>

	newfd = INDEX2FD(newfdnum);
  8013d6:	89 f3                	mov    %esi,%ebx
  8013d8:	c1 e3 0c             	shl    $0xc,%ebx
  8013db:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013e1:	83 c4 04             	add    $0x4,%esp
  8013e4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013e7:	e8 de fd ff ff       	call   8011ca <fd2data>
  8013ec:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013ee:	89 1c 24             	mov    %ebx,(%esp)
  8013f1:	e8 d4 fd ff ff       	call   8011ca <fd2data>
  8013f6:	83 c4 10             	add    $0x10,%esp
  8013f9:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013fc:	89 f8                	mov    %edi,%eax
  8013fe:	c1 e8 16             	shr    $0x16,%eax
  801401:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801408:	a8 01                	test   $0x1,%al
  80140a:	74 37                	je     801443 <dup+0x99>
  80140c:	89 f8                	mov    %edi,%eax
  80140e:	c1 e8 0c             	shr    $0xc,%eax
  801411:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801418:	f6 c2 01             	test   $0x1,%dl
  80141b:	74 26                	je     801443 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80141d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801424:	83 ec 0c             	sub    $0xc,%esp
  801427:	25 07 0e 00 00       	and    $0xe07,%eax
  80142c:	50                   	push   %eax
  80142d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801430:	6a 00                	push   $0x0
  801432:	57                   	push   %edi
  801433:	6a 00                	push   $0x0
  801435:	e8 e0 f7 ff ff       	call   800c1a <sys_page_map>
  80143a:	89 c7                	mov    %eax,%edi
  80143c:	83 c4 20             	add    $0x20,%esp
  80143f:	85 c0                	test   %eax,%eax
  801441:	78 2e                	js     801471 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801443:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801446:	89 d0                	mov    %edx,%eax
  801448:	c1 e8 0c             	shr    $0xc,%eax
  80144b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801452:	83 ec 0c             	sub    $0xc,%esp
  801455:	25 07 0e 00 00       	and    $0xe07,%eax
  80145a:	50                   	push   %eax
  80145b:	53                   	push   %ebx
  80145c:	6a 00                	push   $0x0
  80145e:	52                   	push   %edx
  80145f:	6a 00                	push   $0x0
  801461:	e8 b4 f7 ff ff       	call   800c1a <sys_page_map>
  801466:	89 c7                	mov    %eax,%edi
  801468:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80146b:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80146d:	85 ff                	test   %edi,%edi
  80146f:	79 1d                	jns    80148e <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801471:	83 ec 08             	sub    $0x8,%esp
  801474:	53                   	push   %ebx
  801475:	6a 00                	push   $0x0
  801477:	e8 e0 f7 ff ff       	call   800c5c <sys_page_unmap>
	sys_page_unmap(0, nva);
  80147c:	83 c4 08             	add    $0x8,%esp
  80147f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801482:	6a 00                	push   $0x0
  801484:	e8 d3 f7 ff ff       	call   800c5c <sys_page_unmap>
	return r;
  801489:	83 c4 10             	add    $0x10,%esp
  80148c:	89 f8                	mov    %edi,%eax
}
  80148e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801491:	5b                   	pop    %ebx
  801492:	5e                   	pop    %esi
  801493:	5f                   	pop    %edi
  801494:	5d                   	pop    %ebp
  801495:	c3                   	ret    

00801496 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801496:	55                   	push   %ebp
  801497:	89 e5                	mov    %esp,%ebp
  801499:	53                   	push   %ebx
  80149a:	83 ec 14             	sub    $0x14,%esp
  80149d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014a0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014a3:	50                   	push   %eax
  8014a4:	53                   	push   %ebx
  8014a5:	e8 86 fd ff ff       	call   801230 <fd_lookup>
  8014aa:	83 c4 08             	add    $0x8,%esp
  8014ad:	89 c2                	mov    %eax,%edx
  8014af:	85 c0                	test   %eax,%eax
  8014b1:	78 6d                	js     801520 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014b3:	83 ec 08             	sub    $0x8,%esp
  8014b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014b9:	50                   	push   %eax
  8014ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014bd:	ff 30                	pushl  (%eax)
  8014bf:	e8 c2 fd ff ff       	call   801286 <dev_lookup>
  8014c4:	83 c4 10             	add    $0x10,%esp
  8014c7:	85 c0                	test   %eax,%eax
  8014c9:	78 4c                	js     801517 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014cb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014ce:	8b 42 08             	mov    0x8(%edx),%eax
  8014d1:	83 e0 03             	and    $0x3,%eax
  8014d4:	83 f8 01             	cmp    $0x1,%eax
  8014d7:	75 21                	jne    8014fa <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014d9:	a1 04 40 80 00       	mov    0x804004,%eax
  8014de:	8b 40 48             	mov    0x48(%eax),%eax
  8014e1:	83 ec 04             	sub    $0x4,%esp
  8014e4:	53                   	push   %ebx
  8014e5:	50                   	push   %eax
  8014e6:	68 11 27 80 00       	push   $0x802711
  8014eb:	e8 41 ed ff ff       	call   800231 <cprintf>
		return -E_INVAL;
  8014f0:	83 c4 10             	add    $0x10,%esp
  8014f3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014f8:	eb 26                	jmp    801520 <read+0x8a>
	}
	if (!dev->dev_read)
  8014fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014fd:	8b 40 08             	mov    0x8(%eax),%eax
  801500:	85 c0                	test   %eax,%eax
  801502:	74 17                	je     80151b <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801504:	83 ec 04             	sub    $0x4,%esp
  801507:	ff 75 10             	pushl  0x10(%ebp)
  80150a:	ff 75 0c             	pushl  0xc(%ebp)
  80150d:	52                   	push   %edx
  80150e:	ff d0                	call   *%eax
  801510:	89 c2                	mov    %eax,%edx
  801512:	83 c4 10             	add    $0x10,%esp
  801515:	eb 09                	jmp    801520 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801517:	89 c2                	mov    %eax,%edx
  801519:	eb 05                	jmp    801520 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80151b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801520:	89 d0                	mov    %edx,%eax
  801522:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801525:	c9                   	leave  
  801526:	c3                   	ret    

00801527 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801527:	55                   	push   %ebp
  801528:	89 e5                	mov    %esp,%ebp
  80152a:	57                   	push   %edi
  80152b:	56                   	push   %esi
  80152c:	53                   	push   %ebx
  80152d:	83 ec 0c             	sub    $0xc,%esp
  801530:	8b 7d 08             	mov    0x8(%ebp),%edi
  801533:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801536:	bb 00 00 00 00       	mov    $0x0,%ebx
  80153b:	eb 21                	jmp    80155e <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80153d:	83 ec 04             	sub    $0x4,%esp
  801540:	89 f0                	mov    %esi,%eax
  801542:	29 d8                	sub    %ebx,%eax
  801544:	50                   	push   %eax
  801545:	89 d8                	mov    %ebx,%eax
  801547:	03 45 0c             	add    0xc(%ebp),%eax
  80154a:	50                   	push   %eax
  80154b:	57                   	push   %edi
  80154c:	e8 45 ff ff ff       	call   801496 <read>
		if (m < 0)
  801551:	83 c4 10             	add    $0x10,%esp
  801554:	85 c0                	test   %eax,%eax
  801556:	78 10                	js     801568 <readn+0x41>
			return m;
		if (m == 0)
  801558:	85 c0                	test   %eax,%eax
  80155a:	74 0a                	je     801566 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80155c:	01 c3                	add    %eax,%ebx
  80155e:	39 f3                	cmp    %esi,%ebx
  801560:	72 db                	jb     80153d <readn+0x16>
  801562:	89 d8                	mov    %ebx,%eax
  801564:	eb 02                	jmp    801568 <readn+0x41>
  801566:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801568:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80156b:	5b                   	pop    %ebx
  80156c:	5e                   	pop    %esi
  80156d:	5f                   	pop    %edi
  80156e:	5d                   	pop    %ebp
  80156f:	c3                   	ret    

00801570 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801570:	55                   	push   %ebp
  801571:	89 e5                	mov    %esp,%ebp
  801573:	53                   	push   %ebx
  801574:	83 ec 14             	sub    $0x14,%esp
  801577:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80157a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80157d:	50                   	push   %eax
  80157e:	53                   	push   %ebx
  80157f:	e8 ac fc ff ff       	call   801230 <fd_lookup>
  801584:	83 c4 08             	add    $0x8,%esp
  801587:	89 c2                	mov    %eax,%edx
  801589:	85 c0                	test   %eax,%eax
  80158b:	78 68                	js     8015f5 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80158d:	83 ec 08             	sub    $0x8,%esp
  801590:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801593:	50                   	push   %eax
  801594:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801597:	ff 30                	pushl  (%eax)
  801599:	e8 e8 fc ff ff       	call   801286 <dev_lookup>
  80159e:	83 c4 10             	add    $0x10,%esp
  8015a1:	85 c0                	test   %eax,%eax
  8015a3:	78 47                	js     8015ec <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015a8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015ac:	75 21                	jne    8015cf <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015ae:	a1 04 40 80 00       	mov    0x804004,%eax
  8015b3:	8b 40 48             	mov    0x48(%eax),%eax
  8015b6:	83 ec 04             	sub    $0x4,%esp
  8015b9:	53                   	push   %ebx
  8015ba:	50                   	push   %eax
  8015bb:	68 2d 27 80 00       	push   $0x80272d
  8015c0:	e8 6c ec ff ff       	call   800231 <cprintf>
		return -E_INVAL;
  8015c5:	83 c4 10             	add    $0x10,%esp
  8015c8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015cd:	eb 26                	jmp    8015f5 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015cf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015d2:	8b 52 0c             	mov    0xc(%edx),%edx
  8015d5:	85 d2                	test   %edx,%edx
  8015d7:	74 17                	je     8015f0 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015d9:	83 ec 04             	sub    $0x4,%esp
  8015dc:	ff 75 10             	pushl  0x10(%ebp)
  8015df:	ff 75 0c             	pushl  0xc(%ebp)
  8015e2:	50                   	push   %eax
  8015e3:	ff d2                	call   *%edx
  8015e5:	89 c2                	mov    %eax,%edx
  8015e7:	83 c4 10             	add    $0x10,%esp
  8015ea:	eb 09                	jmp    8015f5 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ec:	89 c2                	mov    %eax,%edx
  8015ee:	eb 05                	jmp    8015f5 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015f0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015f5:	89 d0                	mov    %edx,%eax
  8015f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015fa:	c9                   	leave  
  8015fb:	c3                   	ret    

008015fc <seek>:

int
seek(int fdnum, off_t offset)
{
  8015fc:	55                   	push   %ebp
  8015fd:	89 e5                	mov    %esp,%ebp
  8015ff:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801602:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801605:	50                   	push   %eax
  801606:	ff 75 08             	pushl  0x8(%ebp)
  801609:	e8 22 fc ff ff       	call   801230 <fd_lookup>
  80160e:	83 c4 08             	add    $0x8,%esp
  801611:	85 c0                	test   %eax,%eax
  801613:	78 0e                	js     801623 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801615:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801618:	8b 55 0c             	mov    0xc(%ebp),%edx
  80161b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80161e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801623:	c9                   	leave  
  801624:	c3                   	ret    

00801625 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801625:	55                   	push   %ebp
  801626:	89 e5                	mov    %esp,%ebp
  801628:	53                   	push   %ebx
  801629:	83 ec 14             	sub    $0x14,%esp
  80162c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80162f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801632:	50                   	push   %eax
  801633:	53                   	push   %ebx
  801634:	e8 f7 fb ff ff       	call   801230 <fd_lookup>
  801639:	83 c4 08             	add    $0x8,%esp
  80163c:	89 c2                	mov    %eax,%edx
  80163e:	85 c0                	test   %eax,%eax
  801640:	78 65                	js     8016a7 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801642:	83 ec 08             	sub    $0x8,%esp
  801645:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801648:	50                   	push   %eax
  801649:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80164c:	ff 30                	pushl  (%eax)
  80164e:	e8 33 fc ff ff       	call   801286 <dev_lookup>
  801653:	83 c4 10             	add    $0x10,%esp
  801656:	85 c0                	test   %eax,%eax
  801658:	78 44                	js     80169e <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80165a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80165d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801661:	75 21                	jne    801684 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801663:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801668:	8b 40 48             	mov    0x48(%eax),%eax
  80166b:	83 ec 04             	sub    $0x4,%esp
  80166e:	53                   	push   %ebx
  80166f:	50                   	push   %eax
  801670:	68 f0 26 80 00       	push   $0x8026f0
  801675:	e8 b7 eb ff ff       	call   800231 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80167a:	83 c4 10             	add    $0x10,%esp
  80167d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801682:	eb 23                	jmp    8016a7 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801684:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801687:	8b 52 18             	mov    0x18(%edx),%edx
  80168a:	85 d2                	test   %edx,%edx
  80168c:	74 14                	je     8016a2 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80168e:	83 ec 08             	sub    $0x8,%esp
  801691:	ff 75 0c             	pushl  0xc(%ebp)
  801694:	50                   	push   %eax
  801695:	ff d2                	call   *%edx
  801697:	89 c2                	mov    %eax,%edx
  801699:	83 c4 10             	add    $0x10,%esp
  80169c:	eb 09                	jmp    8016a7 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80169e:	89 c2                	mov    %eax,%edx
  8016a0:	eb 05                	jmp    8016a7 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016a2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8016a7:	89 d0                	mov    %edx,%eax
  8016a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ac:	c9                   	leave  
  8016ad:	c3                   	ret    

008016ae <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016ae:	55                   	push   %ebp
  8016af:	89 e5                	mov    %esp,%ebp
  8016b1:	53                   	push   %ebx
  8016b2:	83 ec 14             	sub    $0x14,%esp
  8016b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016b8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016bb:	50                   	push   %eax
  8016bc:	ff 75 08             	pushl  0x8(%ebp)
  8016bf:	e8 6c fb ff ff       	call   801230 <fd_lookup>
  8016c4:	83 c4 08             	add    $0x8,%esp
  8016c7:	89 c2                	mov    %eax,%edx
  8016c9:	85 c0                	test   %eax,%eax
  8016cb:	78 58                	js     801725 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016cd:	83 ec 08             	sub    $0x8,%esp
  8016d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016d3:	50                   	push   %eax
  8016d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016d7:	ff 30                	pushl  (%eax)
  8016d9:	e8 a8 fb ff ff       	call   801286 <dev_lookup>
  8016de:	83 c4 10             	add    $0x10,%esp
  8016e1:	85 c0                	test   %eax,%eax
  8016e3:	78 37                	js     80171c <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016e8:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016ec:	74 32                	je     801720 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016ee:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016f1:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016f8:	00 00 00 
	stat->st_isdir = 0;
  8016fb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801702:	00 00 00 
	stat->st_dev = dev;
  801705:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80170b:	83 ec 08             	sub    $0x8,%esp
  80170e:	53                   	push   %ebx
  80170f:	ff 75 f0             	pushl  -0x10(%ebp)
  801712:	ff 50 14             	call   *0x14(%eax)
  801715:	89 c2                	mov    %eax,%edx
  801717:	83 c4 10             	add    $0x10,%esp
  80171a:	eb 09                	jmp    801725 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80171c:	89 c2                	mov    %eax,%edx
  80171e:	eb 05                	jmp    801725 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801720:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801725:	89 d0                	mov    %edx,%eax
  801727:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80172a:	c9                   	leave  
  80172b:	c3                   	ret    

0080172c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80172c:	55                   	push   %ebp
  80172d:	89 e5                	mov    %esp,%ebp
  80172f:	56                   	push   %esi
  801730:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801731:	83 ec 08             	sub    $0x8,%esp
  801734:	6a 00                	push   $0x0
  801736:	ff 75 08             	pushl  0x8(%ebp)
  801739:	e8 e3 01 00 00       	call   801921 <open>
  80173e:	89 c3                	mov    %eax,%ebx
  801740:	83 c4 10             	add    $0x10,%esp
  801743:	85 c0                	test   %eax,%eax
  801745:	78 1b                	js     801762 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801747:	83 ec 08             	sub    $0x8,%esp
  80174a:	ff 75 0c             	pushl  0xc(%ebp)
  80174d:	50                   	push   %eax
  80174e:	e8 5b ff ff ff       	call   8016ae <fstat>
  801753:	89 c6                	mov    %eax,%esi
	close(fd);
  801755:	89 1c 24             	mov    %ebx,(%esp)
  801758:	e8 fd fb ff ff       	call   80135a <close>
	return r;
  80175d:	83 c4 10             	add    $0x10,%esp
  801760:	89 f0                	mov    %esi,%eax
}
  801762:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801765:	5b                   	pop    %ebx
  801766:	5e                   	pop    %esi
  801767:	5d                   	pop    %ebp
  801768:	c3                   	ret    

00801769 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801769:	55                   	push   %ebp
  80176a:	89 e5                	mov    %esp,%ebp
  80176c:	56                   	push   %esi
  80176d:	53                   	push   %ebx
  80176e:	89 c6                	mov    %eax,%esi
  801770:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801772:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801779:	75 12                	jne    80178d <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80177b:	83 ec 0c             	sub    $0xc,%esp
  80177e:	6a 01                	push   $0x1
  801780:	e8 fc f9 ff ff       	call   801181 <ipc_find_env>
  801785:	a3 00 40 80 00       	mov    %eax,0x804000
  80178a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80178d:	6a 07                	push   $0x7
  80178f:	68 00 50 80 00       	push   $0x805000
  801794:	56                   	push   %esi
  801795:	ff 35 00 40 80 00    	pushl  0x804000
  80179b:	e8 8d f9 ff ff       	call   80112d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017a0:	83 c4 0c             	add    $0xc,%esp
  8017a3:	6a 00                	push   $0x0
  8017a5:	53                   	push   %ebx
  8017a6:	6a 00                	push   $0x0
  8017a8:	e8 2b f9 ff ff       	call   8010d8 <ipc_recv>
}
  8017ad:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017b0:	5b                   	pop    %ebx
  8017b1:	5e                   	pop    %esi
  8017b2:	5d                   	pop    %ebp
  8017b3:	c3                   	ret    

008017b4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017b4:	55                   	push   %ebp
  8017b5:	89 e5                	mov    %esp,%ebp
  8017b7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8017bd:	8b 40 0c             	mov    0xc(%eax),%eax
  8017c0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017c8:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d2:	b8 02 00 00 00       	mov    $0x2,%eax
  8017d7:	e8 8d ff ff ff       	call   801769 <fsipc>
}
  8017dc:	c9                   	leave  
  8017dd:	c3                   	ret    

008017de <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017de:	55                   	push   %ebp
  8017df:	89 e5                	mov    %esp,%ebp
  8017e1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e7:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ea:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f4:	b8 06 00 00 00       	mov    $0x6,%eax
  8017f9:	e8 6b ff ff ff       	call   801769 <fsipc>
}
  8017fe:	c9                   	leave  
  8017ff:	c3                   	ret    

00801800 <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801800:	55                   	push   %ebp
  801801:	89 e5                	mov    %esp,%ebp
  801803:	53                   	push   %ebx
  801804:	83 ec 04             	sub    $0x4,%esp
  801807:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80180a:	8b 45 08             	mov    0x8(%ebp),%eax
  80180d:	8b 40 0c             	mov    0xc(%eax),%eax
  801810:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801815:	ba 00 00 00 00       	mov    $0x0,%edx
  80181a:	b8 05 00 00 00       	mov    $0x5,%eax
  80181f:	e8 45 ff ff ff       	call   801769 <fsipc>
  801824:	85 c0                	test   %eax,%eax
  801826:	78 2c                	js     801854 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801828:	83 ec 08             	sub    $0x8,%esp
  80182b:	68 00 50 80 00       	push   $0x805000
  801830:	53                   	push   %ebx
  801831:	e8 9e ef ff ff       	call   8007d4 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801836:	a1 80 50 80 00       	mov    0x805080,%eax
  80183b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801841:	a1 84 50 80 00       	mov    0x805084,%eax
  801846:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80184c:	83 c4 10             	add    $0x10,%esp
  80184f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801854:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801857:	c9                   	leave  
  801858:	c3                   	ret    

00801859 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801859:	55                   	push   %ebp
  80185a:	89 e5                	mov    %esp,%ebp
  80185c:	83 ec 0c             	sub    $0xc,%esp
  80185f:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
    
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  801862:	8b 55 08             	mov    0x8(%ebp),%edx
  801865:	8b 52 0c             	mov    0xc(%edx),%edx
  801868:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = MIN(n, PGSIZE);
  80186e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801873:	ba 00 10 00 00       	mov    $0x1000,%edx
  801878:	0f 47 c2             	cmova  %edx,%eax
  80187b:	a3 04 50 80 00       	mov    %eax,0x805004
    memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801880:	50                   	push   %eax
  801881:	ff 75 0c             	pushl  0xc(%ebp)
  801884:	68 08 50 80 00       	push   $0x805008
  801889:	e8 d8 f0 ff ff       	call   800966 <memmove>
    int r = fsipc(FSREQ_WRITE, NULL);
  80188e:	ba 00 00 00 00       	mov    $0x0,%edx
  801893:	b8 04 00 00 00       	mov    $0x4,%eax
  801898:	e8 cc fe ff ff       	call   801769 <fsipc>
    return r;
}
  80189d:	c9                   	leave  
  80189e:	c3                   	ret    

0080189f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80189f:	55                   	push   %ebp
  8018a0:	89 e5                	mov    %esp,%ebp
  8018a2:	56                   	push   %esi
  8018a3:	53                   	push   %ebx
  8018a4:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018aa:	8b 40 0c             	mov    0xc(%eax),%eax
  8018ad:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018b2:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8018bd:	b8 03 00 00 00       	mov    $0x3,%eax
  8018c2:	e8 a2 fe ff ff       	call   801769 <fsipc>
  8018c7:	89 c3                	mov    %eax,%ebx
  8018c9:	85 c0                	test   %eax,%eax
  8018cb:	78 4b                	js     801918 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018cd:	39 c6                	cmp    %eax,%esi
  8018cf:	73 16                	jae    8018e7 <devfile_read+0x48>
  8018d1:	68 5c 27 80 00       	push   $0x80275c
  8018d6:	68 63 27 80 00       	push   $0x802763
  8018db:	6a 7c                	push   $0x7c
  8018dd:	68 78 27 80 00       	push   $0x802778
  8018e2:	e8 71 e8 ff ff       	call   800158 <_panic>
	assert(r <= PGSIZE);
  8018e7:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018ec:	7e 16                	jle    801904 <devfile_read+0x65>
  8018ee:	68 83 27 80 00       	push   $0x802783
  8018f3:	68 63 27 80 00       	push   $0x802763
  8018f8:	6a 7d                	push   $0x7d
  8018fa:	68 78 27 80 00       	push   $0x802778
  8018ff:	e8 54 e8 ff ff       	call   800158 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801904:	83 ec 04             	sub    $0x4,%esp
  801907:	50                   	push   %eax
  801908:	68 00 50 80 00       	push   $0x805000
  80190d:	ff 75 0c             	pushl  0xc(%ebp)
  801910:	e8 51 f0 ff ff       	call   800966 <memmove>
	return r;
  801915:	83 c4 10             	add    $0x10,%esp
}
  801918:	89 d8                	mov    %ebx,%eax
  80191a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80191d:	5b                   	pop    %ebx
  80191e:	5e                   	pop    %esi
  80191f:	5d                   	pop    %ebp
  801920:	c3                   	ret    

00801921 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801921:	55                   	push   %ebp
  801922:	89 e5                	mov    %esp,%ebp
  801924:	53                   	push   %ebx
  801925:	83 ec 20             	sub    $0x20,%esp
  801928:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80192b:	53                   	push   %ebx
  80192c:	e8 6a ee ff ff       	call   80079b <strlen>
  801931:	83 c4 10             	add    $0x10,%esp
  801934:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801939:	7f 67                	jg     8019a2 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80193b:	83 ec 0c             	sub    $0xc,%esp
  80193e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801941:	50                   	push   %eax
  801942:	e8 9a f8 ff ff       	call   8011e1 <fd_alloc>
  801947:	83 c4 10             	add    $0x10,%esp
		return r;
  80194a:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80194c:	85 c0                	test   %eax,%eax
  80194e:	78 57                	js     8019a7 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801950:	83 ec 08             	sub    $0x8,%esp
  801953:	53                   	push   %ebx
  801954:	68 00 50 80 00       	push   $0x805000
  801959:	e8 76 ee ff ff       	call   8007d4 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80195e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801961:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801966:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801969:	b8 01 00 00 00       	mov    $0x1,%eax
  80196e:	e8 f6 fd ff ff       	call   801769 <fsipc>
  801973:	89 c3                	mov    %eax,%ebx
  801975:	83 c4 10             	add    $0x10,%esp
  801978:	85 c0                	test   %eax,%eax
  80197a:	79 14                	jns    801990 <open+0x6f>
		fd_close(fd, 0);
  80197c:	83 ec 08             	sub    $0x8,%esp
  80197f:	6a 00                	push   $0x0
  801981:	ff 75 f4             	pushl  -0xc(%ebp)
  801984:	e8 50 f9 ff ff       	call   8012d9 <fd_close>
		return r;
  801989:	83 c4 10             	add    $0x10,%esp
  80198c:	89 da                	mov    %ebx,%edx
  80198e:	eb 17                	jmp    8019a7 <open+0x86>
	}

	return fd2num(fd);
  801990:	83 ec 0c             	sub    $0xc,%esp
  801993:	ff 75 f4             	pushl  -0xc(%ebp)
  801996:	e8 1f f8 ff ff       	call   8011ba <fd2num>
  80199b:	89 c2                	mov    %eax,%edx
  80199d:	83 c4 10             	add    $0x10,%esp
  8019a0:	eb 05                	jmp    8019a7 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019a2:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019a7:	89 d0                	mov    %edx,%eax
  8019a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019ac:	c9                   	leave  
  8019ad:	c3                   	ret    

008019ae <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019ae:	55                   	push   %ebp
  8019af:	89 e5                	mov    %esp,%ebp
  8019b1:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8019b9:	b8 08 00 00 00       	mov    $0x8,%eax
  8019be:	e8 a6 fd ff ff       	call   801769 <fsipc>
}
  8019c3:	c9                   	leave  
  8019c4:	c3                   	ret    

008019c5 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019c5:	55                   	push   %ebp
  8019c6:	89 e5                	mov    %esp,%ebp
  8019c8:	56                   	push   %esi
  8019c9:	53                   	push   %ebx
  8019ca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019cd:	83 ec 0c             	sub    $0xc,%esp
  8019d0:	ff 75 08             	pushl  0x8(%ebp)
  8019d3:	e8 f2 f7 ff ff       	call   8011ca <fd2data>
  8019d8:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019da:	83 c4 08             	add    $0x8,%esp
  8019dd:	68 8f 27 80 00       	push   $0x80278f
  8019e2:	53                   	push   %ebx
  8019e3:	e8 ec ed ff ff       	call   8007d4 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019e8:	8b 46 04             	mov    0x4(%esi),%eax
  8019eb:	2b 06                	sub    (%esi),%eax
  8019ed:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019f3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019fa:	00 00 00 
	stat->st_dev = &devpipe;
  8019fd:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a04:	30 80 00 
	return 0;
}
  801a07:	b8 00 00 00 00       	mov    $0x0,%eax
  801a0c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a0f:	5b                   	pop    %ebx
  801a10:	5e                   	pop    %esi
  801a11:	5d                   	pop    %ebp
  801a12:	c3                   	ret    

00801a13 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a13:	55                   	push   %ebp
  801a14:	89 e5                	mov    %esp,%ebp
  801a16:	53                   	push   %ebx
  801a17:	83 ec 0c             	sub    $0xc,%esp
  801a1a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a1d:	53                   	push   %ebx
  801a1e:	6a 00                	push   $0x0
  801a20:	e8 37 f2 ff ff       	call   800c5c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a25:	89 1c 24             	mov    %ebx,(%esp)
  801a28:	e8 9d f7 ff ff       	call   8011ca <fd2data>
  801a2d:	83 c4 08             	add    $0x8,%esp
  801a30:	50                   	push   %eax
  801a31:	6a 00                	push   $0x0
  801a33:	e8 24 f2 ff ff       	call   800c5c <sys_page_unmap>
}
  801a38:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a3b:	c9                   	leave  
  801a3c:	c3                   	ret    

00801a3d <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a3d:	55                   	push   %ebp
  801a3e:	89 e5                	mov    %esp,%ebp
  801a40:	57                   	push   %edi
  801a41:	56                   	push   %esi
  801a42:	53                   	push   %ebx
  801a43:	83 ec 1c             	sub    $0x1c,%esp
  801a46:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a49:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a4b:	a1 04 40 80 00       	mov    0x804004,%eax
  801a50:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a53:	83 ec 0c             	sub    $0xc,%esp
  801a56:	ff 75 e0             	pushl  -0x20(%ebp)
  801a59:	e8 d2 04 00 00       	call   801f30 <pageref>
  801a5e:	89 c3                	mov    %eax,%ebx
  801a60:	89 3c 24             	mov    %edi,(%esp)
  801a63:	e8 c8 04 00 00       	call   801f30 <pageref>
  801a68:	83 c4 10             	add    $0x10,%esp
  801a6b:	39 c3                	cmp    %eax,%ebx
  801a6d:	0f 94 c1             	sete   %cl
  801a70:	0f b6 c9             	movzbl %cl,%ecx
  801a73:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a76:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a7c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a7f:	39 ce                	cmp    %ecx,%esi
  801a81:	74 1b                	je     801a9e <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a83:	39 c3                	cmp    %eax,%ebx
  801a85:	75 c4                	jne    801a4b <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a87:	8b 42 58             	mov    0x58(%edx),%eax
  801a8a:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a8d:	50                   	push   %eax
  801a8e:	56                   	push   %esi
  801a8f:	68 96 27 80 00       	push   $0x802796
  801a94:	e8 98 e7 ff ff       	call   800231 <cprintf>
  801a99:	83 c4 10             	add    $0x10,%esp
  801a9c:	eb ad                	jmp    801a4b <_pipeisclosed+0xe>
	}
}
  801a9e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801aa1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aa4:	5b                   	pop    %ebx
  801aa5:	5e                   	pop    %esi
  801aa6:	5f                   	pop    %edi
  801aa7:	5d                   	pop    %ebp
  801aa8:	c3                   	ret    

00801aa9 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801aa9:	55                   	push   %ebp
  801aaa:	89 e5                	mov    %esp,%ebp
  801aac:	57                   	push   %edi
  801aad:	56                   	push   %esi
  801aae:	53                   	push   %ebx
  801aaf:	83 ec 28             	sub    $0x28,%esp
  801ab2:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ab5:	56                   	push   %esi
  801ab6:	e8 0f f7 ff ff       	call   8011ca <fd2data>
  801abb:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801abd:	83 c4 10             	add    $0x10,%esp
  801ac0:	bf 00 00 00 00       	mov    $0x0,%edi
  801ac5:	eb 4b                	jmp    801b12 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ac7:	89 da                	mov    %ebx,%edx
  801ac9:	89 f0                	mov    %esi,%eax
  801acb:	e8 6d ff ff ff       	call   801a3d <_pipeisclosed>
  801ad0:	85 c0                	test   %eax,%eax
  801ad2:	75 48                	jne    801b1c <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ad4:	e8 df f0 ff ff       	call   800bb8 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ad9:	8b 43 04             	mov    0x4(%ebx),%eax
  801adc:	8b 0b                	mov    (%ebx),%ecx
  801ade:	8d 51 20             	lea    0x20(%ecx),%edx
  801ae1:	39 d0                	cmp    %edx,%eax
  801ae3:	73 e2                	jae    801ac7 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ae5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ae8:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801aec:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801aef:	89 c2                	mov    %eax,%edx
  801af1:	c1 fa 1f             	sar    $0x1f,%edx
  801af4:	89 d1                	mov    %edx,%ecx
  801af6:	c1 e9 1b             	shr    $0x1b,%ecx
  801af9:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801afc:	83 e2 1f             	and    $0x1f,%edx
  801aff:	29 ca                	sub    %ecx,%edx
  801b01:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b05:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b09:	83 c0 01             	add    $0x1,%eax
  801b0c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b0f:	83 c7 01             	add    $0x1,%edi
  801b12:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b15:	75 c2                	jne    801ad9 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b17:	8b 45 10             	mov    0x10(%ebp),%eax
  801b1a:	eb 05                	jmp    801b21 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b1c:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b24:	5b                   	pop    %ebx
  801b25:	5e                   	pop    %esi
  801b26:	5f                   	pop    %edi
  801b27:	5d                   	pop    %ebp
  801b28:	c3                   	ret    

00801b29 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b29:	55                   	push   %ebp
  801b2a:	89 e5                	mov    %esp,%ebp
  801b2c:	57                   	push   %edi
  801b2d:	56                   	push   %esi
  801b2e:	53                   	push   %ebx
  801b2f:	83 ec 18             	sub    $0x18,%esp
  801b32:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b35:	57                   	push   %edi
  801b36:	e8 8f f6 ff ff       	call   8011ca <fd2data>
  801b3b:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b3d:	83 c4 10             	add    $0x10,%esp
  801b40:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b45:	eb 3d                	jmp    801b84 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b47:	85 db                	test   %ebx,%ebx
  801b49:	74 04                	je     801b4f <devpipe_read+0x26>
				return i;
  801b4b:	89 d8                	mov    %ebx,%eax
  801b4d:	eb 44                	jmp    801b93 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b4f:	89 f2                	mov    %esi,%edx
  801b51:	89 f8                	mov    %edi,%eax
  801b53:	e8 e5 fe ff ff       	call   801a3d <_pipeisclosed>
  801b58:	85 c0                	test   %eax,%eax
  801b5a:	75 32                	jne    801b8e <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b5c:	e8 57 f0 ff ff       	call   800bb8 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b61:	8b 06                	mov    (%esi),%eax
  801b63:	3b 46 04             	cmp    0x4(%esi),%eax
  801b66:	74 df                	je     801b47 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b68:	99                   	cltd   
  801b69:	c1 ea 1b             	shr    $0x1b,%edx
  801b6c:	01 d0                	add    %edx,%eax
  801b6e:	83 e0 1f             	and    $0x1f,%eax
  801b71:	29 d0                	sub    %edx,%eax
  801b73:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b7b:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b7e:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b81:	83 c3 01             	add    $0x1,%ebx
  801b84:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b87:	75 d8                	jne    801b61 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b89:	8b 45 10             	mov    0x10(%ebp),%eax
  801b8c:	eb 05                	jmp    801b93 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b8e:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b93:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b96:	5b                   	pop    %ebx
  801b97:	5e                   	pop    %esi
  801b98:	5f                   	pop    %edi
  801b99:	5d                   	pop    %ebp
  801b9a:	c3                   	ret    

00801b9b <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b9b:	55                   	push   %ebp
  801b9c:	89 e5                	mov    %esp,%ebp
  801b9e:	56                   	push   %esi
  801b9f:	53                   	push   %ebx
  801ba0:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ba3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ba6:	50                   	push   %eax
  801ba7:	e8 35 f6 ff ff       	call   8011e1 <fd_alloc>
  801bac:	83 c4 10             	add    $0x10,%esp
  801baf:	89 c2                	mov    %eax,%edx
  801bb1:	85 c0                	test   %eax,%eax
  801bb3:	0f 88 2c 01 00 00    	js     801ce5 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bb9:	83 ec 04             	sub    $0x4,%esp
  801bbc:	68 07 04 00 00       	push   $0x407
  801bc1:	ff 75 f4             	pushl  -0xc(%ebp)
  801bc4:	6a 00                	push   $0x0
  801bc6:	e8 0c f0 ff ff       	call   800bd7 <sys_page_alloc>
  801bcb:	83 c4 10             	add    $0x10,%esp
  801bce:	89 c2                	mov    %eax,%edx
  801bd0:	85 c0                	test   %eax,%eax
  801bd2:	0f 88 0d 01 00 00    	js     801ce5 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801bd8:	83 ec 0c             	sub    $0xc,%esp
  801bdb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bde:	50                   	push   %eax
  801bdf:	e8 fd f5 ff ff       	call   8011e1 <fd_alloc>
  801be4:	89 c3                	mov    %eax,%ebx
  801be6:	83 c4 10             	add    $0x10,%esp
  801be9:	85 c0                	test   %eax,%eax
  801beb:	0f 88 e2 00 00 00    	js     801cd3 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bf1:	83 ec 04             	sub    $0x4,%esp
  801bf4:	68 07 04 00 00       	push   $0x407
  801bf9:	ff 75 f0             	pushl  -0x10(%ebp)
  801bfc:	6a 00                	push   $0x0
  801bfe:	e8 d4 ef ff ff       	call   800bd7 <sys_page_alloc>
  801c03:	89 c3                	mov    %eax,%ebx
  801c05:	83 c4 10             	add    $0x10,%esp
  801c08:	85 c0                	test   %eax,%eax
  801c0a:	0f 88 c3 00 00 00    	js     801cd3 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c10:	83 ec 0c             	sub    $0xc,%esp
  801c13:	ff 75 f4             	pushl  -0xc(%ebp)
  801c16:	e8 af f5 ff ff       	call   8011ca <fd2data>
  801c1b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c1d:	83 c4 0c             	add    $0xc,%esp
  801c20:	68 07 04 00 00       	push   $0x407
  801c25:	50                   	push   %eax
  801c26:	6a 00                	push   $0x0
  801c28:	e8 aa ef ff ff       	call   800bd7 <sys_page_alloc>
  801c2d:	89 c3                	mov    %eax,%ebx
  801c2f:	83 c4 10             	add    $0x10,%esp
  801c32:	85 c0                	test   %eax,%eax
  801c34:	0f 88 89 00 00 00    	js     801cc3 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c3a:	83 ec 0c             	sub    $0xc,%esp
  801c3d:	ff 75 f0             	pushl  -0x10(%ebp)
  801c40:	e8 85 f5 ff ff       	call   8011ca <fd2data>
  801c45:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c4c:	50                   	push   %eax
  801c4d:	6a 00                	push   $0x0
  801c4f:	56                   	push   %esi
  801c50:	6a 00                	push   $0x0
  801c52:	e8 c3 ef ff ff       	call   800c1a <sys_page_map>
  801c57:	89 c3                	mov    %eax,%ebx
  801c59:	83 c4 20             	add    $0x20,%esp
  801c5c:	85 c0                	test   %eax,%eax
  801c5e:	78 55                	js     801cb5 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c60:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c66:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c69:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c6e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c75:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c7e:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c80:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c83:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c8a:	83 ec 0c             	sub    $0xc,%esp
  801c8d:	ff 75 f4             	pushl  -0xc(%ebp)
  801c90:	e8 25 f5 ff ff       	call   8011ba <fd2num>
  801c95:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c98:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c9a:	83 c4 04             	add    $0x4,%esp
  801c9d:	ff 75 f0             	pushl  -0x10(%ebp)
  801ca0:	e8 15 f5 ff ff       	call   8011ba <fd2num>
  801ca5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ca8:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801cab:	83 c4 10             	add    $0x10,%esp
  801cae:	ba 00 00 00 00       	mov    $0x0,%edx
  801cb3:	eb 30                	jmp    801ce5 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801cb5:	83 ec 08             	sub    $0x8,%esp
  801cb8:	56                   	push   %esi
  801cb9:	6a 00                	push   $0x0
  801cbb:	e8 9c ef ff ff       	call   800c5c <sys_page_unmap>
  801cc0:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801cc3:	83 ec 08             	sub    $0x8,%esp
  801cc6:	ff 75 f0             	pushl  -0x10(%ebp)
  801cc9:	6a 00                	push   $0x0
  801ccb:	e8 8c ef ff ff       	call   800c5c <sys_page_unmap>
  801cd0:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801cd3:	83 ec 08             	sub    $0x8,%esp
  801cd6:	ff 75 f4             	pushl  -0xc(%ebp)
  801cd9:	6a 00                	push   $0x0
  801cdb:	e8 7c ef ff ff       	call   800c5c <sys_page_unmap>
  801ce0:	83 c4 10             	add    $0x10,%esp
  801ce3:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801ce5:	89 d0                	mov    %edx,%eax
  801ce7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cea:	5b                   	pop    %ebx
  801ceb:	5e                   	pop    %esi
  801cec:	5d                   	pop    %ebp
  801ced:	c3                   	ret    

00801cee <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801cee:	55                   	push   %ebp
  801cef:	89 e5                	mov    %esp,%ebp
  801cf1:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cf4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cf7:	50                   	push   %eax
  801cf8:	ff 75 08             	pushl  0x8(%ebp)
  801cfb:	e8 30 f5 ff ff       	call   801230 <fd_lookup>
  801d00:	83 c4 10             	add    $0x10,%esp
  801d03:	85 c0                	test   %eax,%eax
  801d05:	78 18                	js     801d1f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d07:	83 ec 0c             	sub    $0xc,%esp
  801d0a:	ff 75 f4             	pushl  -0xc(%ebp)
  801d0d:	e8 b8 f4 ff ff       	call   8011ca <fd2data>
	return _pipeisclosed(fd, p);
  801d12:	89 c2                	mov    %eax,%edx
  801d14:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d17:	e8 21 fd ff ff       	call   801a3d <_pipeisclosed>
  801d1c:	83 c4 10             	add    $0x10,%esp
}
  801d1f:	c9                   	leave  
  801d20:	c3                   	ret    

00801d21 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d21:	55                   	push   %ebp
  801d22:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d24:	b8 00 00 00 00       	mov    $0x0,%eax
  801d29:	5d                   	pop    %ebp
  801d2a:	c3                   	ret    

00801d2b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d2b:	55                   	push   %ebp
  801d2c:	89 e5                	mov    %esp,%ebp
  801d2e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d31:	68 ae 27 80 00       	push   $0x8027ae
  801d36:	ff 75 0c             	pushl  0xc(%ebp)
  801d39:	e8 96 ea ff ff       	call   8007d4 <strcpy>
	return 0;
}
  801d3e:	b8 00 00 00 00       	mov    $0x0,%eax
  801d43:	c9                   	leave  
  801d44:	c3                   	ret    

00801d45 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d45:	55                   	push   %ebp
  801d46:	89 e5                	mov    %esp,%ebp
  801d48:	57                   	push   %edi
  801d49:	56                   	push   %esi
  801d4a:	53                   	push   %ebx
  801d4b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d51:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d56:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d5c:	eb 2d                	jmp    801d8b <devcons_write+0x46>
		m = n - tot;
  801d5e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d61:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d63:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d66:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d6b:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d6e:	83 ec 04             	sub    $0x4,%esp
  801d71:	53                   	push   %ebx
  801d72:	03 45 0c             	add    0xc(%ebp),%eax
  801d75:	50                   	push   %eax
  801d76:	57                   	push   %edi
  801d77:	e8 ea eb ff ff       	call   800966 <memmove>
		sys_cputs(buf, m);
  801d7c:	83 c4 08             	add    $0x8,%esp
  801d7f:	53                   	push   %ebx
  801d80:	57                   	push   %edi
  801d81:	e8 95 ed ff ff       	call   800b1b <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d86:	01 de                	add    %ebx,%esi
  801d88:	83 c4 10             	add    $0x10,%esp
  801d8b:	89 f0                	mov    %esi,%eax
  801d8d:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d90:	72 cc                	jb     801d5e <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d92:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d95:	5b                   	pop    %ebx
  801d96:	5e                   	pop    %esi
  801d97:	5f                   	pop    %edi
  801d98:	5d                   	pop    %ebp
  801d99:	c3                   	ret    

00801d9a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d9a:	55                   	push   %ebp
  801d9b:	89 e5                	mov    %esp,%ebp
  801d9d:	83 ec 08             	sub    $0x8,%esp
  801da0:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801da5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801da9:	74 2a                	je     801dd5 <devcons_read+0x3b>
  801dab:	eb 05                	jmp    801db2 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801dad:	e8 06 ee ff ff       	call   800bb8 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801db2:	e8 82 ed ff ff       	call   800b39 <sys_cgetc>
  801db7:	85 c0                	test   %eax,%eax
  801db9:	74 f2                	je     801dad <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801dbb:	85 c0                	test   %eax,%eax
  801dbd:	78 16                	js     801dd5 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801dbf:	83 f8 04             	cmp    $0x4,%eax
  801dc2:	74 0c                	je     801dd0 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801dc4:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dc7:	88 02                	mov    %al,(%edx)
	return 1;
  801dc9:	b8 01 00 00 00       	mov    $0x1,%eax
  801dce:	eb 05                	jmp    801dd5 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801dd0:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801dd5:	c9                   	leave  
  801dd6:	c3                   	ret    

00801dd7 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801dd7:	55                   	push   %ebp
  801dd8:	89 e5                	mov    %esp,%ebp
  801dda:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ddd:	8b 45 08             	mov    0x8(%ebp),%eax
  801de0:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801de3:	6a 01                	push   $0x1
  801de5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801de8:	50                   	push   %eax
  801de9:	e8 2d ed ff ff       	call   800b1b <sys_cputs>
}
  801dee:	83 c4 10             	add    $0x10,%esp
  801df1:	c9                   	leave  
  801df2:	c3                   	ret    

00801df3 <getchar>:

int
getchar(void)
{
  801df3:	55                   	push   %ebp
  801df4:	89 e5                	mov    %esp,%ebp
  801df6:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801df9:	6a 01                	push   $0x1
  801dfb:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dfe:	50                   	push   %eax
  801dff:	6a 00                	push   $0x0
  801e01:	e8 90 f6 ff ff       	call   801496 <read>
	if (r < 0)
  801e06:	83 c4 10             	add    $0x10,%esp
  801e09:	85 c0                	test   %eax,%eax
  801e0b:	78 0f                	js     801e1c <getchar+0x29>
		return r;
	if (r < 1)
  801e0d:	85 c0                	test   %eax,%eax
  801e0f:	7e 06                	jle    801e17 <getchar+0x24>
		return -E_EOF;
	return c;
  801e11:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e15:	eb 05                	jmp    801e1c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e17:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e1c:	c9                   	leave  
  801e1d:	c3                   	ret    

00801e1e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e1e:	55                   	push   %ebp
  801e1f:	89 e5                	mov    %esp,%ebp
  801e21:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e24:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e27:	50                   	push   %eax
  801e28:	ff 75 08             	pushl  0x8(%ebp)
  801e2b:	e8 00 f4 ff ff       	call   801230 <fd_lookup>
  801e30:	83 c4 10             	add    $0x10,%esp
  801e33:	85 c0                	test   %eax,%eax
  801e35:	78 11                	js     801e48 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e37:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e3a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e40:	39 10                	cmp    %edx,(%eax)
  801e42:	0f 94 c0             	sete   %al
  801e45:	0f b6 c0             	movzbl %al,%eax
}
  801e48:	c9                   	leave  
  801e49:	c3                   	ret    

00801e4a <opencons>:

int
opencons(void)
{
  801e4a:	55                   	push   %ebp
  801e4b:	89 e5                	mov    %esp,%ebp
  801e4d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e50:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e53:	50                   	push   %eax
  801e54:	e8 88 f3 ff ff       	call   8011e1 <fd_alloc>
  801e59:	83 c4 10             	add    $0x10,%esp
		return r;
  801e5c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e5e:	85 c0                	test   %eax,%eax
  801e60:	78 3e                	js     801ea0 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e62:	83 ec 04             	sub    $0x4,%esp
  801e65:	68 07 04 00 00       	push   $0x407
  801e6a:	ff 75 f4             	pushl  -0xc(%ebp)
  801e6d:	6a 00                	push   $0x0
  801e6f:	e8 63 ed ff ff       	call   800bd7 <sys_page_alloc>
  801e74:	83 c4 10             	add    $0x10,%esp
		return r;
  801e77:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e79:	85 c0                	test   %eax,%eax
  801e7b:	78 23                	js     801ea0 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e7d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e83:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e86:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e88:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e8b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e92:	83 ec 0c             	sub    $0xc,%esp
  801e95:	50                   	push   %eax
  801e96:	e8 1f f3 ff ff       	call   8011ba <fd2num>
  801e9b:	89 c2                	mov    %eax,%edx
  801e9d:	83 c4 10             	add    $0x10,%esp
}
  801ea0:	89 d0                	mov    %edx,%eax
  801ea2:	c9                   	leave  
  801ea3:	c3                   	ret    

00801ea4 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801ea4:	55                   	push   %ebp
  801ea5:	89 e5                	mov    %esp,%ebp
  801ea7:	83 ec 08             	sub    $0x8,%esp
	int r;
	int ret;
	if (_pgfault_handler == 0) {
  801eaa:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801eb1:	75 36                	jne    801ee9 <set_pgfault_handler+0x45>
		// First time through!
		// LAB 4: Your code here.
        
        	ret = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  801eb3:	a1 04 40 80 00       	mov    0x804004,%eax
  801eb8:	8b 40 48             	mov    0x48(%eax),%eax
  801ebb:	83 ec 04             	sub    $0x4,%esp
  801ebe:	68 07 0e 00 00       	push   $0xe07
  801ec3:	68 00 f0 bf ee       	push   $0xeebff000
  801ec8:	50                   	push   %eax
  801ec9:	e8 09 ed ff ff       	call   800bd7 <sys_page_alloc>
		if (ret < 0) {
  801ece:	83 c4 10             	add    $0x10,%esp
  801ed1:	85 c0                	test   %eax,%eax
  801ed3:	79 14                	jns    801ee9 <set_pgfault_handler+0x45>
		    panic("Allocate user exception stack failed!\n");
  801ed5:	83 ec 04             	sub    $0x4,%esp
  801ed8:	68 bc 27 80 00       	push   $0x8027bc
  801edd:	6a 23                	push   $0x23
  801edf:	68 e4 27 80 00       	push   $0x8027e4
  801ee4:	e8 6f e2 ff ff       	call   800158 <_panic>
		}
	}
	sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  801ee9:	a1 04 40 80 00       	mov    0x804004,%eax
  801eee:	8b 40 48             	mov    0x48(%eax),%eax
  801ef1:	83 ec 08             	sub    $0x8,%esp
  801ef4:	68 0c 1f 80 00       	push   $0x801f0c
  801ef9:	50                   	push   %eax
  801efa:	e8 23 ee ff ff       	call   800d22 <sys_env_set_pgfault_upcall>
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801eff:	8b 45 08             	mov    0x8(%ebp),%eax
  801f02:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801f07:	83 c4 10             	add    $0x10,%esp
  801f0a:	c9                   	leave  
  801f0b:	c3                   	ret    

00801f0c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f0c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f0d:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f12:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f14:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 0x28(%esp), %ebx  # trap-time eip
  801f17:	8b 5c 24 28          	mov    0x28(%esp),%ebx
        subl $0x4, 0x30(%esp)  # trap-time esp minus 4
  801f1b:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax 
  801f20:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl %ebx, (%eax)      # trap-time esp store trap-time eip
  801f24:	89 18                	mov    %ebx,(%eax)
        addl $0x8, %esp
  801f26:	83 c4 08             	add    $0x8,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  801f29:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  801f2a:	83 c4 04             	add    $0x4,%esp
        popfl
  801f2d:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  801f2e:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  801f2f:	c3                   	ret    

00801f30 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f30:	55                   	push   %ebp
  801f31:	89 e5                	mov    %esp,%ebp
  801f33:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f36:	89 d0                	mov    %edx,%eax
  801f38:	c1 e8 16             	shr    $0x16,%eax
  801f3b:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f42:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f47:	f6 c1 01             	test   $0x1,%cl
  801f4a:	74 1d                	je     801f69 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f4c:	c1 ea 0c             	shr    $0xc,%edx
  801f4f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f56:	f6 c2 01             	test   $0x1,%dl
  801f59:	74 0e                	je     801f69 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f5b:	c1 ea 0c             	shr    $0xc,%edx
  801f5e:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f65:	ef 
  801f66:	0f b7 c0             	movzwl %ax,%eax
}
  801f69:	5d                   	pop    %ebp
  801f6a:	c3                   	ret    
  801f6b:	66 90                	xchg   %ax,%ax
  801f6d:	66 90                	xchg   %ax,%ax
  801f6f:	90                   	nop

00801f70 <__udivdi3>:
  801f70:	55                   	push   %ebp
  801f71:	57                   	push   %edi
  801f72:	56                   	push   %esi
  801f73:	53                   	push   %ebx
  801f74:	83 ec 1c             	sub    $0x1c,%esp
  801f77:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f7b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f7f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801f83:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f87:	85 f6                	test   %esi,%esi
  801f89:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f8d:	89 ca                	mov    %ecx,%edx
  801f8f:	89 f8                	mov    %edi,%eax
  801f91:	75 3d                	jne    801fd0 <__udivdi3+0x60>
  801f93:	39 cf                	cmp    %ecx,%edi
  801f95:	0f 87 c5 00 00 00    	ja     802060 <__udivdi3+0xf0>
  801f9b:	85 ff                	test   %edi,%edi
  801f9d:	89 fd                	mov    %edi,%ebp
  801f9f:	75 0b                	jne    801fac <__udivdi3+0x3c>
  801fa1:	b8 01 00 00 00       	mov    $0x1,%eax
  801fa6:	31 d2                	xor    %edx,%edx
  801fa8:	f7 f7                	div    %edi
  801faa:	89 c5                	mov    %eax,%ebp
  801fac:	89 c8                	mov    %ecx,%eax
  801fae:	31 d2                	xor    %edx,%edx
  801fb0:	f7 f5                	div    %ebp
  801fb2:	89 c1                	mov    %eax,%ecx
  801fb4:	89 d8                	mov    %ebx,%eax
  801fb6:	89 cf                	mov    %ecx,%edi
  801fb8:	f7 f5                	div    %ebp
  801fba:	89 c3                	mov    %eax,%ebx
  801fbc:	89 d8                	mov    %ebx,%eax
  801fbe:	89 fa                	mov    %edi,%edx
  801fc0:	83 c4 1c             	add    $0x1c,%esp
  801fc3:	5b                   	pop    %ebx
  801fc4:	5e                   	pop    %esi
  801fc5:	5f                   	pop    %edi
  801fc6:	5d                   	pop    %ebp
  801fc7:	c3                   	ret    
  801fc8:	90                   	nop
  801fc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fd0:	39 ce                	cmp    %ecx,%esi
  801fd2:	77 74                	ja     802048 <__udivdi3+0xd8>
  801fd4:	0f bd fe             	bsr    %esi,%edi
  801fd7:	83 f7 1f             	xor    $0x1f,%edi
  801fda:	0f 84 98 00 00 00    	je     802078 <__udivdi3+0x108>
  801fe0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801fe5:	89 f9                	mov    %edi,%ecx
  801fe7:	89 c5                	mov    %eax,%ebp
  801fe9:	29 fb                	sub    %edi,%ebx
  801feb:	d3 e6                	shl    %cl,%esi
  801fed:	89 d9                	mov    %ebx,%ecx
  801fef:	d3 ed                	shr    %cl,%ebp
  801ff1:	89 f9                	mov    %edi,%ecx
  801ff3:	d3 e0                	shl    %cl,%eax
  801ff5:	09 ee                	or     %ebp,%esi
  801ff7:	89 d9                	mov    %ebx,%ecx
  801ff9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ffd:	89 d5                	mov    %edx,%ebp
  801fff:	8b 44 24 08          	mov    0x8(%esp),%eax
  802003:	d3 ed                	shr    %cl,%ebp
  802005:	89 f9                	mov    %edi,%ecx
  802007:	d3 e2                	shl    %cl,%edx
  802009:	89 d9                	mov    %ebx,%ecx
  80200b:	d3 e8                	shr    %cl,%eax
  80200d:	09 c2                	or     %eax,%edx
  80200f:	89 d0                	mov    %edx,%eax
  802011:	89 ea                	mov    %ebp,%edx
  802013:	f7 f6                	div    %esi
  802015:	89 d5                	mov    %edx,%ebp
  802017:	89 c3                	mov    %eax,%ebx
  802019:	f7 64 24 0c          	mull   0xc(%esp)
  80201d:	39 d5                	cmp    %edx,%ebp
  80201f:	72 10                	jb     802031 <__udivdi3+0xc1>
  802021:	8b 74 24 08          	mov    0x8(%esp),%esi
  802025:	89 f9                	mov    %edi,%ecx
  802027:	d3 e6                	shl    %cl,%esi
  802029:	39 c6                	cmp    %eax,%esi
  80202b:	73 07                	jae    802034 <__udivdi3+0xc4>
  80202d:	39 d5                	cmp    %edx,%ebp
  80202f:	75 03                	jne    802034 <__udivdi3+0xc4>
  802031:	83 eb 01             	sub    $0x1,%ebx
  802034:	31 ff                	xor    %edi,%edi
  802036:	89 d8                	mov    %ebx,%eax
  802038:	89 fa                	mov    %edi,%edx
  80203a:	83 c4 1c             	add    $0x1c,%esp
  80203d:	5b                   	pop    %ebx
  80203e:	5e                   	pop    %esi
  80203f:	5f                   	pop    %edi
  802040:	5d                   	pop    %ebp
  802041:	c3                   	ret    
  802042:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802048:	31 ff                	xor    %edi,%edi
  80204a:	31 db                	xor    %ebx,%ebx
  80204c:	89 d8                	mov    %ebx,%eax
  80204e:	89 fa                	mov    %edi,%edx
  802050:	83 c4 1c             	add    $0x1c,%esp
  802053:	5b                   	pop    %ebx
  802054:	5e                   	pop    %esi
  802055:	5f                   	pop    %edi
  802056:	5d                   	pop    %ebp
  802057:	c3                   	ret    
  802058:	90                   	nop
  802059:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802060:	89 d8                	mov    %ebx,%eax
  802062:	f7 f7                	div    %edi
  802064:	31 ff                	xor    %edi,%edi
  802066:	89 c3                	mov    %eax,%ebx
  802068:	89 d8                	mov    %ebx,%eax
  80206a:	89 fa                	mov    %edi,%edx
  80206c:	83 c4 1c             	add    $0x1c,%esp
  80206f:	5b                   	pop    %ebx
  802070:	5e                   	pop    %esi
  802071:	5f                   	pop    %edi
  802072:	5d                   	pop    %ebp
  802073:	c3                   	ret    
  802074:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802078:	39 ce                	cmp    %ecx,%esi
  80207a:	72 0c                	jb     802088 <__udivdi3+0x118>
  80207c:	31 db                	xor    %ebx,%ebx
  80207e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802082:	0f 87 34 ff ff ff    	ja     801fbc <__udivdi3+0x4c>
  802088:	bb 01 00 00 00       	mov    $0x1,%ebx
  80208d:	e9 2a ff ff ff       	jmp    801fbc <__udivdi3+0x4c>
  802092:	66 90                	xchg   %ax,%ax
  802094:	66 90                	xchg   %ax,%ax
  802096:	66 90                	xchg   %ax,%ax
  802098:	66 90                	xchg   %ax,%ax
  80209a:	66 90                	xchg   %ax,%ax
  80209c:	66 90                	xchg   %ax,%ax
  80209e:	66 90                	xchg   %ax,%ax

008020a0 <__umoddi3>:
  8020a0:	55                   	push   %ebp
  8020a1:	57                   	push   %edi
  8020a2:	56                   	push   %esi
  8020a3:	53                   	push   %ebx
  8020a4:	83 ec 1c             	sub    $0x1c,%esp
  8020a7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020ab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8020af:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020b7:	85 d2                	test   %edx,%edx
  8020b9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8020bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020c1:	89 f3                	mov    %esi,%ebx
  8020c3:	89 3c 24             	mov    %edi,(%esp)
  8020c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020ca:	75 1c                	jne    8020e8 <__umoddi3+0x48>
  8020cc:	39 f7                	cmp    %esi,%edi
  8020ce:	76 50                	jbe    802120 <__umoddi3+0x80>
  8020d0:	89 c8                	mov    %ecx,%eax
  8020d2:	89 f2                	mov    %esi,%edx
  8020d4:	f7 f7                	div    %edi
  8020d6:	89 d0                	mov    %edx,%eax
  8020d8:	31 d2                	xor    %edx,%edx
  8020da:	83 c4 1c             	add    $0x1c,%esp
  8020dd:	5b                   	pop    %ebx
  8020de:	5e                   	pop    %esi
  8020df:	5f                   	pop    %edi
  8020e0:	5d                   	pop    %ebp
  8020e1:	c3                   	ret    
  8020e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020e8:	39 f2                	cmp    %esi,%edx
  8020ea:	89 d0                	mov    %edx,%eax
  8020ec:	77 52                	ja     802140 <__umoddi3+0xa0>
  8020ee:	0f bd ea             	bsr    %edx,%ebp
  8020f1:	83 f5 1f             	xor    $0x1f,%ebp
  8020f4:	75 5a                	jne    802150 <__umoddi3+0xb0>
  8020f6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8020fa:	0f 82 e0 00 00 00    	jb     8021e0 <__umoddi3+0x140>
  802100:	39 0c 24             	cmp    %ecx,(%esp)
  802103:	0f 86 d7 00 00 00    	jbe    8021e0 <__umoddi3+0x140>
  802109:	8b 44 24 08          	mov    0x8(%esp),%eax
  80210d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802111:	83 c4 1c             	add    $0x1c,%esp
  802114:	5b                   	pop    %ebx
  802115:	5e                   	pop    %esi
  802116:	5f                   	pop    %edi
  802117:	5d                   	pop    %ebp
  802118:	c3                   	ret    
  802119:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802120:	85 ff                	test   %edi,%edi
  802122:	89 fd                	mov    %edi,%ebp
  802124:	75 0b                	jne    802131 <__umoddi3+0x91>
  802126:	b8 01 00 00 00       	mov    $0x1,%eax
  80212b:	31 d2                	xor    %edx,%edx
  80212d:	f7 f7                	div    %edi
  80212f:	89 c5                	mov    %eax,%ebp
  802131:	89 f0                	mov    %esi,%eax
  802133:	31 d2                	xor    %edx,%edx
  802135:	f7 f5                	div    %ebp
  802137:	89 c8                	mov    %ecx,%eax
  802139:	f7 f5                	div    %ebp
  80213b:	89 d0                	mov    %edx,%eax
  80213d:	eb 99                	jmp    8020d8 <__umoddi3+0x38>
  80213f:	90                   	nop
  802140:	89 c8                	mov    %ecx,%eax
  802142:	89 f2                	mov    %esi,%edx
  802144:	83 c4 1c             	add    $0x1c,%esp
  802147:	5b                   	pop    %ebx
  802148:	5e                   	pop    %esi
  802149:	5f                   	pop    %edi
  80214a:	5d                   	pop    %ebp
  80214b:	c3                   	ret    
  80214c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802150:	8b 34 24             	mov    (%esp),%esi
  802153:	bf 20 00 00 00       	mov    $0x20,%edi
  802158:	89 e9                	mov    %ebp,%ecx
  80215a:	29 ef                	sub    %ebp,%edi
  80215c:	d3 e0                	shl    %cl,%eax
  80215e:	89 f9                	mov    %edi,%ecx
  802160:	89 f2                	mov    %esi,%edx
  802162:	d3 ea                	shr    %cl,%edx
  802164:	89 e9                	mov    %ebp,%ecx
  802166:	09 c2                	or     %eax,%edx
  802168:	89 d8                	mov    %ebx,%eax
  80216a:	89 14 24             	mov    %edx,(%esp)
  80216d:	89 f2                	mov    %esi,%edx
  80216f:	d3 e2                	shl    %cl,%edx
  802171:	89 f9                	mov    %edi,%ecx
  802173:	89 54 24 04          	mov    %edx,0x4(%esp)
  802177:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80217b:	d3 e8                	shr    %cl,%eax
  80217d:	89 e9                	mov    %ebp,%ecx
  80217f:	89 c6                	mov    %eax,%esi
  802181:	d3 e3                	shl    %cl,%ebx
  802183:	89 f9                	mov    %edi,%ecx
  802185:	89 d0                	mov    %edx,%eax
  802187:	d3 e8                	shr    %cl,%eax
  802189:	89 e9                	mov    %ebp,%ecx
  80218b:	09 d8                	or     %ebx,%eax
  80218d:	89 d3                	mov    %edx,%ebx
  80218f:	89 f2                	mov    %esi,%edx
  802191:	f7 34 24             	divl   (%esp)
  802194:	89 d6                	mov    %edx,%esi
  802196:	d3 e3                	shl    %cl,%ebx
  802198:	f7 64 24 04          	mull   0x4(%esp)
  80219c:	39 d6                	cmp    %edx,%esi
  80219e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021a2:	89 d1                	mov    %edx,%ecx
  8021a4:	89 c3                	mov    %eax,%ebx
  8021a6:	72 08                	jb     8021b0 <__umoddi3+0x110>
  8021a8:	75 11                	jne    8021bb <__umoddi3+0x11b>
  8021aa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8021ae:	73 0b                	jae    8021bb <__umoddi3+0x11b>
  8021b0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8021b4:	1b 14 24             	sbb    (%esp),%edx
  8021b7:	89 d1                	mov    %edx,%ecx
  8021b9:	89 c3                	mov    %eax,%ebx
  8021bb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8021bf:	29 da                	sub    %ebx,%edx
  8021c1:	19 ce                	sbb    %ecx,%esi
  8021c3:	89 f9                	mov    %edi,%ecx
  8021c5:	89 f0                	mov    %esi,%eax
  8021c7:	d3 e0                	shl    %cl,%eax
  8021c9:	89 e9                	mov    %ebp,%ecx
  8021cb:	d3 ea                	shr    %cl,%edx
  8021cd:	89 e9                	mov    %ebp,%ecx
  8021cf:	d3 ee                	shr    %cl,%esi
  8021d1:	09 d0                	or     %edx,%eax
  8021d3:	89 f2                	mov    %esi,%edx
  8021d5:	83 c4 1c             	add    $0x1c,%esp
  8021d8:	5b                   	pop    %ebx
  8021d9:	5e                   	pop    %esi
  8021da:	5f                   	pop    %edi
  8021db:	5d                   	pop    %ebp
  8021dc:	c3                   	ret    
  8021dd:	8d 76 00             	lea    0x0(%esi),%esi
  8021e0:	29 f9                	sub    %edi,%ecx
  8021e2:	19 d6                	sbb    %edx,%esi
  8021e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021ec:	e9 18 ff ff ff       	jmp    802109 <__umoddi3+0x69>
