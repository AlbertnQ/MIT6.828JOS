
obj/user/lsfd.debug:     file format elf32-i386


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
  80002c:	e8 dc 00 00 00       	call   80010d <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <usage>:
#include <inc/lib.h>

void
usage(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	cprintf("usage: lsfd [-1]\n");
  800039:	68 e0 20 80 00       	push   $0x8020e0
  80003e:	e8 bd 01 00 00       	call   800200 <cprintf>
	exit();
  800043:	e8 0b 01 00 00       	call   800153 <exit>
}
  800048:	83 c4 10             	add    $0x10,%esp
  80004b:	c9                   	leave  
  80004c:	c3                   	ret    

0080004d <umain>:

void
umain(int argc, char **argv)
{
  80004d:	55                   	push   %ebp
  80004e:	89 e5                	mov    %esp,%ebp
  800050:	57                   	push   %edi
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	81 ec b0 00 00 00    	sub    $0xb0,%esp
	int i, usefprint = 0;
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
  800059:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  80005f:	50                   	push   %eax
  800060:	ff 75 0c             	pushl  0xc(%ebp)
  800063:	8d 45 08             	lea    0x8(%ebp),%eax
  800066:	50                   	push   %eax
  800067:	e8 2b 0d 00 00       	call   800d97 <argstart>
	while ((i = argnext(&args)) >= 0)
  80006c:	83 c4 10             	add    $0x10,%esp
}

void
umain(int argc, char **argv)
{
	int i, usefprint = 0;
  80006f:	be 00 00 00 00       	mov    $0x0,%esi
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  800074:	8d 9d 4c ff ff ff    	lea    -0xb4(%ebp),%ebx
  80007a:	eb 11                	jmp    80008d <umain+0x40>
		if (i == '1')
  80007c:	83 f8 31             	cmp    $0x31,%eax
  80007f:	74 07                	je     800088 <umain+0x3b>
			usefprint = 1;
		else
			usage();
  800081:	e8 ad ff ff ff       	call   800033 <usage>
  800086:	eb 05                	jmp    80008d <umain+0x40>
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
		if (i == '1')
			usefprint = 1;
  800088:	be 01 00 00 00       	mov    $0x1,%esi
	int i, usefprint = 0;
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  80008d:	83 ec 0c             	sub    $0xc,%esp
  800090:	53                   	push   %ebx
  800091:	e8 31 0d 00 00       	call   800dc7 <argnext>
  800096:	83 c4 10             	add    $0x10,%esp
  800099:	85 c0                	test   %eax,%eax
  80009b:	79 df                	jns    80007c <umain+0x2f>
  80009d:	bb 00 00 00 00       	mov    $0x0,%ebx
			usefprint = 1;
		else
			usage();

	for (i = 0; i < 32; i++)
		if (fstat(i, &st) >= 0) {
  8000a2:	8d bd 5c ff ff ff    	lea    -0xa4(%ebp),%edi
  8000a8:	83 ec 08             	sub    $0x8,%esp
  8000ab:	57                   	push   %edi
  8000ac:	53                   	push   %ebx
  8000ad:	e8 2d 13 00 00       	call   8013df <fstat>
  8000b2:	83 c4 10             	add    $0x10,%esp
  8000b5:	85 c0                	test   %eax,%eax
  8000b7:	78 44                	js     8000fd <umain+0xb0>
			if (usefprint)
  8000b9:	85 f6                	test   %esi,%esi
  8000bb:	74 22                	je     8000df <umain+0x92>
				fprintf(1, "fd %d: name %s isdir %d size %d dev %s\n",
  8000bd:	83 ec 04             	sub    $0x4,%esp
  8000c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000c3:	ff 70 04             	pushl  0x4(%eax)
  8000c6:	ff 75 dc             	pushl  -0x24(%ebp)
  8000c9:	ff 75 e0             	pushl  -0x20(%ebp)
  8000cc:	57                   	push   %edi
  8000cd:	53                   	push   %ebx
  8000ce:	68 f4 20 80 00       	push   $0x8020f4
  8000d3:	6a 01                	push   $0x1
  8000d5:	e8 ff 16 00 00       	call   8017d9 <fprintf>
  8000da:	83 c4 20             	add    $0x20,%esp
  8000dd:	eb 1e                	jmp    8000fd <umain+0xb0>
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
			else
				cprintf("fd %d: name %s isdir %d size %d dev %s\n",
  8000df:	83 ec 08             	sub    $0x8,%esp
  8000e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000e5:	ff 70 04             	pushl  0x4(%eax)
  8000e8:	ff 75 dc             	pushl  -0x24(%ebp)
  8000eb:	ff 75 e0             	pushl  -0x20(%ebp)
  8000ee:	57                   	push   %edi
  8000ef:	53                   	push   %ebx
  8000f0:	68 f4 20 80 00       	push   $0x8020f4
  8000f5:	e8 06 01 00 00       	call   800200 <cprintf>
  8000fa:	83 c4 20             	add    $0x20,%esp
		if (i == '1')
			usefprint = 1;
		else
			usage();

	for (i = 0; i < 32; i++)
  8000fd:	83 c3 01             	add    $0x1,%ebx
  800100:	83 fb 20             	cmp    $0x20,%ebx
  800103:	75 a3                	jne    8000a8 <umain+0x5b>
			else
				cprintf("fd %d: name %s isdir %d size %d dev %s\n",
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
		}
}
  800105:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800108:	5b                   	pop    %ebx
  800109:	5e                   	pop    %esi
  80010a:	5f                   	pop    %edi
  80010b:	5d                   	pop    %ebp
  80010c:	c3                   	ret    

0080010d <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80010d:	55                   	push   %ebp
  80010e:	89 e5                	mov    %esp,%ebp
  800110:	56                   	push   %esi
  800111:	53                   	push   %ebx
  800112:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800115:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  800118:	e8 4b 0a 00 00       	call   800b68 <sys_getenvid>
  80011d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800122:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800125:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80012a:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80012f:	85 db                	test   %ebx,%ebx
  800131:	7e 07                	jle    80013a <libmain+0x2d>
		binaryname = argv[0];
  800133:	8b 06                	mov    (%esi),%eax
  800135:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80013a:	83 ec 08             	sub    $0x8,%esp
  80013d:	56                   	push   %esi
  80013e:	53                   	push   %ebx
  80013f:	e8 09 ff ff ff       	call   80004d <umain>

	// exit gracefully
	exit();
  800144:	e8 0a 00 00 00       	call   800153 <exit>
}
  800149:	83 c4 10             	add    $0x10,%esp
  80014c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80014f:	5b                   	pop    %ebx
  800150:	5e                   	pop    %esi
  800151:	5d                   	pop    %ebp
  800152:	c3                   	ret    

00800153 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800153:	55                   	push   %ebp
  800154:	89 e5                	mov    %esp,%ebp
  800156:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800159:	e8 58 0f 00 00       	call   8010b6 <close_all>
	sys_env_destroy(0);
  80015e:	83 ec 0c             	sub    $0xc,%esp
  800161:	6a 00                	push   $0x0
  800163:	e8 bf 09 00 00       	call   800b27 <sys_env_destroy>
}
  800168:	83 c4 10             	add    $0x10,%esp
  80016b:	c9                   	leave  
  80016c:	c3                   	ret    

0080016d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80016d:	55                   	push   %ebp
  80016e:	89 e5                	mov    %esp,%ebp
  800170:	53                   	push   %ebx
  800171:	83 ec 04             	sub    $0x4,%esp
  800174:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800177:	8b 13                	mov    (%ebx),%edx
  800179:	8d 42 01             	lea    0x1(%edx),%eax
  80017c:	89 03                	mov    %eax,(%ebx)
  80017e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800181:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800185:	3d ff 00 00 00       	cmp    $0xff,%eax
  80018a:	75 1a                	jne    8001a6 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80018c:	83 ec 08             	sub    $0x8,%esp
  80018f:	68 ff 00 00 00       	push   $0xff
  800194:	8d 43 08             	lea    0x8(%ebx),%eax
  800197:	50                   	push   %eax
  800198:	e8 4d 09 00 00       	call   800aea <sys_cputs>
		b->idx = 0;
  80019d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001a3:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001a6:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001ad:	c9                   	leave  
  8001ae:	c3                   	ret    

008001af <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001af:	55                   	push   %ebp
  8001b0:	89 e5                	mov    %esp,%ebp
  8001b2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001b8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001bf:	00 00 00 
	b.cnt = 0;
  8001c2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001c9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001cc:	ff 75 0c             	pushl  0xc(%ebp)
  8001cf:	ff 75 08             	pushl  0x8(%ebp)
  8001d2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d8:	50                   	push   %eax
  8001d9:	68 6d 01 80 00       	push   $0x80016d
  8001de:	e8 54 01 00 00       	call   800337 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e3:	83 c4 08             	add    $0x8,%esp
  8001e6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001ec:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001f2:	50                   	push   %eax
  8001f3:	e8 f2 08 00 00       	call   800aea <sys_cputs>

	return b.cnt;
}
  8001f8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001fe:	c9                   	leave  
  8001ff:	c3                   	ret    

00800200 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800200:	55                   	push   %ebp
  800201:	89 e5                	mov    %esp,%ebp
  800203:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800206:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800209:	50                   	push   %eax
  80020a:	ff 75 08             	pushl  0x8(%ebp)
  80020d:	e8 9d ff ff ff       	call   8001af <vcprintf>
	va_end(ap);

	return cnt;
}
  800212:	c9                   	leave  
  800213:	c3                   	ret    

00800214 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	57                   	push   %edi
  800218:	56                   	push   %esi
  800219:	53                   	push   %ebx
  80021a:	83 ec 1c             	sub    $0x1c,%esp
  80021d:	89 c7                	mov    %eax,%edi
  80021f:	89 d6                	mov    %edx,%esi
  800221:	8b 45 08             	mov    0x8(%ebp),%eax
  800224:	8b 55 0c             	mov    0xc(%ebp),%edx
  800227:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80022a:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80022d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800230:	bb 00 00 00 00       	mov    $0x0,%ebx
  800235:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800238:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80023b:	39 d3                	cmp    %edx,%ebx
  80023d:	72 05                	jb     800244 <printnum+0x30>
  80023f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800242:	77 45                	ja     800289 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800244:	83 ec 0c             	sub    $0xc,%esp
  800247:	ff 75 18             	pushl  0x18(%ebp)
  80024a:	8b 45 14             	mov    0x14(%ebp),%eax
  80024d:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800250:	53                   	push   %ebx
  800251:	ff 75 10             	pushl  0x10(%ebp)
  800254:	83 ec 08             	sub    $0x8,%esp
  800257:	ff 75 e4             	pushl  -0x1c(%ebp)
  80025a:	ff 75 e0             	pushl  -0x20(%ebp)
  80025d:	ff 75 dc             	pushl  -0x24(%ebp)
  800260:	ff 75 d8             	pushl  -0x28(%ebp)
  800263:	e8 e8 1b 00 00       	call   801e50 <__udivdi3>
  800268:	83 c4 18             	add    $0x18,%esp
  80026b:	52                   	push   %edx
  80026c:	50                   	push   %eax
  80026d:	89 f2                	mov    %esi,%edx
  80026f:	89 f8                	mov    %edi,%eax
  800271:	e8 9e ff ff ff       	call   800214 <printnum>
  800276:	83 c4 20             	add    $0x20,%esp
  800279:	eb 18                	jmp    800293 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80027b:	83 ec 08             	sub    $0x8,%esp
  80027e:	56                   	push   %esi
  80027f:	ff 75 18             	pushl  0x18(%ebp)
  800282:	ff d7                	call   *%edi
  800284:	83 c4 10             	add    $0x10,%esp
  800287:	eb 03                	jmp    80028c <printnum+0x78>
  800289:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80028c:	83 eb 01             	sub    $0x1,%ebx
  80028f:	85 db                	test   %ebx,%ebx
  800291:	7f e8                	jg     80027b <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800293:	83 ec 08             	sub    $0x8,%esp
  800296:	56                   	push   %esi
  800297:	83 ec 04             	sub    $0x4,%esp
  80029a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80029d:	ff 75 e0             	pushl  -0x20(%ebp)
  8002a0:	ff 75 dc             	pushl  -0x24(%ebp)
  8002a3:	ff 75 d8             	pushl  -0x28(%ebp)
  8002a6:	e8 d5 1c 00 00       	call   801f80 <__umoddi3>
  8002ab:	83 c4 14             	add    $0x14,%esp
  8002ae:	0f be 80 26 21 80 00 	movsbl 0x802126(%eax),%eax
  8002b5:	50                   	push   %eax
  8002b6:	ff d7                	call   *%edi
}
  8002b8:	83 c4 10             	add    $0x10,%esp
  8002bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002be:	5b                   	pop    %ebx
  8002bf:	5e                   	pop    %esi
  8002c0:	5f                   	pop    %edi
  8002c1:	5d                   	pop    %ebp
  8002c2:	c3                   	ret    

008002c3 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002c3:	55                   	push   %ebp
  8002c4:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002c6:	83 fa 01             	cmp    $0x1,%edx
  8002c9:	7e 0e                	jle    8002d9 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002cb:	8b 10                	mov    (%eax),%edx
  8002cd:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002d0:	89 08                	mov    %ecx,(%eax)
  8002d2:	8b 02                	mov    (%edx),%eax
  8002d4:	8b 52 04             	mov    0x4(%edx),%edx
  8002d7:	eb 22                	jmp    8002fb <getuint+0x38>
	else if (lflag)
  8002d9:	85 d2                	test   %edx,%edx
  8002db:	74 10                	je     8002ed <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002dd:	8b 10                	mov    (%eax),%edx
  8002df:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e2:	89 08                	mov    %ecx,(%eax)
  8002e4:	8b 02                	mov    (%edx),%eax
  8002e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8002eb:	eb 0e                	jmp    8002fb <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002ed:	8b 10                	mov    (%eax),%edx
  8002ef:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f2:	89 08                	mov    %ecx,(%eax)
  8002f4:	8b 02                	mov    (%edx),%eax
  8002f6:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002fb:	5d                   	pop    %ebp
  8002fc:	c3                   	ret    

008002fd <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002fd:	55                   	push   %ebp
  8002fe:	89 e5                	mov    %esp,%ebp
  800300:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800303:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800307:	8b 10                	mov    (%eax),%edx
  800309:	3b 50 04             	cmp    0x4(%eax),%edx
  80030c:	73 0a                	jae    800318 <sprintputch+0x1b>
		*b->buf++ = ch;
  80030e:	8d 4a 01             	lea    0x1(%edx),%ecx
  800311:	89 08                	mov    %ecx,(%eax)
  800313:	8b 45 08             	mov    0x8(%ebp),%eax
  800316:	88 02                	mov    %al,(%edx)
}
  800318:	5d                   	pop    %ebp
  800319:	c3                   	ret    

0080031a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80031a:	55                   	push   %ebp
  80031b:	89 e5                	mov    %esp,%ebp
  80031d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800320:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800323:	50                   	push   %eax
  800324:	ff 75 10             	pushl  0x10(%ebp)
  800327:	ff 75 0c             	pushl  0xc(%ebp)
  80032a:	ff 75 08             	pushl  0x8(%ebp)
  80032d:	e8 05 00 00 00       	call   800337 <vprintfmt>
	va_end(ap);
}
  800332:	83 c4 10             	add    $0x10,%esp
  800335:	c9                   	leave  
  800336:	c3                   	ret    

00800337 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800337:	55                   	push   %ebp
  800338:	89 e5                	mov    %esp,%ebp
  80033a:	57                   	push   %edi
  80033b:	56                   	push   %esi
  80033c:	53                   	push   %ebx
  80033d:	83 ec 2c             	sub    $0x2c,%esp
  800340:	8b 75 08             	mov    0x8(%ebp),%esi
  800343:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800346:	8b 7d 10             	mov    0x10(%ebp),%edi
  800349:	eb 12                	jmp    80035d <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80034b:	85 c0                	test   %eax,%eax
  80034d:	0f 84 a7 03 00 00    	je     8006fa <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
  800353:	83 ec 08             	sub    $0x8,%esp
  800356:	53                   	push   %ebx
  800357:	50                   	push   %eax
  800358:	ff d6                	call   *%esi
  80035a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80035d:	83 c7 01             	add    $0x1,%edi
  800360:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800364:	83 f8 25             	cmp    $0x25,%eax
  800367:	75 e2                	jne    80034b <vprintfmt+0x14>
  800369:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80036d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800374:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80037b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800382:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800389:	b9 00 00 00 00       	mov    $0x0,%ecx
  80038e:	eb 07                	jmp    800397 <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800390:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800393:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800397:	8d 47 01             	lea    0x1(%edi),%eax
  80039a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80039d:	0f b6 07             	movzbl (%edi),%eax
  8003a0:	0f b6 d0             	movzbl %al,%edx
  8003a3:	83 e8 23             	sub    $0x23,%eax
  8003a6:	3c 55                	cmp    $0x55,%al
  8003a8:	0f 87 31 03 00 00    	ja     8006df <vprintfmt+0x3a8>
  8003ae:	0f b6 c0             	movzbl %al,%eax
  8003b1:	ff 24 85 60 22 80 00 	jmp    *0x802260(,%eax,4)
  8003b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003bb:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003bf:	eb d6                	jmp    800397 <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c9:	89 75 08             	mov    %esi,0x8(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003cc:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003cf:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003d3:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003d6:	8d 72 d0             	lea    -0x30(%edx),%esi
  8003d9:	83 fe 09             	cmp    $0x9,%esi
  8003dc:	77 34                	ja     800412 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003de:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003e1:	eb e9                	jmp    8003cc <vprintfmt+0x95>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e6:	8d 50 04             	lea    0x4(%eax),%edx
  8003e9:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ec:	8b 00                	mov    (%eax),%eax
  8003ee:	89 45 cc             	mov    %eax,-0x34(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003f4:	eb 22                	jmp    800418 <vprintfmt+0xe1>
  8003f6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003f9:	85 c0                	test   %eax,%eax
  8003fb:	0f 48 c1             	cmovs  %ecx,%eax
  8003fe:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800401:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800404:	eb 91                	jmp    800397 <vprintfmt+0x60>
  800406:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800409:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800410:	eb 85                	jmp    800397 <vprintfmt+0x60>
  800412:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800415:	8b 75 08             	mov    0x8(%ebp),%esi

		process_precision:
			if (width < 0)
  800418:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80041c:	0f 89 75 ff ff ff    	jns    800397 <vprintfmt+0x60>
				width = precision, precision = -1;
  800422:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800425:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800428:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80042f:	e9 63 ff ff ff       	jmp    800397 <vprintfmt+0x60>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800434:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800438:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80043b:	e9 57 ff ff ff       	jmp    800397 <vprintfmt+0x60>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800440:	8b 45 14             	mov    0x14(%ebp),%eax
  800443:	8d 50 04             	lea    0x4(%eax),%edx
  800446:	89 55 14             	mov    %edx,0x14(%ebp)
  800449:	83 ec 08             	sub    $0x8,%esp
  80044c:	53                   	push   %ebx
  80044d:	ff 30                	pushl  (%eax)
  80044f:	ff d6                	call   *%esi
			break;
  800451:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800454:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800457:	e9 01 ff ff ff       	jmp    80035d <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80045c:	8b 45 14             	mov    0x14(%ebp),%eax
  80045f:	8d 50 04             	lea    0x4(%eax),%edx
  800462:	89 55 14             	mov    %edx,0x14(%ebp)
  800465:	8b 00                	mov    (%eax),%eax
  800467:	99                   	cltd   
  800468:	31 d0                	xor    %edx,%eax
  80046a:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80046c:	83 f8 0f             	cmp    $0xf,%eax
  80046f:	7f 0b                	jg     80047c <vprintfmt+0x145>
  800471:	8b 14 85 c0 23 80 00 	mov    0x8023c0(,%eax,4),%edx
  800478:	85 d2                	test   %edx,%edx
  80047a:	75 18                	jne    800494 <vprintfmt+0x15d>
				printfmt(putch, putdat, "error %d", err);
  80047c:	50                   	push   %eax
  80047d:	68 3e 21 80 00       	push   $0x80213e
  800482:	53                   	push   %ebx
  800483:	56                   	push   %esi
  800484:	e8 91 fe ff ff       	call   80031a <printfmt>
  800489:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80048f:	e9 c9 fe ff ff       	jmp    80035d <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800494:	52                   	push   %edx
  800495:	68 f1 24 80 00       	push   $0x8024f1
  80049a:	53                   	push   %ebx
  80049b:	56                   	push   %esi
  80049c:	e8 79 fe ff ff       	call   80031a <printfmt>
  8004a1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004a7:	e9 b1 fe ff ff       	jmp    80035d <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8004af:	8d 50 04             	lea    0x4(%eax),%edx
  8004b2:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b5:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004b7:	85 ff                	test   %edi,%edi
  8004b9:	b8 37 21 80 00       	mov    $0x802137,%eax
  8004be:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004c1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004c5:	0f 8e 94 00 00 00    	jle    80055f <vprintfmt+0x228>
  8004cb:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004cf:	0f 84 98 00 00 00    	je     80056d <vprintfmt+0x236>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d5:	83 ec 08             	sub    $0x8,%esp
  8004d8:	ff 75 cc             	pushl  -0x34(%ebp)
  8004db:	57                   	push   %edi
  8004dc:	e8 a1 02 00 00       	call   800782 <strnlen>
  8004e1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004e4:	29 c1                	sub    %eax,%ecx
  8004e6:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8004e9:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004ec:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004f0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004f3:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004f6:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f8:	eb 0f                	jmp    800509 <vprintfmt+0x1d2>
					putch(padc, putdat);
  8004fa:	83 ec 08             	sub    $0x8,%esp
  8004fd:	53                   	push   %ebx
  8004fe:	ff 75 e0             	pushl  -0x20(%ebp)
  800501:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800503:	83 ef 01             	sub    $0x1,%edi
  800506:	83 c4 10             	add    $0x10,%esp
  800509:	85 ff                	test   %edi,%edi
  80050b:	7f ed                	jg     8004fa <vprintfmt+0x1c3>
  80050d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800510:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800513:	85 c9                	test   %ecx,%ecx
  800515:	b8 00 00 00 00       	mov    $0x0,%eax
  80051a:	0f 49 c1             	cmovns %ecx,%eax
  80051d:	29 c1                	sub    %eax,%ecx
  80051f:	89 75 08             	mov    %esi,0x8(%ebp)
  800522:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800525:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800528:	89 cb                	mov    %ecx,%ebx
  80052a:	eb 4d                	jmp    800579 <vprintfmt+0x242>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80052c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800530:	74 1b                	je     80054d <vprintfmt+0x216>
  800532:	0f be c0             	movsbl %al,%eax
  800535:	83 e8 20             	sub    $0x20,%eax
  800538:	83 f8 5e             	cmp    $0x5e,%eax
  80053b:	76 10                	jbe    80054d <vprintfmt+0x216>
					putch('?', putdat);
  80053d:	83 ec 08             	sub    $0x8,%esp
  800540:	ff 75 0c             	pushl  0xc(%ebp)
  800543:	6a 3f                	push   $0x3f
  800545:	ff 55 08             	call   *0x8(%ebp)
  800548:	83 c4 10             	add    $0x10,%esp
  80054b:	eb 0d                	jmp    80055a <vprintfmt+0x223>
				else
					putch(ch, putdat);
  80054d:	83 ec 08             	sub    $0x8,%esp
  800550:	ff 75 0c             	pushl  0xc(%ebp)
  800553:	52                   	push   %edx
  800554:	ff 55 08             	call   *0x8(%ebp)
  800557:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80055a:	83 eb 01             	sub    $0x1,%ebx
  80055d:	eb 1a                	jmp    800579 <vprintfmt+0x242>
  80055f:	89 75 08             	mov    %esi,0x8(%ebp)
  800562:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800565:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800568:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80056b:	eb 0c                	jmp    800579 <vprintfmt+0x242>
  80056d:	89 75 08             	mov    %esi,0x8(%ebp)
  800570:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800573:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800576:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800579:	83 c7 01             	add    $0x1,%edi
  80057c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800580:	0f be d0             	movsbl %al,%edx
  800583:	85 d2                	test   %edx,%edx
  800585:	74 23                	je     8005aa <vprintfmt+0x273>
  800587:	85 f6                	test   %esi,%esi
  800589:	78 a1                	js     80052c <vprintfmt+0x1f5>
  80058b:	83 ee 01             	sub    $0x1,%esi
  80058e:	79 9c                	jns    80052c <vprintfmt+0x1f5>
  800590:	89 df                	mov    %ebx,%edi
  800592:	8b 75 08             	mov    0x8(%ebp),%esi
  800595:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800598:	eb 18                	jmp    8005b2 <vprintfmt+0x27b>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80059a:	83 ec 08             	sub    $0x8,%esp
  80059d:	53                   	push   %ebx
  80059e:	6a 20                	push   $0x20
  8005a0:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005a2:	83 ef 01             	sub    $0x1,%edi
  8005a5:	83 c4 10             	add    $0x10,%esp
  8005a8:	eb 08                	jmp    8005b2 <vprintfmt+0x27b>
  8005aa:	89 df                	mov    %ebx,%edi
  8005ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8005af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005b2:	85 ff                	test   %edi,%edi
  8005b4:	7f e4                	jg     80059a <vprintfmt+0x263>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b9:	e9 9f fd ff ff       	jmp    80035d <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005be:	83 7d d0 01          	cmpl   $0x1,-0x30(%ebp)
  8005c2:	7e 16                	jle    8005da <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  8005c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c7:	8d 50 08             	lea    0x8(%eax),%edx
  8005ca:	89 55 14             	mov    %edx,0x14(%ebp)
  8005cd:	8b 50 04             	mov    0x4(%eax),%edx
  8005d0:	8b 00                	mov    (%eax),%eax
  8005d2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005d8:	eb 34                	jmp    80060e <vprintfmt+0x2d7>
	else if (lflag)
  8005da:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8005de:	74 18                	je     8005f8 <vprintfmt+0x2c1>
		return va_arg(*ap, long);
  8005e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e3:	8d 50 04             	lea    0x4(%eax),%edx
  8005e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e9:	8b 00                	mov    (%eax),%eax
  8005eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ee:	89 c1                	mov    %eax,%ecx
  8005f0:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005f6:	eb 16                	jmp    80060e <vprintfmt+0x2d7>
	else
		return va_arg(*ap, int);
  8005f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fb:	8d 50 04             	lea    0x4(%eax),%edx
  8005fe:	89 55 14             	mov    %edx,0x14(%ebp)
  800601:	8b 00                	mov    (%eax),%eax
  800603:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800606:	89 c1                	mov    %eax,%ecx
  800608:	c1 f9 1f             	sar    $0x1f,%ecx
  80060b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80060e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800611:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800614:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800619:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80061d:	0f 89 88 00 00 00    	jns    8006ab <vprintfmt+0x374>
				putch('-', putdat);
  800623:	83 ec 08             	sub    $0x8,%esp
  800626:	53                   	push   %ebx
  800627:	6a 2d                	push   $0x2d
  800629:	ff d6                	call   *%esi
				num = -(long long) num;
  80062b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80062e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800631:	f7 d8                	neg    %eax
  800633:	83 d2 00             	adc    $0x0,%edx
  800636:	f7 da                	neg    %edx
  800638:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80063b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800640:	eb 69                	jmp    8006ab <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800642:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800645:	8d 45 14             	lea    0x14(%ebp),%eax
  800648:	e8 76 fc ff ff       	call   8002c3 <getuint>
			base = 10;
  80064d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800652:	eb 57                	jmp    8006ab <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  800654:	83 ec 08             	sub    $0x8,%esp
  800657:	53                   	push   %ebx
  800658:	6a 30                	push   $0x30
  80065a:	ff d6                	call   *%esi
			num = getuint(&ap, lflag);
  80065c:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80065f:	8d 45 14             	lea    0x14(%ebp),%eax
  800662:	e8 5c fc ff ff       	call   8002c3 <getuint>
			base = 8;
			goto number;
  800667:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  80066a:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80066f:	eb 3a                	jmp    8006ab <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  800671:	83 ec 08             	sub    $0x8,%esp
  800674:	53                   	push   %ebx
  800675:	6a 30                	push   $0x30
  800677:	ff d6                	call   *%esi
			putch('x', putdat);
  800679:	83 c4 08             	add    $0x8,%esp
  80067c:	53                   	push   %ebx
  80067d:	6a 78                	push   $0x78
  80067f:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800681:	8b 45 14             	mov    0x14(%ebp),%eax
  800684:	8d 50 04             	lea    0x4(%eax),%edx
  800687:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80068a:	8b 00                	mov    (%eax),%eax
  80068c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800691:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800694:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800699:	eb 10                	jmp    8006ab <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80069b:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80069e:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a1:	e8 1d fc ff ff       	call   8002c3 <getuint>
			base = 16;
  8006a6:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006ab:	83 ec 0c             	sub    $0xc,%esp
  8006ae:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006b2:	57                   	push   %edi
  8006b3:	ff 75 e0             	pushl  -0x20(%ebp)
  8006b6:	51                   	push   %ecx
  8006b7:	52                   	push   %edx
  8006b8:	50                   	push   %eax
  8006b9:	89 da                	mov    %ebx,%edx
  8006bb:	89 f0                	mov    %esi,%eax
  8006bd:	e8 52 fb ff ff       	call   800214 <printnum>
			break;
  8006c2:	83 c4 20             	add    $0x20,%esp
  8006c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006c8:	e9 90 fc ff ff       	jmp    80035d <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006cd:	83 ec 08             	sub    $0x8,%esp
  8006d0:	53                   	push   %ebx
  8006d1:	52                   	push   %edx
  8006d2:	ff d6                	call   *%esi
			break;
  8006d4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006da:	e9 7e fc ff ff       	jmp    80035d <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006df:	83 ec 08             	sub    $0x8,%esp
  8006e2:	53                   	push   %ebx
  8006e3:	6a 25                	push   $0x25
  8006e5:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006e7:	83 c4 10             	add    $0x10,%esp
  8006ea:	eb 03                	jmp    8006ef <vprintfmt+0x3b8>
  8006ec:	83 ef 01             	sub    $0x1,%edi
  8006ef:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006f3:	75 f7                	jne    8006ec <vprintfmt+0x3b5>
  8006f5:	e9 63 fc ff ff       	jmp    80035d <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006fd:	5b                   	pop    %ebx
  8006fe:	5e                   	pop    %esi
  8006ff:	5f                   	pop    %edi
  800700:	5d                   	pop    %ebp
  800701:	c3                   	ret    

00800702 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800702:	55                   	push   %ebp
  800703:	89 e5                	mov    %esp,%ebp
  800705:	83 ec 18             	sub    $0x18,%esp
  800708:	8b 45 08             	mov    0x8(%ebp),%eax
  80070b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80070e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800711:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800715:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800718:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80071f:	85 c0                	test   %eax,%eax
  800721:	74 26                	je     800749 <vsnprintf+0x47>
  800723:	85 d2                	test   %edx,%edx
  800725:	7e 22                	jle    800749 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800727:	ff 75 14             	pushl  0x14(%ebp)
  80072a:	ff 75 10             	pushl  0x10(%ebp)
  80072d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800730:	50                   	push   %eax
  800731:	68 fd 02 80 00       	push   $0x8002fd
  800736:	e8 fc fb ff ff       	call   800337 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80073b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80073e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800741:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800744:	83 c4 10             	add    $0x10,%esp
  800747:	eb 05                	jmp    80074e <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800749:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80074e:	c9                   	leave  
  80074f:	c3                   	ret    

00800750 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800750:	55                   	push   %ebp
  800751:	89 e5                	mov    %esp,%ebp
  800753:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800756:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800759:	50                   	push   %eax
  80075a:	ff 75 10             	pushl  0x10(%ebp)
  80075d:	ff 75 0c             	pushl  0xc(%ebp)
  800760:	ff 75 08             	pushl  0x8(%ebp)
  800763:	e8 9a ff ff ff       	call   800702 <vsnprintf>
	va_end(ap);

	return rc;
}
  800768:	c9                   	leave  
  800769:	c3                   	ret    

0080076a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80076a:	55                   	push   %ebp
  80076b:	89 e5                	mov    %esp,%ebp
  80076d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800770:	b8 00 00 00 00       	mov    $0x0,%eax
  800775:	eb 03                	jmp    80077a <strlen+0x10>
		n++;
  800777:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80077a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80077e:	75 f7                	jne    800777 <strlen+0xd>
		n++;
	return n;
}
  800780:	5d                   	pop    %ebp
  800781:	c3                   	ret    

00800782 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800782:	55                   	push   %ebp
  800783:	89 e5                	mov    %esp,%ebp
  800785:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800788:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80078b:	ba 00 00 00 00       	mov    $0x0,%edx
  800790:	eb 03                	jmp    800795 <strnlen+0x13>
		n++;
  800792:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800795:	39 c2                	cmp    %eax,%edx
  800797:	74 08                	je     8007a1 <strnlen+0x1f>
  800799:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80079d:	75 f3                	jne    800792 <strnlen+0x10>
  80079f:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007a1:	5d                   	pop    %ebp
  8007a2:	c3                   	ret    

008007a3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007a3:	55                   	push   %ebp
  8007a4:	89 e5                	mov    %esp,%ebp
  8007a6:	53                   	push   %ebx
  8007a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007ad:	89 c2                	mov    %eax,%edx
  8007af:	83 c2 01             	add    $0x1,%edx
  8007b2:	83 c1 01             	add    $0x1,%ecx
  8007b5:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007b9:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007bc:	84 db                	test   %bl,%bl
  8007be:	75 ef                	jne    8007af <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007c0:	5b                   	pop    %ebx
  8007c1:	5d                   	pop    %ebp
  8007c2:	c3                   	ret    

008007c3 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007c3:	55                   	push   %ebp
  8007c4:	89 e5                	mov    %esp,%ebp
  8007c6:	53                   	push   %ebx
  8007c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007ca:	53                   	push   %ebx
  8007cb:	e8 9a ff ff ff       	call   80076a <strlen>
  8007d0:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007d3:	ff 75 0c             	pushl  0xc(%ebp)
  8007d6:	01 d8                	add    %ebx,%eax
  8007d8:	50                   	push   %eax
  8007d9:	e8 c5 ff ff ff       	call   8007a3 <strcpy>
	return dst;
}
  8007de:	89 d8                	mov    %ebx,%eax
  8007e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007e3:	c9                   	leave  
  8007e4:	c3                   	ret    

008007e5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007e5:	55                   	push   %ebp
  8007e6:	89 e5                	mov    %esp,%ebp
  8007e8:	56                   	push   %esi
  8007e9:	53                   	push   %ebx
  8007ea:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f0:	89 f3                	mov    %esi,%ebx
  8007f2:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007f5:	89 f2                	mov    %esi,%edx
  8007f7:	eb 0f                	jmp    800808 <strncpy+0x23>
		*dst++ = *src;
  8007f9:	83 c2 01             	add    $0x1,%edx
  8007fc:	0f b6 01             	movzbl (%ecx),%eax
  8007ff:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800802:	80 39 01             	cmpb   $0x1,(%ecx)
  800805:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800808:	39 da                	cmp    %ebx,%edx
  80080a:	75 ed                	jne    8007f9 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80080c:	89 f0                	mov    %esi,%eax
  80080e:	5b                   	pop    %ebx
  80080f:	5e                   	pop    %esi
  800810:	5d                   	pop    %ebp
  800811:	c3                   	ret    

00800812 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800812:	55                   	push   %ebp
  800813:	89 e5                	mov    %esp,%ebp
  800815:	56                   	push   %esi
  800816:	53                   	push   %ebx
  800817:	8b 75 08             	mov    0x8(%ebp),%esi
  80081a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80081d:	8b 55 10             	mov    0x10(%ebp),%edx
  800820:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800822:	85 d2                	test   %edx,%edx
  800824:	74 21                	je     800847 <strlcpy+0x35>
  800826:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80082a:	89 f2                	mov    %esi,%edx
  80082c:	eb 09                	jmp    800837 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80082e:	83 c2 01             	add    $0x1,%edx
  800831:	83 c1 01             	add    $0x1,%ecx
  800834:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800837:	39 c2                	cmp    %eax,%edx
  800839:	74 09                	je     800844 <strlcpy+0x32>
  80083b:	0f b6 19             	movzbl (%ecx),%ebx
  80083e:	84 db                	test   %bl,%bl
  800840:	75 ec                	jne    80082e <strlcpy+0x1c>
  800842:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800844:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800847:	29 f0                	sub    %esi,%eax
}
  800849:	5b                   	pop    %ebx
  80084a:	5e                   	pop    %esi
  80084b:	5d                   	pop    %ebp
  80084c:	c3                   	ret    

0080084d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80084d:	55                   	push   %ebp
  80084e:	89 e5                	mov    %esp,%ebp
  800850:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800853:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800856:	eb 06                	jmp    80085e <strcmp+0x11>
		p++, q++;
  800858:	83 c1 01             	add    $0x1,%ecx
  80085b:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80085e:	0f b6 01             	movzbl (%ecx),%eax
  800861:	84 c0                	test   %al,%al
  800863:	74 04                	je     800869 <strcmp+0x1c>
  800865:	3a 02                	cmp    (%edx),%al
  800867:	74 ef                	je     800858 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800869:	0f b6 c0             	movzbl %al,%eax
  80086c:	0f b6 12             	movzbl (%edx),%edx
  80086f:	29 d0                	sub    %edx,%eax
}
  800871:	5d                   	pop    %ebp
  800872:	c3                   	ret    

00800873 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800873:	55                   	push   %ebp
  800874:	89 e5                	mov    %esp,%ebp
  800876:	53                   	push   %ebx
  800877:	8b 45 08             	mov    0x8(%ebp),%eax
  80087a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80087d:	89 c3                	mov    %eax,%ebx
  80087f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800882:	eb 06                	jmp    80088a <strncmp+0x17>
		n--, p++, q++;
  800884:	83 c0 01             	add    $0x1,%eax
  800887:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80088a:	39 d8                	cmp    %ebx,%eax
  80088c:	74 15                	je     8008a3 <strncmp+0x30>
  80088e:	0f b6 08             	movzbl (%eax),%ecx
  800891:	84 c9                	test   %cl,%cl
  800893:	74 04                	je     800899 <strncmp+0x26>
  800895:	3a 0a                	cmp    (%edx),%cl
  800897:	74 eb                	je     800884 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800899:	0f b6 00             	movzbl (%eax),%eax
  80089c:	0f b6 12             	movzbl (%edx),%edx
  80089f:	29 d0                	sub    %edx,%eax
  8008a1:	eb 05                	jmp    8008a8 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008a3:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008a8:	5b                   	pop    %ebx
  8008a9:	5d                   	pop    %ebp
  8008aa:	c3                   	ret    

008008ab <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008b5:	eb 07                	jmp    8008be <strchr+0x13>
		if (*s == c)
  8008b7:	38 ca                	cmp    %cl,%dl
  8008b9:	74 0f                	je     8008ca <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008bb:	83 c0 01             	add    $0x1,%eax
  8008be:	0f b6 10             	movzbl (%eax),%edx
  8008c1:	84 d2                	test   %dl,%dl
  8008c3:	75 f2                	jne    8008b7 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008ca:	5d                   	pop    %ebp
  8008cb:	c3                   	ret    

008008cc <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008cc:	55                   	push   %ebp
  8008cd:	89 e5                	mov    %esp,%ebp
  8008cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008d6:	eb 03                	jmp    8008db <strfind+0xf>
  8008d8:	83 c0 01             	add    $0x1,%eax
  8008db:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008de:	38 ca                	cmp    %cl,%dl
  8008e0:	74 04                	je     8008e6 <strfind+0x1a>
  8008e2:	84 d2                	test   %dl,%dl
  8008e4:	75 f2                	jne    8008d8 <strfind+0xc>
			break;
	return (char *) s;
}
  8008e6:	5d                   	pop    %ebp
  8008e7:	c3                   	ret    

008008e8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	57                   	push   %edi
  8008ec:	56                   	push   %esi
  8008ed:	53                   	push   %ebx
  8008ee:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008f1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008f4:	85 c9                	test   %ecx,%ecx
  8008f6:	74 36                	je     80092e <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008f8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008fe:	75 28                	jne    800928 <memset+0x40>
  800900:	f6 c1 03             	test   $0x3,%cl
  800903:	75 23                	jne    800928 <memset+0x40>
		c &= 0xFF;
  800905:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800909:	89 d3                	mov    %edx,%ebx
  80090b:	c1 e3 08             	shl    $0x8,%ebx
  80090e:	89 d6                	mov    %edx,%esi
  800910:	c1 e6 18             	shl    $0x18,%esi
  800913:	89 d0                	mov    %edx,%eax
  800915:	c1 e0 10             	shl    $0x10,%eax
  800918:	09 f0                	or     %esi,%eax
  80091a:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80091c:	89 d8                	mov    %ebx,%eax
  80091e:	09 d0                	or     %edx,%eax
  800920:	c1 e9 02             	shr    $0x2,%ecx
  800923:	fc                   	cld    
  800924:	f3 ab                	rep stos %eax,%es:(%edi)
  800926:	eb 06                	jmp    80092e <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800928:	8b 45 0c             	mov    0xc(%ebp),%eax
  80092b:	fc                   	cld    
  80092c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80092e:	89 f8                	mov    %edi,%eax
  800930:	5b                   	pop    %ebx
  800931:	5e                   	pop    %esi
  800932:	5f                   	pop    %edi
  800933:	5d                   	pop    %ebp
  800934:	c3                   	ret    

00800935 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800935:	55                   	push   %ebp
  800936:	89 e5                	mov    %esp,%ebp
  800938:	57                   	push   %edi
  800939:	56                   	push   %esi
  80093a:	8b 45 08             	mov    0x8(%ebp),%eax
  80093d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800940:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800943:	39 c6                	cmp    %eax,%esi
  800945:	73 35                	jae    80097c <memmove+0x47>
  800947:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80094a:	39 d0                	cmp    %edx,%eax
  80094c:	73 2e                	jae    80097c <memmove+0x47>
		s += n;
		d += n;
  80094e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800951:	89 d6                	mov    %edx,%esi
  800953:	09 fe                	or     %edi,%esi
  800955:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80095b:	75 13                	jne    800970 <memmove+0x3b>
  80095d:	f6 c1 03             	test   $0x3,%cl
  800960:	75 0e                	jne    800970 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800962:	83 ef 04             	sub    $0x4,%edi
  800965:	8d 72 fc             	lea    -0x4(%edx),%esi
  800968:	c1 e9 02             	shr    $0x2,%ecx
  80096b:	fd                   	std    
  80096c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80096e:	eb 09                	jmp    800979 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800970:	83 ef 01             	sub    $0x1,%edi
  800973:	8d 72 ff             	lea    -0x1(%edx),%esi
  800976:	fd                   	std    
  800977:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800979:	fc                   	cld    
  80097a:	eb 1d                	jmp    800999 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80097c:	89 f2                	mov    %esi,%edx
  80097e:	09 c2                	or     %eax,%edx
  800980:	f6 c2 03             	test   $0x3,%dl
  800983:	75 0f                	jne    800994 <memmove+0x5f>
  800985:	f6 c1 03             	test   $0x3,%cl
  800988:	75 0a                	jne    800994 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80098a:	c1 e9 02             	shr    $0x2,%ecx
  80098d:	89 c7                	mov    %eax,%edi
  80098f:	fc                   	cld    
  800990:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800992:	eb 05                	jmp    800999 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800994:	89 c7                	mov    %eax,%edi
  800996:	fc                   	cld    
  800997:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800999:	5e                   	pop    %esi
  80099a:	5f                   	pop    %edi
  80099b:	5d                   	pop    %ebp
  80099c:	c3                   	ret    

0080099d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80099d:	55                   	push   %ebp
  80099e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009a0:	ff 75 10             	pushl  0x10(%ebp)
  8009a3:	ff 75 0c             	pushl  0xc(%ebp)
  8009a6:	ff 75 08             	pushl  0x8(%ebp)
  8009a9:	e8 87 ff ff ff       	call   800935 <memmove>
}
  8009ae:	c9                   	leave  
  8009af:	c3                   	ret    

008009b0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009b0:	55                   	push   %ebp
  8009b1:	89 e5                	mov    %esp,%ebp
  8009b3:	56                   	push   %esi
  8009b4:	53                   	push   %ebx
  8009b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009bb:	89 c6                	mov    %eax,%esi
  8009bd:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c0:	eb 1a                	jmp    8009dc <memcmp+0x2c>
		if (*s1 != *s2)
  8009c2:	0f b6 08             	movzbl (%eax),%ecx
  8009c5:	0f b6 1a             	movzbl (%edx),%ebx
  8009c8:	38 d9                	cmp    %bl,%cl
  8009ca:	74 0a                	je     8009d6 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009cc:	0f b6 c1             	movzbl %cl,%eax
  8009cf:	0f b6 db             	movzbl %bl,%ebx
  8009d2:	29 d8                	sub    %ebx,%eax
  8009d4:	eb 0f                	jmp    8009e5 <memcmp+0x35>
		s1++, s2++;
  8009d6:	83 c0 01             	add    $0x1,%eax
  8009d9:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009dc:	39 f0                	cmp    %esi,%eax
  8009de:	75 e2                	jne    8009c2 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e5:	5b                   	pop    %ebx
  8009e6:	5e                   	pop    %esi
  8009e7:	5d                   	pop    %ebp
  8009e8:	c3                   	ret    

008009e9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009e9:	55                   	push   %ebp
  8009ea:	89 e5                	mov    %esp,%ebp
  8009ec:	53                   	push   %ebx
  8009ed:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009f0:	89 c1                	mov    %eax,%ecx
  8009f2:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009f5:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009f9:	eb 0a                	jmp    800a05 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009fb:	0f b6 10             	movzbl (%eax),%edx
  8009fe:	39 da                	cmp    %ebx,%edx
  800a00:	74 07                	je     800a09 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a02:	83 c0 01             	add    $0x1,%eax
  800a05:	39 c8                	cmp    %ecx,%eax
  800a07:	72 f2                	jb     8009fb <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a09:	5b                   	pop    %ebx
  800a0a:	5d                   	pop    %ebp
  800a0b:	c3                   	ret    

00800a0c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a0c:	55                   	push   %ebp
  800a0d:	89 e5                	mov    %esp,%ebp
  800a0f:	57                   	push   %edi
  800a10:	56                   	push   %esi
  800a11:	53                   	push   %ebx
  800a12:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a15:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a18:	eb 03                	jmp    800a1d <strtol+0x11>
		s++;
  800a1a:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a1d:	0f b6 01             	movzbl (%ecx),%eax
  800a20:	3c 20                	cmp    $0x20,%al
  800a22:	74 f6                	je     800a1a <strtol+0xe>
  800a24:	3c 09                	cmp    $0x9,%al
  800a26:	74 f2                	je     800a1a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a28:	3c 2b                	cmp    $0x2b,%al
  800a2a:	75 0a                	jne    800a36 <strtol+0x2a>
		s++;
  800a2c:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a2f:	bf 00 00 00 00       	mov    $0x0,%edi
  800a34:	eb 11                	jmp    800a47 <strtol+0x3b>
  800a36:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a3b:	3c 2d                	cmp    $0x2d,%al
  800a3d:	75 08                	jne    800a47 <strtol+0x3b>
		s++, neg = 1;
  800a3f:	83 c1 01             	add    $0x1,%ecx
  800a42:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a47:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a4d:	75 15                	jne    800a64 <strtol+0x58>
  800a4f:	80 39 30             	cmpb   $0x30,(%ecx)
  800a52:	75 10                	jne    800a64 <strtol+0x58>
  800a54:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a58:	75 7c                	jne    800ad6 <strtol+0xca>
		s += 2, base = 16;
  800a5a:	83 c1 02             	add    $0x2,%ecx
  800a5d:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a62:	eb 16                	jmp    800a7a <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a64:	85 db                	test   %ebx,%ebx
  800a66:	75 12                	jne    800a7a <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a68:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a6d:	80 39 30             	cmpb   $0x30,(%ecx)
  800a70:	75 08                	jne    800a7a <strtol+0x6e>
		s++, base = 8;
  800a72:	83 c1 01             	add    $0x1,%ecx
  800a75:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a7a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a7f:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a82:	0f b6 11             	movzbl (%ecx),%edx
  800a85:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a88:	89 f3                	mov    %esi,%ebx
  800a8a:	80 fb 09             	cmp    $0x9,%bl
  800a8d:	77 08                	ja     800a97 <strtol+0x8b>
			dig = *s - '0';
  800a8f:	0f be d2             	movsbl %dl,%edx
  800a92:	83 ea 30             	sub    $0x30,%edx
  800a95:	eb 22                	jmp    800ab9 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a97:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a9a:	89 f3                	mov    %esi,%ebx
  800a9c:	80 fb 19             	cmp    $0x19,%bl
  800a9f:	77 08                	ja     800aa9 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800aa1:	0f be d2             	movsbl %dl,%edx
  800aa4:	83 ea 57             	sub    $0x57,%edx
  800aa7:	eb 10                	jmp    800ab9 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800aa9:	8d 72 bf             	lea    -0x41(%edx),%esi
  800aac:	89 f3                	mov    %esi,%ebx
  800aae:	80 fb 19             	cmp    $0x19,%bl
  800ab1:	77 16                	ja     800ac9 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ab3:	0f be d2             	movsbl %dl,%edx
  800ab6:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ab9:	3b 55 10             	cmp    0x10(%ebp),%edx
  800abc:	7d 0b                	jge    800ac9 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800abe:	83 c1 01             	add    $0x1,%ecx
  800ac1:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ac5:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ac7:	eb b9                	jmp    800a82 <strtol+0x76>

	if (endptr)
  800ac9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800acd:	74 0d                	je     800adc <strtol+0xd0>
		*endptr = (char *) s;
  800acf:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ad2:	89 0e                	mov    %ecx,(%esi)
  800ad4:	eb 06                	jmp    800adc <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ad6:	85 db                	test   %ebx,%ebx
  800ad8:	74 98                	je     800a72 <strtol+0x66>
  800ada:	eb 9e                	jmp    800a7a <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800adc:	89 c2                	mov    %eax,%edx
  800ade:	f7 da                	neg    %edx
  800ae0:	85 ff                	test   %edi,%edi
  800ae2:	0f 45 c2             	cmovne %edx,%eax
}
  800ae5:	5b                   	pop    %ebx
  800ae6:	5e                   	pop    %esi
  800ae7:	5f                   	pop    %edi
  800ae8:	5d                   	pop    %ebp
  800ae9:	c3                   	ret    

00800aea <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aea:	55                   	push   %ebp
  800aeb:	89 e5                	mov    %esp,%ebp
  800aed:	57                   	push   %edi
  800aee:	56                   	push   %esi
  800aef:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af0:	b8 00 00 00 00       	mov    $0x0,%eax
  800af5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800af8:	8b 55 08             	mov    0x8(%ebp),%edx
  800afb:	89 c3                	mov    %eax,%ebx
  800afd:	89 c7                	mov    %eax,%edi
  800aff:	89 c6                	mov    %eax,%esi
  800b01:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b03:	5b                   	pop    %ebx
  800b04:	5e                   	pop    %esi
  800b05:	5f                   	pop    %edi
  800b06:	5d                   	pop    %ebp
  800b07:	c3                   	ret    

00800b08 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b08:	55                   	push   %ebp
  800b09:	89 e5                	mov    %esp,%ebp
  800b0b:	57                   	push   %edi
  800b0c:	56                   	push   %esi
  800b0d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b0e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b13:	b8 01 00 00 00       	mov    $0x1,%eax
  800b18:	89 d1                	mov    %edx,%ecx
  800b1a:	89 d3                	mov    %edx,%ebx
  800b1c:	89 d7                	mov    %edx,%edi
  800b1e:	89 d6                	mov    %edx,%esi
  800b20:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b22:	5b                   	pop    %ebx
  800b23:	5e                   	pop    %esi
  800b24:	5f                   	pop    %edi
  800b25:	5d                   	pop    %ebp
  800b26:	c3                   	ret    

00800b27 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b27:	55                   	push   %ebp
  800b28:	89 e5                	mov    %esp,%ebp
  800b2a:	57                   	push   %edi
  800b2b:	56                   	push   %esi
  800b2c:	53                   	push   %ebx
  800b2d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b30:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b35:	b8 03 00 00 00       	mov    $0x3,%eax
  800b3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b3d:	89 cb                	mov    %ecx,%ebx
  800b3f:	89 cf                	mov    %ecx,%edi
  800b41:	89 ce                	mov    %ecx,%esi
  800b43:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b45:	85 c0                	test   %eax,%eax
  800b47:	7e 17                	jle    800b60 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b49:	83 ec 0c             	sub    $0xc,%esp
  800b4c:	50                   	push   %eax
  800b4d:	6a 03                	push   $0x3
  800b4f:	68 1f 24 80 00       	push   $0x80241f
  800b54:	6a 23                	push   $0x23
  800b56:	68 3c 24 80 00       	push   $0x80243c
  800b5b:	e8 85 11 00 00       	call   801ce5 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b60:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b63:	5b                   	pop    %ebx
  800b64:	5e                   	pop    %esi
  800b65:	5f                   	pop    %edi
  800b66:	5d                   	pop    %ebp
  800b67:	c3                   	ret    

00800b68 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b68:	55                   	push   %ebp
  800b69:	89 e5                	mov    %esp,%ebp
  800b6b:	57                   	push   %edi
  800b6c:	56                   	push   %esi
  800b6d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b73:	b8 02 00 00 00       	mov    $0x2,%eax
  800b78:	89 d1                	mov    %edx,%ecx
  800b7a:	89 d3                	mov    %edx,%ebx
  800b7c:	89 d7                	mov    %edx,%edi
  800b7e:	89 d6                	mov    %edx,%esi
  800b80:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b82:	5b                   	pop    %ebx
  800b83:	5e                   	pop    %esi
  800b84:	5f                   	pop    %edi
  800b85:	5d                   	pop    %ebp
  800b86:	c3                   	ret    

00800b87 <sys_yield>:

void
sys_yield(void)
{
  800b87:	55                   	push   %ebp
  800b88:	89 e5                	mov    %esp,%ebp
  800b8a:	57                   	push   %edi
  800b8b:	56                   	push   %esi
  800b8c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b92:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b97:	89 d1                	mov    %edx,%ecx
  800b99:	89 d3                	mov    %edx,%ebx
  800b9b:	89 d7                	mov    %edx,%edi
  800b9d:	89 d6                	mov    %edx,%esi
  800b9f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ba1:	5b                   	pop    %ebx
  800ba2:	5e                   	pop    %esi
  800ba3:	5f                   	pop    %edi
  800ba4:	5d                   	pop    %ebp
  800ba5:	c3                   	ret    

00800ba6 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ba6:	55                   	push   %ebp
  800ba7:	89 e5                	mov    %esp,%ebp
  800ba9:	57                   	push   %edi
  800baa:	56                   	push   %esi
  800bab:	53                   	push   %ebx
  800bac:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800baf:	be 00 00 00 00       	mov    $0x0,%esi
  800bb4:	b8 04 00 00 00       	mov    $0x4,%eax
  800bb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bc2:	89 f7                	mov    %esi,%edi
  800bc4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bc6:	85 c0                	test   %eax,%eax
  800bc8:	7e 17                	jle    800be1 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bca:	83 ec 0c             	sub    $0xc,%esp
  800bcd:	50                   	push   %eax
  800bce:	6a 04                	push   $0x4
  800bd0:	68 1f 24 80 00       	push   $0x80241f
  800bd5:	6a 23                	push   $0x23
  800bd7:	68 3c 24 80 00       	push   $0x80243c
  800bdc:	e8 04 11 00 00       	call   801ce5 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800be1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be4:	5b                   	pop    %ebx
  800be5:	5e                   	pop    %esi
  800be6:	5f                   	pop    %edi
  800be7:	5d                   	pop    %ebp
  800be8:	c3                   	ret    

00800be9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800be9:	55                   	push   %ebp
  800bea:	89 e5                	mov    %esp,%ebp
  800bec:	57                   	push   %edi
  800bed:	56                   	push   %esi
  800bee:	53                   	push   %ebx
  800bef:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf2:	b8 05 00 00 00       	mov    $0x5,%eax
  800bf7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c00:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c03:	8b 75 18             	mov    0x18(%ebp),%esi
  800c06:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c08:	85 c0                	test   %eax,%eax
  800c0a:	7e 17                	jle    800c23 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c0c:	83 ec 0c             	sub    $0xc,%esp
  800c0f:	50                   	push   %eax
  800c10:	6a 05                	push   $0x5
  800c12:	68 1f 24 80 00       	push   $0x80241f
  800c17:	6a 23                	push   $0x23
  800c19:	68 3c 24 80 00       	push   $0x80243c
  800c1e:	e8 c2 10 00 00       	call   801ce5 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c23:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c26:	5b                   	pop    %ebx
  800c27:	5e                   	pop    %esi
  800c28:	5f                   	pop    %edi
  800c29:	5d                   	pop    %ebp
  800c2a:	c3                   	ret    

00800c2b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c2b:	55                   	push   %ebp
  800c2c:	89 e5                	mov    %esp,%ebp
  800c2e:	57                   	push   %edi
  800c2f:	56                   	push   %esi
  800c30:	53                   	push   %ebx
  800c31:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c34:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c39:	b8 06 00 00 00       	mov    $0x6,%eax
  800c3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c41:	8b 55 08             	mov    0x8(%ebp),%edx
  800c44:	89 df                	mov    %ebx,%edi
  800c46:	89 de                	mov    %ebx,%esi
  800c48:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c4a:	85 c0                	test   %eax,%eax
  800c4c:	7e 17                	jle    800c65 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4e:	83 ec 0c             	sub    $0xc,%esp
  800c51:	50                   	push   %eax
  800c52:	6a 06                	push   $0x6
  800c54:	68 1f 24 80 00       	push   $0x80241f
  800c59:	6a 23                	push   $0x23
  800c5b:	68 3c 24 80 00       	push   $0x80243c
  800c60:	e8 80 10 00 00       	call   801ce5 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c68:	5b                   	pop    %ebx
  800c69:	5e                   	pop    %esi
  800c6a:	5f                   	pop    %edi
  800c6b:	5d                   	pop    %ebp
  800c6c:	c3                   	ret    

00800c6d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c6d:	55                   	push   %ebp
  800c6e:	89 e5                	mov    %esp,%ebp
  800c70:	57                   	push   %edi
  800c71:	56                   	push   %esi
  800c72:	53                   	push   %ebx
  800c73:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c76:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c7b:	b8 08 00 00 00       	mov    $0x8,%eax
  800c80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c83:	8b 55 08             	mov    0x8(%ebp),%edx
  800c86:	89 df                	mov    %ebx,%edi
  800c88:	89 de                	mov    %ebx,%esi
  800c8a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c8c:	85 c0                	test   %eax,%eax
  800c8e:	7e 17                	jle    800ca7 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c90:	83 ec 0c             	sub    $0xc,%esp
  800c93:	50                   	push   %eax
  800c94:	6a 08                	push   $0x8
  800c96:	68 1f 24 80 00       	push   $0x80241f
  800c9b:	6a 23                	push   $0x23
  800c9d:	68 3c 24 80 00       	push   $0x80243c
  800ca2:	e8 3e 10 00 00       	call   801ce5 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ca7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800caa:	5b                   	pop    %ebx
  800cab:	5e                   	pop    %esi
  800cac:	5f                   	pop    %edi
  800cad:	5d                   	pop    %ebp
  800cae:	c3                   	ret    

00800caf <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800caf:	55                   	push   %ebp
  800cb0:	89 e5                	mov    %esp,%ebp
  800cb2:	57                   	push   %edi
  800cb3:	56                   	push   %esi
  800cb4:	53                   	push   %ebx
  800cb5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cbd:	b8 09 00 00 00       	mov    $0x9,%eax
  800cc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc8:	89 df                	mov    %ebx,%edi
  800cca:	89 de                	mov    %ebx,%esi
  800ccc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cce:	85 c0                	test   %eax,%eax
  800cd0:	7e 17                	jle    800ce9 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd2:	83 ec 0c             	sub    $0xc,%esp
  800cd5:	50                   	push   %eax
  800cd6:	6a 09                	push   $0x9
  800cd8:	68 1f 24 80 00       	push   $0x80241f
  800cdd:	6a 23                	push   $0x23
  800cdf:	68 3c 24 80 00       	push   $0x80243c
  800ce4:	e8 fc 0f 00 00       	call   801ce5 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ce9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cec:	5b                   	pop    %ebx
  800ced:	5e                   	pop    %esi
  800cee:	5f                   	pop    %edi
  800cef:	5d                   	pop    %ebp
  800cf0:	c3                   	ret    

00800cf1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cf1:	55                   	push   %ebp
  800cf2:	89 e5                	mov    %esp,%ebp
  800cf4:	57                   	push   %edi
  800cf5:	56                   	push   %esi
  800cf6:	53                   	push   %ebx
  800cf7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfa:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cff:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d07:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0a:	89 df                	mov    %ebx,%edi
  800d0c:	89 de                	mov    %ebx,%esi
  800d0e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d10:	85 c0                	test   %eax,%eax
  800d12:	7e 17                	jle    800d2b <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d14:	83 ec 0c             	sub    $0xc,%esp
  800d17:	50                   	push   %eax
  800d18:	6a 0a                	push   $0xa
  800d1a:	68 1f 24 80 00       	push   $0x80241f
  800d1f:	6a 23                	push   $0x23
  800d21:	68 3c 24 80 00       	push   $0x80243c
  800d26:	e8 ba 0f 00 00       	call   801ce5 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2e:	5b                   	pop    %ebx
  800d2f:	5e                   	pop    %esi
  800d30:	5f                   	pop    %edi
  800d31:	5d                   	pop    %ebp
  800d32:	c3                   	ret    

00800d33 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d33:	55                   	push   %ebp
  800d34:	89 e5                	mov    %esp,%ebp
  800d36:	57                   	push   %edi
  800d37:	56                   	push   %esi
  800d38:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d39:	be 00 00 00 00       	mov    $0x0,%esi
  800d3e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d46:	8b 55 08             	mov    0x8(%ebp),%edx
  800d49:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d4c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d4f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d51:	5b                   	pop    %ebx
  800d52:	5e                   	pop    %esi
  800d53:	5f                   	pop    %edi
  800d54:	5d                   	pop    %ebp
  800d55:	c3                   	ret    

00800d56 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d56:	55                   	push   %ebp
  800d57:	89 e5                	mov    %esp,%ebp
  800d59:	57                   	push   %edi
  800d5a:	56                   	push   %esi
  800d5b:	53                   	push   %ebx
  800d5c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d64:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d69:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6c:	89 cb                	mov    %ecx,%ebx
  800d6e:	89 cf                	mov    %ecx,%edi
  800d70:	89 ce                	mov    %ecx,%esi
  800d72:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d74:	85 c0                	test   %eax,%eax
  800d76:	7e 17                	jle    800d8f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d78:	83 ec 0c             	sub    $0xc,%esp
  800d7b:	50                   	push   %eax
  800d7c:	6a 0d                	push   $0xd
  800d7e:	68 1f 24 80 00       	push   $0x80241f
  800d83:	6a 23                	push   $0x23
  800d85:	68 3c 24 80 00       	push   $0x80243c
  800d8a:	e8 56 0f 00 00       	call   801ce5 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d92:	5b                   	pop    %ebx
  800d93:	5e                   	pop    %esi
  800d94:	5f                   	pop    %edi
  800d95:	5d                   	pop    %ebp
  800d96:	c3                   	ret    

00800d97 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  800d97:	55                   	push   %ebp
  800d98:	89 e5                	mov    %esp,%ebp
  800d9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da0:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  800da3:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  800da5:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  800da8:	83 3a 01             	cmpl   $0x1,(%edx)
  800dab:	7e 09                	jle    800db6 <argstart+0x1f>
  800dad:	ba f1 20 80 00       	mov    $0x8020f1,%edx
  800db2:	85 c9                	test   %ecx,%ecx
  800db4:	75 05                	jne    800dbb <argstart+0x24>
  800db6:	ba 00 00 00 00       	mov    $0x0,%edx
  800dbb:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  800dbe:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  800dc5:	5d                   	pop    %ebp
  800dc6:	c3                   	ret    

00800dc7 <argnext>:

int
argnext(struct Argstate *args)
{
  800dc7:	55                   	push   %ebp
  800dc8:	89 e5                	mov    %esp,%ebp
  800dca:	53                   	push   %ebx
  800dcb:	83 ec 04             	sub    $0x4,%esp
  800dce:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  800dd1:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  800dd8:	8b 43 08             	mov    0x8(%ebx),%eax
  800ddb:	85 c0                	test   %eax,%eax
  800ddd:	74 6f                	je     800e4e <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  800ddf:	80 38 00             	cmpb   $0x0,(%eax)
  800de2:	75 4e                	jne    800e32 <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  800de4:	8b 0b                	mov    (%ebx),%ecx
  800de6:	83 39 01             	cmpl   $0x1,(%ecx)
  800de9:	74 55                	je     800e40 <argnext+0x79>
		    || args->argv[1][0] != '-'
  800deb:	8b 53 04             	mov    0x4(%ebx),%edx
  800dee:	8b 42 04             	mov    0x4(%edx),%eax
  800df1:	80 38 2d             	cmpb   $0x2d,(%eax)
  800df4:	75 4a                	jne    800e40 <argnext+0x79>
		    || args->argv[1][1] == '\0')
  800df6:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800dfa:	74 44                	je     800e40 <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  800dfc:	83 c0 01             	add    $0x1,%eax
  800dff:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800e02:	83 ec 04             	sub    $0x4,%esp
  800e05:	8b 01                	mov    (%ecx),%eax
  800e07:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  800e0e:	50                   	push   %eax
  800e0f:	8d 42 08             	lea    0x8(%edx),%eax
  800e12:	50                   	push   %eax
  800e13:	83 c2 04             	add    $0x4,%edx
  800e16:	52                   	push   %edx
  800e17:	e8 19 fb ff ff       	call   800935 <memmove>
		(*args->argc)--;
  800e1c:	8b 03                	mov    (%ebx),%eax
  800e1e:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  800e21:	8b 43 08             	mov    0x8(%ebx),%eax
  800e24:	83 c4 10             	add    $0x10,%esp
  800e27:	80 38 2d             	cmpb   $0x2d,(%eax)
  800e2a:	75 06                	jne    800e32 <argnext+0x6b>
  800e2c:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800e30:	74 0e                	je     800e40 <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  800e32:	8b 53 08             	mov    0x8(%ebx),%edx
  800e35:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  800e38:	83 c2 01             	add    $0x1,%edx
  800e3b:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  800e3e:	eb 13                	jmp    800e53 <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  800e40:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  800e47:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800e4c:	eb 05                	jmp    800e53 <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  800e4e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  800e53:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e56:	c9                   	leave  
  800e57:	c3                   	ret    

00800e58 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  800e58:	55                   	push   %ebp
  800e59:	89 e5                	mov    %esp,%ebp
  800e5b:	53                   	push   %ebx
  800e5c:	83 ec 04             	sub    $0x4,%esp
  800e5f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  800e62:	8b 43 08             	mov    0x8(%ebx),%eax
  800e65:	85 c0                	test   %eax,%eax
  800e67:	74 58                	je     800ec1 <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  800e69:	80 38 00             	cmpb   $0x0,(%eax)
  800e6c:	74 0c                	je     800e7a <argnextvalue+0x22>
		args->argvalue = args->curarg;
  800e6e:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  800e71:	c7 43 08 f1 20 80 00 	movl   $0x8020f1,0x8(%ebx)
  800e78:	eb 42                	jmp    800ebc <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  800e7a:	8b 13                	mov    (%ebx),%edx
  800e7c:	83 3a 01             	cmpl   $0x1,(%edx)
  800e7f:	7e 2d                	jle    800eae <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  800e81:	8b 43 04             	mov    0x4(%ebx),%eax
  800e84:	8b 48 04             	mov    0x4(%eax),%ecx
  800e87:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800e8a:	83 ec 04             	sub    $0x4,%esp
  800e8d:	8b 12                	mov    (%edx),%edx
  800e8f:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  800e96:	52                   	push   %edx
  800e97:	8d 50 08             	lea    0x8(%eax),%edx
  800e9a:	52                   	push   %edx
  800e9b:	83 c0 04             	add    $0x4,%eax
  800e9e:	50                   	push   %eax
  800e9f:	e8 91 fa ff ff       	call   800935 <memmove>
		(*args->argc)--;
  800ea4:	8b 03                	mov    (%ebx),%eax
  800ea6:	83 28 01             	subl   $0x1,(%eax)
  800ea9:	83 c4 10             	add    $0x10,%esp
  800eac:	eb 0e                	jmp    800ebc <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  800eae:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  800eb5:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  800ebc:	8b 43 0c             	mov    0xc(%ebx),%eax
  800ebf:	eb 05                	jmp    800ec6 <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  800ec1:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  800ec6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ec9:	c9                   	leave  
  800eca:	c3                   	ret    

00800ecb <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  800ecb:	55                   	push   %ebp
  800ecc:	89 e5                	mov    %esp,%ebp
  800ece:	83 ec 08             	sub    $0x8,%esp
  800ed1:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  800ed4:	8b 51 0c             	mov    0xc(%ecx),%edx
  800ed7:	89 d0                	mov    %edx,%eax
  800ed9:	85 d2                	test   %edx,%edx
  800edb:	75 0c                	jne    800ee9 <argvalue+0x1e>
  800edd:	83 ec 0c             	sub    $0xc,%esp
  800ee0:	51                   	push   %ecx
  800ee1:	e8 72 ff ff ff       	call   800e58 <argnextvalue>
  800ee6:	83 c4 10             	add    $0x10,%esp
}
  800ee9:	c9                   	leave  
  800eea:	c3                   	ret    

00800eeb <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800eeb:	55                   	push   %ebp
  800eec:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800eee:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef1:	05 00 00 00 30       	add    $0x30000000,%eax
  800ef6:	c1 e8 0c             	shr    $0xc,%eax
}
  800ef9:	5d                   	pop    %ebp
  800efa:	c3                   	ret    

00800efb <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800efb:	55                   	push   %ebp
  800efc:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800efe:	8b 45 08             	mov    0x8(%ebp),%eax
  800f01:	05 00 00 00 30       	add    $0x30000000,%eax
  800f06:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f0b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800f10:	5d                   	pop    %ebp
  800f11:	c3                   	ret    

00800f12 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f12:	55                   	push   %ebp
  800f13:	89 e5                	mov    %esp,%ebp
  800f15:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f18:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f1d:	89 c2                	mov    %eax,%edx
  800f1f:	c1 ea 16             	shr    $0x16,%edx
  800f22:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f29:	f6 c2 01             	test   $0x1,%dl
  800f2c:	74 11                	je     800f3f <fd_alloc+0x2d>
  800f2e:	89 c2                	mov    %eax,%edx
  800f30:	c1 ea 0c             	shr    $0xc,%edx
  800f33:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f3a:	f6 c2 01             	test   $0x1,%dl
  800f3d:	75 09                	jne    800f48 <fd_alloc+0x36>
			*fd_store = fd;
  800f3f:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f41:	b8 00 00 00 00       	mov    $0x0,%eax
  800f46:	eb 17                	jmp    800f5f <fd_alloc+0x4d>
  800f48:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f4d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f52:	75 c9                	jne    800f1d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f54:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800f5a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f5f:	5d                   	pop    %ebp
  800f60:	c3                   	ret    

00800f61 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f61:	55                   	push   %ebp
  800f62:	89 e5                	mov    %esp,%ebp
  800f64:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f67:	83 f8 1f             	cmp    $0x1f,%eax
  800f6a:	77 36                	ja     800fa2 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f6c:	c1 e0 0c             	shl    $0xc,%eax
  800f6f:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f74:	89 c2                	mov    %eax,%edx
  800f76:	c1 ea 16             	shr    $0x16,%edx
  800f79:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f80:	f6 c2 01             	test   $0x1,%dl
  800f83:	74 24                	je     800fa9 <fd_lookup+0x48>
  800f85:	89 c2                	mov    %eax,%edx
  800f87:	c1 ea 0c             	shr    $0xc,%edx
  800f8a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f91:	f6 c2 01             	test   $0x1,%dl
  800f94:	74 1a                	je     800fb0 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f96:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f99:	89 02                	mov    %eax,(%edx)
	return 0;
  800f9b:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa0:	eb 13                	jmp    800fb5 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fa2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fa7:	eb 0c                	jmp    800fb5 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fa9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fae:	eb 05                	jmp    800fb5 <fd_lookup+0x54>
  800fb0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800fb5:	5d                   	pop    %ebp
  800fb6:	c3                   	ret    

00800fb7 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800fb7:	55                   	push   %ebp
  800fb8:	89 e5                	mov    %esp,%ebp
  800fba:	83 ec 08             	sub    $0x8,%esp
  800fbd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fc0:	ba c8 24 80 00       	mov    $0x8024c8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800fc5:	eb 13                	jmp    800fda <dev_lookup+0x23>
  800fc7:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800fca:	39 08                	cmp    %ecx,(%eax)
  800fcc:	75 0c                	jne    800fda <dev_lookup+0x23>
			*dev = devtab[i];
  800fce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fd1:	89 01                	mov    %eax,(%ecx)
			return 0;
  800fd3:	b8 00 00 00 00       	mov    $0x0,%eax
  800fd8:	eb 2e                	jmp    801008 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800fda:	8b 02                	mov    (%edx),%eax
  800fdc:	85 c0                	test   %eax,%eax
  800fde:	75 e7                	jne    800fc7 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800fe0:	a1 04 40 80 00       	mov    0x804004,%eax
  800fe5:	8b 40 48             	mov    0x48(%eax),%eax
  800fe8:	83 ec 04             	sub    $0x4,%esp
  800feb:	51                   	push   %ecx
  800fec:	50                   	push   %eax
  800fed:	68 4c 24 80 00       	push   $0x80244c
  800ff2:	e8 09 f2 ff ff       	call   800200 <cprintf>
	*dev = 0;
  800ff7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ffa:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801000:	83 c4 10             	add    $0x10,%esp
  801003:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801008:	c9                   	leave  
  801009:	c3                   	ret    

0080100a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80100a:	55                   	push   %ebp
  80100b:	89 e5                	mov    %esp,%ebp
  80100d:	56                   	push   %esi
  80100e:	53                   	push   %ebx
  80100f:	83 ec 10             	sub    $0x10,%esp
  801012:	8b 75 08             	mov    0x8(%ebp),%esi
  801015:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801018:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80101b:	50                   	push   %eax
  80101c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801022:	c1 e8 0c             	shr    $0xc,%eax
  801025:	50                   	push   %eax
  801026:	e8 36 ff ff ff       	call   800f61 <fd_lookup>
  80102b:	83 c4 08             	add    $0x8,%esp
  80102e:	85 c0                	test   %eax,%eax
  801030:	78 05                	js     801037 <fd_close+0x2d>
	    || fd != fd2)
  801032:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801035:	74 0c                	je     801043 <fd_close+0x39>
		return (must_exist ? r : 0);
  801037:	84 db                	test   %bl,%bl
  801039:	ba 00 00 00 00       	mov    $0x0,%edx
  80103e:	0f 44 c2             	cmove  %edx,%eax
  801041:	eb 41                	jmp    801084 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801043:	83 ec 08             	sub    $0x8,%esp
  801046:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801049:	50                   	push   %eax
  80104a:	ff 36                	pushl  (%esi)
  80104c:	e8 66 ff ff ff       	call   800fb7 <dev_lookup>
  801051:	89 c3                	mov    %eax,%ebx
  801053:	83 c4 10             	add    $0x10,%esp
  801056:	85 c0                	test   %eax,%eax
  801058:	78 1a                	js     801074 <fd_close+0x6a>
		if (dev->dev_close)
  80105a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80105d:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801060:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801065:	85 c0                	test   %eax,%eax
  801067:	74 0b                	je     801074 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801069:	83 ec 0c             	sub    $0xc,%esp
  80106c:	56                   	push   %esi
  80106d:	ff d0                	call   *%eax
  80106f:	89 c3                	mov    %eax,%ebx
  801071:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801074:	83 ec 08             	sub    $0x8,%esp
  801077:	56                   	push   %esi
  801078:	6a 00                	push   $0x0
  80107a:	e8 ac fb ff ff       	call   800c2b <sys_page_unmap>
	return r;
  80107f:	83 c4 10             	add    $0x10,%esp
  801082:	89 d8                	mov    %ebx,%eax
}
  801084:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801087:	5b                   	pop    %ebx
  801088:	5e                   	pop    %esi
  801089:	5d                   	pop    %ebp
  80108a:	c3                   	ret    

0080108b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80108b:	55                   	push   %ebp
  80108c:	89 e5                	mov    %esp,%ebp
  80108e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801091:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801094:	50                   	push   %eax
  801095:	ff 75 08             	pushl  0x8(%ebp)
  801098:	e8 c4 fe ff ff       	call   800f61 <fd_lookup>
  80109d:	83 c4 08             	add    $0x8,%esp
  8010a0:	85 c0                	test   %eax,%eax
  8010a2:	78 10                	js     8010b4 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8010a4:	83 ec 08             	sub    $0x8,%esp
  8010a7:	6a 01                	push   $0x1
  8010a9:	ff 75 f4             	pushl  -0xc(%ebp)
  8010ac:	e8 59 ff ff ff       	call   80100a <fd_close>
  8010b1:	83 c4 10             	add    $0x10,%esp
}
  8010b4:	c9                   	leave  
  8010b5:	c3                   	ret    

008010b6 <close_all>:

void
close_all(void)
{
  8010b6:	55                   	push   %ebp
  8010b7:	89 e5                	mov    %esp,%ebp
  8010b9:	53                   	push   %ebx
  8010ba:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8010bd:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8010c2:	83 ec 0c             	sub    $0xc,%esp
  8010c5:	53                   	push   %ebx
  8010c6:	e8 c0 ff ff ff       	call   80108b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8010cb:	83 c3 01             	add    $0x1,%ebx
  8010ce:	83 c4 10             	add    $0x10,%esp
  8010d1:	83 fb 20             	cmp    $0x20,%ebx
  8010d4:	75 ec                	jne    8010c2 <close_all+0xc>
		close(i);
}
  8010d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010d9:	c9                   	leave  
  8010da:	c3                   	ret    

008010db <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010db:	55                   	push   %ebp
  8010dc:	89 e5                	mov    %esp,%ebp
  8010de:	57                   	push   %edi
  8010df:	56                   	push   %esi
  8010e0:	53                   	push   %ebx
  8010e1:	83 ec 2c             	sub    $0x2c,%esp
  8010e4:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010e7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010ea:	50                   	push   %eax
  8010eb:	ff 75 08             	pushl  0x8(%ebp)
  8010ee:	e8 6e fe ff ff       	call   800f61 <fd_lookup>
  8010f3:	83 c4 08             	add    $0x8,%esp
  8010f6:	85 c0                	test   %eax,%eax
  8010f8:	0f 88 c1 00 00 00    	js     8011bf <dup+0xe4>
		return r;
	close(newfdnum);
  8010fe:	83 ec 0c             	sub    $0xc,%esp
  801101:	56                   	push   %esi
  801102:	e8 84 ff ff ff       	call   80108b <close>

	newfd = INDEX2FD(newfdnum);
  801107:	89 f3                	mov    %esi,%ebx
  801109:	c1 e3 0c             	shl    $0xc,%ebx
  80110c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801112:	83 c4 04             	add    $0x4,%esp
  801115:	ff 75 e4             	pushl  -0x1c(%ebp)
  801118:	e8 de fd ff ff       	call   800efb <fd2data>
  80111d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80111f:	89 1c 24             	mov    %ebx,(%esp)
  801122:	e8 d4 fd ff ff       	call   800efb <fd2data>
  801127:	83 c4 10             	add    $0x10,%esp
  80112a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80112d:	89 f8                	mov    %edi,%eax
  80112f:	c1 e8 16             	shr    $0x16,%eax
  801132:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801139:	a8 01                	test   $0x1,%al
  80113b:	74 37                	je     801174 <dup+0x99>
  80113d:	89 f8                	mov    %edi,%eax
  80113f:	c1 e8 0c             	shr    $0xc,%eax
  801142:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801149:	f6 c2 01             	test   $0x1,%dl
  80114c:	74 26                	je     801174 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80114e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801155:	83 ec 0c             	sub    $0xc,%esp
  801158:	25 07 0e 00 00       	and    $0xe07,%eax
  80115d:	50                   	push   %eax
  80115e:	ff 75 d4             	pushl  -0x2c(%ebp)
  801161:	6a 00                	push   $0x0
  801163:	57                   	push   %edi
  801164:	6a 00                	push   $0x0
  801166:	e8 7e fa ff ff       	call   800be9 <sys_page_map>
  80116b:	89 c7                	mov    %eax,%edi
  80116d:	83 c4 20             	add    $0x20,%esp
  801170:	85 c0                	test   %eax,%eax
  801172:	78 2e                	js     8011a2 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801174:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801177:	89 d0                	mov    %edx,%eax
  801179:	c1 e8 0c             	shr    $0xc,%eax
  80117c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801183:	83 ec 0c             	sub    $0xc,%esp
  801186:	25 07 0e 00 00       	and    $0xe07,%eax
  80118b:	50                   	push   %eax
  80118c:	53                   	push   %ebx
  80118d:	6a 00                	push   $0x0
  80118f:	52                   	push   %edx
  801190:	6a 00                	push   $0x0
  801192:	e8 52 fa ff ff       	call   800be9 <sys_page_map>
  801197:	89 c7                	mov    %eax,%edi
  801199:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80119c:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80119e:	85 ff                	test   %edi,%edi
  8011a0:	79 1d                	jns    8011bf <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8011a2:	83 ec 08             	sub    $0x8,%esp
  8011a5:	53                   	push   %ebx
  8011a6:	6a 00                	push   $0x0
  8011a8:	e8 7e fa ff ff       	call   800c2b <sys_page_unmap>
	sys_page_unmap(0, nva);
  8011ad:	83 c4 08             	add    $0x8,%esp
  8011b0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8011b3:	6a 00                	push   $0x0
  8011b5:	e8 71 fa ff ff       	call   800c2b <sys_page_unmap>
	return r;
  8011ba:	83 c4 10             	add    $0x10,%esp
  8011bd:	89 f8                	mov    %edi,%eax
}
  8011bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011c2:	5b                   	pop    %ebx
  8011c3:	5e                   	pop    %esi
  8011c4:	5f                   	pop    %edi
  8011c5:	5d                   	pop    %ebp
  8011c6:	c3                   	ret    

008011c7 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8011c7:	55                   	push   %ebp
  8011c8:	89 e5                	mov    %esp,%ebp
  8011ca:	53                   	push   %ebx
  8011cb:	83 ec 14             	sub    $0x14,%esp
  8011ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011d1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011d4:	50                   	push   %eax
  8011d5:	53                   	push   %ebx
  8011d6:	e8 86 fd ff ff       	call   800f61 <fd_lookup>
  8011db:	83 c4 08             	add    $0x8,%esp
  8011de:	89 c2                	mov    %eax,%edx
  8011e0:	85 c0                	test   %eax,%eax
  8011e2:	78 6d                	js     801251 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011e4:	83 ec 08             	sub    $0x8,%esp
  8011e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011ea:	50                   	push   %eax
  8011eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ee:	ff 30                	pushl  (%eax)
  8011f0:	e8 c2 fd ff ff       	call   800fb7 <dev_lookup>
  8011f5:	83 c4 10             	add    $0x10,%esp
  8011f8:	85 c0                	test   %eax,%eax
  8011fa:	78 4c                	js     801248 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011fc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011ff:	8b 42 08             	mov    0x8(%edx),%eax
  801202:	83 e0 03             	and    $0x3,%eax
  801205:	83 f8 01             	cmp    $0x1,%eax
  801208:	75 21                	jne    80122b <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80120a:	a1 04 40 80 00       	mov    0x804004,%eax
  80120f:	8b 40 48             	mov    0x48(%eax),%eax
  801212:	83 ec 04             	sub    $0x4,%esp
  801215:	53                   	push   %ebx
  801216:	50                   	push   %eax
  801217:	68 8d 24 80 00       	push   $0x80248d
  80121c:	e8 df ef ff ff       	call   800200 <cprintf>
		return -E_INVAL;
  801221:	83 c4 10             	add    $0x10,%esp
  801224:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801229:	eb 26                	jmp    801251 <read+0x8a>
	}
	if (!dev->dev_read)
  80122b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80122e:	8b 40 08             	mov    0x8(%eax),%eax
  801231:	85 c0                	test   %eax,%eax
  801233:	74 17                	je     80124c <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801235:	83 ec 04             	sub    $0x4,%esp
  801238:	ff 75 10             	pushl  0x10(%ebp)
  80123b:	ff 75 0c             	pushl  0xc(%ebp)
  80123e:	52                   	push   %edx
  80123f:	ff d0                	call   *%eax
  801241:	89 c2                	mov    %eax,%edx
  801243:	83 c4 10             	add    $0x10,%esp
  801246:	eb 09                	jmp    801251 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801248:	89 c2                	mov    %eax,%edx
  80124a:	eb 05                	jmp    801251 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80124c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801251:	89 d0                	mov    %edx,%eax
  801253:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801256:	c9                   	leave  
  801257:	c3                   	ret    

00801258 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801258:	55                   	push   %ebp
  801259:	89 e5                	mov    %esp,%ebp
  80125b:	57                   	push   %edi
  80125c:	56                   	push   %esi
  80125d:	53                   	push   %ebx
  80125e:	83 ec 0c             	sub    $0xc,%esp
  801261:	8b 7d 08             	mov    0x8(%ebp),%edi
  801264:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801267:	bb 00 00 00 00       	mov    $0x0,%ebx
  80126c:	eb 21                	jmp    80128f <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80126e:	83 ec 04             	sub    $0x4,%esp
  801271:	89 f0                	mov    %esi,%eax
  801273:	29 d8                	sub    %ebx,%eax
  801275:	50                   	push   %eax
  801276:	89 d8                	mov    %ebx,%eax
  801278:	03 45 0c             	add    0xc(%ebp),%eax
  80127b:	50                   	push   %eax
  80127c:	57                   	push   %edi
  80127d:	e8 45 ff ff ff       	call   8011c7 <read>
		if (m < 0)
  801282:	83 c4 10             	add    $0x10,%esp
  801285:	85 c0                	test   %eax,%eax
  801287:	78 10                	js     801299 <readn+0x41>
			return m;
		if (m == 0)
  801289:	85 c0                	test   %eax,%eax
  80128b:	74 0a                	je     801297 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80128d:	01 c3                	add    %eax,%ebx
  80128f:	39 f3                	cmp    %esi,%ebx
  801291:	72 db                	jb     80126e <readn+0x16>
  801293:	89 d8                	mov    %ebx,%eax
  801295:	eb 02                	jmp    801299 <readn+0x41>
  801297:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801299:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80129c:	5b                   	pop    %ebx
  80129d:	5e                   	pop    %esi
  80129e:	5f                   	pop    %edi
  80129f:	5d                   	pop    %ebp
  8012a0:	c3                   	ret    

008012a1 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8012a1:	55                   	push   %ebp
  8012a2:	89 e5                	mov    %esp,%ebp
  8012a4:	53                   	push   %ebx
  8012a5:	83 ec 14             	sub    $0x14,%esp
  8012a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012ab:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012ae:	50                   	push   %eax
  8012af:	53                   	push   %ebx
  8012b0:	e8 ac fc ff ff       	call   800f61 <fd_lookup>
  8012b5:	83 c4 08             	add    $0x8,%esp
  8012b8:	89 c2                	mov    %eax,%edx
  8012ba:	85 c0                	test   %eax,%eax
  8012bc:	78 68                	js     801326 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012be:	83 ec 08             	sub    $0x8,%esp
  8012c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012c4:	50                   	push   %eax
  8012c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c8:	ff 30                	pushl  (%eax)
  8012ca:	e8 e8 fc ff ff       	call   800fb7 <dev_lookup>
  8012cf:	83 c4 10             	add    $0x10,%esp
  8012d2:	85 c0                	test   %eax,%eax
  8012d4:	78 47                	js     80131d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012d9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012dd:	75 21                	jne    801300 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012df:	a1 04 40 80 00       	mov    0x804004,%eax
  8012e4:	8b 40 48             	mov    0x48(%eax),%eax
  8012e7:	83 ec 04             	sub    $0x4,%esp
  8012ea:	53                   	push   %ebx
  8012eb:	50                   	push   %eax
  8012ec:	68 a9 24 80 00       	push   $0x8024a9
  8012f1:	e8 0a ef ff ff       	call   800200 <cprintf>
		return -E_INVAL;
  8012f6:	83 c4 10             	add    $0x10,%esp
  8012f9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012fe:	eb 26                	jmp    801326 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801300:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801303:	8b 52 0c             	mov    0xc(%edx),%edx
  801306:	85 d2                	test   %edx,%edx
  801308:	74 17                	je     801321 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80130a:	83 ec 04             	sub    $0x4,%esp
  80130d:	ff 75 10             	pushl  0x10(%ebp)
  801310:	ff 75 0c             	pushl  0xc(%ebp)
  801313:	50                   	push   %eax
  801314:	ff d2                	call   *%edx
  801316:	89 c2                	mov    %eax,%edx
  801318:	83 c4 10             	add    $0x10,%esp
  80131b:	eb 09                	jmp    801326 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80131d:	89 c2                	mov    %eax,%edx
  80131f:	eb 05                	jmp    801326 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801321:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801326:	89 d0                	mov    %edx,%eax
  801328:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80132b:	c9                   	leave  
  80132c:	c3                   	ret    

0080132d <seek>:

int
seek(int fdnum, off_t offset)
{
  80132d:	55                   	push   %ebp
  80132e:	89 e5                	mov    %esp,%ebp
  801330:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801333:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801336:	50                   	push   %eax
  801337:	ff 75 08             	pushl  0x8(%ebp)
  80133a:	e8 22 fc ff ff       	call   800f61 <fd_lookup>
  80133f:	83 c4 08             	add    $0x8,%esp
  801342:	85 c0                	test   %eax,%eax
  801344:	78 0e                	js     801354 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801346:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801349:	8b 55 0c             	mov    0xc(%ebp),%edx
  80134c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80134f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801354:	c9                   	leave  
  801355:	c3                   	ret    

00801356 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801356:	55                   	push   %ebp
  801357:	89 e5                	mov    %esp,%ebp
  801359:	53                   	push   %ebx
  80135a:	83 ec 14             	sub    $0x14,%esp
  80135d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801360:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801363:	50                   	push   %eax
  801364:	53                   	push   %ebx
  801365:	e8 f7 fb ff ff       	call   800f61 <fd_lookup>
  80136a:	83 c4 08             	add    $0x8,%esp
  80136d:	89 c2                	mov    %eax,%edx
  80136f:	85 c0                	test   %eax,%eax
  801371:	78 65                	js     8013d8 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801373:	83 ec 08             	sub    $0x8,%esp
  801376:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801379:	50                   	push   %eax
  80137a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80137d:	ff 30                	pushl  (%eax)
  80137f:	e8 33 fc ff ff       	call   800fb7 <dev_lookup>
  801384:	83 c4 10             	add    $0x10,%esp
  801387:	85 c0                	test   %eax,%eax
  801389:	78 44                	js     8013cf <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80138b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80138e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801392:	75 21                	jne    8013b5 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801394:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801399:	8b 40 48             	mov    0x48(%eax),%eax
  80139c:	83 ec 04             	sub    $0x4,%esp
  80139f:	53                   	push   %ebx
  8013a0:	50                   	push   %eax
  8013a1:	68 6c 24 80 00       	push   $0x80246c
  8013a6:	e8 55 ee ff ff       	call   800200 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8013ab:	83 c4 10             	add    $0x10,%esp
  8013ae:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013b3:	eb 23                	jmp    8013d8 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8013b5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013b8:	8b 52 18             	mov    0x18(%edx),%edx
  8013bb:	85 d2                	test   %edx,%edx
  8013bd:	74 14                	je     8013d3 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8013bf:	83 ec 08             	sub    $0x8,%esp
  8013c2:	ff 75 0c             	pushl  0xc(%ebp)
  8013c5:	50                   	push   %eax
  8013c6:	ff d2                	call   *%edx
  8013c8:	89 c2                	mov    %eax,%edx
  8013ca:	83 c4 10             	add    $0x10,%esp
  8013cd:	eb 09                	jmp    8013d8 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013cf:	89 c2                	mov    %eax,%edx
  8013d1:	eb 05                	jmp    8013d8 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8013d3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8013d8:	89 d0                	mov    %edx,%eax
  8013da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013dd:	c9                   	leave  
  8013de:	c3                   	ret    

008013df <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8013df:	55                   	push   %ebp
  8013e0:	89 e5                	mov    %esp,%ebp
  8013e2:	53                   	push   %ebx
  8013e3:	83 ec 14             	sub    $0x14,%esp
  8013e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013e9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013ec:	50                   	push   %eax
  8013ed:	ff 75 08             	pushl  0x8(%ebp)
  8013f0:	e8 6c fb ff ff       	call   800f61 <fd_lookup>
  8013f5:	83 c4 08             	add    $0x8,%esp
  8013f8:	89 c2                	mov    %eax,%edx
  8013fa:	85 c0                	test   %eax,%eax
  8013fc:	78 58                	js     801456 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013fe:	83 ec 08             	sub    $0x8,%esp
  801401:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801404:	50                   	push   %eax
  801405:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801408:	ff 30                	pushl  (%eax)
  80140a:	e8 a8 fb ff ff       	call   800fb7 <dev_lookup>
  80140f:	83 c4 10             	add    $0x10,%esp
  801412:	85 c0                	test   %eax,%eax
  801414:	78 37                	js     80144d <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801416:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801419:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80141d:	74 32                	je     801451 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80141f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801422:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801429:	00 00 00 
	stat->st_isdir = 0;
  80142c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801433:	00 00 00 
	stat->st_dev = dev;
  801436:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80143c:	83 ec 08             	sub    $0x8,%esp
  80143f:	53                   	push   %ebx
  801440:	ff 75 f0             	pushl  -0x10(%ebp)
  801443:	ff 50 14             	call   *0x14(%eax)
  801446:	89 c2                	mov    %eax,%edx
  801448:	83 c4 10             	add    $0x10,%esp
  80144b:	eb 09                	jmp    801456 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80144d:	89 c2                	mov    %eax,%edx
  80144f:	eb 05                	jmp    801456 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801451:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801456:	89 d0                	mov    %edx,%eax
  801458:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80145b:	c9                   	leave  
  80145c:	c3                   	ret    

0080145d <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80145d:	55                   	push   %ebp
  80145e:	89 e5                	mov    %esp,%ebp
  801460:	56                   	push   %esi
  801461:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801462:	83 ec 08             	sub    $0x8,%esp
  801465:	6a 00                	push   $0x0
  801467:	ff 75 08             	pushl  0x8(%ebp)
  80146a:	e8 e3 01 00 00       	call   801652 <open>
  80146f:	89 c3                	mov    %eax,%ebx
  801471:	83 c4 10             	add    $0x10,%esp
  801474:	85 c0                	test   %eax,%eax
  801476:	78 1b                	js     801493 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801478:	83 ec 08             	sub    $0x8,%esp
  80147b:	ff 75 0c             	pushl  0xc(%ebp)
  80147e:	50                   	push   %eax
  80147f:	e8 5b ff ff ff       	call   8013df <fstat>
  801484:	89 c6                	mov    %eax,%esi
	close(fd);
  801486:	89 1c 24             	mov    %ebx,(%esp)
  801489:	e8 fd fb ff ff       	call   80108b <close>
	return r;
  80148e:	83 c4 10             	add    $0x10,%esp
  801491:	89 f0                	mov    %esi,%eax
}
  801493:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801496:	5b                   	pop    %ebx
  801497:	5e                   	pop    %esi
  801498:	5d                   	pop    %ebp
  801499:	c3                   	ret    

0080149a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80149a:	55                   	push   %ebp
  80149b:	89 e5                	mov    %esp,%ebp
  80149d:	56                   	push   %esi
  80149e:	53                   	push   %ebx
  80149f:	89 c6                	mov    %eax,%esi
  8014a1:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8014a3:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8014aa:	75 12                	jne    8014be <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8014ac:	83 ec 0c             	sub    $0xc,%esp
  8014af:	6a 01                	push   $0x1
  8014b1:	e8 1e 09 00 00       	call   801dd4 <ipc_find_env>
  8014b6:	a3 00 40 80 00       	mov    %eax,0x804000
  8014bb:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8014be:	6a 07                	push   $0x7
  8014c0:	68 00 50 80 00       	push   $0x805000
  8014c5:	56                   	push   %esi
  8014c6:	ff 35 00 40 80 00    	pushl  0x804000
  8014cc:	e8 af 08 00 00       	call   801d80 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8014d1:	83 c4 0c             	add    $0xc,%esp
  8014d4:	6a 00                	push   $0x0
  8014d6:	53                   	push   %ebx
  8014d7:	6a 00                	push   $0x0
  8014d9:	e8 4d 08 00 00       	call   801d2b <ipc_recv>
}
  8014de:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014e1:	5b                   	pop    %ebx
  8014e2:	5e                   	pop    %esi
  8014e3:	5d                   	pop    %ebp
  8014e4:	c3                   	ret    

008014e5 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8014e5:	55                   	push   %ebp
  8014e6:	89 e5                	mov    %esp,%ebp
  8014e8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8014eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ee:	8b 40 0c             	mov    0xc(%eax),%eax
  8014f1:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8014f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014f9:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014fe:	ba 00 00 00 00       	mov    $0x0,%edx
  801503:	b8 02 00 00 00       	mov    $0x2,%eax
  801508:	e8 8d ff ff ff       	call   80149a <fsipc>
}
  80150d:	c9                   	leave  
  80150e:	c3                   	ret    

0080150f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80150f:	55                   	push   %ebp
  801510:	89 e5                	mov    %esp,%ebp
  801512:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801515:	8b 45 08             	mov    0x8(%ebp),%eax
  801518:	8b 40 0c             	mov    0xc(%eax),%eax
  80151b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801520:	ba 00 00 00 00       	mov    $0x0,%edx
  801525:	b8 06 00 00 00       	mov    $0x6,%eax
  80152a:	e8 6b ff ff ff       	call   80149a <fsipc>
}
  80152f:	c9                   	leave  
  801530:	c3                   	ret    

00801531 <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801531:	55                   	push   %ebp
  801532:	89 e5                	mov    %esp,%ebp
  801534:	53                   	push   %ebx
  801535:	83 ec 04             	sub    $0x4,%esp
  801538:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80153b:	8b 45 08             	mov    0x8(%ebp),%eax
  80153e:	8b 40 0c             	mov    0xc(%eax),%eax
  801541:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801546:	ba 00 00 00 00       	mov    $0x0,%edx
  80154b:	b8 05 00 00 00       	mov    $0x5,%eax
  801550:	e8 45 ff ff ff       	call   80149a <fsipc>
  801555:	85 c0                	test   %eax,%eax
  801557:	78 2c                	js     801585 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801559:	83 ec 08             	sub    $0x8,%esp
  80155c:	68 00 50 80 00       	push   $0x805000
  801561:	53                   	push   %ebx
  801562:	e8 3c f2 ff ff       	call   8007a3 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801567:	a1 80 50 80 00       	mov    0x805080,%eax
  80156c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801572:	a1 84 50 80 00       	mov    0x805084,%eax
  801577:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80157d:	83 c4 10             	add    $0x10,%esp
  801580:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801585:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801588:	c9                   	leave  
  801589:	c3                   	ret    

0080158a <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80158a:	55                   	push   %ebp
  80158b:	89 e5                	mov    %esp,%ebp
  80158d:	83 ec 0c             	sub    $0xc,%esp
  801590:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
    
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  801593:	8b 55 08             	mov    0x8(%ebp),%edx
  801596:	8b 52 0c             	mov    0xc(%edx),%edx
  801599:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = MIN(n, PGSIZE);
  80159f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015a4:	ba 00 10 00 00       	mov    $0x1000,%edx
  8015a9:	0f 47 c2             	cmova  %edx,%eax
  8015ac:	a3 04 50 80 00       	mov    %eax,0x805004
    memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8015b1:	50                   	push   %eax
  8015b2:	ff 75 0c             	pushl  0xc(%ebp)
  8015b5:	68 08 50 80 00       	push   $0x805008
  8015ba:	e8 76 f3 ff ff       	call   800935 <memmove>
    int r = fsipc(FSREQ_WRITE, NULL);
  8015bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8015c4:	b8 04 00 00 00       	mov    $0x4,%eax
  8015c9:	e8 cc fe ff ff       	call   80149a <fsipc>
    return r;
}
  8015ce:	c9                   	leave  
  8015cf:	c3                   	ret    

008015d0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8015d0:	55                   	push   %ebp
  8015d1:	89 e5                	mov    %esp,%ebp
  8015d3:	56                   	push   %esi
  8015d4:	53                   	push   %ebx
  8015d5:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8015d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8015db:	8b 40 0c             	mov    0xc(%eax),%eax
  8015de:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8015e3:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8015e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8015ee:	b8 03 00 00 00       	mov    $0x3,%eax
  8015f3:	e8 a2 fe ff ff       	call   80149a <fsipc>
  8015f8:	89 c3                	mov    %eax,%ebx
  8015fa:	85 c0                	test   %eax,%eax
  8015fc:	78 4b                	js     801649 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8015fe:	39 c6                	cmp    %eax,%esi
  801600:	73 16                	jae    801618 <devfile_read+0x48>
  801602:	68 d8 24 80 00       	push   $0x8024d8
  801607:	68 df 24 80 00       	push   $0x8024df
  80160c:	6a 7c                	push   $0x7c
  80160e:	68 f4 24 80 00       	push   $0x8024f4
  801613:	e8 cd 06 00 00       	call   801ce5 <_panic>
	assert(r <= PGSIZE);
  801618:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80161d:	7e 16                	jle    801635 <devfile_read+0x65>
  80161f:	68 ff 24 80 00       	push   $0x8024ff
  801624:	68 df 24 80 00       	push   $0x8024df
  801629:	6a 7d                	push   $0x7d
  80162b:	68 f4 24 80 00       	push   $0x8024f4
  801630:	e8 b0 06 00 00       	call   801ce5 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801635:	83 ec 04             	sub    $0x4,%esp
  801638:	50                   	push   %eax
  801639:	68 00 50 80 00       	push   $0x805000
  80163e:	ff 75 0c             	pushl  0xc(%ebp)
  801641:	e8 ef f2 ff ff       	call   800935 <memmove>
	return r;
  801646:	83 c4 10             	add    $0x10,%esp
}
  801649:	89 d8                	mov    %ebx,%eax
  80164b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80164e:	5b                   	pop    %ebx
  80164f:	5e                   	pop    %esi
  801650:	5d                   	pop    %ebp
  801651:	c3                   	ret    

00801652 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801652:	55                   	push   %ebp
  801653:	89 e5                	mov    %esp,%ebp
  801655:	53                   	push   %ebx
  801656:	83 ec 20             	sub    $0x20,%esp
  801659:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80165c:	53                   	push   %ebx
  80165d:	e8 08 f1 ff ff       	call   80076a <strlen>
  801662:	83 c4 10             	add    $0x10,%esp
  801665:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80166a:	7f 67                	jg     8016d3 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80166c:	83 ec 0c             	sub    $0xc,%esp
  80166f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801672:	50                   	push   %eax
  801673:	e8 9a f8 ff ff       	call   800f12 <fd_alloc>
  801678:	83 c4 10             	add    $0x10,%esp
		return r;
  80167b:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80167d:	85 c0                	test   %eax,%eax
  80167f:	78 57                	js     8016d8 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801681:	83 ec 08             	sub    $0x8,%esp
  801684:	53                   	push   %ebx
  801685:	68 00 50 80 00       	push   $0x805000
  80168a:	e8 14 f1 ff ff       	call   8007a3 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80168f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801692:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801697:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80169a:	b8 01 00 00 00       	mov    $0x1,%eax
  80169f:	e8 f6 fd ff ff       	call   80149a <fsipc>
  8016a4:	89 c3                	mov    %eax,%ebx
  8016a6:	83 c4 10             	add    $0x10,%esp
  8016a9:	85 c0                	test   %eax,%eax
  8016ab:	79 14                	jns    8016c1 <open+0x6f>
		fd_close(fd, 0);
  8016ad:	83 ec 08             	sub    $0x8,%esp
  8016b0:	6a 00                	push   $0x0
  8016b2:	ff 75 f4             	pushl  -0xc(%ebp)
  8016b5:	e8 50 f9 ff ff       	call   80100a <fd_close>
		return r;
  8016ba:	83 c4 10             	add    $0x10,%esp
  8016bd:	89 da                	mov    %ebx,%edx
  8016bf:	eb 17                	jmp    8016d8 <open+0x86>
	}

	return fd2num(fd);
  8016c1:	83 ec 0c             	sub    $0xc,%esp
  8016c4:	ff 75 f4             	pushl  -0xc(%ebp)
  8016c7:	e8 1f f8 ff ff       	call   800eeb <fd2num>
  8016cc:	89 c2                	mov    %eax,%edx
  8016ce:	83 c4 10             	add    $0x10,%esp
  8016d1:	eb 05                	jmp    8016d8 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8016d3:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8016d8:	89 d0                	mov    %edx,%eax
  8016da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016dd:	c9                   	leave  
  8016de:	c3                   	ret    

008016df <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8016df:	55                   	push   %ebp
  8016e0:	89 e5                	mov    %esp,%ebp
  8016e2:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8016e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ea:	b8 08 00 00 00       	mov    $0x8,%eax
  8016ef:	e8 a6 fd ff ff       	call   80149a <fsipc>
}
  8016f4:	c9                   	leave  
  8016f5:	c3                   	ret    

008016f6 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  8016f6:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8016fa:	7e 37                	jle    801733 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  8016fc:	55                   	push   %ebp
  8016fd:	89 e5                	mov    %esp,%ebp
  8016ff:	53                   	push   %ebx
  801700:	83 ec 08             	sub    $0x8,%esp
  801703:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  801705:	ff 70 04             	pushl  0x4(%eax)
  801708:	8d 40 10             	lea    0x10(%eax),%eax
  80170b:	50                   	push   %eax
  80170c:	ff 33                	pushl  (%ebx)
  80170e:	e8 8e fb ff ff       	call   8012a1 <write>
		if (result > 0)
  801713:	83 c4 10             	add    $0x10,%esp
  801716:	85 c0                	test   %eax,%eax
  801718:	7e 03                	jle    80171d <writebuf+0x27>
			b->result += result;
  80171a:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  80171d:	3b 43 04             	cmp    0x4(%ebx),%eax
  801720:	74 0d                	je     80172f <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  801722:	85 c0                	test   %eax,%eax
  801724:	ba 00 00 00 00       	mov    $0x0,%edx
  801729:	0f 4f c2             	cmovg  %edx,%eax
  80172c:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  80172f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801732:	c9                   	leave  
  801733:	f3 c3                	repz ret 

00801735 <putch>:

static void
putch(int ch, void *thunk)
{
  801735:	55                   	push   %ebp
  801736:	89 e5                	mov    %esp,%ebp
  801738:	53                   	push   %ebx
  801739:	83 ec 04             	sub    $0x4,%esp
  80173c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  80173f:	8b 53 04             	mov    0x4(%ebx),%edx
  801742:	8d 42 01             	lea    0x1(%edx),%eax
  801745:	89 43 04             	mov    %eax,0x4(%ebx)
  801748:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80174b:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  80174f:	3d 00 01 00 00       	cmp    $0x100,%eax
  801754:	75 0e                	jne    801764 <putch+0x2f>
		writebuf(b);
  801756:	89 d8                	mov    %ebx,%eax
  801758:	e8 99 ff ff ff       	call   8016f6 <writebuf>
		b->idx = 0;
  80175d:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801764:	83 c4 04             	add    $0x4,%esp
  801767:	5b                   	pop    %ebx
  801768:	5d                   	pop    %ebp
  801769:	c3                   	ret    

0080176a <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  80176a:	55                   	push   %ebp
  80176b:	89 e5                	mov    %esp,%ebp
  80176d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801773:	8b 45 08             	mov    0x8(%ebp),%eax
  801776:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  80177c:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801783:	00 00 00 
	b.result = 0;
  801786:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80178d:	00 00 00 
	b.error = 1;
  801790:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801797:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  80179a:	ff 75 10             	pushl  0x10(%ebp)
  80179d:	ff 75 0c             	pushl  0xc(%ebp)
  8017a0:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8017a6:	50                   	push   %eax
  8017a7:	68 35 17 80 00       	push   $0x801735
  8017ac:	e8 86 eb ff ff       	call   800337 <vprintfmt>
	if (b.idx > 0)
  8017b1:	83 c4 10             	add    $0x10,%esp
  8017b4:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8017bb:	7e 0b                	jle    8017c8 <vfprintf+0x5e>
		writebuf(&b);
  8017bd:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8017c3:	e8 2e ff ff ff       	call   8016f6 <writebuf>

	return (b.result ? b.result : b.error);
  8017c8:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8017ce:	85 c0                	test   %eax,%eax
  8017d0:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  8017d7:	c9                   	leave  
  8017d8:	c3                   	ret    

008017d9 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8017d9:	55                   	push   %ebp
  8017da:	89 e5                	mov    %esp,%ebp
  8017dc:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8017df:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  8017e2:	50                   	push   %eax
  8017e3:	ff 75 0c             	pushl  0xc(%ebp)
  8017e6:	ff 75 08             	pushl  0x8(%ebp)
  8017e9:	e8 7c ff ff ff       	call   80176a <vfprintf>
	va_end(ap);

	return cnt;
}
  8017ee:	c9                   	leave  
  8017ef:	c3                   	ret    

008017f0 <printf>:

int
printf(const char *fmt, ...)
{
  8017f0:	55                   	push   %ebp
  8017f1:	89 e5                	mov    %esp,%ebp
  8017f3:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8017f6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  8017f9:	50                   	push   %eax
  8017fa:	ff 75 08             	pushl  0x8(%ebp)
  8017fd:	6a 01                	push   $0x1
  8017ff:	e8 66 ff ff ff       	call   80176a <vfprintf>
	va_end(ap);

	return cnt;
}
  801804:	c9                   	leave  
  801805:	c3                   	ret    

00801806 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801806:	55                   	push   %ebp
  801807:	89 e5                	mov    %esp,%ebp
  801809:	56                   	push   %esi
  80180a:	53                   	push   %ebx
  80180b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80180e:	83 ec 0c             	sub    $0xc,%esp
  801811:	ff 75 08             	pushl  0x8(%ebp)
  801814:	e8 e2 f6 ff ff       	call   800efb <fd2data>
  801819:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80181b:	83 c4 08             	add    $0x8,%esp
  80181e:	68 0b 25 80 00       	push   $0x80250b
  801823:	53                   	push   %ebx
  801824:	e8 7a ef ff ff       	call   8007a3 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801829:	8b 46 04             	mov    0x4(%esi),%eax
  80182c:	2b 06                	sub    (%esi),%eax
  80182e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801834:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80183b:	00 00 00 
	stat->st_dev = &devpipe;
  80183e:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801845:	30 80 00 
	return 0;
}
  801848:	b8 00 00 00 00       	mov    $0x0,%eax
  80184d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801850:	5b                   	pop    %ebx
  801851:	5e                   	pop    %esi
  801852:	5d                   	pop    %ebp
  801853:	c3                   	ret    

00801854 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801854:	55                   	push   %ebp
  801855:	89 e5                	mov    %esp,%ebp
  801857:	53                   	push   %ebx
  801858:	83 ec 0c             	sub    $0xc,%esp
  80185b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80185e:	53                   	push   %ebx
  80185f:	6a 00                	push   $0x0
  801861:	e8 c5 f3 ff ff       	call   800c2b <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801866:	89 1c 24             	mov    %ebx,(%esp)
  801869:	e8 8d f6 ff ff       	call   800efb <fd2data>
  80186e:	83 c4 08             	add    $0x8,%esp
  801871:	50                   	push   %eax
  801872:	6a 00                	push   $0x0
  801874:	e8 b2 f3 ff ff       	call   800c2b <sys_page_unmap>
}
  801879:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80187c:	c9                   	leave  
  80187d:	c3                   	ret    

0080187e <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80187e:	55                   	push   %ebp
  80187f:	89 e5                	mov    %esp,%ebp
  801881:	57                   	push   %edi
  801882:	56                   	push   %esi
  801883:	53                   	push   %ebx
  801884:	83 ec 1c             	sub    $0x1c,%esp
  801887:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80188a:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80188c:	a1 04 40 80 00       	mov    0x804004,%eax
  801891:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801894:	83 ec 0c             	sub    $0xc,%esp
  801897:	ff 75 e0             	pushl  -0x20(%ebp)
  80189a:	e8 6e 05 00 00       	call   801e0d <pageref>
  80189f:	89 c3                	mov    %eax,%ebx
  8018a1:	89 3c 24             	mov    %edi,(%esp)
  8018a4:	e8 64 05 00 00       	call   801e0d <pageref>
  8018a9:	83 c4 10             	add    $0x10,%esp
  8018ac:	39 c3                	cmp    %eax,%ebx
  8018ae:	0f 94 c1             	sete   %cl
  8018b1:	0f b6 c9             	movzbl %cl,%ecx
  8018b4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8018b7:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8018bd:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8018c0:	39 ce                	cmp    %ecx,%esi
  8018c2:	74 1b                	je     8018df <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8018c4:	39 c3                	cmp    %eax,%ebx
  8018c6:	75 c4                	jne    80188c <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8018c8:	8b 42 58             	mov    0x58(%edx),%eax
  8018cb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8018ce:	50                   	push   %eax
  8018cf:	56                   	push   %esi
  8018d0:	68 12 25 80 00       	push   $0x802512
  8018d5:	e8 26 e9 ff ff       	call   800200 <cprintf>
  8018da:	83 c4 10             	add    $0x10,%esp
  8018dd:	eb ad                	jmp    80188c <_pipeisclosed+0xe>
	}
}
  8018df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018e5:	5b                   	pop    %ebx
  8018e6:	5e                   	pop    %esi
  8018e7:	5f                   	pop    %edi
  8018e8:	5d                   	pop    %ebp
  8018e9:	c3                   	ret    

008018ea <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8018ea:	55                   	push   %ebp
  8018eb:	89 e5                	mov    %esp,%ebp
  8018ed:	57                   	push   %edi
  8018ee:	56                   	push   %esi
  8018ef:	53                   	push   %ebx
  8018f0:	83 ec 28             	sub    $0x28,%esp
  8018f3:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8018f6:	56                   	push   %esi
  8018f7:	e8 ff f5 ff ff       	call   800efb <fd2data>
  8018fc:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018fe:	83 c4 10             	add    $0x10,%esp
  801901:	bf 00 00 00 00       	mov    $0x0,%edi
  801906:	eb 4b                	jmp    801953 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801908:	89 da                	mov    %ebx,%edx
  80190a:	89 f0                	mov    %esi,%eax
  80190c:	e8 6d ff ff ff       	call   80187e <_pipeisclosed>
  801911:	85 c0                	test   %eax,%eax
  801913:	75 48                	jne    80195d <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801915:	e8 6d f2 ff ff       	call   800b87 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80191a:	8b 43 04             	mov    0x4(%ebx),%eax
  80191d:	8b 0b                	mov    (%ebx),%ecx
  80191f:	8d 51 20             	lea    0x20(%ecx),%edx
  801922:	39 d0                	cmp    %edx,%eax
  801924:	73 e2                	jae    801908 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801926:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801929:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80192d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801930:	89 c2                	mov    %eax,%edx
  801932:	c1 fa 1f             	sar    $0x1f,%edx
  801935:	89 d1                	mov    %edx,%ecx
  801937:	c1 e9 1b             	shr    $0x1b,%ecx
  80193a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80193d:	83 e2 1f             	and    $0x1f,%edx
  801940:	29 ca                	sub    %ecx,%edx
  801942:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801946:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80194a:	83 c0 01             	add    $0x1,%eax
  80194d:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801950:	83 c7 01             	add    $0x1,%edi
  801953:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801956:	75 c2                	jne    80191a <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801958:	8b 45 10             	mov    0x10(%ebp),%eax
  80195b:	eb 05                	jmp    801962 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80195d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801962:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801965:	5b                   	pop    %ebx
  801966:	5e                   	pop    %esi
  801967:	5f                   	pop    %edi
  801968:	5d                   	pop    %ebp
  801969:	c3                   	ret    

0080196a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80196a:	55                   	push   %ebp
  80196b:	89 e5                	mov    %esp,%ebp
  80196d:	57                   	push   %edi
  80196e:	56                   	push   %esi
  80196f:	53                   	push   %ebx
  801970:	83 ec 18             	sub    $0x18,%esp
  801973:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801976:	57                   	push   %edi
  801977:	e8 7f f5 ff ff       	call   800efb <fd2data>
  80197c:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80197e:	83 c4 10             	add    $0x10,%esp
  801981:	bb 00 00 00 00       	mov    $0x0,%ebx
  801986:	eb 3d                	jmp    8019c5 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801988:	85 db                	test   %ebx,%ebx
  80198a:	74 04                	je     801990 <devpipe_read+0x26>
				return i;
  80198c:	89 d8                	mov    %ebx,%eax
  80198e:	eb 44                	jmp    8019d4 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801990:	89 f2                	mov    %esi,%edx
  801992:	89 f8                	mov    %edi,%eax
  801994:	e8 e5 fe ff ff       	call   80187e <_pipeisclosed>
  801999:	85 c0                	test   %eax,%eax
  80199b:	75 32                	jne    8019cf <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80199d:	e8 e5 f1 ff ff       	call   800b87 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8019a2:	8b 06                	mov    (%esi),%eax
  8019a4:	3b 46 04             	cmp    0x4(%esi),%eax
  8019a7:	74 df                	je     801988 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8019a9:	99                   	cltd   
  8019aa:	c1 ea 1b             	shr    $0x1b,%edx
  8019ad:	01 d0                	add    %edx,%eax
  8019af:	83 e0 1f             	and    $0x1f,%eax
  8019b2:	29 d0                	sub    %edx,%eax
  8019b4:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8019b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019bc:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8019bf:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019c2:	83 c3 01             	add    $0x1,%ebx
  8019c5:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8019c8:	75 d8                	jne    8019a2 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8019ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8019cd:	eb 05                	jmp    8019d4 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019cf:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8019d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019d7:	5b                   	pop    %ebx
  8019d8:	5e                   	pop    %esi
  8019d9:	5f                   	pop    %edi
  8019da:	5d                   	pop    %ebp
  8019db:	c3                   	ret    

008019dc <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8019dc:	55                   	push   %ebp
  8019dd:	89 e5                	mov    %esp,%ebp
  8019df:	56                   	push   %esi
  8019e0:	53                   	push   %ebx
  8019e1:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8019e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019e7:	50                   	push   %eax
  8019e8:	e8 25 f5 ff ff       	call   800f12 <fd_alloc>
  8019ed:	83 c4 10             	add    $0x10,%esp
  8019f0:	89 c2                	mov    %eax,%edx
  8019f2:	85 c0                	test   %eax,%eax
  8019f4:	0f 88 2c 01 00 00    	js     801b26 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019fa:	83 ec 04             	sub    $0x4,%esp
  8019fd:	68 07 04 00 00       	push   $0x407
  801a02:	ff 75 f4             	pushl  -0xc(%ebp)
  801a05:	6a 00                	push   $0x0
  801a07:	e8 9a f1 ff ff       	call   800ba6 <sys_page_alloc>
  801a0c:	83 c4 10             	add    $0x10,%esp
  801a0f:	89 c2                	mov    %eax,%edx
  801a11:	85 c0                	test   %eax,%eax
  801a13:	0f 88 0d 01 00 00    	js     801b26 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a19:	83 ec 0c             	sub    $0xc,%esp
  801a1c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a1f:	50                   	push   %eax
  801a20:	e8 ed f4 ff ff       	call   800f12 <fd_alloc>
  801a25:	89 c3                	mov    %eax,%ebx
  801a27:	83 c4 10             	add    $0x10,%esp
  801a2a:	85 c0                	test   %eax,%eax
  801a2c:	0f 88 e2 00 00 00    	js     801b14 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a32:	83 ec 04             	sub    $0x4,%esp
  801a35:	68 07 04 00 00       	push   $0x407
  801a3a:	ff 75 f0             	pushl  -0x10(%ebp)
  801a3d:	6a 00                	push   $0x0
  801a3f:	e8 62 f1 ff ff       	call   800ba6 <sys_page_alloc>
  801a44:	89 c3                	mov    %eax,%ebx
  801a46:	83 c4 10             	add    $0x10,%esp
  801a49:	85 c0                	test   %eax,%eax
  801a4b:	0f 88 c3 00 00 00    	js     801b14 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801a51:	83 ec 0c             	sub    $0xc,%esp
  801a54:	ff 75 f4             	pushl  -0xc(%ebp)
  801a57:	e8 9f f4 ff ff       	call   800efb <fd2data>
  801a5c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a5e:	83 c4 0c             	add    $0xc,%esp
  801a61:	68 07 04 00 00       	push   $0x407
  801a66:	50                   	push   %eax
  801a67:	6a 00                	push   $0x0
  801a69:	e8 38 f1 ff ff       	call   800ba6 <sys_page_alloc>
  801a6e:	89 c3                	mov    %eax,%ebx
  801a70:	83 c4 10             	add    $0x10,%esp
  801a73:	85 c0                	test   %eax,%eax
  801a75:	0f 88 89 00 00 00    	js     801b04 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a7b:	83 ec 0c             	sub    $0xc,%esp
  801a7e:	ff 75 f0             	pushl  -0x10(%ebp)
  801a81:	e8 75 f4 ff ff       	call   800efb <fd2data>
  801a86:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801a8d:	50                   	push   %eax
  801a8e:	6a 00                	push   $0x0
  801a90:	56                   	push   %esi
  801a91:	6a 00                	push   $0x0
  801a93:	e8 51 f1 ff ff       	call   800be9 <sys_page_map>
  801a98:	89 c3                	mov    %eax,%ebx
  801a9a:	83 c4 20             	add    $0x20,%esp
  801a9d:	85 c0                	test   %eax,%eax
  801a9f:	78 55                	js     801af6 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801aa1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801aa7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aaa:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801aac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aaf:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ab6:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801abc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801abf:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ac1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ac4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801acb:	83 ec 0c             	sub    $0xc,%esp
  801ace:	ff 75 f4             	pushl  -0xc(%ebp)
  801ad1:	e8 15 f4 ff ff       	call   800eeb <fd2num>
  801ad6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ad9:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801adb:	83 c4 04             	add    $0x4,%esp
  801ade:	ff 75 f0             	pushl  -0x10(%ebp)
  801ae1:	e8 05 f4 ff ff       	call   800eeb <fd2num>
  801ae6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ae9:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801aec:	83 c4 10             	add    $0x10,%esp
  801aef:	ba 00 00 00 00       	mov    $0x0,%edx
  801af4:	eb 30                	jmp    801b26 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801af6:	83 ec 08             	sub    $0x8,%esp
  801af9:	56                   	push   %esi
  801afa:	6a 00                	push   $0x0
  801afc:	e8 2a f1 ff ff       	call   800c2b <sys_page_unmap>
  801b01:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801b04:	83 ec 08             	sub    $0x8,%esp
  801b07:	ff 75 f0             	pushl  -0x10(%ebp)
  801b0a:	6a 00                	push   $0x0
  801b0c:	e8 1a f1 ff ff       	call   800c2b <sys_page_unmap>
  801b11:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801b14:	83 ec 08             	sub    $0x8,%esp
  801b17:	ff 75 f4             	pushl  -0xc(%ebp)
  801b1a:	6a 00                	push   $0x0
  801b1c:	e8 0a f1 ff ff       	call   800c2b <sys_page_unmap>
  801b21:	83 c4 10             	add    $0x10,%esp
  801b24:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801b26:	89 d0                	mov    %edx,%eax
  801b28:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b2b:	5b                   	pop    %ebx
  801b2c:	5e                   	pop    %esi
  801b2d:	5d                   	pop    %ebp
  801b2e:	c3                   	ret    

00801b2f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801b2f:	55                   	push   %ebp
  801b30:	89 e5                	mov    %esp,%ebp
  801b32:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b35:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b38:	50                   	push   %eax
  801b39:	ff 75 08             	pushl  0x8(%ebp)
  801b3c:	e8 20 f4 ff ff       	call   800f61 <fd_lookup>
  801b41:	83 c4 10             	add    $0x10,%esp
  801b44:	85 c0                	test   %eax,%eax
  801b46:	78 18                	js     801b60 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801b48:	83 ec 0c             	sub    $0xc,%esp
  801b4b:	ff 75 f4             	pushl  -0xc(%ebp)
  801b4e:	e8 a8 f3 ff ff       	call   800efb <fd2data>
	return _pipeisclosed(fd, p);
  801b53:	89 c2                	mov    %eax,%edx
  801b55:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b58:	e8 21 fd ff ff       	call   80187e <_pipeisclosed>
  801b5d:	83 c4 10             	add    $0x10,%esp
}
  801b60:	c9                   	leave  
  801b61:	c3                   	ret    

00801b62 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801b62:	55                   	push   %ebp
  801b63:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801b65:	b8 00 00 00 00       	mov    $0x0,%eax
  801b6a:	5d                   	pop    %ebp
  801b6b:	c3                   	ret    

00801b6c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801b6c:	55                   	push   %ebp
  801b6d:	89 e5                	mov    %esp,%ebp
  801b6f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801b72:	68 2a 25 80 00       	push   $0x80252a
  801b77:	ff 75 0c             	pushl  0xc(%ebp)
  801b7a:	e8 24 ec ff ff       	call   8007a3 <strcpy>
	return 0;
}
  801b7f:	b8 00 00 00 00       	mov    $0x0,%eax
  801b84:	c9                   	leave  
  801b85:	c3                   	ret    

00801b86 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b86:	55                   	push   %ebp
  801b87:	89 e5                	mov    %esp,%ebp
  801b89:	57                   	push   %edi
  801b8a:	56                   	push   %esi
  801b8b:	53                   	push   %ebx
  801b8c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b92:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801b97:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b9d:	eb 2d                	jmp    801bcc <devcons_write+0x46>
		m = n - tot;
  801b9f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ba2:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801ba4:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801ba7:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801bac:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801baf:	83 ec 04             	sub    $0x4,%esp
  801bb2:	53                   	push   %ebx
  801bb3:	03 45 0c             	add    0xc(%ebp),%eax
  801bb6:	50                   	push   %eax
  801bb7:	57                   	push   %edi
  801bb8:	e8 78 ed ff ff       	call   800935 <memmove>
		sys_cputs(buf, m);
  801bbd:	83 c4 08             	add    $0x8,%esp
  801bc0:	53                   	push   %ebx
  801bc1:	57                   	push   %edi
  801bc2:	e8 23 ef ff ff       	call   800aea <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bc7:	01 de                	add    %ebx,%esi
  801bc9:	83 c4 10             	add    $0x10,%esp
  801bcc:	89 f0                	mov    %esi,%eax
  801bce:	3b 75 10             	cmp    0x10(%ebp),%esi
  801bd1:	72 cc                	jb     801b9f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801bd3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bd6:	5b                   	pop    %ebx
  801bd7:	5e                   	pop    %esi
  801bd8:	5f                   	pop    %edi
  801bd9:	5d                   	pop    %ebp
  801bda:	c3                   	ret    

00801bdb <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801bdb:	55                   	push   %ebp
  801bdc:	89 e5                	mov    %esp,%ebp
  801bde:	83 ec 08             	sub    $0x8,%esp
  801be1:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801be6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801bea:	74 2a                	je     801c16 <devcons_read+0x3b>
  801bec:	eb 05                	jmp    801bf3 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801bee:	e8 94 ef ff ff       	call   800b87 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801bf3:	e8 10 ef ff ff       	call   800b08 <sys_cgetc>
  801bf8:	85 c0                	test   %eax,%eax
  801bfa:	74 f2                	je     801bee <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801bfc:	85 c0                	test   %eax,%eax
  801bfe:	78 16                	js     801c16 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801c00:	83 f8 04             	cmp    $0x4,%eax
  801c03:	74 0c                	je     801c11 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801c05:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c08:	88 02                	mov    %al,(%edx)
	return 1;
  801c0a:	b8 01 00 00 00       	mov    $0x1,%eax
  801c0f:	eb 05                	jmp    801c16 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801c11:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801c16:	c9                   	leave  
  801c17:	c3                   	ret    

00801c18 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801c18:	55                   	push   %ebp
  801c19:	89 e5                	mov    %esp,%ebp
  801c1b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801c1e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c21:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801c24:	6a 01                	push   $0x1
  801c26:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c29:	50                   	push   %eax
  801c2a:	e8 bb ee ff ff       	call   800aea <sys_cputs>
}
  801c2f:	83 c4 10             	add    $0x10,%esp
  801c32:	c9                   	leave  
  801c33:	c3                   	ret    

00801c34 <getchar>:

int
getchar(void)
{
  801c34:	55                   	push   %ebp
  801c35:	89 e5                	mov    %esp,%ebp
  801c37:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801c3a:	6a 01                	push   $0x1
  801c3c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c3f:	50                   	push   %eax
  801c40:	6a 00                	push   $0x0
  801c42:	e8 80 f5 ff ff       	call   8011c7 <read>
	if (r < 0)
  801c47:	83 c4 10             	add    $0x10,%esp
  801c4a:	85 c0                	test   %eax,%eax
  801c4c:	78 0f                	js     801c5d <getchar+0x29>
		return r;
	if (r < 1)
  801c4e:	85 c0                	test   %eax,%eax
  801c50:	7e 06                	jle    801c58 <getchar+0x24>
		return -E_EOF;
	return c;
  801c52:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801c56:	eb 05                	jmp    801c5d <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801c58:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801c5d:	c9                   	leave  
  801c5e:	c3                   	ret    

00801c5f <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801c5f:	55                   	push   %ebp
  801c60:	89 e5                	mov    %esp,%ebp
  801c62:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c65:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c68:	50                   	push   %eax
  801c69:	ff 75 08             	pushl  0x8(%ebp)
  801c6c:	e8 f0 f2 ff ff       	call   800f61 <fd_lookup>
  801c71:	83 c4 10             	add    $0x10,%esp
  801c74:	85 c0                	test   %eax,%eax
  801c76:	78 11                	js     801c89 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801c78:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c7b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c81:	39 10                	cmp    %edx,(%eax)
  801c83:	0f 94 c0             	sete   %al
  801c86:	0f b6 c0             	movzbl %al,%eax
}
  801c89:	c9                   	leave  
  801c8a:	c3                   	ret    

00801c8b <opencons>:

int
opencons(void)
{
  801c8b:	55                   	push   %ebp
  801c8c:	89 e5                	mov    %esp,%ebp
  801c8e:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801c91:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c94:	50                   	push   %eax
  801c95:	e8 78 f2 ff ff       	call   800f12 <fd_alloc>
  801c9a:	83 c4 10             	add    $0x10,%esp
		return r;
  801c9d:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801c9f:	85 c0                	test   %eax,%eax
  801ca1:	78 3e                	js     801ce1 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ca3:	83 ec 04             	sub    $0x4,%esp
  801ca6:	68 07 04 00 00       	push   $0x407
  801cab:	ff 75 f4             	pushl  -0xc(%ebp)
  801cae:	6a 00                	push   $0x0
  801cb0:	e8 f1 ee ff ff       	call   800ba6 <sys_page_alloc>
  801cb5:	83 c4 10             	add    $0x10,%esp
		return r;
  801cb8:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801cba:	85 c0                	test   %eax,%eax
  801cbc:	78 23                	js     801ce1 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801cbe:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cc7:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801cc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ccc:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801cd3:	83 ec 0c             	sub    $0xc,%esp
  801cd6:	50                   	push   %eax
  801cd7:	e8 0f f2 ff ff       	call   800eeb <fd2num>
  801cdc:	89 c2                	mov    %eax,%edx
  801cde:	83 c4 10             	add    $0x10,%esp
}
  801ce1:	89 d0                	mov    %edx,%eax
  801ce3:	c9                   	leave  
  801ce4:	c3                   	ret    

00801ce5 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801ce5:	55                   	push   %ebp
  801ce6:	89 e5                	mov    %esp,%ebp
  801ce8:	56                   	push   %esi
  801ce9:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801cea:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801ced:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801cf3:	e8 70 ee ff ff       	call   800b68 <sys_getenvid>
  801cf8:	83 ec 0c             	sub    $0xc,%esp
  801cfb:	ff 75 0c             	pushl  0xc(%ebp)
  801cfe:	ff 75 08             	pushl  0x8(%ebp)
  801d01:	56                   	push   %esi
  801d02:	50                   	push   %eax
  801d03:	68 38 25 80 00       	push   $0x802538
  801d08:	e8 f3 e4 ff ff       	call   800200 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801d0d:	83 c4 18             	add    $0x18,%esp
  801d10:	53                   	push   %ebx
  801d11:	ff 75 10             	pushl  0x10(%ebp)
  801d14:	e8 96 e4 ff ff       	call   8001af <vcprintf>
	cprintf("\n");
  801d19:	c7 04 24 f0 20 80 00 	movl   $0x8020f0,(%esp)
  801d20:	e8 db e4 ff ff       	call   800200 <cprintf>
  801d25:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801d28:	cc                   	int3   
  801d29:	eb fd                	jmp    801d28 <_panic+0x43>

00801d2b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801d2b:	55                   	push   %ebp
  801d2c:	89 e5                	mov    %esp,%ebp
  801d2e:	56                   	push   %esi
  801d2f:	53                   	push   %ebx
  801d30:	8b 75 08             	mov    0x8(%ebp),%esi
  801d33:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d36:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_recv not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  801d39:	85 c0                	test   %eax,%eax
  801d3b:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801d40:	0f 44 c2             	cmove  %edx,%eax

    int r = sys_ipc_recv(pg);
  801d43:	83 ec 0c             	sub    $0xc,%esp
  801d46:	50                   	push   %eax
  801d47:	e8 0a f0 ff ff       	call   800d56 <sys_ipc_recv>
    int from_env = 0, perm = 0;
    if (r == 0) {
  801d4c:	83 c4 10             	add    $0x10,%esp
  801d4f:	85 c0                	test   %eax,%eax
  801d51:	75 10                	jne    801d63 <ipc_recv+0x38>
        from_env = thisenv->env_ipc_from;
  801d53:	a1 04 40 80 00       	mov    0x804004,%eax
  801d58:	8b 48 74             	mov    0x74(%eax),%ecx
        perm = thisenv->env_ipc_perm;
  801d5b:	8b 50 78             	mov    0x78(%eax),%edx
        r = thisenv->env_ipc_value;
  801d5e:	8b 40 70             	mov    0x70(%eax),%eax
  801d61:	eb 0a                	jmp    801d6d <ipc_recv+0x42>
    } else {
        from_env = 0;
        perm = 0;
  801d63:	ba 00 00 00 00       	mov    $0x0,%edx
    if (r == 0) {
        from_env = thisenv->env_ipc_from;
        perm = thisenv->env_ipc_perm;
        r = thisenv->env_ipc_value;
    } else {
        from_env = 0;
  801d68:	b9 00 00 00 00       	mov    $0x0,%ecx
        perm = 0;
    }

    if (from_env_store) *from_env_store = from_env;
  801d6d:	85 f6                	test   %esi,%esi
  801d6f:	74 02                	je     801d73 <ipc_recv+0x48>
  801d71:	89 0e                	mov    %ecx,(%esi)
    if (perm_store) *perm_store = perm;
  801d73:	85 db                	test   %ebx,%ebx
  801d75:	74 02                	je     801d79 <ipc_recv+0x4e>
  801d77:	89 13                	mov    %edx,(%ebx)

    return r;
}
  801d79:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d7c:	5b                   	pop    %ebx
  801d7d:	5e                   	pop    %esi
  801d7e:	5d                   	pop    %ebp
  801d7f:	c3                   	ret    

00801d80 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801d80:	55                   	push   %ebp
  801d81:	89 e5                	mov    %esp,%ebp
  801d83:	57                   	push   %edi
  801d84:	56                   	push   %esi
  801d85:	53                   	push   %ebx
  801d86:	83 ec 0c             	sub    $0xc,%esp
  801d89:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d8c:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d8f:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  801d92:	85 db                	test   %ebx,%ebx
  801d94:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801d99:	0f 44 d8             	cmove  %eax,%ebx
  801d9c:	eb 1c                	jmp    801dba <ipc_send+0x3a>

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        if (ret != -E_IPC_NOT_RECV)
  801d9e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801da1:	74 12                	je     801db5 <ipc_send+0x35>
            panic("ipc_send error %e", ret);
  801da3:	50                   	push   %eax
  801da4:	68 5c 25 80 00       	push   $0x80255c
  801da9:	6a 40                	push   $0x40
  801dab:	68 6e 25 80 00       	push   $0x80256e
  801db0:	e8 30 ff ff ff       	call   801ce5 <_panic>
        sys_yield();
  801db5:	e8 cd ed ff ff       	call   800b87 <sys_yield>
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801dba:	ff 75 14             	pushl  0x14(%ebp)
  801dbd:	53                   	push   %ebx
  801dbe:	56                   	push   %esi
  801dbf:	57                   	push   %edi
  801dc0:	e8 6e ef ff ff       	call   800d33 <sys_ipc_try_send>
  801dc5:	83 c4 10             	add    $0x10,%esp
  801dc8:	85 c0                	test   %eax,%eax
  801dca:	75 d2                	jne    801d9e <ipc_send+0x1e>
        if (ret != -E_IPC_NOT_RECV)
            panic("ipc_send error %e", ret);
        sys_yield();
    }
}
  801dcc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dcf:	5b                   	pop    %ebx
  801dd0:	5e                   	pop    %esi
  801dd1:	5f                   	pop    %edi
  801dd2:	5d                   	pop    %ebp
  801dd3:	c3                   	ret    

00801dd4 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801dd4:	55                   	push   %ebp
  801dd5:	89 e5                	mov    %esp,%ebp
  801dd7:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801dda:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ddf:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801de2:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801de8:	8b 52 50             	mov    0x50(%edx),%edx
  801deb:	39 ca                	cmp    %ecx,%edx
  801ded:	75 0d                	jne    801dfc <ipc_find_env+0x28>
			return envs[i].env_id;
  801def:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801df2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801df7:	8b 40 48             	mov    0x48(%eax),%eax
  801dfa:	eb 0f                	jmp    801e0b <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801dfc:	83 c0 01             	add    $0x1,%eax
  801dff:	3d 00 04 00 00       	cmp    $0x400,%eax
  801e04:	75 d9                	jne    801ddf <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801e06:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e0b:	5d                   	pop    %ebp
  801e0c:	c3                   	ret    

00801e0d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801e0d:	55                   	push   %ebp
  801e0e:	89 e5                	mov    %esp,%ebp
  801e10:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e13:	89 d0                	mov    %edx,%eax
  801e15:	c1 e8 16             	shr    $0x16,%eax
  801e18:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801e1f:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e24:	f6 c1 01             	test   $0x1,%cl
  801e27:	74 1d                	je     801e46 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801e29:	c1 ea 0c             	shr    $0xc,%edx
  801e2c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801e33:	f6 c2 01             	test   $0x1,%dl
  801e36:	74 0e                	je     801e46 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801e38:	c1 ea 0c             	shr    $0xc,%edx
  801e3b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801e42:	ef 
  801e43:	0f b7 c0             	movzwl %ax,%eax
}
  801e46:	5d                   	pop    %ebp
  801e47:	c3                   	ret    
  801e48:	66 90                	xchg   %ax,%ax
  801e4a:	66 90                	xchg   %ax,%ax
  801e4c:	66 90                	xchg   %ax,%ax
  801e4e:	66 90                	xchg   %ax,%ax

00801e50 <__udivdi3>:
  801e50:	55                   	push   %ebp
  801e51:	57                   	push   %edi
  801e52:	56                   	push   %esi
  801e53:	53                   	push   %ebx
  801e54:	83 ec 1c             	sub    $0x1c,%esp
  801e57:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801e5b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801e5f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801e63:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801e67:	85 f6                	test   %esi,%esi
  801e69:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e6d:	89 ca                	mov    %ecx,%edx
  801e6f:	89 f8                	mov    %edi,%eax
  801e71:	75 3d                	jne    801eb0 <__udivdi3+0x60>
  801e73:	39 cf                	cmp    %ecx,%edi
  801e75:	0f 87 c5 00 00 00    	ja     801f40 <__udivdi3+0xf0>
  801e7b:	85 ff                	test   %edi,%edi
  801e7d:	89 fd                	mov    %edi,%ebp
  801e7f:	75 0b                	jne    801e8c <__udivdi3+0x3c>
  801e81:	b8 01 00 00 00       	mov    $0x1,%eax
  801e86:	31 d2                	xor    %edx,%edx
  801e88:	f7 f7                	div    %edi
  801e8a:	89 c5                	mov    %eax,%ebp
  801e8c:	89 c8                	mov    %ecx,%eax
  801e8e:	31 d2                	xor    %edx,%edx
  801e90:	f7 f5                	div    %ebp
  801e92:	89 c1                	mov    %eax,%ecx
  801e94:	89 d8                	mov    %ebx,%eax
  801e96:	89 cf                	mov    %ecx,%edi
  801e98:	f7 f5                	div    %ebp
  801e9a:	89 c3                	mov    %eax,%ebx
  801e9c:	89 d8                	mov    %ebx,%eax
  801e9e:	89 fa                	mov    %edi,%edx
  801ea0:	83 c4 1c             	add    $0x1c,%esp
  801ea3:	5b                   	pop    %ebx
  801ea4:	5e                   	pop    %esi
  801ea5:	5f                   	pop    %edi
  801ea6:	5d                   	pop    %ebp
  801ea7:	c3                   	ret    
  801ea8:	90                   	nop
  801ea9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801eb0:	39 ce                	cmp    %ecx,%esi
  801eb2:	77 74                	ja     801f28 <__udivdi3+0xd8>
  801eb4:	0f bd fe             	bsr    %esi,%edi
  801eb7:	83 f7 1f             	xor    $0x1f,%edi
  801eba:	0f 84 98 00 00 00    	je     801f58 <__udivdi3+0x108>
  801ec0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801ec5:	89 f9                	mov    %edi,%ecx
  801ec7:	89 c5                	mov    %eax,%ebp
  801ec9:	29 fb                	sub    %edi,%ebx
  801ecb:	d3 e6                	shl    %cl,%esi
  801ecd:	89 d9                	mov    %ebx,%ecx
  801ecf:	d3 ed                	shr    %cl,%ebp
  801ed1:	89 f9                	mov    %edi,%ecx
  801ed3:	d3 e0                	shl    %cl,%eax
  801ed5:	09 ee                	or     %ebp,%esi
  801ed7:	89 d9                	mov    %ebx,%ecx
  801ed9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801edd:	89 d5                	mov    %edx,%ebp
  801edf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ee3:	d3 ed                	shr    %cl,%ebp
  801ee5:	89 f9                	mov    %edi,%ecx
  801ee7:	d3 e2                	shl    %cl,%edx
  801ee9:	89 d9                	mov    %ebx,%ecx
  801eeb:	d3 e8                	shr    %cl,%eax
  801eed:	09 c2                	or     %eax,%edx
  801eef:	89 d0                	mov    %edx,%eax
  801ef1:	89 ea                	mov    %ebp,%edx
  801ef3:	f7 f6                	div    %esi
  801ef5:	89 d5                	mov    %edx,%ebp
  801ef7:	89 c3                	mov    %eax,%ebx
  801ef9:	f7 64 24 0c          	mull   0xc(%esp)
  801efd:	39 d5                	cmp    %edx,%ebp
  801eff:	72 10                	jb     801f11 <__udivdi3+0xc1>
  801f01:	8b 74 24 08          	mov    0x8(%esp),%esi
  801f05:	89 f9                	mov    %edi,%ecx
  801f07:	d3 e6                	shl    %cl,%esi
  801f09:	39 c6                	cmp    %eax,%esi
  801f0b:	73 07                	jae    801f14 <__udivdi3+0xc4>
  801f0d:	39 d5                	cmp    %edx,%ebp
  801f0f:	75 03                	jne    801f14 <__udivdi3+0xc4>
  801f11:	83 eb 01             	sub    $0x1,%ebx
  801f14:	31 ff                	xor    %edi,%edi
  801f16:	89 d8                	mov    %ebx,%eax
  801f18:	89 fa                	mov    %edi,%edx
  801f1a:	83 c4 1c             	add    $0x1c,%esp
  801f1d:	5b                   	pop    %ebx
  801f1e:	5e                   	pop    %esi
  801f1f:	5f                   	pop    %edi
  801f20:	5d                   	pop    %ebp
  801f21:	c3                   	ret    
  801f22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f28:	31 ff                	xor    %edi,%edi
  801f2a:	31 db                	xor    %ebx,%ebx
  801f2c:	89 d8                	mov    %ebx,%eax
  801f2e:	89 fa                	mov    %edi,%edx
  801f30:	83 c4 1c             	add    $0x1c,%esp
  801f33:	5b                   	pop    %ebx
  801f34:	5e                   	pop    %esi
  801f35:	5f                   	pop    %edi
  801f36:	5d                   	pop    %ebp
  801f37:	c3                   	ret    
  801f38:	90                   	nop
  801f39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f40:	89 d8                	mov    %ebx,%eax
  801f42:	f7 f7                	div    %edi
  801f44:	31 ff                	xor    %edi,%edi
  801f46:	89 c3                	mov    %eax,%ebx
  801f48:	89 d8                	mov    %ebx,%eax
  801f4a:	89 fa                	mov    %edi,%edx
  801f4c:	83 c4 1c             	add    $0x1c,%esp
  801f4f:	5b                   	pop    %ebx
  801f50:	5e                   	pop    %esi
  801f51:	5f                   	pop    %edi
  801f52:	5d                   	pop    %ebp
  801f53:	c3                   	ret    
  801f54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f58:	39 ce                	cmp    %ecx,%esi
  801f5a:	72 0c                	jb     801f68 <__udivdi3+0x118>
  801f5c:	31 db                	xor    %ebx,%ebx
  801f5e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801f62:	0f 87 34 ff ff ff    	ja     801e9c <__udivdi3+0x4c>
  801f68:	bb 01 00 00 00       	mov    $0x1,%ebx
  801f6d:	e9 2a ff ff ff       	jmp    801e9c <__udivdi3+0x4c>
  801f72:	66 90                	xchg   %ax,%ax
  801f74:	66 90                	xchg   %ax,%ax
  801f76:	66 90                	xchg   %ax,%ax
  801f78:	66 90                	xchg   %ax,%ax
  801f7a:	66 90                	xchg   %ax,%ax
  801f7c:	66 90                	xchg   %ax,%ax
  801f7e:	66 90                	xchg   %ax,%ax

00801f80 <__umoddi3>:
  801f80:	55                   	push   %ebp
  801f81:	57                   	push   %edi
  801f82:	56                   	push   %esi
  801f83:	53                   	push   %ebx
  801f84:	83 ec 1c             	sub    $0x1c,%esp
  801f87:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801f8b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801f8f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801f93:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f97:	85 d2                	test   %edx,%edx
  801f99:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801f9d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801fa1:	89 f3                	mov    %esi,%ebx
  801fa3:	89 3c 24             	mov    %edi,(%esp)
  801fa6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801faa:	75 1c                	jne    801fc8 <__umoddi3+0x48>
  801fac:	39 f7                	cmp    %esi,%edi
  801fae:	76 50                	jbe    802000 <__umoddi3+0x80>
  801fb0:	89 c8                	mov    %ecx,%eax
  801fb2:	89 f2                	mov    %esi,%edx
  801fb4:	f7 f7                	div    %edi
  801fb6:	89 d0                	mov    %edx,%eax
  801fb8:	31 d2                	xor    %edx,%edx
  801fba:	83 c4 1c             	add    $0x1c,%esp
  801fbd:	5b                   	pop    %ebx
  801fbe:	5e                   	pop    %esi
  801fbf:	5f                   	pop    %edi
  801fc0:	5d                   	pop    %ebp
  801fc1:	c3                   	ret    
  801fc2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801fc8:	39 f2                	cmp    %esi,%edx
  801fca:	89 d0                	mov    %edx,%eax
  801fcc:	77 52                	ja     802020 <__umoddi3+0xa0>
  801fce:	0f bd ea             	bsr    %edx,%ebp
  801fd1:	83 f5 1f             	xor    $0x1f,%ebp
  801fd4:	75 5a                	jne    802030 <__umoddi3+0xb0>
  801fd6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801fda:	0f 82 e0 00 00 00    	jb     8020c0 <__umoddi3+0x140>
  801fe0:	39 0c 24             	cmp    %ecx,(%esp)
  801fe3:	0f 86 d7 00 00 00    	jbe    8020c0 <__umoddi3+0x140>
  801fe9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801fed:	8b 54 24 04          	mov    0x4(%esp),%edx
  801ff1:	83 c4 1c             	add    $0x1c,%esp
  801ff4:	5b                   	pop    %ebx
  801ff5:	5e                   	pop    %esi
  801ff6:	5f                   	pop    %edi
  801ff7:	5d                   	pop    %ebp
  801ff8:	c3                   	ret    
  801ff9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802000:	85 ff                	test   %edi,%edi
  802002:	89 fd                	mov    %edi,%ebp
  802004:	75 0b                	jne    802011 <__umoddi3+0x91>
  802006:	b8 01 00 00 00       	mov    $0x1,%eax
  80200b:	31 d2                	xor    %edx,%edx
  80200d:	f7 f7                	div    %edi
  80200f:	89 c5                	mov    %eax,%ebp
  802011:	89 f0                	mov    %esi,%eax
  802013:	31 d2                	xor    %edx,%edx
  802015:	f7 f5                	div    %ebp
  802017:	89 c8                	mov    %ecx,%eax
  802019:	f7 f5                	div    %ebp
  80201b:	89 d0                	mov    %edx,%eax
  80201d:	eb 99                	jmp    801fb8 <__umoddi3+0x38>
  80201f:	90                   	nop
  802020:	89 c8                	mov    %ecx,%eax
  802022:	89 f2                	mov    %esi,%edx
  802024:	83 c4 1c             	add    $0x1c,%esp
  802027:	5b                   	pop    %ebx
  802028:	5e                   	pop    %esi
  802029:	5f                   	pop    %edi
  80202a:	5d                   	pop    %ebp
  80202b:	c3                   	ret    
  80202c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802030:	8b 34 24             	mov    (%esp),%esi
  802033:	bf 20 00 00 00       	mov    $0x20,%edi
  802038:	89 e9                	mov    %ebp,%ecx
  80203a:	29 ef                	sub    %ebp,%edi
  80203c:	d3 e0                	shl    %cl,%eax
  80203e:	89 f9                	mov    %edi,%ecx
  802040:	89 f2                	mov    %esi,%edx
  802042:	d3 ea                	shr    %cl,%edx
  802044:	89 e9                	mov    %ebp,%ecx
  802046:	09 c2                	or     %eax,%edx
  802048:	89 d8                	mov    %ebx,%eax
  80204a:	89 14 24             	mov    %edx,(%esp)
  80204d:	89 f2                	mov    %esi,%edx
  80204f:	d3 e2                	shl    %cl,%edx
  802051:	89 f9                	mov    %edi,%ecx
  802053:	89 54 24 04          	mov    %edx,0x4(%esp)
  802057:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80205b:	d3 e8                	shr    %cl,%eax
  80205d:	89 e9                	mov    %ebp,%ecx
  80205f:	89 c6                	mov    %eax,%esi
  802061:	d3 e3                	shl    %cl,%ebx
  802063:	89 f9                	mov    %edi,%ecx
  802065:	89 d0                	mov    %edx,%eax
  802067:	d3 e8                	shr    %cl,%eax
  802069:	89 e9                	mov    %ebp,%ecx
  80206b:	09 d8                	or     %ebx,%eax
  80206d:	89 d3                	mov    %edx,%ebx
  80206f:	89 f2                	mov    %esi,%edx
  802071:	f7 34 24             	divl   (%esp)
  802074:	89 d6                	mov    %edx,%esi
  802076:	d3 e3                	shl    %cl,%ebx
  802078:	f7 64 24 04          	mull   0x4(%esp)
  80207c:	39 d6                	cmp    %edx,%esi
  80207e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802082:	89 d1                	mov    %edx,%ecx
  802084:	89 c3                	mov    %eax,%ebx
  802086:	72 08                	jb     802090 <__umoddi3+0x110>
  802088:	75 11                	jne    80209b <__umoddi3+0x11b>
  80208a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80208e:	73 0b                	jae    80209b <__umoddi3+0x11b>
  802090:	2b 44 24 04          	sub    0x4(%esp),%eax
  802094:	1b 14 24             	sbb    (%esp),%edx
  802097:	89 d1                	mov    %edx,%ecx
  802099:	89 c3                	mov    %eax,%ebx
  80209b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80209f:	29 da                	sub    %ebx,%edx
  8020a1:	19 ce                	sbb    %ecx,%esi
  8020a3:	89 f9                	mov    %edi,%ecx
  8020a5:	89 f0                	mov    %esi,%eax
  8020a7:	d3 e0                	shl    %cl,%eax
  8020a9:	89 e9                	mov    %ebp,%ecx
  8020ab:	d3 ea                	shr    %cl,%edx
  8020ad:	89 e9                	mov    %ebp,%ecx
  8020af:	d3 ee                	shr    %cl,%esi
  8020b1:	09 d0                	or     %edx,%eax
  8020b3:	89 f2                	mov    %esi,%edx
  8020b5:	83 c4 1c             	add    $0x1c,%esp
  8020b8:	5b                   	pop    %ebx
  8020b9:	5e                   	pop    %esi
  8020ba:	5f                   	pop    %edi
  8020bb:	5d                   	pop    %ebp
  8020bc:	c3                   	ret    
  8020bd:	8d 76 00             	lea    0x0(%esi),%esi
  8020c0:	29 f9                	sub    %edi,%ecx
  8020c2:	19 d6                	sbb    %edx,%esi
  8020c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020c8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020cc:	e9 18 ff ff ff       	jmp    801fe9 <__umoddi3+0x69>
