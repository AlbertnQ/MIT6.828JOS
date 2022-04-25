
obj/user/sh.debug:     file format elf32-i386


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
  80002c:	e8 84 09 00 00       	call   8009b5 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <_gettoken>:
#define WHITESPACE " \t\r\n"
#define SYMBOLS "<|>&;()"

int
_gettoken(char *s, char **p1, char **p2)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 0c             	sub    $0xc,%esp
  80003c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80003f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int t;

	if (s == 0) {
  800042:	85 db                	test   %ebx,%ebx
  800044:	75 2c                	jne    800072 <_gettoken+0x3f>
		if (debug > 1)
			cprintf("GETTOKEN NULL\n");
		return 0;
  800046:	b8 00 00 00 00       	mov    $0x0,%eax
_gettoken(char *s, char **p1, char **p2)
{
	int t;

	if (s == 0) {
		if (debug > 1)
  80004b:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800052:	0f 8e 3e 01 00 00    	jle    800196 <_gettoken+0x163>
			cprintf("GETTOKEN NULL\n");
  800058:	83 ec 0c             	sub    $0xc,%esp
  80005b:	68 a0 32 80 00       	push   $0x8032a0
  800060:	e8 89 0a 00 00       	call   800aee <cprintf>
  800065:	83 c4 10             	add    $0x10,%esp
		return 0;
  800068:	b8 00 00 00 00       	mov    $0x0,%eax
  80006d:	e9 24 01 00 00       	jmp    800196 <_gettoken+0x163>
	}

	if (debug > 1)
  800072:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800079:	7e 11                	jle    80008c <_gettoken+0x59>
		cprintf("GETTOKEN: %s\n", s);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	53                   	push   %ebx
  80007f:	68 af 32 80 00       	push   $0x8032af
  800084:	e8 65 0a 00 00       	call   800aee <cprintf>
  800089:	83 c4 10             	add    $0x10,%esp

	*p1 = 0;
  80008c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	*p2 = 0;
  800092:	8b 45 10             	mov    0x10(%ebp),%eax
  800095:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	while (strchr(WHITESPACE, *s))
  80009b:	eb 07                	jmp    8000a4 <_gettoken+0x71>
		*s++ = 0;
  80009d:	83 c3 01             	add    $0x1,%ebx
  8000a0:	c6 43 ff 00          	movb   $0x0,-0x1(%ebx)
		cprintf("GETTOKEN: %s\n", s);

	*p1 = 0;
	*p2 = 0;

	while (strchr(WHITESPACE, *s))
  8000a4:	83 ec 08             	sub    $0x8,%esp
  8000a7:	0f be 03             	movsbl (%ebx),%eax
  8000aa:	50                   	push   %eax
  8000ab:	68 bd 32 80 00       	push   $0x8032bd
  8000b0:	e8 d7 11 00 00       	call   80128c <strchr>
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	85 c0                	test   %eax,%eax
  8000ba:	75 e1                	jne    80009d <_gettoken+0x6a>
		*s++ = 0;
	if (*s == 0) {
  8000bc:	0f b6 03             	movzbl (%ebx),%eax
  8000bf:	84 c0                	test   %al,%al
  8000c1:	75 2c                	jne    8000ef <_gettoken+0xbc>
		if (debug > 1)
			cprintf("EOL\n");
		return 0;
  8000c3:	b8 00 00 00 00       	mov    $0x0,%eax
	*p2 = 0;

	while (strchr(WHITESPACE, *s))
		*s++ = 0;
	if (*s == 0) {
		if (debug > 1)
  8000c8:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  8000cf:	0f 8e c1 00 00 00    	jle    800196 <_gettoken+0x163>
			cprintf("EOL\n");
  8000d5:	83 ec 0c             	sub    $0xc,%esp
  8000d8:	68 c2 32 80 00       	push   $0x8032c2
  8000dd:	e8 0c 0a 00 00       	call   800aee <cprintf>
  8000e2:	83 c4 10             	add    $0x10,%esp
		return 0;
  8000e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ea:	e9 a7 00 00 00       	jmp    800196 <_gettoken+0x163>
	}
	if (strchr(SYMBOLS, *s)) {
  8000ef:	83 ec 08             	sub    $0x8,%esp
  8000f2:	0f be c0             	movsbl %al,%eax
  8000f5:	50                   	push   %eax
  8000f6:	68 d3 32 80 00       	push   $0x8032d3
  8000fb:	e8 8c 11 00 00       	call   80128c <strchr>
  800100:	83 c4 10             	add    $0x10,%esp
  800103:	85 c0                	test   %eax,%eax
  800105:	74 30                	je     800137 <_gettoken+0x104>
		t = *s;
  800107:	0f be 3b             	movsbl (%ebx),%edi
		*p1 = s;
  80010a:	89 1e                	mov    %ebx,(%esi)
		*s++ = 0;
  80010c:	c6 03 00             	movb   $0x0,(%ebx)
		*p2 = s;
  80010f:	83 c3 01             	add    $0x1,%ebx
  800112:	8b 45 10             	mov    0x10(%ebp),%eax
  800115:	89 18                	mov    %ebx,(%eax)
		if (debug > 1)
			cprintf("TOK %c\n", t);
		return t;
  800117:	89 f8                	mov    %edi,%eax
	if (strchr(SYMBOLS, *s)) {
		t = *s;
		*p1 = s;
		*s++ = 0;
		*p2 = s;
		if (debug > 1)
  800119:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800120:	7e 74                	jle    800196 <_gettoken+0x163>
			cprintf("TOK %c\n", t);
  800122:	83 ec 08             	sub    $0x8,%esp
  800125:	57                   	push   %edi
  800126:	68 c7 32 80 00       	push   $0x8032c7
  80012b:	e8 be 09 00 00       	call   800aee <cprintf>
  800130:	83 c4 10             	add    $0x10,%esp
		return t;
  800133:	89 f8                	mov    %edi,%eax
  800135:	eb 5f                	jmp    800196 <_gettoken+0x163>
	}
	*p1 = s;
  800137:	89 1e                	mov    %ebx,(%esi)
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  800139:	eb 03                	jmp    80013e <_gettoken+0x10b>
		s++;
  80013b:	83 c3 01             	add    $0x1,%ebx
		if (debug > 1)
			cprintf("TOK %c\n", t);
		return t;
	}
	*p1 = s;
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  80013e:	0f b6 03             	movzbl (%ebx),%eax
  800141:	84 c0                	test   %al,%al
  800143:	74 18                	je     80015d <_gettoken+0x12a>
  800145:	83 ec 08             	sub    $0x8,%esp
  800148:	0f be c0             	movsbl %al,%eax
  80014b:	50                   	push   %eax
  80014c:	68 cf 32 80 00       	push   $0x8032cf
  800151:	e8 36 11 00 00       	call   80128c <strchr>
  800156:	83 c4 10             	add    $0x10,%esp
  800159:	85 c0                	test   %eax,%eax
  80015b:	74 de                	je     80013b <_gettoken+0x108>
		s++;
	*p2 = s;
  80015d:	8b 45 10             	mov    0x10(%ebp),%eax
  800160:	89 18                	mov    %ebx,(%eax)
		t = **p2;
		**p2 = 0;
		cprintf("WORD: %s\n", *p1);
		**p2 = t;
	}
	return 'w';
  800162:	b8 77 00 00 00       	mov    $0x77,%eax
	}
	*p1 = s;
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
		s++;
	*p2 = s;
	if (debug > 1) {
  800167:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  80016e:	7e 26                	jle    800196 <_gettoken+0x163>
		t = **p2;
  800170:	0f b6 3b             	movzbl (%ebx),%edi
		**p2 = 0;
  800173:	c6 03 00             	movb   $0x0,(%ebx)
		cprintf("WORD: %s\n", *p1);
  800176:	83 ec 08             	sub    $0x8,%esp
  800179:	ff 36                	pushl  (%esi)
  80017b:	68 db 32 80 00       	push   $0x8032db
  800180:	e8 69 09 00 00       	call   800aee <cprintf>
		**p2 = t;
  800185:	8b 45 10             	mov    0x10(%ebp),%eax
  800188:	8b 00                	mov    (%eax),%eax
  80018a:	89 fa                	mov    %edi,%edx
  80018c:	88 10                	mov    %dl,(%eax)
  80018e:	83 c4 10             	add    $0x10,%esp
	}
	return 'w';
  800191:	b8 77 00 00 00       	mov    $0x77,%eax
}
  800196:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800199:	5b                   	pop    %ebx
  80019a:	5e                   	pop    %esi
  80019b:	5f                   	pop    %edi
  80019c:	5d                   	pop    %ebp
  80019d:	c3                   	ret    

0080019e <gettoken>:

int
gettoken(char *s, char **p1)
{
  80019e:	55                   	push   %ebp
  80019f:	89 e5                	mov    %esp,%ebp
  8001a1:	83 ec 08             	sub    $0x8,%esp
  8001a4:	8b 45 08             	mov    0x8(%ebp),%eax
	static int c, nc;
	static char* np1, *np2;

	if (s) {
  8001a7:	85 c0                	test   %eax,%eax
  8001a9:	74 22                	je     8001cd <gettoken+0x2f>
		nc = _gettoken(s, &np1, &np2);
  8001ab:	83 ec 04             	sub    $0x4,%esp
  8001ae:	68 0c 50 80 00       	push   $0x80500c
  8001b3:	68 10 50 80 00       	push   $0x805010
  8001b8:	50                   	push   %eax
  8001b9:	e8 75 fe ff ff       	call   800033 <_gettoken>
  8001be:	a3 08 50 80 00       	mov    %eax,0x805008
		return 0;
  8001c3:	83 c4 10             	add    $0x10,%esp
  8001c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8001cb:	eb 3a                	jmp    800207 <gettoken+0x69>
	}
	c = nc;
  8001cd:	a1 08 50 80 00       	mov    0x805008,%eax
  8001d2:	a3 04 50 80 00       	mov    %eax,0x805004
	*p1 = np1;
  8001d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001da:	8b 15 10 50 80 00    	mov    0x805010,%edx
  8001e0:	89 10                	mov    %edx,(%eax)
	nc = _gettoken(np2, &np1, &np2);
  8001e2:	83 ec 04             	sub    $0x4,%esp
  8001e5:	68 0c 50 80 00       	push   $0x80500c
  8001ea:	68 10 50 80 00       	push   $0x805010
  8001ef:	ff 35 0c 50 80 00    	pushl  0x80500c
  8001f5:	e8 39 fe ff ff       	call   800033 <_gettoken>
  8001fa:	a3 08 50 80 00       	mov    %eax,0x805008
	return c;
  8001ff:	a1 04 50 80 00       	mov    0x805004,%eax
  800204:	83 c4 10             	add    $0x10,%esp
}
  800207:	c9                   	leave  
  800208:	c3                   	ret    

00800209 <runcmd>:
// runcmd() is called in a forked child,
// so it's OK to manipulate file descriptor state.
#define MAXARGS 16
void
runcmd(char* s)
{
  800209:	55                   	push   %ebp
  80020a:	89 e5                	mov    %esp,%ebp
  80020c:	57                   	push   %edi
  80020d:	56                   	push   %esi
  80020e:	53                   	push   %ebx
  80020f:	81 ec 64 04 00 00    	sub    $0x464,%esp
	char *argv[MAXARGS], *t, argv0buf[BUFSIZ];
	int argc, c, i, r, p[2], fd, pipe_child;

	pipe_child = 0;
	gettoken(s, 0);
  800215:	6a 00                	push   $0x0
  800217:	ff 75 08             	pushl  0x8(%ebp)
  80021a:	e8 7f ff ff ff       	call   80019e <gettoken>
  80021f:	83 c4 10             	add    $0x10,%esp

again:
	argc = 0;
	while (1) {
		switch ((c = gettoken(0, &t))) {
  800222:	8d 5d a4             	lea    -0x5c(%ebp),%ebx

	pipe_child = 0;
	gettoken(s, 0);

again:
	argc = 0;
  800225:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		switch ((c = gettoken(0, &t))) {
  80022a:	83 ec 08             	sub    $0x8,%esp
  80022d:	53                   	push   %ebx
  80022e:	6a 00                	push   $0x0
  800230:	e8 69 ff ff ff       	call   80019e <gettoken>
  800235:	83 c4 10             	add    $0x10,%esp
  800238:	83 f8 3e             	cmp    $0x3e,%eax
  80023b:	0f 84 cc 00 00 00    	je     80030d <runcmd+0x104>
  800241:	83 f8 3e             	cmp    $0x3e,%eax
  800244:	7f 12                	jg     800258 <runcmd+0x4f>
  800246:	85 c0                	test   %eax,%eax
  800248:	0f 84 3b 02 00 00    	je     800489 <runcmd+0x280>
  80024e:	83 f8 3c             	cmp    $0x3c,%eax
  800251:	74 3e                	je     800291 <runcmd+0x88>
  800253:	e9 1f 02 00 00       	jmp    800477 <runcmd+0x26e>
  800258:	83 f8 77             	cmp    $0x77,%eax
  80025b:	74 0e                	je     80026b <runcmd+0x62>
  80025d:	83 f8 7c             	cmp    $0x7c,%eax
  800260:	0f 84 25 01 00 00    	je     80038b <runcmd+0x182>
  800266:	e9 0c 02 00 00       	jmp    800477 <runcmd+0x26e>

		case 'w':	// Add an argument
			if (argc == MAXARGS) {
  80026b:	83 fe 10             	cmp    $0x10,%esi
  80026e:	75 15                	jne    800285 <runcmd+0x7c>
				cprintf("too many arguments\n");
  800270:	83 ec 0c             	sub    $0xc,%esp
  800273:	68 e5 32 80 00       	push   $0x8032e5
  800278:	e8 71 08 00 00       	call   800aee <cprintf>
				exit();
  80027d:	e8 79 07 00 00       	call   8009fb <exit>
  800282:	83 c4 10             	add    $0x10,%esp
			}
			argv[argc++] = t;
  800285:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  800288:	89 44 b5 a8          	mov    %eax,-0x58(%ebp,%esi,4)
  80028c:	8d 76 01             	lea    0x1(%esi),%esi
			break;
  80028f:	eb 99                	jmp    80022a <runcmd+0x21>

		case '<':	// Input redirection
			// Grab the filename from the argument list
			if (gettoken(0, &t) != 'w') {
  800291:	83 ec 08             	sub    $0x8,%esp
  800294:	53                   	push   %ebx
  800295:	6a 00                	push   $0x0
  800297:	e8 02 ff ff ff       	call   80019e <gettoken>
  80029c:	83 c4 10             	add    $0x10,%esp
  80029f:	83 f8 77             	cmp    $0x77,%eax
  8002a2:	74 15                	je     8002b9 <runcmd+0xb0>
				cprintf("syntax error: < not followed by word\n");
  8002a4:	83 ec 0c             	sub    $0xc,%esp
  8002a7:	68 38 34 80 00       	push   $0x803438
  8002ac:	e8 3d 08 00 00       	call   800aee <cprintf>
				exit();
  8002b1:	e8 45 07 00 00       	call   8009fb <exit>
  8002b6:	83 c4 10             	add    $0x10,%esp
			// If not, dup 'fd' onto file descriptor 0,
			// then close the original 'fd'.

			// LAB 5: Your code here.
			//panic("< redirection not implemented");
			if ( (fd = open(t, O_RDONLY) )< 0 ) {
  8002b9:	83 ec 08             	sub    $0x8,%esp
  8002bc:	6a 00                	push   $0x0
  8002be:	ff 75 a4             	pushl  -0x5c(%ebp)
  8002c1:	e8 7d 20 00 00       	call   802343 <open>
  8002c6:	89 c7                	mov    %eax,%edi
  8002c8:	83 c4 10             	add    $0x10,%esp
  8002cb:	85 c0                	test   %eax,%eax
  8002cd:	79 1b                	jns    8002ea <runcmd+0xe1>
                		cprintf("open %s for read: %e", t, fd);
  8002cf:	83 ec 04             	sub    $0x4,%esp
  8002d2:	50                   	push   %eax
  8002d3:	ff 75 a4             	pushl  -0x5c(%ebp)
  8002d6:	68 f9 32 80 00       	push   $0x8032f9
  8002db:	e8 0e 08 00 00       	call   800aee <cprintf>
                		exit();
  8002e0:	e8 16 07 00 00       	call   8009fb <exit>
  8002e5:	83 c4 10             	add    $0x10,%esp
  8002e8:	eb 08                	jmp    8002f2 <runcmd+0xe9>
            		}
		        if (fd != 0) {
  8002ea:	85 c0                	test   %eax,%eax
  8002ec:	0f 84 38 ff ff ff    	je     80022a <runcmd+0x21>
				dup(fd, 0);
  8002f2:	83 ec 08             	sub    $0x8,%esp
  8002f5:	6a 00                	push   $0x0
  8002f7:	57                   	push   %edi
  8002f8:	e8 cf 1a 00 00       	call   801dcc <dup>
				close(fd);
  8002fd:	89 3c 24             	mov    %edi,(%esp)
  800300:	e8 77 1a 00 00       	call   801d7c <close>
  800305:	83 c4 10             	add    $0x10,%esp
  800308:	e9 1d ff ff ff       	jmp    80022a <runcmd+0x21>
		    	}
			break;

		case '>':	// Output redirection
			// Grab the filename from the argument list
			if (gettoken(0, &t) != 'w') {
  80030d:	83 ec 08             	sub    $0x8,%esp
  800310:	53                   	push   %ebx
  800311:	6a 00                	push   $0x0
  800313:	e8 86 fe ff ff       	call   80019e <gettoken>
  800318:	83 c4 10             	add    $0x10,%esp
  80031b:	83 f8 77             	cmp    $0x77,%eax
  80031e:	74 15                	je     800335 <runcmd+0x12c>
				cprintf("syntax error: > not followed by word\n");
  800320:	83 ec 0c             	sub    $0xc,%esp
  800323:	68 60 34 80 00       	push   $0x803460
  800328:	e8 c1 07 00 00       	call   800aee <cprintf>
				exit();
  80032d:	e8 c9 06 00 00       	call   8009fb <exit>
  800332:	83 c4 10             	add    $0x10,%esp
			}
			if ((fd = open(t, O_WRONLY|O_CREAT|O_TRUNC)) < 0) {
  800335:	83 ec 08             	sub    $0x8,%esp
  800338:	68 01 03 00 00       	push   $0x301
  80033d:	ff 75 a4             	pushl  -0x5c(%ebp)
  800340:	e8 fe 1f 00 00       	call   802343 <open>
  800345:	89 c7                	mov    %eax,%edi
  800347:	83 c4 10             	add    $0x10,%esp
  80034a:	85 c0                	test   %eax,%eax
  80034c:	79 19                	jns    800367 <runcmd+0x15e>
				cprintf("open %s for write: %e", t, fd);
  80034e:	83 ec 04             	sub    $0x4,%esp
  800351:	50                   	push   %eax
  800352:	ff 75 a4             	pushl  -0x5c(%ebp)
  800355:	68 0e 33 80 00       	push   $0x80330e
  80035a:	e8 8f 07 00 00       	call   800aee <cprintf>
				exit();
  80035f:	e8 97 06 00 00       	call   8009fb <exit>
  800364:	83 c4 10             	add    $0x10,%esp
			}
			if (fd != 1) {
  800367:	83 ff 01             	cmp    $0x1,%edi
  80036a:	0f 84 ba fe ff ff    	je     80022a <runcmd+0x21>
				dup(fd, 1);
  800370:	83 ec 08             	sub    $0x8,%esp
  800373:	6a 01                	push   $0x1
  800375:	57                   	push   %edi
  800376:	e8 51 1a 00 00       	call   801dcc <dup>
				close(fd);
  80037b:	89 3c 24             	mov    %edi,(%esp)
  80037e:	e8 f9 19 00 00       	call   801d7c <close>
  800383:	83 c4 10             	add    $0x10,%esp
  800386:	e9 9f fe ff ff       	jmp    80022a <runcmd+0x21>
			}
			break;

		case '|':	// Pipe
			if ((r = pipe(p)) < 0) {
  80038b:	83 ec 0c             	sub    $0xc,%esp
  80038e:	8d 85 9c fb ff ff    	lea    -0x464(%ebp),%eax
  800394:	50                   	push   %eax
  800395:	e8 e7 28 00 00       	call   802c81 <pipe>
  80039a:	83 c4 10             	add    $0x10,%esp
  80039d:	85 c0                	test   %eax,%eax
  80039f:	79 16                	jns    8003b7 <runcmd+0x1ae>
				cprintf("pipe: %e", r);
  8003a1:	83 ec 08             	sub    $0x8,%esp
  8003a4:	50                   	push   %eax
  8003a5:	68 24 33 80 00       	push   $0x803324
  8003aa:	e8 3f 07 00 00       	call   800aee <cprintf>
				exit();
  8003af:	e8 47 06 00 00       	call   8009fb <exit>
  8003b4:	83 c4 10             	add    $0x10,%esp
			}
			if (debug)
  8003b7:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8003be:	74 1c                	je     8003dc <runcmd+0x1d3>
				cprintf("PIPE: %d %d\n", p[0], p[1]);
  8003c0:	83 ec 04             	sub    $0x4,%esp
  8003c3:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  8003c9:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  8003cf:	68 2d 33 80 00       	push   $0x80332d
  8003d4:	e8 15 07 00 00       	call   800aee <cprintf>
  8003d9:	83 c4 10             	add    $0x10,%esp
			if ((r = fork()) < 0) {
  8003dc:	e8 6b 15 00 00       	call   80194c <fork>
  8003e1:	89 c7                	mov    %eax,%edi
  8003e3:	85 c0                	test   %eax,%eax
  8003e5:	79 16                	jns    8003fd <runcmd+0x1f4>
				cprintf("fork: %e", r);
  8003e7:	83 ec 08             	sub    $0x8,%esp
  8003ea:	50                   	push   %eax
  8003eb:	68 3a 33 80 00       	push   $0x80333a
  8003f0:	e8 f9 06 00 00       	call   800aee <cprintf>
				exit();
  8003f5:	e8 01 06 00 00       	call   8009fb <exit>
  8003fa:	83 c4 10             	add    $0x10,%esp
			}
			if (r == 0) {
  8003fd:	85 ff                	test   %edi,%edi
  8003ff:	75 3c                	jne    80043d <runcmd+0x234>
				if (p[0] != 0) {
  800401:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  800407:	85 c0                	test   %eax,%eax
  800409:	74 1c                	je     800427 <runcmd+0x21e>
					dup(p[0], 0);
  80040b:	83 ec 08             	sub    $0x8,%esp
  80040e:	6a 00                	push   $0x0
  800410:	50                   	push   %eax
  800411:	e8 b6 19 00 00       	call   801dcc <dup>
					close(p[0]);
  800416:	83 c4 04             	add    $0x4,%esp
  800419:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  80041f:	e8 58 19 00 00       	call   801d7c <close>
  800424:	83 c4 10             	add    $0x10,%esp
				}
				close(p[1]);
  800427:	83 ec 0c             	sub    $0xc,%esp
  80042a:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  800430:	e8 47 19 00 00       	call   801d7c <close>
				goto again;
  800435:	83 c4 10             	add    $0x10,%esp
  800438:	e9 e8 fd ff ff       	jmp    800225 <runcmd+0x1c>
			} else {
				pipe_child = r;
				if (p[1] != 1) {
  80043d:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  800443:	83 f8 01             	cmp    $0x1,%eax
  800446:	74 1c                	je     800464 <runcmd+0x25b>
					dup(p[1], 1);
  800448:	83 ec 08             	sub    $0x8,%esp
  80044b:	6a 01                	push   $0x1
  80044d:	50                   	push   %eax
  80044e:	e8 79 19 00 00       	call   801dcc <dup>
					close(p[1]);
  800453:	83 c4 04             	add    $0x4,%esp
  800456:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  80045c:	e8 1b 19 00 00       	call   801d7c <close>
  800461:	83 c4 10             	add    $0x10,%esp
				}
				close(p[0]);
  800464:	83 ec 0c             	sub    $0xc,%esp
  800467:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  80046d:	e8 0a 19 00 00       	call   801d7c <close>
				goto runit;
  800472:	83 c4 10             	add    $0x10,%esp
  800475:	eb 17                	jmp    80048e <runcmd+0x285>
		case 0:		// String is complete
			// Run the current command!
			goto runit;

		default:
			panic("bad return %d from gettoken", c);
  800477:	50                   	push   %eax
  800478:	68 43 33 80 00       	push   $0x803343
  80047d:	6a 78                	push   $0x78
  80047f:	68 5f 33 80 00       	push   $0x80335f
  800484:	e8 8c 05 00 00       	call   800a15 <_panic>
runcmd(char* s)
{
	char *argv[MAXARGS], *t, argv0buf[BUFSIZ];
	int argc, c, i, r, p[2], fd, pipe_child;

	pipe_child = 0;
  800489:	bf 00 00 00 00       	mov    $0x0,%edi
		}
	}

runit:
	// Return immediately if command line was empty.
	if(argc == 0) {
  80048e:	85 f6                	test   %esi,%esi
  800490:	75 22                	jne    8004b4 <runcmd+0x2ab>
		if (debug)
  800492:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800499:	0f 84 96 01 00 00    	je     800635 <runcmd+0x42c>
			cprintf("EMPTY COMMAND\n");
  80049f:	83 ec 0c             	sub    $0xc,%esp
  8004a2:	68 69 33 80 00       	push   $0x803369
  8004a7:	e8 42 06 00 00       	call   800aee <cprintf>
  8004ac:	83 c4 10             	add    $0x10,%esp
  8004af:	e9 81 01 00 00       	jmp    800635 <runcmd+0x42c>

	// Clean up command line.
	// Read all commands from the filesystem: add an initial '/' to
	// the command name.
	// This essentially acts like 'PATH=/'.
	if (argv[0][0] != '/') {
  8004b4:	8b 45 a8             	mov    -0x58(%ebp),%eax
  8004b7:	80 38 2f             	cmpb   $0x2f,(%eax)
  8004ba:	74 23                	je     8004df <runcmd+0x2d6>
		argv0buf[0] = '/';
  8004bc:	c6 85 a4 fb ff ff 2f 	movb   $0x2f,-0x45c(%ebp)
		strcpy(argv0buf + 1, argv[0]);
  8004c3:	83 ec 08             	sub    $0x8,%esp
  8004c6:	50                   	push   %eax
  8004c7:	8d 9d a4 fb ff ff    	lea    -0x45c(%ebp),%ebx
  8004cd:	8d 85 a5 fb ff ff    	lea    -0x45b(%ebp),%eax
  8004d3:	50                   	push   %eax
  8004d4:	e8 ab 0c 00 00       	call   801184 <strcpy>
		argv[0] = argv0buf;
  8004d9:	89 5d a8             	mov    %ebx,-0x58(%ebp)
  8004dc:	83 c4 10             	add    $0x10,%esp
	}
	argv[argc] = 0;
  8004df:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
  8004e6:	00 

	// Print the command.
	if (debug) {
  8004e7:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8004ee:	74 49                	je     800539 <runcmd+0x330>
		cprintf("[%08x] SPAWN:", thisenv->env_id);
  8004f0:	a1 24 54 80 00       	mov    0x805424,%eax
  8004f5:	8b 40 48             	mov    0x48(%eax),%eax
  8004f8:	83 ec 08             	sub    $0x8,%esp
  8004fb:	50                   	push   %eax
  8004fc:	68 78 33 80 00       	push   $0x803378
  800501:	e8 e8 05 00 00       	call   800aee <cprintf>
  800506:	8d 5d a8             	lea    -0x58(%ebp),%ebx
		for (i = 0; argv[i]; i++)
  800509:	83 c4 10             	add    $0x10,%esp
  80050c:	eb 11                	jmp    80051f <runcmd+0x316>
			cprintf(" %s", argv[i]);
  80050e:	83 ec 08             	sub    $0x8,%esp
  800511:	50                   	push   %eax
  800512:	68 00 34 80 00       	push   $0x803400
  800517:	e8 d2 05 00 00       	call   800aee <cprintf>
  80051c:	83 c4 10             	add    $0x10,%esp
  80051f:	83 c3 04             	add    $0x4,%ebx
	argv[argc] = 0;

	// Print the command.
	if (debug) {
		cprintf("[%08x] SPAWN:", thisenv->env_id);
		for (i = 0; argv[i]; i++)
  800522:	8b 43 fc             	mov    -0x4(%ebx),%eax
  800525:	85 c0                	test   %eax,%eax
  800527:	75 e5                	jne    80050e <runcmd+0x305>
			cprintf(" %s", argv[i]);
		cprintf("\n");
  800529:	83 ec 0c             	sub    $0xc,%esp
  80052c:	68 c0 32 80 00       	push   $0x8032c0
  800531:	e8 b8 05 00 00       	call   800aee <cprintf>
  800536:	83 c4 10             	add    $0x10,%esp
	}

	// Spawn the command!
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
  800539:	83 ec 08             	sub    $0x8,%esp
  80053c:	8d 45 a8             	lea    -0x58(%ebp),%eax
  80053f:	50                   	push   %eax
  800540:	ff 75 a8             	pushl  -0x58(%ebp)
  800543:	e8 af 1f 00 00       	call   8024f7 <spawn>
  800548:	89 c3                	mov    %eax,%ebx
  80054a:	83 c4 10             	add    $0x10,%esp
  80054d:	85 c0                	test   %eax,%eax
  80054f:	0f 89 c3 00 00 00    	jns    800618 <runcmd+0x40f>
		cprintf("spawn %s: %e\n", argv[0], r);
  800555:	83 ec 04             	sub    $0x4,%esp
  800558:	50                   	push   %eax
  800559:	ff 75 a8             	pushl  -0x58(%ebp)
  80055c:	68 86 33 80 00       	push   $0x803386
  800561:	e8 88 05 00 00       	call   800aee <cprintf>

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  800566:	e8 3c 18 00 00       	call   801da7 <close_all>
  80056b:	83 c4 10             	add    $0x10,%esp
  80056e:	eb 4c                	jmp    8005bc <runcmd+0x3b3>
	if (r >= 0) {
		if (debug)
			cprintf("[%08x] WAIT %s %08x\n", thisenv->env_id, argv[0], r);
  800570:	a1 24 54 80 00       	mov    0x805424,%eax
  800575:	8b 40 48             	mov    0x48(%eax),%eax
  800578:	53                   	push   %ebx
  800579:	ff 75 a8             	pushl  -0x58(%ebp)
  80057c:	50                   	push   %eax
  80057d:	68 94 33 80 00       	push   $0x803394
  800582:	e8 67 05 00 00       	call   800aee <cprintf>
  800587:	83 c4 10             	add    $0x10,%esp
		wait(r);
  80058a:	83 ec 0c             	sub    $0xc,%esp
  80058d:	53                   	push   %ebx
  80058e:	e8 74 28 00 00       	call   802e07 <wait>
		if (debug)
  800593:	83 c4 10             	add    $0x10,%esp
  800596:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80059d:	0f 84 8c 00 00 00    	je     80062f <runcmd+0x426>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  8005a3:	a1 24 54 80 00       	mov    0x805424,%eax
  8005a8:	8b 40 48             	mov    0x48(%eax),%eax
  8005ab:	83 ec 08             	sub    $0x8,%esp
  8005ae:	50                   	push   %eax
  8005af:	68 a9 33 80 00       	push   $0x8033a9
  8005b4:	e8 35 05 00 00       	call   800aee <cprintf>
  8005b9:	83 c4 10             	add    $0x10,%esp
	}

	// If we were the left-hand part of a pipe,
	// wait for the right-hand part to finish.
	if (pipe_child) {
  8005bc:	85 ff                	test   %edi,%edi
  8005be:	74 51                	je     800611 <runcmd+0x408>
		if (debug)
  8005c0:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8005c7:	74 1a                	je     8005e3 <runcmd+0x3da>
			cprintf("[%08x] WAIT pipe_child %08x\n", thisenv->env_id, pipe_child);
  8005c9:	a1 24 54 80 00       	mov    0x805424,%eax
  8005ce:	8b 40 48             	mov    0x48(%eax),%eax
  8005d1:	83 ec 04             	sub    $0x4,%esp
  8005d4:	57                   	push   %edi
  8005d5:	50                   	push   %eax
  8005d6:	68 bf 33 80 00       	push   $0x8033bf
  8005db:	e8 0e 05 00 00       	call   800aee <cprintf>
  8005e0:	83 c4 10             	add    $0x10,%esp
		wait(pipe_child);
  8005e3:	83 ec 0c             	sub    $0xc,%esp
  8005e6:	57                   	push   %edi
  8005e7:	e8 1b 28 00 00       	call   802e07 <wait>
		if (debug)
  8005ec:	83 c4 10             	add    $0x10,%esp
  8005ef:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8005f6:	74 19                	je     800611 <runcmd+0x408>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  8005f8:	a1 24 54 80 00       	mov    0x805424,%eax
  8005fd:	8b 40 48             	mov    0x48(%eax),%eax
  800600:	83 ec 08             	sub    $0x8,%esp
  800603:	50                   	push   %eax
  800604:	68 a9 33 80 00       	push   $0x8033a9
  800609:	e8 e0 04 00 00       	call   800aee <cprintf>
  80060e:	83 c4 10             	add    $0x10,%esp
	}

	// Done!
	exit();
  800611:	e8 e5 03 00 00       	call   8009fb <exit>
  800616:	eb 1d                	jmp    800635 <runcmd+0x42c>
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
		cprintf("spawn %s: %e\n", argv[0], r);

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  800618:	e8 8a 17 00 00       	call   801da7 <close_all>
	if (r >= 0) {
		if (debug)
  80061d:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800624:	0f 84 60 ff ff ff    	je     80058a <runcmd+0x381>
  80062a:	e9 41 ff ff ff       	jmp    800570 <runcmd+0x367>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
	}

	// If we were the left-hand part of a pipe,
	// wait for the right-hand part to finish.
	if (pipe_child) {
  80062f:	85 ff                	test   %edi,%edi
  800631:	75 b0                	jne    8005e3 <runcmd+0x3da>
  800633:	eb dc                	jmp    800611 <runcmd+0x408>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
	}

	// Done!
	exit();
}
  800635:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800638:	5b                   	pop    %ebx
  800639:	5e                   	pop    %esi
  80063a:	5f                   	pop    %edi
  80063b:	5d                   	pop    %ebp
  80063c:	c3                   	ret    

0080063d <usage>:
}


void
usage(void)
{
  80063d:	55                   	push   %ebp
  80063e:	89 e5                	mov    %esp,%ebp
  800640:	83 ec 14             	sub    $0x14,%esp
	cprintf("usage: sh [-dix] [command-file]\n");
  800643:	68 88 34 80 00       	push   $0x803488
  800648:	e8 a1 04 00 00       	call   800aee <cprintf>
	exit();
  80064d:	e8 a9 03 00 00       	call   8009fb <exit>
}
  800652:	83 c4 10             	add    $0x10,%esp
  800655:	c9                   	leave  
  800656:	c3                   	ret    

00800657 <umain>:

void
umain(int argc, char **argv)
{
  800657:	55                   	push   %ebp
  800658:	89 e5                	mov    %esp,%ebp
  80065a:	57                   	push   %edi
  80065b:	56                   	push   %esi
  80065c:	53                   	push   %ebx
  80065d:	83 ec 30             	sub    $0x30,%esp
  800660:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
  800663:	8d 45 d8             	lea    -0x28(%ebp),%eax
  800666:	50                   	push   %eax
  800667:	57                   	push   %edi
  800668:	8d 45 08             	lea    0x8(%ebp),%eax
  80066b:	50                   	push   %eax
  80066c:	e8 17 14 00 00       	call   801a88 <argstart>
	while ((r = argnext(&args)) >= 0)
  800671:	83 c4 10             	add    $0x10,%esp
{
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
  800674:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
umain(int argc, char **argv)
{
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
  80067b:	be 3f 00 00 00       	mov    $0x3f,%esi
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
  800680:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  800683:	eb 2f                	jmp    8006b4 <umain+0x5d>
		switch (r) {
  800685:	83 f8 69             	cmp    $0x69,%eax
  800688:	74 25                	je     8006af <umain+0x58>
  80068a:	83 f8 78             	cmp    $0x78,%eax
  80068d:	74 07                	je     800696 <umain+0x3f>
  80068f:	83 f8 64             	cmp    $0x64,%eax
  800692:	75 14                	jne    8006a8 <umain+0x51>
  800694:	eb 09                	jmp    80069f <umain+0x48>
			break;
		case 'i':
			interactive = 1;
			break;
		case 'x':
			echocmds = 1;
  800696:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  80069d:	eb 15                	jmp    8006b4 <umain+0x5d>
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
		switch (r) {
		case 'd':
			debug++;
  80069f:	83 05 00 50 80 00 01 	addl   $0x1,0x805000
			break;
  8006a6:	eb 0c                	jmp    8006b4 <umain+0x5d>
			break;
		case 'x':
			echocmds = 1;
			break;
		default:
			usage();
  8006a8:	e8 90 ff ff ff       	call   80063d <usage>
  8006ad:	eb 05                	jmp    8006b4 <umain+0x5d>
		switch (r) {
		case 'd':
			debug++;
			break;
		case 'i':
			interactive = 1;
  8006af:	be 01 00 00 00       	mov    $0x1,%esi
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
  8006b4:	83 ec 0c             	sub    $0xc,%esp
  8006b7:	53                   	push   %ebx
  8006b8:	e8 fb 13 00 00       	call   801ab8 <argnext>
  8006bd:	83 c4 10             	add    $0x10,%esp
  8006c0:	85 c0                	test   %eax,%eax
  8006c2:	79 c1                	jns    800685 <umain+0x2e>
			break;
		default:
			usage();
		}

	if (argc > 2)
  8006c4:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  8006c8:	7e 05                	jle    8006cf <umain+0x78>
		usage();
  8006ca:	e8 6e ff ff ff       	call   80063d <usage>
	if (argc == 2) {
  8006cf:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  8006d3:	75 56                	jne    80072b <umain+0xd4>
		close(0);
  8006d5:	83 ec 0c             	sub    $0xc,%esp
  8006d8:	6a 00                	push   $0x0
  8006da:	e8 9d 16 00 00       	call   801d7c <close>
		if ((r = open(argv[1], O_RDONLY)) < 0)
  8006df:	83 c4 08             	add    $0x8,%esp
  8006e2:	6a 00                	push   $0x0
  8006e4:	ff 77 04             	pushl  0x4(%edi)
  8006e7:	e8 57 1c 00 00       	call   802343 <open>
  8006ec:	83 c4 10             	add    $0x10,%esp
  8006ef:	85 c0                	test   %eax,%eax
  8006f1:	79 1b                	jns    80070e <umain+0xb7>
			panic("open %s: %e", argv[1], r);
  8006f3:	83 ec 0c             	sub    $0xc,%esp
  8006f6:	50                   	push   %eax
  8006f7:	ff 77 04             	pushl  0x4(%edi)
  8006fa:	68 dc 33 80 00       	push   $0x8033dc
  8006ff:	68 28 01 00 00       	push   $0x128
  800704:	68 5f 33 80 00       	push   $0x80335f
  800709:	e8 07 03 00 00       	call   800a15 <_panic>
		assert(r == 0);
  80070e:	85 c0                	test   %eax,%eax
  800710:	74 19                	je     80072b <umain+0xd4>
  800712:	68 e8 33 80 00       	push   $0x8033e8
  800717:	68 ef 33 80 00       	push   $0x8033ef
  80071c:	68 29 01 00 00       	push   $0x129
  800721:	68 5f 33 80 00       	push   $0x80335f
  800726:	e8 ea 02 00 00       	call   800a15 <_panic>
	}
	if (interactive == '?')
  80072b:	83 fe 3f             	cmp    $0x3f,%esi
  80072e:	75 0f                	jne    80073f <umain+0xe8>
		interactive = iscons(0);
  800730:	83 ec 0c             	sub    $0xc,%esp
  800733:	6a 00                	push   $0x0
  800735:	e8 f5 01 00 00       	call   80092f <iscons>
  80073a:	89 c6                	mov    %eax,%esi
  80073c:	83 c4 10             	add    $0x10,%esp
  80073f:	85 f6                	test   %esi,%esi
  800741:	b8 00 00 00 00       	mov    $0x0,%eax
  800746:	bf 04 34 80 00       	mov    $0x803404,%edi
  80074b:	0f 44 f8             	cmove  %eax,%edi

	while (1) {
		char *buf;

		buf = readline(interactive ? "$ " : NULL);
  80074e:	83 ec 0c             	sub    $0xc,%esp
  800751:	57                   	push   %edi
  800752:	e8 01 09 00 00       	call   801058 <readline>
  800757:	89 c3                	mov    %eax,%ebx
		if (buf == NULL) {
  800759:	83 c4 10             	add    $0x10,%esp
  80075c:	85 c0                	test   %eax,%eax
  80075e:	75 1e                	jne    80077e <umain+0x127>
			if (debug)
  800760:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800767:	74 10                	je     800779 <umain+0x122>
				cprintf("EXITING\n");
  800769:	83 ec 0c             	sub    $0xc,%esp
  80076c:	68 07 34 80 00       	push   $0x803407
  800771:	e8 78 03 00 00       	call   800aee <cprintf>
  800776:	83 c4 10             	add    $0x10,%esp
			exit();	// end of file
  800779:	e8 7d 02 00 00       	call   8009fb <exit>
		}
		if (debug)
  80077e:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800785:	74 11                	je     800798 <umain+0x141>
			cprintf("LINE: %s\n", buf);
  800787:	83 ec 08             	sub    $0x8,%esp
  80078a:	53                   	push   %ebx
  80078b:	68 10 34 80 00       	push   $0x803410
  800790:	e8 59 03 00 00       	call   800aee <cprintf>
  800795:	83 c4 10             	add    $0x10,%esp
		if (buf[0] == '#')
  800798:	80 3b 23             	cmpb   $0x23,(%ebx)
  80079b:	74 b1                	je     80074e <umain+0xf7>
			continue;
		if (echocmds)
  80079d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8007a1:	74 11                	je     8007b4 <umain+0x15d>
			printf("# %s\n", buf);
  8007a3:	83 ec 08             	sub    $0x8,%esp
  8007a6:	53                   	push   %ebx
  8007a7:	68 1a 34 80 00       	push   $0x80341a
  8007ac:	e8 30 1d 00 00       	call   8024e1 <printf>
  8007b1:	83 c4 10             	add    $0x10,%esp
		if (debug)
  8007b4:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007bb:	74 10                	je     8007cd <umain+0x176>
			cprintf("BEFORE FORK\n");
  8007bd:	83 ec 0c             	sub    $0xc,%esp
  8007c0:	68 20 34 80 00       	push   $0x803420
  8007c5:	e8 24 03 00 00       	call   800aee <cprintf>
  8007ca:	83 c4 10             	add    $0x10,%esp
		if ((r = fork()) < 0)
  8007cd:	e8 7a 11 00 00       	call   80194c <fork>
  8007d2:	89 c6                	mov    %eax,%esi
  8007d4:	85 c0                	test   %eax,%eax
  8007d6:	79 15                	jns    8007ed <umain+0x196>
			panic("fork: %e", r);
  8007d8:	50                   	push   %eax
  8007d9:	68 3a 33 80 00       	push   $0x80333a
  8007de:	68 40 01 00 00       	push   $0x140
  8007e3:	68 5f 33 80 00       	push   $0x80335f
  8007e8:	e8 28 02 00 00       	call   800a15 <_panic>
		if (debug)
  8007ed:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007f4:	74 11                	je     800807 <umain+0x1b0>
			cprintf("FORK: %d\n", r);
  8007f6:	83 ec 08             	sub    $0x8,%esp
  8007f9:	50                   	push   %eax
  8007fa:	68 2d 34 80 00       	push   $0x80342d
  8007ff:	e8 ea 02 00 00       	call   800aee <cprintf>
  800804:	83 c4 10             	add    $0x10,%esp
		if (r == 0) {
  800807:	85 f6                	test   %esi,%esi
  800809:	75 16                	jne    800821 <umain+0x1ca>
			runcmd(buf);
  80080b:	83 ec 0c             	sub    $0xc,%esp
  80080e:	53                   	push   %ebx
  80080f:	e8 f5 f9 ff ff       	call   800209 <runcmd>
			exit();
  800814:	e8 e2 01 00 00       	call   8009fb <exit>
  800819:	83 c4 10             	add    $0x10,%esp
  80081c:	e9 2d ff ff ff       	jmp    80074e <umain+0xf7>
		} else
			wait(r);
  800821:	83 ec 0c             	sub    $0xc,%esp
  800824:	56                   	push   %esi
  800825:	e8 dd 25 00 00       	call   802e07 <wait>
  80082a:	83 c4 10             	add    $0x10,%esp
  80082d:	e9 1c ff ff ff       	jmp    80074e <umain+0xf7>

00800832 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800832:	55                   	push   %ebp
  800833:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800835:	b8 00 00 00 00       	mov    $0x0,%eax
  80083a:	5d                   	pop    %ebp
  80083b:	c3                   	ret    

0080083c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80083c:	55                   	push   %ebp
  80083d:	89 e5                	mov    %esp,%ebp
  80083f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800842:	68 a9 34 80 00       	push   $0x8034a9
  800847:	ff 75 0c             	pushl  0xc(%ebp)
  80084a:	e8 35 09 00 00       	call   801184 <strcpy>
	return 0;
}
  80084f:	b8 00 00 00 00       	mov    $0x0,%eax
  800854:	c9                   	leave  
  800855:	c3                   	ret    

00800856 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800856:	55                   	push   %ebp
  800857:	89 e5                	mov    %esp,%ebp
  800859:	57                   	push   %edi
  80085a:	56                   	push   %esi
  80085b:	53                   	push   %ebx
  80085c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800862:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800867:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80086d:	eb 2d                	jmp    80089c <devcons_write+0x46>
		m = n - tot;
  80086f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800872:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800874:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800877:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80087c:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80087f:	83 ec 04             	sub    $0x4,%esp
  800882:	53                   	push   %ebx
  800883:	03 45 0c             	add    0xc(%ebp),%eax
  800886:	50                   	push   %eax
  800887:	57                   	push   %edi
  800888:	e8 89 0a 00 00       	call   801316 <memmove>
		sys_cputs(buf, m);
  80088d:	83 c4 08             	add    $0x8,%esp
  800890:	53                   	push   %ebx
  800891:	57                   	push   %edi
  800892:	e8 34 0c 00 00       	call   8014cb <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800897:	01 de                	add    %ebx,%esi
  800899:	83 c4 10             	add    $0x10,%esp
  80089c:	89 f0                	mov    %esi,%eax
  80089e:	3b 75 10             	cmp    0x10(%ebp),%esi
  8008a1:	72 cc                	jb     80086f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8008a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008a6:	5b                   	pop    %ebx
  8008a7:	5e                   	pop    %esi
  8008a8:	5f                   	pop    %edi
  8008a9:	5d                   	pop    %ebp
  8008aa:	c3                   	ret    

008008ab <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	83 ec 08             	sub    $0x8,%esp
  8008b1:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8008b6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8008ba:	74 2a                	je     8008e6 <devcons_read+0x3b>
  8008bc:	eb 05                	jmp    8008c3 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8008be:	e8 a5 0c 00 00       	call   801568 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8008c3:	e8 21 0c 00 00       	call   8014e9 <sys_cgetc>
  8008c8:	85 c0                	test   %eax,%eax
  8008ca:	74 f2                	je     8008be <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8008cc:	85 c0                	test   %eax,%eax
  8008ce:	78 16                	js     8008e6 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8008d0:	83 f8 04             	cmp    $0x4,%eax
  8008d3:	74 0c                	je     8008e1 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8008d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008d8:	88 02                	mov    %al,(%edx)
	return 1;
  8008da:	b8 01 00 00 00       	mov    $0x1,%eax
  8008df:	eb 05                	jmp    8008e6 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8008e1:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8008e6:	c9                   	leave  
  8008e7:	c3                   	ret    

008008e8 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8008ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f1:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8008f4:	6a 01                	push   $0x1
  8008f6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8008f9:	50                   	push   %eax
  8008fa:	e8 cc 0b 00 00       	call   8014cb <sys_cputs>
}
  8008ff:	83 c4 10             	add    $0x10,%esp
  800902:	c9                   	leave  
  800903:	c3                   	ret    

00800904 <getchar>:

int
getchar(void)
{
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
  800907:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80090a:	6a 01                	push   $0x1
  80090c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80090f:	50                   	push   %eax
  800910:	6a 00                	push   $0x0
  800912:	e8 a1 15 00 00       	call   801eb8 <read>
	if (r < 0)
  800917:	83 c4 10             	add    $0x10,%esp
  80091a:	85 c0                	test   %eax,%eax
  80091c:	78 0f                	js     80092d <getchar+0x29>
		return r;
	if (r < 1)
  80091e:	85 c0                	test   %eax,%eax
  800920:	7e 06                	jle    800928 <getchar+0x24>
		return -E_EOF;
	return c;
  800922:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800926:	eb 05                	jmp    80092d <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800928:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80092d:	c9                   	leave  
  80092e:	c3                   	ret    

0080092f <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
  800932:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800935:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800938:	50                   	push   %eax
  800939:	ff 75 08             	pushl  0x8(%ebp)
  80093c:	e8 11 13 00 00       	call   801c52 <fd_lookup>
  800941:	83 c4 10             	add    $0x10,%esp
  800944:	85 c0                	test   %eax,%eax
  800946:	78 11                	js     800959 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800948:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80094b:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800951:	39 10                	cmp    %edx,(%eax)
  800953:	0f 94 c0             	sete   %al
  800956:	0f b6 c0             	movzbl %al,%eax
}
  800959:	c9                   	leave  
  80095a:	c3                   	ret    

0080095b <opencons>:

int
opencons(void)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800961:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800964:	50                   	push   %eax
  800965:	e8 99 12 00 00       	call   801c03 <fd_alloc>
  80096a:	83 c4 10             	add    $0x10,%esp
		return r;
  80096d:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80096f:	85 c0                	test   %eax,%eax
  800971:	78 3e                	js     8009b1 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800973:	83 ec 04             	sub    $0x4,%esp
  800976:	68 07 04 00 00       	push   $0x407
  80097b:	ff 75 f4             	pushl  -0xc(%ebp)
  80097e:	6a 00                	push   $0x0
  800980:	e8 02 0c 00 00       	call   801587 <sys_page_alloc>
  800985:	83 c4 10             	add    $0x10,%esp
		return r;
  800988:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80098a:	85 c0                	test   %eax,%eax
  80098c:	78 23                	js     8009b1 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80098e:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800994:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800997:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800999:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80099c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8009a3:	83 ec 0c             	sub    $0xc,%esp
  8009a6:	50                   	push   %eax
  8009a7:	e8 30 12 00 00       	call   801bdc <fd2num>
  8009ac:	89 c2                	mov    %eax,%edx
  8009ae:	83 c4 10             	add    $0x10,%esp
}
  8009b1:	89 d0                	mov    %edx,%eax
  8009b3:	c9                   	leave  
  8009b4:	c3                   	ret    

008009b5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8009b5:	55                   	push   %ebp
  8009b6:	89 e5                	mov    %esp,%ebp
  8009b8:	56                   	push   %esi
  8009b9:	53                   	push   %ebx
  8009ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009bd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  8009c0:	e8 84 0b 00 00       	call   801549 <sys_getenvid>
  8009c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8009ca:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8009cd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8009d2:	a3 24 54 80 00       	mov    %eax,0x805424
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8009d7:	85 db                	test   %ebx,%ebx
  8009d9:	7e 07                	jle    8009e2 <libmain+0x2d>
		binaryname = argv[0];
  8009db:	8b 06                	mov    (%esi),%eax
  8009dd:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  8009e2:	83 ec 08             	sub    $0x8,%esp
  8009e5:	56                   	push   %esi
  8009e6:	53                   	push   %ebx
  8009e7:	e8 6b fc ff ff       	call   800657 <umain>

	// exit gracefully
	exit();
  8009ec:	e8 0a 00 00 00       	call   8009fb <exit>
}
  8009f1:	83 c4 10             	add    $0x10,%esp
  8009f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009f7:	5b                   	pop    %ebx
  8009f8:	5e                   	pop    %esi
  8009f9:	5d                   	pop    %ebp
  8009fa:	c3                   	ret    

008009fb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
  8009fe:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800a01:	e8 a1 13 00 00       	call   801da7 <close_all>
	sys_env_destroy(0);
  800a06:	83 ec 0c             	sub    $0xc,%esp
  800a09:	6a 00                	push   $0x0
  800a0b:	e8 f8 0a 00 00       	call   801508 <sys_env_destroy>
}
  800a10:	83 c4 10             	add    $0x10,%esp
  800a13:	c9                   	leave  
  800a14:	c3                   	ret    

00800a15 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800a15:	55                   	push   %ebp
  800a16:	89 e5                	mov    %esp,%ebp
  800a18:	56                   	push   %esi
  800a19:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800a1a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800a1d:	8b 35 1c 40 80 00    	mov    0x80401c,%esi
  800a23:	e8 21 0b 00 00       	call   801549 <sys_getenvid>
  800a28:	83 ec 0c             	sub    $0xc,%esp
  800a2b:	ff 75 0c             	pushl  0xc(%ebp)
  800a2e:	ff 75 08             	pushl  0x8(%ebp)
  800a31:	56                   	push   %esi
  800a32:	50                   	push   %eax
  800a33:	68 c0 34 80 00       	push   $0x8034c0
  800a38:	e8 b1 00 00 00       	call   800aee <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800a3d:	83 c4 18             	add    $0x18,%esp
  800a40:	53                   	push   %ebx
  800a41:	ff 75 10             	pushl  0x10(%ebp)
  800a44:	e8 54 00 00 00       	call   800a9d <vcprintf>
	cprintf("\n");
  800a49:	c7 04 24 c0 32 80 00 	movl   $0x8032c0,(%esp)
  800a50:	e8 99 00 00 00       	call   800aee <cprintf>
  800a55:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800a58:	cc                   	int3   
  800a59:	eb fd                	jmp    800a58 <_panic+0x43>

00800a5b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	53                   	push   %ebx
  800a5f:	83 ec 04             	sub    $0x4,%esp
  800a62:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800a65:	8b 13                	mov    (%ebx),%edx
  800a67:	8d 42 01             	lea    0x1(%edx),%eax
  800a6a:	89 03                	mov    %eax,(%ebx)
  800a6c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a6f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800a73:	3d ff 00 00 00       	cmp    $0xff,%eax
  800a78:	75 1a                	jne    800a94 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800a7a:	83 ec 08             	sub    $0x8,%esp
  800a7d:	68 ff 00 00 00       	push   $0xff
  800a82:	8d 43 08             	lea    0x8(%ebx),%eax
  800a85:	50                   	push   %eax
  800a86:	e8 40 0a 00 00       	call   8014cb <sys_cputs>
		b->idx = 0;
  800a8b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800a91:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800a94:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800a98:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a9b:	c9                   	leave  
  800a9c:	c3                   	ret    

00800a9d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800a9d:	55                   	push   %ebp
  800a9e:	89 e5                	mov    %esp,%ebp
  800aa0:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800aa6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800aad:	00 00 00 
	b.cnt = 0;
  800ab0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800ab7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800aba:	ff 75 0c             	pushl  0xc(%ebp)
  800abd:	ff 75 08             	pushl  0x8(%ebp)
  800ac0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800ac6:	50                   	push   %eax
  800ac7:	68 5b 0a 80 00       	push   $0x800a5b
  800acc:	e8 54 01 00 00       	call   800c25 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800ad1:	83 c4 08             	add    $0x8,%esp
  800ad4:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800ada:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800ae0:	50                   	push   %eax
  800ae1:	e8 e5 09 00 00       	call   8014cb <sys_cputs>

	return b.cnt;
}
  800ae6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800aec:	c9                   	leave  
  800aed:	c3                   	ret    

00800aee <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800aee:	55                   	push   %ebp
  800aef:	89 e5                	mov    %esp,%ebp
  800af1:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800af4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800af7:	50                   	push   %eax
  800af8:	ff 75 08             	pushl  0x8(%ebp)
  800afb:	e8 9d ff ff ff       	call   800a9d <vcprintf>
	va_end(ap);

	return cnt;
}
  800b00:	c9                   	leave  
  800b01:	c3                   	ret    

00800b02 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800b02:	55                   	push   %ebp
  800b03:	89 e5                	mov    %esp,%ebp
  800b05:	57                   	push   %edi
  800b06:	56                   	push   %esi
  800b07:	53                   	push   %ebx
  800b08:	83 ec 1c             	sub    $0x1c,%esp
  800b0b:	89 c7                	mov    %eax,%edi
  800b0d:	89 d6                	mov    %edx,%esi
  800b0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b12:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b15:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b18:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800b1b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b1e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b23:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800b26:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800b29:	39 d3                	cmp    %edx,%ebx
  800b2b:	72 05                	jb     800b32 <printnum+0x30>
  800b2d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800b30:	77 45                	ja     800b77 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800b32:	83 ec 0c             	sub    $0xc,%esp
  800b35:	ff 75 18             	pushl  0x18(%ebp)
  800b38:	8b 45 14             	mov    0x14(%ebp),%eax
  800b3b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800b3e:	53                   	push   %ebx
  800b3f:	ff 75 10             	pushl  0x10(%ebp)
  800b42:	83 ec 08             	sub    $0x8,%esp
  800b45:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b48:	ff 75 e0             	pushl  -0x20(%ebp)
  800b4b:	ff 75 dc             	pushl  -0x24(%ebp)
  800b4e:	ff 75 d8             	pushl  -0x28(%ebp)
  800b51:	e8 aa 24 00 00       	call   803000 <__udivdi3>
  800b56:	83 c4 18             	add    $0x18,%esp
  800b59:	52                   	push   %edx
  800b5a:	50                   	push   %eax
  800b5b:	89 f2                	mov    %esi,%edx
  800b5d:	89 f8                	mov    %edi,%eax
  800b5f:	e8 9e ff ff ff       	call   800b02 <printnum>
  800b64:	83 c4 20             	add    $0x20,%esp
  800b67:	eb 18                	jmp    800b81 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800b69:	83 ec 08             	sub    $0x8,%esp
  800b6c:	56                   	push   %esi
  800b6d:	ff 75 18             	pushl  0x18(%ebp)
  800b70:	ff d7                	call   *%edi
  800b72:	83 c4 10             	add    $0x10,%esp
  800b75:	eb 03                	jmp    800b7a <printnum+0x78>
  800b77:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800b7a:	83 eb 01             	sub    $0x1,%ebx
  800b7d:	85 db                	test   %ebx,%ebx
  800b7f:	7f e8                	jg     800b69 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800b81:	83 ec 08             	sub    $0x8,%esp
  800b84:	56                   	push   %esi
  800b85:	83 ec 04             	sub    $0x4,%esp
  800b88:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b8b:	ff 75 e0             	pushl  -0x20(%ebp)
  800b8e:	ff 75 dc             	pushl  -0x24(%ebp)
  800b91:	ff 75 d8             	pushl  -0x28(%ebp)
  800b94:	e8 97 25 00 00       	call   803130 <__umoddi3>
  800b99:	83 c4 14             	add    $0x14,%esp
  800b9c:	0f be 80 e3 34 80 00 	movsbl 0x8034e3(%eax),%eax
  800ba3:	50                   	push   %eax
  800ba4:	ff d7                	call   *%edi
}
  800ba6:	83 c4 10             	add    $0x10,%esp
  800ba9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bac:	5b                   	pop    %ebx
  800bad:	5e                   	pop    %esi
  800bae:	5f                   	pop    %edi
  800baf:	5d                   	pop    %ebp
  800bb0:	c3                   	ret    

00800bb1 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800bb1:	55                   	push   %ebp
  800bb2:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800bb4:	83 fa 01             	cmp    $0x1,%edx
  800bb7:	7e 0e                	jle    800bc7 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800bb9:	8b 10                	mov    (%eax),%edx
  800bbb:	8d 4a 08             	lea    0x8(%edx),%ecx
  800bbe:	89 08                	mov    %ecx,(%eax)
  800bc0:	8b 02                	mov    (%edx),%eax
  800bc2:	8b 52 04             	mov    0x4(%edx),%edx
  800bc5:	eb 22                	jmp    800be9 <getuint+0x38>
	else if (lflag)
  800bc7:	85 d2                	test   %edx,%edx
  800bc9:	74 10                	je     800bdb <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800bcb:	8b 10                	mov    (%eax),%edx
  800bcd:	8d 4a 04             	lea    0x4(%edx),%ecx
  800bd0:	89 08                	mov    %ecx,(%eax)
  800bd2:	8b 02                	mov    (%edx),%eax
  800bd4:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd9:	eb 0e                	jmp    800be9 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800bdb:	8b 10                	mov    (%eax),%edx
  800bdd:	8d 4a 04             	lea    0x4(%edx),%ecx
  800be0:	89 08                	mov    %ecx,(%eax)
  800be2:	8b 02                	mov    (%edx),%eax
  800be4:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800be9:	5d                   	pop    %ebp
  800bea:	c3                   	ret    

00800beb <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800bf1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800bf5:	8b 10                	mov    (%eax),%edx
  800bf7:	3b 50 04             	cmp    0x4(%eax),%edx
  800bfa:	73 0a                	jae    800c06 <sprintputch+0x1b>
		*b->buf++ = ch;
  800bfc:	8d 4a 01             	lea    0x1(%edx),%ecx
  800bff:	89 08                	mov    %ecx,(%eax)
  800c01:	8b 45 08             	mov    0x8(%ebp),%eax
  800c04:	88 02                	mov    %al,(%edx)
}
  800c06:	5d                   	pop    %ebp
  800c07:	c3                   	ret    

00800c08 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800c08:	55                   	push   %ebp
  800c09:	89 e5                	mov    %esp,%ebp
  800c0b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800c0e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800c11:	50                   	push   %eax
  800c12:	ff 75 10             	pushl  0x10(%ebp)
  800c15:	ff 75 0c             	pushl  0xc(%ebp)
  800c18:	ff 75 08             	pushl  0x8(%ebp)
  800c1b:	e8 05 00 00 00       	call   800c25 <vprintfmt>
	va_end(ap);
}
  800c20:	83 c4 10             	add    $0x10,%esp
  800c23:	c9                   	leave  
  800c24:	c3                   	ret    

00800c25 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800c25:	55                   	push   %ebp
  800c26:	89 e5                	mov    %esp,%ebp
  800c28:	57                   	push   %edi
  800c29:	56                   	push   %esi
  800c2a:	53                   	push   %ebx
  800c2b:	83 ec 2c             	sub    $0x2c,%esp
  800c2e:	8b 75 08             	mov    0x8(%ebp),%esi
  800c31:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c34:	8b 7d 10             	mov    0x10(%ebp),%edi
  800c37:	eb 12                	jmp    800c4b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800c39:	85 c0                	test   %eax,%eax
  800c3b:	0f 84 a7 03 00 00    	je     800fe8 <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
  800c41:	83 ec 08             	sub    $0x8,%esp
  800c44:	53                   	push   %ebx
  800c45:	50                   	push   %eax
  800c46:	ff d6                	call   *%esi
  800c48:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800c4b:	83 c7 01             	add    $0x1,%edi
  800c4e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800c52:	83 f8 25             	cmp    $0x25,%eax
  800c55:	75 e2                	jne    800c39 <vprintfmt+0x14>
  800c57:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800c5b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800c62:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800c69:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800c70:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800c77:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c7c:	eb 07                	jmp    800c85 <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c7e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800c81:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c85:	8d 47 01             	lea    0x1(%edi),%eax
  800c88:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c8b:	0f b6 07             	movzbl (%edi),%eax
  800c8e:	0f b6 d0             	movzbl %al,%edx
  800c91:	83 e8 23             	sub    $0x23,%eax
  800c94:	3c 55                	cmp    $0x55,%al
  800c96:	0f 87 31 03 00 00    	ja     800fcd <vprintfmt+0x3a8>
  800c9c:	0f b6 c0             	movzbl %al,%eax
  800c9f:	ff 24 85 20 36 80 00 	jmp    *0x803620(,%eax,4)
  800ca6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800ca9:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800cad:	eb d6                	jmp    800c85 <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800caf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800cb2:	b8 00 00 00 00       	mov    $0x0,%eax
  800cb7:	89 75 08             	mov    %esi,0x8(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800cba:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800cbd:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800cc1:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800cc4:	8d 72 d0             	lea    -0x30(%edx),%esi
  800cc7:	83 fe 09             	cmp    $0x9,%esi
  800cca:	77 34                	ja     800d00 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800ccc:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800ccf:	eb e9                	jmp    800cba <vprintfmt+0x95>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800cd1:	8b 45 14             	mov    0x14(%ebp),%eax
  800cd4:	8d 50 04             	lea    0x4(%eax),%edx
  800cd7:	89 55 14             	mov    %edx,0x14(%ebp)
  800cda:	8b 00                	mov    (%eax),%eax
  800cdc:	89 45 cc             	mov    %eax,-0x34(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cdf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800ce2:	eb 22                	jmp    800d06 <vprintfmt+0xe1>
  800ce4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ce7:	85 c0                	test   %eax,%eax
  800ce9:	0f 48 c1             	cmovs  %ecx,%eax
  800cec:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800cf2:	eb 91                	jmp    800c85 <vprintfmt+0x60>
  800cf4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800cf7:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800cfe:	eb 85                	jmp    800c85 <vprintfmt+0x60>
  800d00:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800d03:	8b 75 08             	mov    0x8(%ebp),%esi

		process_precision:
			if (width < 0)
  800d06:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800d0a:	0f 89 75 ff ff ff    	jns    800c85 <vprintfmt+0x60>
				width = precision, precision = -1;
  800d10:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800d13:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800d16:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800d1d:	e9 63 ff ff ff       	jmp    800c85 <vprintfmt+0x60>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800d22:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d26:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800d29:	e9 57 ff ff ff       	jmp    800c85 <vprintfmt+0x60>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800d2e:	8b 45 14             	mov    0x14(%ebp),%eax
  800d31:	8d 50 04             	lea    0x4(%eax),%edx
  800d34:	89 55 14             	mov    %edx,0x14(%ebp)
  800d37:	83 ec 08             	sub    $0x8,%esp
  800d3a:	53                   	push   %ebx
  800d3b:	ff 30                	pushl  (%eax)
  800d3d:	ff d6                	call   *%esi
			break;
  800d3f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d42:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800d45:	e9 01 ff ff ff       	jmp    800c4b <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800d4a:	8b 45 14             	mov    0x14(%ebp),%eax
  800d4d:	8d 50 04             	lea    0x4(%eax),%edx
  800d50:	89 55 14             	mov    %edx,0x14(%ebp)
  800d53:	8b 00                	mov    (%eax),%eax
  800d55:	99                   	cltd   
  800d56:	31 d0                	xor    %edx,%eax
  800d58:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800d5a:	83 f8 0f             	cmp    $0xf,%eax
  800d5d:	7f 0b                	jg     800d6a <vprintfmt+0x145>
  800d5f:	8b 14 85 80 37 80 00 	mov    0x803780(,%eax,4),%edx
  800d66:	85 d2                	test   %edx,%edx
  800d68:	75 18                	jne    800d82 <vprintfmt+0x15d>
				printfmt(putch, putdat, "error %d", err);
  800d6a:	50                   	push   %eax
  800d6b:	68 fb 34 80 00       	push   $0x8034fb
  800d70:	53                   	push   %ebx
  800d71:	56                   	push   %esi
  800d72:	e8 91 fe ff ff       	call   800c08 <printfmt>
  800d77:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d7a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800d7d:	e9 c9 fe ff ff       	jmp    800c4b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800d82:	52                   	push   %edx
  800d83:	68 01 34 80 00       	push   $0x803401
  800d88:	53                   	push   %ebx
  800d89:	56                   	push   %esi
  800d8a:	e8 79 fe ff ff       	call   800c08 <printfmt>
  800d8f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d92:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800d95:	e9 b1 fe ff ff       	jmp    800c4b <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800d9a:	8b 45 14             	mov    0x14(%ebp),%eax
  800d9d:	8d 50 04             	lea    0x4(%eax),%edx
  800da0:	89 55 14             	mov    %edx,0x14(%ebp)
  800da3:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800da5:	85 ff                	test   %edi,%edi
  800da7:	b8 f4 34 80 00       	mov    $0x8034f4,%eax
  800dac:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800daf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800db3:	0f 8e 94 00 00 00    	jle    800e4d <vprintfmt+0x228>
  800db9:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800dbd:	0f 84 98 00 00 00    	je     800e5b <vprintfmt+0x236>
				for (width -= strnlen(p, precision); width > 0; width--)
  800dc3:	83 ec 08             	sub    $0x8,%esp
  800dc6:	ff 75 cc             	pushl  -0x34(%ebp)
  800dc9:	57                   	push   %edi
  800dca:	e8 94 03 00 00       	call   801163 <strnlen>
  800dcf:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800dd2:	29 c1                	sub    %eax,%ecx
  800dd4:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800dd7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800dda:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800dde:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800de1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800de4:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800de6:	eb 0f                	jmp    800df7 <vprintfmt+0x1d2>
					putch(padc, putdat);
  800de8:	83 ec 08             	sub    $0x8,%esp
  800deb:	53                   	push   %ebx
  800dec:	ff 75 e0             	pushl  -0x20(%ebp)
  800def:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800df1:	83 ef 01             	sub    $0x1,%edi
  800df4:	83 c4 10             	add    $0x10,%esp
  800df7:	85 ff                	test   %edi,%edi
  800df9:	7f ed                	jg     800de8 <vprintfmt+0x1c3>
  800dfb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800dfe:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800e01:	85 c9                	test   %ecx,%ecx
  800e03:	b8 00 00 00 00       	mov    $0x0,%eax
  800e08:	0f 49 c1             	cmovns %ecx,%eax
  800e0b:	29 c1                	sub    %eax,%ecx
  800e0d:	89 75 08             	mov    %esi,0x8(%ebp)
  800e10:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800e13:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800e16:	89 cb                	mov    %ecx,%ebx
  800e18:	eb 4d                	jmp    800e67 <vprintfmt+0x242>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800e1a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800e1e:	74 1b                	je     800e3b <vprintfmt+0x216>
  800e20:	0f be c0             	movsbl %al,%eax
  800e23:	83 e8 20             	sub    $0x20,%eax
  800e26:	83 f8 5e             	cmp    $0x5e,%eax
  800e29:	76 10                	jbe    800e3b <vprintfmt+0x216>
					putch('?', putdat);
  800e2b:	83 ec 08             	sub    $0x8,%esp
  800e2e:	ff 75 0c             	pushl  0xc(%ebp)
  800e31:	6a 3f                	push   $0x3f
  800e33:	ff 55 08             	call   *0x8(%ebp)
  800e36:	83 c4 10             	add    $0x10,%esp
  800e39:	eb 0d                	jmp    800e48 <vprintfmt+0x223>
				else
					putch(ch, putdat);
  800e3b:	83 ec 08             	sub    $0x8,%esp
  800e3e:	ff 75 0c             	pushl  0xc(%ebp)
  800e41:	52                   	push   %edx
  800e42:	ff 55 08             	call   *0x8(%ebp)
  800e45:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800e48:	83 eb 01             	sub    $0x1,%ebx
  800e4b:	eb 1a                	jmp    800e67 <vprintfmt+0x242>
  800e4d:	89 75 08             	mov    %esi,0x8(%ebp)
  800e50:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800e53:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800e56:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800e59:	eb 0c                	jmp    800e67 <vprintfmt+0x242>
  800e5b:	89 75 08             	mov    %esi,0x8(%ebp)
  800e5e:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800e61:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800e64:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800e67:	83 c7 01             	add    $0x1,%edi
  800e6a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800e6e:	0f be d0             	movsbl %al,%edx
  800e71:	85 d2                	test   %edx,%edx
  800e73:	74 23                	je     800e98 <vprintfmt+0x273>
  800e75:	85 f6                	test   %esi,%esi
  800e77:	78 a1                	js     800e1a <vprintfmt+0x1f5>
  800e79:	83 ee 01             	sub    $0x1,%esi
  800e7c:	79 9c                	jns    800e1a <vprintfmt+0x1f5>
  800e7e:	89 df                	mov    %ebx,%edi
  800e80:	8b 75 08             	mov    0x8(%ebp),%esi
  800e83:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e86:	eb 18                	jmp    800ea0 <vprintfmt+0x27b>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800e88:	83 ec 08             	sub    $0x8,%esp
  800e8b:	53                   	push   %ebx
  800e8c:	6a 20                	push   $0x20
  800e8e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800e90:	83 ef 01             	sub    $0x1,%edi
  800e93:	83 c4 10             	add    $0x10,%esp
  800e96:	eb 08                	jmp    800ea0 <vprintfmt+0x27b>
  800e98:	89 df                	mov    %ebx,%edi
  800e9a:	8b 75 08             	mov    0x8(%ebp),%esi
  800e9d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ea0:	85 ff                	test   %edi,%edi
  800ea2:	7f e4                	jg     800e88 <vprintfmt+0x263>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ea4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800ea7:	e9 9f fd ff ff       	jmp    800c4b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800eac:	83 7d d0 01          	cmpl   $0x1,-0x30(%ebp)
  800eb0:	7e 16                	jle    800ec8 <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  800eb2:	8b 45 14             	mov    0x14(%ebp),%eax
  800eb5:	8d 50 08             	lea    0x8(%eax),%edx
  800eb8:	89 55 14             	mov    %edx,0x14(%ebp)
  800ebb:	8b 50 04             	mov    0x4(%eax),%edx
  800ebe:	8b 00                	mov    (%eax),%eax
  800ec0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ec3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800ec6:	eb 34                	jmp    800efc <vprintfmt+0x2d7>
	else if (lflag)
  800ec8:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800ecc:	74 18                	je     800ee6 <vprintfmt+0x2c1>
		return va_arg(*ap, long);
  800ece:	8b 45 14             	mov    0x14(%ebp),%eax
  800ed1:	8d 50 04             	lea    0x4(%eax),%edx
  800ed4:	89 55 14             	mov    %edx,0x14(%ebp)
  800ed7:	8b 00                	mov    (%eax),%eax
  800ed9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800edc:	89 c1                	mov    %eax,%ecx
  800ede:	c1 f9 1f             	sar    $0x1f,%ecx
  800ee1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800ee4:	eb 16                	jmp    800efc <vprintfmt+0x2d7>
	else
		return va_arg(*ap, int);
  800ee6:	8b 45 14             	mov    0x14(%ebp),%eax
  800ee9:	8d 50 04             	lea    0x4(%eax),%edx
  800eec:	89 55 14             	mov    %edx,0x14(%ebp)
  800eef:	8b 00                	mov    (%eax),%eax
  800ef1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ef4:	89 c1                	mov    %eax,%ecx
  800ef6:	c1 f9 1f             	sar    $0x1f,%ecx
  800ef9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800efc:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800eff:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800f02:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800f07:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800f0b:	0f 89 88 00 00 00    	jns    800f99 <vprintfmt+0x374>
				putch('-', putdat);
  800f11:	83 ec 08             	sub    $0x8,%esp
  800f14:	53                   	push   %ebx
  800f15:	6a 2d                	push   $0x2d
  800f17:	ff d6                	call   *%esi
				num = -(long long) num;
  800f19:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800f1c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800f1f:	f7 d8                	neg    %eax
  800f21:	83 d2 00             	adc    $0x0,%edx
  800f24:	f7 da                	neg    %edx
  800f26:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800f29:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800f2e:	eb 69                	jmp    800f99 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800f30:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800f33:	8d 45 14             	lea    0x14(%ebp),%eax
  800f36:	e8 76 fc ff ff       	call   800bb1 <getuint>
			base = 10;
  800f3b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800f40:	eb 57                	jmp    800f99 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  800f42:	83 ec 08             	sub    $0x8,%esp
  800f45:	53                   	push   %ebx
  800f46:	6a 30                	push   $0x30
  800f48:	ff d6                	call   *%esi
			num = getuint(&ap, lflag);
  800f4a:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800f4d:	8d 45 14             	lea    0x14(%ebp),%eax
  800f50:	e8 5c fc ff ff       	call   800bb1 <getuint>
			base = 8;
			goto number;
  800f55:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800f58:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800f5d:	eb 3a                	jmp    800f99 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  800f5f:	83 ec 08             	sub    $0x8,%esp
  800f62:	53                   	push   %ebx
  800f63:	6a 30                	push   $0x30
  800f65:	ff d6                	call   *%esi
			putch('x', putdat);
  800f67:	83 c4 08             	add    $0x8,%esp
  800f6a:	53                   	push   %ebx
  800f6b:	6a 78                	push   $0x78
  800f6d:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800f6f:	8b 45 14             	mov    0x14(%ebp),%eax
  800f72:	8d 50 04             	lea    0x4(%eax),%edx
  800f75:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800f78:	8b 00                	mov    (%eax),%eax
  800f7a:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800f7f:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800f82:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800f87:	eb 10                	jmp    800f99 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800f89:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800f8c:	8d 45 14             	lea    0x14(%ebp),%eax
  800f8f:	e8 1d fc ff ff       	call   800bb1 <getuint>
			base = 16;
  800f94:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800f99:	83 ec 0c             	sub    $0xc,%esp
  800f9c:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800fa0:	57                   	push   %edi
  800fa1:	ff 75 e0             	pushl  -0x20(%ebp)
  800fa4:	51                   	push   %ecx
  800fa5:	52                   	push   %edx
  800fa6:	50                   	push   %eax
  800fa7:	89 da                	mov    %ebx,%edx
  800fa9:	89 f0                	mov    %esi,%eax
  800fab:	e8 52 fb ff ff       	call   800b02 <printnum>
			break;
  800fb0:	83 c4 20             	add    $0x20,%esp
  800fb3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800fb6:	e9 90 fc ff ff       	jmp    800c4b <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800fbb:	83 ec 08             	sub    $0x8,%esp
  800fbe:	53                   	push   %ebx
  800fbf:	52                   	push   %edx
  800fc0:	ff d6                	call   *%esi
			break;
  800fc2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800fc5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800fc8:	e9 7e fc ff ff       	jmp    800c4b <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800fcd:	83 ec 08             	sub    $0x8,%esp
  800fd0:	53                   	push   %ebx
  800fd1:	6a 25                	push   $0x25
  800fd3:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800fd5:	83 c4 10             	add    $0x10,%esp
  800fd8:	eb 03                	jmp    800fdd <vprintfmt+0x3b8>
  800fda:	83 ef 01             	sub    $0x1,%edi
  800fdd:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800fe1:	75 f7                	jne    800fda <vprintfmt+0x3b5>
  800fe3:	e9 63 fc ff ff       	jmp    800c4b <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800fe8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800feb:	5b                   	pop    %ebx
  800fec:	5e                   	pop    %esi
  800fed:	5f                   	pop    %edi
  800fee:	5d                   	pop    %ebp
  800fef:	c3                   	ret    

00800ff0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800ff0:	55                   	push   %ebp
  800ff1:	89 e5                	mov    %esp,%ebp
  800ff3:	83 ec 18             	sub    $0x18,%esp
  800ff6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800ffc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800fff:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801003:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801006:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80100d:	85 c0                	test   %eax,%eax
  80100f:	74 26                	je     801037 <vsnprintf+0x47>
  801011:	85 d2                	test   %edx,%edx
  801013:	7e 22                	jle    801037 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801015:	ff 75 14             	pushl  0x14(%ebp)
  801018:	ff 75 10             	pushl  0x10(%ebp)
  80101b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80101e:	50                   	push   %eax
  80101f:	68 eb 0b 80 00       	push   $0x800beb
  801024:	e8 fc fb ff ff       	call   800c25 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801029:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80102c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80102f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801032:	83 c4 10             	add    $0x10,%esp
  801035:	eb 05                	jmp    80103c <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801037:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80103c:	c9                   	leave  
  80103d:	c3                   	ret    

0080103e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80103e:	55                   	push   %ebp
  80103f:	89 e5                	mov    %esp,%ebp
  801041:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801044:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801047:	50                   	push   %eax
  801048:	ff 75 10             	pushl  0x10(%ebp)
  80104b:	ff 75 0c             	pushl  0xc(%ebp)
  80104e:	ff 75 08             	pushl  0x8(%ebp)
  801051:	e8 9a ff ff ff       	call   800ff0 <vsnprintf>
	va_end(ap);

	return rc;
}
  801056:	c9                   	leave  
  801057:	c3                   	ret    

00801058 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  801058:	55                   	push   %ebp
  801059:	89 e5                	mov    %esp,%ebp
  80105b:	57                   	push   %edi
  80105c:	56                   	push   %esi
  80105d:	53                   	push   %ebx
  80105e:	83 ec 0c             	sub    $0xc,%esp
  801061:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  801064:	85 c0                	test   %eax,%eax
  801066:	74 13                	je     80107b <readline+0x23>
		fprintf(1, "%s", prompt);
  801068:	83 ec 04             	sub    $0x4,%esp
  80106b:	50                   	push   %eax
  80106c:	68 01 34 80 00       	push   $0x803401
  801071:	6a 01                	push   $0x1
  801073:	e8 52 14 00 00       	call   8024ca <fprintf>
  801078:	83 c4 10             	add    $0x10,%esp
#endif

	i = 0;
	echoing = iscons(0);
  80107b:	83 ec 0c             	sub    $0xc,%esp
  80107e:	6a 00                	push   $0x0
  801080:	e8 aa f8 ff ff       	call   80092f <iscons>
  801085:	89 c7                	mov    %eax,%edi
  801087:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
  80108a:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
  80108f:	e8 70 f8 ff ff       	call   800904 <getchar>
  801094:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  801096:	85 c0                	test   %eax,%eax
  801098:	79 29                	jns    8010c3 <readline+0x6b>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  80109a:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
  80109f:	83 fb f8             	cmp    $0xfffffff8,%ebx
  8010a2:	0f 84 9b 00 00 00    	je     801143 <readline+0xeb>
				cprintf("read error: %e\n", c);
  8010a8:	83 ec 08             	sub    $0x8,%esp
  8010ab:	53                   	push   %ebx
  8010ac:	68 df 37 80 00       	push   $0x8037df
  8010b1:	e8 38 fa ff ff       	call   800aee <cprintf>
  8010b6:	83 c4 10             	add    $0x10,%esp
			return NULL;
  8010b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8010be:	e9 80 00 00 00       	jmp    801143 <readline+0xeb>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  8010c3:	83 f8 08             	cmp    $0x8,%eax
  8010c6:	0f 94 c2             	sete   %dl
  8010c9:	83 f8 7f             	cmp    $0x7f,%eax
  8010cc:	0f 94 c0             	sete   %al
  8010cf:	08 c2                	or     %al,%dl
  8010d1:	74 1a                	je     8010ed <readline+0x95>
  8010d3:	85 f6                	test   %esi,%esi
  8010d5:	7e 16                	jle    8010ed <readline+0x95>
			if (echoing)
  8010d7:	85 ff                	test   %edi,%edi
  8010d9:	74 0d                	je     8010e8 <readline+0x90>
				cputchar('\b');
  8010db:	83 ec 0c             	sub    $0xc,%esp
  8010de:	6a 08                	push   $0x8
  8010e0:	e8 03 f8 ff ff       	call   8008e8 <cputchar>
  8010e5:	83 c4 10             	add    $0x10,%esp
			i--;
  8010e8:	83 ee 01             	sub    $0x1,%esi
  8010eb:	eb a2                	jmp    80108f <readline+0x37>
		} else if (c >= ' ' && i < BUFLEN-1) {
  8010ed:	83 fb 1f             	cmp    $0x1f,%ebx
  8010f0:	7e 26                	jle    801118 <readline+0xc0>
  8010f2:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  8010f8:	7f 1e                	jg     801118 <readline+0xc0>
			if (echoing)
  8010fa:	85 ff                	test   %edi,%edi
  8010fc:	74 0c                	je     80110a <readline+0xb2>
				cputchar(c);
  8010fe:	83 ec 0c             	sub    $0xc,%esp
  801101:	53                   	push   %ebx
  801102:	e8 e1 f7 ff ff       	call   8008e8 <cputchar>
  801107:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
  80110a:	88 9e 20 50 80 00    	mov    %bl,0x805020(%esi)
  801110:	8d 76 01             	lea    0x1(%esi),%esi
  801113:	e9 77 ff ff ff       	jmp    80108f <readline+0x37>
		} else if (c == '\n' || c == '\r') {
  801118:	83 fb 0a             	cmp    $0xa,%ebx
  80111b:	74 09                	je     801126 <readline+0xce>
  80111d:	83 fb 0d             	cmp    $0xd,%ebx
  801120:	0f 85 69 ff ff ff    	jne    80108f <readline+0x37>
			if (echoing)
  801126:	85 ff                	test   %edi,%edi
  801128:	74 0d                	je     801137 <readline+0xdf>
				cputchar('\n');
  80112a:	83 ec 0c             	sub    $0xc,%esp
  80112d:	6a 0a                	push   $0xa
  80112f:	e8 b4 f7 ff ff       	call   8008e8 <cputchar>
  801134:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
  801137:	c6 86 20 50 80 00 00 	movb   $0x0,0x805020(%esi)
			return buf;
  80113e:	b8 20 50 80 00       	mov    $0x805020,%eax
		}
	}
}
  801143:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801146:	5b                   	pop    %ebx
  801147:	5e                   	pop    %esi
  801148:	5f                   	pop    %edi
  801149:	5d                   	pop    %ebp
  80114a:	c3                   	ret    

0080114b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80114b:	55                   	push   %ebp
  80114c:	89 e5                	mov    %esp,%ebp
  80114e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801151:	b8 00 00 00 00       	mov    $0x0,%eax
  801156:	eb 03                	jmp    80115b <strlen+0x10>
		n++;
  801158:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80115b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80115f:	75 f7                	jne    801158 <strlen+0xd>
		n++;
	return n;
}
  801161:	5d                   	pop    %ebp
  801162:	c3                   	ret    

00801163 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801163:	55                   	push   %ebp
  801164:	89 e5                	mov    %esp,%ebp
  801166:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801169:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80116c:	ba 00 00 00 00       	mov    $0x0,%edx
  801171:	eb 03                	jmp    801176 <strnlen+0x13>
		n++;
  801173:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801176:	39 c2                	cmp    %eax,%edx
  801178:	74 08                	je     801182 <strnlen+0x1f>
  80117a:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80117e:	75 f3                	jne    801173 <strnlen+0x10>
  801180:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801182:	5d                   	pop    %ebp
  801183:	c3                   	ret    

00801184 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801184:	55                   	push   %ebp
  801185:	89 e5                	mov    %esp,%ebp
  801187:	53                   	push   %ebx
  801188:	8b 45 08             	mov    0x8(%ebp),%eax
  80118b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80118e:	89 c2                	mov    %eax,%edx
  801190:	83 c2 01             	add    $0x1,%edx
  801193:	83 c1 01             	add    $0x1,%ecx
  801196:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80119a:	88 5a ff             	mov    %bl,-0x1(%edx)
  80119d:	84 db                	test   %bl,%bl
  80119f:	75 ef                	jne    801190 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8011a1:	5b                   	pop    %ebx
  8011a2:	5d                   	pop    %ebp
  8011a3:	c3                   	ret    

008011a4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8011a4:	55                   	push   %ebp
  8011a5:	89 e5                	mov    %esp,%ebp
  8011a7:	53                   	push   %ebx
  8011a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8011ab:	53                   	push   %ebx
  8011ac:	e8 9a ff ff ff       	call   80114b <strlen>
  8011b1:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8011b4:	ff 75 0c             	pushl  0xc(%ebp)
  8011b7:	01 d8                	add    %ebx,%eax
  8011b9:	50                   	push   %eax
  8011ba:	e8 c5 ff ff ff       	call   801184 <strcpy>
	return dst;
}
  8011bf:	89 d8                	mov    %ebx,%eax
  8011c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011c4:	c9                   	leave  
  8011c5:	c3                   	ret    

008011c6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8011c6:	55                   	push   %ebp
  8011c7:	89 e5                	mov    %esp,%ebp
  8011c9:	56                   	push   %esi
  8011ca:	53                   	push   %ebx
  8011cb:	8b 75 08             	mov    0x8(%ebp),%esi
  8011ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011d1:	89 f3                	mov    %esi,%ebx
  8011d3:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8011d6:	89 f2                	mov    %esi,%edx
  8011d8:	eb 0f                	jmp    8011e9 <strncpy+0x23>
		*dst++ = *src;
  8011da:	83 c2 01             	add    $0x1,%edx
  8011dd:	0f b6 01             	movzbl (%ecx),%eax
  8011e0:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8011e3:	80 39 01             	cmpb   $0x1,(%ecx)
  8011e6:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8011e9:	39 da                	cmp    %ebx,%edx
  8011eb:	75 ed                	jne    8011da <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8011ed:	89 f0                	mov    %esi,%eax
  8011ef:	5b                   	pop    %ebx
  8011f0:	5e                   	pop    %esi
  8011f1:	5d                   	pop    %ebp
  8011f2:	c3                   	ret    

008011f3 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8011f3:	55                   	push   %ebp
  8011f4:	89 e5                	mov    %esp,%ebp
  8011f6:	56                   	push   %esi
  8011f7:	53                   	push   %ebx
  8011f8:	8b 75 08             	mov    0x8(%ebp),%esi
  8011fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011fe:	8b 55 10             	mov    0x10(%ebp),%edx
  801201:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801203:	85 d2                	test   %edx,%edx
  801205:	74 21                	je     801228 <strlcpy+0x35>
  801207:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80120b:	89 f2                	mov    %esi,%edx
  80120d:	eb 09                	jmp    801218 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80120f:	83 c2 01             	add    $0x1,%edx
  801212:	83 c1 01             	add    $0x1,%ecx
  801215:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801218:	39 c2                	cmp    %eax,%edx
  80121a:	74 09                	je     801225 <strlcpy+0x32>
  80121c:	0f b6 19             	movzbl (%ecx),%ebx
  80121f:	84 db                	test   %bl,%bl
  801221:	75 ec                	jne    80120f <strlcpy+0x1c>
  801223:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801225:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801228:	29 f0                	sub    %esi,%eax
}
  80122a:	5b                   	pop    %ebx
  80122b:	5e                   	pop    %esi
  80122c:	5d                   	pop    %ebp
  80122d:	c3                   	ret    

0080122e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80122e:	55                   	push   %ebp
  80122f:	89 e5                	mov    %esp,%ebp
  801231:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801234:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801237:	eb 06                	jmp    80123f <strcmp+0x11>
		p++, q++;
  801239:	83 c1 01             	add    $0x1,%ecx
  80123c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80123f:	0f b6 01             	movzbl (%ecx),%eax
  801242:	84 c0                	test   %al,%al
  801244:	74 04                	je     80124a <strcmp+0x1c>
  801246:	3a 02                	cmp    (%edx),%al
  801248:	74 ef                	je     801239 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80124a:	0f b6 c0             	movzbl %al,%eax
  80124d:	0f b6 12             	movzbl (%edx),%edx
  801250:	29 d0                	sub    %edx,%eax
}
  801252:	5d                   	pop    %ebp
  801253:	c3                   	ret    

00801254 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801254:	55                   	push   %ebp
  801255:	89 e5                	mov    %esp,%ebp
  801257:	53                   	push   %ebx
  801258:	8b 45 08             	mov    0x8(%ebp),%eax
  80125b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80125e:	89 c3                	mov    %eax,%ebx
  801260:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801263:	eb 06                	jmp    80126b <strncmp+0x17>
		n--, p++, q++;
  801265:	83 c0 01             	add    $0x1,%eax
  801268:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80126b:	39 d8                	cmp    %ebx,%eax
  80126d:	74 15                	je     801284 <strncmp+0x30>
  80126f:	0f b6 08             	movzbl (%eax),%ecx
  801272:	84 c9                	test   %cl,%cl
  801274:	74 04                	je     80127a <strncmp+0x26>
  801276:	3a 0a                	cmp    (%edx),%cl
  801278:	74 eb                	je     801265 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80127a:	0f b6 00             	movzbl (%eax),%eax
  80127d:	0f b6 12             	movzbl (%edx),%edx
  801280:	29 d0                	sub    %edx,%eax
  801282:	eb 05                	jmp    801289 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801284:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801289:	5b                   	pop    %ebx
  80128a:	5d                   	pop    %ebp
  80128b:	c3                   	ret    

0080128c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80128c:	55                   	push   %ebp
  80128d:	89 e5                	mov    %esp,%ebp
  80128f:	8b 45 08             	mov    0x8(%ebp),%eax
  801292:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801296:	eb 07                	jmp    80129f <strchr+0x13>
		if (*s == c)
  801298:	38 ca                	cmp    %cl,%dl
  80129a:	74 0f                	je     8012ab <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80129c:	83 c0 01             	add    $0x1,%eax
  80129f:	0f b6 10             	movzbl (%eax),%edx
  8012a2:	84 d2                	test   %dl,%dl
  8012a4:	75 f2                	jne    801298 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8012a6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012ab:	5d                   	pop    %ebp
  8012ac:	c3                   	ret    

008012ad <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8012ad:	55                   	push   %ebp
  8012ae:	89 e5                	mov    %esp,%ebp
  8012b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8012b3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8012b7:	eb 03                	jmp    8012bc <strfind+0xf>
  8012b9:	83 c0 01             	add    $0x1,%eax
  8012bc:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8012bf:	38 ca                	cmp    %cl,%dl
  8012c1:	74 04                	je     8012c7 <strfind+0x1a>
  8012c3:	84 d2                	test   %dl,%dl
  8012c5:	75 f2                	jne    8012b9 <strfind+0xc>
			break;
	return (char *) s;
}
  8012c7:	5d                   	pop    %ebp
  8012c8:	c3                   	ret    

008012c9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8012c9:	55                   	push   %ebp
  8012ca:	89 e5                	mov    %esp,%ebp
  8012cc:	57                   	push   %edi
  8012cd:	56                   	push   %esi
  8012ce:	53                   	push   %ebx
  8012cf:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012d2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8012d5:	85 c9                	test   %ecx,%ecx
  8012d7:	74 36                	je     80130f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8012d9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8012df:	75 28                	jne    801309 <memset+0x40>
  8012e1:	f6 c1 03             	test   $0x3,%cl
  8012e4:	75 23                	jne    801309 <memset+0x40>
		c &= 0xFF;
  8012e6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8012ea:	89 d3                	mov    %edx,%ebx
  8012ec:	c1 e3 08             	shl    $0x8,%ebx
  8012ef:	89 d6                	mov    %edx,%esi
  8012f1:	c1 e6 18             	shl    $0x18,%esi
  8012f4:	89 d0                	mov    %edx,%eax
  8012f6:	c1 e0 10             	shl    $0x10,%eax
  8012f9:	09 f0                	or     %esi,%eax
  8012fb:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8012fd:	89 d8                	mov    %ebx,%eax
  8012ff:	09 d0                	or     %edx,%eax
  801301:	c1 e9 02             	shr    $0x2,%ecx
  801304:	fc                   	cld    
  801305:	f3 ab                	rep stos %eax,%es:(%edi)
  801307:	eb 06                	jmp    80130f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801309:	8b 45 0c             	mov    0xc(%ebp),%eax
  80130c:	fc                   	cld    
  80130d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80130f:	89 f8                	mov    %edi,%eax
  801311:	5b                   	pop    %ebx
  801312:	5e                   	pop    %esi
  801313:	5f                   	pop    %edi
  801314:	5d                   	pop    %ebp
  801315:	c3                   	ret    

00801316 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801316:	55                   	push   %ebp
  801317:	89 e5                	mov    %esp,%ebp
  801319:	57                   	push   %edi
  80131a:	56                   	push   %esi
  80131b:	8b 45 08             	mov    0x8(%ebp),%eax
  80131e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801321:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801324:	39 c6                	cmp    %eax,%esi
  801326:	73 35                	jae    80135d <memmove+0x47>
  801328:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80132b:	39 d0                	cmp    %edx,%eax
  80132d:	73 2e                	jae    80135d <memmove+0x47>
		s += n;
		d += n;
  80132f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801332:	89 d6                	mov    %edx,%esi
  801334:	09 fe                	or     %edi,%esi
  801336:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80133c:	75 13                	jne    801351 <memmove+0x3b>
  80133e:	f6 c1 03             	test   $0x3,%cl
  801341:	75 0e                	jne    801351 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801343:	83 ef 04             	sub    $0x4,%edi
  801346:	8d 72 fc             	lea    -0x4(%edx),%esi
  801349:	c1 e9 02             	shr    $0x2,%ecx
  80134c:	fd                   	std    
  80134d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80134f:	eb 09                	jmp    80135a <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801351:	83 ef 01             	sub    $0x1,%edi
  801354:	8d 72 ff             	lea    -0x1(%edx),%esi
  801357:	fd                   	std    
  801358:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80135a:	fc                   	cld    
  80135b:	eb 1d                	jmp    80137a <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80135d:	89 f2                	mov    %esi,%edx
  80135f:	09 c2                	or     %eax,%edx
  801361:	f6 c2 03             	test   $0x3,%dl
  801364:	75 0f                	jne    801375 <memmove+0x5f>
  801366:	f6 c1 03             	test   $0x3,%cl
  801369:	75 0a                	jne    801375 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80136b:	c1 e9 02             	shr    $0x2,%ecx
  80136e:	89 c7                	mov    %eax,%edi
  801370:	fc                   	cld    
  801371:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801373:	eb 05                	jmp    80137a <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801375:	89 c7                	mov    %eax,%edi
  801377:	fc                   	cld    
  801378:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80137a:	5e                   	pop    %esi
  80137b:	5f                   	pop    %edi
  80137c:	5d                   	pop    %ebp
  80137d:	c3                   	ret    

0080137e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80137e:	55                   	push   %ebp
  80137f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801381:	ff 75 10             	pushl  0x10(%ebp)
  801384:	ff 75 0c             	pushl  0xc(%ebp)
  801387:	ff 75 08             	pushl  0x8(%ebp)
  80138a:	e8 87 ff ff ff       	call   801316 <memmove>
}
  80138f:	c9                   	leave  
  801390:	c3                   	ret    

00801391 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801391:	55                   	push   %ebp
  801392:	89 e5                	mov    %esp,%ebp
  801394:	56                   	push   %esi
  801395:	53                   	push   %ebx
  801396:	8b 45 08             	mov    0x8(%ebp),%eax
  801399:	8b 55 0c             	mov    0xc(%ebp),%edx
  80139c:	89 c6                	mov    %eax,%esi
  80139e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8013a1:	eb 1a                	jmp    8013bd <memcmp+0x2c>
		if (*s1 != *s2)
  8013a3:	0f b6 08             	movzbl (%eax),%ecx
  8013a6:	0f b6 1a             	movzbl (%edx),%ebx
  8013a9:	38 d9                	cmp    %bl,%cl
  8013ab:	74 0a                	je     8013b7 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8013ad:	0f b6 c1             	movzbl %cl,%eax
  8013b0:	0f b6 db             	movzbl %bl,%ebx
  8013b3:	29 d8                	sub    %ebx,%eax
  8013b5:	eb 0f                	jmp    8013c6 <memcmp+0x35>
		s1++, s2++;
  8013b7:	83 c0 01             	add    $0x1,%eax
  8013ba:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8013bd:	39 f0                	cmp    %esi,%eax
  8013bf:	75 e2                	jne    8013a3 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8013c1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013c6:	5b                   	pop    %ebx
  8013c7:	5e                   	pop    %esi
  8013c8:	5d                   	pop    %ebp
  8013c9:	c3                   	ret    

008013ca <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8013ca:	55                   	push   %ebp
  8013cb:	89 e5                	mov    %esp,%ebp
  8013cd:	53                   	push   %ebx
  8013ce:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8013d1:	89 c1                	mov    %eax,%ecx
  8013d3:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8013d6:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8013da:	eb 0a                	jmp    8013e6 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8013dc:	0f b6 10             	movzbl (%eax),%edx
  8013df:	39 da                	cmp    %ebx,%edx
  8013e1:	74 07                	je     8013ea <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8013e3:	83 c0 01             	add    $0x1,%eax
  8013e6:	39 c8                	cmp    %ecx,%eax
  8013e8:	72 f2                	jb     8013dc <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8013ea:	5b                   	pop    %ebx
  8013eb:	5d                   	pop    %ebp
  8013ec:	c3                   	ret    

008013ed <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8013ed:	55                   	push   %ebp
  8013ee:	89 e5                	mov    %esp,%ebp
  8013f0:	57                   	push   %edi
  8013f1:	56                   	push   %esi
  8013f2:	53                   	push   %ebx
  8013f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013f6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8013f9:	eb 03                	jmp    8013fe <strtol+0x11>
		s++;
  8013fb:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8013fe:	0f b6 01             	movzbl (%ecx),%eax
  801401:	3c 20                	cmp    $0x20,%al
  801403:	74 f6                	je     8013fb <strtol+0xe>
  801405:	3c 09                	cmp    $0x9,%al
  801407:	74 f2                	je     8013fb <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801409:	3c 2b                	cmp    $0x2b,%al
  80140b:	75 0a                	jne    801417 <strtol+0x2a>
		s++;
  80140d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801410:	bf 00 00 00 00       	mov    $0x0,%edi
  801415:	eb 11                	jmp    801428 <strtol+0x3b>
  801417:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80141c:	3c 2d                	cmp    $0x2d,%al
  80141e:	75 08                	jne    801428 <strtol+0x3b>
		s++, neg = 1;
  801420:	83 c1 01             	add    $0x1,%ecx
  801423:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801428:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80142e:	75 15                	jne    801445 <strtol+0x58>
  801430:	80 39 30             	cmpb   $0x30,(%ecx)
  801433:	75 10                	jne    801445 <strtol+0x58>
  801435:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801439:	75 7c                	jne    8014b7 <strtol+0xca>
		s += 2, base = 16;
  80143b:	83 c1 02             	add    $0x2,%ecx
  80143e:	bb 10 00 00 00       	mov    $0x10,%ebx
  801443:	eb 16                	jmp    80145b <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801445:	85 db                	test   %ebx,%ebx
  801447:	75 12                	jne    80145b <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801449:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80144e:	80 39 30             	cmpb   $0x30,(%ecx)
  801451:	75 08                	jne    80145b <strtol+0x6e>
		s++, base = 8;
  801453:	83 c1 01             	add    $0x1,%ecx
  801456:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  80145b:	b8 00 00 00 00       	mov    $0x0,%eax
  801460:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801463:	0f b6 11             	movzbl (%ecx),%edx
  801466:	8d 72 d0             	lea    -0x30(%edx),%esi
  801469:	89 f3                	mov    %esi,%ebx
  80146b:	80 fb 09             	cmp    $0x9,%bl
  80146e:	77 08                	ja     801478 <strtol+0x8b>
			dig = *s - '0';
  801470:	0f be d2             	movsbl %dl,%edx
  801473:	83 ea 30             	sub    $0x30,%edx
  801476:	eb 22                	jmp    80149a <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801478:	8d 72 9f             	lea    -0x61(%edx),%esi
  80147b:	89 f3                	mov    %esi,%ebx
  80147d:	80 fb 19             	cmp    $0x19,%bl
  801480:	77 08                	ja     80148a <strtol+0x9d>
			dig = *s - 'a' + 10;
  801482:	0f be d2             	movsbl %dl,%edx
  801485:	83 ea 57             	sub    $0x57,%edx
  801488:	eb 10                	jmp    80149a <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  80148a:	8d 72 bf             	lea    -0x41(%edx),%esi
  80148d:	89 f3                	mov    %esi,%ebx
  80148f:	80 fb 19             	cmp    $0x19,%bl
  801492:	77 16                	ja     8014aa <strtol+0xbd>
			dig = *s - 'A' + 10;
  801494:	0f be d2             	movsbl %dl,%edx
  801497:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  80149a:	3b 55 10             	cmp    0x10(%ebp),%edx
  80149d:	7d 0b                	jge    8014aa <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  80149f:	83 c1 01             	add    $0x1,%ecx
  8014a2:	0f af 45 10          	imul   0x10(%ebp),%eax
  8014a6:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8014a8:	eb b9                	jmp    801463 <strtol+0x76>

	if (endptr)
  8014aa:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8014ae:	74 0d                	je     8014bd <strtol+0xd0>
		*endptr = (char *) s;
  8014b0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8014b3:	89 0e                	mov    %ecx,(%esi)
  8014b5:	eb 06                	jmp    8014bd <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8014b7:	85 db                	test   %ebx,%ebx
  8014b9:	74 98                	je     801453 <strtol+0x66>
  8014bb:	eb 9e                	jmp    80145b <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8014bd:	89 c2                	mov    %eax,%edx
  8014bf:	f7 da                	neg    %edx
  8014c1:	85 ff                	test   %edi,%edi
  8014c3:	0f 45 c2             	cmovne %edx,%eax
}
  8014c6:	5b                   	pop    %ebx
  8014c7:	5e                   	pop    %esi
  8014c8:	5f                   	pop    %edi
  8014c9:	5d                   	pop    %ebp
  8014ca:	c3                   	ret    

008014cb <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8014cb:	55                   	push   %ebp
  8014cc:	89 e5                	mov    %esp,%ebp
  8014ce:	57                   	push   %edi
  8014cf:	56                   	push   %esi
  8014d0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8014d6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014d9:	8b 55 08             	mov    0x8(%ebp),%edx
  8014dc:	89 c3                	mov    %eax,%ebx
  8014de:	89 c7                	mov    %eax,%edi
  8014e0:	89 c6                	mov    %eax,%esi
  8014e2:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8014e4:	5b                   	pop    %ebx
  8014e5:	5e                   	pop    %esi
  8014e6:	5f                   	pop    %edi
  8014e7:	5d                   	pop    %ebp
  8014e8:	c3                   	ret    

008014e9 <sys_cgetc>:

int
sys_cgetc(void)
{
  8014e9:	55                   	push   %ebp
  8014ea:	89 e5                	mov    %esp,%ebp
  8014ec:	57                   	push   %edi
  8014ed:	56                   	push   %esi
  8014ee:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8014f4:	b8 01 00 00 00       	mov    $0x1,%eax
  8014f9:	89 d1                	mov    %edx,%ecx
  8014fb:	89 d3                	mov    %edx,%ebx
  8014fd:	89 d7                	mov    %edx,%edi
  8014ff:	89 d6                	mov    %edx,%esi
  801501:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801503:	5b                   	pop    %ebx
  801504:	5e                   	pop    %esi
  801505:	5f                   	pop    %edi
  801506:	5d                   	pop    %ebp
  801507:	c3                   	ret    

00801508 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801508:	55                   	push   %ebp
  801509:	89 e5                	mov    %esp,%ebp
  80150b:	57                   	push   %edi
  80150c:	56                   	push   %esi
  80150d:	53                   	push   %ebx
  80150e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801511:	b9 00 00 00 00       	mov    $0x0,%ecx
  801516:	b8 03 00 00 00       	mov    $0x3,%eax
  80151b:	8b 55 08             	mov    0x8(%ebp),%edx
  80151e:	89 cb                	mov    %ecx,%ebx
  801520:	89 cf                	mov    %ecx,%edi
  801522:	89 ce                	mov    %ecx,%esi
  801524:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801526:	85 c0                	test   %eax,%eax
  801528:	7e 17                	jle    801541 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80152a:	83 ec 0c             	sub    $0xc,%esp
  80152d:	50                   	push   %eax
  80152e:	6a 03                	push   $0x3
  801530:	68 ef 37 80 00       	push   $0x8037ef
  801535:	6a 23                	push   $0x23
  801537:	68 0c 38 80 00       	push   $0x80380c
  80153c:	e8 d4 f4 ff ff       	call   800a15 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801541:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801544:	5b                   	pop    %ebx
  801545:	5e                   	pop    %esi
  801546:	5f                   	pop    %edi
  801547:	5d                   	pop    %ebp
  801548:	c3                   	ret    

00801549 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801549:	55                   	push   %ebp
  80154a:	89 e5                	mov    %esp,%ebp
  80154c:	57                   	push   %edi
  80154d:	56                   	push   %esi
  80154e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80154f:	ba 00 00 00 00       	mov    $0x0,%edx
  801554:	b8 02 00 00 00       	mov    $0x2,%eax
  801559:	89 d1                	mov    %edx,%ecx
  80155b:	89 d3                	mov    %edx,%ebx
  80155d:	89 d7                	mov    %edx,%edi
  80155f:	89 d6                	mov    %edx,%esi
  801561:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801563:	5b                   	pop    %ebx
  801564:	5e                   	pop    %esi
  801565:	5f                   	pop    %edi
  801566:	5d                   	pop    %ebp
  801567:	c3                   	ret    

00801568 <sys_yield>:

void
sys_yield(void)
{
  801568:	55                   	push   %ebp
  801569:	89 e5                	mov    %esp,%ebp
  80156b:	57                   	push   %edi
  80156c:	56                   	push   %esi
  80156d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80156e:	ba 00 00 00 00       	mov    $0x0,%edx
  801573:	b8 0b 00 00 00       	mov    $0xb,%eax
  801578:	89 d1                	mov    %edx,%ecx
  80157a:	89 d3                	mov    %edx,%ebx
  80157c:	89 d7                	mov    %edx,%edi
  80157e:	89 d6                	mov    %edx,%esi
  801580:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801582:	5b                   	pop    %ebx
  801583:	5e                   	pop    %esi
  801584:	5f                   	pop    %edi
  801585:	5d                   	pop    %ebp
  801586:	c3                   	ret    

00801587 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801587:	55                   	push   %ebp
  801588:	89 e5                	mov    %esp,%ebp
  80158a:	57                   	push   %edi
  80158b:	56                   	push   %esi
  80158c:	53                   	push   %ebx
  80158d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801590:	be 00 00 00 00       	mov    $0x0,%esi
  801595:	b8 04 00 00 00       	mov    $0x4,%eax
  80159a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80159d:	8b 55 08             	mov    0x8(%ebp),%edx
  8015a0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8015a3:	89 f7                	mov    %esi,%edi
  8015a5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8015a7:	85 c0                	test   %eax,%eax
  8015a9:	7e 17                	jle    8015c2 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8015ab:	83 ec 0c             	sub    $0xc,%esp
  8015ae:	50                   	push   %eax
  8015af:	6a 04                	push   $0x4
  8015b1:	68 ef 37 80 00       	push   $0x8037ef
  8015b6:	6a 23                	push   $0x23
  8015b8:	68 0c 38 80 00       	push   $0x80380c
  8015bd:	e8 53 f4 ff ff       	call   800a15 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8015c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015c5:	5b                   	pop    %ebx
  8015c6:	5e                   	pop    %esi
  8015c7:	5f                   	pop    %edi
  8015c8:	5d                   	pop    %ebp
  8015c9:	c3                   	ret    

008015ca <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8015ca:	55                   	push   %ebp
  8015cb:	89 e5                	mov    %esp,%ebp
  8015cd:	57                   	push   %edi
  8015ce:	56                   	push   %esi
  8015cf:	53                   	push   %ebx
  8015d0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015d3:	b8 05 00 00 00       	mov    $0x5,%eax
  8015d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015db:	8b 55 08             	mov    0x8(%ebp),%edx
  8015de:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8015e1:	8b 7d 14             	mov    0x14(%ebp),%edi
  8015e4:	8b 75 18             	mov    0x18(%ebp),%esi
  8015e7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8015e9:	85 c0                	test   %eax,%eax
  8015eb:	7e 17                	jle    801604 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8015ed:	83 ec 0c             	sub    $0xc,%esp
  8015f0:	50                   	push   %eax
  8015f1:	6a 05                	push   $0x5
  8015f3:	68 ef 37 80 00       	push   $0x8037ef
  8015f8:	6a 23                	push   $0x23
  8015fa:	68 0c 38 80 00       	push   $0x80380c
  8015ff:	e8 11 f4 ff ff       	call   800a15 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801604:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801607:	5b                   	pop    %ebx
  801608:	5e                   	pop    %esi
  801609:	5f                   	pop    %edi
  80160a:	5d                   	pop    %ebp
  80160b:	c3                   	ret    

0080160c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80160c:	55                   	push   %ebp
  80160d:	89 e5                	mov    %esp,%ebp
  80160f:	57                   	push   %edi
  801610:	56                   	push   %esi
  801611:	53                   	push   %ebx
  801612:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801615:	bb 00 00 00 00       	mov    $0x0,%ebx
  80161a:	b8 06 00 00 00       	mov    $0x6,%eax
  80161f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801622:	8b 55 08             	mov    0x8(%ebp),%edx
  801625:	89 df                	mov    %ebx,%edi
  801627:	89 de                	mov    %ebx,%esi
  801629:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80162b:	85 c0                	test   %eax,%eax
  80162d:	7e 17                	jle    801646 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80162f:	83 ec 0c             	sub    $0xc,%esp
  801632:	50                   	push   %eax
  801633:	6a 06                	push   $0x6
  801635:	68 ef 37 80 00       	push   $0x8037ef
  80163a:	6a 23                	push   $0x23
  80163c:	68 0c 38 80 00       	push   $0x80380c
  801641:	e8 cf f3 ff ff       	call   800a15 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801646:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801649:	5b                   	pop    %ebx
  80164a:	5e                   	pop    %esi
  80164b:	5f                   	pop    %edi
  80164c:	5d                   	pop    %ebp
  80164d:	c3                   	ret    

0080164e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80164e:	55                   	push   %ebp
  80164f:	89 e5                	mov    %esp,%ebp
  801651:	57                   	push   %edi
  801652:	56                   	push   %esi
  801653:	53                   	push   %ebx
  801654:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801657:	bb 00 00 00 00       	mov    $0x0,%ebx
  80165c:	b8 08 00 00 00       	mov    $0x8,%eax
  801661:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801664:	8b 55 08             	mov    0x8(%ebp),%edx
  801667:	89 df                	mov    %ebx,%edi
  801669:	89 de                	mov    %ebx,%esi
  80166b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80166d:	85 c0                	test   %eax,%eax
  80166f:	7e 17                	jle    801688 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801671:	83 ec 0c             	sub    $0xc,%esp
  801674:	50                   	push   %eax
  801675:	6a 08                	push   $0x8
  801677:	68 ef 37 80 00       	push   $0x8037ef
  80167c:	6a 23                	push   $0x23
  80167e:	68 0c 38 80 00       	push   $0x80380c
  801683:	e8 8d f3 ff ff       	call   800a15 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801688:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80168b:	5b                   	pop    %ebx
  80168c:	5e                   	pop    %esi
  80168d:	5f                   	pop    %edi
  80168e:	5d                   	pop    %ebp
  80168f:	c3                   	ret    

00801690 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801690:	55                   	push   %ebp
  801691:	89 e5                	mov    %esp,%ebp
  801693:	57                   	push   %edi
  801694:	56                   	push   %esi
  801695:	53                   	push   %ebx
  801696:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801699:	bb 00 00 00 00       	mov    $0x0,%ebx
  80169e:	b8 09 00 00 00       	mov    $0x9,%eax
  8016a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8016a9:	89 df                	mov    %ebx,%edi
  8016ab:	89 de                	mov    %ebx,%esi
  8016ad:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8016af:	85 c0                	test   %eax,%eax
  8016b1:	7e 17                	jle    8016ca <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8016b3:	83 ec 0c             	sub    $0xc,%esp
  8016b6:	50                   	push   %eax
  8016b7:	6a 09                	push   $0x9
  8016b9:	68 ef 37 80 00       	push   $0x8037ef
  8016be:	6a 23                	push   $0x23
  8016c0:	68 0c 38 80 00       	push   $0x80380c
  8016c5:	e8 4b f3 ff ff       	call   800a15 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8016ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016cd:	5b                   	pop    %ebx
  8016ce:	5e                   	pop    %esi
  8016cf:	5f                   	pop    %edi
  8016d0:	5d                   	pop    %ebp
  8016d1:	c3                   	ret    

008016d2 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8016d2:	55                   	push   %ebp
  8016d3:	89 e5                	mov    %esp,%ebp
  8016d5:	57                   	push   %edi
  8016d6:	56                   	push   %esi
  8016d7:	53                   	push   %ebx
  8016d8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8016db:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016e0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8016e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8016eb:	89 df                	mov    %ebx,%edi
  8016ed:	89 de                	mov    %ebx,%esi
  8016ef:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8016f1:	85 c0                	test   %eax,%eax
  8016f3:	7e 17                	jle    80170c <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8016f5:	83 ec 0c             	sub    $0xc,%esp
  8016f8:	50                   	push   %eax
  8016f9:	6a 0a                	push   $0xa
  8016fb:	68 ef 37 80 00       	push   $0x8037ef
  801700:	6a 23                	push   $0x23
  801702:	68 0c 38 80 00       	push   $0x80380c
  801707:	e8 09 f3 ff ff       	call   800a15 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80170c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80170f:	5b                   	pop    %ebx
  801710:	5e                   	pop    %esi
  801711:	5f                   	pop    %edi
  801712:	5d                   	pop    %ebp
  801713:	c3                   	ret    

00801714 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801714:	55                   	push   %ebp
  801715:	89 e5                	mov    %esp,%ebp
  801717:	57                   	push   %edi
  801718:	56                   	push   %esi
  801719:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80171a:	be 00 00 00 00       	mov    $0x0,%esi
  80171f:	b8 0c 00 00 00       	mov    $0xc,%eax
  801724:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801727:	8b 55 08             	mov    0x8(%ebp),%edx
  80172a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80172d:	8b 7d 14             	mov    0x14(%ebp),%edi
  801730:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801732:	5b                   	pop    %ebx
  801733:	5e                   	pop    %esi
  801734:	5f                   	pop    %edi
  801735:	5d                   	pop    %ebp
  801736:	c3                   	ret    

00801737 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801737:	55                   	push   %ebp
  801738:	89 e5                	mov    %esp,%ebp
  80173a:	57                   	push   %edi
  80173b:	56                   	push   %esi
  80173c:	53                   	push   %ebx
  80173d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801740:	b9 00 00 00 00       	mov    $0x0,%ecx
  801745:	b8 0d 00 00 00       	mov    $0xd,%eax
  80174a:	8b 55 08             	mov    0x8(%ebp),%edx
  80174d:	89 cb                	mov    %ecx,%ebx
  80174f:	89 cf                	mov    %ecx,%edi
  801751:	89 ce                	mov    %ecx,%esi
  801753:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801755:	85 c0                	test   %eax,%eax
  801757:	7e 17                	jle    801770 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801759:	83 ec 0c             	sub    $0xc,%esp
  80175c:	50                   	push   %eax
  80175d:	6a 0d                	push   $0xd
  80175f:	68 ef 37 80 00       	push   $0x8037ef
  801764:	6a 23                	push   $0x23
  801766:	68 0c 38 80 00       	push   $0x80380c
  80176b:	e8 a5 f2 ff ff       	call   800a15 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801770:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801773:	5b                   	pop    %ebx
  801774:	5e                   	pop    %esi
  801775:	5f                   	pop    %edi
  801776:	5d                   	pop    %ebp
  801777:	c3                   	ret    

00801778 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  801778:	55                   	push   %ebp
  801779:	89 e5                	mov    %esp,%ebp
  80177b:	53                   	push   %ebx
  80177c:	83 ec 04             	sub    $0x4,%esp
	int r;
	// LAB 4: Your code here.
    	pte_t *pte;
	int ret;
	// 用户空间的地址较低
	void *addr = (void *)(pn * PGSIZE);
  80177f:	89 d3                	mov    %edx,%ebx
  801781:	c1 e3 0c             	shl    $0xc,%ebx
	if (uvpt[pn] & PTE_SHARE) {
  801784:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  80178b:	f6 c5 04             	test   $0x4,%ch
  80178e:	74 2f                	je     8017bf <duppage+0x47>
		// cprintf("dup share page :%d\n", pn);
		if ((r = sys_page_map(0, addr, envid, addr, PTE_SYSCALL)) < 0)
  801790:	83 ec 0c             	sub    $0xc,%esp
  801793:	68 07 0e 00 00       	push   $0xe07
  801798:	53                   	push   %ebx
  801799:	50                   	push   %eax
  80179a:	53                   	push   %ebx
  80179b:	6a 00                	push   $0x0
  80179d:	e8 28 fe ff ff       	call   8015ca <sys_page_map>
  8017a2:	83 c4 20             	add    $0x20,%esp
  8017a5:	85 c0                	test   %eax,%eax
  8017a7:	0f 89 a0 00 00 00    	jns    80184d <duppage+0xd5>
			panic("duppage sys_page_map:%e", r);
  8017ad:	50                   	push   %eax
  8017ae:	68 1a 38 80 00       	push   $0x80381a
  8017b3:	6a 4d                	push   $0x4d
  8017b5:	68 32 38 80 00       	push   $0x803832
  8017ba:	e8 56 f2 ff ff       	call   800a15 <_panic>
	} else if (uvpt[pn] & (PTE_W|PTE_COW)) {
  8017bf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8017c6:	f7 c2 02 08 00 00    	test   $0x802,%edx
  8017cc:	74 57                	je     801825 <duppage+0xad>
		if ((r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  8017ce:	83 ec 0c             	sub    $0xc,%esp
  8017d1:	68 05 08 00 00       	push   $0x805
  8017d6:	53                   	push   %ebx
  8017d7:	50                   	push   %eax
  8017d8:	53                   	push   %ebx
  8017d9:	6a 00                	push   $0x0
  8017db:	e8 ea fd ff ff       	call   8015ca <sys_page_map>
  8017e0:	83 c4 20             	add    $0x20,%esp
  8017e3:	85 c0                	test   %eax,%eax
  8017e5:	79 12                	jns    8017f9 <duppage+0x81>
			panic("sys_page_map COW:%e", r);
  8017e7:	50                   	push   %eax
  8017e8:	68 3d 38 80 00       	push   $0x80383d
  8017ed:	6a 50                	push   $0x50
  8017ef:	68 32 38 80 00       	push   $0x803832
  8017f4:	e8 1c f2 ff ff       	call   800a15 <_panic>

		if ((r = sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  8017f9:	83 ec 0c             	sub    $0xc,%esp
  8017fc:	68 05 08 00 00       	push   $0x805
  801801:	53                   	push   %ebx
  801802:	6a 00                	push   $0x0
  801804:	53                   	push   %ebx
  801805:	6a 00                	push   $0x0
  801807:	e8 be fd ff ff       	call   8015ca <sys_page_map>
  80180c:	83 c4 20             	add    $0x20,%esp
  80180f:	85 c0                	test   %eax,%eax
  801811:	79 3a                	jns    80184d <duppage+0xd5>
			panic("sys_page_map COW:%e", r);
  801813:	50                   	push   %eax
  801814:	68 3d 38 80 00       	push   $0x80383d
  801819:	6a 53                	push   $0x53
  80181b:	68 32 38 80 00       	push   $0x803832
  801820:	e8 f0 f1 ff ff       	call   800a15 <_panic>
	} else {
		if ((r = sys_page_map(0, addr, envid, addr, PTE_U|PTE_P)) < 0)
  801825:	83 ec 0c             	sub    $0xc,%esp
  801828:	6a 05                	push   $0x5
  80182a:	53                   	push   %ebx
  80182b:	50                   	push   %eax
  80182c:	53                   	push   %ebx
  80182d:	6a 00                	push   $0x0
  80182f:	e8 96 fd ff ff       	call   8015ca <sys_page_map>
  801834:	83 c4 20             	add    $0x20,%esp
  801837:	85 c0                	test   %eax,%eax
  801839:	79 12                	jns    80184d <duppage+0xd5>
			panic("sys_page_map UP:%e", r);
  80183b:	50                   	push   %eax
  80183c:	68 51 38 80 00       	push   $0x803851
  801841:	6a 56                	push   $0x56
  801843:	68 32 38 80 00       	push   $0x803832
  801848:	e8 c8 f1 ff ff       	call   800a15 <_panic>
	}
	return 0;
}
  80184d:	b8 00 00 00 00       	mov    $0x0,%eax
  801852:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801855:	c9                   	leave  
  801856:	c3                   	ret    

00801857 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801857:	55                   	push   %ebp
  801858:	89 e5                	mov    %esp,%ebp
  80185a:	56                   	push   %esi
  80185b:	53                   	push   %ebx
  80185c:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  80185f:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (! ( (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  801861:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801865:	74 2d                	je     801894 <pgfault+0x3d>
  801867:	89 d8                	mov    %ebx,%eax
  801869:	c1 e8 16             	shr    $0x16,%eax
  80186c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801873:	a8 01                	test   $0x1,%al
  801875:	74 1d                	je     801894 <pgfault+0x3d>
  801877:	89 d8                	mov    %ebx,%eax
  801879:	c1 e8 0c             	shr    $0xc,%eax
  80187c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801883:	f6 c2 01             	test   $0x1,%dl
  801886:	74 0c                	je     801894 <pgfault+0x3d>
  801888:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80188f:	f6 c4 08             	test   $0x8,%ah
  801892:	75 14                	jne    8018a8 <pgfault+0x51>
        	panic("Neither the fault is a write nor COW page. \n");
  801894:	83 ec 04             	sub    $0x4,%esp
  801897:	68 d0 38 80 00       	push   $0x8038d0
  80189c:	6a 1d                	push   $0x1d
  80189e:	68 32 38 80 00       	push   $0x803832
  8018a3:	e8 6d f1 ff ff       	call   800a15 <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.
	

    	envid_t envid = sys_getenvid();
  8018a8:	e8 9c fc ff ff       	call   801549 <sys_getenvid>
  8018ad:	89 c6                	mov    %eax,%esi
    	// cprintf("pgfault: envid: %d\n", ENVX(envid));
    	// 临时页暂存
    	if ((r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P| PTE_W|PTE_U)) < 0)
  8018af:	83 ec 04             	sub    $0x4,%esp
  8018b2:	6a 07                	push   $0x7
  8018b4:	68 00 f0 7f 00       	push   $0x7ff000
  8018b9:	50                   	push   %eax
  8018ba:	e8 c8 fc ff ff       	call   801587 <sys_page_alloc>
  8018bf:	83 c4 10             	add    $0x10,%esp
  8018c2:	85 c0                	test   %eax,%eax
  8018c4:	79 12                	jns    8018d8 <pgfault+0x81>
        	panic("pgfault: page allocation fault:%e\n", r);
  8018c6:	50                   	push   %eax
  8018c7:	68 00 39 80 00       	push   $0x803900
  8018cc:	6a 2b                	push   $0x2b
  8018ce:	68 32 38 80 00       	push   $0x803832
  8018d3:	e8 3d f1 ff ff       	call   800a15 <_panic>
    	addr = ROUNDDOWN(addr, PGSIZE);
  8018d8:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  8018de:	83 ec 04             	sub    $0x4,%esp
  8018e1:	68 00 10 00 00       	push   $0x1000
  8018e6:	53                   	push   %ebx
  8018e7:	68 00 f0 7f 00       	push   $0x7ff000
  8018ec:	e8 8d fa ff ff       	call   80137e <memcpy>
    	if ((r = sys_page_map(envid, (void *) PFTEMP, envid, addr , PTE_P|PTE_W|PTE_U)) < 0 )
  8018f1:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  8018f8:	53                   	push   %ebx
  8018f9:	56                   	push   %esi
  8018fa:	68 00 f0 7f 00       	push   $0x7ff000
  8018ff:	56                   	push   %esi
  801900:	e8 c5 fc ff ff       	call   8015ca <sys_page_map>
  801905:	83 c4 20             	add    $0x20,%esp
  801908:	85 c0                	test   %eax,%eax
  80190a:	79 12                	jns    80191e <pgfault+0xc7>
        	panic("pgfault: page map failed %e\n", r);
  80190c:	50                   	push   %eax
  80190d:	68 64 38 80 00       	push   $0x803864
  801912:	6a 2f                	push   $0x2f
  801914:	68 32 38 80 00       	push   $0x803832
  801919:	e8 f7 f0 ff ff       	call   800a15 <_panic>
    
    	if ((r = sys_page_unmap(envid, (void *) PFTEMP)) < 0)
  80191e:	83 ec 08             	sub    $0x8,%esp
  801921:	68 00 f0 7f 00       	push   $0x7ff000
  801926:	56                   	push   %esi
  801927:	e8 e0 fc ff ff       	call   80160c <sys_page_unmap>
  80192c:	83 c4 10             	add    $0x10,%esp
  80192f:	85 c0                	test   %eax,%eax
  801931:	79 12                	jns    801945 <pgfault+0xee>
        	panic("pgfault: page unmap failed %e\n", r);
  801933:	50                   	push   %eax
  801934:	68 24 39 80 00       	push   $0x803924
  801939:	6a 32                	push   $0x32
  80193b:	68 32 38 80 00       	push   $0x803832
  801940:	e8 d0 f0 ff ff       	call   800a15 <_panic>
	//panic("pgfault not implemented");
}
  801945:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801948:	5b                   	pop    %ebx
  801949:	5e                   	pop    %esi
  80194a:	5d                   	pop    %ebp
  80194b:	c3                   	ret    

0080194c <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80194c:	55                   	push   %ebp
  80194d:	89 e5                	mov    %esp,%ebp
  80194f:	56                   	push   %esi
  801950:	53                   	push   %ebx
  801951:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	set_pgfault_handler(pgfault);
  801954:	68 57 18 80 00       	push   $0x801857
  801959:	e8 f8 14 00 00       	call   802e56 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80195e:	b8 07 00 00 00       	mov    $0x7,%eax
  801963:	cd 30                	int    $0x30
  801965:	89 c3                	mov    %eax,%ebx

	envid_t envid = sys_exofork();
	uint8_t *addr;
	if (envid < 0)
  801967:	83 c4 10             	add    $0x10,%esp
  80196a:	85 c0                	test   %eax,%eax
  80196c:	79 12                	jns    801980 <fork+0x34>
		panic("sys_exofork:%e", envid);
  80196e:	50                   	push   %eax
  80196f:	68 81 38 80 00       	push   $0x803881
  801974:	6a 75                	push   $0x75
  801976:	68 32 38 80 00       	push   $0x803832
  80197b:	e8 95 f0 ff ff       	call   800a15 <_panic>
  801980:	89 c6                	mov    %eax,%esi
	if (envid == 0) {
  801982:	85 c0                	test   %eax,%eax
  801984:	75 21                	jne    8019a7 <fork+0x5b>
		thisenv = &envs[ENVX(sys_getenvid())];
  801986:	e8 be fb ff ff       	call   801549 <sys_getenvid>
  80198b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801990:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801993:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801998:	a3 24 54 80 00       	mov    %eax,0x805424
		return 0;
  80199d:	b8 00 00 00 00       	mov    $0x0,%eax
  8019a2:	e9 c0 00 00 00       	jmp    801a67 <fork+0x11b>
	}

	for (addr = (uint8_t *)UTEXT; addr < (uint8_t *)USTACKTOP-PGSIZE; addr += PGSIZE) {
  8019a7:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  8019ae:	ba 00 00 80 00       	mov    $0x800000,%edx
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
  8019b3:	89 d0                	mov    %edx,%eax
  8019b5:	c1 e8 16             	shr    $0x16,%eax
  8019b8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8019bf:	a8 01                	test   $0x1,%al
  8019c1:	74 20                	je     8019e3 <fork+0x97>
  8019c3:	c1 ea 0c             	shr    $0xc,%edx
  8019c6:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8019cd:	a8 01                	test   $0x1,%al
  8019cf:	74 12                	je     8019e3 <fork+0x97>
				&& (uvpt[PGNUM(addr)] & PTE_U)) {
  8019d1:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8019d8:	a8 04                	test   $0x4,%al
  8019da:	74 07                	je     8019e3 <fork+0x97>
			duppage(envid, PGNUM(addr));
  8019dc:	89 f0                	mov    %esi,%eax
  8019de:	e8 95 fd ff ff       	call   801778 <duppage>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}

	for (addr = (uint8_t *)UTEXT; addr < (uint8_t *)USTACKTOP-PGSIZE; addr += PGSIZE) {
  8019e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019e6:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
  8019ec:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8019ef:	81 fa ff cf bf ee    	cmp    $0xeebfcfff,%edx
  8019f5:	76 bc                	jbe    8019b3 <fork+0x67>
				&& (uvpt[PGNUM(addr)] & PTE_U)) {
			duppage(envid, PGNUM(addr));
		}
	}

	duppage(envid, PGNUM(ROUNDDOWN(&addr, PGSIZE)));
  8019f7:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8019fa:	c1 ea 0c             	shr    $0xc,%edx
  8019fd:	89 d8                	mov    %ebx,%eax
  8019ff:	e8 74 fd ff ff       	call   801778 <duppage>

	int r;
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)))
  801a04:	83 ec 04             	sub    $0x4,%esp
  801a07:	6a 07                	push   $0x7
  801a09:	68 00 f0 bf ee       	push   $0xeebff000
  801a0e:	53                   	push   %ebx
  801a0f:	e8 73 fb ff ff       	call   801587 <sys_page_alloc>
  801a14:	83 c4 10             	add    $0x10,%esp
  801a17:	85 c0                	test   %eax,%eax
  801a19:	74 15                	je     801a30 <fork+0xe4>
		panic("sys_page_alloc:%e", r);
  801a1b:	50                   	push   %eax
  801a1c:	68 90 38 80 00       	push   $0x803890
  801a21:	68 86 00 00 00       	push   $0x86
  801a26:	68 32 38 80 00       	push   $0x803832
  801a2b:	e8 e5 ef ff ff       	call   800a15 <_panic>

	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801a30:	83 ec 08             	sub    $0x8,%esp
  801a33:	68 be 2e 80 00       	push   $0x802ebe
  801a38:	53                   	push   %ebx
  801a39:	e8 94 fc ff ff       	call   8016d2 <sys_env_set_pgfault_upcall>

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)))
  801a3e:	83 c4 08             	add    $0x8,%esp
  801a41:	6a 02                	push   $0x2
  801a43:	53                   	push   %ebx
  801a44:	e8 05 fc ff ff       	call   80164e <sys_env_set_status>
  801a49:	83 c4 10             	add    $0x10,%esp
  801a4c:	85 c0                	test   %eax,%eax
  801a4e:	74 15                	je     801a65 <fork+0x119>
		panic("sys_env_set_status:%e", r);
  801a50:	50                   	push   %eax
  801a51:	68 a2 38 80 00       	push   $0x8038a2
  801a56:	68 8c 00 00 00       	push   $0x8c
  801a5b:	68 32 38 80 00       	push   $0x803832
  801a60:	e8 b0 ef ff ff       	call   800a15 <_panic>

	return envid;
  801a65:	89 d8                	mov    %ebx,%eax
	    
}
  801a67:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a6a:	5b                   	pop    %ebx
  801a6b:	5e                   	pop    %esi
  801a6c:	5d                   	pop    %ebp
  801a6d:	c3                   	ret    

00801a6e <sfork>:

// Challenge!
int
sfork(void)
{
  801a6e:	55                   	push   %ebp
  801a6f:	89 e5                	mov    %esp,%ebp
  801a71:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801a74:	68 b8 38 80 00       	push   $0x8038b8
  801a79:	68 96 00 00 00       	push   $0x96
  801a7e:	68 32 38 80 00       	push   $0x803832
  801a83:	e8 8d ef ff ff       	call   800a15 <_panic>

00801a88 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  801a88:	55                   	push   %ebp
  801a89:	89 e5                	mov    %esp,%ebp
  801a8b:	8b 55 08             	mov    0x8(%ebp),%edx
  801a8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a91:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801a94:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  801a96:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  801a99:	83 3a 01             	cmpl   $0x1,(%edx)
  801a9c:	7e 09                	jle    801aa7 <argstart+0x1f>
  801a9e:	ba c1 32 80 00       	mov    $0x8032c1,%edx
  801aa3:	85 c9                	test   %ecx,%ecx
  801aa5:	75 05                	jne    801aac <argstart+0x24>
  801aa7:	ba 00 00 00 00       	mov    $0x0,%edx
  801aac:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  801aaf:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  801ab6:	5d                   	pop    %ebp
  801ab7:	c3                   	ret    

00801ab8 <argnext>:

int
argnext(struct Argstate *args)
{
  801ab8:	55                   	push   %ebp
  801ab9:	89 e5                	mov    %esp,%ebp
  801abb:	53                   	push   %ebx
  801abc:	83 ec 04             	sub    $0x4,%esp
  801abf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801ac2:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801ac9:	8b 43 08             	mov    0x8(%ebx),%eax
  801acc:	85 c0                	test   %eax,%eax
  801ace:	74 6f                	je     801b3f <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  801ad0:	80 38 00             	cmpb   $0x0,(%eax)
  801ad3:	75 4e                	jne    801b23 <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801ad5:	8b 0b                	mov    (%ebx),%ecx
  801ad7:	83 39 01             	cmpl   $0x1,(%ecx)
  801ada:	74 55                	je     801b31 <argnext+0x79>
		    || args->argv[1][0] != '-'
  801adc:	8b 53 04             	mov    0x4(%ebx),%edx
  801adf:	8b 42 04             	mov    0x4(%edx),%eax
  801ae2:	80 38 2d             	cmpb   $0x2d,(%eax)
  801ae5:	75 4a                	jne    801b31 <argnext+0x79>
		    || args->argv[1][1] == '\0')
  801ae7:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801aeb:	74 44                	je     801b31 <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801aed:	83 c0 01             	add    $0x1,%eax
  801af0:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801af3:	83 ec 04             	sub    $0x4,%esp
  801af6:	8b 01                	mov    (%ecx),%eax
  801af8:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801aff:	50                   	push   %eax
  801b00:	8d 42 08             	lea    0x8(%edx),%eax
  801b03:	50                   	push   %eax
  801b04:	83 c2 04             	add    $0x4,%edx
  801b07:	52                   	push   %edx
  801b08:	e8 09 f8 ff ff       	call   801316 <memmove>
		(*args->argc)--;
  801b0d:	8b 03                	mov    (%ebx),%eax
  801b0f:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801b12:	8b 43 08             	mov    0x8(%ebx),%eax
  801b15:	83 c4 10             	add    $0x10,%esp
  801b18:	80 38 2d             	cmpb   $0x2d,(%eax)
  801b1b:	75 06                	jne    801b23 <argnext+0x6b>
  801b1d:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801b21:	74 0e                	je     801b31 <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801b23:	8b 53 08             	mov    0x8(%ebx),%edx
  801b26:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801b29:	83 c2 01             	add    $0x1,%edx
  801b2c:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  801b2f:	eb 13                	jmp    801b44 <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  801b31:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801b38:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801b3d:	eb 05                	jmp    801b44 <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  801b3f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801b44:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b47:	c9                   	leave  
  801b48:	c3                   	ret    

00801b49 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801b49:	55                   	push   %ebp
  801b4a:	89 e5                	mov    %esp,%ebp
  801b4c:	53                   	push   %ebx
  801b4d:	83 ec 04             	sub    $0x4,%esp
  801b50:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801b53:	8b 43 08             	mov    0x8(%ebx),%eax
  801b56:	85 c0                	test   %eax,%eax
  801b58:	74 58                	je     801bb2 <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  801b5a:	80 38 00             	cmpb   $0x0,(%eax)
  801b5d:	74 0c                	je     801b6b <argnextvalue+0x22>
		args->argvalue = args->curarg;
  801b5f:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801b62:	c7 43 08 c1 32 80 00 	movl   $0x8032c1,0x8(%ebx)
  801b69:	eb 42                	jmp    801bad <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  801b6b:	8b 13                	mov    (%ebx),%edx
  801b6d:	83 3a 01             	cmpl   $0x1,(%edx)
  801b70:	7e 2d                	jle    801b9f <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  801b72:	8b 43 04             	mov    0x4(%ebx),%eax
  801b75:	8b 48 04             	mov    0x4(%eax),%ecx
  801b78:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801b7b:	83 ec 04             	sub    $0x4,%esp
  801b7e:	8b 12                	mov    (%edx),%edx
  801b80:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  801b87:	52                   	push   %edx
  801b88:	8d 50 08             	lea    0x8(%eax),%edx
  801b8b:	52                   	push   %edx
  801b8c:	83 c0 04             	add    $0x4,%eax
  801b8f:	50                   	push   %eax
  801b90:	e8 81 f7 ff ff       	call   801316 <memmove>
		(*args->argc)--;
  801b95:	8b 03                	mov    (%ebx),%eax
  801b97:	83 28 01             	subl   $0x1,(%eax)
  801b9a:	83 c4 10             	add    $0x10,%esp
  801b9d:	eb 0e                	jmp    801bad <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  801b9f:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801ba6:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  801bad:	8b 43 0c             	mov    0xc(%ebx),%eax
  801bb0:	eb 05                	jmp    801bb7 <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  801bb2:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  801bb7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bba:	c9                   	leave  
  801bbb:	c3                   	ret    

00801bbc <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  801bbc:	55                   	push   %ebp
  801bbd:	89 e5                	mov    %esp,%ebp
  801bbf:	83 ec 08             	sub    $0x8,%esp
  801bc2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801bc5:	8b 51 0c             	mov    0xc(%ecx),%edx
  801bc8:	89 d0                	mov    %edx,%eax
  801bca:	85 d2                	test   %edx,%edx
  801bcc:	75 0c                	jne    801bda <argvalue+0x1e>
  801bce:	83 ec 0c             	sub    $0xc,%esp
  801bd1:	51                   	push   %ecx
  801bd2:	e8 72 ff ff ff       	call   801b49 <argnextvalue>
  801bd7:	83 c4 10             	add    $0x10,%esp
}
  801bda:	c9                   	leave  
  801bdb:	c3                   	ret    

00801bdc <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801bdc:	55                   	push   %ebp
  801bdd:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801bdf:	8b 45 08             	mov    0x8(%ebp),%eax
  801be2:	05 00 00 00 30       	add    $0x30000000,%eax
  801be7:	c1 e8 0c             	shr    $0xc,%eax
}
  801bea:	5d                   	pop    %ebp
  801beb:	c3                   	ret    

00801bec <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801bec:	55                   	push   %ebp
  801bed:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801bef:	8b 45 08             	mov    0x8(%ebp),%eax
  801bf2:	05 00 00 00 30       	add    $0x30000000,%eax
  801bf7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801bfc:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801c01:	5d                   	pop    %ebp
  801c02:	c3                   	ret    

00801c03 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801c03:	55                   	push   %ebp
  801c04:	89 e5                	mov    %esp,%ebp
  801c06:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c09:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801c0e:	89 c2                	mov    %eax,%edx
  801c10:	c1 ea 16             	shr    $0x16,%edx
  801c13:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801c1a:	f6 c2 01             	test   $0x1,%dl
  801c1d:	74 11                	je     801c30 <fd_alloc+0x2d>
  801c1f:	89 c2                	mov    %eax,%edx
  801c21:	c1 ea 0c             	shr    $0xc,%edx
  801c24:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801c2b:	f6 c2 01             	test   $0x1,%dl
  801c2e:	75 09                	jne    801c39 <fd_alloc+0x36>
			*fd_store = fd;
  801c30:	89 01                	mov    %eax,(%ecx)
			return 0;
  801c32:	b8 00 00 00 00       	mov    $0x0,%eax
  801c37:	eb 17                	jmp    801c50 <fd_alloc+0x4d>
  801c39:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801c3e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801c43:	75 c9                	jne    801c0e <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801c45:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801c4b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801c50:	5d                   	pop    %ebp
  801c51:	c3                   	ret    

00801c52 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801c52:	55                   	push   %ebp
  801c53:	89 e5                	mov    %esp,%ebp
  801c55:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801c58:	83 f8 1f             	cmp    $0x1f,%eax
  801c5b:	77 36                	ja     801c93 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801c5d:	c1 e0 0c             	shl    $0xc,%eax
  801c60:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801c65:	89 c2                	mov    %eax,%edx
  801c67:	c1 ea 16             	shr    $0x16,%edx
  801c6a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801c71:	f6 c2 01             	test   $0x1,%dl
  801c74:	74 24                	je     801c9a <fd_lookup+0x48>
  801c76:	89 c2                	mov    %eax,%edx
  801c78:	c1 ea 0c             	shr    $0xc,%edx
  801c7b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801c82:	f6 c2 01             	test   $0x1,%dl
  801c85:	74 1a                	je     801ca1 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801c87:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c8a:	89 02                	mov    %eax,(%edx)
	return 0;
  801c8c:	b8 00 00 00 00       	mov    $0x0,%eax
  801c91:	eb 13                	jmp    801ca6 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801c93:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801c98:	eb 0c                	jmp    801ca6 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801c9a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801c9f:	eb 05                	jmp    801ca6 <fd_lookup+0x54>
  801ca1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801ca6:	5d                   	pop    %ebp
  801ca7:	c3                   	ret    

00801ca8 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801ca8:	55                   	push   %ebp
  801ca9:	89 e5                	mov    %esp,%ebp
  801cab:	83 ec 08             	sub    $0x8,%esp
  801cae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cb1:	ba c0 39 80 00       	mov    $0x8039c0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801cb6:	eb 13                	jmp    801ccb <dev_lookup+0x23>
  801cb8:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801cbb:	39 08                	cmp    %ecx,(%eax)
  801cbd:	75 0c                	jne    801ccb <dev_lookup+0x23>
			*dev = devtab[i];
  801cbf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cc2:	89 01                	mov    %eax,(%ecx)
			return 0;
  801cc4:	b8 00 00 00 00       	mov    $0x0,%eax
  801cc9:	eb 2e                	jmp    801cf9 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801ccb:	8b 02                	mov    (%edx),%eax
  801ccd:	85 c0                	test   %eax,%eax
  801ccf:	75 e7                	jne    801cb8 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801cd1:	a1 24 54 80 00       	mov    0x805424,%eax
  801cd6:	8b 40 48             	mov    0x48(%eax),%eax
  801cd9:	83 ec 04             	sub    $0x4,%esp
  801cdc:	51                   	push   %ecx
  801cdd:	50                   	push   %eax
  801cde:	68 44 39 80 00       	push   $0x803944
  801ce3:	e8 06 ee ff ff       	call   800aee <cprintf>
	*dev = 0;
  801ce8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ceb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801cf1:	83 c4 10             	add    $0x10,%esp
  801cf4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801cf9:	c9                   	leave  
  801cfa:	c3                   	ret    

00801cfb <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801cfb:	55                   	push   %ebp
  801cfc:	89 e5                	mov    %esp,%ebp
  801cfe:	56                   	push   %esi
  801cff:	53                   	push   %ebx
  801d00:	83 ec 10             	sub    $0x10,%esp
  801d03:	8b 75 08             	mov    0x8(%ebp),%esi
  801d06:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801d09:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d0c:	50                   	push   %eax
  801d0d:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801d13:	c1 e8 0c             	shr    $0xc,%eax
  801d16:	50                   	push   %eax
  801d17:	e8 36 ff ff ff       	call   801c52 <fd_lookup>
  801d1c:	83 c4 08             	add    $0x8,%esp
  801d1f:	85 c0                	test   %eax,%eax
  801d21:	78 05                	js     801d28 <fd_close+0x2d>
	    || fd != fd2)
  801d23:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801d26:	74 0c                	je     801d34 <fd_close+0x39>
		return (must_exist ? r : 0);
  801d28:	84 db                	test   %bl,%bl
  801d2a:	ba 00 00 00 00       	mov    $0x0,%edx
  801d2f:	0f 44 c2             	cmove  %edx,%eax
  801d32:	eb 41                	jmp    801d75 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801d34:	83 ec 08             	sub    $0x8,%esp
  801d37:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d3a:	50                   	push   %eax
  801d3b:	ff 36                	pushl  (%esi)
  801d3d:	e8 66 ff ff ff       	call   801ca8 <dev_lookup>
  801d42:	89 c3                	mov    %eax,%ebx
  801d44:	83 c4 10             	add    $0x10,%esp
  801d47:	85 c0                	test   %eax,%eax
  801d49:	78 1a                	js     801d65 <fd_close+0x6a>
		if (dev->dev_close)
  801d4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d4e:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801d51:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801d56:	85 c0                	test   %eax,%eax
  801d58:	74 0b                	je     801d65 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801d5a:	83 ec 0c             	sub    $0xc,%esp
  801d5d:	56                   	push   %esi
  801d5e:	ff d0                	call   *%eax
  801d60:	89 c3                	mov    %eax,%ebx
  801d62:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801d65:	83 ec 08             	sub    $0x8,%esp
  801d68:	56                   	push   %esi
  801d69:	6a 00                	push   $0x0
  801d6b:	e8 9c f8 ff ff       	call   80160c <sys_page_unmap>
	return r;
  801d70:	83 c4 10             	add    $0x10,%esp
  801d73:	89 d8                	mov    %ebx,%eax
}
  801d75:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d78:	5b                   	pop    %ebx
  801d79:	5e                   	pop    %esi
  801d7a:	5d                   	pop    %ebp
  801d7b:	c3                   	ret    

00801d7c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801d7c:	55                   	push   %ebp
  801d7d:	89 e5                	mov    %esp,%ebp
  801d7f:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d82:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d85:	50                   	push   %eax
  801d86:	ff 75 08             	pushl  0x8(%ebp)
  801d89:	e8 c4 fe ff ff       	call   801c52 <fd_lookup>
  801d8e:	83 c4 08             	add    $0x8,%esp
  801d91:	85 c0                	test   %eax,%eax
  801d93:	78 10                	js     801da5 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801d95:	83 ec 08             	sub    $0x8,%esp
  801d98:	6a 01                	push   $0x1
  801d9a:	ff 75 f4             	pushl  -0xc(%ebp)
  801d9d:	e8 59 ff ff ff       	call   801cfb <fd_close>
  801da2:	83 c4 10             	add    $0x10,%esp
}
  801da5:	c9                   	leave  
  801da6:	c3                   	ret    

00801da7 <close_all>:

void
close_all(void)
{
  801da7:	55                   	push   %ebp
  801da8:	89 e5                	mov    %esp,%ebp
  801daa:	53                   	push   %ebx
  801dab:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801dae:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801db3:	83 ec 0c             	sub    $0xc,%esp
  801db6:	53                   	push   %ebx
  801db7:	e8 c0 ff ff ff       	call   801d7c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801dbc:	83 c3 01             	add    $0x1,%ebx
  801dbf:	83 c4 10             	add    $0x10,%esp
  801dc2:	83 fb 20             	cmp    $0x20,%ebx
  801dc5:	75 ec                	jne    801db3 <close_all+0xc>
		close(i);
}
  801dc7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dca:	c9                   	leave  
  801dcb:	c3                   	ret    

00801dcc <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801dcc:	55                   	push   %ebp
  801dcd:	89 e5                	mov    %esp,%ebp
  801dcf:	57                   	push   %edi
  801dd0:	56                   	push   %esi
  801dd1:	53                   	push   %ebx
  801dd2:	83 ec 2c             	sub    $0x2c,%esp
  801dd5:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801dd8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801ddb:	50                   	push   %eax
  801ddc:	ff 75 08             	pushl  0x8(%ebp)
  801ddf:	e8 6e fe ff ff       	call   801c52 <fd_lookup>
  801de4:	83 c4 08             	add    $0x8,%esp
  801de7:	85 c0                	test   %eax,%eax
  801de9:	0f 88 c1 00 00 00    	js     801eb0 <dup+0xe4>
		return r;
	close(newfdnum);
  801def:	83 ec 0c             	sub    $0xc,%esp
  801df2:	56                   	push   %esi
  801df3:	e8 84 ff ff ff       	call   801d7c <close>

	newfd = INDEX2FD(newfdnum);
  801df8:	89 f3                	mov    %esi,%ebx
  801dfa:	c1 e3 0c             	shl    $0xc,%ebx
  801dfd:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801e03:	83 c4 04             	add    $0x4,%esp
  801e06:	ff 75 e4             	pushl  -0x1c(%ebp)
  801e09:	e8 de fd ff ff       	call   801bec <fd2data>
  801e0e:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801e10:	89 1c 24             	mov    %ebx,(%esp)
  801e13:	e8 d4 fd ff ff       	call   801bec <fd2data>
  801e18:	83 c4 10             	add    $0x10,%esp
  801e1b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801e1e:	89 f8                	mov    %edi,%eax
  801e20:	c1 e8 16             	shr    $0x16,%eax
  801e23:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801e2a:	a8 01                	test   $0x1,%al
  801e2c:	74 37                	je     801e65 <dup+0x99>
  801e2e:	89 f8                	mov    %edi,%eax
  801e30:	c1 e8 0c             	shr    $0xc,%eax
  801e33:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801e3a:	f6 c2 01             	test   $0x1,%dl
  801e3d:	74 26                	je     801e65 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801e3f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801e46:	83 ec 0c             	sub    $0xc,%esp
  801e49:	25 07 0e 00 00       	and    $0xe07,%eax
  801e4e:	50                   	push   %eax
  801e4f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801e52:	6a 00                	push   $0x0
  801e54:	57                   	push   %edi
  801e55:	6a 00                	push   $0x0
  801e57:	e8 6e f7 ff ff       	call   8015ca <sys_page_map>
  801e5c:	89 c7                	mov    %eax,%edi
  801e5e:	83 c4 20             	add    $0x20,%esp
  801e61:	85 c0                	test   %eax,%eax
  801e63:	78 2e                	js     801e93 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801e65:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801e68:	89 d0                	mov    %edx,%eax
  801e6a:	c1 e8 0c             	shr    $0xc,%eax
  801e6d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801e74:	83 ec 0c             	sub    $0xc,%esp
  801e77:	25 07 0e 00 00       	and    $0xe07,%eax
  801e7c:	50                   	push   %eax
  801e7d:	53                   	push   %ebx
  801e7e:	6a 00                	push   $0x0
  801e80:	52                   	push   %edx
  801e81:	6a 00                	push   $0x0
  801e83:	e8 42 f7 ff ff       	call   8015ca <sys_page_map>
  801e88:	89 c7                	mov    %eax,%edi
  801e8a:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801e8d:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801e8f:	85 ff                	test   %edi,%edi
  801e91:	79 1d                	jns    801eb0 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801e93:	83 ec 08             	sub    $0x8,%esp
  801e96:	53                   	push   %ebx
  801e97:	6a 00                	push   $0x0
  801e99:	e8 6e f7 ff ff       	call   80160c <sys_page_unmap>
	sys_page_unmap(0, nva);
  801e9e:	83 c4 08             	add    $0x8,%esp
  801ea1:	ff 75 d4             	pushl  -0x2c(%ebp)
  801ea4:	6a 00                	push   $0x0
  801ea6:	e8 61 f7 ff ff       	call   80160c <sys_page_unmap>
	return r;
  801eab:	83 c4 10             	add    $0x10,%esp
  801eae:	89 f8                	mov    %edi,%eax
}
  801eb0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801eb3:	5b                   	pop    %ebx
  801eb4:	5e                   	pop    %esi
  801eb5:	5f                   	pop    %edi
  801eb6:	5d                   	pop    %ebp
  801eb7:	c3                   	ret    

00801eb8 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801eb8:	55                   	push   %ebp
  801eb9:	89 e5                	mov    %esp,%ebp
  801ebb:	53                   	push   %ebx
  801ebc:	83 ec 14             	sub    $0x14,%esp
  801ebf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801ec2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ec5:	50                   	push   %eax
  801ec6:	53                   	push   %ebx
  801ec7:	e8 86 fd ff ff       	call   801c52 <fd_lookup>
  801ecc:	83 c4 08             	add    $0x8,%esp
  801ecf:	89 c2                	mov    %eax,%edx
  801ed1:	85 c0                	test   %eax,%eax
  801ed3:	78 6d                	js     801f42 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801ed5:	83 ec 08             	sub    $0x8,%esp
  801ed8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801edb:	50                   	push   %eax
  801edc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801edf:	ff 30                	pushl  (%eax)
  801ee1:	e8 c2 fd ff ff       	call   801ca8 <dev_lookup>
  801ee6:	83 c4 10             	add    $0x10,%esp
  801ee9:	85 c0                	test   %eax,%eax
  801eeb:	78 4c                	js     801f39 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801eed:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801ef0:	8b 42 08             	mov    0x8(%edx),%eax
  801ef3:	83 e0 03             	and    $0x3,%eax
  801ef6:	83 f8 01             	cmp    $0x1,%eax
  801ef9:	75 21                	jne    801f1c <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801efb:	a1 24 54 80 00       	mov    0x805424,%eax
  801f00:	8b 40 48             	mov    0x48(%eax),%eax
  801f03:	83 ec 04             	sub    $0x4,%esp
  801f06:	53                   	push   %ebx
  801f07:	50                   	push   %eax
  801f08:	68 85 39 80 00       	push   $0x803985
  801f0d:	e8 dc eb ff ff       	call   800aee <cprintf>
		return -E_INVAL;
  801f12:	83 c4 10             	add    $0x10,%esp
  801f15:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801f1a:	eb 26                	jmp    801f42 <read+0x8a>
	}
	if (!dev->dev_read)
  801f1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f1f:	8b 40 08             	mov    0x8(%eax),%eax
  801f22:	85 c0                	test   %eax,%eax
  801f24:	74 17                	je     801f3d <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801f26:	83 ec 04             	sub    $0x4,%esp
  801f29:	ff 75 10             	pushl  0x10(%ebp)
  801f2c:	ff 75 0c             	pushl  0xc(%ebp)
  801f2f:	52                   	push   %edx
  801f30:	ff d0                	call   *%eax
  801f32:	89 c2                	mov    %eax,%edx
  801f34:	83 c4 10             	add    $0x10,%esp
  801f37:	eb 09                	jmp    801f42 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801f39:	89 c2                	mov    %eax,%edx
  801f3b:	eb 05                	jmp    801f42 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801f3d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801f42:	89 d0                	mov    %edx,%eax
  801f44:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f47:	c9                   	leave  
  801f48:	c3                   	ret    

00801f49 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801f49:	55                   	push   %ebp
  801f4a:	89 e5                	mov    %esp,%ebp
  801f4c:	57                   	push   %edi
  801f4d:	56                   	push   %esi
  801f4e:	53                   	push   %ebx
  801f4f:	83 ec 0c             	sub    $0xc,%esp
  801f52:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f55:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801f58:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f5d:	eb 21                	jmp    801f80 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801f5f:	83 ec 04             	sub    $0x4,%esp
  801f62:	89 f0                	mov    %esi,%eax
  801f64:	29 d8                	sub    %ebx,%eax
  801f66:	50                   	push   %eax
  801f67:	89 d8                	mov    %ebx,%eax
  801f69:	03 45 0c             	add    0xc(%ebp),%eax
  801f6c:	50                   	push   %eax
  801f6d:	57                   	push   %edi
  801f6e:	e8 45 ff ff ff       	call   801eb8 <read>
		if (m < 0)
  801f73:	83 c4 10             	add    $0x10,%esp
  801f76:	85 c0                	test   %eax,%eax
  801f78:	78 10                	js     801f8a <readn+0x41>
			return m;
		if (m == 0)
  801f7a:	85 c0                	test   %eax,%eax
  801f7c:	74 0a                	je     801f88 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801f7e:	01 c3                	add    %eax,%ebx
  801f80:	39 f3                	cmp    %esi,%ebx
  801f82:	72 db                	jb     801f5f <readn+0x16>
  801f84:	89 d8                	mov    %ebx,%eax
  801f86:	eb 02                	jmp    801f8a <readn+0x41>
  801f88:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801f8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f8d:	5b                   	pop    %ebx
  801f8e:	5e                   	pop    %esi
  801f8f:	5f                   	pop    %edi
  801f90:	5d                   	pop    %ebp
  801f91:	c3                   	ret    

00801f92 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801f92:	55                   	push   %ebp
  801f93:	89 e5                	mov    %esp,%ebp
  801f95:	53                   	push   %ebx
  801f96:	83 ec 14             	sub    $0x14,%esp
  801f99:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801f9c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f9f:	50                   	push   %eax
  801fa0:	53                   	push   %ebx
  801fa1:	e8 ac fc ff ff       	call   801c52 <fd_lookup>
  801fa6:	83 c4 08             	add    $0x8,%esp
  801fa9:	89 c2                	mov    %eax,%edx
  801fab:	85 c0                	test   %eax,%eax
  801fad:	78 68                	js     802017 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801faf:	83 ec 08             	sub    $0x8,%esp
  801fb2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fb5:	50                   	push   %eax
  801fb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fb9:	ff 30                	pushl  (%eax)
  801fbb:	e8 e8 fc ff ff       	call   801ca8 <dev_lookup>
  801fc0:	83 c4 10             	add    $0x10,%esp
  801fc3:	85 c0                	test   %eax,%eax
  801fc5:	78 47                	js     80200e <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801fc7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fca:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801fce:	75 21                	jne    801ff1 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801fd0:	a1 24 54 80 00       	mov    0x805424,%eax
  801fd5:	8b 40 48             	mov    0x48(%eax),%eax
  801fd8:	83 ec 04             	sub    $0x4,%esp
  801fdb:	53                   	push   %ebx
  801fdc:	50                   	push   %eax
  801fdd:	68 a1 39 80 00       	push   $0x8039a1
  801fe2:	e8 07 eb ff ff       	call   800aee <cprintf>
		return -E_INVAL;
  801fe7:	83 c4 10             	add    $0x10,%esp
  801fea:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801fef:	eb 26                	jmp    802017 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801ff1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ff4:	8b 52 0c             	mov    0xc(%edx),%edx
  801ff7:	85 d2                	test   %edx,%edx
  801ff9:	74 17                	je     802012 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801ffb:	83 ec 04             	sub    $0x4,%esp
  801ffe:	ff 75 10             	pushl  0x10(%ebp)
  802001:	ff 75 0c             	pushl  0xc(%ebp)
  802004:	50                   	push   %eax
  802005:	ff d2                	call   *%edx
  802007:	89 c2                	mov    %eax,%edx
  802009:	83 c4 10             	add    $0x10,%esp
  80200c:	eb 09                	jmp    802017 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80200e:	89 c2                	mov    %eax,%edx
  802010:	eb 05                	jmp    802017 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  802012:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  802017:	89 d0                	mov    %edx,%eax
  802019:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80201c:	c9                   	leave  
  80201d:	c3                   	ret    

0080201e <seek>:

int
seek(int fdnum, off_t offset)
{
  80201e:	55                   	push   %ebp
  80201f:	89 e5                	mov    %esp,%ebp
  802021:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802024:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802027:	50                   	push   %eax
  802028:	ff 75 08             	pushl  0x8(%ebp)
  80202b:	e8 22 fc ff ff       	call   801c52 <fd_lookup>
  802030:	83 c4 08             	add    $0x8,%esp
  802033:	85 c0                	test   %eax,%eax
  802035:	78 0e                	js     802045 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  802037:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80203a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80203d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  802040:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802045:	c9                   	leave  
  802046:	c3                   	ret    

00802047 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802047:	55                   	push   %ebp
  802048:	89 e5                	mov    %esp,%ebp
  80204a:	53                   	push   %ebx
  80204b:	83 ec 14             	sub    $0x14,%esp
  80204e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  802051:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802054:	50                   	push   %eax
  802055:	53                   	push   %ebx
  802056:	e8 f7 fb ff ff       	call   801c52 <fd_lookup>
  80205b:	83 c4 08             	add    $0x8,%esp
  80205e:	89 c2                	mov    %eax,%edx
  802060:	85 c0                	test   %eax,%eax
  802062:	78 65                	js     8020c9 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802064:	83 ec 08             	sub    $0x8,%esp
  802067:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80206a:	50                   	push   %eax
  80206b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80206e:	ff 30                	pushl  (%eax)
  802070:	e8 33 fc ff ff       	call   801ca8 <dev_lookup>
  802075:	83 c4 10             	add    $0x10,%esp
  802078:	85 c0                	test   %eax,%eax
  80207a:	78 44                	js     8020c0 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80207c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80207f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802083:	75 21                	jne    8020a6 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  802085:	a1 24 54 80 00       	mov    0x805424,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80208a:	8b 40 48             	mov    0x48(%eax),%eax
  80208d:	83 ec 04             	sub    $0x4,%esp
  802090:	53                   	push   %ebx
  802091:	50                   	push   %eax
  802092:	68 64 39 80 00       	push   $0x803964
  802097:	e8 52 ea ff ff       	call   800aee <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80209c:	83 c4 10             	add    $0x10,%esp
  80209f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8020a4:	eb 23                	jmp    8020c9 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8020a6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8020a9:	8b 52 18             	mov    0x18(%edx),%edx
  8020ac:	85 d2                	test   %edx,%edx
  8020ae:	74 14                	je     8020c4 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8020b0:	83 ec 08             	sub    $0x8,%esp
  8020b3:	ff 75 0c             	pushl  0xc(%ebp)
  8020b6:	50                   	push   %eax
  8020b7:	ff d2                	call   *%edx
  8020b9:	89 c2                	mov    %eax,%edx
  8020bb:	83 c4 10             	add    $0x10,%esp
  8020be:	eb 09                	jmp    8020c9 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8020c0:	89 c2                	mov    %eax,%edx
  8020c2:	eb 05                	jmp    8020c9 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8020c4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8020c9:	89 d0                	mov    %edx,%eax
  8020cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020ce:	c9                   	leave  
  8020cf:	c3                   	ret    

008020d0 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8020d0:	55                   	push   %ebp
  8020d1:	89 e5                	mov    %esp,%ebp
  8020d3:	53                   	push   %ebx
  8020d4:	83 ec 14             	sub    $0x14,%esp
  8020d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8020da:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8020dd:	50                   	push   %eax
  8020de:	ff 75 08             	pushl  0x8(%ebp)
  8020e1:	e8 6c fb ff ff       	call   801c52 <fd_lookup>
  8020e6:	83 c4 08             	add    $0x8,%esp
  8020e9:	89 c2                	mov    %eax,%edx
  8020eb:	85 c0                	test   %eax,%eax
  8020ed:	78 58                	js     802147 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8020ef:	83 ec 08             	sub    $0x8,%esp
  8020f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020f5:	50                   	push   %eax
  8020f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020f9:	ff 30                	pushl  (%eax)
  8020fb:	e8 a8 fb ff ff       	call   801ca8 <dev_lookup>
  802100:	83 c4 10             	add    $0x10,%esp
  802103:	85 c0                	test   %eax,%eax
  802105:	78 37                	js     80213e <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  802107:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80210a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80210e:	74 32                	je     802142 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802110:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  802113:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80211a:	00 00 00 
	stat->st_isdir = 0;
  80211d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802124:	00 00 00 
	stat->st_dev = dev;
  802127:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80212d:	83 ec 08             	sub    $0x8,%esp
  802130:	53                   	push   %ebx
  802131:	ff 75 f0             	pushl  -0x10(%ebp)
  802134:	ff 50 14             	call   *0x14(%eax)
  802137:	89 c2                	mov    %eax,%edx
  802139:	83 c4 10             	add    $0x10,%esp
  80213c:	eb 09                	jmp    802147 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80213e:	89 c2                	mov    %eax,%edx
  802140:	eb 05                	jmp    802147 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  802142:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  802147:	89 d0                	mov    %edx,%eax
  802149:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80214c:	c9                   	leave  
  80214d:	c3                   	ret    

0080214e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80214e:	55                   	push   %ebp
  80214f:	89 e5                	mov    %esp,%ebp
  802151:	56                   	push   %esi
  802152:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  802153:	83 ec 08             	sub    $0x8,%esp
  802156:	6a 00                	push   $0x0
  802158:	ff 75 08             	pushl  0x8(%ebp)
  80215b:	e8 e3 01 00 00       	call   802343 <open>
  802160:	89 c3                	mov    %eax,%ebx
  802162:	83 c4 10             	add    $0x10,%esp
  802165:	85 c0                	test   %eax,%eax
  802167:	78 1b                	js     802184 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  802169:	83 ec 08             	sub    $0x8,%esp
  80216c:	ff 75 0c             	pushl  0xc(%ebp)
  80216f:	50                   	push   %eax
  802170:	e8 5b ff ff ff       	call   8020d0 <fstat>
  802175:	89 c6                	mov    %eax,%esi
	close(fd);
  802177:	89 1c 24             	mov    %ebx,(%esp)
  80217a:	e8 fd fb ff ff       	call   801d7c <close>
	return r;
  80217f:	83 c4 10             	add    $0x10,%esp
  802182:	89 f0                	mov    %esi,%eax
}
  802184:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802187:	5b                   	pop    %ebx
  802188:	5e                   	pop    %esi
  802189:	5d                   	pop    %ebp
  80218a:	c3                   	ret    

0080218b <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80218b:	55                   	push   %ebp
  80218c:	89 e5                	mov    %esp,%ebp
  80218e:	56                   	push   %esi
  80218f:	53                   	push   %ebx
  802190:	89 c6                	mov    %eax,%esi
  802192:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  802194:	83 3d 20 54 80 00 00 	cmpl   $0x0,0x805420
  80219b:	75 12                	jne    8021af <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80219d:	83 ec 0c             	sub    $0xc,%esp
  8021a0:	6a 01                	push   $0x1
  8021a2:	e8 e4 0d 00 00       	call   802f8b <ipc_find_env>
  8021a7:	a3 20 54 80 00       	mov    %eax,0x805420
  8021ac:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8021af:	6a 07                	push   $0x7
  8021b1:	68 00 60 80 00       	push   $0x806000
  8021b6:	56                   	push   %esi
  8021b7:	ff 35 20 54 80 00    	pushl  0x805420
  8021bd:	e8 75 0d 00 00       	call   802f37 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8021c2:	83 c4 0c             	add    $0xc,%esp
  8021c5:	6a 00                	push   $0x0
  8021c7:	53                   	push   %ebx
  8021c8:	6a 00                	push   $0x0
  8021ca:	e8 13 0d 00 00       	call   802ee2 <ipc_recv>
}
  8021cf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021d2:	5b                   	pop    %ebx
  8021d3:	5e                   	pop    %esi
  8021d4:	5d                   	pop    %ebp
  8021d5:	c3                   	ret    

008021d6 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8021d6:	55                   	push   %ebp
  8021d7:	89 e5                	mov    %esp,%ebp
  8021d9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8021dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8021df:	8b 40 0c             	mov    0xc(%eax),%eax
  8021e2:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  8021e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021ea:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8021ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8021f4:	b8 02 00 00 00       	mov    $0x2,%eax
  8021f9:	e8 8d ff ff ff       	call   80218b <fsipc>
}
  8021fe:	c9                   	leave  
  8021ff:	c3                   	ret    

00802200 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  802200:	55                   	push   %ebp
  802201:	89 e5                	mov    %esp,%ebp
  802203:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802206:	8b 45 08             	mov    0x8(%ebp),%eax
  802209:	8b 40 0c             	mov    0xc(%eax),%eax
  80220c:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  802211:	ba 00 00 00 00       	mov    $0x0,%edx
  802216:	b8 06 00 00 00       	mov    $0x6,%eax
  80221b:	e8 6b ff ff ff       	call   80218b <fsipc>
}
  802220:	c9                   	leave  
  802221:	c3                   	ret    

00802222 <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  802222:	55                   	push   %ebp
  802223:	89 e5                	mov    %esp,%ebp
  802225:	53                   	push   %ebx
  802226:	83 ec 04             	sub    $0x4,%esp
  802229:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80222c:	8b 45 08             	mov    0x8(%ebp),%eax
  80222f:	8b 40 0c             	mov    0xc(%eax),%eax
  802232:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802237:	ba 00 00 00 00       	mov    $0x0,%edx
  80223c:	b8 05 00 00 00       	mov    $0x5,%eax
  802241:	e8 45 ff ff ff       	call   80218b <fsipc>
  802246:	85 c0                	test   %eax,%eax
  802248:	78 2c                	js     802276 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80224a:	83 ec 08             	sub    $0x8,%esp
  80224d:	68 00 60 80 00       	push   $0x806000
  802252:	53                   	push   %ebx
  802253:	e8 2c ef ff ff       	call   801184 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802258:	a1 80 60 80 00       	mov    0x806080,%eax
  80225d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  802263:	a1 84 60 80 00       	mov    0x806084,%eax
  802268:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80226e:	83 c4 10             	add    $0x10,%esp
  802271:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802276:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802279:	c9                   	leave  
  80227a:	c3                   	ret    

0080227b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80227b:	55                   	push   %ebp
  80227c:	89 e5                	mov    %esp,%ebp
  80227e:	83 ec 0c             	sub    $0xc,%esp
  802281:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
    
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  802284:	8b 55 08             	mov    0x8(%ebp),%edx
  802287:	8b 52 0c             	mov    0xc(%edx),%edx
  80228a:	89 15 00 60 80 00    	mov    %edx,0x806000
    fsipcbuf.write.req_n = MIN(n, PGSIZE);
  802290:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802295:	ba 00 10 00 00       	mov    $0x1000,%edx
  80229a:	0f 47 c2             	cmova  %edx,%eax
  80229d:	a3 04 60 80 00       	mov    %eax,0x806004
    memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8022a2:	50                   	push   %eax
  8022a3:	ff 75 0c             	pushl  0xc(%ebp)
  8022a6:	68 08 60 80 00       	push   $0x806008
  8022ab:	e8 66 f0 ff ff       	call   801316 <memmove>
    int r = fsipc(FSREQ_WRITE, NULL);
  8022b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8022b5:	b8 04 00 00 00       	mov    $0x4,%eax
  8022ba:	e8 cc fe ff ff       	call   80218b <fsipc>
    return r;
}
  8022bf:	c9                   	leave  
  8022c0:	c3                   	ret    

008022c1 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8022c1:	55                   	push   %ebp
  8022c2:	89 e5                	mov    %esp,%ebp
  8022c4:	56                   	push   %esi
  8022c5:	53                   	push   %ebx
  8022c6:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8022c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8022cc:	8b 40 0c             	mov    0xc(%eax),%eax
  8022cf:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  8022d4:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8022da:	ba 00 00 00 00       	mov    $0x0,%edx
  8022df:	b8 03 00 00 00       	mov    $0x3,%eax
  8022e4:	e8 a2 fe ff ff       	call   80218b <fsipc>
  8022e9:	89 c3                	mov    %eax,%ebx
  8022eb:	85 c0                	test   %eax,%eax
  8022ed:	78 4b                	js     80233a <devfile_read+0x79>
		return r;
	assert(r <= n);
  8022ef:	39 c6                	cmp    %eax,%esi
  8022f1:	73 16                	jae    802309 <devfile_read+0x48>
  8022f3:	68 d0 39 80 00       	push   $0x8039d0
  8022f8:	68 ef 33 80 00       	push   $0x8033ef
  8022fd:	6a 7c                	push   $0x7c
  8022ff:	68 d7 39 80 00       	push   $0x8039d7
  802304:	e8 0c e7 ff ff       	call   800a15 <_panic>
	assert(r <= PGSIZE);
  802309:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80230e:	7e 16                	jle    802326 <devfile_read+0x65>
  802310:	68 e2 39 80 00       	push   $0x8039e2
  802315:	68 ef 33 80 00       	push   $0x8033ef
  80231a:	6a 7d                	push   $0x7d
  80231c:	68 d7 39 80 00       	push   $0x8039d7
  802321:	e8 ef e6 ff ff       	call   800a15 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  802326:	83 ec 04             	sub    $0x4,%esp
  802329:	50                   	push   %eax
  80232a:	68 00 60 80 00       	push   $0x806000
  80232f:	ff 75 0c             	pushl  0xc(%ebp)
  802332:	e8 df ef ff ff       	call   801316 <memmove>
	return r;
  802337:	83 c4 10             	add    $0x10,%esp
}
  80233a:	89 d8                	mov    %ebx,%eax
  80233c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80233f:	5b                   	pop    %ebx
  802340:	5e                   	pop    %esi
  802341:	5d                   	pop    %ebp
  802342:	c3                   	ret    

00802343 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  802343:	55                   	push   %ebp
  802344:	89 e5                	mov    %esp,%ebp
  802346:	53                   	push   %ebx
  802347:	83 ec 20             	sub    $0x20,%esp
  80234a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80234d:	53                   	push   %ebx
  80234e:	e8 f8 ed ff ff       	call   80114b <strlen>
  802353:	83 c4 10             	add    $0x10,%esp
  802356:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80235b:	7f 67                	jg     8023c4 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80235d:	83 ec 0c             	sub    $0xc,%esp
  802360:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802363:	50                   	push   %eax
  802364:	e8 9a f8 ff ff       	call   801c03 <fd_alloc>
  802369:	83 c4 10             	add    $0x10,%esp
		return r;
  80236c:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80236e:	85 c0                	test   %eax,%eax
  802370:	78 57                	js     8023c9 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  802372:	83 ec 08             	sub    $0x8,%esp
  802375:	53                   	push   %ebx
  802376:	68 00 60 80 00       	push   $0x806000
  80237b:	e8 04 ee ff ff       	call   801184 <strcpy>
	fsipcbuf.open.req_omode = mode;
  802380:	8b 45 0c             	mov    0xc(%ebp),%eax
  802383:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  802388:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80238b:	b8 01 00 00 00       	mov    $0x1,%eax
  802390:	e8 f6 fd ff ff       	call   80218b <fsipc>
  802395:	89 c3                	mov    %eax,%ebx
  802397:	83 c4 10             	add    $0x10,%esp
  80239a:	85 c0                	test   %eax,%eax
  80239c:	79 14                	jns    8023b2 <open+0x6f>
		fd_close(fd, 0);
  80239e:	83 ec 08             	sub    $0x8,%esp
  8023a1:	6a 00                	push   $0x0
  8023a3:	ff 75 f4             	pushl  -0xc(%ebp)
  8023a6:	e8 50 f9 ff ff       	call   801cfb <fd_close>
		return r;
  8023ab:	83 c4 10             	add    $0x10,%esp
  8023ae:	89 da                	mov    %ebx,%edx
  8023b0:	eb 17                	jmp    8023c9 <open+0x86>
	}

	return fd2num(fd);
  8023b2:	83 ec 0c             	sub    $0xc,%esp
  8023b5:	ff 75 f4             	pushl  -0xc(%ebp)
  8023b8:	e8 1f f8 ff ff       	call   801bdc <fd2num>
  8023bd:	89 c2                	mov    %eax,%edx
  8023bf:	83 c4 10             	add    $0x10,%esp
  8023c2:	eb 05                	jmp    8023c9 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8023c4:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8023c9:	89 d0                	mov    %edx,%eax
  8023cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8023ce:	c9                   	leave  
  8023cf:	c3                   	ret    

008023d0 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8023d0:	55                   	push   %ebp
  8023d1:	89 e5                	mov    %esp,%ebp
  8023d3:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8023d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8023db:	b8 08 00 00 00       	mov    $0x8,%eax
  8023e0:	e8 a6 fd ff ff       	call   80218b <fsipc>
}
  8023e5:	c9                   	leave  
  8023e6:	c3                   	ret    

008023e7 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  8023e7:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8023eb:	7e 37                	jle    802424 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  8023ed:	55                   	push   %ebp
  8023ee:	89 e5                	mov    %esp,%ebp
  8023f0:	53                   	push   %ebx
  8023f1:	83 ec 08             	sub    $0x8,%esp
  8023f4:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  8023f6:	ff 70 04             	pushl  0x4(%eax)
  8023f9:	8d 40 10             	lea    0x10(%eax),%eax
  8023fc:	50                   	push   %eax
  8023fd:	ff 33                	pushl  (%ebx)
  8023ff:	e8 8e fb ff ff       	call   801f92 <write>
		if (result > 0)
  802404:	83 c4 10             	add    $0x10,%esp
  802407:	85 c0                	test   %eax,%eax
  802409:	7e 03                	jle    80240e <writebuf+0x27>
			b->result += result;
  80240b:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  80240e:	3b 43 04             	cmp    0x4(%ebx),%eax
  802411:	74 0d                	je     802420 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  802413:	85 c0                	test   %eax,%eax
  802415:	ba 00 00 00 00       	mov    $0x0,%edx
  80241a:	0f 4f c2             	cmovg  %edx,%eax
  80241d:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  802420:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802423:	c9                   	leave  
  802424:	f3 c3                	repz ret 

00802426 <putch>:

static void
putch(int ch, void *thunk)
{
  802426:	55                   	push   %ebp
  802427:	89 e5                	mov    %esp,%ebp
  802429:	53                   	push   %ebx
  80242a:	83 ec 04             	sub    $0x4,%esp
  80242d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  802430:	8b 53 04             	mov    0x4(%ebx),%edx
  802433:	8d 42 01             	lea    0x1(%edx),%eax
  802436:	89 43 04             	mov    %eax,0x4(%ebx)
  802439:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80243c:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  802440:	3d 00 01 00 00       	cmp    $0x100,%eax
  802445:	75 0e                	jne    802455 <putch+0x2f>
		writebuf(b);
  802447:	89 d8                	mov    %ebx,%eax
  802449:	e8 99 ff ff ff       	call   8023e7 <writebuf>
		b->idx = 0;
  80244e:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  802455:	83 c4 04             	add    $0x4,%esp
  802458:	5b                   	pop    %ebx
  802459:	5d                   	pop    %ebp
  80245a:	c3                   	ret    

0080245b <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  80245b:	55                   	push   %ebp
  80245c:	89 e5                	mov    %esp,%ebp
  80245e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  802464:	8b 45 08             	mov    0x8(%ebp),%eax
  802467:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  80246d:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  802474:	00 00 00 
	b.result = 0;
  802477:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80247e:	00 00 00 
	b.error = 1;
  802481:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  802488:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  80248b:	ff 75 10             	pushl  0x10(%ebp)
  80248e:	ff 75 0c             	pushl  0xc(%ebp)
  802491:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  802497:	50                   	push   %eax
  802498:	68 26 24 80 00       	push   $0x802426
  80249d:	e8 83 e7 ff ff       	call   800c25 <vprintfmt>
	if (b.idx > 0)
  8024a2:	83 c4 10             	add    $0x10,%esp
  8024a5:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8024ac:	7e 0b                	jle    8024b9 <vfprintf+0x5e>
		writebuf(&b);
  8024ae:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8024b4:	e8 2e ff ff ff       	call   8023e7 <writebuf>

	return (b.result ? b.result : b.error);
  8024b9:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8024bf:	85 c0                	test   %eax,%eax
  8024c1:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  8024c8:	c9                   	leave  
  8024c9:	c3                   	ret    

008024ca <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8024ca:	55                   	push   %ebp
  8024cb:	89 e5                	mov    %esp,%ebp
  8024cd:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8024d0:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  8024d3:	50                   	push   %eax
  8024d4:	ff 75 0c             	pushl  0xc(%ebp)
  8024d7:	ff 75 08             	pushl  0x8(%ebp)
  8024da:	e8 7c ff ff ff       	call   80245b <vfprintf>
	va_end(ap);

	return cnt;
}
  8024df:	c9                   	leave  
  8024e0:	c3                   	ret    

008024e1 <printf>:

int
printf(const char *fmt, ...)
{
  8024e1:	55                   	push   %ebp
  8024e2:	89 e5                	mov    %esp,%ebp
  8024e4:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8024e7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  8024ea:	50                   	push   %eax
  8024eb:	ff 75 08             	pushl  0x8(%ebp)
  8024ee:	6a 01                	push   $0x1
  8024f0:	e8 66 ff ff ff       	call   80245b <vfprintf>
	va_end(ap);

	return cnt;
}
  8024f5:	c9                   	leave  
  8024f6:	c3                   	ret    

008024f7 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8024f7:	55                   	push   %ebp
  8024f8:	89 e5                	mov    %esp,%ebp
  8024fa:	57                   	push   %edi
  8024fb:	56                   	push   %esi
  8024fc:	53                   	push   %ebx
  8024fd:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  802503:	6a 00                	push   $0x0
  802505:	ff 75 08             	pushl  0x8(%ebp)
  802508:	e8 36 fe ff ff       	call   802343 <open>
  80250d:	89 c7                	mov    %eax,%edi
  80250f:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  802515:	83 c4 10             	add    $0x10,%esp
  802518:	85 c0                	test   %eax,%eax
  80251a:	0f 88 ae 04 00 00    	js     8029ce <spawn+0x4d7>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  802520:	83 ec 04             	sub    $0x4,%esp
  802523:	68 00 02 00 00       	push   $0x200
  802528:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  80252e:	50                   	push   %eax
  80252f:	57                   	push   %edi
  802530:	e8 14 fa ff ff       	call   801f49 <readn>
  802535:	83 c4 10             	add    $0x10,%esp
  802538:	3d 00 02 00 00       	cmp    $0x200,%eax
  80253d:	75 0c                	jne    80254b <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  80253f:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  802546:	45 4c 46 
  802549:	74 33                	je     80257e <spawn+0x87>
		close(fd);
  80254b:	83 ec 0c             	sub    $0xc,%esp
  80254e:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802554:	e8 23 f8 ff ff       	call   801d7c <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  802559:	83 c4 0c             	add    $0xc,%esp
  80255c:	68 7f 45 4c 46       	push   $0x464c457f
  802561:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  802567:	68 ee 39 80 00       	push   $0x8039ee
  80256c:	e8 7d e5 ff ff       	call   800aee <cprintf>
		return -E_NOT_EXEC;
  802571:	83 c4 10             	add    $0x10,%esp
  802574:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  802579:	e9 b0 04 00 00       	jmp    802a2e <spawn+0x537>
  80257e:	b8 07 00 00 00       	mov    $0x7,%eax
  802583:	cd 30                	int    $0x30
  802585:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  80258b:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  802591:	85 c0                	test   %eax,%eax
  802593:	0f 88 3d 04 00 00    	js     8029d6 <spawn+0x4df>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  802599:	89 c6                	mov    %eax,%esi
  80259b:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  8025a1:	6b f6 7c             	imul   $0x7c,%esi,%esi
  8025a4:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  8025aa:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8025b0:	b9 11 00 00 00       	mov    $0x11,%ecx
  8025b5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8025b7:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8025bd:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8025c3:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  8025c8:	be 00 00 00 00       	mov    $0x0,%esi
  8025cd:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8025d0:	eb 13                	jmp    8025e5 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  8025d2:	83 ec 0c             	sub    $0xc,%esp
  8025d5:	50                   	push   %eax
  8025d6:	e8 70 eb ff ff       	call   80114b <strlen>
  8025db:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8025df:	83 c3 01             	add    $0x1,%ebx
  8025e2:	83 c4 10             	add    $0x10,%esp
  8025e5:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  8025ec:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8025ef:	85 c0                	test   %eax,%eax
  8025f1:	75 df                	jne    8025d2 <spawn+0xdb>
  8025f3:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  8025f9:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8025ff:	bf 00 10 40 00       	mov    $0x401000,%edi
  802604:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  802606:	89 fa                	mov    %edi,%edx
  802608:	83 e2 fc             	and    $0xfffffffc,%edx
  80260b:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  802612:	29 c2                	sub    %eax,%edx
  802614:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  80261a:	8d 42 f8             	lea    -0x8(%edx),%eax
  80261d:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  802622:	0f 86 be 03 00 00    	jbe    8029e6 <spawn+0x4ef>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802628:	83 ec 04             	sub    $0x4,%esp
  80262b:	6a 07                	push   $0x7
  80262d:	68 00 00 40 00       	push   $0x400000
  802632:	6a 00                	push   $0x0
  802634:	e8 4e ef ff ff       	call   801587 <sys_page_alloc>
  802639:	83 c4 10             	add    $0x10,%esp
  80263c:	85 c0                	test   %eax,%eax
  80263e:	0f 88 a9 03 00 00    	js     8029ed <spawn+0x4f6>
  802644:	be 00 00 00 00       	mov    $0x0,%esi
  802649:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  80264f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  802652:	eb 30                	jmp    802684 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  802654:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  80265a:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  802660:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  802663:	83 ec 08             	sub    $0x8,%esp
  802666:	ff 34 b3             	pushl  (%ebx,%esi,4)
  802669:	57                   	push   %edi
  80266a:	e8 15 eb ff ff       	call   801184 <strcpy>
		string_store += strlen(argv[i]) + 1;
  80266f:	83 c4 04             	add    $0x4,%esp
  802672:	ff 34 b3             	pushl  (%ebx,%esi,4)
  802675:	e8 d1 ea ff ff       	call   80114b <strlen>
  80267a:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  80267e:	83 c6 01             	add    $0x1,%esi
  802681:	83 c4 10             	add    $0x10,%esp
  802684:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  80268a:	7f c8                	jg     802654 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  80268c:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  802692:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  802698:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  80269f:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  8026a5:	74 19                	je     8026c0 <spawn+0x1c9>
  8026a7:	68 64 3a 80 00       	push   $0x803a64
  8026ac:	68 ef 33 80 00       	push   $0x8033ef
  8026b1:	68 f2 00 00 00       	push   $0xf2
  8026b6:	68 08 3a 80 00       	push   $0x803a08
  8026bb:	e8 55 e3 ff ff       	call   800a15 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  8026c0:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  8026c6:	89 f8                	mov    %edi,%eax
  8026c8:	2d 00 30 80 11       	sub    $0x11803000,%eax
  8026cd:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  8026d0:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8026d6:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  8026d9:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  8026df:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8026e5:	83 ec 0c             	sub    $0xc,%esp
  8026e8:	6a 07                	push   $0x7
  8026ea:	68 00 d0 bf ee       	push   $0xeebfd000
  8026ef:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8026f5:	68 00 00 40 00       	push   $0x400000
  8026fa:	6a 00                	push   $0x0
  8026fc:	e8 c9 ee ff ff       	call   8015ca <sys_page_map>
  802701:	89 c3                	mov    %eax,%ebx
  802703:	83 c4 20             	add    $0x20,%esp
  802706:	85 c0                	test   %eax,%eax
  802708:	0f 88 0e 03 00 00    	js     802a1c <spawn+0x525>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  80270e:	83 ec 08             	sub    $0x8,%esp
  802711:	68 00 00 40 00       	push   $0x400000
  802716:	6a 00                	push   $0x0
  802718:	e8 ef ee ff ff       	call   80160c <sys_page_unmap>
  80271d:	89 c3                	mov    %eax,%ebx
  80271f:	83 c4 10             	add    $0x10,%esp
  802722:	85 c0                	test   %eax,%eax
  802724:	0f 88 f2 02 00 00    	js     802a1c <spawn+0x525>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  80272a:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  802730:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  802737:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80273d:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  802744:	00 00 00 
  802747:	e9 88 01 00 00       	jmp    8028d4 <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  80274c:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  802752:	83 38 01             	cmpl   $0x1,(%eax)
  802755:	0f 85 6b 01 00 00    	jne    8028c6 <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  80275b:	89 c7                	mov    %eax,%edi
  80275d:	8b 40 18             	mov    0x18(%eax),%eax
  802760:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  802766:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  802769:	83 f8 01             	cmp    $0x1,%eax
  80276c:	19 c0                	sbb    %eax,%eax
  80276e:	83 e0 fe             	and    $0xfffffffe,%eax
  802771:	83 c0 07             	add    $0x7,%eax
  802774:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  80277a:	89 f8                	mov    %edi,%eax
  80277c:	8b 7f 04             	mov    0x4(%edi),%edi
  80277f:	89 f9                	mov    %edi,%ecx
  802781:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  802787:	8b 78 10             	mov    0x10(%eax),%edi
  80278a:	8b 50 14             	mov    0x14(%eax),%edx
  80278d:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  802793:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  802796:	89 f0                	mov    %esi,%eax
  802798:	25 ff 0f 00 00       	and    $0xfff,%eax
  80279d:	74 14                	je     8027b3 <spawn+0x2bc>
		va -= i;
  80279f:	29 c6                	sub    %eax,%esi
		memsz += i;
  8027a1:	01 c2                	add    %eax,%edx
  8027a3:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  8027a9:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  8027ab:	29 c1                	sub    %eax,%ecx
  8027ad:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8027b3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8027b8:	e9 f7 00 00 00       	jmp    8028b4 <spawn+0x3bd>
		if (i >= filesz) {
  8027bd:	39 df                	cmp    %ebx,%edi
  8027bf:	77 27                	ja     8027e8 <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  8027c1:	83 ec 04             	sub    $0x4,%esp
  8027c4:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8027ca:	56                   	push   %esi
  8027cb:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  8027d1:	e8 b1 ed ff ff       	call   801587 <sys_page_alloc>
  8027d6:	83 c4 10             	add    $0x10,%esp
  8027d9:	85 c0                	test   %eax,%eax
  8027db:	0f 89 c7 00 00 00    	jns    8028a8 <spawn+0x3b1>
  8027e1:	89 c3                	mov    %eax,%ebx
  8027e3:	e9 13 02 00 00       	jmp    8029fb <spawn+0x504>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8027e8:	83 ec 04             	sub    $0x4,%esp
  8027eb:	6a 07                	push   $0x7
  8027ed:	68 00 00 40 00       	push   $0x400000
  8027f2:	6a 00                	push   $0x0
  8027f4:	e8 8e ed ff ff       	call   801587 <sys_page_alloc>
  8027f9:	83 c4 10             	add    $0x10,%esp
  8027fc:	85 c0                	test   %eax,%eax
  8027fe:	0f 88 ed 01 00 00    	js     8029f1 <spawn+0x4fa>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802804:	83 ec 08             	sub    $0x8,%esp
  802807:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  80280d:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  802813:	50                   	push   %eax
  802814:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80281a:	e8 ff f7 ff ff       	call   80201e <seek>
  80281f:	83 c4 10             	add    $0x10,%esp
  802822:	85 c0                	test   %eax,%eax
  802824:	0f 88 cb 01 00 00    	js     8029f5 <spawn+0x4fe>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  80282a:	83 ec 04             	sub    $0x4,%esp
  80282d:	89 f8                	mov    %edi,%eax
  80282f:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  802835:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80283a:	ba 00 10 00 00       	mov    $0x1000,%edx
  80283f:	0f 47 c2             	cmova  %edx,%eax
  802842:	50                   	push   %eax
  802843:	68 00 00 40 00       	push   $0x400000
  802848:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80284e:	e8 f6 f6 ff ff       	call   801f49 <readn>
  802853:	83 c4 10             	add    $0x10,%esp
  802856:	85 c0                	test   %eax,%eax
  802858:	0f 88 9b 01 00 00    	js     8029f9 <spawn+0x502>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  80285e:	83 ec 0c             	sub    $0xc,%esp
  802861:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  802867:	56                   	push   %esi
  802868:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  80286e:	68 00 00 40 00       	push   $0x400000
  802873:	6a 00                	push   $0x0
  802875:	e8 50 ed ff ff       	call   8015ca <sys_page_map>
  80287a:	83 c4 20             	add    $0x20,%esp
  80287d:	85 c0                	test   %eax,%eax
  80287f:	79 15                	jns    802896 <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  802881:	50                   	push   %eax
  802882:	68 14 3a 80 00       	push   $0x803a14
  802887:	68 25 01 00 00       	push   $0x125
  80288c:	68 08 3a 80 00       	push   $0x803a08
  802891:	e8 7f e1 ff ff       	call   800a15 <_panic>
			sys_page_unmap(0, UTEMP);
  802896:	83 ec 08             	sub    $0x8,%esp
  802899:	68 00 00 40 00       	push   $0x400000
  80289e:	6a 00                	push   $0x0
  8028a0:	e8 67 ed ff ff       	call   80160c <sys_page_unmap>
  8028a5:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8028a8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8028ae:	81 c6 00 10 00 00    	add    $0x1000,%esi
  8028b4:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  8028ba:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  8028c0:	0f 87 f7 fe ff ff    	ja     8027bd <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8028c6:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  8028cd:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  8028d4:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  8028db:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  8028e1:	0f 8c 65 fe ff ff    	jl     80274c <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  8028e7:	83 ec 0c             	sub    $0xc,%esp
  8028ea:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8028f0:	e8 87 f4 ff ff       	call   801d7c <close>
  8028f5:	83 c4 10             	add    $0x10,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
   	uintptr_t addr;
	for (addr = 0; addr < UTOP; addr += PGSIZE) {
  8028f8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8028fd:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) &&(uvpt[PGNUM(addr)] & PTE_U) && (uvpt[PGNUM(addr)] & PTE_SHARE)) {
  802903:	89 d8                	mov    %ebx,%eax
  802905:	c1 e8 16             	shr    $0x16,%eax
  802908:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80290f:	a8 01                	test   $0x1,%al
  802911:	74 46                	je     802959 <spawn+0x462>
  802913:	89 d8                	mov    %ebx,%eax
  802915:	c1 e8 0c             	shr    $0xc,%eax
  802918:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80291f:	f6 c2 01             	test   $0x1,%dl
  802922:	74 35                	je     802959 <spawn+0x462>
  802924:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80292b:	f6 c2 04             	test   $0x4,%dl
  80292e:	74 29                	je     802959 <spawn+0x462>
  802930:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802937:	f6 c6 04             	test   $0x4,%dh
  80293a:	74 1d                	je     802959 <spawn+0x462>
			// cprintf("copy shared page %d to env:%x\n", PGNUM(addr), child);
            		sys_page_map(0, (void*)addr, child, (void*)addr, (uvpt[PGNUM(addr)] & PTE_SYSCALL));
  80293c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802943:	83 ec 0c             	sub    $0xc,%esp
  802946:	25 07 0e 00 00       	and    $0xe07,%eax
  80294b:	50                   	push   %eax
  80294c:	53                   	push   %ebx
  80294d:	56                   	push   %esi
  80294e:	53                   	push   %ebx
  80294f:	6a 00                	push   $0x0
  802951:	e8 74 ec ff ff       	call   8015ca <sys_page_map>
  802956:	83 c4 20             	add    $0x20,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
   	uintptr_t addr;
	for (addr = 0; addr < UTOP; addr += PGSIZE) {
  802959:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80295f:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  802965:	75 9c                	jne    802903 <spawn+0x40c>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  802967:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  80296e:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802971:	83 ec 08             	sub    $0x8,%esp
  802974:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  80297a:	50                   	push   %eax
  80297b:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802981:	e8 0a ed ff ff       	call   801690 <sys_env_set_trapframe>
  802986:	83 c4 10             	add    $0x10,%esp
  802989:	85 c0                	test   %eax,%eax
  80298b:	79 15                	jns    8029a2 <spawn+0x4ab>
		panic("sys_env_set_trapframe: %e", r);
  80298d:	50                   	push   %eax
  80298e:	68 31 3a 80 00       	push   $0x803a31
  802993:	68 86 00 00 00       	push   $0x86
  802998:	68 08 3a 80 00       	push   $0x803a08
  80299d:	e8 73 e0 ff ff       	call   800a15 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  8029a2:	83 ec 08             	sub    $0x8,%esp
  8029a5:	6a 02                	push   $0x2
  8029a7:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8029ad:	e8 9c ec ff ff       	call   80164e <sys_env_set_status>
  8029b2:	83 c4 10             	add    $0x10,%esp
  8029b5:	85 c0                	test   %eax,%eax
  8029b7:	79 25                	jns    8029de <spawn+0x4e7>
		panic("sys_env_set_status: %e", r);
  8029b9:	50                   	push   %eax
  8029ba:	68 4b 3a 80 00       	push   $0x803a4b
  8029bf:	68 89 00 00 00       	push   $0x89
  8029c4:	68 08 3a 80 00       	push   $0x803a08
  8029c9:	e8 47 e0 ff ff       	call   800a15 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  8029ce:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  8029d4:	eb 58                	jmp    802a2e <spawn+0x537>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  8029d6:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  8029dc:	eb 50                	jmp    802a2e <spawn+0x537>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  8029de:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  8029e4:	eb 48                	jmp    802a2e <spawn+0x537>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  8029e6:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  8029eb:	eb 41                	jmp    802a2e <spawn+0x537>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  8029ed:	89 c3                	mov    %eax,%ebx
  8029ef:	eb 3d                	jmp    802a2e <spawn+0x537>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8029f1:	89 c3                	mov    %eax,%ebx
  8029f3:	eb 06                	jmp    8029fb <spawn+0x504>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8029f5:	89 c3                	mov    %eax,%ebx
  8029f7:	eb 02                	jmp    8029fb <spawn+0x504>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8029f9:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  8029fb:	83 ec 0c             	sub    $0xc,%esp
  8029fe:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802a04:	e8 ff ea ff ff       	call   801508 <sys_env_destroy>
	close(fd);
  802a09:	83 c4 04             	add    $0x4,%esp
  802a0c:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802a12:	e8 65 f3 ff ff       	call   801d7c <close>
	return r;
  802a17:	83 c4 10             	add    $0x10,%esp
  802a1a:	eb 12                	jmp    802a2e <spawn+0x537>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  802a1c:	83 ec 08             	sub    $0x8,%esp
  802a1f:	68 00 00 40 00       	push   $0x400000
  802a24:	6a 00                	push   $0x0
  802a26:	e8 e1 eb ff ff       	call   80160c <sys_page_unmap>
  802a2b:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  802a2e:	89 d8                	mov    %ebx,%eax
  802a30:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802a33:	5b                   	pop    %ebx
  802a34:	5e                   	pop    %esi
  802a35:	5f                   	pop    %edi
  802a36:	5d                   	pop    %ebp
  802a37:	c3                   	ret    

00802a38 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802a38:	55                   	push   %ebp
  802a39:	89 e5                	mov    %esp,%ebp
  802a3b:	56                   	push   %esi
  802a3c:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802a3d:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  802a40:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802a45:	eb 03                	jmp    802a4a <spawnl+0x12>
		argc++;
  802a47:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802a4a:	83 c2 04             	add    $0x4,%edx
  802a4d:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  802a51:	75 f4                	jne    802a47 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802a53:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  802a5a:	83 e2 f0             	and    $0xfffffff0,%edx
  802a5d:	29 d4                	sub    %edx,%esp
  802a5f:	8d 54 24 03          	lea    0x3(%esp),%edx
  802a63:	c1 ea 02             	shr    $0x2,%edx
  802a66:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  802a6d:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  802a6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802a72:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  802a79:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  802a80:	00 
  802a81:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802a83:	b8 00 00 00 00       	mov    $0x0,%eax
  802a88:	eb 0a                	jmp    802a94 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  802a8a:	83 c0 01             	add    $0x1,%eax
  802a8d:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  802a91:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802a94:	39 d0                	cmp    %edx,%eax
  802a96:	75 f2                	jne    802a8a <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802a98:	83 ec 08             	sub    $0x8,%esp
  802a9b:	56                   	push   %esi
  802a9c:	ff 75 08             	pushl  0x8(%ebp)
  802a9f:	e8 53 fa ff ff       	call   8024f7 <spawn>
}
  802aa4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802aa7:	5b                   	pop    %ebx
  802aa8:	5e                   	pop    %esi
  802aa9:	5d                   	pop    %ebp
  802aaa:	c3                   	ret    

00802aab <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802aab:	55                   	push   %ebp
  802aac:	89 e5                	mov    %esp,%ebp
  802aae:	56                   	push   %esi
  802aaf:	53                   	push   %ebx
  802ab0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802ab3:	83 ec 0c             	sub    $0xc,%esp
  802ab6:	ff 75 08             	pushl  0x8(%ebp)
  802ab9:	e8 2e f1 ff ff       	call   801bec <fd2data>
  802abe:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802ac0:	83 c4 08             	add    $0x8,%esp
  802ac3:	68 8a 3a 80 00       	push   $0x803a8a
  802ac8:	53                   	push   %ebx
  802ac9:	e8 b6 e6 ff ff       	call   801184 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802ace:	8b 46 04             	mov    0x4(%esi),%eax
  802ad1:	2b 06                	sub    (%esi),%eax
  802ad3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802ad9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802ae0:	00 00 00 
	stat->st_dev = &devpipe;
  802ae3:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  802aea:	40 80 00 
	return 0;
}
  802aed:	b8 00 00 00 00       	mov    $0x0,%eax
  802af2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802af5:	5b                   	pop    %ebx
  802af6:	5e                   	pop    %esi
  802af7:	5d                   	pop    %ebp
  802af8:	c3                   	ret    

00802af9 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802af9:	55                   	push   %ebp
  802afa:	89 e5                	mov    %esp,%ebp
  802afc:	53                   	push   %ebx
  802afd:	83 ec 0c             	sub    $0xc,%esp
  802b00:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802b03:	53                   	push   %ebx
  802b04:	6a 00                	push   $0x0
  802b06:	e8 01 eb ff ff       	call   80160c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802b0b:	89 1c 24             	mov    %ebx,(%esp)
  802b0e:	e8 d9 f0 ff ff       	call   801bec <fd2data>
  802b13:	83 c4 08             	add    $0x8,%esp
  802b16:	50                   	push   %eax
  802b17:	6a 00                	push   $0x0
  802b19:	e8 ee ea ff ff       	call   80160c <sys_page_unmap>
}
  802b1e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802b21:	c9                   	leave  
  802b22:	c3                   	ret    

00802b23 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802b23:	55                   	push   %ebp
  802b24:	89 e5                	mov    %esp,%ebp
  802b26:	57                   	push   %edi
  802b27:	56                   	push   %esi
  802b28:	53                   	push   %ebx
  802b29:	83 ec 1c             	sub    $0x1c,%esp
  802b2c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802b2f:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802b31:	a1 24 54 80 00       	mov    0x805424,%eax
  802b36:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  802b39:	83 ec 0c             	sub    $0xc,%esp
  802b3c:	ff 75 e0             	pushl  -0x20(%ebp)
  802b3f:	e8 80 04 00 00       	call   802fc4 <pageref>
  802b44:	89 c3                	mov    %eax,%ebx
  802b46:	89 3c 24             	mov    %edi,(%esp)
  802b49:	e8 76 04 00 00       	call   802fc4 <pageref>
  802b4e:	83 c4 10             	add    $0x10,%esp
  802b51:	39 c3                	cmp    %eax,%ebx
  802b53:	0f 94 c1             	sete   %cl
  802b56:	0f b6 c9             	movzbl %cl,%ecx
  802b59:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802b5c:	8b 15 24 54 80 00    	mov    0x805424,%edx
  802b62:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802b65:	39 ce                	cmp    %ecx,%esi
  802b67:	74 1b                	je     802b84 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802b69:	39 c3                	cmp    %eax,%ebx
  802b6b:	75 c4                	jne    802b31 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802b6d:	8b 42 58             	mov    0x58(%edx),%eax
  802b70:	ff 75 e4             	pushl  -0x1c(%ebp)
  802b73:	50                   	push   %eax
  802b74:	56                   	push   %esi
  802b75:	68 91 3a 80 00       	push   $0x803a91
  802b7a:	e8 6f df ff ff       	call   800aee <cprintf>
  802b7f:	83 c4 10             	add    $0x10,%esp
  802b82:	eb ad                	jmp    802b31 <_pipeisclosed+0xe>
	}
}
  802b84:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802b87:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802b8a:	5b                   	pop    %ebx
  802b8b:	5e                   	pop    %esi
  802b8c:	5f                   	pop    %edi
  802b8d:	5d                   	pop    %ebp
  802b8e:	c3                   	ret    

00802b8f <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802b8f:	55                   	push   %ebp
  802b90:	89 e5                	mov    %esp,%ebp
  802b92:	57                   	push   %edi
  802b93:	56                   	push   %esi
  802b94:	53                   	push   %ebx
  802b95:	83 ec 28             	sub    $0x28,%esp
  802b98:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802b9b:	56                   	push   %esi
  802b9c:	e8 4b f0 ff ff       	call   801bec <fd2data>
  802ba1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802ba3:	83 c4 10             	add    $0x10,%esp
  802ba6:	bf 00 00 00 00       	mov    $0x0,%edi
  802bab:	eb 4b                	jmp    802bf8 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802bad:	89 da                	mov    %ebx,%edx
  802baf:	89 f0                	mov    %esi,%eax
  802bb1:	e8 6d ff ff ff       	call   802b23 <_pipeisclosed>
  802bb6:	85 c0                	test   %eax,%eax
  802bb8:	75 48                	jne    802c02 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802bba:	e8 a9 e9 ff ff       	call   801568 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802bbf:	8b 43 04             	mov    0x4(%ebx),%eax
  802bc2:	8b 0b                	mov    (%ebx),%ecx
  802bc4:	8d 51 20             	lea    0x20(%ecx),%edx
  802bc7:	39 d0                	cmp    %edx,%eax
  802bc9:	73 e2                	jae    802bad <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802bcb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802bce:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802bd2:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802bd5:	89 c2                	mov    %eax,%edx
  802bd7:	c1 fa 1f             	sar    $0x1f,%edx
  802bda:	89 d1                	mov    %edx,%ecx
  802bdc:	c1 e9 1b             	shr    $0x1b,%ecx
  802bdf:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802be2:	83 e2 1f             	and    $0x1f,%edx
  802be5:	29 ca                	sub    %ecx,%edx
  802be7:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802beb:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802bef:	83 c0 01             	add    $0x1,%eax
  802bf2:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802bf5:	83 c7 01             	add    $0x1,%edi
  802bf8:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802bfb:	75 c2                	jne    802bbf <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802bfd:	8b 45 10             	mov    0x10(%ebp),%eax
  802c00:	eb 05                	jmp    802c07 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802c02:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802c07:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802c0a:	5b                   	pop    %ebx
  802c0b:	5e                   	pop    %esi
  802c0c:	5f                   	pop    %edi
  802c0d:	5d                   	pop    %ebp
  802c0e:	c3                   	ret    

00802c0f <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802c0f:	55                   	push   %ebp
  802c10:	89 e5                	mov    %esp,%ebp
  802c12:	57                   	push   %edi
  802c13:	56                   	push   %esi
  802c14:	53                   	push   %ebx
  802c15:	83 ec 18             	sub    $0x18,%esp
  802c18:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802c1b:	57                   	push   %edi
  802c1c:	e8 cb ef ff ff       	call   801bec <fd2data>
  802c21:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802c23:	83 c4 10             	add    $0x10,%esp
  802c26:	bb 00 00 00 00       	mov    $0x0,%ebx
  802c2b:	eb 3d                	jmp    802c6a <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802c2d:	85 db                	test   %ebx,%ebx
  802c2f:	74 04                	je     802c35 <devpipe_read+0x26>
				return i;
  802c31:	89 d8                	mov    %ebx,%eax
  802c33:	eb 44                	jmp    802c79 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802c35:	89 f2                	mov    %esi,%edx
  802c37:	89 f8                	mov    %edi,%eax
  802c39:	e8 e5 fe ff ff       	call   802b23 <_pipeisclosed>
  802c3e:	85 c0                	test   %eax,%eax
  802c40:	75 32                	jne    802c74 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802c42:	e8 21 e9 ff ff       	call   801568 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802c47:	8b 06                	mov    (%esi),%eax
  802c49:	3b 46 04             	cmp    0x4(%esi),%eax
  802c4c:	74 df                	je     802c2d <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802c4e:	99                   	cltd   
  802c4f:	c1 ea 1b             	shr    $0x1b,%edx
  802c52:	01 d0                	add    %edx,%eax
  802c54:	83 e0 1f             	and    $0x1f,%eax
  802c57:	29 d0                	sub    %edx,%eax
  802c59:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802c5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802c61:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802c64:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802c67:	83 c3 01             	add    $0x1,%ebx
  802c6a:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802c6d:	75 d8                	jne    802c47 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802c6f:	8b 45 10             	mov    0x10(%ebp),%eax
  802c72:	eb 05                	jmp    802c79 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802c74:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802c79:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802c7c:	5b                   	pop    %ebx
  802c7d:	5e                   	pop    %esi
  802c7e:	5f                   	pop    %edi
  802c7f:	5d                   	pop    %ebp
  802c80:	c3                   	ret    

00802c81 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802c81:	55                   	push   %ebp
  802c82:	89 e5                	mov    %esp,%ebp
  802c84:	56                   	push   %esi
  802c85:	53                   	push   %ebx
  802c86:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802c89:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802c8c:	50                   	push   %eax
  802c8d:	e8 71 ef ff ff       	call   801c03 <fd_alloc>
  802c92:	83 c4 10             	add    $0x10,%esp
  802c95:	89 c2                	mov    %eax,%edx
  802c97:	85 c0                	test   %eax,%eax
  802c99:	0f 88 2c 01 00 00    	js     802dcb <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802c9f:	83 ec 04             	sub    $0x4,%esp
  802ca2:	68 07 04 00 00       	push   $0x407
  802ca7:	ff 75 f4             	pushl  -0xc(%ebp)
  802caa:	6a 00                	push   $0x0
  802cac:	e8 d6 e8 ff ff       	call   801587 <sys_page_alloc>
  802cb1:	83 c4 10             	add    $0x10,%esp
  802cb4:	89 c2                	mov    %eax,%edx
  802cb6:	85 c0                	test   %eax,%eax
  802cb8:	0f 88 0d 01 00 00    	js     802dcb <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802cbe:	83 ec 0c             	sub    $0xc,%esp
  802cc1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802cc4:	50                   	push   %eax
  802cc5:	e8 39 ef ff ff       	call   801c03 <fd_alloc>
  802cca:	89 c3                	mov    %eax,%ebx
  802ccc:	83 c4 10             	add    $0x10,%esp
  802ccf:	85 c0                	test   %eax,%eax
  802cd1:	0f 88 e2 00 00 00    	js     802db9 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802cd7:	83 ec 04             	sub    $0x4,%esp
  802cda:	68 07 04 00 00       	push   $0x407
  802cdf:	ff 75 f0             	pushl  -0x10(%ebp)
  802ce2:	6a 00                	push   $0x0
  802ce4:	e8 9e e8 ff ff       	call   801587 <sys_page_alloc>
  802ce9:	89 c3                	mov    %eax,%ebx
  802ceb:	83 c4 10             	add    $0x10,%esp
  802cee:	85 c0                	test   %eax,%eax
  802cf0:	0f 88 c3 00 00 00    	js     802db9 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802cf6:	83 ec 0c             	sub    $0xc,%esp
  802cf9:	ff 75 f4             	pushl  -0xc(%ebp)
  802cfc:	e8 eb ee ff ff       	call   801bec <fd2data>
  802d01:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802d03:	83 c4 0c             	add    $0xc,%esp
  802d06:	68 07 04 00 00       	push   $0x407
  802d0b:	50                   	push   %eax
  802d0c:	6a 00                	push   $0x0
  802d0e:	e8 74 e8 ff ff       	call   801587 <sys_page_alloc>
  802d13:	89 c3                	mov    %eax,%ebx
  802d15:	83 c4 10             	add    $0x10,%esp
  802d18:	85 c0                	test   %eax,%eax
  802d1a:	0f 88 89 00 00 00    	js     802da9 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802d20:	83 ec 0c             	sub    $0xc,%esp
  802d23:	ff 75 f0             	pushl  -0x10(%ebp)
  802d26:	e8 c1 ee ff ff       	call   801bec <fd2data>
  802d2b:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802d32:	50                   	push   %eax
  802d33:	6a 00                	push   $0x0
  802d35:	56                   	push   %esi
  802d36:	6a 00                	push   $0x0
  802d38:	e8 8d e8 ff ff       	call   8015ca <sys_page_map>
  802d3d:	89 c3                	mov    %eax,%ebx
  802d3f:	83 c4 20             	add    $0x20,%esp
  802d42:	85 c0                	test   %eax,%eax
  802d44:	78 55                	js     802d9b <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802d46:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802d4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802d4f:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802d51:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802d54:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802d5b:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802d61:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d64:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802d66:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d69:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802d70:	83 ec 0c             	sub    $0xc,%esp
  802d73:	ff 75 f4             	pushl  -0xc(%ebp)
  802d76:	e8 61 ee ff ff       	call   801bdc <fd2num>
  802d7b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802d7e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802d80:	83 c4 04             	add    $0x4,%esp
  802d83:	ff 75 f0             	pushl  -0x10(%ebp)
  802d86:	e8 51 ee ff ff       	call   801bdc <fd2num>
  802d8b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802d8e:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802d91:	83 c4 10             	add    $0x10,%esp
  802d94:	ba 00 00 00 00       	mov    $0x0,%edx
  802d99:	eb 30                	jmp    802dcb <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802d9b:	83 ec 08             	sub    $0x8,%esp
  802d9e:	56                   	push   %esi
  802d9f:	6a 00                	push   $0x0
  802da1:	e8 66 e8 ff ff       	call   80160c <sys_page_unmap>
  802da6:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802da9:	83 ec 08             	sub    $0x8,%esp
  802dac:	ff 75 f0             	pushl  -0x10(%ebp)
  802daf:	6a 00                	push   $0x0
  802db1:	e8 56 e8 ff ff       	call   80160c <sys_page_unmap>
  802db6:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802db9:	83 ec 08             	sub    $0x8,%esp
  802dbc:	ff 75 f4             	pushl  -0xc(%ebp)
  802dbf:	6a 00                	push   $0x0
  802dc1:	e8 46 e8 ff ff       	call   80160c <sys_page_unmap>
  802dc6:	83 c4 10             	add    $0x10,%esp
  802dc9:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802dcb:	89 d0                	mov    %edx,%eax
  802dcd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802dd0:	5b                   	pop    %ebx
  802dd1:	5e                   	pop    %esi
  802dd2:	5d                   	pop    %ebp
  802dd3:	c3                   	ret    

00802dd4 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802dd4:	55                   	push   %ebp
  802dd5:	89 e5                	mov    %esp,%ebp
  802dd7:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802dda:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802ddd:	50                   	push   %eax
  802dde:	ff 75 08             	pushl  0x8(%ebp)
  802de1:	e8 6c ee ff ff       	call   801c52 <fd_lookup>
  802de6:	83 c4 10             	add    $0x10,%esp
  802de9:	85 c0                	test   %eax,%eax
  802deb:	78 18                	js     802e05 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802ded:	83 ec 0c             	sub    $0xc,%esp
  802df0:	ff 75 f4             	pushl  -0xc(%ebp)
  802df3:	e8 f4 ed ff ff       	call   801bec <fd2data>
	return _pipeisclosed(fd, p);
  802df8:	89 c2                	mov    %eax,%edx
  802dfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802dfd:	e8 21 fd ff ff       	call   802b23 <_pipeisclosed>
  802e02:	83 c4 10             	add    $0x10,%esp
}
  802e05:	c9                   	leave  
  802e06:	c3                   	ret    

00802e07 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802e07:	55                   	push   %ebp
  802e08:	89 e5                	mov    %esp,%ebp
  802e0a:	56                   	push   %esi
  802e0b:	53                   	push   %ebx
  802e0c:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802e0f:	85 f6                	test   %esi,%esi
  802e11:	75 16                	jne    802e29 <wait+0x22>
  802e13:	68 a9 3a 80 00       	push   $0x803aa9
  802e18:	68 ef 33 80 00       	push   $0x8033ef
  802e1d:	6a 09                	push   $0x9
  802e1f:	68 b4 3a 80 00       	push   $0x803ab4
  802e24:	e8 ec db ff ff       	call   800a15 <_panic>
	e = &envs[ENVX(envid)];
  802e29:	89 f3                	mov    %esi,%ebx
  802e2b:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802e31:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  802e34:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802e3a:	eb 05                	jmp    802e41 <wait+0x3a>
		sys_yield();
  802e3c:	e8 27 e7 ff ff       	call   801568 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802e41:	8b 43 48             	mov    0x48(%ebx),%eax
  802e44:	39 c6                	cmp    %eax,%esi
  802e46:	75 07                	jne    802e4f <wait+0x48>
  802e48:	8b 43 54             	mov    0x54(%ebx),%eax
  802e4b:	85 c0                	test   %eax,%eax
  802e4d:	75 ed                	jne    802e3c <wait+0x35>
		sys_yield();
}
  802e4f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802e52:	5b                   	pop    %ebx
  802e53:	5e                   	pop    %esi
  802e54:	5d                   	pop    %ebp
  802e55:	c3                   	ret    

00802e56 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802e56:	55                   	push   %ebp
  802e57:	89 e5                	mov    %esp,%ebp
  802e59:	83 ec 08             	sub    $0x8,%esp
	int r;
	int ret;
	if (_pgfault_handler == 0) {
  802e5c:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802e63:	75 36                	jne    802e9b <set_pgfault_handler+0x45>
		// First time through!
		// LAB 4: Your code here.
        
        	ret = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  802e65:	a1 24 54 80 00       	mov    0x805424,%eax
  802e6a:	8b 40 48             	mov    0x48(%eax),%eax
  802e6d:	83 ec 04             	sub    $0x4,%esp
  802e70:	68 07 0e 00 00       	push   $0xe07
  802e75:	68 00 f0 bf ee       	push   $0xeebff000
  802e7a:	50                   	push   %eax
  802e7b:	e8 07 e7 ff ff       	call   801587 <sys_page_alloc>
		if (ret < 0) {
  802e80:	83 c4 10             	add    $0x10,%esp
  802e83:	85 c0                	test   %eax,%eax
  802e85:	79 14                	jns    802e9b <set_pgfault_handler+0x45>
		    panic("Allocate user exception stack failed!\n");
  802e87:	83 ec 04             	sub    $0x4,%esp
  802e8a:	68 c0 3a 80 00       	push   $0x803ac0
  802e8f:	6a 23                	push   $0x23
  802e91:	68 e8 3a 80 00       	push   $0x803ae8
  802e96:	e8 7a db ff ff       	call   800a15 <_panic>
		}
	}
	sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  802e9b:	a1 24 54 80 00       	mov    0x805424,%eax
  802ea0:	8b 40 48             	mov    0x48(%eax),%eax
  802ea3:	83 ec 08             	sub    $0x8,%esp
  802ea6:	68 be 2e 80 00       	push   $0x802ebe
  802eab:	50                   	push   %eax
  802eac:	e8 21 e8 ff ff       	call   8016d2 <sys_env_set_pgfault_upcall>
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802eb1:	8b 45 08             	mov    0x8(%ebp),%eax
  802eb4:	a3 00 70 80 00       	mov    %eax,0x807000
}
  802eb9:	83 c4 10             	add    $0x10,%esp
  802ebc:	c9                   	leave  
  802ebd:	c3                   	ret    

00802ebe <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802ebe:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802ebf:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802ec4:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802ec6:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 0x28(%esp), %ebx  # trap-time eip
  802ec9:	8b 5c 24 28          	mov    0x28(%esp),%ebx
        subl $0x4, 0x30(%esp)  # trap-time esp minus 4
  802ecd:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax 
  802ed2:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl %ebx, (%eax)      # trap-time esp store trap-time eip
  802ed6:	89 18                	mov    %ebx,(%eax)
        addl $0x8, %esp
  802ed8:	83 c4 08             	add    $0x8,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  802edb:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  802edc:	83 c4 04             	add    $0x4,%esp
        popfl
  802edf:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  802ee0:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  802ee1:	c3                   	ret    

00802ee2 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802ee2:	55                   	push   %ebp
  802ee3:	89 e5                	mov    %esp,%ebp
  802ee5:	56                   	push   %esi
  802ee6:	53                   	push   %ebx
  802ee7:	8b 75 08             	mov    0x8(%ebp),%esi
  802eea:	8b 45 0c             	mov    0xc(%ebp),%eax
  802eed:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_recv not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  802ef0:	85 c0                	test   %eax,%eax
  802ef2:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802ef7:	0f 44 c2             	cmove  %edx,%eax

    int r = sys_ipc_recv(pg);
  802efa:	83 ec 0c             	sub    $0xc,%esp
  802efd:	50                   	push   %eax
  802efe:	e8 34 e8 ff ff       	call   801737 <sys_ipc_recv>
    int from_env = 0, perm = 0;
    if (r == 0) {
  802f03:	83 c4 10             	add    $0x10,%esp
  802f06:	85 c0                	test   %eax,%eax
  802f08:	75 10                	jne    802f1a <ipc_recv+0x38>
        from_env = thisenv->env_ipc_from;
  802f0a:	a1 24 54 80 00       	mov    0x805424,%eax
  802f0f:	8b 48 74             	mov    0x74(%eax),%ecx
        perm = thisenv->env_ipc_perm;
  802f12:	8b 50 78             	mov    0x78(%eax),%edx
        r = thisenv->env_ipc_value;
  802f15:	8b 40 70             	mov    0x70(%eax),%eax
  802f18:	eb 0a                	jmp    802f24 <ipc_recv+0x42>
    } else {
        from_env = 0;
        perm = 0;
  802f1a:	ba 00 00 00 00       	mov    $0x0,%edx
    if (r == 0) {
        from_env = thisenv->env_ipc_from;
        perm = thisenv->env_ipc_perm;
        r = thisenv->env_ipc_value;
    } else {
        from_env = 0;
  802f1f:	b9 00 00 00 00       	mov    $0x0,%ecx
        perm = 0;
    }

    if (from_env_store) *from_env_store = from_env;
  802f24:	85 f6                	test   %esi,%esi
  802f26:	74 02                	je     802f2a <ipc_recv+0x48>
  802f28:	89 0e                	mov    %ecx,(%esi)
    if (perm_store) *perm_store = perm;
  802f2a:	85 db                	test   %ebx,%ebx
  802f2c:	74 02                	je     802f30 <ipc_recv+0x4e>
  802f2e:	89 13                	mov    %edx,(%ebx)

    return r;
}
  802f30:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802f33:	5b                   	pop    %ebx
  802f34:	5e                   	pop    %esi
  802f35:	5d                   	pop    %ebp
  802f36:	c3                   	ret    

00802f37 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802f37:	55                   	push   %ebp
  802f38:	89 e5                	mov    %esp,%ebp
  802f3a:	57                   	push   %edi
  802f3b:	56                   	push   %esi
  802f3c:	53                   	push   %ebx
  802f3d:	83 ec 0c             	sub    $0xc,%esp
  802f40:	8b 7d 08             	mov    0x8(%ebp),%edi
  802f43:	8b 75 0c             	mov    0xc(%ebp),%esi
  802f46:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  802f49:	85 db                	test   %ebx,%ebx
  802f4b:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802f50:	0f 44 d8             	cmove  %eax,%ebx
  802f53:	eb 1c                	jmp    802f71 <ipc_send+0x3a>

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        if (ret != -E_IPC_NOT_RECV)
  802f55:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802f58:	74 12                	je     802f6c <ipc_send+0x35>
            panic("ipc_send error %e", ret);
  802f5a:	50                   	push   %eax
  802f5b:	68 f6 3a 80 00       	push   $0x803af6
  802f60:	6a 40                	push   $0x40
  802f62:	68 08 3b 80 00       	push   $0x803b08
  802f67:	e8 a9 da ff ff       	call   800a15 <_panic>
        sys_yield();
  802f6c:	e8 f7 e5 ff ff       	call   801568 <sys_yield>
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  802f71:	ff 75 14             	pushl  0x14(%ebp)
  802f74:	53                   	push   %ebx
  802f75:	56                   	push   %esi
  802f76:	57                   	push   %edi
  802f77:	e8 98 e7 ff ff       	call   801714 <sys_ipc_try_send>
  802f7c:	83 c4 10             	add    $0x10,%esp
  802f7f:	85 c0                	test   %eax,%eax
  802f81:	75 d2                	jne    802f55 <ipc_send+0x1e>
        if (ret != -E_IPC_NOT_RECV)
            panic("ipc_send error %e", ret);
        sys_yield();
    }
}
  802f83:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802f86:	5b                   	pop    %ebx
  802f87:	5e                   	pop    %esi
  802f88:	5f                   	pop    %edi
  802f89:	5d                   	pop    %ebp
  802f8a:	c3                   	ret    

00802f8b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802f8b:	55                   	push   %ebp
  802f8c:	89 e5                	mov    %esp,%ebp
  802f8e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802f91:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802f96:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802f99:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802f9f:	8b 52 50             	mov    0x50(%edx),%edx
  802fa2:	39 ca                	cmp    %ecx,%edx
  802fa4:	75 0d                	jne    802fb3 <ipc_find_env+0x28>
			return envs[i].env_id;
  802fa6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802fa9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802fae:	8b 40 48             	mov    0x48(%eax),%eax
  802fb1:	eb 0f                	jmp    802fc2 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802fb3:	83 c0 01             	add    $0x1,%eax
  802fb6:	3d 00 04 00 00       	cmp    $0x400,%eax
  802fbb:	75 d9                	jne    802f96 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802fbd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802fc2:	5d                   	pop    %ebp
  802fc3:	c3                   	ret    

00802fc4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802fc4:	55                   	push   %ebp
  802fc5:	89 e5                	mov    %esp,%ebp
  802fc7:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802fca:	89 d0                	mov    %edx,%eax
  802fcc:	c1 e8 16             	shr    $0x16,%eax
  802fcf:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802fd6:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802fdb:	f6 c1 01             	test   $0x1,%cl
  802fde:	74 1d                	je     802ffd <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802fe0:	c1 ea 0c             	shr    $0xc,%edx
  802fe3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802fea:	f6 c2 01             	test   $0x1,%dl
  802fed:	74 0e                	je     802ffd <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802fef:	c1 ea 0c             	shr    $0xc,%edx
  802ff2:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802ff9:	ef 
  802ffa:	0f b7 c0             	movzwl %ax,%eax
}
  802ffd:	5d                   	pop    %ebp
  802ffe:	c3                   	ret    
  802fff:	90                   	nop

00803000 <__udivdi3>:
  803000:	55                   	push   %ebp
  803001:	57                   	push   %edi
  803002:	56                   	push   %esi
  803003:	53                   	push   %ebx
  803004:	83 ec 1c             	sub    $0x1c,%esp
  803007:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80300b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80300f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  803013:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803017:	85 f6                	test   %esi,%esi
  803019:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80301d:	89 ca                	mov    %ecx,%edx
  80301f:	89 f8                	mov    %edi,%eax
  803021:	75 3d                	jne    803060 <__udivdi3+0x60>
  803023:	39 cf                	cmp    %ecx,%edi
  803025:	0f 87 c5 00 00 00    	ja     8030f0 <__udivdi3+0xf0>
  80302b:	85 ff                	test   %edi,%edi
  80302d:	89 fd                	mov    %edi,%ebp
  80302f:	75 0b                	jne    80303c <__udivdi3+0x3c>
  803031:	b8 01 00 00 00       	mov    $0x1,%eax
  803036:	31 d2                	xor    %edx,%edx
  803038:	f7 f7                	div    %edi
  80303a:	89 c5                	mov    %eax,%ebp
  80303c:	89 c8                	mov    %ecx,%eax
  80303e:	31 d2                	xor    %edx,%edx
  803040:	f7 f5                	div    %ebp
  803042:	89 c1                	mov    %eax,%ecx
  803044:	89 d8                	mov    %ebx,%eax
  803046:	89 cf                	mov    %ecx,%edi
  803048:	f7 f5                	div    %ebp
  80304a:	89 c3                	mov    %eax,%ebx
  80304c:	89 d8                	mov    %ebx,%eax
  80304e:	89 fa                	mov    %edi,%edx
  803050:	83 c4 1c             	add    $0x1c,%esp
  803053:	5b                   	pop    %ebx
  803054:	5e                   	pop    %esi
  803055:	5f                   	pop    %edi
  803056:	5d                   	pop    %ebp
  803057:	c3                   	ret    
  803058:	90                   	nop
  803059:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803060:	39 ce                	cmp    %ecx,%esi
  803062:	77 74                	ja     8030d8 <__udivdi3+0xd8>
  803064:	0f bd fe             	bsr    %esi,%edi
  803067:	83 f7 1f             	xor    $0x1f,%edi
  80306a:	0f 84 98 00 00 00    	je     803108 <__udivdi3+0x108>
  803070:	bb 20 00 00 00       	mov    $0x20,%ebx
  803075:	89 f9                	mov    %edi,%ecx
  803077:	89 c5                	mov    %eax,%ebp
  803079:	29 fb                	sub    %edi,%ebx
  80307b:	d3 e6                	shl    %cl,%esi
  80307d:	89 d9                	mov    %ebx,%ecx
  80307f:	d3 ed                	shr    %cl,%ebp
  803081:	89 f9                	mov    %edi,%ecx
  803083:	d3 e0                	shl    %cl,%eax
  803085:	09 ee                	or     %ebp,%esi
  803087:	89 d9                	mov    %ebx,%ecx
  803089:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80308d:	89 d5                	mov    %edx,%ebp
  80308f:	8b 44 24 08          	mov    0x8(%esp),%eax
  803093:	d3 ed                	shr    %cl,%ebp
  803095:	89 f9                	mov    %edi,%ecx
  803097:	d3 e2                	shl    %cl,%edx
  803099:	89 d9                	mov    %ebx,%ecx
  80309b:	d3 e8                	shr    %cl,%eax
  80309d:	09 c2                	or     %eax,%edx
  80309f:	89 d0                	mov    %edx,%eax
  8030a1:	89 ea                	mov    %ebp,%edx
  8030a3:	f7 f6                	div    %esi
  8030a5:	89 d5                	mov    %edx,%ebp
  8030a7:	89 c3                	mov    %eax,%ebx
  8030a9:	f7 64 24 0c          	mull   0xc(%esp)
  8030ad:	39 d5                	cmp    %edx,%ebp
  8030af:	72 10                	jb     8030c1 <__udivdi3+0xc1>
  8030b1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8030b5:	89 f9                	mov    %edi,%ecx
  8030b7:	d3 e6                	shl    %cl,%esi
  8030b9:	39 c6                	cmp    %eax,%esi
  8030bb:	73 07                	jae    8030c4 <__udivdi3+0xc4>
  8030bd:	39 d5                	cmp    %edx,%ebp
  8030bf:	75 03                	jne    8030c4 <__udivdi3+0xc4>
  8030c1:	83 eb 01             	sub    $0x1,%ebx
  8030c4:	31 ff                	xor    %edi,%edi
  8030c6:	89 d8                	mov    %ebx,%eax
  8030c8:	89 fa                	mov    %edi,%edx
  8030ca:	83 c4 1c             	add    $0x1c,%esp
  8030cd:	5b                   	pop    %ebx
  8030ce:	5e                   	pop    %esi
  8030cf:	5f                   	pop    %edi
  8030d0:	5d                   	pop    %ebp
  8030d1:	c3                   	ret    
  8030d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8030d8:	31 ff                	xor    %edi,%edi
  8030da:	31 db                	xor    %ebx,%ebx
  8030dc:	89 d8                	mov    %ebx,%eax
  8030de:	89 fa                	mov    %edi,%edx
  8030e0:	83 c4 1c             	add    $0x1c,%esp
  8030e3:	5b                   	pop    %ebx
  8030e4:	5e                   	pop    %esi
  8030e5:	5f                   	pop    %edi
  8030e6:	5d                   	pop    %ebp
  8030e7:	c3                   	ret    
  8030e8:	90                   	nop
  8030e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8030f0:	89 d8                	mov    %ebx,%eax
  8030f2:	f7 f7                	div    %edi
  8030f4:	31 ff                	xor    %edi,%edi
  8030f6:	89 c3                	mov    %eax,%ebx
  8030f8:	89 d8                	mov    %ebx,%eax
  8030fa:	89 fa                	mov    %edi,%edx
  8030fc:	83 c4 1c             	add    $0x1c,%esp
  8030ff:	5b                   	pop    %ebx
  803100:	5e                   	pop    %esi
  803101:	5f                   	pop    %edi
  803102:	5d                   	pop    %ebp
  803103:	c3                   	ret    
  803104:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803108:	39 ce                	cmp    %ecx,%esi
  80310a:	72 0c                	jb     803118 <__udivdi3+0x118>
  80310c:	31 db                	xor    %ebx,%ebx
  80310e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  803112:	0f 87 34 ff ff ff    	ja     80304c <__udivdi3+0x4c>
  803118:	bb 01 00 00 00       	mov    $0x1,%ebx
  80311d:	e9 2a ff ff ff       	jmp    80304c <__udivdi3+0x4c>
  803122:	66 90                	xchg   %ax,%ax
  803124:	66 90                	xchg   %ax,%ax
  803126:	66 90                	xchg   %ax,%ax
  803128:	66 90                	xchg   %ax,%ax
  80312a:	66 90                	xchg   %ax,%ax
  80312c:	66 90                	xchg   %ax,%ax
  80312e:	66 90                	xchg   %ax,%ax

00803130 <__umoddi3>:
  803130:	55                   	push   %ebp
  803131:	57                   	push   %edi
  803132:	56                   	push   %esi
  803133:	53                   	push   %ebx
  803134:	83 ec 1c             	sub    $0x1c,%esp
  803137:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80313b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80313f:	8b 74 24 34          	mov    0x34(%esp),%esi
  803143:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803147:	85 d2                	test   %edx,%edx
  803149:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80314d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803151:	89 f3                	mov    %esi,%ebx
  803153:	89 3c 24             	mov    %edi,(%esp)
  803156:	89 74 24 04          	mov    %esi,0x4(%esp)
  80315a:	75 1c                	jne    803178 <__umoddi3+0x48>
  80315c:	39 f7                	cmp    %esi,%edi
  80315e:	76 50                	jbe    8031b0 <__umoddi3+0x80>
  803160:	89 c8                	mov    %ecx,%eax
  803162:	89 f2                	mov    %esi,%edx
  803164:	f7 f7                	div    %edi
  803166:	89 d0                	mov    %edx,%eax
  803168:	31 d2                	xor    %edx,%edx
  80316a:	83 c4 1c             	add    $0x1c,%esp
  80316d:	5b                   	pop    %ebx
  80316e:	5e                   	pop    %esi
  80316f:	5f                   	pop    %edi
  803170:	5d                   	pop    %ebp
  803171:	c3                   	ret    
  803172:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803178:	39 f2                	cmp    %esi,%edx
  80317a:	89 d0                	mov    %edx,%eax
  80317c:	77 52                	ja     8031d0 <__umoddi3+0xa0>
  80317e:	0f bd ea             	bsr    %edx,%ebp
  803181:	83 f5 1f             	xor    $0x1f,%ebp
  803184:	75 5a                	jne    8031e0 <__umoddi3+0xb0>
  803186:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80318a:	0f 82 e0 00 00 00    	jb     803270 <__umoddi3+0x140>
  803190:	39 0c 24             	cmp    %ecx,(%esp)
  803193:	0f 86 d7 00 00 00    	jbe    803270 <__umoddi3+0x140>
  803199:	8b 44 24 08          	mov    0x8(%esp),%eax
  80319d:	8b 54 24 04          	mov    0x4(%esp),%edx
  8031a1:	83 c4 1c             	add    $0x1c,%esp
  8031a4:	5b                   	pop    %ebx
  8031a5:	5e                   	pop    %esi
  8031a6:	5f                   	pop    %edi
  8031a7:	5d                   	pop    %ebp
  8031a8:	c3                   	ret    
  8031a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8031b0:	85 ff                	test   %edi,%edi
  8031b2:	89 fd                	mov    %edi,%ebp
  8031b4:	75 0b                	jne    8031c1 <__umoddi3+0x91>
  8031b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8031bb:	31 d2                	xor    %edx,%edx
  8031bd:	f7 f7                	div    %edi
  8031bf:	89 c5                	mov    %eax,%ebp
  8031c1:	89 f0                	mov    %esi,%eax
  8031c3:	31 d2                	xor    %edx,%edx
  8031c5:	f7 f5                	div    %ebp
  8031c7:	89 c8                	mov    %ecx,%eax
  8031c9:	f7 f5                	div    %ebp
  8031cb:	89 d0                	mov    %edx,%eax
  8031cd:	eb 99                	jmp    803168 <__umoddi3+0x38>
  8031cf:	90                   	nop
  8031d0:	89 c8                	mov    %ecx,%eax
  8031d2:	89 f2                	mov    %esi,%edx
  8031d4:	83 c4 1c             	add    $0x1c,%esp
  8031d7:	5b                   	pop    %ebx
  8031d8:	5e                   	pop    %esi
  8031d9:	5f                   	pop    %edi
  8031da:	5d                   	pop    %ebp
  8031db:	c3                   	ret    
  8031dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8031e0:	8b 34 24             	mov    (%esp),%esi
  8031e3:	bf 20 00 00 00       	mov    $0x20,%edi
  8031e8:	89 e9                	mov    %ebp,%ecx
  8031ea:	29 ef                	sub    %ebp,%edi
  8031ec:	d3 e0                	shl    %cl,%eax
  8031ee:	89 f9                	mov    %edi,%ecx
  8031f0:	89 f2                	mov    %esi,%edx
  8031f2:	d3 ea                	shr    %cl,%edx
  8031f4:	89 e9                	mov    %ebp,%ecx
  8031f6:	09 c2                	or     %eax,%edx
  8031f8:	89 d8                	mov    %ebx,%eax
  8031fa:	89 14 24             	mov    %edx,(%esp)
  8031fd:	89 f2                	mov    %esi,%edx
  8031ff:	d3 e2                	shl    %cl,%edx
  803201:	89 f9                	mov    %edi,%ecx
  803203:	89 54 24 04          	mov    %edx,0x4(%esp)
  803207:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80320b:	d3 e8                	shr    %cl,%eax
  80320d:	89 e9                	mov    %ebp,%ecx
  80320f:	89 c6                	mov    %eax,%esi
  803211:	d3 e3                	shl    %cl,%ebx
  803213:	89 f9                	mov    %edi,%ecx
  803215:	89 d0                	mov    %edx,%eax
  803217:	d3 e8                	shr    %cl,%eax
  803219:	89 e9                	mov    %ebp,%ecx
  80321b:	09 d8                	or     %ebx,%eax
  80321d:	89 d3                	mov    %edx,%ebx
  80321f:	89 f2                	mov    %esi,%edx
  803221:	f7 34 24             	divl   (%esp)
  803224:	89 d6                	mov    %edx,%esi
  803226:	d3 e3                	shl    %cl,%ebx
  803228:	f7 64 24 04          	mull   0x4(%esp)
  80322c:	39 d6                	cmp    %edx,%esi
  80322e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803232:	89 d1                	mov    %edx,%ecx
  803234:	89 c3                	mov    %eax,%ebx
  803236:	72 08                	jb     803240 <__umoddi3+0x110>
  803238:	75 11                	jne    80324b <__umoddi3+0x11b>
  80323a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80323e:	73 0b                	jae    80324b <__umoddi3+0x11b>
  803240:	2b 44 24 04          	sub    0x4(%esp),%eax
  803244:	1b 14 24             	sbb    (%esp),%edx
  803247:	89 d1                	mov    %edx,%ecx
  803249:	89 c3                	mov    %eax,%ebx
  80324b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80324f:	29 da                	sub    %ebx,%edx
  803251:	19 ce                	sbb    %ecx,%esi
  803253:	89 f9                	mov    %edi,%ecx
  803255:	89 f0                	mov    %esi,%eax
  803257:	d3 e0                	shl    %cl,%eax
  803259:	89 e9                	mov    %ebp,%ecx
  80325b:	d3 ea                	shr    %cl,%edx
  80325d:	89 e9                	mov    %ebp,%ecx
  80325f:	d3 ee                	shr    %cl,%esi
  803261:	09 d0                	or     %edx,%eax
  803263:	89 f2                	mov    %esi,%edx
  803265:	83 c4 1c             	add    $0x1c,%esp
  803268:	5b                   	pop    %ebx
  803269:	5e                   	pop    %esi
  80326a:	5f                   	pop    %edi
  80326b:	5d                   	pop    %ebp
  80326c:	c3                   	ret    
  80326d:	8d 76 00             	lea    0x0(%esi),%esi
  803270:	29 f9                	sub    %edi,%ecx
  803272:	19 d6                	sbb    %edx,%esi
  803274:	89 74 24 04          	mov    %esi,0x4(%esp)
  803278:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80327c:	e9 18 ff ff ff       	jmp    803199 <__umoddi3+0x69>
