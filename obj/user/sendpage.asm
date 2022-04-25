
obj/user/sendpage.debug:     file format elf32-i386


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
  80002c:	e8 68 01 00 00       	call   800199 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#define TEMP_ADDR	((char*)0xa00000)
#define TEMP_ADDR_CHILD	((char*)0xb00000)

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	envid_t who;

	if ((who = fork()) == 0) {
  800039:	e8 b9 0f 00 00       	call   800ff7 <fork>
  80003e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800041:	85 c0                	test   %eax,%eax
  800043:	0f 85 9f 00 00 00    	jne    8000e8 <umain+0xb5>
		// Child
		ipc_recv(&who, TEMP_ADDR_CHILD, 0);
  800049:	83 ec 04             	sub    $0x4,%esp
  80004c:	6a 00                	push   $0x0
  80004e:	68 00 00 b0 00       	push   $0xb00000
  800053:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800056:	50                   	push   %eax
  800057:	e8 d7 10 00 00       	call   801133 <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  80005c:	83 c4 0c             	add    $0xc,%esp
  80005f:	68 00 00 b0 00       	push   $0xb00000
  800064:	ff 75 f4             	pushl  -0xc(%ebp)
  800067:	68 a0 22 80 00       	push   $0x8022a0
  80006c:	e8 1b 02 00 00       	call   80028c <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  800071:	83 c4 04             	add    $0x4,%esp
  800074:	ff 35 04 30 80 00    	pushl  0x803004
  80007a:	e8 77 07 00 00       	call   8007f6 <strlen>
  80007f:	83 c4 0c             	add    $0xc,%esp
  800082:	50                   	push   %eax
  800083:	ff 35 04 30 80 00    	pushl  0x803004
  800089:	68 00 00 b0 00       	push   $0xb00000
  80008e:	e8 6c 08 00 00       	call   8008ff <strncmp>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	85 c0                	test   %eax,%eax
  800098:	75 10                	jne    8000aa <umain+0x77>
			cprintf("child received correct message\n");
  80009a:	83 ec 0c             	sub    $0xc,%esp
  80009d:	68 b4 22 80 00       	push   $0x8022b4
  8000a2:	e8 e5 01 00 00       	call   80028c <cprintf>
  8000a7:	83 c4 10             	add    $0x10,%esp

		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  8000aa:	83 ec 0c             	sub    $0xc,%esp
  8000ad:	ff 35 00 30 80 00    	pushl  0x803000
  8000b3:	e8 3e 07 00 00       	call   8007f6 <strlen>
  8000b8:	83 c4 0c             	add    $0xc,%esp
  8000bb:	83 c0 01             	add    $0x1,%eax
  8000be:	50                   	push   %eax
  8000bf:	ff 35 00 30 80 00    	pushl  0x803000
  8000c5:	68 00 00 b0 00       	push   $0xb00000
  8000ca:	e8 5a 09 00 00       	call   800a29 <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  8000cf:	6a 07                	push   $0x7
  8000d1:	68 00 00 b0 00       	push   $0xb00000
  8000d6:	6a 00                	push   $0x0
  8000d8:	ff 75 f4             	pushl  -0xc(%ebp)
  8000db:	e8 a8 10 00 00       	call   801188 <ipc_send>
		return;
  8000e0:	83 c4 20             	add    $0x20,%esp
  8000e3:	e9 af 00 00 00       	jmp    800197 <umain+0x164>
	}

	// Parent
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  8000e8:	a1 04 40 80 00       	mov    0x804004,%eax
  8000ed:	8b 40 48             	mov    0x48(%eax),%eax
  8000f0:	83 ec 04             	sub    $0x4,%esp
  8000f3:	6a 07                	push   $0x7
  8000f5:	68 00 00 a0 00       	push   $0xa00000
  8000fa:	50                   	push   %eax
  8000fb:	e8 32 0b 00 00       	call   800c32 <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  800100:	83 c4 04             	add    $0x4,%esp
  800103:	ff 35 04 30 80 00    	pushl  0x803004
  800109:	e8 e8 06 00 00       	call   8007f6 <strlen>
  80010e:	83 c4 0c             	add    $0xc,%esp
  800111:	83 c0 01             	add    $0x1,%eax
  800114:	50                   	push   %eax
  800115:	ff 35 04 30 80 00    	pushl  0x803004
  80011b:	68 00 00 a0 00       	push   $0xa00000
  800120:	e8 04 09 00 00       	call   800a29 <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800125:	6a 07                	push   $0x7
  800127:	68 00 00 a0 00       	push   $0xa00000
  80012c:	6a 00                	push   $0x0
  80012e:	ff 75 f4             	pushl  -0xc(%ebp)
  800131:	e8 52 10 00 00       	call   801188 <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  800136:	83 c4 1c             	add    $0x1c,%esp
  800139:	6a 00                	push   $0x0
  80013b:	68 00 00 a0 00       	push   $0xa00000
  800140:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800143:	50                   	push   %eax
  800144:	e8 ea 0f 00 00       	call   801133 <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  800149:	83 c4 0c             	add    $0xc,%esp
  80014c:	68 00 00 a0 00       	push   $0xa00000
  800151:	ff 75 f4             	pushl  -0xc(%ebp)
  800154:	68 a0 22 80 00       	push   $0x8022a0
  800159:	e8 2e 01 00 00       	call   80028c <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  80015e:	83 c4 04             	add    $0x4,%esp
  800161:	ff 35 00 30 80 00    	pushl  0x803000
  800167:	e8 8a 06 00 00       	call   8007f6 <strlen>
  80016c:	83 c4 0c             	add    $0xc,%esp
  80016f:	50                   	push   %eax
  800170:	ff 35 00 30 80 00    	pushl  0x803000
  800176:	68 00 00 a0 00       	push   $0xa00000
  80017b:	e8 7f 07 00 00       	call   8008ff <strncmp>
  800180:	83 c4 10             	add    $0x10,%esp
  800183:	85 c0                	test   %eax,%eax
  800185:	75 10                	jne    800197 <umain+0x164>
		cprintf("parent received correct message\n");
  800187:	83 ec 0c             	sub    $0xc,%esp
  80018a:	68 d4 22 80 00       	push   $0x8022d4
  80018f:	e8 f8 00 00 00       	call   80028c <cprintf>
  800194:	83 c4 10             	add    $0x10,%esp
	return;
}
  800197:	c9                   	leave  
  800198:	c3                   	ret    

00800199 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800199:	55                   	push   %ebp
  80019a:	89 e5                	mov    %esp,%ebp
  80019c:	56                   	push   %esi
  80019d:	53                   	push   %ebx
  80019e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001a1:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  8001a4:	e8 4b 0a 00 00       	call   800bf4 <sys_getenvid>
  8001a9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001ae:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001b1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001b6:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001bb:	85 db                	test   %ebx,%ebx
  8001bd:	7e 07                	jle    8001c6 <libmain+0x2d>
		binaryname = argv[0];
  8001bf:	8b 06                	mov    (%esi),%eax
  8001c1:	a3 08 30 80 00       	mov    %eax,0x803008

	// call user main routine
	umain(argc, argv);
  8001c6:	83 ec 08             	sub    $0x8,%esp
  8001c9:	56                   	push   %esi
  8001ca:	53                   	push   %ebx
  8001cb:	e8 63 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8001d0:	e8 0a 00 00 00       	call   8001df <exit>
}
  8001d5:	83 c4 10             	add    $0x10,%esp
  8001d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001db:	5b                   	pop    %ebx
  8001dc:	5e                   	pop    %esi
  8001dd:	5d                   	pop    %ebp
  8001de:	c3                   	ret    

008001df <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001df:	55                   	push   %ebp
  8001e0:	89 e5                	mov    %esp,%ebp
  8001e2:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001e5:	e8 f6 11 00 00       	call   8013e0 <close_all>
	sys_env_destroy(0);
  8001ea:	83 ec 0c             	sub    $0xc,%esp
  8001ed:	6a 00                	push   $0x0
  8001ef:	e8 bf 09 00 00       	call   800bb3 <sys_env_destroy>
}
  8001f4:	83 c4 10             	add    $0x10,%esp
  8001f7:	c9                   	leave  
  8001f8:	c3                   	ret    

008001f9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001f9:	55                   	push   %ebp
  8001fa:	89 e5                	mov    %esp,%ebp
  8001fc:	53                   	push   %ebx
  8001fd:	83 ec 04             	sub    $0x4,%esp
  800200:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800203:	8b 13                	mov    (%ebx),%edx
  800205:	8d 42 01             	lea    0x1(%edx),%eax
  800208:	89 03                	mov    %eax,(%ebx)
  80020a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80020d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800211:	3d ff 00 00 00       	cmp    $0xff,%eax
  800216:	75 1a                	jne    800232 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800218:	83 ec 08             	sub    $0x8,%esp
  80021b:	68 ff 00 00 00       	push   $0xff
  800220:	8d 43 08             	lea    0x8(%ebx),%eax
  800223:	50                   	push   %eax
  800224:	e8 4d 09 00 00       	call   800b76 <sys_cputs>
		b->idx = 0;
  800229:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80022f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800232:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800236:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800239:	c9                   	leave  
  80023a:	c3                   	ret    

0080023b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80023b:	55                   	push   %ebp
  80023c:	89 e5                	mov    %esp,%ebp
  80023e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800244:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80024b:	00 00 00 
	b.cnt = 0;
  80024e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800255:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800258:	ff 75 0c             	pushl  0xc(%ebp)
  80025b:	ff 75 08             	pushl  0x8(%ebp)
  80025e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800264:	50                   	push   %eax
  800265:	68 f9 01 80 00       	push   $0x8001f9
  80026a:	e8 54 01 00 00       	call   8003c3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80026f:	83 c4 08             	add    $0x8,%esp
  800272:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800278:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80027e:	50                   	push   %eax
  80027f:	e8 f2 08 00 00       	call   800b76 <sys_cputs>

	return b.cnt;
}
  800284:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80028a:	c9                   	leave  
  80028b:	c3                   	ret    

0080028c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80028c:	55                   	push   %ebp
  80028d:	89 e5                	mov    %esp,%ebp
  80028f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800292:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800295:	50                   	push   %eax
  800296:	ff 75 08             	pushl  0x8(%ebp)
  800299:	e8 9d ff ff ff       	call   80023b <vcprintf>
	va_end(ap);

	return cnt;
}
  80029e:	c9                   	leave  
  80029f:	c3                   	ret    

008002a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	57                   	push   %edi
  8002a4:	56                   	push   %esi
  8002a5:	53                   	push   %ebx
  8002a6:	83 ec 1c             	sub    $0x1c,%esp
  8002a9:	89 c7                	mov    %eax,%edi
  8002ab:	89 d6                	mov    %edx,%esi
  8002ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002b6:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002b9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002bc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002c4:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002c7:	39 d3                	cmp    %edx,%ebx
  8002c9:	72 05                	jb     8002d0 <printnum+0x30>
  8002cb:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002ce:	77 45                	ja     800315 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d0:	83 ec 0c             	sub    $0xc,%esp
  8002d3:	ff 75 18             	pushl  0x18(%ebp)
  8002d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8002d9:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002dc:	53                   	push   %ebx
  8002dd:	ff 75 10             	pushl  0x10(%ebp)
  8002e0:	83 ec 08             	sub    $0x8,%esp
  8002e3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002e6:	ff 75 e0             	pushl  -0x20(%ebp)
  8002e9:	ff 75 dc             	pushl  -0x24(%ebp)
  8002ec:	ff 75 d8             	pushl  -0x28(%ebp)
  8002ef:	e8 1c 1d 00 00       	call   802010 <__udivdi3>
  8002f4:	83 c4 18             	add    $0x18,%esp
  8002f7:	52                   	push   %edx
  8002f8:	50                   	push   %eax
  8002f9:	89 f2                	mov    %esi,%edx
  8002fb:	89 f8                	mov    %edi,%eax
  8002fd:	e8 9e ff ff ff       	call   8002a0 <printnum>
  800302:	83 c4 20             	add    $0x20,%esp
  800305:	eb 18                	jmp    80031f <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800307:	83 ec 08             	sub    $0x8,%esp
  80030a:	56                   	push   %esi
  80030b:	ff 75 18             	pushl  0x18(%ebp)
  80030e:	ff d7                	call   *%edi
  800310:	83 c4 10             	add    $0x10,%esp
  800313:	eb 03                	jmp    800318 <printnum+0x78>
  800315:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800318:	83 eb 01             	sub    $0x1,%ebx
  80031b:	85 db                	test   %ebx,%ebx
  80031d:	7f e8                	jg     800307 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80031f:	83 ec 08             	sub    $0x8,%esp
  800322:	56                   	push   %esi
  800323:	83 ec 04             	sub    $0x4,%esp
  800326:	ff 75 e4             	pushl  -0x1c(%ebp)
  800329:	ff 75 e0             	pushl  -0x20(%ebp)
  80032c:	ff 75 dc             	pushl  -0x24(%ebp)
  80032f:	ff 75 d8             	pushl  -0x28(%ebp)
  800332:	e8 09 1e 00 00       	call   802140 <__umoddi3>
  800337:	83 c4 14             	add    $0x14,%esp
  80033a:	0f be 80 4c 23 80 00 	movsbl 0x80234c(%eax),%eax
  800341:	50                   	push   %eax
  800342:	ff d7                	call   *%edi
}
  800344:	83 c4 10             	add    $0x10,%esp
  800347:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034a:	5b                   	pop    %ebx
  80034b:	5e                   	pop    %esi
  80034c:	5f                   	pop    %edi
  80034d:	5d                   	pop    %ebp
  80034e:	c3                   	ret    

0080034f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80034f:	55                   	push   %ebp
  800350:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800352:	83 fa 01             	cmp    $0x1,%edx
  800355:	7e 0e                	jle    800365 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800357:	8b 10                	mov    (%eax),%edx
  800359:	8d 4a 08             	lea    0x8(%edx),%ecx
  80035c:	89 08                	mov    %ecx,(%eax)
  80035e:	8b 02                	mov    (%edx),%eax
  800360:	8b 52 04             	mov    0x4(%edx),%edx
  800363:	eb 22                	jmp    800387 <getuint+0x38>
	else if (lflag)
  800365:	85 d2                	test   %edx,%edx
  800367:	74 10                	je     800379 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800369:	8b 10                	mov    (%eax),%edx
  80036b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80036e:	89 08                	mov    %ecx,(%eax)
  800370:	8b 02                	mov    (%edx),%eax
  800372:	ba 00 00 00 00       	mov    $0x0,%edx
  800377:	eb 0e                	jmp    800387 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800379:	8b 10                	mov    (%eax),%edx
  80037b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80037e:	89 08                	mov    %ecx,(%eax)
  800380:	8b 02                	mov    (%edx),%eax
  800382:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800387:	5d                   	pop    %ebp
  800388:	c3                   	ret    

00800389 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800389:	55                   	push   %ebp
  80038a:	89 e5                	mov    %esp,%ebp
  80038c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80038f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800393:	8b 10                	mov    (%eax),%edx
  800395:	3b 50 04             	cmp    0x4(%eax),%edx
  800398:	73 0a                	jae    8003a4 <sprintputch+0x1b>
		*b->buf++ = ch;
  80039a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80039d:	89 08                	mov    %ecx,(%eax)
  80039f:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a2:	88 02                	mov    %al,(%edx)
}
  8003a4:	5d                   	pop    %ebp
  8003a5:	c3                   	ret    

008003a6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003a6:	55                   	push   %ebp
  8003a7:	89 e5                	mov    %esp,%ebp
  8003a9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003ac:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003af:	50                   	push   %eax
  8003b0:	ff 75 10             	pushl  0x10(%ebp)
  8003b3:	ff 75 0c             	pushl  0xc(%ebp)
  8003b6:	ff 75 08             	pushl  0x8(%ebp)
  8003b9:	e8 05 00 00 00       	call   8003c3 <vprintfmt>
	va_end(ap);
}
  8003be:	83 c4 10             	add    $0x10,%esp
  8003c1:	c9                   	leave  
  8003c2:	c3                   	ret    

008003c3 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003c3:	55                   	push   %ebp
  8003c4:	89 e5                	mov    %esp,%ebp
  8003c6:	57                   	push   %edi
  8003c7:	56                   	push   %esi
  8003c8:	53                   	push   %ebx
  8003c9:	83 ec 2c             	sub    $0x2c,%esp
  8003cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8003cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003d2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003d5:	eb 12                	jmp    8003e9 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003d7:	85 c0                	test   %eax,%eax
  8003d9:	0f 84 a7 03 00 00    	je     800786 <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
  8003df:	83 ec 08             	sub    $0x8,%esp
  8003e2:	53                   	push   %ebx
  8003e3:	50                   	push   %eax
  8003e4:	ff d6                	call   *%esi
  8003e6:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003e9:	83 c7 01             	add    $0x1,%edi
  8003ec:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003f0:	83 f8 25             	cmp    $0x25,%eax
  8003f3:	75 e2                	jne    8003d7 <vprintfmt+0x14>
  8003f5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003f9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800400:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800407:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80040e:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800415:	b9 00 00 00 00       	mov    $0x0,%ecx
  80041a:	eb 07                	jmp    800423 <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041c:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80041f:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800423:	8d 47 01             	lea    0x1(%edi),%eax
  800426:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800429:	0f b6 07             	movzbl (%edi),%eax
  80042c:	0f b6 d0             	movzbl %al,%edx
  80042f:	83 e8 23             	sub    $0x23,%eax
  800432:	3c 55                	cmp    $0x55,%al
  800434:	0f 87 31 03 00 00    	ja     80076b <vprintfmt+0x3a8>
  80043a:	0f b6 c0             	movzbl %al,%eax
  80043d:	ff 24 85 80 24 80 00 	jmp    *0x802480(,%eax,4)
  800444:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800447:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80044b:	eb d6                	jmp    800423 <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800450:	b8 00 00 00 00       	mov    $0x0,%eax
  800455:	89 75 08             	mov    %esi,0x8(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800458:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80045b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80045f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800462:	8d 72 d0             	lea    -0x30(%edx),%esi
  800465:	83 fe 09             	cmp    $0x9,%esi
  800468:	77 34                	ja     80049e <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80046a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80046d:	eb e9                	jmp    800458 <vprintfmt+0x95>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80046f:	8b 45 14             	mov    0x14(%ebp),%eax
  800472:	8d 50 04             	lea    0x4(%eax),%edx
  800475:	89 55 14             	mov    %edx,0x14(%ebp)
  800478:	8b 00                	mov    (%eax),%eax
  80047a:	89 45 cc             	mov    %eax,-0x34(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800480:	eb 22                	jmp    8004a4 <vprintfmt+0xe1>
  800482:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800485:	85 c0                	test   %eax,%eax
  800487:	0f 48 c1             	cmovs  %ecx,%eax
  80048a:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800490:	eb 91                	jmp    800423 <vprintfmt+0x60>
  800492:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800495:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80049c:	eb 85                	jmp    800423 <vprintfmt+0x60>
  80049e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8004a1:	8b 75 08             	mov    0x8(%ebp),%esi

		process_precision:
			if (width < 0)
  8004a4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004a8:	0f 89 75 ff ff ff    	jns    800423 <vprintfmt+0x60>
				width = precision, precision = -1;
  8004ae:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b4:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8004bb:	e9 63 ff ff ff       	jmp    800423 <vprintfmt+0x60>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004c0:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004c7:	e9 57 ff ff ff       	jmp    800423 <vprintfmt+0x60>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cf:	8d 50 04             	lea    0x4(%eax),%edx
  8004d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d5:	83 ec 08             	sub    $0x8,%esp
  8004d8:	53                   	push   %ebx
  8004d9:	ff 30                	pushl  (%eax)
  8004db:	ff d6                	call   *%esi
			break;
  8004dd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004e3:	e9 01 ff ff ff       	jmp    8003e9 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004eb:	8d 50 04             	lea    0x4(%eax),%edx
  8004ee:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f1:	8b 00                	mov    (%eax),%eax
  8004f3:	99                   	cltd   
  8004f4:	31 d0                	xor    %edx,%eax
  8004f6:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004f8:	83 f8 0f             	cmp    $0xf,%eax
  8004fb:	7f 0b                	jg     800508 <vprintfmt+0x145>
  8004fd:	8b 14 85 e0 25 80 00 	mov    0x8025e0(,%eax,4),%edx
  800504:	85 d2                	test   %edx,%edx
  800506:	75 18                	jne    800520 <vprintfmt+0x15d>
				printfmt(putch, putdat, "error %d", err);
  800508:	50                   	push   %eax
  800509:	68 64 23 80 00       	push   $0x802364
  80050e:	53                   	push   %ebx
  80050f:	56                   	push   %esi
  800510:	e8 91 fe ff ff       	call   8003a6 <printfmt>
  800515:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800518:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80051b:	e9 c9 fe ff ff       	jmp    8003e9 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800520:	52                   	push   %edx
  800521:	68 55 28 80 00       	push   $0x802855
  800526:	53                   	push   %ebx
  800527:	56                   	push   %esi
  800528:	e8 79 fe ff ff       	call   8003a6 <printfmt>
  80052d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800530:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800533:	e9 b1 fe ff ff       	jmp    8003e9 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800538:	8b 45 14             	mov    0x14(%ebp),%eax
  80053b:	8d 50 04             	lea    0x4(%eax),%edx
  80053e:	89 55 14             	mov    %edx,0x14(%ebp)
  800541:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800543:	85 ff                	test   %edi,%edi
  800545:	b8 5d 23 80 00       	mov    $0x80235d,%eax
  80054a:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80054d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800551:	0f 8e 94 00 00 00    	jle    8005eb <vprintfmt+0x228>
  800557:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80055b:	0f 84 98 00 00 00    	je     8005f9 <vprintfmt+0x236>
				for (width -= strnlen(p, precision); width > 0; width--)
  800561:	83 ec 08             	sub    $0x8,%esp
  800564:	ff 75 cc             	pushl  -0x34(%ebp)
  800567:	57                   	push   %edi
  800568:	e8 a1 02 00 00       	call   80080e <strnlen>
  80056d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800570:	29 c1                	sub    %eax,%ecx
  800572:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800575:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800578:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80057c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80057f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800582:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800584:	eb 0f                	jmp    800595 <vprintfmt+0x1d2>
					putch(padc, putdat);
  800586:	83 ec 08             	sub    $0x8,%esp
  800589:	53                   	push   %ebx
  80058a:	ff 75 e0             	pushl  -0x20(%ebp)
  80058d:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80058f:	83 ef 01             	sub    $0x1,%edi
  800592:	83 c4 10             	add    $0x10,%esp
  800595:	85 ff                	test   %edi,%edi
  800597:	7f ed                	jg     800586 <vprintfmt+0x1c3>
  800599:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80059c:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80059f:	85 c9                	test   %ecx,%ecx
  8005a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a6:	0f 49 c1             	cmovns %ecx,%eax
  8005a9:	29 c1                	sub    %eax,%ecx
  8005ab:	89 75 08             	mov    %esi,0x8(%ebp)
  8005ae:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8005b1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005b4:	89 cb                	mov    %ecx,%ebx
  8005b6:	eb 4d                	jmp    800605 <vprintfmt+0x242>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005b8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005bc:	74 1b                	je     8005d9 <vprintfmt+0x216>
  8005be:	0f be c0             	movsbl %al,%eax
  8005c1:	83 e8 20             	sub    $0x20,%eax
  8005c4:	83 f8 5e             	cmp    $0x5e,%eax
  8005c7:	76 10                	jbe    8005d9 <vprintfmt+0x216>
					putch('?', putdat);
  8005c9:	83 ec 08             	sub    $0x8,%esp
  8005cc:	ff 75 0c             	pushl  0xc(%ebp)
  8005cf:	6a 3f                	push   $0x3f
  8005d1:	ff 55 08             	call   *0x8(%ebp)
  8005d4:	83 c4 10             	add    $0x10,%esp
  8005d7:	eb 0d                	jmp    8005e6 <vprintfmt+0x223>
				else
					putch(ch, putdat);
  8005d9:	83 ec 08             	sub    $0x8,%esp
  8005dc:	ff 75 0c             	pushl  0xc(%ebp)
  8005df:	52                   	push   %edx
  8005e0:	ff 55 08             	call   *0x8(%ebp)
  8005e3:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005e6:	83 eb 01             	sub    $0x1,%ebx
  8005e9:	eb 1a                	jmp    800605 <vprintfmt+0x242>
  8005eb:	89 75 08             	mov    %esi,0x8(%ebp)
  8005ee:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8005f1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005f4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005f7:	eb 0c                	jmp    800605 <vprintfmt+0x242>
  8005f9:	89 75 08             	mov    %esi,0x8(%ebp)
  8005fc:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8005ff:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800602:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800605:	83 c7 01             	add    $0x1,%edi
  800608:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80060c:	0f be d0             	movsbl %al,%edx
  80060f:	85 d2                	test   %edx,%edx
  800611:	74 23                	je     800636 <vprintfmt+0x273>
  800613:	85 f6                	test   %esi,%esi
  800615:	78 a1                	js     8005b8 <vprintfmt+0x1f5>
  800617:	83 ee 01             	sub    $0x1,%esi
  80061a:	79 9c                	jns    8005b8 <vprintfmt+0x1f5>
  80061c:	89 df                	mov    %ebx,%edi
  80061e:	8b 75 08             	mov    0x8(%ebp),%esi
  800621:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800624:	eb 18                	jmp    80063e <vprintfmt+0x27b>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800626:	83 ec 08             	sub    $0x8,%esp
  800629:	53                   	push   %ebx
  80062a:	6a 20                	push   $0x20
  80062c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80062e:	83 ef 01             	sub    $0x1,%edi
  800631:	83 c4 10             	add    $0x10,%esp
  800634:	eb 08                	jmp    80063e <vprintfmt+0x27b>
  800636:	89 df                	mov    %ebx,%edi
  800638:	8b 75 08             	mov    0x8(%ebp),%esi
  80063b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80063e:	85 ff                	test   %edi,%edi
  800640:	7f e4                	jg     800626 <vprintfmt+0x263>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800642:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800645:	e9 9f fd ff ff       	jmp    8003e9 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80064a:	83 7d d0 01          	cmpl   $0x1,-0x30(%ebp)
  80064e:	7e 16                	jle    800666 <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  800650:	8b 45 14             	mov    0x14(%ebp),%eax
  800653:	8d 50 08             	lea    0x8(%eax),%edx
  800656:	89 55 14             	mov    %edx,0x14(%ebp)
  800659:	8b 50 04             	mov    0x4(%eax),%edx
  80065c:	8b 00                	mov    (%eax),%eax
  80065e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800661:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800664:	eb 34                	jmp    80069a <vprintfmt+0x2d7>
	else if (lflag)
  800666:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80066a:	74 18                	je     800684 <vprintfmt+0x2c1>
		return va_arg(*ap, long);
  80066c:	8b 45 14             	mov    0x14(%ebp),%eax
  80066f:	8d 50 04             	lea    0x4(%eax),%edx
  800672:	89 55 14             	mov    %edx,0x14(%ebp)
  800675:	8b 00                	mov    (%eax),%eax
  800677:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80067a:	89 c1                	mov    %eax,%ecx
  80067c:	c1 f9 1f             	sar    $0x1f,%ecx
  80067f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800682:	eb 16                	jmp    80069a <vprintfmt+0x2d7>
	else
		return va_arg(*ap, int);
  800684:	8b 45 14             	mov    0x14(%ebp),%eax
  800687:	8d 50 04             	lea    0x4(%eax),%edx
  80068a:	89 55 14             	mov    %edx,0x14(%ebp)
  80068d:	8b 00                	mov    (%eax),%eax
  80068f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800692:	89 c1                	mov    %eax,%ecx
  800694:	c1 f9 1f             	sar    $0x1f,%ecx
  800697:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80069a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80069d:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006a0:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006a5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006a9:	0f 89 88 00 00 00    	jns    800737 <vprintfmt+0x374>
				putch('-', putdat);
  8006af:	83 ec 08             	sub    $0x8,%esp
  8006b2:	53                   	push   %ebx
  8006b3:	6a 2d                	push   $0x2d
  8006b5:	ff d6                	call   *%esi
				num = -(long long) num;
  8006b7:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006ba:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006bd:	f7 d8                	neg    %eax
  8006bf:	83 d2 00             	adc    $0x0,%edx
  8006c2:	f7 da                	neg    %edx
  8006c4:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006c7:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006cc:	eb 69                	jmp    800737 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006ce:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8006d1:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d4:	e8 76 fc ff ff       	call   80034f <getuint>
			base = 10;
  8006d9:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006de:	eb 57                	jmp    800737 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  8006e0:	83 ec 08             	sub    $0x8,%esp
  8006e3:	53                   	push   %ebx
  8006e4:	6a 30                	push   $0x30
  8006e6:	ff d6                	call   *%esi
			num = getuint(&ap, lflag);
  8006e8:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8006eb:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ee:	e8 5c fc ff ff       	call   80034f <getuint>
			base = 8;
			goto number;
  8006f3:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  8006f6:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8006fb:	eb 3a                	jmp    800737 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  8006fd:	83 ec 08             	sub    $0x8,%esp
  800700:	53                   	push   %ebx
  800701:	6a 30                	push   $0x30
  800703:	ff d6                	call   *%esi
			putch('x', putdat);
  800705:	83 c4 08             	add    $0x8,%esp
  800708:	53                   	push   %ebx
  800709:	6a 78                	push   $0x78
  80070b:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80070d:	8b 45 14             	mov    0x14(%ebp),%eax
  800710:	8d 50 04             	lea    0x4(%eax),%edx
  800713:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800716:	8b 00                	mov    (%eax),%eax
  800718:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80071d:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800720:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800725:	eb 10                	jmp    800737 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800727:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80072a:	8d 45 14             	lea    0x14(%ebp),%eax
  80072d:	e8 1d fc ff ff       	call   80034f <getuint>
			base = 16;
  800732:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800737:	83 ec 0c             	sub    $0xc,%esp
  80073a:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80073e:	57                   	push   %edi
  80073f:	ff 75 e0             	pushl  -0x20(%ebp)
  800742:	51                   	push   %ecx
  800743:	52                   	push   %edx
  800744:	50                   	push   %eax
  800745:	89 da                	mov    %ebx,%edx
  800747:	89 f0                	mov    %esi,%eax
  800749:	e8 52 fb ff ff       	call   8002a0 <printnum>
			break;
  80074e:	83 c4 20             	add    $0x20,%esp
  800751:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800754:	e9 90 fc ff ff       	jmp    8003e9 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800759:	83 ec 08             	sub    $0x8,%esp
  80075c:	53                   	push   %ebx
  80075d:	52                   	push   %edx
  80075e:	ff d6                	call   *%esi
			break;
  800760:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800763:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800766:	e9 7e fc ff ff       	jmp    8003e9 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80076b:	83 ec 08             	sub    $0x8,%esp
  80076e:	53                   	push   %ebx
  80076f:	6a 25                	push   $0x25
  800771:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800773:	83 c4 10             	add    $0x10,%esp
  800776:	eb 03                	jmp    80077b <vprintfmt+0x3b8>
  800778:	83 ef 01             	sub    $0x1,%edi
  80077b:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80077f:	75 f7                	jne    800778 <vprintfmt+0x3b5>
  800781:	e9 63 fc ff ff       	jmp    8003e9 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800786:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800789:	5b                   	pop    %ebx
  80078a:	5e                   	pop    %esi
  80078b:	5f                   	pop    %edi
  80078c:	5d                   	pop    %ebp
  80078d:	c3                   	ret    

0080078e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80078e:	55                   	push   %ebp
  80078f:	89 e5                	mov    %esp,%ebp
  800791:	83 ec 18             	sub    $0x18,%esp
  800794:	8b 45 08             	mov    0x8(%ebp),%eax
  800797:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80079a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80079d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007a1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007a4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007ab:	85 c0                	test   %eax,%eax
  8007ad:	74 26                	je     8007d5 <vsnprintf+0x47>
  8007af:	85 d2                	test   %edx,%edx
  8007b1:	7e 22                	jle    8007d5 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007b3:	ff 75 14             	pushl  0x14(%ebp)
  8007b6:	ff 75 10             	pushl  0x10(%ebp)
  8007b9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007bc:	50                   	push   %eax
  8007bd:	68 89 03 80 00       	push   $0x800389
  8007c2:	e8 fc fb ff ff       	call   8003c3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007ca:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007d0:	83 c4 10             	add    $0x10,%esp
  8007d3:	eb 05                	jmp    8007da <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007d5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007da:	c9                   	leave  
  8007db:	c3                   	ret    

008007dc <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007dc:	55                   	push   %ebp
  8007dd:	89 e5                	mov    %esp,%ebp
  8007df:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007e2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007e5:	50                   	push   %eax
  8007e6:	ff 75 10             	pushl  0x10(%ebp)
  8007e9:	ff 75 0c             	pushl  0xc(%ebp)
  8007ec:	ff 75 08             	pushl  0x8(%ebp)
  8007ef:	e8 9a ff ff ff       	call   80078e <vsnprintf>
	va_end(ap);

	return rc;
}
  8007f4:	c9                   	leave  
  8007f5:	c3                   	ret    

008007f6 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007f6:	55                   	push   %ebp
  8007f7:	89 e5                	mov    %esp,%ebp
  8007f9:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800801:	eb 03                	jmp    800806 <strlen+0x10>
		n++;
  800803:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800806:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80080a:	75 f7                	jne    800803 <strlen+0xd>
		n++;
	return n;
}
  80080c:	5d                   	pop    %ebp
  80080d:	c3                   	ret    

0080080e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80080e:	55                   	push   %ebp
  80080f:	89 e5                	mov    %esp,%ebp
  800811:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800814:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800817:	ba 00 00 00 00       	mov    $0x0,%edx
  80081c:	eb 03                	jmp    800821 <strnlen+0x13>
		n++;
  80081e:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800821:	39 c2                	cmp    %eax,%edx
  800823:	74 08                	je     80082d <strnlen+0x1f>
  800825:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800829:	75 f3                	jne    80081e <strnlen+0x10>
  80082b:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80082d:	5d                   	pop    %ebp
  80082e:	c3                   	ret    

0080082f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80082f:	55                   	push   %ebp
  800830:	89 e5                	mov    %esp,%ebp
  800832:	53                   	push   %ebx
  800833:	8b 45 08             	mov    0x8(%ebp),%eax
  800836:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800839:	89 c2                	mov    %eax,%edx
  80083b:	83 c2 01             	add    $0x1,%edx
  80083e:	83 c1 01             	add    $0x1,%ecx
  800841:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800845:	88 5a ff             	mov    %bl,-0x1(%edx)
  800848:	84 db                	test   %bl,%bl
  80084a:	75 ef                	jne    80083b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80084c:	5b                   	pop    %ebx
  80084d:	5d                   	pop    %ebp
  80084e:	c3                   	ret    

0080084f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80084f:	55                   	push   %ebp
  800850:	89 e5                	mov    %esp,%ebp
  800852:	53                   	push   %ebx
  800853:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800856:	53                   	push   %ebx
  800857:	e8 9a ff ff ff       	call   8007f6 <strlen>
  80085c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80085f:	ff 75 0c             	pushl  0xc(%ebp)
  800862:	01 d8                	add    %ebx,%eax
  800864:	50                   	push   %eax
  800865:	e8 c5 ff ff ff       	call   80082f <strcpy>
	return dst;
}
  80086a:	89 d8                	mov    %ebx,%eax
  80086c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80086f:	c9                   	leave  
  800870:	c3                   	ret    

00800871 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800871:	55                   	push   %ebp
  800872:	89 e5                	mov    %esp,%ebp
  800874:	56                   	push   %esi
  800875:	53                   	push   %ebx
  800876:	8b 75 08             	mov    0x8(%ebp),%esi
  800879:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80087c:	89 f3                	mov    %esi,%ebx
  80087e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800881:	89 f2                	mov    %esi,%edx
  800883:	eb 0f                	jmp    800894 <strncpy+0x23>
		*dst++ = *src;
  800885:	83 c2 01             	add    $0x1,%edx
  800888:	0f b6 01             	movzbl (%ecx),%eax
  80088b:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80088e:	80 39 01             	cmpb   $0x1,(%ecx)
  800891:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800894:	39 da                	cmp    %ebx,%edx
  800896:	75 ed                	jne    800885 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800898:	89 f0                	mov    %esi,%eax
  80089a:	5b                   	pop    %ebx
  80089b:	5e                   	pop    %esi
  80089c:	5d                   	pop    %ebp
  80089d:	c3                   	ret    

0080089e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80089e:	55                   	push   %ebp
  80089f:	89 e5                	mov    %esp,%ebp
  8008a1:	56                   	push   %esi
  8008a2:	53                   	push   %ebx
  8008a3:	8b 75 08             	mov    0x8(%ebp),%esi
  8008a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008a9:	8b 55 10             	mov    0x10(%ebp),%edx
  8008ac:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008ae:	85 d2                	test   %edx,%edx
  8008b0:	74 21                	je     8008d3 <strlcpy+0x35>
  8008b2:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008b6:	89 f2                	mov    %esi,%edx
  8008b8:	eb 09                	jmp    8008c3 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008ba:	83 c2 01             	add    $0x1,%edx
  8008bd:	83 c1 01             	add    $0x1,%ecx
  8008c0:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008c3:	39 c2                	cmp    %eax,%edx
  8008c5:	74 09                	je     8008d0 <strlcpy+0x32>
  8008c7:	0f b6 19             	movzbl (%ecx),%ebx
  8008ca:	84 db                	test   %bl,%bl
  8008cc:	75 ec                	jne    8008ba <strlcpy+0x1c>
  8008ce:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008d0:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008d3:	29 f0                	sub    %esi,%eax
}
  8008d5:	5b                   	pop    %ebx
  8008d6:	5e                   	pop    %esi
  8008d7:	5d                   	pop    %ebp
  8008d8:	c3                   	ret    

008008d9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008d9:	55                   	push   %ebp
  8008da:	89 e5                	mov    %esp,%ebp
  8008dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008df:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008e2:	eb 06                	jmp    8008ea <strcmp+0x11>
		p++, q++;
  8008e4:	83 c1 01             	add    $0x1,%ecx
  8008e7:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008ea:	0f b6 01             	movzbl (%ecx),%eax
  8008ed:	84 c0                	test   %al,%al
  8008ef:	74 04                	je     8008f5 <strcmp+0x1c>
  8008f1:	3a 02                	cmp    (%edx),%al
  8008f3:	74 ef                	je     8008e4 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f5:	0f b6 c0             	movzbl %al,%eax
  8008f8:	0f b6 12             	movzbl (%edx),%edx
  8008fb:	29 d0                	sub    %edx,%eax
}
  8008fd:	5d                   	pop    %ebp
  8008fe:	c3                   	ret    

008008ff <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008ff:	55                   	push   %ebp
  800900:	89 e5                	mov    %esp,%ebp
  800902:	53                   	push   %ebx
  800903:	8b 45 08             	mov    0x8(%ebp),%eax
  800906:	8b 55 0c             	mov    0xc(%ebp),%edx
  800909:	89 c3                	mov    %eax,%ebx
  80090b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80090e:	eb 06                	jmp    800916 <strncmp+0x17>
		n--, p++, q++;
  800910:	83 c0 01             	add    $0x1,%eax
  800913:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800916:	39 d8                	cmp    %ebx,%eax
  800918:	74 15                	je     80092f <strncmp+0x30>
  80091a:	0f b6 08             	movzbl (%eax),%ecx
  80091d:	84 c9                	test   %cl,%cl
  80091f:	74 04                	je     800925 <strncmp+0x26>
  800921:	3a 0a                	cmp    (%edx),%cl
  800923:	74 eb                	je     800910 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800925:	0f b6 00             	movzbl (%eax),%eax
  800928:	0f b6 12             	movzbl (%edx),%edx
  80092b:	29 d0                	sub    %edx,%eax
  80092d:	eb 05                	jmp    800934 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80092f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800934:	5b                   	pop    %ebx
  800935:	5d                   	pop    %ebp
  800936:	c3                   	ret    

00800937 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800937:	55                   	push   %ebp
  800938:	89 e5                	mov    %esp,%ebp
  80093a:	8b 45 08             	mov    0x8(%ebp),%eax
  80093d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800941:	eb 07                	jmp    80094a <strchr+0x13>
		if (*s == c)
  800943:	38 ca                	cmp    %cl,%dl
  800945:	74 0f                	je     800956 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800947:	83 c0 01             	add    $0x1,%eax
  80094a:	0f b6 10             	movzbl (%eax),%edx
  80094d:	84 d2                	test   %dl,%dl
  80094f:	75 f2                	jne    800943 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800951:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800956:	5d                   	pop    %ebp
  800957:	c3                   	ret    

00800958 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800958:	55                   	push   %ebp
  800959:	89 e5                	mov    %esp,%ebp
  80095b:	8b 45 08             	mov    0x8(%ebp),%eax
  80095e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800962:	eb 03                	jmp    800967 <strfind+0xf>
  800964:	83 c0 01             	add    $0x1,%eax
  800967:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80096a:	38 ca                	cmp    %cl,%dl
  80096c:	74 04                	je     800972 <strfind+0x1a>
  80096e:	84 d2                	test   %dl,%dl
  800970:	75 f2                	jne    800964 <strfind+0xc>
			break;
	return (char *) s;
}
  800972:	5d                   	pop    %ebp
  800973:	c3                   	ret    

00800974 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800974:	55                   	push   %ebp
  800975:	89 e5                	mov    %esp,%ebp
  800977:	57                   	push   %edi
  800978:	56                   	push   %esi
  800979:	53                   	push   %ebx
  80097a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80097d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800980:	85 c9                	test   %ecx,%ecx
  800982:	74 36                	je     8009ba <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800984:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80098a:	75 28                	jne    8009b4 <memset+0x40>
  80098c:	f6 c1 03             	test   $0x3,%cl
  80098f:	75 23                	jne    8009b4 <memset+0x40>
		c &= 0xFF;
  800991:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800995:	89 d3                	mov    %edx,%ebx
  800997:	c1 e3 08             	shl    $0x8,%ebx
  80099a:	89 d6                	mov    %edx,%esi
  80099c:	c1 e6 18             	shl    $0x18,%esi
  80099f:	89 d0                	mov    %edx,%eax
  8009a1:	c1 e0 10             	shl    $0x10,%eax
  8009a4:	09 f0                	or     %esi,%eax
  8009a6:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009a8:	89 d8                	mov    %ebx,%eax
  8009aa:	09 d0                	or     %edx,%eax
  8009ac:	c1 e9 02             	shr    $0x2,%ecx
  8009af:	fc                   	cld    
  8009b0:	f3 ab                	rep stos %eax,%es:(%edi)
  8009b2:	eb 06                	jmp    8009ba <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b7:	fc                   	cld    
  8009b8:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009ba:	89 f8                	mov    %edi,%eax
  8009bc:	5b                   	pop    %ebx
  8009bd:	5e                   	pop    %esi
  8009be:	5f                   	pop    %edi
  8009bf:	5d                   	pop    %ebp
  8009c0:	c3                   	ret    

008009c1 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009c1:	55                   	push   %ebp
  8009c2:	89 e5                	mov    %esp,%ebp
  8009c4:	57                   	push   %edi
  8009c5:	56                   	push   %esi
  8009c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009cc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009cf:	39 c6                	cmp    %eax,%esi
  8009d1:	73 35                	jae    800a08 <memmove+0x47>
  8009d3:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009d6:	39 d0                	cmp    %edx,%eax
  8009d8:	73 2e                	jae    800a08 <memmove+0x47>
		s += n;
		d += n;
  8009da:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009dd:	89 d6                	mov    %edx,%esi
  8009df:	09 fe                	or     %edi,%esi
  8009e1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009e7:	75 13                	jne    8009fc <memmove+0x3b>
  8009e9:	f6 c1 03             	test   $0x3,%cl
  8009ec:	75 0e                	jne    8009fc <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009ee:	83 ef 04             	sub    $0x4,%edi
  8009f1:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009f4:	c1 e9 02             	shr    $0x2,%ecx
  8009f7:	fd                   	std    
  8009f8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009fa:	eb 09                	jmp    800a05 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009fc:	83 ef 01             	sub    $0x1,%edi
  8009ff:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a02:	fd                   	std    
  800a03:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a05:	fc                   	cld    
  800a06:	eb 1d                	jmp    800a25 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a08:	89 f2                	mov    %esi,%edx
  800a0a:	09 c2                	or     %eax,%edx
  800a0c:	f6 c2 03             	test   $0x3,%dl
  800a0f:	75 0f                	jne    800a20 <memmove+0x5f>
  800a11:	f6 c1 03             	test   $0x3,%cl
  800a14:	75 0a                	jne    800a20 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a16:	c1 e9 02             	shr    $0x2,%ecx
  800a19:	89 c7                	mov    %eax,%edi
  800a1b:	fc                   	cld    
  800a1c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a1e:	eb 05                	jmp    800a25 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a20:	89 c7                	mov    %eax,%edi
  800a22:	fc                   	cld    
  800a23:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a25:	5e                   	pop    %esi
  800a26:	5f                   	pop    %edi
  800a27:	5d                   	pop    %ebp
  800a28:	c3                   	ret    

00800a29 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a29:	55                   	push   %ebp
  800a2a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a2c:	ff 75 10             	pushl  0x10(%ebp)
  800a2f:	ff 75 0c             	pushl  0xc(%ebp)
  800a32:	ff 75 08             	pushl  0x8(%ebp)
  800a35:	e8 87 ff ff ff       	call   8009c1 <memmove>
}
  800a3a:	c9                   	leave  
  800a3b:	c3                   	ret    

00800a3c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a3c:	55                   	push   %ebp
  800a3d:	89 e5                	mov    %esp,%ebp
  800a3f:	56                   	push   %esi
  800a40:	53                   	push   %ebx
  800a41:	8b 45 08             	mov    0x8(%ebp),%eax
  800a44:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a47:	89 c6                	mov    %eax,%esi
  800a49:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a4c:	eb 1a                	jmp    800a68 <memcmp+0x2c>
		if (*s1 != *s2)
  800a4e:	0f b6 08             	movzbl (%eax),%ecx
  800a51:	0f b6 1a             	movzbl (%edx),%ebx
  800a54:	38 d9                	cmp    %bl,%cl
  800a56:	74 0a                	je     800a62 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a58:	0f b6 c1             	movzbl %cl,%eax
  800a5b:	0f b6 db             	movzbl %bl,%ebx
  800a5e:	29 d8                	sub    %ebx,%eax
  800a60:	eb 0f                	jmp    800a71 <memcmp+0x35>
		s1++, s2++;
  800a62:	83 c0 01             	add    $0x1,%eax
  800a65:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a68:	39 f0                	cmp    %esi,%eax
  800a6a:	75 e2                	jne    800a4e <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a6c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a71:	5b                   	pop    %ebx
  800a72:	5e                   	pop    %esi
  800a73:	5d                   	pop    %ebp
  800a74:	c3                   	ret    

00800a75 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a75:	55                   	push   %ebp
  800a76:	89 e5                	mov    %esp,%ebp
  800a78:	53                   	push   %ebx
  800a79:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a7c:	89 c1                	mov    %eax,%ecx
  800a7e:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a81:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a85:	eb 0a                	jmp    800a91 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a87:	0f b6 10             	movzbl (%eax),%edx
  800a8a:	39 da                	cmp    %ebx,%edx
  800a8c:	74 07                	je     800a95 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a8e:	83 c0 01             	add    $0x1,%eax
  800a91:	39 c8                	cmp    %ecx,%eax
  800a93:	72 f2                	jb     800a87 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a95:	5b                   	pop    %ebx
  800a96:	5d                   	pop    %ebp
  800a97:	c3                   	ret    

00800a98 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a98:	55                   	push   %ebp
  800a99:	89 e5                	mov    %esp,%ebp
  800a9b:	57                   	push   %edi
  800a9c:	56                   	push   %esi
  800a9d:	53                   	push   %ebx
  800a9e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aa1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aa4:	eb 03                	jmp    800aa9 <strtol+0x11>
		s++;
  800aa6:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aa9:	0f b6 01             	movzbl (%ecx),%eax
  800aac:	3c 20                	cmp    $0x20,%al
  800aae:	74 f6                	je     800aa6 <strtol+0xe>
  800ab0:	3c 09                	cmp    $0x9,%al
  800ab2:	74 f2                	je     800aa6 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ab4:	3c 2b                	cmp    $0x2b,%al
  800ab6:	75 0a                	jne    800ac2 <strtol+0x2a>
		s++;
  800ab8:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800abb:	bf 00 00 00 00       	mov    $0x0,%edi
  800ac0:	eb 11                	jmp    800ad3 <strtol+0x3b>
  800ac2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ac7:	3c 2d                	cmp    $0x2d,%al
  800ac9:	75 08                	jne    800ad3 <strtol+0x3b>
		s++, neg = 1;
  800acb:	83 c1 01             	add    $0x1,%ecx
  800ace:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ad3:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ad9:	75 15                	jne    800af0 <strtol+0x58>
  800adb:	80 39 30             	cmpb   $0x30,(%ecx)
  800ade:	75 10                	jne    800af0 <strtol+0x58>
  800ae0:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ae4:	75 7c                	jne    800b62 <strtol+0xca>
		s += 2, base = 16;
  800ae6:	83 c1 02             	add    $0x2,%ecx
  800ae9:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aee:	eb 16                	jmp    800b06 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800af0:	85 db                	test   %ebx,%ebx
  800af2:	75 12                	jne    800b06 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800af4:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800af9:	80 39 30             	cmpb   $0x30,(%ecx)
  800afc:	75 08                	jne    800b06 <strtol+0x6e>
		s++, base = 8;
  800afe:	83 c1 01             	add    $0x1,%ecx
  800b01:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b06:	b8 00 00 00 00       	mov    $0x0,%eax
  800b0b:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b0e:	0f b6 11             	movzbl (%ecx),%edx
  800b11:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b14:	89 f3                	mov    %esi,%ebx
  800b16:	80 fb 09             	cmp    $0x9,%bl
  800b19:	77 08                	ja     800b23 <strtol+0x8b>
			dig = *s - '0';
  800b1b:	0f be d2             	movsbl %dl,%edx
  800b1e:	83 ea 30             	sub    $0x30,%edx
  800b21:	eb 22                	jmp    800b45 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b23:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b26:	89 f3                	mov    %esi,%ebx
  800b28:	80 fb 19             	cmp    $0x19,%bl
  800b2b:	77 08                	ja     800b35 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b2d:	0f be d2             	movsbl %dl,%edx
  800b30:	83 ea 57             	sub    $0x57,%edx
  800b33:	eb 10                	jmp    800b45 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b35:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b38:	89 f3                	mov    %esi,%ebx
  800b3a:	80 fb 19             	cmp    $0x19,%bl
  800b3d:	77 16                	ja     800b55 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b3f:	0f be d2             	movsbl %dl,%edx
  800b42:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b45:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b48:	7d 0b                	jge    800b55 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b4a:	83 c1 01             	add    $0x1,%ecx
  800b4d:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b51:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b53:	eb b9                	jmp    800b0e <strtol+0x76>

	if (endptr)
  800b55:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b59:	74 0d                	je     800b68 <strtol+0xd0>
		*endptr = (char *) s;
  800b5b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b5e:	89 0e                	mov    %ecx,(%esi)
  800b60:	eb 06                	jmp    800b68 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b62:	85 db                	test   %ebx,%ebx
  800b64:	74 98                	je     800afe <strtol+0x66>
  800b66:	eb 9e                	jmp    800b06 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b68:	89 c2                	mov    %eax,%edx
  800b6a:	f7 da                	neg    %edx
  800b6c:	85 ff                	test   %edi,%edi
  800b6e:	0f 45 c2             	cmovne %edx,%eax
}
  800b71:	5b                   	pop    %ebx
  800b72:	5e                   	pop    %esi
  800b73:	5f                   	pop    %edi
  800b74:	5d                   	pop    %ebp
  800b75:	c3                   	ret    

00800b76 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b76:	55                   	push   %ebp
  800b77:	89 e5                	mov    %esp,%ebp
  800b79:	57                   	push   %edi
  800b7a:	56                   	push   %esi
  800b7b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b81:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b84:	8b 55 08             	mov    0x8(%ebp),%edx
  800b87:	89 c3                	mov    %eax,%ebx
  800b89:	89 c7                	mov    %eax,%edi
  800b8b:	89 c6                	mov    %eax,%esi
  800b8d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b8f:	5b                   	pop    %ebx
  800b90:	5e                   	pop    %esi
  800b91:	5f                   	pop    %edi
  800b92:	5d                   	pop    %ebp
  800b93:	c3                   	ret    

00800b94 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b94:	55                   	push   %ebp
  800b95:	89 e5                	mov    %esp,%ebp
  800b97:	57                   	push   %edi
  800b98:	56                   	push   %esi
  800b99:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9f:	b8 01 00 00 00       	mov    $0x1,%eax
  800ba4:	89 d1                	mov    %edx,%ecx
  800ba6:	89 d3                	mov    %edx,%ebx
  800ba8:	89 d7                	mov    %edx,%edi
  800baa:	89 d6                	mov    %edx,%esi
  800bac:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bae:	5b                   	pop    %ebx
  800baf:	5e                   	pop    %esi
  800bb0:	5f                   	pop    %edi
  800bb1:	5d                   	pop    %ebp
  800bb2:	c3                   	ret    

00800bb3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bb3:	55                   	push   %ebp
  800bb4:	89 e5                	mov    %esp,%ebp
  800bb6:	57                   	push   %edi
  800bb7:	56                   	push   %esi
  800bb8:	53                   	push   %ebx
  800bb9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bc1:	b8 03 00 00 00       	mov    $0x3,%eax
  800bc6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc9:	89 cb                	mov    %ecx,%ebx
  800bcb:	89 cf                	mov    %ecx,%edi
  800bcd:	89 ce                	mov    %ecx,%esi
  800bcf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bd1:	85 c0                	test   %eax,%eax
  800bd3:	7e 17                	jle    800bec <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd5:	83 ec 0c             	sub    $0xc,%esp
  800bd8:	50                   	push   %eax
  800bd9:	6a 03                	push   $0x3
  800bdb:	68 3f 26 80 00       	push   $0x80263f
  800be0:	6a 23                	push   $0x23
  800be2:	68 5c 26 80 00       	push   $0x80265c
  800be7:	e8 13 13 00 00       	call   801eff <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bef:	5b                   	pop    %ebx
  800bf0:	5e                   	pop    %esi
  800bf1:	5f                   	pop    %edi
  800bf2:	5d                   	pop    %ebp
  800bf3:	c3                   	ret    

00800bf4 <sys_getenvid>:

envid_t
sys_getenvid(void)
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
  800bff:	b8 02 00 00 00       	mov    $0x2,%eax
  800c04:	89 d1                	mov    %edx,%ecx
  800c06:	89 d3                	mov    %edx,%ebx
  800c08:	89 d7                	mov    %edx,%edi
  800c0a:	89 d6                	mov    %edx,%esi
  800c0c:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c0e:	5b                   	pop    %ebx
  800c0f:	5e                   	pop    %esi
  800c10:	5f                   	pop    %edi
  800c11:	5d                   	pop    %ebp
  800c12:	c3                   	ret    

00800c13 <sys_yield>:

void
sys_yield(void)
{
  800c13:	55                   	push   %ebp
  800c14:	89 e5                	mov    %esp,%ebp
  800c16:	57                   	push   %edi
  800c17:	56                   	push   %esi
  800c18:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c19:	ba 00 00 00 00       	mov    $0x0,%edx
  800c1e:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c23:	89 d1                	mov    %edx,%ecx
  800c25:	89 d3                	mov    %edx,%ebx
  800c27:	89 d7                	mov    %edx,%edi
  800c29:	89 d6                	mov    %edx,%esi
  800c2b:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c2d:	5b                   	pop    %ebx
  800c2e:	5e                   	pop    %esi
  800c2f:	5f                   	pop    %edi
  800c30:	5d                   	pop    %ebp
  800c31:	c3                   	ret    

00800c32 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c32:	55                   	push   %ebp
  800c33:	89 e5                	mov    %esp,%ebp
  800c35:	57                   	push   %edi
  800c36:	56                   	push   %esi
  800c37:	53                   	push   %ebx
  800c38:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3b:	be 00 00 00 00       	mov    $0x0,%esi
  800c40:	b8 04 00 00 00       	mov    $0x4,%eax
  800c45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c48:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c4e:	89 f7                	mov    %esi,%edi
  800c50:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c52:	85 c0                	test   %eax,%eax
  800c54:	7e 17                	jle    800c6d <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c56:	83 ec 0c             	sub    $0xc,%esp
  800c59:	50                   	push   %eax
  800c5a:	6a 04                	push   $0x4
  800c5c:	68 3f 26 80 00       	push   $0x80263f
  800c61:	6a 23                	push   $0x23
  800c63:	68 5c 26 80 00       	push   $0x80265c
  800c68:	e8 92 12 00 00       	call   801eff <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c6d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c70:	5b                   	pop    %ebx
  800c71:	5e                   	pop    %esi
  800c72:	5f                   	pop    %edi
  800c73:	5d                   	pop    %ebp
  800c74:	c3                   	ret    

00800c75 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c75:	55                   	push   %ebp
  800c76:	89 e5                	mov    %esp,%ebp
  800c78:	57                   	push   %edi
  800c79:	56                   	push   %esi
  800c7a:	53                   	push   %ebx
  800c7b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7e:	b8 05 00 00 00       	mov    $0x5,%eax
  800c83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c86:	8b 55 08             	mov    0x8(%ebp),%edx
  800c89:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c8c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c8f:	8b 75 18             	mov    0x18(%ebp),%esi
  800c92:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c94:	85 c0                	test   %eax,%eax
  800c96:	7e 17                	jle    800caf <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c98:	83 ec 0c             	sub    $0xc,%esp
  800c9b:	50                   	push   %eax
  800c9c:	6a 05                	push   $0x5
  800c9e:	68 3f 26 80 00       	push   $0x80263f
  800ca3:	6a 23                	push   $0x23
  800ca5:	68 5c 26 80 00       	push   $0x80265c
  800caa:	e8 50 12 00 00       	call   801eff <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800caf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb2:	5b                   	pop    %ebx
  800cb3:	5e                   	pop    %esi
  800cb4:	5f                   	pop    %edi
  800cb5:	5d                   	pop    %ebp
  800cb6:	c3                   	ret    

00800cb7 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cb7:	55                   	push   %ebp
  800cb8:	89 e5                	mov    %esp,%ebp
  800cba:	57                   	push   %edi
  800cbb:	56                   	push   %esi
  800cbc:	53                   	push   %ebx
  800cbd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc5:	b8 06 00 00 00       	mov    $0x6,%eax
  800cca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccd:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd0:	89 df                	mov    %ebx,%edi
  800cd2:	89 de                	mov    %ebx,%esi
  800cd4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cd6:	85 c0                	test   %eax,%eax
  800cd8:	7e 17                	jle    800cf1 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cda:	83 ec 0c             	sub    $0xc,%esp
  800cdd:	50                   	push   %eax
  800cde:	6a 06                	push   $0x6
  800ce0:	68 3f 26 80 00       	push   $0x80263f
  800ce5:	6a 23                	push   $0x23
  800ce7:	68 5c 26 80 00       	push   $0x80265c
  800cec:	e8 0e 12 00 00       	call   801eff <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cf1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf4:	5b                   	pop    %ebx
  800cf5:	5e                   	pop    %esi
  800cf6:	5f                   	pop    %edi
  800cf7:	5d                   	pop    %ebp
  800cf8:	c3                   	ret    

00800cf9 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cf9:	55                   	push   %ebp
  800cfa:	89 e5                	mov    %esp,%ebp
  800cfc:	57                   	push   %edi
  800cfd:	56                   	push   %esi
  800cfe:	53                   	push   %ebx
  800cff:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d02:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d07:	b8 08 00 00 00       	mov    $0x8,%eax
  800d0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d12:	89 df                	mov    %ebx,%edi
  800d14:	89 de                	mov    %ebx,%esi
  800d16:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d18:	85 c0                	test   %eax,%eax
  800d1a:	7e 17                	jle    800d33 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1c:	83 ec 0c             	sub    $0xc,%esp
  800d1f:	50                   	push   %eax
  800d20:	6a 08                	push   $0x8
  800d22:	68 3f 26 80 00       	push   $0x80263f
  800d27:	6a 23                	push   $0x23
  800d29:	68 5c 26 80 00       	push   $0x80265c
  800d2e:	e8 cc 11 00 00       	call   801eff <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d36:	5b                   	pop    %ebx
  800d37:	5e                   	pop    %esi
  800d38:	5f                   	pop    %edi
  800d39:	5d                   	pop    %ebp
  800d3a:	c3                   	ret    

00800d3b <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	57                   	push   %edi
  800d3f:	56                   	push   %esi
  800d40:	53                   	push   %ebx
  800d41:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d44:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d49:	b8 09 00 00 00       	mov    $0x9,%eax
  800d4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d51:	8b 55 08             	mov    0x8(%ebp),%edx
  800d54:	89 df                	mov    %ebx,%edi
  800d56:	89 de                	mov    %ebx,%esi
  800d58:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d5a:	85 c0                	test   %eax,%eax
  800d5c:	7e 17                	jle    800d75 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5e:	83 ec 0c             	sub    $0xc,%esp
  800d61:	50                   	push   %eax
  800d62:	6a 09                	push   $0x9
  800d64:	68 3f 26 80 00       	push   $0x80263f
  800d69:	6a 23                	push   $0x23
  800d6b:	68 5c 26 80 00       	push   $0x80265c
  800d70:	e8 8a 11 00 00       	call   801eff <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d75:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d78:	5b                   	pop    %ebx
  800d79:	5e                   	pop    %esi
  800d7a:	5f                   	pop    %edi
  800d7b:	5d                   	pop    %ebp
  800d7c:	c3                   	ret    

00800d7d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d7d:	55                   	push   %ebp
  800d7e:	89 e5                	mov    %esp,%ebp
  800d80:	57                   	push   %edi
  800d81:	56                   	push   %esi
  800d82:	53                   	push   %ebx
  800d83:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d86:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d8b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d93:	8b 55 08             	mov    0x8(%ebp),%edx
  800d96:	89 df                	mov    %ebx,%edi
  800d98:	89 de                	mov    %ebx,%esi
  800d9a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d9c:	85 c0                	test   %eax,%eax
  800d9e:	7e 17                	jle    800db7 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da0:	83 ec 0c             	sub    $0xc,%esp
  800da3:	50                   	push   %eax
  800da4:	6a 0a                	push   $0xa
  800da6:	68 3f 26 80 00       	push   $0x80263f
  800dab:	6a 23                	push   $0x23
  800dad:	68 5c 26 80 00       	push   $0x80265c
  800db2:	e8 48 11 00 00       	call   801eff <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800db7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dba:	5b                   	pop    %ebx
  800dbb:	5e                   	pop    %esi
  800dbc:	5f                   	pop    %edi
  800dbd:	5d                   	pop    %ebp
  800dbe:	c3                   	ret    

00800dbf <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dbf:	55                   	push   %ebp
  800dc0:	89 e5                	mov    %esp,%ebp
  800dc2:	57                   	push   %edi
  800dc3:	56                   	push   %esi
  800dc4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc5:	be 00 00 00 00       	mov    $0x0,%esi
  800dca:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dcf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dd8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ddb:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ddd:	5b                   	pop    %ebx
  800dde:	5e                   	pop    %esi
  800ddf:	5f                   	pop    %edi
  800de0:	5d                   	pop    %ebp
  800de1:	c3                   	ret    

00800de2 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
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
  800deb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800df0:	b8 0d 00 00 00       	mov    $0xd,%eax
  800df5:	8b 55 08             	mov    0x8(%ebp),%edx
  800df8:	89 cb                	mov    %ecx,%ebx
  800dfa:	89 cf                	mov    %ecx,%edi
  800dfc:	89 ce                	mov    %ecx,%esi
  800dfe:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e00:	85 c0                	test   %eax,%eax
  800e02:	7e 17                	jle    800e1b <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e04:	83 ec 0c             	sub    $0xc,%esp
  800e07:	50                   	push   %eax
  800e08:	6a 0d                	push   $0xd
  800e0a:	68 3f 26 80 00       	push   $0x80263f
  800e0f:	6a 23                	push   $0x23
  800e11:	68 5c 26 80 00       	push   $0x80265c
  800e16:	e8 e4 10 00 00       	call   801eff <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e1e:	5b                   	pop    %ebx
  800e1f:	5e                   	pop    %esi
  800e20:	5f                   	pop    %edi
  800e21:	5d                   	pop    %ebp
  800e22:	c3                   	ret    

00800e23 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800e23:	55                   	push   %ebp
  800e24:	89 e5                	mov    %esp,%ebp
  800e26:	53                   	push   %ebx
  800e27:	83 ec 04             	sub    $0x4,%esp
	int r;
	// LAB 4: Your code here.
    	pte_t *pte;
	int ret;
	// 用户空间的地址较低
	void *addr = (void *)(pn * PGSIZE);
  800e2a:	89 d3                	mov    %edx,%ebx
  800e2c:	c1 e3 0c             	shl    $0xc,%ebx
	if (uvpt[pn] & PTE_SHARE) {
  800e2f:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800e36:	f6 c5 04             	test   $0x4,%ch
  800e39:	74 2f                	je     800e6a <duppage+0x47>
		// cprintf("dup share page :%d\n", pn);
		if ((r = sys_page_map(0, addr, envid, addr, PTE_SYSCALL)) < 0)
  800e3b:	83 ec 0c             	sub    $0xc,%esp
  800e3e:	68 07 0e 00 00       	push   $0xe07
  800e43:	53                   	push   %ebx
  800e44:	50                   	push   %eax
  800e45:	53                   	push   %ebx
  800e46:	6a 00                	push   $0x0
  800e48:	e8 28 fe ff ff       	call   800c75 <sys_page_map>
  800e4d:	83 c4 20             	add    $0x20,%esp
  800e50:	85 c0                	test   %eax,%eax
  800e52:	0f 89 a0 00 00 00    	jns    800ef8 <duppage+0xd5>
			panic("duppage sys_page_map:%e", r);
  800e58:	50                   	push   %eax
  800e59:	68 6a 26 80 00       	push   $0x80266a
  800e5e:	6a 4d                	push   $0x4d
  800e60:	68 82 26 80 00       	push   $0x802682
  800e65:	e8 95 10 00 00       	call   801eff <_panic>
	} else if (uvpt[pn] & (PTE_W|PTE_COW)) {
  800e6a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e71:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800e77:	74 57                	je     800ed0 <duppage+0xad>
		if ((r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  800e79:	83 ec 0c             	sub    $0xc,%esp
  800e7c:	68 05 08 00 00       	push   $0x805
  800e81:	53                   	push   %ebx
  800e82:	50                   	push   %eax
  800e83:	53                   	push   %ebx
  800e84:	6a 00                	push   $0x0
  800e86:	e8 ea fd ff ff       	call   800c75 <sys_page_map>
  800e8b:	83 c4 20             	add    $0x20,%esp
  800e8e:	85 c0                	test   %eax,%eax
  800e90:	79 12                	jns    800ea4 <duppage+0x81>
			panic("sys_page_map COW:%e", r);
  800e92:	50                   	push   %eax
  800e93:	68 8d 26 80 00       	push   $0x80268d
  800e98:	6a 50                	push   $0x50
  800e9a:	68 82 26 80 00       	push   $0x802682
  800e9f:	e8 5b 10 00 00       	call   801eff <_panic>

		if ((r = sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  800ea4:	83 ec 0c             	sub    $0xc,%esp
  800ea7:	68 05 08 00 00       	push   $0x805
  800eac:	53                   	push   %ebx
  800ead:	6a 00                	push   $0x0
  800eaf:	53                   	push   %ebx
  800eb0:	6a 00                	push   $0x0
  800eb2:	e8 be fd ff ff       	call   800c75 <sys_page_map>
  800eb7:	83 c4 20             	add    $0x20,%esp
  800eba:	85 c0                	test   %eax,%eax
  800ebc:	79 3a                	jns    800ef8 <duppage+0xd5>
			panic("sys_page_map COW:%e", r);
  800ebe:	50                   	push   %eax
  800ebf:	68 8d 26 80 00       	push   $0x80268d
  800ec4:	6a 53                	push   $0x53
  800ec6:	68 82 26 80 00       	push   $0x802682
  800ecb:	e8 2f 10 00 00       	call   801eff <_panic>
	} else {
		if ((r = sys_page_map(0, addr, envid, addr, PTE_U|PTE_P)) < 0)
  800ed0:	83 ec 0c             	sub    $0xc,%esp
  800ed3:	6a 05                	push   $0x5
  800ed5:	53                   	push   %ebx
  800ed6:	50                   	push   %eax
  800ed7:	53                   	push   %ebx
  800ed8:	6a 00                	push   $0x0
  800eda:	e8 96 fd ff ff       	call   800c75 <sys_page_map>
  800edf:	83 c4 20             	add    $0x20,%esp
  800ee2:	85 c0                	test   %eax,%eax
  800ee4:	79 12                	jns    800ef8 <duppage+0xd5>
			panic("sys_page_map UP:%e", r);
  800ee6:	50                   	push   %eax
  800ee7:	68 a1 26 80 00       	push   $0x8026a1
  800eec:	6a 56                	push   $0x56
  800eee:	68 82 26 80 00       	push   $0x802682
  800ef3:	e8 07 10 00 00       	call   801eff <_panic>
	}
	return 0;
}
  800ef8:	b8 00 00 00 00       	mov    $0x0,%eax
  800efd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f00:	c9                   	leave  
  800f01:	c3                   	ret    

00800f02 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f02:	55                   	push   %ebp
  800f03:	89 e5                	mov    %esp,%ebp
  800f05:	56                   	push   %esi
  800f06:	53                   	push   %ebx
  800f07:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f0a:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (! ( (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  800f0c:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f10:	74 2d                	je     800f3f <pgfault+0x3d>
  800f12:	89 d8                	mov    %ebx,%eax
  800f14:	c1 e8 16             	shr    $0x16,%eax
  800f17:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f1e:	a8 01                	test   $0x1,%al
  800f20:	74 1d                	je     800f3f <pgfault+0x3d>
  800f22:	89 d8                	mov    %ebx,%eax
  800f24:	c1 e8 0c             	shr    $0xc,%eax
  800f27:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f2e:	f6 c2 01             	test   $0x1,%dl
  800f31:	74 0c                	je     800f3f <pgfault+0x3d>
  800f33:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f3a:	f6 c4 08             	test   $0x8,%ah
  800f3d:	75 14                	jne    800f53 <pgfault+0x51>
        	panic("Neither the fault is a write nor COW page. \n");
  800f3f:	83 ec 04             	sub    $0x4,%esp
  800f42:	68 20 27 80 00       	push   $0x802720
  800f47:	6a 1d                	push   $0x1d
  800f49:	68 82 26 80 00       	push   $0x802682
  800f4e:	e8 ac 0f 00 00       	call   801eff <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.
	

    	envid_t envid = sys_getenvid();
  800f53:	e8 9c fc ff ff       	call   800bf4 <sys_getenvid>
  800f58:	89 c6                	mov    %eax,%esi
    	// cprintf("pgfault: envid: %d\n", ENVX(envid));
    	// 临时页暂存
    	if ((r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P| PTE_W|PTE_U)) < 0)
  800f5a:	83 ec 04             	sub    $0x4,%esp
  800f5d:	6a 07                	push   $0x7
  800f5f:	68 00 f0 7f 00       	push   $0x7ff000
  800f64:	50                   	push   %eax
  800f65:	e8 c8 fc ff ff       	call   800c32 <sys_page_alloc>
  800f6a:	83 c4 10             	add    $0x10,%esp
  800f6d:	85 c0                	test   %eax,%eax
  800f6f:	79 12                	jns    800f83 <pgfault+0x81>
        	panic("pgfault: page allocation fault:%e\n", r);
  800f71:	50                   	push   %eax
  800f72:	68 50 27 80 00       	push   $0x802750
  800f77:	6a 2b                	push   $0x2b
  800f79:	68 82 26 80 00       	push   $0x802682
  800f7e:	e8 7c 0f 00 00       	call   801eff <_panic>
    	addr = ROUNDDOWN(addr, PGSIZE);
  800f83:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  800f89:	83 ec 04             	sub    $0x4,%esp
  800f8c:	68 00 10 00 00       	push   $0x1000
  800f91:	53                   	push   %ebx
  800f92:	68 00 f0 7f 00       	push   $0x7ff000
  800f97:	e8 8d fa ff ff       	call   800a29 <memcpy>
    	if ((r = sys_page_map(envid, (void *) PFTEMP, envid, addr , PTE_P|PTE_W|PTE_U)) < 0 )
  800f9c:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800fa3:	53                   	push   %ebx
  800fa4:	56                   	push   %esi
  800fa5:	68 00 f0 7f 00       	push   $0x7ff000
  800faa:	56                   	push   %esi
  800fab:	e8 c5 fc ff ff       	call   800c75 <sys_page_map>
  800fb0:	83 c4 20             	add    $0x20,%esp
  800fb3:	85 c0                	test   %eax,%eax
  800fb5:	79 12                	jns    800fc9 <pgfault+0xc7>
        	panic("pgfault: page map failed %e\n", r);
  800fb7:	50                   	push   %eax
  800fb8:	68 b4 26 80 00       	push   $0x8026b4
  800fbd:	6a 2f                	push   $0x2f
  800fbf:	68 82 26 80 00       	push   $0x802682
  800fc4:	e8 36 0f 00 00       	call   801eff <_panic>
    
    	if ((r = sys_page_unmap(envid, (void *) PFTEMP)) < 0)
  800fc9:	83 ec 08             	sub    $0x8,%esp
  800fcc:	68 00 f0 7f 00       	push   $0x7ff000
  800fd1:	56                   	push   %esi
  800fd2:	e8 e0 fc ff ff       	call   800cb7 <sys_page_unmap>
  800fd7:	83 c4 10             	add    $0x10,%esp
  800fda:	85 c0                	test   %eax,%eax
  800fdc:	79 12                	jns    800ff0 <pgfault+0xee>
        	panic("pgfault: page unmap failed %e\n", r);
  800fde:	50                   	push   %eax
  800fdf:	68 74 27 80 00       	push   $0x802774
  800fe4:	6a 32                	push   $0x32
  800fe6:	68 82 26 80 00       	push   $0x802682
  800feb:	e8 0f 0f 00 00       	call   801eff <_panic>
	//panic("pgfault not implemented");
}
  800ff0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ff3:	5b                   	pop    %ebx
  800ff4:	5e                   	pop    %esi
  800ff5:	5d                   	pop    %ebp
  800ff6:	c3                   	ret    

00800ff7 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ff7:	55                   	push   %ebp
  800ff8:	89 e5                	mov    %esp,%ebp
  800ffa:	56                   	push   %esi
  800ffb:	53                   	push   %ebx
  800ffc:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	set_pgfault_handler(pgfault);
  800fff:	68 02 0f 80 00       	push   $0x800f02
  801004:	e8 3c 0f 00 00       	call   801f45 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801009:	b8 07 00 00 00       	mov    $0x7,%eax
  80100e:	cd 30                	int    $0x30
  801010:	89 c3                	mov    %eax,%ebx

	envid_t envid = sys_exofork();
	uint8_t *addr;
	if (envid < 0)
  801012:	83 c4 10             	add    $0x10,%esp
  801015:	85 c0                	test   %eax,%eax
  801017:	79 12                	jns    80102b <fork+0x34>
		panic("sys_exofork:%e", envid);
  801019:	50                   	push   %eax
  80101a:	68 d1 26 80 00       	push   $0x8026d1
  80101f:	6a 75                	push   $0x75
  801021:	68 82 26 80 00       	push   $0x802682
  801026:	e8 d4 0e 00 00       	call   801eff <_panic>
  80102b:	89 c6                	mov    %eax,%esi
	if (envid == 0) {
  80102d:	85 c0                	test   %eax,%eax
  80102f:	75 21                	jne    801052 <fork+0x5b>
		thisenv = &envs[ENVX(sys_getenvid())];
  801031:	e8 be fb ff ff       	call   800bf4 <sys_getenvid>
  801036:	25 ff 03 00 00       	and    $0x3ff,%eax
  80103b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80103e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801043:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  801048:	b8 00 00 00 00       	mov    $0x0,%eax
  80104d:	e9 c0 00 00 00       	jmp    801112 <fork+0x11b>
	}

	for (addr = (uint8_t *)UTEXT; addr < (uint8_t *)USTACKTOP-PGSIZE; addr += PGSIZE) {
  801052:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  801059:	ba 00 00 80 00       	mov    $0x800000,%edx
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
  80105e:	89 d0                	mov    %edx,%eax
  801060:	c1 e8 16             	shr    $0x16,%eax
  801063:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80106a:	a8 01                	test   $0x1,%al
  80106c:	74 20                	je     80108e <fork+0x97>
  80106e:	c1 ea 0c             	shr    $0xc,%edx
  801071:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801078:	a8 01                	test   $0x1,%al
  80107a:	74 12                	je     80108e <fork+0x97>
				&& (uvpt[PGNUM(addr)] & PTE_U)) {
  80107c:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801083:	a8 04                	test   $0x4,%al
  801085:	74 07                	je     80108e <fork+0x97>
			duppage(envid, PGNUM(addr));
  801087:	89 f0                	mov    %esi,%eax
  801089:	e8 95 fd ff ff       	call   800e23 <duppage>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}

	for (addr = (uint8_t *)UTEXT; addr < (uint8_t *)USTACKTOP-PGSIZE; addr += PGSIZE) {
  80108e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801091:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
  801097:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80109a:	81 fa ff cf bf ee    	cmp    $0xeebfcfff,%edx
  8010a0:	76 bc                	jbe    80105e <fork+0x67>
				&& (uvpt[PGNUM(addr)] & PTE_U)) {
			duppage(envid, PGNUM(addr));
		}
	}

	duppage(envid, PGNUM(ROUNDDOWN(&addr, PGSIZE)));
  8010a2:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8010a5:	c1 ea 0c             	shr    $0xc,%edx
  8010a8:	89 d8                	mov    %ebx,%eax
  8010aa:	e8 74 fd ff ff       	call   800e23 <duppage>

	int r;
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)))
  8010af:	83 ec 04             	sub    $0x4,%esp
  8010b2:	6a 07                	push   $0x7
  8010b4:	68 00 f0 bf ee       	push   $0xeebff000
  8010b9:	53                   	push   %ebx
  8010ba:	e8 73 fb ff ff       	call   800c32 <sys_page_alloc>
  8010bf:	83 c4 10             	add    $0x10,%esp
  8010c2:	85 c0                	test   %eax,%eax
  8010c4:	74 15                	je     8010db <fork+0xe4>
		panic("sys_page_alloc:%e", r);
  8010c6:	50                   	push   %eax
  8010c7:	68 e0 26 80 00       	push   $0x8026e0
  8010cc:	68 86 00 00 00       	push   $0x86
  8010d1:	68 82 26 80 00       	push   $0x802682
  8010d6:	e8 24 0e 00 00       	call   801eff <_panic>

	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8010db:	83 ec 08             	sub    $0x8,%esp
  8010de:	68 ad 1f 80 00       	push   $0x801fad
  8010e3:	53                   	push   %ebx
  8010e4:	e8 94 fc ff ff       	call   800d7d <sys_env_set_pgfault_upcall>

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)))
  8010e9:	83 c4 08             	add    $0x8,%esp
  8010ec:	6a 02                	push   $0x2
  8010ee:	53                   	push   %ebx
  8010ef:	e8 05 fc ff ff       	call   800cf9 <sys_env_set_status>
  8010f4:	83 c4 10             	add    $0x10,%esp
  8010f7:	85 c0                	test   %eax,%eax
  8010f9:	74 15                	je     801110 <fork+0x119>
		panic("sys_env_set_status:%e", r);
  8010fb:	50                   	push   %eax
  8010fc:	68 f2 26 80 00       	push   $0x8026f2
  801101:	68 8c 00 00 00       	push   $0x8c
  801106:	68 82 26 80 00       	push   $0x802682
  80110b:	e8 ef 0d 00 00       	call   801eff <_panic>

	return envid;
  801110:	89 d8                	mov    %ebx,%eax
	    
}
  801112:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801115:	5b                   	pop    %ebx
  801116:	5e                   	pop    %esi
  801117:	5d                   	pop    %ebp
  801118:	c3                   	ret    

00801119 <sfork>:

// Challenge!
int
sfork(void)
{
  801119:	55                   	push   %ebp
  80111a:	89 e5                	mov    %esp,%ebp
  80111c:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80111f:	68 08 27 80 00       	push   $0x802708
  801124:	68 96 00 00 00       	push   $0x96
  801129:	68 82 26 80 00       	push   $0x802682
  80112e:	e8 cc 0d 00 00       	call   801eff <_panic>

00801133 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801133:	55                   	push   %ebp
  801134:	89 e5                	mov    %esp,%ebp
  801136:	56                   	push   %esi
  801137:	53                   	push   %ebx
  801138:	8b 75 08             	mov    0x8(%ebp),%esi
  80113b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80113e:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_recv not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  801141:	85 c0                	test   %eax,%eax
  801143:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801148:	0f 44 c2             	cmove  %edx,%eax

    int r = sys_ipc_recv(pg);
  80114b:	83 ec 0c             	sub    $0xc,%esp
  80114e:	50                   	push   %eax
  80114f:	e8 8e fc ff ff       	call   800de2 <sys_ipc_recv>
    int from_env = 0, perm = 0;
    if (r == 0) {
  801154:	83 c4 10             	add    $0x10,%esp
  801157:	85 c0                	test   %eax,%eax
  801159:	75 10                	jne    80116b <ipc_recv+0x38>
        from_env = thisenv->env_ipc_from;
  80115b:	a1 04 40 80 00       	mov    0x804004,%eax
  801160:	8b 48 74             	mov    0x74(%eax),%ecx
        perm = thisenv->env_ipc_perm;
  801163:	8b 50 78             	mov    0x78(%eax),%edx
        r = thisenv->env_ipc_value;
  801166:	8b 40 70             	mov    0x70(%eax),%eax
  801169:	eb 0a                	jmp    801175 <ipc_recv+0x42>
    } else {
        from_env = 0;
        perm = 0;
  80116b:	ba 00 00 00 00       	mov    $0x0,%edx
    if (r == 0) {
        from_env = thisenv->env_ipc_from;
        perm = thisenv->env_ipc_perm;
        r = thisenv->env_ipc_value;
    } else {
        from_env = 0;
  801170:	b9 00 00 00 00       	mov    $0x0,%ecx
        perm = 0;
    }

    if (from_env_store) *from_env_store = from_env;
  801175:	85 f6                	test   %esi,%esi
  801177:	74 02                	je     80117b <ipc_recv+0x48>
  801179:	89 0e                	mov    %ecx,(%esi)
    if (perm_store) *perm_store = perm;
  80117b:	85 db                	test   %ebx,%ebx
  80117d:	74 02                	je     801181 <ipc_recv+0x4e>
  80117f:	89 13                	mov    %edx,(%ebx)

    return r;
}
  801181:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801184:	5b                   	pop    %ebx
  801185:	5e                   	pop    %esi
  801186:	5d                   	pop    %ebp
  801187:	c3                   	ret    

00801188 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801188:	55                   	push   %ebp
  801189:	89 e5                	mov    %esp,%ebp
  80118b:	57                   	push   %edi
  80118c:	56                   	push   %esi
  80118d:	53                   	push   %ebx
  80118e:	83 ec 0c             	sub    $0xc,%esp
  801191:	8b 7d 08             	mov    0x8(%ebp),%edi
  801194:	8b 75 0c             	mov    0xc(%ebp),%esi
  801197:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  80119a:	85 db                	test   %ebx,%ebx
  80119c:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8011a1:	0f 44 d8             	cmove  %eax,%ebx
  8011a4:	eb 1c                	jmp    8011c2 <ipc_send+0x3a>

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        if (ret != -E_IPC_NOT_RECV)
  8011a6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8011a9:	74 12                	je     8011bd <ipc_send+0x35>
            panic("ipc_send error %e", ret);
  8011ab:	50                   	push   %eax
  8011ac:	68 93 27 80 00       	push   $0x802793
  8011b1:	6a 40                	push   $0x40
  8011b3:	68 a5 27 80 00       	push   $0x8027a5
  8011b8:	e8 42 0d 00 00       	call   801eff <_panic>
        sys_yield();
  8011bd:	e8 51 fa ff ff       	call   800c13 <sys_yield>
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  8011c2:	ff 75 14             	pushl  0x14(%ebp)
  8011c5:	53                   	push   %ebx
  8011c6:	56                   	push   %esi
  8011c7:	57                   	push   %edi
  8011c8:	e8 f2 fb ff ff       	call   800dbf <sys_ipc_try_send>
  8011cd:	83 c4 10             	add    $0x10,%esp
  8011d0:	85 c0                	test   %eax,%eax
  8011d2:	75 d2                	jne    8011a6 <ipc_send+0x1e>
        if (ret != -E_IPC_NOT_RECV)
            panic("ipc_send error %e", ret);
        sys_yield();
    }
}
  8011d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011d7:	5b                   	pop    %ebx
  8011d8:	5e                   	pop    %esi
  8011d9:	5f                   	pop    %edi
  8011da:	5d                   	pop    %ebp
  8011db:	c3                   	ret    

008011dc <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8011dc:	55                   	push   %ebp
  8011dd:	89 e5                	mov    %esp,%ebp
  8011df:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8011e2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8011e7:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8011ea:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8011f0:	8b 52 50             	mov    0x50(%edx),%edx
  8011f3:	39 ca                	cmp    %ecx,%edx
  8011f5:	75 0d                	jne    801204 <ipc_find_env+0x28>
			return envs[i].env_id;
  8011f7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011fa:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011ff:	8b 40 48             	mov    0x48(%eax),%eax
  801202:	eb 0f                	jmp    801213 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801204:	83 c0 01             	add    $0x1,%eax
  801207:	3d 00 04 00 00       	cmp    $0x400,%eax
  80120c:	75 d9                	jne    8011e7 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80120e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801213:	5d                   	pop    %ebp
  801214:	c3                   	ret    

00801215 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801215:	55                   	push   %ebp
  801216:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801218:	8b 45 08             	mov    0x8(%ebp),%eax
  80121b:	05 00 00 00 30       	add    $0x30000000,%eax
  801220:	c1 e8 0c             	shr    $0xc,%eax
}
  801223:	5d                   	pop    %ebp
  801224:	c3                   	ret    

00801225 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801225:	55                   	push   %ebp
  801226:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801228:	8b 45 08             	mov    0x8(%ebp),%eax
  80122b:	05 00 00 00 30       	add    $0x30000000,%eax
  801230:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801235:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80123a:	5d                   	pop    %ebp
  80123b:	c3                   	ret    

0080123c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80123c:	55                   	push   %ebp
  80123d:	89 e5                	mov    %esp,%ebp
  80123f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801242:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801247:	89 c2                	mov    %eax,%edx
  801249:	c1 ea 16             	shr    $0x16,%edx
  80124c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801253:	f6 c2 01             	test   $0x1,%dl
  801256:	74 11                	je     801269 <fd_alloc+0x2d>
  801258:	89 c2                	mov    %eax,%edx
  80125a:	c1 ea 0c             	shr    $0xc,%edx
  80125d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801264:	f6 c2 01             	test   $0x1,%dl
  801267:	75 09                	jne    801272 <fd_alloc+0x36>
			*fd_store = fd;
  801269:	89 01                	mov    %eax,(%ecx)
			return 0;
  80126b:	b8 00 00 00 00       	mov    $0x0,%eax
  801270:	eb 17                	jmp    801289 <fd_alloc+0x4d>
  801272:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801277:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80127c:	75 c9                	jne    801247 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80127e:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801284:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801289:	5d                   	pop    %ebp
  80128a:	c3                   	ret    

0080128b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80128b:	55                   	push   %ebp
  80128c:	89 e5                	mov    %esp,%ebp
  80128e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801291:	83 f8 1f             	cmp    $0x1f,%eax
  801294:	77 36                	ja     8012cc <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801296:	c1 e0 0c             	shl    $0xc,%eax
  801299:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80129e:	89 c2                	mov    %eax,%edx
  8012a0:	c1 ea 16             	shr    $0x16,%edx
  8012a3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012aa:	f6 c2 01             	test   $0x1,%dl
  8012ad:	74 24                	je     8012d3 <fd_lookup+0x48>
  8012af:	89 c2                	mov    %eax,%edx
  8012b1:	c1 ea 0c             	shr    $0xc,%edx
  8012b4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012bb:	f6 c2 01             	test   $0x1,%dl
  8012be:	74 1a                	je     8012da <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012c0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012c3:	89 02                	mov    %eax,(%edx)
	return 0;
  8012c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8012ca:	eb 13                	jmp    8012df <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012cc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012d1:	eb 0c                	jmp    8012df <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012d8:	eb 05                	jmp    8012df <fd_lookup+0x54>
  8012da:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012df:	5d                   	pop    %ebp
  8012e0:	c3                   	ret    

008012e1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012e1:	55                   	push   %ebp
  8012e2:	89 e5                	mov    %esp,%ebp
  8012e4:	83 ec 08             	sub    $0x8,%esp
  8012e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012ea:	ba 2c 28 80 00       	mov    $0x80282c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012ef:	eb 13                	jmp    801304 <dev_lookup+0x23>
  8012f1:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8012f4:	39 08                	cmp    %ecx,(%eax)
  8012f6:	75 0c                	jne    801304 <dev_lookup+0x23>
			*dev = devtab[i];
  8012f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012fb:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012fd:	b8 00 00 00 00       	mov    $0x0,%eax
  801302:	eb 2e                	jmp    801332 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801304:	8b 02                	mov    (%edx),%eax
  801306:	85 c0                	test   %eax,%eax
  801308:	75 e7                	jne    8012f1 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80130a:	a1 04 40 80 00       	mov    0x804004,%eax
  80130f:	8b 40 48             	mov    0x48(%eax),%eax
  801312:	83 ec 04             	sub    $0x4,%esp
  801315:	51                   	push   %ecx
  801316:	50                   	push   %eax
  801317:	68 b0 27 80 00       	push   $0x8027b0
  80131c:	e8 6b ef ff ff       	call   80028c <cprintf>
	*dev = 0;
  801321:	8b 45 0c             	mov    0xc(%ebp),%eax
  801324:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80132a:	83 c4 10             	add    $0x10,%esp
  80132d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801332:	c9                   	leave  
  801333:	c3                   	ret    

00801334 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801334:	55                   	push   %ebp
  801335:	89 e5                	mov    %esp,%ebp
  801337:	56                   	push   %esi
  801338:	53                   	push   %ebx
  801339:	83 ec 10             	sub    $0x10,%esp
  80133c:	8b 75 08             	mov    0x8(%ebp),%esi
  80133f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801342:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801345:	50                   	push   %eax
  801346:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80134c:	c1 e8 0c             	shr    $0xc,%eax
  80134f:	50                   	push   %eax
  801350:	e8 36 ff ff ff       	call   80128b <fd_lookup>
  801355:	83 c4 08             	add    $0x8,%esp
  801358:	85 c0                	test   %eax,%eax
  80135a:	78 05                	js     801361 <fd_close+0x2d>
	    || fd != fd2)
  80135c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80135f:	74 0c                	je     80136d <fd_close+0x39>
		return (must_exist ? r : 0);
  801361:	84 db                	test   %bl,%bl
  801363:	ba 00 00 00 00       	mov    $0x0,%edx
  801368:	0f 44 c2             	cmove  %edx,%eax
  80136b:	eb 41                	jmp    8013ae <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80136d:	83 ec 08             	sub    $0x8,%esp
  801370:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801373:	50                   	push   %eax
  801374:	ff 36                	pushl  (%esi)
  801376:	e8 66 ff ff ff       	call   8012e1 <dev_lookup>
  80137b:	89 c3                	mov    %eax,%ebx
  80137d:	83 c4 10             	add    $0x10,%esp
  801380:	85 c0                	test   %eax,%eax
  801382:	78 1a                	js     80139e <fd_close+0x6a>
		if (dev->dev_close)
  801384:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801387:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80138a:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80138f:	85 c0                	test   %eax,%eax
  801391:	74 0b                	je     80139e <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801393:	83 ec 0c             	sub    $0xc,%esp
  801396:	56                   	push   %esi
  801397:	ff d0                	call   *%eax
  801399:	89 c3                	mov    %eax,%ebx
  80139b:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80139e:	83 ec 08             	sub    $0x8,%esp
  8013a1:	56                   	push   %esi
  8013a2:	6a 00                	push   $0x0
  8013a4:	e8 0e f9 ff ff       	call   800cb7 <sys_page_unmap>
	return r;
  8013a9:	83 c4 10             	add    $0x10,%esp
  8013ac:	89 d8                	mov    %ebx,%eax
}
  8013ae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013b1:	5b                   	pop    %ebx
  8013b2:	5e                   	pop    %esi
  8013b3:	5d                   	pop    %ebp
  8013b4:	c3                   	ret    

008013b5 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013b5:	55                   	push   %ebp
  8013b6:	89 e5                	mov    %esp,%ebp
  8013b8:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013be:	50                   	push   %eax
  8013bf:	ff 75 08             	pushl  0x8(%ebp)
  8013c2:	e8 c4 fe ff ff       	call   80128b <fd_lookup>
  8013c7:	83 c4 08             	add    $0x8,%esp
  8013ca:	85 c0                	test   %eax,%eax
  8013cc:	78 10                	js     8013de <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8013ce:	83 ec 08             	sub    $0x8,%esp
  8013d1:	6a 01                	push   $0x1
  8013d3:	ff 75 f4             	pushl  -0xc(%ebp)
  8013d6:	e8 59 ff ff ff       	call   801334 <fd_close>
  8013db:	83 c4 10             	add    $0x10,%esp
}
  8013de:	c9                   	leave  
  8013df:	c3                   	ret    

008013e0 <close_all>:

void
close_all(void)
{
  8013e0:	55                   	push   %ebp
  8013e1:	89 e5                	mov    %esp,%ebp
  8013e3:	53                   	push   %ebx
  8013e4:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013e7:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013ec:	83 ec 0c             	sub    $0xc,%esp
  8013ef:	53                   	push   %ebx
  8013f0:	e8 c0 ff ff ff       	call   8013b5 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013f5:	83 c3 01             	add    $0x1,%ebx
  8013f8:	83 c4 10             	add    $0x10,%esp
  8013fb:	83 fb 20             	cmp    $0x20,%ebx
  8013fe:	75 ec                	jne    8013ec <close_all+0xc>
		close(i);
}
  801400:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801403:	c9                   	leave  
  801404:	c3                   	ret    

00801405 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801405:	55                   	push   %ebp
  801406:	89 e5                	mov    %esp,%ebp
  801408:	57                   	push   %edi
  801409:	56                   	push   %esi
  80140a:	53                   	push   %ebx
  80140b:	83 ec 2c             	sub    $0x2c,%esp
  80140e:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801411:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801414:	50                   	push   %eax
  801415:	ff 75 08             	pushl  0x8(%ebp)
  801418:	e8 6e fe ff ff       	call   80128b <fd_lookup>
  80141d:	83 c4 08             	add    $0x8,%esp
  801420:	85 c0                	test   %eax,%eax
  801422:	0f 88 c1 00 00 00    	js     8014e9 <dup+0xe4>
		return r;
	close(newfdnum);
  801428:	83 ec 0c             	sub    $0xc,%esp
  80142b:	56                   	push   %esi
  80142c:	e8 84 ff ff ff       	call   8013b5 <close>

	newfd = INDEX2FD(newfdnum);
  801431:	89 f3                	mov    %esi,%ebx
  801433:	c1 e3 0c             	shl    $0xc,%ebx
  801436:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80143c:	83 c4 04             	add    $0x4,%esp
  80143f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801442:	e8 de fd ff ff       	call   801225 <fd2data>
  801447:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801449:	89 1c 24             	mov    %ebx,(%esp)
  80144c:	e8 d4 fd ff ff       	call   801225 <fd2data>
  801451:	83 c4 10             	add    $0x10,%esp
  801454:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801457:	89 f8                	mov    %edi,%eax
  801459:	c1 e8 16             	shr    $0x16,%eax
  80145c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801463:	a8 01                	test   $0x1,%al
  801465:	74 37                	je     80149e <dup+0x99>
  801467:	89 f8                	mov    %edi,%eax
  801469:	c1 e8 0c             	shr    $0xc,%eax
  80146c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801473:	f6 c2 01             	test   $0x1,%dl
  801476:	74 26                	je     80149e <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801478:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80147f:	83 ec 0c             	sub    $0xc,%esp
  801482:	25 07 0e 00 00       	and    $0xe07,%eax
  801487:	50                   	push   %eax
  801488:	ff 75 d4             	pushl  -0x2c(%ebp)
  80148b:	6a 00                	push   $0x0
  80148d:	57                   	push   %edi
  80148e:	6a 00                	push   $0x0
  801490:	e8 e0 f7 ff ff       	call   800c75 <sys_page_map>
  801495:	89 c7                	mov    %eax,%edi
  801497:	83 c4 20             	add    $0x20,%esp
  80149a:	85 c0                	test   %eax,%eax
  80149c:	78 2e                	js     8014cc <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80149e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014a1:	89 d0                	mov    %edx,%eax
  8014a3:	c1 e8 0c             	shr    $0xc,%eax
  8014a6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014ad:	83 ec 0c             	sub    $0xc,%esp
  8014b0:	25 07 0e 00 00       	and    $0xe07,%eax
  8014b5:	50                   	push   %eax
  8014b6:	53                   	push   %ebx
  8014b7:	6a 00                	push   $0x0
  8014b9:	52                   	push   %edx
  8014ba:	6a 00                	push   $0x0
  8014bc:	e8 b4 f7 ff ff       	call   800c75 <sys_page_map>
  8014c1:	89 c7                	mov    %eax,%edi
  8014c3:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8014c6:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014c8:	85 ff                	test   %edi,%edi
  8014ca:	79 1d                	jns    8014e9 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014cc:	83 ec 08             	sub    $0x8,%esp
  8014cf:	53                   	push   %ebx
  8014d0:	6a 00                	push   $0x0
  8014d2:	e8 e0 f7 ff ff       	call   800cb7 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014d7:	83 c4 08             	add    $0x8,%esp
  8014da:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014dd:	6a 00                	push   $0x0
  8014df:	e8 d3 f7 ff ff       	call   800cb7 <sys_page_unmap>
	return r;
  8014e4:	83 c4 10             	add    $0x10,%esp
  8014e7:	89 f8                	mov    %edi,%eax
}
  8014e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014ec:	5b                   	pop    %ebx
  8014ed:	5e                   	pop    %esi
  8014ee:	5f                   	pop    %edi
  8014ef:	5d                   	pop    %ebp
  8014f0:	c3                   	ret    

008014f1 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014f1:	55                   	push   %ebp
  8014f2:	89 e5                	mov    %esp,%ebp
  8014f4:	53                   	push   %ebx
  8014f5:	83 ec 14             	sub    $0x14,%esp
  8014f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014fb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014fe:	50                   	push   %eax
  8014ff:	53                   	push   %ebx
  801500:	e8 86 fd ff ff       	call   80128b <fd_lookup>
  801505:	83 c4 08             	add    $0x8,%esp
  801508:	89 c2                	mov    %eax,%edx
  80150a:	85 c0                	test   %eax,%eax
  80150c:	78 6d                	js     80157b <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80150e:	83 ec 08             	sub    $0x8,%esp
  801511:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801514:	50                   	push   %eax
  801515:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801518:	ff 30                	pushl  (%eax)
  80151a:	e8 c2 fd ff ff       	call   8012e1 <dev_lookup>
  80151f:	83 c4 10             	add    $0x10,%esp
  801522:	85 c0                	test   %eax,%eax
  801524:	78 4c                	js     801572 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801526:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801529:	8b 42 08             	mov    0x8(%edx),%eax
  80152c:	83 e0 03             	and    $0x3,%eax
  80152f:	83 f8 01             	cmp    $0x1,%eax
  801532:	75 21                	jne    801555 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801534:	a1 04 40 80 00       	mov    0x804004,%eax
  801539:	8b 40 48             	mov    0x48(%eax),%eax
  80153c:	83 ec 04             	sub    $0x4,%esp
  80153f:	53                   	push   %ebx
  801540:	50                   	push   %eax
  801541:	68 f1 27 80 00       	push   $0x8027f1
  801546:	e8 41 ed ff ff       	call   80028c <cprintf>
		return -E_INVAL;
  80154b:	83 c4 10             	add    $0x10,%esp
  80154e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801553:	eb 26                	jmp    80157b <read+0x8a>
	}
	if (!dev->dev_read)
  801555:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801558:	8b 40 08             	mov    0x8(%eax),%eax
  80155b:	85 c0                	test   %eax,%eax
  80155d:	74 17                	je     801576 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80155f:	83 ec 04             	sub    $0x4,%esp
  801562:	ff 75 10             	pushl  0x10(%ebp)
  801565:	ff 75 0c             	pushl  0xc(%ebp)
  801568:	52                   	push   %edx
  801569:	ff d0                	call   *%eax
  80156b:	89 c2                	mov    %eax,%edx
  80156d:	83 c4 10             	add    $0x10,%esp
  801570:	eb 09                	jmp    80157b <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801572:	89 c2                	mov    %eax,%edx
  801574:	eb 05                	jmp    80157b <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801576:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80157b:	89 d0                	mov    %edx,%eax
  80157d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801580:	c9                   	leave  
  801581:	c3                   	ret    

00801582 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801582:	55                   	push   %ebp
  801583:	89 e5                	mov    %esp,%ebp
  801585:	57                   	push   %edi
  801586:	56                   	push   %esi
  801587:	53                   	push   %ebx
  801588:	83 ec 0c             	sub    $0xc,%esp
  80158b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80158e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801591:	bb 00 00 00 00       	mov    $0x0,%ebx
  801596:	eb 21                	jmp    8015b9 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801598:	83 ec 04             	sub    $0x4,%esp
  80159b:	89 f0                	mov    %esi,%eax
  80159d:	29 d8                	sub    %ebx,%eax
  80159f:	50                   	push   %eax
  8015a0:	89 d8                	mov    %ebx,%eax
  8015a2:	03 45 0c             	add    0xc(%ebp),%eax
  8015a5:	50                   	push   %eax
  8015a6:	57                   	push   %edi
  8015a7:	e8 45 ff ff ff       	call   8014f1 <read>
		if (m < 0)
  8015ac:	83 c4 10             	add    $0x10,%esp
  8015af:	85 c0                	test   %eax,%eax
  8015b1:	78 10                	js     8015c3 <readn+0x41>
			return m;
		if (m == 0)
  8015b3:	85 c0                	test   %eax,%eax
  8015b5:	74 0a                	je     8015c1 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015b7:	01 c3                	add    %eax,%ebx
  8015b9:	39 f3                	cmp    %esi,%ebx
  8015bb:	72 db                	jb     801598 <readn+0x16>
  8015bd:	89 d8                	mov    %ebx,%eax
  8015bf:	eb 02                	jmp    8015c3 <readn+0x41>
  8015c1:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8015c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015c6:	5b                   	pop    %ebx
  8015c7:	5e                   	pop    %esi
  8015c8:	5f                   	pop    %edi
  8015c9:	5d                   	pop    %ebp
  8015ca:	c3                   	ret    

008015cb <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015cb:	55                   	push   %ebp
  8015cc:	89 e5                	mov    %esp,%ebp
  8015ce:	53                   	push   %ebx
  8015cf:	83 ec 14             	sub    $0x14,%esp
  8015d2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015d5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015d8:	50                   	push   %eax
  8015d9:	53                   	push   %ebx
  8015da:	e8 ac fc ff ff       	call   80128b <fd_lookup>
  8015df:	83 c4 08             	add    $0x8,%esp
  8015e2:	89 c2                	mov    %eax,%edx
  8015e4:	85 c0                	test   %eax,%eax
  8015e6:	78 68                	js     801650 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015e8:	83 ec 08             	sub    $0x8,%esp
  8015eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ee:	50                   	push   %eax
  8015ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015f2:	ff 30                	pushl  (%eax)
  8015f4:	e8 e8 fc ff ff       	call   8012e1 <dev_lookup>
  8015f9:	83 c4 10             	add    $0x10,%esp
  8015fc:	85 c0                	test   %eax,%eax
  8015fe:	78 47                	js     801647 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801600:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801603:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801607:	75 21                	jne    80162a <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801609:	a1 04 40 80 00       	mov    0x804004,%eax
  80160e:	8b 40 48             	mov    0x48(%eax),%eax
  801611:	83 ec 04             	sub    $0x4,%esp
  801614:	53                   	push   %ebx
  801615:	50                   	push   %eax
  801616:	68 0d 28 80 00       	push   $0x80280d
  80161b:	e8 6c ec ff ff       	call   80028c <cprintf>
		return -E_INVAL;
  801620:	83 c4 10             	add    $0x10,%esp
  801623:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801628:	eb 26                	jmp    801650 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80162a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80162d:	8b 52 0c             	mov    0xc(%edx),%edx
  801630:	85 d2                	test   %edx,%edx
  801632:	74 17                	je     80164b <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801634:	83 ec 04             	sub    $0x4,%esp
  801637:	ff 75 10             	pushl  0x10(%ebp)
  80163a:	ff 75 0c             	pushl  0xc(%ebp)
  80163d:	50                   	push   %eax
  80163e:	ff d2                	call   *%edx
  801640:	89 c2                	mov    %eax,%edx
  801642:	83 c4 10             	add    $0x10,%esp
  801645:	eb 09                	jmp    801650 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801647:	89 c2                	mov    %eax,%edx
  801649:	eb 05                	jmp    801650 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80164b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801650:	89 d0                	mov    %edx,%eax
  801652:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801655:	c9                   	leave  
  801656:	c3                   	ret    

00801657 <seek>:

int
seek(int fdnum, off_t offset)
{
  801657:	55                   	push   %ebp
  801658:	89 e5                	mov    %esp,%ebp
  80165a:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80165d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801660:	50                   	push   %eax
  801661:	ff 75 08             	pushl  0x8(%ebp)
  801664:	e8 22 fc ff ff       	call   80128b <fd_lookup>
  801669:	83 c4 08             	add    $0x8,%esp
  80166c:	85 c0                	test   %eax,%eax
  80166e:	78 0e                	js     80167e <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801670:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801673:	8b 55 0c             	mov    0xc(%ebp),%edx
  801676:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801679:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80167e:	c9                   	leave  
  80167f:	c3                   	ret    

00801680 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801680:	55                   	push   %ebp
  801681:	89 e5                	mov    %esp,%ebp
  801683:	53                   	push   %ebx
  801684:	83 ec 14             	sub    $0x14,%esp
  801687:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80168a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80168d:	50                   	push   %eax
  80168e:	53                   	push   %ebx
  80168f:	e8 f7 fb ff ff       	call   80128b <fd_lookup>
  801694:	83 c4 08             	add    $0x8,%esp
  801697:	89 c2                	mov    %eax,%edx
  801699:	85 c0                	test   %eax,%eax
  80169b:	78 65                	js     801702 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80169d:	83 ec 08             	sub    $0x8,%esp
  8016a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a3:	50                   	push   %eax
  8016a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016a7:	ff 30                	pushl  (%eax)
  8016a9:	e8 33 fc ff ff       	call   8012e1 <dev_lookup>
  8016ae:	83 c4 10             	add    $0x10,%esp
  8016b1:	85 c0                	test   %eax,%eax
  8016b3:	78 44                	js     8016f9 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016b8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016bc:	75 21                	jne    8016df <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016be:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016c3:	8b 40 48             	mov    0x48(%eax),%eax
  8016c6:	83 ec 04             	sub    $0x4,%esp
  8016c9:	53                   	push   %ebx
  8016ca:	50                   	push   %eax
  8016cb:	68 d0 27 80 00       	push   $0x8027d0
  8016d0:	e8 b7 eb ff ff       	call   80028c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016d5:	83 c4 10             	add    $0x10,%esp
  8016d8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016dd:	eb 23                	jmp    801702 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8016df:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016e2:	8b 52 18             	mov    0x18(%edx),%edx
  8016e5:	85 d2                	test   %edx,%edx
  8016e7:	74 14                	je     8016fd <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016e9:	83 ec 08             	sub    $0x8,%esp
  8016ec:	ff 75 0c             	pushl  0xc(%ebp)
  8016ef:	50                   	push   %eax
  8016f0:	ff d2                	call   *%edx
  8016f2:	89 c2                	mov    %eax,%edx
  8016f4:	83 c4 10             	add    $0x10,%esp
  8016f7:	eb 09                	jmp    801702 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016f9:	89 c2                	mov    %eax,%edx
  8016fb:	eb 05                	jmp    801702 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016fd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801702:	89 d0                	mov    %edx,%eax
  801704:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801707:	c9                   	leave  
  801708:	c3                   	ret    

00801709 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801709:	55                   	push   %ebp
  80170a:	89 e5                	mov    %esp,%ebp
  80170c:	53                   	push   %ebx
  80170d:	83 ec 14             	sub    $0x14,%esp
  801710:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801713:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801716:	50                   	push   %eax
  801717:	ff 75 08             	pushl  0x8(%ebp)
  80171a:	e8 6c fb ff ff       	call   80128b <fd_lookup>
  80171f:	83 c4 08             	add    $0x8,%esp
  801722:	89 c2                	mov    %eax,%edx
  801724:	85 c0                	test   %eax,%eax
  801726:	78 58                	js     801780 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801728:	83 ec 08             	sub    $0x8,%esp
  80172b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80172e:	50                   	push   %eax
  80172f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801732:	ff 30                	pushl  (%eax)
  801734:	e8 a8 fb ff ff       	call   8012e1 <dev_lookup>
  801739:	83 c4 10             	add    $0x10,%esp
  80173c:	85 c0                	test   %eax,%eax
  80173e:	78 37                	js     801777 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801740:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801743:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801747:	74 32                	je     80177b <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801749:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80174c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801753:	00 00 00 
	stat->st_isdir = 0;
  801756:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80175d:	00 00 00 
	stat->st_dev = dev;
  801760:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801766:	83 ec 08             	sub    $0x8,%esp
  801769:	53                   	push   %ebx
  80176a:	ff 75 f0             	pushl  -0x10(%ebp)
  80176d:	ff 50 14             	call   *0x14(%eax)
  801770:	89 c2                	mov    %eax,%edx
  801772:	83 c4 10             	add    $0x10,%esp
  801775:	eb 09                	jmp    801780 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801777:	89 c2                	mov    %eax,%edx
  801779:	eb 05                	jmp    801780 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80177b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801780:	89 d0                	mov    %edx,%eax
  801782:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801785:	c9                   	leave  
  801786:	c3                   	ret    

00801787 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801787:	55                   	push   %ebp
  801788:	89 e5                	mov    %esp,%ebp
  80178a:	56                   	push   %esi
  80178b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80178c:	83 ec 08             	sub    $0x8,%esp
  80178f:	6a 00                	push   $0x0
  801791:	ff 75 08             	pushl  0x8(%ebp)
  801794:	e8 e3 01 00 00       	call   80197c <open>
  801799:	89 c3                	mov    %eax,%ebx
  80179b:	83 c4 10             	add    $0x10,%esp
  80179e:	85 c0                	test   %eax,%eax
  8017a0:	78 1b                	js     8017bd <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017a2:	83 ec 08             	sub    $0x8,%esp
  8017a5:	ff 75 0c             	pushl  0xc(%ebp)
  8017a8:	50                   	push   %eax
  8017a9:	e8 5b ff ff ff       	call   801709 <fstat>
  8017ae:	89 c6                	mov    %eax,%esi
	close(fd);
  8017b0:	89 1c 24             	mov    %ebx,(%esp)
  8017b3:	e8 fd fb ff ff       	call   8013b5 <close>
	return r;
  8017b8:	83 c4 10             	add    $0x10,%esp
  8017bb:	89 f0                	mov    %esi,%eax
}
  8017bd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017c0:	5b                   	pop    %ebx
  8017c1:	5e                   	pop    %esi
  8017c2:	5d                   	pop    %ebp
  8017c3:	c3                   	ret    

008017c4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017c4:	55                   	push   %ebp
  8017c5:	89 e5                	mov    %esp,%ebp
  8017c7:	56                   	push   %esi
  8017c8:	53                   	push   %ebx
  8017c9:	89 c6                	mov    %eax,%esi
  8017cb:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017cd:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017d4:	75 12                	jne    8017e8 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017d6:	83 ec 0c             	sub    $0xc,%esp
  8017d9:	6a 01                	push   $0x1
  8017db:	e8 fc f9 ff ff       	call   8011dc <ipc_find_env>
  8017e0:	a3 00 40 80 00       	mov    %eax,0x804000
  8017e5:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017e8:	6a 07                	push   $0x7
  8017ea:	68 00 50 80 00       	push   $0x805000
  8017ef:	56                   	push   %esi
  8017f0:	ff 35 00 40 80 00    	pushl  0x804000
  8017f6:	e8 8d f9 ff ff       	call   801188 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017fb:	83 c4 0c             	add    $0xc,%esp
  8017fe:	6a 00                	push   $0x0
  801800:	53                   	push   %ebx
  801801:	6a 00                	push   $0x0
  801803:	e8 2b f9 ff ff       	call   801133 <ipc_recv>
}
  801808:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80180b:	5b                   	pop    %ebx
  80180c:	5e                   	pop    %esi
  80180d:	5d                   	pop    %ebp
  80180e:	c3                   	ret    

0080180f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80180f:	55                   	push   %ebp
  801810:	89 e5                	mov    %esp,%ebp
  801812:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801815:	8b 45 08             	mov    0x8(%ebp),%eax
  801818:	8b 40 0c             	mov    0xc(%eax),%eax
  80181b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801820:	8b 45 0c             	mov    0xc(%ebp),%eax
  801823:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801828:	ba 00 00 00 00       	mov    $0x0,%edx
  80182d:	b8 02 00 00 00       	mov    $0x2,%eax
  801832:	e8 8d ff ff ff       	call   8017c4 <fsipc>
}
  801837:	c9                   	leave  
  801838:	c3                   	ret    

00801839 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801839:	55                   	push   %ebp
  80183a:	89 e5                	mov    %esp,%ebp
  80183c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80183f:	8b 45 08             	mov    0x8(%ebp),%eax
  801842:	8b 40 0c             	mov    0xc(%eax),%eax
  801845:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80184a:	ba 00 00 00 00       	mov    $0x0,%edx
  80184f:	b8 06 00 00 00       	mov    $0x6,%eax
  801854:	e8 6b ff ff ff       	call   8017c4 <fsipc>
}
  801859:	c9                   	leave  
  80185a:	c3                   	ret    

0080185b <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80185b:	55                   	push   %ebp
  80185c:	89 e5                	mov    %esp,%ebp
  80185e:	53                   	push   %ebx
  80185f:	83 ec 04             	sub    $0x4,%esp
  801862:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801865:	8b 45 08             	mov    0x8(%ebp),%eax
  801868:	8b 40 0c             	mov    0xc(%eax),%eax
  80186b:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801870:	ba 00 00 00 00       	mov    $0x0,%edx
  801875:	b8 05 00 00 00       	mov    $0x5,%eax
  80187a:	e8 45 ff ff ff       	call   8017c4 <fsipc>
  80187f:	85 c0                	test   %eax,%eax
  801881:	78 2c                	js     8018af <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801883:	83 ec 08             	sub    $0x8,%esp
  801886:	68 00 50 80 00       	push   $0x805000
  80188b:	53                   	push   %ebx
  80188c:	e8 9e ef ff ff       	call   80082f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801891:	a1 80 50 80 00       	mov    0x805080,%eax
  801896:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80189c:	a1 84 50 80 00       	mov    0x805084,%eax
  8018a1:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018a7:	83 c4 10             	add    $0x10,%esp
  8018aa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018b2:	c9                   	leave  
  8018b3:	c3                   	ret    

008018b4 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018b4:	55                   	push   %ebp
  8018b5:	89 e5                	mov    %esp,%ebp
  8018b7:	83 ec 0c             	sub    $0xc,%esp
  8018ba:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
    
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018bd:	8b 55 08             	mov    0x8(%ebp),%edx
  8018c0:	8b 52 0c             	mov    0xc(%edx),%edx
  8018c3:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = MIN(n, PGSIZE);
  8018c9:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018ce:	ba 00 10 00 00       	mov    $0x1000,%edx
  8018d3:	0f 47 c2             	cmova  %edx,%eax
  8018d6:	a3 04 50 80 00       	mov    %eax,0x805004
    memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8018db:	50                   	push   %eax
  8018dc:	ff 75 0c             	pushl  0xc(%ebp)
  8018df:	68 08 50 80 00       	push   $0x805008
  8018e4:	e8 d8 f0 ff ff       	call   8009c1 <memmove>
    int r = fsipc(FSREQ_WRITE, NULL);
  8018e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ee:	b8 04 00 00 00       	mov    $0x4,%eax
  8018f3:	e8 cc fe ff ff       	call   8017c4 <fsipc>
    return r;
}
  8018f8:	c9                   	leave  
  8018f9:	c3                   	ret    

008018fa <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018fa:	55                   	push   %ebp
  8018fb:	89 e5                	mov    %esp,%ebp
  8018fd:	56                   	push   %esi
  8018fe:	53                   	push   %ebx
  8018ff:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801902:	8b 45 08             	mov    0x8(%ebp),%eax
  801905:	8b 40 0c             	mov    0xc(%eax),%eax
  801908:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80190d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801913:	ba 00 00 00 00       	mov    $0x0,%edx
  801918:	b8 03 00 00 00       	mov    $0x3,%eax
  80191d:	e8 a2 fe ff ff       	call   8017c4 <fsipc>
  801922:	89 c3                	mov    %eax,%ebx
  801924:	85 c0                	test   %eax,%eax
  801926:	78 4b                	js     801973 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801928:	39 c6                	cmp    %eax,%esi
  80192a:	73 16                	jae    801942 <devfile_read+0x48>
  80192c:	68 3c 28 80 00       	push   $0x80283c
  801931:	68 43 28 80 00       	push   $0x802843
  801936:	6a 7c                	push   $0x7c
  801938:	68 58 28 80 00       	push   $0x802858
  80193d:	e8 bd 05 00 00       	call   801eff <_panic>
	assert(r <= PGSIZE);
  801942:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801947:	7e 16                	jle    80195f <devfile_read+0x65>
  801949:	68 63 28 80 00       	push   $0x802863
  80194e:	68 43 28 80 00       	push   $0x802843
  801953:	6a 7d                	push   $0x7d
  801955:	68 58 28 80 00       	push   $0x802858
  80195a:	e8 a0 05 00 00       	call   801eff <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80195f:	83 ec 04             	sub    $0x4,%esp
  801962:	50                   	push   %eax
  801963:	68 00 50 80 00       	push   $0x805000
  801968:	ff 75 0c             	pushl  0xc(%ebp)
  80196b:	e8 51 f0 ff ff       	call   8009c1 <memmove>
	return r;
  801970:	83 c4 10             	add    $0x10,%esp
}
  801973:	89 d8                	mov    %ebx,%eax
  801975:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801978:	5b                   	pop    %ebx
  801979:	5e                   	pop    %esi
  80197a:	5d                   	pop    %ebp
  80197b:	c3                   	ret    

0080197c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80197c:	55                   	push   %ebp
  80197d:	89 e5                	mov    %esp,%ebp
  80197f:	53                   	push   %ebx
  801980:	83 ec 20             	sub    $0x20,%esp
  801983:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801986:	53                   	push   %ebx
  801987:	e8 6a ee ff ff       	call   8007f6 <strlen>
  80198c:	83 c4 10             	add    $0x10,%esp
  80198f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801994:	7f 67                	jg     8019fd <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801996:	83 ec 0c             	sub    $0xc,%esp
  801999:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80199c:	50                   	push   %eax
  80199d:	e8 9a f8 ff ff       	call   80123c <fd_alloc>
  8019a2:	83 c4 10             	add    $0x10,%esp
		return r;
  8019a5:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019a7:	85 c0                	test   %eax,%eax
  8019a9:	78 57                	js     801a02 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019ab:	83 ec 08             	sub    $0x8,%esp
  8019ae:	53                   	push   %ebx
  8019af:	68 00 50 80 00       	push   $0x805000
  8019b4:	e8 76 ee ff ff       	call   80082f <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019bc:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019c4:	b8 01 00 00 00       	mov    $0x1,%eax
  8019c9:	e8 f6 fd ff ff       	call   8017c4 <fsipc>
  8019ce:	89 c3                	mov    %eax,%ebx
  8019d0:	83 c4 10             	add    $0x10,%esp
  8019d3:	85 c0                	test   %eax,%eax
  8019d5:	79 14                	jns    8019eb <open+0x6f>
		fd_close(fd, 0);
  8019d7:	83 ec 08             	sub    $0x8,%esp
  8019da:	6a 00                	push   $0x0
  8019dc:	ff 75 f4             	pushl  -0xc(%ebp)
  8019df:	e8 50 f9 ff ff       	call   801334 <fd_close>
		return r;
  8019e4:	83 c4 10             	add    $0x10,%esp
  8019e7:	89 da                	mov    %ebx,%edx
  8019e9:	eb 17                	jmp    801a02 <open+0x86>
	}

	return fd2num(fd);
  8019eb:	83 ec 0c             	sub    $0xc,%esp
  8019ee:	ff 75 f4             	pushl  -0xc(%ebp)
  8019f1:	e8 1f f8 ff ff       	call   801215 <fd2num>
  8019f6:	89 c2                	mov    %eax,%edx
  8019f8:	83 c4 10             	add    $0x10,%esp
  8019fb:	eb 05                	jmp    801a02 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019fd:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a02:	89 d0                	mov    %edx,%eax
  801a04:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a07:	c9                   	leave  
  801a08:	c3                   	ret    

00801a09 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a09:	55                   	push   %ebp
  801a0a:	89 e5                	mov    %esp,%ebp
  801a0c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a0f:	ba 00 00 00 00       	mov    $0x0,%edx
  801a14:	b8 08 00 00 00       	mov    $0x8,%eax
  801a19:	e8 a6 fd ff ff       	call   8017c4 <fsipc>
}
  801a1e:	c9                   	leave  
  801a1f:	c3                   	ret    

00801a20 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a20:	55                   	push   %ebp
  801a21:	89 e5                	mov    %esp,%ebp
  801a23:	56                   	push   %esi
  801a24:	53                   	push   %ebx
  801a25:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a28:	83 ec 0c             	sub    $0xc,%esp
  801a2b:	ff 75 08             	pushl  0x8(%ebp)
  801a2e:	e8 f2 f7 ff ff       	call   801225 <fd2data>
  801a33:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a35:	83 c4 08             	add    $0x8,%esp
  801a38:	68 6f 28 80 00       	push   $0x80286f
  801a3d:	53                   	push   %ebx
  801a3e:	e8 ec ed ff ff       	call   80082f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a43:	8b 46 04             	mov    0x4(%esi),%eax
  801a46:	2b 06                	sub    (%esi),%eax
  801a48:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a4e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a55:	00 00 00 
	stat->st_dev = &devpipe;
  801a58:	c7 83 88 00 00 00 28 	movl   $0x803028,0x88(%ebx)
  801a5f:	30 80 00 
	return 0;
}
  801a62:	b8 00 00 00 00       	mov    $0x0,%eax
  801a67:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a6a:	5b                   	pop    %ebx
  801a6b:	5e                   	pop    %esi
  801a6c:	5d                   	pop    %ebp
  801a6d:	c3                   	ret    

00801a6e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a6e:	55                   	push   %ebp
  801a6f:	89 e5                	mov    %esp,%ebp
  801a71:	53                   	push   %ebx
  801a72:	83 ec 0c             	sub    $0xc,%esp
  801a75:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a78:	53                   	push   %ebx
  801a79:	6a 00                	push   $0x0
  801a7b:	e8 37 f2 ff ff       	call   800cb7 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a80:	89 1c 24             	mov    %ebx,(%esp)
  801a83:	e8 9d f7 ff ff       	call   801225 <fd2data>
  801a88:	83 c4 08             	add    $0x8,%esp
  801a8b:	50                   	push   %eax
  801a8c:	6a 00                	push   $0x0
  801a8e:	e8 24 f2 ff ff       	call   800cb7 <sys_page_unmap>
}
  801a93:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a96:	c9                   	leave  
  801a97:	c3                   	ret    

00801a98 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a98:	55                   	push   %ebp
  801a99:	89 e5                	mov    %esp,%ebp
  801a9b:	57                   	push   %edi
  801a9c:	56                   	push   %esi
  801a9d:	53                   	push   %ebx
  801a9e:	83 ec 1c             	sub    $0x1c,%esp
  801aa1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801aa4:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801aa6:	a1 04 40 80 00       	mov    0x804004,%eax
  801aab:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801aae:	83 ec 0c             	sub    $0xc,%esp
  801ab1:	ff 75 e0             	pushl  -0x20(%ebp)
  801ab4:	e8 18 05 00 00       	call   801fd1 <pageref>
  801ab9:	89 c3                	mov    %eax,%ebx
  801abb:	89 3c 24             	mov    %edi,(%esp)
  801abe:	e8 0e 05 00 00       	call   801fd1 <pageref>
  801ac3:	83 c4 10             	add    $0x10,%esp
  801ac6:	39 c3                	cmp    %eax,%ebx
  801ac8:	0f 94 c1             	sete   %cl
  801acb:	0f b6 c9             	movzbl %cl,%ecx
  801ace:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801ad1:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801ad7:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ada:	39 ce                	cmp    %ecx,%esi
  801adc:	74 1b                	je     801af9 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801ade:	39 c3                	cmp    %eax,%ebx
  801ae0:	75 c4                	jne    801aa6 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ae2:	8b 42 58             	mov    0x58(%edx),%eax
  801ae5:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ae8:	50                   	push   %eax
  801ae9:	56                   	push   %esi
  801aea:	68 76 28 80 00       	push   $0x802876
  801aef:	e8 98 e7 ff ff       	call   80028c <cprintf>
  801af4:	83 c4 10             	add    $0x10,%esp
  801af7:	eb ad                	jmp    801aa6 <_pipeisclosed+0xe>
	}
}
  801af9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801afc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aff:	5b                   	pop    %ebx
  801b00:	5e                   	pop    %esi
  801b01:	5f                   	pop    %edi
  801b02:	5d                   	pop    %ebp
  801b03:	c3                   	ret    

00801b04 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b04:	55                   	push   %ebp
  801b05:	89 e5                	mov    %esp,%ebp
  801b07:	57                   	push   %edi
  801b08:	56                   	push   %esi
  801b09:	53                   	push   %ebx
  801b0a:	83 ec 28             	sub    $0x28,%esp
  801b0d:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b10:	56                   	push   %esi
  801b11:	e8 0f f7 ff ff       	call   801225 <fd2data>
  801b16:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b18:	83 c4 10             	add    $0x10,%esp
  801b1b:	bf 00 00 00 00       	mov    $0x0,%edi
  801b20:	eb 4b                	jmp    801b6d <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b22:	89 da                	mov    %ebx,%edx
  801b24:	89 f0                	mov    %esi,%eax
  801b26:	e8 6d ff ff ff       	call   801a98 <_pipeisclosed>
  801b2b:	85 c0                	test   %eax,%eax
  801b2d:	75 48                	jne    801b77 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b2f:	e8 df f0 ff ff       	call   800c13 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b34:	8b 43 04             	mov    0x4(%ebx),%eax
  801b37:	8b 0b                	mov    (%ebx),%ecx
  801b39:	8d 51 20             	lea    0x20(%ecx),%edx
  801b3c:	39 d0                	cmp    %edx,%eax
  801b3e:	73 e2                	jae    801b22 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b43:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b47:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b4a:	89 c2                	mov    %eax,%edx
  801b4c:	c1 fa 1f             	sar    $0x1f,%edx
  801b4f:	89 d1                	mov    %edx,%ecx
  801b51:	c1 e9 1b             	shr    $0x1b,%ecx
  801b54:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b57:	83 e2 1f             	and    $0x1f,%edx
  801b5a:	29 ca                	sub    %ecx,%edx
  801b5c:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b60:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b64:	83 c0 01             	add    $0x1,%eax
  801b67:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b6a:	83 c7 01             	add    $0x1,%edi
  801b6d:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b70:	75 c2                	jne    801b34 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b72:	8b 45 10             	mov    0x10(%ebp),%eax
  801b75:	eb 05                	jmp    801b7c <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b77:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b7f:	5b                   	pop    %ebx
  801b80:	5e                   	pop    %esi
  801b81:	5f                   	pop    %edi
  801b82:	5d                   	pop    %ebp
  801b83:	c3                   	ret    

00801b84 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b84:	55                   	push   %ebp
  801b85:	89 e5                	mov    %esp,%ebp
  801b87:	57                   	push   %edi
  801b88:	56                   	push   %esi
  801b89:	53                   	push   %ebx
  801b8a:	83 ec 18             	sub    $0x18,%esp
  801b8d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b90:	57                   	push   %edi
  801b91:	e8 8f f6 ff ff       	call   801225 <fd2data>
  801b96:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b98:	83 c4 10             	add    $0x10,%esp
  801b9b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ba0:	eb 3d                	jmp    801bdf <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ba2:	85 db                	test   %ebx,%ebx
  801ba4:	74 04                	je     801baa <devpipe_read+0x26>
				return i;
  801ba6:	89 d8                	mov    %ebx,%eax
  801ba8:	eb 44                	jmp    801bee <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801baa:	89 f2                	mov    %esi,%edx
  801bac:	89 f8                	mov    %edi,%eax
  801bae:	e8 e5 fe ff ff       	call   801a98 <_pipeisclosed>
  801bb3:	85 c0                	test   %eax,%eax
  801bb5:	75 32                	jne    801be9 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801bb7:	e8 57 f0 ff ff       	call   800c13 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801bbc:	8b 06                	mov    (%esi),%eax
  801bbe:	3b 46 04             	cmp    0x4(%esi),%eax
  801bc1:	74 df                	je     801ba2 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801bc3:	99                   	cltd   
  801bc4:	c1 ea 1b             	shr    $0x1b,%edx
  801bc7:	01 d0                	add    %edx,%eax
  801bc9:	83 e0 1f             	and    $0x1f,%eax
  801bcc:	29 d0                	sub    %edx,%eax
  801bce:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801bd3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bd6:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801bd9:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bdc:	83 c3 01             	add    $0x1,%ebx
  801bdf:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801be2:	75 d8                	jne    801bbc <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801be4:	8b 45 10             	mov    0x10(%ebp),%eax
  801be7:	eb 05                	jmp    801bee <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801be9:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801bee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bf1:	5b                   	pop    %ebx
  801bf2:	5e                   	pop    %esi
  801bf3:	5f                   	pop    %edi
  801bf4:	5d                   	pop    %ebp
  801bf5:	c3                   	ret    

00801bf6 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801bf6:	55                   	push   %ebp
  801bf7:	89 e5                	mov    %esp,%ebp
  801bf9:	56                   	push   %esi
  801bfa:	53                   	push   %ebx
  801bfb:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801bfe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c01:	50                   	push   %eax
  801c02:	e8 35 f6 ff ff       	call   80123c <fd_alloc>
  801c07:	83 c4 10             	add    $0x10,%esp
  801c0a:	89 c2                	mov    %eax,%edx
  801c0c:	85 c0                	test   %eax,%eax
  801c0e:	0f 88 2c 01 00 00    	js     801d40 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c14:	83 ec 04             	sub    $0x4,%esp
  801c17:	68 07 04 00 00       	push   $0x407
  801c1c:	ff 75 f4             	pushl  -0xc(%ebp)
  801c1f:	6a 00                	push   $0x0
  801c21:	e8 0c f0 ff ff       	call   800c32 <sys_page_alloc>
  801c26:	83 c4 10             	add    $0x10,%esp
  801c29:	89 c2                	mov    %eax,%edx
  801c2b:	85 c0                	test   %eax,%eax
  801c2d:	0f 88 0d 01 00 00    	js     801d40 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c33:	83 ec 0c             	sub    $0xc,%esp
  801c36:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c39:	50                   	push   %eax
  801c3a:	e8 fd f5 ff ff       	call   80123c <fd_alloc>
  801c3f:	89 c3                	mov    %eax,%ebx
  801c41:	83 c4 10             	add    $0x10,%esp
  801c44:	85 c0                	test   %eax,%eax
  801c46:	0f 88 e2 00 00 00    	js     801d2e <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c4c:	83 ec 04             	sub    $0x4,%esp
  801c4f:	68 07 04 00 00       	push   $0x407
  801c54:	ff 75 f0             	pushl  -0x10(%ebp)
  801c57:	6a 00                	push   $0x0
  801c59:	e8 d4 ef ff ff       	call   800c32 <sys_page_alloc>
  801c5e:	89 c3                	mov    %eax,%ebx
  801c60:	83 c4 10             	add    $0x10,%esp
  801c63:	85 c0                	test   %eax,%eax
  801c65:	0f 88 c3 00 00 00    	js     801d2e <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c6b:	83 ec 0c             	sub    $0xc,%esp
  801c6e:	ff 75 f4             	pushl  -0xc(%ebp)
  801c71:	e8 af f5 ff ff       	call   801225 <fd2data>
  801c76:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c78:	83 c4 0c             	add    $0xc,%esp
  801c7b:	68 07 04 00 00       	push   $0x407
  801c80:	50                   	push   %eax
  801c81:	6a 00                	push   $0x0
  801c83:	e8 aa ef ff ff       	call   800c32 <sys_page_alloc>
  801c88:	89 c3                	mov    %eax,%ebx
  801c8a:	83 c4 10             	add    $0x10,%esp
  801c8d:	85 c0                	test   %eax,%eax
  801c8f:	0f 88 89 00 00 00    	js     801d1e <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c95:	83 ec 0c             	sub    $0xc,%esp
  801c98:	ff 75 f0             	pushl  -0x10(%ebp)
  801c9b:	e8 85 f5 ff ff       	call   801225 <fd2data>
  801ca0:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ca7:	50                   	push   %eax
  801ca8:	6a 00                	push   $0x0
  801caa:	56                   	push   %esi
  801cab:	6a 00                	push   $0x0
  801cad:	e8 c3 ef ff ff       	call   800c75 <sys_page_map>
  801cb2:	89 c3                	mov    %eax,%ebx
  801cb4:	83 c4 20             	add    $0x20,%esp
  801cb7:	85 c0                	test   %eax,%eax
  801cb9:	78 55                	js     801d10 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801cbb:	8b 15 28 30 80 00    	mov    0x803028,%edx
  801cc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cc4:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801cc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cc9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801cd0:	8b 15 28 30 80 00    	mov    0x803028,%edx
  801cd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cd9:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801cdb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cde:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801ce5:	83 ec 0c             	sub    $0xc,%esp
  801ce8:	ff 75 f4             	pushl  -0xc(%ebp)
  801ceb:	e8 25 f5 ff ff       	call   801215 <fd2num>
  801cf0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cf3:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801cf5:	83 c4 04             	add    $0x4,%esp
  801cf8:	ff 75 f0             	pushl  -0x10(%ebp)
  801cfb:	e8 15 f5 ff ff       	call   801215 <fd2num>
  801d00:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d03:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d06:	83 c4 10             	add    $0x10,%esp
  801d09:	ba 00 00 00 00       	mov    $0x0,%edx
  801d0e:	eb 30                	jmp    801d40 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d10:	83 ec 08             	sub    $0x8,%esp
  801d13:	56                   	push   %esi
  801d14:	6a 00                	push   $0x0
  801d16:	e8 9c ef ff ff       	call   800cb7 <sys_page_unmap>
  801d1b:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d1e:	83 ec 08             	sub    $0x8,%esp
  801d21:	ff 75 f0             	pushl  -0x10(%ebp)
  801d24:	6a 00                	push   $0x0
  801d26:	e8 8c ef ff ff       	call   800cb7 <sys_page_unmap>
  801d2b:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d2e:	83 ec 08             	sub    $0x8,%esp
  801d31:	ff 75 f4             	pushl  -0xc(%ebp)
  801d34:	6a 00                	push   $0x0
  801d36:	e8 7c ef ff ff       	call   800cb7 <sys_page_unmap>
  801d3b:	83 c4 10             	add    $0x10,%esp
  801d3e:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d40:	89 d0                	mov    %edx,%eax
  801d42:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d45:	5b                   	pop    %ebx
  801d46:	5e                   	pop    %esi
  801d47:	5d                   	pop    %ebp
  801d48:	c3                   	ret    

00801d49 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d49:	55                   	push   %ebp
  801d4a:	89 e5                	mov    %esp,%ebp
  801d4c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d4f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d52:	50                   	push   %eax
  801d53:	ff 75 08             	pushl  0x8(%ebp)
  801d56:	e8 30 f5 ff ff       	call   80128b <fd_lookup>
  801d5b:	83 c4 10             	add    $0x10,%esp
  801d5e:	85 c0                	test   %eax,%eax
  801d60:	78 18                	js     801d7a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d62:	83 ec 0c             	sub    $0xc,%esp
  801d65:	ff 75 f4             	pushl  -0xc(%ebp)
  801d68:	e8 b8 f4 ff ff       	call   801225 <fd2data>
	return _pipeisclosed(fd, p);
  801d6d:	89 c2                	mov    %eax,%edx
  801d6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d72:	e8 21 fd ff ff       	call   801a98 <_pipeisclosed>
  801d77:	83 c4 10             	add    $0x10,%esp
}
  801d7a:	c9                   	leave  
  801d7b:	c3                   	ret    

00801d7c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d7c:	55                   	push   %ebp
  801d7d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d7f:	b8 00 00 00 00       	mov    $0x0,%eax
  801d84:	5d                   	pop    %ebp
  801d85:	c3                   	ret    

00801d86 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d86:	55                   	push   %ebp
  801d87:	89 e5                	mov    %esp,%ebp
  801d89:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d8c:	68 8e 28 80 00       	push   $0x80288e
  801d91:	ff 75 0c             	pushl  0xc(%ebp)
  801d94:	e8 96 ea ff ff       	call   80082f <strcpy>
	return 0;
}
  801d99:	b8 00 00 00 00       	mov    $0x0,%eax
  801d9e:	c9                   	leave  
  801d9f:	c3                   	ret    

00801da0 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801da0:	55                   	push   %ebp
  801da1:	89 e5                	mov    %esp,%ebp
  801da3:	57                   	push   %edi
  801da4:	56                   	push   %esi
  801da5:	53                   	push   %ebx
  801da6:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dac:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801db1:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801db7:	eb 2d                	jmp    801de6 <devcons_write+0x46>
		m = n - tot;
  801db9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801dbc:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801dbe:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801dc1:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801dc6:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801dc9:	83 ec 04             	sub    $0x4,%esp
  801dcc:	53                   	push   %ebx
  801dcd:	03 45 0c             	add    0xc(%ebp),%eax
  801dd0:	50                   	push   %eax
  801dd1:	57                   	push   %edi
  801dd2:	e8 ea eb ff ff       	call   8009c1 <memmove>
		sys_cputs(buf, m);
  801dd7:	83 c4 08             	add    $0x8,%esp
  801dda:	53                   	push   %ebx
  801ddb:	57                   	push   %edi
  801ddc:	e8 95 ed ff ff       	call   800b76 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801de1:	01 de                	add    %ebx,%esi
  801de3:	83 c4 10             	add    $0x10,%esp
  801de6:	89 f0                	mov    %esi,%eax
  801de8:	3b 75 10             	cmp    0x10(%ebp),%esi
  801deb:	72 cc                	jb     801db9 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ded:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801df0:	5b                   	pop    %ebx
  801df1:	5e                   	pop    %esi
  801df2:	5f                   	pop    %edi
  801df3:	5d                   	pop    %ebp
  801df4:	c3                   	ret    

00801df5 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801df5:	55                   	push   %ebp
  801df6:	89 e5                	mov    %esp,%ebp
  801df8:	83 ec 08             	sub    $0x8,%esp
  801dfb:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e00:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e04:	74 2a                	je     801e30 <devcons_read+0x3b>
  801e06:	eb 05                	jmp    801e0d <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e08:	e8 06 ee ff ff       	call   800c13 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e0d:	e8 82 ed ff ff       	call   800b94 <sys_cgetc>
  801e12:	85 c0                	test   %eax,%eax
  801e14:	74 f2                	je     801e08 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e16:	85 c0                	test   %eax,%eax
  801e18:	78 16                	js     801e30 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e1a:	83 f8 04             	cmp    $0x4,%eax
  801e1d:	74 0c                	je     801e2b <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e1f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e22:	88 02                	mov    %al,(%edx)
	return 1;
  801e24:	b8 01 00 00 00       	mov    $0x1,%eax
  801e29:	eb 05                	jmp    801e30 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e2b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e30:	c9                   	leave  
  801e31:	c3                   	ret    

00801e32 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e32:	55                   	push   %ebp
  801e33:	89 e5                	mov    %esp,%ebp
  801e35:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e38:	8b 45 08             	mov    0x8(%ebp),%eax
  801e3b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e3e:	6a 01                	push   $0x1
  801e40:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e43:	50                   	push   %eax
  801e44:	e8 2d ed ff ff       	call   800b76 <sys_cputs>
}
  801e49:	83 c4 10             	add    $0x10,%esp
  801e4c:	c9                   	leave  
  801e4d:	c3                   	ret    

00801e4e <getchar>:

int
getchar(void)
{
  801e4e:	55                   	push   %ebp
  801e4f:	89 e5                	mov    %esp,%ebp
  801e51:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e54:	6a 01                	push   $0x1
  801e56:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e59:	50                   	push   %eax
  801e5a:	6a 00                	push   $0x0
  801e5c:	e8 90 f6 ff ff       	call   8014f1 <read>
	if (r < 0)
  801e61:	83 c4 10             	add    $0x10,%esp
  801e64:	85 c0                	test   %eax,%eax
  801e66:	78 0f                	js     801e77 <getchar+0x29>
		return r;
	if (r < 1)
  801e68:	85 c0                	test   %eax,%eax
  801e6a:	7e 06                	jle    801e72 <getchar+0x24>
		return -E_EOF;
	return c;
  801e6c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e70:	eb 05                	jmp    801e77 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e72:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e77:	c9                   	leave  
  801e78:	c3                   	ret    

00801e79 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e79:	55                   	push   %ebp
  801e7a:	89 e5                	mov    %esp,%ebp
  801e7c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e7f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e82:	50                   	push   %eax
  801e83:	ff 75 08             	pushl  0x8(%ebp)
  801e86:	e8 00 f4 ff ff       	call   80128b <fd_lookup>
  801e8b:	83 c4 10             	add    $0x10,%esp
  801e8e:	85 c0                	test   %eax,%eax
  801e90:	78 11                	js     801ea3 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e92:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e95:	8b 15 44 30 80 00    	mov    0x803044,%edx
  801e9b:	39 10                	cmp    %edx,(%eax)
  801e9d:	0f 94 c0             	sete   %al
  801ea0:	0f b6 c0             	movzbl %al,%eax
}
  801ea3:	c9                   	leave  
  801ea4:	c3                   	ret    

00801ea5 <opencons>:

int
opencons(void)
{
  801ea5:	55                   	push   %ebp
  801ea6:	89 e5                	mov    %esp,%ebp
  801ea8:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801eab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eae:	50                   	push   %eax
  801eaf:	e8 88 f3 ff ff       	call   80123c <fd_alloc>
  801eb4:	83 c4 10             	add    $0x10,%esp
		return r;
  801eb7:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801eb9:	85 c0                	test   %eax,%eax
  801ebb:	78 3e                	js     801efb <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ebd:	83 ec 04             	sub    $0x4,%esp
  801ec0:	68 07 04 00 00       	push   $0x407
  801ec5:	ff 75 f4             	pushl  -0xc(%ebp)
  801ec8:	6a 00                	push   $0x0
  801eca:	e8 63 ed ff ff       	call   800c32 <sys_page_alloc>
  801ecf:	83 c4 10             	add    $0x10,%esp
		return r;
  801ed2:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ed4:	85 c0                	test   %eax,%eax
  801ed6:	78 23                	js     801efb <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ed8:	8b 15 44 30 80 00    	mov    0x803044,%edx
  801ede:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ee1:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ee3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ee6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801eed:	83 ec 0c             	sub    $0xc,%esp
  801ef0:	50                   	push   %eax
  801ef1:	e8 1f f3 ff ff       	call   801215 <fd2num>
  801ef6:	89 c2                	mov    %eax,%edx
  801ef8:	83 c4 10             	add    $0x10,%esp
}
  801efb:	89 d0                	mov    %edx,%eax
  801efd:	c9                   	leave  
  801efe:	c3                   	ret    

00801eff <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801eff:	55                   	push   %ebp
  801f00:	89 e5                	mov    %esp,%ebp
  801f02:	56                   	push   %esi
  801f03:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801f04:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801f07:	8b 35 08 30 80 00    	mov    0x803008,%esi
  801f0d:	e8 e2 ec ff ff       	call   800bf4 <sys_getenvid>
  801f12:	83 ec 0c             	sub    $0xc,%esp
  801f15:	ff 75 0c             	pushl  0xc(%ebp)
  801f18:	ff 75 08             	pushl  0x8(%ebp)
  801f1b:	56                   	push   %esi
  801f1c:	50                   	push   %eax
  801f1d:	68 9c 28 80 00       	push   $0x80289c
  801f22:	e8 65 e3 ff ff       	call   80028c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801f27:	83 c4 18             	add    $0x18,%esp
  801f2a:	53                   	push   %ebx
  801f2b:	ff 75 10             	pushl  0x10(%ebp)
  801f2e:	e8 08 e3 ff ff       	call   80023b <vcprintf>
	cprintf("\n");
  801f33:	c7 04 24 87 28 80 00 	movl   $0x802887,(%esp)
  801f3a:	e8 4d e3 ff ff       	call   80028c <cprintf>
  801f3f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801f42:	cc                   	int3   
  801f43:	eb fd                	jmp    801f42 <_panic+0x43>

00801f45 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f45:	55                   	push   %ebp
  801f46:	89 e5                	mov    %esp,%ebp
  801f48:	83 ec 08             	sub    $0x8,%esp
	int r;
	int ret;
	if (_pgfault_handler == 0) {
  801f4b:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f52:	75 36                	jne    801f8a <set_pgfault_handler+0x45>
		// First time through!
		// LAB 4: Your code here.
        
        	ret = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  801f54:	a1 04 40 80 00       	mov    0x804004,%eax
  801f59:	8b 40 48             	mov    0x48(%eax),%eax
  801f5c:	83 ec 04             	sub    $0x4,%esp
  801f5f:	68 07 0e 00 00       	push   $0xe07
  801f64:	68 00 f0 bf ee       	push   $0xeebff000
  801f69:	50                   	push   %eax
  801f6a:	e8 c3 ec ff ff       	call   800c32 <sys_page_alloc>
		if (ret < 0) {
  801f6f:	83 c4 10             	add    $0x10,%esp
  801f72:	85 c0                	test   %eax,%eax
  801f74:	79 14                	jns    801f8a <set_pgfault_handler+0x45>
		    panic("Allocate user exception stack failed!\n");
  801f76:	83 ec 04             	sub    $0x4,%esp
  801f79:	68 c0 28 80 00       	push   $0x8028c0
  801f7e:	6a 23                	push   $0x23
  801f80:	68 e8 28 80 00       	push   $0x8028e8
  801f85:	e8 75 ff ff ff       	call   801eff <_panic>
		}
	}
	sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  801f8a:	a1 04 40 80 00       	mov    0x804004,%eax
  801f8f:	8b 40 48             	mov    0x48(%eax),%eax
  801f92:	83 ec 08             	sub    $0x8,%esp
  801f95:	68 ad 1f 80 00       	push   $0x801fad
  801f9a:	50                   	push   %eax
  801f9b:	e8 dd ed ff ff       	call   800d7d <sys_env_set_pgfault_upcall>
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801fa0:	8b 45 08             	mov    0x8(%ebp),%eax
  801fa3:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801fa8:	83 c4 10             	add    $0x10,%esp
  801fab:	c9                   	leave  
  801fac:	c3                   	ret    

00801fad <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801fad:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801fae:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801fb3:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801fb5:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 0x28(%esp), %ebx  # trap-time eip
  801fb8:	8b 5c 24 28          	mov    0x28(%esp),%ebx
        subl $0x4, 0x30(%esp)  # trap-time esp minus 4
  801fbc:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax 
  801fc1:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl %ebx, (%eax)      # trap-time esp store trap-time eip
  801fc5:	89 18                	mov    %ebx,(%eax)
        addl $0x8, %esp
  801fc7:	83 c4 08             	add    $0x8,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  801fca:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  801fcb:	83 c4 04             	add    $0x4,%esp
        popfl
  801fce:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  801fcf:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  801fd0:	c3                   	ret    

00801fd1 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fd1:	55                   	push   %ebp
  801fd2:	89 e5                	mov    %esp,%ebp
  801fd4:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fd7:	89 d0                	mov    %edx,%eax
  801fd9:	c1 e8 16             	shr    $0x16,%eax
  801fdc:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fe3:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fe8:	f6 c1 01             	test   $0x1,%cl
  801feb:	74 1d                	je     80200a <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fed:	c1 ea 0c             	shr    $0xc,%edx
  801ff0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801ff7:	f6 c2 01             	test   $0x1,%dl
  801ffa:	74 0e                	je     80200a <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ffc:	c1 ea 0c             	shr    $0xc,%edx
  801fff:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802006:	ef 
  802007:	0f b7 c0             	movzwl %ax,%eax
}
  80200a:	5d                   	pop    %ebp
  80200b:	c3                   	ret    
  80200c:	66 90                	xchg   %ax,%ax
  80200e:	66 90                	xchg   %ax,%ax

00802010 <__udivdi3>:
  802010:	55                   	push   %ebp
  802011:	57                   	push   %edi
  802012:	56                   	push   %esi
  802013:	53                   	push   %ebx
  802014:	83 ec 1c             	sub    $0x1c,%esp
  802017:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80201b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80201f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802023:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802027:	85 f6                	test   %esi,%esi
  802029:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80202d:	89 ca                	mov    %ecx,%edx
  80202f:	89 f8                	mov    %edi,%eax
  802031:	75 3d                	jne    802070 <__udivdi3+0x60>
  802033:	39 cf                	cmp    %ecx,%edi
  802035:	0f 87 c5 00 00 00    	ja     802100 <__udivdi3+0xf0>
  80203b:	85 ff                	test   %edi,%edi
  80203d:	89 fd                	mov    %edi,%ebp
  80203f:	75 0b                	jne    80204c <__udivdi3+0x3c>
  802041:	b8 01 00 00 00       	mov    $0x1,%eax
  802046:	31 d2                	xor    %edx,%edx
  802048:	f7 f7                	div    %edi
  80204a:	89 c5                	mov    %eax,%ebp
  80204c:	89 c8                	mov    %ecx,%eax
  80204e:	31 d2                	xor    %edx,%edx
  802050:	f7 f5                	div    %ebp
  802052:	89 c1                	mov    %eax,%ecx
  802054:	89 d8                	mov    %ebx,%eax
  802056:	89 cf                	mov    %ecx,%edi
  802058:	f7 f5                	div    %ebp
  80205a:	89 c3                	mov    %eax,%ebx
  80205c:	89 d8                	mov    %ebx,%eax
  80205e:	89 fa                	mov    %edi,%edx
  802060:	83 c4 1c             	add    $0x1c,%esp
  802063:	5b                   	pop    %ebx
  802064:	5e                   	pop    %esi
  802065:	5f                   	pop    %edi
  802066:	5d                   	pop    %ebp
  802067:	c3                   	ret    
  802068:	90                   	nop
  802069:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802070:	39 ce                	cmp    %ecx,%esi
  802072:	77 74                	ja     8020e8 <__udivdi3+0xd8>
  802074:	0f bd fe             	bsr    %esi,%edi
  802077:	83 f7 1f             	xor    $0x1f,%edi
  80207a:	0f 84 98 00 00 00    	je     802118 <__udivdi3+0x108>
  802080:	bb 20 00 00 00       	mov    $0x20,%ebx
  802085:	89 f9                	mov    %edi,%ecx
  802087:	89 c5                	mov    %eax,%ebp
  802089:	29 fb                	sub    %edi,%ebx
  80208b:	d3 e6                	shl    %cl,%esi
  80208d:	89 d9                	mov    %ebx,%ecx
  80208f:	d3 ed                	shr    %cl,%ebp
  802091:	89 f9                	mov    %edi,%ecx
  802093:	d3 e0                	shl    %cl,%eax
  802095:	09 ee                	or     %ebp,%esi
  802097:	89 d9                	mov    %ebx,%ecx
  802099:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80209d:	89 d5                	mov    %edx,%ebp
  80209f:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020a3:	d3 ed                	shr    %cl,%ebp
  8020a5:	89 f9                	mov    %edi,%ecx
  8020a7:	d3 e2                	shl    %cl,%edx
  8020a9:	89 d9                	mov    %ebx,%ecx
  8020ab:	d3 e8                	shr    %cl,%eax
  8020ad:	09 c2                	or     %eax,%edx
  8020af:	89 d0                	mov    %edx,%eax
  8020b1:	89 ea                	mov    %ebp,%edx
  8020b3:	f7 f6                	div    %esi
  8020b5:	89 d5                	mov    %edx,%ebp
  8020b7:	89 c3                	mov    %eax,%ebx
  8020b9:	f7 64 24 0c          	mull   0xc(%esp)
  8020bd:	39 d5                	cmp    %edx,%ebp
  8020bf:	72 10                	jb     8020d1 <__udivdi3+0xc1>
  8020c1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8020c5:	89 f9                	mov    %edi,%ecx
  8020c7:	d3 e6                	shl    %cl,%esi
  8020c9:	39 c6                	cmp    %eax,%esi
  8020cb:	73 07                	jae    8020d4 <__udivdi3+0xc4>
  8020cd:	39 d5                	cmp    %edx,%ebp
  8020cf:	75 03                	jne    8020d4 <__udivdi3+0xc4>
  8020d1:	83 eb 01             	sub    $0x1,%ebx
  8020d4:	31 ff                	xor    %edi,%edi
  8020d6:	89 d8                	mov    %ebx,%eax
  8020d8:	89 fa                	mov    %edi,%edx
  8020da:	83 c4 1c             	add    $0x1c,%esp
  8020dd:	5b                   	pop    %ebx
  8020de:	5e                   	pop    %esi
  8020df:	5f                   	pop    %edi
  8020e0:	5d                   	pop    %ebp
  8020e1:	c3                   	ret    
  8020e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020e8:	31 ff                	xor    %edi,%edi
  8020ea:	31 db                	xor    %ebx,%ebx
  8020ec:	89 d8                	mov    %ebx,%eax
  8020ee:	89 fa                	mov    %edi,%edx
  8020f0:	83 c4 1c             	add    $0x1c,%esp
  8020f3:	5b                   	pop    %ebx
  8020f4:	5e                   	pop    %esi
  8020f5:	5f                   	pop    %edi
  8020f6:	5d                   	pop    %ebp
  8020f7:	c3                   	ret    
  8020f8:	90                   	nop
  8020f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802100:	89 d8                	mov    %ebx,%eax
  802102:	f7 f7                	div    %edi
  802104:	31 ff                	xor    %edi,%edi
  802106:	89 c3                	mov    %eax,%ebx
  802108:	89 d8                	mov    %ebx,%eax
  80210a:	89 fa                	mov    %edi,%edx
  80210c:	83 c4 1c             	add    $0x1c,%esp
  80210f:	5b                   	pop    %ebx
  802110:	5e                   	pop    %esi
  802111:	5f                   	pop    %edi
  802112:	5d                   	pop    %ebp
  802113:	c3                   	ret    
  802114:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802118:	39 ce                	cmp    %ecx,%esi
  80211a:	72 0c                	jb     802128 <__udivdi3+0x118>
  80211c:	31 db                	xor    %ebx,%ebx
  80211e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802122:	0f 87 34 ff ff ff    	ja     80205c <__udivdi3+0x4c>
  802128:	bb 01 00 00 00       	mov    $0x1,%ebx
  80212d:	e9 2a ff ff ff       	jmp    80205c <__udivdi3+0x4c>
  802132:	66 90                	xchg   %ax,%ax
  802134:	66 90                	xchg   %ax,%ax
  802136:	66 90                	xchg   %ax,%ax
  802138:	66 90                	xchg   %ax,%ax
  80213a:	66 90                	xchg   %ax,%ax
  80213c:	66 90                	xchg   %ax,%ax
  80213e:	66 90                	xchg   %ax,%ax

00802140 <__umoddi3>:
  802140:	55                   	push   %ebp
  802141:	57                   	push   %edi
  802142:	56                   	push   %esi
  802143:	53                   	push   %ebx
  802144:	83 ec 1c             	sub    $0x1c,%esp
  802147:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80214b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80214f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802153:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802157:	85 d2                	test   %edx,%edx
  802159:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80215d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802161:	89 f3                	mov    %esi,%ebx
  802163:	89 3c 24             	mov    %edi,(%esp)
  802166:	89 74 24 04          	mov    %esi,0x4(%esp)
  80216a:	75 1c                	jne    802188 <__umoddi3+0x48>
  80216c:	39 f7                	cmp    %esi,%edi
  80216e:	76 50                	jbe    8021c0 <__umoddi3+0x80>
  802170:	89 c8                	mov    %ecx,%eax
  802172:	89 f2                	mov    %esi,%edx
  802174:	f7 f7                	div    %edi
  802176:	89 d0                	mov    %edx,%eax
  802178:	31 d2                	xor    %edx,%edx
  80217a:	83 c4 1c             	add    $0x1c,%esp
  80217d:	5b                   	pop    %ebx
  80217e:	5e                   	pop    %esi
  80217f:	5f                   	pop    %edi
  802180:	5d                   	pop    %ebp
  802181:	c3                   	ret    
  802182:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802188:	39 f2                	cmp    %esi,%edx
  80218a:	89 d0                	mov    %edx,%eax
  80218c:	77 52                	ja     8021e0 <__umoddi3+0xa0>
  80218e:	0f bd ea             	bsr    %edx,%ebp
  802191:	83 f5 1f             	xor    $0x1f,%ebp
  802194:	75 5a                	jne    8021f0 <__umoddi3+0xb0>
  802196:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80219a:	0f 82 e0 00 00 00    	jb     802280 <__umoddi3+0x140>
  8021a0:	39 0c 24             	cmp    %ecx,(%esp)
  8021a3:	0f 86 d7 00 00 00    	jbe    802280 <__umoddi3+0x140>
  8021a9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021ad:	8b 54 24 04          	mov    0x4(%esp),%edx
  8021b1:	83 c4 1c             	add    $0x1c,%esp
  8021b4:	5b                   	pop    %ebx
  8021b5:	5e                   	pop    %esi
  8021b6:	5f                   	pop    %edi
  8021b7:	5d                   	pop    %ebp
  8021b8:	c3                   	ret    
  8021b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021c0:	85 ff                	test   %edi,%edi
  8021c2:	89 fd                	mov    %edi,%ebp
  8021c4:	75 0b                	jne    8021d1 <__umoddi3+0x91>
  8021c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021cb:	31 d2                	xor    %edx,%edx
  8021cd:	f7 f7                	div    %edi
  8021cf:	89 c5                	mov    %eax,%ebp
  8021d1:	89 f0                	mov    %esi,%eax
  8021d3:	31 d2                	xor    %edx,%edx
  8021d5:	f7 f5                	div    %ebp
  8021d7:	89 c8                	mov    %ecx,%eax
  8021d9:	f7 f5                	div    %ebp
  8021db:	89 d0                	mov    %edx,%eax
  8021dd:	eb 99                	jmp    802178 <__umoddi3+0x38>
  8021df:	90                   	nop
  8021e0:	89 c8                	mov    %ecx,%eax
  8021e2:	89 f2                	mov    %esi,%edx
  8021e4:	83 c4 1c             	add    $0x1c,%esp
  8021e7:	5b                   	pop    %ebx
  8021e8:	5e                   	pop    %esi
  8021e9:	5f                   	pop    %edi
  8021ea:	5d                   	pop    %ebp
  8021eb:	c3                   	ret    
  8021ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021f0:	8b 34 24             	mov    (%esp),%esi
  8021f3:	bf 20 00 00 00       	mov    $0x20,%edi
  8021f8:	89 e9                	mov    %ebp,%ecx
  8021fa:	29 ef                	sub    %ebp,%edi
  8021fc:	d3 e0                	shl    %cl,%eax
  8021fe:	89 f9                	mov    %edi,%ecx
  802200:	89 f2                	mov    %esi,%edx
  802202:	d3 ea                	shr    %cl,%edx
  802204:	89 e9                	mov    %ebp,%ecx
  802206:	09 c2                	or     %eax,%edx
  802208:	89 d8                	mov    %ebx,%eax
  80220a:	89 14 24             	mov    %edx,(%esp)
  80220d:	89 f2                	mov    %esi,%edx
  80220f:	d3 e2                	shl    %cl,%edx
  802211:	89 f9                	mov    %edi,%ecx
  802213:	89 54 24 04          	mov    %edx,0x4(%esp)
  802217:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80221b:	d3 e8                	shr    %cl,%eax
  80221d:	89 e9                	mov    %ebp,%ecx
  80221f:	89 c6                	mov    %eax,%esi
  802221:	d3 e3                	shl    %cl,%ebx
  802223:	89 f9                	mov    %edi,%ecx
  802225:	89 d0                	mov    %edx,%eax
  802227:	d3 e8                	shr    %cl,%eax
  802229:	89 e9                	mov    %ebp,%ecx
  80222b:	09 d8                	or     %ebx,%eax
  80222d:	89 d3                	mov    %edx,%ebx
  80222f:	89 f2                	mov    %esi,%edx
  802231:	f7 34 24             	divl   (%esp)
  802234:	89 d6                	mov    %edx,%esi
  802236:	d3 e3                	shl    %cl,%ebx
  802238:	f7 64 24 04          	mull   0x4(%esp)
  80223c:	39 d6                	cmp    %edx,%esi
  80223e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802242:	89 d1                	mov    %edx,%ecx
  802244:	89 c3                	mov    %eax,%ebx
  802246:	72 08                	jb     802250 <__umoddi3+0x110>
  802248:	75 11                	jne    80225b <__umoddi3+0x11b>
  80224a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80224e:	73 0b                	jae    80225b <__umoddi3+0x11b>
  802250:	2b 44 24 04          	sub    0x4(%esp),%eax
  802254:	1b 14 24             	sbb    (%esp),%edx
  802257:	89 d1                	mov    %edx,%ecx
  802259:	89 c3                	mov    %eax,%ebx
  80225b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80225f:	29 da                	sub    %ebx,%edx
  802261:	19 ce                	sbb    %ecx,%esi
  802263:	89 f9                	mov    %edi,%ecx
  802265:	89 f0                	mov    %esi,%eax
  802267:	d3 e0                	shl    %cl,%eax
  802269:	89 e9                	mov    %ebp,%ecx
  80226b:	d3 ea                	shr    %cl,%edx
  80226d:	89 e9                	mov    %ebp,%ecx
  80226f:	d3 ee                	shr    %cl,%esi
  802271:	09 d0                	or     %edx,%eax
  802273:	89 f2                	mov    %esi,%edx
  802275:	83 c4 1c             	add    $0x1c,%esp
  802278:	5b                   	pop    %ebx
  802279:	5e                   	pop    %esi
  80227a:	5f                   	pop    %edi
  80227b:	5d                   	pop    %ebp
  80227c:	c3                   	ret    
  80227d:	8d 76 00             	lea    0x0(%esi),%esi
  802280:	29 f9                	sub    %edi,%ecx
  802282:	19 d6                	sbb    %edx,%esi
  802284:	89 74 24 04          	mov    %esi,0x4(%esp)
  802288:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80228c:	e9 18 ff ff ff       	jmp    8021a9 <__umoddi3+0x69>
