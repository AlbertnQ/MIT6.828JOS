
obj/user/stresssched.debug:     file format elf32-i386


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
  80002c:	e8 bc 00 00 00       	call   8000ed <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

volatile int counter;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  800038:	e8 51 0b 00 00       	call   800b8e <sys_getenvid>
  80003d:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  80003f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800044:	e8 48 0f 00 00       	call   800f91 <fork>
  800049:	85 c0                	test   %eax,%eax
  80004b:	74 0a                	je     800057 <umain+0x24>
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();

	// Fork several environments
	for (i = 0; i < 20; i++)
  80004d:	83 c3 01             	add    $0x1,%ebx
  800050:	83 fb 14             	cmp    $0x14,%ebx
  800053:	75 ef                	jne    800044 <umain+0x11>
  800055:	eb 05                	jmp    80005c <umain+0x29>
		if (fork() == 0)
			break;
	if (i == 20) {
  800057:	83 fb 14             	cmp    $0x14,%ebx
  80005a:	75 0e                	jne    80006a <umain+0x37>
		sys_yield();
  80005c:	e8 4c 0b 00 00       	call   800bad <sys_yield>
		return;
  800061:	e9 80 00 00 00       	jmp    8000e6 <umain+0xb3>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");
  800066:	f3 90                	pause  
  800068:	eb 0f                	jmp    800079 <umain+0x46>
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80006a:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  800070:	6b d6 7c             	imul   $0x7c,%esi,%edx
  800073:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800079:	8b 42 54             	mov    0x54(%edx),%eax
  80007c:	85 c0                	test   %eax,%eax
  80007e:	75 e6                	jne    800066 <umain+0x33>
  800080:	bb 0a 00 00 00       	mov    $0xa,%ebx
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  800085:	e8 23 0b 00 00       	call   800bad <sys_yield>
  80008a:	ba 10 27 00 00       	mov    $0x2710,%edx
		for (j = 0; j < 10000; j++)
			counter++;
  80008f:	a1 04 40 80 00       	mov    0x804004,%eax
  800094:	83 c0 01             	add    $0x1,%eax
  800097:	a3 04 40 80 00       	mov    %eax,0x804004
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
		for (j = 0; j < 10000; j++)
  80009c:	83 ea 01             	sub    $0x1,%edx
  80009f:	75 ee                	jne    80008f <umain+0x5c>
	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
  8000a1:	83 eb 01             	sub    $0x1,%ebx
  8000a4:	75 df                	jne    800085 <umain+0x52>
		sys_yield();
		for (j = 0; j < 10000; j++)
			counter++;
	}

	if (counter != 10*10000)
  8000a6:	a1 04 40 80 00       	mov    0x804004,%eax
  8000ab:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000b0:	74 17                	je     8000c9 <umain+0x96>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000b2:	a1 04 40 80 00       	mov    0x804004,%eax
  8000b7:	50                   	push   %eax
  8000b8:	68 00 22 80 00       	push   $0x802200
  8000bd:	6a 21                	push   $0x21
  8000bf:	68 28 22 80 00       	push   $0x802228
  8000c4:	e8 84 00 00 00       	call   80014d <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000c9:	a1 08 40 80 00       	mov    0x804008,%eax
  8000ce:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000d1:	8b 40 48             	mov    0x48(%eax),%eax
  8000d4:	83 ec 04             	sub    $0x4,%esp
  8000d7:	52                   	push   %edx
  8000d8:	50                   	push   %eax
  8000d9:	68 3b 22 80 00       	push   $0x80223b
  8000de:	e8 43 01 00 00       	call   800226 <cprintf>
  8000e3:	83 c4 10             	add    $0x10,%esp

}
  8000e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e9:	5b                   	pop    %ebx
  8000ea:	5e                   	pop    %esi
  8000eb:	5d                   	pop    %ebp
  8000ec:	c3                   	ret    

008000ed <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000ed:	55                   	push   %ebp
  8000ee:	89 e5                	mov    %esp,%ebp
  8000f0:	56                   	push   %esi
  8000f1:	53                   	push   %ebx
  8000f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000f5:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  8000f8:	e8 91 0a 00 00       	call   800b8e <sys_getenvid>
  8000fd:	25 ff 03 00 00       	and    $0x3ff,%eax
  800102:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800105:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80010a:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80010f:	85 db                	test   %ebx,%ebx
  800111:	7e 07                	jle    80011a <libmain+0x2d>
		binaryname = argv[0];
  800113:	8b 06                	mov    (%esi),%eax
  800115:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80011a:	83 ec 08             	sub    $0x8,%esp
  80011d:	56                   	push   %esi
  80011e:	53                   	push   %ebx
  80011f:	e8 0f ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800124:	e8 0a 00 00 00       	call   800133 <exit>
}
  800129:	83 c4 10             	add    $0x10,%esp
  80012c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80012f:	5b                   	pop    %ebx
  800130:	5e                   	pop    %esi
  800131:	5d                   	pop    %ebp
  800132:	c3                   	ret    

00800133 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800139:	e8 5a 11 00 00       	call   801298 <close_all>
	sys_env_destroy(0);
  80013e:	83 ec 0c             	sub    $0xc,%esp
  800141:	6a 00                	push   $0x0
  800143:	e8 05 0a 00 00       	call   800b4d <sys_env_destroy>
}
  800148:	83 c4 10             	add    $0x10,%esp
  80014b:	c9                   	leave  
  80014c:	c3                   	ret    

0080014d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80014d:	55                   	push   %ebp
  80014e:	89 e5                	mov    %esp,%ebp
  800150:	56                   	push   %esi
  800151:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800152:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800155:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80015b:	e8 2e 0a 00 00       	call   800b8e <sys_getenvid>
  800160:	83 ec 0c             	sub    $0xc,%esp
  800163:	ff 75 0c             	pushl  0xc(%ebp)
  800166:	ff 75 08             	pushl  0x8(%ebp)
  800169:	56                   	push   %esi
  80016a:	50                   	push   %eax
  80016b:	68 64 22 80 00       	push   $0x802264
  800170:	e8 b1 00 00 00       	call   800226 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800175:	83 c4 18             	add    $0x18,%esp
  800178:	53                   	push   %ebx
  800179:	ff 75 10             	pushl  0x10(%ebp)
  80017c:	e8 54 00 00 00       	call   8001d5 <vcprintf>
	cprintf("\n");
  800181:	c7 04 24 57 22 80 00 	movl   $0x802257,(%esp)
  800188:	e8 99 00 00 00       	call   800226 <cprintf>
  80018d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800190:	cc                   	int3   
  800191:	eb fd                	jmp    800190 <_panic+0x43>

00800193 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800193:	55                   	push   %ebp
  800194:	89 e5                	mov    %esp,%ebp
  800196:	53                   	push   %ebx
  800197:	83 ec 04             	sub    $0x4,%esp
  80019a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80019d:	8b 13                	mov    (%ebx),%edx
  80019f:	8d 42 01             	lea    0x1(%edx),%eax
  8001a2:	89 03                	mov    %eax,(%ebx)
  8001a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001a7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001ab:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001b0:	75 1a                	jne    8001cc <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001b2:	83 ec 08             	sub    $0x8,%esp
  8001b5:	68 ff 00 00 00       	push   $0xff
  8001ba:	8d 43 08             	lea    0x8(%ebx),%eax
  8001bd:	50                   	push   %eax
  8001be:	e8 4d 09 00 00       	call   800b10 <sys_cputs>
		b->idx = 0;
  8001c3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001c9:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001cc:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001d3:	c9                   	leave  
  8001d4:	c3                   	ret    

008001d5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d5:	55                   	push   %ebp
  8001d6:	89 e5                	mov    %esp,%ebp
  8001d8:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001de:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e5:	00 00 00 
	b.cnt = 0;
  8001e8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ef:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001f2:	ff 75 0c             	pushl  0xc(%ebp)
  8001f5:	ff 75 08             	pushl  0x8(%ebp)
  8001f8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001fe:	50                   	push   %eax
  8001ff:	68 93 01 80 00       	push   $0x800193
  800204:	e8 54 01 00 00       	call   80035d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800209:	83 c4 08             	add    $0x8,%esp
  80020c:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800212:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800218:	50                   	push   %eax
  800219:	e8 f2 08 00 00       	call   800b10 <sys_cputs>

	return b.cnt;
}
  80021e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800224:	c9                   	leave  
  800225:	c3                   	ret    

00800226 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800226:	55                   	push   %ebp
  800227:	89 e5                	mov    %esp,%ebp
  800229:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80022c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80022f:	50                   	push   %eax
  800230:	ff 75 08             	pushl  0x8(%ebp)
  800233:	e8 9d ff ff ff       	call   8001d5 <vcprintf>
	va_end(ap);

	return cnt;
}
  800238:	c9                   	leave  
  800239:	c3                   	ret    

0080023a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80023a:	55                   	push   %ebp
  80023b:	89 e5                	mov    %esp,%ebp
  80023d:	57                   	push   %edi
  80023e:	56                   	push   %esi
  80023f:	53                   	push   %ebx
  800240:	83 ec 1c             	sub    $0x1c,%esp
  800243:	89 c7                	mov    %eax,%edi
  800245:	89 d6                	mov    %edx,%esi
  800247:	8b 45 08             	mov    0x8(%ebp),%eax
  80024a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80024d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800250:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800253:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800256:	bb 00 00 00 00       	mov    $0x0,%ebx
  80025b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80025e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800261:	39 d3                	cmp    %edx,%ebx
  800263:	72 05                	jb     80026a <printnum+0x30>
  800265:	39 45 10             	cmp    %eax,0x10(%ebp)
  800268:	77 45                	ja     8002af <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80026a:	83 ec 0c             	sub    $0xc,%esp
  80026d:	ff 75 18             	pushl  0x18(%ebp)
  800270:	8b 45 14             	mov    0x14(%ebp),%eax
  800273:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800276:	53                   	push   %ebx
  800277:	ff 75 10             	pushl  0x10(%ebp)
  80027a:	83 ec 08             	sub    $0x8,%esp
  80027d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800280:	ff 75 e0             	pushl  -0x20(%ebp)
  800283:	ff 75 dc             	pushl  -0x24(%ebp)
  800286:	ff 75 d8             	pushl  -0x28(%ebp)
  800289:	e8 d2 1c 00 00       	call   801f60 <__udivdi3>
  80028e:	83 c4 18             	add    $0x18,%esp
  800291:	52                   	push   %edx
  800292:	50                   	push   %eax
  800293:	89 f2                	mov    %esi,%edx
  800295:	89 f8                	mov    %edi,%eax
  800297:	e8 9e ff ff ff       	call   80023a <printnum>
  80029c:	83 c4 20             	add    $0x20,%esp
  80029f:	eb 18                	jmp    8002b9 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002a1:	83 ec 08             	sub    $0x8,%esp
  8002a4:	56                   	push   %esi
  8002a5:	ff 75 18             	pushl  0x18(%ebp)
  8002a8:	ff d7                	call   *%edi
  8002aa:	83 c4 10             	add    $0x10,%esp
  8002ad:	eb 03                	jmp    8002b2 <printnum+0x78>
  8002af:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002b2:	83 eb 01             	sub    $0x1,%ebx
  8002b5:	85 db                	test   %ebx,%ebx
  8002b7:	7f e8                	jg     8002a1 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002b9:	83 ec 08             	sub    $0x8,%esp
  8002bc:	56                   	push   %esi
  8002bd:	83 ec 04             	sub    $0x4,%esp
  8002c0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c3:	ff 75 e0             	pushl  -0x20(%ebp)
  8002c6:	ff 75 dc             	pushl  -0x24(%ebp)
  8002c9:	ff 75 d8             	pushl  -0x28(%ebp)
  8002cc:	e8 bf 1d 00 00       	call   802090 <__umoddi3>
  8002d1:	83 c4 14             	add    $0x14,%esp
  8002d4:	0f be 80 87 22 80 00 	movsbl 0x802287(%eax),%eax
  8002db:	50                   	push   %eax
  8002dc:	ff d7                	call   *%edi
}
  8002de:	83 c4 10             	add    $0x10,%esp
  8002e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e4:	5b                   	pop    %ebx
  8002e5:	5e                   	pop    %esi
  8002e6:	5f                   	pop    %edi
  8002e7:	5d                   	pop    %ebp
  8002e8:	c3                   	ret    

008002e9 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002e9:	55                   	push   %ebp
  8002ea:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002ec:	83 fa 01             	cmp    $0x1,%edx
  8002ef:	7e 0e                	jle    8002ff <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002f1:	8b 10                	mov    (%eax),%edx
  8002f3:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002f6:	89 08                	mov    %ecx,(%eax)
  8002f8:	8b 02                	mov    (%edx),%eax
  8002fa:	8b 52 04             	mov    0x4(%edx),%edx
  8002fd:	eb 22                	jmp    800321 <getuint+0x38>
	else if (lflag)
  8002ff:	85 d2                	test   %edx,%edx
  800301:	74 10                	je     800313 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800303:	8b 10                	mov    (%eax),%edx
  800305:	8d 4a 04             	lea    0x4(%edx),%ecx
  800308:	89 08                	mov    %ecx,(%eax)
  80030a:	8b 02                	mov    (%edx),%eax
  80030c:	ba 00 00 00 00       	mov    $0x0,%edx
  800311:	eb 0e                	jmp    800321 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800313:	8b 10                	mov    (%eax),%edx
  800315:	8d 4a 04             	lea    0x4(%edx),%ecx
  800318:	89 08                	mov    %ecx,(%eax)
  80031a:	8b 02                	mov    (%edx),%eax
  80031c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800321:	5d                   	pop    %ebp
  800322:	c3                   	ret    

00800323 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800323:	55                   	push   %ebp
  800324:	89 e5                	mov    %esp,%ebp
  800326:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800329:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80032d:	8b 10                	mov    (%eax),%edx
  80032f:	3b 50 04             	cmp    0x4(%eax),%edx
  800332:	73 0a                	jae    80033e <sprintputch+0x1b>
		*b->buf++ = ch;
  800334:	8d 4a 01             	lea    0x1(%edx),%ecx
  800337:	89 08                	mov    %ecx,(%eax)
  800339:	8b 45 08             	mov    0x8(%ebp),%eax
  80033c:	88 02                	mov    %al,(%edx)
}
  80033e:	5d                   	pop    %ebp
  80033f:	c3                   	ret    

00800340 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800340:	55                   	push   %ebp
  800341:	89 e5                	mov    %esp,%ebp
  800343:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800346:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800349:	50                   	push   %eax
  80034a:	ff 75 10             	pushl  0x10(%ebp)
  80034d:	ff 75 0c             	pushl  0xc(%ebp)
  800350:	ff 75 08             	pushl  0x8(%ebp)
  800353:	e8 05 00 00 00       	call   80035d <vprintfmt>
	va_end(ap);
}
  800358:	83 c4 10             	add    $0x10,%esp
  80035b:	c9                   	leave  
  80035c:	c3                   	ret    

0080035d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80035d:	55                   	push   %ebp
  80035e:	89 e5                	mov    %esp,%ebp
  800360:	57                   	push   %edi
  800361:	56                   	push   %esi
  800362:	53                   	push   %ebx
  800363:	83 ec 2c             	sub    $0x2c,%esp
  800366:	8b 75 08             	mov    0x8(%ebp),%esi
  800369:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80036c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80036f:	eb 12                	jmp    800383 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800371:	85 c0                	test   %eax,%eax
  800373:	0f 84 a7 03 00 00    	je     800720 <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
  800379:	83 ec 08             	sub    $0x8,%esp
  80037c:	53                   	push   %ebx
  80037d:	50                   	push   %eax
  80037e:	ff d6                	call   *%esi
  800380:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800383:	83 c7 01             	add    $0x1,%edi
  800386:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80038a:	83 f8 25             	cmp    $0x25,%eax
  80038d:	75 e2                	jne    800371 <vprintfmt+0x14>
  80038f:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800393:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80039a:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8003a1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003a8:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8003af:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003b4:	eb 07                	jmp    8003bd <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003b9:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bd:	8d 47 01             	lea    0x1(%edi),%eax
  8003c0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003c3:	0f b6 07             	movzbl (%edi),%eax
  8003c6:	0f b6 d0             	movzbl %al,%edx
  8003c9:	83 e8 23             	sub    $0x23,%eax
  8003cc:	3c 55                	cmp    $0x55,%al
  8003ce:	0f 87 31 03 00 00    	ja     800705 <vprintfmt+0x3a8>
  8003d4:	0f b6 c0             	movzbl %al,%eax
  8003d7:	ff 24 85 c0 23 80 00 	jmp    *0x8023c0(,%eax,4)
  8003de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003e1:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003e5:	eb d6                	jmp    8003bd <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ef:	89 75 08             	mov    %esi,0x8(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003f2:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003f5:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003f9:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003fc:	8d 72 d0             	lea    -0x30(%edx),%esi
  8003ff:	83 fe 09             	cmp    $0x9,%esi
  800402:	77 34                	ja     800438 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800404:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800407:	eb e9                	jmp    8003f2 <vprintfmt+0x95>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800409:	8b 45 14             	mov    0x14(%ebp),%eax
  80040c:	8d 50 04             	lea    0x4(%eax),%edx
  80040f:	89 55 14             	mov    %edx,0x14(%ebp)
  800412:	8b 00                	mov    (%eax),%eax
  800414:	89 45 cc             	mov    %eax,-0x34(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800417:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80041a:	eb 22                	jmp    80043e <vprintfmt+0xe1>
  80041c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80041f:	85 c0                	test   %eax,%eax
  800421:	0f 48 c1             	cmovs  %ecx,%eax
  800424:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800427:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80042a:	eb 91                	jmp    8003bd <vprintfmt+0x60>
  80042c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80042f:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800436:	eb 85                	jmp    8003bd <vprintfmt+0x60>
  800438:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80043b:	8b 75 08             	mov    0x8(%ebp),%esi

		process_precision:
			if (width < 0)
  80043e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800442:	0f 89 75 ff ff ff    	jns    8003bd <vprintfmt+0x60>
				width = precision, precision = -1;
  800448:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80044b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80044e:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800455:	e9 63 ff ff ff       	jmp    8003bd <vprintfmt+0x60>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80045a:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800461:	e9 57 ff ff ff       	jmp    8003bd <vprintfmt+0x60>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800466:	8b 45 14             	mov    0x14(%ebp),%eax
  800469:	8d 50 04             	lea    0x4(%eax),%edx
  80046c:	89 55 14             	mov    %edx,0x14(%ebp)
  80046f:	83 ec 08             	sub    $0x8,%esp
  800472:	53                   	push   %ebx
  800473:	ff 30                	pushl  (%eax)
  800475:	ff d6                	call   *%esi
			break;
  800477:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80047d:	e9 01 ff ff ff       	jmp    800383 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800482:	8b 45 14             	mov    0x14(%ebp),%eax
  800485:	8d 50 04             	lea    0x4(%eax),%edx
  800488:	89 55 14             	mov    %edx,0x14(%ebp)
  80048b:	8b 00                	mov    (%eax),%eax
  80048d:	99                   	cltd   
  80048e:	31 d0                	xor    %edx,%eax
  800490:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800492:	83 f8 0f             	cmp    $0xf,%eax
  800495:	7f 0b                	jg     8004a2 <vprintfmt+0x145>
  800497:	8b 14 85 20 25 80 00 	mov    0x802520(,%eax,4),%edx
  80049e:	85 d2                	test   %edx,%edx
  8004a0:	75 18                	jne    8004ba <vprintfmt+0x15d>
				printfmt(putch, putdat, "error %d", err);
  8004a2:	50                   	push   %eax
  8004a3:	68 9f 22 80 00       	push   $0x80229f
  8004a8:	53                   	push   %ebx
  8004a9:	56                   	push   %esi
  8004aa:	e8 91 fe ff ff       	call   800340 <printfmt>
  8004af:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004b5:	e9 c9 fe ff ff       	jmp    800383 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004ba:	52                   	push   %edx
  8004bb:	68 79 27 80 00       	push   $0x802779
  8004c0:	53                   	push   %ebx
  8004c1:	56                   	push   %esi
  8004c2:	e8 79 fe ff ff       	call   800340 <printfmt>
  8004c7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004cd:	e9 b1 fe ff ff       	jmp    800383 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d5:	8d 50 04             	lea    0x4(%eax),%edx
  8004d8:	89 55 14             	mov    %edx,0x14(%ebp)
  8004db:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004dd:	85 ff                	test   %edi,%edi
  8004df:	b8 98 22 80 00       	mov    $0x802298,%eax
  8004e4:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004e7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004eb:	0f 8e 94 00 00 00    	jle    800585 <vprintfmt+0x228>
  8004f1:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004f5:	0f 84 98 00 00 00    	je     800593 <vprintfmt+0x236>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004fb:	83 ec 08             	sub    $0x8,%esp
  8004fe:	ff 75 cc             	pushl  -0x34(%ebp)
  800501:	57                   	push   %edi
  800502:	e8 a1 02 00 00       	call   8007a8 <strnlen>
  800507:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80050a:	29 c1                	sub    %eax,%ecx
  80050c:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80050f:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800512:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800516:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800519:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80051c:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80051e:	eb 0f                	jmp    80052f <vprintfmt+0x1d2>
					putch(padc, putdat);
  800520:	83 ec 08             	sub    $0x8,%esp
  800523:	53                   	push   %ebx
  800524:	ff 75 e0             	pushl  -0x20(%ebp)
  800527:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800529:	83 ef 01             	sub    $0x1,%edi
  80052c:	83 c4 10             	add    $0x10,%esp
  80052f:	85 ff                	test   %edi,%edi
  800531:	7f ed                	jg     800520 <vprintfmt+0x1c3>
  800533:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800536:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800539:	85 c9                	test   %ecx,%ecx
  80053b:	b8 00 00 00 00       	mov    $0x0,%eax
  800540:	0f 49 c1             	cmovns %ecx,%eax
  800543:	29 c1                	sub    %eax,%ecx
  800545:	89 75 08             	mov    %esi,0x8(%ebp)
  800548:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80054b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80054e:	89 cb                	mov    %ecx,%ebx
  800550:	eb 4d                	jmp    80059f <vprintfmt+0x242>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800552:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800556:	74 1b                	je     800573 <vprintfmt+0x216>
  800558:	0f be c0             	movsbl %al,%eax
  80055b:	83 e8 20             	sub    $0x20,%eax
  80055e:	83 f8 5e             	cmp    $0x5e,%eax
  800561:	76 10                	jbe    800573 <vprintfmt+0x216>
					putch('?', putdat);
  800563:	83 ec 08             	sub    $0x8,%esp
  800566:	ff 75 0c             	pushl  0xc(%ebp)
  800569:	6a 3f                	push   $0x3f
  80056b:	ff 55 08             	call   *0x8(%ebp)
  80056e:	83 c4 10             	add    $0x10,%esp
  800571:	eb 0d                	jmp    800580 <vprintfmt+0x223>
				else
					putch(ch, putdat);
  800573:	83 ec 08             	sub    $0x8,%esp
  800576:	ff 75 0c             	pushl  0xc(%ebp)
  800579:	52                   	push   %edx
  80057a:	ff 55 08             	call   *0x8(%ebp)
  80057d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800580:	83 eb 01             	sub    $0x1,%ebx
  800583:	eb 1a                	jmp    80059f <vprintfmt+0x242>
  800585:	89 75 08             	mov    %esi,0x8(%ebp)
  800588:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80058b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80058e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800591:	eb 0c                	jmp    80059f <vprintfmt+0x242>
  800593:	89 75 08             	mov    %esi,0x8(%ebp)
  800596:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800599:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80059c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80059f:	83 c7 01             	add    $0x1,%edi
  8005a2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005a6:	0f be d0             	movsbl %al,%edx
  8005a9:	85 d2                	test   %edx,%edx
  8005ab:	74 23                	je     8005d0 <vprintfmt+0x273>
  8005ad:	85 f6                	test   %esi,%esi
  8005af:	78 a1                	js     800552 <vprintfmt+0x1f5>
  8005b1:	83 ee 01             	sub    $0x1,%esi
  8005b4:	79 9c                	jns    800552 <vprintfmt+0x1f5>
  8005b6:	89 df                	mov    %ebx,%edi
  8005b8:	8b 75 08             	mov    0x8(%ebp),%esi
  8005bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005be:	eb 18                	jmp    8005d8 <vprintfmt+0x27b>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005c0:	83 ec 08             	sub    $0x8,%esp
  8005c3:	53                   	push   %ebx
  8005c4:	6a 20                	push   $0x20
  8005c6:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005c8:	83 ef 01             	sub    $0x1,%edi
  8005cb:	83 c4 10             	add    $0x10,%esp
  8005ce:	eb 08                	jmp    8005d8 <vprintfmt+0x27b>
  8005d0:	89 df                	mov    %ebx,%edi
  8005d2:	8b 75 08             	mov    0x8(%ebp),%esi
  8005d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005d8:	85 ff                	test   %edi,%edi
  8005da:	7f e4                	jg     8005c0 <vprintfmt+0x263>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005df:	e9 9f fd ff ff       	jmp    800383 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005e4:	83 7d d0 01          	cmpl   $0x1,-0x30(%ebp)
  8005e8:	7e 16                	jle    800600 <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  8005ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ed:	8d 50 08             	lea    0x8(%eax),%edx
  8005f0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f3:	8b 50 04             	mov    0x4(%eax),%edx
  8005f6:	8b 00                	mov    (%eax),%eax
  8005f8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005fb:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005fe:	eb 34                	jmp    800634 <vprintfmt+0x2d7>
	else if (lflag)
  800600:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800604:	74 18                	je     80061e <vprintfmt+0x2c1>
		return va_arg(*ap, long);
  800606:	8b 45 14             	mov    0x14(%ebp),%eax
  800609:	8d 50 04             	lea    0x4(%eax),%edx
  80060c:	89 55 14             	mov    %edx,0x14(%ebp)
  80060f:	8b 00                	mov    (%eax),%eax
  800611:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800614:	89 c1                	mov    %eax,%ecx
  800616:	c1 f9 1f             	sar    $0x1f,%ecx
  800619:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80061c:	eb 16                	jmp    800634 <vprintfmt+0x2d7>
	else
		return va_arg(*ap, int);
  80061e:	8b 45 14             	mov    0x14(%ebp),%eax
  800621:	8d 50 04             	lea    0x4(%eax),%edx
  800624:	89 55 14             	mov    %edx,0x14(%ebp)
  800627:	8b 00                	mov    (%eax),%eax
  800629:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80062c:	89 c1                	mov    %eax,%ecx
  80062e:	c1 f9 1f             	sar    $0x1f,%ecx
  800631:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800634:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800637:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80063a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80063f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800643:	0f 89 88 00 00 00    	jns    8006d1 <vprintfmt+0x374>
				putch('-', putdat);
  800649:	83 ec 08             	sub    $0x8,%esp
  80064c:	53                   	push   %ebx
  80064d:	6a 2d                	push   $0x2d
  80064f:	ff d6                	call   *%esi
				num = -(long long) num;
  800651:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800654:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800657:	f7 d8                	neg    %eax
  800659:	83 d2 00             	adc    $0x0,%edx
  80065c:	f7 da                	neg    %edx
  80065e:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800661:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800666:	eb 69                	jmp    8006d1 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800668:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80066b:	8d 45 14             	lea    0x14(%ebp),%eax
  80066e:	e8 76 fc ff ff       	call   8002e9 <getuint>
			base = 10;
  800673:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800678:	eb 57                	jmp    8006d1 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  80067a:	83 ec 08             	sub    $0x8,%esp
  80067d:	53                   	push   %ebx
  80067e:	6a 30                	push   $0x30
  800680:	ff d6                	call   *%esi
			num = getuint(&ap, lflag);
  800682:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800685:	8d 45 14             	lea    0x14(%ebp),%eax
  800688:	e8 5c fc ff ff       	call   8002e9 <getuint>
			base = 8;
			goto number;
  80068d:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800690:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800695:	eb 3a                	jmp    8006d1 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  800697:	83 ec 08             	sub    $0x8,%esp
  80069a:	53                   	push   %ebx
  80069b:	6a 30                	push   $0x30
  80069d:	ff d6                	call   *%esi
			putch('x', putdat);
  80069f:	83 c4 08             	add    $0x8,%esp
  8006a2:	53                   	push   %ebx
  8006a3:	6a 78                	push   $0x78
  8006a5:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006aa:	8d 50 04             	lea    0x4(%eax),%edx
  8006ad:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006b0:	8b 00                	mov    (%eax),%eax
  8006b2:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006b7:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006ba:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006bf:	eb 10                	jmp    8006d1 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006c1:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8006c4:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c7:	e8 1d fc ff ff       	call   8002e9 <getuint>
			base = 16;
  8006cc:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006d1:	83 ec 0c             	sub    $0xc,%esp
  8006d4:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006d8:	57                   	push   %edi
  8006d9:	ff 75 e0             	pushl  -0x20(%ebp)
  8006dc:	51                   	push   %ecx
  8006dd:	52                   	push   %edx
  8006de:	50                   	push   %eax
  8006df:	89 da                	mov    %ebx,%edx
  8006e1:	89 f0                	mov    %esi,%eax
  8006e3:	e8 52 fb ff ff       	call   80023a <printnum>
			break;
  8006e8:	83 c4 20             	add    $0x20,%esp
  8006eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006ee:	e9 90 fc ff ff       	jmp    800383 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006f3:	83 ec 08             	sub    $0x8,%esp
  8006f6:	53                   	push   %ebx
  8006f7:	52                   	push   %edx
  8006f8:	ff d6                	call   *%esi
			break;
  8006fa:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800700:	e9 7e fc ff ff       	jmp    800383 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800705:	83 ec 08             	sub    $0x8,%esp
  800708:	53                   	push   %ebx
  800709:	6a 25                	push   $0x25
  80070b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80070d:	83 c4 10             	add    $0x10,%esp
  800710:	eb 03                	jmp    800715 <vprintfmt+0x3b8>
  800712:	83 ef 01             	sub    $0x1,%edi
  800715:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800719:	75 f7                	jne    800712 <vprintfmt+0x3b5>
  80071b:	e9 63 fc ff ff       	jmp    800383 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800720:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800723:	5b                   	pop    %ebx
  800724:	5e                   	pop    %esi
  800725:	5f                   	pop    %edi
  800726:	5d                   	pop    %ebp
  800727:	c3                   	ret    

00800728 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800728:	55                   	push   %ebp
  800729:	89 e5                	mov    %esp,%ebp
  80072b:	83 ec 18             	sub    $0x18,%esp
  80072e:	8b 45 08             	mov    0x8(%ebp),%eax
  800731:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800734:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800737:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80073b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80073e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800745:	85 c0                	test   %eax,%eax
  800747:	74 26                	je     80076f <vsnprintf+0x47>
  800749:	85 d2                	test   %edx,%edx
  80074b:	7e 22                	jle    80076f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80074d:	ff 75 14             	pushl  0x14(%ebp)
  800750:	ff 75 10             	pushl  0x10(%ebp)
  800753:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800756:	50                   	push   %eax
  800757:	68 23 03 80 00       	push   $0x800323
  80075c:	e8 fc fb ff ff       	call   80035d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800761:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800764:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800767:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80076a:	83 c4 10             	add    $0x10,%esp
  80076d:	eb 05                	jmp    800774 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80076f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800774:	c9                   	leave  
  800775:	c3                   	ret    

00800776 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800776:	55                   	push   %ebp
  800777:	89 e5                	mov    %esp,%ebp
  800779:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80077c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80077f:	50                   	push   %eax
  800780:	ff 75 10             	pushl  0x10(%ebp)
  800783:	ff 75 0c             	pushl  0xc(%ebp)
  800786:	ff 75 08             	pushl  0x8(%ebp)
  800789:	e8 9a ff ff ff       	call   800728 <vsnprintf>
	va_end(ap);

	return rc;
}
  80078e:	c9                   	leave  
  80078f:	c3                   	ret    

00800790 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800790:	55                   	push   %ebp
  800791:	89 e5                	mov    %esp,%ebp
  800793:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800796:	b8 00 00 00 00       	mov    $0x0,%eax
  80079b:	eb 03                	jmp    8007a0 <strlen+0x10>
		n++;
  80079d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007a4:	75 f7                	jne    80079d <strlen+0xd>
		n++;
	return n;
}
  8007a6:	5d                   	pop    %ebp
  8007a7:	c3                   	ret    

008007a8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ae:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8007b6:	eb 03                	jmp    8007bb <strnlen+0x13>
		n++;
  8007b8:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007bb:	39 c2                	cmp    %eax,%edx
  8007bd:	74 08                	je     8007c7 <strnlen+0x1f>
  8007bf:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007c3:	75 f3                	jne    8007b8 <strnlen+0x10>
  8007c5:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007c7:	5d                   	pop    %ebp
  8007c8:	c3                   	ret    

008007c9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007c9:	55                   	push   %ebp
  8007ca:	89 e5                	mov    %esp,%ebp
  8007cc:	53                   	push   %ebx
  8007cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007d3:	89 c2                	mov    %eax,%edx
  8007d5:	83 c2 01             	add    $0x1,%edx
  8007d8:	83 c1 01             	add    $0x1,%ecx
  8007db:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007df:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007e2:	84 db                	test   %bl,%bl
  8007e4:	75 ef                	jne    8007d5 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007e6:	5b                   	pop    %ebx
  8007e7:	5d                   	pop    %ebp
  8007e8:	c3                   	ret    

008007e9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007e9:	55                   	push   %ebp
  8007ea:	89 e5                	mov    %esp,%ebp
  8007ec:	53                   	push   %ebx
  8007ed:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007f0:	53                   	push   %ebx
  8007f1:	e8 9a ff ff ff       	call   800790 <strlen>
  8007f6:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007f9:	ff 75 0c             	pushl  0xc(%ebp)
  8007fc:	01 d8                	add    %ebx,%eax
  8007fe:	50                   	push   %eax
  8007ff:	e8 c5 ff ff ff       	call   8007c9 <strcpy>
	return dst;
}
  800804:	89 d8                	mov    %ebx,%eax
  800806:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800809:	c9                   	leave  
  80080a:	c3                   	ret    

0080080b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80080b:	55                   	push   %ebp
  80080c:	89 e5                	mov    %esp,%ebp
  80080e:	56                   	push   %esi
  80080f:	53                   	push   %ebx
  800810:	8b 75 08             	mov    0x8(%ebp),%esi
  800813:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800816:	89 f3                	mov    %esi,%ebx
  800818:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80081b:	89 f2                	mov    %esi,%edx
  80081d:	eb 0f                	jmp    80082e <strncpy+0x23>
		*dst++ = *src;
  80081f:	83 c2 01             	add    $0x1,%edx
  800822:	0f b6 01             	movzbl (%ecx),%eax
  800825:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800828:	80 39 01             	cmpb   $0x1,(%ecx)
  80082b:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80082e:	39 da                	cmp    %ebx,%edx
  800830:	75 ed                	jne    80081f <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800832:	89 f0                	mov    %esi,%eax
  800834:	5b                   	pop    %ebx
  800835:	5e                   	pop    %esi
  800836:	5d                   	pop    %ebp
  800837:	c3                   	ret    

00800838 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800838:	55                   	push   %ebp
  800839:	89 e5                	mov    %esp,%ebp
  80083b:	56                   	push   %esi
  80083c:	53                   	push   %ebx
  80083d:	8b 75 08             	mov    0x8(%ebp),%esi
  800840:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800843:	8b 55 10             	mov    0x10(%ebp),%edx
  800846:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800848:	85 d2                	test   %edx,%edx
  80084a:	74 21                	je     80086d <strlcpy+0x35>
  80084c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800850:	89 f2                	mov    %esi,%edx
  800852:	eb 09                	jmp    80085d <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800854:	83 c2 01             	add    $0x1,%edx
  800857:	83 c1 01             	add    $0x1,%ecx
  80085a:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80085d:	39 c2                	cmp    %eax,%edx
  80085f:	74 09                	je     80086a <strlcpy+0x32>
  800861:	0f b6 19             	movzbl (%ecx),%ebx
  800864:	84 db                	test   %bl,%bl
  800866:	75 ec                	jne    800854 <strlcpy+0x1c>
  800868:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80086a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80086d:	29 f0                	sub    %esi,%eax
}
  80086f:	5b                   	pop    %ebx
  800870:	5e                   	pop    %esi
  800871:	5d                   	pop    %ebp
  800872:	c3                   	ret    

00800873 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800873:	55                   	push   %ebp
  800874:	89 e5                	mov    %esp,%ebp
  800876:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800879:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80087c:	eb 06                	jmp    800884 <strcmp+0x11>
		p++, q++;
  80087e:	83 c1 01             	add    $0x1,%ecx
  800881:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800884:	0f b6 01             	movzbl (%ecx),%eax
  800887:	84 c0                	test   %al,%al
  800889:	74 04                	je     80088f <strcmp+0x1c>
  80088b:	3a 02                	cmp    (%edx),%al
  80088d:	74 ef                	je     80087e <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80088f:	0f b6 c0             	movzbl %al,%eax
  800892:	0f b6 12             	movzbl (%edx),%edx
  800895:	29 d0                	sub    %edx,%eax
}
  800897:	5d                   	pop    %ebp
  800898:	c3                   	ret    

00800899 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800899:	55                   	push   %ebp
  80089a:	89 e5                	mov    %esp,%ebp
  80089c:	53                   	push   %ebx
  80089d:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a3:	89 c3                	mov    %eax,%ebx
  8008a5:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008a8:	eb 06                	jmp    8008b0 <strncmp+0x17>
		n--, p++, q++;
  8008aa:	83 c0 01             	add    $0x1,%eax
  8008ad:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008b0:	39 d8                	cmp    %ebx,%eax
  8008b2:	74 15                	je     8008c9 <strncmp+0x30>
  8008b4:	0f b6 08             	movzbl (%eax),%ecx
  8008b7:	84 c9                	test   %cl,%cl
  8008b9:	74 04                	je     8008bf <strncmp+0x26>
  8008bb:	3a 0a                	cmp    (%edx),%cl
  8008bd:	74 eb                	je     8008aa <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008bf:	0f b6 00             	movzbl (%eax),%eax
  8008c2:	0f b6 12             	movzbl (%edx),%edx
  8008c5:	29 d0                	sub    %edx,%eax
  8008c7:	eb 05                	jmp    8008ce <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008c9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008ce:	5b                   	pop    %ebx
  8008cf:	5d                   	pop    %ebp
  8008d0:	c3                   	ret    

008008d1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008d1:	55                   	push   %ebp
  8008d2:	89 e5                	mov    %esp,%ebp
  8008d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008db:	eb 07                	jmp    8008e4 <strchr+0x13>
		if (*s == c)
  8008dd:	38 ca                	cmp    %cl,%dl
  8008df:	74 0f                	je     8008f0 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008e1:	83 c0 01             	add    $0x1,%eax
  8008e4:	0f b6 10             	movzbl (%eax),%edx
  8008e7:	84 d2                	test   %dl,%dl
  8008e9:	75 f2                	jne    8008dd <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008eb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008f0:	5d                   	pop    %ebp
  8008f1:	c3                   	ret    

008008f2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008f2:	55                   	push   %ebp
  8008f3:	89 e5                	mov    %esp,%ebp
  8008f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008fc:	eb 03                	jmp    800901 <strfind+0xf>
  8008fe:	83 c0 01             	add    $0x1,%eax
  800901:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800904:	38 ca                	cmp    %cl,%dl
  800906:	74 04                	je     80090c <strfind+0x1a>
  800908:	84 d2                	test   %dl,%dl
  80090a:	75 f2                	jne    8008fe <strfind+0xc>
			break;
	return (char *) s;
}
  80090c:	5d                   	pop    %ebp
  80090d:	c3                   	ret    

0080090e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80090e:	55                   	push   %ebp
  80090f:	89 e5                	mov    %esp,%ebp
  800911:	57                   	push   %edi
  800912:	56                   	push   %esi
  800913:	53                   	push   %ebx
  800914:	8b 7d 08             	mov    0x8(%ebp),%edi
  800917:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80091a:	85 c9                	test   %ecx,%ecx
  80091c:	74 36                	je     800954 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80091e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800924:	75 28                	jne    80094e <memset+0x40>
  800926:	f6 c1 03             	test   $0x3,%cl
  800929:	75 23                	jne    80094e <memset+0x40>
		c &= 0xFF;
  80092b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80092f:	89 d3                	mov    %edx,%ebx
  800931:	c1 e3 08             	shl    $0x8,%ebx
  800934:	89 d6                	mov    %edx,%esi
  800936:	c1 e6 18             	shl    $0x18,%esi
  800939:	89 d0                	mov    %edx,%eax
  80093b:	c1 e0 10             	shl    $0x10,%eax
  80093e:	09 f0                	or     %esi,%eax
  800940:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800942:	89 d8                	mov    %ebx,%eax
  800944:	09 d0                	or     %edx,%eax
  800946:	c1 e9 02             	shr    $0x2,%ecx
  800949:	fc                   	cld    
  80094a:	f3 ab                	rep stos %eax,%es:(%edi)
  80094c:	eb 06                	jmp    800954 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80094e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800951:	fc                   	cld    
  800952:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800954:	89 f8                	mov    %edi,%eax
  800956:	5b                   	pop    %ebx
  800957:	5e                   	pop    %esi
  800958:	5f                   	pop    %edi
  800959:	5d                   	pop    %ebp
  80095a:	c3                   	ret    

0080095b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	57                   	push   %edi
  80095f:	56                   	push   %esi
  800960:	8b 45 08             	mov    0x8(%ebp),%eax
  800963:	8b 75 0c             	mov    0xc(%ebp),%esi
  800966:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800969:	39 c6                	cmp    %eax,%esi
  80096b:	73 35                	jae    8009a2 <memmove+0x47>
  80096d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800970:	39 d0                	cmp    %edx,%eax
  800972:	73 2e                	jae    8009a2 <memmove+0x47>
		s += n;
		d += n;
  800974:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800977:	89 d6                	mov    %edx,%esi
  800979:	09 fe                	or     %edi,%esi
  80097b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800981:	75 13                	jne    800996 <memmove+0x3b>
  800983:	f6 c1 03             	test   $0x3,%cl
  800986:	75 0e                	jne    800996 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800988:	83 ef 04             	sub    $0x4,%edi
  80098b:	8d 72 fc             	lea    -0x4(%edx),%esi
  80098e:	c1 e9 02             	shr    $0x2,%ecx
  800991:	fd                   	std    
  800992:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800994:	eb 09                	jmp    80099f <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800996:	83 ef 01             	sub    $0x1,%edi
  800999:	8d 72 ff             	lea    -0x1(%edx),%esi
  80099c:	fd                   	std    
  80099d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80099f:	fc                   	cld    
  8009a0:	eb 1d                	jmp    8009bf <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a2:	89 f2                	mov    %esi,%edx
  8009a4:	09 c2                	or     %eax,%edx
  8009a6:	f6 c2 03             	test   $0x3,%dl
  8009a9:	75 0f                	jne    8009ba <memmove+0x5f>
  8009ab:	f6 c1 03             	test   $0x3,%cl
  8009ae:	75 0a                	jne    8009ba <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009b0:	c1 e9 02             	shr    $0x2,%ecx
  8009b3:	89 c7                	mov    %eax,%edi
  8009b5:	fc                   	cld    
  8009b6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009b8:	eb 05                	jmp    8009bf <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009ba:	89 c7                	mov    %eax,%edi
  8009bc:	fc                   	cld    
  8009bd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009bf:	5e                   	pop    %esi
  8009c0:	5f                   	pop    %edi
  8009c1:	5d                   	pop    %ebp
  8009c2:	c3                   	ret    

008009c3 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009c3:	55                   	push   %ebp
  8009c4:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009c6:	ff 75 10             	pushl  0x10(%ebp)
  8009c9:	ff 75 0c             	pushl  0xc(%ebp)
  8009cc:	ff 75 08             	pushl  0x8(%ebp)
  8009cf:	e8 87 ff ff ff       	call   80095b <memmove>
}
  8009d4:	c9                   	leave  
  8009d5:	c3                   	ret    

008009d6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009d6:	55                   	push   %ebp
  8009d7:	89 e5                	mov    %esp,%ebp
  8009d9:	56                   	push   %esi
  8009da:	53                   	push   %ebx
  8009db:	8b 45 08             	mov    0x8(%ebp),%eax
  8009de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009e1:	89 c6                	mov    %eax,%esi
  8009e3:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009e6:	eb 1a                	jmp    800a02 <memcmp+0x2c>
		if (*s1 != *s2)
  8009e8:	0f b6 08             	movzbl (%eax),%ecx
  8009eb:	0f b6 1a             	movzbl (%edx),%ebx
  8009ee:	38 d9                	cmp    %bl,%cl
  8009f0:	74 0a                	je     8009fc <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009f2:	0f b6 c1             	movzbl %cl,%eax
  8009f5:	0f b6 db             	movzbl %bl,%ebx
  8009f8:	29 d8                	sub    %ebx,%eax
  8009fa:	eb 0f                	jmp    800a0b <memcmp+0x35>
		s1++, s2++;
  8009fc:	83 c0 01             	add    $0x1,%eax
  8009ff:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a02:	39 f0                	cmp    %esi,%eax
  800a04:	75 e2                	jne    8009e8 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a06:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a0b:	5b                   	pop    %ebx
  800a0c:	5e                   	pop    %esi
  800a0d:	5d                   	pop    %ebp
  800a0e:	c3                   	ret    

00800a0f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a0f:	55                   	push   %ebp
  800a10:	89 e5                	mov    %esp,%ebp
  800a12:	53                   	push   %ebx
  800a13:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a16:	89 c1                	mov    %eax,%ecx
  800a18:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a1b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a1f:	eb 0a                	jmp    800a2b <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a21:	0f b6 10             	movzbl (%eax),%edx
  800a24:	39 da                	cmp    %ebx,%edx
  800a26:	74 07                	je     800a2f <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a28:	83 c0 01             	add    $0x1,%eax
  800a2b:	39 c8                	cmp    %ecx,%eax
  800a2d:	72 f2                	jb     800a21 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a2f:	5b                   	pop    %ebx
  800a30:	5d                   	pop    %ebp
  800a31:	c3                   	ret    

00800a32 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a32:	55                   	push   %ebp
  800a33:	89 e5                	mov    %esp,%ebp
  800a35:	57                   	push   %edi
  800a36:	56                   	push   %esi
  800a37:	53                   	push   %ebx
  800a38:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a3b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a3e:	eb 03                	jmp    800a43 <strtol+0x11>
		s++;
  800a40:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a43:	0f b6 01             	movzbl (%ecx),%eax
  800a46:	3c 20                	cmp    $0x20,%al
  800a48:	74 f6                	je     800a40 <strtol+0xe>
  800a4a:	3c 09                	cmp    $0x9,%al
  800a4c:	74 f2                	je     800a40 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a4e:	3c 2b                	cmp    $0x2b,%al
  800a50:	75 0a                	jne    800a5c <strtol+0x2a>
		s++;
  800a52:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a55:	bf 00 00 00 00       	mov    $0x0,%edi
  800a5a:	eb 11                	jmp    800a6d <strtol+0x3b>
  800a5c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a61:	3c 2d                	cmp    $0x2d,%al
  800a63:	75 08                	jne    800a6d <strtol+0x3b>
		s++, neg = 1;
  800a65:	83 c1 01             	add    $0x1,%ecx
  800a68:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a6d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a73:	75 15                	jne    800a8a <strtol+0x58>
  800a75:	80 39 30             	cmpb   $0x30,(%ecx)
  800a78:	75 10                	jne    800a8a <strtol+0x58>
  800a7a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a7e:	75 7c                	jne    800afc <strtol+0xca>
		s += 2, base = 16;
  800a80:	83 c1 02             	add    $0x2,%ecx
  800a83:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a88:	eb 16                	jmp    800aa0 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a8a:	85 db                	test   %ebx,%ebx
  800a8c:	75 12                	jne    800aa0 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a8e:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a93:	80 39 30             	cmpb   $0x30,(%ecx)
  800a96:	75 08                	jne    800aa0 <strtol+0x6e>
		s++, base = 8;
  800a98:	83 c1 01             	add    $0x1,%ecx
  800a9b:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800aa0:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa5:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800aa8:	0f b6 11             	movzbl (%ecx),%edx
  800aab:	8d 72 d0             	lea    -0x30(%edx),%esi
  800aae:	89 f3                	mov    %esi,%ebx
  800ab0:	80 fb 09             	cmp    $0x9,%bl
  800ab3:	77 08                	ja     800abd <strtol+0x8b>
			dig = *s - '0';
  800ab5:	0f be d2             	movsbl %dl,%edx
  800ab8:	83 ea 30             	sub    $0x30,%edx
  800abb:	eb 22                	jmp    800adf <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800abd:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ac0:	89 f3                	mov    %esi,%ebx
  800ac2:	80 fb 19             	cmp    $0x19,%bl
  800ac5:	77 08                	ja     800acf <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ac7:	0f be d2             	movsbl %dl,%edx
  800aca:	83 ea 57             	sub    $0x57,%edx
  800acd:	eb 10                	jmp    800adf <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800acf:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ad2:	89 f3                	mov    %esi,%ebx
  800ad4:	80 fb 19             	cmp    $0x19,%bl
  800ad7:	77 16                	ja     800aef <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ad9:	0f be d2             	movsbl %dl,%edx
  800adc:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800adf:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ae2:	7d 0b                	jge    800aef <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ae4:	83 c1 01             	add    $0x1,%ecx
  800ae7:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aeb:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800aed:	eb b9                	jmp    800aa8 <strtol+0x76>

	if (endptr)
  800aef:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800af3:	74 0d                	je     800b02 <strtol+0xd0>
		*endptr = (char *) s;
  800af5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800af8:	89 0e                	mov    %ecx,(%esi)
  800afa:	eb 06                	jmp    800b02 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800afc:	85 db                	test   %ebx,%ebx
  800afe:	74 98                	je     800a98 <strtol+0x66>
  800b00:	eb 9e                	jmp    800aa0 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b02:	89 c2                	mov    %eax,%edx
  800b04:	f7 da                	neg    %edx
  800b06:	85 ff                	test   %edi,%edi
  800b08:	0f 45 c2             	cmovne %edx,%eax
}
  800b0b:	5b                   	pop    %ebx
  800b0c:	5e                   	pop    %esi
  800b0d:	5f                   	pop    %edi
  800b0e:	5d                   	pop    %ebp
  800b0f:	c3                   	ret    

00800b10 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b10:	55                   	push   %ebp
  800b11:	89 e5                	mov    %esp,%ebp
  800b13:	57                   	push   %edi
  800b14:	56                   	push   %esi
  800b15:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b16:	b8 00 00 00 00       	mov    $0x0,%eax
  800b1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b21:	89 c3                	mov    %eax,%ebx
  800b23:	89 c7                	mov    %eax,%edi
  800b25:	89 c6                	mov    %eax,%esi
  800b27:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b29:	5b                   	pop    %ebx
  800b2a:	5e                   	pop    %esi
  800b2b:	5f                   	pop    %edi
  800b2c:	5d                   	pop    %ebp
  800b2d:	c3                   	ret    

00800b2e <sys_cgetc>:

int
sys_cgetc(void)
{
  800b2e:	55                   	push   %ebp
  800b2f:	89 e5                	mov    %esp,%ebp
  800b31:	57                   	push   %edi
  800b32:	56                   	push   %esi
  800b33:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b34:	ba 00 00 00 00       	mov    $0x0,%edx
  800b39:	b8 01 00 00 00       	mov    $0x1,%eax
  800b3e:	89 d1                	mov    %edx,%ecx
  800b40:	89 d3                	mov    %edx,%ebx
  800b42:	89 d7                	mov    %edx,%edi
  800b44:	89 d6                	mov    %edx,%esi
  800b46:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b48:	5b                   	pop    %ebx
  800b49:	5e                   	pop    %esi
  800b4a:	5f                   	pop    %edi
  800b4b:	5d                   	pop    %ebp
  800b4c:	c3                   	ret    

00800b4d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b4d:	55                   	push   %ebp
  800b4e:	89 e5                	mov    %esp,%ebp
  800b50:	57                   	push   %edi
  800b51:	56                   	push   %esi
  800b52:	53                   	push   %ebx
  800b53:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b56:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b5b:	b8 03 00 00 00       	mov    $0x3,%eax
  800b60:	8b 55 08             	mov    0x8(%ebp),%edx
  800b63:	89 cb                	mov    %ecx,%ebx
  800b65:	89 cf                	mov    %ecx,%edi
  800b67:	89 ce                	mov    %ecx,%esi
  800b69:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b6b:	85 c0                	test   %eax,%eax
  800b6d:	7e 17                	jle    800b86 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b6f:	83 ec 0c             	sub    $0xc,%esp
  800b72:	50                   	push   %eax
  800b73:	6a 03                	push   $0x3
  800b75:	68 7f 25 80 00       	push   $0x80257f
  800b7a:	6a 23                	push   $0x23
  800b7c:	68 9c 25 80 00       	push   $0x80259c
  800b81:	e8 c7 f5 ff ff       	call   80014d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b89:	5b                   	pop    %ebx
  800b8a:	5e                   	pop    %esi
  800b8b:	5f                   	pop    %edi
  800b8c:	5d                   	pop    %ebp
  800b8d:	c3                   	ret    

00800b8e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b8e:	55                   	push   %ebp
  800b8f:	89 e5                	mov    %esp,%ebp
  800b91:	57                   	push   %edi
  800b92:	56                   	push   %esi
  800b93:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b94:	ba 00 00 00 00       	mov    $0x0,%edx
  800b99:	b8 02 00 00 00       	mov    $0x2,%eax
  800b9e:	89 d1                	mov    %edx,%ecx
  800ba0:	89 d3                	mov    %edx,%ebx
  800ba2:	89 d7                	mov    %edx,%edi
  800ba4:	89 d6                	mov    %edx,%esi
  800ba6:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ba8:	5b                   	pop    %ebx
  800ba9:	5e                   	pop    %esi
  800baa:	5f                   	pop    %edi
  800bab:	5d                   	pop    %ebp
  800bac:	c3                   	ret    

00800bad <sys_yield>:

void
sys_yield(void)
{
  800bad:	55                   	push   %ebp
  800bae:	89 e5                	mov    %esp,%ebp
  800bb0:	57                   	push   %edi
  800bb1:	56                   	push   %esi
  800bb2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb3:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb8:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bbd:	89 d1                	mov    %edx,%ecx
  800bbf:	89 d3                	mov    %edx,%ebx
  800bc1:	89 d7                	mov    %edx,%edi
  800bc3:	89 d6                	mov    %edx,%esi
  800bc5:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bc7:	5b                   	pop    %ebx
  800bc8:	5e                   	pop    %esi
  800bc9:	5f                   	pop    %edi
  800bca:	5d                   	pop    %ebp
  800bcb:	c3                   	ret    

00800bcc <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bcc:	55                   	push   %ebp
  800bcd:	89 e5                	mov    %esp,%ebp
  800bcf:	57                   	push   %edi
  800bd0:	56                   	push   %esi
  800bd1:	53                   	push   %ebx
  800bd2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd5:	be 00 00 00 00       	mov    $0x0,%esi
  800bda:	b8 04 00 00 00       	mov    $0x4,%eax
  800bdf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be2:	8b 55 08             	mov    0x8(%ebp),%edx
  800be5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800be8:	89 f7                	mov    %esi,%edi
  800bea:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bec:	85 c0                	test   %eax,%eax
  800bee:	7e 17                	jle    800c07 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf0:	83 ec 0c             	sub    $0xc,%esp
  800bf3:	50                   	push   %eax
  800bf4:	6a 04                	push   $0x4
  800bf6:	68 7f 25 80 00       	push   $0x80257f
  800bfb:	6a 23                	push   $0x23
  800bfd:	68 9c 25 80 00       	push   $0x80259c
  800c02:	e8 46 f5 ff ff       	call   80014d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c07:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c0a:	5b                   	pop    %ebx
  800c0b:	5e                   	pop    %esi
  800c0c:	5f                   	pop    %edi
  800c0d:	5d                   	pop    %ebp
  800c0e:	c3                   	ret    

00800c0f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c0f:	55                   	push   %ebp
  800c10:	89 e5                	mov    %esp,%ebp
  800c12:	57                   	push   %edi
  800c13:	56                   	push   %esi
  800c14:	53                   	push   %ebx
  800c15:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c18:	b8 05 00 00 00       	mov    $0x5,%eax
  800c1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c20:	8b 55 08             	mov    0x8(%ebp),%edx
  800c23:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c26:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c29:	8b 75 18             	mov    0x18(%ebp),%esi
  800c2c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c2e:	85 c0                	test   %eax,%eax
  800c30:	7e 17                	jle    800c49 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c32:	83 ec 0c             	sub    $0xc,%esp
  800c35:	50                   	push   %eax
  800c36:	6a 05                	push   $0x5
  800c38:	68 7f 25 80 00       	push   $0x80257f
  800c3d:	6a 23                	push   $0x23
  800c3f:	68 9c 25 80 00       	push   $0x80259c
  800c44:	e8 04 f5 ff ff       	call   80014d <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c49:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c4c:	5b                   	pop    %ebx
  800c4d:	5e                   	pop    %esi
  800c4e:	5f                   	pop    %edi
  800c4f:	5d                   	pop    %ebp
  800c50:	c3                   	ret    

00800c51 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c51:	55                   	push   %ebp
  800c52:	89 e5                	mov    %esp,%ebp
  800c54:	57                   	push   %edi
  800c55:	56                   	push   %esi
  800c56:	53                   	push   %ebx
  800c57:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c5f:	b8 06 00 00 00       	mov    $0x6,%eax
  800c64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c67:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6a:	89 df                	mov    %ebx,%edi
  800c6c:	89 de                	mov    %ebx,%esi
  800c6e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c70:	85 c0                	test   %eax,%eax
  800c72:	7e 17                	jle    800c8b <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c74:	83 ec 0c             	sub    $0xc,%esp
  800c77:	50                   	push   %eax
  800c78:	6a 06                	push   $0x6
  800c7a:	68 7f 25 80 00       	push   $0x80257f
  800c7f:	6a 23                	push   $0x23
  800c81:	68 9c 25 80 00       	push   $0x80259c
  800c86:	e8 c2 f4 ff ff       	call   80014d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c8b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8e:	5b                   	pop    %ebx
  800c8f:	5e                   	pop    %esi
  800c90:	5f                   	pop    %edi
  800c91:	5d                   	pop    %ebp
  800c92:	c3                   	ret    

00800c93 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c93:	55                   	push   %ebp
  800c94:	89 e5                	mov    %esp,%ebp
  800c96:	57                   	push   %edi
  800c97:	56                   	push   %esi
  800c98:	53                   	push   %ebx
  800c99:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca1:	b8 08 00 00 00       	mov    $0x8,%eax
  800ca6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cac:	89 df                	mov    %ebx,%edi
  800cae:	89 de                	mov    %ebx,%esi
  800cb0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cb2:	85 c0                	test   %eax,%eax
  800cb4:	7e 17                	jle    800ccd <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb6:	83 ec 0c             	sub    $0xc,%esp
  800cb9:	50                   	push   %eax
  800cba:	6a 08                	push   $0x8
  800cbc:	68 7f 25 80 00       	push   $0x80257f
  800cc1:	6a 23                	push   $0x23
  800cc3:	68 9c 25 80 00       	push   $0x80259c
  800cc8:	e8 80 f4 ff ff       	call   80014d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ccd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd0:	5b                   	pop    %ebx
  800cd1:	5e                   	pop    %esi
  800cd2:	5f                   	pop    %edi
  800cd3:	5d                   	pop    %ebp
  800cd4:	c3                   	ret    

00800cd5 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cd5:	55                   	push   %ebp
  800cd6:	89 e5                	mov    %esp,%ebp
  800cd8:	57                   	push   %edi
  800cd9:	56                   	push   %esi
  800cda:	53                   	push   %ebx
  800cdb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cde:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce3:	b8 09 00 00 00       	mov    $0x9,%eax
  800ce8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ceb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cee:	89 df                	mov    %ebx,%edi
  800cf0:	89 de                	mov    %ebx,%esi
  800cf2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cf4:	85 c0                	test   %eax,%eax
  800cf6:	7e 17                	jle    800d0f <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf8:	83 ec 0c             	sub    $0xc,%esp
  800cfb:	50                   	push   %eax
  800cfc:	6a 09                	push   $0x9
  800cfe:	68 7f 25 80 00       	push   $0x80257f
  800d03:	6a 23                	push   $0x23
  800d05:	68 9c 25 80 00       	push   $0x80259c
  800d0a:	e8 3e f4 ff ff       	call   80014d <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d0f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d12:	5b                   	pop    %ebx
  800d13:	5e                   	pop    %esi
  800d14:	5f                   	pop    %edi
  800d15:	5d                   	pop    %ebp
  800d16:	c3                   	ret    

00800d17 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
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
  800d20:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d25:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d30:	89 df                	mov    %ebx,%edi
  800d32:	89 de                	mov    %ebx,%esi
  800d34:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d36:	85 c0                	test   %eax,%eax
  800d38:	7e 17                	jle    800d51 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3a:	83 ec 0c             	sub    $0xc,%esp
  800d3d:	50                   	push   %eax
  800d3e:	6a 0a                	push   $0xa
  800d40:	68 7f 25 80 00       	push   $0x80257f
  800d45:	6a 23                	push   $0x23
  800d47:	68 9c 25 80 00       	push   $0x80259c
  800d4c:	e8 fc f3 ff ff       	call   80014d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d51:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d54:	5b                   	pop    %ebx
  800d55:	5e                   	pop    %esi
  800d56:	5f                   	pop    %edi
  800d57:	5d                   	pop    %ebp
  800d58:	c3                   	ret    

00800d59 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d59:	55                   	push   %ebp
  800d5a:	89 e5                	mov    %esp,%ebp
  800d5c:	57                   	push   %edi
  800d5d:	56                   	push   %esi
  800d5e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5f:	be 00 00 00 00       	mov    $0x0,%esi
  800d64:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d69:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d72:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d75:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d77:	5b                   	pop    %ebx
  800d78:	5e                   	pop    %esi
  800d79:	5f                   	pop    %edi
  800d7a:	5d                   	pop    %ebp
  800d7b:	c3                   	ret    

00800d7c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
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
  800d85:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d8a:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d92:	89 cb                	mov    %ecx,%ebx
  800d94:	89 cf                	mov    %ecx,%edi
  800d96:	89 ce                	mov    %ecx,%esi
  800d98:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d9a:	85 c0                	test   %eax,%eax
  800d9c:	7e 17                	jle    800db5 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d9e:	83 ec 0c             	sub    $0xc,%esp
  800da1:	50                   	push   %eax
  800da2:	6a 0d                	push   $0xd
  800da4:	68 7f 25 80 00       	push   $0x80257f
  800da9:	6a 23                	push   $0x23
  800dab:	68 9c 25 80 00       	push   $0x80259c
  800db0:	e8 98 f3 ff ff       	call   80014d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800db5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800db8:	5b                   	pop    %ebx
  800db9:	5e                   	pop    %esi
  800dba:	5f                   	pop    %edi
  800dbb:	5d                   	pop    %ebp
  800dbc:	c3                   	ret    

00800dbd <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800dbd:	55                   	push   %ebp
  800dbe:	89 e5                	mov    %esp,%ebp
  800dc0:	53                   	push   %ebx
  800dc1:	83 ec 04             	sub    $0x4,%esp
	int r;
	// LAB 4: Your code here.
    	pte_t *pte;
	int ret;
	// 用户空间的地址较低
	void *addr = (void *)(pn * PGSIZE);
  800dc4:	89 d3                	mov    %edx,%ebx
  800dc6:	c1 e3 0c             	shl    $0xc,%ebx
	if (uvpt[pn] & PTE_SHARE) {
  800dc9:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800dd0:	f6 c5 04             	test   $0x4,%ch
  800dd3:	74 2f                	je     800e04 <duppage+0x47>
		// cprintf("dup share page :%d\n", pn);
		if ((r = sys_page_map(0, addr, envid, addr, PTE_SYSCALL)) < 0)
  800dd5:	83 ec 0c             	sub    $0xc,%esp
  800dd8:	68 07 0e 00 00       	push   $0xe07
  800ddd:	53                   	push   %ebx
  800dde:	50                   	push   %eax
  800ddf:	53                   	push   %ebx
  800de0:	6a 00                	push   $0x0
  800de2:	e8 28 fe ff ff       	call   800c0f <sys_page_map>
  800de7:	83 c4 20             	add    $0x20,%esp
  800dea:	85 c0                	test   %eax,%eax
  800dec:	0f 89 a0 00 00 00    	jns    800e92 <duppage+0xd5>
			panic("duppage sys_page_map:%e", r);
  800df2:	50                   	push   %eax
  800df3:	68 aa 25 80 00       	push   $0x8025aa
  800df8:	6a 4d                	push   $0x4d
  800dfa:	68 c2 25 80 00       	push   $0x8025c2
  800dff:	e8 49 f3 ff ff       	call   80014d <_panic>
	} else if (uvpt[pn] & (PTE_W|PTE_COW)) {
  800e04:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e0b:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800e11:	74 57                	je     800e6a <duppage+0xad>
		if ((r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  800e13:	83 ec 0c             	sub    $0xc,%esp
  800e16:	68 05 08 00 00       	push   $0x805
  800e1b:	53                   	push   %ebx
  800e1c:	50                   	push   %eax
  800e1d:	53                   	push   %ebx
  800e1e:	6a 00                	push   $0x0
  800e20:	e8 ea fd ff ff       	call   800c0f <sys_page_map>
  800e25:	83 c4 20             	add    $0x20,%esp
  800e28:	85 c0                	test   %eax,%eax
  800e2a:	79 12                	jns    800e3e <duppage+0x81>
			panic("sys_page_map COW:%e", r);
  800e2c:	50                   	push   %eax
  800e2d:	68 cd 25 80 00       	push   $0x8025cd
  800e32:	6a 50                	push   $0x50
  800e34:	68 c2 25 80 00       	push   $0x8025c2
  800e39:	e8 0f f3 ff ff       	call   80014d <_panic>

		if ((r = sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  800e3e:	83 ec 0c             	sub    $0xc,%esp
  800e41:	68 05 08 00 00       	push   $0x805
  800e46:	53                   	push   %ebx
  800e47:	6a 00                	push   $0x0
  800e49:	53                   	push   %ebx
  800e4a:	6a 00                	push   $0x0
  800e4c:	e8 be fd ff ff       	call   800c0f <sys_page_map>
  800e51:	83 c4 20             	add    $0x20,%esp
  800e54:	85 c0                	test   %eax,%eax
  800e56:	79 3a                	jns    800e92 <duppage+0xd5>
			panic("sys_page_map COW:%e", r);
  800e58:	50                   	push   %eax
  800e59:	68 cd 25 80 00       	push   $0x8025cd
  800e5e:	6a 53                	push   $0x53
  800e60:	68 c2 25 80 00       	push   $0x8025c2
  800e65:	e8 e3 f2 ff ff       	call   80014d <_panic>
	} else {
		if ((r = sys_page_map(0, addr, envid, addr, PTE_U|PTE_P)) < 0)
  800e6a:	83 ec 0c             	sub    $0xc,%esp
  800e6d:	6a 05                	push   $0x5
  800e6f:	53                   	push   %ebx
  800e70:	50                   	push   %eax
  800e71:	53                   	push   %ebx
  800e72:	6a 00                	push   $0x0
  800e74:	e8 96 fd ff ff       	call   800c0f <sys_page_map>
  800e79:	83 c4 20             	add    $0x20,%esp
  800e7c:	85 c0                	test   %eax,%eax
  800e7e:	79 12                	jns    800e92 <duppage+0xd5>
			panic("sys_page_map UP:%e", r);
  800e80:	50                   	push   %eax
  800e81:	68 e1 25 80 00       	push   $0x8025e1
  800e86:	6a 56                	push   $0x56
  800e88:	68 c2 25 80 00       	push   $0x8025c2
  800e8d:	e8 bb f2 ff ff       	call   80014d <_panic>
	}
	return 0;
}
  800e92:	b8 00 00 00 00       	mov    $0x0,%eax
  800e97:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e9a:	c9                   	leave  
  800e9b:	c3                   	ret    

00800e9c <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e9c:	55                   	push   %ebp
  800e9d:	89 e5                	mov    %esp,%ebp
  800e9f:	56                   	push   %esi
  800ea0:	53                   	push   %ebx
  800ea1:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800ea4:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (! ( (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  800ea6:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800eaa:	74 2d                	je     800ed9 <pgfault+0x3d>
  800eac:	89 d8                	mov    %ebx,%eax
  800eae:	c1 e8 16             	shr    $0x16,%eax
  800eb1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800eb8:	a8 01                	test   $0x1,%al
  800eba:	74 1d                	je     800ed9 <pgfault+0x3d>
  800ebc:	89 d8                	mov    %ebx,%eax
  800ebe:	c1 e8 0c             	shr    $0xc,%eax
  800ec1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ec8:	f6 c2 01             	test   $0x1,%dl
  800ecb:	74 0c                	je     800ed9 <pgfault+0x3d>
  800ecd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ed4:	f6 c4 08             	test   $0x8,%ah
  800ed7:	75 14                	jne    800eed <pgfault+0x51>
        	panic("Neither the fault is a write nor COW page. \n");
  800ed9:	83 ec 04             	sub    $0x4,%esp
  800edc:	68 60 26 80 00       	push   $0x802660
  800ee1:	6a 1d                	push   $0x1d
  800ee3:	68 c2 25 80 00       	push   $0x8025c2
  800ee8:	e8 60 f2 ff ff       	call   80014d <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.
	

    	envid_t envid = sys_getenvid();
  800eed:	e8 9c fc ff ff       	call   800b8e <sys_getenvid>
  800ef2:	89 c6                	mov    %eax,%esi
    	// cprintf("pgfault: envid: %d\n", ENVX(envid));
    	// 临时页暂存
    	if ((r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P| PTE_W|PTE_U)) < 0)
  800ef4:	83 ec 04             	sub    $0x4,%esp
  800ef7:	6a 07                	push   $0x7
  800ef9:	68 00 f0 7f 00       	push   $0x7ff000
  800efe:	50                   	push   %eax
  800eff:	e8 c8 fc ff ff       	call   800bcc <sys_page_alloc>
  800f04:	83 c4 10             	add    $0x10,%esp
  800f07:	85 c0                	test   %eax,%eax
  800f09:	79 12                	jns    800f1d <pgfault+0x81>
        	panic("pgfault: page allocation fault:%e\n", r);
  800f0b:	50                   	push   %eax
  800f0c:	68 90 26 80 00       	push   $0x802690
  800f11:	6a 2b                	push   $0x2b
  800f13:	68 c2 25 80 00       	push   $0x8025c2
  800f18:	e8 30 f2 ff ff       	call   80014d <_panic>
    	addr = ROUNDDOWN(addr, PGSIZE);
  800f1d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  800f23:	83 ec 04             	sub    $0x4,%esp
  800f26:	68 00 10 00 00       	push   $0x1000
  800f2b:	53                   	push   %ebx
  800f2c:	68 00 f0 7f 00       	push   $0x7ff000
  800f31:	e8 8d fa ff ff       	call   8009c3 <memcpy>
    	if ((r = sys_page_map(envid, (void *) PFTEMP, envid, addr , PTE_P|PTE_W|PTE_U)) < 0 )
  800f36:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f3d:	53                   	push   %ebx
  800f3e:	56                   	push   %esi
  800f3f:	68 00 f0 7f 00       	push   $0x7ff000
  800f44:	56                   	push   %esi
  800f45:	e8 c5 fc ff ff       	call   800c0f <sys_page_map>
  800f4a:	83 c4 20             	add    $0x20,%esp
  800f4d:	85 c0                	test   %eax,%eax
  800f4f:	79 12                	jns    800f63 <pgfault+0xc7>
        	panic("pgfault: page map failed %e\n", r);
  800f51:	50                   	push   %eax
  800f52:	68 f4 25 80 00       	push   $0x8025f4
  800f57:	6a 2f                	push   $0x2f
  800f59:	68 c2 25 80 00       	push   $0x8025c2
  800f5e:	e8 ea f1 ff ff       	call   80014d <_panic>
    
    	if ((r = sys_page_unmap(envid, (void *) PFTEMP)) < 0)
  800f63:	83 ec 08             	sub    $0x8,%esp
  800f66:	68 00 f0 7f 00       	push   $0x7ff000
  800f6b:	56                   	push   %esi
  800f6c:	e8 e0 fc ff ff       	call   800c51 <sys_page_unmap>
  800f71:	83 c4 10             	add    $0x10,%esp
  800f74:	85 c0                	test   %eax,%eax
  800f76:	79 12                	jns    800f8a <pgfault+0xee>
        	panic("pgfault: page unmap failed %e\n", r);
  800f78:	50                   	push   %eax
  800f79:	68 b4 26 80 00       	push   $0x8026b4
  800f7e:	6a 32                	push   $0x32
  800f80:	68 c2 25 80 00       	push   $0x8025c2
  800f85:	e8 c3 f1 ff ff       	call   80014d <_panic>
	//panic("pgfault not implemented");
}
  800f8a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f8d:	5b                   	pop    %ebx
  800f8e:	5e                   	pop    %esi
  800f8f:	5d                   	pop    %ebp
  800f90:	c3                   	ret    

00800f91 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f91:	55                   	push   %ebp
  800f92:	89 e5                	mov    %esp,%ebp
  800f94:	56                   	push   %esi
  800f95:	53                   	push   %ebx
  800f96:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	set_pgfault_handler(pgfault);
  800f99:	68 9c 0e 80 00       	push   $0x800e9c
  800f9e:	e8 14 0e 00 00       	call   801db7 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800fa3:	b8 07 00 00 00       	mov    $0x7,%eax
  800fa8:	cd 30                	int    $0x30
  800faa:	89 c3                	mov    %eax,%ebx

	envid_t envid = sys_exofork();
	uint8_t *addr;
	if (envid < 0)
  800fac:	83 c4 10             	add    $0x10,%esp
  800faf:	85 c0                	test   %eax,%eax
  800fb1:	79 12                	jns    800fc5 <fork+0x34>
		panic("sys_exofork:%e", envid);
  800fb3:	50                   	push   %eax
  800fb4:	68 11 26 80 00       	push   $0x802611
  800fb9:	6a 75                	push   $0x75
  800fbb:	68 c2 25 80 00       	push   $0x8025c2
  800fc0:	e8 88 f1 ff ff       	call   80014d <_panic>
  800fc5:	89 c6                	mov    %eax,%esi
	if (envid == 0) {
  800fc7:	85 c0                	test   %eax,%eax
  800fc9:	75 21                	jne    800fec <fork+0x5b>
		thisenv = &envs[ENVX(sys_getenvid())];
  800fcb:	e8 be fb ff ff       	call   800b8e <sys_getenvid>
  800fd0:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fd5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fd8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fdd:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800fe2:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe7:	e9 c0 00 00 00       	jmp    8010ac <fork+0x11b>
	}

	for (addr = (uint8_t *)UTEXT; addr < (uint8_t *)USTACKTOP-PGSIZE; addr += PGSIZE) {
  800fec:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  800ff3:	ba 00 00 80 00       	mov    $0x800000,%edx
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
  800ff8:	89 d0                	mov    %edx,%eax
  800ffa:	c1 e8 16             	shr    $0x16,%eax
  800ffd:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801004:	a8 01                	test   $0x1,%al
  801006:	74 20                	je     801028 <fork+0x97>
  801008:	c1 ea 0c             	shr    $0xc,%edx
  80100b:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801012:	a8 01                	test   $0x1,%al
  801014:	74 12                	je     801028 <fork+0x97>
				&& (uvpt[PGNUM(addr)] & PTE_U)) {
  801016:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80101d:	a8 04                	test   $0x4,%al
  80101f:	74 07                	je     801028 <fork+0x97>
			duppage(envid, PGNUM(addr));
  801021:	89 f0                	mov    %esi,%eax
  801023:	e8 95 fd ff ff       	call   800dbd <duppage>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}

	for (addr = (uint8_t *)UTEXT; addr < (uint8_t *)USTACKTOP-PGSIZE; addr += PGSIZE) {
  801028:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80102b:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
  801031:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801034:	81 fa ff cf bf ee    	cmp    $0xeebfcfff,%edx
  80103a:	76 bc                	jbe    800ff8 <fork+0x67>
				&& (uvpt[PGNUM(addr)] & PTE_U)) {
			duppage(envid, PGNUM(addr));
		}
	}

	duppage(envid, PGNUM(ROUNDDOWN(&addr, PGSIZE)));
  80103c:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80103f:	c1 ea 0c             	shr    $0xc,%edx
  801042:	89 d8                	mov    %ebx,%eax
  801044:	e8 74 fd ff ff       	call   800dbd <duppage>

	int r;
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)))
  801049:	83 ec 04             	sub    $0x4,%esp
  80104c:	6a 07                	push   $0x7
  80104e:	68 00 f0 bf ee       	push   $0xeebff000
  801053:	53                   	push   %ebx
  801054:	e8 73 fb ff ff       	call   800bcc <sys_page_alloc>
  801059:	83 c4 10             	add    $0x10,%esp
  80105c:	85 c0                	test   %eax,%eax
  80105e:	74 15                	je     801075 <fork+0xe4>
		panic("sys_page_alloc:%e", r);
  801060:	50                   	push   %eax
  801061:	68 20 26 80 00       	push   $0x802620
  801066:	68 86 00 00 00       	push   $0x86
  80106b:	68 c2 25 80 00       	push   $0x8025c2
  801070:	e8 d8 f0 ff ff       	call   80014d <_panic>

	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801075:	83 ec 08             	sub    $0x8,%esp
  801078:	68 1f 1e 80 00       	push   $0x801e1f
  80107d:	53                   	push   %ebx
  80107e:	e8 94 fc ff ff       	call   800d17 <sys_env_set_pgfault_upcall>

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)))
  801083:	83 c4 08             	add    $0x8,%esp
  801086:	6a 02                	push   $0x2
  801088:	53                   	push   %ebx
  801089:	e8 05 fc ff ff       	call   800c93 <sys_env_set_status>
  80108e:	83 c4 10             	add    $0x10,%esp
  801091:	85 c0                	test   %eax,%eax
  801093:	74 15                	je     8010aa <fork+0x119>
		panic("sys_env_set_status:%e", r);
  801095:	50                   	push   %eax
  801096:	68 32 26 80 00       	push   $0x802632
  80109b:	68 8c 00 00 00       	push   $0x8c
  8010a0:	68 c2 25 80 00       	push   $0x8025c2
  8010a5:	e8 a3 f0 ff ff       	call   80014d <_panic>

	return envid;
  8010aa:	89 d8                	mov    %ebx,%eax
	    
}
  8010ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010af:	5b                   	pop    %ebx
  8010b0:	5e                   	pop    %esi
  8010b1:	5d                   	pop    %ebp
  8010b2:	c3                   	ret    

008010b3 <sfork>:

// Challenge!
int
sfork(void)
{
  8010b3:	55                   	push   %ebp
  8010b4:	89 e5                	mov    %esp,%ebp
  8010b6:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010b9:	68 48 26 80 00       	push   $0x802648
  8010be:	68 96 00 00 00       	push   $0x96
  8010c3:	68 c2 25 80 00       	push   $0x8025c2
  8010c8:	e8 80 f0 ff ff       	call   80014d <_panic>

008010cd <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010cd:	55                   	push   %ebp
  8010ce:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d3:	05 00 00 00 30       	add    $0x30000000,%eax
  8010d8:	c1 e8 0c             	shr    $0xc,%eax
}
  8010db:	5d                   	pop    %ebp
  8010dc:	c3                   	ret    

008010dd <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010dd:	55                   	push   %ebp
  8010de:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8010e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e3:	05 00 00 00 30       	add    $0x30000000,%eax
  8010e8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010ed:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010f2:	5d                   	pop    %ebp
  8010f3:	c3                   	ret    

008010f4 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010f4:	55                   	push   %ebp
  8010f5:	89 e5                	mov    %esp,%ebp
  8010f7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010fa:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010ff:	89 c2                	mov    %eax,%edx
  801101:	c1 ea 16             	shr    $0x16,%edx
  801104:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80110b:	f6 c2 01             	test   $0x1,%dl
  80110e:	74 11                	je     801121 <fd_alloc+0x2d>
  801110:	89 c2                	mov    %eax,%edx
  801112:	c1 ea 0c             	shr    $0xc,%edx
  801115:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80111c:	f6 c2 01             	test   $0x1,%dl
  80111f:	75 09                	jne    80112a <fd_alloc+0x36>
			*fd_store = fd;
  801121:	89 01                	mov    %eax,(%ecx)
			return 0;
  801123:	b8 00 00 00 00       	mov    $0x0,%eax
  801128:	eb 17                	jmp    801141 <fd_alloc+0x4d>
  80112a:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80112f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801134:	75 c9                	jne    8010ff <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801136:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80113c:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801141:	5d                   	pop    %ebp
  801142:	c3                   	ret    

00801143 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801143:	55                   	push   %ebp
  801144:	89 e5                	mov    %esp,%ebp
  801146:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801149:	83 f8 1f             	cmp    $0x1f,%eax
  80114c:	77 36                	ja     801184 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80114e:	c1 e0 0c             	shl    $0xc,%eax
  801151:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801156:	89 c2                	mov    %eax,%edx
  801158:	c1 ea 16             	shr    $0x16,%edx
  80115b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801162:	f6 c2 01             	test   $0x1,%dl
  801165:	74 24                	je     80118b <fd_lookup+0x48>
  801167:	89 c2                	mov    %eax,%edx
  801169:	c1 ea 0c             	shr    $0xc,%edx
  80116c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801173:	f6 c2 01             	test   $0x1,%dl
  801176:	74 1a                	je     801192 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801178:	8b 55 0c             	mov    0xc(%ebp),%edx
  80117b:	89 02                	mov    %eax,(%edx)
	return 0;
  80117d:	b8 00 00 00 00       	mov    $0x0,%eax
  801182:	eb 13                	jmp    801197 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801184:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801189:	eb 0c                	jmp    801197 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80118b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801190:	eb 05                	jmp    801197 <fd_lookup+0x54>
  801192:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801197:	5d                   	pop    %ebp
  801198:	c3                   	ret    

00801199 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801199:	55                   	push   %ebp
  80119a:	89 e5                	mov    %esp,%ebp
  80119c:	83 ec 08             	sub    $0x8,%esp
  80119f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011a2:	ba 50 27 80 00       	mov    $0x802750,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8011a7:	eb 13                	jmp    8011bc <dev_lookup+0x23>
  8011a9:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8011ac:	39 08                	cmp    %ecx,(%eax)
  8011ae:	75 0c                	jne    8011bc <dev_lookup+0x23>
			*dev = devtab[i];
  8011b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011b3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ba:	eb 2e                	jmp    8011ea <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011bc:	8b 02                	mov    (%edx),%eax
  8011be:	85 c0                	test   %eax,%eax
  8011c0:	75 e7                	jne    8011a9 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011c2:	a1 08 40 80 00       	mov    0x804008,%eax
  8011c7:	8b 40 48             	mov    0x48(%eax),%eax
  8011ca:	83 ec 04             	sub    $0x4,%esp
  8011cd:	51                   	push   %ecx
  8011ce:	50                   	push   %eax
  8011cf:	68 d4 26 80 00       	push   $0x8026d4
  8011d4:	e8 4d f0 ff ff       	call   800226 <cprintf>
	*dev = 0;
  8011d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011dc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011e2:	83 c4 10             	add    $0x10,%esp
  8011e5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011ea:	c9                   	leave  
  8011eb:	c3                   	ret    

008011ec <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8011ec:	55                   	push   %ebp
  8011ed:	89 e5                	mov    %esp,%ebp
  8011ef:	56                   	push   %esi
  8011f0:	53                   	push   %ebx
  8011f1:	83 ec 10             	sub    $0x10,%esp
  8011f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8011f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011fd:	50                   	push   %eax
  8011fe:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801204:	c1 e8 0c             	shr    $0xc,%eax
  801207:	50                   	push   %eax
  801208:	e8 36 ff ff ff       	call   801143 <fd_lookup>
  80120d:	83 c4 08             	add    $0x8,%esp
  801210:	85 c0                	test   %eax,%eax
  801212:	78 05                	js     801219 <fd_close+0x2d>
	    || fd != fd2)
  801214:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801217:	74 0c                	je     801225 <fd_close+0x39>
		return (must_exist ? r : 0);
  801219:	84 db                	test   %bl,%bl
  80121b:	ba 00 00 00 00       	mov    $0x0,%edx
  801220:	0f 44 c2             	cmove  %edx,%eax
  801223:	eb 41                	jmp    801266 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801225:	83 ec 08             	sub    $0x8,%esp
  801228:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80122b:	50                   	push   %eax
  80122c:	ff 36                	pushl  (%esi)
  80122e:	e8 66 ff ff ff       	call   801199 <dev_lookup>
  801233:	89 c3                	mov    %eax,%ebx
  801235:	83 c4 10             	add    $0x10,%esp
  801238:	85 c0                	test   %eax,%eax
  80123a:	78 1a                	js     801256 <fd_close+0x6a>
		if (dev->dev_close)
  80123c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80123f:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801242:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801247:	85 c0                	test   %eax,%eax
  801249:	74 0b                	je     801256 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80124b:	83 ec 0c             	sub    $0xc,%esp
  80124e:	56                   	push   %esi
  80124f:	ff d0                	call   *%eax
  801251:	89 c3                	mov    %eax,%ebx
  801253:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801256:	83 ec 08             	sub    $0x8,%esp
  801259:	56                   	push   %esi
  80125a:	6a 00                	push   $0x0
  80125c:	e8 f0 f9 ff ff       	call   800c51 <sys_page_unmap>
	return r;
  801261:	83 c4 10             	add    $0x10,%esp
  801264:	89 d8                	mov    %ebx,%eax
}
  801266:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801269:	5b                   	pop    %ebx
  80126a:	5e                   	pop    %esi
  80126b:	5d                   	pop    %ebp
  80126c:	c3                   	ret    

0080126d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80126d:	55                   	push   %ebp
  80126e:	89 e5                	mov    %esp,%ebp
  801270:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801273:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801276:	50                   	push   %eax
  801277:	ff 75 08             	pushl  0x8(%ebp)
  80127a:	e8 c4 fe ff ff       	call   801143 <fd_lookup>
  80127f:	83 c4 08             	add    $0x8,%esp
  801282:	85 c0                	test   %eax,%eax
  801284:	78 10                	js     801296 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801286:	83 ec 08             	sub    $0x8,%esp
  801289:	6a 01                	push   $0x1
  80128b:	ff 75 f4             	pushl  -0xc(%ebp)
  80128e:	e8 59 ff ff ff       	call   8011ec <fd_close>
  801293:	83 c4 10             	add    $0x10,%esp
}
  801296:	c9                   	leave  
  801297:	c3                   	ret    

00801298 <close_all>:

void
close_all(void)
{
  801298:	55                   	push   %ebp
  801299:	89 e5                	mov    %esp,%ebp
  80129b:	53                   	push   %ebx
  80129c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80129f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012a4:	83 ec 0c             	sub    $0xc,%esp
  8012a7:	53                   	push   %ebx
  8012a8:	e8 c0 ff ff ff       	call   80126d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012ad:	83 c3 01             	add    $0x1,%ebx
  8012b0:	83 c4 10             	add    $0x10,%esp
  8012b3:	83 fb 20             	cmp    $0x20,%ebx
  8012b6:	75 ec                	jne    8012a4 <close_all+0xc>
		close(i);
}
  8012b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012bb:	c9                   	leave  
  8012bc:	c3                   	ret    

008012bd <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012bd:	55                   	push   %ebp
  8012be:	89 e5                	mov    %esp,%ebp
  8012c0:	57                   	push   %edi
  8012c1:	56                   	push   %esi
  8012c2:	53                   	push   %ebx
  8012c3:	83 ec 2c             	sub    $0x2c,%esp
  8012c6:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012c9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012cc:	50                   	push   %eax
  8012cd:	ff 75 08             	pushl  0x8(%ebp)
  8012d0:	e8 6e fe ff ff       	call   801143 <fd_lookup>
  8012d5:	83 c4 08             	add    $0x8,%esp
  8012d8:	85 c0                	test   %eax,%eax
  8012da:	0f 88 c1 00 00 00    	js     8013a1 <dup+0xe4>
		return r;
	close(newfdnum);
  8012e0:	83 ec 0c             	sub    $0xc,%esp
  8012e3:	56                   	push   %esi
  8012e4:	e8 84 ff ff ff       	call   80126d <close>

	newfd = INDEX2FD(newfdnum);
  8012e9:	89 f3                	mov    %esi,%ebx
  8012eb:	c1 e3 0c             	shl    $0xc,%ebx
  8012ee:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8012f4:	83 c4 04             	add    $0x4,%esp
  8012f7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012fa:	e8 de fd ff ff       	call   8010dd <fd2data>
  8012ff:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801301:	89 1c 24             	mov    %ebx,(%esp)
  801304:	e8 d4 fd ff ff       	call   8010dd <fd2data>
  801309:	83 c4 10             	add    $0x10,%esp
  80130c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80130f:	89 f8                	mov    %edi,%eax
  801311:	c1 e8 16             	shr    $0x16,%eax
  801314:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80131b:	a8 01                	test   $0x1,%al
  80131d:	74 37                	je     801356 <dup+0x99>
  80131f:	89 f8                	mov    %edi,%eax
  801321:	c1 e8 0c             	shr    $0xc,%eax
  801324:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80132b:	f6 c2 01             	test   $0x1,%dl
  80132e:	74 26                	je     801356 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801330:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801337:	83 ec 0c             	sub    $0xc,%esp
  80133a:	25 07 0e 00 00       	and    $0xe07,%eax
  80133f:	50                   	push   %eax
  801340:	ff 75 d4             	pushl  -0x2c(%ebp)
  801343:	6a 00                	push   $0x0
  801345:	57                   	push   %edi
  801346:	6a 00                	push   $0x0
  801348:	e8 c2 f8 ff ff       	call   800c0f <sys_page_map>
  80134d:	89 c7                	mov    %eax,%edi
  80134f:	83 c4 20             	add    $0x20,%esp
  801352:	85 c0                	test   %eax,%eax
  801354:	78 2e                	js     801384 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801356:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801359:	89 d0                	mov    %edx,%eax
  80135b:	c1 e8 0c             	shr    $0xc,%eax
  80135e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801365:	83 ec 0c             	sub    $0xc,%esp
  801368:	25 07 0e 00 00       	and    $0xe07,%eax
  80136d:	50                   	push   %eax
  80136e:	53                   	push   %ebx
  80136f:	6a 00                	push   $0x0
  801371:	52                   	push   %edx
  801372:	6a 00                	push   $0x0
  801374:	e8 96 f8 ff ff       	call   800c0f <sys_page_map>
  801379:	89 c7                	mov    %eax,%edi
  80137b:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80137e:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801380:	85 ff                	test   %edi,%edi
  801382:	79 1d                	jns    8013a1 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801384:	83 ec 08             	sub    $0x8,%esp
  801387:	53                   	push   %ebx
  801388:	6a 00                	push   $0x0
  80138a:	e8 c2 f8 ff ff       	call   800c51 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80138f:	83 c4 08             	add    $0x8,%esp
  801392:	ff 75 d4             	pushl  -0x2c(%ebp)
  801395:	6a 00                	push   $0x0
  801397:	e8 b5 f8 ff ff       	call   800c51 <sys_page_unmap>
	return r;
  80139c:	83 c4 10             	add    $0x10,%esp
  80139f:	89 f8                	mov    %edi,%eax
}
  8013a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013a4:	5b                   	pop    %ebx
  8013a5:	5e                   	pop    %esi
  8013a6:	5f                   	pop    %edi
  8013a7:	5d                   	pop    %ebp
  8013a8:	c3                   	ret    

008013a9 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013a9:	55                   	push   %ebp
  8013aa:	89 e5                	mov    %esp,%ebp
  8013ac:	53                   	push   %ebx
  8013ad:	83 ec 14             	sub    $0x14,%esp
  8013b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013b3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013b6:	50                   	push   %eax
  8013b7:	53                   	push   %ebx
  8013b8:	e8 86 fd ff ff       	call   801143 <fd_lookup>
  8013bd:	83 c4 08             	add    $0x8,%esp
  8013c0:	89 c2                	mov    %eax,%edx
  8013c2:	85 c0                	test   %eax,%eax
  8013c4:	78 6d                	js     801433 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013c6:	83 ec 08             	sub    $0x8,%esp
  8013c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013cc:	50                   	push   %eax
  8013cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013d0:	ff 30                	pushl  (%eax)
  8013d2:	e8 c2 fd ff ff       	call   801199 <dev_lookup>
  8013d7:	83 c4 10             	add    $0x10,%esp
  8013da:	85 c0                	test   %eax,%eax
  8013dc:	78 4c                	js     80142a <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013de:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013e1:	8b 42 08             	mov    0x8(%edx),%eax
  8013e4:	83 e0 03             	and    $0x3,%eax
  8013e7:	83 f8 01             	cmp    $0x1,%eax
  8013ea:	75 21                	jne    80140d <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013ec:	a1 08 40 80 00       	mov    0x804008,%eax
  8013f1:	8b 40 48             	mov    0x48(%eax),%eax
  8013f4:	83 ec 04             	sub    $0x4,%esp
  8013f7:	53                   	push   %ebx
  8013f8:	50                   	push   %eax
  8013f9:	68 15 27 80 00       	push   $0x802715
  8013fe:	e8 23 ee ff ff       	call   800226 <cprintf>
		return -E_INVAL;
  801403:	83 c4 10             	add    $0x10,%esp
  801406:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80140b:	eb 26                	jmp    801433 <read+0x8a>
	}
	if (!dev->dev_read)
  80140d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801410:	8b 40 08             	mov    0x8(%eax),%eax
  801413:	85 c0                	test   %eax,%eax
  801415:	74 17                	je     80142e <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801417:	83 ec 04             	sub    $0x4,%esp
  80141a:	ff 75 10             	pushl  0x10(%ebp)
  80141d:	ff 75 0c             	pushl  0xc(%ebp)
  801420:	52                   	push   %edx
  801421:	ff d0                	call   *%eax
  801423:	89 c2                	mov    %eax,%edx
  801425:	83 c4 10             	add    $0x10,%esp
  801428:	eb 09                	jmp    801433 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80142a:	89 c2                	mov    %eax,%edx
  80142c:	eb 05                	jmp    801433 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80142e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801433:	89 d0                	mov    %edx,%eax
  801435:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801438:	c9                   	leave  
  801439:	c3                   	ret    

0080143a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80143a:	55                   	push   %ebp
  80143b:	89 e5                	mov    %esp,%ebp
  80143d:	57                   	push   %edi
  80143e:	56                   	push   %esi
  80143f:	53                   	push   %ebx
  801440:	83 ec 0c             	sub    $0xc,%esp
  801443:	8b 7d 08             	mov    0x8(%ebp),%edi
  801446:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801449:	bb 00 00 00 00       	mov    $0x0,%ebx
  80144e:	eb 21                	jmp    801471 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801450:	83 ec 04             	sub    $0x4,%esp
  801453:	89 f0                	mov    %esi,%eax
  801455:	29 d8                	sub    %ebx,%eax
  801457:	50                   	push   %eax
  801458:	89 d8                	mov    %ebx,%eax
  80145a:	03 45 0c             	add    0xc(%ebp),%eax
  80145d:	50                   	push   %eax
  80145e:	57                   	push   %edi
  80145f:	e8 45 ff ff ff       	call   8013a9 <read>
		if (m < 0)
  801464:	83 c4 10             	add    $0x10,%esp
  801467:	85 c0                	test   %eax,%eax
  801469:	78 10                	js     80147b <readn+0x41>
			return m;
		if (m == 0)
  80146b:	85 c0                	test   %eax,%eax
  80146d:	74 0a                	je     801479 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80146f:	01 c3                	add    %eax,%ebx
  801471:	39 f3                	cmp    %esi,%ebx
  801473:	72 db                	jb     801450 <readn+0x16>
  801475:	89 d8                	mov    %ebx,%eax
  801477:	eb 02                	jmp    80147b <readn+0x41>
  801479:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80147b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80147e:	5b                   	pop    %ebx
  80147f:	5e                   	pop    %esi
  801480:	5f                   	pop    %edi
  801481:	5d                   	pop    %ebp
  801482:	c3                   	ret    

00801483 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801483:	55                   	push   %ebp
  801484:	89 e5                	mov    %esp,%ebp
  801486:	53                   	push   %ebx
  801487:	83 ec 14             	sub    $0x14,%esp
  80148a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80148d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801490:	50                   	push   %eax
  801491:	53                   	push   %ebx
  801492:	e8 ac fc ff ff       	call   801143 <fd_lookup>
  801497:	83 c4 08             	add    $0x8,%esp
  80149a:	89 c2                	mov    %eax,%edx
  80149c:	85 c0                	test   %eax,%eax
  80149e:	78 68                	js     801508 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014a0:	83 ec 08             	sub    $0x8,%esp
  8014a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014a6:	50                   	push   %eax
  8014a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014aa:	ff 30                	pushl  (%eax)
  8014ac:	e8 e8 fc ff ff       	call   801199 <dev_lookup>
  8014b1:	83 c4 10             	add    $0x10,%esp
  8014b4:	85 c0                	test   %eax,%eax
  8014b6:	78 47                	js     8014ff <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014bb:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014bf:	75 21                	jne    8014e2 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014c1:	a1 08 40 80 00       	mov    0x804008,%eax
  8014c6:	8b 40 48             	mov    0x48(%eax),%eax
  8014c9:	83 ec 04             	sub    $0x4,%esp
  8014cc:	53                   	push   %ebx
  8014cd:	50                   	push   %eax
  8014ce:	68 31 27 80 00       	push   $0x802731
  8014d3:	e8 4e ed ff ff       	call   800226 <cprintf>
		return -E_INVAL;
  8014d8:	83 c4 10             	add    $0x10,%esp
  8014db:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014e0:	eb 26                	jmp    801508 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014e5:	8b 52 0c             	mov    0xc(%edx),%edx
  8014e8:	85 d2                	test   %edx,%edx
  8014ea:	74 17                	je     801503 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014ec:	83 ec 04             	sub    $0x4,%esp
  8014ef:	ff 75 10             	pushl  0x10(%ebp)
  8014f2:	ff 75 0c             	pushl  0xc(%ebp)
  8014f5:	50                   	push   %eax
  8014f6:	ff d2                	call   *%edx
  8014f8:	89 c2                	mov    %eax,%edx
  8014fa:	83 c4 10             	add    $0x10,%esp
  8014fd:	eb 09                	jmp    801508 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ff:	89 c2                	mov    %eax,%edx
  801501:	eb 05                	jmp    801508 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801503:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801508:	89 d0                	mov    %edx,%eax
  80150a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80150d:	c9                   	leave  
  80150e:	c3                   	ret    

0080150f <seek>:

int
seek(int fdnum, off_t offset)
{
  80150f:	55                   	push   %ebp
  801510:	89 e5                	mov    %esp,%ebp
  801512:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801515:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801518:	50                   	push   %eax
  801519:	ff 75 08             	pushl  0x8(%ebp)
  80151c:	e8 22 fc ff ff       	call   801143 <fd_lookup>
  801521:	83 c4 08             	add    $0x8,%esp
  801524:	85 c0                	test   %eax,%eax
  801526:	78 0e                	js     801536 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801528:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80152b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80152e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801531:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801536:	c9                   	leave  
  801537:	c3                   	ret    

00801538 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801538:	55                   	push   %ebp
  801539:	89 e5                	mov    %esp,%ebp
  80153b:	53                   	push   %ebx
  80153c:	83 ec 14             	sub    $0x14,%esp
  80153f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801542:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801545:	50                   	push   %eax
  801546:	53                   	push   %ebx
  801547:	e8 f7 fb ff ff       	call   801143 <fd_lookup>
  80154c:	83 c4 08             	add    $0x8,%esp
  80154f:	89 c2                	mov    %eax,%edx
  801551:	85 c0                	test   %eax,%eax
  801553:	78 65                	js     8015ba <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801555:	83 ec 08             	sub    $0x8,%esp
  801558:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80155b:	50                   	push   %eax
  80155c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80155f:	ff 30                	pushl  (%eax)
  801561:	e8 33 fc ff ff       	call   801199 <dev_lookup>
  801566:	83 c4 10             	add    $0x10,%esp
  801569:	85 c0                	test   %eax,%eax
  80156b:	78 44                	js     8015b1 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80156d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801570:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801574:	75 21                	jne    801597 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801576:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80157b:	8b 40 48             	mov    0x48(%eax),%eax
  80157e:	83 ec 04             	sub    $0x4,%esp
  801581:	53                   	push   %ebx
  801582:	50                   	push   %eax
  801583:	68 f4 26 80 00       	push   $0x8026f4
  801588:	e8 99 ec ff ff       	call   800226 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80158d:	83 c4 10             	add    $0x10,%esp
  801590:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801595:	eb 23                	jmp    8015ba <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801597:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80159a:	8b 52 18             	mov    0x18(%edx),%edx
  80159d:	85 d2                	test   %edx,%edx
  80159f:	74 14                	je     8015b5 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015a1:	83 ec 08             	sub    $0x8,%esp
  8015a4:	ff 75 0c             	pushl  0xc(%ebp)
  8015a7:	50                   	push   %eax
  8015a8:	ff d2                	call   *%edx
  8015aa:	89 c2                	mov    %eax,%edx
  8015ac:	83 c4 10             	add    $0x10,%esp
  8015af:	eb 09                	jmp    8015ba <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b1:	89 c2                	mov    %eax,%edx
  8015b3:	eb 05                	jmp    8015ba <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015b5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8015ba:	89 d0                	mov    %edx,%eax
  8015bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015bf:	c9                   	leave  
  8015c0:	c3                   	ret    

008015c1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015c1:	55                   	push   %ebp
  8015c2:	89 e5                	mov    %esp,%ebp
  8015c4:	53                   	push   %ebx
  8015c5:	83 ec 14             	sub    $0x14,%esp
  8015c8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015cb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015ce:	50                   	push   %eax
  8015cf:	ff 75 08             	pushl  0x8(%ebp)
  8015d2:	e8 6c fb ff ff       	call   801143 <fd_lookup>
  8015d7:	83 c4 08             	add    $0x8,%esp
  8015da:	89 c2                	mov    %eax,%edx
  8015dc:	85 c0                	test   %eax,%eax
  8015de:	78 58                	js     801638 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015e0:	83 ec 08             	sub    $0x8,%esp
  8015e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015e6:	50                   	push   %eax
  8015e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ea:	ff 30                	pushl  (%eax)
  8015ec:	e8 a8 fb ff ff       	call   801199 <dev_lookup>
  8015f1:	83 c4 10             	add    $0x10,%esp
  8015f4:	85 c0                	test   %eax,%eax
  8015f6:	78 37                	js     80162f <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8015f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015fb:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015ff:	74 32                	je     801633 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801601:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801604:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80160b:	00 00 00 
	stat->st_isdir = 0;
  80160e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801615:	00 00 00 
	stat->st_dev = dev;
  801618:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80161e:	83 ec 08             	sub    $0x8,%esp
  801621:	53                   	push   %ebx
  801622:	ff 75 f0             	pushl  -0x10(%ebp)
  801625:	ff 50 14             	call   *0x14(%eax)
  801628:	89 c2                	mov    %eax,%edx
  80162a:	83 c4 10             	add    $0x10,%esp
  80162d:	eb 09                	jmp    801638 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80162f:	89 c2                	mov    %eax,%edx
  801631:	eb 05                	jmp    801638 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801633:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801638:	89 d0                	mov    %edx,%eax
  80163a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80163d:	c9                   	leave  
  80163e:	c3                   	ret    

0080163f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80163f:	55                   	push   %ebp
  801640:	89 e5                	mov    %esp,%ebp
  801642:	56                   	push   %esi
  801643:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801644:	83 ec 08             	sub    $0x8,%esp
  801647:	6a 00                	push   $0x0
  801649:	ff 75 08             	pushl  0x8(%ebp)
  80164c:	e8 e3 01 00 00       	call   801834 <open>
  801651:	89 c3                	mov    %eax,%ebx
  801653:	83 c4 10             	add    $0x10,%esp
  801656:	85 c0                	test   %eax,%eax
  801658:	78 1b                	js     801675 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80165a:	83 ec 08             	sub    $0x8,%esp
  80165d:	ff 75 0c             	pushl  0xc(%ebp)
  801660:	50                   	push   %eax
  801661:	e8 5b ff ff ff       	call   8015c1 <fstat>
  801666:	89 c6                	mov    %eax,%esi
	close(fd);
  801668:	89 1c 24             	mov    %ebx,(%esp)
  80166b:	e8 fd fb ff ff       	call   80126d <close>
	return r;
  801670:	83 c4 10             	add    $0x10,%esp
  801673:	89 f0                	mov    %esi,%eax
}
  801675:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801678:	5b                   	pop    %ebx
  801679:	5e                   	pop    %esi
  80167a:	5d                   	pop    %ebp
  80167b:	c3                   	ret    

0080167c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80167c:	55                   	push   %ebp
  80167d:	89 e5                	mov    %esp,%ebp
  80167f:	56                   	push   %esi
  801680:	53                   	push   %ebx
  801681:	89 c6                	mov    %eax,%esi
  801683:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801685:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80168c:	75 12                	jne    8016a0 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80168e:	83 ec 0c             	sub    $0xc,%esp
  801691:	6a 01                	push   $0x1
  801693:	e8 54 08 00 00       	call   801eec <ipc_find_env>
  801698:	a3 00 40 80 00       	mov    %eax,0x804000
  80169d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016a0:	6a 07                	push   $0x7
  8016a2:	68 00 50 80 00       	push   $0x805000
  8016a7:	56                   	push   %esi
  8016a8:	ff 35 00 40 80 00    	pushl  0x804000
  8016ae:	e8 e5 07 00 00       	call   801e98 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016b3:	83 c4 0c             	add    $0xc,%esp
  8016b6:	6a 00                	push   $0x0
  8016b8:	53                   	push   %ebx
  8016b9:	6a 00                	push   $0x0
  8016bb:	e8 83 07 00 00       	call   801e43 <ipc_recv>
}
  8016c0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016c3:	5b                   	pop    %ebx
  8016c4:	5e                   	pop    %esi
  8016c5:	5d                   	pop    %ebp
  8016c6:	c3                   	ret    

008016c7 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016c7:	55                   	push   %ebp
  8016c8:	89 e5                	mov    %esp,%ebp
  8016ca:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d0:	8b 40 0c             	mov    0xc(%eax),%eax
  8016d3:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016db:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8016e5:	b8 02 00 00 00       	mov    $0x2,%eax
  8016ea:	e8 8d ff ff ff       	call   80167c <fsipc>
}
  8016ef:	c9                   	leave  
  8016f0:	c3                   	ret    

008016f1 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016f1:	55                   	push   %ebp
  8016f2:	89 e5                	mov    %esp,%ebp
  8016f4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8016fa:	8b 40 0c             	mov    0xc(%eax),%eax
  8016fd:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801702:	ba 00 00 00 00       	mov    $0x0,%edx
  801707:	b8 06 00 00 00       	mov    $0x6,%eax
  80170c:	e8 6b ff ff ff       	call   80167c <fsipc>
}
  801711:	c9                   	leave  
  801712:	c3                   	ret    

00801713 <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801713:	55                   	push   %ebp
  801714:	89 e5                	mov    %esp,%ebp
  801716:	53                   	push   %ebx
  801717:	83 ec 04             	sub    $0x4,%esp
  80171a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80171d:	8b 45 08             	mov    0x8(%ebp),%eax
  801720:	8b 40 0c             	mov    0xc(%eax),%eax
  801723:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801728:	ba 00 00 00 00       	mov    $0x0,%edx
  80172d:	b8 05 00 00 00       	mov    $0x5,%eax
  801732:	e8 45 ff ff ff       	call   80167c <fsipc>
  801737:	85 c0                	test   %eax,%eax
  801739:	78 2c                	js     801767 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80173b:	83 ec 08             	sub    $0x8,%esp
  80173e:	68 00 50 80 00       	push   $0x805000
  801743:	53                   	push   %ebx
  801744:	e8 80 f0 ff ff       	call   8007c9 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801749:	a1 80 50 80 00       	mov    0x805080,%eax
  80174e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801754:	a1 84 50 80 00       	mov    0x805084,%eax
  801759:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80175f:	83 c4 10             	add    $0x10,%esp
  801762:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801767:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80176a:	c9                   	leave  
  80176b:	c3                   	ret    

0080176c <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80176c:	55                   	push   %ebp
  80176d:	89 e5                	mov    %esp,%ebp
  80176f:	83 ec 0c             	sub    $0xc,%esp
  801772:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
    
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  801775:	8b 55 08             	mov    0x8(%ebp),%edx
  801778:	8b 52 0c             	mov    0xc(%edx),%edx
  80177b:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = MIN(n, PGSIZE);
  801781:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801786:	ba 00 10 00 00       	mov    $0x1000,%edx
  80178b:	0f 47 c2             	cmova  %edx,%eax
  80178e:	a3 04 50 80 00       	mov    %eax,0x805004
    memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801793:	50                   	push   %eax
  801794:	ff 75 0c             	pushl  0xc(%ebp)
  801797:	68 08 50 80 00       	push   $0x805008
  80179c:	e8 ba f1 ff ff       	call   80095b <memmove>
    int r = fsipc(FSREQ_WRITE, NULL);
  8017a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a6:	b8 04 00 00 00       	mov    $0x4,%eax
  8017ab:	e8 cc fe ff ff       	call   80167c <fsipc>
    return r;
}
  8017b0:	c9                   	leave  
  8017b1:	c3                   	ret    

008017b2 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017b2:	55                   	push   %ebp
  8017b3:	89 e5                	mov    %esp,%ebp
  8017b5:	56                   	push   %esi
  8017b6:	53                   	push   %ebx
  8017b7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8017bd:	8b 40 0c             	mov    0xc(%eax),%eax
  8017c0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8017c5:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d0:	b8 03 00 00 00       	mov    $0x3,%eax
  8017d5:	e8 a2 fe ff ff       	call   80167c <fsipc>
  8017da:	89 c3                	mov    %eax,%ebx
  8017dc:	85 c0                	test   %eax,%eax
  8017de:	78 4b                	js     80182b <devfile_read+0x79>
		return r;
	assert(r <= n);
  8017e0:	39 c6                	cmp    %eax,%esi
  8017e2:	73 16                	jae    8017fa <devfile_read+0x48>
  8017e4:	68 60 27 80 00       	push   $0x802760
  8017e9:	68 67 27 80 00       	push   $0x802767
  8017ee:	6a 7c                	push   $0x7c
  8017f0:	68 7c 27 80 00       	push   $0x80277c
  8017f5:	e8 53 e9 ff ff       	call   80014d <_panic>
	assert(r <= PGSIZE);
  8017fa:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017ff:	7e 16                	jle    801817 <devfile_read+0x65>
  801801:	68 87 27 80 00       	push   $0x802787
  801806:	68 67 27 80 00       	push   $0x802767
  80180b:	6a 7d                	push   $0x7d
  80180d:	68 7c 27 80 00       	push   $0x80277c
  801812:	e8 36 e9 ff ff       	call   80014d <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801817:	83 ec 04             	sub    $0x4,%esp
  80181a:	50                   	push   %eax
  80181b:	68 00 50 80 00       	push   $0x805000
  801820:	ff 75 0c             	pushl  0xc(%ebp)
  801823:	e8 33 f1 ff ff       	call   80095b <memmove>
	return r;
  801828:	83 c4 10             	add    $0x10,%esp
}
  80182b:	89 d8                	mov    %ebx,%eax
  80182d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801830:	5b                   	pop    %ebx
  801831:	5e                   	pop    %esi
  801832:	5d                   	pop    %ebp
  801833:	c3                   	ret    

00801834 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801834:	55                   	push   %ebp
  801835:	89 e5                	mov    %esp,%ebp
  801837:	53                   	push   %ebx
  801838:	83 ec 20             	sub    $0x20,%esp
  80183b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80183e:	53                   	push   %ebx
  80183f:	e8 4c ef ff ff       	call   800790 <strlen>
  801844:	83 c4 10             	add    $0x10,%esp
  801847:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80184c:	7f 67                	jg     8018b5 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80184e:	83 ec 0c             	sub    $0xc,%esp
  801851:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801854:	50                   	push   %eax
  801855:	e8 9a f8 ff ff       	call   8010f4 <fd_alloc>
  80185a:	83 c4 10             	add    $0x10,%esp
		return r;
  80185d:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80185f:	85 c0                	test   %eax,%eax
  801861:	78 57                	js     8018ba <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801863:	83 ec 08             	sub    $0x8,%esp
  801866:	53                   	push   %ebx
  801867:	68 00 50 80 00       	push   $0x805000
  80186c:	e8 58 ef ff ff       	call   8007c9 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801871:	8b 45 0c             	mov    0xc(%ebp),%eax
  801874:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801879:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80187c:	b8 01 00 00 00       	mov    $0x1,%eax
  801881:	e8 f6 fd ff ff       	call   80167c <fsipc>
  801886:	89 c3                	mov    %eax,%ebx
  801888:	83 c4 10             	add    $0x10,%esp
  80188b:	85 c0                	test   %eax,%eax
  80188d:	79 14                	jns    8018a3 <open+0x6f>
		fd_close(fd, 0);
  80188f:	83 ec 08             	sub    $0x8,%esp
  801892:	6a 00                	push   $0x0
  801894:	ff 75 f4             	pushl  -0xc(%ebp)
  801897:	e8 50 f9 ff ff       	call   8011ec <fd_close>
		return r;
  80189c:	83 c4 10             	add    $0x10,%esp
  80189f:	89 da                	mov    %ebx,%edx
  8018a1:	eb 17                	jmp    8018ba <open+0x86>
	}

	return fd2num(fd);
  8018a3:	83 ec 0c             	sub    $0xc,%esp
  8018a6:	ff 75 f4             	pushl  -0xc(%ebp)
  8018a9:	e8 1f f8 ff ff       	call   8010cd <fd2num>
  8018ae:	89 c2                	mov    %eax,%edx
  8018b0:	83 c4 10             	add    $0x10,%esp
  8018b3:	eb 05                	jmp    8018ba <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8018b5:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8018ba:	89 d0                	mov    %edx,%eax
  8018bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018bf:	c9                   	leave  
  8018c0:	c3                   	ret    

008018c1 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8018c1:	55                   	push   %ebp
  8018c2:	89 e5                	mov    %esp,%ebp
  8018c4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8018cc:	b8 08 00 00 00       	mov    $0x8,%eax
  8018d1:	e8 a6 fd ff ff       	call   80167c <fsipc>
}
  8018d6:	c9                   	leave  
  8018d7:	c3                   	ret    

008018d8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8018d8:	55                   	push   %ebp
  8018d9:	89 e5                	mov    %esp,%ebp
  8018db:	56                   	push   %esi
  8018dc:	53                   	push   %ebx
  8018dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8018e0:	83 ec 0c             	sub    $0xc,%esp
  8018e3:	ff 75 08             	pushl  0x8(%ebp)
  8018e6:	e8 f2 f7 ff ff       	call   8010dd <fd2data>
  8018eb:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8018ed:	83 c4 08             	add    $0x8,%esp
  8018f0:	68 93 27 80 00       	push   $0x802793
  8018f5:	53                   	push   %ebx
  8018f6:	e8 ce ee ff ff       	call   8007c9 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8018fb:	8b 46 04             	mov    0x4(%esi),%eax
  8018fe:	2b 06                	sub    (%esi),%eax
  801900:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801906:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80190d:	00 00 00 
	stat->st_dev = &devpipe;
  801910:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801917:	30 80 00 
	return 0;
}
  80191a:	b8 00 00 00 00       	mov    $0x0,%eax
  80191f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801922:	5b                   	pop    %ebx
  801923:	5e                   	pop    %esi
  801924:	5d                   	pop    %ebp
  801925:	c3                   	ret    

00801926 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801926:	55                   	push   %ebp
  801927:	89 e5                	mov    %esp,%ebp
  801929:	53                   	push   %ebx
  80192a:	83 ec 0c             	sub    $0xc,%esp
  80192d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801930:	53                   	push   %ebx
  801931:	6a 00                	push   $0x0
  801933:	e8 19 f3 ff ff       	call   800c51 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801938:	89 1c 24             	mov    %ebx,(%esp)
  80193b:	e8 9d f7 ff ff       	call   8010dd <fd2data>
  801940:	83 c4 08             	add    $0x8,%esp
  801943:	50                   	push   %eax
  801944:	6a 00                	push   $0x0
  801946:	e8 06 f3 ff ff       	call   800c51 <sys_page_unmap>
}
  80194b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80194e:	c9                   	leave  
  80194f:	c3                   	ret    

00801950 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801950:	55                   	push   %ebp
  801951:	89 e5                	mov    %esp,%ebp
  801953:	57                   	push   %edi
  801954:	56                   	push   %esi
  801955:	53                   	push   %ebx
  801956:	83 ec 1c             	sub    $0x1c,%esp
  801959:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80195c:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80195e:	a1 08 40 80 00       	mov    0x804008,%eax
  801963:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801966:	83 ec 0c             	sub    $0xc,%esp
  801969:	ff 75 e0             	pushl  -0x20(%ebp)
  80196c:	e8 b4 05 00 00       	call   801f25 <pageref>
  801971:	89 c3                	mov    %eax,%ebx
  801973:	89 3c 24             	mov    %edi,(%esp)
  801976:	e8 aa 05 00 00       	call   801f25 <pageref>
  80197b:	83 c4 10             	add    $0x10,%esp
  80197e:	39 c3                	cmp    %eax,%ebx
  801980:	0f 94 c1             	sete   %cl
  801983:	0f b6 c9             	movzbl %cl,%ecx
  801986:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801989:	8b 15 08 40 80 00    	mov    0x804008,%edx
  80198f:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801992:	39 ce                	cmp    %ecx,%esi
  801994:	74 1b                	je     8019b1 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801996:	39 c3                	cmp    %eax,%ebx
  801998:	75 c4                	jne    80195e <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80199a:	8b 42 58             	mov    0x58(%edx),%eax
  80199d:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019a0:	50                   	push   %eax
  8019a1:	56                   	push   %esi
  8019a2:	68 9a 27 80 00       	push   $0x80279a
  8019a7:	e8 7a e8 ff ff       	call   800226 <cprintf>
  8019ac:	83 c4 10             	add    $0x10,%esp
  8019af:	eb ad                	jmp    80195e <_pipeisclosed+0xe>
	}
}
  8019b1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019b7:	5b                   	pop    %ebx
  8019b8:	5e                   	pop    %esi
  8019b9:	5f                   	pop    %edi
  8019ba:	5d                   	pop    %ebp
  8019bb:	c3                   	ret    

008019bc <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019bc:	55                   	push   %ebp
  8019bd:	89 e5                	mov    %esp,%ebp
  8019bf:	57                   	push   %edi
  8019c0:	56                   	push   %esi
  8019c1:	53                   	push   %ebx
  8019c2:	83 ec 28             	sub    $0x28,%esp
  8019c5:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8019c8:	56                   	push   %esi
  8019c9:	e8 0f f7 ff ff       	call   8010dd <fd2data>
  8019ce:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019d0:	83 c4 10             	add    $0x10,%esp
  8019d3:	bf 00 00 00 00       	mov    $0x0,%edi
  8019d8:	eb 4b                	jmp    801a25 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8019da:	89 da                	mov    %ebx,%edx
  8019dc:	89 f0                	mov    %esi,%eax
  8019de:	e8 6d ff ff ff       	call   801950 <_pipeisclosed>
  8019e3:	85 c0                	test   %eax,%eax
  8019e5:	75 48                	jne    801a2f <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8019e7:	e8 c1 f1 ff ff       	call   800bad <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8019ec:	8b 43 04             	mov    0x4(%ebx),%eax
  8019ef:	8b 0b                	mov    (%ebx),%ecx
  8019f1:	8d 51 20             	lea    0x20(%ecx),%edx
  8019f4:	39 d0                	cmp    %edx,%eax
  8019f6:	73 e2                	jae    8019da <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8019f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019fb:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8019ff:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a02:	89 c2                	mov    %eax,%edx
  801a04:	c1 fa 1f             	sar    $0x1f,%edx
  801a07:	89 d1                	mov    %edx,%ecx
  801a09:	c1 e9 1b             	shr    $0x1b,%ecx
  801a0c:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a0f:	83 e2 1f             	and    $0x1f,%edx
  801a12:	29 ca                	sub    %ecx,%edx
  801a14:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a18:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a1c:	83 c0 01             	add    $0x1,%eax
  801a1f:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a22:	83 c7 01             	add    $0x1,%edi
  801a25:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a28:	75 c2                	jne    8019ec <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a2a:	8b 45 10             	mov    0x10(%ebp),%eax
  801a2d:	eb 05                	jmp    801a34 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a2f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a37:	5b                   	pop    %ebx
  801a38:	5e                   	pop    %esi
  801a39:	5f                   	pop    %edi
  801a3a:	5d                   	pop    %ebp
  801a3b:	c3                   	ret    

00801a3c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a3c:	55                   	push   %ebp
  801a3d:	89 e5                	mov    %esp,%ebp
  801a3f:	57                   	push   %edi
  801a40:	56                   	push   %esi
  801a41:	53                   	push   %ebx
  801a42:	83 ec 18             	sub    $0x18,%esp
  801a45:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a48:	57                   	push   %edi
  801a49:	e8 8f f6 ff ff       	call   8010dd <fd2data>
  801a4e:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a50:	83 c4 10             	add    $0x10,%esp
  801a53:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a58:	eb 3d                	jmp    801a97 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a5a:	85 db                	test   %ebx,%ebx
  801a5c:	74 04                	je     801a62 <devpipe_read+0x26>
				return i;
  801a5e:	89 d8                	mov    %ebx,%eax
  801a60:	eb 44                	jmp    801aa6 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a62:	89 f2                	mov    %esi,%edx
  801a64:	89 f8                	mov    %edi,%eax
  801a66:	e8 e5 fe ff ff       	call   801950 <_pipeisclosed>
  801a6b:	85 c0                	test   %eax,%eax
  801a6d:	75 32                	jne    801aa1 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a6f:	e8 39 f1 ff ff       	call   800bad <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a74:	8b 06                	mov    (%esi),%eax
  801a76:	3b 46 04             	cmp    0x4(%esi),%eax
  801a79:	74 df                	je     801a5a <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a7b:	99                   	cltd   
  801a7c:	c1 ea 1b             	shr    $0x1b,%edx
  801a7f:	01 d0                	add    %edx,%eax
  801a81:	83 e0 1f             	and    $0x1f,%eax
  801a84:	29 d0                	sub    %edx,%eax
  801a86:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801a8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a8e:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801a91:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a94:	83 c3 01             	add    $0x1,%ebx
  801a97:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a9a:	75 d8                	jne    801a74 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a9c:	8b 45 10             	mov    0x10(%ebp),%eax
  801a9f:	eb 05                	jmp    801aa6 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801aa1:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801aa6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aa9:	5b                   	pop    %ebx
  801aaa:	5e                   	pop    %esi
  801aab:	5f                   	pop    %edi
  801aac:	5d                   	pop    %ebp
  801aad:	c3                   	ret    

00801aae <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801aae:	55                   	push   %ebp
  801aaf:	89 e5                	mov    %esp,%ebp
  801ab1:	56                   	push   %esi
  801ab2:	53                   	push   %ebx
  801ab3:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ab6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ab9:	50                   	push   %eax
  801aba:	e8 35 f6 ff ff       	call   8010f4 <fd_alloc>
  801abf:	83 c4 10             	add    $0x10,%esp
  801ac2:	89 c2                	mov    %eax,%edx
  801ac4:	85 c0                	test   %eax,%eax
  801ac6:	0f 88 2c 01 00 00    	js     801bf8 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801acc:	83 ec 04             	sub    $0x4,%esp
  801acf:	68 07 04 00 00       	push   $0x407
  801ad4:	ff 75 f4             	pushl  -0xc(%ebp)
  801ad7:	6a 00                	push   $0x0
  801ad9:	e8 ee f0 ff ff       	call   800bcc <sys_page_alloc>
  801ade:	83 c4 10             	add    $0x10,%esp
  801ae1:	89 c2                	mov    %eax,%edx
  801ae3:	85 c0                	test   %eax,%eax
  801ae5:	0f 88 0d 01 00 00    	js     801bf8 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801aeb:	83 ec 0c             	sub    $0xc,%esp
  801aee:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801af1:	50                   	push   %eax
  801af2:	e8 fd f5 ff ff       	call   8010f4 <fd_alloc>
  801af7:	89 c3                	mov    %eax,%ebx
  801af9:	83 c4 10             	add    $0x10,%esp
  801afc:	85 c0                	test   %eax,%eax
  801afe:	0f 88 e2 00 00 00    	js     801be6 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b04:	83 ec 04             	sub    $0x4,%esp
  801b07:	68 07 04 00 00       	push   $0x407
  801b0c:	ff 75 f0             	pushl  -0x10(%ebp)
  801b0f:	6a 00                	push   $0x0
  801b11:	e8 b6 f0 ff ff       	call   800bcc <sys_page_alloc>
  801b16:	89 c3                	mov    %eax,%ebx
  801b18:	83 c4 10             	add    $0x10,%esp
  801b1b:	85 c0                	test   %eax,%eax
  801b1d:	0f 88 c3 00 00 00    	js     801be6 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b23:	83 ec 0c             	sub    $0xc,%esp
  801b26:	ff 75 f4             	pushl  -0xc(%ebp)
  801b29:	e8 af f5 ff ff       	call   8010dd <fd2data>
  801b2e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b30:	83 c4 0c             	add    $0xc,%esp
  801b33:	68 07 04 00 00       	push   $0x407
  801b38:	50                   	push   %eax
  801b39:	6a 00                	push   $0x0
  801b3b:	e8 8c f0 ff ff       	call   800bcc <sys_page_alloc>
  801b40:	89 c3                	mov    %eax,%ebx
  801b42:	83 c4 10             	add    $0x10,%esp
  801b45:	85 c0                	test   %eax,%eax
  801b47:	0f 88 89 00 00 00    	js     801bd6 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b4d:	83 ec 0c             	sub    $0xc,%esp
  801b50:	ff 75 f0             	pushl  -0x10(%ebp)
  801b53:	e8 85 f5 ff ff       	call   8010dd <fd2data>
  801b58:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b5f:	50                   	push   %eax
  801b60:	6a 00                	push   $0x0
  801b62:	56                   	push   %esi
  801b63:	6a 00                	push   $0x0
  801b65:	e8 a5 f0 ff ff       	call   800c0f <sys_page_map>
  801b6a:	89 c3                	mov    %eax,%ebx
  801b6c:	83 c4 20             	add    $0x20,%esp
  801b6f:	85 c0                	test   %eax,%eax
  801b71:	78 55                	js     801bc8 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b73:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b79:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b7c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b81:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b88:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b91:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b93:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b96:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b9d:	83 ec 0c             	sub    $0xc,%esp
  801ba0:	ff 75 f4             	pushl  -0xc(%ebp)
  801ba3:	e8 25 f5 ff ff       	call   8010cd <fd2num>
  801ba8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bab:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801bad:	83 c4 04             	add    $0x4,%esp
  801bb0:	ff 75 f0             	pushl  -0x10(%ebp)
  801bb3:	e8 15 f5 ff ff       	call   8010cd <fd2num>
  801bb8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bbb:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801bbe:	83 c4 10             	add    $0x10,%esp
  801bc1:	ba 00 00 00 00       	mov    $0x0,%edx
  801bc6:	eb 30                	jmp    801bf8 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801bc8:	83 ec 08             	sub    $0x8,%esp
  801bcb:	56                   	push   %esi
  801bcc:	6a 00                	push   $0x0
  801bce:	e8 7e f0 ff ff       	call   800c51 <sys_page_unmap>
  801bd3:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801bd6:	83 ec 08             	sub    $0x8,%esp
  801bd9:	ff 75 f0             	pushl  -0x10(%ebp)
  801bdc:	6a 00                	push   $0x0
  801bde:	e8 6e f0 ff ff       	call   800c51 <sys_page_unmap>
  801be3:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801be6:	83 ec 08             	sub    $0x8,%esp
  801be9:	ff 75 f4             	pushl  -0xc(%ebp)
  801bec:	6a 00                	push   $0x0
  801bee:	e8 5e f0 ff ff       	call   800c51 <sys_page_unmap>
  801bf3:	83 c4 10             	add    $0x10,%esp
  801bf6:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801bf8:	89 d0                	mov    %edx,%eax
  801bfa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bfd:	5b                   	pop    %ebx
  801bfe:	5e                   	pop    %esi
  801bff:	5d                   	pop    %ebp
  801c00:	c3                   	ret    

00801c01 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c01:	55                   	push   %ebp
  801c02:	89 e5                	mov    %esp,%ebp
  801c04:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c07:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c0a:	50                   	push   %eax
  801c0b:	ff 75 08             	pushl  0x8(%ebp)
  801c0e:	e8 30 f5 ff ff       	call   801143 <fd_lookup>
  801c13:	83 c4 10             	add    $0x10,%esp
  801c16:	85 c0                	test   %eax,%eax
  801c18:	78 18                	js     801c32 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c1a:	83 ec 0c             	sub    $0xc,%esp
  801c1d:	ff 75 f4             	pushl  -0xc(%ebp)
  801c20:	e8 b8 f4 ff ff       	call   8010dd <fd2data>
	return _pipeisclosed(fd, p);
  801c25:	89 c2                	mov    %eax,%edx
  801c27:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c2a:	e8 21 fd ff ff       	call   801950 <_pipeisclosed>
  801c2f:	83 c4 10             	add    $0x10,%esp
}
  801c32:	c9                   	leave  
  801c33:	c3                   	ret    

00801c34 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c34:	55                   	push   %ebp
  801c35:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c37:	b8 00 00 00 00       	mov    $0x0,%eax
  801c3c:	5d                   	pop    %ebp
  801c3d:	c3                   	ret    

00801c3e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c3e:	55                   	push   %ebp
  801c3f:	89 e5                	mov    %esp,%ebp
  801c41:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c44:	68 b2 27 80 00       	push   $0x8027b2
  801c49:	ff 75 0c             	pushl  0xc(%ebp)
  801c4c:	e8 78 eb ff ff       	call   8007c9 <strcpy>
	return 0;
}
  801c51:	b8 00 00 00 00       	mov    $0x0,%eax
  801c56:	c9                   	leave  
  801c57:	c3                   	ret    

00801c58 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c58:	55                   	push   %ebp
  801c59:	89 e5                	mov    %esp,%ebp
  801c5b:	57                   	push   %edi
  801c5c:	56                   	push   %esi
  801c5d:	53                   	push   %ebx
  801c5e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c64:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c69:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c6f:	eb 2d                	jmp    801c9e <devcons_write+0x46>
		m = n - tot;
  801c71:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c74:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801c76:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801c79:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801c7e:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c81:	83 ec 04             	sub    $0x4,%esp
  801c84:	53                   	push   %ebx
  801c85:	03 45 0c             	add    0xc(%ebp),%eax
  801c88:	50                   	push   %eax
  801c89:	57                   	push   %edi
  801c8a:	e8 cc ec ff ff       	call   80095b <memmove>
		sys_cputs(buf, m);
  801c8f:	83 c4 08             	add    $0x8,%esp
  801c92:	53                   	push   %ebx
  801c93:	57                   	push   %edi
  801c94:	e8 77 ee ff ff       	call   800b10 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c99:	01 de                	add    %ebx,%esi
  801c9b:	83 c4 10             	add    $0x10,%esp
  801c9e:	89 f0                	mov    %esi,%eax
  801ca0:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ca3:	72 cc                	jb     801c71 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ca5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ca8:	5b                   	pop    %ebx
  801ca9:	5e                   	pop    %esi
  801caa:	5f                   	pop    %edi
  801cab:	5d                   	pop    %ebp
  801cac:	c3                   	ret    

00801cad <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801cad:	55                   	push   %ebp
  801cae:	89 e5                	mov    %esp,%ebp
  801cb0:	83 ec 08             	sub    $0x8,%esp
  801cb3:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801cb8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801cbc:	74 2a                	je     801ce8 <devcons_read+0x3b>
  801cbe:	eb 05                	jmp    801cc5 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801cc0:	e8 e8 ee ff ff       	call   800bad <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801cc5:	e8 64 ee ff ff       	call   800b2e <sys_cgetc>
  801cca:	85 c0                	test   %eax,%eax
  801ccc:	74 f2                	je     801cc0 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801cce:	85 c0                	test   %eax,%eax
  801cd0:	78 16                	js     801ce8 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801cd2:	83 f8 04             	cmp    $0x4,%eax
  801cd5:	74 0c                	je     801ce3 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801cd7:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cda:	88 02                	mov    %al,(%edx)
	return 1;
  801cdc:	b8 01 00 00 00       	mov    $0x1,%eax
  801ce1:	eb 05                	jmp    801ce8 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ce3:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801ce8:	c9                   	leave  
  801ce9:	c3                   	ret    

00801cea <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801cea:	55                   	push   %ebp
  801ceb:	89 e5                	mov    %esp,%ebp
  801ced:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801cf0:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf3:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801cf6:	6a 01                	push   $0x1
  801cf8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801cfb:	50                   	push   %eax
  801cfc:	e8 0f ee ff ff       	call   800b10 <sys_cputs>
}
  801d01:	83 c4 10             	add    $0x10,%esp
  801d04:	c9                   	leave  
  801d05:	c3                   	ret    

00801d06 <getchar>:

int
getchar(void)
{
  801d06:	55                   	push   %ebp
  801d07:	89 e5                	mov    %esp,%ebp
  801d09:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801d0c:	6a 01                	push   $0x1
  801d0e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d11:	50                   	push   %eax
  801d12:	6a 00                	push   $0x0
  801d14:	e8 90 f6 ff ff       	call   8013a9 <read>
	if (r < 0)
  801d19:	83 c4 10             	add    $0x10,%esp
  801d1c:	85 c0                	test   %eax,%eax
  801d1e:	78 0f                	js     801d2f <getchar+0x29>
		return r;
	if (r < 1)
  801d20:	85 c0                	test   %eax,%eax
  801d22:	7e 06                	jle    801d2a <getchar+0x24>
		return -E_EOF;
	return c;
  801d24:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d28:	eb 05                	jmp    801d2f <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801d2a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801d2f:	c9                   	leave  
  801d30:	c3                   	ret    

00801d31 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801d31:	55                   	push   %ebp
  801d32:	89 e5                	mov    %esp,%ebp
  801d34:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d37:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d3a:	50                   	push   %eax
  801d3b:	ff 75 08             	pushl  0x8(%ebp)
  801d3e:	e8 00 f4 ff ff       	call   801143 <fd_lookup>
  801d43:	83 c4 10             	add    $0x10,%esp
  801d46:	85 c0                	test   %eax,%eax
  801d48:	78 11                	js     801d5b <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801d4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d4d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d53:	39 10                	cmp    %edx,(%eax)
  801d55:	0f 94 c0             	sete   %al
  801d58:	0f b6 c0             	movzbl %al,%eax
}
  801d5b:	c9                   	leave  
  801d5c:	c3                   	ret    

00801d5d <opencons>:

int
opencons(void)
{
  801d5d:	55                   	push   %ebp
  801d5e:	89 e5                	mov    %esp,%ebp
  801d60:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d63:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d66:	50                   	push   %eax
  801d67:	e8 88 f3 ff ff       	call   8010f4 <fd_alloc>
  801d6c:	83 c4 10             	add    $0x10,%esp
		return r;
  801d6f:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d71:	85 c0                	test   %eax,%eax
  801d73:	78 3e                	js     801db3 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d75:	83 ec 04             	sub    $0x4,%esp
  801d78:	68 07 04 00 00       	push   $0x407
  801d7d:	ff 75 f4             	pushl  -0xc(%ebp)
  801d80:	6a 00                	push   $0x0
  801d82:	e8 45 ee ff ff       	call   800bcc <sys_page_alloc>
  801d87:	83 c4 10             	add    $0x10,%esp
		return r;
  801d8a:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d8c:	85 c0                	test   %eax,%eax
  801d8e:	78 23                	js     801db3 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d90:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d96:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d99:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d9e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801da5:	83 ec 0c             	sub    $0xc,%esp
  801da8:	50                   	push   %eax
  801da9:	e8 1f f3 ff ff       	call   8010cd <fd2num>
  801dae:	89 c2                	mov    %eax,%edx
  801db0:	83 c4 10             	add    $0x10,%esp
}
  801db3:	89 d0                	mov    %edx,%eax
  801db5:	c9                   	leave  
  801db6:	c3                   	ret    

00801db7 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801db7:	55                   	push   %ebp
  801db8:	89 e5                	mov    %esp,%ebp
  801dba:	83 ec 08             	sub    $0x8,%esp
	int r;
	int ret;
	if (_pgfault_handler == 0) {
  801dbd:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801dc4:	75 36                	jne    801dfc <set_pgfault_handler+0x45>
		// First time through!
		// LAB 4: Your code here.
        
        	ret = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  801dc6:	a1 08 40 80 00       	mov    0x804008,%eax
  801dcb:	8b 40 48             	mov    0x48(%eax),%eax
  801dce:	83 ec 04             	sub    $0x4,%esp
  801dd1:	68 07 0e 00 00       	push   $0xe07
  801dd6:	68 00 f0 bf ee       	push   $0xeebff000
  801ddb:	50                   	push   %eax
  801ddc:	e8 eb ed ff ff       	call   800bcc <sys_page_alloc>
		if (ret < 0) {
  801de1:	83 c4 10             	add    $0x10,%esp
  801de4:	85 c0                	test   %eax,%eax
  801de6:	79 14                	jns    801dfc <set_pgfault_handler+0x45>
		    panic("Allocate user exception stack failed!\n");
  801de8:	83 ec 04             	sub    $0x4,%esp
  801deb:	68 c0 27 80 00       	push   $0x8027c0
  801df0:	6a 23                	push   $0x23
  801df2:	68 e8 27 80 00       	push   $0x8027e8
  801df7:	e8 51 e3 ff ff       	call   80014d <_panic>
		}
	}
	sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  801dfc:	a1 08 40 80 00       	mov    0x804008,%eax
  801e01:	8b 40 48             	mov    0x48(%eax),%eax
  801e04:	83 ec 08             	sub    $0x8,%esp
  801e07:	68 1f 1e 80 00       	push   $0x801e1f
  801e0c:	50                   	push   %eax
  801e0d:	e8 05 ef ff ff       	call   800d17 <sys_env_set_pgfault_upcall>
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e12:	8b 45 08             	mov    0x8(%ebp),%eax
  801e15:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801e1a:	83 c4 10             	add    $0x10,%esp
  801e1d:	c9                   	leave  
  801e1e:	c3                   	ret    

00801e1f <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e1f:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e20:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e25:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e27:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 0x28(%esp), %ebx  # trap-time eip
  801e2a:	8b 5c 24 28          	mov    0x28(%esp),%ebx
        subl $0x4, 0x30(%esp)  # trap-time esp minus 4
  801e2e:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax 
  801e33:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl %ebx, (%eax)      # trap-time esp store trap-time eip
  801e37:	89 18                	mov    %ebx,(%eax)
        addl $0x8, %esp
  801e39:	83 c4 08             	add    $0x8,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  801e3c:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  801e3d:	83 c4 04             	add    $0x4,%esp
        popfl
  801e40:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  801e41:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  801e42:	c3                   	ret    

00801e43 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e43:	55                   	push   %ebp
  801e44:	89 e5                	mov    %esp,%ebp
  801e46:	56                   	push   %esi
  801e47:	53                   	push   %ebx
  801e48:	8b 75 08             	mov    0x8(%ebp),%esi
  801e4b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e4e:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_recv not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  801e51:	85 c0                	test   %eax,%eax
  801e53:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801e58:	0f 44 c2             	cmove  %edx,%eax

    int r = sys_ipc_recv(pg);
  801e5b:	83 ec 0c             	sub    $0xc,%esp
  801e5e:	50                   	push   %eax
  801e5f:	e8 18 ef ff ff       	call   800d7c <sys_ipc_recv>
    int from_env = 0, perm = 0;
    if (r == 0) {
  801e64:	83 c4 10             	add    $0x10,%esp
  801e67:	85 c0                	test   %eax,%eax
  801e69:	75 10                	jne    801e7b <ipc_recv+0x38>
        from_env = thisenv->env_ipc_from;
  801e6b:	a1 08 40 80 00       	mov    0x804008,%eax
  801e70:	8b 48 74             	mov    0x74(%eax),%ecx
        perm = thisenv->env_ipc_perm;
  801e73:	8b 50 78             	mov    0x78(%eax),%edx
        r = thisenv->env_ipc_value;
  801e76:	8b 40 70             	mov    0x70(%eax),%eax
  801e79:	eb 0a                	jmp    801e85 <ipc_recv+0x42>
    } else {
        from_env = 0;
        perm = 0;
  801e7b:	ba 00 00 00 00       	mov    $0x0,%edx
    if (r == 0) {
        from_env = thisenv->env_ipc_from;
        perm = thisenv->env_ipc_perm;
        r = thisenv->env_ipc_value;
    } else {
        from_env = 0;
  801e80:	b9 00 00 00 00       	mov    $0x0,%ecx
        perm = 0;
    }

    if (from_env_store) *from_env_store = from_env;
  801e85:	85 f6                	test   %esi,%esi
  801e87:	74 02                	je     801e8b <ipc_recv+0x48>
  801e89:	89 0e                	mov    %ecx,(%esi)
    if (perm_store) *perm_store = perm;
  801e8b:	85 db                	test   %ebx,%ebx
  801e8d:	74 02                	je     801e91 <ipc_recv+0x4e>
  801e8f:	89 13                	mov    %edx,(%ebx)

    return r;
}
  801e91:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e94:	5b                   	pop    %ebx
  801e95:	5e                   	pop    %esi
  801e96:	5d                   	pop    %ebp
  801e97:	c3                   	ret    

00801e98 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e98:	55                   	push   %ebp
  801e99:	89 e5                	mov    %esp,%ebp
  801e9b:	57                   	push   %edi
  801e9c:	56                   	push   %esi
  801e9d:	53                   	push   %ebx
  801e9e:	83 ec 0c             	sub    $0xc,%esp
  801ea1:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ea4:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ea7:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  801eaa:	85 db                	test   %ebx,%ebx
  801eac:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801eb1:	0f 44 d8             	cmove  %eax,%ebx
  801eb4:	eb 1c                	jmp    801ed2 <ipc_send+0x3a>

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        if (ret != -E_IPC_NOT_RECV)
  801eb6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801eb9:	74 12                	je     801ecd <ipc_send+0x35>
            panic("ipc_send error %e", ret);
  801ebb:	50                   	push   %eax
  801ebc:	68 f6 27 80 00       	push   $0x8027f6
  801ec1:	6a 40                	push   $0x40
  801ec3:	68 08 28 80 00       	push   $0x802808
  801ec8:	e8 80 e2 ff ff       	call   80014d <_panic>
        sys_yield();
  801ecd:	e8 db ec ff ff       	call   800bad <sys_yield>
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801ed2:	ff 75 14             	pushl  0x14(%ebp)
  801ed5:	53                   	push   %ebx
  801ed6:	56                   	push   %esi
  801ed7:	57                   	push   %edi
  801ed8:	e8 7c ee ff ff       	call   800d59 <sys_ipc_try_send>
  801edd:	83 c4 10             	add    $0x10,%esp
  801ee0:	85 c0                	test   %eax,%eax
  801ee2:	75 d2                	jne    801eb6 <ipc_send+0x1e>
        if (ret != -E_IPC_NOT_RECV)
            panic("ipc_send error %e", ret);
        sys_yield();
    }
}
  801ee4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ee7:	5b                   	pop    %ebx
  801ee8:	5e                   	pop    %esi
  801ee9:	5f                   	pop    %edi
  801eea:	5d                   	pop    %ebp
  801eeb:	c3                   	ret    

00801eec <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801eec:	55                   	push   %ebp
  801eed:	89 e5                	mov    %esp,%ebp
  801eef:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ef2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ef7:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801efa:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f00:	8b 52 50             	mov    0x50(%edx),%edx
  801f03:	39 ca                	cmp    %ecx,%edx
  801f05:	75 0d                	jne    801f14 <ipc_find_env+0x28>
			return envs[i].env_id;
  801f07:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f0a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f0f:	8b 40 48             	mov    0x48(%eax),%eax
  801f12:	eb 0f                	jmp    801f23 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f14:	83 c0 01             	add    $0x1,%eax
  801f17:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f1c:	75 d9                	jne    801ef7 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f1e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f23:	5d                   	pop    %ebp
  801f24:	c3                   	ret    

00801f25 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f25:	55                   	push   %ebp
  801f26:	89 e5                	mov    %esp,%ebp
  801f28:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f2b:	89 d0                	mov    %edx,%eax
  801f2d:	c1 e8 16             	shr    $0x16,%eax
  801f30:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f37:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f3c:	f6 c1 01             	test   $0x1,%cl
  801f3f:	74 1d                	je     801f5e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f41:	c1 ea 0c             	shr    $0xc,%edx
  801f44:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f4b:	f6 c2 01             	test   $0x1,%dl
  801f4e:	74 0e                	je     801f5e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f50:	c1 ea 0c             	shr    $0xc,%edx
  801f53:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f5a:	ef 
  801f5b:	0f b7 c0             	movzwl %ax,%eax
}
  801f5e:	5d                   	pop    %ebp
  801f5f:	c3                   	ret    

00801f60 <__udivdi3>:
  801f60:	55                   	push   %ebp
  801f61:	57                   	push   %edi
  801f62:	56                   	push   %esi
  801f63:	53                   	push   %ebx
  801f64:	83 ec 1c             	sub    $0x1c,%esp
  801f67:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f6b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f6f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801f73:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f77:	85 f6                	test   %esi,%esi
  801f79:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f7d:	89 ca                	mov    %ecx,%edx
  801f7f:	89 f8                	mov    %edi,%eax
  801f81:	75 3d                	jne    801fc0 <__udivdi3+0x60>
  801f83:	39 cf                	cmp    %ecx,%edi
  801f85:	0f 87 c5 00 00 00    	ja     802050 <__udivdi3+0xf0>
  801f8b:	85 ff                	test   %edi,%edi
  801f8d:	89 fd                	mov    %edi,%ebp
  801f8f:	75 0b                	jne    801f9c <__udivdi3+0x3c>
  801f91:	b8 01 00 00 00       	mov    $0x1,%eax
  801f96:	31 d2                	xor    %edx,%edx
  801f98:	f7 f7                	div    %edi
  801f9a:	89 c5                	mov    %eax,%ebp
  801f9c:	89 c8                	mov    %ecx,%eax
  801f9e:	31 d2                	xor    %edx,%edx
  801fa0:	f7 f5                	div    %ebp
  801fa2:	89 c1                	mov    %eax,%ecx
  801fa4:	89 d8                	mov    %ebx,%eax
  801fa6:	89 cf                	mov    %ecx,%edi
  801fa8:	f7 f5                	div    %ebp
  801faa:	89 c3                	mov    %eax,%ebx
  801fac:	89 d8                	mov    %ebx,%eax
  801fae:	89 fa                	mov    %edi,%edx
  801fb0:	83 c4 1c             	add    $0x1c,%esp
  801fb3:	5b                   	pop    %ebx
  801fb4:	5e                   	pop    %esi
  801fb5:	5f                   	pop    %edi
  801fb6:	5d                   	pop    %ebp
  801fb7:	c3                   	ret    
  801fb8:	90                   	nop
  801fb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fc0:	39 ce                	cmp    %ecx,%esi
  801fc2:	77 74                	ja     802038 <__udivdi3+0xd8>
  801fc4:	0f bd fe             	bsr    %esi,%edi
  801fc7:	83 f7 1f             	xor    $0x1f,%edi
  801fca:	0f 84 98 00 00 00    	je     802068 <__udivdi3+0x108>
  801fd0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801fd5:	89 f9                	mov    %edi,%ecx
  801fd7:	89 c5                	mov    %eax,%ebp
  801fd9:	29 fb                	sub    %edi,%ebx
  801fdb:	d3 e6                	shl    %cl,%esi
  801fdd:	89 d9                	mov    %ebx,%ecx
  801fdf:	d3 ed                	shr    %cl,%ebp
  801fe1:	89 f9                	mov    %edi,%ecx
  801fe3:	d3 e0                	shl    %cl,%eax
  801fe5:	09 ee                	or     %ebp,%esi
  801fe7:	89 d9                	mov    %ebx,%ecx
  801fe9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fed:	89 d5                	mov    %edx,%ebp
  801fef:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ff3:	d3 ed                	shr    %cl,%ebp
  801ff5:	89 f9                	mov    %edi,%ecx
  801ff7:	d3 e2                	shl    %cl,%edx
  801ff9:	89 d9                	mov    %ebx,%ecx
  801ffb:	d3 e8                	shr    %cl,%eax
  801ffd:	09 c2                	or     %eax,%edx
  801fff:	89 d0                	mov    %edx,%eax
  802001:	89 ea                	mov    %ebp,%edx
  802003:	f7 f6                	div    %esi
  802005:	89 d5                	mov    %edx,%ebp
  802007:	89 c3                	mov    %eax,%ebx
  802009:	f7 64 24 0c          	mull   0xc(%esp)
  80200d:	39 d5                	cmp    %edx,%ebp
  80200f:	72 10                	jb     802021 <__udivdi3+0xc1>
  802011:	8b 74 24 08          	mov    0x8(%esp),%esi
  802015:	89 f9                	mov    %edi,%ecx
  802017:	d3 e6                	shl    %cl,%esi
  802019:	39 c6                	cmp    %eax,%esi
  80201b:	73 07                	jae    802024 <__udivdi3+0xc4>
  80201d:	39 d5                	cmp    %edx,%ebp
  80201f:	75 03                	jne    802024 <__udivdi3+0xc4>
  802021:	83 eb 01             	sub    $0x1,%ebx
  802024:	31 ff                	xor    %edi,%edi
  802026:	89 d8                	mov    %ebx,%eax
  802028:	89 fa                	mov    %edi,%edx
  80202a:	83 c4 1c             	add    $0x1c,%esp
  80202d:	5b                   	pop    %ebx
  80202e:	5e                   	pop    %esi
  80202f:	5f                   	pop    %edi
  802030:	5d                   	pop    %ebp
  802031:	c3                   	ret    
  802032:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802038:	31 ff                	xor    %edi,%edi
  80203a:	31 db                	xor    %ebx,%ebx
  80203c:	89 d8                	mov    %ebx,%eax
  80203e:	89 fa                	mov    %edi,%edx
  802040:	83 c4 1c             	add    $0x1c,%esp
  802043:	5b                   	pop    %ebx
  802044:	5e                   	pop    %esi
  802045:	5f                   	pop    %edi
  802046:	5d                   	pop    %ebp
  802047:	c3                   	ret    
  802048:	90                   	nop
  802049:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802050:	89 d8                	mov    %ebx,%eax
  802052:	f7 f7                	div    %edi
  802054:	31 ff                	xor    %edi,%edi
  802056:	89 c3                	mov    %eax,%ebx
  802058:	89 d8                	mov    %ebx,%eax
  80205a:	89 fa                	mov    %edi,%edx
  80205c:	83 c4 1c             	add    $0x1c,%esp
  80205f:	5b                   	pop    %ebx
  802060:	5e                   	pop    %esi
  802061:	5f                   	pop    %edi
  802062:	5d                   	pop    %ebp
  802063:	c3                   	ret    
  802064:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802068:	39 ce                	cmp    %ecx,%esi
  80206a:	72 0c                	jb     802078 <__udivdi3+0x118>
  80206c:	31 db                	xor    %ebx,%ebx
  80206e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802072:	0f 87 34 ff ff ff    	ja     801fac <__udivdi3+0x4c>
  802078:	bb 01 00 00 00       	mov    $0x1,%ebx
  80207d:	e9 2a ff ff ff       	jmp    801fac <__udivdi3+0x4c>
  802082:	66 90                	xchg   %ax,%ax
  802084:	66 90                	xchg   %ax,%ax
  802086:	66 90                	xchg   %ax,%ax
  802088:	66 90                	xchg   %ax,%ax
  80208a:	66 90                	xchg   %ax,%ax
  80208c:	66 90                	xchg   %ax,%ax
  80208e:	66 90                	xchg   %ax,%ax

00802090 <__umoddi3>:
  802090:	55                   	push   %ebp
  802091:	57                   	push   %edi
  802092:	56                   	push   %esi
  802093:	53                   	push   %ebx
  802094:	83 ec 1c             	sub    $0x1c,%esp
  802097:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80209b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80209f:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020a7:	85 d2                	test   %edx,%edx
  8020a9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8020ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020b1:	89 f3                	mov    %esi,%ebx
  8020b3:	89 3c 24             	mov    %edi,(%esp)
  8020b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020ba:	75 1c                	jne    8020d8 <__umoddi3+0x48>
  8020bc:	39 f7                	cmp    %esi,%edi
  8020be:	76 50                	jbe    802110 <__umoddi3+0x80>
  8020c0:	89 c8                	mov    %ecx,%eax
  8020c2:	89 f2                	mov    %esi,%edx
  8020c4:	f7 f7                	div    %edi
  8020c6:	89 d0                	mov    %edx,%eax
  8020c8:	31 d2                	xor    %edx,%edx
  8020ca:	83 c4 1c             	add    $0x1c,%esp
  8020cd:	5b                   	pop    %ebx
  8020ce:	5e                   	pop    %esi
  8020cf:	5f                   	pop    %edi
  8020d0:	5d                   	pop    %ebp
  8020d1:	c3                   	ret    
  8020d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020d8:	39 f2                	cmp    %esi,%edx
  8020da:	89 d0                	mov    %edx,%eax
  8020dc:	77 52                	ja     802130 <__umoddi3+0xa0>
  8020de:	0f bd ea             	bsr    %edx,%ebp
  8020e1:	83 f5 1f             	xor    $0x1f,%ebp
  8020e4:	75 5a                	jne    802140 <__umoddi3+0xb0>
  8020e6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8020ea:	0f 82 e0 00 00 00    	jb     8021d0 <__umoddi3+0x140>
  8020f0:	39 0c 24             	cmp    %ecx,(%esp)
  8020f3:	0f 86 d7 00 00 00    	jbe    8021d0 <__umoddi3+0x140>
  8020f9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020fd:	8b 54 24 04          	mov    0x4(%esp),%edx
  802101:	83 c4 1c             	add    $0x1c,%esp
  802104:	5b                   	pop    %ebx
  802105:	5e                   	pop    %esi
  802106:	5f                   	pop    %edi
  802107:	5d                   	pop    %ebp
  802108:	c3                   	ret    
  802109:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802110:	85 ff                	test   %edi,%edi
  802112:	89 fd                	mov    %edi,%ebp
  802114:	75 0b                	jne    802121 <__umoddi3+0x91>
  802116:	b8 01 00 00 00       	mov    $0x1,%eax
  80211b:	31 d2                	xor    %edx,%edx
  80211d:	f7 f7                	div    %edi
  80211f:	89 c5                	mov    %eax,%ebp
  802121:	89 f0                	mov    %esi,%eax
  802123:	31 d2                	xor    %edx,%edx
  802125:	f7 f5                	div    %ebp
  802127:	89 c8                	mov    %ecx,%eax
  802129:	f7 f5                	div    %ebp
  80212b:	89 d0                	mov    %edx,%eax
  80212d:	eb 99                	jmp    8020c8 <__umoddi3+0x38>
  80212f:	90                   	nop
  802130:	89 c8                	mov    %ecx,%eax
  802132:	89 f2                	mov    %esi,%edx
  802134:	83 c4 1c             	add    $0x1c,%esp
  802137:	5b                   	pop    %ebx
  802138:	5e                   	pop    %esi
  802139:	5f                   	pop    %edi
  80213a:	5d                   	pop    %ebp
  80213b:	c3                   	ret    
  80213c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802140:	8b 34 24             	mov    (%esp),%esi
  802143:	bf 20 00 00 00       	mov    $0x20,%edi
  802148:	89 e9                	mov    %ebp,%ecx
  80214a:	29 ef                	sub    %ebp,%edi
  80214c:	d3 e0                	shl    %cl,%eax
  80214e:	89 f9                	mov    %edi,%ecx
  802150:	89 f2                	mov    %esi,%edx
  802152:	d3 ea                	shr    %cl,%edx
  802154:	89 e9                	mov    %ebp,%ecx
  802156:	09 c2                	or     %eax,%edx
  802158:	89 d8                	mov    %ebx,%eax
  80215a:	89 14 24             	mov    %edx,(%esp)
  80215d:	89 f2                	mov    %esi,%edx
  80215f:	d3 e2                	shl    %cl,%edx
  802161:	89 f9                	mov    %edi,%ecx
  802163:	89 54 24 04          	mov    %edx,0x4(%esp)
  802167:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80216b:	d3 e8                	shr    %cl,%eax
  80216d:	89 e9                	mov    %ebp,%ecx
  80216f:	89 c6                	mov    %eax,%esi
  802171:	d3 e3                	shl    %cl,%ebx
  802173:	89 f9                	mov    %edi,%ecx
  802175:	89 d0                	mov    %edx,%eax
  802177:	d3 e8                	shr    %cl,%eax
  802179:	89 e9                	mov    %ebp,%ecx
  80217b:	09 d8                	or     %ebx,%eax
  80217d:	89 d3                	mov    %edx,%ebx
  80217f:	89 f2                	mov    %esi,%edx
  802181:	f7 34 24             	divl   (%esp)
  802184:	89 d6                	mov    %edx,%esi
  802186:	d3 e3                	shl    %cl,%ebx
  802188:	f7 64 24 04          	mull   0x4(%esp)
  80218c:	39 d6                	cmp    %edx,%esi
  80218e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802192:	89 d1                	mov    %edx,%ecx
  802194:	89 c3                	mov    %eax,%ebx
  802196:	72 08                	jb     8021a0 <__umoddi3+0x110>
  802198:	75 11                	jne    8021ab <__umoddi3+0x11b>
  80219a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80219e:	73 0b                	jae    8021ab <__umoddi3+0x11b>
  8021a0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8021a4:	1b 14 24             	sbb    (%esp),%edx
  8021a7:	89 d1                	mov    %edx,%ecx
  8021a9:	89 c3                	mov    %eax,%ebx
  8021ab:	8b 54 24 08          	mov    0x8(%esp),%edx
  8021af:	29 da                	sub    %ebx,%edx
  8021b1:	19 ce                	sbb    %ecx,%esi
  8021b3:	89 f9                	mov    %edi,%ecx
  8021b5:	89 f0                	mov    %esi,%eax
  8021b7:	d3 e0                	shl    %cl,%eax
  8021b9:	89 e9                	mov    %ebp,%ecx
  8021bb:	d3 ea                	shr    %cl,%edx
  8021bd:	89 e9                	mov    %ebp,%ecx
  8021bf:	d3 ee                	shr    %cl,%esi
  8021c1:	09 d0                	or     %edx,%eax
  8021c3:	89 f2                	mov    %esi,%edx
  8021c5:	83 c4 1c             	add    $0x1c,%esp
  8021c8:	5b                   	pop    %ebx
  8021c9:	5e                   	pop    %esi
  8021ca:	5f                   	pop    %edi
  8021cb:	5d                   	pop    %ebp
  8021cc:	c3                   	ret    
  8021cd:	8d 76 00             	lea    0x0(%esi),%esi
  8021d0:	29 f9                	sub    %edi,%ecx
  8021d2:	19 d6                	sbb    %edx,%esi
  8021d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021dc:	e9 18 ff ff ff       	jmp    8020f9 <__umoddi3+0x69>
