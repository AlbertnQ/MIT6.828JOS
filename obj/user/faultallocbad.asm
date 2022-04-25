
obj/user/faultallocbad.debug:     file format elf32-i386


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
  80002c:	e8 84 00 00 00       	call   8000b5 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003a:	8b 45 08             	mov    0x8(%ebp),%eax
  80003d:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  80003f:	53                   	push   %ebx
  800040:	68 c0 1e 80 00       	push   $0x801ec0
  800045:	e8 a4 01 00 00       	call   8001ee <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 36 0b 00 00       	call   800b94 <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	79 16                	jns    80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800065:	83 ec 0c             	sub    $0xc,%esp
  800068:	50                   	push   %eax
  800069:	53                   	push   %ebx
  80006a:	68 e0 1e 80 00       	push   $0x801ee0
  80006f:	6a 0f                	push   $0xf
  800071:	68 ca 1e 80 00       	push   $0x801eca
  800076:	e8 9a 00 00 00       	call   800115 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007b:	53                   	push   %ebx
  80007c:	68 0c 1f 80 00       	push   $0x801f0c
  800081:	6a 64                	push   $0x64
  800083:	53                   	push   %ebx
  800084:	e8 b5 06 00 00       	call   80073e <snprintf>
}
  800089:	83 c4 10             	add    $0x10,%esp
  80008c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80008f:	c9                   	leave  
  800090:	c3                   	ret    

00800091 <umain>:

void
umain(int argc, char **argv)
{
  800091:	55                   	push   %ebp
  800092:	89 e5                	mov    %esp,%ebp
  800094:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800097:	68 33 00 80 00       	push   $0x800033
  80009c:	e8 e4 0c 00 00       	call   800d85 <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	6a 04                	push   $0x4
  8000a6:	68 ef be ad de       	push   $0xdeadbeef
  8000ab:	e8 28 0a 00 00       	call   800ad8 <sys_cputs>
}
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    

008000b5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
  8000ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000bd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  8000c0:	e8 91 0a 00 00       	call   800b56 <sys_getenvid>
  8000c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ca:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000cd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d2:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000d7:	85 db                	test   %ebx,%ebx
  8000d9:	7e 07                	jle    8000e2 <libmain+0x2d>
		binaryname = argv[0];
  8000db:	8b 06                	mov    (%esi),%eax
  8000dd:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000e2:	83 ec 08             	sub    $0x8,%esp
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
  8000e7:	e8 a5 ff ff ff       	call   800091 <umain>

	// exit gracefully
	exit();
  8000ec:	e8 0a 00 00 00       	call   8000fb <exit>
}
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000f7:	5b                   	pop    %ebx
  8000f8:	5e                   	pop    %esi
  8000f9:	5d                   	pop    %ebp
  8000fa:	c3                   	ret    

008000fb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800101:	e8 d6 0e 00 00       	call   800fdc <close_all>
	sys_env_destroy(0);
  800106:	83 ec 0c             	sub    $0xc,%esp
  800109:	6a 00                	push   $0x0
  80010b:	e8 05 0a 00 00       	call   800b15 <sys_env_destroy>
}
  800110:	83 c4 10             	add    $0x10,%esp
  800113:	c9                   	leave  
  800114:	c3                   	ret    

00800115 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800115:	55                   	push   %ebp
  800116:	89 e5                	mov    %esp,%ebp
  800118:	56                   	push   %esi
  800119:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80011a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80011d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800123:	e8 2e 0a 00 00       	call   800b56 <sys_getenvid>
  800128:	83 ec 0c             	sub    $0xc,%esp
  80012b:	ff 75 0c             	pushl  0xc(%ebp)
  80012e:	ff 75 08             	pushl  0x8(%ebp)
  800131:	56                   	push   %esi
  800132:	50                   	push   %eax
  800133:	68 38 1f 80 00       	push   $0x801f38
  800138:	e8 b1 00 00 00       	call   8001ee <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80013d:	83 c4 18             	add    $0x18,%esp
  800140:	53                   	push   %ebx
  800141:	ff 75 10             	pushl  0x10(%ebp)
  800144:	e8 54 00 00 00       	call   80019d <vcprintf>
	cprintf("\n");
  800149:	c7 04 24 9f 23 80 00 	movl   $0x80239f,(%esp)
  800150:	e8 99 00 00 00       	call   8001ee <cprintf>
  800155:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800158:	cc                   	int3   
  800159:	eb fd                	jmp    800158 <_panic+0x43>

0080015b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	53                   	push   %ebx
  80015f:	83 ec 04             	sub    $0x4,%esp
  800162:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800165:	8b 13                	mov    (%ebx),%edx
  800167:	8d 42 01             	lea    0x1(%edx),%eax
  80016a:	89 03                	mov    %eax,(%ebx)
  80016c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80016f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800173:	3d ff 00 00 00       	cmp    $0xff,%eax
  800178:	75 1a                	jne    800194 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80017a:	83 ec 08             	sub    $0x8,%esp
  80017d:	68 ff 00 00 00       	push   $0xff
  800182:	8d 43 08             	lea    0x8(%ebx),%eax
  800185:	50                   	push   %eax
  800186:	e8 4d 09 00 00       	call   800ad8 <sys_cputs>
		b->idx = 0;
  80018b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800191:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800194:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800198:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80019b:	c9                   	leave  
  80019c:	c3                   	ret    

0080019d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80019d:	55                   	push   %ebp
  80019e:	89 e5                	mov    %esp,%ebp
  8001a0:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001a6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ad:	00 00 00 
	b.cnt = 0;
  8001b0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001b7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001ba:	ff 75 0c             	pushl  0xc(%ebp)
  8001bd:	ff 75 08             	pushl  0x8(%ebp)
  8001c0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001c6:	50                   	push   %eax
  8001c7:	68 5b 01 80 00       	push   $0x80015b
  8001cc:	e8 54 01 00 00       	call   800325 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001d1:	83 c4 08             	add    $0x8,%esp
  8001d4:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001da:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e0:	50                   	push   %eax
  8001e1:	e8 f2 08 00 00       	call   800ad8 <sys_cputs>

	return b.cnt;
}
  8001e6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ec:	c9                   	leave  
  8001ed:	c3                   	ret    

008001ee <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001ee:	55                   	push   %ebp
  8001ef:	89 e5                	mov    %esp,%ebp
  8001f1:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001f4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001f7:	50                   	push   %eax
  8001f8:	ff 75 08             	pushl  0x8(%ebp)
  8001fb:	e8 9d ff ff ff       	call   80019d <vcprintf>
	va_end(ap);

	return cnt;
}
  800200:	c9                   	leave  
  800201:	c3                   	ret    

00800202 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800202:	55                   	push   %ebp
  800203:	89 e5                	mov    %esp,%ebp
  800205:	57                   	push   %edi
  800206:	56                   	push   %esi
  800207:	53                   	push   %ebx
  800208:	83 ec 1c             	sub    $0x1c,%esp
  80020b:	89 c7                	mov    %eax,%edi
  80020d:	89 d6                	mov    %edx,%esi
  80020f:	8b 45 08             	mov    0x8(%ebp),%eax
  800212:	8b 55 0c             	mov    0xc(%ebp),%edx
  800215:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800218:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80021b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80021e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800223:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800226:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800229:	39 d3                	cmp    %edx,%ebx
  80022b:	72 05                	jb     800232 <printnum+0x30>
  80022d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800230:	77 45                	ja     800277 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800232:	83 ec 0c             	sub    $0xc,%esp
  800235:	ff 75 18             	pushl  0x18(%ebp)
  800238:	8b 45 14             	mov    0x14(%ebp),%eax
  80023b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80023e:	53                   	push   %ebx
  80023f:	ff 75 10             	pushl  0x10(%ebp)
  800242:	83 ec 08             	sub    $0x8,%esp
  800245:	ff 75 e4             	pushl  -0x1c(%ebp)
  800248:	ff 75 e0             	pushl  -0x20(%ebp)
  80024b:	ff 75 dc             	pushl  -0x24(%ebp)
  80024e:	ff 75 d8             	pushl  -0x28(%ebp)
  800251:	e8 ca 19 00 00       	call   801c20 <__udivdi3>
  800256:	83 c4 18             	add    $0x18,%esp
  800259:	52                   	push   %edx
  80025a:	50                   	push   %eax
  80025b:	89 f2                	mov    %esi,%edx
  80025d:	89 f8                	mov    %edi,%eax
  80025f:	e8 9e ff ff ff       	call   800202 <printnum>
  800264:	83 c4 20             	add    $0x20,%esp
  800267:	eb 18                	jmp    800281 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800269:	83 ec 08             	sub    $0x8,%esp
  80026c:	56                   	push   %esi
  80026d:	ff 75 18             	pushl  0x18(%ebp)
  800270:	ff d7                	call   *%edi
  800272:	83 c4 10             	add    $0x10,%esp
  800275:	eb 03                	jmp    80027a <printnum+0x78>
  800277:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80027a:	83 eb 01             	sub    $0x1,%ebx
  80027d:	85 db                	test   %ebx,%ebx
  80027f:	7f e8                	jg     800269 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800281:	83 ec 08             	sub    $0x8,%esp
  800284:	56                   	push   %esi
  800285:	83 ec 04             	sub    $0x4,%esp
  800288:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028b:	ff 75 e0             	pushl  -0x20(%ebp)
  80028e:	ff 75 dc             	pushl  -0x24(%ebp)
  800291:	ff 75 d8             	pushl  -0x28(%ebp)
  800294:	e8 b7 1a 00 00       	call   801d50 <__umoddi3>
  800299:	83 c4 14             	add    $0x14,%esp
  80029c:	0f be 80 5b 1f 80 00 	movsbl 0x801f5b(%eax),%eax
  8002a3:	50                   	push   %eax
  8002a4:	ff d7                	call   *%edi
}
  8002a6:	83 c4 10             	add    $0x10,%esp
  8002a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ac:	5b                   	pop    %ebx
  8002ad:	5e                   	pop    %esi
  8002ae:	5f                   	pop    %edi
  8002af:	5d                   	pop    %ebp
  8002b0:	c3                   	ret    

008002b1 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002b4:	83 fa 01             	cmp    $0x1,%edx
  8002b7:	7e 0e                	jle    8002c7 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002b9:	8b 10                	mov    (%eax),%edx
  8002bb:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002be:	89 08                	mov    %ecx,(%eax)
  8002c0:	8b 02                	mov    (%edx),%eax
  8002c2:	8b 52 04             	mov    0x4(%edx),%edx
  8002c5:	eb 22                	jmp    8002e9 <getuint+0x38>
	else if (lflag)
  8002c7:	85 d2                	test   %edx,%edx
  8002c9:	74 10                	je     8002db <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002cb:	8b 10                	mov    (%eax),%edx
  8002cd:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d0:	89 08                	mov    %ecx,(%eax)
  8002d2:	8b 02                	mov    (%edx),%eax
  8002d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d9:	eb 0e                	jmp    8002e9 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002db:	8b 10                	mov    (%eax),%edx
  8002dd:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e0:	89 08                	mov    %ecx,(%eax)
  8002e2:	8b 02                	mov    (%edx),%eax
  8002e4:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002e9:	5d                   	pop    %ebp
  8002ea:	c3                   	ret    

008002eb <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002eb:	55                   	push   %ebp
  8002ec:	89 e5                	mov    %esp,%ebp
  8002ee:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002f1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002f5:	8b 10                	mov    (%eax),%edx
  8002f7:	3b 50 04             	cmp    0x4(%eax),%edx
  8002fa:	73 0a                	jae    800306 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002fc:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002ff:	89 08                	mov    %ecx,(%eax)
  800301:	8b 45 08             	mov    0x8(%ebp),%eax
  800304:	88 02                	mov    %al,(%edx)
}
  800306:	5d                   	pop    %ebp
  800307:	c3                   	ret    

00800308 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800308:	55                   	push   %ebp
  800309:	89 e5                	mov    %esp,%ebp
  80030b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80030e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800311:	50                   	push   %eax
  800312:	ff 75 10             	pushl  0x10(%ebp)
  800315:	ff 75 0c             	pushl  0xc(%ebp)
  800318:	ff 75 08             	pushl  0x8(%ebp)
  80031b:	e8 05 00 00 00       	call   800325 <vprintfmt>
	va_end(ap);
}
  800320:	83 c4 10             	add    $0x10,%esp
  800323:	c9                   	leave  
  800324:	c3                   	ret    

00800325 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800325:	55                   	push   %ebp
  800326:	89 e5                	mov    %esp,%ebp
  800328:	57                   	push   %edi
  800329:	56                   	push   %esi
  80032a:	53                   	push   %ebx
  80032b:	83 ec 2c             	sub    $0x2c,%esp
  80032e:	8b 75 08             	mov    0x8(%ebp),%esi
  800331:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800334:	8b 7d 10             	mov    0x10(%ebp),%edi
  800337:	eb 12                	jmp    80034b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800339:	85 c0                	test   %eax,%eax
  80033b:	0f 84 a7 03 00 00    	je     8006e8 <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
  800341:	83 ec 08             	sub    $0x8,%esp
  800344:	53                   	push   %ebx
  800345:	50                   	push   %eax
  800346:	ff d6                	call   *%esi
  800348:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80034b:	83 c7 01             	add    $0x1,%edi
  80034e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800352:	83 f8 25             	cmp    $0x25,%eax
  800355:	75 e2                	jne    800339 <vprintfmt+0x14>
  800357:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80035b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800362:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800369:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800370:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800377:	b9 00 00 00 00       	mov    $0x0,%ecx
  80037c:	eb 07                	jmp    800385 <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800381:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800385:	8d 47 01             	lea    0x1(%edi),%eax
  800388:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80038b:	0f b6 07             	movzbl (%edi),%eax
  80038e:	0f b6 d0             	movzbl %al,%edx
  800391:	83 e8 23             	sub    $0x23,%eax
  800394:	3c 55                	cmp    $0x55,%al
  800396:	0f 87 31 03 00 00    	ja     8006cd <vprintfmt+0x3a8>
  80039c:	0f b6 c0             	movzbl %al,%eax
  80039f:	ff 24 85 a0 20 80 00 	jmp    *0x8020a0(,%eax,4)
  8003a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003a9:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003ad:	eb d6                	jmp    800385 <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b7:	89 75 08             	mov    %esi,0x8(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003ba:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003bd:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003c1:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003c4:	8d 72 d0             	lea    -0x30(%edx),%esi
  8003c7:	83 fe 09             	cmp    $0x9,%esi
  8003ca:	77 34                	ja     800400 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003cc:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003cf:	eb e9                	jmp    8003ba <vprintfmt+0x95>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d4:	8d 50 04             	lea    0x4(%eax),%edx
  8003d7:	89 55 14             	mov    %edx,0x14(%ebp)
  8003da:	8b 00                	mov    (%eax),%eax
  8003dc:	89 45 cc             	mov    %eax,-0x34(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003e2:	eb 22                	jmp    800406 <vprintfmt+0xe1>
  8003e4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003e7:	85 c0                	test   %eax,%eax
  8003e9:	0f 48 c1             	cmovs  %ecx,%eax
  8003ec:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f2:	eb 91                	jmp    800385 <vprintfmt+0x60>
  8003f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003f7:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003fe:	eb 85                	jmp    800385 <vprintfmt+0x60>
  800400:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800403:	8b 75 08             	mov    0x8(%ebp),%esi

		process_precision:
			if (width < 0)
  800406:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80040a:	0f 89 75 ff ff ff    	jns    800385 <vprintfmt+0x60>
				width = precision, precision = -1;
  800410:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800413:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800416:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80041d:	e9 63 ff ff ff       	jmp    800385 <vprintfmt+0x60>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800422:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800426:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800429:	e9 57 ff ff ff       	jmp    800385 <vprintfmt+0x60>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80042e:	8b 45 14             	mov    0x14(%ebp),%eax
  800431:	8d 50 04             	lea    0x4(%eax),%edx
  800434:	89 55 14             	mov    %edx,0x14(%ebp)
  800437:	83 ec 08             	sub    $0x8,%esp
  80043a:	53                   	push   %ebx
  80043b:	ff 30                	pushl  (%eax)
  80043d:	ff d6                	call   *%esi
			break;
  80043f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800442:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800445:	e9 01 ff ff ff       	jmp    80034b <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80044a:	8b 45 14             	mov    0x14(%ebp),%eax
  80044d:	8d 50 04             	lea    0x4(%eax),%edx
  800450:	89 55 14             	mov    %edx,0x14(%ebp)
  800453:	8b 00                	mov    (%eax),%eax
  800455:	99                   	cltd   
  800456:	31 d0                	xor    %edx,%eax
  800458:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80045a:	83 f8 0f             	cmp    $0xf,%eax
  80045d:	7f 0b                	jg     80046a <vprintfmt+0x145>
  80045f:	8b 14 85 00 22 80 00 	mov    0x802200(,%eax,4),%edx
  800466:	85 d2                	test   %edx,%edx
  800468:	75 18                	jne    800482 <vprintfmt+0x15d>
				printfmt(putch, putdat, "error %d", err);
  80046a:	50                   	push   %eax
  80046b:	68 73 1f 80 00       	push   $0x801f73
  800470:	53                   	push   %ebx
  800471:	56                   	push   %esi
  800472:	e8 91 fe ff ff       	call   800308 <printfmt>
  800477:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80047d:	e9 c9 fe ff ff       	jmp    80034b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800482:	52                   	push   %edx
  800483:	68 6d 23 80 00       	push   $0x80236d
  800488:	53                   	push   %ebx
  800489:	56                   	push   %esi
  80048a:	e8 79 fe ff ff       	call   800308 <printfmt>
  80048f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800492:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800495:	e9 b1 fe ff ff       	jmp    80034b <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80049a:	8b 45 14             	mov    0x14(%ebp),%eax
  80049d:	8d 50 04             	lea    0x4(%eax),%edx
  8004a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a3:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004a5:	85 ff                	test   %edi,%edi
  8004a7:	b8 6c 1f 80 00       	mov    $0x801f6c,%eax
  8004ac:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004af:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004b3:	0f 8e 94 00 00 00    	jle    80054d <vprintfmt+0x228>
  8004b9:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004bd:	0f 84 98 00 00 00    	je     80055b <vprintfmt+0x236>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c3:	83 ec 08             	sub    $0x8,%esp
  8004c6:	ff 75 cc             	pushl  -0x34(%ebp)
  8004c9:	57                   	push   %edi
  8004ca:	e8 a1 02 00 00       	call   800770 <strnlen>
  8004cf:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004d2:	29 c1                	sub    %eax,%ecx
  8004d4:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8004d7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004da:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004de:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004e1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004e4:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e6:	eb 0f                	jmp    8004f7 <vprintfmt+0x1d2>
					putch(padc, putdat);
  8004e8:	83 ec 08             	sub    $0x8,%esp
  8004eb:	53                   	push   %ebx
  8004ec:	ff 75 e0             	pushl  -0x20(%ebp)
  8004ef:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f1:	83 ef 01             	sub    $0x1,%edi
  8004f4:	83 c4 10             	add    $0x10,%esp
  8004f7:	85 ff                	test   %edi,%edi
  8004f9:	7f ed                	jg     8004e8 <vprintfmt+0x1c3>
  8004fb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004fe:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800501:	85 c9                	test   %ecx,%ecx
  800503:	b8 00 00 00 00       	mov    $0x0,%eax
  800508:	0f 49 c1             	cmovns %ecx,%eax
  80050b:	29 c1                	sub    %eax,%ecx
  80050d:	89 75 08             	mov    %esi,0x8(%ebp)
  800510:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800513:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800516:	89 cb                	mov    %ecx,%ebx
  800518:	eb 4d                	jmp    800567 <vprintfmt+0x242>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80051a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80051e:	74 1b                	je     80053b <vprintfmt+0x216>
  800520:	0f be c0             	movsbl %al,%eax
  800523:	83 e8 20             	sub    $0x20,%eax
  800526:	83 f8 5e             	cmp    $0x5e,%eax
  800529:	76 10                	jbe    80053b <vprintfmt+0x216>
					putch('?', putdat);
  80052b:	83 ec 08             	sub    $0x8,%esp
  80052e:	ff 75 0c             	pushl  0xc(%ebp)
  800531:	6a 3f                	push   $0x3f
  800533:	ff 55 08             	call   *0x8(%ebp)
  800536:	83 c4 10             	add    $0x10,%esp
  800539:	eb 0d                	jmp    800548 <vprintfmt+0x223>
				else
					putch(ch, putdat);
  80053b:	83 ec 08             	sub    $0x8,%esp
  80053e:	ff 75 0c             	pushl  0xc(%ebp)
  800541:	52                   	push   %edx
  800542:	ff 55 08             	call   *0x8(%ebp)
  800545:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800548:	83 eb 01             	sub    $0x1,%ebx
  80054b:	eb 1a                	jmp    800567 <vprintfmt+0x242>
  80054d:	89 75 08             	mov    %esi,0x8(%ebp)
  800550:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800553:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800556:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800559:	eb 0c                	jmp    800567 <vprintfmt+0x242>
  80055b:	89 75 08             	mov    %esi,0x8(%ebp)
  80055e:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800561:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800564:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800567:	83 c7 01             	add    $0x1,%edi
  80056a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80056e:	0f be d0             	movsbl %al,%edx
  800571:	85 d2                	test   %edx,%edx
  800573:	74 23                	je     800598 <vprintfmt+0x273>
  800575:	85 f6                	test   %esi,%esi
  800577:	78 a1                	js     80051a <vprintfmt+0x1f5>
  800579:	83 ee 01             	sub    $0x1,%esi
  80057c:	79 9c                	jns    80051a <vprintfmt+0x1f5>
  80057e:	89 df                	mov    %ebx,%edi
  800580:	8b 75 08             	mov    0x8(%ebp),%esi
  800583:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800586:	eb 18                	jmp    8005a0 <vprintfmt+0x27b>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800588:	83 ec 08             	sub    $0x8,%esp
  80058b:	53                   	push   %ebx
  80058c:	6a 20                	push   $0x20
  80058e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800590:	83 ef 01             	sub    $0x1,%edi
  800593:	83 c4 10             	add    $0x10,%esp
  800596:	eb 08                	jmp    8005a0 <vprintfmt+0x27b>
  800598:	89 df                	mov    %ebx,%edi
  80059a:	8b 75 08             	mov    0x8(%ebp),%esi
  80059d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005a0:	85 ff                	test   %edi,%edi
  8005a2:	7f e4                	jg     800588 <vprintfmt+0x263>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a7:	e9 9f fd ff ff       	jmp    80034b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ac:	83 7d d0 01          	cmpl   $0x1,-0x30(%ebp)
  8005b0:	7e 16                	jle    8005c8 <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  8005b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b5:	8d 50 08             	lea    0x8(%eax),%edx
  8005b8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005bb:	8b 50 04             	mov    0x4(%eax),%edx
  8005be:	8b 00                	mov    (%eax),%eax
  8005c0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005c6:	eb 34                	jmp    8005fc <vprintfmt+0x2d7>
	else if (lflag)
  8005c8:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8005cc:	74 18                	je     8005e6 <vprintfmt+0x2c1>
		return va_arg(*ap, long);
  8005ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d1:	8d 50 04             	lea    0x4(%eax),%edx
  8005d4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d7:	8b 00                	mov    (%eax),%eax
  8005d9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005dc:	89 c1                	mov    %eax,%ecx
  8005de:	c1 f9 1f             	sar    $0x1f,%ecx
  8005e1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005e4:	eb 16                	jmp    8005fc <vprintfmt+0x2d7>
	else
		return va_arg(*ap, int);
  8005e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e9:	8d 50 04             	lea    0x4(%eax),%edx
  8005ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ef:	8b 00                	mov    (%eax),%eax
  8005f1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f4:	89 c1                	mov    %eax,%ecx
  8005f6:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005fc:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005ff:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800602:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800607:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80060b:	0f 89 88 00 00 00    	jns    800699 <vprintfmt+0x374>
				putch('-', putdat);
  800611:	83 ec 08             	sub    $0x8,%esp
  800614:	53                   	push   %ebx
  800615:	6a 2d                	push   $0x2d
  800617:	ff d6                	call   *%esi
				num = -(long long) num;
  800619:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80061c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80061f:	f7 d8                	neg    %eax
  800621:	83 d2 00             	adc    $0x0,%edx
  800624:	f7 da                	neg    %edx
  800626:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800629:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80062e:	eb 69                	jmp    800699 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800630:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800633:	8d 45 14             	lea    0x14(%ebp),%eax
  800636:	e8 76 fc ff ff       	call   8002b1 <getuint>
			base = 10;
  80063b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800640:	eb 57                	jmp    800699 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  800642:	83 ec 08             	sub    $0x8,%esp
  800645:	53                   	push   %ebx
  800646:	6a 30                	push   $0x30
  800648:	ff d6                	call   *%esi
			num = getuint(&ap, lflag);
  80064a:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80064d:	8d 45 14             	lea    0x14(%ebp),%eax
  800650:	e8 5c fc ff ff       	call   8002b1 <getuint>
			base = 8;
			goto number;
  800655:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800658:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80065d:	eb 3a                	jmp    800699 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  80065f:	83 ec 08             	sub    $0x8,%esp
  800662:	53                   	push   %ebx
  800663:	6a 30                	push   $0x30
  800665:	ff d6                	call   *%esi
			putch('x', putdat);
  800667:	83 c4 08             	add    $0x8,%esp
  80066a:	53                   	push   %ebx
  80066b:	6a 78                	push   $0x78
  80066d:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80066f:	8b 45 14             	mov    0x14(%ebp),%eax
  800672:	8d 50 04             	lea    0x4(%eax),%edx
  800675:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800678:	8b 00                	mov    (%eax),%eax
  80067a:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80067f:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800682:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800687:	eb 10                	jmp    800699 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800689:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80068c:	8d 45 14             	lea    0x14(%ebp),%eax
  80068f:	e8 1d fc ff ff       	call   8002b1 <getuint>
			base = 16;
  800694:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800699:	83 ec 0c             	sub    $0xc,%esp
  80069c:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006a0:	57                   	push   %edi
  8006a1:	ff 75 e0             	pushl  -0x20(%ebp)
  8006a4:	51                   	push   %ecx
  8006a5:	52                   	push   %edx
  8006a6:	50                   	push   %eax
  8006a7:	89 da                	mov    %ebx,%edx
  8006a9:	89 f0                	mov    %esi,%eax
  8006ab:	e8 52 fb ff ff       	call   800202 <printnum>
			break;
  8006b0:	83 c4 20             	add    $0x20,%esp
  8006b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006b6:	e9 90 fc ff ff       	jmp    80034b <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006bb:	83 ec 08             	sub    $0x8,%esp
  8006be:	53                   	push   %ebx
  8006bf:	52                   	push   %edx
  8006c0:	ff d6                	call   *%esi
			break;
  8006c2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006c8:	e9 7e fc ff ff       	jmp    80034b <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006cd:	83 ec 08             	sub    $0x8,%esp
  8006d0:	53                   	push   %ebx
  8006d1:	6a 25                	push   $0x25
  8006d3:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006d5:	83 c4 10             	add    $0x10,%esp
  8006d8:	eb 03                	jmp    8006dd <vprintfmt+0x3b8>
  8006da:	83 ef 01             	sub    $0x1,%edi
  8006dd:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006e1:	75 f7                	jne    8006da <vprintfmt+0x3b5>
  8006e3:	e9 63 fc ff ff       	jmp    80034b <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006eb:	5b                   	pop    %ebx
  8006ec:	5e                   	pop    %esi
  8006ed:	5f                   	pop    %edi
  8006ee:	5d                   	pop    %ebp
  8006ef:	c3                   	ret    

008006f0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006f0:	55                   	push   %ebp
  8006f1:	89 e5                	mov    %esp,%ebp
  8006f3:	83 ec 18             	sub    $0x18,%esp
  8006f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006fc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006ff:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800703:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800706:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80070d:	85 c0                	test   %eax,%eax
  80070f:	74 26                	je     800737 <vsnprintf+0x47>
  800711:	85 d2                	test   %edx,%edx
  800713:	7e 22                	jle    800737 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800715:	ff 75 14             	pushl  0x14(%ebp)
  800718:	ff 75 10             	pushl  0x10(%ebp)
  80071b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80071e:	50                   	push   %eax
  80071f:	68 eb 02 80 00       	push   $0x8002eb
  800724:	e8 fc fb ff ff       	call   800325 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800729:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80072c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80072f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800732:	83 c4 10             	add    $0x10,%esp
  800735:	eb 05                	jmp    80073c <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800737:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80073c:	c9                   	leave  
  80073d:	c3                   	ret    

0080073e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80073e:	55                   	push   %ebp
  80073f:	89 e5                	mov    %esp,%ebp
  800741:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800744:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800747:	50                   	push   %eax
  800748:	ff 75 10             	pushl  0x10(%ebp)
  80074b:	ff 75 0c             	pushl  0xc(%ebp)
  80074e:	ff 75 08             	pushl  0x8(%ebp)
  800751:	e8 9a ff ff ff       	call   8006f0 <vsnprintf>
	va_end(ap);

	return rc;
}
  800756:	c9                   	leave  
  800757:	c3                   	ret    

00800758 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800758:	55                   	push   %ebp
  800759:	89 e5                	mov    %esp,%ebp
  80075b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80075e:	b8 00 00 00 00       	mov    $0x0,%eax
  800763:	eb 03                	jmp    800768 <strlen+0x10>
		n++;
  800765:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800768:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80076c:	75 f7                	jne    800765 <strlen+0xd>
		n++;
	return n;
}
  80076e:	5d                   	pop    %ebp
  80076f:	c3                   	ret    

00800770 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800770:	55                   	push   %ebp
  800771:	89 e5                	mov    %esp,%ebp
  800773:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800776:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800779:	ba 00 00 00 00       	mov    $0x0,%edx
  80077e:	eb 03                	jmp    800783 <strnlen+0x13>
		n++;
  800780:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800783:	39 c2                	cmp    %eax,%edx
  800785:	74 08                	je     80078f <strnlen+0x1f>
  800787:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80078b:	75 f3                	jne    800780 <strnlen+0x10>
  80078d:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80078f:	5d                   	pop    %ebp
  800790:	c3                   	ret    

00800791 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800791:	55                   	push   %ebp
  800792:	89 e5                	mov    %esp,%ebp
  800794:	53                   	push   %ebx
  800795:	8b 45 08             	mov    0x8(%ebp),%eax
  800798:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80079b:	89 c2                	mov    %eax,%edx
  80079d:	83 c2 01             	add    $0x1,%edx
  8007a0:	83 c1 01             	add    $0x1,%ecx
  8007a3:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007a7:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007aa:	84 db                	test   %bl,%bl
  8007ac:	75 ef                	jne    80079d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007ae:	5b                   	pop    %ebx
  8007af:	5d                   	pop    %ebp
  8007b0:	c3                   	ret    

008007b1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007b1:	55                   	push   %ebp
  8007b2:	89 e5                	mov    %esp,%ebp
  8007b4:	53                   	push   %ebx
  8007b5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007b8:	53                   	push   %ebx
  8007b9:	e8 9a ff ff ff       	call   800758 <strlen>
  8007be:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007c1:	ff 75 0c             	pushl  0xc(%ebp)
  8007c4:	01 d8                	add    %ebx,%eax
  8007c6:	50                   	push   %eax
  8007c7:	e8 c5 ff ff ff       	call   800791 <strcpy>
	return dst;
}
  8007cc:	89 d8                	mov    %ebx,%eax
  8007ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d1:	c9                   	leave  
  8007d2:	c3                   	ret    

008007d3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007d3:	55                   	push   %ebp
  8007d4:	89 e5                	mov    %esp,%ebp
  8007d6:	56                   	push   %esi
  8007d7:	53                   	push   %ebx
  8007d8:	8b 75 08             	mov    0x8(%ebp),%esi
  8007db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007de:	89 f3                	mov    %esi,%ebx
  8007e0:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e3:	89 f2                	mov    %esi,%edx
  8007e5:	eb 0f                	jmp    8007f6 <strncpy+0x23>
		*dst++ = *src;
  8007e7:	83 c2 01             	add    $0x1,%edx
  8007ea:	0f b6 01             	movzbl (%ecx),%eax
  8007ed:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007f0:	80 39 01             	cmpb   $0x1,(%ecx)
  8007f3:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007f6:	39 da                	cmp    %ebx,%edx
  8007f8:	75 ed                	jne    8007e7 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007fa:	89 f0                	mov    %esi,%eax
  8007fc:	5b                   	pop    %ebx
  8007fd:	5e                   	pop    %esi
  8007fe:	5d                   	pop    %ebp
  8007ff:	c3                   	ret    

00800800 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	56                   	push   %esi
  800804:	53                   	push   %ebx
  800805:	8b 75 08             	mov    0x8(%ebp),%esi
  800808:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80080b:	8b 55 10             	mov    0x10(%ebp),%edx
  80080e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800810:	85 d2                	test   %edx,%edx
  800812:	74 21                	je     800835 <strlcpy+0x35>
  800814:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800818:	89 f2                	mov    %esi,%edx
  80081a:	eb 09                	jmp    800825 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80081c:	83 c2 01             	add    $0x1,%edx
  80081f:	83 c1 01             	add    $0x1,%ecx
  800822:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800825:	39 c2                	cmp    %eax,%edx
  800827:	74 09                	je     800832 <strlcpy+0x32>
  800829:	0f b6 19             	movzbl (%ecx),%ebx
  80082c:	84 db                	test   %bl,%bl
  80082e:	75 ec                	jne    80081c <strlcpy+0x1c>
  800830:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800832:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800835:	29 f0                	sub    %esi,%eax
}
  800837:	5b                   	pop    %ebx
  800838:	5e                   	pop    %esi
  800839:	5d                   	pop    %ebp
  80083a:	c3                   	ret    

0080083b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80083b:	55                   	push   %ebp
  80083c:	89 e5                	mov    %esp,%ebp
  80083e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800841:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800844:	eb 06                	jmp    80084c <strcmp+0x11>
		p++, q++;
  800846:	83 c1 01             	add    $0x1,%ecx
  800849:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80084c:	0f b6 01             	movzbl (%ecx),%eax
  80084f:	84 c0                	test   %al,%al
  800851:	74 04                	je     800857 <strcmp+0x1c>
  800853:	3a 02                	cmp    (%edx),%al
  800855:	74 ef                	je     800846 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800857:	0f b6 c0             	movzbl %al,%eax
  80085a:	0f b6 12             	movzbl (%edx),%edx
  80085d:	29 d0                	sub    %edx,%eax
}
  80085f:	5d                   	pop    %ebp
  800860:	c3                   	ret    

00800861 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800861:	55                   	push   %ebp
  800862:	89 e5                	mov    %esp,%ebp
  800864:	53                   	push   %ebx
  800865:	8b 45 08             	mov    0x8(%ebp),%eax
  800868:	8b 55 0c             	mov    0xc(%ebp),%edx
  80086b:	89 c3                	mov    %eax,%ebx
  80086d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800870:	eb 06                	jmp    800878 <strncmp+0x17>
		n--, p++, q++;
  800872:	83 c0 01             	add    $0x1,%eax
  800875:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800878:	39 d8                	cmp    %ebx,%eax
  80087a:	74 15                	je     800891 <strncmp+0x30>
  80087c:	0f b6 08             	movzbl (%eax),%ecx
  80087f:	84 c9                	test   %cl,%cl
  800881:	74 04                	je     800887 <strncmp+0x26>
  800883:	3a 0a                	cmp    (%edx),%cl
  800885:	74 eb                	je     800872 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800887:	0f b6 00             	movzbl (%eax),%eax
  80088a:	0f b6 12             	movzbl (%edx),%edx
  80088d:	29 d0                	sub    %edx,%eax
  80088f:	eb 05                	jmp    800896 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800891:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800896:	5b                   	pop    %ebx
  800897:	5d                   	pop    %ebp
  800898:	c3                   	ret    

00800899 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800899:	55                   	push   %ebp
  80089a:	89 e5                	mov    %esp,%ebp
  80089c:	8b 45 08             	mov    0x8(%ebp),%eax
  80089f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a3:	eb 07                	jmp    8008ac <strchr+0x13>
		if (*s == c)
  8008a5:	38 ca                	cmp    %cl,%dl
  8008a7:	74 0f                	je     8008b8 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008a9:	83 c0 01             	add    $0x1,%eax
  8008ac:	0f b6 10             	movzbl (%eax),%edx
  8008af:	84 d2                	test   %dl,%dl
  8008b1:	75 f2                	jne    8008a5 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008b8:	5d                   	pop    %ebp
  8008b9:	c3                   	ret    

008008ba <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008ba:	55                   	push   %ebp
  8008bb:	89 e5                	mov    %esp,%ebp
  8008bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c4:	eb 03                	jmp    8008c9 <strfind+0xf>
  8008c6:	83 c0 01             	add    $0x1,%eax
  8008c9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008cc:	38 ca                	cmp    %cl,%dl
  8008ce:	74 04                	je     8008d4 <strfind+0x1a>
  8008d0:	84 d2                	test   %dl,%dl
  8008d2:	75 f2                	jne    8008c6 <strfind+0xc>
			break;
	return (char *) s;
}
  8008d4:	5d                   	pop    %ebp
  8008d5:	c3                   	ret    

008008d6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008d6:	55                   	push   %ebp
  8008d7:	89 e5                	mov    %esp,%ebp
  8008d9:	57                   	push   %edi
  8008da:	56                   	push   %esi
  8008db:	53                   	push   %ebx
  8008dc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008df:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008e2:	85 c9                	test   %ecx,%ecx
  8008e4:	74 36                	je     80091c <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008e6:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008ec:	75 28                	jne    800916 <memset+0x40>
  8008ee:	f6 c1 03             	test   $0x3,%cl
  8008f1:	75 23                	jne    800916 <memset+0x40>
		c &= 0xFF;
  8008f3:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008f7:	89 d3                	mov    %edx,%ebx
  8008f9:	c1 e3 08             	shl    $0x8,%ebx
  8008fc:	89 d6                	mov    %edx,%esi
  8008fe:	c1 e6 18             	shl    $0x18,%esi
  800901:	89 d0                	mov    %edx,%eax
  800903:	c1 e0 10             	shl    $0x10,%eax
  800906:	09 f0                	or     %esi,%eax
  800908:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80090a:	89 d8                	mov    %ebx,%eax
  80090c:	09 d0                	or     %edx,%eax
  80090e:	c1 e9 02             	shr    $0x2,%ecx
  800911:	fc                   	cld    
  800912:	f3 ab                	rep stos %eax,%es:(%edi)
  800914:	eb 06                	jmp    80091c <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800916:	8b 45 0c             	mov    0xc(%ebp),%eax
  800919:	fc                   	cld    
  80091a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80091c:	89 f8                	mov    %edi,%eax
  80091e:	5b                   	pop    %ebx
  80091f:	5e                   	pop    %esi
  800920:	5f                   	pop    %edi
  800921:	5d                   	pop    %ebp
  800922:	c3                   	ret    

00800923 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800923:	55                   	push   %ebp
  800924:	89 e5                	mov    %esp,%ebp
  800926:	57                   	push   %edi
  800927:	56                   	push   %esi
  800928:	8b 45 08             	mov    0x8(%ebp),%eax
  80092b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80092e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800931:	39 c6                	cmp    %eax,%esi
  800933:	73 35                	jae    80096a <memmove+0x47>
  800935:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800938:	39 d0                	cmp    %edx,%eax
  80093a:	73 2e                	jae    80096a <memmove+0x47>
		s += n;
		d += n;
  80093c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80093f:	89 d6                	mov    %edx,%esi
  800941:	09 fe                	or     %edi,%esi
  800943:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800949:	75 13                	jne    80095e <memmove+0x3b>
  80094b:	f6 c1 03             	test   $0x3,%cl
  80094e:	75 0e                	jne    80095e <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800950:	83 ef 04             	sub    $0x4,%edi
  800953:	8d 72 fc             	lea    -0x4(%edx),%esi
  800956:	c1 e9 02             	shr    $0x2,%ecx
  800959:	fd                   	std    
  80095a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80095c:	eb 09                	jmp    800967 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80095e:	83 ef 01             	sub    $0x1,%edi
  800961:	8d 72 ff             	lea    -0x1(%edx),%esi
  800964:	fd                   	std    
  800965:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800967:	fc                   	cld    
  800968:	eb 1d                	jmp    800987 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80096a:	89 f2                	mov    %esi,%edx
  80096c:	09 c2                	or     %eax,%edx
  80096e:	f6 c2 03             	test   $0x3,%dl
  800971:	75 0f                	jne    800982 <memmove+0x5f>
  800973:	f6 c1 03             	test   $0x3,%cl
  800976:	75 0a                	jne    800982 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800978:	c1 e9 02             	shr    $0x2,%ecx
  80097b:	89 c7                	mov    %eax,%edi
  80097d:	fc                   	cld    
  80097e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800980:	eb 05                	jmp    800987 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800982:	89 c7                	mov    %eax,%edi
  800984:	fc                   	cld    
  800985:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800987:	5e                   	pop    %esi
  800988:	5f                   	pop    %edi
  800989:	5d                   	pop    %ebp
  80098a:	c3                   	ret    

0080098b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80098e:	ff 75 10             	pushl  0x10(%ebp)
  800991:	ff 75 0c             	pushl  0xc(%ebp)
  800994:	ff 75 08             	pushl  0x8(%ebp)
  800997:	e8 87 ff ff ff       	call   800923 <memmove>
}
  80099c:	c9                   	leave  
  80099d:	c3                   	ret    

0080099e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80099e:	55                   	push   %ebp
  80099f:	89 e5                	mov    %esp,%ebp
  8009a1:	56                   	push   %esi
  8009a2:	53                   	push   %ebx
  8009a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a9:	89 c6                	mov    %eax,%esi
  8009ab:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ae:	eb 1a                	jmp    8009ca <memcmp+0x2c>
		if (*s1 != *s2)
  8009b0:	0f b6 08             	movzbl (%eax),%ecx
  8009b3:	0f b6 1a             	movzbl (%edx),%ebx
  8009b6:	38 d9                	cmp    %bl,%cl
  8009b8:	74 0a                	je     8009c4 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009ba:	0f b6 c1             	movzbl %cl,%eax
  8009bd:	0f b6 db             	movzbl %bl,%ebx
  8009c0:	29 d8                	sub    %ebx,%eax
  8009c2:	eb 0f                	jmp    8009d3 <memcmp+0x35>
		s1++, s2++;
  8009c4:	83 c0 01             	add    $0x1,%eax
  8009c7:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ca:	39 f0                	cmp    %esi,%eax
  8009cc:	75 e2                	jne    8009b0 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009ce:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d3:	5b                   	pop    %ebx
  8009d4:	5e                   	pop    %esi
  8009d5:	5d                   	pop    %ebp
  8009d6:	c3                   	ret    

008009d7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009d7:	55                   	push   %ebp
  8009d8:	89 e5                	mov    %esp,%ebp
  8009da:	53                   	push   %ebx
  8009db:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009de:	89 c1                	mov    %eax,%ecx
  8009e0:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009e3:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009e7:	eb 0a                	jmp    8009f3 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009e9:	0f b6 10             	movzbl (%eax),%edx
  8009ec:	39 da                	cmp    %ebx,%edx
  8009ee:	74 07                	je     8009f7 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009f0:	83 c0 01             	add    $0x1,%eax
  8009f3:	39 c8                	cmp    %ecx,%eax
  8009f5:	72 f2                	jb     8009e9 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009f7:	5b                   	pop    %ebx
  8009f8:	5d                   	pop    %ebp
  8009f9:	c3                   	ret    

008009fa <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009fa:	55                   	push   %ebp
  8009fb:	89 e5                	mov    %esp,%ebp
  8009fd:	57                   	push   %edi
  8009fe:	56                   	push   %esi
  8009ff:	53                   	push   %ebx
  800a00:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a03:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a06:	eb 03                	jmp    800a0b <strtol+0x11>
		s++;
  800a08:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a0b:	0f b6 01             	movzbl (%ecx),%eax
  800a0e:	3c 20                	cmp    $0x20,%al
  800a10:	74 f6                	je     800a08 <strtol+0xe>
  800a12:	3c 09                	cmp    $0x9,%al
  800a14:	74 f2                	je     800a08 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a16:	3c 2b                	cmp    $0x2b,%al
  800a18:	75 0a                	jne    800a24 <strtol+0x2a>
		s++;
  800a1a:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a1d:	bf 00 00 00 00       	mov    $0x0,%edi
  800a22:	eb 11                	jmp    800a35 <strtol+0x3b>
  800a24:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a29:	3c 2d                	cmp    $0x2d,%al
  800a2b:	75 08                	jne    800a35 <strtol+0x3b>
		s++, neg = 1;
  800a2d:	83 c1 01             	add    $0x1,%ecx
  800a30:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a35:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a3b:	75 15                	jne    800a52 <strtol+0x58>
  800a3d:	80 39 30             	cmpb   $0x30,(%ecx)
  800a40:	75 10                	jne    800a52 <strtol+0x58>
  800a42:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a46:	75 7c                	jne    800ac4 <strtol+0xca>
		s += 2, base = 16;
  800a48:	83 c1 02             	add    $0x2,%ecx
  800a4b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a50:	eb 16                	jmp    800a68 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a52:	85 db                	test   %ebx,%ebx
  800a54:	75 12                	jne    800a68 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a56:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a5b:	80 39 30             	cmpb   $0x30,(%ecx)
  800a5e:	75 08                	jne    800a68 <strtol+0x6e>
		s++, base = 8;
  800a60:	83 c1 01             	add    $0x1,%ecx
  800a63:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a68:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6d:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a70:	0f b6 11             	movzbl (%ecx),%edx
  800a73:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a76:	89 f3                	mov    %esi,%ebx
  800a78:	80 fb 09             	cmp    $0x9,%bl
  800a7b:	77 08                	ja     800a85 <strtol+0x8b>
			dig = *s - '0';
  800a7d:	0f be d2             	movsbl %dl,%edx
  800a80:	83 ea 30             	sub    $0x30,%edx
  800a83:	eb 22                	jmp    800aa7 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a85:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a88:	89 f3                	mov    %esi,%ebx
  800a8a:	80 fb 19             	cmp    $0x19,%bl
  800a8d:	77 08                	ja     800a97 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a8f:	0f be d2             	movsbl %dl,%edx
  800a92:	83 ea 57             	sub    $0x57,%edx
  800a95:	eb 10                	jmp    800aa7 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a97:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a9a:	89 f3                	mov    %esi,%ebx
  800a9c:	80 fb 19             	cmp    $0x19,%bl
  800a9f:	77 16                	ja     800ab7 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800aa1:	0f be d2             	movsbl %dl,%edx
  800aa4:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800aa7:	3b 55 10             	cmp    0x10(%ebp),%edx
  800aaa:	7d 0b                	jge    800ab7 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800aac:	83 c1 01             	add    $0x1,%ecx
  800aaf:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ab3:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ab5:	eb b9                	jmp    800a70 <strtol+0x76>

	if (endptr)
  800ab7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800abb:	74 0d                	je     800aca <strtol+0xd0>
		*endptr = (char *) s;
  800abd:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac0:	89 0e                	mov    %ecx,(%esi)
  800ac2:	eb 06                	jmp    800aca <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ac4:	85 db                	test   %ebx,%ebx
  800ac6:	74 98                	je     800a60 <strtol+0x66>
  800ac8:	eb 9e                	jmp    800a68 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800aca:	89 c2                	mov    %eax,%edx
  800acc:	f7 da                	neg    %edx
  800ace:	85 ff                	test   %edi,%edi
  800ad0:	0f 45 c2             	cmovne %edx,%eax
}
  800ad3:	5b                   	pop    %ebx
  800ad4:	5e                   	pop    %esi
  800ad5:	5f                   	pop    %edi
  800ad6:	5d                   	pop    %ebp
  800ad7:	c3                   	ret    

00800ad8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ad8:	55                   	push   %ebp
  800ad9:	89 e5                	mov    %esp,%ebp
  800adb:	57                   	push   %edi
  800adc:	56                   	push   %esi
  800add:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ade:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ae6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae9:	89 c3                	mov    %eax,%ebx
  800aeb:	89 c7                	mov    %eax,%edi
  800aed:	89 c6                	mov    %eax,%esi
  800aef:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800af1:	5b                   	pop    %ebx
  800af2:	5e                   	pop    %esi
  800af3:	5f                   	pop    %edi
  800af4:	5d                   	pop    %ebp
  800af5:	c3                   	ret    

00800af6 <sys_cgetc>:

int
sys_cgetc(void)
{
  800af6:	55                   	push   %ebp
  800af7:	89 e5                	mov    %esp,%ebp
  800af9:	57                   	push   %edi
  800afa:	56                   	push   %esi
  800afb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800afc:	ba 00 00 00 00       	mov    $0x0,%edx
  800b01:	b8 01 00 00 00       	mov    $0x1,%eax
  800b06:	89 d1                	mov    %edx,%ecx
  800b08:	89 d3                	mov    %edx,%ebx
  800b0a:	89 d7                	mov    %edx,%edi
  800b0c:	89 d6                	mov    %edx,%esi
  800b0e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b10:	5b                   	pop    %ebx
  800b11:	5e                   	pop    %esi
  800b12:	5f                   	pop    %edi
  800b13:	5d                   	pop    %ebp
  800b14:	c3                   	ret    

00800b15 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b15:	55                   	push   %ebp
  800b16:	89 e5                	mov    %esp,%ebp
  800b18:	57                   	push   %edi
  800b19:	56                   	push   %esi
  800b1a:	53                   	push   %ebx
  800b1b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b23:	b8 03 00 00 00       	mov    $0x3,%eax
  800b28:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2b:	89 cb                	mov    %ecx,%ebx
  800b2d:	89 cf                	mov    %ecx,%edi
  800b2f:	89 ce                	mov    %ecx,%esi
  800b31:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b33:	85 c0                	test   %eax,%eax
  800b35:	7e 17                	jle    800b4e <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b37:	83 ec 0c             	sub    $0xc,%esp
  800b3a:	50                   	push   %eax
  800b3b:	6a 03                	push   $0x3
  800b3d:	68 5f 22 80 00       	push   $0x80225f
  800b42:	6a 23                	push   $0x23
  800b44:	68 7c 22 80 00       	push   $0x80227c
  800b49:	e8 c7 f5 ff ff       	call   800115 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b4e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b51:	5b                   	pop    %ebx
  800b52:	5e                   	pop    %esi
  800b53:	5f                   	pop    %edi
  800b54:	5d                   	pop    %ebp
  800b55:	c3                   	ret    

00800b56 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b56:	55                   	push   %ebp
  800b57:	89 e5                	mov    %esp,%ebp
  800b59:	57                   	push   %edi
  800b5a:	56                   	push   %esi
  800b5b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b61:	b8 02 00 00 00       	mov    $0x2,%eax
  800b66:	89 d1                	mov    %edx,%ecx
  800b68:	89 d3                	mov    %edx,%ebx
  800b6a:	89 d7                	mov    %edx,%edi
  800b6c:	89 d6                	mov    %edx,%esi
  800b6e:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b70:	5b                   	pop    %ebx
  800b71:	5e                   	pop    %esi
  800b72:	5f                   	pop    %edi
  800b73:	5d                   	pop    %ebp
  800b74:	c3                   	ret    

00800b75 <sys_yield>:

void
sys_yield(void)
{
  800b75:	55                   	push   %ebp
  800b76:	89 e5                	mov    %esp,%ebp
  800b78:	57                   	push   %edi
  800b79:	56                   	push   %esi
  800b7a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b80:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b85:	89 d1                	mov    %edx,%ecx
  800b87:	89 d3                	mov    %edx,%ebx
  800b89:	89 d7                	mov    %edx,%edi
  800b8b:	89 d6                	mov    %edx,%esi
  800b8d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b8f:	5b                   	pop    %ebx
  800b90:	5e                   	pop    %esi
  800b91:	5f                   	pop    %edi
  800b92:	5d                   	pop    %ebp
  800b93:	c3                   	ret    

00800b94 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b94:	55                   	push   %ebp
  800b95:	89 e5                	mov    %esp,%ebp
  800b97:	57                   	push   %edi
  800b98:	56                   	push   %esi
  800b99:	53                   	push   %ebx
  800b9a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9d:	be 00 00 00 00       	mov    $0x0,%esi
  800ba2:	b8 04 00 00 00       	mov    $0x4,%eax
  800ba7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800baa:	8b 55 08             	mov    0x8(%ebp),%edx
  800bad:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bb0:	89 f7                	mov    %esi,%edi
  800bb2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bb4:	85 c0                	test   %eax,%eax
  800bb6:	7e 17                	jle    800bcf <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb8:	83 ec 0c             	sub    $0xc,%esp
  800bbb:	50                   	push   %eax
  800bbc:	6a 04                	push   $0x4
  800bbe:	68 5f 22 80 00       	push   $0x80225f
  800bc3:	6a 23                	push   $0x23
  800bc5:	68 7c 22 80 00       	push   $0x80227c
  800bca:	e8 46 f5 ff ff       	call   800115 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bcf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd2:	5b                   	pop    %ebx
  800bd3:	5e                   	pop    %esi
  800bd4:	5f                   	pop    %edi
  800bd5:	5d                   	pop    %ebp
  800bd6:	c3                   	ret    

00800bd7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  800be0:	b8 05 00 00 00       	mov    $0x5,%eax
  800be5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be8:	8b 55 08             	mov    0x8(%ebp),%edx
  800beb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bee:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bf1:	8b 75 18             	mov    0x18(%ebp),%esi
  800bf4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bf6:	85 c0                	test   %eax,%eax
  800bf8:	7e 17                	jle    800c11 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bfa:	83 ec 0c             	sub    $0xc,%esp
  800bfd:	50                   	push   %eax
  800bfe:	6a 05                	push   $0x5
  800c00:	68 5f 22 80 00       	push   $0x80225f
  800c05:	6a 23                	push   $0x23
  800c07:	68 7c 22 80 00       	push   $0x80227c
  800c0c:	e8 04 f5 ff ff       	call   800115 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c11:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c14:	5b                   	pop    %ebx
  800c15:	5e                   	pop    %esi
  800c16:	5f                   	pop    %edi
  800c17:	5d                   	pop    %ebp
  800c18:	c3                   	ret    

00800c19 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c19:	55                   	push   %ebp
  800c1a:	89 e5                	mov    %esp,%ebp
  800c1c:	57                   	push   %edi
  800c1d:	56                   	push   %esi
  800c1e:	53                   	push   %ebx
  800c1f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c22:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c27:	b8 06 00 00 00       	mov    $0x6,%eax
  800c2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c32:	89 df                	mov    %ebx,%edi
  800c34:	89 de                	mov    %ebx,%esi
  800c36:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c38:	85 c0                	test   %eax,%eax
  800c3a:	7e 17                	jle    800c53 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3c:	83 ec 0c             	sub    $0xc,%esp
  800c3f:	50                   	push   %eax
  800c40:	6a 06                	push   $0x6
  800c42:	68 5f 22 80 00       	push   $0x80225f
  800c47:	6a 23                	push   $0x23
  800c49:	68 7c 22 80 00       	push   $0x80227c
  800c4e:	e8 c2 f4 ff ff       	call   800115 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c56:	5b                   	pop    %ebx
  800c57:	5e                   	pop    %esi
  800c58:	5f                   	pop    %edi
  800c59:	5d                   	pop    %ebp
  800c5a:	c3                   	ret    

00800c5b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c5b:	55                   	push   %ebp
  800c5c:	89 e5                	mov    %esp,%ebp
  800c5e:	57                   	push   %edi
  800c5f:	56                   	push   %esi
  800c60:	53                   	push   %ebx
  800c61:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c64:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c69:	b8 08 00 00 00       	mov    $0x8,%eax
  800c6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c71:	8b 55 08             	mov    0x8(%ebp),%edx
  800c74:	89 df                	mov    %ebx,%edi
  800c76:	89 de                	mov    %ebx,%esi
  800c78:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c7a:	85 c0                	test   %eax,%eax
  800c7c:	7e 17                	jle    800c95 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7e:	83 ec 0c             	sub    $0xc,%esp
  800c81:	50                   	push   %eax
  800c82:	6a 08                	push   $0x8
  800c84:	68 5f 22 80 00       	push   $0x80225f
  800c89:	6a 23                	push   $0x23
  800c8b:	68 7c 22 80 00       	push   $0x80227c
  800c90:	e8 80 f4 ff ff       	call   800115 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c95:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c98:	5b                   	pop    %ebx
  800c99:	5e                   	pop    %esi
  800c9a:	5f                   	pop    %edi
  800c9b:	5d                   	pop    %ebp
  800c9c:	c3                   	ret    

00800c9d <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c9d:	55                   	push   %ebp
  800c9e:	89 e5                	mov    %esp,%ebp
  800ca0:	57                   	push   %edi
  800ca1:	56                   	push   %esi
  800ca2:	53                   	push   %ebx
  800ca3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cab:	b8 09 00 00 00       	mov    $0x9,%eax
  800cb0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb6:	89 df                	mov    %ebx,%edi
  800cb8:	89 de                	mov    %ebx,%esi
  800cba:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cbc:	85 c0                	test   %eax,%eax
  800cbe:	7e 17                	jle    800cd7 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc0:	83 ec 0c             	sub    $0xc,%esp
  800cc3:	50                   	push   %eax
  800cc4:	6a 09                	push   $0x9
  800cc6:	68 5f 22 80 00       	push   $0x80225f
  800ccb:	6a 23                	push   $0x23
  800ccd:	68 7c 22 80 00       	push   $0x80227c
  800cd2:	e8 3e f4 ff ff       	call   800115 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cd7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cda:	5b                   	pop    %ebx
  800cdb:	5e                   	pop    %esi
  800cdc:	5f                   	pop    %edi
  800cdd:	5d                   	pop    %ebp
  800cde:	c3                   	ret    

00800cdf <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cdf:	55                   	push   %ebp
  800ce0:	89 e5                	mov    %esp,%ebp
  800ce2:	57                   	push   %edi
  800ce3:	56                   	push   %esi
  800ce4:	53                   	push   %ebx
  800ce5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ced:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cf2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf8:	89 df                	mov    %ebx,%edi
  800cfa:	89 de                	mov    %ebx,%esi
  800cfc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cfe:	85 c0                	test   %eax,%eax
  800d00:	7e 17                	jle    800d19 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d02:	83 ec 0c             	sub    $0xc,%esp
  800d05:	50                   	push   %eax
  800d06:	6a 0a                	push   $0xa
  800d08:	68 5f 22 80 00       	push   $0x80225f
  800d0d:	6a 23                	push   $0x23
  800d0f:	68 7c 22 80 00       	push   $0x80227c
  800d14:	e8 fc f3 ff ff       	call   800115 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1c:	5b                   	pop    %ebx
  800d1d:	5e                   	pop    %esi
  800d1e:	5f                   	pop    %edi
  800d1f:	5d                   	pop    %ebp
  800d20:	c3                   	ret    

00800d21 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d21:	55                   	push   %ebp
  800d22:	89 e5                	mov    %esp,%ebp
  800d24:	57                   	push   %edi
  800d25:	56                   	push   %esi
  800d26:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d27:	be 00 00 00 00       	mov    $0x0,%esi
  800d2c:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d34:	8b 55 08             	mov    0x8(%ebp),%edx
  800d37:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d3a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d3d:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d3f:	5b                   	pop    %ebx
  800d40:	5e                   	pop    %esi
  800d41:	5f                   	pop    %edi
  800d42:	5d                   	pop    %ebp
  800d43:	c3                   	ret    

00800d44 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d44:	55                   	push   %ebp
  800d45:	89 e5                	mov    %esp,%ebp
  800d47:	57                   	push   %edi
  800d48:	56                   	push   %esi
  800d49:	53                   	push   %ebx
  800d4a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d52:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d57:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5a:	89 cb                	mov    %ecx,%ebx
  800d5c:	89 cf                	mov    %ecx,%edi
  800d5e:	89 ce                	mov    %ecx,%esi
  800d60:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d62:	85 c0                	test   %eax,%eax
  800d64:	7e 17                	jle    800d7d <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d66:	83 ec 0c             	sub    $0xc,%esp
  800d69:	50                   	push   %eax
  800d6a:	6a 0d                	push   $0xd
  800d6c:	68 5f 22 80 00       	push   $0x80225f
  800d71:	6a 23                	push   $0x23
  800d73:	68 7c 22 80 00       	push   $0x80227c
  800d78:	e8 98 f3 ff ff       	call   800115 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d80:	5b                   	pop    %ebx
  800d81:	5e                   	pop    %esi
  800d82:	5f                   	pop    %edi
  800d83:	5d                   	pop    %ebp
  800d84:	c3                   	ret    

00800d85 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d85:	55                   	push   %ebp
  800d86:	89 e5                	mov    %esp,%ebp
  800d88:	83 ec 08             	sub    $0x8,%esp
	int r;
	int ret;
	if (_pgfault_handler == 0) {
  800d8b:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800d92:	75 36                	jne    800dca <set_pgfault_handler+0x45>
		// First time through!
		// LAB 4: Your code here.
        
        	ret = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  800d94:	a1 04 40 80 00       	mov    0x804004,%eax
  800d99:	8b 40 48             	mov    0x48(%eax),%eax
  800d9c:	83 ec 04             	sub    $0x4,%esp
  800d9f:	68 07 0e 00 00       	push   $0xe07
  800da4:	68 00 f0 bf ee       	push   $0xeebff000
  800da9:	50                   	push   %eax
  800daa:	e8 e5 fd ff ff       	call   800b94 <sys_page_alloc>
		if (ret < 0) {
  800daf:	83 c4 10             	add    $0x10,%esp
  800db2:	85 c0                	test   %eax,%eax
  800db4:	79 14                	jns    800dca <set_pgfault_handler+0x45>
		    panic("Allocate user exception stack failed!\n");
  800db6:	83 ec 04             	sub    $0x4,%esp
  800db9:	68 8c 22 80 00       	push   $0x80228c
  800dbe:	6a 23                	push   $0x23
  800dc0:	68 b3 22 80 00       	push   $0x8022b3
  800dc5:	e8 4b f3 ff ff       	call   800115 <_panic>
		}
	}
	sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  800dca:	a1 04 40 80 00       	mov    0x804004,%eax
  800dcf:	8b 40 48             	mov    0x48(%eax),%eax
  800dd2:	83 ec 08             	sub    $0x8,%esp
  800dd5:	68 ed 0d 80 00       	push   $0x800ded
  800dda:	50                   	push   %eax
  800ddb:	e8 ff fe ff ff       	call   800cdf <sys_env_set_pgfault_upcall>
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800de0:	8b 45 08             	mov    0x8(%ebp),%eax
  800de3:	a3 08 40 80 00       	mov    %eax,0x804008
}
  800de8:	83 c4 10             	add    $0x10,%esp
  800deb:	c9                   	leave  
  800dec:	c3                   	ret    

00800ded <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800ded:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800dee:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800df3:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800df5:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 0x28(%esp), %ebx  # trap-time eip
  800df8:	8b 5c 24 28          	mov    0x28(%esp),%ebx
        subl $0x4, 0x30(%esp)  # trap-time esp minus 4
  800dfc:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax 
  800e01:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl %ebx, (%eax)      # trap-time esp store trap-time eip
  800e05:	89 18                	mov    %ebx,(%eax)
        addl $0x8, %esp
  800e07:	83 c4 08             	add    $0x8,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  800e0a:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  800e0b:	83 c4 04             	add    $0x4,%esp
        popfl
  800e0e:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  800e0f:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  800e10:	c3                   	ret    

00800e11 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e11:	55                   	push   %ebp
  800e12:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e14:	8b 45 08             	mov    0x8(%ebp),%eax
  800e17:	05 00 00 00 30       	add    $0x30000000,%eax
  800e1c:	c1 e8 0c             	shr    $0xc,%eax
}
  800e1f:	5d                   	pop    %ebp
  800e20:	c3                   	ret    

00800e21 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e21:	55                   	push   %ebp
  800e22:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e24:	8b 45 08             	mov    0x8(%ebp),%eax
  800e27:	05 00 00 00 30       	add    $0x30000000,%eax
  800e2c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e31:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e36:	5d                   	pop    %ebp
  800e37:	c3                   	ret    

00800e38 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e38:	55                   	push   %ebp
  800e39:	89 e5                	mov    %esp,%ebp
  800e3b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e3e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e43:	89 c2                	mov    %eax,%edx
  800e45:	c1 ea 16             	shr    $0x16,%edx
  800e48:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e4f:	f6 c2 01             	test   $0x1,%dl
  800e52:	74 11                	je     800e65 <fd_alloc+0x2d>
  800e54:	89 c2                	mov    %eax,%edx
  800e56:	c1 ea 0c             	shr    $0xc,%edx
  800e59:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e60:	f6 c2 01             	test   $0x1,%dl
  800e63:	75 09                	jne    800e6e <fd_alloc+0x36>
			*fd_store = fd;
  800e65:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e67:	b8 00 00 00 00       	mov    $0x0,%eax
  800e6c:	eb 17                	jmp    800e85 <fd_alloc+0x4d>
  800e6e:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e73:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e78:	75 c9                	jne    800e43 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e7a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e80:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e85:	5d                   	pop    %ebp
  800e86:	c3                   	ret    

00800e87 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e87:	55                   	push   %ebp
  800e88:	89 e5                	mov    %esp,%ebp
  800e8a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e8d:	83 f8 1f             	cmp    $0x1f,%eax
  800e90:	77 36                	ja     800ec8 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e92:	c1 e0 0c             	shl    $0xc,%eax
  800e95:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e9a:	89 c2                	mov    %eax,%edx
  800e9c:	c1 ea 16             	shr    $0x16,%edx
  800e9f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ea6:	f6 c2 01             	test   $0x1,%dl
  800ea9:	74 24                	je     800ecf <fd_lookup+0x48>
  800eab:	89 c2                	mov    %eax,%edx
  800ead:	c1 ea 0c             	shr    $0xc,%edx
  800eb0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800eb7:	f6 c2 01             	test   $0x1,%dl
  800eba:	74 1a                	je     800ed6 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ebc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ebf:	89 02                	mov    %eax,(%edx)
	return 0;
  800ec1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec6:	eb 13                	jmp    800edb <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ec8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ecd:	eb 0c                	jmp    800edb <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ecf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ed4:	eb 05                	jmp    800edb <fd_lookup+0x54>
  800ed6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800edb:	5d                   	pop    %ebp
  800edc:	c3                   	ret    

00800edd <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800edd:	55                   	push   %ebp
  800ede:	89 e5                	mov    %esp,%ebp
  800ee0:	83 ec 08             	sub    $0x8,%esp
  800ee3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ee6:	ba 44 23 80 00       	mov    $0x802344,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800eeb:	eb 13                	jmp    800f00 <dev_lookup+0x23>
  800eed:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800ef0:	39 08                	cmp    %ecx,(%eax)
  800ef2:	75 0c                	jne    800f00 <dev_lookup+0x23>
			*dev = devtab[i];
  800ef4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef7:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ef9:	b8 00 00 00 00       	mov    $0x0,%eax
  800efe:	eb 2e                	jmp    800f2e <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f00:	8b 02                	mov    (%edx),%eax
  800f02:	85 c0                	test   %eax,%eax
  800f04:	75 e7                	jne    800eed <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f06:	a1 04 40 80 00       	mov    0x804004,%eax
  800f0b:	8b 40 48             	mov    0x48(%eax),%eax
  800f0e:	83 ec 04             	sub    $0x4,%esp
  800f11:	51                   	push   %ecx
  800f12:	50                   	push   %eax
  800f13:	68 c4 22 80 00       	push   $0x8022c4
  800f18:	e8 d1 f2 ff ff       	call   8001ee <cprintf>
	*dev = 0;
  800f1d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f20:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f26:	83 c4 10             	add    $0x10,%esp
  800f29:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f2e:	c9                   	leave  
  800f2f:	c3                   	ret    

00800f30 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f30:	55                   	push   %ebp
  800f31:	89 e5                	mov    %esp,%ebp
  800f33:	56                   	push   %esi
  800f34:	53                   	push   %ebx
  800f35:	83 ec 10             	sub    $0x10,%esp
  800f38:	8b 75 08             	mov    0x8(%ebp),%esi
  800f3b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f3e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f41:	50                   	push   %eax
  800f42:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f48:	c1 e8 0c             	shr    $0xc,%eax
  800f4b:	50                   	push   %eax
  800f4c:	e8 36 ff ff ff       	call   800e87 <fd_lookup>
  800f51:	83 c4 08             	add    $0x8,%esp
  800f54:	85 c0                	test   %eax,%eax
  800f56:	78 05                	js     800f5d <fd_close+0x2d>
	    || fd != fd2)
  800f58:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f5b:	74 0c                	je     800f69 <fd_close+0x39>
		return (must_exist ? r : 0);
  800f5d:	84 db                	test   %bl,%bl
  800f5f:	ba 00 00 00 00       	mov    $0x0,%edx
  800f64:	0f 44 c2             	cmove  %edx,%eax
  800f67:	eb 41                	jmp    800faa <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f69:	83 ec 08             	sub    $0x8,%esp
  800f6c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f6f:	50                   	push   %eax
  800f70:	ff 36                	pushl  (%esi)
  800f72:	e8 66 ff ff ff       	call   800edd <dev_lookup>
  800f77:	89 c3                	mov    %eax,%ebx
  800f79:	83 c4 10             	add    $0x10,%esp
  800f7c:	85 c0                	test   %eax,%eax
  800f7e:	78 1a                	js     800f9a <fd_close+0x6a>
		if (dev->dev_close)
  800f80:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f83:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f86:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f8b:	85 c0                	test   %eax,%eax
  800f8d:	74 0b                	je     800f9a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f8f:	83 ec 0c             	sub    $0xc,%esp
  800f92:	56                   	push   %esi
  800f93:	ff d0                	call   *%eax
  800f95:	89 c3                	mov    %eax,%ebx
  800f97:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f9a:	83 ec 08             	sub    $0x8,%esp
  800f9d:	56                   	push   %esi
  800f9e:	6a 00                	push   $0x0
  800fa0:	e8 74 fc ff ff       	call   800c19 <sys_page_unmap>
	return r;
  800fa5:	83 c4 10             	add    $0x10,%esp
  800fa8:	89 d8                	mov    %ebx,%eax
}
  800faa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fad:	5b                   	pop    %ebx
  800fae:	5e                   	pop    %esi
  800faf:	5d                   	pop    %ebp
  800fb0:	c3                   	ret    

00800fb1 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800fb1:	55                   	push   %ebp
  800fb2:	89 e5                	mov    %esp,%ebp
  800fb4:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fb7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fba:	50                   	push   %eax
  800fbb:	ff 75 08             	pushl  0x8(%ebp)
  800fbe:	e8 c4 fe ff ff       	call   800e87 <fd_lookup>
  800fc3:	83 c4 08             	add    $0x8,%esp
  800fc6:	85 c0                	test   %eax,%eax
  800fc8:	78 10                	js     800fda <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800fca:	83 ec 08             	sub    $0x8,%esp
  800fcd:	6a 01                	push   $0x1
  800fcf:	ff 75 f4             	pushl  -0xc(%ebp)
  800fd2:	e8 59 ff ff ff       	call   800f30 <fd_close>
  800fd7:	83 c4 10             	add    $0x10,%esp
}
  800fda:	c9                   	leave  
  800fdb:	c3                   	ret    

00800fdc <close_all>:

void
close_all(void)
{
  800fdc:	55                   	push   %ebp
  800fdd:	89 e5                	mov    %esp,%ebp
  800fdf:	53                   	push   %ebx
  800fe0:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fe3:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fe8:	83 ec 0c             	sub    $0xc,%esp
  800feb:	53                   	push   %ebx
  800fec:	e8 c0 ff ff ff       	call   800fb1 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800ff1:	83 c3 01             	add    $0x1,%ebx
  800ff4:	83 c4 10             	add    $0x10,%esp
  800ff7:	83 fb 20             	cmp    $0x20,%ebx
  800ffa:	75 ec                	jne    800fe8 <close_all+0xc>
		close(i);
}
  800ffc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fff:	c9                   	leave  
  801000:	c3                   	ret    

00801001 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801001:	55                   	push   %ebp
  801002:	89 e5                	mov    %esp,%ebp
  801004:	57                   	push   %edi
  801005:	56                   	push   %esi
  801006:	53                   	push   %ebx
  801007:	83 ec 2c             	sub    $0x2c,%esp
  80100a:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80100d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801010:	50                   	push   %eax
  801011:	ff 75 08             	pushl  0x8(%ebp)
  801014:	e8 6e fe ff ff       	call   800e87 <fd_lookup>
  801019:	83 c4 08             	add    $0x8,%esp
  80101c:	85 c0                	test   %eax,%eax
  80101e:	0f 88 c1 00 00 00    	js     8010e5 <dup+0xe4>
		return r;
	close(newfdnum);
  801024:	83 ec 0c             	sub    $0xc,%esp
  801027:	56                   	push   %esi
  801028:	e8 84 ff ff ff       	call   800fb1 <close>

	newfd = INDEX2FD(newfdnum);
  80102d:	89 f3                	mov    %esi,%ebx
  80102f:	c1 e3 0c             	shl    $0xc,%ebx
  801032:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801038:	83 c4 04             	add    $0x4,%esp
  80103b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80103e:	e8 de fd ff ff       	call   800e21 <fd2data>
  801043:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801045:	89 1c 24             	mov    %ebx,(%esp)
  801048:	e8 d4 fd ff ff       	call   800e21 <fd2data>
  80104d:	83 c4 10             	add    $0x10,%esp
  801050:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801053:	89 f8                	mov    %edi,%eax
  801055:	c1 e8 16             	shr    $0x16,%eax
  801058:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80105f:	a8 01                	test   $0x1,%al
  801061:	74 37                	je     80109a <dup+0x99>
  801063:	89 f8                	mov    %edi,%eax
  801065:	c1 e8 0c             	shr    $0xc,%eax
  801068:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80106f:	f6 c2 01             	test   $0x1,%dl
  801072:	74 26                	je     80109a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801074:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80107b:	83 ec 0c             	sub    $0xc,%esp
  80107e:	25 07 0e 00 00       	and    $0xe07,%eax
  801083:	50                   	push   %eax
  801084:	ff 75 d4             	pushl  -0x2c(%ebp)
  801087:	6a 00                	push   $0x0
  801089:	57                   	push   %edi
  80108a:	6a 00                	push   $0x0
  80108c:	e8 46 fb ff ff       	call   800bd7 <sys_page_map>
  801091:	89 c7                	mov    %eax,%edi
  801093:	83 c4 20             	add    $0x20,%esp
  801096:	85 c0                	test   %eax,%eax
  801098:	78 2e                	js     8010c8 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80109a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80109d:	89 d0                	mov    %edx,%eax
  80109f:	c1 e8 0c             	shr    $0xc,%eax
  8010a2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010a9:	83 ec 0c             	sub    $0xc,%esp
  8010ac:	25 07 0e 00 00       	and    $0xe07,%eax
  8010b1:	50                   	push   %eax
  8010b2:	53                   	push   %ebx
  8010b3:	6a 00                	push   $0x0
  8010b5:	52                   	push   %edx
  8010b6:	6a 00                	push   $0x0
  8010b8:	e8 1a fb ff ff       	call   800bd7 <sys_page_map>
  8010bd:	89 c7                	mov    %eax,%edi
  8010bf:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010c2:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010c4:	85 ff                	test   %edi,%edi
  8010c6:	79 1d                	jns    8010e5 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010c8:	83 ec 08             	sub    $0x8,%esp
  8010cb:	53                   	push   %ebx
  8010cc:	6a 00                	push   $0x0
  8010ce:	e8 46 fb ff ff       	call   800c19 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010d3:	83 c4 08             	add    $0x8,%esp
  8010d6:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010d9:	6a 00                	push   $0x0
  8010db:	e8 39 fb ff ff       	call   800c19 <sys_page_unmap>
	return r;
  8010e0:	83 c4 10             	add    $0x10,%esp
  8010e3:	89 f8                	mov    %edi,%eax
}
  8010e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010e8:	5b                   	pop    %ebx
  8010e9:	5e                   	pop    %esi
  8010ea:	5f                   	pop    %edi
  8010eb:	5d                   	pop    %ebp
  8010ec:	c3                   	ret    

008010ed <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010ed:	55                   	push   %ebp
  8010ee:	89 e5                	mov    %esp,%ebp
  8010f0:	53                   	push   %ebx
  8010f1:	83 ec 14             	sub    $0x14,%esp
  8010f4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010f7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010fa:	50                   	push   %eax
  8010fb:	53                   	push   %ebx
  8010fc:	e8 86 fd ff ff       	call   800e87 <fd_lookup>
  801101:	83 c4 08             	add    $0x8,%esp
  801104:	89 c2                	mov    %eax,%edx
  801106:	85 c0                	test   %eax,%eax
  801108:	78 6d                	js     801177 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80110a:	83 ec 08             	sub    $0x8,%esp
  80110d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801110:	50                   	push   %eax
  801111:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801114:	ff 30                	pushl  (%eax)
  801116:	e8 c2 fd ff ff       	call   800edd <dev_lookup>
  80111b:	83 c4 10             	add    $0x10,%esp
  80111e:	85 c0                	test   %eax,%eax
  801120:	78 4c                	js     80116e <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801122:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801125:	8b 42 08             	mov    0x8(%edx),%eax
  801128:	83 e0 03             	and    $0x3,%eax
  80112b:	83 f8 01             	cmp    $0x1,%eax
  80112e:	75 21                	jne    801151 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801130:	a1 04 40 80 00       	mov    0x804004,%eax
  801135:	8b 40 48             	mov    0x48(%eax),%eax
  801138:	83 ec 04             	sub    $0x4,%esp
  80113b:	53                   	push   %ebx
  80113c:	50                   	push   %eax
  80113d:	68 08 23 80 00       	push   $0x802308
  801142:	e8 a7 f0 ff ff       	call   8001ee <cprintf>
		return -E_INVAL;
  801147:	83 c4 10             	add    $0x10,%esp
  80114a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80114f:	eb 26                	jmp    801177 <read+0x8a>
	}
	if (!dev->dev_read)
  801151:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801154:	8b 40 08             	mov    0x8(%eax),%eax
  801157:	85 c0                	test   %eax,%eax
  801159:	74 17                	je     801172 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80115b:	83 ec 04             	sub    $0x4,%esp
  80115e:	ff 75 10             	pushl  0x10(%ebp)
  801161:	ff 75 0c             	pushl  0xc(%ebp)
  801164:	52                   	push   %edx
  801165:	ff d0                	call   *%eax
  801167:	89 c2                	mov    %eax,%edx
  801169:	83 c4 10             	add    $0x10,%esp
  80116c:	eb 09                	jmp    801177 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80116e:	89 c2                	mov    %eax,%edx
  801170:	eb 05                	jmp    801177 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801172:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801177:	89 d0                	mov    %edx,%eax
  801179:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80117c:	c9                   	leave  
  80117d:	c3                   	ret    

0080117e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80117e:	55                   	push   %ebp
  80117f:	89 e5                	mov    %esp,%ebp
  801181:	57                   	push   %edi
  801182:	56                   	push   %esi
  801183:	53                   	push   %ebx
  801184:	83 ec 0c             	sub    $0xc,%esp
  801187:	8b 7d 08             	mov    0x8(%ebp),%edi
  80118a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80118d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801192:	eb 21                	jmp    8011b5 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801194:	83 ec 04             	sub    $0x4,%esp
  801197:	89 f0                	mov    %esi,%eax
  801199:	29 d8                	sub    %ebx,%eax
  80119b:	50                   	push   %eax
  80119c:	89 d8                	mov    %ebx,%eax
  80119e:	03 45 0c             	add    0xc(%ebp),%eax
  8011a1:	50                   	push   %eax
  8011a2:	57                   	push   %edi
  8011a3:	e8 45 ff ff ff       	call   8010ed <read>
		if (m < 0)
  8011a8:	83 c4 10             	add    $0x10,%esp
  8011ab:	85 c0                	test   %eax,%eax
  8011ad:	78 10                	js     8011bf <readn+0x41>
			return m;
		if (m == 0)
  8011af:	85 c0                	test   %eax,%eax
  8011b1:	74 0a                	je     8011bd <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011b3:	01 c3                	add    %eax,%ebx
  8011b5:	39 f3                	cmp    %esi,%ebx
  8011b7:	72 db                	jb     801194 <readn+0x16>
  8011b9:	89 d8                	mov    %ebx,%eax
  8011bb:	eb 02                	jmp    8011bf <readn+0x41>
  8011bd:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8011bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011c2:	5b                   	pop    %ebx
  8011c3:	5e                   	pop    %esi
  8011c4:	5f                   	pop    %edi
  8011c5:	5d                   	pop    %ebp
  8011c6:	c3                   	ret    

008011c7 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
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
  8011d6:	e8 ac fc ff ff       	call   800e87 <fd_lookup>
  8011db:	83 c4 08             	add    $0x8,%esp
  8011de:	89 c2                	mov    %eax,%edx
  8011e0:	85 c0                	test   %eax,%eax
  8011e2:	78 68                	js     80124c <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011e4:	83 ec 08             	sub    $0x8,%esp
  8011e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011ea:	50                   	push   %eax
  8011eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ee:	ff 30                	pushl  (%eax)
  8011f0:	e8 e8 fc ff ff       	call   800edd <dev_lookup>
  8011f5:	83 c4 10             	add    $0x10,%esp
  8011f8:	85 c0                	test   %eax,%eax
  8011fa:	78 47                	js     801243 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ff:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801203:	75 21                	jne    801226 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801205:	a1 04 40 80 00       	mov    0x804004,%eax
  80120a:	8b 40 48             	mov    0x48(%eax),%eax
  80120d:	83 ec 04             	sub    $0x4,%esp
  801210:	53                   	push   %ebx
  801211:	50                   	push   %eax
  801212:	68 24 23 80 00       	push   $0x802324
  801217:	e8 d2 ef ff ff       	call   8001ee <cprintf>
		return -E_INVAL;
  80121c:	83 c4 10             	add    $0x10,%esp
  80121f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801224:	eb 26                	jmp    80124c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801226:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801229:	8b 52 0c             	mov    0xc(%edx),%edx
  80122c:	85 d2                	test   %edx,%edx
  80122e:	74 17                	je     801247 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801230:	83 ec 04             	sub    $0x4,%esp
  801233:	ff 75 10             	pushl  0x10(%ebp)
  801236:	ff 75 0c             	pushl  0xc(%ebp)
  801239:	50                   	push   %eax
  80123a:	ff d2                	call   *%edx
  80123c:	89 c2                	mov    %eax,%edx
  80123e:	83 c4 10             	add    $0x10,%esp
  801241:	eb 09                	jmp    80124c <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801243:	89 c2                	mov    %eax,%edx
  801245:	eb 05                	jmp    80124c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801247:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80124c:	89 d0                	mov    %edx,%eax
  80124e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801251:	c9                   	leave  
  801252:	c3                   	ret    

00801253 <seek>:

int
seek(int fdnum, off_t offset)
{
  801253:	55                   	push   %ebp
  801254:	89 e5                	mov    %esp,%ebp
  801256:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801259:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80125c:	50                   	push   %eax
  80125d:	ff 75 08             	pushl  0x8(%ebp)
  801260:	e8 22 fc ff ff       	call   800e87 <fd_lookup>
  801265:	83 c4 08             	add    $0x8,%esp
  801268:	85 c0                	test   %eax,%eax
  80126a:	78 0e                	js     80127a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80126c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80126f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801272:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801275:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80127a:	c9                   	leave  
  80127b:	c3                   	ret    

0080127c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80127c:	55                   	push   %ebp
  80127d:	89 e5                	mov    %esp,%ebp
  80127f:	53                   	push   %ebx
  801280:	83 ec 14             	sub    $0x14,%esp
  801283:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801286:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801289:	50                   	push   %eax
  80128a:	53                   	push   %ebx
  80128b:	e8 f7 fb ff ff       	call   800e87 <fd_lookup>
  801290:	83 c4 08             	add    $0x8,%esp
  801293:	89 c2                	mov    %eax,%edx
  801295:	85 c0                	test   %eax,%eax
  801297:	78 65                	js     8012fe <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801299:	83 ec 08             	sub    $0x8,%esp
  80129c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80129f:	50                   	push   %eax
  8012a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a3:	ff 30                	pushl  (%eax)
  8012a5:	e8 33 fc ff ff       	call   800edd <dev_lookup>
  8012aa:	83 c4 10             	add    $0x10,%esp
  8012ad:	85 c0                	test   %eax,%eax
  8012af:	78 44                	js     8012f5 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012b4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012b8:	75 21                	jne    8012db <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012ba:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012bf:	8b 40 48             	mov    0x48(%eax),%eax
  8012c2:	83 ec 04             	sub    $0x4,%esp
  8012c5:	53                   	push   %ebx
  8012c6:	50                   	push   %eax
  8012c7:	68 e4 22 80 00       	push   $0x8022e4
  8012cc:	e8 1d ef ff ff       	call   8001ee <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012d1:	83 c4 10             	add    $0x10,%esp
  8012d4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012d9:	eb 23                	jmp    8012fe <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012db:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012de:	8b 52 18             	mov    0x18(%edx),%edx
  8012e1:	85 d2                	test   %edx,%edx
  8012e3:	74 14                	je     8012f9 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012e5:	83 ec 08             	sub    $0x8,%esp
  8012e8:	ff 75 0c             	pushl  0xc(%ebp)
  8012eb:	50                   	push   %eax
  8012ec:	ff d2                	call   *%edx
  8012ee:	89 c2                	mov    %eax,%edx
  8012f0:	83 c4 10             	add    $0x10,%esp
  8012f3:	eb 09                	jmp    8012fe <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012f5:	89 c2                	mov    %eax,%edx
  8012f7:	eb 05                	jmp    8012fe <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012f9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8012fe:	89 d0                	mov    %edx,%eax
  801300:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801303:	c9                   	leave  
  801304:	c3                   	ret    

00801305 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801305:	55                   	push   %ebp
  801306:	89 e5                	mov    %esp,%ebp
  801308:	53                   	push   %ebx
  801309:	83 ec 14             	sub    $0x14,%esp
  80130c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80130f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801312:	50                   	push   %eax
  801313:	ff 75 08             	pushl  0x8(%ebp)
  801316:	e8 6c fb ff ff       	call   800e87 <fd_lookup>
  80131b:	83 c4 08             	add    $0x8,%esp
  80131e:	89 c2                	mov    %eax,%edx
  801320:	85 c0                	test   %eax,%eax
  801322:	78 58                	js     80137c <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801324:	83 ec 08             	sub    $0x8,%esp
  801327:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80132a:	50                   	push   %eax
  80132b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80132e:	ff 30                	pushl  (%eax)
  801330:	e8 a8 fb ff ff       	call   800edd <dev_lookup>
  801335:	83 c4 10             	add    $0x10,%esp
  801338:	85 c0                	test   %eax,%eax
  80133a:	78 37                	js     801373 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80133c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80133f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801343:	74 32                	je     801377 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801345:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801348:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80134f:	00 00 00 
	stat->st_isdir = 0;
  801352:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801359:	00 00 00 
	stat->st_dev = dev;
  80135c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801362:	83 ec 08             	sub    $0x8,%esp
  801365:	53                   	push   %ebx
  801366:	ff 75 f0             	pushl  -0x10(%ebp)
  801369:	ff 50 14             	call   *0x14(%eax)
  80136c:	89 c2                	mov    %eax,%edx
  80136e:	83 c4 10             	add    $0x10,%esp
  801371:	eb 09                	jmp    80137c <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801373:	89 c2                	mov    %eax,%edx
  801375:	eb 05                	jmp    80137c <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801377:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80137c:	89 d0                	mov    %edx,%eax
  80137e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801381:	c9                   	leave  
  801382:	c3                   	ret    

00801383 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801383:	55                   	push   %ebp
  801384:	89 e5                	mov    %esp,%ebp
  801386:	56                   	push   %esi
  801387:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801388:	83 ec 08             	sub    $0x8,%esp
  80138b:	6a 00                	push   $0x0
  80138d:	ff 75 08             	pushl  0x8(%ebp)
  801390:	e8 e3 01 00 00       	call   801578 <open>
  801395:	89 c3                	mov    %eax,%ebx
  801397:	83 c4 10             	add    $0x10,%esp
  80139a:	85 c0                	test   %eax,%eax
  80139c:	78 1b                	js     8013b9 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80139e:	83 ec 08             	sub    $0x8,%esp
  8013a1:	ff 75 0c             	pushl  0xc(%ebp)
  8013a4:	50                   	push   %eax
  8013a5:	e8 5b ff ff ff       	call   801305 <fstat>
  8013aa:	89 c6                	mov    %eax,%esi
	close(fd);
  8013ac:	89 1c 24             	mov    %ebx,(%esp)
  8013af:	e8 fd fb ff ff       	call   800fb1 <close>
	return r;
  8013b4:	83 c4 10             	add    $0x10,%esp
  8013b7:	89 f0                	mov    %esi,%eax
}
  8013b9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013bc:	5b                   	pop    %ebx
  8013bd:	5e                   	pop    %esi
  8013be:	5d                   	pop    %ebp
  8013bf:	c3                   	ret    

008013c0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013c0:	55                   	push   %ebp
  8013c1:	89 e5                	mov    %esp,%ebp
  8013c3:	56                   	push   %esi
  8013c4:	53                   	push   %ebx
  8013c5:	89 c6                	mov    %eax,%esi
  8013c7:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013c9:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013d0:	75 12                	jne    8013e4 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013d2:	83 ec 0c             	sub    $0xc,%esp
  8013d5:	6a 01                	push   $0x1
  8013d7:	e8 c8 07 00 00       	call   801ba4 <ipc_find_env>
  8013dc:	a3 00 40 80 00       	mov    %eax,0x804000
  8013e1:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013e4:	6a 07                	push   $0x7
  8013e6:	68 00 50 80 00       	push   $0x805000
  8013eb:	56                   	push   %esi
  8013ec:	ff 35 00 40 80 00    	pushl  0x804000
  8013f2:	e8 59 07 00 00       	call   801b50 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013f7:	83 c4 0c             	add    $0xc,%esp
  8013fa:	6a 00                	push   $0x0
  8013fc:	53                   	push   %ebx
  8013fd:	6a 00                	push   $0x0
  8013ff:	e8 f7 06 00 00       	call   801afb <ipc_recv>
}
  801404:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801407:	5b                   	pop    %ebx
  801408:	5e                   	pop    %esi
  801409:	5d                   	pop    %ebp
  80140a:	c3                   	ret    

0080140b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80140b:	55                   	push   %ebp
  80140c:	89 e5                	mov    %esp,%ebp
  80140e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801411:	8b 45 08             	mov    0x8(%ebp),%eax
  801414:	8b 40 0c             	mov    0xc(%eax),%eax
  801417:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80141c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80141f:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801424:	ba 00 00 00 00       	mov    $0x0,%edx
  801429:	b8 02 00 00 00       	mov    $0x2,%eax
  80142e:	e8 8d ff ff ff       	call   8013c0 <fsipc>
}
  801433:	c9                   	leave  
  801434:	c3                   	ret    

00801435 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801435:	55                   	push   %ebp
  801436:	89 e5                	mov    %esp,%ebp
  801438:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80143b:	8b 45 08             	mov    0x8(%ebp),%eax
  80143e:	8b 40 0c             	mov    0xc(%eax),%eax
  801441:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801446:	ba 00 00 00 00       	mov    $0x0,%edx
  80144b:	b8 06 00 00 00       	mov    $0x6,%eax
  801450:	e8 6b ff ff ff       	call   8013c0 <fsipc>
}
  801455:	c9                   	leave  
  801456:	c3                   	ret    

00801457 <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801457:	55                   	push   %ebp
  801458:	89 e5                	mov    %esp,%ebp
  80145a:	53                   	push   %ebx
  80145b:	83 ec 04             	sub    $0x4,%esp
  80145e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801461:	8b 45 08             	mov    0x8(%ebp),%eax
  801464:	8b 40 0c             	mov    0xc(%eax),%eax
  801467:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80146c:	ba 00 00 00 00       	mov    $0x0,%edx
  801471:	b8 05 00 00 00       	mov    $0x5,%eax
  801476:	e8 45 ff ff ff       	call   8013c0 <fsipc>
  80147b:	85 c0                	test   %eax,%eax
  80147d:	78 2c                	js     8014ab <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80147f:	83 ec 08             	sub    $0x8,%esp
  801482:	68 00 50 80 00       	push   $0x805000
  801487:	53                   	push   %ebx
  801488:	e8 04 f3 ff ff       	call   800791 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80148d:	a1 80 50 80 00       	mov    0x805080,%eax
  801492:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801498:	a1 84 50 80 00       	mov    0x805084,%eax
  80149d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014a3:	83 c4 10             	add    $0x10,%esp
  8014a6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014ae:	c9                   	leave  
  8014af:	c3                   	ret    

008014b0 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014b0:	55                   	push   %ebp
  8014b1:	89 e5                	mov    %esp,%ebp
  8014b3:	83 ec 0c             	sub    $0xc,%esp
  8014b6:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
    
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8014bc:	8b 52 0c             	mov    0xc(%edx),%edx
  8014bf:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = MIN(n, PGSIZE);
  8014c5:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014ca:	ba 00 10 00 00       	mov    $0x1000,%edx
  8014cf:	0f 47 c2             	cmova  %edx,%eax
  8014d2:	a3 04 50 80 00       	mov    %eax,0x805004
    memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8014d7:	50                   	push   %eax
  8014d8:	ff 75 0c             	pushl  0xc(%ebp)
  8014db:	68 08 50 80 00       	push   $0x805008
  8014e0:	e8 3e f4 ff ff       	call   800923 <memmove>
    int r = fsipc(FSREQ_WRITE, NULL);
  8014e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ea:	b8 04 00 00 00       	mov    $0x4,%eax
  8014ef:	e8 cc fe ff ff       	call   8013c0 <fsipc>
    return r;
}
  8014f4:	c9                   	leave  
  8014f5:	c3                   	ret    

008014f6 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8014f6:	55                   	push   %ebp
  8014f7:	89 e5                	mov    %esp,%ebp
  8014f9:	56                   	push   %esi
  8014fa:	53                   	push   %ebx
  8014fb:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801501:	8b 40 0c             	mov    0xc(%eax),%eax
  801504:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801509:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80150f:	ba 00 00 00 00       	mov    $0x0,%edx
  801514:	b8 03 00 00 00       	mov    $0x3,%eax
  801519:	e8 a2 fe ff ff       	call   8013c0 <fsipc>
  80151e:	89 c3                	mov    %eax,%ebx
  801520:	85 c0                	test   %eax,%eax
  801522:	78 4b                	js     80156f <devfile_read+0x79>
		return r;
	assert(r <= n);
  801524:	39 c6                	cmp    %eax,%esi
  801526:	73 16                	jae    80153e <devfile_read+0x48>
  801528:	68 54 23 80 00       	push   $0x802354
  80152d:	68 5b 23 80 00       	push   $0x80235b
  801532:	6a 7c                	push   $0x7c
  801534:	68 70 23 80 00       	push   $0x802370
  801539:	e8 d7 eb ff ff       	call   800115 <_panic>
	assert(r <= PGSIZE);
  80153e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801543:	7e 16                	jle    80155b <devfile_read+0x65>
  801545:	68 7b 23 80 00       	push   $0x80237b
  80154a:	68 5b 23 80 00       	push   $0x80235b
  80154f:	6a 7d                	push   $0x7d
  801551:	68 70 23 80 00       	push   $0x802370
  801556:	e8 ba eb ff ff       	call   800115 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80155b:	83 ec 04             	sub    $0x4,%esp
  80155e:	50                   	push   %eax
  80155f:	68 00 50 80 00       	push   $0x805000
  801564:	ff 75 0c             	pushl  0xc(%ebp)
  801567:	e8 b7 f3 ff ff       	call   800923 <memmove>
	return r;
  80156c:	83 c4 10             	add    $0x10,%esp
}
  80156f:	89 d8                	mov    %ebx,%eax
  801571:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801574:	5b                   	pop    %ebx
  801575:	5e                   	pop    %esi
  801576:	5d                   	pop    %ebp
  801577:	c3                   	ret    

00801578 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801578:	55                   	push   %ebp
  801579:	89 e5                	mov    %esp,%ebp
  80157b:	53                   	push   %ebx
  80157c:	83 ec 20             	sub    $0x20,%esp
  80157f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801582:	53                   	push   %ebx
  801583:	e8 d0 f1 ff ff       	call   800758 <strlen>
  801588:	83 c4 10             	add    $0x10,%esp
  80158b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801590:	7f 67                	jg     8015f9 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801592:	83 ec 0c             	sub    $0xc,%esp
  801595:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801598:	50                   	push   %eax
  801599:	e8 9a f8 ff ff       	call   800e38 <fd_alloc>
  80159e:	83 c4 10             	add    $0x10,%esp
		return r;
  8015a1:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015a3:	85 c0                	test   %eax,%eax
  8015a5:	78 57                	js     8015fe <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015a7:	83 ec 08             	sub    $0x8,%esp
  8015aa:	53                   	push   %ebx
  8015ab:	68 00 50 80 00       	push   $0x805000
  8015b0:	e8 dc f1 ff ff       	call   800791 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015b8:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015c0:	b8 01 00 00 00       	mov    $0x1,%eax
  8015c5:	e8 f6 fd ff ff       	call   8013c0 <fsipc>
  8015ca:	89 c3                	mov    %eax,%ebx
  8015cc:	83 c4 10             	add    $0x10,%esp
  8015cf:	85 c0                	test   %eax,%eax
  8015d1:	79 14                	jns    8015e7 <open+0x6f>
		fd_close(fd, 0);
  8015d3:	83 ec 08             	sub    $0x8,%esp
  8015d6:	6a 00                	push   $0x0
  8015d8:	ff 75 f4             	pushl  -0xc(%ebp)
  8015db:	e8 50 f9 ff ff       	call   800f30 <fd_close>
		return r;
  8015e0:	83 c4 10             	add    $0x10,%esp
  8015e3:	89 da                	mov    %ebx,%edx
  8015e5:	eb 17                	jmp    8015fe <open+0x86>
	}

	return fd2num(fd);
  8015e7:	83 ec 0c             	sub    $0xc,%esp
  8015ea:	ff 75 f4             	pushl  -0xc(%ebp)
  8015ed:	e8 1f f8 ff ff       	call   800e11 <fd2num>
  8015f2:	89 c2                	mov    %eax,%edx
  8015f4:	83 c4 10             	add    $0x10,%esp
  8015f7:	eb 05                	jmp    8015fe <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8015f9:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8015fe:	89 d0                	mov    %edx,%eax
  801600:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801603:	c9                   	leave  
  801604:	c3                   	ret    

00801605 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801605:	55                   	push   %ebp
  801606:	89 e5                	mov    %esp,%ebp
  801608:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80160b:	ba 00 00 00 00       	mov    $0x0,%edx
  801610:	b8 08 00 00 00       	mov    $0x8,%eax
  801615:	e8 a6 fd ff ff       	call   8013c0 <fsipc>
}
  80161a:	c9                   	leave  
  80161b:	c3                   	ret    

0080161c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80161c:	55                   	push   %ebp
  80161d:	89 e5                	mov    %esp,%ebp
  80161f:	56                   	push   %esi
  801620:	53                   	push   %ebx
  801621:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801624:	83 ec 0c             	sub    $0xc,%esp
  801627:	ff 75 08             	pushl  0x8(%ebp)
  80162a:	e8 f2 f7 ff ff       	call   800e21 <fd2data>
  80162f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801631:	83 c4 08             	add    $0x8,%esp
  801634:	68 87 23 80 00       	push   $0x802387
  801639:	53                   	push   %ebx
  80163a:	e8 52 f1 ff ff       	call   800791 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80163f:	8b 46 04             	mov    0x4(%esi),%eax
  801642:	2b 06                	sub    (%esi),%eax
  801644:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80164a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801651:	00 00 00 
	stat->st_dev = &devpipe;
  801654:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80165b:	30 80 00 
	return 0;
}
  80165e:	b8 00 00 00 00       	mov    $0x0,%eax
  801663:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801666:	5b                   	pop    %ebx
  801667:	5e                   	pop    %esi
  801668:	5d                   	pop    %ebp
  801669:	c3                   	ret    

0080166a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80166a:	55                   	push   %ebp
  80166b:	89 e5                	mov    %esp,%ebp
  80166d:	53                   	push   %ebx
  80166e:	83 ec 0c             	sub    $0xc,%esp
  801671:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801674:	53                   	push   %ebx
  801675:	6a 00                	push   $0x0
  801677:	e8 9d f5 ff ff       	call   800c19 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80167c:	89 1c 24             	mov    %ebx,(%esp)
  80167f:	e8 9d f7 ff ff       	call   800e21 <fd2data>
  801684:	83 c4 08             	add    $0x8,%esp
  801687:	50                   	push   %eax
  801688:	6a 00                	push   $0x0
  80168a:	e8 8a f5 ff ff       	call   800c19 <sys_page_unmap>
}
  80168f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801692:	c9                   	leave  
  801693:	c3                   	ret    

00801694 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801694:	55                   	push   %ebp
  801695:	89 e5                	mov    %esp,%ebp
  801697:	57                   	push   %edi
  801698:	56                   	push   %esi
  801699:	53                   	push   %ebx
  80169a:	83 ec 1c             	sub    $0x1c,%esp
  80169d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8016a0:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8016a2:	a1 04 40 80 00       	mov    0x804004,%eax
  8016a7:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8016aa:	83 ec 0c             	sub    $0xc,%esp
  8016ad:	ff 75 e0             	pushl  -0x20(%ebp)
  8016b0:	e8 28 05 00 00       	call   801bdd <pageref>
  8016b5:	89 c3                	mov    %eax,%ebx
  8016b7:	89 3c 24             	mov    %edi,(%esp)
  8016ba:	e8 1e 05 00 00       	call   801bdd <pageref>
  8016bf:	83 c4 10             	add    $0x10,%esp
  8016c2:	39 c3                	cmp    %eax,%ebx
  8016c4:	0f 94 c1             	sete   %cl
  8016c7:	0f b6 c9             	movzbl %cl,%ecx
  8016ca:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8016cd:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8016d3:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8016d6:	39 ce                	cmp    %ecx,%esi
  8016d8:	74 1b                	je     8016f5 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8016da:	39 c3                	cmp    %eax,%ebx
  8016dc:	75 c4                	jne    8016a2 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8016de:	8b 42 58             	mov    0x58(%edx),%eax
  8016e1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016e4:	50                   	push   %eax
  8016e5:	56                   	push   %esi
  8016e6:	68 8e 23 80 00       	push   $0x80238e
  8016eb:	e8 fe ea ff ff       	call   8001ee <cprintf>
  8016f0:	83 c4 10             	add    $0x10,%esp
  8016f3:	eb ad                	jmp    8016a2 <_pipeisclosed+0xe>
	}
}
  8016f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016fb:	5b                   	pop    %ebx
  8016fc:	5e                   	pop    %esi
  8016fd:	5f                   	pop    %edi
  8016fe:	5d                   	pop    %ebp
  8016ff:	c3                   	ret    

00801700 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801700:	55                   	push   %ebp
  801701:	89 e5                	mov    %esp,%ebp
  801703:	57                   	push   %edi
  801704:	56                   	push   %esi
  801705:	53                   	push   %ebx
  801706:	83 ec 28             	sub    $0x28,%esp
  801709:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80170c:	56                   	push   %esi
  80170d:	e8 0f f7 ff ff       	call   800e21 <fd2data>
  801712:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801714:	83 c4 10             	add    $0x10,%esp
  801717:	bf 00 00 00 00       	mov    $0x0,%edi
  80171c:	eb 4b                	jmp    801769 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80171e:	89 da                	mov    %ebx,%edx
  801720:	89 f0                	mov    %esi,%eax
  801722:	e8 6d ff ff ff       	call   801694 <_pipeisclosed>
  801727:	85 c0                	test   %eax,%eax
  801729:	75 48                	jne    801773 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80172b:	e8 45 f4 ff ff       	call   800b75 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801730:	8b 43 04             	mov    0x4(%ebx),%eax
  801733:	8b 0b                	mov    (%ebx),%ecx
  801735:	8d 51 20             	lea    0x20(%ecx),%edx
  801738:	39 d0                	cmp    %edx,%eax
  80173a:	73 e2                	jae    80171e <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80173c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80173f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801743:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801746:	89 c2                	mov    %eax,%edx
  801748:	c1 fa 1f             	sar    $0x1f,%edx
  80174b:	89 d1                	mov    %edx,%ecx
  80174d:	c1 e9 1b             	shr    $0x1b,%ecx
  801750:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801753:	83 e2 1f             	and    $0x1f,%edx
  801756:	29 ca                	sub    %ecx,%edx
  801758:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80175c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801760:	83 c0 01             	add    $0x1,%eax
  801763:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801766:	83 c7 01             	add    $0x1,%edi
  801769:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80176c:	75 c2                	jne    801730 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80176e:	8b 45 10             	mov    0x10(%ebp),%eax
  801771:	eb 05                	jmp    801778 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801773:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801778:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80177b:	5b                   	pop    %ebx
  80177c:	5e                   	pop    %esi
  80177d:	5f                   	pop    %edi
  80177e:	5d                   	pop    %ebp
  80177f:	c3                   	ret    

00801780 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801780:	55                   	push   %ebp
  801781:	89 e5                	mov    %esp,%ebp
  801783:	57                   	push   %edi
  801784:	56                   	push   %esi
  801785:	53                   	push   %ebx
  801786:	83 ec 18             	sub    $0x18,%esp
  801789:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80178c:	57                   	push   %edi
  80178d:	e8 8f f6 ff ff       	call   800e21 <fd2data>
  801792:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801794:	83 c4 10             	add    $0x10,%esp
  801797:	bb 00 00 00 00       	mov    $0x0,%ebx
  80179c:	eb 3d                	jmp    8017db <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80179e:	85 db                	test   %ebx,%ebx
  8017a0:	74 04                	je     8017a6 <devpipe_read+0x26>
				return i;
  8017a2:	89 d8                	mov    %ebx,%eax
  8017a4:	eb 44                	jmp    8017ea <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8017a6:	89 f2                	mov    %esi,%edx
  8017a8:	89 f8                	mov    %edi,%eax
  8017aa:	e8 e5 fe ff ff       	call   801694 <_pipeisclosed>
  8017af:	85 c0                	test   %eax,%eax
  8017b1:	75 32                	jne    8017e5 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8017b3:	e8 bd f3 ff ff       	call   800b75 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8017b8:	8b 06                	mov    (%esi),%eax
  8017ba:	3b 46 04             	cmp    0x4(%esi),%eax
  8017bd:	74 df                	je     80179e <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8017bf:	99                   	cltd   
  8017c0:	c1 ea 1b             	shr    $0x1b,%edx
  8017c3:	01 d0                	add    %edx,%eax
  8017c5:	83 e0 1f             	and    $0x1f,%eax
  8017c8:	29 d0                	sub    %edx,%eax
  8017ca:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8017cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017d2:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8017d5:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017d8:	83 c3 01             	add    $0x1,%ebx
  8017db:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8017de:	75 d8                	jne    8017b8 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8017e0:	8b 45 10             	mov    0x10(%ebp),%eax
  8017e3:	eb 05                	jmp    8017ea <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017e5:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8017ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017ed:	5b                   	pop    %ebx
  8017ee:	5e                   	pop    %esi
  8017ef:	5f                   	pop    %edi
  8017f0:	5d                   	pop    %ebp
  8017f1:	c3                   	ret    

008017f2 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8017f2:	55                   	push   %ebp
  8017f3:	89 e5                	mov    %esp,%ebp
  8017f5:	56                   	push   %esi
  8017f6:	53                   	push   %ebx
  8017f7:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8017fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017fd:	50                   	push   %eax
  8017fe:	e8 35 f6 ff ff       	call   800e38 <fd_alloc>
  801803:	83 c4 10             	add    $0x10,%esp
  801806:	89 c2                	mov    %eax,%edx
  801808:	85 c0                	test   %eax,%eax
  80180a:	0f 88 2c 01 00 00    	js     80193c <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801810:	83 ec 04             	sub    $0x4,%esp
  801813:	68 07 04 00 00       	push   $0x407
  801818:	ff 75 f4             	pushl  -0xc(%ebp)
  80181b:	6a 00                	push   $0x0
  80181d:	e8 72 f3 ff ff       	call   800b94 <sys_page_alloc>
  801822:	83 c4 10             	add    $0x10,%esp
  801825:	89 c2                	mov    %eax,%edx
  801827:	85 c0                	test   %eax,%eax
  801829:	0f 88 0d 01 00 00    	js     80193c <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80182f:	83 ec 0c             	sub    $0xc,%esp
  801832:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801835:	50                   	push   %eax
  801836:	e8 fd f5 ff ff       	call   800e38 <fd_alloc>
  80183b:	89 c3                	mov    %eax,%ebx
  80183d:	83 c4 10             	add    $0x10,%esp
  801840:	85 c0                	test   %eax,%eax
  801842:	0f 88 e2 00 00 00    	js     80192a <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801848:	83 ec 04             	sub    $0x4,%esp
  80184b:	68 07 04 00 00       	push   $0x407
  801850:	ff 75 f0             	pushl  -0x10(%ebp)
  801853:	6a 00                	push   $0x0
  801855:	e8 3a f3 ff ff       	call   800b94 <sys_page_alloc>
  80185a:	89 c3                	mov    %eax,%ebx
  80185c:	83 c4 10             	add    $0x10,%esp
  80185f:	85 c0                	test   %eax,%eax
  801861:	0f 88 c3 00 00 00    	js     80192a <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801867:	83 ec 0c             	sub    $0xc,%esp
  80186a:	ff 75 f4             	pushl  -0xc(%ebp)
  80186d:	e8 af f5 ff ff       	call   800e21 <fd2data>
  801872:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801874:	83 c4 0c             	add    $0xc,%esp
  801877:	68 07 04 00 00       	push   $0x407
  80187c:	50                   	push   %eax
  80187d:	6a 00                	push   $0x0
  80187f:	e8 10 f3 ff ff       	call   800b94 <sys_page_alloc>
  801884:	89 c3                	mov    %eax,%ebx
  801886:	83 c4 10             	add    $0x10,%esp
  801889:	85 c0                	test   %eax,%eax
  80188b:	0f 88 89 00 00 00    	js     80191a <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801891:	83 ec 0c             	sub    $0xc,%esp
  801894:	ff 75 f0             	pushl  -0x10(%ebp)
  801897:	e8 85 f5 ff ff       	call   800e21 <fd2data>
  80189c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8018a3:	50                   	push   %eax
  8018a4:	6a 00                	push   $0x0
  8018a6:	56                   	push   %esi
  8018a7:	6a 00                	push   $0x0
  8018a9:	e8 29 f3 ff ff       	call   800bd7 <sys_page_map>
  8018ae:	89 c3                	mov    %eax,%ebx
  8018b0:	83 c4 20             	add    $0x20,%esp
  8018b3:	85 c0                	test   %eax,%eax
  8018b5:	78 55                	js     80190c <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8018b7:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018c0:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8018c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018c5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8018cc:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018d5:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8018d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018da:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8018e1:	83 ec 0c             	sub    $0xc,%esp
  8018e4:	ff 75 f4             	pushl  -0xc(%ebp)
  8018e7:	e8 25 f5 ff ff       	call   800e11 <fd2num>
  8018ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018ef:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8018f1:	83 c4 04             	add    $0x4,%esp
  8018f4:	ff 75 f0             	pushl  -0x10(%ebp)
  8018f7:	e8 15 f5 ff ff       	call   800e11 <fd2num>
  8018fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018ff:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801902:	83 c4 10             	add    $0x10,%esp
  801905:	ba 00 00 00 00       	mov    $0x0,%edx
  80190a:	eb 30                	jmp    80193c <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80190c:	83 ec 08             	sub    $0x8,%esp
  80190f:	56                   	push   %esi
  801910:	6a 00                	push   $0x0
  801912:	e8 02 f3 ff ff       	call   800c19 <sys_page_unmap>
  801917:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80191a:	83 ec 08             	sub    $0x8,%esp
  80191d:	ff 75 f0             	pushl  -0x10(%ebp)
  801920:	6a 00                	push   $0x0
  801922:	e8 f2 f2 ff ff       	call   800c19 <sys_page_unmap>
  801927:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80192a:	83 ec 08             	sub    $0x8,%esp
  80192d:	ff 75 f4             	pushl  -0xc(%ebp)
  801930:	6a 00                	push   $0x0
  801932:	e8 e2 f2 ff ff       	call   800c19 <sys_page_unmap>
  801937:	83 c4 10             	add    $0x10,%esp
  80193a:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80193c:	89 d0                	mov    %edx,%eax
  80193e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801941:	5b                   	pop    %ebx
  801942:	5e                   	pop    %esi
  801943:	5d                   	pop    %ebp
  801944:	c3                   	ret    

00801945 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801945:	55                   	push   %ebp
  801946:	89 e5                	mov    %esp,%ebp
  801948:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80194b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80194e:	50                   	push   %eax
  80194f:	ff 75 08             	pushl  0x8(%ebp)
  801952:	e8 30 f5 ff ff       	call   800e87 <fd_lookup>
  801957:	83 c4 10             	add    $0x10,%esp
  80195a:	85 c0                	test   %eax,%eax
  80195c:	78 18                	js     801976 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80195e:	83 ec 0c             	sub    $0xc,%esp
  801961:	ff 75 f4             	pushl  -0xc(%ebp)
  801964:	e8 b8 f4 ff ff       	call   800e21 <fd2data>
	return _pipeisclosed(fd, p);
  801969:	89 c2                	mov    %eax,%edx
  80196b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80196e:	e8 21 fd ff ff       	call   801694 <_pipeisclosed>
  801973:	83 c4 10             	add    $0x10,%esp
}
  801976:	c9                   	leave  
  801977:	c3                   	ret    

00801978 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801978:	55                   	push   %ebp
  801979:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80197b:	b8 00 00 00 00       	mov    $0x0,%eax
  801980:	5d                   	pop    %ebp
  801981:	c3                   	ret    

00801982 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801982:	55                   	push   %ebp
  801983:	89 e5                	mov    %esp,%ebp
  801985:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801988:	68 a6 23 80 00       	push   $0x8023a6
  80198d:	ff 75 0c             	pushl  0xc(%ebp)
  801990:	e8 fc ed ff ff       	call   800791 <strcpy>
	return 0;
}
  801995:	b8 00 00 00 00       	mov    $0x0,%eax
  80199a:	c9                   	leave  
  80199b:	c3                   	ret    

0080199c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80199c:	55                   	push   %ebp
  80199d:	89 e5                	mov    %esp,%ebp
  80199f:	57                   	push   %edi
  8019a0:	56                   	push   %esi
  8019a1:	53                   	push   %ebx
  8019a2:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019a8:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019ad:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019b3:	eb 2d                	jmp    8019e2 <devcons_write+0x46>
		m = n - tot;
  8019b5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8019b8:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8019ba:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8019bd:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8019c2:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019c5:	83 ec 04             	sub    $0x4,%esp
  8019c8:	53                   	push   %ebx
  8019c9:	03 45 0c             	add    0xc(%ebp),%eax
  8019cc:	50                   	push   %eax
  8019cd:	57                   	push   %edi
  8019ce:	e8 50 ef ff ff       	call   800923 <memmove>
		sys_cputs(buf, m);
  8019d3:	83 c4 08             	add    $0x8,%esp
  8019d6:	53                   	push   %ebx
  8019d7:	57                   	push   %edi
  8019d8:	e8 fb f0 ff ff       	call   800ad8 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019dd:	01 de                	add    %ebx,%esi
  8019df:	83 c4 10             	add    $0x10,%esp
  8019e2:	89 f0                	mov    %esi,%eax
  8019e4:	3b 75 10             	cmp    0x10(%ebp),%esi
  8019e7:	72 cc                	jb     8019b5 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8019e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019ec:	5b                   	pop    %ebx
  8019ed:	5e                   	pop    %esi
  8019ee:	5f                   	pop    %edi
  8019ef:	5d                   	pop    %ebp
  8019f0:	c3                   	ret    

008019f1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019f1:	55                   	push   %ebp
  8019f2:	89 e5                	mov    %esp,%ebp
  8019f4:	83 ec 08             	sub    $0x8,%esp
  8019f7:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8019fc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a00:	74 2a                	je     801a2c <devcons_read+0x3b>
  801a02:	eb 05                	jmp    801a09 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801a04:	e8 6c f1 ff ff       	call   800b75 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801a09:	e8 e8 f0 ff ff       	call   800af6 <sys_cgetc>
  801a0e:	85 c0                	test   %eax,%eax
  801a10:	74 f2                	je     801a04 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801a12:	85 c0                	test   %eax,%eax
  801a14:	78 16                	js     801a2c <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801a16:	83 f8 04             	cmp    $0x4,%eax
  801a19:	74 0c                	je     801a27 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801a1b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a1e:	88 02                	mov    %al,(%edx)
	return 1;
  801a20:	b8 01 00 00 00       	mov    $0x1,%eax
  801a25:	eb 05                	jmp    801a2c <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801a27:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801a2c:	c9                   	leave  
  801a2d:	c3                   	ret    

00801a2e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801a2e:	55                   	push   %ebp
  801a2f:	89 e5                	mov    %esp,%ebp
  801a31:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a34:	8b 45 08             	mov    0x8(%ebp),%eax
  801a37:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801a3a:	6a 01                	push   $0x1
  801a3c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a3f:	50                   	push   %eax
  801a40:	e8 93 f0 ff ff       	call   800ad8 <sys_cputs>
}
  801a45:	83 c4 10             	add    $0x10,%esp
  801a48:	c9                   	leave  
  801a49:	c3                   	ret    

00801a4a <getchar>:

int
getchar(void)
{
  801a4a:	55                   	push   %ebp
  801a4b:	89 e5                	mov    %esp,%ebp
  801a4d:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801a50:	6a 01                	push   $0x1
  801a52:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a55:	50                   	push   %eax
  801a56:	6a 00                	push   $0x0
  801a58:	e8 90 f6 ff ff       	call   8010ed <read>
	if (r < 0)
  801a5d:	83 c4 10             	add    $0x10,%esp
  801a60:	85 c0                	test   %eax,%eax
  801a62:	78 0f                	js     801a73 <getchar+0x29>
		return r;
	if (r < 1)
  801a64:	85 c0                	test   %eax,%eax
  801a66:	7e 06                	jle    801a6e <getchar+0x24>
		return -E_EOF;
	return c;
  801a68:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801a6c:	eb 05                	jmp    801a73 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801a6e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801a73:	c9                   	leave  
  801a74:	c3                   	ret    

00801a75 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801a75:	55                   	push   %ebp
  801a76:	89 e5                	mov    %esp,%ebp
  801a78:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a7b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a7e:	50                   	push   %eax
  801a7f:	ff 75 08             	pushl  0x8(%ebp)
  801a82:	e8 00 f4 ff ff       	call   800e87 <fd_lookup>
  801a87:	83 c4 10             	add    $0x10,%esp
  801a8a:	85 c0                	test   %eax,%eax
  801a8c:	78 11                	js     801a9f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801a8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a91:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a97:	39 10                	cmp    %edx,(%eax)
  801a99:	0f 94 c0             	sete   %al
  801a9c:	0f b6 c0             	movzbl %al,%eax
}
  801a9f:	c9                   	leave  
  801aa0:	c3                   	ret    

00801aa1 <opencons>:

int
opencons(void)
{
  801aa1:	55                   	push   %ebp
  801aa2:	89 e5                	mov    %esp,%ebp
  801aa4:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801aa7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aaa:	50                   	push   %eax
  801aab:	e8 88 f3 ff ff       	call   800e38 <fd_alloc>
  801ab0:	83 c4 10             	add    $0x10,%esp
		return r;
  801ab3:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ab5:	85 c0                	test   %eax,%eax
  801ab7:	78 3e                	js     801af7 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ab9:	83 ec 04             	sub    $0x4,%esp
  801abc:	68 07 04 00 00       	push   $0x407
  801ac1:	ff 75 f4             	pushl  -0xc(%ebp)
  801ac4:	6a 00                	push   $0x0
  801ac6:	e8 c9 f0 ff ff       	call   800b94 <sys_page_alloc>
  801acb:	83 c4 10             	add    $0x10,%esp
		return r;
  801ace:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ad0:	85 c0                	test   %eax,%eax
  801ad2:	78 23                	js     801af7 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ad4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ada:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801add:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801adf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ae2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ae9:	83 ec 0c             	sub    $0xc,%esp
  801aec:	50                   	push   %eax
  801aed:	e8 1f f3 ff ff       	call   800e11 <fd2num>
  801af2:	89 c2                	mov    %eax,%edx
  801af4:	83 c4 10             	add    $0x10,%esp
}
  801af7:	89 d0                	mov    %edx,%eax
  801af9:	c9                   	leave  
  801afa:	c3                   	ret    

00801afb <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801afb:	55                   	push   %ebp
  801afc:	89 e5                	mov    %esp,%ebp
  801afe:	56                   	push   %esi
  801aff:	53                   	push   %ebx
  801b00:	8b 75 08             	mov    0x8(%ebp),%esi
  801b03:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b06:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_recv not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  801b09:	85 c0                	test   %eax,%eax
  801b0b:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801b10:	0f 44 c2             	cmove  %edx,%eax

    int r = sys_ipc_recv(pg);
  801b13:	83 ec 0c             	sub    $0xc,%esp
  801b16:	50                   	push   %eax
  801b17:	e8 28 f2 ff ff       	call   800d44 <sys_ipc_recv>
    int from_env = 0, perm = 0;
    if (r == 0) {
  801b1c:	83 c4 10             	add    $0x10,%esp
  801b1f:	85 c0                	test   %eax,%eax
  801b21:	75 10                	jne    801b33 <ipc_recv+0x38>
        from_env = thisenv->env_ipc_from;
  801b23:	a1 04 40 80 00       	mov    0x804004,%eax
  801b28:	8b 48 74             	mov    0x74(%eax),%ecx
        perm = thisenv->env_ipc_perm;
  801b2b:	8b 50 78             	mov    0x78(%eax),%edx
        r = thisenv->env_ipc_value;
  801b2e:	8b 40 70             	mov    0x70(%eax),%eax
  801b31:	eb 0a                	jmp    801b3d <ipc_recv+0x42>
    } else {
        from_env = 0;
        perm = 0;
  801b33:	ba 00 00 00 00       	mov    $0x0,%edx
    if (r == 0) {
        from_env = thisenv->env_ipc_from;
        perm = thisenv->env_ipc_perm;
        r = thisenv->env_ipc_value;
    } else {
        from_env = 0;
  801b38:	b9 00 00 00 00       	mov    $0x0,%ecx
        perm = 0;
    }

    if (from_env_store) *from_env_store = from_env;
  801b3d:	85 f6                	test   %esi,%esi
  801b3f:	74 02                	je     801b43 <ipc_recv+0x48>
  801b41:	89 0e                	mov    %ecx,(%esi)
    if (perm_store) *perm_store = perm;
  801b43:	85 db                	test   %ebx,%ebx
  801b45:	74 02                	je     801b49 <ipc_recv+0x4e>
  801b47:	89 13                	mov    %edx,(%ebx)

    return r;
}
  801b49:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b4c:	5b                   	pop    %ebx
  801b4d:	5e                   	pop    %esi
  801b4e:	5d                   	pop    %ebp
  801b4f:	c3                   	ret    

00801b50 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b50:	55                   	push   %ebp
  801b51:	89 e5                	mov    %esp,%ebp
  801b53:	57                   	push   %edi
  801b54:	56                   	push   %esi
  801b55:	53                   	push   %ebx
  801b56:	83 ec 0c             	sub    $0xc,%esp
  801b59:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b5c:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b5f:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  801b62:	85 db                	test   %ebx,%ebx
  801b64:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801b69:	0f 44 d8             	cmove  %eax,%ebx
  801b6c:	eb 1c                	jmp    801b8a <ipc_send+0x3a>

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        if (ret != -E_IPC_NOT_RECV)
  801b6e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b71:	74 12                	je     801b85 <ipc_send+0x35>
            panic("ipc_send error %e", ret);
  801b73:	50                   	push   %eax
  801b74:	68 b2 23 80 00       	push   $0x8023b2
  801b79:	6a 40                	push   $0x40
  801b7b:	68 c4 23 80 00       	push   $0x8023c4
  801b80:	e8 90 e5 ff ff       	call   800115 <_panic>
        sys_yield();
  801b85:	e8 eb ef ff ff       	call   800b75 <sys_yield>
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801b8a:	ff 75 14             	pushl  0x14(%ebp)
  801b8d:	53                   	push   %ebx
  801b8e:	56                   	push   %esi
  801b8f:	57                   	push   %edi
  801b90:	e8 8c f1 ff ff       	call   800d21 <sys_ipc_try_send>
  801b95:	83 c4 10             	add    $0x10,%esp
  801b98:	85 c0                	test   %eax,%eax
  801b9a:	75 d2                	jne    801b6e <ipc_send+0x1e>
        if (ret != -E_IPC_NOT_RECV)
            panic("ipc_send error %e", ret);
        sys_yield();
    }
}
  801b9c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b9f:	5b                   	pop    %ebx
  801ba0:	5e                   	pop    %esi
  801ba1:	5f                   	pop    %edi
  801ba2:	5d                   	pop    %ebp
  801ba3:	c3                   	ret    

00801ba4 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ba4:	55                   	push   %ebp
  801ba5:	89 e5                	mov    %esp,%ebp
  801ba7:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801baa:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801baf:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801bb2:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801bb8:	8b 52 50             	mov    0x50(%edx),%edx
  801bbb:	39 ca                	cmp    %ecx,%edx
  801bbd:	75 0d                	jne    801bcc <ipc_find_env+0x28>
			return envs[i].env_id;
  801bbf:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801bc2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801bc7:	8b 40 48             	mov    0x48(%eax),%eax
  801bca:	eb 0f                	jmp    801bdb <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801bcc:	83 c0 01             	add    $0x1,%eax
  801bcf:	3d 00 04 00 00       	cmp    $0x400,%eax
  801bd4:	75 d9                	jne    801baf <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801bd6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bdb:	5d                   	pop    %ebp
  801bdc:	c3                   	ret    

00801bdd <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801bdd:	55                   	push   %ebp
  801bde:	89 e5                	mov    %esp,%ebp
  801be0:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801be3:	89 d0                	mov    %edx,%eax
  801be5:	c1 e8 16             	shr    $0x16,%eax
  801be8:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801bef:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bf4:	f6 c1 01             	test   $0x1,%cl
  801bf7:	74 1d                	je     801c16 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801bf9:	c1 ea 0c             	shr    $0xc,%edx
  801bfc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801c03:	f6 c2 01             	test   $0x1,%dl
  801c06:	74 0e                	je     801c16 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c08:	c1 ea 0c             	shr    $0xc,%edx
  801c0b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c12:	ef 
  801c13:	0f b7 c0             	movzwl %ax,%eax
}
  801c16:	5d                   	pop    %ebp
  801c17:	c3                   	ret    
  801c18:	66 90                	xchg   %ax,%ax
  801c1a:	66 90                	xchg   %ax,%ax
  801c1c:	66 90                	xchg   %ax,%ax
  801c1e:	66 90                	xchg   %ax,%ax

00801c20 <__udivdi3>:
  801c20:	55                   	push   %ebp
  801c21:	57                   	push   %edi
  801c22:	56                   	push   %esi
  801c23:	53                   	push   %ebx
  801c24:	83 ec 1c             	sub    $0x1c,%esp
  801c27:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801c2b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801c2f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801c33:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c37:	85 f6                	test   %esi,%esi
  801c39:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c3d:	89 ca                	mov    %ecx,%edx
  801c3f:	89 f8                	mov    %edi,%eax
  801c41:	75 3d                	jne    801c80 <__udivdi3+0x60>
  801c43:	39 cf                	cmp    %ecx,%edi
  801c45:	0f 87 c5 00 00 00    	ja     801d10 <__udivdi3+0xf0>
  801c4b:	85 ff                	test   %edi,%edi
  801c4d:	89 fd                	mov    %edi,%ebp
  801c4f:	75 0b                	jne    801c5c <__udivdi3+0x3c>
  801c51:	b8 01 00 00 00       	mov    $0x1,%eax
  801c56:	31 d2                	xor    %edx,%edx
  801c58:	f7 f7                	div    %edi
  801c5a:	89 c5                	mov    %eax,%ebp
  801c5c:	89 c8                	mov    %ecx,%eax
  801c5e:	31 d2                	xor    %edx,%edx
  801c60:	f7 f5                	div    %ebp
  801c62:	89 c1                	mov    %eax,%ecx
  801c64:	89 d8                	mov    %ebx,%eax
  801c66:	89 cf                	mov    %ecx,%edi
  801c68:	f7 f5                	div    %ebp
  801c6a:	89 c3                	mov    %eax,%ebx
  801c6c:	89 d8                	mov    %ebx,%eax
  801c6e:	89 fa                	mov    %edi,%edx
  801c70:	83 c4 1c             	add    $0x1c,%esp
  801c73:	5b                   	pop    %ebx
  801c74:	5e                   	pop    %esi
  801c75:	5f                   	pop    %edi
  801c76:	5d                   	pop    %ebp
  801c77:	c3                   	ret    
  801c78:	90                   	nop
  801c79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c80:	39 ce                	cmp    %ecx,%esi
  801c82:	77 74                	ja     801cf8 <__udivdi3+0xd8>
  801c84:	0f bd fe             	bsr    %esi,%edi
  801c87:	83 f7 1f             	xor    $0x1f,%edi
  801c8a:	0f 84 98 00 00 00    	je     801d28 <__udivdi3+0x108>
  801c90:	bb 20 00 00 00       	mov    $0x20,%ebx
  801c95:	89 f9                	mov    %edi,%ecx
  801c97:	89 c5                	mov    %eax,%ebp
  801c99:	29 fb                	sub    %edi,%ebx
  801c9b:	d3 e6                	shl    %cl,%esi
  801c9d:	89 d9                	mov    %ebx,%ecx
  801c9f:	d3 ed                	shr    %cl,%ebp
  801ca1:	89 f9                	mov    %edi,%ecx
  801ca3:	d3 e0                	shl    %cl,%eax
  801ca5:	09 ee                	or     %ebp,%esi
  801ca7:	89 d9                	mov    %ebx,%ecx
  801ca9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801cad:	89 d5                	mov    %edx,%ebp
  801caf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801cb3:	d3 ed                	shr    %cl,%ebp
  801cb5:	89 f9                	mov    %edi,%ecx
  801cb7:	d3 e2                	shl    %cl,%edx
  801cb9:	89 d9                	mov    %ebx,%ecx
  801cbb:	d3 e8                	shr    %cl,%eax
  801cbd:	09 c2                	or     %eax,%edx
  801cbf:	89 d0                	mov    %edx,%eax
  801cc1:	89 ea                	mov    %ebp,%edx
  801cc3:	f7 f6                	div    %esi
  801cc5:	89 d5                	mov    %edx,%ebp
  801cc7:	89 c3                	mov    %eax,%ebx
  801cc9:	f7 64 24 0c          	mull   0xc(%esp)
  801ccd:	39 d5                	cmp    %edx,%ebp
  801ccf:	72 10                	jb     801ce1 <__udivdi3+0xc1>
  801cd1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801cd5:	89 f9                	mov    %edi,%ecx
  801cd7:	d3 e6                	shl    %cl,%esi
  801cd9:	39 c6                	cmp    %eax,%esi
  801cdb:	73 07                	jae    801ce4 <__udivdi3+0xc4>
  801cdd:	39 d5                	cmp    %edx,%ebp
  801cdf:	75 03                	jne    801ce4 <__udivdi3+0xc4>
  801ce1:	83 eb 01             	sub    $0x1,%ebx
  801ce4:	31 ff                	xor    %edi,%edi
  801ce6:	89 d8                	mov    %ebx,%eax
  801ce8:	89 fa                	mov    %edi,%edx
  801cea:	83 c4 1c             	add    $0x1c,%esp
  801ced:	5b                   	pop    %ebx
  801cee:	5e                   	pop    %esi
  801cef:	5f                   	pop    %edi
  801cf0:	5d                   	pop    %ebp
  801cf1:	c3                   	ret    
  801cf2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cf8:	31 ff                	xor    %edi,%edi
  801cfa:	31 db                	xor    %ebx,%ebx
  801cfc:	89 d8                	mov    %ebx,%eax
  801cfe:	89 fa                	mov    %edi,%edx
  801d00:	83 c4 1c             	add    $0x1c,%esp
  801d03:	5b                   	pop    %ebx
  801d04:	5e                   	pop    %esi
  801d05:	5f                   	pop    %edi
  801d06:	5d                   	pop    %ebp
  801d07:	c3                   	ret    
  801d08:	90                   	nop
  801d09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d10:	89 d8                	mov    %ebx,%eax
  801d12:	f7 f7                	div    %edi
  801d14:	31 ff                	xor    %edi,%edi
  801d16:	89 c3                	mov    %eax,%ebx
  801d18:	89 d8                	mov    %ebx,%eax
  801d1a:	89 fa                	mov    %edi,%edx
  801d1c:	83 c4 1c             	add    $0x1c,%esp
  801d1f:	5b                   	pop    %ebx
  801d20:	5e                   	pop    %esi
  801d21:	5f                   	pop    %edi
  801d22:	5d                   	pop    %ebp
  801d23:	c3                   	ret    
  801d24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d28:	39 ce                	cmp    %ecx,%esi
  801d2a:	72 0c                	jb     801d38 <__udivdi3+0x118>
  801d2c:	31 db                	xor    %ebx,%ebx
  801d2e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801d32:	0f 87 34 ff ff ff    	ja     801c6c <__udivdi3+0x4c>
  801d38:	bb 01 00 00 00       	mov    $0x1,%ebx
  801d3d:	e9 2a ff ff ff       	jmp    801c6c <__udivdi3+0x4c>
  801d42:	66 90                	xchg   %ax,%ax
  801d44:	66 90                	xchg   %ax,%ax
  801d46:	66 90                	xchg   %ax,%ax
  801d48:	66 90                	xchg   %ax,%ax
  801d4a:	66 90                	xchg   %ax,%ax
  801d4c:	66 90                	xchg   %ax,%ax
  801d4e:	66 90                	xchg   %ax,%ax

00801d50 <__umoddi3>:
  801d50:	55                   	push   %ebp
  801d51:	57                   	push   %edi
  801d52:	56                   	push   %esi
  801d53:	53                   	push   %ebx
  801d54:	83 ec 1c             	sub    $0x1c,%esp
  801d57:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801d5b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d5f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d63:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d67:	85 d2                	test   %edx,%edx
  801d69:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801d6d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d71:	89 f3                	mov    %esi,%ebx
  801d73:	89 3c 24             	mov    %edi,(%esp)
  801d76:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d7a:	75 1c                	jne    801d98 <__umoddi3+0x48>
  801d7c:	39 f7                	cmp    %esi,%edi
  801d7e:	76 50                	jbe    801dd0 <__umoddi3+0x80>
  801d80:	89 c8                	mov    %ecx,%eax
  801d82:	89 f2                	mov    %esi,%edx
  801d84:	f7 f7                	div    %edi
  801d86:	89 d0                	mov    %edx,%eax
  801d88:	31 d2                	xor    %edx,%edx
  801d8a:	83 c4 1c             	add    $0x1c,%esp
  801d8d:	5b                   	pop    %ebx
  801d8e:	5e                   	pop    %esi
  801d8f:	5f                   	pop    %edi
  801d90:	5d                   	pop    %ebp
  801d91:	c3                   	ret    
  801d92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d98:	39 f2                	cmp    %esi,%edx
  801d9a:	89 d0                	mov    %edx,%eax
  801d9c:	77 52                	ja     801df0 <__umoddi3+0xa0>
  801d9e:	0f bd ea             	bsr    %edx,%ebp
  801da1:	83 f5 1f             	xor    $0x1f,%ebp
  801da4:	75 5a                	jne    801e00 <__umoddi3+0xb0>
  801da6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801daa:	0f 82 e0 00 00 00    	jb     801e90 <__umoddi3+0x140>
  801db0:	39 0c 24             	cmp    %ecx,(%esp)
  801db3:	0f 86 d7 00 00 00    	jbe    801e90 <__umoddi3+0x140>
  801db9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801dbd:	8b 54 24 04          	mov    0x4(%esp),%edx
  801dc1:	83 c4 1c             	add    $0x1c,%esp
  801dc4:	5b                   	pop    %ebx
  801dc5:	5e                   	pop    %esi
  801dc6:	5f                   	pop    %edi
  801dc7:	5d                   	pop    %ebp
  801dc8:	c3                   	ret    
  801dc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801dd0:	85 ff                	test   %edi,%edi
  801dd2:	89 fd                	mov    %edi,%ebp
  801dd4:	75 0b                	jne    801de1 <__umoddi3+0x91>
  801dd6:	b8 01 00 00 00       	mov    $0x1,%eax
  801ddb:	31 d2                	xor    %edx,%edx
  801ddd:	f7 f7                	div    %edi
  801ddf:	89 c5                	mov    %eax,%ebp
  801de1:	89 f0                	mov    %esi,%eax
  801de3:	31 d2                	xor    %edx,%edx
  801de5:	f7 f5                	div    %ebp
  801de7:	89 c8                	mov    %ecx,%eax
  801de9:	f7 f5                	div    %ebp
  801deb:	89 d0                	mov    %edx,%eax
  801ded:	eb 99                	jmp    801d88 <__umoddi3+0x38>
  801def:	90                   	nop
  801df0:	89 c8                	mov    %ecx,%eax
  801df2:	89 f2                	mov    %esi,%edx
  801df4:	83 c4 1c             	add    $0x1c,%esp
  801df7:	5b                   	pop    %ebx
  801df8:	5e                   	pop    %esi
  801df9:	5f                   	pop    %edi
  801dfa:	5d                   	pop    %ebp
  801dfb:	c3                   	ret    
  801dfc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e00:	8b 34 24             	mov    (%esp),%esi
  801e03:	bf 20 00 00 00       	mov    $0x20,%edi
  801e08:	89 e9                	mov    %ebp,%ecx
  801e0a:	29 ef                	sub    %ebp,%edi
  801e0c:	d3 e0                	shl    %cl,%eax
  801e0e:	89 f9                	mov    %edi,%ecx
  801e10:	89 f2                	mov    %esi,%edx
  801e12:	d3 ea                	shr    %cl,%edx
  801e14:	89 e9                	mov    %ebp,%ecx
  801e16:	09 c2                	or     %eax,%edx
  801e18:	89 d8                	mov    %ebx,%eax
  801e1a:	89 14 24             	mov    %edx,(%esp)
  801e1d:	89 f2                	mov    %esi,%edx
  801e1f:	d3 e2                	shl    %cl,%edx
  801e21:	89 f9                	mov    %edi,%ecx
  801e23:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e27:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801e2b:	d3 e8                	shr    %cl,%eax
  801e2d:	89 e9                	mov    %ebp,%ecx
  801e2f:	89 c6                	mov    %eax,%esi
  801e31:	d3 e3                	shl    %cl,%ebx
  801e33:	89 f9                	mov    %edi,%ecx
  801e35:	89 d0                	mov    %edx,%eax
  801e37:	d3 e8                	shr    %cl,%eax
  801e39:	89 e9                	mov    %ebp,%ecx
  801e3b:	09 d8                	or     %ebx,%eax
  801e3d:	89 d3                	mov    %edx,%ebx
  801e3f:	89 f2                	mov    %esi,%edx
  801e41:	f7 34 24             	divl   (%esp)
  801e44:	89 d6                	mov    %edx,%esi
  801e46:	d3 e3                	shl    %cl,%ebx
  801e48:	f7 64 24 04          	mull   0x4(%esp)
  801e4c:	39 d6                	cmp    %edx,%esi
  801e4e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e52:	89 d1                	mov    %edx,%ecx
  801e54:	89 c3                	mov    %eax,%ebx
  801e56:	72 08                	jb     801e60 <__umoddi3+0x110>
  801e58:	75 11                	jne    801e6b <__umoddi3+0x11b>
  801e5a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801e5e:	73 0b                	jae    801e6b <__umoddi3+0x11b>
  801e60:	2b 44 24 04          	sub    0x4(%esp),%eax
  801e64:	1b 14 24             	sbb    (%esp),%edx
  801e67:	89 d1                	mov    %edx,%ecx
  801e69:	89 c3                	mov    %eax,%ebx
  801e6b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801e6f:	29 da                	sub    %ebx,%edx
  801e71:	19 ce                	sbb    %ecx,%esi
  801e73:	89 f9                	mov    %edi,%ecx
  801e75:	89 f0                	mov    %esi,%eax
  801e77:	d3 e0                	shl    %cl,%eax
  801e79:	89 e9                	mov    %ebp,%ecx
  801e7b:	d3 ea                	shr    %cl,%edx
  801e7d:	89 e9                	mov    %ebp,%ecx
  801e7f:	d3 ee                	shr    %cl,%esi
  801e81:	09 d0                	or     %edx,%eax
  801e83:	89 f2                	mov    %esi,%edx
  801e85:	83 c4 1c             	add    $0x1c,%esp
  801e88:	5b                   	pop    %ebx
  801e89:	5e                   	pop    %esi
  801e8a:	5f                   	pop    %edi
  801e8b:	5d                   	pop    %ebp
  801e8c:	c3                   	ret    
  801e8d:	8d 76 00             	lea    0x0(%esi),%esi
  801e90:	29 f9                	sub    %edi,%ecx
  801e92:	19 d6                	sbb    %edx,%esi
  801e94:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e98:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e9c:	e9 18 ff ff ff       	jmp    801db9 <__umoddi3+0x69>
