
obj/user/init.debug:     file format elf32-i386


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
  80002c:	e8 6e 03 00 00       	call   80039f <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <sum>:

char bss[6000];

int
sum(const char *s, int n)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 75 08             	mov    0x8(%ebp),%esi
  80003b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i, tot = 0;
  80003e:	b8 00 00 00 00       	mov    $0x0,%eax
	for (i = 0; i < n; i++)
  800043:	ba 00 00 00 00       	mov    $0x0,%edx
  800048:	eb 0c                	jmp    800056 <sum+0x23>
		tot ^= i * s[i];
  80004a:	0f be 0c 16          	movsbl (%esi,%edx,1),%ecx
  80004e:	0f af ca             	imul   %edx,%ecx
  800051:	31 c8                	xor    %ecx,%eax

int
sum(const char *s, int n)
{
	int i, tot = 0;
	for (i = 0; i < n; i++)
  800053:	83 c2 01             	add    $0x1,%edx
  800056:	39 da                	cmp    %ebx,%edx
  800058:	7c f0                	jl     80004a <sum+0x17>
		tot ^= i * s[i];
	return tot;
}
  80005a:	5b                   	pop    %ebx
  80005b:	5e                   	pop    %esi
  80005c:	5d                   	pop    %ebp
  80005d:	c3                   	ret    

0080005e <umain>:

void
umain(int argc, char **argv)
{
  80005e:	55                   	push   %ebp
  80005f:	89 e5                	mov    %esp,%ebp
  800061:	57                   	push   %edi
  800062:	56                   	push   %esi
  800063:	53                   	push   %ebx
  800064:	81 ec 18 01 00 00    	sub    $0x118,%esp
  80006a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int i, r, x, want;
	char args[256];

	cprintf("init: running\n");
  80006d:	68 a0 25 80 00       	push   $0x8025a0
  800072:	e8 61 04 00 00       	call   8004d8 <cprintf>

	want = 0xf989e;
	if ((x = sum((char*)&data, sizeof data)) != want)
  800077:	83 c4 08             	add    $0x8,%esp
  80007a:	68 70 17 00 00       	push   $0x1770
  80007f:	68 00 30 80 00       	push   $0x803000
  800084:	e8 aa ff ff ff       	call   800033 <sum>
  800089:	83 c4 10             	add    $0x10,%esp
  80008c:	3d 9e 98 0f 00       	cmp    $0xf989e,%eax
  800091:	74 18                	je     8000ab <umain+0x4d>
		cprintf("init: data is not initialized: got sum %08x wanted %08x\n",
  800093:	83 ec 04             	sub    $0x4,%esp
  800096:	68 9e 98 0f 00       	push   $0xf989e
  80009b:	50                   	push   %eax
  80009c:	68 68 26 80 00       	push   $0x802668
  8000a1:	e8 32 04 00 00       	call   8004d8 <cprintf>
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	eb 10                	jmp    8000bb <umain+0x5d>
			x, want);
	else
		cprintf("init: data seems okay\n");
  8000ab:	83 ec 0c             	sub    $0xc,%esp
  8000ae:	68 af 25 80 00       	push   $0x8025af
  8000b3:	e8 20 04 00 00       	call   8004d8 <cprintf>
  8000b8:	83 c4 10             	add    $0x10,%esp
	if ((x = sum(bss, sizeof bss)) != 0)
  8000bb:	83 ec 08             	sub    $0x8,%esp
  8000be:	68 70 17 00 00       	push   $0x1770
  8000c3:	68 20 50 80 00       	push   $0x805020
  8000c8:	e8 66 ff ff ff       	call   800033 <sum>
  8000cd:	83 c4 10             	add    $0x10,%esp
  8000d0:	85 c0                	test   %eax,%eax
  8000d2:	74 13                	je     8000e7 <umain+0x89>
		cprintf("bss is not initialized: wanted sum 0 got %08x\n", x);
  8000d4:	83 ec 08             	sub    $0x8,%esp
  8000d7:	50                   	push   %eax
  8000d8:	68 a4 26 80 00       	push   $0x8026a4
  8000dd:	e8 f6 03 00 00       	call   8004d8 <cprintf>
  8000e2:	83 c4 10             	add    $0x10,%esp
  8000e5:	eb 10                	jmp    8000f7 <umain+0x99>
	else
		cprintf("init: bss seems okay\n");
  8000e7:	83 ec 0c             	sub    $0xc,%esp
  8000ea:	68 c6 25 80 00       	push   $0x8025c6
  8000ef:	e8 e4 03 00 00       	call   8004d8 <cprintf>
  8000f4:	83 c4 10             	add    $0x10,%esp

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
  8000f7:	83 ec 08             	sub    $0x8,%esp
  8000fa:	68 dc 25 80 00       	push   $0x8025dc
  8000ff:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  800105:	50                   	push   %eax
  800106:	e8 90 09 00 00       	call   800a9b <strcat>
	for (i = 0; i < argc; i++) {
  80010b:	83 c4 10             	add    $0x10,%esp
  80010e:	bb 00 00 00 00       	mov    $0x0,%ebx
		strcat(args, " '");
  800113:	8d b5 e8 fe ff ff    	lea    -0x118(%ebp),%esi
	else
		cprintf("init: bss seems okay\n");

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
	for (i = 0; i < argc; i++) {
  800119:	eb 2e                	jmp    800149 <umain+0xeb>
		strcat(args, " '");
  80011b:	83 ec 08             	sub    $0x8,%esp
  80011e:	68 e8 25 80 00       	push   $0x8025e8
  800123:	56                   	push   %esi
  800124:	e8 72 09 00 00       	call   800a9b <strcat>
		strcat(args, argv[i]);
  800129:	83 c4 08             	add    $0x8,%esp
  80012c:	ff 34 9f             	pushl  (%edi,%ebx,4)
  80012f:	56                   	push   %esi
  800130:	e8 66 09 00 00       	call   800a9b <strcat>
		strcat(args, "'");
  800135:	83 c4 08             	add    $0x8,%esp
  800138:	68 e9 25 80 00       	push   $0x8025e9
  80013d:	56                   	push   %esi
  80013e:	e8 58 09 00 00       	call   800a9b <strcat>
	else
		cprintf("init: bss seems okay\n");

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
	for (i = 0; i < argc; i++) {
  800143:	83 c3 01             	add    $0x1,%ebx
  800146:	83 c4 10             	add    $0x10,%esp
  800149:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  80014c:	7c cd                	jl     80011b <umain+0xbd>
		strcat(args, " '");
		strcat(args, argv[i]);
		strcat(args, "'");
	}
	cprintf("%s\n", args);
  80014e:	83 ec 08             	sub    $0x8,%esp
  800151:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  800157:	50                   	push   %eax
  800158:	68 eb 25 80 00       	push   $0x8025eb
  80015d:	e8 76 03 00 00       	call   8004d8 <cprintf>

	cprintf("init: running sh\n");
  800162:	c7 04 24 ef 25 80 00 	movl   $0x8025ef,(%esp)
  800169:	e8 6a 03 00 00       	call   8004d8 <cprintf>

	// being run directly from kernel, so no file descriptors open yet
	close(0);
  80016e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800175:	e8 95 10 00 00       	call   80120f <close>
	if ((r = opencons()) < 0)
  80017a:	e8 c6 01 00 00       	call   800345 <opencons>
  80017f:	83 c4 10             	add    $0x10,%esp
  800182:	85 c0                	test   %eax,%eax
  800184:	79 12                	jns    800198 <umain+0x13a>
		panic("opencons: %e", r);
  800186:	50                   	push   %eax
  800187:	68 01 26 80 00       	push   $0x802601
  80018c:	6a 37                	push   $0x37
  80018e:	68 0e 26 80 00       	push   $0x80260e
  800193:	e8 67 02 00 00       	call   8003ff <_panic>
	if (r != 0)
  800198:	85 c0                	test   %eax,%eax
  80019a:	74 12                	je     8001ae <umain+0x150>
		panic("first opencons used fd %d", r);
  80019c:	50                   	push   %eax
  80019d:	68 1a 26 80 00       	push   $0x80261a
  8001a2:	6a 39                	push   $0x39
  8001a4:	68 0e 26 80 00       	push   $0x80260e
  8001a9:	e8 51 02 00 00       	call   8003ff <_panic>
	if ((r = dup(0, 1)) < 0)
  8001ae:	83 ec 08             	sub    $0x8,%esp
  8001b1:	6a 01                	push   $0x1
  8001b3:	6a 00                	push   $0x0
  8001b5:	e8 a5 10 00 00       	call   80125f <dup>
  8001ba:	83 c4 10             	add    $0x10,%esp
  8001bd:	85 c0                	test   %eax,%eax
  8001bf:	79 12                	jns    8001d3 <umain+0x175>
		panic("dup: %e", r);
  8001c1:	50                   	push   %eax
  8001c2:	68 34 26 80 00       	push   $0x802634
  8001c7:	6a 3b                	push   $0x3b
  8001c9:	68 0e 26 80 00       	push   $0x80260e
  8001ce:	e8 2c 02 00 00       	call   8003ff <_panic>
	while (1) {
		cprintf("init: starting sh\n");
  8001d3:	83 ec 0c             	sub    $0xc,%esp
  8001d6:	68 3c 26 80 00       	push   $0x80263c
  8001db:	e8 f8 02 00 00       	call   8004d8 <cprintf>
		r = spawnl("/sh", "sh", (char*)0);
  8001e0:	83 c4 0c             	add    $0xc,%esp
  8001e3:	6a 00                	push   $0x0
  8001e5:	68 50 26 80 00       	push   $0x802650
  8001ea:	68 4f 26 80 00       	push   $0x80264f
  8001ef:	e8 c7 1b 00 00       	call   801dbb <spawnl>
		if (r < 0) {
  8001f4:	83 c4 10             	add    $0x10,%esp
  8001f7:	85 c0                	test   %eax,%eax
  8001f9:	79 13                	jns    80020e <umain+0x1b0>
			cprintf("init: spawn sh: %e\n", r);
  8001fb:	83 ec 08             	sub    $0x8,%esp
  8001fe:	50                   	push   %eax
  8001ff:	68 53 26 80 00       	push   $0x802653
  800204:	e8 cf 02 00 00       	call   8004d8 <cprintf>
			continue;
  800209:	83 c4 10             	add    $0x10,%esp
  80020c:	eb c5                	jmp    8001d3 <umain+0x175>
		}
		wait(r);
  80020e:	83 ec 0c             	sub    $0xc,%esp
  800211:	50                   	push   %eax
  800212:	e8 73 1f 00 00       	call   80218a <wait>
  800217:	83 c4 10             	add    $0x10,%esp
  80021a:	eb b7                	jmp    8001d3 <umain+0x175>

0080021c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80021f:	b8 00 00 00 00       	mov    $0x0,%eax
  800224:	5d                   	pop    %ebp
  800225:	c3                   	ret    

00800226 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800226:	55                   	push   %ebp
  800227:	89 e5                	mov    %esp,%ebp
  800229:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80022c:	68 d3 26 80 00       	push   $0x8026d3
  800231:	ff 75 0c             	pushl  0xc(%ebp)
  800234:	e8 42 08 00 00       	call   800a7b <strcpy>
	return 0;
}
  800239:	b8 00 00 00 00       	mov    $0x0,%eax
  80023e:	c9                   	leave  
  80023f:	c3                   	ret    

00800240 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800240:	55                   	push   %ebp
  800241:	89 e5                	mov    %esp,%ebp
  800243:	57                   	push   %edi
  800244:	56                   	push   %esi
  800245:	53                   	push   %ebx
  800246:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80024c:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800251:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800257:	eb 2d                	jmp    800286 <devcons_write+0x46>
		m = n - tot;
  800259:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80025c:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80025e:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800261:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800266:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800269:	83 ec 04             	sub    $0x4,%esp
  80026c:	53                   	push   %ebx
  80026d:	03 45 0c             	add    0xc(%ebp),%eax
  800270:	50                   	push   %eax
  800271:	57                   	push   %edi
  800272:	e8 96 09 00 00       	call   800c0d <memmove>
		sys_cputs(buf, m);
  800277:	83 c4 08             	add    $0x8,%esp
  80027a:	53                   	push   %ebx
  80027b:	57                   	push   %edi
  80027c:	e8 41 0b 00 00       	call   800dc2 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800281:	01 de                	add    %ebx,%esi
  800283:	83 c4 10             	add    $0x10,%esp
  800286:	89 f0                	mov    %esi,%eax
  800288:	3b 75 10             	cmp    0x10(%ebp),%esi
  80028b:	72 cc                	jb     800259 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80028d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800290:	5b                   	pop    %ebx
  800291:	5e                   	pop    %esi
  800292:	5f                   	pop    %edi
  800293:	5d                   	pop    %ebp
  800294:	c3                   	ret    

00800295 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800295:	55                   	push   %ebp
  800296:	89 e5                	mov    %esp,%ebp
  800298:	83 ec 08             	sub    $0x8,%esp
  80029b:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8002a0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8002a4:	74 2a                	je     8002d0 <devcons_read+0x3b>
  8002a6:	eb 05                	jmp    8002ad <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8002a8:	e8 b2 0b 00 00       	call   800e5f <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8002ad:	e8 2e 0b 00 00       	call   800de0 <sys_cgetc>
  8002b2:	85 c0                	test   %eax,%eax
  8002b4:	74 f2                	je     8002a8 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8002b6:	85 c0                	test   %eax,%eax
  8002b8:	78 16                	js     8002d0 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8002ba:	83 f8 04             	cmp    $0x4,%eax
  8002bd:	74 0c                	je     8002cb <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8002bf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002c2:	88 02                	mov    %al,(%edx)
	return 1;
  8002c4:	b8 01 00 00 00       	mov    $0x1,%eax
  8002c9:	eb 05                	jmp    8002d0 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8002cb:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8002d0:	c9                   	leave  
  8002d1:	c3                   	ret    

008002d2 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8002d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8002db:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8002de:	6a 01                	push   $0x1
  8002e0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8002e3:	50                   	push   %eax
  8002e4:	e8 d9 0a 00 00       	call   800dc2 <sys_cputs>
}
  8002e9:	83 c4 10             	add    $0x10,%esp
  8002ec:	c9                   	leave  
  8002ed:	c3                   	ret    

008002ee <getchar>:

int
getchar(void)
{
  8002ee:	55                   	push   %ebp
  8002ef:	89 e5                	mov    %esp,%ebp
  8002f1:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8002f4:	6a 01                	push   $0x1
  8002f6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8002f9:	50                   	push   %eax
  8002fa:	6a 00                	push   $0x0
  8002fc:	e8 4a 10 00 00       	call   80134b <read>
	if (r < 0)
  800301:	83 c4 10             	add    $0x10,%esp
  800304:	85 c0                	test   %eax,%eax
  800306:	78 0f                	js     800317 <getchar+0x29>
		return r;
	if (r < 1)
  800308:	85 c0                	test   %eax,%eax
  80030a:	7e 06                	jle    800312 <getchar+0x24>
		return -E_EOF;
	return c;
  80030c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800310:	eb 05                	jmp    800317 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800312:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800317:	c9                   	leave  
  800318:	c3                   	ret    

00800319 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800319:	55                   	push   %ebp
  80031a:	89 e5                	mov    %esp,%ebp
  80031c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80031f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800322:	50                   	push   %eax
  800323:	ff 75 08             	pushl  0x8(%ebp)
  800326:	e8 ba 0d 00 00       	call   8010e5 <fd_lookup>
  80032b:	83 c4 10             	add    $0x10,%esp
  80032e:	85 c0                	test   %eax,%eax
  800330:	78 11                	js     800343 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800332:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800335:	8b 15 70 47 80 00    	mov    0x804770,%edx
  80033b:	39 10                	cmp    %edx,(%eax)
  80033d:	0f 94 c0             	sete   %al
  800340:	0f b6 c0             	movzbl %al,%eax
}
  800343:	c9                   	leave  
  800344:	c3                   	ret    

00800345 <opencons>:

int
opencons(void)
{
  800345:	55                   	push   %ebp
  800346:	89 e5                	mov    %esp,%ebp
  800348:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80034b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80034e:	50                   	push   %eax
  80034f:	e8 42 0d 00 00       	call   801096 <fd_alloc>
  800354:	83 c4 10             	add    $0x10,%esp
		return r;
  800357:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800359:	85 c0                	test   %eax,%eax
  80035b:	78 3e                	js     80039b <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80035d:	83 ec 04             	sub    $0x4,%esp
  800360:	68 07 04 00 00       	push   $0x407
  800365:	ff 75 f4             	pushl  -0xc(%ebp)
  800368:	6a 00                	push   $0x0
  80036a:	e8 0f 0b 00 00       	call   800e7e <sys_page_alloc>
  80036f:	83 c4 10             	add    $0x10,%esp
		return r;
  800372:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800374:	85 c0                	test   %eax,%eax
  800376:	78 23                	js     80039b <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800378:	8b 15 70 47 80 00    	mov    0x804770,%edx
  80037e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800381:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800383:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800386:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80038d:	83 ec 0c             	sub    $0xc,%esp
  800390:	50                   	push   %eax
  800391:	e8 d9 0c 00 00       	call   80106f <fd2num>
  800396:	89 c2                	mov    %eax,%edx
  800398:	83 c4 10             	add    $0x10,%esp
}
  80039b:	89 d0                	mov    %edx,%eax
  80039d:	c9                   	leave  
  80039e:	c3                   	ret    

0080039f <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80039f:	55                   	push   %ebp
  8003a0:	89 e5                	mov    %esp,%ebp
  8003a2:	56                   	push   %esi
  8003a3:	53                   	push   %ebx
  8003a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8003a7:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  8003aa:	e8 91 0a 00 00       	call   800e40 <sys_getenvid>
  8003af:	25 ff 03 00 00       	and    $0x3ff,%eax
  8003b4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8003b7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8003bc:	a3 90 67 80 00       	mov    %eax,0x806790
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8003c1:	85 db                	test   %ebx,%ebx
  8003c3:	7e 07                	jle    8003cc <libmain+0x2d>
		binaryname = argv[0];
  8003c5:	8b 06                	mov    (%esi),%eax
  8003c7:	a3 8c 47 80 00       	mov    %eax,0x80478c

	// call user main routine
	umain(argc, argv);
  8003cc:	83 ec 08             	sub    $0x8,%esp
  8003cf:	56                   	push   %esi
  8003d0:	53                   	push   %ebx
  8003d1:	e8 88 fc ff ff       	call   80005e <umain>

	// exit gracefully
	exit();
  8003d6:	e8 0a 00 00 00       	call   8003e5 <exit>
}
  8003db:	83 c4 10             	add    $0x10,%esp
  8003de:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8003e1:	5b                   	pop    %ebx
  8003e2:	5e                   	pop    %esi
  8003e3:	5d                   	pop    %ebp
  8003e4:	c3                   	ret    

008003e5 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8003e5:	55                   	push   %ebp
  8003e6:	89 e5                	mov    %esp,%ebp
  8003e8:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8003eb:	e8 4a 0e 00 00       	call   80123a <close_all>
	sys_env_destroy(0);
  8003f0:	83 ec 0c             	sub    $0xc,%esp
  8003f3:	6a 00                	push   $0x0
  8003f5:	e8 05 0a 00 00       	call   800dff <sys_env_destroy>
}
  8003fa:	83 c4 10             	add    $0x10,%esp
  8003fd:	c9                   	leave  
  8003fe:	c3                   	ret    

008003ff <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8003ff:	55                   	push   %ebp
  800400:	89 e5                	mov    %esp,%ebp
  800402:	56                   	push   %esi
  800403:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800404:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800407:	8b 35 8c 47 80 00    	mov    0x80478c,%esi
  80040d:	e8 2e 0a 00 00       	call   800e40 <sys_getenvid>
  800412:	83 ec 0c             	sub    $0xc,%esp
  800415:	ff 75 0c             	pushl  0xc(%ebp)
  800418:	ff 75 08             	pushl  0x8(%ebp)
  80041b:	56                   	push   %esi
  80041c:	50                   	push   %eax
  80041d:	68 ec 26 80 00       	push   $0x8026ec
  800422:	e8 b1 00 00 00       	call   8004d8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800427:	83 c4 18             	add    $0x18,%esp
  80042a:	53                   	push   %ebx
  80042b:	ff 75 10             	pushl  0x10(%ebp)
  80042e:	e8 54 00 00 00       	call   800487 <vcprintf>
	cprintf("\n");
  800433:	c7 04 24 c0 2b 80 00 	movl   $0x802bc0,(%esp)
  80043a:	e8 99 00 00 00       	call   8004d8 <cprintf>
  80043f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800442:	cc                   	int3   
  800443:	eb fd                	jmp    800442 <_panic+0x43>

00800445 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800445:	55                   	push   %ebp
  800446:	89 e5                	mov    %esp,%ebp
  800448:	53                   	push   %ebx
  800449:	83 ec 04             	sub    $0x4,%esp
  80044c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80044f:	8b 13                	mov    (%ebx),%edx
  800451:	8d 42 01             	lea    0x1(%edx),%eax
  800454:	89 03                	mov    %eax,(%ebx)
  800456:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800459:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80045d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800462:	75 1a                	jne    80047e <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800464:	83 ec 08             	sub    $0x8,%esp
  800467:	68 ff 00 00 00       	push   $0xff
  80046c:	8d 43 08             	lea    0x8(%ebx),%eax
  80046f:	50                   	push   %eax
  800470:	e8 4d 09 00 00       	call   800dc2 <sys_cputs>
		b->idx = 0;
  800475:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80047b:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80047e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800482:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800485:	c9                   	leave  
  800486:	c3                   	ret    

00800487 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800487:	55                   	push   %ebp
  800488:	89 e5                	mov    %esp,%ebp
  80048a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800490:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800497:	00 00 00 
	b.cnt = 0;
  80049a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004a1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004a4:	ff 75 0c             	pushl  0xc(%ebp)
  8004a7:	ff 75 08             	pushl  0x8(%ebp)
  8004aa:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8004b0:	50                   	push   %eax
  8004b1:	68 45 04 80 00       	push   $0x800445
  8004b6:	e8 54 01 00 00       	call   80060f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8004bb:	83 c4 08             	add    $0x8,%esp
  8004be:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8004c4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8004ca:	50                   	push   %eax
  8004cb:	e8 f2 08 00 00       	call   800dc2 <sys_cputs>

	return b.cnt;
}
  8004d0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8004d6:	c9                   	leave  
  8004d7:	c3                   	ret    

008004d8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8004d8:	55                   	push   %ebp
  8004d9:	89 e5                	mov    %esp,%ebp
  8004db:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8004de:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8004e1:	50                   	push   %eax
  8004e2:	ff 75 08             	pushl  0x8(%ebp)
  8004e5:	e8 9d ff ff ff       	call   800487 <vcprintf>
	va_end(ap);

	return cnt;
}
  8004ea:	c9                   	leave  
  8004eb:	c3                   	ret    

008004ec <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004ec:	55                   	push   %ebp
  8004ed:	89 e5                	mov    %esp,%ebp
  8004ef:	57                   	push   %edi
  8004f0:	56                   	push   %esi
  8004f1:	53                   	push   %ebx
  8004f2:	83 ec 1c             	sub    $0x1c,%esp
  8004f5:	89 c7                	mov    %eax,%edi
  8004f7:	89 d6                	mov    %edx,%esi
  8004f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8004fc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004ff:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800502:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800505:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800508:	bb 00 00 00 00       	mov    $0x0,%ebx
  80050d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800510:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800513:	39 d3                	cmp    %edx,%ebx
  800515:	72 05                	jb     80051c <printnum+0x30>
  800517:	39 45 10             	cmp    %eax,0x10(%ebp)
  80051a:	77 45                	ja     800561 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80051c:	83 ec 0c             	sub    $0xc,%esp
  80051f:	ff 75 18             	pushl  0x18(%ebp)
  800522:	8b 45 14             	mov    0x14(%ebp),%eax
  800525:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800528:	53                   	push   %ebx
  800529:	ff 75 10             	pushl  0x10(%ebp)
  80052c:	83 ec 08             	sub    $0x8,%esp
  80052f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800532:	ff 75 e0             	pushl  -0x20(%ebp)
  800535:	ff 75 dc             	pushl  -0x24(%ebp)
  800538:	ff 75 d8             	pushl  -0x28(%ebp)
  80053b:	e8 c0 1d 00 00       	call   802300 <__udivdi3>
  800540:	83 c4 18             	add    $0x18,%esp
  800543:	52                   	push   %edx
  800544:	50                   	push   %eax
  800545:	89 f2                	mov    %esi,%edx
  800547:	89 f8                	mov    %edi,%eax
  800549:	e8 9e ff ff ff       	call   8004ec <printnum>
  80054e:	83 c4 20             	add    $0x20,%esp
  800551:	eb 18                	jmp    80056b <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800553:	83 ec 08             	sub    $0x8,%esp
  800556:	56                   	push   %esi
  800557:	ff 75 18             	pushl  0x18(%ebp)
  80055a:	ff d7                	call   *%edi
  80055c:	83 c4 10             	add    $0x10,%esp
  80055f:	eb 03                	jmp    800564 <printnum+0x78>
  800561:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800564:	83 eb 01             	sub    $0x1,%ebx
  800567:	85 db                	test   %ebx,%ebx
  800569:	7f e8                	jg     800553 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80056b:	83 ec 08             	sub    $0x8,%esp
  80056e:	56                   	push   %esi
  80056f:	83 ec 04             	sub    $0x4,%esp
  800572:	ff 75 e4             	pushl  -0x1c(%ebp)
  800575:	ff 75 e0             	pushl  -0x20(%ebp)
  800578:	ff 75 dc             	pushl  -0x24(%ebp)
  80057b:	ff 75 d8             	pushl  -0x28(%ebp)
  80057e:	e8 ad 1e 00 00       	call   802430 <__umoddi3>
  800583:	83 c4 14             	add    $0x14,%esp
  800586:	0f be 80 0f 27 80 00 	movsbl 0x80270f(%eax),%eax
  80058d:	50                   	push   %eax
  80058e:	ff d7                	call   *%edi
}
  800590:	83 c4 10             	add    $0x10,%esp
  800593:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800596:	5b                   	pop    %ebx
  800597:	5e                   	pop    %esi
  800598:	5f                   	pop    %edi
  800599:	5d                   	pop    %ebp
  80059a:	c3                   	ret    

0080059b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80059b:	55                   	push   %ebp
  80059c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80059e:	83 fa 01             	cmp    $0x1,%edx
  8005a1:	7e 0e                	jle    8005b1 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8005a3:	8b 10                	mov    (%eax),%edx
  8005a5:	8d 4a 08             	lea    0x8(%edx),%ecx
  8005a8:	89 08                	mov    %ecx,(%eax)
  8005aa:	8b 02                	mov    (%edx),%eax
  8005ac:	8b 52 04             	mov    0x4(%edx),%edx
  8005af:	eb 22                	jmp    8005d3 <getuint+0x38>
	else if (lflag)
  8005b1:	85 d2                	test   %edx,%edx
  8005b3:	74 10                	je     8005c5 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8005b5:	8b 10                	mov    (%eax),%edx
  8005b7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005ba:	89 08                	mov    %ecx,(%eax)
  8005bc:	8b 02                	mov    (%edx),%eax
  8005be:	ba 00 00 00 00       	mov    $0x0,%edx
  8005c3:	eb 0e                	jmp    8005d3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8005c5:	8b 10                	mov    (%eax),%edx
  8005c7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005ca:	89 08                	mov    %ecx,(%eax)
  8005cc:	8b 02                	mov    (%edx),%eax
  8005ce:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8005d3:	5d                   	pop    %ebp
  8005d4:	c3                   	ret    

008005d5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005d5:	55                   	push   %ebp
  8005d6:	89 e5                	mov    %esp,%ebp
  8005d8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005db:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8005df:	8b 10                	mov    (%eax),%edx
  8005e1:	3b 50 04             	cmp    0x4(%eax),%edx
  8005e4:	73 0a                	jae    8005f0 <sprintputch+0x1b>
		*b->buf++ = ch;
  8005e6:	8d 4a 01             	lea    0x1(%edx),%ecx
  8005e9:	89 08                	mov    %ecx,(%eax)
  8005eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ee:	88 02                	mov    %al,(%edx)
}
  8005f0:	5d                   	pop    %ebp
  8005f1:	c3                   	ret    

008005f2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8005f2:	55                   	push   %ebp
  8005f3:	89 e5                	mov    %esp,%ebp
  8005f5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8005f8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005fb:	50                   	push   %eax
  8005fc:	ff 75 10             	pushl  0x10(%ebp)
  8005ff:	ff 75 0c             	pushl  0xc(%ebp)
  800602:	ff 75 08             	pushl  0x8(%ebp)
  800605:	e8 05 00 00 00       	call   80060f <vprintfmt>
	va_end(ap);
}
  80060a:	83 c4 10             	add    $0x10,%esp
  80060d:	c9                   	leave  
  80060e:	c3                   	ret    

0080060f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80060f:	55                   	push   %ebp
  800610:	89 e5                	mov    %esp,%ebp
  800612:	57                   	push   %edi
  800613:	56                   	push   %esi
  800614:	53                   	push   %ebx
  800615:	83 ec 2c             	sub    $0x2c,%esp
  800618:	8b 75 08             	mov    0x8(%ebp),%esi
  80061b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80061e:	8b 7d 10             	mov    0x10(%ebp),%edi
  800621:	eb 12                	jmp    800635 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800623:	85 c0                	test   %eax,%eax
  800625:	0f 84 a7 03 00 00    	je     8009d2 <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
  80062b:	83 ec 08             	sub    $0x8,%esp
  80062e:	53                   	push   %ebx
  80062f:	50                   	push   %eax
  800630:	ff d6                	call   *%esi
  800632:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800635:	83 c7 01             	add    $0x1,%edi
  800638:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80063c:	83 f8 25             	cmp    $0x25,%eax
  80063f:	75 e2                	jne    800623 <vprintfmt+0x14>
  800641:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800645:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80064c:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800653:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80065a:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800661:	b9 00 00 00 00       	mov    $0x0,%ecx
  800666:	eb 07                	jmp    80066f <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800668:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80066b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066f:	8d 47 01             	lea    0x1(%edi),%eax
  800672:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800675:	0f b6 07             	movzbl (%edi),%eax
  800678:	0f b6 d0             	movzbl %al,%edx
  80067b:	83 e8 23             	sub    $0x23,%eax
  80067e:	3c 55                	cmp    $0x55,%al
  800680:	0f 87 31 03 00 00    	ja     8009b7 <vprintfmt+0x3a8>
  800686:	0f b6 c0             	movzbl %al,%eax
  800689:	ff 24 85 60 28 80 00 	jmp    *0x802860(,%eax,4)
  800690:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800693:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800697:	eb d6                	jmp    80066f <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800699:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80069c:	b8 00 00 00 00       	mov    $0x0,%eax
  8006a1:	89 75 08             	mov    %esi,0x8(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8006a4:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8006a7:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8006ab:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8006ae:	8d 72 d0             	lea    -0x30(%edx),%esi
  8006b1:	83 fe 09             	cmp    $0x9,%esi
  8006b4:	77 34                	ja     8006ea <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8006b6:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8006b9:	eb e9                	jmp    8006a4 <vprintfmt+0x95>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8006bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006be:	8d 50 04             	lea    0x4(%eax),%edx
  8006c1:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c4:	8b 00                	mov    (%eax),%eax
  8006c6:	89 45 cc             	mov    %eax,-0x34(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8006cc:	eb 22                	jmp    8006f0 <vprintfmt+0xe1>
  8006ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006d1:	85 c0                	test   %eax,%eax
  8006d3:	0f 48 c1             	cmovs  %ecx,%eax
  8006d6:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006dc:	eb 91                	jmp    80066f <vprintfmt+0x60>
  8006de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8006e1:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8006e8:	eb 85                	jmp    80066f <vprintfmt+0x60>
  8006ea:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8006ed:	8b 75 08             	mov    0x8(%ebp),%esi

		process_precision:
			if (width < 0)
  8006f0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006f4:	0f 89 75 ff ff ff    	jns    80066f <vprintfmt+0x60>
				width = precision, precision = -1;
  8006fa:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006fd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800700:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800707:	e9 63 ff ff ff       	jmp    80066f <vprintfmt+0x60>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80070c:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800710:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800713:	e9 57 ff ff ff       	jmp    80066f <vprintfmt+0x60>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800718:	8b 45 14             	mov    0x14(%ebp),%eax
  80071b:	8d 50 04             	lea    0x4(%eax),%edx
  80071e:	89 55 14             	mov    %edx,0x14(%ebp)
  800721:	83 ec 08             	sub    $0x8,%esp
  800724:	53                   	push   %ebx
  800725:	ff 30                	pushl  (%eax)
  800727:	ff d6                	call   *%esi
			break;
  800729:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80072c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80072f:	e9 01 ff ff ff       	jmp    800635 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800734:	8b 45 14             	mov    0x14(%ebp),%eax
  800737:	8d 50 04             	lea    0x4(%eax),%edx
  80073a:	89 55 14             	mov    %edx,0x14(%ebp)
  80073d:	8b 00                	mov    (%eax),%eax
  80073f:	99                   	cltd   
  800740:	31 d0                	xor    %edx,%eax
  800742:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800744:	83 f8 0f             	cmp    $0xf,%eax
  800747:	7f 0b                	jg     800754 <vprintfmt+0x145>
  800749:	8b 14 85 c0 29 80 00 	mov    0x8029c0(,%eax,4),%edx
  800750:	85 d2                	test   %edx,%edx
  800752:	75 18                	jne    80076c <vprintfmt+0x15d>
				printfmt(putch, putdat, "error %d", err);
  800754:	50                   	push   %eax
  800755:	68 27 27 80 00       	push   $0x802727
  80075a:	53                   	push   %ebx
  80075b:	56                   	push   %esi
  80075c:	e8 91 fe ff ff       	call   8005f2 <printfmt>
  800761:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800764:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800767:	e9 c9 fe ff ff       	jmp    800635 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80076c:	52                   	push   %edx
  80076d:	68 f1 2a 80 00       	push   $0x802af1
  800772:	53                   	push   %ebx
  800773:	56                   	push   %esi
  800774:	e8 79 fe ff ff       	call   8005f2 <printfmt>
  800779:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80077c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80077f:	e9 b1 fe ff ff       	jmp    800635 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800784:	8b 45 14             	mov    0x14(%ebp),%eax
  800787:	8d 50 04             	lea    0x4(%eax),%edx
  80078a:	89 55 14             	mov    %edx,0x14(%ebp)
  80078d:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80078f:	85 ff                	test   %edi,%edi
  800791:	b8 20 27 80 00       	mov    $0x802720,%eax
  800796:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800799:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80079d:	0f 8e 94 00 00 00    	jle    800837 <vprintfmt+0x228>
  8007a3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8007a7:	0f 84 98 00 00 00    	je     800845 <vprintfmt+0x236>
				for (width -= strnlen(p, precision); width > 0; width--)
  8007ad:	83 ec 08             	sub    $0x8,%esp
  8007b0:	ff 75 cc             	pushl  -0x34(%ebp)
  8007b3:	57                   	push   %edi
  8007b4:	e8 a1 02 00 00       	call   800a5a <strnlen>
  8007b9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8007bc:	29 c1                	sub    %eax,%ecx
  8007be:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8007c1:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8007c4:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8007c8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007cb:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8007ce:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007d0:	eb 0f                	jmp    8007e1 <vprintfmt+0x1d2>
					putch(padc, putdat);
  8007d2:	83 ec 08             	sub    $0x8,%esp
  8007d5:	53                   	push   %ebx
  8007d6:	ff 75 e0             	pushl  -0x20(%ebp)
  8007d9:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007db:	83 ef 01             	sub    $0x1,%edi
  8007de:	83 c4 10             	add    $0x10,%esp
  8007e1:	85 ff                	test   %edi,%edi
  8007e3:	7f ed                	jg     8007d2 <vprintfmt+0x1c3>
  8007e5:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8007e8:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8007eb:	85 c9                	test   %ecx,%ecx
  8007ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f2:	0f 49 c1             	cmovns %ecx,%eax
  8007f5:	29 c1                	sub    %eax,%ecx
  8007f7:	89 75 08             	mov    %esi,0x8(%ebp)
  8007fa:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8007fd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800800:	89 cb                	mov    %ecx,%ebx
  800802:	eb 4d                	jmp    800851 <vprintfmt+0x242>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800804:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800808:	74 1b                	je     800825 <vprintfmt+0x216>
  80080a:	0f be c0             	movsbl %al,%eax
  80080d:	83 e8 20             	sub    $0x20,%eax
  800810:	83 f8 5e             	cmp    $0x5e,%eax
  800813:	76 10                	jbe    800825 <vprintfmt+0x216>
					putch('?', putdat);
  800815:	83 ec 08             	sub    $0x8,%esp
  800818:	ff 75 0c             	pushl  0xc(%ebp)
  80081b:	6a 3f                	push   $0x3f
  80081d:	ff 55 08             	call   *0x8(%ebp)
  800820:	83 c4 10             	add    $0x10,%esp
  800823:	eb 0d                	jmp    800832 <vprintfmt+0x223>
				else
					putch(ch, putdat);
  800825:	83 ec 08             	sub    $0x8,%esp
  800828:	ff 75 0c             	pushl  0xc(%ebp)
  80082b:	52                   	push   %edx
  80082c:	ff 55 08             	call   *0x8(%ebp)
  80082f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800832:	83 eb 01             	sub    $0x1,%ebx
  800835:	eb 1a                	jmp    800851 <vprintfmt+0x242>
  800837:	89 75 08             	mov    %esi,0x8(%ebp)
  80083a:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80083d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800840:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800843:	eb 0c                	jmp    800851 <vprintfmt+0x242>
  800845:	89 75 08             	mov    %esi,0x8(%ebp)
  800848:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80084b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80084e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800851:	83 c7 01             	add    $0x1,%edi
  800854:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800858:	0f be d0             	movsbl %al,%edx
  80085b:	85 d2                	test   %edx,%edx
  80085d:	74 23                	je     800882 <vprintfmt+0x273>
  80085f:	85 f6                	test   %esi,%esi
  800861:	78 a1                	js     800804 <vprintfmt+0x1f5>
  800863:	83 ee 01             	sub    $0x1,%esi
  800866:	79 9c                	jns    800804 <vprintfmt+0x1f5>
  800868:	89 df                	mov    %ebx,%edi
  80086a:	8b 75 08             	mov    0x8(%ebp),%esi
  80086d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800870:	eb 18                	jmp    80088a <vprintfmt+0x27b>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800872:	83 ec 08             	sub    $0x8,%esp
  800875:	53                   	push   %ebx
  800876:	6a 20                	push   $0x20
  800878:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80087a:	83 ef 01             	sub    $0x1,%edi
  80087d:	83 c4 10             	add    $0x10,%esp
  800880:	eb 08                	jmp    80088a <vprintfmt+0x27b>
  800882:	89 df                	mov    %ebx,%edi
  800884:	8b 75 08             	mov    0x8(%ebp),%esi
  800887:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80088a:	85 ff                	test   %edi,%edi
  80088c:	7f e4                	jg     800872 <vprintfmt+0x263>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80088e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800891:	e9 9f fd ff ff       	jmp    800635 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800896:	83 7d d0 01          	cmpl   $0x1,-0x30(%ebp)
  80089a:	7e 16                	jle    8008b2 <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  80089c:	8b 45 14             	mov    0x14(%ebp),%eax
  80089f:	8d 50 08             	lea    0x8(%eax),%edx
  8008a2:	89 55 14             	mov    %edx,0x14(%ebp)
  8008a5:	8b 50 04             	mov    0x4(%eax),%edx
  8008a8:	8b 00                	mov    (%eax),%eax
  8008aa:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008ad:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8008b0:	eb 34                	jmp    8008e6 <vprintfmt+0x2d7>
	else if (lflag)
  8008b2:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8008b6:	74 18                	je     8008d0 <vprintfmt+0x2c1>
		return va_arg(*ap, long);
  8008b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008bb:	8d 50 04             	lea    0x4(%eax),%edx
  8008be:	89 55 14             	mov    %edx,0x14(%ebp)
  8008c1:	8b 00                	mov    (%eax),%eax
  8008c3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008c6:	89 c1                	mov    %eax,%ecx
  8008c8:	c1 f9 1f             	sar    $0x1f,%ecx
  8008cb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8008ce:	eb 16                	jmp    8008e6 <vprintfmt+0x2d7>
	else
		return va_arg(*ap, int);
  8008d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d3:	8d 50 04             	lea    0x4(%eax),%edx
  8008d6:	89 55 14             	mov    %edx,0x14(%ebp)
  8008d9:	8b 00                	mov    (%eax),%eax
  8008db:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008de:	89 c1                	mov    %eax,%ecx
  8008e0:	c1 f9 1f             	sar    $0x1f,%ecx
  8008e3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8008e6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8008e9:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8008ec:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8008f1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8008f5:	0f 89 88 00 00 00    	jns    800983 <vprintfmt+0x374>
				putch('-', putdat);
  8008fb:	83 ec 08             	sub    $0x8,%esp
  8008fe:	53                   	push   %ebx
  8008ff:	6a 2d                	push   $0x2d
  800901:	ff d6                	call   *%esi
				num = -(long long) num;
  800903:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800906:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800909:	f7 d8                	neg    %eax
  80090b:	83 d2 00             	adc    $0x0,%edx
  80090e:	f7 da                	neg    %edx
  800910:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800913:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800918:	eb 69                	jmp    800983 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80091a:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80091d:	8d 45 14             	lea    0x14(%ebp),%eax
  800920:	e8 76 fc ff ff       	call   80059b <getuint>
			base = 10;
  800925:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80092a:	eb 57                	jmp    800983 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  80092c:	83 ec 08             	sub    $0x8,%esp
  80092f:	53                   	push   %ebx
  800930:	6a 30                	push   $0x30
  800932:	ff d6                	call   *%esi
			num = getuint(&ap, lflag);
  800934:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800937:	8d 45 14             	lea    0x14(%ebp),%eax
  80093a:	e8 5c fc ff ff       	call   80059b <getuint>
			base = 8;
			goto number;
  80093f:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800942:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800947:	eb 3a                	jmp    800983 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  800949:	83 ec 08             	sub    $0x8,%esp
  80094c:	53                   	push   %ebx
  80094d:	6a 30                	push   $0x30
  80094f:	ff d6                	call   *%esi
			putch('x', putdat);
  800951:	83 c4 08             	add    $0x8,%esp
  800954:	53                   	push   %ebx
  800955:	6a 78                	push   $0x78
  800957:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800959:	8b 45 14             	mov    0x14(%ebp),%eax
  80095c:	8d 50 04             	lea    0x4(%eax),%edx
  80095f:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800962:	8b 00                	mov    (%eax),%eax
  800964:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800969:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80096c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800971:	eb 10                	jmp    800983 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800973:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800976:	8d 45 14             	lea    0x14(%ebp),%eax
  800979:	e8 1d fc ff ff       	call   80059b <getuint>
			base = 16;
  80097e:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800983:	83 ec 0c             	sub    $0xc,%esp
  800986:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80098a:	57                   	push   %edi
  80098b:	ff 75 e0             	pushl  -0x20(%ebp)
  80098e:	51                   	push   %ecx
  80098f:	52                   	push   %edx
  800990:	50                   	push   %eax
  800991:	89 da                	mov    %ebx,%edx
  800993:	89 f0                	mov    %esi,%eax
  800995:	e8 52 fb ff ff       	call   8004ec <printnum>
			break;
  80099a:	83 c4 20             	add    $0x20,%esp
  80099d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8009a0:	e9 90 fc ff ff       	jmp    800635 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8009a5:	83 ec 08             	sub    $0x8,%esp
  8009a8:	53                   	push   %ebx
  8009a9:	52                   	push   %edx
  8009aa:	ff d6                	call   *%esi
			break;
  8009ac:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8009b2:	e9 7e fc ff ff       	jmp    800635 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8009b7:	83 ec 08             	sub    $0x8,%esp
  8009ba:	53                   	push   %ebx
  8009bb:	6a 25                	push   $0x25
  8009bd:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009bf:	83 c4 10             	add    $0x10,%esp
  8009c2:	eb 03                	jmp    8009c7 <vprintfmt+0x3b8>
  8009c4:	83 ef 01             	sub    $0x1,%edi
  8009c7:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8009cb:	75 f7                	jne    8009c4 <vprintfmt+0x3b5>
  8009cd:	e9 63 fc ff ff       	jmp    800635 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8009d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009d5:	5b                   	pop    %ebx
  8009d6:	5e                   	pop    %esi
  8009d7:	5f                   	pop    %edi
  8009d8:	5d                   	pop    %ebp
  8009d9:	c3                   	ret    

008009da <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009da:	55                   	push   %ebp
  8009db:	89 e5                	mov    %esp,%ebp
  8009dd:	83 ec 18             	sub    $0x18,%esp
  8009e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009e6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009e9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009ed:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009f0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009f7:	85 c0                	test   %eax,%eax
  8009f9:	74 26                	je     800a21 <vsnprintf+0x47>
  8009fb:	85 d2                	test   %edx,%edx
  8009fd:	7e 22                	jle    800a21 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009ff:	ff 75 14             	pushl  0x14(%ebp)
  800a02:	ff 75 10             	pushl  0x10(%ebp)
  800a05:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a08:	50                   	push   %eax
  800a09:	68 d5 05 80 00       	push   $0x8005d5
  800a0e:	e8 fc fb ff ff       	call   80060f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a13:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a16:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a19:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a1c:	83 c4 10             	add    $0x10,%esp
  800a1f:	eb 05                	jmp    800a26 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a21:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a26:	c9                   	leave  
  800a27:	c3                   	ret    

00800a28 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a28:	55                   	push   %ebp
  800a29:	89 e5                	mov    %esp,%ebp
  800a2b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a2e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a31:	50                   	push   %eax
  800a32:	ff 75 10             	pushl  0x10(%ebp)
  800a35:	ff 75 0c             	pushl  0xc(%ebp)
  800a38:	ff 75 08             	pushl  0x8(%ebp)
  800a3b:	e8 9a ff ff ff       	call   8009da <vsnprintf>
	va_end(ap);

	return rc;
}
  800a40:	c9                   	leave  
  800a41:	c3                   	ret    

00800a42 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a42:	55                   	push   %ebp
  800a43:	89 e5                	mov    %esp,%ebp
  800a45:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a48:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4d:	eb 03                	jmp    800a52 <strlen+0x10>
		n++;
  800a4f:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a52:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a56:	75 f7                	jne    800a4f <strlen+0xd>
		n++;
	return n;
}
  800a58:	5d                   	pop    %ebp
  800a59:	c3                   	ret    

00800a5a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a5a:	55                   	push   %ebp
  800a5b:	89 e5                	mov    %esp,%ebp
  800a5d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a60:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a63:	ba 00 00 00 00       	mov    $0x0,%edx
  800a68:	eb 03                	jmp    800a6d <strnlen+0x13>
		n++;
  800a6a:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a6d:	39 c2                	cmp    %eax,%edx
  800a6f:	74 08                	je     800a79 <strnlen+0x1f>
  800a71:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800a75:	75 f3                	jne    800a6a <strnlen+0x10>
  800a77:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800a79:	5d                   	pop    %ebp
  800a7a:	c3                   	ret    

00800a7b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a7b:	55                   	push   %ebp
  800a7c:	89 e5                	mov    %esp,%ebp
  800a7e:	53                   	push   %ebx
  800a7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a85:	89 c2                	mov    %eax,%edx
  800a87:	83 c2 01             	add    $0x1,%edx
  800a8a:	83 c1 01             	add    $0x1,%ecx
  800a8d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a91:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a94:	84 db                	test   %bl,%bl
  800a96:	75 ef                	jne    800a87 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a98:	5b                   	pop    %ebx
  800a99:	5d                   	pop    %ebp
  800a9a:	c3                   	ret    

00800a9b <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a9b:	55                   	push   %ebp
  800a9c:	89 e5                	mov    %esp,%ebp
  800a9e:	53                   	push   %ebx
  800a9f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800aa2:	53                   	push   %ebx
  800aa3:	e8 9a ff ff ff       	call   800a42 <strlen>
  800aa8:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800aab:	ff 75 0c             	pushl  0xc(%ebp)
  800aae:	01 d8                	add    %ebx,%eax
  800ab0:	50                   	push   %eax
  800ab1:	e8 c5 ff ff ff       	call   800a7b <strcpy>
	return dst;
}
  800ab6:	89 d8                	mov    %ebx,%eax
  800ab8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800abb:	c9                   	leave  
  800abc:	c3                   	ret    

00800abd <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800abd:	55                   	push   %ebp
  800abe:	89 e5                	mov    %esp,%ebp
  800ac0:	56                   	push   %esi
  800ac1:	53                   	push   %ebx
  800ac2:	8b 75 08             	mov    0x8(%ebp),%esi
  800ac5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ac8:	89 f3                	mov    %esi,%ebx
  800aca:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800acd:	89 f2                	mov    %esi,%edx
  800acf:	eb 0f                	jmp    800ae0 <strncpy+0x23>
		*dst++ = *src;
  800ad1:	83 c2 01             	add    $0x1,%edx
  800ad4:	0f b6 01             	movzbl (%ecx),%eax
  800ad7:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ada:	80 39 01             	cmpb   $0x1,(%ecx)
  800add:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ae0:	39 da                	cmp    %ebx,%edx
  800ae2:	75 ed                	jne    800ad1 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800ae4:	89 f0                	mov    %esi,%eax
  800ae6:	5b                   	pop    %ebx
  800ae7:	5e                   	pop    %esi
  800ae8:	5d                   	pop    %ebp
  800ae9:	c3                   	ret    

00800aea <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800aea:	55                   	push   %ebp
  800aeb:	89 e5                	mov    %esp,%ebp
  800aed:	56                   	push   %esi
  800aee:	53                   	push   %ebx
  800aef:	8b 75 08             	mov    0x8(%ebp),%esi
  800af2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800af5:	8b 55 10             	mov    0x10(%ebp),%edx
  800af8:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800afa:	85 d2                	test   %edx,%edx
  800afc:	74 21                	je     800b1f <strlcpy+0x35>
  800afe:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800b02:	89 f2                	mov    %esi,%edx
  800b04:	eb 09                	jmp    800b0f <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b06:	83 c2 01             	add    $0x1,%edx
  800b09:	83 c1 01             	add    $0x1,%ecx
  800b0c:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800b0f:	39 c2                	cmp    %eax,%edx
  800b11:	74 09                	je     800b1c <strlcpy+0x32>
  800b13:	0f b6 19             	movzbl (%ecx),%ebx
  800b16:	84 db                	test   %bl,%bl
  800b18:	75 ec                	jne    800b06 <strlcpy+0x1c>
  800b1a:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800b1c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b1f:	29 f0                	sub    %esi,%eax
}
  800b21:	5b                   	pop    %ebx
  800b22:	5e                   	pop    %esi
  800b23:	5d                   	pop    %ebp
  800b24:	c3                   	ret    

00800b25 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b25:	55                   	push   %ebp
  800b26:	89 e5                	mov    %esp,%ebp
  800b28:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b2b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b2e:	eb 06                	jmp    800b36 <strcmp+0x11>
		p++, q++;
  800b30:	83 c1 01             	add    $0x1,%ecx
  800b33:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b36:	0f b6 01             	movzbl (%ecx),%eax
  800b39:	84 c0                	test   %al,%al
  800b3b:	74 04                	je     800b41 <strcmp+0x1c>
  800b3d:	3a 02                	cmp    (%edx),%al
  800b3f:	74 ef                	je     800b30 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b41:	0f b6 c0             	movzbl %al,%eax
  800b44:	0f b6 12             	movzbl (%edx),%edx
  800b47:	29 d0                	sub    %edx,%eax
}
  800b49:	5d                   	pop    %ebp
  800b4a:	c3                   	ret    

00800b4b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b4b:	55                   	push   %ebp
  800b4c:	89 e5                	mov    %esp,%ebp
  800b4e:	53                   	push   %ebx
  800b4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b52:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b55:	89 c3                	mov    %eax,%ebx
  800b57:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b5a:	eb 06                	jmp    800b62 <strncmp+0x17>
		n--, p++, q++;
  800b5c:	83 c0 01             	add    $0x1,%eax
  800b5f:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b62:	39 d8                	cmp    %ebx,%eax
  800b64:	74 15                	je     800b7b <strncmp+0x30>
  800b66:	0f b6 08             	movzbl (%eax),%ecx
  800b69:	84 c9                	test   %cl,%cl
  800b6b:	74 04                	je     800b71 <strncmp+0x26>
  800b6d:	3a 0a                	cmp    (%edx),%cl
  800b6f:	74 eb                	je     800b5c <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b71:	0f b6 00             	movzbl (%eax),%eax
  800b74:	0f b6 12             	movzbl (%edx),%edx
  800b77:	29 d0                	sub    %edx,%eax
  800b79:	eb 05                	jmp    800b80 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b7b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b80:	5b                   	pop    %ebx
  800b81:	5d                   	pop    %ebp
  800b82:	c3                   	ret    

00800b83 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b83:	55                   	push   %ebp
  800b84:	89 e5                	mov    %esp,%ebp
  800b86:	8b 45 08             	mov    0x8(%ebp),%eax
  800b89:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b8d:	eb 07                	jmp    800b96 <strchr+0x13>
		if (*s == c)
  800b8f:	38 ca                	cmp    %cl,%dl
  800b91:	74 0f                	je     800ba2 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b93:	83 c0 01             	add    $0x1,%eax
  800b96:	0f b6 10             	movzbl (%eax),%edx
  800b99:	84 d2                	test   %dl,%dl
  800b9b:	75 f2                	jne    800b8f <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800b9d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ba2:	5d                   	pop    %ebp
  800ba3:	c3                   	ret    

00800ba4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ba4:	55                   	push   %ebp
  800ba5:	89 e5                	mov    %esp,%ebp
  800ba7:	8b 45 08             	mov    0x8(%ebp),%eax
  800baa:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bae:	eb 03                	jmp    800bb3 <strfind+0xf>
  800bb0:	83 c0 01             	add    $0x1,%eax
  800bb3:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800bb6:	38 ca                	cmp    %cl,%dl
  800bb8:	74 04                	je     800bbe <strfind+0x1a>
  800bba:	84 d2                	test   %dl,%dl
  800bbc:	75 f2                	jne    800bb0 <strfind+0xc>
			break;
	return (char *) s;
}
  800bbe:	5d                   	pop    %ebp
  800bbf:	c3                   	ret    

00800bc0 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bc0:	55                   	push   %ebp
  800bc1:	89 e5                	mov    %esp,%ebp
  800bc3:	57                   	push   %edi
  800bc4:	56                   	push   %esi
  800bc5:	53                   	push   %ebx
  800bc6:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bc9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bcc:	85 c9                	test   %ecx,%ecx
  800bce:	74 36                	je     800c06 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bd0:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bd6:	75 28                	jne    800c00 <memset+0x40>
  800bd8:	f6 c1 03             	test   $0x3,%cl
  800bdb:	75 23                	jne    800c00 <memset+0x40>
		c &= 0xFF;
  800bdd:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800be1:	89 d3                	mov    %edx,%ebx
  800be3:	c1 e3 08             	shl    $0x8,%ebx
  800be6:	89 d6                	mov    %edx,%esi
  800be8:	c1 e6 18             	shl    $0x18,%esi
  800beb:	89 d0                	mov    %edx,%eax
  800bed:	c1 e0 10             	shl    $0x10,%eax
  800bf0:	09 f0                	or     %esi,%eax
  800bf2:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800bf4:	89 d8                	mov    %ebx,%eax
  800bf6:	09 d0                	or     %edx,%eax
  800bf8:	c1 e9 02             	shr    $0x2,%ecx
  800bfb:	fc                   	cld    
  800bfc:	f3 ab                	rep stos %eax,%es:(%edi)
  800bfe:	eb 06                	jmp    800c06 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c00:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c03:	fc                   	cld    
  800c04:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c06:	89 f8                	mov    %edi,%eax
  800c08:	5b                   	pop    %ebx
  800c09:	5e                   	pop    %esi
  800c0a:	5f                   	pop    %edi
  800c0b:	5d                   	pop    %ebp
  800c0c:	c3                   	ret    

00800c0d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c0d:	55                   	push   %ebp
  800c0e:	89 e5                	mov    %esp,%ebp
  800c10:	57                   	push   %edi
  800c11:	56                   	push   %esi
  800c12:	8b 45 08             	mov    0x8(%ebp),%eax
  800c15:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c18:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c1b:	39 c6                	cmp    %eax,%esi
  800c1d:	73 35                	jae    800c54 <memmove+0x47>
  800c1f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c22:	39 d0                	cmp    %edx,%eax
  800c24:	73 2e                	jae    800c54 <memmove+0x47>
		s += n;
		d += n;
  800c26:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c29:	89 d6                	mov    %edx,%esi
  800c2b:	09 fe                	or     %edi,%esi
  800c2d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c33:	75 13                	jne    800c48 <memmove+0x3b>
  800c35:	f6 c1 03             	test   $0x3,%cl
  800c38:	75 0e                	jne    800c48 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800c3a:	83 ef 04             	sub    $0x4,%edi
  800c3d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c40:	c1 e9 02             	shr    $0x2,%ecx
  800c43:	fd                   	std    
  800c44:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c46:	eb 09                	jmp    800c51 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c48:	83 ef 01             	sub    $0x1,%edi
  800c4b:	8d 72 ff             	lea    -0x1(%edx),%esi
  800c4e:	fd                   	std    
  800c4f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c51:	fc                   	cld    
  800c52:	eb 1d                	jmp    800c71 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c54:	89 f2                	mov    %esi,%edx
  800c56:	09 c2                	or     %eax,%edx
  800c58:	f6 c2 03             	test   $0x3,%dl
  800c5b:	75 0f                	jne    800c6c <memmove+0x5f>
  800c5d:	f6 c1 03             	test   $0x3,%cl
  800c60:	75 0a                	jne    800c6c <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800c62:	c1 e9 02             	shr    $0x2,%ecx
  800c65:	89 c7                	mov    %eax,%edi
  800c67:	fc                   	cld    
  800c68:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c6a:	eb 05                	jmp    800c71 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c6c:	89 c7                	mov    %eax,%edi
  800c6e:	fc                   	cld    
  800c6f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c71:	5e                   	pop    %esi
  800c72:	5f                   	pop    %edi
  800c73:	5d                   	pop    %ebp
  800c74:	c3                   	ret    

00800c75 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c75:	55                   	push   %ebp
  800c76:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c78:	ff 75 10             	pushl  0x10(%ebp)
  800c7b:	ff 75 0c             	pushl  0xc(%ebp)
  800c7e:	ff 75 08             	pushl  0x8(%ebp)
  800c81:	e8 87 ff ff ff       	call   800c0d <memmove>
}
  800c86:	c9                   	leave  
  800c87:	c3                   	ret    

00800c88 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c88:	55                   	push   %ebp
  800c89:	89 e5                	mov    %esp,%ebp
  800c8b:	56                   	push   %esi
  800c8c:	53                   	push   %ebx
  800c8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c90:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c93:	89 c6                	mov    %eax,%esi
  800c95:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c98:	eb 1a                	jmp    800cb4 <memcmp+0x2c>
		if (*s1 != *s2)
  800c9a:	0f b6 08             	movzbl (%eax),%ecx
  800c9d:	0f b6 1a             	movzbl (%edx),%ebx
  800ca0:	38 d9                	cmp    %bl,%cl
  800ca2:	74 0a                	je     800cae <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ca4:	0f b6 c1             	movzbl %cl,%eax
  800ca7:	0f b6 db             	movzbl %bl,%ebx
  800caa:	29 d8                	sub    %ebx,%eax
  800cac:	eb 0f                	jmp    800cbd <memcmp+0x35>
		s1++, s2++;
  800cae:	83 c0 01             	add    $0x1,%eax
  800cb1:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cb4:	39 f0                	cmp    %esi,%eax
  800cb6:	75 e2                	jne    800c9a <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800cb8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cbd:	5b                   	pop    %ebx
  800cbe:	5e                   	pop    %esi
  800cbf:	5d                   	pop    %ebp
  800cc0:	c3                   	ret    

00800cc1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	53                   	push   %ebx
  800cc5:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800cc8:	89 c1                	mov    %eax,%ecx
  800cca:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800ccd:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cd1:	eb 0a                	jmp    800cdd <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cd3:	0f b6 10             	movzbl (%eax),%edx
  800cd6:	39 da                	cmp    %ebx,%edx
  800cd8:	74 07                	je     800ce1 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cda:	83 c0 01             	add    $0x1,%eax
  800cdd:	39 c8                	cmp    %ecx,%eax
  800cdf:	72 f2                	jb     800cd3 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ce1:	5b                   	pop    %ebx
  800ce2:	5d                   	pop    %ebp
  800ce3:	c3                   	ret    

00800ce4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ce4:	55                   	push   %ebp
  800ce5:	89 e5                	mov    %esp,%ebp
  800ce7:	57                   	push   %edi
  800ce8:	56                   	push   %esi
  800ce9:	53                   	push   %ebx
  800cea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ced:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cf0:	eb 03                	jmp    800cf5 <strtol+0x11>
		s++;
  800cf2:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cf5:	0f b6 01             	movzbl (%ecx),%eax
  800cf8:	3c 20                	cmp    $0x20,%al
  800cfa:	74 f6                	je     800cf2 <strtol+0xe>
  800cfc:	3c 09                	cmp    $0x9,%al
  800cfe:	74 f2                	je     800cf2 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d00:	3c 2b                	cmp    $0x2b,%al
  800d02:	75 0a                	jne    800d0e <strtol+0x2a>
		s++;
  800d04:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d07:	bf 00 00 00 00       	mov    $0x0,%edi
  800d0c:	eb 11                	jmp    800d1f <strtol+0x3b>
  800d0e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d13:	3c 2d                	cmp    $0x2d,%al
  800d15:	75 08                	jne    800d1f <strtol+0x3b>
		s++, neg = 1;
  800d17:	83 c1 01             	add    $0x1,%ecx
  800d1a:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d1f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d25:	75 15                	jne    800d3c <strtol+0x58>
  800d27:	80 39 30             	cmpb   $0x30,(%ecx)
  800d2a:	75 10                	jne    800d3c <strtol+0x58>
  800d2c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d30:	75 7c                	jne    800dae <strtol+0xca>
		s += 2, base = 16;
  800d32:	83 c1 02             	add    $0x2,%ecx
  800d35:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d3a:	eb 16                	jmp    800d52 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800d3c:	85 db                	test   %ebx,%ebx
  800d3e:	75 12                	jne    800d52 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d40:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d45:	80 39 30             	cmpb   $0x30,(%ecx)
  800d48:	75 08                	jne    800d52 <strtol+0x6e>
		s++, base = 8;
  800d4a:	83 c1 01             	add    $0x1,%ecx
  800d4d:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800d52:	b8 00 00 00 00       	mov    $0x0,%eax
  800d57:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d5a:	0f b6 11             	movzbl (%ecx),%edx
  800d5d:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d60:	89 f3                	mov    %esi,%ebx
  800d62:	80 fb 09             	cmp    $0x9,%bl
  800d65:	77 08                	ja     800d6f <strtol+0x8b>
			dig = *s - '0';
  800d67:	0f be d2             	movsbl %dl,%edx
  800d6a:	83 ea 30             	sub    $0x30,%edx
  800d6d:	eb 22                	jmp    800d91 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800d6f:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d72:	89 f3                	mov    %esi,%ebx
  800d74:	80 fb 19             	cmp    $0x19,%bl
  800d77:	77 08                	ja     800d81 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800d79:	0f be d2             	movsbl %dl,%edx
  800d7c:	83 ea 57             	sub    $0x57,%edx
  800d7f:	eb 10                	jmp    800d91 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800d81:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d84:	89 f3                	mov    %esi,%ebx
  800d86:	80 fb 19             	cmp    $0x19,%bl
  800d89:	77 16                	ja     800da1 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800d8b:	0f be d2             	movsbl %dl,%edx
  800d8e:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800d91:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d94:	7d 0b                	jge    800da1 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800d96:	83 c1 01             	add    $0x1,%ecx
  800d99:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d9d:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800d9f:	eb b9                	jmp    800d5a <strtol+0x76>

	if (endptr)
  800da1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800da5:	74 0d                	je     800db4 <strtol+0xd0>
		*endptr = (char *) s;
  800da7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800daa:	89 0e                	mov    %ecx,(%esi)
  800dac:	eb 06                	jmp    800db4 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800dae:	85 db                	test   %ebx,%ebx
  800db0:	74 98                	je     800d4a <strtol+0x66>
  800db2:	eb 9e                	jmp    800d52 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800db4:	89 c2                	mov    %eax,%edx
  800db6:	f7 da                	neg    %edx
  800db8:	85 ff                	test   %edi,%edi
  800dba:	0f 45 c2             	cmovne %edx,%eax
}
  800dbd:	5b                   	pop    %ebx
  800dbe:	5e                   	pop    %esi
  800dbf:	5f                   	pop    %edi
  800dc0:	5d                   	pop    %ebp
  800dc1:	c3                   	ret    

00800dc2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800dc2:	55                   	push   %ebp
  800dc3:	89 e5                	mov    %esp,%ebp
  800dc5:	57                   	push   %edi
  800dc6:	56                   	push   %esi
  800dc7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc8:	b8 00 00 00 00       	mov    $0x0,%eax
  800dcd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd0:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd3:	89 c3                	mov    %eax,%ebx
  800dd5:	89 c7                	mov    %eax,%edi
  800dd7:	89 c6                	mov    %eax,%esi
  800dd9:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ddb:	5b                   	pop    %ebx
  800ddc:	5e                   	pop    %esi
  800ddd:	5f                   	pop    %edi
  800dde:	5d                   	pop    %ebp
  800ddf:	c3                   	ret    

00800de0 <sys_cgetc>:

int
sys_cgetc(void)
{
  800de0:	55                   	push   %ebp
  800de1:	89 e5                	mov    %esp,%ebp
  800de3:	57                   	push   %edi
  800de4:	56                   	push   %esi
  800de5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de6:	ba 00 00 00 00       	mov    $0x0,%edx
  800deb:	b8 01 00 00 00       	mov    $0x1,%eax
  800df0:	89 d1                	mov    %edx,%ecx
  800df2:	89 d3                	mov    %edx,%ebx
  800df4:	89 d7                	mov    %edx,%edi
  800df6:	89 d6                	mov    %edx,%esi
  800df8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800dfa:	5b                   	pop    %ebx
  800dfb:	5e                   	pop    %esi
  800dfc:	5f                   	pop    %edi
  800dfd:	5d                   	pop    %ebp
  800dfe:	c3                   	ret    

00800dff <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800dff:	55                   	push   %ebp
  800e00:	89 e5                	mov    %esp,%ebp
  800e02:	57                   	push   %edi
  800e03:	56                   	push   %esi
  800e04:	53                   	push   %ebx
  800e05:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e08:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e0d:	b8 03 00 00 00       	mov    $0x3,%eax
  800e12:	8b 55 08             	mov    0x8(%ebp),%edx
  800e15:	89 cb                	mov    %ecx,%ebx
  800e17:	89 cf                	mov    %ecx,%edi
  800e19:	89 ce                	mov    %ecx,%esi
  800e1b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e1d:	85 c0                	test   %eax,%eax
  800e1f:	7e 17                	jle    800e38 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e21:	83 ec 0c             	sub    $0xc,%esp
  800e24:	50                   	push   %eax
  800e25:	6a 03                	push   $0x3
  800e27:	68 1f 2a 80 00       	push   $0x802a1f
  800e2c:	6a 23                	push   $0x23
  800e2e:	68 3c 2a 80 00       	push   $0x802a3c
  800e33:	e8 c7 f5 ff ff       	call   8003ff <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e3b:	5b                   	pop    %ebx
  800e3c:	5e                   	pop    %esi
  800e3d:	5f                   	pop    %edi
  800e3e:	5d                   	pop    %ebp
  800e3f:	c3                   	ret    

00800e40 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e40:	55                   	push   %ebp
  800e41:	89 e5                	mov    %esp,%ebp
  800e43:	57                   	push   %edi
  800e44:	56                   	push   %esi
  800e45:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e46:	ba 00 00 00 00       	mov    $0x0,%edx
  800e4b:	b8 02 00 00 00       	mov    $0x2,%eax
  800e50:	89 d1                	mov    %edx,%ecx
  800e52:	89 d3                	mov    %edx,%ebx
  800e54:	89 d7                	mov    %edx,%edi
  800e56:	89 d6                	mov    %edx,%esi
  800e58:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e5a:	5b                   	pop    %ebx
  800e5b:	5e                   	pop    %esi
  800e5c:	5f                   	pop    %edi
  800e5d:	5d                   	pop    %ebp
  800e5e:	c3                   	ret    

00800e5f <sys_yield>:

void
sys_yield(void)
{
  800e5f:	55                   	push   %ebp
  800e60:	89 e5                	mov    %esp,%ebp
  800e62:	57                   	push   %edi
  800e63:	56                   	push   %esi
  800e64:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e65:	ba 00 00 00 00       	mov    $0x0,%edx
  800e6a:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e6f:	89 d1                	mov    %edx,%ecx
  800e71:	89 d3                	mov    %edx,%ebx
  800e73:	89 d7                	mov    %edx,%edi
  800e75:	89 d6                	mov    %edx,%esi
  800e77:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e79:	5b                   	pop    %ebx
  800e7a:	5e                   	pop    %esi
  800e7b:	5f                   	pop    %edi
  800e7c:	5d                   	pop    %ebp
  800e7d:	c3                   	ret    

00800e7e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e7e:	55                   	push   %ebp
  800e7f:	89 e5                	mov    %esp,%ebp
  800e81:	57                   	push   %edi
  800e82:	56                   	push   %esi
  800e83:	53                   	push   %ebx
  800e84:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e87:	be 00 00 00 00       	mov    $0x0,%esi
  800e8c:	b8 04 00 00 00       	mov    $0x4,%eax
  800e91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e94:	8b 55 08             	mov    0x8(%ebp),%edx
  800e97:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e9a:	89 f7                	mov    %esi,%edi
  800e9c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e9e:	85 c0                	test   %eax,%eax
  800ea0:	7e 17                	jle    800eb9 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea2:	83 ec 0c             	sub    $0xc,%esp
  800ea5:	50                   	push   %eax
  800ea6:	6a 04                	push   $0x4
  800ea8:	68 1f 2a 80 00       	push   $0x802a1f
  800ead:	6a 23                	push   $0x23
  800eaf:	68 3c 2a 80 00       	push   $0x802a3c
  800eb4:	e8 46 f5 ff ff       	call   8003ff <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800eb9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ebc:	5b                   	pop    %ebx
  800ebd:	5e                   	pop    %esi
  800ebe:	5f                   	pop    %edi
  800ebf:	5d                   	pop    %ebp
  800ec0:	c3                   	ret    

00800ec1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ec1:	55                   	push   %ebp
  800ec2:	89 e5                	mov    %esp,%ebp
  800ec4:	57                   	push   %edi
  800ec5:	56                   	push   %esi
  800ec6:	53                   	push   %ebx
  800ec7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eca:	b8 05 00 00 00       	mov    $0x5,%eax
  800ecf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ed8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800edb:	8b 75 18             	mov    0x18(%ebp),%esi
  800ede:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ee0:	85 c0                	test   %eax,%eax
  800ee2:	7e 17                	jle    800efb <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee4:	83 ec 0c             	sub    $0xc,%esp
  800ee7:	50                   	push   %eax
  800ee8:	6a 05                	push   $0x5
  800eea:	68 1f 2a 80 00       	push   $0x802a1f
  800eef:	6a 23                	push   $0x23
  800ef1:	68 3c 2a 80 00       	push   $0x802a3c
  800ef6:	e8 04 f5 ff ff       	call   8003ff <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800efb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800efe:	5b                   	pop    %ebx
  800eff:	5e                   	pop    %esi
  800f00:	5f                   	pop    %edi
  800f01:	5d                   	pop    %ebp
  800f02:	c3                   	ret    

00800f03 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f03:	55                   	push   %ebp
  800f04:	89 e5                	mov    %esp,%ebp
  800f06:	57                   	push   %edi
  800f07:	56                   	push   %esi
  800f08:	53                   	push   %ebx
  800f09:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f0c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f11:	b8 06 00 00 00       	mov    $0x6,%eax
  800f16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f19:	8b 55 08             	mov    0x8(%ebp),%edx
  800f1c:	89 df                	mov    %ebx,%edi
  800f1e:	89 de                	mov    %ebx,%esi
  800f20:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f22:	85 c0                	test   %eax,%eax
  800f24:	7e 17                	jle    800f3d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f26:	83 ec 0c             	sub    $0xc,%esp
  800f29:	50                   	push   %eax
  800f2a:	6a 06                	push   $0x6
  800f2c:	68 1f 2a 80 00       	push   $0x802a1f
  800f31:	6a 23                	push   $0x23
  800f33:	68 3c 2a 80 00       	push   $0x802a3c
  800f38:	e8 c2 f4 ff ff       	call   8003ff <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f40:	5b                   	pop    %ebx
  800f41:	5e                   	pop    %esi
  800f42:	5f                   	pop    %edi
  800f43:	5d                   	pop    %ebp
  800f44:	c3                   	ret    

00800f45 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f45:	55                   	push   %ebp
  800f46:	89 e5                	mov    %esp,%ebp
  800f48:	57                   	push   %edi
  800f49:	56                   	push   %esi
  800f4a:	53                   	push   %ebx
  800f4b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f4e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f53:	b8 08 00 00 00       	mov    $0x8,%eax
  800f58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f5e:	89 df                	mov    %ebx,%edi
  800f60:	89 de                	mov    %ebx,%esi
  800f62:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f64:	85 c0                	test   %eax,%eax
  800f66:	7e 17                	jle    800f7f <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f68:	83 ec 0c             	sub    $0xc,%esp
  800f6b:	50                   	push   %eax
  800f6c:	6a 08                	push   $0x8
  800f6e:	68 1f 2a 80 00       	push   $0x802a1f
  800f73:	6a 23                	push   $0x23
  800f75:	68 3c 2a 80 00       	push   $0x802a3c
  800f7a:	e8 80 f4 ff ff       	call   8003ff <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f82:	5b                   	pop    %ebx
  800f83:	5e                   	pop    %esi
  800f84:	5f                   	pop    %edi
  800f85:	5d                   	pop    %ebp
  800f86:	c3                   	ret    

00800f87 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f87:	55                   	push   %ebp
  800f88:	89 e5                	mov    %esp,%ebp
  800f8a:	57                   	push   %edi
  800f8b:	56                   	push   %esi
  800f8c:	53                   	push   %ebx
  800f8d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f90:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f95:	b8 09 00 00 00       	mov    $0x9,%eax
  800f9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa0:	89 df                	mov    %ebx,%edi
  800fa2:	89 de                	mov    %ebx,%esi
  800fa4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fa6:	85 c0                	test   %eax,%eax
  800fa8:	7e 17                	jle    800fc1 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800faa:	83 ec 0c             	sub    $0xc,%esp
  800fad:	50                   	push   %eax
  800fae:	6a 09                	push   $0x9
  800fb0:	68 1f 2a 80 00       	push   $0x802a1f
  800fb5:	6a 23                	push   $0x23
  800fb7:	68 3c 2a 80 00       	push   $0x802a3c
  800fbc:	e8 3e f4 ff ff       	call   8003ff <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800fc1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fc4:	5b                   	pop    %ebx
  800fc5:	5e                   	pop    %esi
  800fc6:	5f                   	pop    %edi
  800fc7:	5d                   	pop    %ebp
  800fc8:	c3                   	ret    

00800fc9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800fc9:	55                   	push   %ebp
  800fca:	89 e5                	mov    %esp,%ebp
  800fcc:	57                   	push   %edi
  800fcd:	56                   	push   %esi
  800fce:	53                   	push   %ebx
  800fcf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fd2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fd7:	b8 0a 00 00 00       	mov    $0xa,%eax
  800fdc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fdf:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe2:	89 df                	mov    %ebx,%edi
  800fe4:	89 de                	mov    %ebx,%esi
  800fe6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fe8:	85 c0                	test   %eax,%eax
  800fea:	7e 17                	jle    801003 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fec:	83 ec 0c             	sub    $0xc,%esp
  800fef:	50                   	push   %eax
  800ff0:	6a 0a                	push   $0xa
  800ff2:	68 1f 2a 80 00       	push   $0x802a1f
  800ff7:	6a 23                	push   $0x23
  800ff9:	68 3c 2a 80 00       	push   $0x802a3c
  800ffe:	e8 fc f3 ff ff       	call   8003ff <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801003:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801006:	5b                   	pop    %ebx
  801007:	5e                   	pop    %esi
  801008:	5f                   	pop    %edi
  801009:	5d                   	pop    %ebp
  80100a:	c3                   	ret    

0080100b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80100b:	55                   	push   %ebp
  80100c:	89 e5                	mov    %esp,%ebp
  80100e:	57                   	push   %edi
  80100f:	56                   	push   %esi
  801010:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801011:	be 00 00 00 00       	mov    $0x0,%esi
  801016:	b8 0c 00 00 00       	mov    $0xc,%eax
  80101b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80101e:	8b 55 08             	mov    0x8(%ebp),%edx
  801021:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801024:	8b 7d 14             	mov    0x14(%ebp),%edi
  801027:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801029:	5b                   	pop    %ebx
  80102a:	5e                   	pop    %esi
  80102b:	5f                   	pop    %edi
  80102c:	5d                   	pop    %ebp
  80102d:	c3                   	ret    

0080102e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80102e:	55                   	push   %ebp
  80102f:	89 e5                	mov    %esp,%ebp
  801031:	57                   	push   %edi
  801032:	56                   	push   %esi
  801033:	53                   	push   %ebx
  801034:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801037:	b9 00 00 00 00       	mov    $0x0,%ecx
  80103c:	b8 0d 00 00 00       	mov    $0xd,%eax
  801041:	8b 55 08             	mov    0x8(%ebp),%edx
  801044:	89 cb                	mov    %ecx,%ebx
  801046:	89 cf                	mov    %ecx,%edi
  801048:	89 ce                	mov    %ecx,%esi
  80104a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80104c:	85 c0                	test   %eax,%eax
  80104e:	7e 17                	jle    801067 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801050:	83 ec 0c             	sub    $0xc,%esp
  801053:	50                   	push   %eax
  801054:	6a 0d                	push   $0xd
  801056:	68 1f 2a 80 00       	push   $0x802a1f
  80105b:	6a 23                	push   $0x23
  80105d:	68 3c 2a 80 00       	push   $0x802a3c
  801062:	e8 98 f3 ff ff       	call   8003ff <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801067:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80106a:	5b                   	pop    %ebx
  80106b:	5e                   	pop    %esi
  80106c:	5f                   	pop    %edi
  80106d:	5d                   	pop    %ebp
  80106e:	c3                   	ret    

0080106f <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80106f:	55                   	push   %ebp
  801070:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801072:	8b 45 08             	mov    0x8(%ebp),%eax
  801075:	05 00 00 00 30       	add    $0x30000000,%eax
  80107a:	c1 e8 0c             	shr    $0xc,%eax
}
  80107d:	5d                   	pop    %ebp
  80107e:	c3                   	ret    

0080107f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80107f:	55                   	push   %ebp
  801080:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801082:	8b 45 08             	mov    0x8(%ebp),%eax
  801085:	05 00 00 00 30       	add    $0x30000000,%eax
  80108a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80108f:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801094:	5d                   	pop    %ebp
  801095:	c3                   	ret    

00801096 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801096:	55                   	push   %ebp
  801097:	89 e5                	mov    %esp,%ebp
  801099:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80109c:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010a1:	89 c2                	mov    %eax,%edx
  8010a3:	c1 ea 16             	shr    $0x16,%edx
  8010a6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010ad:	f6 c2 01             	test   $0x1,%dl
  8010b0:	74 11                	je     8010c3 <fd_alloc+0x2d>
  8010b2:	89 c2                	mov    %eax,%edx
  8010b4:	c1 ea 0c             	shr    $0xc,%edx
  8010b7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010be:	f6 c2 01             	test   $0x1,%dl
  8010c1:	75 09                	jne    8010cc <fd_alloc+0x36>
			*fd_store = fd;
  8010c3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8010ca:	eb 17                	jmp    8010e3 <fd_alloc+0x4d>
  8010cc:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010d1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010d6:	75 c9                	jne    8010a1 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010d8:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8010de:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010e3:	5d                   	pop    %ebp
  8010e4:	c3                   	ret    

008010e5 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010e5:	55                   	push   %ebp
  8010e6:	89 e5                	mov    %esp,%ebp
  8010e8:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010eb:	83 f8 1f             	cmp    $0x1f,%eax
  8010ee:	77 36                	ja     801126 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010f0:	c1 e0 0c             	shl    $0xc,%eax
  8010f3:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010f8:	89 c2                	mov    %eax,%edx
  8010fa:	c1 ea 16             	shr    $0x16,%edx
  8010fd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801104:	f6 c2 01             	test   $0x1,%dl
  801107:	74 24                	je     80112d <fd_lookup+0x48>
  801109:	89 c2                	mov    %eax,%edx
  80110b:	c1 ea 0c             	shr    $0xc,%edx
  80110e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801115:	f6 c2 01             	test   $0x1,%dl
  801118:	74 1a                	je     801134 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80111a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80111d:	89 02                	mov    %eax,(%edx)
	return 0;
  80111f:	b8 00 00 00 00       	mov    $0x0,%eax
  801124:	eb 13                	jmp    801139 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801126:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80112b:	eb 0c                	jmp    801139 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80112d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801132:	eb 05                	jmp    801139 <fd_lookup+0x54>
  801134:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801139:	5d                   	pop    %ebp
  80113a:	c3                   	ret    

0080113b <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80113b:	55                   	push   %ebp
  80113c:	89 e5                	mov    %esp,%ebp
  80113e:	83 ec 08             	sub    $0x8,%esp
  801141:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801144:	ba c8 2a 80 00       	mov    $0x802ac8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801149:	eb 13                	jmp    80115e <dev_lookup+0x23>
  80114b:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80114e:	39 08                	cmp    %ecx,(%eax)
  801150:	75 0c                	jne    80115e <dev_lookup+0x23>
			*dev = devtab[i];
  801152:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801155:	89 01                	mov    %eax,(%ecx)
			return 0;
  801157:	b8 00 00 00 00       	mov    $0x0,%eax
  80115c:	eb 2e                	jmp    80118c <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80115e:	8b 02                	mov    (%edx),%eax
  801160:	85 c0                	test   %eax,%eax
  801162:	75 e7                	jne    80114b <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801164:	a1 90 67 80 00       	mov    0x806790,%eax
  801169:	8b 40 48             	mov    0x48(%eax),%eax
  80116c:	83 ec 04             	sub    $0x4,%esp
  80116f:	51                   	push   %ecx
  801170:	50                   	push   %eax
  801171:	68 4c 2a 80 00       	push   $0x802a4c
  801176:	e8 5d f3 ff ff       	call   8004d8 <cprintf>
	*dev = 0;
  80117b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80117e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801184:	83 c4 10             	add    $0x10,%esp
  801187:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80118c:	c9                   	leave  
  80118d:	c3                   	ret    

0080118e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80118e:	55                   	push   %ebp
  80118f:	89 e5                	mov    %esp,%ebp
  801191:	56                   	push   %esi
  801192:	53                   	push   %ebx
  801193:	83 ec 10             	sub    $0x10,%esp
  801196:	8b 75 08             	mov    0x8(%ebp),%esi
  801199:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80119c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80119f:	50                   	push   %eax
  8011a0:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011a6:	c1 e8 0c             	shr    $0xc,%eax
  8011a9:	50                   	push   %eax
  8011aa:	e8 36 ff ff ff       	call   8010e5 <fd_lookup>
  8011af:	83 c4 08             	add    $0x8,%esp
  8011b2:	85 c0                	test   %eax,%eax
  8011b4:	78 05                	js     8011bb <fd_close+0x2d>
	    || fd != fd2)
  8011b6:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011b9:	74 0c                	je     8011c7 <fd_close+0x39>
		return (must_exist ? r : 0);
  8011bb:	84 db                	test   %bl,%bl
  8011bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8011c2:	0f 44 c2             	cmove  %edx,%eax
  8011c5:	eb 41                	jmp    801208 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011c7:	83 ec 08             	sub    $0x8,%esp
  8011ca:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011cd:	50                   	push   %eax
  8011ce:	ff 36                	pushl  (%esi)
  8011d0:	e8 66 ff ff ff       	call   80113b <dev_lookup>
  8011d5:	89 c3                	mov    %eax,%ebx
  8011d7:	83 c4 10             	add    $0x10,%esp
  8011da:	85 c0                	test   %eax,%eax
  8011dc:	78 1a                	js     8011f8 <fd_close+0x6a>
		if (dev->dev_close)
  8011de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011e1:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8011e4:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8011e9:	85 c0                	test   %eax,%eax
  8011eb:	74 0b                	je     8011f8 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8011ed:	83 ec 0c             	sub    $0xc,%esp
  8011f0:	56                   	push   %esi
  8011f1:	ff d0                	call   *%eax
  8011f3:	89 c3                	mov    %eax,%ebx
  8011f5:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8011f8:	83 ec 08             	sub    $0x8,%esp
  8011fb:	56                   	push   %esi
  8011fc:	6a 00                	push   $0x0
  8011fe:	e8 00 fd ff ff       	call   800f03 <sys_page_unmap>
	return r;
  801203:	83 c4 10             	add    $0x10,%esp
  801206:	89 d8                	mov    %ebx,%eax
}
  801208:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80120b:	5b                   	pop    %ebx
  80120c:	5e                   	pop    %esi
  80120d:	5d                   	pop    %ebp
  80120e:	c3                   	ret    

0080120f <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80120f:	55                   	push   %ebp
  801210:	89 e5                	mov    %esp,%ebp
  801212:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801215:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801218:	50                   	push   %eax
  801219:	ff 75 08             	pushl  0x8(%ebp)
  80121c:	e8 c4 fe ff ff       	call   8010e5 <fd_lookup>
  801221:	83 c4 08             	add    $0x8,%esp
  801224:	85 c0                	test   %eax,%eax
  801226:	78 10                	js     801238 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801228:	83 ec 08             	sub    $0x8,%esp
  80122b:	6a 01                	push   $0x1
  80122d:	ff 75 f4             	pushl  -0xc(%ebp)
  801230:	e8 59 ff ff ff       	call   80118e <fd_close>
  801235:	83 c4 10             	add    $0x10,%esp
}
  801238:	c9                   	leave  
  801239:	c3                   	ret    

0080123a <close_all>:

void
close_all(void)
{
  80123a:	55                   	push   %ebp
  80123b:	89 e5                	mov    %esp,%ebp
  80123d:	53                   	push   %ebx
  80123e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801241:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801246:	83 ec 0c             	sub    $0xc,%esp
  801249:	53                   	push   %ebx
  80124a:	e8 c0 ff ff ff       	call   80120f <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80124f:	83 c3 01             	add    $0x1,%ebx
  801252:	83 c4 10             	add    $0x10,%esp
  801255:	83 fb 20             	cmp    $0x20,%ebx
  801258:	75 ec                	jne    801246 <close_all+0xc>
		close(i);
}
  80125a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80125d:	c9                   	leave  
  80125e:	c3                   	ret    

0080125f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80125f:	55                   	push   %ebp
  801260:	89 e5                	mov    %esp,%ebp
  801262:	57                   	push   %edi
  801263:	56                   	push   %esi
  801264:	53                   	push   %ebx
  801265:	83 ec 2c             	sub    $0x2c,%esp
  801268:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80126b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80126e:	50                   	push   %eax
  80126f:	ff 75 08             	pushl  0x8(%ebp)
  801272:	e8 6e fe ff ff       	call   8010e5 <fd_lookup>
  801277:	83 c4 08             	add    $0x8,%esp
  80127a:	85 c0                	test   %eax,%eax
  80127c:	0f 88 c1 00 00 00    	js     801343 <dup+0xe4>
		return r;
	close(newfdnum);
  801282:	83 ec 0c             	sub    $0xc,%esp
  801285:	56                   	push   %esi
  801286:	e8 84 ff ff ff       	call   80120f <close>

	newfd = INDEX2FD(newfdnum);
  80128b:	89 f3                	mov    %esi,%ebx
  80128d:	c1 e3 0c             	shl    $0xc,%ebx
  801290:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801296:	83 c4 04             	add    $0x4,%esp
  801299:	ff 75 e4             	pushl  -0x1c(%ebp)
  80129c:	e8 de fd ff ff       	call   80107f <fd2data>
  8012a1:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8012a3:	89 1c 24             	mov    %ebx,(%esp)
  8012a6:	e8 d4 fd ff ff       	call   80107f <fd2data>
  8012ab:	83 c4 10             	add    $0x10,%esp
  8012ae:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012b1:	89 f8                	mov    %edi,%eax
  8012b3:	c1 e8 16             	shr    $0x16,%eax
  8012b6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012bd:	a8 01                	test   $0x1,%al
  8012bf:	74 37                	je     8012f8 <dup+0x99>
  8012c1:	89 f8                	mov    %edi,%eax
  8012c3:	c1 e8 0c             	shr    $0xc,%eax
  8012c6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012cd:	f6 c2 01             	test   $0x1,%dl
  8012d0:	74 26                	je     8012f8 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012d2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012d9:	83 ec 0c             	sub    $0xc,%esp
  8012dc:	25 07 0e 00 00       	and    $0xe07,%eax
  8012e1:	50                   	push   %eax
  8012e2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012e5:	6a 00                	push   $0x0
  8012e7:	57                   	push   %edi
  8012e8:	6a 00                	push   $0x0
  8012ea:	e8 d2 fb ff ff       	call   800ec1 <sys_page_map>
  8012ef:	89 c7                	mov    %eax,%edi
  8012f1:	83 c4 20             	add    $0x20,%esp
  8012f4:	85 c0                	test   %eax,%eax
  8012f6:	78 2e                	js     801326 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012f8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8012fb:	89 d0                	mov    %edx,%eax
  8012fd:	c1 e8 0c             	shr    $0xc,%eax
  801300:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801307:	83 ec 0c             	sub    $0xc,%esp
  80130a:	25 07 0e 00 00       	and    $0xe07,%eax
  80130f:	50                   	push   %eax
  801310:	53                   	push   %ebx
  801311:	6a 00                	push   $0x0
  801313:	52                   	push   %edx
  801314:	6a 00                	push   $0x0
  801316:	e8 a6 fb ff ff       	call   800ec1 <sys_page_map>
  80131b:	89 c7                	mov    %eax,%edi
  80131d:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801320:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801322:	85 ff                	test   %edi,%edi
  801324:	79 1d                	jns    801343 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801326:	83 ec 08             	sub    $0x8,%esp
  801329:	53                   	push   %ebx
  80132a:	6a 00                	push   $0x0
  80132c:	e8 d2 fb ff ff       	call   800f03 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801331:	83 c4 08             	add    $0x8,%esp
  801334:	ff 75 d4             	pushl  -0x2c(%ebp)
  801337:	6a 00                	push   $0x0
  801339:	e8 c5 fb ff ff       	call   800f03 <sys_page_unmap>
	return r;
  80133e:	83 c4 10             	add    $0x10,%esp
  801341:	89 f8                	mov    %edi,%eax
}
  801343:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801346:	5b                   	pop    %ebx
  801347:	5e                   	pop    %esi
  801348:	5f                   	pop    %edi
  801349:	5d                   	pop    %ebp
  80134a:	c3                   	ret    

0080134b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80134b:	55                   	push   %ebp
  80134c:	89 e5                	mov    %esp,%ebp
  80134e:	53                   	push   %ebx
  80134f:	83 ec 14             	sub    $0x14,%esp
  801352:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801355:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801358:	50                   	push   %eax
  801359:	53                   	push   %ebx
  80135a:	e8 86 fd ff ff       	call   8010e5 <fd_lookup>
  80135f:	83 c4 08             	add    $0x8,%esp
  801362:	89 c2                	mov    %eax,%edx
  801364:	85 c0                	test   %eax,%eax
  801366:	78 6d                	js     8013d5 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801368:	83 ec 08             	sub    $0x8,%esp
  80136b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80136e:	50                   	push   %eax
  80136f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801372:	ff 30                	pushl  (%eax)
  801374:	e8 c2 fd ff ff       	call   80113b <dev_lookup>
  801379:	83 c4 10             	add    $0x10,%esp
  80137c:	85 c0                	test   %eax,%eax
  80137e:	78 4c                	js     8013cc <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801380:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801383:	8b 42 08             	mov    0x8(%edx),%eax
  801386:	83 e0 03             	and    $0x3,%eax
  801389:	83 f8 01             	cmp    $0x1,%eax
  80138c:	75 21                	jne    8013af <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80138e:	a1 90 67 80 00       	mov    0x806790,%eax
  801393:	8b 40 48             	mov    0x48(%eax),%eax
  801396:	83 ec 04             	sub    $0x4,%esp
  801399:	53                   	push   %ebx
  80139a:	50                   	push   %eax
  80139b:	68 8d 2a 80 00       	push   $0x802a8d
  8013a0:	e8 33 f1 ff ff       	call   8004d8 <cprintf>
		return -E_INVAL;
  8013a5:	83 c4 10             	add    $0x10,%esp
  8013a8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013ad:	eb 26                	jmp    8013d5 <read+0x8a>
	}
	if (!dev->dev_read)
  8013af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013b2:	8b 40 08             	mov    0x8(%eax),%eax
  8013b5:	85 c0                	test   %eax,%eax
  8013b7:	74 17                	je     8013d0 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013b9:	83 ec 04             	sub    $0x4,%esp
  8013bc:	ff 75 10             	pushl  0x10(%ebp)
  8013bf:	ff 75 0c             	pushl  0xc(%ebp)
  8013c2:	52                   	push   %edx
  8013c3:	ff d0                	call   *%eax
  8013c5:	89 c2                	mov    %eax,%edx
  8013c7:	83 c4 10             	add    $0x10,%esp
  8013ca:	eb 09                	jmp    8013d5 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013cc:	89 c2                	mov    %eax,%edx
  8013ce:	eb 05                	jmp    8013d5 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8013d0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8013d5:	89 d0                	mov    %edx,%eax
  8013d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013da:	c9                   	leave  
  8013db:	c3                   	ret    

008013dc <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013dc:	55                   	push   %ebp
  8013dd:	89 e5                	mov    %esp,%ebp
  8013df:	57                   	push   %edi
  8013e0:	56                   	push   %esi
  8013e1:	53                   	push   %ebx
  8013e2:	83 ec 0c             	sub    $0xc,%esp
  8013e5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013e8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013eb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013f0:	eb 21                	jmp    801413 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013f2:	83 ec 04             	sub    $0x4,%esp
  8013f5:	89 f0                	mov    %esi,%eax
  8013f7:	29 d8                	sub    %ebx,%eax
  8013f9:	50                   	push   %eax
  8013fa:	89 d8                	mov    %ebx,%eax
  8013fc:	03 45 0c             	add    0xc(%ebp),%eax
  8013ff:	50                   	push   %eax
  801400:	57                   	push   %edi
  801401:	e8 45 ff ff ff       	call   80134b <read>
		if (m < 0)
  801406:	83 c4 10             	add    $0x10,%esp
  801409:	85 c0                	test   %eax,%eax
  80140b:	78 10                	js     80141d <readn+0x41>
			return m;
		if (m == 0)
  80140d:	85 c0                	test   %eax,%eax
  80140f:	74 0a                	je     80141b <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801411:	01 c3                	add    %eax,%ebx
  801413:	39 f3                	cmp    %esi,%ebx
  801415:	72 db                	jb     8013f2 <readn+0x16>
  801417:	89 d8                	mov    %ebx,%eax
  801419:	eb 02                	jmp    80141d <readn+0x41>
  80141b:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80141d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801420:	5b                   	pop    %ebx
  801421:	5e                   	pop    %esi
  801422:	5f                   	pop    %edi
  801423:	5d                   	pop    %ebp
  801424:	c3                   	ret    

00801425 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801425:	55                   	push   %ebp
  801426:	89 e5                	mov    %esp,%ebp
  801428:	53                   	push   %ebx
  801429:	83 ec 14             	sub    $0x14,%esp
  80142c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80142f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801432:	50                   	push   %eax
  801433:	53                   	push   %ebx
  801434:	e8 ac fc ff ff       	call   8010e5 <fd_lookup>
  801439:	83 c4 08             	add    $0x8,%esp
  80143c:	89 c2                	mov    %eax,%edx
  80143e:	85 c0                	test   %eax,%eax
  801440:	78 68                	js     8014aa <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801442:	83 ec 08             	sub    $0x8,%esp
  801445:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801448:	50                   	push   %eax
  801449:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80144c:	ff 30                	pushl  (%eax)
  80144e:	e8 e8 fc ff ff       	call   80113b <dev_lookup>
  801453:	83 c4 10             	add    $0x10,%esp
  801456:	85 c0                	test   %eax,%eax
  801458:	78 47                	js     8014a1 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80145a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80145d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801461:	75 21                	jne    801484 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801463:	a1 90 67 80 00       	mov    0x806790,%eax
  801468:	8b 40 48             	mov    0x48(%eax),%eax
  80146b:	83 ec 04             	sub    $0x4,%esp
  80146e:	53                   	push   %ebx
  80146f:	50                   	push   %eax
  801470:	68 a9 2a 80 00       	push   $0x802aa9
  801475:	e8 5e f0 ff ff       	call   8004d8 <cprintf>
		return -E_INVAL;
  80147a:	83 c4 10             	add    $0x10,%esp
  80147d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801482:	eb 26                	jmp    8014aa <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801484:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801487:	8b 52 0c             	mov    0xc(%edx),%edx
  80148a:	85 d2                	test   %edx,%edx
  80148c:	74 17                	je     8014a5 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80148e:	83 ec 04             	sub    $0x4,%esp
  801491:	ff 75 10             	pushl  0x10(%ebp)
  801494:	ff 75 0c             	pushl  0xc(%ebp)
  801497:	50                   	push   %eax
  801498:	ff d2                	call   *%edx
  80149a:	89 c2                	mov    %eax,%edx
  80149c:	83 c4 10             	add    $0x10,%esp
  80149f:	eb 09                	jmp    8014aa <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014a1:	89 c2                	mov    %eax,%edx
  8014a3:	eb 05                	jmp    8014aa <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014a5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8014aa:	89 d0                	mov    %edx,%eax
  8014ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014af:	c9                   	leave  
  8014b0:	c3                   	ret    

008014b1 <seek>:

int
seek(int fdnum, off_t offset)
{
  8014b1:	55                   	push   %ebp
  8014b2:	89 e5                	mov    %esp,%ebp
  8014b4:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014b7:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014ba:	50                   	push   %eax
  8014bb:	ff 75 08             	pushl  0x8(%ebp)
  8014be:	e8 22 fc ff ff       	call   8010e5 <fd_lookup>
  8014c3:	83 c4 08             	add    $0x8,%esp
  8014c6:	85 c0                	test   %eax,%eax
  8014c8:	78 0e                	js     8014d8 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014d0:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014d8:	c9                   	leave  
  8014d9:	c3                   	ret    

008014da <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014da:	55                   	push   %ebp
  8014db:	89 e5                	mov    %esp,%ebp
  8014dd:	53                   	push   %ebx
  8014de:	83 ec 14             	sub    $0x14,%esp
  8014e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014e4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014e7:	50                   	push   %eax
  8014e8:	53                   	push   %ebx
  8014e9:	e8 f7 fb ff ff       	call   8010e5 <fd_lookup>
  8014ee:	83 c4 08             	add    $0x8,%esp
  8014f1:	89 c2                	mov    %eax,%edx
  8014f3:	85 c0                	test   %eax,%eax
  8014f5:	78 65                	js     80155c <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014f7:	83 ec 08             	sub    $0x8,%esp
  8014fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014fd:	50                   	push   %eax
  8014fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801501:	ff 30                	pushl  (%eax)
  801503:	e8 33 fc ff ff       	call   80113b <dev_lookup>
  801508:	83 c4 10             	add    $0x10,%esp
  80150b:	85 c0                	test   %eax,%eax
  80150d:	78 44                	js     801553 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80150f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801512:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801516:	75 21                	jne    801539 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801518:	a1 90 67 80 00       	mov    0x806790,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80151d:	8b 40 48             	mov    0x48(%eax),%eax
  801520:	83 ec 04             	sub    $0x4,%esp
  801523:	53                   	push   %ebx
  801524:	50                   	push   %eax
  801525:	68 6c 2a 80 00       	push   $0x802a6c
  80152a:	e8 a9 ef ff ff       	call   8004d8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80152f:	83 c4 10             	add    $0x10,%esp
  801532:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801537:	eb 23                	jmp    80155c <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801539:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80153c:	8b 52 18             	mov    0x18(%edx),%edx
  80153f:	85 d2                	test   %edx,%edx
  801541:	74 14                	je     801557 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801543:	83 ec 08             	sub    $0x8,%esp
  801546:	ff 75 0c             	pushl  0xc(%ebp)
  801549:	50                   	push   %eax
  80154a:	ff d2                	call   *%edx
  80154c:	89 c2                	mov    %eax,%edx
  80154e:	83 c4 10             	add    $0x10,%esp
  801551:	eb 09                	jmp    80155c <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801553:	89 c2                	mov    %eax,%edx
  801555:	eb 05                	jmp    80155c <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801557:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80155c:	89 d0                	mov    %edx,%eax
  80155e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801561:	c9                   	leave  
  801562:	c3                   	ret    

00801563 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801563:	55                   	push   %ebp
  801564:	89 e5                	mov    %esp,%ebp
  801566:	53                   	push   %ebx
  801567:	83 ec 14             	sub    $0x14,%esp
  80156a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80156d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801570:	50                   	push   %eax
  801571:	ff 75 08             	pushl  0x8(%ebp)
  801574:	e8 6c fb ff ff       	call   8010e5 <fd_lookup>
  801579:	83 c4 08             	add    $0x8,%esp
  80157c:	89 c2                	mov    %eax,%edx
  80157e:	85 c0                	test   %eax,%eax
  801580:	78 58                	js     8015da <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801582:	83 ec 08             	sub    $0x8,%esp
  801585:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801588:	50                   	push   %eax
  801589:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80158c:	ff 30                	pushl  (%eax)
  80158e:	e8 a8 fb ff ff       	call   80113b <dev_lookup>
  801593:	83 c4 10             	add    $0x10,%esp
  801596:	85 c0                	test   %eax,%eax
  801598:	78 37                	js     8015d1 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80159a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80159d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015a1:	74 32                	je     8015d5 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015a3:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015a6:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015ad:	00 00 00 
	stat->st_isdir = 0;
  8015b0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015b7:	00 00 00 
	stat->st_dev = dev;
  8015ba:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015c0:	83 ec 08             	sub    $0x8,%esp
  8015c3:	53                   	push   %ebx
  8015c4:	ff 75 f0             	pushl  -0x10(%ebp)
  8015c7:	ff 50 14             	call   *0x14(%eax)
  8015ca:	89 c2                	mov    %eax,%edx
  8015cc:	83 c4 10             	add    $0x10,%esp
  8015cf:	eb 09                	jmp    8015da <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d1:	89 c2                	mov    %eax,%edx
  8015d3:	eb 05                	jmp    8015da <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8015d5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8015da:	89 d0                	mov    %edx,%eax
  8015dc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015df:	c9                   	leave  
  8015e0:	c3                   	ret    

008015e1 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015e1:	55                   	push   %ebp
  8015e2:	89 e5                	mov    %esp,%ebp
  8015e4:	56                   	push   %esi
  8015e5:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015e6:	83 ec 08             	sub    $0x8,%esp
  8015e9:	6a 00                	push   $0x0
  8015eb:	ff 75 08             	pushl  0x8(%ebp)
  8015ee:	e8 e3 01 00 00       	call   8017d6 <open>
  8015f3:	89 c3                	mov    %eax,%ebx
  8015f5:	83 c4 10             	add    $0x10,%esp
  8015f8:	85 c0                	test   %eax,%eax
  8015fa:	78 1b                	js     801617 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8015fc:	83 ec 08             	sub    $0x8,%esp
  8015ff:	ff 75 0c             	pushl  0xc(%ebp)
  801602:	50                   	push   %eax
  801603:	e8 5b ff ff ff       	call   801563 <fstat>
  801608:	89 c6                	mov    %eax,%esi
	close(fd);
  80160a:	89 1c 24             	mov    %ebx,(%esp)
  80160d:	e8 fd fb ff ff       	call   80120f <close>
	return r;
  801612:	83 c4 10             	add    $0x10,%esp
  801615:	89 f0                	mov    %esi,%eax
}
  801617:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80161a:	5b                   	pop    %ebx
  80161b:	5e                   	pop    %esi
  80161c:	5d                   	pop    %ebp
  80161d:	c3                   	ret    

0080161e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80161e:	55                   	push   %ebp
  80161f:	89 e5                	mov    %esp,%ebp
  801621:	56                   	push   %esi
  801622:	53                   	push   %ebx
  801623:	89 c6                	mov    %eax,%esi
  801625:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801627:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80162e:	75 12                	jne    801642 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801630:	83 ec 0c             	sub    $0xc,%esp
  801633:	6a 01                	push   $0x1
  801635:	e8 48 0c 00 00       	call   802282 <ipc_find_env>
  80163a:	a3 00 50 80 00       	mov    %eax,0x805000
  80163f:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801642:	6a 07                	push   $0x7
  801644:	68 00 70 80 00       	push   $0x807000
  801649:	56                   	push   %esi
  80164a:	ff 35 00 50 80 00    	pushl  0x805000
  801650:	e8 d9 0b 00 00       	call   80222e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801655:	83 c4 0c             	add    $0xc,%esp
  801658:	6a 00                	push   $0x0
  80165a:	53                   	push   %ebx
  80165b:	6a 00                	push   $0x0
  80165d:	e8 77 0b 00 00       	call   8021d9 <ipc_recv>
}
  801662:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801665:	5b                   	pop    %ebx
  801666:	5e                   	pop    %esi
  801667:	5d                   	pop    %ebp
  801668:	c3                   	ret    

00801669 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801669:	55                   	push   %ebp
  80166a:	89 e5                	mov    %esp,%ebp
  80166c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80166f:	8b 45 08             	mov    0x8(%ebp),%eax
  801672:	8b 40 0c             	mov    0xc(%eax),%eax
  801675:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  80167a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80167d:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801682:	ba 00 00 00 00       	mov    $0x0,%edx
  801687:	b8 02 00 00 00       	mov    $0x2,%eax
  80168c:	e8 8d ff ff ff       	call   80161e <fsipc>
}
  801691:	c9                   	leave  
  801692:	c3                   	ret    

00801693 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801693:	55                   	push   %ebp
  801694:	89 e5                	mov    %esp,%ebp
  801696:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801699:	8b 45 08             	mov    0x8(%ebp),%eax
  80169c:	8b 40 0c             	mov    0xc(%eax),%eax
  80169f:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  8016a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a9:	b8 06 00 00 00       	mov    $0x6,%eax
  8016ae:	e8 6b ff ff ff       	call   80161e <fsipc>
}
  8016b3:	c9                   	leave  
  8016b4:	c3                   	ret    

008016b5 <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016b5:	55                   	push   %ebp
  8016b6:	89 e5                	mov    %esp,%ebp
  8016b8:	53                   	push   %ebx
  8016b9:	83 ec 04             	sub    $0x4,%esp
  8016bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c2:	8b 40 0c             	mov    0xc(%eax),%eax
  8016c5:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8016cf:	b8 05 00 00 00       	mov    $0x5,%eax
  8016d4:	e8 45 ff ff ff       	call   80161e <fsipc>
  8016d9:	85 c0                	test   %eax,%eax
  8016db:	78 2c                	js     801709 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016dd:	83 ec 08             	sub    $0x8,%esp
  8016e0:	68 00 70 80 00       	push   $0x807000
  8016e5:	53                   	push   %ebx
  8016e6:	e8 90 f3 ff ff       	call   800a7b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016eb:	a1 80 70 80 00       	mov    0x807080,%eax
  8016f0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016f6:	a1 84 70 80 00       	mov    0x807084,%eax
  8016fb:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801701:	83 c4 10             	add    $0x10,%esp
  801704:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801709:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80170c:	c9                   	leave  
  80170d:	c3                   	ret    

0080170e <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80170e:	55                   	push   %ebp
  80170f:	89 e5                	mov    %esp,%ebp
  801711:	83 ec 0c             	sub    $0xc,%esp
  801714:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
    
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  801717:	8b 55 08             	mov    0x8(%ebp),%edx
  80171a:	8b 52 0c             	mov    0xc(%edx),%edx
  80171d:	89 15 00 70 80 00    	mov    %edx,0x807000
    fsipcbuf.write.req_n = MIN(n, PGSIZE);
  801723:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801728:	ba 00 10 00 00       	mov    $0x1000,%edx
  80172d:	0f 47 c2             	cmova  %edx,%eax
  801730:	a3 04 70 80 00       	mov    %eax,0x807004
    memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801735:	50                   	push   %eax
  801736:	ff 75 0c             	pushl  0xc(%ebp)
  801739:	68 08 70 80 00       	push   $0x807008
  80173e:	e8 ca f4 ff ff       	call   800c0d <memmove>
    int r = fsipc(FSREQ_WRITE, NULL);
  801743:	ba 00 00 00 00       	mov    $0x0,%edx
  801748:	b8 04 00 00 00       	mov    $0x4,%eax
  80174d:	e8 cc fe ff ff       	call   80161e <fsipc>
    return r;
}
  801752:	c9                   	leave  
  801753:	c3                   	ret    

00801754 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801754:	55                   	push   %ebp
  801755:	89 e5                	mov    %esp,%ebp
  801757:	56                   	push   %esi
  801758:	53                   	push   %ebx
  801759:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80175c:	8b 45 08             	mov    0x8(%ebp),%eax
  80175f:	8b 40 0c             	mov    0xc(%eax),%eax
  801762:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  801767:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80176d:	ba 00 00 00 00       	mov    $0x0,%edx
  801772:	b8 03 00 00 00       	mov    $0x3,%eax
  801777:	e8 a2 fe ff ff       	call   80161e <fsipc>
  80177c:	89 c3                	mov    %eax,%ebx
  80177e:	85 c0                	test   %eax,%eax
  801780:	78 4b                	js     8017cd <devfile_read+0x79>
		return r;
	assert(r <= n);
  801782:	39 c6                	cmp    %eax,%esi
  801784:	73 16                	jae    80179c <devfile_read+0x48>
  801786:	68 d8 2a 80 00       	push   $0x802ad8
  80178b:	68 df 2a 80 00       	push   $0x802adf
  801790:	6a 7c                	push   $0x7c
  801792:	68 f4 2a 80 00       	push   $0x802af4
  801797:	e8 63 ec ff ff       	call   8003ff <_panic>
	assert(r <= PGSIZE);
  80179c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017a1:	7e 16                	jle    8017b9 <devfile_read+0x65>
  8017a3:	68 ff 2a 80 00       	push   $0x802aff
  8017a8:	68 df 2a 80 00       	push   $0x802adf
  8017ad:	6a 7d                	push   $0x7d
  8017af:	68 f4 2a 80 00       	push   $0x802af4
  8017b4:	e8 46 ec ff ff       	call   8003ff <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017b9:	83 ec 04             	sub    $0x4,%esp
  8017bc:	50                   	push   %eax
  8017bd:	68 00 70 80 00       	push   $0x807000
  8017c2:	ff 75 0c             	pushl  0xc(%ebp)
  8017c5:	e8 43 f4 ff ff       	call   800c0d <memmove>
	return r;
  8017ca:	83 c4 10             	add    $0x10,%esp
}
  8017cd:	89 d8                	mov    %ebx,%eax
  8017cf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017d2:	5b                   	pop    %ebx
  8017d3:	5e                   	pop    %esi
  8017d4:	5d                   	pop    %ebp
  8017d5:	c3                   	ret    

008017d6 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017d6:	55                   	push   %ebp
  8017d7:	89 e5                	mov    %esp,%ebp
  8017d9:	53                   	push   %ebx
  8017da:	83 ec 20             	sub    $0x20,%esp
  8017dd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8017e0:	53                   	push   %ebx
  8017e1:	e8 5c f2 ff ff       	call   800a42 <strlen>
  8017e6:	83 c4 10             	add    $0x10,%esp
  8017e9:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017ee:	7f 67                	jg     801857 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017f0:	83 ec 0c             	sub    $0xc,%esp
  8017f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017f6:	50                   	push   %eax
  8017f7:	e8 9a f8 ff ff       	call   801096 <fd_alloc>
  8017fc:	83 c4 10             	add    $0x10,%esp
		return r;
  8017ff:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801801:	85 c0                	test   %eax,%eax
  801803:	78 57                	js     80185c <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801805:	83 ec 08             	sub    $0x8,%esp
  801808:	53                   	push   %ebx
  801809:	68 00 70 80 00       	push   $0x807000
  80180e:	e8 68 f2 ff ff       	call   800a7b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801813:	8b 45 0c             	mov    0xc(%ebp),%eax
  801816:	a3 00 74 80 00       	mov    %eax,0x807400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80181b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80181e:	b8 01 00 00 00       	mov    $0x1,%eax
  801823:	e8 f6 fd ff ff       	call   80161e <fsipc>
  801828:	89 c3                	mov    %eax,%ebx
  80182a:	83 c4 10             	add    $0x10,%esp
  80182d:	85 c0                	test   %eax,%eax
  80182f:	79 14                	jns    801845 <open+0x6f>
		fd_close(fd, 0);
  801831:	83 ec 08             	sub    $0x8,%esp
  801834:	6a 00                	push   $0x0
  801836:	ff 75 f4             	pushl  -0xc(%ebp)
  801839:	e8 50 f9 ff ff       	call   80118e <fd_close>
		return r;
  80183e:	83 c4 10             	add    $0x10,%esp
  801841:	89 da                	mov    %ebx,%edx
  801843:	eb 17                	jmp    80185c <open+0x86>
	}

	return fd2num(fd);
  801845:	83 ec 0c             	sub    $0xc,%esp
  801848:	ff 75 f4             	pushl  -0xc(%ebp)
  80184b:	e8 1f f8 ff ff       	call   80106f <fd2num>
  801850:	89 c2                	mov    %eax,%edx
  801852:	83 c4 10             	add    $0x10,%esp
  801855:	eb 05                	jmp    80185c <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801857:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80185c:	89 d0                	mov    %edx,%eax
  80185e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801861:	c9                   	leave  
  801862:	c3                   	ret    

00801863 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801863:	55                   	push   %ebp
  801864:	89 e5                	mov    %esp,%ebp
  801866:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801869:	ba 00 00 00 00       	mov    $0x0,%edx
  80186e:	b8 08 00 00 00       	mov    $0x8,%eax
  801873:	e8 a6 fd ff ff       	call   80161e <fsipc>
}
  801878:	c9                   	leave  
  801879:	c3                   	ret    

0080187a <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  80187a:	55                   	push   %ebp
  80187b:	89 e5                	mov    %esp,%ebp
  80187d:	57                   	push   %edi
  80187e:	56                   	push   %esi
  80187f:	53                   	push   %ebx
  801880:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801886:	6a 00                	push   $0x0
  801888:	ff 75 08             	pushl  0x8(%ebp)
  80188b:	e8 46 ff ff ff       	call   8017d6 <open>
  801890:	89 c7                	mov    %eax,%edi
  801892:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801898:	83 c4 10             	add    $0x10,%esp
  80189b:	85 c0                	test   %eax,%eax
  80189d:	0f 88 ae 04 00 00    	js     801d51 <spawn+0x4d7>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8018a3:	83 ec 04             	sub    $0x4,%esp
  8018a6:	68 00 02 00 00       	push   $0x200
  8018ab:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8018b1:	50                   	push   %eax
  8018b2:	57                   	push   %edi
  8018b3:	e8 24 fb ff ff       	call   8013dc <readn>
  8018b8:	83 c4 10             	add    $0x10,%esp
  8018bb:	3d 00 02 00 00       	cmp    $0x200,%eax
  8018c0:	75 0c                	jne    8018ce <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  8018c2:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8018c9:	45 4c 46 
  8018cc:	74 33                	je     801901 <spawn+0x87>
		close(fd);
  8018ce:	83 ec 0c             	sub    $0xc,%esp
  8018d1:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8018d7:	e8 33 f9 ff ff       	call   80120f <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8018dc:	83 c4 0c             	add    $0xc,%esp
  8018df:	68 7f 45 4c 46       	push   $0x464c457f
  8018e4:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  8018ea:	68 0b 2b 80 00       	push   $0x802b0b
  8018ef:	e8 e4 eb ff ff       	call   8004d8 <cprintf>
		return -E_NOT_EXEC;
  8018f4:	83 c4 10             	add    $0x10,%esp
  8018f7:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  8018fc:	e9 b0 04 00 00       	jmp    801db1 <spawn+0x537>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801901:	b8 07 00 00 00       	mov    $0x7,%eax
  801906:	cd 30                	int    $0x30
  801908:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  80190e:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801914:	85 c0                	test   %eax,%eax
  801916:	0f 88 3d 04 00 00    	js     801d59 <spawn+0x4df>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  80191c:	89 c6                	mov    %eax,%esi
  80191e:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801924:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801927:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  80192d:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801933:	b9 11 00 00 00       	mov    $0x11,%ecx
  801938:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  80193a:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801940:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801946:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  80194b:	be 00 00 00 00       	mov    $0x0,%esi
  801950:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801953:	eb 13                	jmp    801968 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801955:	83 ec 0c             	sub    $0xc,%esp
  801958:	50                   	push   %eax
  801959:	e8 e4 f0 ff ff       	call   800a42 <strlen>
  80195e:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801962:	83 c3 01             	add    $0x1,%ebx
  801965:	83 c4 10             	add    $0x10,%esp
  801968:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  80196f:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801972:	85 c0                	test   %eax,%eax
  801974:	75 df                	jne    801955 <spawn+0xdb>
  801976:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  80197c:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801982:	bf 00 10 40 00       	mov    $0x401000,%edi
  801987:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801989:	89 fa                	mov    %edi,%edx
  80198b:	83 e2 fc             	and    $0xfffffffc,%edx
  80198e:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801995:	29 c2                	sub    %eax,%edx
  801997:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  80199d:	8d 42 f8             	lea    -0x8(%edx),%eax
  8019a0:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8019a5:	0f 86 be 03 00 00    	jbe    801d69 <spawn+0x4ef>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8019ab:	83 ec 04             	sub    $0x4,%esp
  8019ae:	6a 07                	push   $0x7
  8019b0:	68 00 00 40 00       	push   $0x400000
  8019b5:	6a 00                	push   $0x0
  8019b7:	e8 c2 f4 ff ff       	call   800e7e <sys_page_alloc>
  8019bc:	83 c4 10             	add    $0x10,%esp
  8019bf:	85 c0                	test   %eax,%eax
  8019c1:	0f 88 a9 03 00 00    	js     801d70 <spawn+0x4f6>
  8019c7:	be 00 00 00 00       	mov    $0x0,%esi
  8019cc:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  8019d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019d5:	eb 30                	jmp    801a07 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  8019d7:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  8019dd:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  8019e3:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  8019e6:	83 ec 08             	sub    $0x8,%esp
  8019e9:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8019ec:	57                   	push   %edi
  8019ed:	e8 89 f0 ff ff       	call   800a7b <strcpy>
		string_store += strlen(argv[i]) + 1;
  8019f2:	83 c4 04             	add    $0x4,%esp
  8019f5:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8019f8:	e8 45 f0 ff ff       	call   800a42 <strlen>
  8019fd:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801a01:	83 c6 01             	add    $0x1,%esi
  801a04:	83 c4 10             	add    $0x10,%esp
  801a07:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801a0d:	7f c8                	jg     8019d7 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801a0f:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801a15:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801a1b:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801a22:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801a28:	74 19                	je     801a43 <spawn+0x1c9>
  801a2a:	68 80 2b 80 00       	push   $0x802b80
  801a2f:	68 df 2a 80 00       	push   $0x802adf
  801a34:	68 f2 00 00 00       	push   $0xf2
  801a39:	68 25 2b 80 00       	push   $0x802b25
  801a3e:	e8 bc e9 ff ff       	call   8003ff <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801a43:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801a49:	89 f8                	mov    %edi,%eax
  801a4b:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801a50:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801a53:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801a59:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801a5c:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801a62:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801a68:	83 ec 0c             	sub    $0xc,%esp
  801a6b:	6a 07                	push   $0x7
  801a6d:	68 00 d0 bf ee       	push   $0xeebfd000
  801a72:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801a78:	68 00 00 40 00       	push   $0x400000
  801a7d:	6a 00                	push   $0x0
  801a7f:	e8 3d f4 ff ff       	call   800ec1 <sys_page_map>
  801a84:	89 c3                	mov    %eax,%ebx
  801a86:	83 c4 20             	add    $0x20,%esp
  801a89:	85 c0                	test   %eax,%eax
  801a8b:	0f 88 0e 03 00 00    	js     801d9f <spawn+0x525>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801a91:	83 ec 08             	sub    $0x8,%esp
  801a94:	68 00 00 40 00       	push   $0x400000
  801a99:	6a 00                	push   $0x0
  801a9b:	e8 63 f4 ff ff       	call   800f03 <sys_page_unmap>
  801aa0:	89 c3                	mov    %eax,%ebx
  801aa2:	83 c4 10             	add    $0x10,%esp
  801aa5:	85 c0                	test   %eax,%eax
  801aa7:	0f 88 f2 02 00 00    	js     801d9f <spawn+0x525>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801aad:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801ab3:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801aba:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801ac0:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801ac7:	00 00 00 
  801aca:	e9 88 01 00 00       	jmp    801c57 <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  801acf:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801ad5:	83 38 01             	cmpl   $0x1,(%eax)
  801ad8:	0f 85 6b 01 00 00    	jne    801c49 <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801ade:	89 c7                	mov    %eax,%edi
  801ae0:	8b 40 18             	mov    0x18(%eax),%eax
  801ae3:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801ae9:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801aec:	83 f8 01             	cmp    $0x1,%eax
  801aef:	19 c0                	sbb    %eax,%eax
  801af1:	83 e0 fe             	and    $0xfffffffe,%eax
  801af4:	83 c0 07             	add    $0x7,%eax
  801af7:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801afd:	89 f8                	mov    %edi,%eax
  801aff:	8b 7f 04             	mov    0x4(%edi),%edi
  801b02:	89 f9                	mov    %edi,%ecx
  801b04:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801b0a:	8b 78 10             	mov    0x10(%eax),%edi
  801b0d:	8b 50 14             	mov    0x14(%eax),%edx
  801b10:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  801b16:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801b19:	89 f0                	mov    %esi,%eax
  801b1b:	25 ff 0f 00 00       	and    $0xfff,%eax
  801b20:	74 14                	je     801b36 <spawn+0x2bc>
		va -= i;
  801b22:	29 c6                	sub    %eax,%esi
		memsz += i;
  801b24:	01 c2                	add    %eax,%edx
  801b26:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  801b2c:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801b2e:	29 c1                	sub    %eax,%ecx
  801b30:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801b36:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b3b:	e9 f7 00 00 00       	jmp    801c37 <spawn+0x3bd>
		if (i >= filesz) {
  801b40:	39 df                	cmp    %ebx,%edi
  801b42:	77 27                	ja     801b6b <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801b44:	83 ec 04             	sub    $0x4,%esp
  801b47:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801b4d:	56                   	push   %esi
  801b4e:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801b54:	e8 25 f3 ff ff       	call   800e7e <sys_page_alloc>
  801b59:	83 c4 10             	add    $0x10,%esp
  801b5c:	85 c0                	test   %eax,%eax
  801b5e:	0f 89 c7 00 00 00    	jns    801c2b <spawn+0x3b1>
  801b64:	89 c3                	mov    %eax,%ebx
  801b66:	e9 13 02 00 00       	jmp    801d7e <spawn+0x504>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801b6b:	83 ec 04             	sub    $0x4,%esp
  801b6e:	6a 07                	push   $0x7
  801b70:	68 00 00 40 00       	push   $0x400000
  801b75:	6a 00                	push   $0x0
  801b77:	e8 02 f3 ff ff       	call   800e7e <sys_page_alloc>
  801b7c:	83 c4 10             	add    $0x10,%esp
  801b7f:	85 c0                	test   %eax,%eax
  801b81:	0f 88 ed 01 00 00    	js     801d74 <spawn+0x4fa>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801b87:	83 ec 08             	sub    $0x8,%esp
  801b8a:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801b90:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801b96:	50                   	push   %eax
  801b97:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801b9d:	e8 0f f9 ff ff       	call   8014b1 <seek>
  801ba2:	83 c4 10             	add    $0x10,%esp
  801ba5:	85 c0                	test   %eax,%eax
  801ba7:	0f 88 cb 01 00 00    	js     801d78 <spawn+0x4fe>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801bad:	83 ec 04             	sub    $0x4,%esp
  801bb0:	89 f8                	mov    %edi,%eax
  801bb2:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801bb8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801bbd:	ba 00 10 00 00       	mov    $0x1000,%edx
  801bc2:	0f 47 c2             	cmova  %edx,%eax
  801bc5:	50                   	push   %eax
  801bc6:	68 00 00 40 00       	push   $0x400000
  801bcb:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801bd1:	e8 06 f8 ff ff       	call   8013dc <readn>
  801bd6:	83 c4 10             	add    $0x10,%esp
  801bd9:	85 c0                	test   %eax,%eax
  801bdb:	0f 88 9b 01 00 00    	js     801d7c <spawn+0x502>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801be1:	83 ec 0c             	sub    $0xc,%esp
  801be4:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801bea:	56                   	push   %esi
  801beb:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801bf1:	68 00 00 40 00       	push   $0x400000
  801bf6:	6a 00                	push   $0x0
  801bf8:	e8 c4 f2 ff ff       	call   800ec1 <sys_page_map>
  801bfd:	83 c4 20             	add    $0x20,%esp
  801c00:	85 c0                	test   %eax,%eax
  801c02:	79 15                	jns    801c19 <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  801c04:	50                   	push   %eax
  801c05:	68 31 2b 80 00       	push   $0x802b31
  801c0a:	68 25 01 00 00       	push   $0x125
  801c0f:	68 25 2b 80 00       	push   $0x802b25
  801c14:	e8 e6 e7 ff ff       	call   8003ff <_panic>
			sys_page_unmap(0, UTEMP);
  801c19:	83 ec 08             	sub    $0x8,%esp
  801c1c:	68 00 00 40 00       	push   $0x400000
  801c21:	6a 00                	push   $0x0
  801c23:	e8 db f2 ff ff       	call   800f03 <sys_page_unmap>
  801c28:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801c2b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801c31:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801c37:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801c3d:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  801c43:	0f 87 f7 fe ff ff    	ja     801b40 <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801c49:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801c50:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801c57:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801c5e:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801c64:	0f 8c 65 fe ff ff    	jl     801acf <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801c6a:	83 ec 0c             	sub    $0xc,%esp
  801c6d:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801c73:	e8 97 f5 ff ff       	call   80120f <close>
  801c78:	83 c4 10             	add    $0x10,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
   	uintptr_t addr;
	for (addr = 0; addr < UTOP; addr += PGSIZE) {
  801c7b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c80:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) &&(uvpt[PGNUM(addr)] & PTE_U) && (uvpt[PGNUM(addr)] & PTE_SHARE)) {
  801c86:	89 d8                	mov    %ebx,%eax
  801c88:	c1 e8 16             	shr    $0x16,%eax
  801c8b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801c92:	a8 01                	test   $0x1,%al
  801c94:	74 46                	je     801cdc <spawn+0x462>
  801c96:	89 d8                	mov    %ebx,%eax
  801c98:	c1 e8 0c             	shr    $0xc,%eax
  801c9b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801ca2:	f6 c2 01             	test   $0x1,%dl
  801ca5:	74 35                	je     801cdc <spawn+0x462>
  801ca7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801cae:	f6 c2 04             	test   $0x4,%dl
  801cb1:	74 29                	je     801cdc <spawn+0x462>
  801cb3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801cba:	f6 c6 04             	test   $0x4,%dh
  801cbd:	74 1d                	je     801cdc <spawn+0x462>
			// cprintf("copy shared page %d to env:%x\n", PGNUM(addr), child);
            		sys_page_map(0, (void*)addr, child, (void*)addr, (uvpt[PGNUM(addr)] & PTE_SYSCALL));
  801cbf:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801cc6:	83 ec 0c             	sub    $0xc,%esp
  801cc9:	25 07 0e 00 00       	and    $0xe07,%eax
  801cce:	50                   	push   %eax
  801ccf:	53                   	push   %ebx
  801cd0:	56                   	push   %esi
  801cd1:	53                   	push   %ebx
  801cd2:	6a 00                	push   $0x0
  801cd4:	e8 e8 f1 ff ff       	call   800ec1 <sys_page_map>
  801cd9:	83 c4 20             	add    $0x20,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
   	uintptr_t addr;
	for (addr = 0; addr < UTOP; addr += PGSIZE) {
  801cdc:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801ce2:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801ce8:	75 9c                	jne    801c86 <spawn+0x40c>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801cea:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801cf1:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801cf4:	83 ec 08             	sub    $0x8,%esp
  801cf7:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801cfd:	50                   	push   %eax
  801cfe:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801d04:	e8 7e f2 ff ff       	call   800f87 <sys_env_set_trapframe>
  801d09:	83 c4 10             	add    $0x10,%esp
  801d0c:	85 c0                	test   %eax,%eax
  801d0e:	79 15                	jns    801d25 <spawn+0x4ab>
		panic("sys_env_set_trapframe: %e", r);
  801d10:	50                   	push   %eax
  801d11:	68 4e 2b 80 00       	push   $0x802b4e
  801d16:	68 86 00 00 00       	push   $0x86
  801d1b:	68 25 2b 80 00       	push   $0x802b25
  801d20:	e8 da e6 ff ff       	call   8003ff <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801d25:	83 ec 08             	sub    $0x8,%esp
  801d28:	6a 02                	push   $0x2
  801d2a:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801d30:	e8 10 f2 ff ff       	call   800f45 <sys_env_set_status>
  801d35:	83 c4 10             	add    $0x10,%esp
  801d38:	85 c0                	test   %eax,%eax
  801d3a:	79 25                	jns    801d61 <spawn+0x4e7>
		panic("sys_env_set_status: %e", r);
  801d3c:	50                   	push   %eax
  801d3d:	68 68 2b 80 00       	push   $0x802b68
  801d42:	68 89 00 00 00       	push   $0x89
  801d47:	68 25 2b 80 00       	push   $0x802b25
  801d4c:	e8 ae e6 ff ff       	call   8003ff <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801d51:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801d57:	eb 58                	jmp    801db1 <spawn+0x537>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801d59:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801d5f:	eb 50                	jmp    801db1 <spawn+0x537>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801d61:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801d67:	eb 48                	jmp    801db1 <spawn+0x537>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801d69:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801d6e:	eb 41                	jmp    801db1 <spawn+0x537>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801d70:	89 c3                	mov    %eax,%ebx
  801d72:	eb 3d                	jmp    801db1 <spawn+0x537>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801d74:	89 c3                	mov    %eax,%ebx
  801d76:	eb 06                	jmp    801d7e <spawn+0x504>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801d78:	89 c3                	mov    %eax,%ebx
  801d7a:	eb 02                	jmp    801d7e <spawn+0x504>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801d7c:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801d7e:	83 ec 0c             	sub    $0xc,%esp
  801d81:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801d87:	e8 73 f0 ff ff       	call   800dff <sys_env_destroy>
	close(fd);
  801d8c:	83 c4 04             	add    $0x4,%esp
  801d8f:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801d95:	e8 75 f4 ff ff       	call   80120f <close>
	return r;
  801d9a:	83 c4 10             	add    $0x10,%esp
  801d9d:	eb 12                	jmp    801db1 <spawn+0x537>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801d9f:	83 ec 08             	sub    $0x8,%esp
  801da2:	68 00 00 40 00       	push   $0x400000
  801da7:	6a 00                	push   $0x0
  801da9:	e8 55 f1 ff ff       	call   800f03 <sys_page_unmap>
  801dae:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801db1:	89 d8                	mov    %ebx,%eax
  801db3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801db6:	5b                   	pop    %ebx
  801db7:	5e                   	pop    %esi
  801db8:	5f                   	pop    %edi
  801db9:	5d                   	pop    %ebp
  801dba:	c3                   	ret    

00801dbb <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801dbb:	55                   	push   %ebp
  801dbc:	89 e5                	mov    %esp,%ebp
  801dbe:	56                   	push   %esi
  801dbf:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801dc0:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801dc3:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801dc8:	eb 03                	jmp    801dcd <spawnl+0x12>
		argc++;
  801dca:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801dcd:	83 c2 04             	add    $0x4,%edx
  801dd0:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801dd4:	75 f4                	jne    801dca <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801dd6:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801ddd:	83 e2 f0             	and    $0xfffffff0,%edx
  801de0:	29 d4                	sub    %edx,%esp
  801de2:	8d 54 24 03          	lea    0x3(%esp),%edx
  801de6:	c1 ea 02             	shr    $0x2,%edx
  801de9:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801df0:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801df2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801df5:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801dfc:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801e03:	00 
  801e04:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801e06:	b8 00 00 00 00       	mov    $0x0,%eax
  801e0b:	eb 0a                	jmp    801e17 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801e0d:	83 c0 01             	add    $0x1,%eax
  801e10:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801e14:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801e17:	39 d0                	cmp    %edx,%eax
  801e19:	75 f2                	jne    801e0d <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801e1b:	83 ec 08             	sub    $0x8,%esp
  801e1e:	56                   	push   %esi
  801e1f:	ff 75 08             	pushl  0x8(%ebp)
  801e22:	e8 53 fa ff ff       	call   80187a <spawn>
}
  801e27:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e2a:	5b                   	pop    %ebx
  801e2b:	5e                   	pop    %esi
  801e2c:	5d                   	pop    %ebp
  801e2d:	c3                   	ret    

00801e2e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e2e:	55                   	push   %ebp
  801e2f:	89 e5                	mov    %esp,%ebp
  801e31:	56                   	push   %esi
  801e32:	53                   	push   %ebx
  801e33:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e36:	83 ec 0c             	sub    $0xc,%esp
  801e39:	ff 75 08             	pushl  0x8(%ebp)
  801e3c:	e8 3e f2 ff ff       	call   80107f <fd2data>
  801e41:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e43:	83 c4 08             	add    $0x8,%esp
  801e46:	68 a8 2b 80 00       	push   $0x802ba8
  801e4b:	53                   	push   %ebx
  801e4c:	e8 2a ec ff ff       	call   800a7b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e51:	8b 46 04             	mov    0x4(%esi),%eax
  801e54:	2b 06                	sub    (%esi),%eax
  801e56:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801e5c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801e63:	00 00 00 
	stat->st_dev = &devpipe;
  801e66:	c7 83 88 00 00 00 ac 	movl   $0x8047ac,0x88(%ebx)
  801e6d:	47 80 00 
	return 0;
}
  801e70:	b8 00 00 00 00       	mov    $0x0,%eax
  801e75:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e78:	5b                   	pop    %ebx
  801e79:	5e                   	pop    %esi
  801e7a:	5d                   	pop    %ebp
  801e7b:	c3                   	ret    

00801e7c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e7c:	55                   	push   %ebp
  801e7d:	89 e5                	mov    %esp,%ebp
  801e7f:	53                   	push   %ebx
  801e80:	83 ec 0c             	sub    $0xc,%esp
  801e83:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e86:	53                   	push   %ebx
  801e87:	6a 00                	push   $0x0
  801e89:	e8 75 f0 ff ff       	call   800f03 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e8e:	89 1c 24             	mov    %ebx,(%esp)
  801e91:	e8 e9 f1 ff ff       	call   80107f <fd2data>
  801e96:	83 c4 08             	add    $0x8,%esp
  801e99:	50                   	push   %eax
  801e9a:	6a 00                	push   $0x0
  801e9c:	e8 62 f0 ff ff       	call   800f03 <sys_page_unmap>
}
  801ea1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ea4:	c9                   	leave  
  801ea5:	c3                   	ret    

00801ea6 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ea6:	55                   	push   %ebp
  801ea7:	89 e5                	mov    %esp,%ebp
  801ea9:	57                   	push   %edi
  801eaa:	56                   	push   %esi
  801eab:	53                   	push   %ebx
  801eac:	83 ec 1c             	sub    $0x1c,%esp
  801eaf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801eb2:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801eb4:	a1 90 67 80 00       	mov    0x806790,%eax
  801eb9:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801ebc:	83 ec 0c             	sub    $0xc,%esp
  801ebf:	ff 75 e0             	pushl  -0x20(%ebp)
  801ec2:	e8 f4 03 00 00       	call   8022bb <pageref>
  801ec7:	89 c3                	mov    %eax,%ebx
  801ec9:	89 3c 24             	mov    %edi,(%esp)
  801ecc:	e8 ea 03 00 00       	call   8022bb <pageref>
  801ed1:	83 c4 10             	add    $0x10,%esp
  801ed4:	39 c3                	cmp    %eax,%ebx
  801ed6:	0f 94 c1             	sete   %cl
  801ed9:	0f b6 c9             	movzbl %cl,%ecx
  801edc:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801edf:	8b 15 90 67 80 00    	mov    0x806790,%edx
  801ee5:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ee8:	39 ce                	cmp    %ecx,%esi
  801eea:	74 1b                	je     801f07 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801eec:	39 c3                	cmp    %eax,%ebx
  801eee:	75 c4                	jne    801eb4 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ef0:	8b 42 58             	mov    0x58(%edx),%eax
  801ef3:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ef6:	50                   	push   %eax
  801ef7:	56                   	push   %esi
  801ef8:	68 af 2b 80 00       	push   $0x802baf
  801efd:	e8 d6 e5 ff ff       	call   8004d8 <cprintf>
  801f02:	83 c4 10             	add    $0x10,%esp
  801f05:	eb ad                	jmp    801eb4 <_pipeisclosed+0xe>
	}
}
  801f07:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f0d:	5b                   	pop    %ebx
  801f0e:	5e                   	pop    %esi
  801f0f:	5f                   	pop    %edi
  801f10:	5d                   	pop    %ebp
  801f11:	c3                   	ret    

00801f12 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f12:	55                   	push   %ebp
  801f13:	89 e5                	mov    %esp,%ebp
  801f15:	57                   	push   %edi
  801f16:	56                   	push   %esi
  801f17:	53                   	push   %ebx
  801f18:	83 ec 28             	sub    $0x28,%esp
  801f1b:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801f1e:	56                   	push   %esi
  801f1f:	e8 5b f1 ff ff       	call   80107f <fd2data>
  801f24:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f26:	83 c4 10             	add    $0x10,%esp
  801f29:	bf 00 00 00 00       	mov    $0x0,%edi
  801f2e:	eb 4b                	jmp    801f7b <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801f30:	89 da                	mov    %ebx,%edx
  801f32:	89 f0                	mov    %esi,%eax
  801f34:	e8 6d ff ff ff       	call   801ea6 <_pipeisclosed>
  801f39:	85 c0                	test   %eax,%eax
  801f3b:	75 48                	jne    801f85 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801f3d:	e8 1d ef ff ff       	call   800e5f <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f42:	8b 43 04             	mov    0x4(%ebx),%eax
  801f45:	8b 0b                	mov    (%ebx),%ecx
  801f47:	8d 51 20             	lea    0x20(%ecx),%edx
  801f4a:	39 d0                	cmp    %edx,%eax
  801f4c:	73 e2                	jae    801f30 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f51:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801f55:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801f58:	89 c2                	mov    %eax,%edx
  801f5a:	c1 fa 1f             	sar    $0x1f,%edx
  801f5d:	89 d1                	mov    %edx,%ecx
  801f5f:	c1 e9 1b             	shr    $0x1b,%ecx
  801f62:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801f65:	83 e2 1f             	and    $0x1f,%edx
  801f68:	29 ca                	sub    %ecx,%edx
  801f6a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801f6e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f72:	83 c0 01             	add    $0x1,%eax
  801f75:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f78:	83 c7 01             	add    $0x1,%edi
  801f7b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f7e:	75 c2                	jne    801f42 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801f80:	8b 45 10             	mov    0x10(%ebp),%eax
  801f83:	eb 05                	jmp    801f8a <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f85:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801f8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f8d:	5b                   	pop    %ebx
  801f8e:	5e                   	pop    %esi
  801f8f:	5f                   	pop    %edi
  801f90:	5d                   	pop    %ebp
  801f91:	c3                   	ret    

00801f92 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f92:	55                   	push   %ebp
  801f93:	89 e5                	mov    %esp,%ebp
  801f95:	57                   	push   %edi
  801f96:	56                   	push   %esi
  801f97:	53                   	push   %ebx
  801f98:	83 ec 18             	sub    $0x18,%esp
  801f9b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801f9e:	57                   	push   %edi
  801f9f:	e8 db f0 ff ff       	call   80107f <fd2data>
  801fa4:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fa6:	83 c4 10             	add    $0x10,%esp
  801fa9:	bb 00 00 00 00       	mov    $0x0,%ebx
  801fae:	eb 3d                	jmp    801fed <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801fb0:	85 db                	test   %ebx,%ebx
  801fb2:	74 04                	je     801fb8 <devpipe_read+0x26>
				return i;
  801fb4:	89 d8                	mov    %ebx,%eax
  801fb6:	eb 44                	jmp    801ffc <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801fb8:	89 f2                	mov    %esi,%edx
  801fba:	89 f8                	mov    %edi,%eax
  801fbc:	e8 e5 fe ff ff       	call   801ea6 <_pipeisclosed>
  801fc1:	85 c0                	test   %eax,%eax
  801fc3:	75 32                	jne    801ff7 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801fc5:	e8 95 ee ff ff       	call   800e5f <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801fca:	8b 06                	mov    (%esi),%eax
  801fcc:	3b 46 04             	cmp    0x4(%esi),%eax
  801fcf:	74 df                	je     801fb0 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801fd1:	99                   	cltd   
  801fd2:	c1 ea 1b             	shr    $0x1b,%edx
  801fd5:	01 d0                	add    %edx,%eax
  801fd7:	83 e0 1f             	and    $0x1f,%eax
  801fda:	29 d0                	sub    %edx,%eax
  801fdc:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801fe1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fe4:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801fe7:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fea:	83 c3 01             	add    $0x1,%ebx
  801fed:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801ff0:	75 d8                	jne    801fca <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801ff2:	8b 45 10             	mov    0x10(%ebp),%eax
  801ff5:	eb 05                	jmp    801ffc <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ff7:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801ffc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fff:	5b                   	pop    %ebx
  802000:	5e                   	pop    %esi
  802001:	5f                   	pop    %edi
  802002:	5d                   	pop    %ebp
  802003:	c3                   	ret    

00802004 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802004:	55                   	push   %ebp
  802005:	89 e5                	mov    %esp,%ebp
  802007:	56                   	push   %esi
  802008:	53                   	push   %ebx
  802009:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80200c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80200f:	50                   	push   %eax
  802010:	e8 81 f0 ff ff       	call   801096 <fd_alloc>
  802015:	83 c4 10             	add    $0x10,%esp
  802018:	89 c2                	mov    %eax,%edx
  80201a:	85 c0                	test   %eax,%eax
  80201c:	0f 88 2c 01 00 00    	js     80214e <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802022:	83 ec 04             	sub    $0x4,%esp
  802025:	68 07 04 00 00       	push   $0x407
  80202a:	ff 75 f4             	pushl  -0xc(%ebp)
  80202d:	6a 00                	push   $0x0
  80202f:	e8 4a ee ff ff       	call   800e7e <sys_page_alloc>
  802034:	83 c4 10             	add    $0x10,%esp
  802037:	89 c2                	mov    %eax,%edx
  802039:	85 c0                	test   %eax,%eax
  80203b:	0f 88 0d 01 00 00    	js     80214e <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802041:	83 ec 0c             	sub    $0xc,%esp
  802044:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802047:	50                   	push   %eax
  802048:	e8 49 f0 ff ff       	call   801096 <fd_alloc>
  80204d:	89 c3                	mov    %eax,%ebx
  80204f:	83 c4 10             	add    $0x10,%esp
  802052:	85 c0                	test   %eax,%eax
  802054:	0f 88 e2 00 00 00    	js     80213c <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80205a:	83 ec 04             	sub    $0x4,%esp
  80205d:	68 07 04 00 00       	push   $0x407
  802062:	ff 75 f0             	pushl  -0x10(%ebp)
  802065:	6a 00                	push   $0x0
  802067:	e8 12 ee ff ff       	call   800e7e <sys_page_alloc>
  80206c:	89 c3                	mov    %eax,%ebx
  80206e:	83 c4 10             	add    $0x10,%esp
  802071:	85 c0                	test   %eax,%eax
  802073:	0f 88 c3 00 00 00    	js     80213c <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802079:	83 ec 0c             	sub    $0xc,%esp
  80207c:	ff 75 f4             	pushl  -0xc(%ebp)
  80207f:	e8 fb ef ff ff       	call   80107f <fd2data>
  802084:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802086:	83 c4 0c             	add    $0xc,%esp
  802089:	68 07 04 00 00       	push   $0x407
  80208e:	50                   	push   %eax
  80208f:	6a 00                	push   $0x0
  802091:	e8 e8 ed ff ff       	call   800e7e <sys_page_alloc>
  802096:	89 c3                	mov    %eax,%ebx
  802098:	83 c4 10             	add    $0x10,%esp
  80209b:	85 c0                	test   %eax,%eax
  80209d:	0f 88 89 00 00 00    	js     80212c <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020a3:	83 ec 0c             	sub    $0xc,%esp
  8020a6:	ff 75 f0             	pushl  -0x10(%ebp)
  8020a9:	e8 d1 ef ff ff       	call   80107f <fd2data>
  8020ae:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8020b5:	50                   	push   %eax
  8020b6:	6a 00                	push   $0x0
  8020b8:	56                   	push   %esi
  8020b9:	6a 00                	push   $0x0
  8020bb:	e8 01 ee ff ff       	call   800ec1 <sys_page_map>
  8020c0:	89 c3                	mov    %eax,%ebx
  8020c2:	83 c4 20             	add    $0x20,%esp
  8020c5:	85 c0                	test   %eax,%eax
  8020c7:	78 55                	js     80211e <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8020c9:	8b 15 ac 47 80 00    	mov    0x8047ac,%edx
  8020cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020d2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8020d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020d7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8020de:	8b 15 ac 47 80 00    	mov    0x8047ac,%edx
  8020e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020e7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8020e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020ec:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8020f3:	83 ec 0c             	sub    $0xc,%esp
  8020f6:	ff 75 f4             	pushl  -0xc(%ebp)
  8020f9:	e8 71 ef ff ff       	call   80106f <fd2num>
  8020fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802101:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802103:	83 c4 04             	add    $0x4,%esp
  802106:	ff 75 f0             	pushl  -0x10(%ebp)
  802109:	e8 61 ef ff ff       	call   80106f <fd2num>
  80210e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802111:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802114:	83 c4 10             	add    $0x10,%esp
  802117:	ba 00 00 00 00       	mov    $0x0,%edx
  80211c:	eb 30                	jmp    80214e <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80211e:	83 ec 08             	sub    $0x8,%esp
  802121:	56                   	push   %esi
  802122:	6a 00                	push   $0x0
  802124:	e8 da ed ff ff       	call   800f03 <sys_page_unmap>
  802129:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80212c:	83 ec 08             	sub    $0x8,%esp
  80212f:	ff 75 f0             	pushl  -0x10(%ebp)
  802132:	6a 00                	push   $0x0
  802134:	e8 ca ed ff ff       	call   800f03 <sys_page_unmap>
  802139:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80213c:	83 ec 08             	sub    $0x8,%esp
  80213f:	ff 75 f4             	pushl  -0xc(%ebp)
  802142:	6a 00                	push   $0x0
  802144:	e8 ba ed ff ff       	call   800f03 <sys_page_unmap>
  802149:	83 c4 10             	add    $0x10,%esp
  80214c:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80214e:	89 d0                	mov    %edx,%eax
  802150:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802153:	5b                   	pop    %ebx
  802154:	5e                   	pop    %esi
  802155:	5d                   	pop    %ebp
  802156:	c3                   	ret    

00802157 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802157:	55                   	push   %ebp
  802158:	89 e5                	mov    %esp,%ebp
  80215a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80215d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802160:	50                   	push   %eax
  802161:	ff 75 08             	pushl  0x8(%ebp)
  802164:	e8 7c ef ff ff       	call   8010e5 <fd_lookup>
  802169:	83 c4 10             	add    $0x10,%esp
  80216c:	85 c0                	test   %eax,%eax
  80216e:	78 18                	js     802188 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802170:	83 ec 0c             	sub    $0xc,%esp
  802173:	ff 75 f4             	pushl  -0xc(%ebp)
  802176:	e8 04 ef ff ff       	call   80107f <fd2data>
	return _pipeisclosed(fd, p);
  80217b:	89 c2                	mov    %eax,%edx
  80217d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802180:	e8 21 fd ff ff       	call   801ea6 <_pipeisclosed>
  802185:	83 c4 10             	add    $0x10,%esp
}
  802188:	c9                   	leave  
  802189:	c3                   	ret    

0080218a <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  80218a:	55                   	push   %ebp
  80218b:	89 e5                	mov    %esp,%ebp
  80218d:	56                   	push   %esi
  80218e:	53                   	push   %ebx
  80218f:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802192:	85 f6                	test   %esi,%esi
  802194:	75 16                	jne    8021ac <wait+0x22>
  802196:	68 c7 2b 80 00       	push   $0x802bc7
  80219b:	68 df 2a 80 00       	push   $0x802adf
  8021a0:	6a 09                	push   $0x9
  8021a2:	68 d2 2b 80 00       	push   $0x802bd2
  8021a7:	e8 53 e2 ff ff       	call   8003ff <_panic>
	e = &envs[ENVX(envid)];
  8021ac:	89 f3                	mov    %esi,%ebx
  8021ae:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8021b4:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  8021b7:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  8021bd:	eb 05                	jmp    8021c4 <wait+0x3a>
		sys_yield();
  8021bf:	e8 9b ec ff ff       	call   800e5f <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8021c4:	8b 43 48             	mov    0x48(%ebx),%eax
  8021c7:	39 c6                	cmp    %eax,%esi
  8021c9:	75 07                	jne    8021d2 <wait+0x48>
  8021cb:	8b 43 54             	mov    0x54(%ebx),%eax
  8021ce:	85 c0                	test   %eax,%eax
  8021d0:	75 ed                	jne    8021bf <wait+0x35>
		sys_yield();
}
  8021d2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021d5:	5b                   	pop    %ebx
  8021d6:	5e                   	pop    %esi
  8021d7:	5d                   	pop    %ebp
  8021d8:	c3                   	ret    

008021d9 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8021d9:	55                   	push   %ebp
  8021da:	89 e5                	mov    %esp,%ebp
  8021dc:	56                   	push   %esi
  8021dd:	53                   	push   %ebx
  8021de:	8b 75 08             	mov    0x8(%ebp),%esi
  8021e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021e4:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_recv not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  8021e7:	85 c0                	test   %eax,%eax
  8021e9:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8021ee:	0f 44 c2             	cmove  %edx,%eax

    int r = sys_ipc_recv(pg);
  8021f1:	83 ec 0c             	sub    $0xc,%esp
  8021f4:	50                   	push   %eax
  8021f5:	e8 34 ee ff ff       	call   80102e <sys_ipc_recv>
    int from_env = 0, perm = 0;
    if (r == 0) {
  8021fa:	83 c4 10             	add    $0x10,%esp
  8021fd:	85 c0                	test   %eax,%eax
  8021ff:	75 10                	jne    802211 <ipc_recv+0x38>
        from_env = thisenv->env_ipc_from;
  802201:	a1 90 67 80 00       	mov    0x806790,%eax
  802206:	8b 48 74             	mov    0x74(%eax),%ecx
        perm = thisenv->env_ipc_perm;
  802209:	8b 50 78             	mov    0x78(%eax),%edx
        r = thisenv->env_ipc_value;
  80220c:	8b 40 70             	mov    0x70(%eax),%eax
  80220f:	eb 0a                	jmp    80221b <ipc_recv+0x42>
    } else {
        from_env = 0;
        perm = 0;
  802211:	ba 00 00 00 00       	mov    $0x0,%edx
    if (r == 0) {
        from_env = thisenv->env_ipc_from;
        perm = thisenv->env_ipc_perm;
        r = thisenv->env_ipc_value;
    } else {
        from_env = 0;
  802216:	b9 00 00 00 00       	mov    $0x0,%ecx
        perm = 0;
    }

    if (from_env_store) *from_env_store = from_env;
  80221b:	85 f6                	test   %esi,%esi
  80221d:	74 02                	je     802221 <ipc_recv+0x48>
  80221f:	89 0e                	mov    %ecx,(%esi)
    if (perm_store) *perm_store = perm;
  802221:	85 db                	test   %ebx,%ebx
  802223:	74 02                	je     802227 <ipc_recv+0x4e>
  802225:	89 13                	mov    %edx,(%ebx)

    return r;
}
  802227:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80222a:	5b                   	pop    %ebx
  80222b:	5e                   	pop    %esi
  80222c:	5d                   	pop    %ebp
  80222d:	c3                   	ret    

0080222e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80222e:	55                   	push   %ebp
  80222f:	89 e5                	mov    %esp,%ebp
  802231:	57                   	push   %edi
  802232:	56                   	push   %esi
  802233:	53                   	push   %ebx
  802234:	83 ec 0c             	sub    $0xc,%esp
  802237:	8b 7d 08             	mov    0x8(%ebp),%edi
  80223a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80223d:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  802240:	85 db                	test   %ebx,%ebx
  802242:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802247:	0f 44 d8             	cmove  %eax,%ebx
  80224a:	eb 1c                	jmp    802268 <ipc_send+0x3a>

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        if (ret != -E_IPC_NOT_RECV)
  80224c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80224f:	74 12                	je     802263 <ipc_send+0x35>
            panic("ipc_send error %e", ret);
  802251:	50                   	push   %eax
  802252:	68 dd 2b 80 00       	push   $0x802bdd
  802257:	6a 40                	push   $0x40
  802259:	68 ef 2b 80 00       	push   $0x802bef
  80225e:	e8 9c e1 ff ff       	call   8003ff <_panic>
        sys_yield();
  802263:	e8 f7 eb ff ff       	call   800e5f <sys_yield>
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  802268:	ff 75 14             	pushl  0x14(%ebp)
  80226b:	53                   	push   %ebx
  80226c:	56                   	push   %esi
  80226d:	57                   	push   %edi
  80226e:	e8 98 ed ff ff       	call   80100b <sys_ipc_try_send>
  802273:	83 c4 10             	add    $0x10,%esp
  802276:	85 c0                	test   %eax,%eax
  802278:	75 d2                	jne    80224c <ipc_send+0x1e>
        if (ret != -E_IPC_NOT_RECV)
            panic("ipc_send error %e", ret);
        sys_yield();
    }
}
  80227a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80227d:	5b                   	pop    %ebx
  80227e:	5e                   	pop    %esi
  80227f:	5f                   	pop    %edi
  802280:	5d                   	pop    %ebp
  802281:	c3                   	ret    

00802282 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802282:	55                   	push   %ebp
  802283:	89 e5                	mov    %esp,%ebp
  802285:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802288:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80228d:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802290:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802296:	8b 52 50             	mov    0x50(%edx),%edx
  802299:	39 ca                	cmp    %ecx,%edx
  80229b:	75 0d                	jne    8022aa <ipc_find_env+0x28>
			return envs[i].env_id;
  80229d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8022a0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8022a5:	8b 40 48             	mov    0x48(%eax),%eax
  8022a8:	eb 0f                	jmp    8022b9 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8022aa:	83 c0 01             	add    $0x1,%eax
  8022ad:	3d 00 04 00 00       	cmp    $0x400,%eax
  8022b2:	75 d9                	jne    80228d <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8022b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8022b9:	5d                   	pop    %ebp
  8022ba:	c3                   	ret    

008022bb <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8022bb:	55                   	push   %ebp
  8022bc:	89 e5                	mov    %esp,%ebp
  8022be:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8022c1:	89 d0                	mov    %edx,%eax
  8022c3:	c1 e8 16             	shr    $0x16,%eax
  8022c6:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8022cd:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8022d2:	f6 c1 01             	test   $0x1,%cl
  8022d5:	74 1d                	je     8022f4 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8022d7:	c1 ea 0c             	shr    $0xc,%edx
  8022da:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8022e1:	f6 c2 01             	test   $0x1,%dl
  8022e4:	74 0e                	je     8022f4 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8022e6:	c1 ea 0c             	shr    $0xc,%edx
  8022e9:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8022f0:	ef 
  8022f1:	0f b7 c0             	movzwl %ax,%eax
}
  8022f4:	5d                   	pop    %ebp
  8022f5:	c3                   	ret    
  8022f6:	66 90                	xchg   %ax,%ax
  8022f8:	66 90                	xchg   %ax,%ax
  8022fa:	66 90                	xchg   %ax,%ax
  8022fc:	66 90                	xchg   %ax,%ax
  8022fe:	66 90                	xchg   %ax,%ax

00802300 <__udivdi3>:
  802300:	55                   	push   %ebp
  802301:	57                   	push   %edi
  802302:	56                   	push   %esi
  802303:	53                   	push   %ebx
  802304:	83 ec 1c             	sub    $0x1c,%esp
  802307:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80230b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80230f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802313:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802317:	85 f6                	test   %esi,%esi
  802319:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80231d:	89 ca                	mov    %ecx,%edx
  80231f:	89 f8                	mov    %edi,%eax
  802321:	75 3d                	jne    802360 <__udivdi3+0x60>
  802323:	39 cf                	cmp    %ecx,%edi
  802325:	0f 87 c5 00 00 00    	ja     8023f0 <__udivdi3+0xf0>
  80232b:	85 ff                	test   %edi,%edi
  80232d:	89 fd                	mov    %edi,%ebp
  80232f:	75 0b                	jne    80233c <__udivdi3+0x3c>
  802331:	b8 01 00 00 00       	mov    $0x1,%eax
  802336:	31 d2                	xor    %edx,%edx
  802338:	f7 f7                	div    %edi
  80233a:	89 c5                	mov    %eax,%ebp
  80233c:	89 c8                	mov    %ecx,%eax
  80233e:	31 d2                	xor    %edx,%edx
  802340:	f7 f5                	div    %ebp
  802342:	89 c1                	mov    %eax,%ecx
  802344:	89 d8                	mov    %ebx,%eax
  802346:	89 cf                	mov    %ecx,%edi
  802348:	f7 f5                	div    %ebp
  80234a:	89 c3                	mov    %eax,%ebx
  80234c:	89 d8                	mov    %ebx,%eax
  80234e:	89 fa                	mov    %edi,%edx
  802350:	83 c4 1c             	add    $0x1c,%esp
  802353:	5b                   	pop    %ebx
  802354:	5e                   	pop    %esi
  802355:	5f                   	pop    %edi
  802356:	5d                   	pop    %ebp
  802357:	c3                   	ret    
  802358:	90                   	nop
  802359:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802360:	39 ce                	cmp    %ecx,%esi
  802362:	77 74                	ja     8023d8 <__udivdi3+0xd8>
  802364:	0f bd fe             	bsr    %esi,%edi
  802367:	83 f7 1f             	xor    $0x1f,%edi
  80236a:	0f 84 98 00 00 00    	je     802408 <__udivdi3+0x108>
  802370:	bb 20 00 00 00       	mov    $0x20,%ebx
  802375:	89 f9                	mov    %edi,%ecx
  802377:	89 c5                	mov    %eax,%ebp
  802379:	29 fb                	sub    %edi,%ebx
  80237b:	d3 e6                	shl    %cl,%esi
  80237d:	89 d9                	mov    %ebx,%ecx
  80237f:	d3 ed                	shr    %cl,%ebp
  802381:	89 f9                	mov    %edi,%ecx
  802383:	d3 e0                	shl    %cl,%eax
  802385:	09 ee                	or     %ebp,%esi
  802387:	89 d9                	mov    %ebx,%ecx
  802389:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80238d:	89 d5                	mov    %edx,%ebp
  80238f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802393:	d3 ed                	shr    %cl,%ebp
  802395:	89 f9                	mov    %edi,%ecx
  802397:	d3 e2                	shl    %cl,%edx
  802399:	89 d9                	mov    %ebx,%ecx
  80239b:	d3 e8                	shr    %cl,%eax
  80239d:	09 c2                	or     %eax,%edx
  80239f:	89 d0                	mov    %edx,%eax
  8023a1:	89 ea                	mov    %ebp,%edx
  8023a3:	f7 f6                	div    %esi
  8023a5:	89 d5                	mov    %edx,%ebp
  8023a7:	89 c3                	mov    %eax,%ebx
  8023a9:	f7 64 24 0c          	mull   0xc(%esp)
  8023ad:	39 d5                	cmp    %edx,%ebp
  8023af:	72 10                	jb     8023c1 <__udivdi3+0xc1>
  8023b1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8023b5:	89 f9                	mov    %edi,%ecx
  8023b7:	d3 e6                	shl    %cl,%esi
  8023b9:	39 c6                	cmp    %eax,%esi
  8023bb:	73 07                	jae    8023c4 <__udivdi3+0xc4>
  8023bd:	39 d5                	cmp    %edx,%ebp
  8023bf:	75 03                	jne    8023c4 <__udivdi3+0xc4>
  8023c1:	83 eb 01             	sub    $0x1,%ebx
  8023c4:	31 ff                	xor    %edi,%edi
  8023c6:	89 d8                	mov    %ebx,%eax
  8023c8:	89 fa                	mov    %edi,%edx
  8023ca:	83 c4 1c             	add    $0x1c,%esp
  8023cd:	5b                   	pop    %ebx
  8023ce:	5e                   	pop    %esi
  8023cf:	5f                   	pop    %edi
  8023d0:	5d                   	pop    %ebp
  8023d1:	c3                   	ret    
  8023d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023d8:	31 ff                	xor    %edi,%edi
  8023da:	31 db                	xor    %ebx,%ebx
  8023dc:	89 d8                	mov    %ebx,%eax
  8023de:	89 fa                	mov    %edi,%edx
  8023e0:	83 c4 1c             	add    $0x1c,%esp
  8023e3:	5b                   	pop    %ebx
  8023e4:	5e                   	pop    %esi
  8023e5:	5f                   	pop    %edi
  8023e6:	5d                   	pop    %ebp
  8023e7:	c3                   	ret    
  8023e8:	90                   	nop
  8023e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023f0:	89 d8                	mov    %ebx,%eax
  8023f2:	f7 f7                	div    %edi
  8023f4:	31 ff                	xor    %edi,%edi
  8023f6:	89 c3                	mov    %eax,%ebx
  8023f8:	89 d8                	mov    %ebx,%eax
  8023fa:	89 fa                	mov    %edi,%edx
  8023fc:	83 c4 1c             	add    $0x1c,%esp
  8023ff:	5b                   	pop    %ebx
  802400:	5e                   	pop    %esi
  802401:	5f                   	pop    %edi
  802402:	5d                   	pop    %ebp
  802403:	c3                   	ret    
  802404:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802408:	39 ce                	cmp    %ecx,%esi
  80240a:	72 0c                	jb     802418 <__udivdi3+0x118>
  80240c:	31 db                	xor    %ebx,%ebx
  80240e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802412:	0f 87 34 ff ff ff    	ja     80234c <__udivdi3+0x4c>
  802418:	bb 01 00 00 00       	mov    $0x1,%ebx
  80241d:	e9 2a ff ff ff       	jmp    80234c <__udivdi3+0x4c>
  802422:	66 90                	xchg   %ax,%ax
  802424:	66 90                	xchg   %ax,%ax
  802426:	66 90                	xchg   %ax,%ax
  802428:	66 90                	xchg   %ax,%ax
  80242a:	66 90                	xchg   %ax,%ax
  80242c:	66 90                	xchg   %ax,%ax
  80242e:	66 90                	xchg   %ax,%ax

00802430 <__umoddi3>:
  802430:	55                   	push   %ebp
  802431:	57                   	push   %edi
  802432:	56                   	push   %esi
  802433:	53                   	push   %ebx
  802434:	83 ec 1c             	sub    $0x1c,%esp
  802437:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80243b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80243f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802443:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802447:	85 d2                	test   %edx,%edx
  802449:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80244d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802451:	89 f3                	mov    %esi,%ebx
  802453:	89 3c 24             	mov    %edi,(%esp)
  802456:	89 74 24 04          	mov    %esi,0x4(%esp)
  80245a:	75 1c                	jne    802478 <__umoddi3+0x48>
  80245c:	39 f7                	cmp    %esi,%edi
  80245e:	76 50                	jbe    8024b0 <__umoddi3+0x80>
  802460:	89 c8                	mov    %ecx,%eax
  802462:	89 f2                	mov    %esi,%edx
  802464:	f7 f7                	div    %edi
  802466:	89 d0                	mov    %edx,%eax
  802468:	31 d2                	xor    %edx,%edx
  80246a:	83 c4 1c             	add    $0x1c,%esp
  80246d:	5b                   	pop    %ebx
  80246e:	5e                   	pop    %esi
  80246f:	5f                   	pop    %edi
  802470:	5d                   	pop    %ebp
  802471:	c3                   	ret    
  802472:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802478:	39 f2                	cmp    %esi,%edx
  80247a:	89 d0                	mov    %edx,%eax
  80247c:	77 52                	ja     8024d0 <__umoddi3+0xa0>
  80247e:	0f bd ea             	bsr    %edx,%ebp
  802481:	83 f5 1f             	xor    $0x1f,%ebp
  802484:	75 5a                	jne    8024e0 <__umoddi3+0xb0>
  802486:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80248a:	0f 82 e0 00 00 00    	jb     802570 <__umoddi3+0x140>
  802490:	39 0c 24             	cmp    %ecx,(%esp)
  802493:	0f 86 d7 00 00 00    	jbe    802570 <__umoddi3+0x140>
  802499:	8b 44 24 08          	mov    0x8(%esp),%eax
  80249d:	8b 54 24 04          	mov    0x4(%esp),%edx
  8024a1:	83 c4 1c             	add    $0x1c,%esp
  8024a4:	5b                   	pop    %ebx
  8024a5:	5e                   	pop    %esi
  8024a6:	5f                   	pop    %edi
  8024a7:	5d                   	pop    %ebp
  8024a8:	c3                   	ret    
  8024a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024b0:	85 ff                	test   %edi,%edi
  8024b2:	89 fd                	mov    %edi,%ebp
  8024b4:	75 0b                	jne    8024c1 <__umoddi3+0x91>
  8024b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8024bb:	31 d2                	xor    %edx,%edx
  8024bd:	f7 f7                	div    %edi
  8024bf:	89 c5                	mov    %eax,%ebp
  8024c1:	89 f0                	mov    %esi,%eax
  8024c3:	31 d2                	xor    %edx,%edx
  8024c5:	f7 f5                	div    %ebp
  8024c7:	89 c8                	mov    %ecx,%eax
  8024c9:	f7 f5                	div    %ebp
  8024cb:	89 d0                	mov    %edx,%eax
  8024cd:	eb 99                	jmp    802468 <__umoddi3+0x38>
  8024cf:	90                   	nop
  8024d0:	89 c8                	mov    %ecx,%eax
  8024d2:	89 f2                	mov    %esi,%edx
  8024d4:	83 c4 1c             	add    $0x1c,%esp
  8024d7:	5b                   	pop    %ebx
  8024d8:	5e                   	pop    %esi
  8024d9:	5f                   	pop    %edi
  8024da:	5d                   	pop    %ebp
  8024db:	c3                   	ret    
  8024dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8024e0:	8b 34 24             	mov    (%esp),%esi
  8024e3:	bf 20 00 00 00       	mov    $0x20,%edi
  8024e8:	89 e9                	mov    %ebp,%ecx
  8024ea:	29 ef                	sub    %ebp,%edi
  8024ec:	d3 e0                	shl    %cl,%eax
  8024ee:	89 f9                	mov    %edi,%ecx
  8024f0:	89 f2                	mov    %esi,%edx
  8024f2:	d3 ea                	shr    %cl,%edx
  8024f4:	89 e9                	mov    %ebp,%ecx
  8024f6:	09 c2                	or     %eax,%edx
  8024f8:	89 d8                	mov    %ebx,%eax
  8024fa:	89 14 24             	mov    %edx,(%esp)
  8024fd:	89 f2                	mov    %esi,%edx
  8024ff:	d3 e2                	shl    %cl,%edx
  802501:	89 f9                	mov    %edi,%ecx
  802503:	89 54 24 04          	mov    %edx,0x4(%esp)
  802507:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80250b:	d3 e8                	shr    %cl,%eax
  80250d:	89 e9                	mov    %ebp,%ecx
  80250f:	89 c6                	mov    %eax,%esi
  802511:	d3 e3                	shl    %cl,%ebx
  802513:	89 f9                	mov    %edi,%ecx
  802515:	89 d0                	mov    %edx,%eax
  802517:	d3 e8                	shr    %cl,%eax
  802519:	89 e9                	mov    %ebp,%ecx
  80251b:	09 d8                	or     %ebx,%eax
  80251d:	89 d3                	mov    %edx,%ebx
  80251f:	89 f2                	mov    %esi,%edx
  802521:	f7 34 24             	divl   (%esp)
  802524:	89 d6                	mov    %edx,%esi
  802526:	d3 e3                	shl    %cl,%ebx
  802528:	f7 64 24 04          	mull   0x4(%esp)
  80252c:	39 d6                	cmp    %edx,%esi
  80252e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802532:	89 d1                	mov    %edx,%ecx
  802534:	89 c3                	mov    %eax,%ebx
  802536:	72 08                	jb     802540 <__umoddi3+0x110>
  802538:	75 11                	jne    80254b <__umoddi3+0x11b>
  80253a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80253e:	73 0b                	jae    80254b <__umoddi3+0x11b>
  802540:	2b 44 24 04          	sub    0x4(%esp),%eax
  802544:	1b 14 24             	sbb    (%esp),%edx
  802547:	89 d1                	mov    %edx,%ecx
  802549:	89 c3                	mov    %eax,%ebx
  80254b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80254f:	29 da                	sub    %ebx,%edx
  802551:	19 ce                	sbb    %ecx,%esi
  802553:	89 f9                	mov    %edi,%ecx
  802555:	89 f0                	mov    %esi,%eax
  802557:	d3 e0                	shl    %cl,%eax
  802559:	89 e9                	mov    %ebp,%ecx
  80255b:	d3 ea                	shr    %cl,%edx
  80255d:	89 e9                	mov    %ebp,%ecx
  80255f:	d3 ee                	shr    %cl,%esi
  802561:	09 d0                	or     %edx,%eax
  802563:	89 f2                	mov    %esi,%edx
  802565:	83 c4 1c             	add    $0x1c,%esp
  802568:	5b                   	pop    %ebx
  802569:	5e                   	pop    %esi
  80256a:	5f                   	pop    %edi
  80256b:	5d                   	pop    %ebp
  80256c:	c3                   	ret    
  80256d:	8d 76 00             	lea    0x0(%esi),%esi
  802570:	29 f9                	sub    %edi,%ecx
  802572:	19 d6                	sbb    %edx,%esi
  802574:	89 74 24 04          	mov    %esi,0x4(%esp)
  802578:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80257c:	e9 18 ff ff ff       	jmp    802499 <__umoddi3+0x69>
