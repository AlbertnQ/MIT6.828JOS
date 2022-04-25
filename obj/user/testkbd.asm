
obj/user/testkbd.debug:     file format elf32-i386


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
  80002c:	e8 3b 02 00 00       	call   80026c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 04             	sub    $0x4,%esp
  80003a:	bb 0a 00 00 00       	mov    $0xa,%ebx
	int i, r;

	// Spin for a bit to let the console quiet
	for (i = 0; i < 10; ++i)
		sys_yield();
  80003f:	e8 db 0d 00 00       	call   800e1f <sys_yield>
umain(int argc, char **argv)
{
	int i, r;

	// Spin for a bit to let the console quiet
	for (i = 0; i < 10; ++i)
  800044:	83 eb 01             	sub    $0x1,%ebx
  800047:	75 f6                	jne    80003f <umain+0xc>
		sys_yield();

	close(0);
  800049:	83 ec 0c             	sub    $0xc,%esp
  80004c:	6a 00                	push   $0x0
  80004e:	e8 7c 11 00 00       	call   8011cf <close>
	if ((r = opencons()) < 0)
  800053:	e8 ba 01 00 00       	call   800212 <opencons>
  800058:	83 c4 10             	add    $0x10,%esp
  80005b:	85 c0                	test   %eax,%eax
  80005d:	79 12                	jns    800071 <umain+0x3e>
		panic("opencons: %e", r);
  80005f:	50                   	push   %eax
  800060:	68 60 20 80 00       	push   $0x802060
  800065:	6a 0f                	push   $0xf
  800067:	68 6d 20 80 00       	push   $0x80206d
  80006c:	e8 5b 02 00 00       	call   8002cc <_panic>
	if (r != 0)
  800071:	85 c0                	test   %eax,%eax
  800073:	74 12                	je     800087 <umain+0x54>
		panic("first opencons used fd %d", r);
  800075:	50                   	push   %eax
  800076:	68 7c 20 80 00       	push   $0x80207c
  80007b:	6a 11                	push   $0x11
  80007d:	68 6d 20 80 00       	push   $0x80206d
  800082:	e8 45 02 00 00       	call   8002cc <_panic>
	if ((r = dup(0, 1)) < 0)
  800087:	83 ec 08             	sub    $0x8,%esp
  80008a:	6a 01                	push   $0x1
  80008c:	6a 00                	push   $0x0
  80008e:	e8 8c 11 00 00       	call   80121f <dup>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	85 c0                	test   %eax,%eax
  800098:	79 12                	jns    8000ac <umain+0x79>
		panic("dup: %e", r);
  80009a:	50                   	push   %eax
  80009b:	68 96 20 80 00       	push   $0x802096
  8000a0:	6a 13                	push   $0x13
  8000a2:	68 6d 20 80 00       	push   $0x80206d
  8000a7:	e8 20 02 00 00       	call   8002cc <_panic>

	for(;;){
		char *buf;

		buf = readline("Type a line: ");
  8000ac:	83 ec 0c             	sub    $0xc,%esp
  8000af:	68 9e 20 80 00       	push   $0x80209e
  8000b4:	e8 56 08 00 00       	call   80090f <readline>
		if (buf != NULL)
  8000b9:	83 c4 10             	add    $0x10,%esp
  8000bc:	85 c0                	test   %eax,%eax
  8000be:	74 15                	je     8000d5 <umain+0xa2>
			fprintf(1, "%s\n", buf);
  8000c0:	83 ec 04             	sub    $0x4,%esp
  8000c3:	50                   	push   %eax
  8000c4:	68 ac 20 80 00       	push   $0x8020ac
  8000c9:	6a 01                	push   $0x1
  8000cb:	e8 4d 18 00 00       	call   80191d <fprintf>
  8000d0:	83 c4 10             	add    $0x10,%esp
  8000d3:	eb d7                	jmp    8000ac <umain+0x79>
		else
			fprintf(1, "(end of file received)\n");
  8000d5:	83 ec 08             	sub    $0x8,%esp
  8000d8:	68 b0 20 80 00       	push   $0x8020b0
  8000dd:	6a 01                	push   $0x1
  8000df:	e8 39 18 00 00       	call   80191d <fprintf>
  8000e4:	83 c4 10             	add    $0x10,%esp
  8000e7:	eb c3                	jmp    8000ac <umain+0x79>

008000e9 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8000e9:	55                   	push   %ebp
  8000ea:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8000ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8000f1:	5d                   	pop    %ebp
  8000f2:	c3                   	ret    

008000f3 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8000f3:	55                   	push   %ebp
  8000f4:	89 e5                	mov    %esp,%ebp
  8000f6:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8000f9:	68 c8 20 80 00       	push   $0x8020c8
  8000fe:	ff 75 0c             	pushl  0xc(%ebp)
  800101:	e8 35 09 00 00       	call   800a3b <strcpy>
	return 0;
}
  800106:	b8 00 00 00 00       	mov    $0x0,%eax
  80010b:	c9                   	leave  
  80010c:	c3                   	ret    

0080010d <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80010d:	55                   	push   %ebp
  80010e:	89 e5                	mov    %esp,%ebp
  800110:	57                   	push   %edi
  800111:	56                   	push   %esi
  800112:	53                   	push   %ebx
  800113:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800119:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80011e:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800124:	eb 2d                	jmp    800153 <devcons_write+0x46>
		m = n - tot;
  800126:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800129:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80012b:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80012e:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800133:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800136:	83 ec 04             	sub    $0x4,%esp
  800139:	53                   	push   %ebx
  80013a:	03 45 0c             	add    0xc(%ebp),%eax
  80013d:	50                   	push   %eax
  80013e:	57                   	push   %edi
  80013f:	e8 89 0a 00 00       	call   800bcd <memmove>
		sys_cputs(buf, m);
  800144:	83 c4 08             	add    $0x8,%esp
  800147:	53                   	push   %ebx
  800148:	57                   	push   %edi
  800149:	e8 34 0c 00 00       	call   800d82 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80014e:	01 de                	add    %ebx,%esi
  800150:	83 c4 10             	add    $0x10,%esp
  800153:	89 f0                	mov    %esi,%eax
  800155:	3b 75 10             	cmp    0x10(%ebp),%esi
  800158:	72 cc                	jb     800126 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80015a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80015d:	5b                   	pop    %ebx
  80015e:	5e                   	pop    %esi
  80015f:	5f                   	pop    %edi
  800160:	5d                   	pop    %ebp
  800161:	c3                   	ret    

00800162 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	83 ec 08             	sub    $0x8,%esp
  800168:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80016d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800171:	74 2a                	je     80019d <devcons_read+0x3b>
  800173:	eb 05                	jmp    80017a <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800175:	e8 a5 0c 00 00       	call   800e1f <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80017a:	e8 21 0c 00 00       	call   800da0 <sys_cgetc>
  80017f:	85 c0                	test   %eax,%eax
  800181:	74 f2                	je     800175 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800183:	85 c0                	test   %eax,%eax
  800185:	78 16                	js     80019d <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800187:	83 f8 04             	cmp    $0x4,%eax
  80018a:	74 0c                	je     800198 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80018c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80018f:	88 02                	mov    %al,(%edx)
	return 1;
  800191:	b8 01 00 00 00       	mov    $0x1,%eax
  800196:	eb 05                	jmp    80019d <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800198:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80019d:	c9                   	leave  
  80019e:	c3                   	ret    

0080019f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80019f:	55                   	push   %ebp
  8001a0:	89 e5                	mov    %esp,%ebp
  8001a2:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8001a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a8:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8001ab:	6a 01                	push   $0x1
  8001ad:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8001b0:	50                   	push   %eax
  8001b1:	e8 cc 0b 00 00       	call   800d82 <sys_cputs>
}
  8001b6:	83 c4 10             	add    $0x10,%esp
  8001b9:	c9                   	leave  
  8001ba:	c3                   	ret    

008001bb <getchar>:

int
getchar(void)
{
  8001bb:	55                   	push   %ebp
  8001bc:	89 e5                	mov    %esp,%ebp
  8001be:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8001c1:	6a 01                	push   $0x1
  8001c3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8001c6:	50                   	push   %eax
  8001c7:	6a 00                	push   $0x0
  8001c9:	e8 3d 11 00 00       	call   80130b <read>
	if (r < 0)
  8001ce:	83 c4 10             	add    $0x10,%esp
  8001d1:	85 c0                	test   %eax,%eax
  8001d3:	78 0f                	js     8001e4 <getchar+0x29>
		return r;
	if (r < 1)
  8001d5:	85 c0                	test   %eax,%eax
  8001d7:	7e 06                	jle    8001df <getchar+0x24>
		return -E_EOF;
	return c;
  8001d9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8001dd:	eb 05                	jmp    8001e4 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8001df:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8001e4:	c9                   	leave  
  8001e5:	c3                   	ret    

008001e6 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8001e6:	55                   	push   %ebp
  8001e7:	89 e5                	mov    %esp,%ebp
  8001e9:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8001ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8001ef:	50                   	push   %eax
  8001f0:	ff 75 08             	pushl  0x8(%ebp)
  8001f3:	e8 ad 0e 00 00       	call   8010a5 <fd_lookup>
  8001f8:	83 c4 10             	add    $0x10,%esp
  8001fb:	85 c0                	test   %eax,%eax
  8001fd:	78 11                	js     800210 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8001ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800202:	8b 15 00 30 80 00    	mov    0x803000,%edx
  800208:	39 10                	cmp    %edx,(%eax)
  80020a:	0f 94 c0             	sete   %al
  80020d:	0f b6 c0             	movzbl %al,%eax
}
  800210:	c9                   	leave  
  800211:	c3                   	ret    

00800212 <opencons>:

int
opencons(void)
{
  800212:	55                   	push   %ebp
  800213:	89 e5                	mov    %esp,%ebp
  800215:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800218:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80021b:	50                   	push   %eax
  80021c:	e8 35 0e 00 00       	call   801056 <fd_alloc>
  800221:	83 c4 10             	add    $0x10,%esp
		return r;
  800224:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800226:	85 c0                	test   %eax,%eax
  800228:	78 3e                	js     800268 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80022a:	83 ec 04             	sub    $0x4,%esp
  80022d:	68 07 04 00 00       	push   $0x407
  800232:	ff 75 f4             	pushl  -0xc(%ebp)
  800235:	6a 00                	push   $0x0
  800237:	e8 02 0c 00 00       	call   800e3e <sys_page_alloc>
  80023c:	83 c4 10             	add    $0x10,%esp
		return r;
  80023f:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800241:	85 c0                	test   %eax,%eax
  800243:	78 23                	js     800268 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800245:	8b 15 00 30 80 00    	mov    0x803000,%edx
  80024b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80024e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800250:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800253:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80025a:	83 ec 0c             	sub    $0xc,%esp
  80025d:	50                   	push   %eax
  80025e:	e8 cc 0d 00 00       	call   80102f <fd2num>
  800263:	89 c2                	mov    %eax,%edx
  800265:	83 c4 10             	add    $0x10,%esp
}
  800268:	89 d0                	mov    %edx,%eax
  80026a:	c9                   	leave  
  80026b:	c3                   	ret    

0080026c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	56                   	push   %esi
  800270:	53                   	push   %ebx
  800271:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800274:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  800277:	e8 84 0b 00 00       	call   800e00 <sys_getenvid>
  80027c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800281:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800284:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800289:	a3 04 44 80 00       	mov    %eax,0x804404
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80028e:	85 db                	test   %ebx,%ebx
  800290:	7e 07                	jle    800299 <libmain+0x2d>
		binaryname = argv[0];
  800292:	8b 06                	mov    (%esi),%eax
  800294:	a3 1c 30 80 00       	mov    %eax,0x80301c

	// call user main routine
	umain(argc, argv);
  800299:	83 ec 08             	sub    $0x8,%esp
  80029c:	56                   	push   %esi
  80029d:	53                   	push   %ebx
  80029e:	e8 90 fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8002a3:	e8 0a 00 00 00       	call   8002b2 <exit>
}
  8002a8:	83 c4 10             	add    $0x10,%esp
  8002ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002ae:	5b                   	pop    %ebx
  8002af:	5e                   	pop    %esi
  8002b0:	5d                   	pop    %ebp
  8002b1:	c3                   	ret    

008002b2 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002b2:	55                   	push   %ebp
  8002b3:	89 e5                	mov    %esp,%ebp
  8002b5:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8002b8:	e8 3d 0f 00 00       	call   8011fa <close_all>
	sys_env_destroy(0);
  8002bd:	83 ec 0c             	sub    $0xc,%esp
  8002c0:	6a 00                	push   $0x0
  8002c2:	e8 f8 0a 00 00       	call   800dbf <sys_env_destroy>
}
  8002c7:	83 c4 10             	add    $0x10,%esp
  8002ca:	c9                   	leave  
  8002cb:	c3                   	ret    

008002cc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	56                   	push   %esi
  8002d0:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002d1:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002d4:	8b 35 1c 30 80 00    	mov    0x80301c,%esi
  8002da:	e8 21 0b 00 00       	call   800e00 <sys_getenvid>
  8002df:	83 ec 0c             	sub    $0xc,%esp
  8002e2:	ff 75 0c             	pushl  0xc(%ebp)
  8002e5:	ff 75 08             	pushl  0x8(%ebp)
  8002e8:	56                   	push   %esi
  8002e9:	50                   	push   %eax
  8002ea:	68 e0 20 80 00       	push   $0x8020e0
  8002ef:	e8 b1 00 00 00       	call   8003a5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002f4:	83 c4 18             	add    $0x18,%esp
  8002f7:	53                   	push   %ebx
  8002f8:	ff 75 10             	pushl  0x10(%ebp)
  8002fb:	e8 54 00 00 00       	call   800354 <vcprintf>
	cprintf("\n");
  800300:	c7 04 24 c6 20 80 00 	movl   $0x8020c6,(%esp)
  800307:	e8 99 00 00 00       	call   8003a5 <cprintf>
  80030c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80030f:	cc                   	int3   
  800310:	eb fd                	jmp    80030f <_panic+0x43>

00800312 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800312:	55                   	push   %ebp
  800313:	89 e5                	mov    %esp,%ebp
  800315:	53                   	push   %ebx
  800316:	83 ec 04             	sub    $0x4,%esp
  800319:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80031c:	8b 13                	mov    (%ebx),%edx
  80031e:	8d 42 01             	lea    0x1(%edx),%eax
  800321:	89 03                	mov    %eax,(%ebx)
  800323:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800326:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80032a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80032f:	75 1a                	jne    80034b <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800331:	83 ec 08             	sub    $0x8,%esp
  800334:	68 ff 00 00 00       	push   $0xff
  800339:	8d 43 08             	lea    0x8(%ebx),%eax
  80033c:	50                   	push   %eax
  80033d:	e8 40 0a 00 00       	call   800d82 <sys_cputs>
		b->idx = 0;
  800342:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800348:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80034b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80034f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800352:	c9                   	leave  
  800353:	c3                   	ret    

00800354 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
  800357:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80035d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800364:	00 00 00 
	b.cnt = 0;
  800367:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80036e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800371:	ff 75 0c             	pushl  0xc(%ebp)
  800374:	ff 75 08             	pushl  0x8(%ebp)
  800377:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80037d:	50                   	push   %eax
  80037e:	68 12 03 80 00       	push   $0x800312
  800383:	e8 54 01 00 00       	call   8004dc <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800388:	83 c4 08             	add    $0x8,%esp
  80038b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800391:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800397:	50                   	push   %eax
  800398:	e8 e5 09 00 00       	call   800d82 <sys_cputs>

	return b.cnt;
}
  80039d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003a3:	c9                   	leave  
  8003a4:	c3                   	ret    

008003a5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003a5:	55                   	push   %ebp
  8003a6:	89 e5                	mov    %esp,%ebp
  8003a8:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003ab:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003ae:	50                   	push   %eax
  8003af:	ff 75 08             	pushl  0x8(%ebp)
  8003b2:	e8 9d ff ff ff       	call   800354 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003b7:	c9                   	leave  
  8003b8:	c3                   	ret    

008003b9 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003b9:	55                   	push   %ebp
  8003ba:	89 e5                	mov    %esp,%ebp
  8003bc:	57                   	push   %edi
  8003bd:	56                   	push   %esi
  8003be:	53                   	push   %ebx
  8003bf:	83 ec 1c             	sub    $0x1c,%esp
  8003c2:	89 c7                	mov    %eax,%edi
  8003c4:	89 d6                	mov    %edx,%esi
  8003c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003cc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003cf:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003d2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8003d5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003da:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8003dd:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8003e0:	39 d3                	cmp    %edx,%ebx
  8003e2:	72 05                	jb     8003e9 <printnum+0x30>
  8003e4:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003e7:	77 45                	ja     80042e <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003e9:	83 ec 0c             	sub    $0xc,%esp
  8003ec:	ff 75 18             	pushl  0x18(%ebp)
  8003ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f2:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8003f5:	53                   	push   %ebx
  8003f6:	ff 75 10             	pushl  0x10(%ebp)
  8003f9:	83 ec 08             	sub    $0x8,%esp
  8003fc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003ff:	ff 75 e0             	pushl  -0x20(%ebp)
  800402:	ff 75 dc             	pushl  -0x24(%ebp)
  800405:	ff 75 d8             	pushl  -0x28(%ebp)
  800408:	e8 c3 19 00 00       	call   801dd0 <__udivdi3>
  80040d:	83 c4 18             	add    $0x18,%esp
  800410:	52                   	push   %edx
  800411:	50                   	push   %eax
  800412:	89 f2                	mov    %esi,%edx
  800414:	89 f8                	mov    %edi,%eax
  800416:	e8 9e ff ff ff       	call   8003b9 <printnum>
  80041b:	83 c4 20             	add    $0x20,%esp
  80041e:	eb 18                	jmp    800438 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800420:	83 ec 08             	sub    $0x8,%esp
  800423:	56                   	push   %esi
  800424:	ff 75 18             	pushl  0x18(%ebp)
  800427:	ff d7                	call   *%edi
  800429:	83 c4 10             	add    $0x10,%esp
  80042c:	eb 03                	jmp    800431 <printnum+0x78>
  80042e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800431:	83 eb 01             	sub    $0x1,%ebx
  800434:	85 db                	test   %ebx,%ebx
  800436:	7f e8                	jg     800420 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800438:	83 ec 08             	sub    $0x8,%esp
  80043b:	56                   	push   %esi
  80043c:	83 ec 04             	sub    $0x4,%esp
  80043f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800442:	ff 75 e0             	pushl  -0x20(%ebp)
  800445:	ff 75 dc             	pushl  -0x24(%ebp)
  800448:	ff 75 d8             	pushl  -0x28(%ebp)
  80044b:	e8 b0 1a 00 00       	call   801f00 <__umoddi3>
  800450:	83 c4 14             	add    $0x14,%esp
  800453:	0f be 80 03 21 80 00 	movsbl 0x802103(%eax),%eax
  80045a:	50                   	push   %eax
  80045b:	ff d7                	call   *%edi
}
  80045d:	83 c4 10             	add    $0x10,%esp
  800460:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800463:	5b                   	pop    %ebx
  800464:	5e                   	pop    %esi
  800465:	5f                   	pop    %edi
  800466:	5d                   	pop    %ebp
  800467:	c3                   	ret    

00800468 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800468:	55                   	push   %ebp
  800469:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80046b:	83 fa 01             	cmp    $0x1,%edx
  80046e:	7e 0e                	jle    80047e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800470:	8b 10                	mov    (%eax),%edx
  800472:	8d 4a 08             	lea    0x8(%edx),%ecx
  800475:	89 08                	mov    %ecx,(%eax)
  800477:	8b 02                	mov    (%edx),%eax
  800479:	8b 52 04             	mov    0x4(%edx),%edx
  80047c:	eb 22                	jmp    8004a0 <getuint+0x38>
	else if (lflag)
  80047e:	85 d2                	test   %edx,%edx
  800480:	74 10                	je     800492 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800482:	8b 10                	mov    (%eax),%edx
  800484:	8d 4a 04             	lea    0x4(%edx),%ecx
  800487:	89 08                	mov    %ecx,(%eax)
  800489:	8b 02                	mov    (%edx),%eax
  80048b:	ba 00 00 00 00       	mov    $0x0,%edx
  800490:	eb 0e                	jmp    8004a0 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800492:	8b 10                	mov    (%eax),%edx
  800494:	8d 4a 04             	lea    0x4(%edx),%ecx
  800497:	89 08                	mov    %ecx,(%eax)
  800499:	8b 02                	mov    (%edx),%eax
  80049b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004a0:	5d                   	pop    %ebp
  8004a1:	c3                   	ret    

008004a2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004a2:	55                   	push   %ebp
  8004a3:	89 e5                	mov    %esp,%ebp
  8004a5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004a8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004ac:	8b 10                	mov    (%eax),%edx
  8004ae:	3b 50 04             	cmp    0x4(%eax),%edx
  8004b1:	73 0a                	jae    8004bd <sprintputch+0x1b>
		*b->buf++ = ch;
  8004b3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004b6:	89 08                	mov    %ecx,(%eax)
  8004b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8004bb:	88 02                	mov    %al,(%edx)
}
  8004bd:	5d                   	pop    %ebp
  8004be:	c3                   	ret    

008004bf <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004bf:	55                   	push   %ebp
  8004c0:	89 e5                	mov    %esp,%ebp
  8004c2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004c5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004c8:	50                   	push   %eax
  8004c9:	ff 75 10             	pushl  0x10(%ebp)
  8004cc:	ff 75 0c             	pushl  0xc(%ebp)
  8004cf:	ff 75 08             	pushl  0x8(%ebp)
  8004d2:	e8 05 00 00 00       	call   8004dc <vprintfmt>
	va_end(ap);
}
  8004d7:	83 c4 10             	add    $0x10,%esp
  8004da:	c9                   	leave  
  8004db:	c3                   	ret    

008004dc <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004dc:	55                   	push   %ebp
  8004dd:	89 e5                	mov    %esp,%ebp
  8004df:	57                   	push   %edi
  8004e0:	56                   	push   %esi
  8004e1:	53                   	push   %ebx
  8004e2:	83 ec 2c             	sub    $0x2c,%esp
  8004e5:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004eb:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004ee:	eb 12                	jmp    800502 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004f0:	85 c0                	test   %eax,%eax
  8004f2:	0f 84 a7 03 00 00    	je     80089f <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
  8004f8:	83 ec 08             	sub    $0x8,%esp
  8004fb:	53                   	push   %ebx
  8004fc:	50                   	push   %eax
  8004fd:	ff d6                	call   *%esi
  8004ff:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800502:	83 c7 01             	add    $0x1,%edi
  800505:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800509:	83 f8 25             	cmp    $0x25,%eax
  80050c:	75 e2                	jne    8004f0 <vprintfmt+0x14>
  80050e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800512:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800519:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800520:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800527:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80052e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800533:	eb 07                	jmp    80053c <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800535:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800538:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053c:	8d 47 01             	lea    0x1(%edi),%eax
  80053f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800542:	0f b6 07             	movzbl (%edi),%eax
  800545:	0f b6 d0             	movzbl %al,%edx
  800548:	83 e8 23             	sub    $0x23,%eax
  80054b:	3c 55                	cmp    $0x55,%al
  80054d:	0f 87 31 03 00 00    	ja     800884 <vprintfmt+0x3a8>
  800553:	0f b6 c0             	movzbl %al,%eax
  800556:	ff 24 85 40 22 80 00 	jmp    *0x802240(,%eax,4)
  80055d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800560:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800564:	eb d6                	jmp    80053c <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800566:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800569:	b8 00 00 00 00       	mov    $0x0,%eax
  80056e:	89 75 08             	mov    %esi,0x8(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800571:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800574:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800578:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80057b:	8d 72 d0             	lea    -0x30(%edx),%esi
  80057e:	83 fe 09             	cmp    $0x9,%esi
  800581:	77 34                	ja     8005b7 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800583:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800586:	eb e9                	jmp    800571 <vprintfmt+0x95>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800588:	8b 45 14             	mov    0x14(%ebp),%eax
  80058b:	8d 50 04             	lea    0x4(%eax),%edx
  80058e:	89 55 14             	mov    %edx,0x14(%ebp)
  800591:	8b 00                	mov    (%eax),%eax
  800593:	89 45 cc             	mov    %eax,-0x34(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800596:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800599:	eb 22                	jmp    8005bd <vprintfmt+0xe1>
  80059b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80059e:	85 c0                	test   %eax,%eax
  8005a0:	0f 48 c1             	cmovs  %ecx,%eax
  8005a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a9:	eb 91                	jmp    80053c <vprintfmt+0x60>
  8005ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005ae:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005b5:	eb 85                	jmp    80053c <vprintfmt+0x60>
  8005b7:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8005ba:	8b 75 08             	mov    0x8(%ebp),%esi

		process_precision:
			if (width < 0)
  8005bd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005c1:	0f 89 75 ff ff ff    	jns    80053c <vprintfmt+0x60>
				width = precision, precision = -1;
  8005c7:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005ca:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005cd:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8005d4:	e9 63 ff ff ff       	jmp    80053c <vprintfmt+0x60>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005d9:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005e0:	e9 57 ff ff ff       	jmp    80053c <vprintfmt+0x60>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e8:	8d 50 04             	lea    0x4(%eax),%edx
  8005eb:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ee:	83 ec 08             	sub    $0x8,%esp
  8005f1:	53                   	push   %ebx
  8005f2:	ff 30                	pushl  (%eax)
  8005f4:	ff d6                	call   *%esi
			break;
  8005f6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005fc:	e9 01 ff ff ff       	jmp    800502 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800601:	8b 45 14             	mov    0x14(%ebp),%eax
  800604:	8d 50 04             	lea    0x4(%eax),%edx
  800607:	89 55 14             	mov    %edx,0x14(%ebp)
  80060a:	8b 00                	mov    (%eax),%eax
  80060c:	99                   	cltd   
  80060d:	31 d0                	xor    %edx,%eax
  80060f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800611:	83 f8 0f             	cmp    $0xf,%eax
  800614:	7f 0b                	jg     800621 <vprintfmt+0x145>
  800616:	8b 14 85 a0 23 80 00 	mov    0x8023a0(,%eax,4),%edx
  80061d:	85 d2                	test   %edx,%edx
  80061f:	75 18                	jne    800639 <vprintfmt+0x15d>
				printfmt(putch, putdat, "error %d", err);
  800621:	50                   	push   %eax
  800622:	68 1b 21 80 00       	push   $0x80211b
  800627:	53                   	push   %ebx
  800628:	56                   	push   %esi
  800629:	e8 91 fe ff ff       	call   8004bf <printfmt>
  80062e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800631:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800634:	e9 c9 fe ff ff       	jmp    800502 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800639:	52                   	push   %edx
  80063a:	68 e5 24 80 00       	push   $0x8024e5
  80063f:	53                   	push   %ebx
  800640:	56                   	push   %esi
  800641:	e8 79 fe ff ff       	call   8004bf <printfmt>
  800646:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800649:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80064c:	e9 b1 fe ff ff       	jmp    800502 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800651:	8b 45 14             	mov    0x14(%ebp),%eax
  800654:	8d 50 04             	lea    0x4(%eax),%edx
  800657:	89 55 14             	mov    %edx,0x14(%ebp)
  80065a:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80065c:	85 ff                	test   %edi,%edi
  80065e:	b8 14 21 80 00       	mov    $0x802114,%eax
  800663:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800666:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80066a:	0f 8e 94 00 00 00    	jle    800704 <vprintfmt+0x228>
  800670:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800674:	0f 84 98 00 00 00    	je     800712 <vprintfmt+0x236>
				for (width -= strnlen(p, precision); width > 0; width--)
  80067a:	83 ec 08             	sub    $0x8,%esp
  80067d:	ff 75 cc             	pushl  -0x34(%ebp)
  800680:	57                   	push   %edi
  800681:	e8 94 03 00 00       	call   800a1a <strnlen>
  800686:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800689:	29 c1                	sub    %eax,%ecx
  80068b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80068e:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800691:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800695:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800698:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80069b:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80069d:	eb 0f                	jmp    8006ae <vprintfmt+0x1d2>
					putch(padc, putdat);
  80069f:	83 ec 08             	sub    $0x8,%esp
  8006a2:	53                   	push   %ebx
  8006a3:	ff 75 e0             	pushl  -0x20(%ebp)
  8006a6:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a8:	83 ef 01             	sub    $0x1,%edi
  8006ab:	83 c4 10             	add    $0x10,%esp
  8006ae:	85 ff                	test   %edi,%edi
  8006b0:	7f ed                	jg     80069f <vprintfmt+0x1c3>
  8006b2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006b5:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8006b8:	85 c9                	test   %ecx,%ecx
  8006ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8006bf:	0f 49 c1             	cmovns %ecx,%eax
  8006c2:	29 c1                	sub    %eax,%ecx
  8006c4:	89 75 08             	mov    %esi,0x8(%ebp)
  8006c7:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8006ca:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006cd:	89 cb                	mov    %ecx,%ebx
  8006cf:	eb 4d                	jmp    80071e <vprintfmt+0x242>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006d1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006d5:	74 1b                	je     8006f2 <vprintfmt+0x216>
  8006d7:	0f be c0             	movsbl %al,%eax
  8006da:	83 e8 20             	sub    $0x20,%eax
  8006dd:	83 f8 5e             	cmp    $0x5e,%eax
  8006e0:	76 10                	jbe    8006f2 <vprintfmt+0x216>
					putch('?', putdat);
  8006e2:	83 ec 08             	sub    $0x8,%esp
  8006e5:	ff 75 0c             	pushl  0xc(%ebp)
  8006e8:	6a 3f                	push   $0x3f
  8006ea:	ff 55 08             	call   *0x8(%ebp)
  8006ed:	83 c4 10             	add    $0x10,%esp
  8006f0:	eb 0d                	jmp    8006ff <vprintfmt+0x223>
				else
					putch(ch, putdat);
  8006f2:	83 ec 08             	sub    $0x8,%esp
  8006f5:	ff 75 0c             	pushl  0xc(%ebp)
  8006f8:	52                   	push   %edx
  8006f9:	ff 55 08             	call   *0x8(%ebp)
  8006fc:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006ff:	83 eb 01             	sub    $0x1,%ebx
  800702:	eb 1a                	jmp    80071e <vprintfmt+0x242>
  800704:	89 75 08             	mov    %esi,0x8(%ebp)
  800707:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80070a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80070d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800710:	eb 0c                	jmp    80071e <vprintfmt+0x242>
  800712:	89 75 08             	mov    %esi,0x8(%ebp)
  800715:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800718:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80071b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80071e:	83 c7 01             	add    $0x1,%edi
  800721:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800725:	0f be d0             	movsbl %al,%edx
  800728:	85 d2                	test   %edx,%edx
  80072a:	74 23                	je     80074f <vprintfmt+0x273>
  80072c:	85 f6                	test   %esi,%esi
  80072e:	78 a1                	js     8006d1 <vprintfmt+0x1f5>
  800730:	83 ee 01             	sub    $0x1,%esi
  800733:	79 9c                	jns    8006d1 <vprintfmt+0x1f5>
  800735:	89 df                	mov    %ebx,%edi
  800737:	8b 75 08             	mov    0x8(%ebp),%esi
  80073a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80073d:	eb 18                	jmp    800757 <vprintfmt+0x27b>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80073f:	83 ec 08             	sub    $0x8,%esp
  800742:	53                   	push   %ebx
  800743:	6a 20                	push   $0x20
  800745:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800747:	83 ef 01             	sub    $0x1,%edi
  80074a:	83 c4 10             	add    $0x10,%esp
  80074d:	eb 08                	jmp    800757 <vprintfmt+0x27b>
  80074f:	89 df                	mov    %ebx,%edi
  800751:	8b 75 08             	mov    0x8(%ebp),%esi
  800754:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800757:	85 ff                	test   %edi,%edi
  800759:	7f e4                	jg     80073f <vprintfmt+0x263>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80075b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80075e:	e9 9f fd ff ff       	jmp    800502 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800763:	83 7d d0 01          	cmpl   $0x1,-0x30(%ebp)
  800767:	7e 16                	jle    80077f <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  800769:	8b 45 14             	mov    0x14(%ebp),%eax
  80076c:	8d 50 08             	lea    0x8(%eax),%edx
  80076f:	89 55 14             	mov    %edx,0x14(%ebp)
  800772:	8b 50 04             	mov    0x4(%eax),%edx
  800775:	8b 00                	mov    (%eax),%eax
  800777:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80077a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80077d:	eb 34                	jmp    8007b3 <vprintfmt+0x2d7>
	else if (lflag)
  80077f:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800783:	74 18                	je     80079d <vprintfmt+0x2c1>
		return va_arg(*ap, long);
  800785:	8b 45 14             	mov    0x14(%ebp),%eax
  800788:	8d 50 04             	lea    0x4(%eax),%edx
  80078b:	89 55 14             	mov    %edx,0x14(%ebp)
  80078e:	8b 00                	mov    (%eax),%eax
  800790:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800793:	89 c1                	mov    %eax,%ecx
  800795:	c1 f9 1f             	sar    $0x1f,%ecx
  800798:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80079b:	eb 16                	jmp    8007b3 <vprintfmt+0x2d7>
	else
		return va_arg(*ap, int);
  80079d:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a0:	8d 50 04             	lea    0x4(%eax),%edx
  8007a3:	89 55 14             	mov    %edx,0x14(%ebp)
  8007a6:	8b 00                	mov    (%eax),%eax
  8007a8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007ab:	89 c1                	mov    %eax,%ecx
  8007ad:	c1 f9 1f             	sar    $0x1f,%ecx
  8007b0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007b3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007b6:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007b9:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007be:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007c2:	0f 89 88 00 00 00    	jns    800850 <vprintfmt+0x374>
				putch('-', putdat);
  8007c8:	83 ec 08             	sub    $0x8,%esp
  8007cb:	53                   	push   %ebx
  8007cc:	6a 2d                	push   $0x2d
  8007ce:	ff d6                	call   *%esi
				num = -(long long) num;
  8007d0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007d3:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8007d6:	f7 d8                	neg    %eax
  8007d8:	83 d2 00             	adc    $0x0,%edx
  8007db:	f7 da                	neg    %edx
  8007dd:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8007e0:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007e5:	eb 69                	jmp    800850 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007e7:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8007ea:	8d 45 14             	lea    0x14(%ebp),%eax
  8007ed:	e8 76 fc ff ff       	call   800468 <getuint>
			base = 10;
  8007f2:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8007f7:	eb 57                	jmp    800850 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  8007f9:	83 ec 08             	sub    $0x8,%esp
  8007fc:	53                   	push   %ebx
  8007fd:	6a 30                	push   $0x30
  8007ff:	ff d6                	call   *%esi
			num = getuint(&ap, lflag);
  800801:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800804:	8d 45 14             	lea    0x14(%ebp),%eax
  800807:	e8 5c fc ff ff       	call   800468 <getuint>
			base = 8;
			goto number;
  80080c:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  80080f:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800814:	eb 3a                	jmp    800850 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  800816:	83 ec 08             	sub    $0x8,%esp
  800819:	53                   	push   %ebx
  80081a:	6a 30                	push   $0x30
  80081c:	ff d6                	call   *%esi
			putch('x', putdat);
  80081e:	83 c4 08             	add    $0x8,%esp
  800821:	53                   	push   %ebx
  800822:	6a 78                	push   $0x78
  800824:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800826:	8b 45 14             	mov    0x14(%ebp),%eax
  800829:	8d 50 04             	lea    0x4(%eax),%edx
  80082c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80082f:	8b 00                	mov    (%eax),%eax
  800831:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800836:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800839:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80083e:	eb 10                	jmp    800850 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800840:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800843:	8d 45 14             	lea    0x14(%ebp),%eax
  800846:	e8 1d fc ff ff       	call   800468 <getuint>
			base = 16;
  80084b:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800850:	83 ec 0c             	sub    $0xc,%esp
  800853:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800857:	57                   	push   %edi
  800858:	ff 75 e0             	pushl  -0x20(%ebp)
  80085b:	51                   	push   %ecx
  80085c:	52                   	push   %edx
  80085d:	50                   	push   %eax
  80085e:	89 da                	mov    %ebx,%edx
  800860:	89 f0                	mov    %esi,%eax
  800862:	e8 52 fb ff ff       	call   8003b9 <printnum>
			break;
  800867:	83 c4 20             	add    $0x20,%esp
  80086a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80086d:	e9 90 fc ff ff       	jmp    800502 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800872:	83 ec 08             	sub    $0x8,%esp
  800875:	53                   	push   %ebx
  800876:	52                   	push   %edx
  800877:	ff d6                	call   *%esi
			break;
  800879:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80087c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80087f:	e9 7e fc ff ff       	jmp    800502 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800884:	83 ec 08             	sub    $0x8,%esp
  800887:	53                   	push   %ebx
  800888:	6a 25                	push   $0x25
  80088a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80088c:	83 c4 10             	add    $0x10,%esp
  80088f:	eb 03                	jmp    800894 <vprintfmt+0x3b8>
  800891:	83 ef 01             	sub    $0x1,%edi
  800894:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800898:	75 f7                	jne    800891 <vprintfmt+0x3b5>
  80089a:	e9 63 fc ff ff       	jmp    800502 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80089f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008a2:	5b                   	pop    %ebx
  8008a3:	5e                   	pop    %esi
  8008a4:	5f                   	pop    %edi
  8008a5:	5d                   	pop    %ebp
  8008a6:	c3                   	ret    

008008a7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008a7:	55                   	push   %ebp
  8008a8:	89 e5                	mov    %esp,%ebp
  8008aa:	83 ec 18             	sub    $0x18,%esp
  8008ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008b3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008b6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008ba:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008bd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008c4:	85 c0                	test   %eax,%eax
  8008c6:	74 26                	je     8008ee <vsnprintf+0x47>
  8008c8:	85 d2                	test   %edx,%edx
  8008ca:	7e 22                	jle    8008ee <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008cc:	ff 75 14             	pushl  0x14(%ebp)
  8008cf:	ff 75 10             	pushl  0x10(%ebp)
  8008d2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008d5:	50                   	push   %eax
  8008d6:	68 a2 04 80 00       	push   $0x8004a2
  8008db:	e8 fc fb ff ff       	call   8004dc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008e0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008e3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008e9:	83 c4 10             	add    $0x10,%esp
  8008ec:	eb 05                	jmp    8008f3 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008f3:	c9                   	leave  
  8008f4:	c3                   	ret    

008008f5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008f5:	55                   	push   %ebp
  8008f6:	89 e5                	mov    %esp,%ebp
  8008f8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008fb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008fe:	50                   	push   %eax
  8008ff:	ff 75 10             	pushl  0x10(%ebp)
  800902:	ff 75 0c             	pushl  0xc(%ebp)
  800905:	ff 75 08             	pushl  0x8(%ebp)
  800908:	e8 9a ff ff ff       	call   8008a7 <vsnprintf>
	va_end(ap);

	return rc;
}
  80090d:	c9                   	leave  
  80090e:	c3                   	ret    

0080090f <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  80090f:	55                   	push   %ebp
  800910:	89 e5                	mov    %esp,%ebp
  800912:	57                   	push   %edi
  800913:	56                   	push   %esi
  800914:	53                   	push   %ebx
  800915:	83 ec 0c             	sub    $0xc,%esp
  800918:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  80091b:	85 c0                	test   %eax,%eax
  80091d:	74 13                	je     800932 <readline+0x23>
		fprintf(1, "%s", prompt);
  80091f:	83 ec 04             	sub    $0x4,%esp
  800922:	50                   	push   %eax
  800923:	68 e5 24 80 00       	push   $0x8024e5
  800928:	6a 01                	push   $0x1
  80092a:	e8 ee 0f 00 00       	call   80191d <fprintf>
  80092f:	83 c4 10             	add    $0x10,%esp
#endif

	i = 0;
	echoing = iscons(0);
  800932:	83 ec 0c             	sub    $0xc,%esp
  800935:	6a 00                	push   $0x0
  800937:	e8 aa f8 ff ff       	call   8001e6 <iscons>
  80093c:	89 c7                	mov    %eax,%edi
  80093e:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
  800941:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
  800946:	e8 70 f8 ff ff       	call   8001bb <getchar>
  80094b:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  80094d:	85 c0                	test   %eax,%eax
  80094f:	79 29                	jns    80097a <readline+0x6b>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  800951:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
  800956:	83 fb f8             	cmp    $0xfffffff8,%ebx
  800959:	0f 84 9b 00 00 00    	je     8009fa <readline+0xeb>
				cprintf("read error: %e\n", c);
  80095f:	83 ec 08             	sub    $0x8,%esp
  800962:	53                   	push   %ebx
  800963:	68 ff 23 80 00       	push   $0x8023ff
  800968:	e8 38 fa ff ff       	call   8003a5 <cprintf>
  80096d:	83 c4 10             	add    $0x10,%esp
			return NULL;
  800970:	b8 00 00 00 00       	mov    $0x0,%eax
  800975:	e9 80 00 00 00       	jmp    8009fa <readline+0xeb>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  80097a:	83 f8 08             	cmp    $0x8,%eax
  80097d:	0f 94 c2             	sete   %dl
  800980:	83 f8 7f             	cmp    $0x7f,%eax
  800983:	0f 94 c0             	sete   %al
  800986:	08 c2                	or     %al,%dl
  800988:	74 1a                	je     8009a4 <readline+0x95>
  80098a:	85 f6                	test   %esi,%esi
  80098c:	7e 16                	jle    8009a4 <readline+0x95>
			if (echoing)
  80098e:	85 ff                	test   %edi,%edi
  800990:	74 0d                	je     80099f <readline+0x90>
				cputchar('\b');
  800992:	83 ec 0c             	sub    $0xc,%esp
  800995:	6a 08                	push   $0x8
  800997:	e8 03 f8 ff ff       	call   80019f <cputchar>
  80099c:	83 c4 10             	add    $0x10,%esp
			i--;
  80099f:	83 ee 01             	sub    $0x1,%esi
  8009a2:	eb a2                	jmp    800946 <readline+0x37>
		} else if (c >= ' ' && i < BUFLEN-1) {
  8009a4:	83 fb 1f             	cmp    $0x1f,%ebx
  8009a7:	7e 26                	jle    8009cf <readline+0xc0>
  8009a9:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  8009af:	7f 1e                	jg     8009cf <readline+0xc0>
			if (echoing)
  8009b1:	85 ff                	test   %edi,%edi
  8009b3:	74 0c                	je     8009c1 <readline+0xb2>
				cputchar(c);
  8009b5:	83 ec 0c             	sub    $0xc,%esp
  8009b8:	53                   	push   %ebx
  8009b9:	e8 e1 f7 ff ff       	call   80019f <cputchar>
  8009be:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
  8009c1:	88 9e 00 40 80 00    	mov    %bl,0x804000(%esi)
  8009c7:	8d 76 01             	lea    0x1(%esi),%esi
  8009ca:	e9 77 ff ff ff       	jmp    800946 <readline+0x37>
		} else if (c == '\n' || c == '\r') {
  8009cf:	83 fb 0a             	cmp    $0xa,%ebx
  8009d2:	74 09                	je     8009dd <readline+0xce>
  8009d4:	83 fb 0d             	cmp    $0xd,%ebx
  8009d7:	0f 85 69 ff ff ff    	jne    800946 <readline+0x37>
			if (echoing)
  8009dd:	85 ff                	test   %edi,%edi
  8009df:	74 0d                	je     8009ee <readline+0xdf>
				cputchar('\n');
  8009e1:	83 ec 0c             	sub    $0xc,%esp
  8009e4:	6a 0a                	push   $0xa
  8009e6:	e8 b4 f7 ff ff       	call   80019f <cputchar>
  8009eb:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
  8009ee:	c6 86 00 40 80 00 00 	movb   $0x0,0x804000(%esi)
			return buf;
  8009f5:	b8 00 40 80 00       	mov    $0x804000,%eax
		}
	}
}
  8009fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009fd:	5b                   	pop    %ebx
  8009fe:	5e                   	pop    %esi
  8009ff:	5f                   	pop    %edi
  800a00:	5d                   	pop    %ebp
  800a01:	c3                   	ret    

00800a02 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a02:	55                   	push   %ebp
  800a03:	89 e5                	mov    %esp,%ebp
  800a05:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a08:	b8 00 00 00 00       	mov    $0x0,%eax
  800a0d:	eb 03                	jmp    800a12 <strlen+0x10>
		n++;
  800a0f:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a12:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a16:	75 f7                	jne    800a0f <strlen+0xd>
		n++;
	return n;
}
  800a18:	5d                   	pop    %ebp
  800a19:	c3                   	ret    

00800a1a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a1a:	55                   	push   %ebp
  800a1b:	89 e5                	mov    %esp,%ebp
  800a1d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a20:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a23:	ba 00 00 00 00       	mov    $0x0,%edx
  800a28:	eb 03                	jmp    800a2d <strnlen+0x13>
		n++;
  800a2a:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a2d:	39 c2                	cmp    %eax,%edx
  800a2f:	74 08                	je     800a39 <strnlen+0x1f>
  800a31:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800a35:	75 f3                	jne    800a2a <strnlen+0x10>
  800a37:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800a39:	5d                   	pop    %ebp
  800a3a:	c3                   	ret    

00800a3b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a3b:	55                   	push   %ebp
  800a3c:	89 e5                	mov    %esp,%ebp
  800a3e:	53                   	push   %ebx
  800a3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a45:	89 c2                	mov    %eax,%edx
  800a47:	83 c2 01             	add    $0x1,%edx
  800a4a:	83 c1 01             	add    $0x1,%ecx
  800a4d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a51:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a54:	84 db                	test   %bl,%bl
  800a56:	75 ef                	jne    800a47 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a58:	5b                   	pop    %ebx
  800a59:	5d                   	pop    %ebp
  800a5a:	c3                   	ret    

00800a5b <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	53                   	push   %ebx
  800a5f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a62:	53                   	push   %ebx
  800a63:	e8 9a ff ff ff       	call   800a02 <strlen>
  800a68:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a6b:	ff 75 0c             	pushl  0xc(%ebp)
  800a6e:	01 d8                	add    %ebx,%eax
  800a70:	50                   	push   %eax
  800a71:	e8 c5 ff ff ff       	call   800a3b <strcpy>
	return dst;
}
  800a76:	89 d8                	mov    %ebx,%eax
  800a78:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a7b:	c9                   	leave  
  800a7c:	c3                   	ret    

00800a7d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a7d:	55                   	push   %ebp
  800a7e:	89 e5                	mov    %esp,%ebp
  800a80:	56                   	push   %esi
  800a81:	53                   	push   %ebx
  800a82:	8b 75 08             	mov    0x8(%ebp),%esi
  800a85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a88:	89 f3                	mov    %esi,%ebx
  800a8a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a8d:	89 f2                	mov    %esi,%edx
  800a8f:	eb 0f                	jmp    800aa0 <strncpy+0x23>
		*dst++ = *src;
  800a91:	83 c2 01             	add    $0x1,%edx
  800a94:	0f b6 01             	movzbl (%ecx),%eax
  800a97:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a9a:	80 39 01             	cmpb   $0x1,(%ecx)
  800a9d:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800aa0:	39 da                	cmp    %ebx,%edx
  800aa2:	75 ed                	jne    800a91 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800aa4:	89 f0                	mov    %esi,%eax
  800aa6:	5b                   	pop    %ebx
  800aa7:	5e                   	pop    %esi
  800aa8:	5d                   	pop    %ebp
  800aa9:	c3                   	ret    

00800aaa <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800aaa:	55                   	push   %ebp
  800aab:	89 e5                	mov    %esp,%ebp
  800aad:	56                   	push   %esi
  800aae:	53                   	push   %ebx
  800aaf:	8b 75 08             	mov    0x8(%ebp),%esi
  800ab2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ab5:	8b 55 10             	mov    0x10(%ebp),%edx
  800ab8:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800aba:	85 d2                	test   %edx,%edx
  800abc:	74 21                	je     800adf <strlcpy+0x35>
  800abe:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800ac2:	89 f2                	mov    %esi,%edx
  800ac4:	eb 09                	jmp    800acf <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800ac6:	83 c2 01             	add    $0x1,%edx
  800ac9:	83 c1 01             	add    $0x1,%ecx
  800acc:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800acf:	39 c2                	cmp    %eax,%edx
  800ad1:	74 09                	je     800adc <strlcpy+0x32>
  800ad3:	0f b6 19             	movzbl (%ecx),%ebx
  800ad6:	84 db                	test   %bl,%bl
  800ad8:	75 ec                	jne    800ac6 <strlcpy+0x1c>
  800ada:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800adc:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800adf:	29 f0                	sub    %esi,%eax
}
  800ae1:	5b                   	pop    %ebx
  800ae2:	5e                   	pop    %esi
  800ae3:	5d                   	pop    %ebp
  800ae4:	c3                   	ret    

00800ae5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ae5:	55                   	push   %ebp
  800ae6:	89 e5                	mov    %esp,%ebp
  800ae8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aeb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800aee:	eb 06                	jmp    800af6 <strcmp+0x11>
		p++, q++;
  800af0:	83 c1 01             	add    $0x1,%ecx
  800af3:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800af6:	0f b6 01             	movzbl (%ecx),%eax
  800af9:	84 c0                	test   %al,%al
  800afb:	74 04                	je     800b01 <strcmp+0x1c>
  800afd:	3a 02                	cmp    (%edx),%al
  800aff:	74 ef                	je     800af0 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b01:	0f b6 c0             	movzbl %al,%eax
  800b04:	0f b6 12             	movzbl (%edx),%edx
  800b07:	29 d0                	sub    %edx,%eax
}
  800b09:	5d                   	pop    %ebp
  800b0a:	c3                   	ret    

00800b0b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b0b:	55                   	push   %ebp
  800b0c:	89 e5                	mov    %esp,%ebp
  800b0e:	53                   	push   %ebx
  800b0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b12:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b15:	89 c3                	mov    %eax,%ebx
  800b17:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b1a:	eb 06                	jmp    800b22 <strncmp+0x17>
		n--, p++, q++;
  800b1c:	83 c0 01             	add    $0x1,%eax
  800b1f:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b22:	39 d8                	cmp    %ebx,%eax
  800b24:	74 15                	je     800b3b <strncmp+0x30>
  800b26:	0f b6 08             	movzbl (%eax),%ecx
  800b29:	84 c9                	test   %cl,%cl
  800b2b:	74 04                	je     800b31 <strncmp+0x26>
  800b2d:	3a 0a                	cmp    (%edx),%cl
  800b2f:	74 eb                	je     800b1c <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b31:	0f b6 00             	movzbl (%eax),%eax
  800b34:	0f b6 12             	movzbl (%edx),%edx
  800b37:	29 d0                	sub    %edx,%eax
  800b39:	eb 05                	jmp    800b40 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b3b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b40:	5b                   	pop    %ebx
  800b41:	5d                   	pop    %ebp
  800b42:	c3                   	ret    

00800b43 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b43:	55                   	push   %ebp
  800b44:	89 e5                	mov    %esp,%ebp
  800b46:	8b 45 08             	mov    0x8(%ebp),%eax
  800b49:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b4d:	eb 07                	jmp    800b56 <strchr+0x13>
		if (*s == c)
  800b4f:	38 ca                	cmp    %cl,%dl
  800b51:	74 0f                	je     800b62 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b53:	83 c0 01             	add    $0x1,%eax
  800b56:	0f b6 10             	movzbl (%eax),%edx
  800b59:	84 d2                	test   %dl,%dl
  800b5b:	75 f2                	jne    800b4f <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800b5d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b62:	5d                   	pop    %ebp
  800b63:	c3                   	ret    

00800b64 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b64:	55                   	push   %ebp
  800b65:	89 e5                	mov    %esp,%ebp
  800b67:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b6e:	eb 03                	jmp    800b73 <strfind+0xf>
  800b70:	83 c0 01             	add    $0x1,%eax
  800b73:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b76:	38 ca                	cmp    %cl,%dl
  800b78:	74 04                	je     800b7e <strfind+0x1a>
  800b7a:	84 d2                	test   %dl,%dl
  800b7c:	75 f2                	jne    800b70 <strfind+0xc>
			break;
	return (char *) s;
}
  800b7e:	5d                   	pop    %ebp
  800b7f:	c3                   	ret    

00800b80 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	57                   	push   %edi
  800b84:	56                   	push   %esi
  800b85:	53                   	push   %ebx
  800b86:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b89:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b8c:	85 c9                	test   %ecx,%ecx
  800b8e:	74 36                	je     800bc6 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b90:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b96:	75 28                	jne    800bc0 <memset+0x40>
  800b98:	f6 c1 03             	test   $0x3,%cl
  800b9b:	75 23                	jne    800bc0 <memset+0x40>
		c &= 0xFF;
  800b9d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ba1:	89 d3                	mov    %edx,%ebx
  800ba3:	c1 e3 08             	shl    $0x8,%ebx
  800ba6:	89 d6                	mov    %edx,%esi
  800ba8:	c1 e6 18             	shl    $0x18,%esi
  800bab:	89 d0                	mov    %edx,%eax
  800bad:	c1 e0 10             	shl    $0x10,%eax
  800bb0:	09 f0                	or     %esi,%eax
  800bb2:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800bb4:	89 d8                	mov    %ebx,%eax
  800bb6:	09 d0                	or     %edx,%eax
  800bb8:	c1 e9 02             	shr    $0x2,%ecx
  800bbb:	fc                   	cld    
  800bbc:	f3 ab                	rep stos %eax,%es:(%edi)
  800bbe:	eb 06                	jmp    800bc6 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bc0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bc3:	fc                   	cld    
  800bc4:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bc6:	89 f8                	mov    %edi,%eax
  800bc8:	5b                   	pop    %ebx
  800bc9:	5e                   	pop    %esi
  800bca:	5f                   	pop    %edi
  800bcb:	5d                   	pop    %ebp
  800bcc:	c3                   	ret    

00800bcd <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bcd:	55                   	push   %ebp
  800bce:	89 e5                	mov    %esp,%ebp
  800bd0:	57                   	push   %edi
  800bd1:	56                   	push   %esi
  800bd2:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bd8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bdb:	39 c6                	cmp    %eax,%esi
  800bdd:	73 35                	jae    800c14 <memmove+0x47>
  800bdf:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800be2:	39 d0                	cmp    %edx,%eax
  800be4:	73 2e                	jae    800c14 <memmove+0x47>
		s += n;
		d += n;
  800be6:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800be9:	89 d6                	mov    %edx,%esi
  800beb:	09 fe                	or     %edi,%esi
  800bed:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bf3:	75 13                	jne    800c08 <memmove+0x3b>
  800bf5:	f6 c1 03             	test   $0x3,%cl
  800bf8:	75 0e                	jne    800c08 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800bfa:	83 ef 04             	sub    $0x4,%edi
  800bfd:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c00:	c1 e9 02             	shr    $0x2,%ecx
  800c03:	fd                   	std    
  800c04:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c06:	eb 09                	jmp    800c11 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c08:	83 ef 01             	sub    $0x1,%edi
  800c0b:	8d 72 ff             	lea    -0x1(%edx),%esi
  800c0e:	fd                   	std    
  800c0f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c11:	fc                   	cld    
  800c12:	eb 1d                	jmp    800c31 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c14:	89 f2                	mov    %esi,%edx
  800c16:	09 c2                	or     %eax,%edx
  800c18:	f6 c2 03             	test   $0x3,%dl
  800c1b:	75 0f                	jne    800c2c <memmove+0x5f>
  800c1d:	f6 c1 03             	test   $0x3,%cl
  800c20:	75 0a                	jne    800c2c <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800c22:	c1 e9 02             	shr    $0x2,%ecx
  800c25:	89 c7                	mov    %eax,%edi
  800c27:	fc                   	cld    
  800c28:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c2a:	eb 05                	jmp    800c31 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c2c:	89 c7                	mov    %eax,%edi
  800c2e:	fc                   	cld    
  800c2f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c31:	5e                   	pop    %esi
  800c32:	5f                   	pop    %edi
  800c33:	5d                   	pop    %ebp
  800c34:	c3                   	ret    

00800c35 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c35:	55                   	push   %ebp
  800c36:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c38:	ff 75 10             	pushl  0x10(%ebp)
  800c3b:	ff 75 0c             	pushl  0xc(%ebp)
  800c3e:	ff 75 08             	pushl  0x8(%ebp)
  800c41:	e8 87 ff ff ff       	call   800bcd <memmove>
}
  800c46:	c9                   	leave  
  800c47:	c3                   	ret    

00800c48 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c48:	55                   	push   %ebp
  800c49:	89 e5                	mov    %esp,%ebp
  800c4b:	56                   	push   %esi
  800c4c:	53                   	push   %ebx
  800c4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c50:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c53:	89 c6                	mov    %eax,%esi
  800c55:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c58:	eb 1a                	jmp    800c74 <memcmp+0x2c>
		if (*s1 != *s2)
  800c5a:	0f b6 08             	movzbl (%eax),%ecx
  800c5d:	0f b6 1a             	movzbl (%edx),%ebx
  800c60:	38 d9                	cmp    %bl,%cl
  800c62:	74 0a                	je     800c6e <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800c64:	0f b6 c1             	movzbl %cl,%eax
  800c67:	0f b6 db             	movzbl %bl,%ebx
  800c6a:	29 d8                	sub    %ebx,%eax
  800c6c:	eb 0f                	jmp    800c7d <memcmp+0x35>
		s1++, s2++;
  800c6e:	83 c0 01             	add    $0x1,%eax
  800c71:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c74:	39 f0                	cmp    %esi,%eax
  800c76:	75 e2                	jne    800c5a <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c78:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c7d:	5b                   	pop    %ebx
  800c7e:	5e                   	pop    %esi
  800c7f:	5d                   	pop    %ebp
  800c80:	c3                   	ret    

00800c81 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c81:	55                   	push   %ebp
  800c82:	89 e5                	mov    %esp,%ebp
  800c84:	53                   	push   %ebx
  800c85:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c88:	89 c1                	mov    %eax,%ecx
  800c8a:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c8d:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c91:	eb 0a                	jmp    800c9d <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c93:	0f b6 10             	movzbl (%eax),%edx
  800c96:	39 da                	cmp    %ebx,%edx
  800c98:	74 07                	je     800ca1 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c9a:	83 c0 01             	add    $0x1,%eax
  800c9d:	39 c8                	cmp    %ecx,%eax
  800c9f:	72 f2                	jb     800c93 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ca1:	5b                   	pop    %ebx
  800ca2:	5d                   	pop    %ebp
  800ca3:	c3                   	ret    

00800ca4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ca4:	55                   	push   %ebp
  800ca5:	89 e5                	mov    %esp,%ebp
  800ca7:	57                   	push   %edi
  800ca8:	56                   	push   %esi
  800ca9:	53                   	push   %ebx
  800caa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cad:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cb0:	eb 03                	jmp    800cb5 <strtol+0x11>
		s++;
  800cb2:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cb5:	0f b6 01             	movzbl (%ecx),%eax
  800cb8:	3c 20                	cmp    $0x20,%al
  800cba:	74 f6                	je     800cb2 <strtol+0xe>
  800cbc:	3c 09                	cmp    $0x9,%al
  800cbe:	74 f2                	je     800cb2 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800cc0:	3c 2b                	cmp    $0x2b,%al
  800cc2:	75 0a                	jne    800cce <strtol+0x2a>
		s++;
  800cc4:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cc7:	bf 00 00 00 00       	mov    $0x0,%edi
  800ccc:	eb 11                	jmp    800cdf <strtol+0x3b>
  800cce:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800cd3:	3c 2d                	cmp    $0x2d,%al
  800cd5:	75 08                	jne    800cdf <strtol+0x3b>
		s++, neg = 1;
  800cd7:	83 c1 01             	add    $0x1,%ecx
  800cda:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cdf:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ce5:	75 15                	jne    800cfc <strtol+0x58>
  800ce7:	80 39 30             	cmpb   $0x30,(%ecx)
  800cea:	75 10                	jne    800cfc <strtol+0x58>
  800cec:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800cf0:	75 7c                	jne    800d6e <strtol+0xca>
		s += 2, base = 16;
  800cf2:	83 c1 02             	add    $0x2,%ecx
  800cf5:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cfa:	eb 16                	jmp    800d12 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800cfc:	85 db                	test   %ebx,%ebx
  800cfe:	75 12                	jne    800d12 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d00:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d05:	80 39 30             	cmpb   $0x30,(%ecx)
  800d08:	75 08                	jne    800d12 <strtol+0x6e>
		s++, base = 8;
  800d0a:	83 c1 01             	add    $0x1,%ecx
  800d0d:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800d12:	b8 00 00 00 00       	mov    $0x0,%eax
  800d17:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d1a:	0f b6 11             	movzbl (%ecx),%edx
  800d1d:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d20:	89 f3                	mov    %esi,%ebx
  800d22:	80 fb 09             	cmp    $0x9,%bl
  800d25:	77 08                	ja     800d2f <strtol+0x8b>
			dig = *s - '0';
  800d27:	0f be d2             	movsbl %dl,%edx
  800d2a:	83 ea 30             	sub    $0x30,%edx
  800d2d:	eb 22                	jmp    800d51 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800d2f:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d32:	89 f3                	mov    %esi,%ebx
  800d34:	80 fb 19             	cmp    $0x19,%bl
  800d37:	77 08                	ja     800d41 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800d39:	0f be d2             	movsbl %dl,%edx
  800d3c:	83 ea 57             	sub    $0x57,%edx
  800d3f:	eb 10                	jmp    800d51 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800d41:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d44:	89 f3                	mov    %esi,%ebx
  800d46:	80 fb 19             	cmp    $0x19,%bl
  800d49:	77 16                	ja     800d61 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800d4b:	0f be d2             	movsbl %dl,%edx
  800d4e:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800d51:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d54:	7d 0b                	jge    800d61 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800d56:	83 c1 01             	add    $0x1,%ecx
  800d59:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d5d:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800d5f:	eb b9                	jmp    800d1a <strtol+0x76>

	if (endptr)
  800d61:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d65:	74 0d                	je     800d74 <strtol+0xd0>
		*endptr = (char *) s;
  800d67:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d6a:	89 0e                	mov    %ecx,(%esi)
  800d6c:	eb 06                	jmp    800d74 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d6e:	85 db                	test   %ebx,%ebx
  800d70:	74 98                	je     800d0a <strtol+0x66>
  800d72:	eb 9e                	jmp    800d12 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d74:	89 c2                	mov    %eax,%edx
  800d76:	f7 da                	neg    %edx
  800d78:	85 ff                	test   %edi,%edi
  800d7a:	0f 45 c2             	cmovne %edx,%eax
}
  800d7d:	5b                   	pop    %ebx
  800d7e:	5e                   	pop    %esi
  800d7f:	5f                   	pop    %edi
  800d80:	5d                   	pop    %ebp
  800d81:	c3                   	ret    

00800d82 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d82:	55                   	push   %ebp
  800d83:	89 e5                	mov    %esp,%ebp
  800d85:	57                   	push   %edi
  800d86:	56                   	push   %esi
  800d87:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d88:	b8 00 00 00 00       	mov    $0x0,%eax
  800d8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d90:	8b 55 08             	mov    0x8(%ebp),%edx
  800d93:	89 c3                	mov    %eax,%ebx
  800d95:	89 c7                	mov    %eax,%edi
  800d97:	89 c6                	mov    %eax,%esi
  800d99:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d9b:	5b                   	pop    %ebx
  800d9c:	5e                   	pop    %esi
  800d9d:	5f                   	pop    %edi
  800d9e:	5d                   	pop    %ebp
  800d9f:	c3                   	ret    

00800da0 <sys_cgetc>:

int
sys_cgetc(void)
{
  800da0:	55                   	push   %ebp
  800da1:	89 e5                	mov    %esp,%ebp
  800da3:	57                   	push   %edi
  800da4:	56                   	push   %esi
  800da5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da6:	ba 00 00 00 00       	mov    $0x0,%edx
  800dab:	b8 01 00 00 00       	mov    $0x1,%eax
  800db0:	89 d1                	mov    %edx,%ecx
  800db2:	89 d3                	mov    %edx,%ebx
  800db4:	89 d7                	mov    %edx,%edi
  800db6:	89 d6                	mov    %edx,%esi
  800db8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800dba:	5b                   	pop    %ebx
  800dbb:	5e                   	pop    %esi
  800dbc:	5f                   	pop    %edi
  800dbd:	5d                   	pop    %ebp
  800dbe:	c3                   	ret    

00800dbf <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800dbf:	55                   	push   %ebp
  800dc0:	89 e5                	mov    %esp,%ebp
  800dc2:	57                   	push   %edi
  800dc3:	56                   	push   %esi
  800dc4:	53                   	push   %ebx
  800dc5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dcd:	b8 03 00 00 00       	mov    $0x3,%eax
  800dd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd5:	89 cb                	mov    %ecx,%ebx
  800dd7:	89 cf                	mov    %ecx,%edi
  800dd9:	89 ce                	mov    %ecx,%esi
  800ddb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ddd:	85 c0                	test   %eax,%eax
  800ddf:	7e 17                	jle    800df8 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de1:	83 ec 0c             	sub    $0xc,%esp
  800de4:	50                   	push   %eax
  800de5:	6a 03                	push   $0x3
  800de7:	68 0f 24 80 00       	push   $0x80240f
  800dec:	6a 23                	push   $0x23
  800dee:	68 2c 24 80 00       	push   $0x80242c
  800df3:	e8 d4 f4 ff ff       	call   8002cc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800df8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dfb:	5b                   	pop    %ebx
  800dfc:	5e                   	pop    %esi
  800dfd:	5f                   	pop    %edi
  800dfe:	5d                   	pop    %ebp
  800dff:	c3                   	ret    

00800e00 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e00:	55                   	push   %ebp
  800e01:	89 e5                	mov    %esp,%ebp
  800e03:	57                   	push   %edi
  800e04:	56                   	push   %esi
  800e05:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e06:	ba 00 00 00 00       	mov    $0x0,%edx
  800e0b:	b8 02 00 00 00       	mov    $0x2,%eax
  800e10:	89 d1                	mov    %edx,%ecx
  800e12:	89 d3                	mov    %edx,%ebx
  800e14:	89 d7                	mov    %edx,%edi
  800e16:	89 d6                	mov    %edx,%esi
  800e18:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e1a:	5b                   	pop    %ebx
  800e1b:	5e                   	pop    %esi
  800e1c:	5f                   	pop    %edi
  800e1d:	5d                   	pop    %ebp
  800e1e:	c3                   	ret    

00800e1f <sys_yield>:

void
sys_yield(void)
{
  800e1f:	55                   	push   %ebp
  800e20:	89 e5                	mov    %esp,%ebp
  800e22:	57                   	push   %edi
  800e23:	56                   	push   %esi
  800e24:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e25:	ba 00 00 00 00       	mov    $0x0,%edx
  800e2a:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e2f:	89 d1                	mov    %edx,%ecx
  800e31:	89 d3                	mov    %edx,%ebx
  800e33:	89 d7                	mov    %edx,%edi
  800e35:	89 d6                	mov    %edx,%esi
  800e37:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e39:	5b                   	pop    %ebx
  800e3a:	5e                   	pop    %esi
  800e3b:	5f                   	pop    %edi
  800e3c:	5d                   	pop    %ebp
  800e3d:	c3                   	ret    

00800e3e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e3e:	55                   	push   %ebp
  800e3f:	89 e5                	mov    %esp,%ebp
  800e41:	57                   	push   %edi
  800e42:	56                   	push   %esi
  800e43:	53                   	push   %ebx
  800e44:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e47:	be 00 00 00 00       	mov    $0x0,%esi
  800e4c:	b8 04 00 00 00       	mov    $0x4,%eax
  800e51:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e54:	8b 55 08             	mov    0x8(%ebp),%edx
  800e57:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e5a:	89 f7                	mov    %esi,%edi
  800e5c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e5e:	85 c0                	test   %eax,%eax
  800e60:	7e 17                	jle    800e79 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e62:	83 ec 0c             	sub    $0xc,%esp
  800e65:	50                   	push   %eax
  800e66:	6a 04                	push   $0x4
  800e68:	68 0f 24 80 00       	push   $0x80240f
  800e6d:	6a 23                	push   $0x23
  800e6f:	68 2c 24 80 00       	push   $0x80242c
  800e74:	e8 53 f4 ff ff       	call   8002cc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e79:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e7c:	5b                   	pop    %ebx
  800e7d:	5e                   	pop    %esi
  800e7e:	5f                   	pop    %edi
  800e7f:	5d                   	pop    %ebp
  800e80:	c3                   	ret    

00800e81 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e81:	55                   	push   %ebp
  800e82:	89 e5                	mov    %esp,%ebp
  800e84:	57                   	push   %edi
  800e85:	56                   	push   %esi
  800e86:	53                   	push   %ebx
  800e87:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8a:	b8 05 00 00 00       	mov    $0x5,%eax
  800e8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e92:	8b 55 08             	mov    0x8(%ebp),%edx
  800e95:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e98:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e9b:	8b 75 18             	mov    0x18(%ebp),%esi
  800e9e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ea0:	85 c0                	test   %eax,%eax
  800ea2:	7e 17                	jle    800ebb <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea4:	83 ec 0c             	sub    $0xc,%esp
  800ea7:	50                   	push   %eax
  800ea8:	6a 05                	push   $0x5
  800eaa:	68 0f 24 80 00       	push   $0x80240f
  800eaf:	6a 23                	push   $0x23
  800eb1:	68 2c 24 80 00       	push   $0x80242c
  800eb6:	e8 11 f4 ff ff       	call   8002cc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ebb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ebe:	5b                   	pop    %ebx
  800ebf:	5e                   	pop    %esi
  800ec0:	5f                   	pop    %edi
  800ec1:	5d                   	pop    %ebp
  800ec2:	c3                   	ret    

00800ec3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ec3:	55                   	push   %ebp
  800ec4:	89 e5                	mov    %esp,%ebp
  800ec6:	57                   	push   %edi
  800ec7:	56                   	push   %esi
  800ec8:	53                   	push   %ebx
  800ec9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ecc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ed1:	b8 06 00 00 00       	mov    $0x6,%eax
  800ed6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed9:	8b 55 08             	mov    0x8(%ebp),%edx
  800edc:	89 df                	mov    %ebx,%edi
  800ede:	89 de                	mov    %ebx,%esi
  800ee0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ee2:	85 c0                	test   %eax,%eax
  800ee4:	7e 17                	jle    800efd <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee6:	83 ec 0c             	sub    $0xc,%esp
  800ee9:	50                   	push   %eax
  800eea:	6a 06                	push   $0x6
  800eec:	68 0f 24 80 00       	push   $0x80240f
  800ef1:	6a 23                	push   $0x23
  800ef3:	68 2c 24 80 00       	push   $0x80242c
  800ef8:	e8 cf f3 ff ff       	call   8002cc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800efd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f00:	5b                   	pop    %ebx
  800f01:	5e                   	pop    %esi
  800f02:	5f                   	pop    %edi
  800f03:	5d                   	pop    %ebp
  800f04:	c3                   	ret    

00800f05 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f05:	55                   	push   %ebp
  800f06:	89 e5                	mov    %esp,%ebp
  800f08:	57                   	push   %edi
  800f09:	56                   	push   %esi
  800f0a:	53                   	push   %ebx
  800f0b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f0e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f13:	b8 08 00 00 00       	mov    $0x8,%eax
  800f18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f1e:	89 df                	mov    %ebx,%edi
  800f20:	89 de                	mov    %ebx,%esi
  800f22:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f24:	85 c0                	test   %eax,%eax
  800f26:	7e 17                	jle    800f3f <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f28:	83 ec 0c             	sub    $0xc,%esp
  800f2b:	50                   	push   %eax
  800f2c:	6a 08                	push   $0x8
  800f2e:	68 0f 24 80 00       	push   $0x80240f
  800f33:	6a 23                	push   $0x23
  800f35:	68 2c 24 80 00       	push   $0x80242c
  800f3a:	e8 8d f3 ff ff       	call   8002cc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f42:	5b                   	pop    %ebx
  800f43:	5e                   	pop    %esi
  800f44:	5f                   	pop    %edi
  800f45:	5d                   	pop    %ebp
  800f46:	c3                   	ret    

00800f47 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f47:	55                   	push   %ebp
  800f48:	89 e5                	mov    %esp,%ebp
  800f4a:	57                   	push   %edi
  800f4b:	56                   	push   %esi
  800f4c:	53                   	push   %ebx
  800f4d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f50:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f55:	b8 09 00 00 00       	mov    $0x9,%eax
  800f5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f60:	89 df                	mov    %ebx,%edi
  800f62:	89 de                	mov    %ebx,%esi
  800f64:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f66:	85 c0                	test   %eax,%eax
  800f68:	7e 17                	jle    800f81 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f6a:	83 ec 0c             	sub    $0xc,%esp
  800f6d:	50                   	push   %eax
  800f6e:	6a 09                	push   $0x9
  800f70:	68 0f 24 80 00       	push   $0x80240f
  800f75:	6a 23                	push   $0x23
  800f77:	68 2c 24 80 00       	push   $0x80242c
  800f7c:	e8 4b f3 ff ff       	call   8002cc <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f81:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f84:	5b                   	pop    %ebx
  800f85:	5e                   	pop    %esi
  800f86:	5f                   	pop    %edi
  800f87:	5d                   	pop    %ebp
  800f88:	c3                   	ret    

00800f89 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f89:	55                   	push   %ebp
  800f8a:	89 e5                	mov    %esp,%ebp
  800f8c:	57                   	push   %edi
  800f8d:	56                   	push   %esi
  800f8e:	53                   	push   %ebx
  800f8f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f92:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f97:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa2:	89 df                	mov    %ebx,%edi
  800fa4:	89 de                	mov    %ebx,%esi
  800fa6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fa8:	85 c0                	test   %eax,%eax
  800faa:	7e 17                	jle    800fc3 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fac:	83 ec 0c             	sub    $0xc,%esp
  800faf:	50                   	push   %eax
  800fb0:	6a 0a                	push   $0xa
  800fb2:	68 0f 24 80 00       	push   $0x80240f
  800fb7:	6a 23                	push   $0x23
  800fb9:	68 2c 24 80 00       	push   $0x80242c
  800fbe:	e8 09 f3 ff ff       	call   8002cc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800fc3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fc6:	5b                   	pop    %ebx
  800fc7:	5e                   	pop    %esi
  800fc8:	5f                   	pop    %edi
  800fc9:	5d                   	pop    %ebp
  800fca:	c3                   	ret    

00800fcb <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800fcb:	55                   	push   %ebp
  800fcc:	89 e5                	mov    %esp,%ebp
  800fce:	57                   	push   %edi
  800fcf:	56                   	push   %esi
  800fd0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fd1:	be 00 00 00 00       	mov    $0x0,%esi
  800fd6:	b8 0c 00 00 00       	mov    $0xc,%eax
  800fdb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fde:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fe4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fe7:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800fe9:	5b                   	pop    %ebx
  800fea:	5e                   	pop    %esi
  800feb:	5f                   	pop    %edi
  800fec:	5d                   	pop    %ebp
  800fed:	c3                   	ret    

00800fee <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800fee:	55                   	push   %ebp
  800fef:	89 e5                	mov    %esp,%ebp
  800ff1:	57                   	push   %edi
  800ff2:	56                   	push   %esi
  800ff3:	53                   	push   %ebx
  800ff4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ff7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ffc:	b8 0d 00 00 00       	mov    $0xd,%eax
  801001:	8b 55 08             	mov    0x8(%ebp),%edx
  801004:	89 cb                	mov    %ecx,%ebx
  801006:	89 cf                	mov    %ecx,%edi
  801008:	89 ce                	mov    %ecx,%esi
  80100a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80100c:	85 c0                	test   %eax,%eax
  80100e:	7e 17                	jle    801027 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801010:	83 ec 0c             	sub    $0xc,%esp
  801013:	50                   	push   %eax
  801014:	6a 0d                	push   $0xd
  801016:	68 0f 24 80 00       	push   $0x80240f
  80101b:	6a 23                	push   $0x23
  80101d:	68 2c 24 80 00       	push   $0x80242c
  801022:	e8 a5 f2 ff ff       	call   8002cc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801027:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80102a:	5b                   	pop    %ebx
  80102b:	5e                   	pop    %esi
  80102c:	5f                   	pop    %edi
  80102d:	5d                   	pop    %ebp
  80102e:	c3                   	ret    

0080102f <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80102f:	55                   	push   %ebp
  801030:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801032:	8b 45 08             	mov    0x8(%ebp),%eax
  801035:	05 00 00 00 30       	add    $0x30000000,%eax
  80103a:	c1 e8 0c             	shr    $0xc,%eax
}
  80103d:	5d                   	pop    %ebp
  80103e:	c3                   	ret    

0080103f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80103f:	55                   	push   %ebp
  801040:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801042:	8b 45 08             	mov    0x8(%ebp),%eax
  801045:	05 00 00 00 30       	add    $0x30000000,%eax
  80104a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80104f:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801054:	5d                   	pop    %ebp
  801055:	c3                   	ret    

00801056 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801056:	55                   	push   %ebp
  801057:	89 e5                	mov    %esp,%ebp
  801059:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80105c:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801061:	89 c2                	mov    %eax,%edx
  801063:	c1 ea 16             	shr    $0x16,%edx
  801066:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80106d:	f6 c2 01             	test   $0x1,%dl
  801070:	74 11                	je     801083 <fd_alloc+0x2d>
  801072:	89 c2                	mov    %eax,%edx
  801074:	c1 ea 0c             	shr    $0xc,%edx
  801077:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80107e:	f6 c2 01             	test   $0x1,%dl
  801081:	75 09                	jne    80108c <fd_alloc+0x36>
			*fd_store = fd;
  801083:	89 01                	mov    %eax,(%ecx)
			return 0;
  801085:	b8 00 00 00 00       	mov    $0x0,%eax
  80108a:	eb 17                	jmp    8010a3 <fd_alloc+0x4d>
  80108c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801091:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801096:	75 c9                	jne    801061 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801098:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80109e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010a3:	5d                   	pop    %ebp
  8010a4:	c3                   	ret    

008010a5 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010a5:	55                   	push   %ebp
  8010a6:	89 e5                	mov    %esp,%ebp
  8010a8:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010ab:	83 f8 1f             	cmp    $0x1f,%eax
  8010ae:	77 36                	ja     8010e6 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010b0:	c1 e0 0c             	shl    $0xc,%eax
  8010b3:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010b8:	89 c2                	mov    %eax,%edx
  8010ba:	c1 ea 16             	shr    $0x16,%edx
  8010bd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010c4:	f6 c2 01             	test   $0x1,%dl
  8010c7:	74 24                	je     8010ed <fd_lookup+0x48>
  8010c9:	89 c2                	mov    %eax,%edx
  8010cb:	c1 ea 0c             	shr    $0xc,%edx
  8010ce:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010d5:	f6 c2 01             	test   $0x1,%dl
  8010d8:	74 1a                	je     8010f4 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8010da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010dd:	89 02                	mov    %eax,(%edx)
	return 0;
  8010df:	b8 00 00 00 00       	mov    $0x0,%eax
  8010e4:	eb 13                	jmp    8010f9 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010eb:	eb 0c                	jmp    8010f9 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010ed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010f2:	eb 05                	jmp    8010f9 <fd_lookup+0x54>
  8010f4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8010f9:	5d                   	pop    %ebp
  8010fa:	c3                   	ret    

008010fb <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8010fb:	55                   	push   %ebp
  8010fc:	89 e5                	mov    %esp,%ebp
  8010fe:	83 ec 08             	sub    $0x8,%esp
  801101:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801104:	ba bc 24 80 00       	mov    $0x8024bc,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801109:	eb 13                	jmp    80111e <dev_lookup+0x23>
  80110b:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80110e:	39 08                	cmp    %ecx,(%eax)
  801110:	75 0c                	jne    80111e <dev_lookup+0x23>
			*dev = devtab[i];
  801112:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801115:	89 01                	mov    %eax,(%ecx)
			return 0;
  801117:	b8 00 00 00 00       	mov    $0x0,%eax
  80111c:	eb 2e                	jmp    80114c <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80111e:	8b 02                	mov    (%edx),%eax
  801120:	85 c0                	test   %eax,%eax
  801122:	75 e7                	jne    80110b <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801124:	a1 04 44 80 00       	mov    0x804404,%eax
  801129:	8b 40 48             	mov    0x48(%eax),%eax
  80112c:	83 ec 04             	sub    $0x4,%esp
  80112f:	51                   	push   %ecx
  801130:	50                   	push   %eax
  801131:	68 3c 24 80 00       	push   $0x80243c
  801136:	e8 6a f2 ff ff       	call   8003a5 <cprintf>
	*dev = 0;
  80113b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80113e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801144:	83 c4 10             	add    $0x10,%esp
  801147:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80114c:	c9                   	leave  
  80114d:	c3                   	ret    

0080114e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80114e:	55                   	push   %ebp
  80114f:	89 e5                	mov    %esp,%ebp
  801151:	56                   	push   %esi
  801152:	53                   	push   %ebx
  801153:	83 ec 10             	sub    $0x10,%esp
  801156:	8b 75 08             	mov    0x8(%ebp),%esi
  801159:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80115c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80115f:	50                   	push   %eax
  801160:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801166:	c1 e8 0c             	shr    $0xc,%eax
  801169:	50                   	push   %eax
  80116a:	e8 36 ff ff ff       	call   8010a5 <fd_lookup>
  80116f:	83 c4 08             	add    $0x8,%esp
  801172:	85 c0                	test   %eax,%eax
  801174:	78 05                	js     80117b <fd_close+0x2d>
	    || fd != fd2)
  801176:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801179:	74 0c                	je     801187 <fd_close+0x39>
		return (must_exist ? r : 0);
  80117b:	84 db                	test   %bl,%bl
  80117d:	ba 00 00 00 00       	mov    $0x0,%edx
  801182:	0f 44 c2             	cmove  %edx,%eax
  801185:	eb 41                	jmp    8011c8 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801187:	83 ec 08             	sub    $0x8,%esp
  80118a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80118d:	50                   	push   %eax
  80118e:	ff 36                	pushl  (%esi)
  801190:	e8 66 ff ff ff       	call   8010fb <dev_lookup>
  801195:	89 c3                	mov    %eax,%ebx
  801197:	83 c4 10             	add    $0x10,%esp
  80119a:	85 c0                	test   %eax,%eax
  80119c:	78 1a                	js     8011b8 <fd_close+0x6a>
		if (dev->dev_close)
  80119e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011a1:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8011a4:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8011a9:	85 c0                	test   %eax,%eax
  8011ab:	74 0b                	je     8011b8 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8011ad:	83 ec 0c             	sub    $0xc,%esp
  8011b0:	56                   	push   %esi
  8011b1:	ff d0                	call   *%eax
  8011b3:	89 c3                	mov    %eax,%ebx
  8011b5:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8011b8:	83 ec 08             	sub    $0x8,%esp
  8011bb:	56                   	push   %esi
  8011bc:	6a 00                	push   $0x0
  8011be:	e8 00 fd ff ff       	call   800ec3 <sys_page_unmap>
	return r;
  8011c3:	83 c4 10             	add    $0x10,%esp
  8011c6:	89 d8                	mov    %ebx,%eax
}
  8011c8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011cb:	5b                   	pop    %ebx
  8011cc:	5e                   	pop    %esi
  8011cd:	5d                   	pop    %ebp
  8011ce:	c3                   	ret    

008011cf <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8011cf:	55                   	push   %ebp
  8011d0:	89 e5                	mov    %esp,%ebp
  8011d2:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011d8:	50                   	push   %eax
  8011d9:	ff 75 08             	pushl  0x8(%ebp)
  8011dc:	e8 c4 fe ff ff       	call   8010a5 <fd_lookup>
  8011e1:	83 c4 08             	add    $0x8,%esp
  8011e4:	85 c0                	test   %eax,%eax
  8011e6:	78 10                	js     8011f8 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8011e8:	83 ec 08             	sub    $0x8,%esp
  8011eb:	6a 01                	push   $0x1
  8011ed:	ff 75 f4             	pushl  -0xc(%ebp)
  8011f0:	e8 59 ff ff ff       	call   80114e <fd_close>
  8011f5:	83 c4 10             	add    $0x10,%esp
}
  8011f8:	c9                   	leave  
  8011f9:	c3                   	ret    

008011fa <close_all>:

void
close_all(void)
{
  8011fa:	55                   	push   %ebp
  8011fb:	89 e5                	mov    %esp,%ebp
  8011fd:	53                   	push   %ebx
  8011fe:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801201:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801206:	83 ec 0c             	sub    $0xc,%esp
  801209:	53                   	push   %ebx
  80120a:	e8 c0 ff ff ff       	call   8011cf <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80120f:	83 c3 01             	add    $0x1,%ebx
  801212:	83 c4 10             	add    $0x10,%esp
  801215:	83 fb 20             	cmp    $0x20,%ebx
  801218:	75 ec                	jne    801206 <close_all+0xc>
		close(i);
}
  80121a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80121d:	c9                   	leave  
  80121e:	c3                   	ret    

0080121f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80121f:	55                   	push   %ebp
  801220:	89 e5                	mov    %esp,%ebp
  801222:	57                   	push   %edi
  801223:	56                   	push   %esi
  801224:	53                   	push   %ebx
  801225:	83 ec 2c             	sub    $0x2c,%esp
  801228:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80122b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80122e:	50                   	push   %eax
  80122f:	ff 75 08             	pushl  0x8(%ebp)
  801232:	e8 6e fe ff ff       	call   8010a5 <fd_lookup>
  801237:	83 c4 08             	add    $0x8,%esp
  80123a:	85 c0                	test   %eax,%eax
  80123c:	0f 88 c1 00 00 00    	js     801303 <dup+0xe4>
		return r;
	close(newfdnum);
  801242:	83 ec 0c             	sub    $0xc,%esp
  801245:	56                   	push   %esi
  801246:	e8 84 ff ff ff       	call   8011cf <close>

	newfd = INDEX2FD(newfdnum);
  80124b:	89 f3                	mov    %esi,%ebx
  80124d:	c1 e3 0c             	shl    $0xc,%ebx
  801250:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801256:	83 c4 04             	add    $0x4,%esp
  801259:	ff 75 e4             	pushl  -0x1c(%ebp)
  80125c:	e8 de fd ff ff       	call   80103f <fd2data>
  801261:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801263:	89 1c 24             	mov    %ebx,(%esp)
  801266:	e8 d4 fd ff ff       	call   80103f <fd2data>
  80126b:	83 c4 10             	add    $0x10,%esp
  80126e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801271:	89 f8                	mov    %edi,%eax
  801273:	c1 e8 16             	shr    $0x16,%eax
  801276:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80127d:	a8 01                	test   $0x1,%al
  80127f:	74 37                	je     8012b8 <dup+0x99>
  801281:	89 f8                	mov    %edi,%eax
  801283:	c1 e8 0c             	shr    $0xc,%eax
  801286:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80128d:	f6 c2 01             	test   $0x1,%dl
  801290:	74 26                	je     8012b8 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801292:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801299:	83 ec 0c             	sub    $0xc,%esp
  80129c:	25 07 0e 00 00       	and    $0xe07,%eax
  8012a1:	50                   	push   %eax
  8012a2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012a5:	6a 00                	push   $0x0
  8012a7:	57                   	push   %edi
  8012a8:	6a 00                	push   $0x0
  8012aa:	e8 d2 fb ff ff       	call   800e81 <sys_page_map>
  8012af:	89 c7                	mov    %eax,%edi
  8012b1:	83 c4 20             	add    $0x20,%esp
  8012b4:	85 c0                	test   %eax,%eax
  8012b6:	78 2e                	js     8012e6 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012b8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8012bb:	89 d0                	mov    %edx,%eax
  8012bd:	c1 e8 0c             	shr    $0xc,%eax
  8012c0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012c7:	83 ec 0c             	sub    $0xc,%esp
  8012ca:	25 07 0e 00 00       	and    $0xe07,%eax
  8012cf:	50                   	push   %eax
  8012d0:	53                   	push   %ebx
  8012d1:	6a 00                	push   $0x0
  8012d3:	52                   	push   %edx
  8012d4:	6a 00                	push   $0x0
  8012d6:	e8 a6 fb ff ff       	call   800e81 <sys_page_map>
  8012db:	89 c7                	mov    %eax,%edi
  8012dd:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8012e0:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012e2:	85 ff                	test   %edi,%edi
  8012e4:	79 1d                	jns    801303 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8012e6:	83 ec 08             	sub    $0x8,%esp
  8012e9:	53                   	push   %ebx
  8012ea:	6a 00                	push   $0x0
  8012ec:	e8 d2 fb ff ff       	call   800ec3 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8012f1:	83 c4 08             	add    $0x8,%esp
  8012f4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012f7:	6a 00                	push   $0x0
  8012f9:	e8 c5 fb ff ff       	call   800ec3 <sys_page_unmap>
	return r;
  8012fe:	83 c4 10             	add    $0x10,%esp
  801301:	89 f8                	mov    %edi,%eax
}
  801303:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801306:	5b                   	pop    %ebx
  801307:	5e                   	pop    %esi
  801308:	5f                   	pop    %edi
  801309:	5d                   	pop    %ebp
  80130a:	c3                   	ret    

0080130b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80130b:	55                   	push   %ebp
  80130c:	89 e5                	mov    %esp,%ebp
  80130e:	53                   	push   %ebx
  80130f:	83 ec 14             	sub    $0x14,%esp
  801312:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801315:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801318:	50                   	push   %eax
  801319:	53                   	push   %ebx
  80131a:	e8 86 fd ff ff       	call   8010a5 <fd_lookup>
  80131f:	83 c4 08             	add    $0x8,%esp
  801322:	89 c2                	mov    %eax,%edx
  801324:	85 c0                	test   %eax,%eax
  801326:	78 6d                	js     801395 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801328:	83 ec 08             	sub    $0x8,%esp
  80132b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80132e:	50                   	push   %eax
  80132f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801332:	ff 30                	pushl  (%eax)
  801334:	e8 c2 fd ff ff       	call   8010fb <dev_lookup>
  801339:	83 c4 10             	add    $0x10,%esp
  80133c:	85 c0                	test   %eax,%eax
  80133e:	78 4c                	js     80138c <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801340:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801343:	8b 42 08             	mov    0x8(%edx),%eax
  801346:	83 e0 03             	and    $0x3,%eax
  801349:	83 f8 01             	cmp    $0x1,%eax
  80134c:	75 21                	jne    80136f <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80134e:	a1 04 44 80 00       	mov    0x804404,%eax
  801353:	8b 40 48             	mov    0x48(%eax),%eax
  801356:	83 ec 04             	sub    $0x4,%esp
  801359:	53                   	push   %ebx
  80135a:	50                   	push   %eax
  80135b:	68 80 24 80 00       	push   $0x802480
  801360:	e8 40 f0 ff ff       	call   8003a5 <cprintf>
		return -E_INVAL;
  801365:	83 c4 10             	add    $0x10,%esp
  801368:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80136d:	eb 26                	jmp    801395 <read+0x8a>
	}
	if (!dev->dev_read)
  80136f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801372:	8b 40 08             	mov    0x8(%eax),%eax
  801375:	85 c0                	test   %eax,%eax
  801377:	74 17                	je     801390 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801379:	83 ec 04             	sub    $0x4,%esp
  80137c:	ff 75 10             	pushl  0x10(%ebp)
  80137f:	ff 75 0c             	pushl  0xc(%ebp)
  801382:	52                   	push   %edx
  801383:	ff d0                	call   *%eax
  801385:	89 c2                	mov    %eax,%edx
  801387:	83 c4 10             	add    $0x10,%esp
  80138a:	eb 09                	jmp    801395 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80138c:	89 c2                	mov    %eax,%edx
  80138e:	eb 05                	jmp    801395 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801390:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801395:	89 d0                	mov    %edx,%eax
  801397:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80139a:	c9                   	leave  
  80139b:	c3                   	ret    

0080139c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80139c:	55                   	push   %ebp
  80139d:	89 e5                	mov    %esp,%ebp
  80139f:	57                   	push   %edi
  8013a0:	56                   	push   %esi
  8013a1:	53                   	push   %ebx
  8013a2:	83 ec 0c             	sub    $0xc,%esp
  8013a5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013a8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013ab:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013b0:	eb 21                	jmp    8013d3 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013b2:	83 ec 04             	sub    $0x4,%esp
  8013b5:	89 f0                	mov    %esi,%eax
  8013b7:	29 d8                	sub    %ebx,%eax
  8013b9:	50                   	push   %eax
  8013ba:	89 d8                	mov    %ebx,%eax
  8013bc:	03 45 0c             	add    0xc(%ebp),%eax
  8013bf:	50                   	push   %eax
  8013c0:	57                   	push   %edi
  8013c1:	e8 45 ff ff ff       	call   80130b <read>
		if (m < 0)
  8013c6:	83 c4 10             	add    $0x10,%esp
  8013c9:	85 c0                	test   %eax,%eax
  8013cb:	78 10                	js     8013dd <readn+0x41>
			return m;
		if (m == 0)
  8013cd:	85 c0                	test   %eax,%eax
  8013cf:	74 0a                	je     8013db <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013d1:	01 c3                	add    %eax,%ebx
  8013d3:	39 f3                	cmp    %esi,%ebx
  8013d5:	72 db                	jb     8013b2 <readn+0x16>
  8013d7:	89 d8                	mov    %ebx,%eax
  8013d9:	eb 02                	jmp    8013dd <readn+0x41>
  8013db:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8013dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013e0:	5b                   	pop    %ebx
  8013e1:	5e                   	pop    %esi
  8013e2:	5f                   	pop    %edi
  8013e3:	5d                   	pop    %ebp
  8013e4:	c3                   	ret    

008013e5 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8013e5:	55                   	push   %ebp
  8013e6:	89 e5                	mov    %esp,%ebp
  8013e8:	53                   	push   %ebx
  8013e9:	83 ec 14             	sub    $0x14,%esp
  8013ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013ef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013f2:	50                   	push   %eax
  8013f3:	53                   	push   %ebx
  8013f4:	e8 ac fc ff ff       	call   8010a5 <fd_lookup>
  8013f9:	83 c4 08             	add    $0x8,%esp
  8013fc:	89 c2                	mov    %eax,%edx
  8013fe:	85 c0                	test   %eax,%eax
  801400:	78 68                	js     80146a <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801402:	83 ec 08             	sub    $0x8,%esp
  801405:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801408:	50                   	push   %eax
  801409:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80140c:	ff 30                	pushl  (%eax)
  80140e:	e8 e8 fc ff ff       	call   8010fb <dev_lookup>
  801413:	83 c4 10             	add    $0x10,%esp
  801416:	85 c0                	test   %eax,%eax
  801418:	78 47                	js     801461 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80141a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80141d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801421:	75 21                	jne    801444 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801423:	a1 04 44 80 00       	mov    0x804404,%eax
  801428:	8b 40 48             	mov    0x48(%eax),%eax
  80142b:	83 ec 04             	sub    $0x4,%esp
  80142e:	53                   	push   %ebx
  80142f:	50                   	push   %eax
  801430:	68 9c 24 80 00       	push   $0x80249c
  801435:	e8 6b ef ff ff       	call   8003a5 <cprintf>
		return -E_INVAL;
  80143a:	83 c4 10             	add    $0x10,%esp
  80143d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801442:	eb 26                	jmp    80146a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801444:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801447:	8b 52 0c             	mov    0xc(%edx),%edx
  80144a:	85 d2                	test   %edx,%edx
  80144c:	74 17                	je     801465 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80144e:	83 ec 04             	sub    $0x4,%esp
  801451:	ff 75 10             	pushl  0x10(%ebp)
  801454:	ff 75 0c             	pushl  0xc(%ebp)
  801457:	50                   	push   %eax
  801458:	ff d2                	call   *%edx
  80145a:	89 c2                	mov    %eax,%edx
  80145c:	83 c4 10             	add    $0x10,%esp
  80145f:	eb 09                	jmp    80146a <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801461:	89 c2                	mov    %eax,%edx
  801463:	eb 05                	jmp    80146a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801465:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80146a:	89 d0                	mov    %edx,%eax
  80146c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80146f:	c9                   	leave  
  801470:	c3                   	ret    

00801471 <seek>:

int
seek(int fdnum, off_t offset)
{
  801471:	55                   	push   %ebp
  801472:	89 e5                	mov    %esp,%ebp
  801474:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801477:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80147a:	50                   	push   %eax
  80147b:	ff 75 08             	pushl  0x8(%ebp)
  80147e:	e8 22 fc ff ff       	call   8010a5 <fd_lookup>
  801483:	83 c4 08             	add    $0x8,%esp
  801486:	85 c0                	test   %eax,%eax
  801488:	78 0e                	js     801498 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80148a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80148d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801490:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801493:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801498:	c9                   	leave  
  801499:	c3                   	ret    

0080149a <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80149a:	55                   	push   %ebp
  80149b:	89 e5                	mov    %esp,%ebp
  80149d:	53                   	push   %ebx
  80149e:	83 ec 14             	sub    $0x14,%esp
  8014a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014a4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014a7:	50                   	push   %eax
  8014a8:	53                   	push   %ebx
  8014a9:	e8 f7 fb ff ff       	call   8010a5 <fd_lookup>
  8014ae:	83 c4 08             	add    $0x8,%esp
  8014b1:	89 c2                	mov    %eax,%edx
  8014b3:	85 c0                	test   %eax,%eax
  8014b5:	78 65                	js     80151c <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014b7:	83 ec 08             	sub    $0x8,%esp
  8014ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014bd:	50                   	push   %eax
  8014be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014c1:	ff 30                	pushl  (%eax)
  8014c3:	e8 33 fc ff ff       	call   8010fb <dev_lookup>
  8014c8:	83 c4 10             	add    $0x10,%esp
  8014cb:	85 c0                	test   %eax,%eax
  8014cd:	78 44                	js     801513 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014d2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014d6:	75 21                	jne    8014f9 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8014d8:	a1 04 44 80 00       	mov    0x804404,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8014dd:	8b 40 48             	mov    0x48(%eax),%eax
  8014e0:	83 ec 04             	sub    $0x4,%esp
  8014e3:	53                   	push   %ebx
  8014e4:	50                   	push   %eax
  8014e5:	68 5c 24 80 00       	push   $0x80245c
  8014ea:	e8 b6 ee ff ff       	call   8003a5 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8014ef:	83 c4 10             	add    $0x10,%esp
  8014f2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014f7:	eb 23                	jmp    80151c <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8014f9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014fc:	8b 52 18             	mov    0x18(%edx),%edx
  8014ff:	85 d2                	test   %edx,%edx
  801501:	74 14                	je     801517 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801503:	83 ec 08             	sub    $0x8,%esp
  801506:	ff 75 0c             	pushl  0xc(%ebp)
  801509:	50                   	push   %eax
  80150a:	ff d2                	call   *%edx
  80150c:	89 c2                	mov    %eax,%edx
  80150e:	83 c4 10             	add    $0x10,%esp
  801511:	eb 09                	jmp    80151c <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801513:	89 c2                	mov    %eax,%edx
  801515:	eb 05                	jmp    80151c <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801517:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80151c:	89 d0                	mov    %edx,%eax
  80151e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801521:	c9                   	leave  
  801522:	c3                   	ret    

00801523 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801523:	55                   	push   %ebp
  801524:	89 e5                	mov    %esp,%ebp
  801526:	53                   	push   %ebx
  801527:	83 ec 14             	sub    $0x14,%esp
  80152a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80152d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801530:	50                   	push   %eax
  801531:	ff 75 08             	pushl  0x8(%ebp)
  801534:	e8 6c fb ff ff       	call   8010a5 <fd_lookup>
  801539:	83 c4 08             	add    $0x8,%esp
  80153c:	89 c2                	mov    %eax,%edx
  80153e:	85 c0                	test   %eax,%eax
  801540:	78 58                	js     80159a <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801542:	83 ec 08             	sub    $0x8,%esp
  801545:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801548:	50                   	push   %eax
  801549:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80154c:	ff 30                	pushl  (%eax)
  80154e:	e8 a8 fb ff ff       	call   8010fb <dev_lookup>
  801553:	83 c4 10             	add    $0x10,%esp
  801556:	85 c0                	test   %eax,%eax
  801558:	78 37                	js     801591 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80155a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80155d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801561:	74 32                	je     801595 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801563:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801566:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80156d:	00 00 00 
	stat->st_isdir = 0;
  801570:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801577:	00 00 00 
	stat->st_dev = dev;
  80157a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801580:	83 ec 08             	sub    $0x8,%esp
  801583:	53                   	push   %ebx
  801584:	ff 75 f0             	pushl  -0x10(%ebp)
  801587:	ff 50 14             	call   *0x14(%eax)
  80158a:	89 c2                	mov    %eax,%edx
  80158c:	83 c4 10             	add    $0x10,%esp
  80158f:	eb 09                	jmp    80159a <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801591:	89 c2                	mov    %eax,%edx
  801593:	eb 05                	jmp    80159a <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801595:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80159a:	89 d0                	mov    %edx,%eax
  80159c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80159f:	c9                   	leave  
  8015a0:	c3                   	ret    

008015a1 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015a1:	55                   	push   %ebp
  8015a2:	89 e5                	mov    %esp,%ebp
  8015a4:	56                   	push   %esi
  8015a5:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015a6:	83 ec 08             	sub    $0x8,%esp
  8015a9:	6a 00                	push   $0x0
  8015ab:	ff 75 08             	pushl  0x8(%ebp)
  8015ae:	e8 e3 01 00 00       	call   801796 <open>
  8015b3:	89 c3                	mov    %eax,%ebx
  8015b5:	83 c4 10             	add    $0x10,%esp
  8015b8:	85 c0                	test   %eax,%eax
  8015ba:	78 1b                	js     8015d7 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8015bc:	83 ec 08             	sub    $0x8,%esp
  8015bf:	ff 75 0c             	pushl  0xc(%ebp)
  8015c2:	50                   	push   %eax
  8015c3:	e8 5b ff ff ff       	call   801523 <fstat>
  8015c8:	89 c6                	mov    %eax,%esi
	close(fd);
  8015ca:	89 1c 24             	mov    %ebx,(%esp)
  8015cd:	e8 fd fb ff ff       	call   8011cf <close>
	return r;
  8015d2:	83 c4 10             	add    $0x10,%esp
  8015d5:	89 f0                	mov    %esi,%eax
}
  8015d7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015da:	5b                   	pop    %ebx
  8015db:	5e                   	pop    %esi
  8015dc:	5d                   	pop    %ebp
  8015dd:	c3                   	ret    

008015de <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8015de:	55                   	push   %ebp
  8015df:	89 e5                	mov    %esp,%ebp
  8015e1:	56                   	push   %esi
  8015e2:	53                   	push   %ebx
  8015e3:	89 c6                	mov    %eax,%esi
  8015e5:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8015e7:	83 3d 00 44 80 00 00 	cmpl   $0x0,0x804400
  8015ee:	75 12                	jne    801602 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8015f0:	83 ec 0c             	sub    $0xc,%esp
  8015f3:	6a 01                	push   $0x1
  8015f5:	e8 55 07 00 00       	call   801d4f <ipc_find_env>
  8015fa:	a3 00 44 80 00       	mov    %eax,0x804400
  8015ff:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801602:	6a 07                	push   $0x7
  801604:	68 00 50 80 00       	push   $0x805000
  801609:	56                   	push   %esi
  80160a:	ff 35 00 44 80 00    	pushl  0x804400
  801610:	e8 e6 06 00 00       	call   801cfb <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801615:	83 c4 0c             	add    $0xc,%esp
  801618:	6a 00                	push   $0x0
  80161a:	53                   	push   %ebx
  80161b:	6a 00                	push   $0x0
  80161d:	e8 84 06 00 00       	call   801ca6 <ipc_recv>
}
  801622:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801625:	5b                   	pop    %ebx
  801626:	5e                   	pop    %esi
  801627:	5d                   	pop    %ebp
  801628:	c3                   	ret    

00801629 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801629:	55                   	push   %ebp
  80162a:	89 e5                	mov    %esp,%ebp
  80162c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80162f:	8b 45 08             	mov    0x8(%ebp),%eax
  801632:	8b 40 0c             	mov    0xc(%eax),%eax
  801635:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80163a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80163d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801642:	ba 00 00 00 00       	mov    $0x0,%edx
  801647:	b8 02 00 00 00       	mov    $0x2,%eax
  80164c:	e8 8d ff ff ff       	call   8015de <fsipc>
}
  801651:	c9                   	leave  
  801652:	c3                   	ret    

00801653 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801653:	55                   	push   %ebp
  801654:	89 e5                	mov    %esp,%ebp
  801656:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801659:	8b 45 08             	mov    0x8(%ebp),%eax
  80165c:	8b 40 0c             	mov    0xc(%eax),%eax
  80165f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801664:	ba 00 00 00 00       	mov    $0x0,%edx
  801669:	b8 06 00 00 00       	mov    $0x6,%eax
  80166e:	e8 6b ff ff ff       	call   8015de <fsipc>
}
  801673:	c9                   	leave  
  801674:	c3                   	ret    

00801675 <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801675:	55                   	push   %ebp
  801676:	89 e5                	mov    %esp,%ebp
  801678:	53                   	push   %ebx
  801679:	83 ec 04             	sub    $0x4,%esp
  80167c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80167f:	8b 45 08             	mov    0x8(%ebp),%eax
  801682:	8b 40 0c             	mov    0xc(%eax),%eax
  801685:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80168a:	ba 00 00 00 00       	mov    $0x0,%edx
  80168f:	b8 05 00 00 00       	mov    $0x5,%eax
  801694:	e8 45 ff ff ff       	call   8015de <fsipc>
  801699:	85 c0                	test   %eax,%eax
  80169b:	78 2c                	js     8016c9 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80169d:	83 ec 08             	sub    $0x8,%esp
  8016a0:	68 00 50 80 00       	push   $0x805000
  8016a5:	53                   	push   %ebx
  8016a6:	e8 90 f3 ff ff       	call   800a3b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016ab:	a1 80 50 80 00       	mov    0x805080,%eax
  8016b0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016b6:	a1 84 50 80 00       	mov    0x805084,%eax
  8016bb:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016c1:	83 c4 10             	add    $0x10,%esp
  8016c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016cc:	c9                   	leave  
  8016cd:	c3                   	ret    

008016ce <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8016ce:	55                   	push   %ebp
  8016cf:	89 e5                	mov    %esp,%ebp
  8016d1:	83 ec 0c             	sub    $0xc,%esp
  8016d4:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
    
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  8016d7:	8b 55 08             	mov    0x8(%ebp),%edx
  8016da:	8b 52 0c             	mov    0xc(%edx),%edx
  8016dd:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = MIN(n, PGSIZE);
  8016e3:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8016e8:	ba 00 10 00 00       	mov    $0x1000,%edx
  8016ed:	0f 47 c2             	cmova  %edx,%eax
  8016f0:	a3 04 50 80 00       	mov    %eax,0x805004
    memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8016f5:	50                   	push   %eax
  8016f6:	ff 75 0c             	pushl  0xc(%ebp)
  8016f9:	68 08 50 80 00       	push   $0x805008
  8016fe:	e8 ca f4 ff ff       	call   800bcd <memmove>
    int r = fsipc(FSREQ_WRITE, NULL);
  801703:	ba 00 00 00 00       	mov    $0x0,%edx
  801708:	b8 04 00 00 00       	mov    $0x4,%eax
  80170d:	e8 cc fe ff ff       	call   8015de <fsipc>
    return r;
}
  801712:	c9                   	leave  
  801713:	c3                   	ret    

00801714 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801714:	55                   	push   %ebp
  801715:	89 e5                	mov    %esp,%ebp
  801717:	56                   	push   %esi
  801718:	53                   	push   %ebx
  801719:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80171c:	8b 45 08             	mov    0x8(%ebp),%eax
  80171f:	8b 40 0c             	mov    0xc(%eax),%eax
  801722:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801727:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80172d:	ba 00 00 00 00       	mov    $0x0,%edx
  801732:	b8 03 00 00 00       	mov    $0x3,%eax
  801737:	e8 a2 fe ff ff       	call   8015de <fsipc>
  80173c:	89 c3                	mov    %eax,%ebx
  80173e:	85 c0                	test   %eax,%eax
  801740:	78 4b                	js     80178d <devfile_read+0x79>
		return r;
	assert(r <= n);
  801742:	39 c6                	cmp    %eax,%esi
  801744:	73 16                	jae    80175c <devfile_read+0x48>
  801746:	68 cc 24 80 00       	push   $0x8024cc
  80174b:	68 d3 24 80 00       	push   $0x8024d3
  801750:	6a 7c                	push   $0x7c
  801752:	68 e8 24 80 00       	push   $0x8024e8
  801757:	e8 70 eb ff ff       	call   8002cc <_panic>
	assert(r <= PGSIZE);
  80175c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801761:	7e 16                	jle    801779 <devfile_read+0x65>
  801763:	68 f3 24 80 00       	push   $0x8024f3
  801768:	68 d3 24 80 00       	push   $0x8024d3
  80176d:	6a 7d                	push   $0x7d
  80176f:	68 e8 24 80 00       	push   $0x8024e8
  801774:	e8 53 eb ff ff       	call   8002cc <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801779:	83 ec 04             	sub    $0x4,%esp
  80177c:	50                   	push   %eax
  80177d:	68 00 50 80 00       	push   $0x805000
  801782:	ff 75 0c             	pushl  0xc(%ebp)
  801785:	e8 43 f4 ff ff       	call   800bcd <memmove>
	return r;
  80178a:	83 c4 10             	add    $0x10,%esp
}
  80178d:	89 d8                	mov    %ebx,%eax
  80178f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801792:	5b                   	pop    %ebx
  801793:	5e                   	pop    %esi
  801794:	5d                   	pop    %ebp
  801795:	c3                   	ret    

00801796 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801796:	55                   	push   %ebp
  801797:	89 e5                	mov    %esp,%ebp
  801799:	53                   	push   %ebx
  80179a:	83 ec 20             	sub    $0x20,%esp
  80179d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8017a0:	53                   	push   %ebx
  8017a1:	e8 5c f2 ff ff       	call   800a02 <strlen>
  8017a6:	83 c4 10             	add    $0x10,%esp
  8017a9:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017ae:	7f 67                	jg     801817 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017b0:	83 ec 0c             	sub    $0xc,%esp
  8017b3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017b6:	50                   	push   %eax
  8017b7:	e8 9a f8 ff ff       	call   801056 <fd_alloc>
  8017bc:	83 c4 10             	add    $0x10,%esp
		return r;
  8017bf:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017c1:	85 c0                	test   %eax,%eax
  8017c3:	78 57                	js     80181c <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8017c5:	83 ec 08             	sub    $0x8,%esp
  8017c8:	53                   	push   %ebx
  8017c9:	68 00 50 80 00       	push   $0x805000
  8017ce:	e8 68 f2 ff ff       	call   800a3b <strcpy>
	fsipcbuf.open.req_omode = mode;
  8017d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017d6:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8017db:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017de:	b8 01 00 00 00       	mov    $0x1,%eax
  8017e3:	e8 f6 fd ff ff       	call   8015de <fsipc>
  8017e8:	89 c3                	mov    %eax,%ebx
  8017ea:	83 c4 10             	add    $0x10,%esp
  8017ed:	85 c0                	test   %eax,%eax
  8017ef:	79 14                	jns    801805 <open+0x6f>
		fd_close(fd, 0);
  8017f1:	83 ec 08             	sub    $0x8,%esp
  8017f4:	6a 00                	push   $0x0
  8017f6:	ff 75 f4             	pushl  -0xc(%ebp)
  8017f9:	e8 50 f9 ff ff       	call   80114e <fd_close>
		return r;
  8017fe:	83 c4 10             	add    $0x10,%esp
  801801:	89 da                	mov    %ebx,%edx
  801803:	eb 17                	jmp    80181c <open+0x86>
	}

	return fd2num(fd);
  801805:	83 ec 0c             	sub    $0xc,%esp
  801808:	ff 75 f4             	pushl  -0xc(%ebp)
  80180b:	e8 1f f8 ff ff       	call   80102f <fd2num>
  801810:	89 c2                	mov    %eax,%edx
  801812:	83 c4 10             	add    $0x10,%esp
  801815:	eb 05                	jmp    80181c <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801817:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80181c:	89 d0                	mov    %edx,%eax
  80181e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801821:	c9                   	leave  
  801822:	c3                   	ret    

00801823 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801823:	55                   	push   %ebp
  801824:	89 e5                	mov    %esp,%ebp
  801826:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801829:	ba 00 00 00 00       	mov    $0x0,%edx
  80182e:	b8 08 00 00 00       	mov    $0x8,%eax
  801833:	e8 a6 fd ff ff       	call   8015de <fsipc>
}
  801838:	c9                   	leave  
  801839:	c3                   	ret    

0080183a <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  80183a:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  80183e:	7e 37                	jle    801877 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  801840:	55                   	push   %ebp
  801841:	89 e5                	mov    %esp,%ebp
  801843:	53                   	push   %ebx
  801844:	83 ec 08             	sub    $0x8,%esp
  801847:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  801849:	ff 70 04             	pushl  0x4(%eax)
  80184c:	8d 40 10             	lea    0x10(%eax),%eax
  80184f:	50                   	push   %eax
  801850:	ff 33                	pushl  (%ebx)
  801852:	e8 8e fb ff ff       	call   8013e5 <write>
		if (result > 0)
  801857:	83 c4 10             	add    $0x10,%esp
  80185a:	85 c0                	test   %eax,%eax
  80185c:	7e 03                	jle    801861 <writebuf+0x27>
			b->result += result;
  80185e:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801861:	3b 43 04             	cmp    0x4(%ebx),%eax
  801864:	74 0d                	je     801873 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  801866:	85 c0                	test   %eax,%eax
  801868:	ba 00 00 00 00       	mov    $0x0,%edx
  80186d:	0f 4f c2             	cmovg  %edx,%eax
  801870:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801873:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801876:	c9                   	leave  
  801877:	f3 c3                	repz ret 

00801879 <putch>:

static void
putch(int ch, void *thunk)
{
  801879:	55                   	push   %ebp
  80187a:	89 e5                	mov    %esp,%ebp
  80187c:	53                   	push   %ebx
  80187d:	83 ec 04             	sub    $0x4,%esp
  801880:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801883:	8b 53 04             	mov    0x4(%ebx),%edx
  801886:	8d 42 01             	lea    0x1(%edx),%eax
  801889:	89 43 04             	mov    %eax,0x4(%ebx)
  80188c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80188f:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801893:	3d 00 01 00 00       	cmp    $0x100,%eax
  801898:	75 0e                	jne    8018a8 <putch+0x2f>
		writebuf(b);
  80189a:	89 d8                	mov    %ebx,%eax
  80189c:	e8 99 ff ff ff       	call   80183a <writebuf>
		b->idx = 0;
  8018a1:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8018a8:	83 c4 04             	add    $0x4,%esp
  8018ab:	5b                   	pop    %ebx
  8018ac:	5d                   	pop    %ebp
  8018ad:	c3                   	ret    

008018ae <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8018ae:	55                   	push   %ebp
  8018af:	89 e5                	mov    %esp,%ebp
  8018b1:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8018b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ba:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8018c0:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8018c7:	00 00 00 
	b.result = 0;
  8018ca:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8018d1:	00 00 00 
	b.error = 1;
  8018d4:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8018db:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8018de:	ff 75 10             	pushl  0x10(%ebp)
  8018e1:	ff 75 0c             	pushl  0xc(%ebp)
  8018e4:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8018ea:	50                   	push   %eax
  8018eb:	68 79 18 80 00       	push   $0x801879
  8018f0:	e8 e7 eb ff ff       	call   8004dc <vprintfmt>
	if (b.idx > 0)
  8018f5:	83 c4 10             	add    $0x10,%esp
  8018f8:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8018ff:	7e 0b                	jle    80190c <vfprintf+0x5e>
		writebuf(&b);
  801901:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801907:	e8 2e ff ff ff       	call   80183a <writebuf>

	return (b.result ? b.result : b.error);
  80190c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801912:	85 c0                	test   %eax,%eax
  801914:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  80191b:	c9                   	leave  
  80191c:	c3                   	ret    

0080191d <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  80191d:	55                   	push   %ebp
  80191e:	89 e5                	mov    %esp,%ebp
  801920:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801923:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801926:	50                   	push   %eax
  801927:	ff 75 0c             	pushl  0xc(%ebp)
  80192a:	ff 75 08             	pushl  0x8(%ebp)
  80192d:	e8 7c ff ff ff       	call   8018ae <vfprintf>
	va_end(ap);

	return cnt;
}
  801932:	c9                   	leave  
  801933:	c3                   	ret    

00801934 <printf>:

int
printf(const char *fmt, ...)
{
  801934:	55                   	push   %ebp
  801935:	89 e5                	mov    %esp,%ebp
  801937:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80193a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  80193d:	50                   	push   %eax
  80193e:	ff 75 08             	pushl  0x8(%ebp)
  801941:	6a 01                	push   $0x1
  801943:	e8 66 ff ff ff       	call   8018ae <vfprintf>
	va_end(ap);

	return cnt;
}
  801948:	c9                   	leave  
  801949:	c3                   	ret    

0080194a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80194a:	55                   	push   %ebp
  80194b:	89 e5                	mov    %esp,%ebp
  80194d:	56                   	push   %esi
  80194e:	53                   	push   %ebx
  80194f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801952:	83 ec 0c             	sub    $0xc,%esp
  801955:	ff 75 08             	pushl  0x8(%ebp)
  801958:	e8 e2 f6 ff ff       	call   80103f <fd2data>
  80195d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80195f:	83 c4 08             	add    $0x8,%esp
  801962:	68 ff 24 80 00       	push   $0x8024ff
  801967:	53                   	push   %ebx
  801968:	e8 ce f0 ff ff       	call   800a3b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80196d:	8b 46 04             	mov    0x4(%esi),%eax
  801970:	2b 06                	sub    (%esi),%eax
  801972:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801978:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80197f:	00 00 00 
	stat->st_dev = &devpipe;
  801982:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801989:	30 80 00 
	return 0;
}
  80198c:	b8 00 00 00 00       	mov    $0x0,%eax
  801991:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801994:	5b                   	pop    %ebx
  801995:	5e                   	pop    %esi
  801996:	5d                   	pop    %ebp
  801997:	c3                   	ret    

00801998 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801998:	55                   	push   %ebp
  801999:	89 e5                	mov    %esp,%ebp
  80199b:	53                   	push   %ebx
  80199c:	83 ec 0c             	sub    $0xc,%esp
  80199f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019a2:	53                   	push   %ebx
  8019a3:	6a 00                	push   $0x0
  8019a5:	e8 19 f5 ff ff       	call   800ec3 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019aa:	89 1c 24             	mov    %ebx,(%esp)
  8019ad:	e8 8d f6 ff ff       	call   80103f <fd2data>
  8019b2:	83 c4 08             	add    $0x8,%esp
  8019b5:	50                   	push   %eax
  8019b6:	6a 00                	push   $0x0
  8019b8:	e8 06 f5 ff ff       	call   800ec3 <sys_page_unmap>
}
  8019bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019c0:	c9                   	leave  
  8019c1:	c3                   	ret    

008019c2 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019c2:	55                   	push   %ebp
  8019c3:	89 e5                	mov    %esp,%ebp
  8019c5:	57                   	push   %edi
  8019c6:	56                   	push   %esi
  8019c7:	53                   	push   %ebx
  8019c8:	83 ec 1c             	sub    $0x1c,%esp
  8019cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8019ce:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8019d0:	a1 04 44 80 00       	mov    0x804404,%eax
  8019d5:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8019d8:	83 ec 0c             	sub    $0xc,%esp
  8019db:	ff 75 e0             	pushl  -0x20(%ebp)
  8019de:	e8 a5 03 00 00       	call   801d88 <pageref>
  8019e3:	89 c3                	mov    %eax,%ebx
  8019e5:	89 3c 24             	mov    %edi,(%esp)
  8019e8:	e8 9b 03 00 00       	call   801d88 <pageref>
  8019ed:	83 c4 10             	add    $0x10,%esp
  8019f0:	39 c3                	cmp    %eax,%ebx
  8019f2:	0f 94 c1             	sete   %cl
  8019f5:	0f b6 c9             	movzbl %cl,%ecx
  8019f8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8019fb:	8b 15 04 44 80 00    	mov    0x804404,%edx
  801a01:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a04:	39 ce                	cmp    %ecx,%esi
  801a06:	74 1b                	je     801a23 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a08:	39 c3                	cmp    %eax,%ebx
  801a0a:	75 c4                	jne    8019d0 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a0c:	8b 42 58             	mov    0x58(%edx),%eax
  801a0f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a12:	50                   	push   %eax
  801a13:	56                   	push   %esi
  801a14:	68 06 25 80 00       	push   $0x802506
  801a19:	e8 87 e9 ff ff       	call   8003a5 <cprintf>
  801a1e:	83 c4 10             	add    $0x10,%esp
  801a21:	eb ad                	jmp    8019d0 <_pipeisclosed+0xe>
	}
}
  801a23:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a26:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a29:	5b                   	pop    %ebx
  801a2a:	5e                   	pop    %esi
  801a2b:	5f                   	pop    %edi
  801a2c:	5d                   	pop    %ebp
  801a2d:	c3                   	ret    

00801a2e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a2e:	55                   	push   %ebp
  801a2f:	89 e5                	mov    %esp,%ebp
  801a31:	57                   	push   %edi
  801a32:	56                   	push   %esi
  801a33:	53                   	push   %ebx
  801a34:	83 ec 28             	sub    $0x28,%esp
  801a37:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a3a:	56                   	push   %esi
  801a3b:	e8 ff f5 ff ff       	call   80103f <fd2data>
  801a40:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a42:	83 c4 10             	add    $0x10,%esp
  801a45:	bf 00 00 00 00       	mov    $0x0,%edi
  801a4a:	eb 4b                	jmp    801a97 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a4c:	89 da                	mov    %ebx,%edx
  801a4e:	89 f0                	mov    %esi,%eax
  801a50:	e8 6d ff ff ff       	call   8019c2 <_pipeisclosed>
  801a55:	85 c0                	test   %eax,%eax
  801a57:	75 48                	jne    801aa1 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a59:	e8 c1 f3 ff ff       	call   800e1f <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a5e:	8b 43 04             	mov    0x4(%ebx),%eax
  801a61:	8b 0b                	mov    (%ebx),%ecx
  801a63:	8d 51 20             	lea    0x20(%ecx),%edx
  801a66:	39 d0                	cmp    %edx,%eax
  801a68:	73 e2                	jae    801a4c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a6d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a71:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a74:	89 c2                	mov    %eax,%edx
  801a76:	c1 fa 1f             	sar    $0x1f,%edx
  801a79:	89 d1                	mov    %edx,%ecx
  801a7b:	c1 e9 1b             	shr    $0x1b,%ecx
  801a7e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a81:	83 e2 1f             	and    $0x1f,%edx
  801a84:	29 ca                	sub    %ecx,%edx
  801a86:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a8a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a8e:	83 c0 01             	add    $0x1,%eax
  801a91:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a94:	83 c7 01             	add    $0x1,%edi
  801a97:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a9a:	75 c2                	jne    801a5e <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a9c:	8b 45 10             	mov    0x10(%ebp),%eax
  801a9f:	eb 05                	jmp    801aa6 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801aa1:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801aa6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aa9:	5b                   	pop    %ebx
  801aaa:	5e                   	pop    %esi
  801aab:	5f                   	pop    %edi
  801aac:	5d                   	pop    %ebp
  801aad:	c3                   	ret    

00801aae <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801aae:	55                   	push   %ebp
  801aaf:	89 e5                	mov    %esp,%ebp
  801ab1:	57                   	push   %edi
  801ab2:	56                   	push   %esi
  801ab3:	53                   	push   %ebx
  801ab4:	83 ec 18             	sub    $0x18,%esp
  801ab7:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801aba:	57                   	push   %edi
  801abb:	e8 7f f5 ff ff       	call   80103f <fd2data>
  801ac0:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ac2:	83 c4 10             	add    $0x10,%esp
  801ac5:	bb 00 00 00 00       	mov    $0x0,%ebx
  801aca:	eb 3d                	jmp    801b09 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801acc:	85 db                	test   %ebx,%ebx
  801ace:	74 04                	je     801ad4 <devpipe_read+0x26>
				return i;
  801ad0:	89 d8                	mov    %ebx,%eax
  801ad2:	eb 44                	jmp    801b18 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ad4:	89 f2                	mov    %esi,%edx
  801ad6:	89 f8                	mov    %edi,%eax
  801ad8:	e8 e5 fe ff ff       	call   8019c2 <_pipeisclosed>
  801add:	85 c0                	test   %eax,%eax
  801adf:	75 32                	jne    801b13 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801ae1:	e8 39 f3 ff ff       	call   800e1f <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ae6:	8b 06                	mov    (%esi),%eax
  801ae8:	3b 46 04             	cmp    0x4(%esi),%eax
  801aeb:	74 df                	je     801acc <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801aed:	99                   	cltd   
  801aee:	c1 ea 1b             	shr    $0x1b,%edx
  801af1:	01 d0                	add    %edx,%eax
  801af3:	83 e0 1f             	and    $0x1f,%eax
  801af6:	29 d0                	sub    %edx,%eax
  801af8:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801afd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b00:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b03:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b06:	83 c3 01             	add    $0x1,%ebx
  801b09:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b0c:	75 d8                	jne    801ae6 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b0e:	8b 45 10             	mov    0x10(%ebp),%eax
  801b11:	eb 05                	jmp    801b18 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b13:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b18:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b1b:	5b                   	pop    %ebx
  801b1c:	5e                   	pop    %esi
  801b1d:	5f                   	pop    %edi
  801b1e:	5d                   	pop    %ebp
  801b1f:	c3                   	ret    

00801b20 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b20:	55                   	push   %ebp
  801b21:	89 e5                	mov    %esp,%ebp
  801b23:	56                   	push   %esi
  801b24:	53                   	push   %ebx
  801b25:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b28:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b2b:	50                   	push   %eax
  801b2c:	e8 25 f5 ff ff       	call   801056 <fd_alloc>
  801b31:	83 c4 10             	add    $0x10,%esp
  801b34:	89 c2                	mov    %eax,%edx
  801b36:	85 c0                	test   %eax,%eax
  801b38:	0f 88 2c 01 00 00    	js     801c6a <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b3e:	83 ec 04             	sub    $0x4,%esp
  801b41:	68 07 04 00 00       	push   $0x407
  801b46:	ff 75 f4             	pushl  -0xc(%ebp)
  801b49:	6a 00                	push   $0x0
  801b4b:	e8 ee f2 ff ff       	call   800e3e <sys_page_alloc>
  801b50:	83 c4 10             	add    $0x10,%esp
  801b53:	89 c2                	mov    %eax,%edx
  801b55:	85 c0                	test   %eax,%eax
  801b57:	0f 88 0d 01 00 00    	js     801c6a <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b5d:	83 ec 0c             	sub    $0xc,%esp
  801b60:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b63:	50                   	push   %eax
  801b64:	e8 ed f4 ff ff       	call   801056 <fd_alloc>
  801b69:	89 c3                	mov    %eax,%ebx
  801b6b:	83 c4 10             	add    $0x10,%esp
  801b6e:	85 c0                	test   %eax,%eax
  801b70:	0f 88 e2 00 00 00    	js     801c58 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b76:	83 ec 04             	sub    $0x4,%esp
  801b79:	68 07 04 00 00       	push   $0x407
  801b7e:	ff 75 f0             	pushl  -0x10(%ebp)
  801b81:	6a 00                	push   $0x0
  801b83:	e8 b6 f2 ff ff       	call   800e3e <sys_page_alloc>
  801b88:	89 c3                	mov    %eax,%ebx
  801b8a:	83 c4 10             	add    $0x10,%esp
  801b8d:	85 c0                	test   %eax,%eax
  801b8f:	0f 88 c3 00 00 00    	js     801c58 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b95:	83 ec 0c             	sub    $0xc,%esp
  801b98:	ff 75 f4             	pushl  -0xc(%ebp)
  801b9b:	e8 9f f4 ff ff       	call   80103f <fd2data>
  801ba0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ba2:	83 c4 0c             	add    $0xc,%esp
  801ba5:	68 07 04 00 00       	push   $0x407
  801baa:	50                   	push   %eax
  801bab:	6a 00                	push   $0x0
  801bad:	e8 8c f2 ff ff       	call   800e3e <sys_page_alloc>
  801bb2:	89 c3                	mov    %eax,%ebx
  801bb4:	83 c4 10             	add    $0x10,%esp
  801bb7:	85 c0                	test   %eax,%eax
  801bb9:	0f 88 89 00 00 00    	js     801c48 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bbf:	83 ec 0c             	sub    $0xc,%esp
  801bc2:	ff 75 f0             	pushl  -0x10(%ebp)
  801bc5:	e8 75 f4 ff ff       	call   80103f <fd2data>
  801bca:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801bd1:	50                   	push   %eax
  801bd2:	6a 00                	push   $0x0
  801bd4:	56                   	push   %esi
  801bd5:	6a 00                	push   $0x0
  801bd7:	e8 a5 f2 ff ff       	call   800e81 <sys_page_map>
  801bdc:	89 c3                	mov    %eax,%ebx
  801bde:	83 c4 20             	add    $0x20,%esp
  801be1:	85 c0                	test   %eax,%eax
  801be3:	78 55                	js     801c3a <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801be5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801beb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bee:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801bf0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bf3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801bfa:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c00:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c03:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c05:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c08:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c0f:	83 ec 0c             	sub    $0xc,%esp
  801c12:	ff 75 f4             	pushl  -0xc(%ebp)
  801c15:	e8 15 f4 ff ff       	call   80102f <fd2num>
  801c1a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c1d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c1f:	83 c4 04             	add    $0x4,%esp
  801c22:	ff 75 f0             	pushl  -0x10(%ebp)
  801c25:	e8 05 f4 ff ff       	call   80102f <fd2num>
  801c2a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c2d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c30:	83 c4 10             	add    $0x10,%esp
  801c33:	ba 00 00 00 00       	mov    $0x0,%edx
  801c38:	eb 30                	jmp    801c6a <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c3a:	83 ec 08             	sub    $0x8,%esp
  801c3d:	56                   	push   %esi
  801c3e:	6a 00                	push   $0x0
  801c40:	e8 7e f2 ff ff       	call   800ec3 <sys_page_unmap>
  801c45:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c48:	83 ec 08             	sub    $0x8,%esp
  801c4b:	ff 75 f0             	pushl  -0x10(%ebp)
  801c4e:	6a 00                	push   $0x0
  801c50:	e8 6e f2 ff ff       	call   800ec3 <sys_page_unmap>
  801c55:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c58:	83 ec 08             	sub    $0x8,%esp
  801c5b:	ff 75 f4             	pushl  -0xc(%ebp)
  801c5e:	6a 00                	push   $0x0
  801c60:	e8 5e f2 ff ff       	call   800ec3 <sys_page_unmap>
  801c65:	83 c4 10             	add    $0x10,%esp
  801c68:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801c6a:	89 d0                	mov    %edx,%eax
  801c6c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c6f:	5b                   	pop    %ebx
  801c70:	5e                   	pop    %esi
  801c71:	5d                   	pop    %ebp
  801c72:	c3                   	ret    

00801c73 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c73:	55                   	push   %ebp
  801c74:	89 e5                	mov    %esp,%ebp
  801c76:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c79:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c7c:	50                   	push   %eax
  801c7d:	ff 75 08             	pushl  0x8(%ebp)
  801c80:	e8 20 f4 ff ff       	call   8010a5 <fd_lookup>
  801c85:	83 c4 10             	add    $0x10,%esp
  801c88:	85 c0                	test   %eax,%eax
  801c8a:	78 18                	js     801ca4 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c8c:	83 ec 0c             	sub    $0xc,%esp
  801c8f:	ff 75 f4             	pushl  -0xc(%ebp)
  801c92:	e8 a8 f3 ff ff       	call   80103f <fd2data>
	return _pipeisclosed(fd, p);
  801c97:	89 c2                	mov    %eax,%edx
  801c99:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c9c:	e8 21 fd ff ff       	call   8019c2 <_pipeisclosed>
  801ca1:	83 c4 10             	add    $0x10,%esp
}
  801ca4:	c9                   	leave  
  801ca5:	c3                   	ret    

00801ca6 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ca6:	55                   	push   %ebp
  801ca7:	89 e5                	mov    %esp,%ebp
  801ca9:	56                   	push   %esi
  801caa:	53                   	push   %ebx
  801cab:	8b 75 08             	mov    0x8(%ebp),%esi
  801cae:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cb1:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_recv not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  801cb4:	85 c0                	test   %eax,%eax
  801cb6:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801cbb:	0f 44 c2             	cmove  %edx,%eax

    int r = sys_ipc_recv(pg);
  801cbe:	83 ec 0c             	sub    $0xc,%esp
  801cc1:	50                   	push   %eax
  801cc2:	e8 27 f3 ff ff       	call   800fee <sys_ipc_recv>
    int from_env = 0, perm = 0;
    if (r == 0) {
  801cc7:	83 c4 10             	add    $0x10,%esp
  801cca:	85 c0                	test   %eax,%eax
  801ccc:	75 10                	jne    801cde <ipc_recv+0x38>
        from_env = thisenv->env_ipc_from;
  801cce:	a1 04 44 80 00       	mov    0x804404,%eax
  801cd3:	8b 48 74             	mov    0x74(%eax),%ecx
        perm = thisenv->env_ipc_perm;
  801cd6:	8b 50 78             	mov    0x78(%eax),%edx
        r = thisenv->env_ipc_value;
  801cd9:	8b 40 70             	mov    0x70(%eax),%eax
  801cdc:	eb 0a                	jmp    801ce8 <ipc_recv+0x42>
    } else {
        from_env = 0;
        perm = 0;
  801cde:	ba 00 00 00 00       	mov    $0x0,%edx
    if (r == 0) {
        from_env = thisenv->env_ipc_from;
        perm = thisenv->env_ipc_perm;
        r = thisenv->env_ipc_value;
    } else {
        from_env = 0;
  801ce3:	b9 00 00 00 00       	mov    $0x0,%ecx
        perm = 0;
    }

    if (from_env_store) *from_env_store = from_env;
  801ce8:	85 f6                	test   %esi,%esi
  801cea:	74 02                	je     801cee <ipc_recv+0x48>
  801cec:	89 0e                	mov    %ecx,(%esi)
    if (perm_store) *perm_store = perm;
  801cee:	85 db                	test   %ebx,%ebx
  801cf0:	74 02                	je     801cf4 <ipc_recv+0x4e>
  801cf2:	89 13                	mov    %edx,(%ebx)

    return r;
}
  801cf4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cf7:	5b                   	pop    %ebx
  801cf8:	5e                   	pop    %esi
  801cf9:	5d                   	pop    %ebp
  801cfa:	c3                   	ret    

00801cfb <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801cfb:	55                   	push   %ebp
  801cfc:	89 e5                	mov    %esp,%ebp
  801cfe:	57                   	push   %edi
  801cff:	56                   	push   %esi
  801d00:	53                   	push   %ebx
  801d01:	83 ec 0c             	sub    $0xc,%esp
  801d04:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d07:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d0a:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  801d0d:	85 db                	test   %ebx,%ebx
  801d0f:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801d14:	0f 44 d8             	cmove  %eax,%ebx
  801d17:	eb 1c                	jmp    801d35 <ipc_send+0x3a>

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        if (ret != -E_IPC_NOT_RECV)
  801d19:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801d1c:	74 12                	je     801d30 <ipc_send+0x35>
            panic("ipc_send error %e", ret);
  801d1e:	50                   	push   %eax
  801d1f:	68 1e 25 80 00       	push   $0x80251e
  801d24:	6a 40                	push   $0x40
  801d26:	68 30 25 80 00       	push   $0x802530
  801d2b:	e8 9c e5 ff ff       	call   8002cc <_panic>
        sys_yield();
  801d30:	e8 ea f0 ff ff       	call   800e1f <sys_yield>
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801d35:	ff 75 14             	pushl  0x14(%ebp)
  801d38:	53                   	push   %ebx
  801d39:	56                   	push   %esi
  801d3a:	57                   	push   %edi
  801d3b:	e8 8b f2 ff ff       	call   800fcb <sys_ipc_try_send>
  801d40:	83 c4 10             	add    $0x10,%esp
  801d43:	85 c0                	test   %eax,%eax
  801d45:	75 d2                	jne    801d19 <ipc_send+0x1e>
        if (ret != -E_IPC_NOT_RECV)
            panic("ipc_send error %e", ret);
        sys_yield();
    }
}
  801d47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d4a:	5b                   	pop    %ebx
  801d4b:	5e                   	pop    %esi
  801d4c:	5f                   	pop    %edi
  801d4d:	5d                   	pop    %ebp
  801d4e:	c3                   	ret    

00801d4f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801d4f:	55                   	push   %ebp
  801d50:	89 e5                	mov    %esp,%ebp
  801d52:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801d55:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801d5a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801d5d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801d63:	8b 52 50             	mov    0x50(%edx),%edx
  801d66:	39 ca                	cmp    %ecx,%edx
  801d68:	75 0d                	jne    801d77 <ipc_find_env+0x28>
			return envs[i].env_id;
  801d6a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801d6d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801d72:	8b 40 48             	mov    0x48(%eax),%eax
  801d75:	eb 0f                	jmp    801d86 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801d77:	83 c0 01             	add    $0x1,%eax
  801d7a:	3d 00 04 00 00       	cmp    $0x400,%eax
  801d7f:	75 d9                	jne    801d5a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801d81:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d86:	5d                   	pop    %ebp
  801d87:	c3                   	ret    

00801d88 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801d88:	55                   	push   %ebp
  801d89:	89 e5                	mov    %esp,%ebp
  801d8b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d8e:	89 d0                	mov    %edx,%eax
  801d90:	c1 e8 16             	shr    $0x16,%eax
  801d93:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801d9a:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d9f:	f6 c1 01             	test   $0x1,%cl
  801da2:	74 1d                	je     801dc1 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801da4:	c1 ea 0c             	shr    $0xc,%edx
  801da7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801dae:	f6 c2 01             	test   $0x1,%dl
  801db1:	74 0e                	je     801dc1 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801db3:	c1 ea 0c             	shr    $0xc,%edx
  801db6:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801dbd:	ef 
  801dbe:	0f b7 c0             	movzwl %ax,%eax
}
  801dc1:	5d                   	pop    %ebp
  801dc2:	c3                   	ret    
  801dc3:	66 90                	xchg   %ax,%ax
  801dc5:	66 90                	xchg   %ax,%ax
  801dc7:	66 90                	xchg   %ax,%ax
  801dc9:	66 90                	xchg   %ax,%ax
  801dcb:	66 90                	xchg   %ax,%ax
  801dcd:	66 90                	xchg   %ax,%ax
  801dcf:	90                   	nop

00801dd0 <__udivdi3>:
  801dd0:	55                   	push   %ebp
  801dd1:	57                   	push   %edi
  801dd2:	56                   	push   %esi
  801dd3:	53                   	push   %ebx
  801dd4:	83 ec 1c             	sub    $0x1c,%esp
  801dd7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801ddb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801ddf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801de3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801de7:	85 f6                	test   %esi,%esi
  801de9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ded:	89 ca                	mov    %ecx,%edx
  801def:	89 f8                	mov    %edi,%eax
  801df1:	75 3d                	jne    801e30 <__udivdi3+0x60>
  801df3:	39 cf                	cmp    %ecx,%edi
  801df5:	0f 87 c5 00 00 00    	ja     801ec0 <__udivdi3+0xf0>
  801dfb:	85 ff                	test   %edi,%edi
  801dfd:	89 fd                	mov    %edi,%ebp
  801dff:	75 0b                	jne    801e0c <__udivdi3+0x3c>
  801e01:	b8 01 00 00 00       	mov    $0x1,%eax
  801e06:	31 d2                	xor    %edx,%edx
  801e08:	f7 f7                	div    %edi
  801e0a:	89 c5                	mov    %eax,%ebp
  801e0c:	89 c8                	mov    %ecx,%eax
  801e0e:	31 d2                	xor    %edx,%edx
  801e10:	f7 f5                	div    %ebp
  801e12:	89 c1                	mov    %eax,%ecx
  801e14:	89 d8                	mov    %ebx,%eax
  801e16:	89 cf                	mov    %ecx,%edi
  801e18:	f7 f5                	div    %ebp
  801e1a:	89 c3                	mov    %eax,%ebx
  801e1c:	89 d8                	mov    %ebx,%eax
  801e1e:	89 fa                	mov    %edi,%edx
  801e20:	83 c4 1c             	add    $0x1c,%esp
  801e23:	5b                   	pop    %ebx
  801e24:	5e                   	pop    %esi
  801e25:	5f                   	pop    %edi
  801e26:	5d                   	pop    %ebp
  801e27:	c3                   	ret    
  801e28:	90                   	nop
  801e29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e30:	39 ce                	cmp    %ecx,%esi
  801e32:	77 74                	ja     801ea8 <__udivdi3+0xd8>
  801e34:	0f bd fe             	bsr    %esi,%edi
  801e37:	83 f7 1f             	xor    $0x1f,%edi
  801e3a:	0f 84 98 00 00 00    	je     801ed8 <__udivdi3+0x108>
  801e40:	bb 20 00 00 00       	mov    $0x20,%ebx
  801e45:	89 f9                	mov    %edi,%ecx
  801e47:	89 c5                	mov    %eax,%ebp
  801e49:	29 fb                	sub    %edi,%ebx
  801e4b:	d3 e6                	shl    %cl,%esi
  801e4d:	89 d9                	mov    %ebx,%ecx
  801e4f:	d3 ed                	shr    %cl,%ebp
  801e51:	89 f9                	mov    %edi,%ecx
  801e53:	d3 e0                	shl    %cl,%eax
  801e55:	09 ee                	or     %ebp,%esi
  801e57:	89 d9                	mov    %ebx,%ecx
  801e59:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e5d:	89 d5                	mov    %edx,%ebp
  801e5f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801e63:	d3 ed                	shr    %cl,%ebp
  801e65:	89 f9                	mov    %edi,%ecx
  801e67:	d3 e2                	shl    %cl,%edx
  801e69:	89 d9                	mov    %ebx,%ecx
  801e6b:	d3 e8                	shr    %cl,%eax
  801e6d:	09 c2                	or     %eax,%edx
  801e6f:	89 d0                	mov    %edx,%eax
  801e71:	89 ea                	mov    %ebp,%edx
  801e73:	f7 f6                	div    %esi
  801e75:	89 d5                	mov    %edx,%ebp
  801e77:	89 c3                	mov    %eax,%ebx
  801e79:	f7 64 24 0c          	mull   0xc(%esp)
  801e7d:	39 d5                	cmp    %edx,%ebp
  801e7f:	72 10                	jb     801e91 <__udivdi3+0xc1>
  801e81:	8b 74 24 08          	mov    0x8(%esp),%esi
  801e85:	89 f9                	mov    %edi,%ecx
  801e87:	d3 e6                	shl    %cl,%esi
  801e89:	39 c6                	cmp    %eax,%esi
  801e8b:	73 07                	jae    801e94 <__udivdi3+0xc4>
  801e8d:	39 d5                	cmp    %edx,%ebp
  801e8f:	75 03                	jne    801e94 <__udivdi3+0xc4>
  801e91:	83 eb 01             	sub    $0x1,%ebx
  801e94:	31 ff                	xor    %edi,%edi
  801e96:	89 d8                	mov    %ebx,%eax
  801e98:	89 fa                	mov    %edi,%edx
  801e9a:	83 c4 1c             	add    $0x1c,%esp
  801e9d:	5b                   	pop    %ebx
  801e9e:	5e                   	pop    %esi
  801e9f:	5f                   	pop    %edi
  801ea0:	5d                   	pop    %ebp
  801ea1:	c3                   	ret    
  801ea2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ea8:	31 ff                	xor    %edi,%edi
  801eaa:	31 db                	xor    %ebx,%ebx
  801eac:	89 d8                	mov    %ebx,%eax
  801eae:	89 fa                	mov    %edi,%edx
  801eb0:	83 c4 1c             	add    $0x1c,%esp
  801eb3:	5b                   	pop    %ebx
  801eb4:	5e                   	pop    %esi
  801eb5:	5f                   	pop    %edi
  801eb6:	5d                   	pop    %ebp
  801eb7:	c3                   	ret    
  801eb8:	90                   	nop
  801eb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ec0:	89 d8                	mov    %ebx,%eax
  801ec2:	f7 f7                	div    %edi
  801ec4:	31 ff                	xor    %edi,%edi
  801ec6:	89 c3                	mov    %eax,%ebx
  801ec8:	89 d8                	mov    %ebx,%eax
  801eca:	89 fa                	mov    %edi,%edx
  801ecc:	83 c4 1c             	add    $0x1c,%esp
  801ecf:	5b                   	pop    %ebx
  801ed0:	5e                   	pop    %esi
  801ed1:	5f                   	pop    %edi
  801ed2:	5d                   	pop    %ebp
  801ed3:	c3                   	ret    
  801ed4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ed8:	39 ce                	cmp    %ecx,%esi
  801eda:	72 0c                	jb     801ee8 <__udivdi3+0x118>
  801edc:	31 db                	xor    %ebx,%ebx
  801ede:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801ee2:	0f 87 34 ff ff ff    	ja     801e1c <__udivdi3+0x4c>
  801ee8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801eed:	e9 2a ff ff ff       	jmp    801e1c <__udivdi3+0x4c>
  801ef2:	66 90                	xchg   %ax,%ax
  801ef4:	66 90                	xchg   %ax,%ax
  801ef6:	66 90                	xchg   %ax,%ax
  801ef8:	66 90                	xchg   %ax,%ax
  801efa:	66 90                	xchg   %ax,%ax
  801efc:	66 90                	xchg   %ax,%ax
  801efe:	66 90                	xchg   %ax,%ax

00801f00 <__umoddi3>:
  801f00:	55                   	push   %ebp
  801f01:	57                   	push   %edi
  801f02:	56                   	push   %esi
  801f03:	53                   	push   %ebx
  801f04:	83 ec 1c             	sub    $0x1c,%esp
  801f07:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801f0b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801f0f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801f13:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f17:	85 d2                	test   %edx,%edx
  801f19:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801f1d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f21:	89 f3                	mov    %esi,%ebx
  801f23:	89 3c 24             	mov    %edi,(%esp)
  801f26:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f2a:	75 1c                	jne    801f48 <__umoddi3+0x48>
  801f2c:	39 f7                	cmp    %esi,%edi
  801f2e:	76 50                	jbe    801f80 <__umoddi3+0x80>
  801f30:	89 c8                	mov    %ecx,%eax
  801f32:	89 f2                	mov    %esi,%edx
  801f34:	f7 f7                	div    %edi
  801f36:	89 d0                	mov    %edx,%eax
  801f38:	31 d2                	xor    %edx,%edx
  801f3a:	83 c4 1c             	add    $0x1c,%esp
  801f3d:	5b                   	pop    %ebx
  801f3e:	5e                   	pop    %esi
  801f3f:	5f                   	pop    %edi
  801f40:	5d                   	pop    %ebp
  801f41:	c3                   	ret    
  801f42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f48:	39 f2                	cmp    %esi,%edx
  801f4a:	89 d0                	mov    %edx,%eax
  801f4c:	77 52                	ja     801fa0 <__umoddi3+0xa0>
  801f4e:	0f bd ea             	bsr    %edx,%ebp
  801f51:	83 f5 1f             	xor    $0x1f,%ebp
  801f54:	75 5a                	jne    801fb0 <__umoddi3+0xb0>
  801f56:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801f5a:	0f 82 e0 00 00 00    	jb     802040 <__umoddi3+0x140>
  801f60:	39 0c 24             	cmp    %ecx,(%esp)
  801f63:	0f 86 d7 00 00 00    	jbe    802040 <__umoddi3+0x140>
  801f69:	8b 44 24 08          	mov    0x8(%esp),%eax
  801f6d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801f71:	83 c4 1c             	add    $0x1c,%esp
  801f74:	5b                   	pop    %ebx
  801f75:	5e                   	pop    %esi
  801f76:	5f                   	pop    %edi
  801f77:	5d                   	pop    %ebp
  801f78:	c3                   	ret    
  801f79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f80:	85 ff                	test   %edi,%edi
  801f82:	89 fd                	mov    %edi,%ebp
  801f84:	75 0b                	jne    801f91 <__umoddi3+0x91>
  801f86:	b8 01 00 00 00       	mov    $0x1,%eax
  801f8b:	31 d2                	xor    %edx,%edx
  801f8d:	f7 f7                	div    %edi
  801f8f:	89 c5                	mov    %eax,%ebp
  801f91:	89 f0                	mov    %esi,%eax
  801f93:	31 d2                	xor    %edx,%edx
  801f95:	f7 f5                	div    %ebp
  801f97:	89 c8                	mov    %ecx,%eax
  801f99:	f7 f5                	div    %ebp
  801f9b:	89 d0                	mov    %edx,%eax
  801f9d:	eb 99                	jmp    801f38 <__umoddi3+0x38>
  801f9f:	90                   	nop
  801fa0:	89 c8                	mov    %ecx,%eax
  801fa2:	89 f2                	mov    %esi,%edx
  801fa4:	83 c4 1c             	add    $0x1c,%esp
  801fa7:	5b                   	pop    %ebx
  801fa8:	5e                   	pop    %esi
  801fa9:	5f                   	pop    %edi
  801faa:	5d                   	pop    %ebp
  801fab:	c3                   	ret    
  801fac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fb0:	8b 34 24             	mov    (%esp),%esi
  801fb3:	bf 20 00 00 00       	mov    $0x20,%edi
  801fb8:	89 e9                	mov    %ebp,%ecx
  801fba:	29 ef                	sub    %ebp,%edi
  801fbc:	d3 e0                	shl    %cl,%eax
  801fbe:	89 f9                	mov    %edi,%ecx
  801fc0:	89 f2                	mov    %esi,%edx
  801fc2:	d3 ea                	shr    %cl,%edx
  801fc4:	89 e9                	mov    %ebp,%ecx
  801fc6:	09 c2                	or     %eax,%edx
  801fc8:	89 d8                	mov    %ebx,%eax
  801fca:	89 14 24             	mov    %edx,(%esp)
  801fcd:	89 f2                	mov    %esi,%edx
  801fcf:	d3 e2                	shl    %cl,%edx
  801fd1:	89 f9                	mov    %edi,%ecx
  801fd3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801fd7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801fdb:	d3 e8                	shr    %cl,%eax
  801fdd:	89 e9                	mov    %ebp,%ecx
  801fdf:	89 c6                	mov    %eax,%esi
  801fe1:	d3 e3                	shl    %cl,%ebx
  801fe3:	89 f9                	mov    %edi,%ecx
  801fe5:	89 d0                	mov    %edx,%eax
  801fe7:	d3 e8                	shr    %cl,%eax
  801fe9:	89 e9                	mov    %ebp,%ecx
  801feb:	09 d8                	or     %ebx,%eax
  801fed:	89 d3                	mov    %edx,%ebx
  801fef:	89 f2                	mov    %esi,%edx
  801ff1:	f7 34 24             	divl   (%esp)
  801ff4:	89 d6                	mov    %edx,%esi
  801ff6:	d3 e3                	shl    %cl,%ebx
  801ff8:	f7 64 24 04          	mull   0x4(%esp)
  801ffc:	39 d6                	cmp    %edx,%esi
  801ffe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802002:	89 d1                	mov    %edx,%ecx
  802004:	89 c3                	mov    %eax,%ebx
  802006:	72 08                	jb     802010 <__umoddi3+0x110>
  802008:	75 11                	jne    80201b <__umoddi3+0x11b>
  80200a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80200e:	73 0b                	jae    80201b <__umoddi3+0x11b>
  802010:	2b 44 24 04          	sub    0x4(%esp),%eax
  802014:	1b 14 24             	sbb    (%esp),%edx
  802017:	89 d1                	mov    %edx,%ecx
  802019:	89 c3                	mov    %eax,%ebx
  80201b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80201f:	29 da                	sub    %ebx,%edx
  802021:	19 ce                	sbb    %ecx,%esi
  802023:	89 f9                	mov    %edi,%ecx
  802025:	89 f0                	mov    %esi,%eax
  802027:	d3 e0                	shl    %cl,%eax
  802029:	89 e9                	mov    %ebp,%ecx
  80202b:	d3 ea                	shr    %cl,%edx
  80202d:	89 e9                	mov    %ebp,%ecx
  80202f:	d3 ee                	shr    %cl,%esi
  802031:	09 d0                	or     %edx,%eax
  802033:	89 f2                	mov    %esi,%edx
  802035:	83 c4 1c             	add    $0x1c,%esp
  802038:	5b                   	pop    %ebx
  802039:	5e                   	pop    %esi
  80203a:	5f                   	pop    %edi
  80203b:	5d                   	pop    %ebp
  80203c:	c3                   	ret    
  80203d:	8d 76 00             	lea    0x0(%esi),%esi
  802040:	29 f9                	sub    %edi,%ecx
  802042:	19 d6                	sbb    %edx,%esi
  802044:	89 74 24 04          	mov    %esi,0x4(%esp)
  802048:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80204c:	e9 18 ff ff ff       	jmp    801f69 <__umoddi3+0x69>
