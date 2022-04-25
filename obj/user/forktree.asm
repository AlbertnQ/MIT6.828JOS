
obj/user/forktree.debug:     file format elf32-i386


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
  80002c:	e8 b0 00 00 00       	call   8000e1 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <forktree>:
	}
}

void
forktree(const char *cur)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 04             	sub    $0x4,%esp
  80003a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  80003d:	e8 fa 0a 00 00       	call   800b3c <sys_getenvid>
  800042:	83 ec 04             	sub    $0x4,%esp
  800045:	53                   	push   %ebx
  800046:	50                   	push   %eax
  800047:	68 00 22 80 00       	push   $0x802200
  80004c:	e8 83 01 00 00       	call   8001d4 <cprintf>

	forkchild(cur, '0');
  800051:	83 c4 08             	add    $0x8,%esp
  800054:	6a 30                	push   $0x30
  800056:	53                   	push   %ebx
  800057:	e8 13 00 00 00       	call   80006f <forkchild>
	forkchild(cur, '1');
  80005c:	83 c4 08             	add    $0x8,%esp
  80005f:	6a 31                	push   $0x31
  800061:	53                   	push   %ebx
  800062:	e8 08 00 00 00       	call   80006f <forkchild>
}
  800067:	83 c4 10             	add    $0x10,%esp
  80006a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80006d:	c9                   	leave  
  80006e:	c3                   	ret    

0080006f <forkchild>:

void forktree(const char *cur);

void
forkchild(const char *cur, char branch)
{
  80006f:	55                   	push   %ebp
  800070:	89 e5                	mov    %esp,%ebp
  800072:	56                   	push   %esi
  800073:	53                   	push   %ebx
  800074:	83 ec 1c             	sub    $0x1c,%esp
  800077:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80007a:	8b 75 0c             	mov    0xc(%ebp),%esi
	char nxt[DEPTH+1];

	if (strlen(cur) >= DEPTH)
  80007d:	53                   	push   %ebx
  80007e:	e8 bb 06 00 00       	call   80073e <strlen>
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	83 f8 02             	cmp    $0x2,%eax
  800089:	7f 3a                	jg     8000c5 <forkchild+0x56>
		return;

	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	89 f0                	mov    %esi,%eax
  800090:	0f be f0             	movsbl %al,%esi
  800093:	56                   	push   %esi
  800094:	53                   	push   %ebx
  800095:	68 11 22 80 00       	push   $0x802211
  80009a:	6a 04                	push   $0x4
  80009c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80009f:	50                   	push   %eax
  8000a0:	e8 7f 06 00 00       	call   800724 <snprintf>
	if (fork() == 0) {
  8000a5:	83 c4 20             	add    $0x20,%esp
  8000a8:	e8 92 0e 00 00       	call   800f3f <fork>
  8000ad:	85 c0                	test   %eax,%eax
  8000af:	75 14                	jne    8000c5 <forkchild+0x56>
		forktree(nxt);
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000b7:	50                   	push   %eax
  8000b8:	e8 76 ff ff ff       	call   800033 <forktree>
		exit();
  8000bd:	e8 65 00 00 00       	call   800127 <exit>
  8000c2:	83 c4 10             	add    $0x10,%esp
	}
}
  8000c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c8:	5b                   	pop    %ebx
  8000c9:	5e                   	pop    %esi
  8000ca:	5d                   	pop    %ebp
  8000cb:	c3                   	ret    

008000cc <umain>:
	forkchild(cur, '1');
}

void
umain(int argc, char **argv)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	83 ec 14             	sub    $0x14,%esp
	forktree("");
  8000d2:	68 10 22 80 00       	push   $0x802210
  8000d7:	e8 57 ff ff ff       	call   800033 <forktree>
}
  8000dc:	83 c4 10             	add    $0x10,%esp
  8000df:	c9                   	leave  
  8000e0:	c3                   	ret    

008000e1 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e1:	55                   	push   %ebp
  8000e2:	89 e5                	mov    %esp,%ebp
  8000e4:	56                   	push   %esi
  8000e5:	53                   	push   %ebx
  8000e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000e9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  8000ec:	e8 4b 0a 00 00       	call   800b3c <sys_getenvid>
  8000f1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000f9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000fe:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800103:	85 db                	test   %ebx,%ebx
  800105:	7e 07                	jle    80010e <libmain+0x2d>
		binaryname = argv[0];
  800107:	8b 06                	mov    (%esi),%eax
  800109:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80010e:	83 ec 08             	sub    $0x8,%esp
  800111:	56                   	push   %esi
  800112:	53                   	push   %ebx
  800113:	e8 b4 ff ff ff       	call   8000cc <umain>

	// exit gracefully
	exit();
  800118:	e8 0a 00 00 00       	call   800127 <exit>
}
  80011d:	83 c4 10             	add    $0x10,%esp
  800120:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800123:	5b                   	pop    %ebx
  800124:	5e                   	pop    %esi
  800125:	5d                   	pop    %ebp
  800126:	c3                   	ret    

00800127 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800127:	55                   	push   %ebp
  800128:	89 e5                	mov    %esp,%ebp
  80012a:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80012d:	e8 14 11 00 00       	call   801246 <close_all>
	sys_env_destroy(0);
  800132:	83 ec 0c             	sub    $0xc,%esp
  800135:	6a 00                	push   $0x0
  800137:	e8 bf 09 00 00       	call   800afb <sys_env_destroy>
}
  80013c:	83 c4 10             	add    $0x10,%esp
  80013f:	c9                   	leave  
  800140:	c3                   	ret    

00800141 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800141:	55                   	push   %ebp
  800142:	89 e5                	mov    %esp,%ebp
  800144:	53                   	push   %ebx
  800145:	83 ec 04             	sub    $0x4,%esp
  800148:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80014b:	8b 13                	mov    (%ebx),%edx
  80014d:	8d 42 01             	lea    0x1(%edx),%eax
  800150:	89 03                	mov    %eax,(%ebx)
  800152:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800155:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800159:	3d ff 00 00 00       	cmp    $0xff,%eax
  80015e:	75 1a                	jne    80017a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800160:	83 ec 08             	sub    $0x8,%esp
  800163:	68 ff 00 00 00       	push   $0xff
  800168:	8d 43 08             	lea    0x8(%ebx),%eax
  80016b:	50                   	push   %eax
  80016c:	e8 4d 09 00 00       	call   800abe <sys_cputs>
		b->idx = 0;
  800171:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800177:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80017a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80017e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800181:	c9                   	leave  
  800182:	c3                   	ret    

00800183 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800183:	55                   	push   %ebp
  800184:	89 e5                	mov    %esp,%ebp
  800186:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80018c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800193:	00 00 00 
	b.cnt = 0;
  800196:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80019d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001a0:	ff 75 0c             	pushl  0xc(%ebp)
  8001a3:	ff 75 08             	pushl  0x8(%ebp)
  8001a6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001ac:	50                   	push   %eax
  8001ad:	68 41 01 80 00       	push   $0x800141
  8001b2:	e8 54 01 00 00       	call   80030b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001b7:	83 c4 08             	add    $0x8,%esp
  8001ba:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001c0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001c6:	50                   	push   %eax
  8001c7:	e8 f2 08 00 00       	call   800abe <sys_cputs>

	return b.cnt;
}
  8001cc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001d2:	c9                   	leave  
  8001d3:	c3                   	ret    

008001d4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001d4:	55                   	push   %ebp
  8001d5:	89 e5                	mov    %esp,%ebp
  8001d7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001da:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001dd:	50                   	push   %eax
  8001de:	ff 75 08             	pushl  0x8(%ebp)
  8001e1:	e8 9d ff ff ff       	call   800183 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001e6:	c9                   	leave  
  8001e7:	c3                   	ret    

008001e8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	57                   	push   %edi
  8001ec:	56                   	push   %esi
  8001ed:	53                   	push   %ebx
  8001ee:	83 ec 1c             	sub    $0x1c,%esp
  8001f1:	89 c7                	mov    %eax,%edi
  8001f3:	89 d6                	mov    %edx,%esi
  8001f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001fb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001fe:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800201:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800204:	bb 00 00 00 00       	mov    $0x0,%ebx
  800209:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80020c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80020f:	39 d3                	cmp    %edx,%ebx
  800211:	72 05                	jb     800218 <printnum+0x30>
  800213:	39 45 10             	cmp    %eax,0x10(%ebp)
  800216:	77 45                	ja     80025d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800218:	83 ec 0c             	sub    $0xc,%esp
  80021b:	ff 75 18             	pushl  0x18(%ebp)
  80021e:	8b 45 14             	mov    0x14(%ebp),%eax
  800221:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800224:	53                   	push   %ebx
  800225:	ff 75 10             	pushl  0x10(%ebp)
  800228:	83 ec 08             	sub    $0x8,%esp
  80022b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80022e:	ff 75 e0             	pushl  -0x20(%ebp)
  800231:	ff 75 dc             	pushl  -0x24(%ebp)
  800234:	ff 75 d8             	pushl  -0x28(%ebp)
  800237:	e8 24 1d 00 00       	call   801f60 <__udivdi3>
  80023c:	83 c4 18             	add    $0x18,%esp
  80023f:	52                   	push   %edx
  800240:	50                   	push   %eax
  800241:	89 f2                	mov    %esi,%edx
  800243:	89 f8                	mov    %edi,%eax
  800245:	e8 9e ff ff ff       	call   8001e8 <printnum>
  80024a:	83 c4 20             	add    $0x20,%esp
  80024d:	eb 18                	jmp    800267 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80024f:	83 ec 08             	sub    $0x8,%esp
  800252:	56                   	push   %esi
  800253:	ff 75 18             	pushl  0x18(%ebp)
  800256:	ff d7                	call   *%edi
  800258:	83 c4 10             	add    $0x10,%esp
  80025b:	eb 03                	jmp    800260 <printnum+0x78>
  80025d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800260:	83 eb 01             	sub    $0x1,%ebx
  800263:	85 db                	test   %ebx,%ebx
  800265:	7f e8                	jg     80024f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800267:	83 ec 08             	sub    $0x8,%esp
  80026a:	56                   	push   %esi
  80026b:	83 ec 04             	sub    $0x4,%esp
  80026e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800271:	ff 75 e0             	pushl  -0x20(%ebp)
  800274:	ff 75 dc             	pushl  -0x24(%ebp)
  800277:	ff 75 d8             	pushl  -0x28(%ebp)
  80027a:	e8 11 1e 00 00       	call   802090 <__umoddi3>
  80027f:	83 c4 14             	add    $0x14,%esp
  800282:	0f be 80 20 22 80 00 	movsbl 0x802220(%eax),%eax
  800289:	50                   	push   %eax
  80028a:	ff d7                	call   *%edi
}
  80028c:	83 c4 10             	add    $0x10,%esp
  80028f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800292:	5b                   	pop    %ebx
  800293:	5e                   	pop    %esi
  800294:	5f                   	pop    %edi
  800295:	5d                   	pop    %ebp
  800296:	c3                   	ret    

00800297 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800297:	55                   	push   %ebp
  800298:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80029a:	83 fa 01             	cmp    $0x1,%edx
  80029d:	7e 0e                	jle    8002ad <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80029f:	8b 10                	mov    (%eax),%edx
  8002a1:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002a4:	89 08                	mov    %ecx,(%eax)
  8002a6:	8b 02                	mov    (%edx),%eax
  8002a8:	8b 52 04             	mov    0x4(%edx),%edx
  8002ab:	eb 22                	jmp    8002cf <getuint+0x38>
	else if (lflag)
  8002ad:	85 d2                	test   %edx,%edx
  8002af:	74 10                	je     8002c1 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002b1:	8b 10                	mov    (%eax),%edx
  8002b3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b6:	89 08                	mov    %ecx,(%eax)
  8002b8:	8b 02                	mov    (%edx),%eax
  8002ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8002bf:	eb 0e                	jmp    8002cf <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002c1:	8b 10                	mov    (%eax),%edx
  8002c3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c6:	89 08                	mov    %ecx,(%eax)
  8002c8:	8b 02                	mov    (%edx),%eax
  8002ca:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002cf:	5d                   	pop    %ebp
  8002d0:	c3                   	ret    

008002d1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002d1:	55                   	push   %ebp
  8002d2:	89 e5                	mov    %esp,%ebp
  8002d4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002d7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002db:	8b 10                	mov    (%eax),%edx
  8002dd:	3b 50 04             	cmp    0x4(%eax),%edx
  8002e0:	73 0a                	jae    8002ec <sprintputch+0x1b>
		*b->buf++ = ch;
  8002e2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002e5:	89 08                	mov    %ecx,(%eax)
  8002e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ea:	88 02                	mov    %al,(%edx)
}
  8002ec:	5d                   	pop    %ebp
  8002ed:	c3                   	ret    

008002ee <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ee:	55                   	push   %ebp
  8002ef:	89 e5                	mov    %esp,%ebp
  8002f1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002f4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002f7:	50                   	push   %eax
  8002f8:	ff 75 10             	pushl  0x10(%ebp)
  8002fb:	ff 75 0c             	pushl  0xc(%ebp)
  8002fe:	ff 75 08             	pushl  0x8(%ebp)
  800301:	e8 05 00 00 00       	call   80030b <vprintfmt>
	va_end(ap);
}
  800306:	83 c4 10             	add    $0x10,%esp
  800309:	c9                   	leave  
  80030a:	c3                   	ret    

0080030b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80030b:	55                   	push   %ebp
  80030c:	89 e5                	mov    %esp,%ebp
  80030e:	57                   	push   %edi
  80030f:	56                   	push   %esi
  800310:	53                   	push   %ebx
  800311:	83 ec 2c             	sub    $0x2c,%esp
  800314:	8b 75 08             	mov    0x8(%ebp),%esi
  800317:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80031a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80031d:	eb 12                	jmp    800331 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80031f:	85 c0                	test   %eax,%eax
  800321:	0f 84 a7 03 00 00    	je     8006ce <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
  800327:	83 ec 08             	sub    $0x8,%esp
  80032a:	53                   	push   %ebx
  80032b:	50                   	push   %eax
  80032c:	ff d6                	call   *%esi
  80032e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800331:	83 c7 01             	add    $0x1,%edi
  800334:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800338:	83 f8 25             	cmp    $0x25,%eax
  80033b:	75 e2                	jne    80031f <vprintfmt+0x14>
  80033d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800341:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800348:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80034f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800356:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80035d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800362:	eb 07                	jmp    80036b <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800364:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800367:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036b:	8d 47 01             	lea    0x1(%edi),%eax
  80036e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800371:	0f b6 07             	movzbl (%edi),%eax
  800374:	0f b6 d0             	movzbl %al,%edx
  800377:	83 e8 23             	sub    $0x23,%eax
  80037a:	3c 55                	cmp    $0x55,%al
  80037c:	0f 87 31 03 00 00    	ja     8006b3 <vprintfmt+0x3a8>
  800382:	0f b6 c0             	movzbl %al,%eax
  800385:	ff 24 85 60 23 80 00 	jmp    *0x802360(,%eax,4)
  80038c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80038f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800393:	eb d6                	jmp    80036b <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800395:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800398:	b8 00 00 00 00       	mov    $0x0,%eax
  80039d:	89 75 08             	mov    %esi,0x8(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003a0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003a3:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003a7:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003aa:	8d 72 d0             	lea    -0x30(%edx),%esi
  8003ad:	83 fe 09             	cmp    $0x9,%esi
  8003b0:	77 34                	ja     8003e6 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003b2:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003b5:	eb e9                	jmp    8003a0 <vprintfmt+0x95>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ba:	8d 50 04             	lea    0x4(%eax),%edx
  8003bd:	89 55 14             	mov    %edx,0x14(%ebp)
  8003c0:	8b 00                	mov    (%eax),%eax
  8003c2:	89 45 cc             	mov    %eax,-0x34(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003c8:	eb 22                	jmp    8003ec <vprintfmt+0xe1>
  8003ca:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003cd:	85 c0                	test   %eax,%eax
  8003cf:	0f 48 c1             	cmovs  %ecx,%eax
  8003d2:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003d8:	eb 91                	jmp    80036b <vprintfmt+0x60>
  8003da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003dd:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003e4:	eb 85                	jmp    80036b <vprintfmt+0x60>
  8003e6:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003e9:	8b 75 08             	mov    0x8(%ebp),%esi

		process_precision:
			if (width < 0)
  8003ec:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003f0:	0f 89 75 ff ff ff    	jns    80036b <vprintfmt+0x60>
				width = precision, precision = -1;
  8003f6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8003f9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003fc:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800403:	e9 63 ff ff ff       	jmp    80036b <vprintfmt+0x60>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800408:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80040f:	e9 57 ff ff ff       	jmp    80036b <vprintfmt+0x60>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800414:	8b 45 14             	mov    0x14(%ebp),%eax
  800417:	8d 50 04             	lea    0x4(%eax),%edx
  80041a:	89 55 14             	mov    %edx,0x14(%ebp)
  80041d:	83 ec 08             	sub    $0x8,%esp
  800420:	53                   	push   %ebx
  800421:	ff 30                	pushl  (%eax)
  800423:	ff d6                	call   *%esi
			break;
  800425:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800428:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80042b:	e9 01 ff ff ff       	jmp    800331 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800430:	8b 45 14             	mov    0x14(%ebp),%eax
  800433:	8d 50 04             	lea    0x4(%eax),%edx
  800436:	89 55 14             	mov    %edx,0x14(%ebp)
  800439:	8b 00                	mov    (%eax),%eax
  80043b:	99                   	cltd   
  80043c:	31 d0                	xor    %edx,%eax
  80043e:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800440:	83 f8 0f             	cmp    $0xf,%eax
  800443:	7f 0b                	jg     800450 <vprintfmt+0x145>
  800445:	8b 14 85 c0 24 80 00 	mov    0x8024c0(,%eax,4),%edx
  80044c:	85 d2                	test   %edx,%edx
  80044e:	75 18                	jne    800468 <vprintfmt+0x15d>
				printfmt(putch, putdat, "error %d", err);
  800450:	50                   	push   %eax
  800451:	68 38 22 80 00       	push   $0x802238
  800456:	53                   	push   %ebx
  800457:	56                   	push   %esi
  800458:	e8 91 fe ff ff       	call   8002ee <printfmt>
  80045d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800460:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800463:	e9 c9 fe ff ff       	jmp    800331 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800468:	52                   	push   %edx
  800469:	68 19 27 80 00       	push   $0x802719
  80046e:	53                   	push   %ebx
  80046f:	56                   	push   %esi
  800470:	e8 79 fe ff ff       	call   8002ee <printfmt>
  800475:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800478:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80047b:	e9 b1 fe ff ff       	jmp    800331 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800480:	8b 45 14             	mov    0x14(%ebp),%eax
  800483:	8d 50 04             	lea    0x4(%eax),%edx
  800486:	89 55 14             	mov    %edx,0x14(%ebp)
  800489:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80048b:	85 ff                	test   %edi,%edi
  80048d:	b8 31 22 80 00       	mov    $0x802231,%eax
  800492:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800495:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800499:	0f 8e 94 00 00 00    	jle    800533 <vprintfmt+0x228>
  80049f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004a3:	0f 84 98 00 00 00    	je     800541 <vprintfmt+0x236>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a9:	83 ec 08             	sub    $0x8,%esp
  8004ac:	ff 75 cc             	pushl  -0x34(%ebp)
  8004af:	57                   	push   %edi
  8004b0:	e8 a1 02 00 00       	call   800756 <strnlen>
  8004b5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004b8:	29 c1                	sub    %eax,%ecx
  8004ba:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8004bd:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004c0:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004c4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004c7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004ca:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004cc:	eb 0f                	jmp    8004dd <vprintfmt+0x1d2>
					putch(padc, putdat);
  8004ce:	83 ec 08             	sub    $0x8,%esp
  8004d1:	53                   	push   %ebx
  8004d2:	ff 75 e0             	pushl  -0x20(%ebp)
  8004d5:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d7:	83 ef 01             	sub    $0x1,%edi
  8004da:	83 c4 10             	add    $0x10,%esp
  8004dd:	85 ff                	test   %edi,%edi
  8004df:	7f ed                	jg     8004ce <vprintfmt+0x1c3>
  8004e1:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004e4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004e7:	85 c9                	test   %ecx,%ecx
  8004e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ee:	0f 49 c1             	cmovns %ecx,%eax
  8004f1:	29 c1                	sub    %eax,%ecx
  8004f3:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f6:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8004f9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004fc:	89 cb                	mov    %ecx,%ebx
  8004fe:	eb 4d                	jmp    80054d <vprintfmt+0x242>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800500:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800504:	74 1b                	je     800521 <vprintfmt+0x216>
  800506:	0f be c0             	movsbl %al,%eax
  800509:	83 e8 20             	sub    $0x20,%eax
  80050c:	83 f8 5e             	cmp    $0x5e,%eax
  80050f:	76 10                	jbe    800521 <vprintfmt+0x216>
					putch('?', putdat);
  800511:	83 ec 08             	sub    $0x8,%esp
  800514:	ff 75 0c             	pushl  0xc(%ebp)
  800517:	6a 3f                	push   $0x3f
  800519:	ff 55 08             	call   *0x8(%ebp)
  80051c:	83 c4 10             	add    $0x10,%esp
  80051f:	eb 0d                	jmp    80052e <vprintfmt+0x223>
				else
					putch(ch, putdat);
  800521:	83 ec 08             	sub    $0x8,%esp
  800524:	ff 75 0c             	pushl  0xc(%ebp)
  800527:	52                   	push   %edx
  800528:	ff 55 08             	call   *0x8(%ebp)
  80052b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80052e:	83 eb 01             	sub    $0x1,%ebx
  800531:	eb 1a                	jmp    80054d <vprintfmt+0x242>
  800533:	89 75 08             	mov    %esi,0x8(%ebp)
  800536:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800539:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80053c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80053f:	eb 0c                	jmp    80054d <vprintfmt+0x242>
  800541:	89 75 08             	mov    %esi,0x8(%ebp)
  800544:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800547:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80054a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80054d:	83 c7 01             	add    $0x1,%edi
  800550:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800554:	0f be d0             	movsbl %al,%edx
  800557:	85 d2                	test   %edx,%edx
  800559:	74 23                	je     80057e <vprintfmt+0x273>
  80055b:	85 f6                	test   %esi,%esi
  80055d:	78 a1                	js     800500 <vprintfmt+0x1f5>
  80055f:	83 ee 01             	sub    $0x1,%esi
  800562:	79 9c                	jns    800500 <vprintfmt+0x1f5>
  800564:	89 df                	mov    %ebx,%edi
  800566:	8b 75 08             	mov    0x8(%ebp),%esi
  800569:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80056c:	eb 18                	jmp    800586 <vprintfmt+0x27b>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80056e:	83 ec 08             	sub    $0x8,%esp
  800571:	53                   	push   %ebx
  800572:	6a 20                	push   $0x20
  800574:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800576:	83 ef 01             	sub    $0x1,%edi
  800579:	83 c4 10             	add    $0x10,%esp
  80057c:	eb 08                	jmp    800586 <vprintfmt+0x27b>
  80057e:	89 df                	mov    %ebx,%edi
  800580:	8b 75 08             	mov    0x8(%ebp),%esi
  800583:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800586:	85 ff                	test   %edi,%edi
  800588:	7f e4                	jg     80056e <vprintfmt+0x263>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80058d:	e9 9f fd ff ff       	jmp    800331 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800592:	83 7d d0 01          	cmpl   $0x1,-0x30(%ebp)
  800596:	7e 16                	jle    8005ae <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  800598:	8b 45 14             	mov    0x14(%ebp),%eax
  80059b:	8d 50 08             	lea    0x8(%eax),%edx
  80059e:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a1:	8b 50 04             	mov    0x4(%eax),%edx
  8005a4:	8b 00                	mov    (%eax),%eax
  8005a6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005ac:	eb 34                	jmp    8005e2 <vprintfmt+0x2d7>
	else if (lflag)
  8005ae:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8005b2:	74 18                	je     8005cc <vprintfmt+0x2c1>
		return va_arg(*ap, long);
  8005b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b7:	8d 50 04             	lea    0x4(%eax),%edx
  8005ba:	89 55 14             	mov    %edx,0x14(%ebp)
  8005bd:	8b 00                	mov    (%eax),%eax
  8005bf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c2:	89 c1                	mov    %eax,%ecx
  8005c4:	c1 f9 1f             	sar    $0x1f,%ecx
  8005c7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005ca:	eb 16                	jmp    8005e2 <vprintfmt+0x2d7>
	else
		return va_arg(*ap, int);
  8005cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cf:	8d 50 04             	lea    0x4(%eax),%edx
  8005d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d5:	8b 00                	mov    (%eax),%eax
  8005d7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005da:	89 c1                	mov    %eax,%ecx
  8005dc:	c1 f9 1f             	sar    $0x1f,%ecx
  8005df:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005e2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005e5:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005e8:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005ed:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005f1:	0f 89 88 00 00 00    	jns    80067f <vprintfmt+0x374>
				putch('-', putdat);
  8005f7:	83 ec 08             	sub    $0x8,%esp
  8005fa:	53                   	push   %ebx
  8005fb:	6a 2d                	push   $0x2d
  8005fd:	ff d6                	call   *%esi
				num = -(long long) num;
  8005ff:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800602:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800605:	f7 d8                	neg    %eax
  800607:	83 d2 00             	adc    $0x0,%edx
  80060a:	f7 da                	neg    %edx
  80060c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80060f:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800614:	eb 69                	jmp    80067f <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800616:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800619:	8d 45 14             	lea    0x14(%ebp),%eax
  80061c:	e8 76 fc ff ff       	call   800297 <getuint>
			base = 10;
  800621:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800626:	eb 57                	jmp    80067f <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  800628:	83 ec 08             	sub    $0x8,%esp
  80062b:	53                   	push   %ebx
  80062c:	6a 30                	push   $0x30
  80062e:	ff d6                	call   *%esi
			num = getuint(&ap, lflag);
  800630:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800633:	8d 45 14             	lea    0x14(%ebp),%eax
  800636:	e8 5c fc ff ff       	call   800297 <getuint>
			base = 8;
			goto number;
  80063b:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  80063e:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800643:	eb 3a                	jmp    80067f <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  800645:	83 ec 08             	sub    $0x8,%esp
  800648:	53                   	push   %ebx
  800649:	6a 30                	push   $0x30
  80064b:	ff d6                	call   *%esi
			putch('x', putdat);
  80064d:	83 c4 08             	add    $0x8,%esp
  800650:	53                   	push   %ebx
  800651:	6a 78                	push   $0x78
  800653:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800655:	8b 45 14             	mov    0x14(%ebp),%eax
  800658:	8d 50 04             	lea    0x4(%eax),%edx
  80065b:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80065e:	8b 00                	mov    (%eax),%eax
  800660:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800665:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800668:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80066d:	eb 10                	jmp    80067f <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80066f:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800672:	8d 45 14             	lea    0x14(%ebp),%eax
  800675:	e8 1d fc ff ff       	call   800297 <getuint>
			base = 16;
  80067a:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80067f:	83 ec 0c             	sub    $0xc,%esp
  800682:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800686:	57                   	push   %edi
  800687:	ff 75 e0             	pushl  -0x20(%ebp)
  80068a:	51                   	push   %ecx
  80068b:	52                   	push   %edx
  80068c:	50                   	push   %eax
  80068d:	89 da                	mov    %ebx,%edx
  80068f:	89 f0                	mov    %esi,%eax
  800691:	e8 52 fb ff ff       	call   8001e8 <printnum>
			break;
  800696:	83 c4 20             	add    $0x20,%esp
  800699:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80069c:	e9 90 fc ff ff       	jmp    800331 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006a1:	83 ec 08             	sub    $0x8,%esp
  8006a4:	53                   	push   %ebx
  8006a5:	52                   	push   %edx
  8006a6:	ff d6                	call   *%esi
			break;
  8006a8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006ae:	e9 7e fc ff ff       	jmp    800331 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006b3:	83 ec 08             	sub    $0x8,%esp
  8006b6:	53                   	push   %ebx
  8006b7:	6a 25                	push   $0x25
  8006b9:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006bb:	83 c4 10             	add    $0x10,%esp
  8006be:	eb 03                	jmp    8006c3 <vprintfmt+0x3b8>
  8006c0:	83 ef 01             	sub    $0x1,%edi
  8006c3:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006c7:	75 f7                	jne    8006c0 <vprintfmt+0x3b5>
  8006c9:	e9 63 fc ff ff       	jmp    800331 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006d1:	5b                   	pop    %ebx
  8006d2:	5e                   	pop    %esi
  8006d3:	5f                   	pop    %edi
  8006d4:	5d                   	pop    %ebp
  8006d5:	c3                   	ret    

008006d6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006d6:	55                   	push   %ebp
  8006d7:	89 e5                	mov    %esp,%ebp
  8006d9:	83 ec 18             	sub    $0x18,%esp
  8006dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006df:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006e2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006e5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006e9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006ec:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006f3:	85 c0                	test   %eax,%eax
  8006f5:	74 26                	je     80071d <vsnprintf+0x47>
  8006f7:	85 d2                	test   %edx,%edx
  8006f9:	7e 22                	jle    80071d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006fb:	ff 75 14             	pushl  0x14(%ebp)
  8006fe:	ff 75 10             	pushl  0x10(%ebp)
  800701:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800704:	50                   	push   %eax
  800705:	68 d1 02 80 00       	push   $0x8002d1
  80070a:	e8 fc fb ff ff       	call   80030b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80070f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800712:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800715:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800718:	83 c4 10             	add    $0x10,%esp
  80071b:	eb 05                	jmp    800722 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80071d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800722:	c9                   	leave  
  800723:	c3                   	ret    

00800724 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800724:	55                   	push   %ebp
  800725:	89 e5                	mov    %esp,%ebp
  800727:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80072a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80072d:	50                   	push   %eax
  80072e:	ff 75 10             	pushl  0x10(%ebp)
  800731:	ff 75 0c             	pushl  0xc(%ebp)
  800734:	ff 75 08             	pushl  0x8(%ebp)
  800737:	e8 9a ff ff ff       	call   8006d6 <vsnprintf>
	va_end(ap);

	return rc;
}
  80073c:	c9                   	leave  
  80073d:	c3                   	ret    

0080073e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80073e:	55                   	push   %ebp
  80073f:	89 e5                	mov    %esp,%ebp
  800741:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800744:	b8 00 00 00 00       	mov    $0x0,%eax
  800749:	eb 03                	jmp    80074e <strlen+0x10>
		n++;
  80074b:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80074e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800752:	75 f7                	jne    80074b <strlen+0xd>
		n++;
	return n;
}
  800754:	5d                   	pop    %ebp
  800755:	c3                   	ret    

00800756 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800756:	55                   	push   %ebp
  800757:	89 e5                	mov    %esp,%ebp
  800759:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80075c:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80075f:	ba 00 00 00 00       	mov    $0x0,%edx
  800764:	eb 03                	jmp    800769 <strnlen+0x13>
		n++;
  800766:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800769:	39 c2                	cmp    %eax,%edx
  80076b:	74 08                	je     800775 <strnlen+0x1f>
  80076d:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800771:	75 f3                	jne    800766 <strnlen+0x10>
  800773:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800775:	5d                   	pop    %ebp
  800776:	c3                   	ret    

00800777 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800777:	55                   	push   %ebp
  800778:	89 e5                	mov    %esp,%ebp
  80077a:	53                   	push   %ebx
  80077b:	8b 45 08             	mov    0x8(%ebp),%eax
  80077e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800781:	89 c2                	mov    %eax,%edx
  800783:	83 c2 01             	add    $0x1,%edx
  800786:	83 c1 01             	add    $0x1,%ecx
  800789:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80078d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800790:	84 db                	test   %bl,%bl
  800792:	75 ef                	jne    800783 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800794:	5b                   	pop    %ebx
  800795:	5d                   	pop    %ebp
  800796:	c3                   	ret    

00800797 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800797:	55                   	push   %ebp
  800798:	89 e5                	mov    %esp,%ebp
  80079a:	53                   	push   %ebx
  80079b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80079e:	53                   	push   %ebx
  80079f:	e8 9a ff ff ff       	call   80073e <strlen>
  8007a4:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007a7:	ff 75 0c             	pushl  0xc(%ebp)
  8007aa:	01 d8                	add    %ebx,%eax
  8007ac:	50                   	push   %eax
  8007ad:	e8 c5 ff ff ff       	call   800777 <strcpy>
	return dst;
}
  8007b2:	89 d8                	mov    %ebx,%eax
  8007b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b7:	c9                   	leave  
  8007b8:	c3                   	ret    

008007b9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007b9:	55                   	push   %ebp
  8007ba:	89 e5                	mov    %esp,%ebp
  8007bc:	56                   	push   %esi
  8007bd:	53                   	push   %ebx
  8007be:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007c4:	89 f3                	mov    %esi,%ebx
  8007c6:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c9:	89 f2                	mov    %esi,%edx
  8007cb:	eb 0f                	jmp    8007dc <strncpy+0x23>
		*dst++ = *src;
  8007cd:	83 c2 01             	add    $0x1,%edx
  8007d0:	0f b6 01             	movzbl (%ecx),%eax
  8007d3:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007d6:	80 39 01             	cmpb   $0x1,(%ecx)
  8007d9:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007dc:	39 da                	cmp    %ebx,%edx
  8007de:	75 ed                	jne    8007cd <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007e0:	89 f0                	mov    %esi,%eax
  8007e2:	5b                   	pop    %ebx
  8007e3:	5e                   	pop    %esi
  8007e4:	5d                   	pop    %ebp
  8007e5:	c3                   	ret    

008007e6 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007e6:	55                   	push   %ebp
  8007e7:	89 e5                	mov    %esp,%ebp
  8007e9:	56                   	push   %esi
  8007ea:	53                   	push   %ebx
  8007eb:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f1:	8b 55 10             	mov    0x10(%ebp),%edx
  8007f4:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007f6:	85 d2                	test   %edx,%edx
  8007f8:	74 21                	je     80081b <strlcpy+0x35>
  8007fa:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007fe:	89 f2                	mov    %esi,%edx
  800800:	eb 09                	jmp    80080b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800802:	83 c2 01             	add    $0x1,%edx
  800805:	83 c1 01             	add    $0x1,%ecx
  800808:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80080b:	39 c2                	cmp    %eax,%edx
  80080d:	74 09                	je     800818 <strlcpy+0x32>
  80080f:	0f b6 19             	movzbl (%ecx),%ebx
  800812:	84 db                	test   %bl,%bl
  800814:	75 ec                	jne    800802 <strlcpy+0x1c>
  800816:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800818:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80081b:	29 f0                	sub    %esi,%eax
}
  80081d:	5b                   	pop    %ebx
  80081e:	5e                   	pop    %esi
  80081f:	5d                   	pop    %ebp
  800820:	c3                   	ret    

00800821 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800821:	55                   	push   %ebp
  800822:	89 e5                	mov    %esp,%ebp
  800824:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800827:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80082a:	eb 06                	jmp    800832 <strcmp+0x11>
		p++, q++;
  80082c:	83 c1 01             	add    $0x1,%ecx
  80082f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800832:	0f b6 01             	movzbl (%ecx),%eax
  800835:	84 c0                	test   %al,%al
  800837:	74 04                	je     80083d <strcmp+0x1c>
  800839:	3a 02                	cmp    (%edx),%al
  80083b:	74 ef                	je     80082c <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80083d:	0f b6 c0             	movzbl %al,%eax
  800840:	0f b6 12             	movzbl (%edx),%edx
  800843:	29 d0                	sub    %edx,%eax
}
  800845:	5d                   	pop    %ebp
  800846:	c3                   	ret    

00800847 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800847:	55                   	push   %ebp
  800848:	89 e5                	mov    %esp,%ebp
  80084a:	53                   	push   %ebx
  80084b:	8b 45 08             	mov    0x8(%ebp),%eax
  80084e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800851:	89 c3                	mov    %eax,%ebx
  800853:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800856:	eb 06                	jmp    80085e <strncmp+0x17>
		n--, p++, q++;
  800858:	83 c0 01             	add    $0x1,%eax
  80085b:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80085e:	39 d8                	cmp    %ebx,%eax
  800860:	74 15                	je     800877 <strncmp+0x30>
  800862:	0f b6 08             	movzbl (%eax),%ecx
  800865:	84 c9                	test   %cl,%cl
  800867:	74 04                	je     80086d <strncmp+0x26>
  800869:	3a 0a                	cmp    (%edx),%cl
  80086b:	74 eb                	je     800858 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80086d:	0f b6 00             	movzbl (%eax),%eax
  800870:	0f b6 12             	movzbl (%edx),%edx
  800873:	29 d0                	sub    %edx,%eax
  800875:	eb 05                	jmp    80087c <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800877:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80087c:	5b                   	pop    %ebx
  80087d:	5d                   	pop    %ebp
  80087e:	c3                   	ret    

0080087f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80087f:	55                   	push   %ebp
  800880:	89 e5                	mov    %esp,%ebp
  800882:	8b 45 08             	mov    0x8(%ebp),%eax
  800885:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800889:	eb 07                	jmp    800892 <strchr+0x13>
		if (*s == c)
  80088b:	38 ca                	cmp    %cl,%dl
  80088d:	74 0f                	je     80089e <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80088f:	83 c0 01             	add    $0x1,%eax
  800892:	0f b6 10             	movzbl (%eax),%edx
  800895:	84 d2                	test   %dl,%dl
  800897:	75 f2                	jne    80088b <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800899:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80089e:	5d                   	pop    %ebp
  80089f:	c3                   	ret    

008008a0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008aa:	eb 03                	jmp    8008af <strfind+0xf>
  8008ac:	83 c0 01             	add    $0x1,%eax
  8008af:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008b2:	38 ca                	cmp    %cl,%dl
  8008b4:	74 04                	je     8008ba <strfind+0x1a>
  8008b6:	84 d2                	test   %dl,%dl
  8008b8:	75 f2                	jne    8008ac <strfind+0xc>
			break;
	return (char *) s;
}
  8008ba:	5d                   	pop    %ebp
  8008bb:	c3                   	ret    

008008bc <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008bc:	55                   	push   %ebp
  8008bd:	89 e5                	mov    %esp,%ebp
  8008bf:	57                   	push   %edi
  8008c0:	56                   	push   %esi
  8008c1:	53                   	push   %ebx
  8008c2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008c5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008c8:	85 c9                	test   %ecx,%ecx
  8008ca:	74 36                	je     800902 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008cc:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008d2:	75 28                	jne    8008fc <memset+0x40>
  8008d4:	f6 c1 03             	test   $0x3,%cl
  8008d7:	75 23                	jne    8008fc <memset+0x40>
		c &= 0xFF;
  8008d9:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008dd:	89 d3                	mov    %edx,%ebx
  8008df:	c1 e3 08             	shl    $0x8,%ebx
  8008e2:	89 d6                	mov    %edx,%esi
  8008e4:	c1 e6 18             	shl    $0x18,%esi
  8008e7:	89 d0                	mov    %edx,%eax
  8008e9:	c1 e0 10             	shl    $0x10,%eax
  8008ec:	09 f0                	or     %esi,%eax
  8008ee:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008f0:	89 d8                	mov    %ebx,%eax
  8008f2:	09 d0                	or     %edx,%eax
  8008f4:	c1 e9 02             	shr    $0x2,%ecx
  8008f7:	fc                   	cld    
  8008f8:	f3 ab                	rep stos %eax,%es:(%edi)
  8008fa:	eb 06                	jmp    800902 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ff:	fc                   	cld    
  800900:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800902:	89 f8                	mov    %edi,%eax
  800904:	5b                   	pop    %ebx
  800905:	5e                   	pop    %esi
  800906:	5f                   	pop    %edi
  800907:	5d                   	pop    %ebp
  800908:	c3                   	ret    

00800909 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800909:	55                   	push   %ebp
  80090a:	89 e5                	mov    %esp,%ebp
  80090c:	57                   	push   %edi
  80090d:	56                   	push   %esi
  80090e:	8b 45 08             	mov    0x8(%ebp),%eax
  800911:	8b 75 0c             	mov    0xc(%ebp),%esi
  800914:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800917:	39 c6                	cmp    %eax,%esi
  800919:	73 35                	jae    800950 <memmove+0x47>
  80091b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80091e:	39 d0                	cmp    %edx,%eax
  800920:	73 2e                	jae    800950 <memmove+0x47>
		s += n;
		d += n;
  800922:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800925:	89 d6                	mov    %edx,%esi
  800927:	09 fe                	or     %edi,%esi
  800929:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80092f:	75 13                	jne    800944 <memmove+0x3b>
  800931:	f6 c1 03             	test   $0x3,%cl
  800934:	75 0e                	jne    800944 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800936:	83 ef 04             	sub    $0x4,%edi
  800939:	8d 72 fc             	lea    -0x4(%edx),%esi
  80093c:	c1 e9 02             	shr    $0x2,%ecx
  80093f:	fd                   	std    
  800940:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800942:	eb 09                	jmp    80094d <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800944:	83 ef 01             	sub    $0x1,%edi
  800947:	8d 72 ff             	lea    -0x1(%edx),%esi
  80094a:	fd                   	std    
  80094b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80094d:	fc                   	cld    
  80094e:	eb 1d                	jmp    80096d <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800950:	89 f2                	mov    %esi,%edx
  800952:	09 c2                	or     %eax,%edx
  800954:	f6 c2 03             	test   $0x3,%dl
  800957:	75 0f                	jne    800968 <memmove+0x5f>
  800959:	f6 c1 03             	test   $0x3,%cl
  80095c:	75 0a                	jne    800968 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80095e:	c1 e9 02             	shr    $0x2,%ecx
  800961:	89 c7                	mov    %eax,%edi
  800963:	fc                   	cld    
  800964:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800966:	eb 05                	jmp    80096d <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800968:	89 c7                	mov    %eax,%edi
  80096a:	fc                   	cld    
  80096b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80096d:	5e                   	pop    %esi
  80096e:	5f                   	pop    %edi
  80096f:	5d                   	pop    %ebp
  800970:	c3                   	ret    

00800971 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800971:	55                   	push   %ebp
  800972:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800974:	ff 75 10             	pushl  0x10(%ebp)
  800977:	ff 75 0c             	pushl  0xc(%ebp)
  80097a:	ff 75 08             	pushl  0x8(%ebp)
  80097d:	e8 87 ff ff ff       	call   800909 <memmove>
}
  800982:	c9                   	leave  
  800983:	c3                   	ret    

00800984 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800984:	55                   	push   %ebp
  800985:	89 e5                	mov    %esp,%ebp
  800987:	56                   	push   %esi
  800988:	53                   	push   %ebx
  800989:	8b 45 08             	mov    0x8(%ebp),%eax
  80098c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098f:	89 c6                	mov    %eax,%esi
  800991:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800994:	eb 1a                	jmp    8009b0 <memcmp+0x2c>
		if (*s1 != *s2)
  800996:	0f b6 08             	movzbl (%eax),%ecx
  800999:	0f b6 1a             	movzbl (%edx),%ebx
  80099c:	38 d9                	cmp    %bl,%cl
  80099e:	74 0a                	je     8009aa <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009a0:	0f b6 c1             	movzbl %cl,%eax
  8009a3:	0f b6 db             	movzbl %bl,%ebx
  8009a6:	29 d8                	sub    %ebx,%eax
  8009a8:	eb 0f                	jmp    8009b9 <memcmp+0x35>
		s1++, s2++;
  8009aa:	83 c0 01             	add    $0x1,%eax
  8009ad:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b0:	39 f0                	cmp    %esi,%eax
  8009b2:	75 e2                	jne    800996 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b9:	5b                   	pop    %ebx
  8009ba:	5e                   	pop    %esi
  8009bb:	5d                   	pop    %ebp
  8009bc:	c3                   	ret    

008009bd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009bd:	55                   	push   %ebp
  8009be:	89 e5                	mov    %esp,%ebp
  8009c0:	53                   	push   %ebx
  8009c1:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009c4:	89 c1                	mov    %eax,%ecx
  8009c6:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009c9:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009cd:	eb 0a                	jmp    8009d9 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009cf:	0f b6 10             	movzbl (%eax),%edx
  8009d2:	39 da                	cmp    %ebx,%edx
  8009d4:	74 07                	je     8009dd <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009d6:	83 c0 01             	add    $0x1,%eax
  8009d9:	39 c8                	cmp    %ecx,%eax
  8009db:	72 f2                	jb     8009cf <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009dd:	5b                   	pop    %ebx
  8009de:	5d                   	pop    %ebp
  8009df:	c3                   	ret    

008009e0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009e0:	55                   	push   %ebp
  8009e1:	89 e5                	mov    %esp,%ebp
  8009e3:	57                   	push   %edi
  8009e4:	56                   	push   %esi
  8009e5:	53                   	push   %ebx
  8009e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009e9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ec:	eb 03                	jmp    8009f1 <strtol+0x11>
		s++;
  8009ee:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f1:	0f b6 01             	movzbl (%ecx),%eax
  8009f4:	3c 20                	cmp    $0x20,%al
  8009f6:	74 f6                	je     8009ee <strtol+0xe>
  8009f8:	3c 09                	cmp    $0x9,%al
  8009fa:	74 f2                	je     8009ee <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009fc:	3c 2b                	cmp    $0x2b,%al
  8009fe:	75 0a                	jne    800a0a <strtol+0x2a>
		s++;
  800a00:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a03:	bf 00 00 00 00       	mov    $0x0,%edi
  800a08:	eb 11                	jmp    800a1b <strtol+0x3b>
  800a0a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a0f:	3c 2d                	cmp    $0x2d,%al
  800a11:	75 08                	jne    800a1b <strtol+0x3b>
		s++, neg = 1;
  800a13:	83 c1 01             	add    $0x1,%ecx
  800a16:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a1b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a21:	75 15                	jne    800a38 <strtol+0x58>
  800a23:	80 39 30             	cmpb   $0x30,(%ecx)
  800a26:	75 10                	jne    800a38 <strtol+0x58>
  800a28:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a2c:	75 7c                	jne    800aaa <strtol+0xca>
		s += 2, base = 16;
  800a2e:	83 c1 02             	add    $0x2,%ecx
  800a31:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a36:	eb 16                	jmp    800a4e <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a38:	85 db                	test   %ebx,%ebx
  800a3a:	75 12                	jne    800a4e <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a3c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a41:	80 39 30             	cmpb   $0x30,(%ecx)
  800a44:	75 08                	jne    800a4e <strtol+0x6e>
		s++, base = 8;
  800a46:	83 c1 01             	add    $0x1,%ecx
  800a49:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a4e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a53:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a56:	0f b6 11             	movzbl (%ecx),%edx
  800a59:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a5c:	89 f3                	mov    %esi,%ebx
  800a5e:	80 fb 09             	cmp    $0x9,%bl
  800a61:	77 08                	ja     800a6b <strtol+0x8b>
			dig = *s - '0';
  800a63:	0f be d2             	movsbl %dl,%edx
  800a66:	83 ea 30             	sub    $0x30,%edx
  800a69:	eb 22                	jmp    800a8d <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a6b:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a6e:	89 f3                	mov    %esi,%ebx
  800a70:	80 fb 19             	cmp    $0x19,%bl
  800a73:	77 08                	ja     800a7d <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a75:	0f be d2             	movsbl %dl,%edx
  800a78:	83 ea 57             	sub    $0x57,%edx
  800a7b:	eb 10                	jmp    800a8d <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a7d:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a80:	89 f3                	mov    %esi,%ebx
  800a82:	80 fb 19             	cmp    $0x19,%bl
  800a85:	77 16                	ja     800a9d <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a87:	0f be d2             	movsbl %dl,%edx
  800a8a:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a8d:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a90:	7d 0b                	jge    800a9d <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a92:	83 c1 01             	add    $0x1,%ecx
  800a95:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a99:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a9b:	eb b9                	jmp    800a56 <strtol+0x76>

	if (endptr)
  800a9d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aa1:	74 0d                	je     800ab0 <strtol+0xd0>
		*endptr = (char *) s;
  800aa3:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aa6:	89 0e                	mov    %ecx,(%esi)
  800aa8:	eb 06                	jmp    800ab0 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aaa:	85 db                	test   %ebx,%ebx
  800aac:	74 98                	je     800a46 <strtol+0x66>
  800aae:	eb 9e                	jmp    800a4e <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ab0:	89 c2                	mov    %eax,%edx
  800ab2:	f7 da                	neg    %edx
  800ab4:	85 ff                	test   %edi,%edi
  800ab6:	0f 45 c2             	cmovne %edx,%eax
}
  800ab9:	5b                   	pop    %ebx
  800aba:	5e                   	pop    %esi
  800abb:	5f                   	pop    %edi
  800abc:	5d                   	pop    %ebp
  800abd:	c3                   	ret    

00800abe <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800abe:	55                   	push   %ebp
  800abf:	89 e5                	mov    %esp,%ebp
  800ac1:	57                   	push   %edi
  800ac2:	56                   	push   %esi
  800ac3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800acc:	8b 55 08             	mov    0x8(%ebp),%edx
  800acf:	89 c3                	mov    %eax,%ebx
  800ad1:	89 c7                	mov    %eax,%edi
  800ad3:	89 c6                	mov    %eax,%esi
  800ad5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ad7:	5b                   	pop    %ebx
  800ad8:	5e                   	pop    %esi
  800ad9:	5f                   	pop    %edi
  800ada:	5d                   	pop    %ebp
  800adb:	c3                   	ret    

00800adc <sys_cgetc>:

int
sys_cgetc(void)
{
  800adc:	55                   	push   %ebp
  800add:	89 e5                	mov    %esp,%ebp
  800adf:	57                   	push   %edi
  800ae0:	56                   	push   %esi
  800ae1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae7:	b8 01 00 00 00       	mov    $0x1,%eax
  800aec:	89 d1                	mov    %edx,%ecx
  800aee:	89 d3                	mov    %edx,%ebx
  800af0:	89 d7                	mov    %edx,%edi
  800af2:	89 d6                	mov    %edx,%esi
  800af4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800af6:	5b                   	pop    %ebx
  800af7:	5e                   	pop    %esi
  800af8:	5f                   	pop    %edi
  800af9:	5d                   	pop    %ebp
  800afa:	c3                   	ret    

00800afb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	57                   	push   %edi
  800aff:	56                   	push   %esi
  800b00:	53                   	push   %ebx
  800b01:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b04:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b09:	b8 03 00 00 00       	mov    $0x3,%eax
  800b0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b11:	89 cb                	mov    %ecx,%ebx
  800b13:	89 cf                	mov    %ecx,%edi
  800b15:	89 ce                	mov    %ecx,%esi
  800b17:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b19:	85 c0                	test   %eax,%eax
  800b1b:	7e 17                	jle    800b34 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b1d:	83 ec 0c             	sub    $0xc,%esp
  800b20:	50                   	push   %eax
  800b21:	6a 03                	push   $0x3
  800b23:	68 1f 25 80 00       	push   $0x80251f
  800b28:	6a 23                	push   $0x23
  800b2a:	68 3c 25 80 00       	push   $0x80253c
  800b2f:	e8 31 12 00 00       	call   801d65 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b37:	5b                   	pop    %ebx
  800b38:	5e                   	pop    %esi
  800b39:	5f                   	pop    %edi
  800b3a:	5d                   	pop    %ebp
  800b3b:	c3                   	ret    

00800b3c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	57                   	push   %edi
  800b40:	56                   	push   %esi
  800b41:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b42:	ba 00 00 00 00       	mov    $0x0,%edx
  800b47:	b8 02 00 00 00       	mov    $0x2,%eax
  800b4c:	89 d1                	mov    %edx,%ecx
  800b4e:	89 d3                	mov    %edx,%ebx
  800b50:	89 d7                	mov    %edx,%edi
  800b52:	89 d6                	mov    %edx,%esi
  800b54:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b56:	5b                   	pop    %ebx
  800b57:	5e                   	pop    %esi
  800b58:	5f                   	pop    %edi
  800b59:	5d                   	pop    %ebp
  800b5a:	c3                   	ret    

00800b5b <sys_yield>:

void
sys_yield(void)
{
  800b5b:	55                   	push   %ebp
  800b5c:	89 e5                	mov    %esp,%ebp
  800b5e:	57                   	push   %edi
  800b5f:	56                   	push   %esi
  800b60:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b61:	ba 00 00 00 00       	mov    $0x0,%edx
  800b66:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b6b:	89 d1                	mov    %edx,%ecx
  800b6d:	89 d3                	mov    %edx,%ebx
  800b6f:	89 d7                	mov    %edx,%edi
  800b71:	89 d6                	mov    %edx,%esi
  800b73:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b75:	5b                   	pop    %ebx
  800b76:	5e                   	pop    %esi
  800b77:	5f                   	pop    %edi
  800b78:	5d                   	pop    %ebp
  800b79:	c3                   	ret    

00800b7a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b7a:	55                   	push   %ebp
  800b7b:	89 e5                	mov    %esp,%ebp
  800b7d:	57                   	push   %edi
  800b7e:	56                   	push   %esi
  800b7f:	53                   	push   %ebx
  800b80:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b83:	be 00 00 00 00       	mov    $0x0,%esi
  800b88:	b8 04 00 00 00       	mov    $0x4,%eax
  800b8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b90:	8b 55 08             	mov    0x8(%ebp),%edx
  800b93:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b96:	89 f7                	mov    %esi,%edi
  800b98:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b9a:	85 c0                	test   %eax,%eax
  800b9c:	7e 17                	jle    800bb5 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9e:	83 ec 0c             	sub    $0xc,%esp
  800ba1:	50                   	push   %eax
  800ba2:	6a 04                	push   $0x4
  800ba4:	68 1f 25 80 00       	push   $0x80251f
  800ba9:	6a 23                	push   $0x23
  800bab:	68 3c 25 80 00       	push   $0x80253c
  800bb0:	e8 b0 11 00 00       	call   801d65 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bb5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb8:	5b                   	pop    %ebx
  800bb9:	5e                   	pop    %esi
  800bba:	5f                   	pop    %edi
  800bbb:	5d                   	pop    %ebp
  800bbc:	c3                   	ret    

00800bbd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bbd:	55                   	push   %ebp
  800bbe:	89 e5                	mov    %esp,%ebp
  800bc0:	57                   	push   %edi
  800bc1:	56                   	push   %esi
  800bc2:	53                   	push   %ebx
  800bc3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc6:	b8 05 00 00 00       	mov    $0x5,%eax
  800bcb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bce:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bd7:	8b 75 18             	mov    0x18(%ebp),%esi
  800bda:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bdc:	85 c0                	test   %eax,%eax
  800bde:	7e 17                	jle    800bf7 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be0:	83 ec 0c             	sub    $0xc,%esp
  800be3:	50                   	push   %eax
  800be4:	6a 05                	push   $0x5
  800be6:	68 1f 25 80 00       	push   $0x80251f
  800beb:	6a 23                	push   $0x23
  800bed:	68 3c 25 80 00       	push   $0x80253c
  800bf2:	e8 6e 11 00 00       	call   801d65 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bf7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bfa:	5b                   	pop    %ebx
  800bfb:	5e                   	pop    %esi
  800bfc:	5f                   	pop    %edi
  800bfd:	5d                   	pop    %ebp
  800bfe:	c3                   	ret    

00800bff <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bff:	55                   	push   %ebp
  800c00:	89 e5                	mov    %esp,%ebp
  800c02:	57                   	push   %edi
  800c03:	56                   	push   %esi
  800c04:	53                   	push   %ebx
  800c05:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c08:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c0d:	b8 06 00 00 00       	mov    $0x6,%eax
  800c12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c15:	8b 55 08             	mov    0x8(%ebp),%edx
  800c18:	89 df                	mov    %ebx,%edi
  800c1a:	89 de                	mov    %ebx,%esi
  800c1c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c1e:	85 c0                	test   %eax,%eax
  800c20:	7e 17                	jle    800c39 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c22:	83 ec 0c             	sub    $0xc,%esp
  800c25:	50                   	push   %eax
  800c26:	6a 06                	push   $0x6
  800c28:	68 1f 25 80 00       	push   $0x80251f
  800c2d:	6a 23                	push   $0x23
  800c2f:	68 3c 25 80 00       	push   $0x80253c
  800c34:	e8 2c 11 00 00       	call   801d65 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c39:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3c:	5b                   	pop    %ebx
  800c3d:	5e                   	pop    %esi
  800c3e:	5f                   	pop    %edi
  800c3f:	5d                   	pop    %ebp
  800c40:	c3                   	ret    

00800c41 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c41:	55                   	push   %ebp
  800c42:	89 e5                	mov    %esp,%ebp
  800c44:	57                   	push   %edi
  800c45:	56                   	push   %esi
  800c46:	53                   	push   %ebx
  800c47:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c4f:	b8 08 00 00 00       	mov    $0x8,%eax
  800c54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c57:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5a:	89 df                	mov    %ebx,%edi
  800c5c:	89 de                	mov    %ebx,%esi
  800c5e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c60:	85 c0                	test   %eax,%eax
  800c62:	7e 17                	jle    800c7b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c64:	83 ec 0c             	sub    $0xc,%esp
  800c67:	50                   	push   %eax
  800c68:	6a 08                	push   $0x8
  800c6a:	68 1f 25 80 00       	push   $0x80251f
  800c6f:	6a 23                	push   $0x23
  800c71:	68 3c 25 80 00       	push   $0x80253c
  800c76:	e8 ea 10 00 00       	call   801d65 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7e:	5b                   	pop    %ebx
  800c7f:	5e                   	pop    %esi
  800c80:	5f                   	pop    %edi
  800c81:	5d                   	pop    %ebp
  800c82:	c3                   	ret    

00800c83 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c83:	55                   	push   %ebp
  800c84:	89 e5                	mov    %esp,%ebp
  800c86:	57                   	push   %edi
  800c87:	56                   	push   %esi
  800c88:	53                   	push   %ebx
  800c89:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c91:	b8 09 00 00 00       	mov    $0x9,%eax
  800c96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c99:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9c:	89 df                	mov    %ebx,%edi
  800c9e:	89 de                	mov    %ebx,%esi
  800ca0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca2:	85 c0                	test   %eax,%eax
  800ca4:	7e 17                	jle    800cbd <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca6:	83 ec 0c             	sub    $0xc,%esp
  800ca9:	50                   	push   %eax
  800caa:	6a 09                	push   $0x9
  800cac:	68 1f 25 80 00       	push   $0x80251f
  800cb1:	6a 23                	push   $0x23
  800cb3:	68 3c 25 80 00       	push   $0x80253c
  800cb8:	e8 a8 10 00 00       	call   801d65 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cbd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc0:	5b                   	pop    %ebx
  800cc1:	5e                   	pop    %esi
  800cc2:	5f                   	pop    %edi
  800cc3:	5d                   	pop    %ebp
  800cc4:	c3                   	ret    

00800cc5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cc5:	55                   	push   %ebp
  800cc6:	89 e5                	mov    %esp,%ebp
  800cc8:	57                   	push   %edi
  800cc9:	56                   	push   %esi
  800cca:	53                   	push   %ebx
  800ccb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cce:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd3:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cd8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cde:	89 df                	mov    %ebx,%edi
  800ce0:	89 de                	mov    %ebx,%esi
  800ce2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce4:	85 c0                	test   %eax,%eax
  800ce6:	7e 17                	jle    800cff <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce8:	83 ec 0c             	sub    $0xc,%esp
  800ceb:	50                   	push   %eax
  800cec:	6a 0a                	push   $0xa
  800cee:	68 1f 25 80 00       	push   $0x80251f
  800cf3:	6a 23                	push   $0x23
  800cf5:	68 3c 25 80 00       	push   $0x80253c
  800cfa:	e8 66 10 00 00       	call   801d65 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d02:	5b                   	pop    %ebx
  800d03:	5e                   	pop    %esi
  800d04:	5f                   	pop    %edi
  800d05:	5d                   	pop    %ebp
  800d06:	c3                   	ret    

00800d07 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d07:	55                   	push   %ebp
  800d08:	89 e5                	mov    %esp,%ebp
  800d0a:	57                   	push   %edi
  800d0b:	56                   	push   %esi
  800d0c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0d:	be 00 00 00 00       	mov    $0x0,%esi
  800d12:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d20:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d23:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d25:	5b                   	pop    %ebx
  800d26:	5e                   	pop    %esi
  800d27:	5f                   	pop    %edi
  800d28:	5d                   	pop    %ebp
  800d29:	c3                   	ret    

00800d2a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d2a:	55                   	push   %ebp
  800d2b:	89 e5                	mov    %esp,%ebp
  800d2d:	57                   	push   %edi
  800d2e:	56                   	push   %esi
  800d2f:	53                   	push   %ebx
  800d30:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d33:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d38:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d40:	89 cb                	mov    %ecx,%ebx
  800d42:	89 cf                	mov    %ecx,%edi
  800d44:	89 ce                	mov    %ecx,%esi
  800d46:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d48:	85 c0                	test   %eax,%eax
  800d4a:	7e 17                	jle    800d63 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4c:	83 ec 0c             	sub    $0xc,%esp
  800d4f:	50                   	push   %eax
  800d50:	6a 0d                	push   $0xd
  800d52:	68 1f 25 80 00       	push   $0x80251f
  800d57:	6a 23                	push   $0x23
  800d59:	68 3c 25 80 00       	push   $0x80253c
  800d5e:	e8 02 10 00 00       	call   801d65 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d63:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d66:	5b                   	pop    %ebx
  800d67:	5e                   	pop    %esi
  800d68:	5f                   	pop    %edi
  800d69:	5d                   	pop    %ebp
  800d6a:	c3                   	ret    

00800d6b <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800d6b:	55                   	push   %ebp
  800d6c:	89 e5                	mov    %esp,%ebp
  800d6e:	53                   	push   %ebx
  800d6f:	83 ec 04             	sub    $0x4,%esp
	int r;
	// LAB 4: Your code here.
    	pte_t *pte;
	int ret;
	// 用户空间的地址较低
	void *addr = (void *)(pn * PGSIZE);
  800d72:	89 d3                	mov    %edx,%ebx
  800d74:	c1 e3 0c             	shl    $0xc,%ebx
	if (uvpt[pn] & PTE_SHARE) {
  800d77:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800d7e:	f6 c5 04             	test   $0x4,%ch
  800d81:	74 2f                	je     800db2 <duppage+0x47>
		// cprintf("dup share page :%d\n", pn);
		if ((r = sys_page_map(0, addr, envid, addr, PTE_SYSCALL)) < 0)
  800d83:	83 ec 0c             	sub    $0xc,%esp
  800d86:	68 07 0e 00 00       	push   $0xe07
  800d8b:	53                   	push   %ebx
  800d8c:	50                   	push   %eax
  800d8d:	53                   	push   %ebx
  800d8e:	6a 00                	push   $0x0
  800d90:	e8 28 fe ff ff       	call   800bbd <sys_page_map>
  800d95:	83 c4 20             	add    $0x20,%esp
  800d98:	85 c0                	test   %eax,%eax
  800d9a:	0f 89 a0 00 00 00    	jns    800e40 <duppage+0xd5>
			panic("duppage sys_page_map:%e", r);
  800da0:	50                   	push   %eax
  800da1:	68 4a 25 80 00       	push   $0x80254a
  800da6:	6a 4d                	push   $0x4d
  800da8:	68 62 25 80 00       	push   $0x802562
  800dad:	e8 b3 0f 00 00       	call   801d65 <_panic>
	} else if (uvpt[pn] & (PTE_W|PTE_COW)) {
  800db2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800db9:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800dbf:	74 57                	je     800e18 <duppage+0xad>
		if ((r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  800dc1:	83 ec 0c             	sub    $0xc,%esp
  800dc4:	68 05 08 00 00       	push   $0x805
  800dc9:	53                   	push   %ebx
  800dca:	50                   	push   %eax
  800dcb:	53                   	push   %ebx
  800dcc:	6a 00                	push   $0x0
  800dce:	e8 ea fd ff ff       	call   800bbd <sys_page_map>
  800dd3:	83 c4 20             	add    $0x20,%esp
  800dd6:	85 c0                	test   %eax,%eax
  800dd8:	79 12                	jns    800dec <duppage+0x81>
			panic("sys_page_map COW:%e", r);
  800dda:	50                   	push   %eax
  800ddb:	68 6d 25 80 00       	push   $0x80256d
  800de0:	6a 50                	push   $0x50
  800de2:	68 62 25 80 00       	push   $0x802562
  800de7:	e8 79 0f 00 00       	call   801d65 <_panic>

		if ((r = sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  800dec:	83 ec 0c             	sub    $0xc,%esp
  800def:	68 05 08 00 00       	push   $0x805
  800df4:	53                   	push   %ebx
  800df5:	6a 00                	push   $0x0
  800df7:	53                   	push   %ebx
  800df8:	6a 00                	push   $0x0
  800dfa:	e8 be fd ff ff       	call   800bbd <sys_page_map>
  800dff:	83 c4 20             	add    $0x20,%esp
  800e02:	85 c0                	test   %eax,%eax
  800e04:	79 3a                	jns    800e40 <duppage+0xd5>
			panic("sys_page_map COW:%e", r);
  800e06:	50                   	push   %eax
  800e07:	68 6d 25 80 00       	push   $0x80256d
  800e0c:	6a 53                	push   $0x53
  800e0e:	68 62 25 80 00       	push   $0x802562
  800e13:	e8 4d 0f 00 00       	call   801d65 <_panic>
	} else {
		if ((r = sys_page_map(0, addr, envid, addr, PTE_U|PTE_P)) < 0)
  800e18:	83 ec 0c             	sub    $0xc,%esp
  800e1b:	6a 05                	push   $0x5
  800e1d:	53                   	push   %ebx
  800e1e:	50                   	push   %eax
  800e1f:	53                   	push   %ebx
  800e20:	6a 00                	push   $0x0
  800e22:	e8 96 fd ff ff       	call   800bbd <sys_page_map>
  800e27:	83 c4 20             	add    $0x20,%esp
  800e2a:	85 c0                	test   %eax,%eax
  800e2c:	79 12                	jns    800e40 <duppage+0xd5>
			panic("sys_page_map UP:%e", r);
  800e2e:	50                   	push   %eax
  800e2f:	68 81 25 80 00       	push   $0x802581
  800e34:	6a 56                	push   $0x56
  800e36:	68 62 25 80 00       	push   $0x802562
  800e3b:	e8 25 0f 00 00       	call   801d65 <_panic>
	}
	return 0;
}
  800e40:	b8 00 00 00 00       	mov    $0x0,%eax
  800e45:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e48:	c9                   	leave  
  800e49:	c3                   	ret    

00800e4a <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e4a:	55                   	push   %ebp
  800e4b:	89 e5                	mov    %esp,%ebp
  800e4d:	56                   	push   %esi
  800e4e:	53                   	push   %ebx
  800e4f:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e52:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (! ( (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  800e54:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e58:	74 2d                	je     800e87 <pgfault+0x3d>
  800e5a:	89 d8                	mov    %ebx,%eax
  800e5c:	c1 e8 16             	shr    $0x16,%eax
  800e5f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e66:	a8 01                	test   $0x1,%al
  800e68:	74 1d                	je     800e87 <pgfault+0x3d>
  800e6a:	89 d8                	mov    %ebx,%eax
  800e6c:	c1 e8 0c             	shr    $0xc,%eax
  800e6f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800e76:	f6 c2 01             	test   $0x1,%dl
  800e79:	74 0c                	je     800e87 <pgfault+0x3d>
  800e7b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e82:	f6 c4 08             	test   $0x8,%ah
  800e85:	75 14                	jne    800e9b <pgfault+0x51>
        	panic("Neither the fault is a write nor COW page. \n");
  800e87:	83 ec 04             	sub    $0x4,%esp
  800e8a:	68 00 26 80 00       	push   $0x802600
  800e8f:	6a 1d                	push   $0x1d
  800e91:	68 62 25 80 00       	push   $0x802562
  800e96:	e8 ca 0e 00 00       	call   801d65 <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.
	

    	envid_t envid = sys_getenvid();
  800e9b:	e8 9c fc ff ff       	call   800b3c <sys_getenvid>
  800ea0:	89 c6                	mov    %eax,%esi
    	// cprintf("pgfault: envid: %d\n", ENVX(envid));
    	// 临时页暂存
    	if ((r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P| PTE_W|PTE_U)) < 0)
  800ea2:	83 ec 04             	sub    $0x4,%esp
  800ea5:	6a 07                	push   $0x7
  800ea7:	68 00 f0 7f 00       	push   $0x7ff000
  800eac:	50                   	push   %eax
  800ead:	e8 c8 fc ff ff       	call   800b7a <sys_page_alloc>
  800eb2:	83 c4 10             	add    $0x10,%esp
  800eb5:	85 c0                	test   %eax,%eax
  800eb7:	79 12                	jns    800ecb <pgfault+0x81>
        	panic("pgfault: page allocation fault:%e\n", r);
  800eb9:	50                   	push   %eax
  800eba:	68 30 26 80 00       	push   $0x802630
  800ebf:	6a 2b                	push   $0x2b
  800ec1:	68 62 25 80 00       	push   $0x802562
  800ec6:	e8 9a 0e 00 00       	call   801d65 <_panic>
    	addr = ROUNDDOWN(addr, PGSIZE);
  800ecb:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  800ed1:	83 ec 04             	sub    $0x4,%esp
  800ed4:	68 00 10 00 00       	push   $0x1000
  800ed9:	53                   	push   %ebx
  800eda:	68 00 f0 7f 00       	push   $0x7ff000
  800edf:	e8 8d fa ff ff       	call   800971 <memcpy>
    	if ((r = sys_page_map(envid, (void *) PFTEMP, envid, addr , PTE_P|PTE_W|PTE_U)) < 0 )
  800ee4:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800eeb:	53                   	push   %ebx
  800eec:	56                   	push   %esi
  800eed:	68 00 f0 7f 00       	push   $0x7ff000
  800ef2:	56                   	push   %esi
  800ef3:	e8 c5 fc ff ff       	call   800bbd <sys_page_map>
  800ef8:	83 c4 20             	add    $0x20,%esp
  800efb:	85 c0                	test   %eax,%eax
  800efd:	79 12                	jns    800f11 <pgfault+0xc7>
        	panic("pgfault: page map failed %e\n", r);
  800eff:	50                   	push   %eax
  800f00:	68 94 25 80 00       	push   $0x802594
  800f05:	6a 2f                	push   $0x2f
  800f07:	68 62 25 80 00       	push   $0x802562
  800f0c:	e8 54 0e 00 00       	call   801d65 <_panic>
    
    	if ((r = sys_page_unmap(envid, (void *) PFTEMP)) < 0)
  800f11:	83 ec 08             	sub    $0x8,%esp
  800f14:	68 00 f0 7f 00       	push   $0x7ff000
  800f19:	56                   	push   %esi
  800f1a:	e8 e0 fc ff ff       	call   800bff <sys_page_unmap>
  800f1f:	83 c4 10             	add    $0x10,%esp
  800f22:	85 c0                	test   %eax,%eax
  800f24:	79 12                	jns    800f38 <pgfault+0xee>
        	panic("pgfault: page unmap failed %e\n", r);
  800f26:	50                   	push   %eax
  800f27:	68 54 26 80 00       	push   $0x802654
  800f2c:	6a 32                	push   $0x32
  800f2e:	68 62 25 80 00       	push   $0x802562
  800f33:	e8 2d 0e 00 00       	call   801d65 <_panic>
	//panic("pgfault not implemented");
}
  800f38:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f3b:	5b                   	pop    %ebx
  800f3c:	5e                   	pop    %esi
  800f3d:	5d                   	pop    %ebp
  800f3e:	c3                   	ret    

00800f3f <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f3f:	55                   	push   %ebp
  800f40:	89 e5                	mov    %esp,%ebp
  800f42:	56                   	push   %esi
  800f43:	53                   	push   %ebx
  800f44:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	set_pgfault_handler(pgfault);
  800f47:	68 4a 0e 80 00       	push   $0x800e4a
  800f4c:	e8 5a 0e 00 00       	call   801dab <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f51:	b8 07 00 00 00       	mov    $0x7,%eax
  800f56:	cd 30                	int    $0x30
  800f58:	89 c3                	mov    %eax,%ebx

	envid_t envid = sys_exofork();
	uint8_t *addr;
	if (envid < 0)
  800f5a:	83 c4 10             	add    $0x10,%esp
  800f5d:	85 c0                	test   %eax,%eax
  800f5f:	79 12                	jns    800f73 <fork+0x34>
		panic("sys_exofork:%e", envid);
  800f61:	50                   	push   %eax
  800f62:	68 b1 25 80 00       	push   $0x8025b1
  800f67:	6a 75                	push   $0x75
  800f69:	68 62 25 80 00       	push   $0x802562
  800f6e:	e8 f2 0d 00 00       	call   801d65 <_panic>
  800f73:	89 c6                	mov    %eax,%esi
	if (envid == 0) {
  800f75:	85 c0                	test   %eax,%eax
  800f77:	75 21                	jne    800f9a <fork+0x5b>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f79:	e8 be fb ff ff       	call   800b3c <sys_getenvid>
  800f7e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f83:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f86:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f8b:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800f90:	b8 00 00 00 00       	mov    $0x0,%eax
  800f95:	e9 c0 00 00 00       	jmp    80105a <fork+0x11b>
	}

	for (addr = (uint8_t *)UTEXT; addr < (uint8_t *)USTACKTOP-PGSIZE; addr += PGSIZE) {
  800f9a:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  800fa1:	ba 00 00 80 00       	mov    $0x800000,%edx
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
  800fa6:	89 d0                	mov    %edx,%eax
  800fa8:	c1 e8 16             	shr    $0x16,%eax
  800fab:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fb2:	a8 01                	test   $0x1,%al
  800fb4:	74 20                	je     800fd6 <fork+0x97>
  800fb6:	c1 ea 0c             	shr    $0xc,%edx
  800fb9:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800fc0:	a8 01                	test   $0x1,%al
  800fc2:	74 12                	je     800fd6 <fork+0x97>
				&& (uvpt[PGNUM(addr)] & PTE_U)) {
  800fc4:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800fcb:	a8 04                	test   $0x4,%al
  800fcd:	74 07                	je     800fd6 <fork+0x97>
			duppage(envid, PGNUM(addr));
  800fcf:	89 f0                	mov    %esi,%eax
  800fd1:	e8 95 fd ff ff       	call   800d6b <duppage>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}

	for (addr = (uint8_t *)UTEXT; addr < (uint8_t *)USTACKTOP-PGSIZE; addr += PGSIZE) {
  800fd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fd9:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
  800fdf:	89 55 f4             	mov    %edx,-0xc(%ebp)
  800fe2:	81 fa ff cf bf ee    	cmp    $0xeebfcfff,%edx
  800fe8:	76 bc                	jbe    800fa6 <fork+0x67>
				&& (uvpt[PGNUM(addr)] & PTE_U)) {
			duppage(envid, PGNUM(addr));
		}
	}

	duppage(envid, PGNUM(ROUNDDOWN(&addr, PGSIZE)));
  800fea:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800fed:	c1 ea 0c             	shr    $0xc,%edx
  800ff0:	89 d8                	mov    %ebx,%eax
  800ff2:	e8 74 fd ff ff       	call   800d6b <duppage>

	int r;
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)))
  800ff7:	83 ec 04             	sub    $0x4,%esp
  800ffa:	6a 07                	push   $0x7
  800ffc:	68 00 f0 bf ee       	push   $0xeebff000
  801001:	53                   	push   %ebx
  801002:	e8 73 fb ff ff       	call   800b7a <sys_page_alloc>
  801007:	83 c4 10             	add    $0x10,%esp
  80100a:	85 c0                	test   %eax,%eax
  80100c:	74 15                	je     801023 <fork+0xe4>
		panic("sys_page_alloc:%e", r);
  80100e:	50                   	push   %eax
  80100f:	68 c0 25 80 00       	push   $0x8025c0
  801014:	68 86 00 00 00       	push   $0x86
  801019:	68 62 25 80 00       	push   $0x802562
  80101e:	e8 42 0d 00 00       	call   801d65 <_panic>

	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801023:	83 ec 08             	sub    $0x8,%esp
  801026:	68 13 1e 80 00       	push   $0x801e13
  80102b:	53                   	push   %ebx
  80102c:	e8 94 fc ff ff       	call   800cc5 <sys_env_set_pgfault_upcall>

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)))
  801031:	83 c4 08             	add    $0x8,%esp
  801034:	6a 02                	push   $0x2
  801036:	53                   	push   %ebx
  801037:	e8 05 fc ff ff       	call   800c41 <sys_env_set_status>
  80103c:	83 c4 10             	add    $0x10,%esp
  80103f:	85 c0                	test   %eax,%eax
  801041:	74 15                	je     801058 <fork+0x119>
		panic("sys_env_set_status:%e", r);
  801043:	50                   	push   %eax
  801044:	68 d2 25 80 00       	push   $0x8025d2
  801049:	68 8c 00 00 00       	push   $0x8c
  80104e:	68 62 25 80 00       	push   $0x802562
  801053:	e8 0d 0d 00 00       	call   801d65 <_panic>

	return envid;
  801058:	89 d8                	mov    %ebx,%eax
	    
}
  80105a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80105d:	5b                   	pop    %ebx
  80105e:	5e                   	pop    %esi
  80105f:	5d                   	pop    %ebp
  801060:	c3                   	ret    

00801061 <sfork>:

// Challenge!
int
sfork(void)
{
  801061:	55                   	push   %ebp
  801062:	89 e5                	mov    %esp,%ebp
  801064:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801067:	68 e8 25 80 00       	push   $0x8025e8
  80106c:	68 96 00 00 00       	push   $0x96
  801071:	68 62 25 80 00       	push   $0x802562
  801076:	e8 ea 0c 00 00       	call   801d65 <_panic>

0080107b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80107b:	55                   	push   %ebp
  80107c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80107e:	8b 45 08             	mov    0x8(%ebp),%eax
  801081:	05 00 00 00 30       	add    $0x30000000,%eax
  801086:	c1 e8 0c             	shr    $0xc,%eax
}
  801089:	5d                   	pop    %ebp
  80108a:	c3                   	ret    

0080108b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80108b:	55                   	push   %ebp
  80108c:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80108e:	8b 45 08             	mov    0x8(%ebp),%eax
  801091:	05 00 00 00 30       	add    $0x30000000,%eax
  801096:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80109b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010a0:	5d                   	pop    %ebp
  8010a1:	c3                   	ret    

008010a2 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010a2:	55                   	push   %ebp
  8010a3:	89 e5                	mov    %esp,%ebp
  8010a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010a8:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010ad:	89 c2                	mov    %eax,%edx
  8010af:	c1 ea 16             	shr    $0x16,%edx
  8010b2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010b9:	f6 c2 01             	test   $0x1,%dl
  8010bc:	74 11                	je     8010cf <fd_alloc+0x2d>
  8010be:	89 c2                	mov    %eax,%edx
  8010c0:	c1 ea 0c             	shr    $0xc,%edx
  8010c3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010ca:	f6 c2 01             	test   $0x1,%dl
  8010cd:	75 09                	jne    8010d8 <fd_alloc+0x36>
			*fd_store = fd;
  8010cf:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8010d6:	eb 17                	jmp    8010ef <fd_alloc+0x4d>
  8010d8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010dd:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010e2:	75 c9                	jne    8010ad <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010e4:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8010ea:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010ef:	5d                   	pop    %ebp
  8010f0:	c3                   	ret    

008010f1 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010f1:	55                   	push   %ebp
  8010f2:	89 e5                	mov    %esp,%ebp
  8010f4:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010f7:	83 f8 1f             	cmp    $0x1f,%eax
  8010fa:	77 36                	ja     801132 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010fc:	c1 e0 0c             	shl    $0xc,%eax
  8010ff:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801104:	89 c2                	mov    %eax,%edx
  801106:	c1 ea 16             	shr    $0x16,%edx
  801109:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801110:	f6 c2 01             	test   $0x1,%dl
  801113:	74 24                	je     801139 <fd_lookup+0x48>
  801115:	89 c2                	mov    %eax,%edx
  801117:	c1 ea 0c             	shr    $0xc,%edx
  80111a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801121:	f6 c2 01             	test   $0x1,%dl
  801124:	74 1a                	je     801140 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801126:	8b 55 0c             	mov    0xc(%ebp),%edx
  801129:	89 02                	mov    %eax,(%edx)
	return 0;
  80112b:	b8 00 00 00 00       	mov    $0x0,%eax
  801130:	eb 13                	jmp    801145 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801132:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801137:	eb 0c                	jmp    801145 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801139:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80113e:	eb 05                	jmp    801145 <fd_lookup+0x54>
  801140:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801145:	5d                   	pop    %ebp
  801146:	c3                   	ret    

00801147 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801147:	55                   	push   %ebp
  801148:	89 e5                	mov    %esp,%ebp
  80114a:	83 ec 08             	sub    $0x8,%esp
  80114d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801150:	ba f0 26 80 00       	mov    $0x8026f0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801155:	eb 13                	jmp    80116a <dev_lookup+0x23>
  801157:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80115a:	39 08                	cmp    %ecx,(%eax)
  80115c:	75 0c                	jne    80116a <dev_lookup+0x23>
			*dev = devtab[i];
  80115e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801161:	89 01                	mov    %eax,(%ecx)
			return 0;
  801163:	b8 00 00 00 00       	mov    $0x0,%eax
  801168:	eb 2e                	jmp    801198 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80116a:	8b 02                	mov    (%edx),%eax
  80116c:	85 c0                	test   %eax,%eax
  80116e:	75 e7                	jne    801157 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801170:	a1 04 40 80 00       	mov    0x804004,%eax
  801175:	8b 40 48             	mov    0x48(%eax),%eax
  801178:	83 ec 04             	sub    $0x4,%esp
  80117b:	51                   	push   %ecx
  80117c:	50                   	push   %eax
  80117d:	68 74 26 80 00       	push   $0x802674
  801182:	e8 4d f0 ff ff       	call   8001d4 <cprintf>
	*dev = 0;
  801187:	8b 45 0c             	mov    0xc(%ebp),%eax
  80118a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801190:	83 c4 10             	add    $0x10,%esp
  801193:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801198:	c9                   	leave  
  801199:	c3                   	ret    

0080119a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80119a:	55                   	push   %ebp
  80119b:	89 e5                	mov    %esp,%ebp
  80119d:	56                   	push   %esi
  80119e:	53                   	push   %ebx
  80119f:	83 ec 10             	sub    $0x10,%esp
  8011a2:	8b 75 08             	mov    0x8(%ebp),%esi
  8011a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011ab:	50                   	push   %eax
  8011ac:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011b2:	c1 e8 0c             	shr    $0xc,%eax
  8011b5:	50                   	push   %eax
  8011b6:	e8 36 ff ff ff       	call   8010f1 <fd_lookup>
  8011bb:	83 c4 08             	add    $0x8,%esp
  8011be:	85 c0                	test   %eax,%eax
  8011c0:	78 05                	js     8011c7 <fd_close+0x2d>
	    || fd != fd2)
  8011c2:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011c5:	74 0c                	je     8011d3 <fd_close+0x39>
		return (must_exist ? r : 0);
  8011c7:	84 db                	test   %bl,%bl
  8011c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8011ce:	0f 44 c2             	cmove  %edx,%eax
  8011d1:	eb 41                	jmp    801214 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011d3:	83 ec 08             	sub    $0x8,%esp
  8011d6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011d9:	50                   	push   %eax
  8011da:	ff 36                	pushl  (%esi)
  8011dc:	e8 66 ff ff ff       	call   801147 <dev_lookup>
  8011e1:	89 c3                	mov    %eax,%ebx
  8011e3:	83 c4 10             	add    $0x10,%esp
  8011e6:	85 c0                	test   %eax,%eax
  8011e8:	78 1a                	js     801204 <fd_close+0x6a>
		if (dev->dev_close)
  8011ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ed:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8011f0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8011f5:	85 c0                	test   %eax,%eax
  8011f7:	74 0b                	je     801204 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8011f9:	83 ec 0c             	sub    $0xc,%esp
  8011fc:	56                   	push   %esi
  8011fd:	ff d0                	call   *%eax
  8011ff:	89 c3                	mov    %eax,%ebx
  801201:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801204:	83 ec 08             	sub    $0x8,%esp
  801207:	56                   	push   %esi
  801208:	6a 00                	push   $0x0
  80120a:	e8 f0 f9 ff ff       	call   800bff <sys_page_unmap>
	return r;
  80120f:	83 c4 10             	add    $0x10,%esp
  801212:	89 d8                	mov    %ebx,%eax
}
  801214:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801217:	5b                   	pop    %ebx
  801218:	5e                   	pop    %esi
  801219:	5d                   	pop    %ebp
  80121a:	c3                   	ret    

0080121b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80121b:	55                   	push   %ebp
  80121c:	89 e5                	mov    %esp,%ebp
  80121e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801221:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801224:	50                   	push   %eax
  801225:	ff 75 08             	pushl  0x8(%ebp)
  801228:	e8 c4 fe ff ff       	call   8010f1 <fd_lookup>
  80122d:	83 c4 08             	add    $0x8,%esp
  801230:	85 c0                	test   %eax,%eax
  801232:	78 10                	js     801244 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801234:	83 ec 08             	sub    $0x8,%esp
  801237:	6a 01                	push   $0x1
  801239:	ff 75 f4             	pushl  -0xc(%ebp)
  80123c:	e8 59 ff ff ff       	call   80119a <fd_close>
  801241:	83 c4 10             	add    $0x10,%esp
}
  801244:	c9                   	leave  
  801245:	c3                   	ret    

00801246 <close_all>:

void
close_all(void)
{
  801246:	55                   	push   %ebp
  801247:	89 e5                	mov    %esp,%ebp
  801249:	53                   	push   %ebx
  80124a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80124d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801252:	83 ec 0c             	sub    $0xc,%esp
  801255:	53                   	push   %ebx
  801256:	e8 c0 ff ff ff       	call   80121b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80125b:	83 c3 01             	add    $0x1,%ebx
  80125e:	83 c4 10             	add    $0x10,%esp
  801261:	83 fb 20             	cmp    $0x20,%ebx
  801264:	75 ec                	jne    801252 <close_all+0xc>
		close(i);
}
  801266:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801269:	c9                   	leave  
  80126a:	c3                   	ret    

0080126b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80126b:	55                   	push   %ebp
  80126c:	89 e5                	mov    %esp,%ebp
  80126e:	57                   	push   %edi
  80126f:	56                   	push   %esi
  801270:	53                   	push   %ebx
  801271:	83 ec 2c             	sub    $0x2c,%esp
  801274:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801277:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80127a:	50                   	push   %eax
  80127b:	ff 75 08             	pushl  0x8(%ebp)
  80127e:	e8 6e fe ff ff       	call   8010f1 <fd_lookup>
  801283:	83 c4 08             	add    $0x8,%esp
  801286:	85 c0                	test   %eax,%eax
  801288:	0f 88 c1 00 00 00    	js     80134f <dup+0xe4>
		return r;
	close(newfdnum);
  80128e:	83 ec 0c             	sub    $0xc,%esp
  801291:	56                   	push   %esi
  801292:	e8 84 ff ff ff       	call   80121b <close>

	newfd = INDEX2FD(newfdnum);
  801297:	89 f3                	mov    %esi,%ebx
  801299:	c1 e3 0c             	shl    $0xc,%ebx
  80129c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8012a2:	83 c4 04             	add    $0x4,%esp
  8012a5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012a8:	e8 de fd ff ff       	call   80108b <fd2data>
  8012ad:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8012af:	89 1c 24             	mov    %ebx,(%esp)
  8012b2:	e8 d4 fd ff ff       	call   80108b <fd2data>
  8012b7:	83 c4 10             	add    $0x10,%esp
  8012ba:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012bd:	89 f8                	mov    %edi,%eax
  8012bf:	c1 e8 16             	shr    $0x16,%eax
  8012c2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012c9:	a8 01                	test   $0x1,%al
  8012cb:	74 37                	je     801304 <dup+0x99>
  8012cd:	89 f8                	mov    %edi,%eax
  8012cf:	c1 e8 0c             	shr    $0xc,%eax
  8012d2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012d9:	f6 c2 01             	test   $0x1,%dl
  8012dc:	74 26                	je     801304 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012de:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012e5:	83 ec 0c             	sub    $0xc,%esp
  8012e8:	25 07 0e 00 00       	and    $0xe07,%eax
  8012ed:	50                   	push   %eax
  8012ee:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012f1:	6a 00                	push   $0x0
  8012f3:	57                   	push   %edi
  8012f4:	6a 00                	push   $0x0
  8012f6:	e8 c2 f8 ff ff       	call   800bbd <sys_page_map>
  8012fb:	89 c7                	mov    %eax,%edi
  8012fd:	83 c4 20             	add    $0x20,%esp
  801300:	85 c0                	test   %eax,%eax
  801302:	78 2e                	js     801332 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801304:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801307:	89 d0                	mov    %edx,%eax
  801309:	c1 e8 0c             	shr    $0xc,%eax
  80130c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801313:	83 ec 0c             	sub    $0xc,%esp
  801316:	25 07 0e 00 00       	and    $0xe07,%eax
  80131b:	50                   	push   %eax
  80131c:	53                   	push   %ebx
  80131d:	6a 00                	push   $0x0
  80131f:	52                   	push   %edx
  801320:	6a 00                	push   $0x0
  801322:	e8 96 f8 ff ff       	call   800bbd <sys_page_map>
  801327:	89 c7                	mov    %eax,%edi
  801329:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80132c:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80132e:	85 ff                	test   %edi,%edi
  801330:	79 1d                	jns    80134f <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801332:	83 ec 08             	sub    $0x8,%esp
  801335:	53                   	push   %ebx
  801336:	6a 00                	push   $0x0
  801338:	e8 c2 f8 ff ff       	call   800bff <sys_page_unmap>
	sys_page_unmap(0, nva);
  80133d:	83 c4 08             	add    $0x8,%esp
  801340:	ff 75 d4             	pushl  -0x2c(%ebp)
  801343:	6a 00                	push   $0x0
  801345:	e8 b5 f8 ff ff       	call   800bff <sys_page_unmap>
	return r;
  80134a:	83 c4 10             	add    $0x10,%esp
  80134d:	89 f8                	mov    %edi,%eax
}
  80134f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801352:	5b                   	pop    %ebx
  801353:	5e                   	pop    %esi
  801354:	5f                   	pop    %edi
  801355:	5d                   	pop    %ebp
  801356:	c3                   	ret    

00801357 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801357:	55                   	push   %ebp
  801358:	89 e5                	mov    %esp,%ebp
  80135a:	53                   	push   %ebx
  80135b:	83 ec 14             	sub    $0x14,%esp
  80135e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801361:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801364:	50                   	push   %eax
  801365:	53                   	push   %ebx
  801366:	e8 86 fd ff ff       	call   8010f1 <fd_lookup>
  80136b:	83 c4 08             	add    $0x8,%esp
  80136e:	89 c2                	mov    %eax,%edx
  801370:	85 c0                	test   %eax,%eax
  801372:	78 6d                	js     8013e1 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801374:	83 ec 08             	sub    $0x8,%esp
  801377:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80137a:	50                   	push   %eax
  80137b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80137e:	ff 30                	pushl  (%eax)
  801380:	e8 c2 fd ff ff       	call   801147 <dev_lookup>
  801385:	83 c4 10             	add    $0x10,%esp
  801388:	85 c0                	test   %eax,%eax
  80138a:	78 4c                	js     8013d8 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80138c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80138f:	8b 42 08             	mov    0x8(%edx),%eax
  801392:	83 e0 03             	and    $0x3,%eax
  801395:	83 f8 01             	cmp    $0x1,%eax
  801398:	75 21                	jne    8013bb <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80139a:	a1 04 40 80 00       	mov    0x804004,%eax
  80139f:	8b 40 48             	mov    0x48(%eax),%eax
  8013a2:	83 ec 04             	sub    $0x4,%esp
  8013a5:	53                   	push   %ebx
  8013a6:	50                   	push   %eax
  8013a7:	68 b5 26 80 00       	push   $0x8026b5
  8013ac:	e8 23 ee ff ff       	call   8001d4 <cprintf>
		return -E_INVAL;
  8013b1:	83 c4 10             	add    $0x10,%esp
  8013b4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013b9:	eb 26                	jmp    8013e1 <read+0x8a>
	}
	if (!dev->dev_read)
  8013bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013be:	8b 40 08             	mov    0x8(%eax),%eax
  8013c1:	85 c0                	test   %eax,%eax
  8013c3:	74 17                	je     8013dc <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013c5:	83 ec 04             	sub    $0x4,%esp
  8013c8:	ff 75 10             	pushl  0x10(%ebp)
  8013cb:	ff 75 0c             	pushl  0xc(%ebp)
  8013ce:	52                   	push   %edx
  8013cf:	ff d0                	call   *%eax
  8013d1:	89 c2                	mov    %eax,%edx
  8013d3:	83 c4 10             	add    $0x10,%esp
  8013d6:	eb 09                	jmp    8013e1 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013d8:	89 c2                	mov    %eax,%edx
  8013da:	eb 05                	jmp    8013e1 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8013dc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8013e1:	89 d0                	mov    %edx,%eax
  8013e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013e6:	c9                   	leave  
  8013e7:	c3                   	ret    

008013e8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013e8:	55                   	push   %ebp
  8013e9:	89 e5                	mov    %esp,%ebp
  8013eb:	57                   	push   %edi
  8013ec:	56                   	push   %esi
  8013ed:	53                   	push   %ebx
  8013ee:	83 ec 0c             	sub    $0xc,%esp
  8013f1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013f4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013f7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013fc:	eb 21                	jmp    80141f <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013fe:	83 ec 04             	sub    $0x4,%esp
  801401:	89 f0                	mov    %esi,%eax
  801403:	29 d8                	sub    %ebx,%eax
  801405:	50                   	push   %eax
  801406:	89 d8                	mov    %ebx,%eax
  801408:	03 45 0c             	add    0xc(%ebp),%eax
  80140b:	50                   	push   %eax
  80140c:	57                   	push   %edi
  80140d:	e8 45 ff ff ff       	call   801357 <read>
		if (m < 0)
  801412:	83 c4 10             	add    $0x10,%esp
  801415:	85 c0                	test   %eax,%eax
  801417:	78 10                	js     801429 <readn+0x41>
			return m;
		if (m == 0)
  801419:	85 c0                	test   %eax,%eax
  80141b:	74 0a                	je     801427 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80141d:	01 c3                	add    %eax,%ebx
  80141f:	39 f3                	cmp    %esi,%ebx
  801421:	72 db                	jb     8013fe <readn+0x16>
  801423:	89 d8                	mov    %ebx,%eax
  801425:	eb 02                	jmp    801429 <readn+0x41>
  801427:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801429:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80142c:	5b                   	pop    %ebx
  80142d:	5e                   	pop    %esi
  80142e:	5f                   	pop    %edi
  80142f:	5d                   	pop    %ebp
  801430:	c3                   	ret    

00801431 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801431:	55                   	push   %ebp
  801432:	89 e5                	mov    %esp,%ebp
  801434:	53                   	push   %ebx
  801435:	83 ec 14             	sub    $0x14,%esp
  801438:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80143b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80143e:	50                   	push   %eax
  80143f:	53                   	push   %ebx
  801440:	e8 ac fc ff ff       	call   8010f1 <fd_lookup>
  801445:	83 c4 08             	add    $0x8,%esp
  801448:	89 c2                	mov    %eax,%edx
  80144a:	85 c0                	test   %eax,%eax
  80144c:	78 68                	js     8014b6 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80144e:	83 ec 08             	sub    $0x8,%esp
  801451:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801454:	50                   	push   %eax
  801455:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801458:	ff 30                	pushl  (%eax)
  80145a:	e8 e8 fc ff ff       	call   801147 <dev_lookup>
  80145f:	83 c4 10             	add    $0x10,%esp
  801462:	85 c0                	test   %eax,%eax
  801464:	78 47                	js     8014ad <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801466:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801469:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80146d:	75 21                	jne    801490 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80146f:	a1 04 40 80 00       	mov    0x804004,%eax
  801474:	8b 40 48             	mov    0x48(%eax),%eax
  801477:	83 ec 04             	sub    $0x4,%esp
  80147a:	53                   	push   %ebx
  80147b:	50                   	push   %eax
  80147c:	68 d1 26 80 00       	push   $0x8026d1
  801481:	e8 4e ed ff ff       	call   8001d4 <cprintf>
		return -E_INVAL;
  801486:	83 c4 10             	add    $0x10,%esp
  801489:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80148e:	eb 26                	jmp    8014b6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801490:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801493:	8b 52 0c             	mov    0xc(%edx),%edx
  801496:	85 d2                	test   %edx,%edx
  801498:	74 17                	je     8014b1 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80149a:	83 ec 04             	sub    $0x4,%esp
  80149d:	ff 75 10             	pushl  0x10(%ebp)
  8014a0:	ff 75 0c             	pushl  0xc(%ebp)
  8014a3:	50                   	push   %eax
  8014a4:	ff d2                	call   *%edx
  8014a6:	89 c2                	mov    %eax,%edx
  8014a8:	83 c4 10             	add    $0x10,%esp
  8014ab:	eb 09                	jmp    8014b6 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ad:	89 c2                	mov    %eax,%edx
  8014af:	eb 05                	jmp    8014b6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014b1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8014b6:	89 d0                	mov    %edx,%eax
  8014b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014bb:	c9                   	leave  
  8014bc:	c3                   	ret    

008014bd <seek>:

int
seek(int fdnum, off_t offset)
{
  8014bd:	55                   	push   %ebp
  8014be:	89 e5                	mov    %esp,%ebp
  8014c0:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014c3:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014c6:	50                   	push   %eax
  8014c7:	ff 75 08             	pushl  0x8(%ebp)
  8014ca:	e8 22 fc ff ff       	call   8010f1 <fd_lookup>
  8014cf:	83 c4 08             	add    $0x8,%esp
  8014d2:	85 c0                	test   %eax,%eax
  8014d4:	78 0e                	js     8014e4 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014dc:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014df:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014e4:	c9                   	leave  
  8014e5:	c3                   	ret    

008014e6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014e6:	55                   	push   %ebp
  8014e7:	89 e5                	mov    %esp,%ebp
  8014e9:	53                   	push   %ebx
  8014ea:	83 ec 14             	sub    $0x14,%esp
  8014ed:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014f0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014f3:	50                   	push   %eax
  8014f4:	53                   	push   %ebx
  8014f5:	e8 f7 fb ff ff       	call   8010f1 <fd_lookup>
  8014fa:	83 c4 08             	add    $0x8,%esp
  8014fd:	89 c2                	mov    %eax,%edx
  8014ff:	85 c0                	test   %eax,%eax
  801501:	78 65                	js     801568 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801503:	83 ec 08             	sub    $0x8,%esp
  801506:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801509:	50                   	push   %eax
  80150a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80150d:	ff 30                	pushl  (%eax)
  80150f:	e8 33 fc ff ff       	call   801147 <dev_lookup>
  801514:	83 c4 10             	add    $0x10,%esp
  801517:	85 c0                	test   %eax,%eax
  801519:	78 44                	js     80155f <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80151b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80151e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801522:	75 21                	jne    801545 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801524:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801529:	8b 40 48             	mov    0x48(%eax),%eax
  80152c:	83 ec 04             	sub    $0x4,%esp
  80152f:	53                   	push   %ebx
  801530:	50                   	push   %eax
  801531:	68 94 26 80 00       	push   $0x802694
  801536:	e8 99 ec ff ff       	call   8001d4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80153b:	83 c4 10             	add    $0x10,%esp
  80153e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801543:	eb 23                	jmp    801568 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801545:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801548:	8b 52 18             	mov    0x18(%edx),%edx
  80154b:	85 d2                	test   %edx,%edx
  80154d:	74 14                	je     801563 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80154f:	83 ec 08             	sub    $0x8,%esp
  801552:	ff 75 0c             	pushl  0xc(%ebp)
  801555:	50                   	push   %eax
  801556:	ff d2                	call   *%edx
  801558:	89 c2                	mov    %eax,%edx
  80155a:	83 c4 10             	add    $0x10,%esp
  80155d:	eb 09                	jmp    801568 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80155f:	89 c2                	mov    %eax,%edx
  801561:	eb 05                	jmp    801568 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801563:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801568:	89 d0                	mov    %edx,%eax
  80156a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80156d:	c9                   	leave  
  80156e:	c3                   	ret    

0080156f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80156f:	55                   	push   %ebp
  801570:	89 e5                	mov    %esp,%ebp
  801572:	53                   	push   %ebx
  801573:	83 ec 14             	sub    $0x14,%esp
  801576:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801579:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80157c:	50                   	push   %eax
  80157d:	ff 75 08             	pushl  0x8(%ebp)
  801580:	e8 6c fb ff ff       	call   8010f1 <fd_lookup>
  801585:	83 c4 08             	add    $0x8,%esp
  801588:	89 c2                	mov    %eax,%edx
  80158a:	85 c0                	test   %eax,%eax
  80158c:	78 58                	js     8015e6 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80158e:	83 ec 08             	sub    $0x8,%esp
  801591:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801594:	50                   	push   %eax
  801595:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801598:	ff 30                	pushl  (%eax)
  80159a:	e8 a8 fb ff ff       	call   801147 <dev_lookup>
  80159f:	83 c4 10             	add    $0x10,%esp
  8015a2:	85 c0                	test   %eax,%eax
  8015a4:	78 37                	js     8015dd <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8015a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015a9:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015ad:	74 32                	je     8015e1 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015af:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015b2:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015b9:	00 00 00 
	stat->st_isdir = 0;
  8015bc:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015c3:	00 00 00 
	stat->st_dev = dev;
  8015c6:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015cc:	83 ec 08             	sub    $0x8,%esp
  8015cf:	53                   	push   %ebx
  8015d0:	ff 75 f0             	pushl  -0x10(%ebp)
  8015d3:	ff 50 14             	call   *0x14(%eax)
  8015d6:	89 c2                	mov    %eax,%edx
  8015d8:	83 c4 10             	add    $0x10,%esp
  8015db:	eb 09                	jmp    8015e6 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015dd:	89 c2                	mov    %eax,%edx
  8015df:	eb 05                	jmp    8015e6 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8015e1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8015e6:	89 d0                	mov    %edx,%eax
  8015e8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015eb:	c9                   	leave  
  8015ec:	c3                   	ret    

008015ed <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015ed:	55                   	push   %ebp
  8015ee:	89 e5                	mov    %esp,%ebp
  8015f0:	56                   	push   %esi
  8015f1:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015f2:	83 ec 08             	sub    $0x8,%esp
  8015f5:	6a 00                	push   $0x0
  8015f7:	ff 75 08             	pushl  0x8(%ebp)
  8015fa:	e8 e3 01 00 00       	call   8017e2 <open>
  8015ff:	89 c3                	mov    %eax,%ebx
  801601:	83 c4 10             	add    $0x10,%esp
  801604:	85 c0                	test   %eax,%eax
  801606:	78 1b                	js     801623 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801608:	83 ec 08             	sub    $0x8,%esp
  80160b:	ff 75 0c             	pushl  0xc(%ebp)
  80160e:	50                   	push   %eax
  80160f:	e8 5b ff ff ff       	call   80156f <fstat>
  801614:	89 c6                	mov    %eax,%esi
	close(fd);
  801616:	89 1c 24             	mov    %ebx,(%esp)
  801619:	e8 fd fb ff ff       	call   80121b <close>
	return r;
  80161e:	83 c4 10             	add    $0x10,%esp
  801621:	89 f0                	mov    %esi,%eax
}
  801623:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801626:	5b                   	pop    %ebx
  801627:	5e                   	pop    %esi
  801628:	5d                   	pop    %ebp
  801629:	c3                   	ret    

0080162a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80162a:	55                   	push   %ebp
  80162b:	89 e5                	mov    %esp,%ebp
  80162d:	56                   	push   %esi
  80162e:	53                   	push   %ebx
  80162f:	89 c6                	mov    %eax,%esi
  801631:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801633:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80163a:	75 12                	jne    80164e <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80163c:	83 ec 0c             	sub    $0xc,%esp
  80163f:	6a 01                	push   $0x1
  801641:	e8 9a 08 00 00       	call   801ee0 <ipc_find_env>
  801646:	a3 00 40 80 00       	mov    %eax,0x804000
  80164b:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80164e:	6a 07                	push   $0x7
  801650:	68 00 50 80 00       	push   $0x805000
  801655:	56                   	push   %esi
  801656:	ff 35 00 40 80 00    	pushl  0x804000
  80165c:	e8 2b 08 00 00       	call   801e8c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801661:	83 c4 0c             	add    $0xc,%esp
  801664:	6a 00                	push   $0x0
  801666:	53                   	push   %ebx
  801667:	6a 00                	push   $0x0
  801669:	e8 c9 07 00 00       	call   801e37 <ipc_recv>
}
  80166e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801671:	5b                   	pop    %ebx
  801672:	5e                   	pop    %esi
  801673:	5d                   	pop    %ebp
  801674:	c3                   	ret    

00801675 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801675:	55                   	push   %ebp
  801676:	89 e5                	mov    %esp,%ebp
  801678:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80167b:	8b 45 08             	mov    0x8(%ebp),%eax
  80167e:	8b 40 0c             	mov    0xc(%eax),%eax
  801681:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801686:	8b 45 0c             	mov    0xc(%ebp),%eax
  801689:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80168e:	ba 00 00 00 00       	mov    $0x0,%edx
  801693:	b8 02 00 00 00       	mov    $0x2,%eax
  801698:	e8 8d ff ff ff       	call   80162a <fsipc>
}
  80169d:	c9                   	leave  
  80169e:	c3                   	ret    

0080169f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80169f:	55                   	push   %ebp
  8016a0:	89 e5                	mov    %esp,%ebp
  8016a2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a8:	8b 40 0c             	mov    0xc(%eax),%eax
  8016ab:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b5:	b8 06 00 00 00       	mov    $0x6,%eax
  8016ba:	e8 6b ff ff ff       	call   80162a <fsipc>
}
  8016bf:	c9                   	leave  
  8016c0:	c3                   	ret    

008016c1 <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016c1:	55                   	push   %ebp
  8016c2:	89 e5                	mov    %esp,%ebp
  8016c4:	53                   	push   %ebx
  8016c5:	83 ec 04             	sub    $0x4,%esp
  8016c8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ce:	8b 40 0c             	mov    0xc(%eax),%eax
  8016d1:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8016db:	b8 05 00 00 00       	mov    $0x5,%eax
  8016e0:	e8 45 ff ff ff       	call   80162a <fsipc>
  8016e5:	85 c0                	test   %eax,%eax
  8016e7:	78 2c                	js     801715 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016e9:	83 ec 08             	sub    $0x8,%esp
  8016ec:	68 00 50 80 00       	push   $0x805000
  8016f1:	53                   	push   %ebx
  8016f2:	e8 80 f0 ff ff       	call   800777 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016f7:	a1 80 50 80 00       	mov    0x805080,%eax
  8016fc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801702:	a1 84 50 80 00       	mov    0x805084,%eax
  801707:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80170d:	83 c4 10             	add    $0x10,%esp
  801710:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801715:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801718:	c9                   	leave  
  801719:	c3                   	ret    

0080171a <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80171a:	55                   	push   %ebp
  80171b:	89 e5                	mov    %esp,%ebp
  80171d:	83 ec 0c             	sub    $0xc,%esp
  801720:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
    
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  801723:	8b 55 08             	mov    0x8(%ebp),%edx
  801726:	8b 52 0c             	mov    0xc(%edx),%edx
  801729:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = MIN(n, PGSIZE);
  80172f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801734:	ba 00 10 00 00       	mov    $0x1000,%edx
  801739:	0f 47 c2             	cmova  %edx,%eax
  80173c:	a3 04 50 80 00       	mov    %eax,0x805004
    memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801741:	50                   	push   %eax
  801742:	ff 75 0c             	pushl  0xc(%ebp)
  801745:	68 08 50 80 00       	push   $0x805008
  80174a:	e8 ba f1 ff ff       	call   800909 <memmove>
    int r = fsipc(FSREQ_WRITE, NULL);
  80174f:	ba 00 00 00 00       	mov    $0x0,%edx
  801754:	b8 04 00 00 00       	mov    $0x4,%eax
  801759:	e8 cc fe ff ff       	call   80162a <fsipc>
    return r;
}
  80175e:	c9                   	leave  
  80175f:	c3                   	ret    

00801760 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801760:	55                   	push   %ebp
  801761:	89 e5                	mov    %esp,%ebp
  801763:	56                   	push   %esi
  801764:	53                   	push   %ebx
  801765:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801768:	8b 45 08             	mov    0x8(%ebp),%eax
  80176b:	8b 40 0c             	mov    0xc(%eax),%eax
  80176e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801773:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801779:	ba 00 00 00 00       	mov    $0x0,%edx
  80177e:	b8 03 00 00 00       	mov    $0x3,%eax
  801783:	e8 a2 fe ff ff       	call   80162a <fsipc>
  801788:	89 c3                	mov    %eax,%ebx
  80178a:	85 c0                	test   %eax,%eax
  80178c:	78 4b                	js     8017d9 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80178e:	39 c6                	cmp    %eax,%esi
  801790:	73 16                	jae    8017a8 <devfile_read+0x48>
  801792:	68 00 27 80 00       	push   $0x802700
  801797:	68 07 27 80 00       	push   $0x802707
  80179c:	6a 7c                	push   $0x7c
  80179e:	68 1c 27 80 00       	push   $0x80271c
  8017a3:	e8 bd 05 00 00       	call   801d65 <_panic>
	assert(r <= PGSIZE);
  8017a8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017ad:	7e 16                	jle    8017c5 <devfile_read+0x65>
  8017af:	68 27 27 80 00       	push   $0x802727
  8017b4:	68 07 27 80 00       	push   $0x802707
  8017b9:	6a 7d                	push   $0x7d
  8017bb:	68 1c 27 80 00       	push   $0x80271c
  8017c0:	e8 a0 05 00 00       	call   801d65 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017c5:	83 ec 04             	sub    $0x4,%esp
  8017c8:	50                   	push   %eax
  8017c9:	68 00 50 80 00       	push   $0x805000
  8017ce:	ff 75 0c             	pushl  0xc(%ebp)
  8017d1:	e8 33 f1 ff ff       	call   800909 <memmove>
	return r;
  8017d6:	83 c4 10             	add    $0x10,%esp
}
  8017d9:	89 d8                	mov    %ebx,%eax
  8017db:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017de:	5b                   	pop    %ebx
  8017df:	5e                   	pop    %esi
  8017e0:	5d                   	pop    %ebp
  8017e1:	c3                   	ret    

008017e2 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017e2:	55                   	push   %ebp
  8017e3:	89 e5                	mov    %esp,%ebp
  8017e5:	53                   	push   %ebx
  8017e6:	83 ec 20             	sub    $0x20,%esp
  8017e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8017ec:	53                   	push   %ebx
  8017ed:	e8 4c ef ff ff       	call   80073e <strlen>
  8017f2:	83 c4 10             	add    $0x10,%esp
  8017f5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017fa:	7f 67                	jg     801863 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017fc:	83 ec 0c             	sub    $0xc,%esp
  8017ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801802:	50                   	push   %eax
  801803:	e8 9a f8 ff ff       	call   8010a2 <fd_alloc>
  801808:	83 c4 10             	add    $0x10,%esp
		return r;
  80180b:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80180d:	85 c0                	test   %eax,%eax
  80180f:	78 57                	js     801868 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801811:	83 ec 08             	sub    $0x8,%esp
  801814:	53                   	push   %ebx
  801815:	68 00 50 80 00       	push   $0x805000
  80181a:	e8 58 ef ff ff       	call   800777 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80181f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801822:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801827:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80182a:	b8 01 00 00 00       	mov    $0x1,%eax
  80182f:	e8 f6 fd ff ff       	call   80162a <fsipc>
  801834:	89 c3                	mov    %eax,%ebx
  801836:	83 c4 10             	add    $0x10,%esp
  801839:	85 c0                	test   %eax,%eax
  80183b:	79 14                	jns    801851 <open+0x6f>
		fd_close(fd, 0);
  80183d:	83 ec 08             	sub    $0x8,%esp
  801840:	6a 00                	push   $0x0
  801842:	ff 75 f4             	pushl  -0xc(%ebp)
  801845:	e8 50 f9 ff ff       	call   80119a <fd_close>
		return r;
  80184a:	83 c4 10             	add    $0x10,%esp
  80184d:	89 da                	mov    %ebx,%edx
  80184f:	eb 17                	jmp    801868 <open+0x86>
	}

	return fd2num(fd);
  801851:	83 ec 0c             	sub    $0xc,%esp
  801854:	ff 75 f4             	pushl  -0xc(%ebp)
  801857:	e8 1f f8 ff ff       	call   80107b <fd2num>
  80185c:	89 c2                	mov    %eax,%edx
  80185e:	83 c4 10             	add    $0x10,%esp
  801861:	eb 05                	jmp    801868 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801863:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801868:	89 d0                	mov    %edx,%eax
  80186a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80186d:	c9                   	leave  
  80186e:	c3                   	ret    

0080186f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80186f:	55                   	push   %ebp
  801870:	89 e5                	mov    %esp,%ebp
  801872:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801875:	ba 00 00 00 00       	mov    $0x0,%edx
  80187a:	b8 08 00 00 00       	mov    $0x8,%eax
  80187f:	e8 a6 fd ff ff       	call   80162a <fsipc>
}
  801884:	c9                   	leave  
  801885:	c3                   	ret    

00801886 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801886:	55                   	push   %ebp
  801887:	89 e5                	mov    %esp,%ebp
  801889:	56                   	push   %esi
  80188a:	53                   	push   %ebx
  80188b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80188e:	83 ec 0c             	sub    $0xc,%esp
  801891:	ff 75 08             	pushl  0x8(%ebp)
  801894:	e8 f2 f7 ff ff       	call   80108b <fd2data>
  801899:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80189b:	83 c4 08             	add    $0x8,%esp
  80189e:	68 33 27 80 00       	push   $0x802733
  8018a3:	53                   	push   %ebx
  8018a4:	e8 ce ee ff ff       	call   800777 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8018a9:	8b 46 04             	mov    0x4(%esi),%eax
  8018ac:	2b 06                	sub    (%esi),%eax
  8018ae:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8018b4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018bb:	00 00 00 
	stat->st_dev = &devpipe;
  8018be:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8018c5:	30 80 00 
	return 0;
}
  8018c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8018cd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018d0:	5b                   	pop    %ebx
  8018d1:	5e                   	pop    %esi
  8018d2:	5d                   	pop    %ebp
  8018d3:	c3                   	ret    

008018d4 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8018d4:	55                   	push   %ebp
  8018d5:	89 e5                	mov    %esp,%ebp
  8018d7:	53                   	push   %ebx
  8018d8:	83 ec 0c             	sub    $0xc,%esp
  8018db:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8018de:	53                   	push   %ebx
  8018df:	6a 00                	push   $0x0
  8018e1:	e8 19 f3 ff ff       	call   800bff <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8018e6:	89 1c 24             	mov    %ebx,(%esp)
  8018e9:	e8 9d f7 ff ff       	call   80108b <fd2data>
  8018ee:	83 c4 08             	add    $0x8,%esp
  8018f1:	50                   	push   %eax
  8018f2:	6a 00                	push   $0x0
  8018f4:	e8 06 f3 ff ff       	call   800bff <sys_page_unmap>
}
  8018f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018fc:	c9                   	leave  
  8018fd:	c3                   	ret    

008018fe <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8018fe:	55                   	push   %ebp
  8018ff:	89 e5                	mov    %esp,%ebp
  801901:	57                   	push   %edi
  801902:	56                   	push   %esi
  801903:	53                   	push   %ebx
  801904:	83 ec 1c             	sub    $0x1c,%esp
  801907:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80190a:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80190c:	a1 04 40 80 00       	mov    0x804004,%eax
  801911:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801914:	83 ec 0c             	sub    $0xc,%esp
  801917:	ff 75 e0             	pushl  -0x20(%ebp)
  80191a:	e8 fa 05 00 00       	call   801f19 <pageref>
  80191f:	89 c3                	mov    %eax,%ebx
  801921:	89 3c 24             	mov    %edi,(%esp)
  801924:	e8 f0 05 00 00       	call   801f19 <pageref>
  801929:	83 c4 10             	add    $0x10,%esp
  80192c:	39 c3                	cmp    %eax,%ebx
  80192e:	0f 94 c1             	sete   %cl
  801931:	0f b6 c9             	movzbl %cl,%ecx
  801934:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801937:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80193d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801940:	39 ce                	cmp    %ecx,%esi
  801942:	74 1b                	je     80195f <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801944:	39 c3                	cmp    %eax,%ebx
  801946:	75 c4                	jne    80190c <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801948:	8b 42 58             	mov    0x58(%edx),%eax
  80194b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80194e:	50                   	push   %eax
  80194f:	56                   	push   %esi
  801950:	68 3a 27 80 00       	push   $0x80273a
  801955:	e8 7a e8 ff ff       	call   8001d4 <cprintf>
  80195a:	83 c4 10             	add    $0x10,%esp
  80195d:	eb ad                	jmp    80190c <_pipeisclosed+0xe>
	}
}
  80195f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801962:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801965:	5b                   	pop    %ebx
  801966:	5e                   	pop    %esi
  801967:	5f                   	pop    %edi
  801968:	5d                   	pop    %ebp
  801969:	c3                   	ret    

0080196a <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80196a:	55                   	push   %ebp
  80196b:	89 e5                	mov    %esp,%ebp
  80196d:	57                   	push   %edi
  80196e:	56                   	push   %esi
  80196f:	53                   	push   %ebx
  801970:	83 ec 28             	sub    $0x28,%esp
  801973:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801976:	56                   	push   %esi
  801977:	e8 0f f7 ff ff       	call   80108b <fd2data>
  80197c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80197e:	83 c4 10             	add    $0x10,%esp
  801981:	bf 00 00 00 00       	mov    $0x0,%edi
  801986:	eb 4b                	jmp    8019d3 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801988:	89 da                	mov    %ebx,%edx
  80198a:	89 f0                	mov    %esi,%eax
  80198c:	e8 6d ff ff ff       	call   8018fe <_pipeisclosed>
  801991:	85 c0                	test   %eax,%eax
  801993:	75 48                	jne    8019dd <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801995:	e8 c1 f1 ff ff       	call   800b5b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80199a:	8b 43 04             	mov    0x4(%ebx),%eax
  80199d:	8b 0b                	mov    (%ebx),%ecx
  80199f:	8d 51 20             	lea    0x20(%ecx),%edx
  8019a2:	39 d0                	cmp    %edx,%eax
  8019a4:	73 e2                	jae    801988 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8019a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019a9:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8019ad:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8019b0:	89 c2                	mov    %eax,%edx
  8019b2:	c1 fa 1f             	sar    $0x1f,%edx
  8019b5:	89 d1                	mov    %edx,%ecx
  8019b7:	c1 e9 1b             	shr    $0x1b,%ecx
  8019ba:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8019bd:	83 e2 1f             	and    $0x1f,%edx
  8019c0:	29 ca                	sub    %ecx,%edx
  8019c2:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8019c6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8019ca:	83 c0 01             	add    $0x1,%eax
  8019cd:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019d0:	83 c7 01             	add    $0x1,%edi
  8019d3:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8019d6:	75 c2                	jne    80199a <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8019d8:	8b 45 10             	mov    0x10(%ebp),%eax
  8019db:	eb 05                	jmp    8019e2 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019dd:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8019e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019e5:	5b                   	pop    %ebx
  8019e6:	5e                   	pop    %esi
  8019e7:	5f                   	pop    %edi
  8019e8:	5d                   	pop    %ebp
  8019e9:	c3                   	ret    

008019ea <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019ea:	55                   	push   %ebp
  8019eb:	89 e5                	mov    %esp,%ebp
  8019ed:	57                   	push   %edi
  8019ee:	56                   	push   %esi
  8019ef:	53                   	push   %ebx
  8019f0:	83 ec 18             	sub    $0x18,%esp
  8019f3:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8019f6:	57                   	push   %edi
  8019f7:	e8 8f f6 ff ff       	call   80108b <fd2data>
  8019fc:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019fe:	83 c4 10             	add    $0x10,%esp
  801a01:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a06:	eb 3d                	jmp    801a45 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a08:	85 db                	test   %ebx,%ebx
  801a0a:	74 04                	je     801a10 <devpipe_read+0x26>
				return i;
  801a0c:	89 d8                	mov    %ebx,%eax
  801a0e:	eb 44                	jmp    801a54 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a10:	89 f2                	mov    %esi,%edx
  801a12:	89 f8                	mov    %edi,%eax
  801a14:	e8 e5 fe ff ff       	call   8018fe <_pipeisclosed>
  801a19:	85 c0                	test   %eax,%eax
  801a1b:	75 32                	jne    801a4f <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a1d:	e8 39 f1 ff ff       	call   800b5b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a22:	8b 06                	mov    (%esi),%eax
  801a24:	3b 46 04             	cmp    0x4(%esi),%eax
  801a27:	74 df                	je     801a08 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a29:	99                   	cltd   
  801a2a:	c1 ea 1b             	shr    $0x1b,%edx
  801a2d:	01 d0                	add    %edx,%eax
  801a2f:	83 e0 1f             	and    $0x1f,%eax
  801a32:	29 d0                	sub    %edx,%eax
  801a34:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801a39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a3c:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801a3f:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a42:	83 c3 01             	add    $0x1,%ebx
  801a45:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a48:	75 d8                	jne    801a22 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a4a:	8b 45 10             	mov    0x10(%ebp),%eax
  801a4d:	eb 05                	jmp    801a54 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a4f:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801a54:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a57:	5b                   	pop    %ebx
  801a58:	5e                   	pop    %esi
  801a59:	5f                   	pop    %edi
  801a5a:	5d                   	pop    %ebp
  801a5b:	c3                   	ret    

00801a5c <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a5c:	55                   	push   %ebp
  801a5d:	89 e5                	mov    %esp,%ebp
  801a5f:	56                   	push   %esi
  801a60:	53                   	push   %ebx
  801a61:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a64:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a67:	50                   	push   %eax
  801a68:	e8 35 f6 ff ff       	call   8010a2 <fd_alloc>
  801a6d:	83 c4 10             	add    $0x10,%esp
  801a70:	89 c2                	mov    %eax,%edx
  801a72:	85 c0                	test   %eax,%eax
  801a74:	0f 88 2c 01 00 00    	js     801ba6 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a7a:	83 ec 04             	sub    $0x4,%esp
  801a7d:	68 07 04 00 00       	push   $0x407
  801a82:	ff 75 f4             	pushl  -0xc(%ebp)
  801a85:	6a 00                	push   $0x0
  801a87:	e8 ee f0 ff ff       	call   800b7a <sys_page_alloc>
  801a8c:	83 c4 10             	add    $0x10,%esp
  801a8f:	89 c2                	mov    %eax,%edx
  801a91:	85 c0                	test   %eax,%eax
  801a93:	0f 88 0d 01 00 00    	js     801ba6 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a99:	83 ec 0c             	sub    $0xc,%esp
  801a9c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a9f:	50                   	push   %eax
  801aa0:	e8 fd f5 ff ff       	call   8010a2 <fd_alloc>
  801aa5:	89 c3                	mov    %eax,%ebx
  801aa7:	83 c4 10             	add    $0x10,%esp
  801aaa:	85 c0                	test   %eax,%eax
  801aac:	0f 88 e2 00 00 00    	js     801b94 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ab2:	83 ec 04             	sub    $0x4,%esp
  801ab5:	68 07 04 00 00       	push   $0x407
  801aba:	ff 75 f0             	pushl  -0x10(%ebp)
  801abd:	6a 00                	push   $0x0
  801abf:	e8 b6 f0 ff ff       	call   800b7a <sys_page_alloc>
  801ac4:	89 c3                	mov    %eax,%ebx
  801ac6:	83 c4 10             	add    $0x10,%esp
  801ac9:	85 c0                	test   %eax,%eax
  801acb:	0f 88 c3 00 00 00    	js     801b94 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ad1:	83 ec 0c             	sub    $0xc,%esp
  801ad4:	ff 75 f4             	pushl  -0xc(%ebp)
  801ad7:	e8 af f5 ff ff       	call   80108b <fd2data>
  801adc:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ade:	83 c4 0c             	add    $0xc,%esp
  801ae1:	68 07 04 00 00       	push   $0x407
  801ae6:	50                   	push   %eax
  801ae7:	6a 00                	push   $0x0
  801ae9:	e8 8c f0 ff ff       	call   800b7a <sys_page_alloc>
  801aee:	89 c3                	mov    %eax,%ebx
  801af0:	83 c4 10             	add    $0x10,%esp
  801af3:	85 c0                	test   %eax,%eax
  801af5:	0f 88 89 00 00 00    	js     801b84 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801afb:	83 ec 0c             	sub    $0xc,%esp
  801afe:	ff 75 f0             	pushl  -0x10(%ebp)
  801b01:	e8 85 f5 ff ff       	call   80108b <fd2data>
  801b06:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b0d:	50                   	push   %eax
  801b0e:	6a 00                	push   $0x0
  801b10:	56                   	push   %esi
  801b11:	6a 00                	push   $0x0
  801b13:	e8 a5 f0 ff ff       	call   800bbd <sys_page_map>
  801b18:	89 c3                	mov    %eax,%ebx
  801b1a:	83 c4 20             	add    $0x20,%esp
  801b1d:	85 c0                	test   %eax,%eax
  801b1f:	78 55                	js     801b76 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b21:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b27:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b2a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b2f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b36:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b3f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b41:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b44:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b4b:	83 ec 0c             	sub    $0xc,%esp
  801b4e:	ff 75 f4             	pushl  -0xc(%ebp)
  801b51:	e8 25 f5 ff ff       	call   80107b <fd2num>
  801b56:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b59:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b5b:	83 c4 04             	add    $0x4,%esp
  801b5e:	ff 75 f0             	pushl  -0x10(%ebp)
  801b61:	e8 15 f5 ff ff       	call   80107b <fd2num>
  801b66:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b69:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801b6c:	83 c4 10             	add    $0x10,%esp
  801b6f:	ba 00 00 00 00       	mov    $0x0,%edx
  801b74:	eb 30                	jmp    801ba6 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801b76:	83 ec 08             	sub    $0x8,%esp
  801b79:	56                   	push   %esi
  801b7a:	6a 00                	push   $0x0
  801b7c:	e8 7e f0 ff ff       	call   800bff <sys_page_unmap>
  801b81:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801b84:	83 ec 08             	sub    $0x8,%esp
  801b87:	ff 75 f0             	pushl  -0x10(%ebp)
  801b8a:	6a 00                	push   $0x0
  801b8c:	e8 6e f0 ff ff       	call   800bff <sys_page_unmap>
  801b91:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801b94:	83 ec 08             	sub    $0x8,%esp
  801b97:	ff 75 f4             	pushl  -0xc(%ebp)
  801b9a:	6a 00                	push   $0x0
  801b9c:	e8 5e f0 ff ff       	call   800bff <sys_page_unmap>
  801ba1:	83 c4 10             	add    $0x10,%esp
  801ba4:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801ba6:	89 d0                	mov    %edx,%eax
  801ba8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bab:	5b                   	pop    %ebx
  801bac:	5e                   	pop    %esi
  801bad:	5d                   	pop    %ebp
  801bae:	c3                   	ret    

00801baf <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801baf:	55                   	push   %ebp
  801bb0:	89 e5                	mov    %esp,%ebp
  801bb2:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bb5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bb8:	50                   	push   %eax
  801bb9:	ff 75 08             	pushl  0x8(%ebp)
  801bbc:	e8 30 f5 ff ff       	call   8010f1 <fd_lookup>
  801bc1:	83 c4 10             	add    $0x10,%esp
  801bc4:	85 c0                	test   %eax,%eax
  801bc6:	78 18                	js     801be0 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801bc8:	83 ec 0c             	sub    $0xc,%esp
  801bcb:	ff 75 f4             	pushl  -0xc(%ebp)
  801bce:	e8 b8 f4 ff ff       	call   80108b <fd2data>
	return _pipeisclosed(fd, p);
  801bd3:	89 c2                	mov    %eax,%edx
  801bd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bd8:	e8 21 fd ff ff       	call   8018fe <_pipeisclosed>
  801bdd:	83 c4 10             	add    $0x10,%esp
}
  801be0:	c9                   	leave  
  801be1:	c3                   	ret    

00801be2 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801be2:	55                   	push   %ebp
  801be3:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801be5:	b8 00 00 00 00       	mov    $0x0,%eax
  801bea:	5d                   	pop    %ebp
  801beb:	c3                   	ret    

00801bec <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801bec:	55                   	push   %ebp
  801bed:	89 e5                	mov    %esp,%ebp
  801bef:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801bf2:	68 52 27 80 00       	push   $0x802752
  801bf7:	ff 75 0c             	pushl  0xc(%ebp)
  801bfa:	e8 78 eb ff ff       	call   800777 <strcpy>
	return 0;
}
  801bff:	b8 00 00 00 00       	mov    $0x0,%eax
  801c04:	c9                   	leave  
  801c05:	c3                   	ret    

00801c06 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c06:	55                   	push   %ebp
  801c07:	89 e5                	mov    %esp,%ebp
  801c09:	57                   	push   %edi
  801c0a:	56                   	push   %esi
  801c0b:	53                   	push   %ebx
  801c0c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c12:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c17:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c1d:	eb 2d                	jmp    801c4c <devcons_write+0x46>
		m = n - tot;
  801c1f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c22:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801c24:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801c27:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801c2c:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c2f:	83 ec 04             	sub    $0x4,%esp
  801c32:	53                   	push   %ebx
  801c33:	03 45 0c             	add    0xc(%ebp),%eax
  801c36:	50                   	push   %eax
  801c37:	57                   	push   %edi
  801c38:	e8 cc ec ff ff       	call   800909 <memmove>
		sys_cputs(buf, m);
  801c3d:	83 c4 08             	add    $0x8,%esp
  801c40:	53                   	push   %ebx
  801c41:	57                   	push   %edi
  801c42:	e8 77 ee ff ff       	call   800abe <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c47:	01 de                	add    %ebx,%esi
  801c49:	83 c4 10             	add    $0x10,%esp
  801c4c:	89 f0                	mov    %esi,%eax
  801c4e:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c51:	72 cc                	jb     801c1f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801c53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c56:	5b                   	pop    %ebx
  801c57:	5e                   	pop    %esi
  801c58:	5f                   	pop    %edi
  801c59:	5d                   	pop    %ebp
  801c5a:	c3                   	ret    

00801c5b <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c5b:	55                   	push   %ebp
  801c5c:	89 e5                	mov    %esp,%ebp
  801c5e:	83 ec 08             	sub    $0x8,%esp
  801c61:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801c66:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c6a:	74 2a                	je     801c96 <devcons_read+0x3b>
  801c6c:	eb 05                	jmp    801c73 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c6e:	e8 e8 ee ff ff       	call   800b5b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c73:	e8 64 ee ff ff       	call   800adc <sys_cgetc>
  801c78:	85 c0                	test   %eax,%eax
  801c7a:	74 f2                	je     801c6e <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801c7c:	85 c0                	test   %eax,%eax
  801c7e:	78 16                	js     801c96 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801c80:	83 f8 04             	cmp    $0x4,%eax
  801c83:	74 0c                	je     801c91 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801c85:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c88:	88 02                	mov    %al,(%edx)
	return 1;
  801c8a:	b8 01 00 00 00       	mov    $0x1,%eax
  801c8f:	eb 05                	jmp    801c96 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801c91:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801c96:	c9                   	leave  
  801c97:	c3                   	ret    

00801c98 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801c98:	55                   	push   %ebp
  801c99:	89 e5                	mov    %esp,%ebp
  801c9b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801c9e:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca1:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801ca4:	6a 01                	push   $0x1
  801ca6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ca9:	50                   	push   %eax
  801caa:	e8 0f ee ff ff       	call   800abe <sys_cputs>
}
  801caf:	83 c4 10             	add    $0x10,%esp
  801cb2:	c9                   	leave  
  801cb3:	c3                   	ret    

00801cb4 <getchar>:

int
getchar(void)
{
  801cb4:	55                   	push   %ebp
  801cb5:	89 e5                	mov    %esp,%ebp
  801cb7:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801cba:	6a 01                	push   $0x1
  801cbc:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801cbf:	50                   	push   %eax
  801cc0:	6a 00                	push   $0x0
  801cc2:	e8 90 f6 ff ff       	call   801357 <read>
	if (r < 0)
  801cc7:	83 c4 10             	add    $0x10,%esp
  801cca:	85 c0                	test   %eax,%eax
  801ccc:	78 0f                	js     801cdd <getchar+0x29>
		return r;
	if (r < 1)
  801cce:	85 c0                	test   %eax,%eax
  801cd0:	7e 06                	jle    801cd8 <getchar+0x24>
		return -E_EOF;
	return c;
  801cd2:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801cd6:	eb 05                	jmp    801cdd <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801cd8:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801cdd:	c9                   	leave  
  801cde:	c3                   	ret    

00801cdf <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801cdf:	55                   	push   %ebp
  801ce0:	89 e5                	mov    %esp,%ebp
  801ce2:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ce5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ce8:	50                   	push   %eax
  801ce9:	ff 75 08             	pushl  0x8(%ebp)
  801cec:	e8 00 f4 ff ff       	call   8010f1 <fd_lookup>
  801cf1:	83 c4 10             	add    $0x10,%esp
  801cf4:	85 c0                	test   %eax,%eax
  801cf6:	78 11                	js     801d09 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801cf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cfb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d01:	39 10                	cmp    %edx,(%eax)
  801d03:	0f 94 c0             	sete   %al
  801d06:	0f b6 c0             	movzbl %al,%eax
}
  801d09:	c9                   	leave  
  801d0a:	c3                   	ret    

00801d0b <opencons>:

int
opencons(void)
{
  801d0b:	55                   	push   %ebp
  801d0c:	89 e5                	mov    %esp,%ebp
  801d0e:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d11:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d14:	50                   	push   %eax
  801d15:	e8 88 f3 ff ff       	call   8010a2 <fd_alloc>
  801d1a:	83 c4 10             	add    $0x10,%esp
		return r;
  801d1d:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d1f:	85 c0                	test   %eax,%eax
  801d21:	78 3e                	js     801d61 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d23:	83 ec 04             	sub    $0x4,%esp
  801d26:	68 07 04 00 00       	push   $0x407
  801d2b:	ff 75 f4             	pushl  -0xc(%ebp)
  801d2e:	6a 00                	push   $0x0
  801d30:	e8 45 ee ff ff       	call   800b7a <sys_page_alloc>
  801d35:	83 c4 10             	add    $0x10,%esp
		return r;
  801d38:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d3a:	85 c0                	test   %eax,%eax
  801d3c:	78 23                	js     801d61 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d3e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d44:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d47:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d49:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d4c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d53:	83 ec 0c             	sub    $0xc,%esp
  801d56:	50                   	push   %eax
  801d57:	e8 1f f3 ff ff       	call   80107b <fd2num>
  801d5c:	89 c2                	mov    %eax,%edx
  801d5e:	83 c4 10             	add    $0x10,%esp
}
  801d61:	89 d0                	mov    %edx,%eax
  801d63:	c9                   	leave  
  801d64:	c3                   	ret    

00801d65 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d65:	55                   	push   %ebp
  801d66:	89 e5                	mov    %esp,%ebp
  801d68:	56                   	push   %esi
  801d69:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801d6a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d6d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801d73:	e8 c4 ed ff ff       	call   800b3c <sys_getenvid>
  801d78:	83 ec 0c             	sub    $0xc,%esp
  801d7b:	ff 75 0c             	pushl  0xc(%ebp)
  801d7e:	ff 75 08             	pushl  0x8(%ebp)
  801d81:	56                   	push   %esi
  801d82:	50                   	push   %eax
  801d83:	68 60 27 80 00       	push   $0x802760
  801d88:	e8 47 e4 ff ff       	call   8001d4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801d8d:	83 c4 18             	add    $0x18,%esp
  801d90:	53                   	push   %ebx
  801d91:	ff 75 10             	pushl  0x10(%ebp)
  801d94:	e8 ea e3 ff ff       	call   800183 <vcprintf>
	cprintf("\n");
  801d99:	c7 04 24 0f 22 80 00 	movl   $0x80220f,(%esp)
  801da0:	e8 2f e4 ff ff       	call   8001d4 <cprintf>
  801da5:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801da8:	cc                   	int3   
  801da9:	eb fd                	jmp    801da8 <_panic+0x43>

00801dab <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801dab:	55                   	push   %ebp
  801dac:	89 e5                	mov    %esp,%ebp
  801dae:	83 ec 08             	sub    $0x8,%esp
	int r;
	int ret;
	if (_pgfault_handler == 0) {
  801db1:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801db8:	75 36                	jne    801df0 <set_pgfault_handler+0x45>
		// First time through!
		// LAB 4: Your code here.
        
        	ret = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  801dba:	a1 04 40 80 00       	mov    0x804004,%eax
  801dbf:	8b 40 48             	mov    0x48(%eax),%eax
  801dc2:	83 ec 04             	sub    $0x4,%esp
  801dc5:	68 07 0e 00 00       	push   $0xe07
  801dca:	68 00 f0 bf ee       	push   $0xeebff000
  801dcf:	50                   	push   %eax
  801dd0:	e8 a5 ed ff ff       	call   800b7a <sys_page_alloc>
		if (ret < 0) {
  801dd5:	83 c4 10             	add    $0x10,%esp
  801dd8:	85 c0                	test   %eax,%eax
  801dda:	79 14                	jns    801df0 <set_pgfault_handler+0x45>
		    panic("Allocate user exception stack failed!\n");
  801ddc:	83 ec 04             	sub    $0x4,%esp
  801ddf:	68 84 27 80 00       	push   $0x802784
  801de4:	6a 23                	push   $0x23
  801de6:	68 ac 27 80 00       	push   $0x8027ac
  801deb:	e8 75 ff ff ff       	call   801d65 <_panic>
		}
	}
	sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  801df0:	a1 04 40 80 00       	mov    0x804004,%eax
  801df5:	8b 40 48             	mov    0x48(%eax),%eax
  801df8:	83 ec 08             	sub    $0x8,%esp
  801dfb:	68 13 1e 80 00       	push   $0x801e13
  801e00:	50                   	push   %eax
  801e01:	e8 bf ee ff ff       	call   800cc5 <sys_env_set_pgfault_upcall>
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e06:	8b 45 08             	mov    0x8(%ebp),%eax
  801e09:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801e0e:	83 c4 10             	add    $0x10,%esp
  801e11:	c9                   	leave  
  801e12:	c3                   	ret    

00801e13 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e13:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e14:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e19:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e1b:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 0x28(%esp), %ebx  # trap-time eip
  801e1e:	8b 5c 24 28          	mov    0x28(%esp),%ebx
        subl $0x4, 0x30(%esp)  # trap-time esp minus 4
  801e22:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax 
  801e27:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl %ebx, (%eax)      # trap-time esp store trap-time eip
  801e2b:	89 18                	mov    %ebx,(%eax)
        addl $0x8, %esp
  801e2d:	83 c4 08             	add    $0x8,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  801e30:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  801e31:	83 c4 04             	add    $0x4,%esp
        popfl
  801e34:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  801e35:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  801e36:	c3                   	ret    

00801e37 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e37:	55                   	push   %ebp
  801e38:	89 e5                	mov    %esp,%ebp
  801e3a:	56                   	push   %esi
  801e3b:	53                   	push   %ebx
  801e3c:	8b 75 08             	mov    0x8(%ebp),%esi
  801e3f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e42:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_recv not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  801e45:	85 c0                	test   %eax,%eax
  801e47:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801e4c:	0f 44 c2             	cmove  %edx,%eax

    int r = sys_ipc_recv(pg);
  801e4f:	83 ec 0c             	sub    $0xc,%esp
  801e52:	50                   	push   %eax
  801e53:	e8 d2 ee ff ff       	call   800d2a <sys_ipc_recv>
    int from_env = 0, perm = 0;
    if (r == 0) {
  801e58:	83 c4 10             	add    $0x10,%esp
  801e5b:	85 c0                	test   %eax,%eax
  801e5d:	75 10                	jne    801e6f <ipc_recv+0x38>
        from_env = thisenv->env_ipc_from;
  801e5f:	a1 04 40 80 00       	mov    0x804004,%eax
  801e64:	8b 48 74             	mov    0x74(%eax),%ecx
        perm = thisenv->env_ipc_perm;
  801e67:	8b 50 78             	mov    0x78(%eax),%edx
        r = thisenv->env_ipc_value;
  801e6a:	8b 40 70             	mov    0x70(%eax),%eax
  801e6d:	eb 0a                	jmp    801e79 <ipc_recv+0x42>
    } else {
        from_env = 0;
        perm = 0;
  801e6f:	ba 00 00 00 00       	mov    $0x0,%edx
    if (r == 0) {
        from_env = thisenv->env_ipc_from;
        perm = thisenv->env_ipc_perm;
        r = thisenv->env_ipc_value;
    } else {
        from_env = 0;
  801e74:	b9 00 00 00 00       	mov    $0x0,%ecx
        perm = 0;
    }

    if (from_env_store) *from_env_store = from_env;
  801e79:	85 f6                	test   %esi,%esi
  801e7b:	74 02                	je     801e7f <ipc_recv+0x48>
  801e7d:	89 0e                	mov    %ecx,(%esi)
    if (perm_store) *perm_store = perm;
  801e7f:	85 db                	test   %ebx,%ebx
  801e81:	74 02                	je     801e85 <ipc_recv+0x4e>
  801e83:	89 13                	mov    %edx,(%ebx)

    return r;
}
  801e85:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e88:	5b                   	pop    %ebx
  801e89:	5e                   	pop    %esi
  801e8a:	5d                   	pop    %ebp
  801e8b:	c3                   	ret    

00801e8c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e8c:	55                   	push   %ebp
  801e8d:	89 e5                	mov    %esp,%ebp
  801e8f:	57                   	push   %edi
  801e90:	56                   	push   %esi
  801e91:	53                   	push   %ebx
  801e92:	83 ec 0c             	sub    $0xc,%esp
  801e95:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e98:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e9b:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  801e9e:	85 db                	test   %ebx,%ebx
  801ea0:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801ea5:	0f 44 d8             	cmove  %eax,%ebx
  801ea8:	eb 1c                	jmp    801ec6 <ipc_send+0x3a>

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        if (ret != -E_IPC_NOT_RECV)
  801eaa:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ead:	74 12                	je     801ec1 <ipc_send+0x35>
            panic("ipc_send error %e", ret);
  801eaf:	50                   	push   %eax
  801eb0:	68 ba 27 80 00       	push   $0x8027ba
  801eb5:	6a 40                	push   $0x40
  801eb7:	68 cc 27 80 00       	push   $0x8027cc
  801ebc:	e8 a4 fe ff ff       	call   801d65 <_panic>
        sys_yield();
  801ec1:	e8 95 ec ff ff       	call   800b5b <sys_yield>
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801ec6:	ff 75 14             	pushl  0x14(%ebp)
  801ec9:	53                   	push   %ebx
  801eca:	56                   	push   %esi
  801ecb:	57                   	push   %edi
  801ecc:	e8 36 ee ff ff       	call   800d07 <sys_ipc_try_send>
  801ed1:	83 c4 10             	add    $0x10,%esp
  801ed4:	85 c0                	test   %eax,%eax
  801ed6:	75 d2                	jne    801eaa <ipc_send+0x1e>
        if (ret != -E_IPC_NOT_RECV)
            panic("ipc_send error %e", ret);
        sys_yield();
    }
}
  801ed8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801edb:	5b                   	pop    %ebx
  801edc:	5e                   	pop    %esi
  801edd:	5f                   	pop    %edi
  801ede:	5d                   	pop    %ebp
  801edf:	c3                   	ret    

00801ee0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ee0:	55                   	push   %ebp
  801ee1:	89 e5                	mov    %esp,%ebp
  801ee3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ee6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801eeb:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801eee:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ef4:	8b 52 50             	mov    0x50(%edx),%edx
  801ef7:	39 ca                	cmp    %ecx,%edx
  801ef9:	75 0d                	jne    801f08 <ipc_find_env+0x28>
			return envs[i].env_id;
  801efb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801efe:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f03:	8b 40 48             	mov    0x48(%eax),%eax
  801f06:	eb 0f                	jmp    801f17 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f08:	83 c0 01             	add    $0x1,%eax
  801f0b:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f10:	75 d9                	jne    801eeb <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f12:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f17:	5d                   	pop    %ebp
  801f18:	c3                   	ret    

00801f19 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f19:	55                   	push   %ebp
  801f1a:	89 e5                	mov    %esp,%ebp
  801f1c:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f1f:	89 d0                	mov    %edx,%eax
  801f21:	c1 e8 16             	shr    $0x16,%eax
  801f24:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f2b:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f30:	f6 c1 01             	test   $0x1,%cl
  801f33:	74 1d                	je     801f52 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f35:	c1 ea 0c             	shr    $0xc,%edx
  801f38:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f3f:	f6 c2 01             	test   $0x1,%dl
  801f42:	74 0e                	je     801f52 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f44:	c1 ea 0c             	shr    $0xc,%edx
  801f47:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f4e:	ef 
  801f4f:	0f b7 c0             	movzwl %ax,%eax
}
  801f52:	5d                   	pop    %ebp
  801f53:	c3                   	ret    
  801f54:	66 90                	xchg   %ax,%ax
  801f56:	66 90                	xchg   %ax,%ax
  801f58:	66 90                	xchg   %ax,%ax
  801f5a:	66 90                	xchg   %ax,%ax
  801f5c:	66 90                	xchg   %ax,%ax
  801f5e:	66 90                	xchg   %ax,%ax

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
