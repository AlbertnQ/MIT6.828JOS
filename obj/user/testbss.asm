
obj/user/testbss.debug:     file format elf32-i386


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
  80002c:	e8 ab 00 00 00       	call   8000dc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	int i;

	cprintf("Making sure bss works right...\n");
  800039:	68 60 1e 80 00       	push   $0x801e60
  80003e:	e8 d2 01 00 00       	call   800215 <cprintf>
  800043:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < ARRAYSIZE; i++)
  800046:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  80004b:	83 3c 85 20 40 80 00 	cmpl   $0x0,0x804020(,%eax,4)
  800052:	00 
  800053:	74 12                	je     800067 <umain+0x34>
			panic("bigarray[%d] isn't cleared!\n", i);
  800055:	50                   	push   %eax
  800056:	68 db 1e 80 00       	push   $0x801edb
  80005b:	6a 11                	push   $0x11
  80005d:	68 f8 1e 80 00       	push   $0x801ef8
  800062:	e8 d5 00 00 00       	call   80013c <_panic>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  800067:	83 c0 01             	add    $0x1,%eax
  80006a:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80006f:	75 da                	jne    80004b <umain+0x18>
  800071:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
  800076:	89 04 85 20 40 80 00 	mov    %eax,0x804020(,%eax,4)

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  80007d:	83 c0 01             	add    $0x1,%eax
  800080:	3d 00 00 10 00       	cmp    $0x100000,%eax
  800085:	75 ef                	jne    800076 <umain+0x43>
  800087:	b8 00 00 00 00       	mov    $0x0,%eax
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != i)
  80008c:	3b 04 85 20 40 80 00 	cmp    0x804020(,%eax,4),%eax
  800093:	74 12                	je     8000a7 <umain+0x74>
			panic("bigarray[%d] didn't hold its value!\n", i);
  800095:	50                   	push   %eax
  800096:	68 80 1e 80 00       	push   $0x801e80
  80009b:	6a 16                	push   $0x16
  80009d:	68 f8 1e 80 00       	push   $0x801ef8
  8000a2:	e8 95 00 00 00       	call   80013c <_panic>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  8000a7:	83 c0 01             	add    $0x1,%eax
  8000aa:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000af:	75 db                	jne    80008c <umain+0x59>
		if (bigarray[i] != i)
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	68 a8 1e 80 00       	push   $0x801ea8
  8000b9:	e8 57 01 00 00       	call   800215 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000be:	c7 05 20 50 c0 00 00 	movl   $0x0,0xc05020
  8000c5:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000c8:	83 c4 0c             	add    $0xc,%esp
  8000cb:	68 07 1f 80 00       	push   $0x801f07
  8000d0:	6a 1a                	push   $0x1a
  8000d2:	68 f8 1e 80 00       	push   $0x801ef8
  8000d7:	e8 60 00 00 00       	call   80013c <_panic>

008000dc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	56                   	push   %esi
  8000e0:	53                   	push   %ebx
  8000e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000e4:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  8000e7:	e8 91 0a 00 00       	call   800b7d <sys_getenvid>
  8000ec:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000f4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000f9:	a3 20 40 c0 00       	mov    %eax,0xc04020
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000fe:	85 db                	test   %ebx,%ebx
  800100:	7e 07                	jle    800109 <libmain+0x2d>
		binaryname = argv[0];
  800102:	8b 06                	mov    (%esi),%eax
  800104:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800109:	83 ec 08             	sub    $0x8,%esp
  80010c:	56                   	push   %esi
  80010d:	53                   	push   %ebx
  80010e:	e8 20 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800113:	e8 0a 00 00 00       	call   800122 <exit>
}
  800118:	83 c4 10             	add    $0x10,%esp
  80011b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80011e:	5b                   	pop    %ebx
  80011f:	5e                   	pop    %esi
  800120:	5d                   	pop    %ebp
  800121:	c3                   	ret    

00800122 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800122:	55                   	push   %ebp
  800123:	89 e5                	mov    %esp,%ebp
  800125:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800128:	e8 4a 0e 00 00       	call   800f77 <close_all>
	sys_env_destroy(0);
  80012d:	83 ec 0c             	sub    $0xc,%esp
  800130:	6a 00                	push   $0x0
  800132:	e8 05 0a 00 00       	call   800b3c <sys_env_destroy>
}
  800137:	83 c4 10             	add    $0x10,%esp
  80013a:	c9                   	leave  
  80013b:	c3                   	ret    

0080013c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	56                   	push   %esi
  800140:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800141:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800144:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80014a:	e8 2e 0a 00 00       	call   800b7d <sys_getenvid>
  80014f:	83 ec 0c             	sub    $0xc,%esp
  800152:	ff 75 0c             	pushl  0xc(%ebp)
  800155:	ff 75 08             	pushl  0x8(%ebp)
  800158:	56                   	push   %esi
  800159:	50                   	push   %eax
  80015a:	68 28 1f 80 00       	push   $0x801f28
  80015f:	e8 b1 00 00 00       	call   800215 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800164:	83 c4 18             	add    $0x18,%esp
  800167:	53                   	push   %ebx
  800168:	ff 75 10             	pushl  0x10(%ebp)
  80016b:	e8 54 00 00 00       	call   8001c4 <vcprintf>
	cprintf("\n");
  800170:	c7 04 24 f6 1e 80 00 	movl   $0x801ef6,(%esp)
  800177:	e8 99 00 00 00       	call   800215 <cprintf>
  80017c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80017f:	cc                   	int3   
  800180:	eb fd                	jmp    80017f <_panic+0x43>

00800182 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800182:	55                   	push   %ebp
  800183:	89 e5                	mov    %esp,%ebp
  800185:	53                   	push   %ebx
  800186:	83 ec 04             	sub    $0x4,%esp
  800189:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80018c:	8b 13                	mov    (%ebx),%edx
  80018e:	8d 42 01             	lea    0x1(%edx),%eax
  800191:	89 03                	mov    %eax,(%ebx)
  800193:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800196:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80019a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80019f:	75 1a                	jne    8001bb <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001a1:	83 ec 08             	sub    $0x8,%esp
  8001a4:	68 ff 00 00 00       	push   $0xff
  8001a9:	8d 43 08             	lea    0x8(%ebx),%eax
  8001ac:	50                   	push   %eax
  8001ad:	e8 4d 09 00 00       	call   800aff <sys_cputs>
		b->idx = 0;
  8001b2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001b8:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001bb:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001c2:	c9                   	leave  
  8001c3:	c3                   	ret    

008001c4 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001cd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001d4:	00 00 00 
	b.cnt = 0;
  8001d7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001de:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001e1:	ff 75 0c             	pushl  0xc(%ebp)
  8001e4:	ff 75 08             	pushl  0x8(%ebp)
  8001e7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001ed:	50                   	push   %eax
  8001ee:	68 82 01 80 00       	push   $0x800182
  8001f3:	e8 54 01 00 00       	call   80034c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f8:	83 c4 08             	add    $0x8,%esp
  8001fb:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800201:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800207:	50                   	push   %eax
  800208:	e8 f2 08 00 00       	call   800aff <sys_cputs>

	return b.cnt;
}
  80020d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800213:	c9                   	leave  
  800214:	c3                   	ret    

00800215 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800215:	55                   	push   %ebp
  800216:	89 e5                	mov    %esp,%ebp
  800218:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80021b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80021e:	50                   	push   %eax
  80021f:	ff 75 08             	pushl  0x8(%ebp)
  800222:	e8 9d ff ff ff       	call   8001c4 <vcprintf>
	va_end(ap);

	return cnt;
}
  800227:	c9                   	leave  
  800228:	c3                   	ret    

00800229 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800229:	55                   	push   %ebp
  80022a:	89 e5                	mov    %esp,%ebp
  80022c:	57                   	push   %edi
  80022d:	56                   	push   %esi
  80022e:	53                   	push   %ebx
  80022f:	83 ec 1c             	sub    $0x1c,%esp
  800232:	89 c7                	mov    %eax,%edi
  800234:	89 d6                	mov    %edx,%esi
  800236:	8b 45 08             	mov    0x8(%ebp),%eax
  800239:	8b 55 0c             	mov    0xc(%ebp),%edx
  80023c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80023f:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800242:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800245:	bb 00 00 00 00       	mov    $0x0,%ebx
  80024a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80024d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800250:	39 d3                	cmp    %edx,%ebx
  800252:	72 05                	jb     800259 <printnum+0x30>
  800254:	39 45 10             	cmp    %eax,0x10(%ebp)
  800257:	77 45                	ja     80029e <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800259:	83 ec 0c             	sub    $0xc,%esp
  80025c:	ff 75 18             	pushl  0x18(%ebp)
  80025f:	8b 45 14             	mov    0x14(%ebp),%eax
  800262:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800265:	53                   	push   %ebx
  800266:	ff 75 10             	pushl  0x10(%ebp)
  800269:	83 ec 08             	sub    $0x8,%esp
  80026c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80026f:	ff 75 e0             	pushl  -0x20(%ebp)
  800272:	ff 75 dc             	pushl  -0x24(%ebp)
  800275:	ff 75 d8             	pushl  -0x28(%ebp)
  800278:	e8 43 19 00 00       	call   801bc0 <__udivdi3>
  80027d:	83 c4 18             	add    $0x18,%esp
  800280:	52                   	push   %edx
  800281:	50                   	push   %eax
  800282:	89 f2                	mov    %esi,%edx
  800284:	89 f8                	mov    %edi,%eax
  800286:	e8 9e ff ff ff       	call   800229 <printnum>
  80028b:	83 c4 20             	add    $0x20,%esp
  80028e:	eb 18                	jmp    8002a8 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800290:	83 ec 08             	sub    $0x8,%esp
  800293:	56                   	push   %esi
  800294:	ff 75 18             	pushl  0x18(%ebp)
  800297:	ff d7                	call   *%edi
  800299:	83 c4 10             	add    $0x10,%esp
  80029c:	eb 03                	jmp    8002a1 <printnum+0x78>
  80029e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002a1:	83 eb 01             	sub    $0x1,%ebx
  8002a4:	85 db                	test   %ebx,%ebx
  8002a6:	7f e8                	jg     800290 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a8:	83 ec 08             	sub    $0x8,%esp
  8002ab:	56                   	push   %esi
  8002ac:	83 ec 04             	sub    $0x4,%esp
  8002af:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002b2:	ff 75 e0             	pushl  -0x20(%ebp)
  8002b5:	ff 75 dc             	pushl  -0x24(%ebp)
  8002b8:	ff 75 d8             	pushl  -0x28(%ebp)
  8002bb:	e8 30 1a 00 00       	call   801cf0 <__umoddi3>
  8002c0:	83 c4 14             	add    $0x14,%esp
  8002c3:	0f be 80 4b 1f 80 00 	movsbl 0x801f4b(%eax),%eax
  8002ca:	50                   	push   %eax
  8002cb:	ff d7                	call   *%edi
}
  8002cd:	83 c4 10             	add    $0x10,%esp
  8002d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d3:	5b                   	pop    %ebx
  8002d4:	5e                   	pop    %esi
  8002d5:	5f                   	pop    %edi
  8002d6:	5d                   	pop    %ebp
  8002d7:	c3                   	ret    

008002d8 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002d8:	55                   	push   %ebp
  8002d9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002db:	83 fa 01             	cmp    $0x1,%edx
  8002de:	7e 0e                	jle    8002ee <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002e0:	8b 10                	mov    (%eax),%edx
  8002e2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002e5:	89 08                	mov    %ecx,(%eax)
  8002e7:	8b 02                	mov    (%edx),%eax
  8002e9:	8b 52 04             	mov    0x4(%edx),%edx
  8002ec:	eb 22                	jmp    800310 <getuint+0x38>
	else if (lflag)
  8002ee:	85 d2                	test   %edx,%edx
  8002f0:	74 10                	je     800302 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002f2:	8b 10                	mov    (%eax),%edx
  8002f4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f7:	89 08                	mov    %ecx,(%eax)
  8002f9:	8b 02                	mov    (%edx),%eax
  8002fb:	ba 00 00 00 00       	mov    $0x0,%edx
  800300:	eb 0e                	jmp    800310 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800302:	8b 10                	mov    (%eax),%edx
  800304:	8d 4a 04             	lea    0x4(%edx),%ecx
  800307:	89 08                	mov    %ecx,(%eax)
  800309:	8b 02                	mov    (%edx),%eax
  80030b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800310:	5d                   	pop    %ebp
  800311:	c3                   	ret    

00800312 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800312:	55                   	push   %ebp
  800313:	89 e5                	mov    %esp,%ebp
  800315:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800318:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80031c:	8b 10                	mov    (%eax),%edx
  80031e:	3b 50 04             	cmp    0x4(%eax),%edx
  800321:	73 0a                	jae    80032d <sprintputch+0x1b>
		*b->buf++ = ch;
  800323:	8d 4a 01             	lea    0x1(%edx),%ecx
  800326:	89 08                	mov    %ecx,(%eax)
  800328:	8b 45 08             	mov    0x8(%ebp),%eax
  80032b:	88 02                	mov    %al,(%edx)
}
  80032d:	5d                   	pop    %ebp
  80032e:	c3                   	ret    

0080032f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80032f:	55                   	push   %ebp
  800330:	89 e5                	mov    %esp,%ebp
  800332:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800335:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800338:	50                   	push   %eax
  800339:	ff 75 10             	pushl  0x10(%ebp)
  80033c:	ff 75 0c             	pushl  0xc(%ebp)
  80033f:	ff 75 08             	pushl  0x8(%ebp)
  800342:	e8 05 00 00 00       	call   80034c <vprintfmt>
	va_end(ap);
}
  800347:	83 c4 10             	add    $0x10,%esp
  80034a:	c9                   	leave  
  80034b:	c3                   	ret    

0080034c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80034c:	55                   	push   %ebp
  80034d:	89 e5                	mov    %esp,%ebp
  80034f:	57                   	push   %edi
  800350:	56                   	push   %esi
  800351:	53                   	push   %ebx
  800352:	83 ec 2c             	sub    $0x2c,%esp
  800355:	8b 75 08             	mov    0x8(%ebp),%esi
  800358:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80035b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80035e:	eb 12                	jmp    800372 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800360:	85 c0                	test   %eax,%eax
  800362:	0f 84 a7 03 00 00    	je     80070f <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
  800368:	83 ec 08             	sub    $0x8,%esp
  80036b:	53                   	push   %ebx
  80036c:	50                   	push   %eax
  80036d:	ff d6                	call   *%esi
  80036f:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800372:	83 c7 01             	add    $0x1,%edi
  800375:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800379:	83 f8 25             	cmp    $0x25,%eax
  80037c:	75 e2                	jne    800360 <vprintfmt+0x14>
  80037e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800382:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800389:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800390:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800397:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80039e:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003a3:	eb 07                	jmp    8003ac <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003a8:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ac:	8d 47 01             	lea    0x1(%edi),%eax
  8003af:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003b2:	0f b6 07             	movzbl (%edi),%eax
  8003b5:	0f b6 d0             	movzbl %al,%edx
  8003b8:	83 e8 23             	sub    $0x23,%eax
  8003bb:	3c 55                	cmp    $0x55,%al
  8003bd:	0f 87 31 03 00 00    	ja     8006f4 <vprintfmt+0x3a8>
  8003c3:	0f b6 c0             	movzbl %al,%eax
  8003c6:	ff 24 85 80 20 80 00 	jmp    *0x802080(,%eax,4)
  8003cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003d0:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003d4:	eb d6                	jmp    8003ac <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8003de:	89 75 08             	mov    %esi,0x8(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003e1:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003e4:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003e8:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003eb:	8d 72 d0             	lea    -0x30(%edx),%esi
  8003ee:	83 fe 09             	cmp    $0x9,%esi
  8003f1:	77 34                	ja     800427 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003f3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003f6:	eb e9                	jmp    8003e1 <vprintfmt+0x95>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fb:	8d 50 04             	lea    0x4(%eax),%edx
  8003fe:	89 55 14             	mov    %edx,0x14(%ebp)
  800401:	8b 00                	mov    (%eax),%eax
  800403:	89 45 cc             	mov    %eax,-0x34(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800406:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800409:	eb 22                	jmp    80042d <vprintfmt+0xe1>
  80040b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80040e:	85 c0                	test   %eax,%eax
  800410:	0f 48 c1             	cmovs  %ecx,%eax
  800413:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800416:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800419:	eb 91                	jmp    8003ac <vprintfmt+0x60>
  80041b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80041e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800425:	eb 85                	jmp    8003ac <vprintfmt+0x60>
  800427:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80042a:	8b 75 08             	mov    0x8(%ebp),%esi

		process_precision:
			if (width < 0)
  80042d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800431:	0f 89 75 ff ff ff    	jns    8003ac <vprintfmt+0x60>
				width = precision, precision = -1;
  800437:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80043a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80043d:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800444:	e9 63 ff ff ff       	jmp    8003ac <vprintfmt+0x60>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800449:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800450:	e9 57 ff ff ff       	jmp    8003ac <vprintfmt+0x60>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800455:	8b 45 14             	mov    0x14(%ebp),%eax
  800458:	8d 50 04             	lea    0x4(%eax),%edx
  80045b:	89 55 14             	mov    %edx,0x14(%ebp)
  80045e:	83 ec 08             	sub    $0x8,%esp
  800461:	53                   	push   %ebx
  800462:	ff 30                	pushl  (%eax)
  800464:	ff d6                	call   *%esi
			break;
  800466:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800469:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80046c:	e9 01 ff ff ff       	jmp    800372 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800471:	8b 45 14             	mov    0x14(%ebp),%eax
  800474:	8d 50 04             	lea    0x4(%eax),%edx
  800477:	89 55 14             	mov    %edx,0x14(%ebp)
  80047a:	8b 00                	mov    (%eax),%eax
  80047c:	99                   	cltd   
  80047d:	31 d0                	xor    %edx,%eax
  80047f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800481:	83 f8 0f             	cmp    $0xf,%eax
  800484:	7f 0b                	jg     800491 <vprintfmt+0x145>
  800486:	8b 14 85 e0 21 80 00 	mov    0x8021e0(,%eax,4),%edx
  80048d:	85 d2                	test   %edx,%edx
  80048f:	75 18                	jne    8004a9 <vprintfmt+0x15d>
				printfmt(putch, putdat, "error %d", err);
  800491:	50                   	push   %eax
  800492:	68 63 1f 80 00       	push   $0x801f63
  800497:	53                   	push   %ebx
  800498:	56                   	push   %esi
  800499:	e8 91 fe ff ff       	call   80032f <printfmt>
  80049e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004a4:	e9 c9 fe ff ff       	jmp    800372 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004a9:	52                   	push   %edx
  8004aa:	68 15 23 80 00       	push   $0x802315
  8004af:	53                   	push   %ebx
  8004b0:	56                   	push   %esi
  8004b1:	e8 79 fe ff ff       	call   80032f <printfmt>
  8004b6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004bc:	e9 b1 fe ff ff       	jmp    800372 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c4:	8d 50 04             	lea    0x4(%eax),%edx
  8004c7:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ca:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004cc:	85 ff                	test   %edi,%edi
  8004ce:	b8 5c 1f 80 00       	mov    $0x801f5c,%eax
  8004d3:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004d6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004da:	0f 8e 94 00 00 00    	jle    800574 <vprintfmt+0x228>
  8004e0:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004e4:	0f 84 98 00 00 00    	je     800582 <vprintfmt+0x236>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ea:	83 ec 08             	sub    $0x8,%esp
  8004ed:	ff 75 cc             	pushl  -0x34(%ebp)
  8004f0:	57                   	push   %edi
  8004f1:	e8 a1 02 00 00       	call   800797 <strnlen>
  8004f6:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004f9:	29 c1                	sub    %eax,%ecx
  8004fb:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8004fe:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800501:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800505:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800508:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80050b:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80050d:	eb 0f                	jmp    80051e <vprintfmt+0x1d2>
					putch(padc, putdat);
  80050f:	83 ec 08             	sub    $0x8,%esp
  800512:	53                   	push   %ebx
  800513:	ff 75 e0             	pushl  -0x20(%ebp)
  800516:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800518:	83 ef 01             	sub    $0x1,%edi
  80051b:	83 c4 10             	add    $0x10,%esp
  80051e:	85 ff                	test   %edi,%edi
  800520:	7f ed                	jg     80050f <vprintfmt+0x1c3>
  800522:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800525:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800528:	85 c9                	test   %ecx,%ecx
  80052a:	b8 00 00 00 00       	mov    $0x0,%eax
  80052f:	0f 49 c1             	cmovns %ecx,%eax
  800532:	29 c1                	sub    %eax,%ecx
  800534:	89 75 08             	mov    %esi,0x8(%ebp)
  800537:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80053a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80053d:	89 cb                	mov    %ecx,%ebx
  80053f:	eb 4d                	jmp    80058e <vprintfmt+0x242>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800541:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800545:	74 1b                	je     800562 <vprintfmt+0x216>
  800547:	0f be c0             	movsbl %al,%eax
  80054a:	83 e8 20             	sub    $0x20,%eax
  80054d:	83 f8 5e             	cmp    $0x5e,%eax
  800550:	76 10                	jbe    800562 <vprintfmt+0x216>
					putch('?', putdat);
  800552:	83 ec 08             	sub    $0x8,%esp
  800555:	ff 75 0c             	pushl  0xc(%ebp)
  800558:	6a 3f                	push   $0x3f
  80055a:	ff 55 08             	call   *0x8(%ebp)
  80055d:	83 c4 10             	add    $0x10,%esp
  800560:	eb 0d                	jmp    80056f <vprintfmt+0x223>
				else
					putch(ch, putdat);
  800562:	83 ec 08             	sub    $0x8,%esp
  800565:	ff 75 0c             	pushl  0xc(%ebp)
  800568:	52                   	push   %edx
  800569:	ff 55 08             	call   *0x8(%ebp)
  80056c:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80056f:	83 eb 01             	sub    $0x1,%ebx
  800572:	eb 1a                	jmp    80058e <vprintfmt+0x242>
  800574:	89 75 08             	mov    %esi,0x8(%ebp)
  800577:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80057a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80057d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800580:	eb 0c                	jmp    80058e <vprintfmt+0x242>
  800582:	89 75 08             	mov    %esi,0x8(%ebp)
  800585:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800588:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80058b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80058e:	83 c7 01             	add    $0x1,%edi
  800591:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800595:	0f be d0             	movsbl %al,%edx
  800598:	85 d2                	test   %edx,%edx
  80059a:	74 23                	je     8005bf <vprintfmt+0x273>
  80059c:	85 f6                	test   %esi,%esi
  80059e:	78 a1                	js     800541 <vprintfmt+0x1f5>
  8005a0:	83 ee 01             	sub    $0x1,%esi
  8005a3:	79 9c                	jns    800541 <vprintfmt+0x1f5>
  8005a5:	89 df                	mov    %ebx,%edi
  8005a7:	8b 75 08             	mov    0x8(%ebp),%esi
  8005aa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005ad:	eb 18                	jmp    8005c7 <vprintfmt+0x27b>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005af:	83 ec 08             	sub    $0x8,%esp
  8005b2:	53                   	push   %ebx
  8005b3:	6a 20                	push   $0x20
  8005b5:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005b7:	83 ef 01             	sub    $0x1,%edi
  8005ba:	83 c4 10             	add    $0x10,%esp
  8005bd:	eb 08                	jmp    8005c7 <vprintfmt+0x27b>
  8005bf:	89 df                	mov    %ebx,%edi
  8005c1:	8b 75 08             	mov    0x8(%ebp),%esi
  8005c4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005c7:	85 ff                	test   %edi,%edi
  8005c9:	7f e4                	jg     8005af <vprintfmt+0x263>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ce:	e9 9f fd ff ff       	jmp    800372 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005d3:	83 7d d0 01          	cmpl   $0x1,-0x30(%ebp)
  8005d7:	7e 16                	jle    8005ef <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  8005d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dc:	8d 50 08             	lea    0x8(%eax),%edx
  8005df:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e2:	8b 50 04             	mov    0x4(%eax),%edx
  8005e5:	8b 00                	mov    (%eax),%eax
  8005e7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ea:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005ed:	eb 34                	jmp    800623 <vprintfmt+0x2d7>
	else if (lflag)
  8005ef:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8005f3:	74 18                	je     80060d <vprintfmt+0x2c1>
		return va_arg(*ap, long);
  8005f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f8:	8d 50 04             	lea    0x4(%eax),%edx
  8005fb:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fe:	8b 00                	mov    (%eax),%eax
  800600:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800603:	89 c1                	mov    %eax,%ecx
  800605:	c1 f9 1f             	sar    $0x1f,%ecx
  800608:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80060b:	eb 16                	jmp    800623 <vprintfmt+0x2d7>
	else
		return va_arg(*ap, int);
  80060d:	8b 45 14             	mov    0x14(%ebp),%eax
  800610:	8d 50 04             	lea    0x4(%eax),%edx
  800613:	89 55 14             	mov    %edx,0x14(%ebp)
  800616:	8b 00                	mov    (%eax),%eax
  800618:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80061b:	89 c1                	mov    %eax,%ecx
  80061d:	c1 f9 1f             	sar    $0x1f,%ecx
  800620:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800623:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800626:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800629:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80062e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800632:	0f 89 88 00 00 00    	jns    8006c0 <vprintfmt+0x374>
				putch('-', putdat);
  800638:	83 ec 08             	sub    $0x8,%esp
  80063b:	53                   	push   %ebx
  80063c:	6a 2d                	push   $0x2d
  80063e:	ff d6                	call   *%esi
				num = -(long long) num;
  800640:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800643:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800646:	f7 d8                	neg    %eax
  800648:	83 d2 00             	adc    $0x0,%edx
  80064b:	f7 da                	neg    %edx
  80064d:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800650:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800655:	eb 69                	jmp    8006c0 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800657:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80065a:	8d 45 14             	lea    0x14(%ebp),%eax
  80065d:	e8 76 fc ff ff       	call   8002d8 <getuint>
			base = 10;
  800662:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800667:	eb 57                	jmp    8006c0 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  800669:	83 ec 08             	sub    $0x8,%esp
  80066c:	53                   	push   %ebx
  80066d:	6a 30                	push   $0x30
  80066f:	ff d6                	call   *%esi
			num = getuint(&ap, lflag);
  800671:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800674:	8d 45 14             	lea    0x14(%ebp),%eax
  800677:	e8 5c fc ff ff       	call   8002d8 <getuint>
			base = 8;
			goto number;
  80067c:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  80067f:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800684:	eb 3a                	jmp    8006c0 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  800686:	83 ec 08             	sub    $0x8,%esp
  800689:	53                   	push   %ebx
  80068a:	6a 30                	push   $0x30
  80068c:	ff d6                	call   *%esi
			putch('x', putdat);
  80068e:	83 c4 08             	add    $0x8,%esp
  800691:	53                   	push   %ebx
  800692:	6a 78                	push   $0x78
  800694:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800696:	8b 45 14             	mov    0x14(%ebp),%eax
  800699:	8d 50 04             	lea    0x4(%eax),%edx
  80069c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80069f:	8b 00                	mov    (%eax),%eax
  8006a1:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006a6:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006a9:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006ae:	eb 10                	jmp    8006c0 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006b0:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8006b3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b6:	e8 1d fc ff ff       	call   8002d8 <getuint>
			base = 16;
  8006bb:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006c0:	83 ec 0c             	sub    $0xc,%esp
  8006c3:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006c7:	57                   	push   %edi
  8006c8:	ff 75 e0             	pushl  -0x20(%ebp)
  8006cb:	51                   	push   %ecx
  8006cc:	52                   	push   %edx
  8006cd:	50                   	push   %eax
  8006ce:	89 da                	mov    %ebx,%edx
  8006d0:	89 f0                	mov    %esi,%eax
  8006d2:	e8 52 fb ff ff       	call   800229 <printnum>
			break;
  8006d7:	83 c4 20             	add    $0x20,%esp
  8006da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006dd:	e9 90 fc ff ff       	jmp    800372 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006e2:	83 ec 08             	sub    $0x8,%esp
  8006e5:	53                   	push   %ebx
  8006e6:	52                   	push   %edx
  8006e7:	ff d6                	call   *%esi
			break;
  8006e9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006ef:	e9 7e fc ff ff       	jmp    800372 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006f4:	83 ec 08             	sub    $0x8,%esp
  8006f7:	53                   	push   %ebx
  8006f8:	6a 25                	push   $0x25
  8006fa:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006fc:	83 c4 10             	add    $0x10,%esp
  8006ff:	eb 03                	jmp    800704 <vprintfmt+0x3b8>
  800701:	83 ef 01             	sub    $0x1,%edi
  800704:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800708:	75 f7                	jne    800701 <vprintfmt+0x3b5>
  80070a:	e9 63 fc ff ff       	jmp    800372 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80070f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800712:	5b                   	pop    %ebx
  800713:	5e                   	pop    %esi
  800714:	5f                   	pop    %edi
  800715:	5d                   	pop    %ebp
  800716:	c3                   	ret    

00800717 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800717:	55                   	push   %ebp
  800718:	89 e5                	mov    %esp,%ebp
  80071a:	83 ec 18             	sub    $0x18,%esp
  80071d:	8b 45 08             	mov    0x8(%ebp),%eax
  800720:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800723:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800726:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80072a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80072d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800734:	85 c0                	test   %eax,%eax
  800736:	74 26                	je     80075e <vsnprintf+0x47>
  800738:	85 d2                	test   %edx,%edx
  80073a:	7e 22                	jle    80075e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80073c:	ff 75 14             	pushl  0x14(%ebp)
  80073f:	ff 75 10             	pushl  0x10(%ebp)
  800742:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800745:	50                   	push   %eax
  800746:	68 12 03 80 00       	push   $0x800312
  80074b:	e8 fc fb ff ff       	call   80034c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800750:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800753:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800756:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800759:	83 c4 10             	add    $0x10,%esp
  80075c:	eb 05                	jmp    800763 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80075e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800763:	c9                   	leave  
  800764:	c3                   	ret    

00800765 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800765:	55                   	push   %ebp
  800766:	89 e5                	mov    %esp,%ebp
  800768:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80076b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80076e:	50                   	push   %eax
  80076f:	ff 75 10             	pushl  0x10(%ebp)
  800772:	ff 75 0c             	pushl  0xc(%ebp)
  800775:	ff 75 08             	pushl  0x8(%ebp)
  800778:	e8 9a ff ff ff       	call   800717 <vsnprintf>
	va_end(ap);

	return rc;
}
  80077d:	c9                   	leave  
  80077e:	c3                   	ret    

0080077f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80077f:	55                   	push   %ebp
  800780:	89 e5                	mov    %esp,%ebp
  800782:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800785:	b8 00 00 00 00       	mov    $0x0,%eax
  80078a:	eb 03                	jmp    80078f <strlen+0x10>
		n++;
  80078c:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80078f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800793:	75 f7                	jne    80078c <strlen+0xd>
		n++;
	return n;
}
  800795:	5d                   	pop    %ebp
  800796:	c3                   	ret    

00800797 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800797:	55                   	push   %ebp
  800798:	89 e5                	mov    %esp,%ebp
  80079a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80079d:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8007a5:	eb 03                	jmp    8007aa <strnlen+0x13>
		n++;
  8007a7:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007aa:	39 c2                	cmp    %eax,%edx
  8007ac:	74 08                	je     8007b6 <strnlen+0x1f>
  8007ae:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007b2:	75 f3                	jne    8007a7 <strnlen+0x10>
  8007b4:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007b6:	5d                   	pop    %ebp
  8007b7:	c3                   	ret    

008007b8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007b8:	55                   	push   %ebp
  8007b9:	89 e5                	mov    %esp,%ebp
  8007bb:	53                   	push   %ebx
  8007bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007c2:	89 c2                	mov    %eax,%edx
  8007c4:	83 c2 01             	add    $0x1,%edx
  8007c7:	83 c1 01             	add    $0x1,%ecx
  8007ca:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007ce:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007d1:	84 db                	test   %bl,%bl
  8007d3:	75 ef                	jne    8007c4 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007d5:	5b                   	pop    %ebx
  8007d6:	5d                   	pop    %ebp
  8007d7:	c3                   	ret    

008007d8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007d8:	55                   	push   %ebp
  8007d9:	89 e5                	mov    %esp,%ebp
  8007db:	53                   	push   %ebx
  8007dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007df:	53                   	push   %ebx
  8007e0:	e8 9a ff ff ff       	call   80077f <strlen>
  8007e5:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007e8:	ff 75 0c             	pushl  0xc(%ebp)
  8007eb:	01 d8                	add    %ebx,%eax
  8007ed:	50                   	push   %eax
  8007ee:	e8 c5 ff ff ff       	call   8007b8 <strcpy>
	return dst;
}
  8007f3:	89 d8                	mov    %ebx,%eax
  8007f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f8:	c9                   	leave  
  8007f9:	c3                   	ret    

008007fa <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007fa:	55                   	push   %ebp
  8007fb:	89 e5                	mov    %esp,%ebp
  8007fd:	56                   	push   %esi
  8007fe:	53                   	push   %ebx
  8007ff:	8b 75 08             	mov    0x8(%ebp),%esi
  800802:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800805:	89 f3                	mov    %esi,%ebx
  800807:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80080a:	89 f2                	mov    %esi,%edx
  80080c:	eb 0f                	jmp    80081d <strncpy+0x23>
		*dst++ = *src;
  80080e:	83 c2 01             	add    $0x1,%edx
  800811:	0f b6 01             	movzbl (%ecx),%eax
  800814:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800817:	80 39 01             	cmpb   $0x1,(%ecx)
  80081a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80081d:	39 da                	cmp    %ebx,%edx
  80081f:	75 ed                	jne    80080e <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800821:	89 f0                	mov    %esi,%eax
  800823:	5b                   	pop    %ebx
  800824:	5e                   	pop    %esi
  800825:	5d                   	pop    %ebp
  800826:	c3                   	ret    

00800827 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800827:	55                   	push   %ebp
  800828:	89 e5                	mov    %esp,%ebp
  80082a:	56                   	push   %esi
  80082b:	53                   	push   %ebx
  80082c:	8b 75 08             	mov    0x8(%ebp),%esi
  80082f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800832:	8b 55 10             	mov    0x10(%ebp),%edx
  800835:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800837:	85 d2                	test   %edx,%edx
  800839:	74 21                	je     80085c <strlcpy+0x35>
  80083b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80083f:	89 f2                	mov    %esi,%edx
  800841:	eb 09                	jmp    80084c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800843:	83 c2 01             	add    $0x1,%edx
  800846:	83 c1 01             	add    $0x1,%ecx
  800849:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80084c:	39 c2                	cmp    %eax,%edx
  80084e:	74 09                	je     800859 <strlcpy+0x32>
  800850:	0f b6 19             	movzbl (%ecx),%ebx
  800853:	84 db                	test   %bl,%bl
  800855:	75 ec                	jne    800843 <strlcpy+0x1c>
  800857:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800859:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80085c:	29 f0                	sub    %esi,%eax
}
  80085e:	5b                   	pop    %ebx
  80085f:	5e                   	pop    %esi
  800860:	5d                   	pop    %ebp
  800861:	c3                   	ret    

00800862 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800862:	55                   	push   %ebp
  800863:	89 e5                	mov    %esp,%ebp
  800865:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800868:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80086b:	eb 06                	jmp    800873 <strcmp+0x11>
		p++, q++;
  80086d:	83 c1 01             	add    $0x1,%ecx
  800870:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800873:	0f b6 01             	movzbl (%ecx),%eax
  800876:	84 c0                	test   %al,%al
  800878:	74 04                	je     80087e <strcmp+0x1c>
  80087a:	3a 02                	cmp    (%edx),%al
  80087c:	74 ef                	je     80086d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80087e:	0f b6 c0             	movzbl %al,%eax
  800881:	0f b6 12             	movzbl (%edx),%edx
  800884:	29 d0                	sub    %edx,%eax
}
  800886:	5d                   	pop    %ebp
  800887:	c3                   	ret    

00800888 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800888:	55                   	push   %ebp
  800889:	89 e5                	mov    %esp,%ebp
  80088b:	53                   	push   %ebx
  80088c:	8b 45 08             	mov    0x8(%ebp),%eax
  80088f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800892:	89 c3                	mov    %eax,%ebx
  800894:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800897:	eb 06                	jmp    80089f <strncmp+0x17>
		n--, p++, q++;
  800899:	83 c0 01             	add    $0x1,%eax
  80089c:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80089f:	39 d8                	cmp    %ebx,%eax
  8008a1:	74 15                	je     8008b8 <strncmp+0x30>
  8008a3:	0f b6 08             	movzbl (%eax),%ecx
  8008a6:	84 c9                	test   %cl,%cl
  8008a8:	74 04                	je     8008ae <strncmp+0x26>
  8008aa:	3a 0a                	cmp    (%edx),%cl
  8008ac:	74 eb                	je     800899 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ae:	0f b6 00             	movzbl (%eax),%eax
  8008b1:	0f b6 12             	movzbl (%edx),%edx
  8008b4:	29 d0                	sub    %edx,%eax
  8008b6:	eb 05                	jmp    8008bd <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008b8:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008bd:	5b                   	pop    %ebx
  8008be:	5d                   	pop    %ebp
  8008bf:	c3                   	ret    

008008c0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
  8008c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ca:	eb 07                	jmp    8008d3 <strchr+0x13>
		if (*s == c)
  8008cc:	38 ca                	cmp    %cl,%dl
  8008ce:	74 0f                	je     8008df <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008d0:	83 c0 01             	add    $0x1,%eax
  8008d3:	0f b6 10             	movzbl (%eax),%edx
  8008d6:	84 d2                	test   %dl,%dl
  8008d8:	75 f2                	jne    8008cc <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008da:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008df:	5d                   	pop    %ebp
  8008e0:	c3                   	ret    

008008e1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008e1:	55                   	push   %ebp
  8008e2:	89 e5                	mov    %esp,%ebp
  8008e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008eb:	eb 03                	jmp    8008f0 <strfind+0xf>
  8008ed:	83 c0 01             	add    $0x1,%eax
  8008f0:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008f3:	38 ca                	cmp    %cl,%dl
  8008f5:	74 04                	je     8008fb <strfind+0x1a>
  8008f7:	84 d2                	test   %dl,%dl
  8008f9:	75 f2                	jne    8008ed <strfind+0xc>
			break;
	return (char *) s;
}
  8008fb:	5d                   	pop    %ebp
  8008fc:	c3                   	ret    

008008fd <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008fd:	55                   	push   %ebp
  8008fe:	89 e5                	mov    %esp,%ebp
  800900:	57                   	push   %edi
  800901:	56                   	push   %esi
  800902:	53                   	push   %ebx
  800903:	8b 7d 08             	mov    0x8(%ebp),%edi
  800906:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800909:	85 c9                	test   %ecx,%ecx
  80090b:	74 36                	je     800943 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80090d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800913:	75 28                	jne    80093d <memset+0x40>
  800915:	f6 c1 03             	test   $0x3,%cl
  800918:	75 23                	jne    80093d <memset+0x40>
		c &= 0xFF;
  80091a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80091e:	89 d3                	mov    %edx,%ebx
  800920:	c1 e3 08             	shl    $0x8,%ebx
  800923:	89 d6                	mov    %edx,%esi
  800925:	c1 e6 18             	shl    $0x18,%esi
  800928:	89 d0                	mov    %edx,%eax
  80092a:	c1 e0 10             	shl    $0x10,%eax
  80092d:	09 f0                	or     %esi,%eax
  80092f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800931:	89 d8                	mov    %ebx,%eax
  800933:	09 d0                	or     %edx,%eax
  800935:	c1 e9 02             	shr    $0x2,%ecx
  800938:	fc                   	cld    
  800939:	f3 ab                	rep stos %eax,%es:(%edi)
  80093b:	eb 06                	jmp    800943 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80093d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800940:	fc                   	cld    
  800941:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800943:	89 f8                	mov    %edi,%eax
  800945:	5b                   	pop    %ebx
  800946:	5e                   	pop    %esi
  800947:	5f                   	pop    %edi
  800948:	5d                   	pop    %ebp
  800949:	c3                   	ret    

0080094a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80094a:	55                   	push   %ebp
  80094b:	89 e5                	mov    %esp,%ebp
  80094d:	57                   	push   %edi
  80094e:	56                   	push   %esi
  80094f:	8b 45 08             	mov    0x8(%ebp),%eax
  800952:	8b 75 0c             	mov    0xc(%ebp),%esi
  800955:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800958:	39 c6                	cmp    %eax,%esi
  80095a:	73 35                	jae    800991 <memmove+0x47>
  80095c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80095f:	39 d0                	cmp    %edx,%eax
  800961:	73 2e                	jae    800991 <memmove+0x47>
		s += n;
		d += n;
  800963:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800966:	89 d6                	mov    %edx,%esi
  800968:	09 fe                	or     %edi,%esi
  80096a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800970:	75 13                	jne    800985 <memmove+0x3b>
  800972:	f6 c1 03             	test   $0x3,%cl
  800975:	75 0e                	jne    800985 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800977:	83 ef 04             	sub    $0x4,%edi
  80097a:	8d 72 fc             	lea    -0x4(%edx),%esi
  80097d:	c1 e9 02             	shr    $0x2,%ecx
  800980:	fd                   	std    
  800981:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800983:	eb 09                	jmp    80098e <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800985:	83 ef 01             	sub    $0x1,%edi
  800988:	8d 72 ff             	lea    -0x1(%edx),%esi
  80098b:	fd                   	std    
  80098c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80098e:	fc                   	cld    
  80098f:	eb 1d                	jmp    8009ae <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800991:	89 f2                	mov    %esi,%edx
  800993:	09 c2                	or     %eax,%edx
  800995:	f6 c2 03             	test   $0x3,%dl
  800998:	75 0f                	jne    8009a9 <memmove+0x5f>
  80099a:	f6 c1 03             	test   $0x3,%cl
  80099d:	75 0a                	jne    8009a9 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80099f:	c1 e9 02             	shr    $0x2,%ecx
  8009a2:	89 c7                	mov    %eax,%edi
  8009a4:	fc                   	cld    
  8009a5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a7:	eb 05                	jmp    8009ae <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009a9:	89 c7                	mov    %eax,%edi
  8009ab:	fc                   	cld    
  8009ac:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ae:	5e                   	pop    %esi
  8009af:	5f                   	pop    %edi
  8009b0:	5d                   	pop    %ebp
  8009b1:	c3                   	ret    

008009b2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009b2:	55                   	push   %ebp
  8009b3:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009b5:	ff 75 10             	pushl  0x10(%ebp)
  8009b8:	ff 75 0c             	pushl  0xc(%ebp)
  8009bb:	ff 75 08             	pushl  0x8(%ebp)
  8009be:	e8 87 ff ff ff       	call   80094a <memmove>
}
  8009c3:	c9                   	leave  
  8009c4:	c3                   	ret    

008009c5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009c5:	55                   	push   %ebp
  8009c6:	89 e5                	mov    %esp,%ebp
  8009c8:	56                   	push   %esi
  8009c9:	53                   	push   %ebx
  8009ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d0:	89 c6                	mov    %eax,%esi
  8009d2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d5:	eb 1a                	jmp    8009f1 <memcmp+0x2c>
		if (*s1 != *s2)
  8009d7:	0f b6 08             	movzbl (%eax),%ecx
  8009da:	0f b6 1a             	movzbl (%edx),%ebx
  8009dd:	38 d9                	cmp    %bl,%cl
  8009df:	74 0a                	je     8009eb <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009e1:	0f b6 c1             	movzbl %cl,%eax
  8009e4:	0f b6 db             	movzbl %bl,%ebx
  8009e7:	29 d8                	sub    %ebx,%eax
  8009e9:	eb 0f                	jmp    8009fa <memcmp+0x35>
		s1++, s2++;
  8009eb:	83 c0 01             	add    $0x1,%eax
  8009ee:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f1:	39 f0                	cmp    %esi,%eax
  8009f3:	75 e2                	jne    8009d7 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009f5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009fa:	5b                   	pop    %ebx
  8009fb:	5e                   	pop    %esi
  8009fc:	5d                   	pop    %ebp
  8009fd:	c3                   	ret    

008009fe <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009fe:	55                   	push   %ebp
  8009ff:	89 e5                	mov    %esp,%ebp
  800a01:	53                   	push   %ebx
  800a02:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a05:	89 c1                	mov    %eax,%ecx
  800a07:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a0a:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a0e:	eb 0a                	jmp    800a1a <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a10:	0f b6 10             	movzbl (%eax),%edx
  800a13:	39 da                	cmp    %ebx,%edx
  800a15:	74 07                	je     800a1e <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a17:	83 c0 01             	add    $0x1,%eax
  800a1a:	39 c8                	cmp    %ecx,%eax
  800a1c:	72 f2                	jb     800a10 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a1e:	5b                   	pop    %ebx
  800a1f:	5d                   	pop    %ebp
  800a20:	c3                   	ret    

00800a21 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a21:	55                   	push   %ebp
  800a22:	89 e5                	mov    %esp,%ebp
  800a24:	57                   	push   %edi
  800a25:	56                   	push   %esi
  800a26:	53                   	push   %ebx
  800a27:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a2a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a2d:	eb 03                	jmp    800a32 <strtol+0x11>
		s++;
  800a2f:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a32:	0f b6 01             	movzbl (%ecx),%eax
  800a35:	3c 20                	cmp    $0x20,%al
  800a37:	74 f6                	je     800a2f <strtol+0xe>
  800a39:	3c 09                	cmp    $0x9,%al
  800a3b:	74 f2                	je     800a2f <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a3d:	3c 2b                	cmp    $0x2b,%al
  800a3f:	75 0a                	jne    800a4b <strtol+0x2a>
		s++;
  800a41:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a44:	bf 00 00 00 00       	mov    $0x0,%edi
  800a49:	eb 11                	jmp    800a5c <strtol+0x3b>
  800a4b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a50:	3c 2d                	cmp    $0x2d,%al
  800a52:	75 08                	jne    800a5c <strtol+0x3b>
		s++, neg = 1;
  800a54:	83 c1 01             	add    $0x1,%ecx
  800a57:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a5c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a62:	75 15                	jne    800a79 <strtol+0x58>
  800a64:	80 39 30             	cmpb   $0x30,(%ecx)
  800a67:	75 10                	jne    800a79 <strtol+0x58>
  800a69:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a6d:	75 7c                	jne    800aeb <strtol+0xca>
		s += 2, base = 16;
  800a6f:	83 c1 02             	add    $0x2,%ecx
  800a72:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a77:	eb 16                	jmp    800a8f <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a79:	85 db                	test   %ebx,%ebx
  800a7b:	75 12                	jne    800a8f <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a7d:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a82:	80 39 30             	cmpb   $0x30,(%ecx)
  800a85:	75 08                	jne    800a8f <strtol+0x6e>
		s++, base = 8;
  800a87:	83 c1 01             	add    $0x1,%ecx
  800a8a:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a8f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a94:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a97:	0f b6 11             	movzbl (%ecx),%edx
  800a9a:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a9d:	89 f3                	mov    %esi,%ebx
  800a9f:	80 fb 09             	cmp    $0x9,%bl
  800aa2:	77 08                	ja     800aac <strtol+0x8b>
			dig = *s - '0';
  800aa4:	0f be d2             	movsbl %dl,%edx
  800aa7:	83 ea 30             	sub    $0x30,%edx
  800aaa:	eb 22                	jmp    800ace <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800aac:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aaf:	89 f3                	mov    %esi,%ebx
  800ab1:	80 fb 19             	cmp    $0x19,%bl
  800ab4:	77 08                	ja     800abe <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ab6:	0f be d2             	movsbl %dl,%edx
  800ab9:	83 ea 57             	sub    $0x57,%edx
  800abc:	eb 10                	jmp    800ace <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800abe:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ac1:	89 f3                	mov    %esi,%ebx
  800ac3:	80 fb 19             	cmp    $0x19,%bl
  800ac6:	77 16                	ja     800ade <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ac8:	0f be d2             	movsbl %dl,%edx
  800acb:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ace:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ad1:	7d 0b                	jge    800ade <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ad3:	83 c1 01             	add    $0x1,%ecx
  800ad6:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ada:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800adc:	eb b9                	jmp    800a97 <strtol+0x76>

	if (endptr)
  800ade:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ae2:	74 0d                	je     800af1 <strtol+0xd0>
		*endptr = (char *) s;
  800ae4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ae7:	89 0e                	mov    %ecx,(%esi)
  800ae9:	eb 06                	jmp    800af1 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aeb:	85 db                	test   %ebx,%ebx
  800aed:	74 98                	je     800a87 <strtol+0x66>
  800aef:	eb 9e                	jmp    800a8f <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800af1:	89 c2                	mov    %eax,%edx
  800af3:	f7 da                	neg    %edx
  800af5:	85 ff                	test   %edi,%edi
  800af7:	0f 45 c2             	cmovne %edx,%eax
}
  800afa:	5b                   	pop    %ebx
  800afb:	5e                   	pop    %esi
  800afc:	5f                   	pop    %edi
  800afd:	5d                   	pop    %ebp
  800afe:	c3                   	ret    

00800aff <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aff:	55                   	push   %ebp
  800b00:	89 e5                	mov    %esp,%ebp
  800b02:	57                   	push   %edi
  800b03:	56                   	push   %esi
  800b04:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b05:	b8 00 00 00 00       	mov    $0x0,%eax
  800b0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b10:	89 c3                	mov    %eax,%ebx
  800b12:	89 c7                	mov    %eax,%edi
  800b14:	89 c6                	mov    %eax,%esi
  800b16:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b18:	5b                   	pop    %ebx
  800b19:	5e                   	pop    %esi
  800b1a:	5f                   	pop    %edi
  800b1b:	5d                   	pop    %ebp
  800b1c:	c3                   	ret    

00800b1d <sys_cgetc>:

int
sys_cgetc(void)
{
  800b1d:	55                   	push   %ebp
  800b1e:	89 e5                	mov    %esp,%ebp
  800b20:	57                   	push   %edi
  800b21:	56                   	push   %esi
  800b22:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b23:	ba 00 00 00 00       	mov    $0x0,%edx
  800b28:	b8 01 00 00 00       	mov    $0x1,%eax
  800b2d:	89 d1                	mov    %edx,%ecx
  800b2f:	89 d3                	mov    %edx,%ebx
  800b31:	89 d7                	mov    %edx,%edi
  800b33:	89 d6                	mov    %edx,%esi
  800b35:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b37:	5b                   	pop    %ebx
  800b38:	5e                   	pop    %esi
  800b39:	5f                   	pop    %edi
  800b3a:	5d                   	pop    %ebp
  800b3b:	c3                   	ret    

00800b3c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	57                   	push   %edi
  800b40:	56                   	push   %esi
  800b41:	53                   	push   %ebx
  800b42:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b45:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b4a:	b8 03 00 00 00       	mov    $0x3,%eax
  800b4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b52:	89 cb                	mov    %ecx,%ebx
  800b54:	89 cf                	mov    %ecx,%edi
  800b56:	89 ce                	mov    %ecx,%esi
  800b58:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b5a:	85 c0                	test   %eax,%eax
  800b5c:	7e 17                	jle    800b75 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b5e:	83 ec 0c             	sub    $0xc,%esp
  800b61:	50                   	push   %eax
  800b62:	6a 03                	push   $0x3
  800b64:	68 3f 22 80 00       	push   $0x80223f
  800b69:	6a 23                	push   $0x23
  800b6b:	68 5c 22 80 00       	push   $0x80225c
  800b70:	e8 c7 f5 ff ff       	call   80013c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b75:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b78:	5b                   	pop    %ebx
  800b79:	5e                   	pop    %esi
  800b7a:	5f                   	pop    %edi
  800b7b:	5d                   	pop    %ebp
  800b7c:	c3                   	ret    

00800b7d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b7d:	55                   	push   %ebp
  800b7e:	89 e5                	mov    %esp,%ebp
  800b80:	57                   	push   %edi
  800b81:	56                   	push   %esi
  800b82:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b83:	ba 00 00 00 00       	mov    $0x0,%edx
  800b88:	b8 02 00 00 00       	mov    $0x2,%eax
  800b8d:	89 d1                	mov    %edx,%ecx
  800b8f:	89 d3                	mov    %edx,%ebx
  800b91:	89 d7                	mov    %edx,%edi
  800b93:	89 d6                	mov    %edx,%esi
  800b95:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b97:	5b                   	pop    %ebx
  800b98:	5e                   	pop    %esi
  800b99:	5f                   	pop    %edi
  800b9a:	5d                   	pop    %ebp
  800b9b:	c3                   	ret    

00800b9c <sys_yield>:

void
sys_yield(void)
{
  800b9c:	55                   	push   %ebp
  800b9d:	89 e5                	mov    %esp,%ebp
  800b9f:	57                   	push   %edi
  800ba0:	56                   	push   %esi
  800ba1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba7:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bac:	89 d1                	mov    %edx,%ecx
  800bae:	89 d3                	mov    %edx,%ebx
  800bb0:	89 d7                	mov    %edx,%edi
  800bb2:	89 d6                	mov    %edx,%esi
  800bb4:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bb6:	5b                   	pop    %ebx
  800bb7:	5e                   	pop    %esi
  800bb8:	5f                   	pop    %edi
  800bb9:	5d                   	pop    %ebp
  800bba:	c3                   	ret    

00800bbb <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bbb:	55                   	push   %ebp
  800bbc:	89 e5                	mov    %esp,%ebp
  800bbe:	57                   	push   %edi
  800bbf:	56                   	push   %esi
  800bc0:	53                   	push   %ebx
  800bc1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc4:	be 00 00 00 00       	mov    $0x0,%esi
  800bc9:	b8 04 00 00 00       	mov    $0x4,%eax
  800bce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd1:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd7:	89 f7                	mov    %esi,%edi
  800bd9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bdb:	85 c0                	test   %eax,%eax
  800bdd:	7e 17                	jle    800bf6 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bdf:	83 ec 0c             	sub    $0xc,%esp
  800be2:	50                   	push   %eax
  800be3:	6a 04                	push   $0x4
  800be5:	68 3f 22 80 00       	push   $0x80223f
  800bea:	6a 23                	push   $0x23
  800bec:	68 5c 22 80 00       	push   $0x80225c
  800bf1:	e8 46 f5 ff ff       	call   80013c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bf6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf9:	5b                   	pop    %ebx
  800bfa:	5e                   	pop    %esi
  800bfb:	5f                   	pop    %edi
  800bfc:	5d                   	pop    %ebp
  800bfd:	c3                   	ret    

00800bfe <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bfe:	55                   	push   %ebp
  800bff:	89 e5                	mov    %esp,%ebp
  800c01:	57                   	push   %edi
  800c02:	56                   	push   %esi
  800c03:	53                   	push   %ebx
  800c04:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c07:	b8 05 00 00 00       	mov    $0x5,%eax
  800c0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c12:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c15:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c18:	8b 75 18             	mov    0x18(%ebp),%esi
  800c1b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c1d:	85 c0                	test   %eax,%eax
  800c1f:	7e 17                	jle    800c38 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c21:	83 ec 0c             	sub    $0xc,%esp
  800c24:	50                   	push   %eax
  800c25:	6a 05                	push   $0x5
  800c27:	68 3f 22 80 00       	push   $0x80223f
  800c2c:	6a 23                	push   $0x23
  800c2e:	68 5c 22 80 00       	push   $0x80225c
  800c33:	e8 04 f5 ff ff       	call   80013c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3b:	5b                   	pop    %ebx
  800c3c:	5e                   	pop    %esi
  800c3d:	5f                   	pop    %edi
  800c3e:	5d                   	pop    %ebp
  800c3f:	c3                   	ret    

00800c40 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c40:	55                   	push   %ebp
  800c41:	89 e5                	mov    %esp,%ebp
  800c43:	57                   	push   %edi
  800c44:	56                   	push   %esi
  800c45:	53                   	push   %ebx
  800c46:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c49:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c4e:	b8 06 00 00 00       	mov    $0x6,%eax
  800c53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c56:	8b 55 08             	mov    0x8(%ebp),%edx
  800c59:	89 df                	mov    %ebx,%edi
  800c5b:	89 de                	mov    %ebx,%esi
  800c5d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c5f:	85 c0                	test   %eax,%eax
  800c61:	7e 17                	jle    800c7a <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c63:	83 ec 0c             	sub    $0xc,%esp
  800c66:	50                   	push   %eax
  800c67:	6a 06                	push   $0x6
  800c69:	68 3f 22 80 00       	push   $0x80223f
  800c6e:	6a 23                	push   $0x23
  800c70:	68 5c 22 80 00       	push   $0x80225c
  800c75:	e8 c2 f4 ff ff       	call   80013c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7d:	5b                   	pop    %ebx
  800c7e:	5e                   	pop    %esi
  800c7f:	5f                   	pop    %edi
  800c80:	5d                   	pop    %ebp
  800c81:	c3                   	ret    

00800c82 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c82:	55                   	push   %ebp
  800c83:	89 e5                	mov    %esp,%ebp
  800c85:	57                   	push   %edi
  800c86:	56                   	push   %esi
  800c87:	53                   	push   %ebx
  800c88:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c90:	b8 08 00 00 00       	mov    $0x8,%eax
  800c95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c98:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9b:	89 df                	mov    %ebx,%edi
  800c9d:	89 de                	mov    %ebx,%esi
  800c9f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca1:	85 c0                	test   %eax,%eax
  800ca3:	7e 17                	jle    800cbc <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca5:	83 ec 0c             	sub    $0xc,%esp
  800ca8:	50                   	push   %eax
  800ca9:	6a 08                	push   $0x8
  800cab:	68 3f 22 80 00       	push   $0x80223f
  800cb0:	6a 23                	push   $0x23
  800cb2:	68 5c 22 80 00       	push   $0x80225c
  800cb7:	e8 80 f4 ff ff       	call   80013c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbf:	5b                   	pop    %ebx
  800cc0:	5e                   	pop    %esi
  800cc1:	5f                   	pop    %edi
  800cc2:	5d                   	pop    %ebp
  800cc3:	c3                   	ret    

00800cc4 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cc4:	55                   	push   %ebp
  800cc5:	89 e5                	mov    %esp,%ebp
  800cc7:	57                   	push   %edi
  800cc8:	56                   	push   %esi
  800cc9:	53                   	push   %ebx
  800cca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd2:	b8 09 00 00 00       	mov    $0x9,%eax
  800cd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cda:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdd:	89 df                	mov    %ebx,%edi
  800cdf:	89 de                	mov    %ebx,%esi
  800ce1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce3:	85 c0                	test   %eax,%eax
  800ce5:	7e 17                	jle    800cfe <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce7:	83 ec 0c             	sub    $0xc,%esp
  800cea:	50                   	push   %eax
  800ceb:	6a 09                	push   $0x9
  800ced:	68 3f 22 80 00       	push   $0x80223f
  800cf2:	6a 23                	push   $0x23
  800cf4:	68 5c 22 80 00       	push   $0x80225c
  800cf9:	e8 3e f4 ff ff       	call   80013c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d01:	5b                   	pop    %ebx
  800d02:	5e                   	pop    %esi
  800d03:	5f                   	pop    %edi
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    

00800d06 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
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
  800d0f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d14:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1f:	89 df                	mov    %ebx,%edi
  800d21:	89 de                	mov    %ebx,%esi
  800d23:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d25:	85 c0                	test   %eax,%eax
  800d27:	7e 17                	jle    800d40 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d29:	83 ec 0c             	sub    $0xc,%esp
  800d2c:	50                   	push   %eax
  800d2d:	6a 0a                	push   $0xa
  800d2f:	68 3f 22 80 00       	push   $0x80223f
  800d34:	6a 23                	push   $0x23
  800d36:	68 5c 22 80 00       	push   $0x80225c
  800d3b:	e8 fc f3 ff ff       	call   80013c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d43:	5b                   	pop    %ebx
  800d44:	5e                   	pop    %esi
  800d45:	5f                   	pop    %edi
  800d46:	5d                   	pop    %ebp
  800d47:	c3                   	ret    

00800d48 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d48:	55                   	push   %ebp
  800d49:	89 e5                	mov    %esp,%ebp
  800d4b:	57                   	push   %edi
  800d4c:	56                   	push   %esi
  800d4d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4e:	be 00 00 00 00       	mov    $0x0,%esi
  800d53:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d61:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d64:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d66:	5b                   	pop    %ebx
  800d67:	5e                   	pop    %esi
  800d68:	5f                   	pop    %edi
  800d69:	5d                   	pop    %ebp
  800d6a:	c3                   	ret    

00800d6b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d6b:	55                   	push   %ebp
  800d6c:	89 e5                	mov    %esp,%ebp
  800d6e:	57                   	push   %edi
  800d6f:	56                   	push   %esi
  800d70:	53                   	push   %ebx
  800d71:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d74:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d79:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d81:	89 cb                	mov    %ecx,%ebx
  800d83:	89 cf                	mov    %ecx,%edi
  800d85:	89 ce                	mov    %ecx,%esi
  800d87:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d89:	85 c0                	test   %eax,%eax
  800d8b:	7e 17                	jle    800da4 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8d:	83 ec 0c             	sub    $0xc,%esp
  800d90:	50                   	push   %eax
  800d91:	6a 0d                	push   $0xd
  800d93:	68 3f 22 80 00       	push   $0x80223f
  800d98:	6a 23                	push   $0x23
  800d9a:	68 5c 22 80 00       	push   $0x80225c
  800d9f:	e8 98 f3 ff ff       	call   80013c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800da4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da7:	5b                   	pop    %ebx
  800da8:	5e                   	pop    %esi
  800da9:	5f                   	pop    %edi
  800daa:	5d                   	pop    %ebp
  800dab:	c3                   	ret    

00800dac <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800dac:	55                   	push   %ebp
  800dad:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800daf:	8b 45 08             	mov    0x8(%ebp),%eax
  800db2:	05 00 00 00 30       	add    $0x30000000,%eax
  800db7:	c1 e8 0c             	shr    $0xc,%eax
}
  800dba:	5d                   	pop    %ebp
  800dbb:	c3                   	ret    

00800dbc <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800dbc:	55                   	push   %ebp
  800dbd:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800dbf:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc2:	05 00 00 00 30       	add    $0x30000000,%eax
  800dc7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800dcc:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800dd1:	5d                   	pop    %ebp
  800dd2:	c3                   	ret    

00800dd3 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800dd3:	55                   	push   %ebp
  800dd4:	89 e5                	mov    %esp,%ebp
  800dd6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dd9:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800dde:	89 c2                	mov    %eax,%edx
  800de0:	c1 ea 16             	shr    $0x16,%edx
  800de3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dea:	f6 c2 01             	test   $0x1,%dl
  800ded:	74 11                	je     800e00 <fd_alloc+0x2d>
  800def:	89 c2                	mov    %eax,%edx
  800df1:	c1 ea 0c             	shr    $0xc,%edx
  800df4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dfb:	f6 c2 01             	test   $0x1,%dl
  800dfe:	75 09                	jne    800e09 <fd_alloc+0x36>
			*fd_store = fd;
  800e00:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e02:	b8 00 00 00 00       	mov    $0x0,%eax
  800e07:	eb 17                	jmp    800e20 <fd_alloc+0x4d>
  800e09:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e0e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e13:	75 c9                	jne    800dde <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e15:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e1b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e20:	5d                   	pop    %ebp
  800e21:	c3                   	ret    

00800e22 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e22:	55                   	push   %ebp
  800e23:	89 e5                	mov    %esp,%ebp
  800e25:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e28:	83 f8 1f             	cmp    $0x1f,%eax
  800e2b:	77 36                	ja     800e63 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e2d:	c1 e0 0c             	shl    $0xc,%eax
  800e30:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e35:	89 c2                	mov    %eax,%edx
  800e37:	c1 ea 16             	shr    $0x16,%edx
  800e3a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e41:	f6 c2 01             	test   $0x1,%dl
  800e44:	74 24                	je     800e6a <fd_lookup+0x48>
  800e46:	89 c2                	mov    %eax,%edx
  800e48:	c1 ea 0c             	shr    $0xc,%edx
  800e4b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e52:	f6 c2 01             	test   $0x1,%dl
  800e55:	74 1a                	je     800e71 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e57:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e5a:	89 02                	mov    %eax,(%edx)
	return 0;
  800e5c:	b8 00 00 00 00       	mov    $0x0,%eax
  800e61:	eb 13                	jmp    800e76 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e63:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e68:	eb 0c                	jmp    800e76 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e6a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e6f:	eb 05                	jmp    800e76 <fd_lookup+0x54>
  800e71:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e76:	5d                   	pop    %ebp
  800e77:	c3                   	ret    

00800e78 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e78:	55                   	push   %ebp
  800e79:	89 e5                	mov    %esp,%ebp
  800e7b:	83 ec 08             	sub    $0x8,%esp
  800e7e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e81:	ba ec 22 80 00       	mov    $0x8022ec,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e86:	eb 13                	jmp    800e9b <dev_lookup+0x23>
  800e88:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e8b:	39 08                	cmp    %ecx,(%eax)
  800e8d:	75 0c                	jne    800e9b <dev_lookup+0x23>
			*dev = devtab[i];
  800e8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e92:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e94:	b8 00 00 00 00       	mov    $0x0,%eax
  800e99:	eb 2e                	jmp    800ec9 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e9b:	8b 02                	mov    (%edx),%eax
  800e9d:	85 c0                	test   %eax,%eax
  800e9f:	75 e7                	jne    800e88 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ea1:	a1 20 40 c0 00       	mov    0xc04020,%eax
  800ea6:	8b 40 48             	mov    0x48(%eax),%eax
  800ea9:	83 ec 04             	sub    $0x4,%esp
  800eac:	51                   	push   %ecx
  800ead:	50                   	push   %eax
  800eae:	68 6c 22 80 00       	push   $0x80226c
  800eb3:	e8 5d f3 ff ff       	call   800215 <cprintf>
	*dev = 0;
  800eb8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ebb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800ec1:	83 c4 10             	add    $0x10,%esp
  800ec4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800ec9:	c9                   	leave  
  800eca:	c3                   	ret    

00800ecb <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800ecb:	55                   	push   %ebp
  800ecc:	89 e5                	mov    %esp,%ebp
  800ece:	56                   	push   %esi
  800ecf:	53                   	push   %ebx
  800ed0:	83 ec 10             	sub    $0x10,%esp
  800ed3:	8b 75 08             	mov    0x8(%ebp),%esi
  800ed6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ed9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800edc:	50                   	push   %eax
  800edd:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800ee3:	c1 e8 0c             	shr    $0xc,%eax
  800ee6:	50                   	push   %eax
  800ee7:	e8 36 ff ff ff       	call   800e22 <fd_lookup>
  800eec:	83 c4 08             	add    $0x8,%esp
  800eef:	85 c0                	test   %eax,%eax
  800ef1:	78 05                	js     800ef8 <fd_close+0x2d>
	    || fd != fd2)
  800ef3:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800ef6:	74 0c                	je     800f04 <fd_close+0x39>
		return (must_exist ? r : 0);
  800ef8:	84 db                	test   %bl,%bl
  800efa:	ba 00 00 00 00       	mov    $0x0,%edx
  800eff:	0f 44 c2             	cmove  %edx,%eax
  800f02:	eb 41                	jmp    800f45 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f04:	83 ec 08             	sub    $0x8,%esp
  800f07:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f0a:	50                   	push   %eax
  800f0b:	ff 36                	pushl  (%esi)
  800f0d:	e8 66 ff ff ff       	call   800e78 <dev_lookup>
  800f12:	89 c3                	mov    %eax,%ebx
  800f14:	83 c4 10             	add    $0x10,%esp
  800f17:	85 c0                	test   %eax,%eax
  800f19:	78 1a                	js     800f35 <fd_close+0x6a>
		if (dev->dev_close)
  800f1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f1e:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f21:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f26:	85 c0                	test   %eax,%eax
  800f28:	74 0b                	je     800f35 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f2a:	83 ec 0c             	sub    $0xc,%esp
  800f2d:	56                   	push   %esi
  800f2e:	ff d0                	call   *%eax
  800f30:	89 c3                	mov    %eax,%ebx
  800f32:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f35:	83 ec 08             	sub    $0x8,%esp
  800f38:	56                   	push   %esi
  800f39:	6a 00                	push   $0x0
  800f3b:	e8 00 fd ff ff       	call   800c40 <sys_page_unmap>
	return r;
  800f40:	83 c4 10             	add    $0x10,%esp
  800f43:	89 d8                	mov    %ebx,%eax
}
  800f45:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f48:	5b                   	pop    %ebx
  800f49:	5e                   	pop    %esi
  800f4a:	5d                   	pop    %ebp
  800f4b:	c3                   	ret    

00800f4c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f4c:	55                   	push   %ebp
  800f4d:	89 e5                	mov    %esp,%ebp
  800f4f:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f52:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f55:	50                   	push   %eax
  800f56:	ff 75 08             	pushl  0x8(%ebp)
  800f59:	e8 c4 fe ff ff       	call   800e22 <fd_lookup>
  800f5e:	83 c4 08             	add    $0x8,%esp
  800f61:	85 c0                	test   %eax,%eax
  800f63:	78 10                	js     800f75 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f65:	83 ec 08             	sub    $0x8,%esp
  800f68:	6a 01                	push   $0x1
  800f6a:	ff 75 f4             	pushl  -0xc(%ebp)
  800f6d:	e8 59 ff ff ff       	call   800ecb <fd_close>
  800f72:	83 c4 10             	add    $0x10,%esp
}
  800f75:	c9                   	leave  
  800f76:	c3                   	ret    

00800f77 <close_all>:

void
close_all(void)
{
  800f77:	55                   	push   %ebp
  800f78:	89 e5                	mov    %esp,%ebp
  800f7a:	53                   	push   %ebx
  800f7b:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f7e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f83:	83 ec 0c             	sub    $0xc,%esp
  800f86:	53                   	push   %ebx
  800f87:	e8 c0 ff ff ff       	call   800f4c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f8c:	83 c3 01             	add    $0x1,%ebx
  800f8f:	83 c4 10             	add    $0x10,%esp
  800f92:	83 fb 20             	cmp    $0x20,%ebx
  800f95:	75 ec                	jne    800f83 <close_all+0xc>
		close(i);
}
  800f97:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f9a:	c9                   	leave  
  800f9b:	c3                   	ret    

00800f9c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f9c:	55                   	push   %ebp
  800f9d:	89 e5                	mov    %esp,%ebp
  800f9f:	57                   	push   %edi
  800fa0:	56                   	push   %esi
  800fa1:	53                   	push   %ebx
  800fa2:	83 ec 2c             	sub    $0x2c,%esp
  800fa5:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fa8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fab:	50                   	push   %eax
  800fac:	ff 75 08             	pushl  0x8(%ebp)
  800faf:	e8 6e fe ff ff       	call   800e22 <fd_lookup>
  800fb4:	83 c4 08             	add    $0x8,%esp
  800fb7:	85 c0                	test   %eax,%eax
  800fb9:	0f 88 c1 00 00 00    	js     801080 <dup+0xe4>
		return r;
	close(newfdnum);
  800fbf:	83 ec 0c             	sub    $0xc,%esp
  800fc2:	56                   	push   %esi
  800fc3:	e8 84 ff ff ff       	call   800f4c <close>

	newfd = INDEX2FD(newfdnum);
  800fc8:	89 f3                	mov    %esi,%ebx
  800fca:	c1 e3 0c             	shl    $0xc,%ebx
  800fcd:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800fd3:	83 c4 04             	add    $0x4,%esp
  800fd6:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fd9:	e8 de fd ff ff       	call   800dbc <fd2data>
  800fde:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800fe0:	89 1c 24             	mov    %ebx,(%esp)
  800fe3:	e8 d4 fd ff ff       	call   800dbc <fd2data>
  800fe8:	83 c4 10             	add    $0x10,%esp
  800feb:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800fee:	89 f8                	mov    %edi,%eax
  800ff0:	c1 e8 16             	shr    $0x16,%eax
  800ff3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ffa:	a8 01                	test   $0x1,%al
  800ffc:	74 37                	je     801035 <dup+0x99>
  800ffe:	89 f8                	mov    %edi,%eax
  801000:	c1 e8 0c             	shr    $0xc,%eax
  801003:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80100a:	f6 c2 01             	test   $0x1,%dl
  80100d:	74 26                	je     801035 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80100f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801016:	83 ec 0c             	sub    $0xc,%esp
  801019:	25 07 0e 00 00       	and    $0xe07,%eax
  80101e:	50                   	push   %eax
  80101f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801022:	6a 00                	push   $0x0
  801024:	57                   	push   %edi
  801025:	6a 00                	push   $0x0
  801027:	e8 d2 fb ff ff       	call   800bfe <sys_page_map>
  80102c:	89 c7                	mov    %eax,%edi
  80102e:	83 c4 20             	add    $0x20,%esp
  801031:	85 c0                	test   %eax,%eax
  801033:	78 2e                	js     801063 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801035:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801038:	89 d0                	mov    %edx,%eax
  80103a:	c1 e8 0c             	shr    $0xc,%eax
  80103d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801044:	83 ec 0c             	sub    $0xc,%esp
  801047:	25 07 0e 00 00       	and    $0xe07,%eax
  80104c:	50                   	push   %eax
  80104d:	53                   	push   %ebx
  80104e:	6a 00                	push   $0x0
  801050:	52                   	push   %edx
  801051:	6a 00                	push   $0x0
  801053:	e8 a6 fb ff ff       	call   800bfe <sys_page_map>
  801058:	89 c7                	mov    %eax,%edi
  80105a:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80105d:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80105f:	85 ff                	test   %edi,%edi
  801061:	79 1d                	jns    801080 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801063:	83 ec 08             	sub    $0x8,%esp
  801066:	53                   	push   %ebx
  801067:	6a 00                	push   $0x0
  801069:	e8 d2 fb ff ff       	call   800c40 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80106e:	83 c4 08             	add    $0x8,%esp
  801071:	ff 75 d4             	pushl  -0x2c(%ebp)
  801074:	6a 00                	push   $0x0
  801076:	e8 c5 fb ff ff       	call   800c40 <sys_page_unmap>
	return r;
  80107b:	83 c4 10             	add    $0x10,%esp
  80107e:	89 f8                	mov    %edi,%eax
}
  801080:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801083:	5b                   	pop    %ebx
  801084:	5e                   	pop    %esi
  801085:	5f                   	pop    %edi
  801086:	5d                   	pop    %ebp
  801087:	c3                   	ret    

00801088 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801088:	55                   	push   %ebp
  801089:	89 e5                	mov    %esp,%ebp
  80108b:	53                   	push   %ebx
  80108c:	83 ec 14             	sub    $0x14,%esp
  80108f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801092:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801095:	50                   	push   %eax
  801096:	53                   	push   %ebx
  801097:	e8 86 fd ff ff       	call   800e22 <fd_lookup>
  80109c:	83 c4 08             	add    $0x8,%esp
  80109f:	89 c2                	mov    %eax,%edx
  8010a1:	85 c0                	test   %eax,%eax
  8010a3:	78 6d                	js     801112 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010a5:	83 ec 08             	sub    $0x8,%esp
  8010a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010ab:	50                   	push   %eax
  8010ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010af:	ff 30                	pushl  (%eax)
  8010b1:	e8 c2 fd ff ff       	call   800e78 <dev_lookup>
  8010b6:	83 c4 10             	add    $0x10,%esp
  8010b9:	85 c0                	test   %eax,%eax
  8010bb:	78 4c                	js     801109 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010bd:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010c0:	8b 42 08             	mov    0x8(%edx),%eax
  8010c3:	83 e0 03             	and    $0x3,%eax
  8010c6:	83 f8 01             	cmp    $0x1,%eax
  8010c9:	75 21                	jne    8010ec <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010cb:	a1 20 40 c0 00       	mov    0xc04020,%eax
  8010d0:	8b 40 48             	mov    0x48(%eax),%eax
  8010d3:	83 ec 04             	sub    $0x4,%esp
  8010d6:	53                   	push   %ebx
  8010d7:	50                   	push   %eax
  8010d8:	68 b0 22 80 00       	push   $0x8022b0
  8010dd:	e8 33 f1 ff ff       	call   800215 <cprintf>
		return -E_INVAL;
  8010e2:	83 c4 10             	add    $0x10,%esp
  8010e5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8010ea:	eb 26                	jmp    801112 <read+0x8a>
	}
	if (!dev->dev_read)
  8010ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010ef:	8b 40 08             	mov    0x8(%eax),%eax
  8010f2:	85 c0                	test   %eax,%eax
  8010f4:	74 17                	je     80110d <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8010f6:	83 ec 04             	sub    $0x4,%esp
  8010f9:	ff 75 10             	pushl  0x10(%ebp)
  8010fc:	ff 75 0c             	pushl  0xc(%ebp)
  8010ff:	52                   	push   %edx
  801100:	ff d0                	call   *%eax
  801102:	89 c2                	mov    %eax,%edx
  801104:	83 c4 10             	add    $0x10,%esp
  801107:	eb 09                	jmp    801112 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801109:	89 c2                	mov    %eax,%edx
  80110b:	eb 05                	jmp    801112 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80110d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801112:	89 d0                	mov    %edx,%eax
  801114:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801117:	c9                   	leave  
  801118:	c3                   	ret    

00801119 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801119:	55                   	push   %ebp
  80111a:	89 e5                	mov    %esp,%ebp
  80111c:	57                   	push   %edi
  80111d:	56                   	push   %esi
  80111e:	53                   	push   %ebx
  80111f:	83 ec 0c             	sub    $0xc,%esp
  801122:	8b 7d 08             	mov    0x8(%ebp),%edi
  801125:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801128:	bb 00 00 00 00       	mov    $0x0,%ebx
  80112d:	eb 21                	jmp    801150 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80112f:	83 ec 04             	sub    $0x4,%esp
  801132:	89 f0                	mov    %esi,%eax
  801134:	29 d8                	sub    %ebx,%eax
  801136:	50                   	push   %eax
  801137:	89 d8                	mov    %ebx,%eax
  801139:	03 45 0c             	add    0xc(%ebp),%eax
  80113c:	50                   	push   %eax
  80113d:	57                   	push   %edi
  80113e:	e8 45 ff ff ff       	call   801088 <read>
		if (m < 0)
  801143:	83 c4 10             	add    $0x10,%esp
  801146:	85 c0                	test   %eax,%eax
  801148:	78 10                	js     80115a <readn+0x41>
			return m;
		if (m == 0)
  80114a:	85 c0                	test   %eax,%eax
  80114c:	74 0a                	je     801158 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80114e:	01 c3                	add    %eax,%ebx
  801150:	39 f3                	cmp    %esi,%ebx
  801152:	72 db                	jb     80112f <readn+0x16>
  801154:	89 d8                	mov    %ebx,%eax
  801156:	eb 02                	jmp    80115a <readn+0x41>
  801158:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80115a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80115d:	5b                   	pop    %ebx
  80115e:	5e                   	pop    %esi
  80115f:	5f                   	pop    %edi
  801160:	5d                   	pop    %ebp
  801161:	c3                   	ret    

00801162 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801162:	55                   	push   %ebp
  801163:	89 e5                	mov    %esp,%ebp
  801165:	53                   	push   %ebx
  801166:	83 ec 14             	sub    $0x14,%esp
  801169:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80116c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80116f:	50                   	push   %eax
  801170:	53                   	push   %ebx
  801171:	e8 ac fc ff ff       	call   800e22 <fd_lookup>
  801176:	83 c4 08             	add    $0x8,%esp
  801179:	89 c2                	mov    %eax,%edx
  80117b:	85 c0                	test   %eax,%eax
  80117d:	78 68                	js     8011e7 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80117f:	83 ec 08             	sub    $0x8,%esp
  801182:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801185:	50                   	push   %eax
  801186:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801189:	ff 30                	pushl  (%eax)
  80118b:	e8 e8 fc ff ff       	call   800e78 <dev_lookup>
  801190:	83 c4 10             	add    $0x10,%esp
  801193:	85 c0                	test   %eax,%eax
  801195:	78 47                	js     8011de <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801197:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80119a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80119e:	75 21                	jne    8011c1 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011a0:	a1 20 40 c0 00       	mov    0xc04020,%eax
  8011a5:	8b 40 48             	mov    0x48(%eax),%eax
  8011a8:	83 ec 04             	sub    $0x4,%esp
  8011ab:	53                   	push   %ebx
  8011ac:	50                   	push   %eax
  8011ad:	68 cc 22 80 00       	push   $0x8022cc
  8011b2:	e8 5e f0 ff ff       	call   800215 <cprintf>
		return -E_INVAL;
  8011b7:	83 c4 10             	add    $0x10,%esp
  8011ba:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011bf:	eb 26                	jmp    8011e7 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011c4:	8b 52 0c             	mov    0xc(%edx),%edx
  8011c7:	85 d2                	test   %edx,%edx
  8011c9:	74 17                	je     8011e2 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011cb:	83 ec 04             	sub    $0x4,%esp
  8011ce:	ff 75 10             	pushl  0x10(%ebp)
  8011d1:	ff 75 0c             	pushl  0xc(%ebp)
  8011d4:	50                   	push   %eax
  8011d5:	ff d2                	call   *%edx
  8011d7:	89 c2                	mov    %eax,%edx
  8011d9:	83 c4 10             	add    $0x10,%esp
  8011dc:	eb 09                	jmp    8011e7 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011de:	89 c2                	mov    %eax,%edx
  8011e0:	eb 05                	jmp    8011e7 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8011e2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8011e7:	89 d0                	mov    %edx,%eax
  8011e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011ec:	c9                   	leave  
  8011ed:	c3                   	ret    

008011ee <seek>:

int
seek(int fdnum, off_t offset)
{
  8011ee:	55                   	push   %ebp
  8011ef:	89 e5                	mov    %esp,%ebp
  8011f1:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011f4:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8011f7:	50                   	push   %eax
  8011f8:	ff 75 08             	pushl  0x8(%ebp)
  8011fb:	e8 22 fc ff ff       	call   800e22 <fd_lookup>
  801200:	83 c4 08             	add    $0x8,%esp
  801203:	85 c0                	test   %eax,%eax
  801205:	78 0e                	js     801215 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801207:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80120a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80120d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801210:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801215:	c9                   	leave  
  801216:	c3                   	ret    

00801217 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801217:	55                   	push   %ebp
  801218:	89 e5                	mov    %esp,%ebp
  80121a:	53                   	push   %ebx
  80121b:	83 ec 14             	sub    $0x14,%esp
  80121e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801221:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801224:	50                   	push   %eax
  801225:	53                   	push   %ebx
  801226:	e8 f7 fb ff ff       	call   800e22 <fd_lookup>
  80122b:	83 c4 08             	add    $0x8,%esp
  80122e:	89 c2                	mov    %eax,%edx
  801230:	85 c0                	test   %eax,%eax
  801232:	78 65                	js     801299 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801234:	83 ec 08             	sub    $0x8,%esp
  801237:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80123a:	50                   	push   %eax
  80123b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80123e:	ff 30                	pushl  (%eax)
  801240:	e8 33 fc ff ff       	call   800e78 <dev_lookup>
  801245:	83 c4 10             	add    $0x10,%esp
  801248:	85 c0                	test   %eax,%eax
  80124a:	78 44                	js     801290 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80124c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80124f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801253:	75 21                	jne    801276 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801255:	a1 20 40 c0 00       	mov    0xc04020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80125a:	8b 40 48             	mov    0x48(%eax),%eax
  80125d:	83 ec 04             	sub    $0x4,%esp
  801260:	53                   	push   %ebx
  801261:	50                   	push   %eax
  801262:	68 8c 22 80 00       	push   $0x80228c
  801267:	e8 a9 ef ff ff       	call   800215 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80126c:	83 c4 10             	add    $0x10,%esp
  80126f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801274:	eb 23                	jmp    801299 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801276:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801279:	8b 52 18             	mov    0x18(%edx),%edx
  80127c:	85 d2                	test   %edx,%edx
  80127e:	74 14                	je     801294 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801280:	83 ec 08             	sub    $0x8,%esp
  801283:	ff 75 0c             	pushl  0xc(%ebp)
  801286:	50                   	push   %eax
  801287:	ff d2                	call   *%edx
  801289:	89 c2                	mov    %eax,%edx
  80128b:	83 c4 10             	add    $0x10,%esp
  80128e:	eb 09                	jmp    801299 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801290:	89 c2                	mov    %eax,%edx
  801292:	eb 05                	jmp    801299 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801294:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801299:	89 d0                	mov    %edx,%eax
  80129b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80129e:	c9                   	leave  
  80129f:	c3                   	ret    

008012a0 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012a0:	55                   	push   %ebp
  8012a1:	89 e5                	mov    %esp,%ebp
  8012a3:	53                   	push   %ebx
  8012a4:	83 ec 14             	sub    $0x14,%esp
  8012a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012ad:	50                   	push   %eax
  8012ae:	ff 75 08             	pushl  0x8(%ebp)
  8012b1:	e8 6c fb ff ff       	call   800e22 <fd_lookup>
  8012b6:	83 c4 08             	add    $0x8,%esp
  8012b9:	89 c2                	mov    %eax,%edx
  8012bb:	85 c0                	test   %eax,%eax
  8012bd:	78 58                	js     801317 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012bf:	83 ec 08             	sub    $0x8,%esp
  8012c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012c5:	50                   	push   %eax
  8012c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c9:	ff 30                	pushl  (%eax)
  8012cb:	e8 a8 fb ff ff       	call   800e78 <dev_lookup>
  8012d0:	83 c4 10             	add    $0x10,%esp
  8012d3:	85 c0                	test   %eax,%eax
  8012d5:	78 37                	js     80130e <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8012d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012da:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012de:	74 32                	je     801312 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012e0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012e3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012ea:	00 00 00 
	stat->st_isdir = 0;
  8012ed:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012f4:	00 00 00 
	stat->st_dev = dev;
  8012f7:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012fd:	83 ec 08             	sub    $0x8,%esp
  801300:	53                   	push   %ebx
  801301:	ff 75 f0             	pushl  -0x10(%ebp)
  801304:	ff 50 14             	call   *0x14(%eax)
  801307:	89 c2                	mov    %eax,%edx
  801309:	83 c4 10             	add    $0x10,%esp
  80130c:	eb 09                	jmp    801317 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80130e:	89 c2                	mov    %eax,%edx
  801310:	eb 05                	jmp    801317 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801312:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801317:	89 d0                	mov    %edx,%eax
  801319:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80131c:	c9                   	leave  
  80131d:	c3                   	ret    

0080131e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80131e:	55                   	push   %ebp
  80131f:	89 e5                	mov    %esp,%ebp
  801321:	56                   	push   %esi
  801322:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801323:	83 ec 08             	sub    $0x8,%esp
  801326:	6a 00                	push   $0x0
  801328:	ff 75 08             	pushl  0x8(%ebp)
  80132b:	e8 e3 01 00 00       	call   801513 <open>
  801330:	89 c3                	mov    %eax,%ebx
  801332:	83 c4 10             	add    $0x10,%esp
  801335:	85 c0                	test   %eax,%eax
  801337:	78 1b                	js     801354 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801339:	83 ec 08             	sub    $0x8,%esp
  80133c:	ff 75 0c             	pushl  0xc(%ebp)
  80133f:	50                   	push   %eax
  801340:	e8 5b ff ff ff       	call   8012a0 <fstat>
  801345:	89 c6                	mov    %eax,%esi
	close(fd);
  801347:	89 1c 24             	mov    %ebx,(%esp)
  80134a:	e8 fd fb ff ff       	call   800f4c <close>
	return r;
  80134f:	83 c4 10             	add    $0x10,%esp
  801352:	89 f0                	mov    %esi,%eax
}
  801354:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801357:	5b                   	pop    %ebx
  801358:	5e                   	pop    %esi
  801359:	5d                   	pop    %ebp
  80135a:	c3                   	ret    

0080135b <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80135b:	55                   	push   %ebp
  80135c:	89 e5                	mov    %esp,%ebp
  80135e:	56                   	push   %esi
  80135f:	53                   	push   %ebx
  801360:	89 c6                	mov    %eax,%esi
  801362:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801364:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80136b:	75 12                	jne    80137f <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80136d:	83 ec 0c             	sub    $0xc,%esp
  801370:	6a 01                	push   $0x1
  801372:	e8 c8 07 00 00       	call   801b3f <ipc_find_env>
  801377:	a3 00 40 80 00       	mov    %eax,0x804000
  80137c:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80137f:	6a 07                	push   $0x7
  801381:	68 00 50 c0 00       	push   $0xc05000
  801386:	56                   	push   %esi
  801387:	ff 35 00 40 80 00    	pushl  0x804000
  80138d:	e8 59 07 00 00       	call   801aeb <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801392:	83 c4 0c             	add    $0xc,%esp
  801395:	6a 00                	push   $0x0
  801397:	53                   	push   %ebx
  801398:	6a 00                	push   $0x0
  80139a:	e8 f7 06 00 00       	call   801a96 <ipc_recv>
}
  80139f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013a2:	5b                   	pop    %ebx
  8013a3:	5e                   	pop    %esi
  8013a4:	5d                   	pop    %ebp
  8013a5:	c3                   	ret    

008013a6 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013a6:	55                   	push   %ebp
  8013a7:	89 e5                	mov    %esp,%ebp
  8013a9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8013af:	8b 40 0c             	mov    0xc(%eax),%eax
  8013b2:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.set_size.req_size = newsize;
  8013b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013ba:	a3 04 50 c0 00       	mov    %eax,0xc05004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8013bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8013c4:	b8 02 00 00 00       	mov    $0x2,%eax
  8013c9:	e8 8d ff ff ff       	call   80135b <fsipc>
}
  8013ce:	c9                   	leave  
  8013cf:	c3                   	ret    

008013d0 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8013d0:	55                   	push   %ebp
  8013d1:	89 e5                	mov    %esp,%ebp
  8013d3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8013d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d9:	8b 40 0c             	mov    0xc(%eax),%eax
  8013dc:	a3 00 50 c0 00       	mov    %eax,0xc05000
	return fsipc(FSREQ_FLUSH, NULL);
  8013e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8013e6:	b8 06 00 00 00       	mov    $0x6,%eax
  8013eb:	e8 6b ff ff ff       	call   80135b <fsipc>
}
  8013f0:	c9                   	leave  
  8013f1:	c3                   	ret    

008013f2 <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8013f2:	55                   	push   %ebp
  8013f3:	89 e5                	mov    %esp,%ebp
  8013f5:	53                   	push   %ebx
  8013f6:	83 ec 04             	sub    $0x4,%esp
  8013f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ff:	8b 40 0c             	mov    0xc(%eax),%eax
  801402:	a3 00 50 c0 00       	mov    %eax,0xc05000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801407:	ba 00 00 00 00       	mov    $0x0,%edx
  80140c:	b8 05 00 00 00       	mov    $0x5,%eax
  801411:	e8 45 ff ff ff       	call   80135b <fsipc>
  801416:	85 c0                	test   %eax,%eax
  801418:	78 2c                	js     801446 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80141a:	83 ec 08             	sub    $0x8,%esp
  80141d:	68 00 50 c0 00       	push   $0xc05000
  801422:	53                   	push   %ebx
  801423:	e8 90 f3 ff ff       	call   8007b8 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801428:	a1 80 50 c0 00       	mov    0xc05080,%eax
  80142d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801433:	a1 84 50 c0 00       	mov    0xc05084,%eax
  801438:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80143e:	83 c4 10             	add    $0x10,%esp
  801441:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801446:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801449:	c9                   	leave  
  80144a:	c3                   	ret    

0080144b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80144b:	55                   	push   %ebp
  80144c:	89 e5                	mov    %esp,%ebp
  80144e:	83 ec 0c             	sub    $0xc,%esp
  801451:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
    
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  801454:	8b 55 08             	mov    0x8(%ebp),%edx
  801457:	8b 52 0c             	mov    0xc(%edx),%edx
  80145a:	89 15 00 50 c0 00    	mov    %edx,0xc05000
    fsipcbuf.write.req_n = MIN(n, PGSIZE);
  801460:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801465:	ba 00 10 00 00       	mov    $0x1000,%edx
  80146a:	0f 47 c2             	cmova  %edx,%eax
  80146d:	a3 04 50 c0 00       	mov    %eax,0xc05004
    memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801472:	50                   	push   %eax
  801473:	ff 75 0c             	pushl  0xc(%ebp)
  801476:	68 08 50 c0 00       	push   $0xc05008
  80147b:	e8 ca f4 ff ff       	call   80094a <memmove>
    int r = fsipc(FSREQ_WRITE, NULL);
  801480:	ba 00 00 00 00       	mov    $0x0,%edx
  801485:	b8 04 00 00 00       	mov    $0x4,%eax
  80148a:	e8 cc fe ff ff       	call   80135b <fsipc>
    return r;
}
  80148f:	c9                   	leave  
  801490:	c3                   	ret    

00801491 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801491:	55                   	push   %ebp
  801492:	89 e5                	mov    %esp,%ebp
  801494:	56                   	push   %esi
  801495:	53                   	push   %ebx
  801496:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801499:	8b 45 08             	mov    0x8(%ebp),%eax
  80149c:	8b 40 0c             	mov    0xc(%eax),%eax
  80149f:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.read.req_n = n;
  8014a4:	89 35 04 50 c0 00    	mov    %esi,0xc05004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8014af:	b8 03 00 00 00       	mov    $0x3,%eax
  8014b4:	e8 a2 fe ff ff       	call   80135b <fsipc>
  8014b9:	89 c3                	mov    %eax,%ebx
  8014bb:	85 c0                	test   %eax,%eax
  8014bd:	78 4b                	js     80150a <devfile_read+0x79>
		return r;
	assert(r <= n);
  8014bf:	39 c6                	cmp    %eax,%esi
  8014c1:	73 16                	jae    8014d9 <devfile_read+0x48>
  8014c3:	68 fc 22 80 00       	push   $0x8022fc
  8014c8:	68 03 23 80 00       	push   $0x802303
  8014cd:	6a 7c                	push   $0x7c
  8014cf:	68 18 23 80 00       	push   $0x802318
  8014d4:	e8 63 ec ff ff       	call   80013c <_panic>
	assert(r <= PGSIZE);
  8014d9:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014de:	7e 16                	jle    8014f6 <devfile_read+0x65>
  8014e0:	68 23 23 80 00       	push   $0x802323
  8014e5:	68 03 23 80 00       	push   $0x802303
  8014ea:	6a 7d                	push   $0x7d
  8014ec:	68 18 23 80 00       	push   $0x802318
  8014f1:	e8 46 ec ff ff       	call   80013c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8014f6:	83 ec 04             	sub    $0x4,%esp
  8014f9:	50                   	push   %eax
  8014fa:	68 00 50 c0 00       	push   $0xc05000
  8014ff:	ff 75 0c             	pushl  0xc(%ebp)
  801502:	e8 43 f4 ff ff       	call   80094a <memmove>
	return r;
  801507:	83 c4 10             	add    $0x10,%esp
}
  80150a:	89 d8                	mov    %ebx,%eax
  80150c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80150f:	5b                   	pop    %ebx
  801510:	5e                   	pop    %esi
  801511:	5d                   	pop    %ebp
  801512:	c3                   	ret    

00801513 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801513:	55                   	push   %ebp
  801514:	89 e5                	mov    %esp,%ebp
  801516:	53                   	push   %ebx
  801517:	83 ec 20             	sub    $0x20,%esp
  80151a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80151d:	53                   	push   %ebx
  80151e:	e8 5c f2 ff ff       	call   80077f <strlen>
  801523:	83 c4 10             	add    $0x10,%esp
  801526:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80152b:	7f 67                	jg     801594 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80152d:	83 ec 0c             	sub    $0xc,%esp
  801530:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801533:	50                   	push   %eax
  801534:	e8 9a f8 ff ff       	call   800dd3 <fd_alloc>
  801539:	83 c4 10             	add    $0x10,%esp
		return r;
  80153c:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80153e:	85 c0                	test   %eax,%eax
  801540:	78 57                	js     801599 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801542:	83 ec 08             	sub    $0x8,%esp
  801545:	53                   	push   %ebx
  801546:	68 00 50 c0 00       	push   $0xc05000
  80154b:	e8 68 f2 ff ff       	call   8007b8 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801550:	8b 45 0c             	mov    0xc(%ebp),%eax
  801553:	a3 00 54 c0 00       	mov    %eax,0xc05400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801558:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80155b:	b8 01 00 00 00       	mov    $0x1,%eax
  801560:	e8 f6 fd ff ff       	call   80135b <fsipc>
  801565:	89 c3                	mov    %eax,%ebx
  801567:	83 c4 10             	add    $0x10,%esp
  80156a:	85 c0                	test   %eax,%eax
  80156c:	79 14                	jns    801582 <open+0x6f>
		fd_close(fd, 0);
  80156e:	83 ec 08             	sub    $0x8,%esp
  801571:	6a 00                	push   $0x0
  801573:	ff 75 f4             	pushl  -0xc(%ebp)
  801576:	e8 50 f9 ff ff       	call   800ecb <fd_close>
		return r;
  80157b:	83 c4 10             	add    $0x10,%esp
  80157e:	89 da                	mov    %ebx,%edx
  801580:	eb 17                	jmp    801599 <open+0x86>
	}

	return fd2num(fd);
  801582:	83 ec 0c             	sub    $0xc,%esp
  801585:	ff 75 f4             	pushl  -0xc(%ebp)
  801588:	e8 1f f8 ff ff       	call   800dac <fd2num>
  80158d:	89 c2                	mov    %eax,%edx
  80158f:	83 c4 10             	add    $0x10,%esp
  801592:	eb 05                	jmp    801599 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801594:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801599:	89 d0                	mov    %edx,%eax
  80159b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80159e:	c9                   	leave  
  80159f:	c3                   	ret    

008015a0 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015a0:	55                   	push   %ebp
  8015a1:	89 e5                	mov    %esp,%ebp
  8015a3:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8015ab:	b8 08 00 00 00       	mov    $0x8,%eax
  8015b0:	e8 a6 fd ff ff       	call   80135b <fsipc>
}
  8015b5:	c9                   	leave  
  8015b6:	c3                   	ret    

008015b7 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8015b7:	55                   	push   %ebp
  8015b8:	89 e5                	mov    %esp,%ebp
  8015ba:	56                   	push   %esi
  8015bb:	53                   	push   %ebx
  8015bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8015bf:	83 ec 0c             	sub    $0xc,%esp
  8015c2:	ff 75 08             	pushl  0x8(%ebp)
  8015c5:	e8 f2 f7 ff ff       	call   800dbc <fd2data>
  8015ca:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8015cc:	83 c4 08             	add    $0x8,%esp
  8015cf:	68 2f 23 80 00       	push   $0x80232f
  8015d4:	53                   	push   %ebx
  8015d5:	e8 de f1 ff ff       	call   8007b8 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8015da:	8b 46 04             	mov    0x4(%esi),%eax
  8015dd:	2b 06                	sub    (%esi),%eax
  8015df:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8015e5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015ec:	00 00 00 
	stat->st_dev = &devpipe;
  8015ef:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8015f6:	30 80 00 
	return 0;
}
  8015f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8015fe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801601:	5b                   	pop    %ebx
  801602:	5e                   	pop    %esi
  801603:	5d                   	pop    %ebp
  801604:	c3                   	ret    

00801605 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801605:	55                   	push   %ebp
  801606:	89 e5                	mov    %esp,%ebp
  801608:	53                   	push   %ebx
  801609:	83 ec 0c             	sub    $0xc,%esp
  80160c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80160f:	53                   	push   %ebx
  801610:	6a 00                	push   $0x0
  801612:	e8 29 f6 ff ff       	call   800c40 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801617:	89 1c 24             	mov    %ebx,(%esp)
  80161a:	e8 9d f7 ff ff       	call   800dbc <fd2data>
  80161f:	83 c4 08             	add    $0x8,%esp
  801622:	50                   	push   %eax
  801623:	6a 00                	push   $0x0
  801625:	e8 16 f6 ff ff       	call   800c40 <sys_page_unmap>
}
  80162a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80162d:	c9                   	leave  
  80162e:	c3                   	ret    

0080162f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80162f:	55                   	push   %ebp
  801630:	89 e5                	mov    %esp,%ebp
  801632:	57                   	push   %edi
  801633:	56                   	push   %esi
  801634:	53                   	push   %ebx
  801635:	83 ec 1c             	sub    $0x1c,%esp
  801638:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80163b:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80163d:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801642:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801645:	83 ec 0c             	sub    $0xc,%esp
  801648:	ff 75 e0             	pushl  -0x20(%ebp)
  80164b:	e8 28 05 00 00       	call   801b78 <pageref>
  801650:	89 c3                	mov    %eax,%ebx
  801652:	89 3c 24             	mov    %edi,(%esp)
  801655:	e8 1e 05 00 00       	call   801b78 <pageref>
  80165a:	83 c4 10             	add    $0x10,%esp
  80165d:	39 c3                	cmp    %eax,%ebx
  80165f:	0f 94 c1             	sete   %cl
  801662:	0f b6 c9             	movzbl %cl,%ecx
  801665:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801668:	8b 15 20 40 c0 00    	mov    0xc04020,%edx
  80166e:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801671:	39 ce                	cmp    %ecx,%esi
  801673:	74 1b                	je     801690 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801675:	39 c3                	cmp    %eax,%ebx
  801677:	75 c4                	jne    80163d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801679:	8b 42 58             	mov    0x58(%edx),%eax
  80167c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80167f:	50                   	push   %eax
  801680:	56                   	push   %esi
  801681:	68 36 23 80 00       	push   $0x802336
  801686:	e8 8a eb ff ff       	call   800215 <cprintf>
  80168b:	83 c4 10             	add    $0x10,%esp
  80168e:	eb ad                	jmp    80163d <_pipeisclosed+0xe>
	}
}
  801690:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801693:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801696:	5b                   	pop    %ebx
  801697:	5e                   	pop    %esi
  801698:	5f                   	pop    %edi
  801699:	5d                   	pop    %ebp
  80169a:	c3                   	ret    

0080169b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80169b:	55                   	push   %ebp
  80169c:	89 e5                	mov    %esp,%ebp
  80169e:	57                   	push   %edi
  80169f:	56                   	push   %esi
  8016a0:	53                   	push   %ebx
  8016a1:	83 ec 28             	sub    $0x28,%esp
  8016a4:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8016a7:	56                   	push   %esi
  8016a8:	e8 0f f7 ff ff       	call   800dbc <fd2data>
  8016ad:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016af:	83 c4 10             	add    $0x10,%esp
  8016b2:	bf 00 00 00 00       	mov    $0x0,%edi
  8016b7:	eb 4b                	jmp    801704 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8016b9:	89 da                	mov    %ebx,%edx
  8016bb:	89 f0                	mov    %esi,%eax
  8016bd:	e8 6d ff ff ff       	call   80162f <_pipeisclosed>
  8016c2:	85 c0                	test   %eax,%eax
  8016c4:	75 48                	jne    80170e <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8016c6:	e8 d1 f4 ff ff       	call   800b9c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8016cb:	8b 43 04             	mov    0x4(%ebx),%eax
  8016ce:	8b 0b                	mov    (%ebx),%ecx
  8016d0:	8d 51 20             	lea    0x20(%ecx),%edx
  8016d3:	39 d0                	cmp    %edx,%eax
  8016d5:	73 e2                	jae    8016b9 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8016d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016da:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8016de:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8016e1:	89 c2                	mov    %eax,%edx
  8016e3:	c1 fa 1f             	sar    $0x1f,%edx
  8016e6:	89 d1                	mov    %edx,%ecx
  8016e8:	c1 e9 1b             	shr    $0x1b,%ecx
  8016eb:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8016ee:	83 e2 1f             	and    $0x1f,%edx
  8016f1:	29 ca                	sub    %ecx,%edx
  8016f3:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8016f7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8016fb:	83 c0 01             	add    $0x1,%eax
  8016fe:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801701:	83 c7 01             	add    $0x1,%edi
  801704:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801707:	75 c2                	jne    8016cb <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801709:	8b 45 10             	mov    0x10(%ebp),%eax
  80170c:	eb 05                	jmp    801713 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80170e:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801713:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801716:	5b                   	pop    %ebx
  801717:	5e                   	pop    %esi
  801718:	5f                   	pop    %edi
  801719:	5d                   	pop    %ebp
  80171a:	c3                   	ret    

0080171b <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80171b:	55                   	push   %ebp
  80171c:	89 e5                	mov    %esp,%ebp
  80171e:	57                   	push   %edi
  80171f:	56                   	push   %esi
  801720:	53                   	push   %ebx
  801721:	83 ec 18             	sub    $0x18,%esp
  801724:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801727:	57                   	push   %edi
  801728:	e8 8f f6 ff ff       	call   800dbc <fd2data>
  80172d:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80172f:	83 c4 10             	add    $0x10,%esp
  801732:	bb 00 00 00 00       	mov    $0x0,%ebx
  801737:	eb 3d                	jmp    801776 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801739:	85 db                	test   %ebx,%ebx
  80173b:	74 04                	je     801741 <devpipe_read+0x26>
				return i;
  80173d:	89 d8                	mov    %ebx,%eax
  80173f:	eb 44                	jmp    801785 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801741:	89 f2                	mov    %esi,%edx
  801743:	89 f8                	mov    %edi,%eax
  801745:	e8 e5 fe ff ff       	call   80162f <_pipeisclosed>
  80174a:	85 c0                	test   %eax,%eax
  80174c:	75 32                	jne    801780 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80174e:	e8 49 f4 ff ff       	call   800b9c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801753:	8b 06                	mov    (%esi),%eax
  801755:	3b 46 04             	cmp    0x4(%esi),%eax
  801758:	74 df                	je     801739 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80175a:	99                   	cltd   
  80175b:	c1 ea 1b             	shr    $0x1b,%edx
  80175e:	01 d0                	add    %edx,%eax
  801760:	83 e0 1f             	and    $0x1f,%eax
  801763:	29 d0                	sub    %edx,%eax
  801765:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80176a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80176d:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801770:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801773:	83 c3 01             	add    $0x1,%ebx
  801776:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801779:	75 d8                	jne    801753 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80177b:	8b 45 10             	mov    0x10(%ebp),%eax
  80177e:	eb 05                	jmp    801785 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801780:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801785:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801788:	5b                   	pop    %ebx
  801789:	5e                   	pop    %esi
  80178a:	5f                   	pop    %edi
  80178b:	5d                   	pop    %ebp
  80178c:	c3                   	ret    

0080178d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80178d:	55                   	push   %ebp
  80178e:	89 e5                	mov    %esp,%ebp
  801790:	56                   	push   %esi
  801791:	53                   	push   %ebx
  801792:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801795:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801798:	50                   	push   %eax
  801799:	e8 35 f6 ff ff       	call   800dd3 <fd_alloc>
  80179e:	83 c4 10             	add    $0x10,%esp
  8017a1:	89 c2                	mov    %eax,%edx
  8017a3:	85 c0                	test   %eax,%eax
  8017a5:	0f 88 2c 01 00 00    	js     8018d7 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017ab:	83 ec 04             	sub    $0x4,%esp
  8017ae:	68 07 04 00 00       	push   $0x407
  8017b3:	ff 75 f4             	pushl  -0xc(%ebp)
  8017b6:	6a 00                	push   $0x0
  8017b8:	e8 fe f3 ff ff       	call   800bbb <sys_page_alloc>
  8017bd:	83 c4 10             	add    $0x10,%esp
  8017c0:	89 c2                	mov    %eax,%edx
  8017c2:	85 c0                	test   %eax,%eax
  8017c4:	0f 88 0d 01 00 00    	js     8018d7 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8017ca:	83 ec 0c             	sub    $0xc,%esp
  8017cd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017d0:	50                   	push   %eax
  8017d1:	e8 fd f5 ff ff       	call   800dd3 <fd_alloc>
  8017d6:	89 c3                	mov    %eax,%ebx
  8017d8:	83 c4 10             	add    $0x10,%esp
  8017db:	85 c0                	test   %eax,%eax
  8017dd:	0f 88 e2 00 00 00    	js     8018c5 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017e3:	83 ec 04             	sub    $0x4,%esp
  8017e6:	68 07 04 00 00       	push   $0x407
  8017eb:	ff 75 f0             	pushl  -0x10(%ebp)
  8017ee:	6a 00                	push   $0x0
  8017f0:	e8 c6 f3 ff ff       	call   800bbb <sys_page_alloc>
  8017f5:	89 c3                	mov    %eax,%ebx
  8017f7:	83 c4 10             	add    $0x10,%esp
  8017fa:	85 c0                	test   %eax,%eax
  8017fc:	0f 88 c3 00 00 00    	js     8018c5 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801802:	83 ec 0c             	sub    $0xc,%esp
  801805:	ff 75 f4             	pushl  -0xc(%ebp)
  801808:	e8 af f5 ff ff       	call   800dbc <fd2data>
  80180d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80180f:	83 c4 0c             	add    $0xc,%esp
  801812:	68 07 04 00 00       	push   $0x407
  801817:	50                   	push   %eax
  801818:	6a 00                	push   $0x0
  80181a:	e8 9c f3 ff ff       	call   800bbb <sys_page_alloc>
  80181f:	89 c3                	mov    %eax,%ebx
  801821:	83 c4 10             	add    $0x10,%esp
  801824:	85 c0                	test   %eax,%eax
  801826:	0f 88 89 00 00 00    	js     8018b5 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80182c:	83 ec 0c             	sub    $0xc,%esp
  80182f:	ff 75 f0             	pushl  -0x10(%ebp)
  801832:	e8 85 f5 ff ff       	call   800dbc <fd2data>
  801837:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80183e:	50                   	push   %eax
  80183f:	6a 00                	push   $0x0
  801841:	56                   	push   %esi
  801842:	6a 00                	push   $0x0
  801844:	e8 b5 f3 ff ff       	call   800bfe <sys_page_map>
  801849:	89 c3                	mov    %eax,%ebx
  80184b:	83 c4 20             	add    $0x20,%esp
  80184e:	85 c0                	test   %eax,%eax
  801850:	78 55                	js     8018a7 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801852:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801858:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80185b:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80185d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801860:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801867:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80186d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801870:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801872:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801875:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80187c:	83 ec 0c             	sub    $0xc,%esp
  80187f:	ff 75 f4             	pushl  -0xc(%ebp)
  801882:	e8 25 f5 ff ff       	call   800dac <fd2num>
  801887:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80188a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80188c:	83 c4 04             	add    $0x4,%esp
  80188f:	ff 75 f0             	pushl  -0x10(%ebp)
  801892:	e8 15 f5 ff ff       	call   800dac <fd2num>
  801897:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80189a:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80189d:	83 c4 10             	add    $0x10,%esp
  8018a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a5:	eb 30                	jmp    8018d7 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8018a7:	83 ec 08             	sub    $0x8,%esp
  8018aa:	56                   	push   %esi
  8018ab:	6a 00                	push   $0x0
  8018ad:	e8 8e f3 ff ff       	call   800c40 <sys_page_unmap>
  8018b2:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8018b5:	83 ec 08             	sub    $0x8,%esp
  8018b8:	ff 75 f0             	pushl  -0x10(%ebp)
  8018bb:	6a 00                	push   $0x0
  8018bd:	e8 7e f3 ff ff       	call   800c40 <sys_page_unmap>
  8018c2:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8018c5:	83 ec 08             	sub    $0x8,%esp
  8018c8:	ff 75 f4             	pushl  -0xc(%ebp)
  8018cb:	6a 00                	push   $0x0
  8018cd:	e8 6e f3 ff ff       	call   800c40 <sys_page_unmap>
  8018d2:	83 c4 10             	add    $0x10,%esp
  8018d5:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8018d7:	89 d0                	mov    %edx,%eax
  8018d9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018dc:	5b                   	pop    %ebx
  8018dd:	5e                   	pop    %esi
  8018de:	5d                   	pop    %ebp
  8018df:	c3                   	ret    

008018e0 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8018e0:	55                   	push   %ebp
  8018e1:	89 e5                	mov    %esp,%ebp
  8018e3:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018e9:	50                   	push   %eax
  8018ea:	ff 75 08             	pushl  0x8(%ebp)
  8018ed:	e8 30 f5 ff ff       	call   800e22 <fd_lookup>
  8018f2:	83 c4 10             	add    $0x10,%esp
  8018f5:	85 c0                	test   %eax,%eax
  8018f7:	78 18                	js     801911 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8018f9:	83 ec 0c             	sub    $0xc,%esp
  8018fc:	ff 75 f4             	pushl  -0xc(%ebp)
  8018ff:	e8 b8 f4 ff ff       	call   800dbc <fd2data>
	return _pipeisclosed(fd, p);
  801904:	89 c2                	mov    %eax,%edx
  801906:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801909:	e8 21 fd ff ff       	call   80162f <_pipeisclosed>
  80190e:	83 c4 10             	add    $0x10,%esp
}
  801911:	c9                   	leave  
  801912:	c3                   	ret    

00801913 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801913:	55                   	push   %ebp
  801914:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801916:	b8 00 00 00 00       	mov    $0x0,%eax
  80191b:	5d                   	pop    %ebp
  80191c:	c3                   	ret    

0080191d <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80191d:	55                   	push   %ebp
  80191e:	89 e5                	mov    %esp,%ebp
  801920:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801923:	68 4e 23 80 00       	push   $0x80234e
  801928:	ff 75 0c             	pushl  0xc(%ebp)
  80192b:	e8 88 ee ff ff       	call   8007b8 <strcpy>
	return 0;
}
  801930:	b8 00 00 00 00       	mov    $0x0,%eax
  801935:	c9                   	leave  
  801936:	c3                   	ret    

00801937 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801937:	55                   	push   %ebp
  801938:	89 e5                	mov    %esp,%ebp
  80193a:	57                   	push   %edi
  80193b:	56                   	push   %esi
  80193c:	53                   	push   %ebx
  80193d:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801943:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801948:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80194e:	eb 2d                	jmp    80197d <devcons_write+0x46>
		m = n - tot;
  801950:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801953:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801955:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801958:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80195d:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801960:	83 ec 04             	sub    $0x4,%esp
  801963:	53                   	push   %ebx
  801964:	03 45 0c             	add    0xc(%ebp),%eax
  801967:	50                   	push   %eax
  801968:	57                   	push   %edi
  801969:	e8 dc ef ff ff       	call   80094a <memmove>
		sys_cputs(buf, m);
  80196e:	83 c4 08             	add    $0x8,%esp
  801971:	53                   	push   %ebx
  801972:	57                   	push   %edi
  801973:	e8 87 f1 ff ff       	call   800aff <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801978:	01 de                	add    %ebx,%esi
  80197a:	83 c4 10             	add    $0x10,%esp
  80197d:	89 f0                	mov    %esi,%eax
  80197f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801982:	72 cc                	jb     801950 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801984:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801987:	5b                   	pop    %ebx
  801988:	5e                   	pop    %esi
  801989:	5f                   	pop    %edi
  80198a:	5d                   	pop    %ebp
  80198b:	c3                   	ret    

0080198c <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80198c:	55                   	push   %ebp
  80198d:	89 e5                	mov    %esp,%ebp
  80198f:	83 ec 08             	sub    $0x8,%esp
  801992:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801997:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80199b:	74 2a                	je     8019c7 <devcons_read+0x3b>
  80199d:	eb 05                	jmp    8019a4 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80199f:	e8 f8 f1 ff ff       	call   800b9c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8019a4:	e8 74 f1 ff ff       	call   800b1d <sys_cgetc>
  8019a9:	85 c0                	test   %eax,%eax
  8019ab:	74 f2                	je     80199f <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8019ad:	85 c0                	test   %eax,%eax
  8019af:	78 16                	js     8019c7 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8019b1:	83 f8 04             	cmp    $0x4,%eax
  8019b4:	74 0c                	je     8019c2 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8019b6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019b9:	88 02                	mov    %al,(%edx)
	return 1;
  8019bb:	b8 01 00 00 00       	mov    $0x1,%eax
  8019c0:	eb 05                	jmp    8019c7 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8019c2:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8019c7:	c9                   	leave  
  8019c8:	c3                   	ret    

008019c9 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8019c9:	55                   	push   %ebp
  8019ca:	89 e5                	mov    %esp,%ebp
  8019cc:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8019cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d2:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8019d5:	6a 01                	push   $0x1
  8019d7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8019da:	50                   	push   %eax
  8019db:	e8 1f f1 ff ff       	call   800aff <sys_cputs>
}
  8019e0:	83 c4 10             	add    $0x10,%esp
  8019e3:	c9                   	leave  
  8019e4:	c3                   	ret    

008019e5 <getchar>:

int
getchar(void)
{
  8019e5:	55                   	push   %ebp
  8019e6:	89 e5                	mov    %esp,%ebp
  8019e8:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8019eb:	6a 01                	push   $0x1
  8019ed:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8019f0:	50                   	push   %eax
  8019f1:	6a 00                	push   $0x0
  8019f3:	e8 90 f6 ff ff       	call   801088 <read>
	if (r < 0)
  8019f8:	83 c4 10             	add    $0x10,%esp
  8019fb:	85 c0                	test   %eax,%eax
  8019fd:	78 0f                	js     801a0e <getchar+0x29>
		return r;
	if (r < 1)
  8019ff:	85 c0                	test   %eax,%eax
  801a01:	7e 06                	jle    801a09 <getchar+0x24>
		return -E_EOF;
	return c;
  801a03:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801a07:	eb 05                	jmp    801a0e <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801a09:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801a0e:	c9                   	leave  
  801a0f:	c3                   	ret    

00801a10 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801a10:	55                   	push   %ebp
  801a11:	89 e5                	mov    %esp,%ebp
  801a13:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a16:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a19:	50                   	push   %eax
  801a1a:	ff 75 08             	pushl  0x8(%ebp)
  801a1d:	e8 00 f4 ff ff       	call   800e22 <fd_lookup>
  801a22:	83 c4 10             	add    $0x10,%esp
  801a25:	85 c0                	test   %eax,%eax
  801a27:	78 11                	js     801a3a <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801a29:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a2c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a32:	39 10                	cmp    %edx,(%eax)
  801a34:	0f 94 c0             	sete   %al
  801a37:	0f b6 c0             	movzbl %al,%eax
}
  801a3a:	c9                   	leave  
  801a3b:	c3                   	ret    

00801a3c <opencons>:

int
opencons(void)
{
  801a3c:	55                   	push   %ebp
  801a3d:	89 e5                	mov    %esp,%ebp
  801a3f:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a42:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a45:	50                   	push   %eax
  801a46:	e8 88 f3 ff ff       	call   800dd3 <fd_alloc>
  801a4b:	83 c4 10             	add    $0x10,%esp
		return r;
  801a4e:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a50:	85 c0                	test   %eax,%eax
  801a52:	78 3e                	js     801a92 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a54:	83 ec 04             	sub    $0x4,%esp
  801a57:	68 07 04 00 00       	push   $0x407
  801a5c:	ff 75 f4             	pushl  -0xc(%ebp)
  801a5f:	6a 00                	push   $0x0
  801a61:	e8 55 f1 ff ff       	call   800bbb <sys_page_alloc>
  801a66:	83 c4 10             	add    $0x10,%esp
		return r;
  801a69:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a6b:	85 c0                	test   %eax,%eax
  801a6d:	78 23                	js     801a92 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801a6f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a75:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a78:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801a7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a7d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801a84:	83 ec 0c             	sub    $0xc,%esp
  801a87:	50                   	push   %eax
  801a88:	e8 1f f3 ff ff       	call   800dac <fd2num>
  801a8d:	89 c2                	mov    %eax,%edx
  801a8f:	83 c4 10             	add    $0x10,%esp
}
  801a92:	89 d0                	mov    %edx,%eax
  801a94:	c9                   	leave  
  801a95:	c3                   	ret    

00801a96 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a96:	55                   	push   %ebp
  801a97:	89 e5                	mov    %esp,%ebp
  801a99:	56                   	push   %esi
  801a9a:	53                   	push   %ebx
  801a9b:	8b 75 08             	mov    0x8(%ebp),%esi
  801a9e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aa1:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_recv not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  801aa4:	85 c0                	test   %eax,%eax
  801aa6:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801aab:	0f 44 c2             	cmove  %edx,%eax

    int r = sys_ipc_recv(pg);
  801aae:	83 ec 0c             	sub    $0xc,%esp
  801ab1:	50                   	push   %eax
  801ab2:	e8 b4 f2 ff ff       	call   800d6b <sys_ipc_recv>
    int from_env = 0, perm = 0;
    if (r == 0) {
  801ab7:	83 c4 10             	add    $0x10,%esp
  801aba:	85 c0                	test   %eax,%eax
  801abc:	75 10                	jne    801ace <ipc_recv+0x38>
        from_env = thisenv->env_ipc_from;
  801abe:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801ac3:	8b 48 74             	mov    0x74(%eax),%ecx
        perm = thisenv->env_ipc_perm;
  801ac6:	8b 50 78             	mov    0x78(%eax),%edx
        r = thisenv->env_ipc_value;
  801ac9:	8b 40 70             	mov    0x70(%eax),%eax
  801acc:	eb 0a                	jmp    801ad8 <ipc_recv+0x42>
    } else {
        from_env = 0;
        perm = 0;
  801ace:	ba 00 00 00 00       	mov    $0x0,%edx
    if (r == 0) {
        from_env = thisenv->env_ipc_from;
        perm = thisenv->env_ipc_perm;
        r = thisenv->env_ipc_value;
    } else {
        from_env = 0;
  801ad3:	b9 00 00 00 00       	mov    $0x0,%ecx
        perm = 0;
    }

    if (from_env_store) *from_env_store = from_env;
  801ad8:	85 f6                	test   %esi,%esi
  801ada:	74 02                	je     801ade <ipc_recv+0x48>
  801adc:	89 0e                	mov    %ecx,(%esi)
    if (perm_store) *perm_store = perm;
  801ade:	85 db                	test   %ebx,%ebx
  801ae0:	74 02                	je     801ae4 <ipc_recv+0x4e>
  801ae2:	89 13                	mov    %edx,(%ebx)

    return r;
}
  801ae4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ae7:	5b                   	pop    %ebx
  801ae8:	5e                   	pop    %esi
  801ae9:	5d                   	pop    %ebp
  801aea:	c3                   	ret    

00801aeb <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801aeb:	55                   	push   %ebp
  801aec:	89 e5                	mov    %esp,%ebp
  801aee:	57                   	push   %edi
  801aef:	56                   	push   %esi
  801af0:	53                   	push   %ebx
  801af1:	83 ec 0c             	sub    $0xc,%esp
  801af4:	8b 7d 08             	mov    0x8(%ebp),%edi
  801af7:	8b 75 0c             	mov    0xc(%ebp),%esi
  801afa:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  801afd:	85 db                	test   %ebx,%ebx
  801aff:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801b04:	0f 44 d8             	cmove  %eax,%ebx
  801b07:	eb 1c                	jmp    801b25 <ipc_send+0x3a>

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        if (ret != -E_IPC_NOT_RECV)
  801b09:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b0c:	74 12                	je     801b20 <ipc_send+0x35>
            panic("ipc_send error %e", ret);
  801b0e:	50                   	push   %eax
  801b0f:	68 5a 23 80 00       	push   $0x80235a
  801b14:	6a 40                	push   $0x40
  801b16:	68 6c 23 80 00       	push   $0x80236c
  801b1b:	e8 1c e6 ff ff       	call   80013c <_panic>
        sys_yield();
  801b20:	e8 77 f0 ff ff       	call   800b9c <sys_yield>
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801b25:	ff 75 14             	pushl  0x14(%ebp)
  801b28:	53                   	push   %ebx
  801b29:	56                   	push   %esi
  801b2a:	57                   	push   %edi
  801b2b:	e8 18 f2 ff ff       	call   800d48 <sys_ipc_try_send>
  801b30:	83 c4 10             	add    $0x10,%esp
  801b33:	85 c0                	test   %eax,%eax
  801b35:	75 d2                	jne    801b09 <ipc_send+0x1e>
        if (ret != -E_IPC_NOT_RECV)
            panic("ipc_send error %e", ret);
        sys_yield();
    }
}
  801b37:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b3a:	5b                   	pop    %ebx
  801b3b:	5e                   	pop    %esi
  801b3c:	5f                   	pop    %edi
  801b3d:	5d                   	pop    %ebp
  801b3e:	c3                   	ret    

00801b3f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b3f:	55                   	push   %ebp
  801b40:	89 e5                	mov    %esp,%ebp
  801b42:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b45:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b4a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b4d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b53:	8b 52 50             	mov    0x50(%edx),%edx
  801b56:	39 ca                	cmp    %ecx,%edx
  801b58:	75 0d                	jne    801b67 <ipc_find_env+0x28>
			return envs[i].env_id;
  801b5a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b5d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b62:	8b 40 48             	mov    0x48(%eax),%eax
  801b65:	eb 0f                	jmp    801b76 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b67:	83 c0 01             	add    $0x1,%eax
  801b6a:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b6f:	75 d9                	jne    801b4a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b71:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b76:	5d                   	pop    %ebp
  801b77:	c3                   	ret    

00801b78 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b78:	55                   	push   %ebp
  801b79:	89 e5                	mov    %esp,%ebp
  801b7b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b7e:	89 d0                	mov    %edx,%eax
  801b80:	c1 e8 16             	shr    $0x16,%eax
  801b83:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b8a:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b8f:	f6 c1 01             	test   $0x1,%cl
  801b92:	74 1d                	je     801bb1 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b94:	c1 ea 0c             	shr    $0xc,%edx
  801b97:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b9e:	f6 c2 01             	test   $0x1,%dl
  801ba1:	74 0e                	je     801bb1 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ba3:	c1 ea 0c             	shr    $0xc,%edx
  801ba6:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801bad:	ef 
  801bae:	0f b7 c0             	movzwl %ax,%eax
}
  801bb1:	5d                   	pop    %ebp
  801bb2:	c3                   	ret    
  801bb3:	66 90                	xchg   %ax,%ax
  801bb5:	66 90                	xchg   %ax,%ax
  801bb7:	66 90                	xchg   %ax,%ax
  801bb9:	66 90                	xchg   %ax,%ax
  801bbb:	66 90                	xchg   %ax,%ax
  801bbd:	66 90                	xchg   %ax,%ax
  801bbf:	90                   	nop

00801bc0 <__udivdi3>:
  801bc0:	55                   	push   %ebp
  801bc1:	57                   	push   %edi
  801bc2:	56                   	push   %esi
  801bc3:	53                   	push   %ebx
  801bc4:	83 ec 1c             	sub    $0x1c,%esp
  801bc7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801bcb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801bcf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801bd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801bd7:	85 f6                	test   %esi,%esi
  801bd9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bdd:	89 ca                	mov    %ecx,%edx
  801bdf:	89 f8                	mov    %edi,%eax
  801be1:	75 3d                	jne    801c20 <__udivdi3+0x60>
  801be3:	39 cf                	cmp    %ecx,%edi
  801be5:	0f 87 c5 00 00 00    	ja     801cb0 <__udivdi3+0xf0>
  801beb:	85 ff                	test   %edi,%edi
  801bed:	89 fd                	mov    %edi,%ebp
  801bef:	75 0b                	jne    801bfc <__udivdi3+0x3c>
  801bf1:	b8 01 00 00 00       	mov    $0x1,%eax
  801bf6:	31 d2                	xor    %edx,%edx
  801bf8:	f7 f7                	div    %edi
  801bfa:	89 c5                	mov    %eax,%ebp
  801bfc:	89 c8                	mov    %ecx,%eax
  801bfe:	31 d2                	xor    %edx,%edx
  801c00:	f7 f5                	div    %ebp
  801c02:	89 c1                	mov    %eax,%ecx
  801c04:	89 d8                	mov    %ebx,%eax
  801c06:	89 cf                	mov    %ecx,%edi
  801c08:	f7 f5                	div    %ebp
  801c0a:	89 c3                	mov    %eax,%ebx
  801c0c:	89 d8                	mov    %ebx,%eax
  801c0e:	89 fa                	mov    %edi,%edx
  801c10:	83 c4 1c             	add    $0x1c,%esp
  801c13:	5b                   	pop    %ebx
  801c14:	5e                   	pop    %esi
  801c15:	5f                   	pop    %edi
  801c16:	5d                   	pop    %ebp
  801c17:	c3                   	ret    
  801c18:	90                   	nop
  801c19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c20:	39 ce                	cmp    %ecx,%esi
  801c22:	77 74                	ja     801c98 <__udivdi3+0xd8>
  801c24:	0f bd fe             	bsr    %esi,%edi
  801c27:	83 f7 1f             	xor    $0x1f,%edi
  801c2a:	0f 84 98 00 00 00    	je     801cc8 <__udivdi3+0x108>
  801c30:	bb 20 00 00 00       	mov    $0x20,%ebx
  801c35:	89 f9                	mov    %edi,%ecx
  801c37:	89 c5                	mov    %eax,%ebp
  801c39:	29 fb                	sub    %edi,%ebx
  801c3b:	d3 e6                	shl    %cl,%esi
  801c3d:	89 d9                	mov    %ebx,%ecx
  801c3f:	d3 ed                	shr    %cl,%ebp
  801c41:	89 f9                	mov    %edi,%ecx
  801c43:	d3 e0                	shl    %cl,%eax
  801c45:	09 ee                	or     %ebp,%esi
  801c47:	89 d9                	mov    %ebx,%ecx
  801c49:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c4d:	89 d5                	mov    %edx,%ebp
  801c4f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c53:	d3 ed                	shr    %cl,%ebp
  801c55:	89 f9                	mov    %edi,%ecx
  801c57:	d3 e2                	shl    %cl,%edx
  801c59:	89 d9                	mov    %ebx,%ecx
  801c5b:	d3 e8                	shr    %cl,%eax
  801c5d:	09 c2                	or     %eax,%edx
  801c5f:	89 d0                	mov    %edx,%eax
  801c61:	89 ea                	mov    %ebp,%edx
  801c63:	f7 f6                	div    %esi
  801c65:	89 d5                	mov    %edx,%ebp
  801c67:	89 c3                	mov    %eax,%ebx
  801c69:	f7 64 24 0c          	mull   0xc(%esp)
  801c6d:	39 d5                	cmp    %edx,%ebp
  801c6f:	72 10                	jb     801c81 <__udivdi3+0xc1>
  801c71:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c75:	89 f9                	mov    %edi,%ecx
  801c77:	d3 e6                	shl    %cl,%esi
  801c79:	39 c6                	cmp    %eax,%esi
  801c7b:	73 07                	jae    801c84 <__udivdi3+0xc4>
  801c7d:	39 d5                	cmp    %edx,%ebp
  801c7f:	75 03                	jne    801c84 <__udivdi3+0xc4>
  801c81:	83 eb 01             	sub    $0x1,%ebx
  801c84:	31 ff                	xor    %edi,%edi
  801c86:	89 d8                	mov    %ebx,%eax
  801c88:	89 fa                	mov    %edi,%edx
  801c8a:	83 c4 1c             	add    $0x1c,%esp
  801c8d:	5b                   	pop    %ebx
  801c8e:	5e                   	pop    %esi
  801c8f:	5f                   	pop    %edi
  801c90:	5d                   	pop    %ebp
  801c91:	c3                   	ret    
  801c92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c98:	31 ff                	xor    %edi,%edi
  801c9a:	31 db                	xor    %ebx,%ebx
  801c9c:	89 d8                	mov    %ebx,%eax
  801c9e:	89 fa                	mov    %edi,%edx
  801ca0:	83 c4 1c             	add    $0x1c,%esp
  801ca3:	5b                   	pop    %ebx
  801ca4:	5e                   	pop    %esi
  801ca5:	5f                   	pop    %edi
  801ca6:	5d                   	pop    %ebp
  801ca7:	c3                   	ret    
  801ca8:	90                   	nop
  801ca9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cb0:	89 d8                	mov    %ebx,%eax
  801cb2:	f7 f7                	div    %edi
  801cb4:	31 ff                	xor    %edi,%edi
  801cb6:	89 c3                	mov    %eax,%ebx
  801cb8:	89 d8                	mov    %ebx,%eax
  801cba:	89 fa                	mov    %edi,%edx
  801cbc:	83 c4 1c             	add    $0x1c,%esp
  801cbf:	5b                   	pop    %ebx
  801cc0:	5e                   	pop    %esi
  801cc1:	5f                   	pop    %edi
  801cc2:	5d                   	pop    %ebp
  801cc3:	c3                   	ret    
  801cc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cc8:	39 ce                	cmp    %ecx,%esi
  801cca:	72 0c                	jb     801cd8 <__udivdi3+0x118>
  801ccc:	31 db                	xor    %ebx,%ebx
  801cce:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801cd2:	0f 87 34 ff ff ff    	ja     801c0c <__udivdi3+0x4c>
  801cd8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801cdd:	e9 2a ff ff ff       	jmp    801c0c <__udivdi3+0x4c>
  801ce2:	66 90                	xchg   %ax,%ax
  801ce4:	66 90                	xchg   %ax,%ax
  801ce6:	66 90                	xchg   %ax,%ax
  801ce8:	66 90                	xchg   %ax,%ax
  801cea:	66 90                	xchg   %ax,%ax
  801cec:	66 90                	xchg   %ax,%ax
  801cee:	66 90                	xchg   %ax,%ax

00801cf0 <__umoddi3>:
  801cf0:	55                   	push   %ebp
  801cf1:	57                   	push   %edi
  801cf2:	56                   	push   %esi
  801cf3:	53                   	push   %ebx
  801cf4:	83 ec 1c             	sub    $0x1c,%esp
  801cf7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801cfb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801cff:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d03:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d07:	85 d2                	test   %edx,%edx
  801d09:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801d0d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d11:	89 f3                	mov    %esi,%ebx
  801d13:	89 3c 24             	mov    %edi,(%esp)
  801d16:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d1a:	75 1c                	jne    801d38 <__umoddi3+0x48>
  801d1c:	39 f7                	cmp    %esi,%edi
  801d1e:	76 50                	jbe    801d70 <__umoddi3+0x80>
  801d20:	89 c8                	mov    %ecx,%eax
  801d22:	89 f2                	mov    %esi,%edx
  801d24:	f7 f7                	div    %edi
  801d26:	89 d0                	mov    %edx,%eax
  801d28:	31 d2                	xor    %edx,%edx
  801d2a:	83 c4 1c             	add    $0x1c,%esp
  801d2d:	5b                   	pop    %ebx
  801d2e:	5e                   	pop    %esi
  801d2f:	5f                   	pop    %edi
  801d30:	5d                   	pop    %ebp
  801d31:	c3                   	ret    
  801d32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d38:	39 f2                	cmp    %esi,%edx
  801d3a:	89 d0                	mov    %edx,%eax
  801d3c:	77 52                	ja     801d90 <__umoddi3+0xa0>
  801d3e:	0f bd ea             	bsr    %edx,%ebp
  801d41:	83 f5 1f             	xor    $0x1f,%ebp
  801d44:	75 5a                	jne    801da0 <__umoddi3+0xb0>
  801d46:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d4a:	0f 82 e0 00 00 00    	jb     801e30 <__umoddi3+0x140>
  801d50:	39 0c 24             	cmp    %ecx,(%esp)
  801d53:	0f 86 d7 00 00 00    	jbe    801e30 <__umoddi3+0x140>
  801d59:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d5d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d61:	83 c4 1c             	add    $0x1c,%esp
  801d64:	5b                   	pop    %ebx
  801d65:	5e                   	pop    %esi
  801d66:	5f                   	pop    %edi
  801d67:	5d                   	pop    %ebp
  801d68:	c3                   	ret    
  801d69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d70:	85 ff                	test   %edi,%edi
  801d72:	89 fd                	mov    %edi,%ebp
  801d74:	75 0b                	jne    801d81 <__umoddi3+0x91>
  801d76:	b8 01 00 00 00       	mov    $0x1,%eax
  801d7b:	31 d2                	xor    %edx,%edx
  801d7d:	f7 f7                	div    %edi
  801d7f:	89 c5                	mov    %eax,%ebp
  801d81:	89 f0                	mov    %esi,%eax
  801d83:	31 d2                	xor    %edx,%edx
  801d85:	f7 f5                	div    %ebp
  801d87:	89 c8                	mov    %ecx,%eax
  801d89:	f7 f5                	div    %ebp
  801d8b:	89 d0                	mov    %edx,%eax
  801d8d:	eb 99                	jmp    801d28 <__umoddi3+0x38>
  801d8f:	90                   	nop
  801d90:	89 c8                	mov    %ecx,%eax
  801d92:	89 f2                	mov    %esi,%edx
  801d94:	83 c4 1c             	add    $0x1c,%esp
  801d97:	5b                   	pop    %ebx
  801d98:	5e                   	pop    %esi
  801d99:	5f                   	pop    %edi
  801d9a:	5d                   	pop    %ebp
  801d9b:	c3                   	ret    
  801d9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801da0:	8b 34 24             	mov    (%esp),%esi
  801da3:	bf 20 00 00 00       	mov    $0x20,%edi
  801da8:	89 e9                	mov    %ebp,%ecx
  801daa:	29 ef                	sub    %ebp,%edi
  801dac:	d3 e0                	shl    %cl,%eax
  801dae:	89 f9                	mov    %edi,%ecx
  801db0:	89 f2                	mov    %esi,%edx
  801db2:	d3 ea                	shr    %cl,%edx
  801db4:	89 e9                	mov    %ebp,%ecx
  801db6:	09 c2                	or     %eax,%edx
  801db8:	89 d8                	mov    %ebx,%eax
  801dba:	89 14 24             	mov    %edx,(%esp)
  801dbd:	89 f2                	mov    %esi,%edx
  801dbf:	d3 e2                	shl    %cl,%edx
  801dc1:	89 f9                	mov    %edi,%ecx
  801dc3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801dc7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801dcb:	d3 e8                	shr    %cl,%eax
  801dcd:	89 e9                	mov    %ebp,%ecx
  801dcf:	89 c6                	mov    %eax,%esi
  801dd1:	d3 e3                	shl    %cl,%ebx
  801dd3:	89 f9                	mov    %edi,%ecx
  801dd5:	89 d0                	mov    %edx,%eax
  801dd7:	d3 e8                	shr    %cl,%eax
  801dd9:	89 e9                	mov    %ebp,%ecx
  801ddb:	09 d8                	or     %ebx,%eax
  801ddd:	89 d3                	mov    %edx,%ebx
  801ddf:	89 f2                	mov    %esi,%edx
  801de1:	f7 34 24             	divl   (%esp)
  801de4:	89 d6                	mov    %edx,%esi
  801de6:	d3 e3                	shl    %cl,%ebx
  801de8:	f7 64 24 04          	mull   0x4(%esp)
  801dec:	39 d6                	cmp    %edx,%esi
  801dee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801df2:	89 d1                	mov    %edx,%ecx
  801df4:	89 c3                	mov    %eax,%ebx
  801df6:	72 08                	jb     801e00 <__umoddi3+0x110>
  801df8:	75 11                	jne    801e0b <__umoddi3+0x11b>
  801dfa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801dfe:	73 0b                	jae    801e0b <__umoddi3+0x11b>
  801e00:	2b 44 24 04          	sub    0x4(%esp),%eax
  801e04:	1b 14 24             	sbb    (%esp),%edx
  801e07:	89 d1                	mov    %edx,%ecx
  801e09:	89 c3                	mov    %eax,%ebx
  801e0b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801e0f:	29 da                	sub    %ebx,%edx
  801e11:	19 ce                	sbb    %ecx,%esi
  801e13:	89 f9                	mov    %edi,%ecx
  801e15:	89 f0                	mov    %esi,%eax
  801e17:	d3 e0                	shl    %cl,%eax
  801e19:	89 e9                	mov    %ebp,%ecx
  801e1b:	d3 ea                	shr    %cl,%edx
  801e1d:	89 e9                	mov    %ebp,%ecx
  801e1f:	d3 ee                	shr    %cl,%esi
  801e21:	09 d0                	or     %edx,%eax
  801e23:	89 f2                	mov    %esi,%edx
  801e25:	83 c4 1c             	add    $0x1c,%esp
  801e28:	5b                   	pop    %ebx
  801e29:	5e                   	pop    %esi
  801e2a:	5f                   	pop    %edi
  801e2b:	5d                   	pop    %ebp
  801e2c:	c3                   	ret    
  801e2d:	8d 76 00             	lea    0x0(%esi),%esi
  801e30:	29 f9                	sub    %edi,%ecx
  801e32:	19 d6                	sbb    %edx,%esi
  801e34:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e38:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e3c:	e9 18 ff ff ff       	jmp    801d59 <__umoddi3+0x69>
