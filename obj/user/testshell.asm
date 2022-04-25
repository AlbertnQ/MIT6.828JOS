
obj/user/testshell.debug:     file format elf32-i386


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
  80002c:	e8 53 04 00 00       	call   800484 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <wrong>:
	breakpoint();
}

void
wrong(int rfd, int kfd, int off)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	81 ec 84 00 00 00    	sub    $0x84,%esp
  80003f:	8b 75 08             	mov    0x8(%ebp),%esi
  800042:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800045:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char buf[100];
	int n;

	seek(rfd, off);
  800048:	53                   	push   %ebx
  800049:	56                   	push   %esi
  80004a:	e8 57 18 00 00       	call   8018a6 <seek>
	seek(kfd, off);
  80004f:	83 c4 08             	add    $0x8,%esp
  800052:	53                   	push   %ebx
  800053:	57                   	push   %edi
  800054:	e8 4d 18 00 00       	call   8018a6 <seek>

	cprintf("shell produced incorrect output.\n");
  800059:	c7 04 24 20 2a 80 00 	movl   $0x802a20,(%esp)
  800060:	e8 58 05 00 00       	call   8005bd <cprintf>
	cprintf("expected:\n===\n");
  800065:	c7 04 24 8b 2a 80 00 	movl   $0x802a8b,(%esp)
  80006c:	e8 4c 05 00 00       	call   8005bd <cprintf>
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800071:	83 c4 10             	add    $0x10,%esp
  800074:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  800077:	eb 0d                	jmp    800086 <wrong+0x53>
		sys_cputs(buf, n);
  800079:	83 ec 08             	sub    $0x8,%esp
  80007c:	50                   	push   %eax
  80007d:	53                   	push   %ebx
  80007e:	e8 24 0e 00 00       	call   800ea7 <sys_cputs>
  800083:	83 c4 10             	add    $0x10,%esp
	seek(rfd, off);
	seek(kfd, off);

	cprintf("shell produced incorrect output.\n");
	cprintf("expected:\n===\n");
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800086:	83 ec 04             	sub    $0x4,%esp
  800089:	6a 63                	push   $0x63
  80008b:	53                   	push   %ebx
  80008c:	57                   	push   %edi
  80008d:	e8 ae 16 00 00       	call   801740 <read>
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	85 c0                	test   %eax,%eax
  800097:	7f e0                	jg     800079 <wrong+0x46>
		sys_cputs(buf, n);
	cprintf("===\ngot:\n===\n");
  800099:	83 ec 0c             	sub    $0xc,%esp
  80009c:	68 9a 2a 80 00       	push   $0x802a9a
  8000a1:	e8 17 05 00 00       	call   8005bd <cprintf>
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  8000ac:	eb 0d                	jmp    8000bb <wrong+0x88>
		sys_cputs(buf, n);
  8000ae:	83 ec 08             	sub    $0x8,%esp
  8000b1:	50                   	push   %eax
  8000b2:	53                   	push   %ebx
  8000b3:	e8 ef 0d 00 00       	call   800ea7 <sys_cputs>
  8000b8:	83 c4 10             	add    $0x10,%esp
	cprintf("shell produced incorrect output.\n");
	cprintf("expected:\n===\n");
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
		sys_cputs(buf, n);
	cprintf("===\ngot:\n===\n");
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000bb:	83 ec 04             	sub    $0x4,%esp
  8000be:	6a 63                	push   $0x63
  8000c0:	53                   	push   %ebx
  8000c1:	56                   	push   %esi
  8000c2:	e8 79 16 00 00       	call   801740 <read>
  8000c7:	83 c4 10             	add    $0x10,%esp
  8000ca:	85 c0                	test   %eax,%eax
  8000cc:	7f e0                	jg     8000ae <wrong+0x7b>
		sys_cputs(buf, n);
	cprintf("===\n");
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	68 95 2a 80 00       	push   $0x802a95
  8000d6:	e8 e2 04 00 00       	call   8005bd <cprintf>
	exit();
  8000db:	e8 ea 03 00 00       	call   8004ca <exit>
}
  8000e0:	83 c4 10             	add    $0x10,%esp
  8000e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000e6:	5b                   	pop    %ebx
  8000e7:	5e                   	pop    %esi
  8000e8:	5f                   	pop    %edi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <umain>:

void wrong(int, int, int);

void
umain(int argc, char **argv)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	57                   	push   %edi
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	83 ec 38             	sub    $0x38,%esp
	char c1, c2;
	int r, rfd, wfd, kfd, n1, n2, off, nloff;
	int pfds[2];

	close(0);
  8000f4:	6a 00                	push   $0x0
  8000f6:	e8 09 15 00 00       	call   801604 <close>
	close(1);
  8000fb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800102:	e8 fd 14 00 00       	call   801604 <close>
	opencons();
  800107:	e8 1e 03 00 00       	call   80042a <opencons>
	opencons();
  80010c:	e8 19 03 00 00       	call   80042a <opencons>

	if ((rfd = open("testshell.sh", O_RDONLY)) < 0)
  800111:	83 c4 08             	add    $0x8,%esp
  800114:	6a 00                	push   $0x0
  800116:	68 a8 2a 80 00       	push   $0x802aa8
  80011b:	e8 ab 1a 00 00       	call   801bcb <open>
  800120:	89 c3                	mov    %eax,%ebx
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	85 c0                	test   %eax,%eax
  800127:	79 12                	jns    80013b <umain+0x50>
		panic("open testshell.sh: %e", rfd);
  800129:	50                   	push   %eax
  80012a:	68 b5 2a 80 00       	push   $0x802ab5
  80012f:	6a 13                	push   $0x13
  800131:	68 cb 2a 80 00       	push   $0x802acb
  800136:	e8 a9 03 00 00       	call   8004e4 <_panic>
	if ((wfd = pipe(pfds)) < 0)
  80013b:	83 ec 0c             	sub    $0xc,%esp
  80013e:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800141:	50                   	push   %eax
  800142:	e8 b2 22 00 00       	call   8023f9 <pipe>
  800147:	83 c4 10             	add    $0x10,%esp
  80014a:	85 c0                	test   %eax,%eax
  80014c:	79 12                	jns    800160 <umain+0x75>
		panic("pipe: %e", wfd);
  80014e:	50                   	push   %eax
  80014f:	68 dc 2a 80 00       	push   $0x802adc
  800154:	6a 15                	push   $0x15
  800156:	68 cb 2a 80 00       	push   $0x802acb
  80015b:	e8 84 03 00 00       	call   8004e4 <_panic>
	wfd = pfds[1];
  800160:	8b 75 e0             	mov    -0x20(%ebp),%esi

	cprintf("running sh -x < testshell.sh | cat\n");
  800163:	83 ec 0c             	sub    $0xc,%esp
  800166:	68 44 2a 80 00       	push   $0x802a44
  80016b:	e8 4d 04 00 00       	call   8005bd <cprintf>
	if ((r = fork()) < 0)
  800170:	e8 b3 11 00 00       	call   801328 <fork>
  800175:	83 c4 10             	add    $0x10,%esp
  800178:	85 c0                	test   %eax,%eax
  80017a:	79 12                	jns    80018e <umain+0xa3>
		panic("fork: %e", r);
  80017c:	50                   	push   %eax
  80017d:	68 e5 2a 80 00       	push   $0x802ae5
  800182:	6a 1a                	push   $0x1a
  800184:	68 cb 2a 80 00       	push   $0x802acb
  800189:	e8 56 03 00 00       	call   8004e4 <_panic>
	if (r == 0) {
  80018e:	85 c0                	test   %eax,%eax
  800190:	75 7d                	jne    80020f <umain+0x124>
		dup(rfd, 0);
  800192:	83 ec 08             	sub    $0x8,%esp
  800195:	6a 00                	push   $0x0
  800197:	53                   	push   %ebx
  800198:	e8 b7 14 00 00       	call   801654 <dup>
		dup(wfd, 1);
  80019d:	83 c4 08             	add    $0x8,%esp
  8001a0:	6a 01                	push   $0x1
  8001a2:	56                   	push   %esi
  8001a3:	e8 ac 14 00 00       	call   801654 <dup>
		close(rfd);
  8001a8:	89 1c 24             	mov    %ebx,(%esp)
  8001ab:	e8 54 14 00 00       	call   801604 <close>
		close(wfd);
  8001b0:	89 34 24             	mov    %esi,(%esp)
  8001b3:	e8 4c 14 00 00       	call   801604 <close>
		if ((r = spawnl("/sh", "sh", "-x", 0)) < 0)
  8001b8:	6a 00                	push   $0x0
  8001ba:	68 ee 2a 80 00       	push   $0x802aee
  8001bf:	68 b2 2a 80 00       	push   $0x802ab2
  8001c4:	68 f1 2a 80 00       	push   $0x802af1
  8001c9:	e8 e2 1f 00 00       	call   8021b0 <spawnl>
  8001ce:	89 c7                	mov    %eax,%edi
  8001d0:	83 c4 20             	add    $0x20,%esp
  8001d3:	85 c0                	test   %eax,%eax
  8001d5:	79 12                	jns    8001e9 <umain+0xfe>
			panic("spawn: %e", r);
  8001d7:	50                   	push   %eax
  8001d8:	68 f5 2a 80 00       	push   $0x802af5
  8001dd:	6a 21                	push   $0x21
  8001df:	68 cb 2a 80 00       	push   $0x802acb
  8001e4:	e8 fb 02 00 00       	call   8004e4 <_panic>
		close(0);
  8001e9:	83 ec 0c             	sub    $0xc,%esp
  8001ec:	6a 00                	push   $0x0
  8001ee:	e8 11 14 00 00       	call   801604 <close>
		close(1);
  8001f3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8001fa:	e8 05 14 00 00       	call   801604 <close>
		wait(r);
  8001ff:	89 3c 24             	mov    %edi,(%esp)
  800202:	e8 78 23 00 00       	call   80257f <wait>
		exit();
  800207:	e8 be 02 00 00       	call   8004ca <exit>
  80020c:	83 c4 10             	add    $0x10,%esp
	}
	close(rfd);
  80020f:	83 ec 0c             	sub    $0xc,%esp
  800212:	53                   	push   %ebx
  800213:	e8 ec 13 00 00       	call   801604 <close>
	close(wfd);
  800218:	89 34 24             	mov    %esi,(%esp)
  80021b:	e8 e4 13 00 00       	call   801604 <close>

	rfd = pfds[0];
  800220:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800223:	89 45 d0             	mov    %eax,-0x30(%ebp)
	if ((kfd = open("testshell.key", O_RDONLY)) < 0)
  800226:	83 c4 08             	add    $0x8,%esp
  800229:	6a 00                	push   $0x0
  80022b:	68 ff 2a 80 00       	push   $0x802aff
  800230:	e8 96 19 00 00       	call   801bcb <open>
  800235:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800238:	83 c4 10             	add    $0x10,%esp
  80023b:	85 c0                	test   %eax,%eax
  80023d:	79 12                	jns    800251 <umain+0x166>
		panic("open testshell.key for reading: %e", kfd);
  80023f:	50                   	push   %eax
  800240:	68 68 2a 80 00       	push   $0x802a68
  800245:	6a 2c                	push   $0x2c
  800247:	68 cb 2a 80 00       	push   $0x802acb
  80024c:	e8 93 02 00 00       	call   8004e4 <_panic>
  800251:	be 01 00 00 00       	mov    $0x1,%esi
  800256:	bf 00 00 00 00       	mov    $0x0,%edi

	nloff = 0;
	for (off=0;; off++) {
		n1 = read(rfd, &c1, 1);
  80025b:	83 ec 04             	sub    $0x4,%esp
  80025e:	6a 01                	push   $0x1
  800260:	8d 45 e7             	lea    -0x19(%ebp),%eax
  800263:	50                   	push   %eax
  800264:	ff 75 d0             	pushl  -0x30(%ebp)
  800267:	e8 d4 14 00 00       	call   801740 <read>
  80026c:	89 c3                	mov    %eax,%ebx
		n2 = read(kfd, &c2, 1);
  80026e:	83 c4 0c             	add    $0xc,%esp
  800271:	6a 01                	push   $0x1
  800273:	8d 45 e6             	lea    -0x1a(%ebp),%eax
  800276:	50                   	push   %eax
  800277:	ff 75 d4             	pushl  -0x2c(%ebp)
  80027a:	e8 c1 14 00 00       	call   801740 <read>
		if (n1 < 0)
  80027f:	83 c4 10             	add    $0x10,%esp
  800282:	85 db                	test   %ebx,%ebx
  800284:	79 12                	jns    800298 <umain+0x1ad>
			panic("reading testshell.out: %e", n1);
  800286:	53                   	push   %ebx
  800287:	68 0d 2b 80 00       	push   $0x802b0d
  80028c:	6a 33                	push   $0x33
  80028e:	68 cb 2a 80 00       	push   $0x802acb
  800293:	e8 4c 02 00 00       	call   8004e4 <_panic>
		if (n2 < 0)
  800298:	85 c0                	test   %eax,%eax
  80029a:	79 12                	jns    8002ae <umain+0x1c3>
			panic("reading testshell.key: %e", n2);
  80029c:	50                   	push   %eax
  80029d:	68 27 2b 80 00       	push   $0x802b27
  8002a2:	6a 35                	push   $0x35
  8002a4:	68 cb 2a 80 00       	push   $0x802acb
  8002a9:	e8 36 02 00 00       	call   8004e4 <_panic>
		if (n1 == 0 && n2 == 0)
  8002ae:	89 da                	mov    %ebx,%edx
  8002b0:	09 c2                	or     %eax,%edx
  8002b2:	74 34                	je     8002e8 <umain+0x1fd>
			break;
		if (n1 != 1 || n2 != 1 || c1 != c2)
  8002b4:	83 fb 01             	cmp    $0x1,%ebx
  8002b7:	75 0e                	jne    8002c7 <umain+0x1dc>
  8002b9:	83 f8 01             	cmp    $0x1,%eax
  8002bc:	75 09                	jne    8002c7 <umain+0x1dc>
  8002be:	0f b6 45 e6          	movzbl -0x1a(%ebp),%eax
  8002c2:	38 45 e7             	cmp    %al,-0x19(%ebp)
  8002c5:	74 12                	je     8002d9 <umain+0x1ee>
			wrong(rfd, kfd, nloff);
  8002c7:	83 ec 04             	sub    $0x4,%esp
  8002ca:	57                   	push   %edi
  8002cb:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002ce:	ff 75 d0             	pushl  -0x30(%ebp)
  8002d1:	e8 5d fd ff ff       	call   800033 <wrong>
  8002d6:	83 c4 10             	add    $0x10,%esp
		if (c1 == '\n')
			nloff = off+1;
  8002d9:	80 7d e7 0a          	cmpb   $0xa,-0x19(%ebp)
  8002dd:	0f 44 fe             	cmove  %esi,%edi
  8002e0:	83 c6 01             	add    $0x1,%esi
	}
  8002e3:	e9 73 ff ff ff       	jmp    80025b <umain+0x170>
	cprintf("shell ran correctly\n");
  8002e8:	83 ec 0c             	sub    $0xc,%esp
  8002eb:	68 41 2b 80 00       	push   $0x802b41
  8002f0:	e8 c8 02 00 00       	call   8005bd <cprintf>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  8002f5:	cc                   	int3   

	breakpoint();
}
  8002f6:	83 c4 10             	add    $0x10,%esp
  8002f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002fc:	5b                   	pop    %ebx
  8002fd:	5e                   	pop    %esi
  8002fe:	5f                   	pop    %edi
  8002ff:	5d                   	pop    %ebp
  800300:	c3                   	ret    

00800301 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800301:	55                   	push   %ebp
  800302:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800304:	b8 00 00 00 00       	mov    $0x0,%eax
  800309:	5d                   	pop    %ebp
  80030a:	c3                   	ret    

0080030b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80030b:	55                   	push   %ebp
  80030c:	89 e5                	mov    %esp,%ebp
  80030e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800311:	68 56 2b 80 00       	push   $0x802b56
  800316:	ff 75 0c             	pushl  0xc(%ebp)
  800319:	e8 42 08 00 00       	call   800b60 <strcpy>
	return 0;
}
  80031e:	b8 00 00 00 00       	mov    $0x0,%eax
  800323:	c9                   	leave  
  800324:	c3                   	ret    

00800325 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800325:	55                   	push   %ebp
  800326:	89 e5                	mov    %esp,%ebp
  800328:	57                   	push   %edi
  800329:	56                   	push   %esi
  80032a:	53                   	push   %ebx
  80032b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800331:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800336:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80033c:	eb 2d                	jmp    80036b <devcons_write+0x46>
		m = n - tot;
  80033e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800341:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800343:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800346:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80034b:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80034e:	83 ec 04             	sub    $0x4,%esp
  800351:	53                   	push   %ebx
  800352:	03 45 0c             	add    0xc(%ebp),%eax
  800355:	50                   	push   %eax
  800356:	57                   	push   %edi
  800357:	e8 96 09 00 00       	call   800cf2 <memmove>
		sys_cputs(buf, m);
  80035c:	83 c4 08             	add    $0x8,%esp
  80035f:	53                   	push   %ebx
  800360:	57                   	push   %edi
  800361:	e8 41 0b 00 00       	call   800ea7 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800366:	01 de                	add    %ebx,%esi
  800368:	83 c4 10             	add    $0x10,%esp
  80036b:	89 f0                	mov    %esi,%eax
  80036d:	3b 75 10             	cmp    0x10(%ebp),%esi
  800370:	72 cc                	jb     80033e <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800372:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800375:	5b                   	pop    %ebx
  800376:	5e                   	pop    %esi
  800377:	5f                   	pop    %edi
  800378:	5d                   	pop    %ebp
  800379:	c3                   	ret    

0080037a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80037a:	55                   	push   %ebp
  80037b:	89 e5                	mov    %esp,%ebp
  80037d:	83 ec 08             	sub    $0x8,%esp
  800380:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800385:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800389:	74 2a                	je     8003b5 <devcons_read+0x3b>
  80038b:	eb 05                	jmp    800392 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80038d:	e8 b2 0b 00 00       	call   800f44 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800392:	e8 2e 0b 00 00       	call   800ec5 <sys_cgetc>
  800397:	85 c0                	test   %eax,%eax
  800399:	74 f2                	je     80038d <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80039b:	85 c0                	test   %eax,%eax
  80039d:	78 16                	js     8003b5 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80039f:	83 f8 04             	cmp    $0x4,%eax
  8003a2:	74 0c                	je     8003b0 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8003a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003a7:	88 02                	mov    %al,(%edx)
	return 1;
  8003a9:	b8 01 00 00 00       	mov    $0x1,%eax
  8003ae:	eb 05                	jmp    8003b5 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8003b0:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8003b5:	c9                   	leave  
  8003b6:	c3                   	ret    

008003b7 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8003b7:	55                   	push   %ebp
  8003b8:	89 e5                	mov    %esp,%ebp
  8003ba:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8003bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c0:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8003c3:	6a 01                	push   $0x1
  8003c5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8003c8:	50                   	push   %eax
  8003c9:	e8 d9 0a 00 00       	call   800ea7 <sys_cputs>
}
  8003ce:	83 c4 10             	add    $0x10,%esp
  8003d1:	c9                   	leave  
  8003d2:	c3                   	ret    

008003d3 <getchar>:

int
getchar(void)
{
  8003d3:	55                   	push   %ebp
  8003d4:	89 e5                	mov    %esp,%ebp
  8003d6:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8003d9:	6a 01                	push   $0x1
  8003db:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8003de:	50                   	push   %eax
  8003df:	6a 00                	push   $0x0
  8003e1:	e8 5a 13 00 00       	call   801740 <read>
	if (r < 0)
  8003e6:	83 c4 10             	add    $0x10,%esp
  8003e9:	85 c0                	test   %eax,%eax
  8003eb:	78 0f                	js     8003fc <getchar+0x29>
		return r;
	if (r < 1)
  8003ed:	85 c0                	test   %eax,%eax
  8003ef:	7e 06                	jle    8003f7 <getchar+0x24>
		return -E_EOF;
	return c;
  8003f1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8003f5:	eb 05                	jmp    8003fc <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8003f7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8003fc:	c9                   	leave  
  8003fd:	c3                   	ret    

008003fe <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8003fe:	55                   	push   %ebp
  8003ff:	89 e5                	mov    %esp,%ebp
  800401:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800404:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800407:	50                   	push   %eax
  800408:	ff 75 08             	pushl  0x8(%ebp)
  80040b:	e8 ca 10 00 00       	call   8014da <fd_lookup>
  800410:	83 c4 10             	add    $0x10,%esp
  800413:	85 c0                	test   %eax,%eax
  800415:	78 11                	js     800428 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800417:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80041a:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800420:	39 10                	cmp    %edx,(%eax)
  800422:	0f 94 c0             	sete   %al
  800425:	0f b6 c0             	movzbl %al,%eax
}
  800428:	c9                   	leave  
  800429:	c3                   	ret    

0080042a <opencons>:

int
opencons(void)
{
  80042a:	55                   	push   %ebp
  80042b:	89 e5                	mov    %esp,%ebp
  80042d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800430:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800433:	50                   	push   %eax
  800434:	e8 52 10 00 00       	call   80148b <fd_alloc>
  800439:	83 c4 10             	add    $0x10,%esp
		return r;
  80043c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80043e:	85 c0                	test   %eax,%eax
  800440:	78 3e                	js     800480 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800442:	83 ec 04             	sub    $0x4,%esp
  800445:	68 07 04 00 00       	push   $0x407
  80044a:	ff 75 f4             	pushl  -0xc(%ebp)
  80044d:	6a 00                	push   $0x0
  80044f:	e8 0f 0b 00 00       	call   800f63 <sys_page_alloc>
  800454:	83 c4 10             	add    $0x10,%esp
		return r;
  800457:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800459:	85 c0                	test   %eax,%eax
  80045b:	78 23                	js     800480 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80045d:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800463:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800466:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800468:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80046b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800472:	83 ec 0c             	sub    $0xc,%esp
  800475:	50                   	push   %eax
  800476:	e8 e9 0f 00 00       	call   801464 <fd2num>
  80047b:	89 c2                	mov    %eax,%edx
  80047d:	83 c4 10             	add    $0x10,%esp
}
  800480:	89 d0                	mov    %edx,%eax
  800482:	c9                   	leave  
  800483:	c3                   	ret    

00800484 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800484:	55                   	push   %ebp
  800485:	89 e5                	mov    %esp,%ebp
  800487:	56                   	push   %esi
  800488:	53                   	push   %ebx
  800489:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80048c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  80048f:	e8 91 0a 00 00       	call   800f25 <sys_getenvid>
  800494:	25 ff 03 00 00       	and    $0x3ff,%eax
  800499:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80049c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8004a1:	a3 04 50 80 00       	mov    %eax,0x805004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8004a6:	85 db                	test   %ebx,%ebx
  8004a8:	7e 07                	jle    8004b1 <libmain+0x2d>
		binaryname = argv[0];
  8004aa:	8b 06                	mov    (%esi),%eax
  8004ac:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  8004b1:	83 ec 08             	sub    $0x8,%esp
  8004b4:	56                   	push   %esi
  8004b5:	53                   	push   %ebx
  8004b6:	e8 30 fc ff ff       	call   8000eb <umain>

	// exit gracefully
	exit();
  8004bb:	e8 0a 00 00 00       	call   8004ca <exit>
}
  8004c0:	83 c4 10             	add    $0x10,%esp
  8004c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004c6:	5b                   	pop    %ebx
  8004c7:	5e                   	pop    %esi
  8004c8:	5d                   	pop    %ebp
  8004c9:	c3                   	ret    

008004ca <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8004ca:	55                   	push   %ebp
  8004cb:	89 e5                	mov    %esp,%ebp
  8004cd:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8004d0:	e8 5a 11 00 00       	call   80162f <close_all>
	sys_env_destroy(0);
  8004d5:	83 ec 0c             	sub    $0xc,%esp
  8004d8:	6a 00                	push   $0x0
  8004da:	e8 05 0a 00 00       	call   800ee4 <sys_env_destroy>
}
  8004df:	83 c4 10             	add    $0x10,%esp
  8004e2:	c9                   	leave  
  8004e3:	c3                   	ret    

008004e4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8004e4:	55                   	push   %ebp
  8004e5:	89 e5                	mov    %esp,%ebp
  8004e7:	56                   	push   %esi
  8004e8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8004e9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8004ec:	8b 35 1c 40 80 00    	mov    0x80401c,%esi
  8004f2:	e8 2e 0a 00 00       	call   800f25 <sys_getenvid>
  8004f7:	83 ec 0c             	sub    $0xc,%esp
  8004fa:	ff 75 0c             	pushl  0xc(%ebp)
  8004fd:	ff 75 08             	pushl  0x8(%ebp)
  800500:	56                   	push   %esi
  800501:	50                   	push   %eax
  800502:	68 6c 2b 80 00       	push   $0x802b6c
  800507:	e8 b1 00 00 00       	call   8005bd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80050c:	83 c4 18             	add    $0x18,%esp
  80050f:	53                   	push   %ebx
  800510:	ff 75 10             	pushl  0x10(%ebp)
  800513:	e8 54 00 00 00       	call   80056c <vcprintf>
	cprintf("\n");
  800518:	c7 04 24 98 2a 80 00 	movl   $0x802a98,(%esp)
  80051f:	e8 99 00 00 00       	call   8005bd <cprintf>
  800524:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800527:	cc                   	int3   
  800528:	eb fd                	jmp    800527 <_panic+0x43>

0080052a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80052a:	55                   	push   %ebp
  80052b:	89 e5                	mov    %esp,%ebp
  80052d:	53                   	push   %ebx
  80052e:	83 ec 04             	sub    $0x4,%esp
  800531:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800534:	8b 13                	mov    (%ebx),%edx
  800536:	8d 42 01             	lea    0x1(%edx),%eax
  800539:	89 03                	mov    %eax,(%ebx)
  80053b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80053e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800542:	3d ff 00 00 00       	cmp    $0xff,%eax
  800547:	75 1a                	jne    800563 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800549:	83 ec 08             	sub    $0x8,%esp
  80054c:	68 ff 00 00 00       	push   $0xff
  800551:	8d 43 08             	lea    0x8(%ebx),%eax
  800554:	50                   	push   %eax
  800555:	e8 4d 09 00 00       	call   800ea7 <sys_cputs>
		b->idx = 0;
  80055a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800560:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800563:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800567:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80056a:	c9                   	leave  
  80056b:	c3                   	ret    

0080056c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80056c:	55                   	push   %ebp
  80056d:	89 e5                	mov    %esp,%ebp
  80056f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800575:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80057c:	00 00 00 
	b.cnt = 0;
  80057f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800586:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800589:	ff 75 0c             	pushl  0xc(%ebp)
  80058c:	ff 75 08             	pushl  0x8(%ebp)
  80058f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800595:	50                   	push   %eax
  800596:	68 2a 05 80 00       	push   $0x80052a
  80059b:	e8 54 01 00 00       	call   8006f4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8005a0:	83 c4 08             	add    $0x8,%esp
  8005a3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8005a9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8005af:	50                   	push   %eax
  8005b0:	e8 f2 08 00 00       	call   800ea7 <sys_cputs>

	return b.cnt;
}
  8005b5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8005bb:	c9                   	leave  
  8005bc:	c3                   	ret    

008005bd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8005bd:	55                   	push   %ebp
  8005be:	89 e5                	mov    %esp,%ebp
  8005c0:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8005c3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8005c6:	50                   	push   %eax
  8005c7:	ff 75 08             	pushl  0x8(%ebp)
  8005ca:	e8 9d ff ff ff       	call   80056c <vcprintf>
	va_end(ap);

	return cnt;
}
  8005cf:	c9                   	leave  
  8005d0:	c3                   	ret    

008005d1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005d1:	55                   	push   %ebp
  8005d2:	89 e5                	mov    %esp,%ebp
  8005d4:	57                   	push   %edi
  8005d5:	56                   	push   %esi
  8005d6:	53                   	push   %ebx
  8005d7:	83 ec 1c             	sub    $0x1c,%esp
  8005da:	89 c7                	mov    %eax,%edi
  8005dc:	89 d6                	mov    %edx,%esi
  8005de:	8b 45 08             	mov    0x8(%ebp),%eax
  8005e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005e4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e7:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8005ed:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005f2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8005f5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8005f8:	39 d3                	cmp    %edx,%ebx
  8005fa:	72 05                	jb     800601 <printnum+0x30>
  8005fc:	39 45 10             	cmp    %eax,0x10(%ebp)
  8005ff:	77 45                	ja     800646 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800601:	83 ec 0c             	sub    $0xc,%esp
  800604:	ff 75 18             	pushl  0x18(%ebp)
  800607:	8b 45 14             	mov    0x14(%ebp),%eax
  80060a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80060d:	53                   	push   %ebx
  80060e:	ff 75 10             	pushl  0x10(%ebp)
  800611:	83 ec 08             	sub    $0x8,%esp
  800614:	ff 75 e4             	pushl  -0x1c(%ebp)
  800617:	ff 75 e0             	pushl  -0x20(%ebp)
  80061a:	ff 75 dc             	pushl  -0x24(%ebp)
  80061d:	ff 75 d8             	pushl  -0x28(%ebp)
  800620:	e8 5b 21 00 00       	call   802780 <__udivdi3>
  800625:	83 c4 18             	add    $0x18,%esp
  800628:	52                   	push   %edx
  800629:	50                   	push   %eax
  80062a:	89 f2                	mov    %esi,%edx
  80062c:	89 f8                	mov    %edi,%eax
  80062e:	e8 9e ff ff ff       	call   8005d1 <printnum>
  800633:	83 c4 20             	add    $0x20,%esp
  800636:	eb 18                	jmp    800650 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800638:	83 ec 08             	sub    $0x8,%esp
  80063b:	56                   	push   %esi
  80063c:	ff 75 18             	pushl  0x18(%ebp)
  80063f:	ff d7                	call   *%edi
  800641:	83 c4 10             	add    $0x10,%esp
  800644:	eb 03                	jmp    800649 <printnum+0x78>
  800646:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800649:	83 eb 01             	sub    $0x1,%ebx
  80064c:	85 db                	test   %ebx,%ebx
  80064e:	7f e8                	jg     800638 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800650:	83 ec 08             	sub    $0x8,%esp
  800653:	56                   	push   %esi
  800654:	83 ec 04             	sub    $0x4,%esp
  800657:	ff 75 e4             	pushl  -0x1c(%ebp)
  80065a:	ff 75 e0             	pushl  -0x20(%ebp)
  80065d:	ff 75 dc             	pushl  -0x24(%ebp)
  800660:	ff 75 d8             	pushl  -0x28(%ebp)
  800663:	e8 48 22 00 00       	call   8028b0 <__umoddi3>
  800668:	83 c4 14             	add    $0x14,%esp
  80066b:	0f be 80 8f 2b 80 00 	movsbl 0x802b8f(%eax),%eax
  800672:	50                   	push   %eax
  800673:	ff d7                	call   *%edi
}
  800675:	83 c4 10             	add    $0x10,%esp
  800678:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80067b:	5b                   	pop    %ebx
  80067c:	5e                   	pop    %esi
  80067d:	5f                   	pop    %edi
  80067e:	5d                   	pop    %ebp
  80067f:	c3                   	ret    

00800680 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800680:	55                   	push   %ebp
  800681:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800683:	83 fa 01             	cmp    $0x1,%edx
  800686:	7e 0e                	jle    800696 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800688:	8b 10                	mov    (%eax),%edx
  80068a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80068d:	89 08                	mov    %ecx,(%eax)
  80068f:	8b 02                	mov    (%edx),%eax
  800691:	8b 52 04             	mov    0x4(%edx),%edx
  800694:	eb 22                	jmp    8006b8 <getuint+0x38>
	else if (lflag)
  800696:	85 d2                	test   %edx,%edx
  800698:	74 10                	je     8006aa <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80069a:	8b 10                	mov    (%eax),%edx
  80069c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80069f:	89 08                	mov    %ecx,(%eax)
  8006a1:	8b 02                	mov    (%edx),%eax
  8006a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8006a8:	eb 0e                	jmp    8006b8 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8006aa:	8b 10                	mov    (%eax),%edx
  8006ac:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006af:	89 08                	mov    %ecx,(%eax)
  8006b1:	8b 02                	mov    (%edx),%eax
  8006b3:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8006b8:	5d                   	pop    %ebp
  8006b9:	c3                   	ret    

008006ba <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8006ba:	55                   	push   %ebp
  8006bb:	89 e5                	mov    %esp,%ebp
  8006bd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8006c0:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8006c4:	8b 10                	mov    (%eax),%edx
  8006c6:	3b 50 04             	cmp    0x4(%eax),%edx
  8006c9:	73 0a                	jae    8006d5 <sprintputch+0x1b>
		*b->buf++ = ch;
  8006cb:	8d 4a 01             	lea    0x1(%edx),%ecx
  8006ce:	89 08                	mov    %ecx,(%eax)
  8006d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d3:	88 02                	mov    %al,(%edx)
}
  8006d5:	5d                   	pop    %ebp
  8006d6:	c3                   	ret    

008006d7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8006d7:	55                   	push   %ebp
  8006d8:	89 e5                	mov    %esp,%ebp
  8006da:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8006dd:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006e0:	50                   	push   %eax
  8006e1:	ff 75 10             	pushl  0x10(%ebp)
  8006e4:	ff 75 0c             	pushl  0xc(%ebp)
  8006e7:	ff 75 08             	pushl  0x8(%ebp)
  8006ea:	e8 05 00 00 00       	call   8006f4 <vprintfmt>
	va_end(ap);
}
  8006ef:	83 c4 10             	add    $0x10,%esp
  8006f2:	c9                   	leave  
  8006f3:	c3                   	ret    

008006f4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006f4:	55                   	push   %ebp
  8006f5:	89 e5                	mov    %esp,%ebp
  8006f7:	57                   	push   %edi
  8006f8:	56                   	push   %esi
  8006f9:	53                   	push   %ebx
  8006fa:	83 ec 2c             	sub    $0x2c,%esp
  8006fd:	8b 75 08             	mov    0x8(%ebp),%esi
  800700:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800703:	8b 7d 10             	mov    0x10(%ebp),%edi
  800706:	eb 12                	jmp    80071a <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800708:	85 c0                	test   %eax,%eax
  80070a:	0f 84 a7 03 00 00    	je     800ab7 <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
  800710:	83 ec 08             	sub    $0x8,%esp
  800713:	53                   	push   %ebx
  800714:	50                   	push   %eax
  800715:	ff d6                	call   *%esi
  800717:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80071a:	83 c7 01             	add    $0x1,%edi
  80071d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800721:	83 f8 25             	cmp    $0x25,%eax
  800724:	75 e2                	jne    800708 <vprintfmt+0x14>
  800726:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80072a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800731:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800738:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80073f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800746:	b9 00 00 00 00       	mov    $0x0,%ecx
  80074b:	eb 07                	jmp    800754 <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80074d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800750:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800754:	8d 47 01             	lea    0x1(%edi),%eax
  800757:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80075a:	0f b6 07             	movzbl (%edi),%eax
  80075d:	0f b6 d0             	movzbl %al,%edx
  800760:	83 e8 23             	sub    $0x23,%eax
  800763:	3c 55                	cmp    $0x55,%al
  800765:	0f 87 31 03 00 00    	ja     800a9c <vprintfmt+0x3a8>
  80076b:	0f b6 c0             	movzbl %al,%eax
  80076e:	ff 24 85 e0 2c 80 00 	jmp    *0x802ce0(,%eax,4)
  800775:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800778:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80077c:	eb d6                	jmp    800754 <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80077e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800781:	b8 00 00 00 00       	mov    $0x0,%eax
  800786:	89 75 08             	mov    %esi,0x8(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800789:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80078c:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800790:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800793:	8d 72 d0             	lea    -0x30(%edx),%esi
  800796:	83 fe 09             	cmp    $0x9,%esi
  800799:	77 34                	ja     8007cf <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80079b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80079e:	eb e9                	jmp    800789 <vprintfmt+0x95>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8007a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a3:	8d 50 04             	lea    0x4(%eax),%edx
  8007a6:	89 55 14             	mov    %edx,0x14(%ebp)
  8007a9:	8b 00                	mov    (%eax),%eax
  8007ab:	89 45 cc             	mov    %eax,-0x34(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8007b1:	eb 22                	jmp    8007d5 <vprintfmt+0xe1>
  8007b3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007b6:	85 c0                	test   %eax,%eax
  8007b8:	0f 48 c1             	cmovs  %ecx,%eax
  8007bb:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007c1:	eb 91                	jmp    800754 <vprintfmt+0x60>
  8007c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8007c6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8007cd:	eb 85                	jmp    800754 <vprintfmt+0x60>
  8007cf:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8007d2:	8b 75 08             	mov    0x8(%ebp),%esi

		process_precision:
			if (width < 0)
  8007d5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8007d9:	0f 89 75 ff ff ff    	jns    800754 <vprintfmt+0x60>
				width = precision, precision = -1;
  8007df:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8007e2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007e5:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8007ec:	e9 63 ff ff ff       	jmp    800754 <vprintfmt+0x60>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007f1:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8007f8:	e9 57 ff ff ff       	jmp    800754 <vprintfmt+0x60>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800800:	8d 50 04             	lea    0x4(%eax),%edx
  800803:	89 55 14             	mov    %edx,0x14(%ebp)
  800806:	83 ec 08             	sub    $0x8,%esp
  800809:	53                   	push   %ebx
  80080a:	ff 30                	pushl  (%eax)
  80080c:	ff d6                	call   *%esi
			break;
  80080e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800811:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800814:	e9 01 ff ff ff       	jmp    80071a <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800819:	8b 45 14             	mov    0x14(%ebp),%eax
  80081c:	8d 50 04             	lea    0x4(%eax),%edx
  80081f:	89 55 14             	mov    %edx,0x14(%ebp)
  800822:	8b 00                	mov    (%eax),%eax
  800824:	99                   	cltd   
  800825:	31 d0                	xor    %edx,%eax
  800827:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800829:	83 f8 0f             	cmp    $0xf,%eax
  80082c:	7f 0b                	jg     800839 <vprintfmt+0x145>
  80082e:	8b 14 85 40 2e 80 00 	mov    0x802e40(,%eax,4),%edx
  800835:	85 d2                	test   %edx,%edx
  800837:	75 18                	jne    800851 <vprintfmt+0x15d>
				printfmt(putch, putdat, "error %d", err);
  800839:	50                   	push   %eax
  80083a:	68 a7 2b 80 00       	push   $0x802ba7
  80083f:	53                   	push   %ebx
  800840:	56                   	push   %esi
  800841:	e8 91 fe ff ff       	call   8006d7 <printfmt>
  800846:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800849:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80084c:	e9 c9 fe ff ff       	jmp    80071a <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800851:	52                   	push   %edx
  800852:	68 99 30 80 00       	push   $0x803099
  800857:	53                   	push   %ebx
  800858:	56                   	push   %esi
  800859:	e8 79 fe ff ff       	call   8006d7 <printfmt>
  80085e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800861:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800864:	e9 b1 fe ff ff       	jmp    80071a <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800869:	8b 45 14             	mov    0x14(%ebp),%eax
  80086c:	8d 50 04             	lea    0x4(%eax),%edx
  80086f:	89 55 14             	mov    %edx,0x14(%ebp)
  800872:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800874:	85 ff                	test   %edi,%edi
  800876:	b8 a0 2b 80 00       	mov    $0x802ba0,%eax
  80087b:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80087e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800882:	0f 8e 94 00 00 00    	jle    80091c <vprintfmt+0x228>
  800888:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80088c:	0f 84 98 00 00 00    	je     80092a <vprintfmt+0x236>
				for (width -= strnlen(p, precision); width > 0; width--)
  800892:	83 ec 08             	sub    $0x8,%esp
  800895:	ff 75 cc             	pushl  -0x34(%ebp)
  800898:	57                   	push   %edi
  800899:	e8 a1 02 00 00       	call   800b3f <strnlen>
  80089e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8008a1:	29 c1                	sub    %eax,%ecx
  8008a3:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8008a6:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8008a9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8008ad:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008b0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8008b3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008b5:	eb 0f                	jmp    8008c6 <vprintfmt+0x1d2>
					putch(padc, putdat);
  8008b7:	83 ec 08             	sub    $0x8,%esp
  8008ba:	53                   	push   %ebx
  8008bb:	ff 75 e0             	pushl  -0x20(%ebp)
  8008be:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008c0:	83 ef 01             	sub    $0x1,%edi
  8008c3:	83 c4 10             	add    $0x10,%esp
  8008c6:	85 ff                	test   %edi,%edi
  8008c8:	7f ed                	jg     8008b7 <vprintfmt+0x1c3>
  8008ca:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8008cd:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8008d0:	85 c9                	test   %ecx,%ecx
  8008d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d7:	0f 49 c1             	cmovns %ecx,%eax
  8008da:	29 c1                	sub    %eax,%ecx
  8008dc:	89 75 08             	mov    %esi,0x8(%ebp)
  8008df:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8008e2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8008e5:	89 cb                	mov    %ecx,%ebx
  8008e7:	eb 4d                	jmp    800936 <vprintfmt+0x242>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8008e9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8008ed:	74 1b                	je     80090a <vprintfmt+0x216>
  8008ef:	0f be c0             	movsbl %al,%eax
  8008f2:	83 e8 20             	sub    $0x20,%eax
  8008f5:	83 f8 5e             	cmp    $0x5e,%eax
  8008f8:	76 10                	jbe    80090a <vprintfmt+0x216>
					putch('?', putdat);
  8008fa:	83 ec 08             	sub    $0x8,%esp
  8008fd:	ff 75 0c             	pushl  0xc(%ebp)
  800900:	6a 3f                	push   $0x3f
  800902:	ff 55 08             	call   *0x8(%ebp)
  800905:	83 c4 10             	add    $0x10,%esp
  800908:	eb 0d                	jmp    800917 <vprintfmt+0x223>
				else
					putch(ch, putdat);
  80090a:	83 ec 08             	sub    $0x8,%esp
  80090d:	ff 75 0c             	pushl  0xc(%ebp)
  800910:	52                   	push   %edx
  800911:	ff 55 08             	call   *0x8(%ebp)
  800914:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800917:	83 eb 01             	sub    $0x1,%ebx
  80091a:	eb 1a                	jmp    800936 <vprintfmt+0x242>
  80091c:	89 75 08             	mov    %esi,0x8(%ebp)
  80091f:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800922:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800925:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800928:	eb 0c                	jmp    800936 <vprintfmt+0x242>
  80092a:	89 75 08             	mov    %esi,0x8(%ebp)
  80092d:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800930:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800933:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800936:	83 c7 01             	add    $0x1,%edi
  800939:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80093d:	0f be d0             	movsbl %al,%edx
  800940:	85 d2                	test   %edx,%edx
  800942:	74 23                	je     800967 <vprintfmt+0x273>
  800944:	85 f6                	test   %esi,%esi
  800946:	78 a1                	js     8008e9 <vprintfmt+0x1f5>
  800948:	83 ee 01             	sub    $0x1,%esi
  80094b:	79 9c                	jns    8008e9 <vprintfmt+0x1f5>
  80094d:	89 df                	mov    %ebx,%edi
  80094f:	8b 75 08             	mov    0x8(%ebp),%esi
  800952:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800955:	eb 18                	jmp    80096f <vprintfmt+0x27b>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800957:	83 ec 08             	sub    $0x8,%esp
  80095a:	53                   	push   %ebx
  80095b:	6a 20                	push   $0x20
  80095d:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80095f:	83 ef 01             	sub    $0x1,%edi
  800962:	83 c4 10             	add    $0x10,%esp
  800965:	eb 08                	jmp    80096f <vprintfmt+0x27b>
  800967:	89 df                	mov    %ebx,%edi
  800969:	8b 75 08             	mov    0x8(%ebp),%esi
  80096c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80096f:	85 ff                	test   %edi,%edi
  800971:	7f e4                	jg     800957 <vprintfmt+0x263>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800973:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800976:	e9 9f fd ff ff       	jmp    80071a <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80097b:	83 7d d0 01          	cmpl   $0x1,-0x30(%ebp)
  80097f:	7e 16                	jle    800997 <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  800981:	8b 45 14             	mov    0x14(%ebp),%eax
  800984:	8d 50 08             	lea    0x8(%eax),%edx
  800987:	89 55 14             	mov    %edx,0x14(%ebp)
  80098a:	8b 50 04             	mov    0x4(%eax),%edx
  80098d:	8b 00                	mov    (%eax),%eax
  80098f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800992:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800995:	eb 34                	jmp    8009cb <vprintfmt+0x2d7>
	else if (lflag)
  800997:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80099b:	74 18                	je     8009b5 <vprintfmt+0x2c1>
		return va_arg(*ap, long);
  80099d:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a0:	8d 50 04             	lea    0x4(%eax),%edx
  8009a3:	89 55 14             	mov    %edx,0x14(%ebp)
  8009a6:	8b 00                	mov    (%eax),%eax
  8009a8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8009ab:	89 c1                	mov    %eax,%ecx
  8009ad:	c1 f9 1f             	sar    $0x1f,%ecx
  8009b0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8009b3:	eb 16                	jmp    8009cb <vprintfmt+0x2d7>
	else
		return va_arg(*ap, int);
  8009b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8009b8:	8d 50 04             	lea    0x4(%eax),%edx
  8009bb:	89 55 14             	mov    %edx,0x14(%ebp)
  8009be:	8b 00                	mov    (%eax),%eax
  8009c0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8009c3:	89 c1                	mov    %eax,%ecx
  8009c5:	c1 f9 1f             	sar    $0x1f,%ecx
  8009c8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8009cb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8009ce:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8009d1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8009d6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8009da:	0f 89 88 00 00 00    	jns    800a68 <vprintfmt+0x374>
				putch('-', putdat);
  8009e0:	83 ec 08             	sub    $0x8,%esp
  8009e3:	53                   	push   %ebx
  8009e4:	6a 2d                	push   $0x2d
  8009e6:	ff d6                	call   *%esi
				num = -(long long) num;
  8009e8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8009eb:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8009ee:	f7 d8                	neg    %eax
  8009f0:	83 d2 00             	adc    $0x0,%edx
  8009f3:	f7 da                	neg    %edx
  8009f5:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8009f8:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8009fd:	eb 69                	jmp    800a68 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009ff:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800a02:	8d 45 14             	lea    0x14(%ebp),%eax
  800a05:	e8 76 fc ff ff       	call   800680 <getuint>
			base = 10;
  800a0a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800a0f:	eb 57                	jmp    800a68 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  800a11:	83 ec 08             	sub    $0x8,%esp
  800a14:	53                   	push   %ebx
  800a15:	6a 30                	push   $0x30
  800a17:	ff d6                	call   *%esi
			num = getuint(&ap, lflag);
  800a19:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800a1c:	8d 45 14             	lea    0x14(%ebp),%eax
  800a1f:	e8 5c fc ff ff       	call   800680 <getuint>
			base = 8;
			goto number;
  800a24:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800a27:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800a2c:	eb 3a                	jmp    800a68 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  800a2e:	83 ec 08             	sub    $0x8,%esp
  800a31:	53                   	push   %ebx
  800a32:	6a 30                	push   $0x30
  800a34:	ff d6                	call   *%esi
			putch('x', putdat);
  800a36:	83 c4 08             	add    $0x8,%esp
  800a39:	53                   	push   %ebx
  800a3a:	6a 78                	push   $0x78
  800a3c:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a3e:	8b 45 14             	mov    0x14(%ebp),%eax
  800a41:	8d 50 04             	lea    0x4(%eax),%edx
  800a44:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a47:	8b 00                	mov    (%eax),%eax
  800a49:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800a4e:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a51:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800a56:	eb 10                	jmp    800a68 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a58:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800a5b:	8d 45 14             	lea    0x14(%ebp),%eax
  800a5e:	e8 1d fc ff ff       	call   800680 <getuint>
			base = 16;
  800a63:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a68:	83 ec 0c             	sub    $0xc,%esp
  800a6b:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800a6f:	57                   	push   %edi
  800a70:	ff 75 e0             	pushl  -0x20(%ebp)
  800a73:	51                   	push   %ecx
  800a74:	52                   	push   %edx
  800a75:	50                   	push   %eax
  800a76:	89 da                	mov    %ebx,%edx
  800a78:	89 f0                	mov    %esi,%eax
  800a7a:	e8 52 fb ff ff       	call   8005d1 <printnum>
			break;
  800a7f:	83 c4 20             	add    $0x20,%esp
  800a82:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a85:	e9 90 fc ff ff       	jmp    80071a <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a8a:	83 ec 08             	sub    $0x8,%esp
  800a8d:	53                   	push   %ebx
  800a8e:	52                   	push   %edx
  800a8f:	ff d6                	call   *%esi
			break;
  800a91:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a94:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800a97:	e9 7e fc ff ff       	jmp    80071a <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a9c:	83 ec 08             	sub    $0x8,%esp
  800a9f:	53                   	push   %ebx
  800aa0:	6a 25                	push   $0x25
  800aa2:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800aa4:	83 c4 10             	add    $0x10,%esp
  800aa7:	eb 03                	jmp    800aac <vprintfmt+0x3b8>
  800aa9:	83 ef 01             	sub    $0x1,%edi
  800aac:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800ab0:	75 f7                	jne    800aa9 <vprintfmt+0x3b5>
  800ab2:	e9 63 fc ff ff       	jmp    80071a <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800ab7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800aba:	5b                   	pop    %ebx
  800abb:	5e                   	pop    %esi
  800abc:	5f                   	pop    %edi
  800abd:	5d                   	pop    %ebp
  800abe:	c3                   	ret    

00800abf <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800abf:	55                   	push   %ebp
  800ac0:	89 e5                	mov    %esp,%ebp
  800ac2:	83 ec 18             	sub    $0x18,%esp
  800ac5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800acb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ace:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800ad2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800ad5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800adc:	85 c0                	test   %eax,%eax
  800ade:	74 26                	je     800b06 <vsnprintf+0x47>
  800ae0:	85 d2                	test   %edx,%edx
  800ae2:	7e 22                	jle    800b06 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ae4:	ff 75 14             	pushl  0x14(%ebp)
  800ae7:	ff 75 10             	pushl  0x10(%ebp)
  800aea:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800aed:	50                   	push   %eax
  800aee:	68 ba 06 80 00       	push   $0x8006ba
  800af3:	e8 fc fb ff ff       	call   8006f4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800af8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800afb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800afe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b01:	83 c4 10             	add    $0x10,%esp
  800b04:	eb 05                	jmp    800b0b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800b06:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800b0b:	c9                   	leave  
  800b0c:	c3                   	ret    

00800b0d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b0d:	55                   	push   %ebp
  800b0e:	89 e5                	mov    %esp,%ebp
  800b10:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b13:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800b16:	50                   	push   %eax
  800b17:	ff 75 10             	pushl  0x10(%ebp)
  800b1a:	ff 75 0c             	pushl  0xc(%ebp)
  800b1d:	ff 75 08             	pushl  0x8(%ebp)
  800b20:	e8 9a ff ff ff       	call   800abf <vsnprintf>
	va_end(ap);

	return rc;
}
  800b25:	c9                   	leave  
  800b26:	c3                   	ret    

00800b27 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b27:	55                   	push   %ebp
  800b28:	89 e5                	mov    %esp,%ebp
  800b2a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b2d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b32:	eb 03                	jmp    800b37 <strlen+0x10>
		n++;
  800b34:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b37:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b3b:	75 f7                	jne    800b34 <strlen+0xd>
		n++;
	return n;
}
  800b3d:	5d                   	pop    %ebp
  800b3e:	c3                   	ret    

00800b3f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b3f:	55                   	push   %ebp
  800b40:	89 e5                	mov    %esp,%ebp
  800b42:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b45:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b48:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4d:	eb 03                	jmp    800b52 <strnlen+0x13>
		n++;
  800b4f:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b52:	39 c2                	cmp    %eax,%edx
  800b54:	74 08                	je     800b5e <strnlen+0x1f>
  800b56:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800b5a:	75 f3                	jne    800b4f <strnlen+0x10>
  800b5c:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800b5e:	5d                   	pop    %ebp
  800b5f:	c3                   	ret    

00800b60 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b60:	55                   	push   %ebp
  800b61:	89 e5                	mov    %esp,%ebp
  800b63:	53                   	push   %ebx
  800b64:	8b 45 08             	mov    0x8(%ebp),%eax
  800b67:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b6a:	89 c2                	mov    %eax,%edx
  800b6c:	83 c2 01             	add    $0x1,%edx
  800b6f:	83 c1 01             	add    $0x1,%ecx
  800b72:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800b76:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b79:	84 db                	test   %bl,%bl
  800b7b:	75 ef                	jne    800b6c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800b7d:	5b                   	pop    %ebx
  800b7e:	5d                   	pop    %ebp
  800b7f:	c3                   	ret    

00800b80 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	53                   	push   %ebx
  800b84:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b87:	53                   	push   %ebx
  800b88:	e8 9a ff ff ff       	call   800b27 <strlen>
  800b8d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800b90:	ff 75 0c             	pushl  0xc(%ebp)
  800b93:	01 d8                	add    %ebx,%eax
  800b95:	50                   	push   %eax
  800b96:	e8 c5 ff ff ff       	call   800b60 <strcpy>
	return dst;
}
  800b9b:	89 d8                	mov    %ebx,%eax
  800b9d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ba0:	c9                   	leave  
  800ba1:	c3                   	ret    

00800ba2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ba2:	55                   	push   %ebp
  800ba3:	89 e5                	mov    %esp,%ebp
  800ba5:	56                   	push   %esi
  800ba6:	53                   	push   %ebx
  800ba7:	8b 75 08             	mov    0x8(%ebp),%esi
  800baa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bad:	89 f3                	mov    %esi,%ebx
  800baf:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bb2:	89 f2                	mov    %esi,%edx
  800bb4:	eb 0f                	jmp    800bc5 <strncpy+0x23>
		*dst++ = *src;
  800bb6:	83 c2 01             	add    $0x1,%edx
  800bb9:	0f b6 01             	movzbl (%ecx),%eax
  800bbc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800bbf:	80 39 01             	cmpb   $0x1,(%ecx)
  800bc2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bc5:	39 da                	cmp    %ebx,%edx
  800bc7:	75 ed                	jne    800bb6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800bc9:	89 f0                	mov    %esi,%eax
  800bcb:	5b                   	pop    %ebx
  800bcc:	5e                   	pop    %esi
  800bcd:	5d                   	pop    %ebp
  800bce:	c3                   	ret    

00800bcf <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800bcf:	55                   	push   %ebp
  800bd0:	89 e5                	mov    %esp,%ebp
  800bd2:	56                   	push   %esi
  800bd3:	53                   	push   %ebx
  800bd4:	8b 75 08             	mov    0x8(%ebp),%esi
  800bd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bda:	8b 55 10             	mov    0x10(%ebp),%edx
  800bdd:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800bdf:	85 d2                	test   %edx,%edx
  800be1:	74 21                	je     800c04 <strlcpy+0x35>
  800be3:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800be7:	89 f2                	mov    %esi,%edx
  800be9:	eb 09                	jmp    800bf4 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800beb:	83 c2 01             	add    $0x1,%edx
  800bee:	83 c1 01             	add    $0x1,%ecx
  800bf1:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800bf4:	39 c2                	cmp    %eax,%edx
  800bf6:	74 09                	je     800c01 <strlcpy+0x32>
  800bf8:	0f b6 19             	movzbl (%ecx),%ebx
  800bfb:	84 db                	test   %bl,%bl
  800bfd:	75 ec                	jne    800beb <strlcpy+0x1c>
  800bff:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800c01:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800c04:	29 f0                	sub    %esi,%eax
}
  800c06:	5b                   	pop    %ebx
  800c07:	5e                   	pop    %esi
  800c08:	5d                   	pop    %ebp
  800c09:	c3                   	ret    

00800c0a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c0a:	55                   	push   %ebp
  800c0b:	89 e5                	mov    %esp,%ebp
  800c0d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c10:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c13:	eb 06                	jmp    800c1b <strcmp+0x11>
		p++, q++;
  800c15:	83 c1 01             	add    $0x1,%ecx
  800c18:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800c1b:	0f b6 01             	movzbl (%ecx),%eax
  800c1e:	84 c0                	test   %al,%al
  800c20:	74 04                	je     800c26 <strcmp+0x1c>
  800c22:	3a 02                	cmp    (%edx),%al
  800c24:	74 ef                	je     800c15 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c26:	0f b6 c0             	movzbl %al,%eax
  800c29:	0f b6 12             	movzbl (%edx),%edx
  800c2c:	29 d0                	sub    %edx,%eax
}
  800c2e:	5d                   	pop    %ebp
  800c2f:	c3                   	ret    

00800c30 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c30:	55                   	push   %ebp
  800c31:	89 e5                	mov    %esp,%ebp
  800c33:	53                   	push   %ebx
  800c34:	8b 45 08             	mov    0x8(%ebp),%eax
  800c37:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c3a:	89 c3                	mov    %eax,%ebx
  800c3c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800c3f:	eb 06                	jmp    800c47 <strncmp+0x17>
		n--, p++, q++;
  800c41:	83 c0 01             	add    $0x1,%eax
  800c44:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c47:	39 d8                	cmp    %ebx,%eax
  800c49:	74 15                	je     800c60 <strncmp+0x30>
  800c4b:	0f b6 08             	movzbl (%eax),%ecx
  800c4e:	84 c9                	test   %cl,%cl
  800c50:	74 04                	je     800c56 <strncmp+0x26>
  800c52:	3a 0a                	cmp    (%edx),%cl
  800c54:	74 eb                	je     800c41 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c56:	0f b6 00             	movzbl (%eax),%eax
  800c59:	0f b6 12             	movzbl (%edx),%edx
  800c5c:	29 d0                	sub    %edx,%eax
  800c5e:	eb 05                	jmp    800c65 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c60:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c65:	5b                   	pop    %ebx
  800c66:	5d                   	pop    %ebp
  800c67:	c3                   	ret    

00800c68 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c68:	55                   	push   %ebp
  800c69:	89 e5                	mov    %esp,%ebp
  800c6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c6e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c72:	eb 07                	jmp    800c7b <strchr+0x13>
		if (*s == c)
  800c74:	38 ca                	cmp    %cl,%dl
  800c76:	74 0f                	je     800c87 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c78:	83 c0 01             	add    $0x1,%eax
  800c7b:	0f b6 10             	movzbl (%eax),%edx
  800c7e:	84 d2                	test   %dl,%dl
  800c80:	75 f2                	jne    800c74 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800c82:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c87:	5d                   	pop    %ebp
  800c88:	c3                   	ret    

00800c89 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c89:	55                   	push   %ebp
  800c8a:	89 e5                	mov    %esp,%ebp
  800c8c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c93:	eb 03                	jmp    800c98 <strfind+0xf>
  800c95:	83 c0 01             	add    $0x1,%eax
  800c98:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800c9b:	38 ca                	cmp    %cl,%dl
  800c9d:	74 04                	je     800ca3 <strfind+0x1a>
  800c9f:	84 d2                	test   %dl,%dl
  800ca1:	75 f2                	jne    800c95 <strfind+0xc>
			break;
	return (char *) s;
}
  800ca3:	5d                   	pop    %ebp
  800ca4:	c3                   	ret    

00800ca5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ca5:	55                   	push   %ebp
  800ca6:	89 e5                	mov    %esp,%ebp
  800ca8:	57                   	push   %edi
  800ca9:	56                   	push   %esi
  800caa:	53                   	push   %ebx
  800cab:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cae:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800cb1:	85 c9                	test   %ecx,%ecx
  800cb3:	74 36                	je     800ceb <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800cb5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800cbb:	75 28                	jne    800ce5 <memset+0x40>
  800cbd:	f6 c1 03             	test   $0x3,%cl
  800cc0:	75 23                	jne    800ce5 <memset+0x40>
		c &= 0xFF;
  800cc2:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800cc6:	89 d3                	mov    %edx,%ebx
  800cc8:	c1 e3 08             	shl    $0x8,%ebx
  800ccb:	89 d6                	mov    %edx,%esi
  800ccd:	c1 e6 18             	shl    $0x18,%esi
  800cd0:	89 d0                	mov    %edx,%eax
  800cd2:	c1 e0 10             	shl    $0x10,%eax
  800cd5:	09 f0                	or     %esi,%eax
  800cd7:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800cd9:	89 d8                	mov    %ebx,%eax
  800cdb:	09 d0                	or     %edx,%eax
  800cdd:	c1 e9 02             	shr    $0x2,%ecx
  800ce0:	fc                   	cld    
  800ce1:	f3 ab                	rep stos %eax,%es:(%edi)
  800ce3:	eb 06                	jmp    800ceb <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ce5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ce8:	fc                   	cld    
  800ce9:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ceb:	89 f8                	mov    %edi,%eax
  800ced:	5b                   	pop    %ebx
  800cee:	5e                   	pop    %esi
  800cef:	5f                   	pop    %edi
  800cf0:	5d                   	pop    %ebp
  800cf1:	c3                   	ret    

00800cf2 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800cf2:	55                   	push   %ebp
  800cf3:	89 e5                	mov    %esp,%ebp
  800cf5:	57                   	push   %edi
  800cf6:	56                   	push   %esi
  800cf7:	8b 45 08             	mov    0x8(%ebp),%eax
  800cfa:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cfd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d00:	39 c6                	cmp    %eax,%esi
  800d02:	73 35                	jae    800d39 <memmove+0x47>
  800d04:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d07:	39 d0                	cmp    %edx,%eax
  800d09:	73 2e                	jae    800d39 <memmove+0x47>
		s += n;
		d += n;
  800d0b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d0e:	89 d6                	mov    %edx,%esi
  800d10:	09 fe                	or     %edi,%esi
  800d12:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d18:	75 13                	jne    800d2d <memmove+0x3b>
  800d1a:	f6 c1 03             	test   $0x3,%cl
  800d1d:	75 0e                	jne    800d2d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800d1f:	83 ef 04             	sub    $0x4,%edi
  800d22:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d25:	c1 e9 02             	shr    $0x2,%ecx
  800d28:	fd                   	std    
  800d29:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d2b:	eb 09                	jmp    800d36 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d2d:	83 ef 01             	sub    $0x1,%edi
  800d30:	8d 72 ff             	lea    -0x1(%edx),%esi
  800d33:	fd                   	std    
  800d34:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d36:	fc                   	cld    
  800d37:	eb 1d                	jmp    800d56 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d39:	89 f2                	mov    %esi,%edx
  800d3b:	09 c2                	or     %eax,%edx
  800d3d:	f6 c2 03             	test   $0x3,%dl
  800d40:	75 0f                	jne    800d51 <memmove+0x5f>
  800d42:	f6 c1 03             	test   $0x3,%cl
  800d45:	75 0a                	jne    800d51 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800d47:	c1 e9 02             	shr    $0x2,%ecx
  800d4a:	89 c7                	mov    %eax,%edi
  800d4c:	fc                   	cld    
  800d4d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d4f:	eb 05                	jmp    800d56 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d51:	89 c7                	mov    %eax,%edi
  800d53:	fc                   	cld    
  800d54:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d56:	5e                   	pop    %esi
  800d57:	5f                   	pop    %edi
  800d58:	5d                   	pop    %ebp
  800d59:	c3                   	ret    

00800d5a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d5a:	55                   	push   %ebp
  800d5b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800d5d:	ff 75 10             	pushl  0x10(%ebp)
  800d60:	ff 75 0c             	pushl  0xc(%ebp)
  800d63:	ff 75 08             	pushl  0x8(%ebp)
  800d66:	e8 87 ff ff ff       	call   800cf2 <memmove>
}
  800d6b:	c9                   	leave  
  800d6c:	c3                   	ret    

00800d6d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d6d:	55                   	push   %ebp
  800d6e:	89 e5                	mov    %esp,%ebp
  800d70:	56                   	push   %esi
  800d71:	53                   	push   %ebx
  800d72:	8b 45 08             	mov    0x8(%ebp),%eax
  800d75:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d78:	89 c6                	mov    %eax,%esi
  800d7a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d7d:	eb 1a                	jmp    800d99 <memcmp+0x2c>
		if (*s1 != *s2)
  800d7f:	0f b6 08             	movzbl (%eax),%ecx
  800d82:	0f b6 1a             	movzbl (%edx),%ebx
  800d85:	38 d9                	cmp    %bl,%cl
  800d87:	74 0a                	je     800d93 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800d89:	0f b6 c1             	movzbl %cl,%eax
  800d8c:	0f b6 db             	movzbl %bl,%ebx
  800d8f:	29 d8                	sub    %ebx,%eax
  800d91:	eb 0f                	jmp    800da2 <memcmp+0x35>
		s1++, s2++;
  800d93:	83 c0 01             	add    $0x1,%eax
  800d96:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d99:	39 f0                	cmp    %esi,%eax
  800d9b:	75 e2                	jne    800d7f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d9d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800da2:	5b                   	pop    %ebx
  800da3:	5e                   	pop    %esi
  800da4:	5d                   	pop    %ebp
  800da5:	c3                   	ret    

00800da6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800da6:	55                   	push   %ebp
  800da7:	89 e5                	mov    %esp,%ebp
  800da9:	53                   	push   %ebx
  800daa:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800dad:	89 c1                	mov    %eax,%ecx
  800daf:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800db2:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800db6:	eb 0a                	jmp    800dc2 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800db8:	0f b6 10             	movzbl (%eax),%edx
  800dbb:	39 da                	cmp    %ebx,%edx
  800dbd:	74 07                	je     800dc6 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800dbf:	83 c0 01             	add    $0x1,%eax
  800dc2:	39 c8                	cmp    %ecx,%eax
  800dc4:	72 f2                	jb     800db8 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800dc6:	5b                   	pop    %ebx
  800dc7:	5d                   	pop    %ebp
  800dc8:	c3                   	ret    

00800dc9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800dc9:	55                   	push   %ebp
  800dca:	89 e5                	mov    %esp,%ebp
  800dcc:	57                   	push   %edi
  800dcd:	56                   	push   %esi
  800dce:	53                   	push   %ebx
  800dcf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dd2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800dd5:	eb 03                	jmp    800dda <strtol+0x11>
		s++;
  800dd7:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800dda:	0f b6 01             	movzbl (%ecx),%eax
  800ddd:	3c 20                	cmp    $0x20,%al
  800ddf:	74 f6                	je     800dd7 <strtol+0xe>
  800de1:	3c 09                	cmp    $0x9,%al
  800de3:	74 f2                	je     800dd7 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800de5:	3c 2b                	cmp    $0x2b,%al
  800de7:	75 0a                	jne    800df3 <strtol+0x2a>
		s++;
  800de9:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800dec:	bf 00 00 00 00       	mov    $0x0,%edi
  800df1:	eb 11                	jmp    800e04 <strtol+0x3b>
  800df3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800df8:	3c 2d                	cmp    $0x2d,%al
  800dfa:	75 08                	jne    800e04 <strtol+0x3b>
		s++, neg = 1;
  800dfc:	83 c1 01             	add    $0x1,%ecx
  800dff:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e04:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800e0a:	75 15                	jne    800e21 <strtol+0x58>
  800e0c:	80 39 30             	cmpb   $0x30,(%ecx)
  800e0f:	75 10                	jne    800e21 <strtol+0x58>
  800e11:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800e15:	75 7c                	jne    800e93 <strtol+0xca>
		s += 2, base = 16;
  800e17:	83 c1 02             	add    $0x2,%ecx
  800e1a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e1f:	eb 16                	jmp    800e37 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800e21:	85 db                	test   %ebx,%ebx
  800e23:	75 12                	jne    800e37 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e25:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e2a:	80 39 30             	cmpb   $0x30,(%ecx)
  800e2d:	75 08                	jne    800e37 <strtol+0x6e>
		s++, base = 8;
  800e2f:	83 c1 01             	add    $0x1,%ecx
  800e32:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800e37:	b8 00 00 00 00       	mov    $0x0,%eax
  800e3c:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e3f:	0f b6 11             	movzbl (%ecx),%edx
  800e42:	8d 72 d0             	lea    -0x30(%edx),%esi
  800e45:	89 f3                	mov    %esi,%ebx
  800e47:	80 fb 09             	cmp    $0x9,%bl
  800e4a:	77 08                	ja     800e54 <strtol+0x8b>
			dig = *s - '0';
  800e4c:	0f be d2             	movsbl %dl,%edx
  800e4f:	83 ea 30             	sub    $0x30,%edx
  800e52:	eb 22                	jmp    800e76 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800e54:	8d 72 9f             	lea    -0x61(%edx),%esi
  800e57:	89 f3                	mov    %esi,%ebx
  800e59:	80 fb 19             	cmp    $0x19,%bl
  800e5c:	77 08                	ja     800e66 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800e5e:	0f be d2             	movsbl %dl,%edx
  800e61:	83 ea 57             	sub    $0x57,%edx
  800e64:	eb 10                	jmp    800e76 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800e66:	8d 72 bf             	lea    -0x41(%edx),%esi
  800e69:	89 f3                	mov    %esi,%ebx
  800e6b:	80 fb 19             	cmp    $0x19,%bl
  800e6e:	77 16                	ja     800e86 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800e70:	0f be d2             	movsbl %dl,%edx
  800e73:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800e76:	3b 55 10             	cmp    0x10(%ebp),%edx
  800e79:	7d 0b                	jge    800e86 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800e7b:	83 c1 01             	add    $0x1,%ecx
  800e7e:	0f af 45 10          	imul   0x10(%ebp),%eax
  800e82:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800e84:	eb b9                	jmp    800e3f <strtol+0x76>

	if (endptr)
  800e86:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e8a:	74 0d                	je     800e99 <strtol+0xd0>
		*endptr = (char *) s;
  800e8c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e8f:	89 0e                	mov    %ecx,(%esi)
  800e91:	eb 06                	jmp    800e99 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e93:	85 db                	test   %ebx,%ebx
  800e95:	74 98                	je     800e2f <strtol+0x66>
  800e97:	eb 9e                	jmp    800e37 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800e99:	89 c2                	mov    %eax,%edx
  800e9b:	f7 da                	neg    %edx
  800e9d:	85 ff                	test   %edi,%edi
  800e9f:	0f 45 c2             	cmovne %edx,%eax
}
  800ea2:	5b                   	pop    %ebx
  800ea3:	5e                   	pop    %esi
  800ea4:	5f                   	pop    %edi
  800ea5:	5d                   	pop    %ebp
  800ea6:	c3                   	ret    

00800ea7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ea7:	55                   	push   %ebp
  800ea8:	89 e5                	mov    %esp,%ebp
  800eaa:	57                   	push   %edi
  800eab:	56                   	push   %esi
  800eac:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ead:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb5:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb8:	89 c3                	mov    %eax,%ebx
  800eba:	89 c7                	mov    %eax,%edi
  800ebc:	89 c6                	mov    %eax,%esi
  800ebe:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ec0:	5b                   	pop    %ebx
  800ec1:	5e                   	pop    %esi
  800ec2:	5f                   	pop    %edi
  800ec3:	5d                   	pop    %ebp
  800ec4:	c3                   	ret    

00800ec5 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ec5:	55                   	push   %ebp
  800ec6:	89 e5                	mov    %esp,%ebp
  800ec8:	57                   	push   %edi
  800ec9:	56                   	push   %esi
  800eca:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ecb:	ba 00 00 00 00       	mov    $0x0,%edx
  800ed0:	b8 01 00 00 00       	mov    $0x1,%eax
  800ed5:	89 d1                	mov    %edx,%ecx
  800ed7:	89 d3                	mov    %edx,%ebx
  800ed9:	89 d7                	mov    %edx,%edi
  800edb:	89 d6                	mov    %edx,%esi
  800edd:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800edf:	5b                   	pop    %ebx
  800ee0:	5e                   	pop    %esi
  800ee1:	5f                   	pop    %edi
  800ee2:	5d                   	pop    %ebp
  800ee3:	c3                   	ret    

00800ee4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ee4:	55                   	push   %ebp
  800ee5:	89 e5                	mov    %esp,%ebp
  800ee7:	57                   	push   %edi
  800ee8:	56                   	push   %esi
  800ee9:	53                   	push   %ebx
  800eea:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eed:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ef2:	b8 03 00 00 00       	mov    $0x3,%eax
  800ef7:	8b 55 08             	mov    0x8(%ebp),%edx
  800efa:	89 cb                	mov    %ecx,%ebx
  800efc:	89 cf                	mov    %ecx,%edi
  800efe:	89 ce                	mov    %ecx,%esi
  800f00:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f02:	85 c0                	test   %eax,%eax
  800f04:	7e 17                	jle    800f1d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f06:	83 ec 0c             	sub    $0xc,%esp
  800f09:	50                   	push   %eax
  800f0a:	6a 03                	push   $0x3
  800f0c:	68 9f 2e 80 00       	push   $0x802e9f
  800f11:	6a 23                	push   $0x23
  800f13:	68 bc 2e 80 00       	push   $0x802ebc
  800f18:	e8 c7 f5 ff ff       	call   8004e4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800f1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f20:	5b                   	pop    %ebx
  800f21:	5e                   	pop    %esi
  800f22:	5f                   	pop    %edi
  800f23:	5d                   	pop    %ebp
  800f24:	c3                   	ret    

00800f25 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800f25:	55                   	push   %ebp
  800f26:	89 e5                	mov    %esp,%ebp
  800f28:	57                   	push   %edi
  800f29:	56                   	push   %esi
  800f2a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f2b:	ba 00 00 00 00       	mov    $0x0,%edx
  800f30:	b8 02 00 00 00       	mov    $0x2,%eax
  800f35:	89 d1                	mov    %edx,%ecx
  800f37:	89 d3                	mov    %edx,%ebx
  800f39:	89 d7                	mov    %edx,%edi
  800f3b:	89 d6                	mov    %edx,%esi
  800f3d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f3f:	5b                   	pop    %ebx
  800f40:	5e                   	pop    %esi
  800f41:	5f                   	pop    %edi
  800f42:	5d                   	pop    %ebp
  800f43:	c3                   	ret    

00800f44 <sys_yield>:

void
sys_yield(void)
{
  800f44:	55                   	push   %ebp
  800f45:	89 e5                	mov    %esp,%ebp
  800f47:	57                   	push   %edi
  800f48:	56                   	push   %esi
  800f49:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f4a:	ba 00 00 00 00       	mov    $0x0,%edx
  800f4f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f54:	89 d1                	mov    %edx,%ecx
  800f56:	89 d3                	mov    %edx,%ebx
  800f58:	89 d7                	mov    %edx,%edi
  800f5a:	89 d6                	mov    %edx,%esi
  800f5c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f5e:	5b                   	pop    %ebx
  800f5f:	5e                   	pop    %esi
  800f60:	5f                   	pop    %edi
  800f61:	5d                   	pop    %ebp
  800f62:	c3                   	ret    

00800f63 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f63:	55                   	push   %ebp
  800f64:	89 e5                	mov    %esp,%ebp
  800f66:	57                   	push   %edi
  800f67:	56                   	push   %esi
  800f68:	53                   	push   %ebx
  800f69:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f6c:	be 00 00 00 00       	mov    $0x0,%esi
  800f71:	b8 04 00 00 00       	mov    $0x4,%eax
  800f76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f79:	8b 55 08             	mov    0x8(%ebp),%edx
  800f7c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f7f:	89 f7                	mov    %esi,%edi
  800f81:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f83:	85 c0                	test   %eax,%eax
  800f85:	7e 17                	jle    800f9e <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f87:	83 ec 0c             	sub    $0xc,%esp
  800f8a:	50                   	push   %eax
  800f8b:	6a 04                	push   $0x4
  800f8d:	68 9f 2e 80 00       	push   $0x802e9f
  800f92:	6a 23                	push   $0x23
  800f94:	68 bc 2e 80 00       	push   $0x802ebc
  800f99:	e8 46 f5 ff ff       	call   8004e4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fa1:	5b                   	pop    %ebx
  800fa2:	5e                   	pop    %esi
  800fa3:	5f                   	pop    %edi
  800fa4:	5d                   	pop    %ebp
  800fa5:	c3                   	ret    

00800fa6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800fa6:	55                   	push   %ebp
  800fa7:	89 e5                	mov    %esp,%ebp
  800fa9:	57                   	push   %edi
  800faa:	56                   	push   %esi
  800fab:	53                   	push   %ebx
  800fac:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800faf:	b8 05 00 00 00       	mov    $0x5,%eax
  800fb4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fb7:	8b 55 08             	mov    0x8(%ebp),%edx
  800fba:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fbd:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fc0:	8b 75 18             	mov    0x18(%ebp),%esi
  800fc3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fc5:	85 c0                	test   %eax,%eax
  800fc7:	7e 17                	jle    800fe0 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fc9:	83 ec 0c             	sub    $0xc,%esp
  800fcc:	50                   	push   %eax
  800fcd:	6a 05                	push   $0x5
  800fcf:	68 9f 2e 80 00       	push   $0x802e9f
  800fd4:	6a 23                	push   $0x23
  800fd6:	68 bc 2e 80 00       	push   $0x802ebc
  800fdb:	e8 04 f5 ff ff       	call   8004e4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800fe0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fe3:	5b                   	pop    %ebx
  800fe4:	5e                   	pop    %esi
  800fe5:	5f                   	pop    %edi
  800fe6:	5d                   	pop    %ebp
  800fe7:	c3                   	ret    

00800fe8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800fe8:	55                   	push   %ebp
  800fe9:	89 e5                	mov    %esp,%ebp
  800feb:	57                   	push   %edi
  800fec:	56                   	push   %esi
  800fed:	53                   	push   %ebx
  800fee:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ff1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ff6:	b8 06 00 00 00       	mov    $0x6,%eax
  800ffb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ffe:	8b 55 08             	mov    0x8(%ebp),%edx
  801001:	89 df                	mov    %ebx,%edi
  801003:	89 de                	mov    %ebx,%esi
  801005:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801007:	85 c0                	test   %eax,%eax
  801009:	7e 17                	jle    801022 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80100b:	83 ec 0c             	sub    $0xc,%esp
  80100e:	50                   	push   %eax
  80100f:	6a 06                	push   $0x6
  801011:	68 9f 2e 80 00       	push   $0x802e9f
  801016:	6a 23                	push   $0x23
  801018:	68 bc 2e 80 00       	push   $0x802ebc
  80101d:	e8 c2 f4 ff ff       	call   8004e4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801022:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801025:	5b                   	pop    %ebx
  801026:	5e                   	pop    %esi
  801027:	5f                   	pop    %edi
  801028:	5d                   	pop    %ebp
  801029:	c3                   	ret    

0080102a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80102a:	55                   	push   %ebp
  80102b:	89 e5                	mov    %esp,%ebp
  80102d:	57                   	push   %edi
  80102e:	56                   	push   %esi
  80102f:	53                   	push   %ebx
  801030:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801033:	bb 00 00 00 00       	mov    $0x0,%ebx
  801038:	b8 08 00 00 00       	mov    $0x8,%eax
  80103d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801040:	8b 55 08             	mov    0x8(%ebp),%edx
  801043:	89 df                	mov    %ebx,%edi
  801045:	89 de                	mov    %ebx,%esi
  801047:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801049:	85 c0                	test   %eax,%eax
  80104b:	7e 17                	jle    801064 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80104d:	83 ec 0c             	sub    $0xc,%esp
  801050:	50                   	push   %eax
  801051:	6a 08                	push   $0x8
  801053:	68 9f 2e 80 00       	push   $0x802e9f
  801058:	6a 23                	push   $0x23
  80105a:	68 bc 2e 80 00       	push   $0x802ebc
  80105f:	e8 80 f4 ff ff       	call   8004e4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801064:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801067:	5b                   	pop    %ebx
  801068:	5e                   	pop    %esi
  801069:	5f                   	pop    %edi
  80106a:	5d                   	pop    %ebp
  80106b:	c3                   	ret    

0080106c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80106c:	55                   	push   %ebp
  80106d:	89 e5                	mov    %esp,%ebp
  80106f:	57                   	push   %edi
  801070:	56                   	push   %esi
  801071:	53                   	push   %ebx
  801072:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801075:	bb 00 00 00 00       	mov    $0x0,%ebx
  80107a:	b8 09 00 00 00       	mov    $0x9,%eax
  80107f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801082:	8b 55 08             	mov    0x8(%ebp),%edx
  801085:	89 df                	mov    %ebx,%edi
  801087:	89 de                	mov    %ebx,%esi
  801089:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80108b:	85 c0                	test   %eax,%eax
  80108d:	7e 17                	jle    8010a6 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80108f:	83 ec 0c             	sub    $0xc,%esp
  801092:	50                   	push   %eax
  801093:	6a 09                	push   $0x9
  801095:	68 9f 2e 80 00       	push   $0x802e9f
  80109a:	6a 23                	push   $0x23
  80109c:	68 bc 2e 80 00       	push   $0x802ebc
  8010a1:	e8 3e f4 ff ff       	call   8004e4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8010a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010a9:	5b                   	pop    %ebx
  8010aa:	5e                   	pop    %esi
  8010ab:	5f                   	pop    %edi
  8010ac:	5d                   	pop    %ebp
  8010ad:	c3                   	ret    

008010ae <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8010ae:	55                   	push   %ebp
  8010af:	89 e5                	mov    %esp,%ebp
  8010b1:	57                   	push   %edi
  8010b2:	56                   	push   %esi
  8010b3:	53                   	push   %ebx
  8010b4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010b7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010bc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8010c7:	89 df                	mov    %ebx,%edi
  8010c9:	89 de                	mov    %ebx,%esi
  8010cb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010cd:	85 c0                	test   %eax,%eax
  8010cf:	7e 17                	jle    8010e8 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010d1:	83 ec 0c             	sub    $0xc,%esp
  8010d4:	50                   	push   %eax
  8010d5:	6a 0a                	push   $0xa
  8010d7:	68 9f 2e 80 00       	push   $0x802e9f
  8010dc:	6a 23                	push   $0x23
  8010de:	68 bc 2e 80 00       	push   $0x802ebc
  8010e3:	e8 fc f3 ff ff       	call   8004e4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8010e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010eb:	5b                   	pop    %ebx
  8010ec:	5e                   	pop    %esi
  8010ed:	5f                   	pop    %edi
  8010ee:	5d                   	pop    %ebp
  8010ef:	c3                   	ret    

008010f0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010f0:	55                   	push   %ebp
  8010f1:	89 e5                	mov    %esp,%ebp
  8010f3:	57                   	push   %edi
  8010f4:	56                   	push   %esi
  8010f5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010f6:	be 00 00 00 00       	mov    $0x0,%esi
  8010fb:	b8 0c 00 00 00       	mov    $0xc,%eax
  801100:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801103:	8b 55 08             	mov    0x8(%ebp),%edx
  801106:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801109:	8b 7d 14             	mov    0x14(%ebp),%edi
  80110c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80110e:	5b                   	pop    %ebx
  80110f:	5e                   	pop    %esi
  801110:	5f                   	pop    %edi
  801111:	5d                   	pop    %ebp
  801112:	c3                   	ret    

00801113 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801113:	55                   	push   %ebp
  801114:	89 e5                	mov    %esp,%ebp
  801116:	57                   	push   %edi
  801117:	56                   	push   %esi
  801118:	53                   	push   %ebx
  801119:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80111c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801121:	b8 0d 00 00 00       	mov    $0xd,%eax
  801126:	8b 55 08             	mov    0x8(%ebp),%edx
  801129:	89 cb                	mov    %ecx,%ebx
  80112b:	89 cf                	mov    %ecx,%edi
  80112d:	89 ce                	mov    %ecx,%esi
  80112f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801131:	85 c0                	test   %eax,%eax
  801133:	7e 17                	jle    80114c <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801135:	83 ec 0c             	sub    $0xc,%esp
  801138:	50                   	push   %eax
  801139:	6a 0d                	push   $0xd
  80113b:	68 9f 2e 80 00       	push   $0x802e9f
  801140:	6a 23                	push   $0x23
  801142:	68 bc 2e 80 00       	push   $0x802ebc
  801147:	e8 98 f3 ff ff       	call   8004e4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80114c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80114f:	5b                   	pop    %ebx
  801150:	5e                   	pop    %esi
  801151:	5f                   	pop    %edi
  801152:	5d                   	pop    %ebp
  801153:	c3                   	ret    

00801154 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  801154:	55                   	push   %ebp
  801155:	89 e5                	mov    %esp,%ebp
  801157:	53                   	push   %ebx
  801158:	83 ec 04             	sub    $0x4,%esp
	int r;
	// LAB 4: Your code here.
    	pte_t *pte;
	int ret;
	// 用户空间的地址较低
	void *addr = (void *)(pn * PGSIZE);
  80115b:	89 d3                	mov    %edx,%ebx
  80115d:	c1 e3 0c             	shl    $0xc,%ebx
	if (uvpt[pn] & PTE_SHARE) {
  801160:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  801167:	f6 c5 04             	test   $0x4,%ch
  80116a:	74 2f                	je     80119b <duppage+0x47>
		// cprintf("dup share page :%d\n", pn);
		if ((r = sys_page_map(0, addr, envid, addr, PTE_SYSCALL)) < 0)
  80116c:	83 ec 0c             	sub    $0xc,%esp
  80116f:	68 07 0e 00 00       	push   $0xe07
  801174:	53                   	push   %ebx
  801175:	50                   	push   %eax
  801176:	53                   	push   %ebx
  801177:	6a 00                	push   $0x0
  801179:	e8 28 fe ff ff       	call   800fa6 <sys_page_map>
  80117e:	83 c4 20             	add    $0x20,%esp
  801181:	85 c0                	test   %eax,%eax
  801183:	0f 89 a0 00 00 00    	jns    801229 <duppage+0xd5>
			panic("duppage sys_page_map:%e", r);
  801189:	50                   	push   %eax
  80118a:	68 ca 2e 80 00       	push   $0x802eca
  80118f:	6a 4d                	push   $0x4d
  801191:	68 e2 2e 80 00       	push   $0x802ee2
  801196:	e8 49 f3 ff ff       	call   8004e4 <_panic>
	} else if (uvpt[pn] & (PTE_W|PTE_COW)) {
  80119b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011a2:	f7 c2 02 08 00 00    	test   $0x802,%edx
  8011a8:	74 57                	je     801201 <duppage+0xad>
		if ((r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  8011aa:	83 ec 0c             	sub    $0xc,%esp
  8011ad:	68 05 08 00 00       	push   $0x805
  8011b2:	53                   	push   %ebx
  8011b3:	50                   	push   %eax
  8011b4:	53                   	push   %ebx
  8011b5:	6a 00                	push   $0x0
  8011b7:	e8 ea fd ff ff       	call   800fa6 <sys_page_map>
  8011bc:	83 c4 20             	add    $0x20,%esp
  8011bf:	85 c0                	test   %eax,%eax
  8011c1:	79 12                	jns    8011d5 <duppage+0x81>
			panic("sys_page_map COW:%e", r);
  8011c3:	50                   	push   %eax
  8011c4:	68 ed 2e 80 00       	push   $0x802eed
  8011c9:	6a 50                	push   $0x50
  8011cb:	68 e2 2e 80 00       	push   $0x802ee2
  8011d0:	e8 0f f3 ff ff       	call   8004e4 <_panic>

		if ((r = sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  8011d5:	83 ec 0c             	sub    $0xc,%esp
  8011d8:	68 05 08 00 00       	push   $0x805
  8011dd:	53                   	push   %ebx
  8011de:	6a 00                	push   $0x0
  8011e0:	53                   	push   %ebx
  8011e1:	6a 00                	push   $0x0
  8011e3:	e8 be fd ff ff       	call   800fa6 <sys_page_map>
  8011e8:	83 c4 20             	add    $0x20,%esp
  8011eb:	85 c0                	test   %eax,%eax
  8011ed:	79 3a                	jns    801229 <duppage+0xd5>
			panic("sys_page_map COW:%e", r);
  8011ef:	50                   	push   %eax
  8011f0:	68 ed 2e 80 00       	push   $0x802eed
  8011f5:	6a 53                	push   $0x53
  8011f7:	68 e2 2e 80 00       	push   $0x802ee2
  8011fc:	e8 e3 f2 ff ff       	call   8004e4 <_panic>
	} else {
		if ((r = sys_page_map(0, addr, envid, addr, PTE_U|PTE_P)) < 0)
  801201:	83 ec 0c             	sub    $0xc,%esp
  801204:	6a 05                	push   $0x5
  801206:	53                   	push   %ebx
  801207:	50                   	push   %eax
  801208:	53                   	push   %ebx
  801209:	6a 00                	push   $0x0
  80120b:	e8 96 fd ff ff       	call   800fa6 <sys_page_map>
  801210:	83 c4 20             	add    $0x20,%esp
  801213:	85 c0                	test   %eax,%eax
  801215:	79 12                	jns    801229 <duppage+0xd5>
			panic("sys_page_map UP:%e", r);
  801217:	50                   	push   %eax
  801218:	68 01 2f 80 00       	push   $0x802f01
  80121d:	6a 56                	push   $0x56
  80121f:	68 e2 2e 80 00       	push   $0x802ee2
  801224:	e8 bb f2 ff ff       	call   8004e4 <_panic>
	}
	return 0;
}
  801229:	b8 00 00 00 00       	mov    $0x0,%eax
  80122e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801231:	c9                   	leave  
  801232:	c3                   	ret    

00801233 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801233:	55                   	push   %ebp
  801234:	89 e5                	mov    %esp,%ebp
  801236:	56                   	push   %esi
  801237:	53                   	push   %ebx
  801238:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  80123b:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (! ( (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  80123d:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801241:	74 2d                	je     801270 <pgfault+0x3d>
  801243:	89 d8                	mov    %ebx,%eax
  801245:	c1 e8 16             	shr    $0x16,%eax
  801248:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80124f:	a8 01                	test   $0x1,%al
  801251:	74 1d                	je     801270 <pgfault+0x3d>
  801253:	89 d8                	mov    %ebx,%eax
  801255:	c1 e8 0c             	shr    $0xc,%eax
  801258:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80125f:	f6 c2 01             	test   $0x1,%dl
  801262:	74 0c                	je     801270 <pgfault+0x3d>
  801264:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80126b:	f6 c4 08             	test   $0x8,%ah
  80126e:	75 14                	jne    801284 <pgfault+0x51>
        	panic("Neither the fault is a write nor COW page. \n");
  801270:	83 ec 04             	sub    $0x4,%esp
  801273:	68 80 2f 80 00       	push   $0x802f80
  801278:	6a 1d                	push   $0x1d
  80127a:	68 e2 2e 80 00       	push   $0x802ee2
  80127f:	e8 60 f2 ff ff       	call   8004e4 <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.
	

    	envid_t envid = sys_getenvid();
  801284:	e8 9c fc ff ff       	call   800f25 <sys_getenvid>
  801289:	89 c6                	mov    %eax,%esi
    	// cprintf("pgfault: envid: %d\n", ENVX(envid));
    	// 临时页暂存
    	if ((r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P| PTE_W|PTE_U)) < 0)
  80128b:	83 ec 04             	sub    $0x4,%esp
  80128e:	6a 07                	push   $0x7
  801290:	68 00 f0 7f 00       	push   $0x7ff000
  801295:	50                   	push   %eax
  801296:	e8 c8 fc ff ff       	call   800f63 <sys_page_alloc>
  80129b:	83 c4 10             	add    $0x10,%esp
  80129e:	85 c0                	test   %eax,%eax
  8012a0:	79 12                	jns    8012b4 <pgfault+0x81>
        	panic("pgfault: page allocation fault:%e\n", r);
  8012a2:	50                   	push   %eax
  8012a3:	68 b0 2f 80 00       	push   $0x802fb0
  8012a8:	6a 2b                	push   $0x2b
  8012aa:	68 e2 2e 80 00       	push   $0x802ee2
  8012af:	e8 30 f2 ff ff       	call   8004e4 <_panic>
    	addr = ROUNDDOWN(addr, PGSIZE);
  8012b4:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  8012ba:	83 ec 04             	sub    $0x4,%esp
  8012bd:	68 00 10 00 00       	push   $0x1000
  8012c2:	53                   	push   %ebx
  8012c3:	68 00 f0 7f 00       	push   $0x7ff000
  8012c8:	e8 8d fa ff ff       	call   800d5a <memcpy>
    	if ((r = sys_page_map(envid, (void *) PFTEMP, envid, addr , PTE_P|PTE_W|PTE_U)) < 0 )
  8012cd:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  8012d4:	53                   	push   %ebx
  8012d5:	56                   	push   %esi
  8012d6:	68 00 f0 7f 00       	push   $0x7ff000
  8012db:	56                   	push   %esi
  8012dc:	e8 c5 fc ff ff       	call   800fa6 <sys_page_map>
  8012e1:	83 c4 20             	add    $0x20,%esp
  8012e4:	85 c0                	test   %eax,%eax
  8012e6:	79 12                	jns    8012fa <pgfault+0xc7>
        	panic("pgfault: page map failed %e\n", r);
  8012e8:	50                   	push   %eax
  8012e9:	68 14 2f 80 00       	push   $0x802f14
  8012ee:	6a 2f                	push   $0x2f
  8012f0:	68 e2 2e 80 00       	push   $0x802ee2
  8012f5:	e8 ea f1 ff ff       	call   8004e4 <_panic>
    
    	if ((r = sys_page_unmap(envid, (void *) PFTEMP)) < 0)
  8012fa:	83 ec 08             	sub    $0x8,%esp
  8012fd:	68 00 f0 7f 00       	push   $0x7ff000
  801302:	56                   	push   %esi
  801303:	e8 e0 fc ff ff       	call   800fe8 <sys_page_unmap>
  801308:	83 c4 10             	add    $0x10,%esp
  80130b:	85 c0                	test   %eax,%eax
  80130d:	79 12                	jns    801321 <pgfault+0xee>
        	panic("pgfault: page unmap failed %e\n", r);
  80130f:	50                   	push   %eax
  801310:	68 d4 2f 80 00       	push   $0x802fd4
  801315:	6a 32                	push   $0x32
  801317:	68 e2 2e 80 00       	push   $0x802ee2
  80131c:	e8 c3 f1 ff ff       	call   8004e4 <_panic>
	//panic("pgfault not implemented");
}
  801321:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801324:	5b                   	pop    %ebx
  801325:	5e                   	pop    %esi
  801326:	5d                   	pop    %ebp
  801327:	c3                   	ret    

00801328 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801328:	55                   	push   %ebp
  801329:	89 e5                	mov    %esp,%ebp
  80132b:	56                   	push   %esi
  80132c:	53                   	push   %ebx
  80132d:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	set_pgfault_handler(pgfault);
  801330:	68 33 12 80 00       	push   $0x801233
  801335:	e8 94 12 00 00       	call   8025ce <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80133a:	b8 07 00 00 00       	mov    $0x7,%eax
  80133f:	cd 30                	int    $0x30
  801341:	89 c3                	mov    %eax,%ebx

	envid_t envid = sys_exofork();
	uint8_t *addr;
	if (envid < 0)
  801343:	83 c4 10             	add    $0x10,%esp
  801346:	85 c0                	test   %eax,%eax
  801348:	79 12                	jns    80135c <fork+0x34>
		panic("sys_exofork:%e", envid);
  80134a:	50                   	push   %eax
  80134b:	68 31 2f 80 00       	push   $0x802f31
  801350:	6a 75                	push   $0x75
  801352:	68 e2 2e 80 00       	push   $0x802ee2
  801357:	e8 88 f1 ff ff       	call   8004e4 <_panic>
  80135c:	89 c6                	mov    %eax,%esi
	if (envid == 0) {
  80135e:	85 c0                	test   %eax,%eax
  801360:	75 21                	jne    801383 <fork+0x5b>
		thisenv = &envs[ENVX(sys_getenvid())];
  801362:	e8 be fb ff ff       	call   800f25 <sys_getenvid>
  801367:	25 ff 03 00 00       	and    $0x3ff,%eax
  80136c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80136f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801374:	a3 04 50 80 00       	mov    %eax,0x805004
		return 0;
  801379:	b8 00 00 00 00       	mov    $0x0,%eax
  80137e:	e9 c0 00 00 00       	jmp    801443 <fork+0x11b>
	}

	for (addr = (uint8_t *)UTEXT; addr < (uint8_t *)USTACKTOP-PGSIZE; addr += PGSIZE) {
  801383:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  80138a:	ba 00 00 80 00       	mov    $0x800000,%edx
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
  80138f:	89 d0                	mov    %edx,%eax
  801391:	c1 e8 16             	shr    $0x16,%eax
  801394:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80139b:	a8 01                	test   $0x1,%al
  80139d:	74 20                	je     8013bf <fork+0x97>
  80139f:	c1 ea 0c             	shr    $0xc,%edx
  8013a2:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8013a9:	a8 01                	test   $0x1,%al
  8013ab:	74 12                	je     8013bf <fork+0x97>
				&& (uvpt[PGNUM(addr)] & PTE_U)) {
  8013ad:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8013b4:	a8 04                	test   $0x4,%al
  8013b6:	74 07                	je     8013bf <fork+0x97>
			duppage(envid, PGNUM(addr));
  8013b8:	89 f0                	mov    %esi,%eax
  8013ba:	e8 95 fd ff ff       	call   801154 <duppage>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}

	for (addr = (uint8_t *)UTEXT; addr < (uint8_t *)USTACKTOP-PGSIZE; addr += PGSIZE) {
  8013bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013c2:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
  8013c8:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8013cb:	81 fa ff cf bf ee    	cmp    $0xeebfcfff,%edx
  8013d1:	76 bc                	jbe    80138f <fork+0x67>
				&& (uvpt[PGNUM(addr)] & PTE_U)) {
			duppage(envid, PGNUM(addr));
		}
	}

	duppage(envid, PGNUM(ROUNDDOWN(&addr, PGSIZE)));
  8013d3:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8013d6:	c1 ea 0c             	shr    $0xc,%edx
  8013d9:	89 d8                	mov    %ebx,%eax
  8013db:	e8 74 fd ff ff       	call   801154 <duppage>

	int r;
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)))
  8013e0:	83 ec 04             	sub    $0x4,%esp
  8013e3:	6a 07                	push   $0x7
  8013e5:	68 00 f0 bf ee       	push   $0xeebff000
  8013ea:	53                   	push   %ebx
  8013eb:	e8 73 fb ff ff       	call   800f63 <sys_page_alloc>
  8013f0:	83 c4 10             	add    $0x10,%esp
  8013f3:	85 c0                	test   %eax,%eax
  8013f5:	74 15                	je     80140c <fork+0xe4>
		panic("sys_page_alloc:%e", r);
  8013f7:	50                   	push   %eax
  8013f8:	68 40 2f 80 00       	push   $0x802f40
  8013fd:	68 86 00 00 00       	push   $0x86
  801402:	68 e2 2e 80 00       	push   $0x802ee2
  801407:	e8 d8 f0 ff ff       	call   8004e4 <_panic>

	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80140c:	83 ec 08             	sub    $0x8,%esp
  80140f:	68 36 26 80 00       	push   $0x802636
  801414:	53                   	push   %ebx
  801415:	e8 94 fc ff ff       	call   8010ae <sys_env_set_pgfault_upcall>

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)))
  80141a:	83 c4 08             	add    $0x8,%esp
  80141d:	6a 02                	push   $0x2
  80141f:	53                   	push   %ebx
  801420:	e8 05 fc ff ff       	call   80102a <sys_env_set_status>
  801425:	83 c4 10             	add    $0x10,%esp
  801428:	85 c0                	test   %eax,%eax
  80142a:	74 15                	je     801441 <fork+0x119>
		panic("sys_env_set_status:%e", r);
  80142c:	50                   	push   %eax
  80142d:	68 52 2f 80 00       	push   $0x802f52
  801432:	68 8c 00 00 00       	push   $0x8c
  801437:	68 e2 2e 80 00       	push   $0x802ee2
  80143c:	e8 a3 f0 ff ff       	call   8004e4 <_panic>

	return envid;
  801441:	89 d8                	mov    %ebx,%eax
	    
}
  801443:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801446:	5b                   	pop    %ebx
  801447:	5e                   	pop    %esi
  801448:	5d                   	pop    %ebp
  801449:	c3                   	ret    

0080144a <sfork>:

// Challenge!
int
sfork(void)
{
  80144a:	55                   	push   %ebp
  80144b:	89 e5                	mov    %esp,%ebp
  80144d:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801450:	68 68 2f 80 00       	push   $0x802f68
  801455:	68 96 00 00 00       	push   $0x96
  80145a:	68 e2 2e 80 00       	push   $0x802ee2
  80145f:	e8 80 f0 ff ff       	call   8004e4 <_panic>

00801464 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801464:	55                   	push   %ebp
  801465:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801467:	8b 45 08             	mov    0x8(%ebp),%eax
  80146a:	05 00 00 00 30       	add    $0x30000000,%eax
  80146f:	c1 e8 0c             	shr    $0xc,%eax
}
  801472:	5d                   	pop    %ebp
  801473:	c3                   	ret    

00801474 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801474:	55                   	push   %ebp
  801475:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801477:	8b 45 08             	mov    0x8(%ebp),%eax
  80147a:	05 00 00 00 30       	add    $0x30000000,%eax
  80147f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801484:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801489:	5d                   	pop    %ebp
  80148a:	c3                   	ret    

0080148b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80148b:	55                   	push   %ebp
  80148c:	89 e5                	mov    %esp,%ebp
  80148e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801491:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801496:	89 c2                	mov    %eax,%edx
  801498:	c1 ea 16             	shr    $0x16,%edx
  80149b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014a2:	f6 c2 01             	test   $0x1,%dl
  8014a5:	74 11                	je     8014b8 <fd_alloc+0x2d>
  8014a7:	89 c2                	mov    %eax,%edx
  8014a9:	c1 ea 0c             	shr    $0xc,%edx
  8014ac:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014b3:	f6 c2 01             	test   $0x1,%dl
  8014b6:	75 09                	jne    8014c1 <fd_alloc+0x36>
			*fd_store = fd;
  8014b8:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8014bf:	eb 17                	jmp    8014d8 <fd_alloc+0x4d>
  8014c1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8014c6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8014cb:	75 c9                	jne    801496 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8014cd:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8014d3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8014d8:	5d                   	pop    %ebp
  8014d9:	c3                   	ret    

008014da <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8014da:	55                   	push   %ebp
  8014db:	89 e5                	mov    %esp,%ebp
  8014dd:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8014e0:	83 f8 1f             	cmp    $0x1f,%eax
  8014e3:	77 36                	ja     80151b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8014e5:	c1 e0 0c             	shl    $0xc,%eax
  8014e8:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8014ed:	89 c2                	mov    %eax,%edx
  8014ef:	c1 ea 16             	shr    $0x16,%edx
  8014f2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014f9:	f6 c2 01             	test   $0x1,%dl
  8014fc:	74 24                	je     801522 <fd_lookup+0x48>
  8014fe:	89 c2                	mov    %eax,%edx
  801500:	c1 ea 0c             	shr    $0xc,%edx
  801503:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80150a:	f6 c2 01             	test   $0x1,%dl
  80150d:	74 1a                	je     801529 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80150f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801512:	89 02                	mov    %eax,(%edx)
	return 0;
  801514:	b8 00 00 00 00       	mov    $0x0,%eax
  801519:	eb 13                	jmp    80152e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80151b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801520:	eb 0c                	jmp    80152e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801522:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801527:	eb 05                	jmp    80152e <fd_lookup+0x54>
  801529:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80152e:	5d                   	pop    %ebp
  80152f:	c3                   	ret    

00801530 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801530:	55                   	push   %ebp
  801531:	89 e5                	mov    %esp,%ebp
  801533:	83 ec 08             	sub    $0x8,%esp
  801536:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801539:	ba 70 30 80 00       	mov    $0x803070,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80153e:	eb 13                	jmp    801553 <dev_lookup+0x23>
  801540:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801543:	39 08                	cmp    %ecx,(%eax)
  801545:	75 0c                	jne    801553 <dev_lookup+0x23>
			*dev = devtab[i];
  801547:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80154a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80154c:	b8 00 00 00 00       	mov    $0x0,%eax
  801551:	eb 2e                	jmp    801581 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801553:	8b 02                	mov    (%edx),%eax
  801555:	85 c0                	test   %eax,%eax
  801557:	75 e7                	jne    801540 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801559:	a1 04 50 80 00       	mov    0x805004,%eax
  80155e:	8b 40 48             	mov    0x48(%eax),%eax
  801561:	83 ec 04             	sub    $0x4,%esp
  801564:	51                   	push   %ecx
  801565:	50                   	push   %eax
  801566:	68 f4 2f 80 00       	push   $0x802ff4
  80156b:	e8 4d f0 ff ff       	call   8005bd <cprintf>
	*dev = 0;
  801570:	8b 45 0c             	mov    0xc(%ebp),%eax
  801573:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801579:	83 c4 10             	add    $0x10,%esp
  80157c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801581:	c9                   	leave  
  801582:	c3                   	ret    

00801583 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801583:	55                   	push   %ebp
  801584:	89 e5                	mov    %esp,%ebp
  801586:	56                   	push   %esi
  801587:	53                   	push   %ebx
  801588:	83 ec 10             	sub    $0x10,%esp
  80158b:	8b 75 08             	mov    0x8(%ebp),%esi
  80158e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801591:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801594:	50                   	push   %eax
  801595:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80159b:	c1 e8 0c             	shr    $0xc,%eax
  80159e:	50                   	push   %eax
  80159f:	e8 36 ff ff ff       	call   8014da <fd_lookup>
  8015a4:	83 c4 08             	add    $0x8,%esp
  8015a7:	85 c0                	test   %eax,%eax
  8015a9:	78 05                	js     8015b0 <fd_close+0x2d>
	    || fd != fd2)
  8015ab:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8015ae:	74 0c                	je     8015bc <fd_close+0x39>
		return (must_exist ? r : 0);
  8015b0:	84 db                	test   %bl,%bl
  8015b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8015b7:	0f 44 c2             	cmove  %edx,%eax
  8015ba:	eb 41                	jmp    8015fd <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8015bc:	83 ec 08             	sub    $0x8,%esp
  8015bf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015c2:	50                   	push   %eax
  8015c3:	ff 36                	pushl  (%esi)
  8015c5:	e8 66 ff ff ff       	call   801530 <dev_lookup>
  8015ca:	89 c3                	mov    %eax,%ebx
  8015cc:	83 c4 10             	add    $0x10,%esp
  8015cf:	85 c0                	test   %eax,%eax
  8015d1:	78 1a                	js     8015ed <fd_close+0x6a>
		if (dev->dev_close)
  8015d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015d6:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8015d9:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8015de:	85 c0                	test   %eax,%eax
  8015e0:	74 0b                	je     8015ed <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8015e2:	83 ec 0c             	sub    $0xc,%esp
  8015e5:	56                   	push   %esi
  8015e6:	ff d0                	call   *%eax
  8015e8:	89 c3                	mov    %eax,%ebx
  8015ea:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8015ed:	83 ec 08             	sub    $0x8,%esp
  8015f0:	56                   	push   %esi
  8015f1:	6a 00                	push   $0x0
  8015f3:	e8 f0 f9 ff ff       	call   800fe8 <sys_page_unmap>
	return r;
  8015f8:	83 c4 10             	add    $0x10,%esp
  8015fb:	89 d8                	mov    %ebx,%eax
}
  8015fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801600:	5b                   	pop    %ebx
  801601:	5e                   	pop    %esi
  801602:	5d                   	pop    %ebp
  801603:	c3                   	ret    

00801604 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801604:	55                   	push   %ebp
  801605:	89 e5                	mov    %esp,%ebp
  801607:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80160a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80160d:	50                   	push   %eax
  80160e:	ff 75 08             	pushl  0x8(%ebp)
  801611:	e8 c4 fe ff ff       	call   8014da <fd_lookup>
  801616:	83 c4 08             	add    $0x8,%esp
  801619:	85 c0                	test   %eax,%eax
  80161b:	78 10                	js     80162d <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80161d:	83 ec 08             	sub    $0x8,%esp
  801620:	6a 01                	push   $0x1
  801622:	ff 75 f4             	pushl  -0xc(%ebp)
  801625:	e8 59 ff ff ff       	call   801583 <fd_close>
  80162a:	83 c4 10             	add    $0x10,%esp
}
  80162d:	c9                   	leave  
  80162e:	c3                   	ret    

0080162f <close_all>:

void
close_all(void)
{
  80162f:	55                   	push   %ebp
  801630:	89 e5                	mov    %esp,%ebp
  801632:	53                   	push   %ebx
  801633:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801636:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80163b:	83 ec 0c             	sub    $0xc,%esp
  80163e:	53                   	push   %ebx
  80163f:	e8 c0 ff ff ff       	call   801604 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801644:	83 c3 01             	add    $0x1,%ebx
  801647:	83 c4 10             	add    $0x10,%esp
  80164a:	83 fb 20             	cmp    $0x20,%ebx
  80164d:	75 ec                	jne    80163b <close_all+0xc>
		close(i);
}
  80164f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801652:	c9                   	leave  
  801653:	c3                   	ret    

00801654 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801654:	55                   	push   %ebp
  801655:	89 e5                	mov    %esp,%ebp
  801657:	57                   	push   %edi
  801658:	56                   	push   %esi
  801659:	53                   	push   %ebx
  80165a:	83 ec 2c             	sub    $0x2c,%esp
  80165d:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801660:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801663:	50                   	push   %eax
  801664:	ff 75 08             	pushl  0x8(%ebp)
  801667:	e8 6e fe ff ff       	call   8014da <fd_lookup>
  80166c:	83 c4 08             	add    $0x8,%esp
  80166f:	85 c0                	test   %eax,%eax
  801671:	0f 88 c1 00 00 00    	js     801738 <dup+0xe4>
		return r;
	close(newfdnum);
  801677:	83 ec 0c             	sub    $0xc,%esp
  80167a:	56                   	push   %esi
  80167b:	e8 84 ff ff ff       	call   801604 <close>

	newfd = INDEX2FD(newfdnum);
  801680:	89 f3                	mov    %esi,%ebx
  801682:	c1 e3 0c             	shl    $0xc,%ebx
  801685:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80168b:	83 c4 04             	add    $0x4,%esp
  80168e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801691:	e8 de fd ff ff       	call   801474 <fd2data>
  801696:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801698:	89 1c 24             	mov    %ebx,(%esp)
  80169b:	e8 d4 fd ff ff       	call   801474 <fd2data>
  8016a0:	83 c4 10             	add    $0x10,%esp
  8016a3:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8016a6:	89 f8                	mov    %edi,%eax
  8016a8:	c1 e8 16             	shr    $0x16,%eax
  8016ab:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8016b2:	a8 01                	test   $0x1,%al
  8016b4:	74 37                	je     8016ed <dup+0x99>
  8016b6:	89 f8                	mov    %edi,%eax
  8016b8:	c1 e8 0c             	shr    $0xc,%eax
  8016bb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8016c2:	f6 c2 01             	test   $0x1,%dl
  8016c5:	74 26                	je     8016ed <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8016c7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016ce:	83 ec 0c             	sub    $0xc,%esp
  8016d1:	25 07 0e 00 00       	and    $0xe07,%eax
  8016d6:	50                   	push   %eax
  8016d7:	ff 75 d4             	pushl  -0x2c(%ebp)
  8016da:	6a 00                	push   $0x0
  8016dc:	57                   	push   %edi
  8016dd:	6a 00                	push   $0x0
  8016df:	e8 c2 f8 ff ff       	call   800fa6 <sys_page_map>
  8016e4:	89 c7                	mov    %eax,%edi
  8016e6:	83 c4 20             	add    $0x20,%esp
  8016e9:	85 c0                	test   %eax,%eax
  8016eb:	78 2e                	js     80171b <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016ed:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8016f0:	89 d0                	mov    %edx,%eax
  8016f2:	c1 e8 0c             	shr    $0xc,%eax
  8016f5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016fc:	83 ec 0c             	sub    $0xc,%esp
  8016ff:	25 07 0e 00 00       	and    $0xe07,%eax
  801704:	50                   	push   %eax
  801705:	53                   	push   %ebx
  801706:	6a 00                	push   $0x0
  801708:	52                   	push   %edx
  801709:	6a 00                	push   $0x0
  80170b:	e8 96 f8 ff ff       	call   800fa6 <sys_page_map>
  801710:	89 c7                	mov    %eax,%edi
  801712:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801715:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801717:	85 ff                	test   %edi,%edi
  801719:	79 1d                	jns    801738 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80171b:	83 ec 08             	sub    $0x8,%esp
  80171e:	53                   	push   %ebx
  80171f:	6a 00                	push   $0x0
  801721:	e8 c2 f8 ff ff       	call   800fe8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801726:	83 c4 08             	add    $0x8,%esp
  801729:	ff 75 d4             	pushl  -0x2c(%ebp)
  80172c:	6a 00                	push   $0x0
  80172e:	e8 b5 f8 ff ff       	call   800fe8 <sys_page_unmap>
	return r;
  801733:	83 c4 10             	add    $0x10,%esp
  801736:	89 f8                	mov    %edi,%eax
}
  801738:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80173b:	5b                   	pop    %ebx
  80173c:	5e                   	pop    %esi
  80173d:	5f                   	pop    %edi
  80173e:	5d                   	pop    %ebp
  80173f:	c3                   	ret    

00801740 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801740:	55                   	push   %ebp
  801741:	89 e5                	mov    %esp,%ebp
  801743:	53                   	push   %ebx
  801744:	83 ec 14             	sub    $0x14,%esp
  801747:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80174a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80174d:	50                   	push   %eax
  80174e:	53                   	push   %ebx
  80174f:	e8 86 fd ff ff       	call   8014da <fd_lookup>
  801754:	83 c4 08             	add    $0x8,%esp
  801757:	89 c2                	mov    %eax,%edx
  801759:	85 c0                	test   %eax,%eax
  80175b:	78 6d                	js     8017ca <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80175d:	83 ec 08             	sub    $0x8,%esp
  801760:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801763:	50                   	push   %eax
  801764:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801767:	ff 30                	pushl  (%eax)
  801769:	e8 c2 fd ff ff       	call   801530 <dev_lookup>
  80176e:	83 c4 10             	add    $0x10,%esp
  801771:	85 c0                	test   %eax,%eax
  801773:	78 4c                	js     8017c1 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801775:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801778:	8b 42 08             	mov    0x8(%edx),%eax
  80177b:	83 e0 03             	and    $0x3,%eax
  80177e:	83 f8 01             	cmp    $0x1,%eax
  801781:	75 21                	jne    8017a4 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801783:	a1 04 50 80 00       	mov    0x805004,%eax
  801788:	8b 40 48             	mov    0x48(%eax),%eax
  80178b:	83 ec 04             	sub    $0x4,%esp
  80178e:	53                   	push   %ebx
  80178f:	50                   	push   %eax
  801790:	68 35 30 80 00       	push   $0x803035
  801795:	e8 23 ee ff ff       	call   8005bd <cprintf>
		return -E_INVAL;
  80179a:	83 c4 10             	add    $0x10,%esp
  80179d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017a2:	eb 26                	jmp    8017ca <read+0x8a>
	}
	if (!dev->dev_read)
  8017a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017a7:	8b 40 08             	mov    0x8(%eax),%eax
  8017aa:	85 c0                	test   %eax,%eax
  8017ac:	74 17                	je     8017c5 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8017ae:	83 ec 04             	sub    $0x4,%esp
  8017b1:	ff 75 10             	pushl  0x10(%ebp)
  8017b4:	ff 75 0c             	pushl  0xc(%ebp)
  8017b7:	52                   	push   %edx
  8017b8:	ff d0                	call   *%eax
  8017ba:	89 c2                	mov    %eax,%edx
  8017bc:	83 c4 10             	add    $0x10,%esp
  8017bf:	eb 09                	jmp    8017ca <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017c1:	89 c2                	mov    %eax,%edx
  8017c3:	eb 05                	jmp    8017ca <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8017c5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8017ca:	89 d0                	mov    %edx,%eax
  8017cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017cf:	c9                   	leave  
  8017d0:	c3                   	ret    

008017d1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8017d1:	55                   	push   %ebp
  8017d2:	89 e5                	mov    %esp,%ebp
  8017d4:	57                   	push   %edi
  8017d5:	56                   	push   %esi
  8017d6:	53                   	push   %ebx
  8017d7:	83 ec 0c             	sub    $0xc,%esp
  8017da:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017dd:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017e0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017e5:	eb 21                	jmp    801808 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8017e7:	83 ec 04             	sub    $0x4,%esp
  8017ea:	89 f0                	mov    %esi,%eax
  8017ec:	29 d8                	sub    %ebx,%eax
  8017ee:	50                   	push   %eax
  8017ef:	89 d8                	mov    %ebx,%eax
  8017f1:	03 45 0c             	add    0xc(%ebp),%eax
  8017f4:	50                   	push   %eax
  8017f5:	57                   	push   %edi
  8017f6:	e8 45 ff ff ff       	call   801740 <read>
		if (m < 0)
  8017fb:	83 c4 10             	add    $0x10,%esp
  8017fe:	85 c0                	test   %eax,%eax
  801800:	78 10                	js     801812 <readn+0x41>
			return m;
		if (m == 0)
  801802:	85 c0                	test   %eax,%eax
  801804:	74 0a                	je     801810 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801806:	01 c3                	add    %eax,%ebx
  801808:	39 f3                	cmp    %esi,%ebx
  80180a:	72 db                	jb     8017e7 <readn+0x16>
  80180c:	89 d8                	mov    %ebx,%eax
  80180e:	eb 02                	jmp    801812 <readn+0x41>
  801810:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801812:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801815:	5b                   	pop    %ebx
  801816:	5e                   	pop    %esi
  801817:	5f                   	pop    %edi
  801818:	5d                   	pop    %ebp
  801819:	c3                   	ret    

0080181a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80181a:	55                   	push   %ebp
  80181b:	89 e5                	mov    %esp,%ebp
  80181d:	53                   	push   %ebx
  80181e:	83 ec 14             	sub    $0x14,%esp
  801821:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801824:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801827:	50                   	push   %eax
  801828:	53                   	push   %ebx
  801829:	e8 ac fc ff ff       	call   8014da <fd_lookup>
  80182e:	83 c4 08             	add    $0x8,%esp
  801831:	89 c2                	mov    %eax,%edx
  801833:	85 c0                	test   %eax,%eax
  801835:	78 68                	js     80189f <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801837:	83 ec 08             	sub    $0x8,%esp
  80183a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80183d:	50                   	push   %eax
  80183e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801841:	ff 30                	pushl  (%eax)
  801843:	e8 e8 fc ff ff       	call   801530 <dev_lookup>
  801848:	83 c4 10             	add    $0x10,%esp
  80184b:	85 c0                	test   %eax,%eax
  80184d:	78 47                	js     801896 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80184f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801852:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801856:	75 21                	jne    801879 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801858:	a1 04 50 80 00       	mov    0x805004,%eax
  80185d:	8b 40 48             	mov    0x48(%eax),%eax
  801860:	83 ec 04             	sub    $0x4,%esp
  801863:	53                   	push   %ebx
  801864:	50                   	push   %eax
  801865:	68 51 30 80 00       	push   $0x803051
  80186a:	e8 4e ed ff ff       	call   8005bd <cprintf>
		return -E_INVAL;
  80186f:	83 c4 10             	add    $0x10,%esp
  801872:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801877:	eb 26                	jmp    80189f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801879:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80187c:	8b 52 0c             	mov    0xc(%edx),%edx
  80187f:	85 d2                	test   %edx,%edx
  801881:	74 17                	je     80189a <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801883:	83 ec 04             	sub    $0x4,%esp
  801886:	ff 75 10             	pushl  0x10(%ebp)
  801889:	ff 75 0c             	pushl  0xc(%ebp)
  80188c:	50                   	push   %eax
  80188d:	ff d2                	call   *%edx
  80188f:	89 c2                	mov    %eax,%edx
  801891:	83 c4 10             	add    $0x10,%esp
  801894:	eb 09                	jmp    80189f <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801896:	89 c2                	mov    %eax,%edx
  801898:	eb 05                	jmp    80189f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80189a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80189f:	89 d0                	mov    %edx,%eax
  8018a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018a4:	c9                   	leave  
  8018a5:	c3                   	ret    

008018a6 <seek>:

int
seek(int fdnum, off_t offset)
{
  8018a6:	55                   	push   %ebp
  8018a7:	89 e5                	mov    %esp,%ebp
  8018a9:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018ac:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8018af:	50                   	push   %eax
  8018b0:	ff 75 08             	pushl  0x8(%ebp)
  8018b3:	e8 22 fc ff ff       	call   8014da <fd_lookup>
  8018b8:	83 c4 08             	add    $0x8,%esp
  8018bb:	85 c0                	test   %eax,%eax
  8018bd:	78 0e                	js     8018cd <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8018bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8018c2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018c5:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8018c8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018cd:	c9                   	leave  
  8018ce:	c3                   	ret    

008018cf <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8018cf:	55                   	push   %ebp
  8018d0:	89 e5                	mov    %esp,%ebp
  8018d2:	53                   	push   %ebx
  8018d3:	83 ec 14             	sub    $0x14,%esp
  8018d6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018d9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018dc:	50                   	push   %eax
  8018dd:	53                   	push   %ebx
  8018de:	e8 f7 fb ff ff       	call   8014da <fd_lookup>
  8018e3:	83 c4 08             	add    $0x8,%esp
  8018e6:	89 c2                	mov    %eax,%edx
  8018e8:	85 c0                	test   %eax,%eax
  8018ea:	78 65                	js     801951 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018ec:	83 ec 08             	sub    $0x8,%esp
  8018ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018f2:	50                   	push   %eax
  8018f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018f6:	ff 30                	pushl  (%eax)
  8018f8:	e8 33 fc ff ff       	call   801530 <dev_lookup>
  8018fd:	83 c4 10             	add    $0x10,%esp
  801900:	85 c0                	test   %eax,%eax
  801902:	78 44                	js     801948 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801904:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801907:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80190b:	75 21                	jne    80192e <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80190d:	a1 04 50 80 00       	mov    0x805004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801912:	8b 40 48             	mov    0x48(%eax),%eax
  801915:	83 ec 04             	sub    $0x4,%esp
  801918:	53                   	push   %ebx
  801919:	50                   	push   %eax
  80191a:	68 14 30 80 00       	push   $0x803014
  80191f:	e8 99 ec ff ff       	call   8005bd <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801924:	83 c4 10             	add    $0x10,%esp
  801927:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80192c:	eb 23                	jmp    801951 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80192e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801931:	8b 52 18             	mov    0x18(%edx),%edx
  801934:	85 d2                	test   %edx,%edx
  801936:	74 14                	je     80194c <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801938:	83 ec 08             	sub    $0x8,%esp
  80193b:	ff 75 0c             	pushl  0xc(%ebp)
  80193e:	50                   	push   %eax
  80193f:	ff d2                	call   *%edx
  801941:	89 c2                	mov    %eax,%edx
  801943:	83 c4 10             	add    $0x10,%esp
  801946:	eb 09                	jmp    801951 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801948:	89 c2                	mov    %eax,%edx
  80194a:	eb 05                	jmp    801951 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80194c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801951:	89 d0                	mov    %edx,%eax
  801953:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801956:	c9                   	leave  
  801957:	c3                   	ret    

00801958 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801958:	55                   	push   %ebp
  801959:	89 e5                	mov    %esp,%ebp
  80195b:	53                   	push   %ebx
  80195c:	83 ec 14             	sub    $0x14,%esp
  80195f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801962:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801965:	50                   	push   %eax
  801966:	ff 75 08             	pushl  0x8(%ebp)
  801969:	e8 6c fb ff ff       	call   8014da <fd_lookup>
  80196e:	83 c4 08             	add    $0x8,%esp
  801971:	89 c2                	mov    %eax,%edx
  801973:	85 c0                	test   %eax,%eax
  801975:	78 58                	js     8019cf <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801977:	83 ec 08             	sub    $0x8,%esp
  80197a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80197d:	50                   	push   %eax
  80197e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801981:	ff 30                	pushl  (%eax)
  801983:	e8 a8 fb ff ff       	call   801530 <dev_lookup>
  801988:	83 c4 10             	add    $0x10,%esp
  80198b:	85 c0                	test   %eax,%eax
  80198d:	78 37                	js     8019c6 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80198f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801992:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801996:	74 32                	je     8019ca <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801998:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80199b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8019a2:	00 00 00 
	stat->st_isdir = 0;
  8019a5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019ac:	00 00 00 
	stat->st_dev = dev;
  8019af:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8019b5:	83 ec 08             	sub    $0x8,%esp
  8019b8:	53                   	push   %ebx
  8019b9:	ff 75 f0             	pushl  -0x10(%ebp)
  8019bc:	ff 50 14             	call   *0x14(%eax)
  8019bf:	89 c2                	mov    %eax,%edx
  8019c1:	83 c4 10             	add    $0x10,%esp
  8019c4:	eb 09                	jmp    8019cf <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019c6:	89 c2                	mov    %eax,%edx
  8019c8:	eb 05                	jmp    8019cf <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8019ca:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8019cf:	89 d0                	mov    %edx,%eax
  8019d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019d4:	c9                   	leave  
  8019d5:	c3                   	ret    

008019d6 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8019d6:	55                   	push   %ebp
  8019d7:	89 e5                	mov    %esp,%ebp
  8019d9:	56                   	push   %esi
  8019da:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8019db:	83 ec 08             	sub    $0x8,%esp
  8019de:	6a 00                	push   $0x0
  8019e0:	ff 75 08             	pushl  0x8(%ebp)
  8019e3:	e8 e3 01 00 00       	call   801bcb <open>
  8019e8:	89 c3                	mov    %eax,%ebx
  8019ea:	83 c4 10             	add    $0x10,%esp
  8019ed:	85 c0                	test   %eax,%eax
  8019ef:	78 1b                	js     801a0c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8019f1:	83 ec 08             	sub    $0x8,%esp
  8019f4:	ff 75 0c             	pushl  0xc(%ebp)
  8019f7:	50                   	push   %eax
  8019f8:	e8 5b ff ff ff       	call   801958 <fstat>
  8019fd:	89 c6                	mov    %eax,%esi
	close(fd);
  8019ff:	89 1c 24             	mov    %ebx,(%esp)
  801a02:	e8 fd fb ff ff       	call   801604 <close>
	return r;
  801a07:	83 c4 10             	add    $0x10,%esp
  801a0a:	89 f0                	mov    %esi,%eax
}
  801a0c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a0f:	5b                   	pop    %ebx
  801a10:	5e                   	pop    %esi
  801a11:	5d                   	pop    %ebp
  801a12:	c3                   	ret    

00801a13 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a13:	55                   	push   %ebp
  801a14:	89 e5                	mov    %esp,%ebp
  801a16:	56                   	push   %esi
  801a17:	53                   	push   %ebx
  801a18:	89 c6                	mov    %eax,%esi
  801a1a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801a1c:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801a23:	75 12                	jne    801a37 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a25:	83 ec 0c             	sub    $0xc,%esp
  801a28:	6a 01                	push   $0x1
  801a2a:	e8 d4 0c 00 00       	call   802703 <ipc_find_env>
  801a2f:	a3 00 50 80 00       	mov    %eax,0x805000
  801a34:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a37:	6a 07                	push   $0x7
  801a39:	68 00 60 80 00       	push   $0x806000
  801a3e:	56                   	push   %esi
  801a3f:	ff 35 00 50 80 00    	pushl  0x805000
  801a45:	e8 65 0c 00 00       	call   8026af <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a4a:	83 c4 0c             	add    $0xc,%esp
  801a4d:	6a 00                	push   $0x0
  801a4f:	53                   	push   %ebx
  801a50:	6a 00                	push   $0x0
  801a52:	e8 03 0c 00 00       	call   80265a <ipc_recv>
}
  801a57:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a5a:	5b                   	pop    %ebx
  801a5b:	5e                   	pop    %esi
  801a5c:	5d                   	pop    %ebp
  801a5d:	c3                   	ret    

00801a5e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a5e:	55                   	push   %ebp
  801a5f:	89 e5                	mov    %esp,%ebp
  801a61:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a64:	8b 45 08             	mov    0x8(%ebp),%eax
  801a67:	8b 40 0c             	mov    0xc(%eax),%eax
  801a6a:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801a6f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a72:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a77:	ba 00 00 00 00       	mov    $0x0,%edx
  801a7c:	b8 02 00 00 00       	mov    $0x2,%eax
  801a81:	e8 8d ff ff ff       	call   801a13 <fsipc>
}
  801a86:	c9                   	leave  
  801a87:	c3                   	ret    

00801a88 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a88:	55                   	push   %ebp
  801a89:	89 e5                	mov    %esp,%ebp
  801a8b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a8e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a91:	8b 40 0c             	mov    0xc(%eax),%eax
  801a94:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801a99:	ba 00 00 00 00       	mov    $0x0,%edx
  801a9e:	b8 06 00 00 00       	mov    $0x6,%eax
  801aa3:	e8 6b ff ff ff       	call   801a13 <fsipc>
}
  801aa8:	c9                   	leave  
  801aa9:	c3                   	ret    

00801aaa <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801aaa:	55                   	push   %ebp
  801aab:	89 e5                	mov    %esp,%ebp
  801aad:	53                   	push   %ebx
  801aae:	83 ec 04             	sub    $0x4,%esp
  801ab1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801ab4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab7:	8b 40 0c             	mov    0xc(%eax),%eax
  801aba:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801abf:	ba 00 00 00 00       	mov    $0x0,%edx
  801ac4:	b8 05 00 00 00       	mov    $0x5,%eax
  801ac9:	e8 45 ff ff ff       	call   801a13 <fsipc>
  801ace:	85 c0                	test   %eax,%eax
  801ad0:	78 2c                	js     801afe <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801ad2:	83 ec 08             	sub    $0x8,%esp
  801ad5:	68 00 60 80 00       	push   $0x806000
  801ada:	53                   	push   %ebx
  801adb:	e8 80 f0 ff ff       	call   800b60 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801ae0:	a1 80 60 80 00       	mov    0x806080,%eax
  801ae5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801aeb:	a1 84 60 80 00       	mov    0x806084,%eax
  801af0:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801af6:	83 c4 10             	add    $0x10,%esp
  801af9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801afe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b01:	c9                   	leave  
  801b02:	c3                   	ret    

00801b03 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801b03:	55                   	push   %ebp
  801b04:	89 e5                	mov    %esp,%ebp
  801b06:	83 ec 0c             	sub    $0xc,%esp
  801b09:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
    
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  801b0c:	8b 55 08             	mov    0x8(%ebp),%edx
  801b0f:	8b 52 0c             	mov    0xc(%edx),%edx
  801b12:	89 15 00 60 80 00    	mov    %edx,0x806000
    fsipcbuf.write.req_n = MIN(n, PGSIZE);
  801b18:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b1d:	ba 00 10 00 00       	mov    $0x1000,%edx
  801b22:	0f 47 c2             	cmova  %edx,%eax
  801b25:	a3 04 60 80 00       	mov    %eax,0x806004
    memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801b2a:	50                   	push   %eax
  801b2b:	ff 75 0c             	pushl  0xc(%ebp)
  801b2e:	68 08 60 80 00       	push   $0x806008
  801b33:	e8 ba f1 ff ff       	call   800cf2 <memmove>
    int r = fsipc(FSREQ_WRITE, NULL);
  801b38:	ba 00 00 00 00       	mov    $0x0,%edx
  801b3d:	b8 04 00 00 00       	mov    $0x4,%eax
  801b42:	e8 cc fe ff ff       	call   801a13 <fsipc>
    return r;
}
  801b47:	c9                   	leave  
  801b48:	c3                   	ret    

00801b49 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801b49:	55                   	push   %ebp
  801b4a:	89 e5                	mov    %esp,%ebp
  801b4c:	56                   	push   %esi
  801b4d:	53                   	push   %ebx
  801b4e:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b51:	8b 45 08             	mov    0x8(%ebp),%eax
  801b54:	8b 40 0c             	mov    0xc(%eax),%eax
  801b57:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801b5c:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b62:	ba 00 00 00 00       	mov    $0x0,%edx
  801b67:	b8 03 00 00 00       	mov    $0x3,%eax
  801b6c:	e8 a2 fe ff ff       	call   801a13 <fsipc>
  801b71:	89 c3                	mov    %eax,%ebx
  801b73:	85 c0                	test   %eax,%eax
  801b75:	78 4b                	js     801bc2 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801b77:	39 c6                	cmp    %eax,%esi
  801b79:	73 16                	jae    801b91 <devfile_read+0x48>
  801b7b:	68 80 30 80 00       	push   $0x803080
  801b80:	68 87 30 80 00       	push   $0x803087
  801b85:	6a 7c                	push   $0x7c
  801b87:	68 9c 30 80 00       	push   $0x80309c
  801b8c:	e8 53 e9 ff ff       	call   8004e4 <_panic>
	assert(r <= PGSIZE);
  801b91:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b96:	7e 16                	jle    801bae <devfile_read+0x65>
  801b98:	68 a7 30 80 00       	push   $0x8030a7
  801b9d:	68 87 30 80 00       	push   $0x803087
  801ba2:	6a 7d                	push   $0x7d
  801ba4:	68 9c 30 80 00       	push   $0x80309c
  801ba9:	e8 36 e9 ff ff       	call   8004e4 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801bae:	83 ec 04             	sub    $0x4,%esp
  801bb1:	50                   	push   %eax
  801bb2:	68 00 60 80 00       	push   $0x806000
  801bb7:	ff 75 0c             	pushl  0xc(%ebp)
  801bba:	e8 33 f1 ff ff       	call   800cf2 <memmove>
	return r;
  801bbf:	83 c4 10             	add    $0x10,%esp
}
  801bc2:	89 d8                	mov    %ebx,%eax
  801bc4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bc7:	5b                   	pop    %ebx
  801bc8:	5e                   	pop    %esi
  801bc9:	5d                   	pop    %ebp
  801bca:	c3                   	ret    

00801bcb <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801bcb:	55                   	push   %ebp
  801bcc:	89 e5                	mov    %esp,%ebp
  801bce:	53                   	push   %ebx
  801bcf:	83 ec 20             	sub    $0x20,%esp
  801bd2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801bd5:	53                   	push   %ebx
  801bd6:	e8 4c ef ff ff       	call   800b27 <strlen>
  801bdb:	83 c4 10             	add    $0x10,%esp
  801bde:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801be3:	7f 67                	jg     801c4c <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801be5:	83 ec 0c             	sub    $0xc,%esp
  801be8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801beb:	50                   	push   %eax
  801bec:	e8 9a f8 ff ff       	call   80148b <fd_alloc>
  801bf1:	83 c4 10             	add    $0x10,%esp
		return r;
  801bf4:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801bf6:	85 c0                	test   %eax,%eax
  801bf8:	78 57                	js     801c51 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801bfa:	83 ec 08             	sub    $0x8,%esp
  801bfd:	53                   	push   %ebx
  801bfe:	68 00 60 80 00       	push   $0x806000
  801c03:	e8 58 ef ff ff       	call   800b60 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801c08:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c0b:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c10:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c13:	b8 01 00 00 00       	mov    $0x1,%eax
  801c18:	e8 f6 fd ff ff       	call   801a13 <fsipc>
  801c1d:	89 c3                	mov    %eax,%ebx
  801c1f:	83 c4 10             	add    $0x10,%esp
  801c22:	85 c0                	test   %eax,%eax
  801c24:	79 14                	jns    801c3a <open+0x6f>
		fd_close(fd, 0);
  801c26:	83 ec 08             	sub    $0x8,%esp
  801c29:	6a 00                	push   $0x0
  801c2b:	ff 75 f4             	pushl  -0xc(%ebp)
  801c2e:	e8 50 f9 ff ff       	call   801583 <fd_close>
		return r;
  801c33:	83 c4 10             	add    $0x10,%esp
  801c36:	89 da                	mov    %ebx,%edx
  801c38:	eb 17                	jmp    801c51 <open+0x86>
	}

	return fd2num(fd);
  801c3a:	83 ec 0c             	sub    $0xc,%esp
  801c3d:	ff 75 f4             	pushl  -0xc(%ebp)
  801c40:	e8 1f f8 ff ff       	call   801464 <fd2num>
  801c45:	89 c2                	mov    %eax,%edx
  801c47:	83 c4 10             	add    $0x10,%esp
  801c4a:	eb 05                	jmp    801c51 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c4c:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801c51:	89 d0                	mov    %edx,%eax
  801c53:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c56:	c9                   	leave  
  801c57:	c3                   	ret    

00801c58 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c58:	55                   	push   %ebp
  801c59:	89 e5                	mov    %esp,%ebp
  801c5b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c5e:	ba 00 00 00 00       	mov    $0x0,%edx
  801c63:	b8 08 00 00 00       	mov    $0x8,%eax
  801c68:	e8 a6 fd ff ff       	call   801a13 <fsipc>
}
  801c6d:	c9                   	leave  
  801c6e:	c3                   	ret    

00801c6f <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801c6f:	55                   	push   %ebp
  801c70:	89 e5                	mov    %esp,%ebp
  801c72:	57                   	push   %edi
  801c73:	56                   	push   %esi
  801c74:	53                   	push   %ebx
  801c75:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801c7b:	6a 00                	push   $0x0
  801c7d:	ff 75 08             	pushl  0x8(%ebp)
  801c80:	e8 46 ff ff ff       	call   801bcb <open>
  801c85:	89 c7                	mov    %eax,%edi
  801c87:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801c8d:	83 c4 10             	add    $0x10,%esp
  801c90:	85 c0                	test   %eax,%eax
  801c92:	0f 88 ae 04 00 00    	js     802146 <spawn+0x4d7>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801c98:	83 ec 04             	sub    $0x4,%esp
  801c9b:	68 00 02 00 00       	push   $0x200
  801ca0:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801ca6:	50                   	push   %eax
  801ca7:	57                   	push   %edi
  801ca8:	e8 24 fb ff ff       	call   8017d1 <readn>
  801cad:	83 c4 10             	add    $0x10,%esp
  801cb0:	3d 00 02 00 00       	cmp    $0x200,%eax
  801cb5:	75 0c                	jne    801cc3 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  801cb7:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801cbe:	45 4c 46 
  801cc1:	74 33                	je     801cf6 <spawn+0x87>
		close(fd);
  801cc3:	83 ec 0c             	sub    $0xc,%esp
  801cc6:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801ccc:	e8 33 f9 ff ff       	call   801604 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801cd1:	83 c4 0c             	add    $0xc,%esp
  801cd4:	68 7f 45 4c 46       	push   $0x464c457f
  801cd9:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801cdf:	68 b3 30 80 00       	push   $0x8030b3
  801ce4:	e8 d4 e8 ff ff       	call   8005bd <cprintf>
		return -E_NOT_EXEC;
  801ce9:	83 c4 10             	add    $0x10,%esp
  801cec:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801cf1:	e9 b0 04 00 00       	jmp    8021a6 <spawn+0x537>
  801cf6:	b8 07 00 00 00       	mov    $0x7,%eax
  801cfb:	cd 30                	int    $0x30
  801cfd:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801d03:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801d09:	85 c0                	test   %eax,%eax
  801d0b:	0f 88 3d 04 00 00    	js     80214e <spawn+0x4df>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801d11:	89 c6                	mov    %eax,%esi
  801d13:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801d19:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801d1c:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801d22:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801d28:	b9 11 00 00 00       	mov    $0x11,%ecx
  801d2d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801d2f:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801d35:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801d3b:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801d40:	be 00 00 00 00       	mov    $0x0,%esi
  801d45:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801d48:	eb 13                	jmp    801d5d <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801d4a:	83 ec 0c             	sub    $0xc,%esp
  801d4d:	50                   	push   %eax
  801d4e:	e8 d4 ed ff ff       	call   800b27 <strlen>
  801d53:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801d57:	83 c3 01             	add    $0x1,%ebx
  801d5a:	83 c4 10             	add    $0x10,%esp
  801d5d:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801d64:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801d67:	85 c0                	test   %eax,%eax
  801d69:	75 df                	jne    801d4a <spawn+0xdb>
  801d6b:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801d71:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801d77:	bf 00 10 40 00       	mov    $0x401000,%edi
  801d7c:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801d7e:	89 fa                	mov    %edi,%edx
  801d80:	83 e2 fc             	and    $0xfffffffc,%edx
  801d83:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801d8a:	29 c2                	sub    %eax,%edx
  801d8c:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801d92:	8d 42 f8             	lea    -0x8(%edx),%eax
  801d95:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801d9a:	0f 86 be 03 00 00    	jbe    80215e <spawn+0x4ef>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801da0:	83 ec 04             	sub    $0x4,%esp
  801da3:	6a 07                	push   $0x7
  801da5:	68 00 00 40 00       	push   $0x400000
  801daa:	6a 00                	push   $0x0
  801dac:	e8 b2 f1 ff ff       	call   800f63 <sys_page_alloc>
  801db1:	83 c4 10             	add    $0x10,%esp
  801db4:	85 c0                	test   %eax,%eax
  801db6:	0f 88 a9 03 00 00    	js     802165 <spawn+0x4f6>
  801dbc:	be 00 00 00 00       	mov    $0x0,%esi
  801dc1:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801dc7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801dca:	eb 30                	jmp    801dfc <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801dcc:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801dd2:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801dd8:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801ddb:	83 ec 08             	sub    $0x8,%esp
  801dde:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801de1:	57                   	push   %edi
  801de2:	e8 79 ed ff ff       	call   800b60 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801de7:	83 c4 04             	add    $0x4,%esp
  801dea:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801ded:	e8 35 ed ff ff       	call   800b27 <strlen>
  801df2:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801df6:	83 c6 01             	add    $0x1,%esi
  801df9:	83 c4 10             	add    $0x10,%esp
  801dfc:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801e02:	7f c8                	jg     801dcc <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801e04:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801e0a:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801e10:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801e17:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801e1d:	74 19                	je     801e38 <spawn+0x1c9>
  801e1f:	68 28 31 80 00       	push   $0x803128
  801e24:	68 87 30 80 00       	push   $0x803087
  801e29:	68 f2 00 00 00       	push   $0xf2
  801e2e:	68 cd 30 80 00       	push   $0x8030cd
  801e33:	e8 ac e6 ff ff       	call   8004e4 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801e38:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801e3e:	89 f8                	mov    %edi,%eax
  801e40:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801e45:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801e48:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801e4e:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801e51:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801e57:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801e5d:	83 ec 0c             	sub    $0xc,%esp
  801e60:	6a 07                	push   $0x7
  801e62:	68 00 d0 bf ee       	push   $0xeebfd000
  801e67:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e6d:	68 00 00 40 00       	push   $0x400000
  801e72:	6a 00                	push   $0x0
  801e74:	e8 2d f1 ff ff       	call   800fa6 <sys_page_map>
  801e79:	89 c3                	mov    %eax,%ebx
  801e7b:	83 c4 20             	add    $0x20,%esp
  801e7e:	85 c0                	test   %eax,%eax
  801e80:	0f 88 0e 03 00 00    	js     802194 <spawn+0x525>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801e86:	83 ec 08             	sub    $0x8,%esp
  801e89:	68 00 00 40 00       	push   $0x400000
  801e8e:	6a 00                	push   $0x0
  801e90:	e8 53 f1 ff ff       	call   800fe8 <sys_page_unmap>
  801e95:	89 c3                	mov    %eax,%ebx
  801e97:	83 c4 10             	add    $0x10,%esp
  801e9a:	85 c0                	test   %eax,%eax
  801e9c:	0f 88 f2 02 00 00    	js     802194 <spawn+0x525>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801ea2:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801ea8:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801eaf:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801eb5:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801ebc:	00 00 00 
  801ebf:	e9 88 01 00 00       	jmp    80204c <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  801ec4:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801eca:	83 38 01             	cmpl   $0x1,(%eax)
  801ecd:	0f 85 6b 01 00 00    	jne    80203e <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801ed3:	89 c7                	mov    %eax,%edi
  801ed5:	8b 40 18             	mov    0x18(%eax),%eax
  801ed8:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801ede:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801ee1:	83 f8 01             	cmp    $0x1,%eax
  801ee4:	19 c0                	sbb    %eax,%eax
  801ee6:	83 e0 fe             	and    $0xfffffffe,%eax
  801ee9:	83 c0 07             	add    $0x7,%eax
  801eec:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801ef2:	89 f8                	mov    %edi,%eax
  801ef4:	8b 7f 04             	mov    0x4(%edi),%edi
  801ef7:	89 f9                	mov    %edi,%ecx
  801ef9:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801eff:	8b 78 10             	mov    0x10(%eax),%edi
  801f02:	8b 50 14             	mov    0x14(%eax),%edx
  801f05:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  801f0b:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801f0e:	89 f0                	mov    %esi,%eax
  801f10:	25 ff 0f 00 00       	and    $0xfff,%eax
  801f15:	74 14                	je     801f2b <spawn+0x2bc>
		va -= i;
  801f17:	29 c6                	sub    %eax,%esi
		memsz += i;
  801f19:	01 c2                	add    %eax,%edx
  801f1b:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  801f21:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801f23:	29 c1                	sub    %eax,%ecx
  801f25:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801f2b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f30:	e9 f7 00 00 00       	jmp    80202c <spawn+0x3bd>
		if (i >= filesz) {
  801f35:	39 df                	cmp    %ebx,%edi
  801f37:	77 27                	ja     801f60 <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801f39:	83 ec 04             	sub    $0x4,%esp
  801f3c:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801f42:	56                   	push   %esi
  801f43:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801f49:	e8 15 f0 ff ff       	call   800f63 <sys_page_alloc>
  801f4e:	83 c4 10             	add    $0x10,%esp
  801f51:	85 c0                	test   %eax,%eax
  801f53:	0f 89 c7 00 00 00    	jns    802020 <spawn+0x3b1>
  801f59:	89 c3                	mov    %eax,%ebx
  801f5b:	e9 13 02 00 00       	jmp    802173 <spawn+0x504>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801f60:	83 ec 04             	sub    $0x4,%esp
  801f63:	6a 07                	push   $0x7
  801f65:	68 00 00 40 00       	push   $0x400000
  801f6a:	6a 00                	push   $0x0
  801f6c:	e8 f2 ef ff ff       	call   800f63 <sys_page_alloc>
  801f71:	83 c4 10             	add    $0x10,%esp
  801f74:	85 c0                	test   %eax,%eax
  801f76:	0f 88 ed 01 00 00    	js     802169 <spawn+0x4fa>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801f7c:	83 ec 08             	sub    $0x8,%esp
  801f7f:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801f85:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801f8b:	50                   	push   %eax
  801f8c:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801f92:	e8 0f f9 ff ff       	call   8018a6 <seek>
  801f97:	83 c4 10             	add    $0x10,%esp
  801f9a:	85 c0                	test   %eax,%eax
  801f9c:	0f 88 cb 01 00 00    	js     80216d <spawn+0x4fe>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801fa2:	83 ec 04             	sub    $0x4,%esp
  801fa5:	89 f8                	mov    %edi,%eax
  801fa7:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801fad:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801fb2:	ba 00 10 00 00       	mov    $0x1000,%edx
  801fb7:	0f 47 c2             	cmova  %edx,%eax
  801fba:	50                   	push   %eax
  801fbb:	68 00 00 40 00       	push   $0x400000
  801fc0:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801fc6:	e8 06 f8 ff ff       	call   8017d1 <readn>
  801fcb:	83 c4 10             	add    $0x10,%esp
  801fce:	85 c0                	test   %eax,%eax
  801fd0:	0f 88 9b 01 00 00    	js     802171 <spawn+0x502>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801fd6:	83 ec 0c             	sub    $0xc,%esp
  801fd9:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801fdf:	56                   	push   %esi
  801fe0:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801fe6:	68 00 00 40 00       	push   $0x400000
  801feb:	6a 00                	push   $0x0
  801fed:	e8 b4 ef ff ff       	call   800fa6 <sys_page_map>
  801ff2:	83 c4 20             	add    $0x20,%esp
  801ff5:	85 c0                	test   %eax,%eax
  801ff7:	79 15                	jns    80200e <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  801ff9:	50                   	push   %eax
  801ffa:	68 d9 30 80 00       	push   $0x8030d9
  801fff:	68 25 01 00 00       	push   $0x125
  802004:	68 cd 30 80 00       	push   $0x8030cd
  802009:	e8 d6 e4 ff ff       	call   8004e4 <_panic>
			sys_page_unmap(0, UTEMP);
  80200e:	83 ec 08             	sub    $0x8,%esp
  802011:	68 00 00 40 00       	push   $0x400000
  802016:	6a 00                	push   $0x0
  802018:	e8 cb ef ff ff       	call   800fe8 <sys_page_unmap>
  80201d:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  802020:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802026:	81 c6 00 10 00 00    	add    $0x1000,%esi
  80202c:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  802032:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  802038:	0f 87 f7 fe ff ff    	ja     801f35 <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80203e:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  802045:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  80204c:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  802053:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  802059:	0f 8c 65 fe ff ff    	jl     801ec4 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  80205f:	83 ec 0c             	sub    $0xc,%esp
  802062:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802068:	e8 97 f5 ff ff       	call   801604 <close>
  80206d:	83 c4 10             	add    $0x10,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
   	uintptr_t addr;
	for (addr = 0; addr < UTOP; addr += PGSIZE) {
  802070:	bb 00 00 00 00       	mov    $0x0,%ebx
  802075:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) &&(uvpt[PGNUM(addr)] & PTE_U) && (uvpt[PGNUM(addr)] & PTE_SHARE)) {
  80207b:	89 d8                	mov    %ebx,%eax
  80207d:	c1 e8 16             	shr    $0x16,%eax
  802080:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802087:	a8 01                	test   $0x1,%al
  802089:	74 46                	je     8020d1 <spawn+0x462>
  80208b:	89 d8                	mov    %ebx,%eax
  80208d:	c1 e8 0c             	shr    $0xc,%eax
  802090:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802097:	f6 c2 01             	test   $0x1,%dl
  80209a:	74 35                	je     8020d1 <spawn+0x462>
  80209c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8020a3:	f6 c2 04             	test   $0x4,%dl
  8020a6:	74 29                	je     8020d1 <spawn+0x462>
  8020a8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8020af:	f6 c6 04             	test   $0x4,%dh
  8020b2:	74 1d                	je     8020d1 <spawn+0x462>
			// cprintf("copy shared page %d to env:%x\n", PGNUM(addr), child);
            		sys_page_map(0, (void*)addr, child, (void*)addr, (uvpt[PGNUM(addr)] & PTE_SYSCALL));
  8020b4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8020bb:	83 ec 0c             	sub    $0xc,%esp
  8020be:	25 07 0e 00 00       	and    $0xe07,%eax
  8020c3:	50                   	push   %eax
  8020c4:	53                   	push   %ebx
  8020c5:	56                   	push   %esi
  8020c6:	53                   	push   %ebx
  8020c7:	6a 00                	push   $0x0
  8020c9:	e8 d8 ee ff ff       	call   800fa6 <sys_page_map>
  8020ce:	83 c4 20             	add    $0x20,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
   	uintptr_t addr;
	for (addr = 0; addr < UTOP; addr += PGSIZE) {
  8020d1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8020d7:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  8020dd:	75 9c                	jne    80207b <spawn+0x40c>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  8020df:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  8020e6:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  8020e9:	83 ec 08             	sub    $0x8,%esp
  8020ec:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  8020f2:	50                   	push   %eax
  8020f3:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8020f9:	e8 6e ef ff ff       	call   80106c <sys_env_set_trapframe>
  8020fe:	83 c4 10             	add    $0x10,%esp
  802101:	85 c0                	test   %eax,%eax
  802103:	79 15                	jns    80211a <spawn+0x4ab>
		panic("sys_env_set_trapframe: %e", r);
  802105:	50                   	push   %eax
  802106:	68 f6 30 80 00       	push   $0x8030f6
  80210b:	68 86 00 00 00       	push   $0x86
  802110:	68 cd 30 80 00       	push   $0x8030cd
  802115:	e8 ca e3 ff ff       	call   8004e4 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  80211a:	83 ec 08             	sub    $0x8,%esp
  80211d:	6a 02                	push   $0x2
  80211f:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802125:	e8 00 ef ff ff       	call   80102a <sys_env_set_status>
  80212a:	83 c4 10             	add    $0x10,%esp
  80212d:	85 c0                	test   %eax,%eax
  80212f:	79 25                	jns    802156 <spawn+0x4e7>
		panic("sys_env_set_status: %e", r);
  802131:	50                   	push   %eax
  802132:	68 10 31 80 00       	push   $0x803110
  802137:	68 89 00 00 00       	push   $0x89
  80213c:	68 cd 30 80 00       	push   $0x8030cd
  802141:	e8 9e e3 ff ff       	call   8004e4 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  802146:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  80214c:	eb 58                	jmp    8021a6 <spawn+0x537>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  80214e:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  802154:	eb 50                	jmp    8021a6 <spawn+0x537>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  802156:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  80215c:	eb 48                	jmp    8021a6 <spawn+0x537>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  80215e:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  802163:	eb 41                	jmp    8021a6 <spawn+0x537>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  802165:	89 c3                	mov    %eax,%ebx
  802167:	eb 3d                	jmp    8021a6 <spawn+0x537>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802169:	89 c3                	mov    %eax,%ebx
  80216b:	eb 06                	jmp    802173 <spawn+0x504>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  80216d:	89 c3                	mov    %eax,%ebx
  80216f:	eb 02                	jmp    802173 <spawn+0x504>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802171:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  802173:	83 ec 0c             	sub    $0xc,%esp
  802176:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80217c:	e8 63 ed ff ff       	call   800ee4 <sys_env_destroy>
	close(fd);
  802181:	83 c4 04             	add    $0x4,%esp
  802184:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80218a:	e8 75 f4 ff ff       	call   801604 <close>
	return r;
  80218f:	83 c4 10             	add    $0x10,%esp
  802192:	eb 12                	jmp    8021a6 <spawn+0x537>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  802194:	83 ec 08             	sub    $0x8,%esp
  802197:	68 00 00 40 00       	push   $0x400000
  80219c:	6a 00                	push   $0x0
  80219e:	e8 45 ee ff ff       	call   800fe8 <sys_page_unmap>
  8021a3:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  8021a6:	89 d8                	mov    %ebx,%eax
  8021a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021ab:	5b                   	pop    %ebx
  8021ac:	5e                   	pop    %esi
  8021ad:	5f                   	pop    %edi
  8021ae:	5d                   	pop    %ebp
  8021af:	c3                   	ret    

008021b0 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  8021b0:	55                   	push   %ebp
  8021b1:	89 e5                	mov    %esp,%ebp
  8021b3:	56                   	push   %esi
  8021b4:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8021b5:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  8021b8:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8021bd:	eb 03                	jmp    8021c2 <spawnl+0x12>
		argc++;
  8021bf:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8021c2:	83 c2 04             	add    $0x4,%edx
  8021c5:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  8021c9:	75 f4                	jne    8021bf <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  8021cb:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  8021d2:	83 e2 f0             	and    $0xfffffff0,%edx
  8021d5:	29 d4                	sub    %edx,%esp
  8021d7:	8d 54 24 03          	lea    0x3(%esp),%edx
  8021db:	c1 ea 02             	shr    $0x2,%edx
  8021de:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  8021e5:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  8021e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8021ea:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  8021f1:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  8021f8:	00 
  8021f9:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  8021fb:	b8 00 00 00 00       	mov    $0x0,%eax
  802200:	eb 0a                	jmp    80220c <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  802202:	83 c0 01             	add    $0x1,%eax
  802205:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  802209:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  80220c:	39 d0                	cmp    %edx,%eax
  80220e:	75 f2                	jne    802202 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802210:	83 ec 08             	sub    $0x8,%esp
  802213:	56                   	push   %esi
  802214:	ff 75 08             	pushl  0x8(%ebp)
  802217:	e8 53 fa ff ff       	call   801c6f <spawn>
}
  80221c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80221f:	5b                   	pop    %ebx
  802220:	5e                   	pop    %esi
  802221:	5d                   	pop    %ebp
  802222:	c3                   	ret    

00802223 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802223:	55                   	push   %ebp
  802224:	89 e5                	mov    %esp,%ebp
  802226:	56                   	push   %esi
  802227:	53                   	push   %ebx
  802228:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80222b:	83 ec 0c             	sub    $0xc,%esp
  80222e:	ff 75 08             	pushl  0x8(%ebp)
  802231:	e8 3e f2 ff ff       	call   801474 <fd2data>
  802236:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802238:	83 c4 08             	add    $0x8,%esp
  80223b:	68 4e 31 80 00       	push   $0x80314e
  802240:	53                   	push   %ebx
  802241:	e8 1a e9 ff ff       	call   800b60 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802246:	8b 46 04             	mov    0x4(%esi),%eax
  802249:	2b 06                	sub    (%esi),%eax
  80224b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802251:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802258:	00 00 00 
	stat->st_dev = &devpipe;
  80225b:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  802262:	40 80 00 
	return 0;
}
  802265:	b8 00 00 00 00       	mov    $0x0,%eax
  80226a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80226d:	5b                   	pop    %ebx
  80226e:	5e                   	pop    %esi
  80226f:	5d                   	pop    %ebp
  802270:	c3                   	ret    

00802271 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802271:	55                   	push   %ebp
  802272:	89 e5                	mov    %esp,%ebp
  802274:	53                   	push   %ebx
  802275:	83 ec 0c             	sub    $0xc,%esp
  802278:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80227b:	53                   	push   %ebx
  80227c:	6a 00                	push   $0x0
  80227e:	e8 65 ed ff ff       	call   800fe8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802283:	89 1c 24             	mov    %ebx,(%esp)
  802286:	e8 e9 f1 ff ff       	call   801474 <fd2data>
  80228b:	83 c4 08             	add    $0x8,%esp
  80228e:	50                   	push   %eax
  80228f:	6a 00                	push   $0x0
  802291:	e8 52 ed ff ff       	call   800fe8 <sys_page_unmap>
}
  802296:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802299:	c9                   	leave  
  80229a:	c3                   	ret    

0080229b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80229b:	55                   	push   %ebp
  80229c:	89 e5                	mov    %esp,%ebp
  80229e:	57                   	push   %edi
  80229f:	56                   	push   %esi
  8022a0:	53                   	push   %ebx
  8022a1:	83 ec 1c             	sub    $0x1c,%esp
  8022a4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8022a7:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8022a9:	a1 04 50 80 00       	mov    0x805004,%eax
  8022ae:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8022b1:	83 ec 0c             	sub    $0xc,%esp
  8022b4:	ff 75 e0             	pushl  -0x20(%ebp)
  8022b7:	e8 80 04 00 00       	call   80273c <pageref>
  8022bc:	89 c3                	mov    %eax,%ebx
  8022be:	89 3c 24             	mov    %edi,(%esp)
  8022c1:	e8 76 04 00 00       	call   80273c <pageref>
  8022c6:	83 c4 10             	add    $0x10,%esp
  8022c9:	39 c3                	cmp    %eax,%ebx
  8022cb:	0f 94 c1             	sete   %cl
  8022ce:	0f b6 c9             	movzbl %cl,%ecx
  8022d1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8022d4:	8b 15 04 50 80 00    	mov    0x805004,%edx
  8022da:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8022dd:	39 ce                	cmp    %ecx,%esi
  8022df:	74 1b                	je     8022fc <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8022e1:	39 c3                	cmp    %eax,%ebx
  8022e3:	75 c4                	jne    8022a9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8022e5:	8b 42 58             	mov    0x58(%edx),%eax
  8022e8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8022eb:	50                   	push   %eax
  8022ec:	56                   	push   %esi
  8022ed:	68 55 31 80 00       	push   $0x803155
  8022f2:	e8 c6 e2 ff ff       	call   8005bd <cprintf>
  8022f7:	83 c4 10             	add    $0x10,%esp
  8022fa:	eb ad                	jmp    8022a9 <_pipeisclosed+0xe>
	}
}
  8022fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8022ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802302:	5b                   	pop    %ebx
  802303:	5e                   	pop    %esi
  802304:	5f                   	pop    %edi
  802305:	5d                   	pop    %ebp
  802306:	c3                   	ret    

00802307 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802307:	55                   	push   %ebp
  802308:	89 e5                	mov    %esp,%ebp
  80230a:	57                   	push   %edi
  80230b:	56                   	push   %esi
  80230c:	53                   	push   %ebx
  80230d:	83 ec 28             	sub    $0x28,%esp
  802310:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802313:	56                   	push   %esi
  802314:	e8 5b f1 ff ff       	call   801474 <fd2data>
  802319:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80231b:	83 c4 10             	add    $0x10,%esp
  80231e:	bf 00 00 00 00       	mov    $0x0,%edi
  802323:	eb 4b                	jmp    802370 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802325:	89 da                	mov    %ebx,%edx
  802327:	89 f0                	mov    %esi,%eax
  802329:	e8 6d ff ff ff       	call   80229b <_pipeisclosed>
  80232e:	85 c0                	test   %eax,%eax
  802330:	75 48                	jne    80237a <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802332:	e8 0d ec ff ff       	call   800f44 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802337:	8b 43 04             	mov    0x4(%ebx),%eax
  80233a:	8b 0b                	mov    (%ebx),%ecx
  80233c:	8d 51 20             	lea    0x20(%ecx),%edx
  80233f:	39 d0                	cmp    %edx,%eax
  802341:	73 e2                	jae    802325 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802343:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802346:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80234a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80234d:	89 c2                	mov    %eax,%edx
  80234f:	c1 fa 1f             	sar    $0x1f,%edx
  802352:	89 d1                	mov    %edx,%ecx
  802354:	c1 e9 1b             	shr    $0x1b,%ecx
  802357:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80235a:	83 e2 1f             	and    $0x1f,%edx
  80235d:	29 ca                	sub    %ecx,%edx
  80235f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802363:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802367:	83 c0 01             	add    $0x1,%eax
  80236a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80236d:	83 c7 01             	add    $0x1,%edi
  802370:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802373:	75 c2                	jne    802337 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802375:	8b 45 10             	mov    0x10(%ebp),%eax
  802378:	eb 05                	jmp    80237f <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80237a:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80237f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802382:	5b                   	pop    %ebx
  802383:	5e                   	pop    %esi
  802384:	5f                   	pop    %edi
  802385:	5d                   	pop    %ebp
  802386:	c3                   	ret    

00802387 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802387:	55                   	push   %ebp
  802388:	89 e5                	mov    %esp,%ebp
  80238a:	57                   	push   %edi
  80238b:	56                   	push   %esi
  80238c:	53                   	push   %ebx
  80238d:	83 ec 18             	sub    $0x18,%esp
  802390:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802393:	57                   	push   %edi
  802394:	e8 db f0 ff ff       	call   801474 <fd2data>
  802399:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80239b:	83 c4 10             	add    $0x10,%esp
  80239e:	bb 00 00 00 00       	mov    $0x0,%ebx
  8023a3:	eb 3d                	jmp    8023e2 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8023a5:	85 db                	test   %ebx,%ebx
  8023a7:	74 04                	je     8023ad <devpipe_read+0x26>
				return i;
  8023a9:	89 d8                	mov    %ebx,%eax
  8023ab:	eb 44                	jmp    8023f1 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8023ad:	89 f2                	mov    %esi,%edx
  8023af:	89 f8                	mov    %edi,%eax
  8023b1:	e8 e5 fe ff ff       	call   80229b <_pipeisclosed>
  8023b6:	85 c0                	test   %eax,%eax
  8023b8:	75 32                	jne    8023ec <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8023ba:	e8 85 eb ff ff       	call   800f44 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8023bf:	8b 06                	mov    (%esi),%eax
  8023c1:	3b 46 04             	cmp    0x4(%esi),%eax
  8023c4:	74 df                	je     8023a5 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8023c6:	99                   	cltd   
  8023c7:	c1 ea 1b             	shr    $0x1b,%edx
  8023ca:	01 d0                	add    %edx,%eax
  8023cc:	83 e0 1f             	and    $0x1f,%eax
  8023cf:	29 d0                	sub    %edx,%eax
  8023d1:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8023d6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8023d9:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8023dc:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8023df:	83 c3 01             	add    $0x1,%ebx
  8023e2:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8023e5:	75 d8                	jne    8023bf <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8023e7:	8b 45 10             	mov    0x10(%ebp),%eax
  8023ea:	eb 05                	jmp    8023f1 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8023ec:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8023f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023f4:	5b                   	pop    %ebx
  8023f5:	5e                   	pop    %esi
  8023f6:	5f                   	pop    %edi
  8023f7:	5d                   	pop    %ebp
  8023f8:	c3                   	ret    

008023f9 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8023f9:	55                   	push   %ebp
  8023fa:	89 e5                	mov    %esp,%ebp
  8023fc:	56                   	push   %esi
  8023fd:	53                   	push   %ebx
  8023fe:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802401:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802404:	50                   	push   %eax
  802405:	e8 81 f0 ff ff       	call   80148b <fd_alloc>
  80240a:	83 c4 10             	add    $0x10,%esp
  80240d:	89 c2                	mov    %eax,%edx
  80240f:	85 c0                	test   %eax,%eax
  802411:	0f 88 2c 01 00 00    	js     802543 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802417:	83 ec 04             	sub    $0x4,%esp
  80241a:	68 07 04 00 00       	push   $0x407
  80241f:	ff 75 f4             	pushl  -0xc(%ebp)
  802422:	6a 00                	push   $0x0
  802424:	e8 3a eb ff ff       	call   800f63 <sys_page_alloc>
  802429:	83 c4 10             	add    $0x10,%esp
  80242c:	89 c2                	mov    %eax,%edx
  80242e:	85 c0                	test   %eax,%eax
  802430:	0f 88 0d 01 00 00    	js     802543 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802436:	83 ec 0c             	sub    $0xc,%esp
  802439:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80243c:	50                   	push   %eax
  80243d:	e8 49 f0 ff ff       	call   80148b <fd_alloc>
  802442:	89 c3                	mov    %eax,%ebx
  802444:	83 c4 10             	add    $0x10,%esp
  802447:	85 c0                	test   %eax,%eax
  802449:	0f 88 e2 00 00 00    	js     802531 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80244f:	83 ec 04             	sub    $0x4,%esp
  802452:	68 07 04 00 00       	push   $0x407
  802457:	ff 75 f0             	pushl  -0x10(%ebp)
  80245a:	6a 00                	push   $0x0
  80245c:	e8 02 eb ff ff       	call   800f63 <sys_page_alloc>
  802461:	89 c3                	mov    %eax,%ebx
  802463:	83 c4 10             	add    $0x10,%esp
  802466:	85 c0                	test   %eax,%eax
  802468:	0f 88 c3 00 00 00    	js     802531 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80246e:	83 ec 0c             	sub    $0xc,%esp
  802471:	ff 75 f4             	pushl  -0xc(%ebp)
  802474:	e8 fb ef ff ff       	call   801474 <fd2data>
  802479:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80247b:	83 c4 0c             	add    $0xc,%esp
  80247e:	68 07 04 00 00       	push   $0x407
  802483:	50                   	push   %eax
  802484:	6a 00                	push   $0x0
  802486:	e8 d8 ea ff ff       	call   800f63 <sys_page_alloc>
  80248b:	89 c3                	mov    %eax,%ebx
  80248d:	83 c4 10             	add    $0x10,%esp
  802490:	85 c0                	test   %eax,%eax
  802492:	0f 88 89 00 00 00    	js     802521 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802498:	83 ec 0c             	sub    $0xc,%esp
  80249b:	ff 75 f0             	pushl  -0x10(%ebp)
  80249e:	e8 d1 ef ff ff       	call   801474 <fd2data>
  8024a3:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8024aa:	50                   	push   %eax
  8024ab:	6a 00                	push   $0x0
  8024ad:	56                   	push   %esi
  8024ae:	6a 00                	push   $0x0
  8024b0:	e8 f1 ea ff ff       	call   800fa6 <sys_page_map>
  8024b5:	89 c3                	mov    %eax,%ebx
  8024b7:	83 c4 20             	add    $0x20,%esp
  8024ba:	85 c0                	test   %eax,%eax
  8024bc:	78 55                	js     802513 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8024be:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  8024c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024c7:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8024c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024cc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8024d3:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  8024d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8024dc:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8024de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8024e1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8024e8:	83 ec 0c             	sub    $0xc,%esp
  8024eb:	ff 75 f4             	pushl  -0xc(%ebp)
  8024ee:	e8 71 ef ff ff       	call   801464 <fd2num>
  8024f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8024f6:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8024f8:	83 c4 04             	add    $0x4,%esp
  8024fb:	ff 75 f0             	pushl  -0x10(%ebp)
  8024fe:	e8 61 ef ff ff       	call   801464 <fd2num>
  802503:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802506:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802509:	83 c4 10             	add    $0x10,%esp
  80250c:	ba 00 00 00 00       	mov    $0x0,%edx
  802511:	eb 30                	jmp    802543 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802513:	83 ec 08             	sub    $0x8,%esp
  802516:	56                   	push   %esi
  802517:	6a 00                	push   $0x0
  802519:	e8 ca ea ff ff       	call   800fe8 <sys_page_unmap>
  80251e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802521:	83 ec 08             	sub    $0x8,%esp
  802524:	ff 75 f0             	pushl  -0x10(%ebp)
  802527:	6a 00                	push   $0x0
  802529:	e8 ba ea ff ff       	call   800fe8 <sys_page_unmap>
  80252e:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802531:	83 ec 08             	sub    $0x8,%esp
  802534:	ff 75 f4             	pushl  -0xc(%ebp)
  802537:	6a 00                	push   $0x0
  802539:	e8 aa ea ff ff       	call   800fe8 <sys_page_unmap>
  80253e:	83 c4 10             	add    $0x10,%esp
  802541:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802543:	89 d0                	mov    %edx,%eax
  802545:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802548:	5b                   	pop    %ebx
  802549:	5e                   	pop    %esi
  80254a:	5d                   	pop    %ebp
  80254b:	c3                   	ret    

0080254c <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80254c:	55                   	push   %ebp
  80254d:	89 e5                	mov    %esp,%ebp
  80254f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802552:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802555:	50                   	push   %eax
  802556:	ff 75 08             	pushl  0x8(%ebp)
  802559:	e8 7c ef ff ff       	call   8014da <fd_lookup>
  80255e:	83 c4 10             	add    $0x10,%esp
  802561:	85 c0                	test   %eax,%eax
  802563:	78 18                	js     80257d <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802565:	83 ec 0c             	sub    $0xc,%esp
  802568:	ff 75 f4             	pushl  -0xc(%ebp)
  80256b:	e8 04 ef ff ff       	call   801474 <fd2data>
	return _pipeisclosed(fd, p);
  802570:	89 c2                	mov    %eax,%edx
  802572:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802575:	e8 21 fd ff ff       	call   80229b <_pipeisclosed>
  80257a:	83 c4 10             	add    $0x10,%esp
}
  80257d:	c9                   	leave  
  80257e:	c3                   	ret    

0080257f <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  80257f:	55                   	push   %ebp
  802580:	89 e5                	mov    %esp,%ebp
  802582:	56                   	push   %esi
  802583:	53                   	push   %ebx
  802584:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802587:	85 f6                	test   %esi,%esi
  802589:	75 16                	jne    8025a1 <wait+0x22>
  80258b:	68 6d 31 80 00       	push   $0x80316d
  802590:	68 87 30 80 00       	push   $0x803087
  802595:	6a 09                	push   $0x9
  802597:	68 78 31 80 00       	push   $0x803178
  80259c:	e8 43 df ff ff       	call   8004e4 <_panic>
	e = &envs[ENVX(envid)];
  8025a1:	89 f3                	mov    %esi,%ebx
  8025a3:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8025a9:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  8025ac:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  8025b2:	eb 05                	jmp    8025b9 <wait+0x3a>
		sys_yield();
  8025b4:	e8 8b e9 ff ff       	call   800f44 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8025b9:	8b 43 48             	mov    0x48(%ebx),%eax
  8025bc:	39 c6                	cmp    %eax,%esi
  8025be:	75 07                	jne    8025c7 <wait+0x48>
  8025c0:	8b 43 54             	mov    0x54(%ebx),%eax
  8025c3:	85 c0                	test   %eax,%eax
  8025c5:	75 ed                	jne    8025b4 <wait+0x35>
		sys_yield();
}
  8025c7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8025ca:	5b                   	pop    %ebx
  8025cb:	5e                   	pop    %esi
  8025cc:	5d                   	pop    %ebp
  8025cd:	c3                   	ret    

008025ce <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8025ce:	55                   	push   %ebp
  8025cf:	89 e5                	mov    %esp,%ebp
  8025d1:	83 ec 08             	sub    $0x8,%esp
	int r;
	int ret;
	if (_pgfault_handler == 0) {
  8025d4:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8025db:	75 36                	jne    802613 <set_pgfault_handler+0x45>
		// First time through!
		// LAB 4: Your code here.
        
        	ret = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  8025dd:	a1 04 50 80 00       	mov    0x805004,%eax
  8025e2:	8b 40 48             	mov    0x48(%eax),%eax
  8025e5:	83 ec 04             	sub    $0x4,%esp
  8025e8:	68 07 0e 00 00       	push   $0xe07
  8025ed:	68 00 f0 bf ee       	push   $0xeebff000
  8025f2:	50                   	push   %eax
  8025f3:	e8 6b e9 ff ff       	call   800f63 <sys_page_alloc>
		if (ret < 0) {
  8025f8:	83 c4 10             	add    $0x10,%esp
  8025fb:	85 c0                	test   %eax,%eax
  8025fd:	79 14                	jns    802613 <set_pgfault_handler+0x45>
		    panic("Allocate user exception stack failed!\n");
  8025ff:	83 ec 04             	sub    $0x4,%esp
  802602:	68 84 31 80 00       	push   $0x803184
  802607:	6a 23                	push   $0x23
  802609:	68 ac 31 80 00       	push   $0x8031ac
  80260e:	e8 d1 de ff ff       	call   8004e4 <_panic>
		}
	}
	sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  802613:	a1 04 50 80 00       	mov    0x805004,%eax
  802618:	8b 40 48             	mov    0x48(%eax),%eax
  80261b:	83 ec 08             	sub    $0x8,%esp
  80261e:	68 36 26 80 00       	push   $0x802636
  802623:	50                   	push   %eax
  802624:	e8 85 ea ff ff       	call   8010ae <sys_env_set_pgfault_upcall>
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802629:	8b 45 08             	mov    0x8(%ebp),%eax
  80262c:	a3 00 70 80 00       	mov    %eax,0x807000
}
  802631:	83 c4 10             	add    $0x10,%esp
  802634:	c9                   	leave  
  802635:	c3                   	ret    

00802636 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802636:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802637:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  80263c:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80263e:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 0x28(%esp), %ebx  # trap-time eip
  802641:	8b 5c 24 28          	mov    0x28(%esp),%ebx
        subl $0x4, 0x30(%esp)  # trap-time esp minus 4
  802645:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax 
  80264a:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl %ebx, (%eax)      # trap-time esp store trap-time eip
  80264e:	89 18                	mov    %ebx,(%eax)
        addl $0x8, %esp
  802650:	83 c4 08             	add    $0x8,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  802653:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  802654:	83 c4 04             	add    $0x4,%esp
        popfl
  802657:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  802658:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  802659:	c3                   	ret    

0080265a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80265a:	55                   	push   %ebp
  80265b:	89 e5                	mov    %esp,%ebp
  80265d:	56                   	push   %esi
  80265e:	53                   	push   %ebx
  80265f:	8b 75 08             	mov    0x8(%ebp),%esi
  802662:	8b 45 0c             	mov    0xc(%ebp),%eax
  802665:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_recv not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  802668:	85 c0                	test   %eax,%eax
  80266a:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80266f:	0f 44 c2             	cmove  %edx,%eax

    int r = sys_ipc_recv(pg);
  802672:	83 ec 0c             	sub    $0xc,%esp
  802675:	50                   	push   %eax
  802676:	e8 98 ea ff ff       	call   801113 <sys_ipc_recv>
    int from_env = 0, perm = 0;
    if (r == 0) {
  80267b:	83 c4 10             	add    $0x10,%esp
  80267e:	85 c0                	test   %eax,%eax
  802680:	75 10                	jne    802692 <ipc_recv+0x38>
        from_env = thisenv->env_ipc_from;
  802682:	a1 04 50 80 00       	mov    0x805004,%eax
  802687:	8b 48 74             	mov    0x74(%eax),%ecx
        perm = thisenv->env_ipc_perm;
  80268a:	8b 50 78             	mov    0x78(%eax),%edx
        r = thisenv->env_ipc_value;
  80268d:	8b 40 70             	mov    0x70(%eax),%eax
  802690:	eb 0a                	jmp    80269c <ipc_recv+0x42>
    } else {
        from_env = 0;
        perm = 0;
  802692:	ba 00 00 00 00       	mov    $0x0,%edx
    if (r == 0) {
        from_env = thisenv->env_ipc_from;
        perm = thisenv->env_ipc_perm;
        r = thisenv->env_ipc_value;
    } else {
        from_env = 0;
  802697:	b9 00 00 00 00       	mov    $0x0,%ecx
        perm = 0;
    }

    if (from_env_store) *from_env_store = from_env;
  80269c:	85 f6                	test   %esi,%esi
  80269e:	74 02                	je     8026a2 <ipc_recv+0x48>
  8026a0:	89 0e                	mov    %ecx,(%esi)
    if (perm_store) *perm_store = perm;
  8026a2:	85 db                	test   %ebx,%ebx
  8026a4:	74 02                	je     8026a8 <ipc_recv+0x4e>
  8026a6:	89 13                	mov    %edx,(%ebx)

    return r;
}
  8026a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8026ab:	5b                   	pop    %ebx
  8026ac:	5e                   	pop    %esi
  8026ad:	5d                   	pop    %ebp
  8026ae:	c3                   	ret    

008026af <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8026af:	55                   	push   %ebp
  8026b0:	89 e5                	mov    %esp,%ebp
  8026b2:	57                   	push   %edi
  8026b3:	56                   	push   %esi
  8026b4:	53                   	push   %ebx
  8026b5:	83 ec 0c             	sub    $0xc,%esp
  8026b8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8026bb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8026be:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  8026c1:	85 db                	test   %ebx,%ebx
  8026c3:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8026c8:	0f 44 d8             	cmove  %eax,%ebx
  8026cb:	eb 1c                	jmp    8026e9 <ipc_send+0x3a>

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        if (ret != -E_IPC_NOT_RECV)
  8026cd:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8026d0:	74 12                	je     8026e4 <ipc_send+0x35>
            panic("ipc_send error %e", ret);
  8026d2:	50                   	push   %eax
  8026d3:	68 ba 31 80 00       	push   $0x8031ba
  8026d8:	6a 40                	push   $0x40
  8026da:	68 cc 31 80 00       	push   $0x8031cc
  8026df:	e8 00 de ff ff       	call   8004e4 <_panic>
        sys_yield();
  8026e4:	e8 5b e8 ff ff       	call   800f44 <sys_yield>
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  8026e9:	ff 75 14             	pushl  0x14(%ebp)
  8026ec:	53                   	push   %ebx
  8026ed:	56                   	push   %esi
  8026ee:	57                   	push   %edi
  8026ef:	e8 fc e9 ff ff       	call   8010f0 <sys_ipc_try_send>
  8026f4:	83 c4 10             	add    $0x10,%esp
  8026f7:	85 c0                	test   %eax,%eax
  8026f9:	75 d2                	jne    8026cd <ipc_send+0x1e>
        if (ret != -E_IPC_NOT_RECV)
            panic("ipc_send error %e", ret);
        sys_yield();
    }
}
  8026fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8026fe:	5b                   	pop    %ebx
  8026ff:	5e                   	pop    %esi
  802700:	5f                   	pop    %edi
  802701:	5d                   	pop    %ebp
  802702:	c3                   	ret    

00802703 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802703:	55                   	push   %ebp
  802704:	89 e5                	mov    %esp,%ebp
  802706:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802709:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80270e:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802711:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802717:	8b 52 50             	mov    0x50(%edx),%edx
  80271a:	39 ca                	cmp    %ecx,%edx
  80271c:	75 0d                	jne    80272b <ipc_find_env+0x28>
			return envs[i].env_id;
  80271e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802721:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802726:	8b 40 48             	mov    0x48(%eax),%eax
  802729:	eb 0f                	jmp    80273a <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80272b:	83 c0 01             	add    $0x1,%eax
  80272e:	3d 00 04 00 00       	cmp    $0x400,%eax
  802733:	75 d9                	jne    80270e <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802735:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80273a:	5d                   	pop    %ebp
  80273b:	c3                   	ret    

0080273c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80273c:	55                   	push   %ebp
  80273d:	89 e5                	mov    %esp,%ebp
  80273f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802742:	89 d0                	mov    %edx,%eax
  802744:	c1 e8 16             	shr    $0x16,%eax
  802747:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80274e:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802753:	f6 c1 01             	test   $0x1,%cl
  802756:	74 1d                	je     802775 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802758:	c1 ea 0c             	shr    $0xc,%edx
  80275b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802762:	f6 c2 01             	test   $0x1,%dl
  802765:	74 0e                	je     802775 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802767:	c1 ea 0c             	shr    $0xc,%edx
  80276a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802771:	ef 
  802772:	0f b7 c0             	movzwl %ax,%eax
}
  802775:	5d                   	pop    %ebp
  802776:	c3                   	ret    
  802777:	66 90                	xchg   %ax,%ax
  802779:	66 90                	xchg   %ax,%ax
  80277b:	66 90                	xchg   %ax,%ax
  80277d:	66 90                	xchg   %ax,%ax
  80277f:	90                   	nop

00802780 <__udivdi3>:
  802780:	55                   	push   %ebp
  802781:	57                   	push   %edi
  802782:	56                   	push   %esi
  802783:	53                   	push   %ebx
  802784:	83 ec 1c             	sub    $0x1c,%esp
  802787:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80278b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80278f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802793:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802797:	85 f6                	test   %esi,%esi
  802799:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80279d:	89 ca                	mov    %ecx,%edx
  80279f:	89 f8                	mov    %edi,%eax
  8027a1:	75 3d                	jne    8027e0 <__udivdi3+0x60>
  8027a3:	39 cf                	cmp    %ecx,%edi
  8027a5:	0f 87 c5 00 00 00    	ja     802870 <__udivdi3+0xf0>
  8027ab:	85 ff                	test   %edi,%edi
  8027ad:	89 fd                	mov    %edi,%ebp
  8027af:	75 0b                	jne    8027bc <__udivdi3+0x3c>
  8027b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8027b6:	31 d2                	xor    %edx,%edx
  8027b8:	f7 f7                	div    %edi
  8027ba:	89 c5                	mov    %eax,%ebp
  8027bc:	89 c8                	mov    %ecx,%eax
  8027be:	31 d2                	xor    %edx,%edx
  8027c0:	f7 f5                	div    %ebp
  8027c2:	89 c1                	mov    %eax,%ecx
  8027c4:	89 d8                	mov    %ebx,%eax
  8027c6:	89 cf                	mov    %ecx,%edi
  8027c8:	f7 f5                	div    %ebp
  8027ca:	89 c3                	mov    %eax,%ebx
  8027cc:	89 d8                	mov    %ebx,%eax
  8027ce:	89 fa                	mov    %edi,%edx
  8027d0:	83 c4 1c             	add    $0x1c,%esp
  8027d3:	5b                   	pop    %ebx
  8027d4:	5e                   	pop    %esi
  8027d5:	5f                   	pop    %edi
  8027d6:	5d                   	pop    %ebp
  8027d7:	c3                   	ret    
  8027d8:	90                   	nop
  8027d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8027e0:	39 ce                	cmp    %ecx,%esi
  8027e2:	77 74                	ja     802858 <__udivdi3+0xd8>
  8027e4:	0f bd fe             	bsr    %esi,%edi
  8027e7:	83 f7 1f             	xor    $0x1f,%edi
  8027ea:	0f 84 98 00 00 00    	je     802888 <__udivdi3+0x108>
  8027f0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8027f5:	89 f9                	mov    %edi,%ecx
  8027f7:	89 c5                	mov    %eax,%ebp
  8027f9:	29 fb                	sub    %edi,%ebx
  8027fb:	d3 e6                	shl    %cl,%esi
  8027fd:	89 d9                	mov    %ebx,%ecx
  8027ff:	d3 ed                	shr    %cl,%ebp
  802801:	89 f9                	mov    %edi,%ecx
  802803:	d3 e0                	shl    %cl,%eax
  802805:	09 ee                	or     %ebp,%esi
  802807:	89 d9                	mov    %ebx,%ecx
  802809:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80280d:	89 d5                	mov    %edx,%ebp
  80280f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802813:	d3 ed                	shr    %cl,%ebp
  802815:	89 f9                	mov    %edi,%ecx
  802817:	d3 e2                	shl    %cl,%edx
  802819:	89 d9                	mov    %ebx,%ecx
  80281b:	d3 e8                	shr    %cl,%eax
  80281d:	09 c2                	or     %eax,%edx
  80281f:	89 d0                	mov    %edx,%eax
  802821:	89 ea                	mov    %ebp,%edx
  802823:	f7 f6                	div    %esi
  802825:	89 d5                	mov    %edx,%ebp
  802827:	89 c3                	mov    %eax,%ebx
  802829:	f7 64 24 0c          	mull   0xc(%esp)
  80282d:	39 d5                	cmp    %edx,%ebp
  80282f:	72 10                	jb     802841 <__udivdi3+0xc1>
  802831:	8b 74 24 08          	mov    0x8(%esp),%esi
  802835:	89 f9                	mov    %edi,%ecx
  802837:	d3 e6                	shl    %cl,%esi
  802839:	39 c6                	cmp    %eax,%esi
  80283b:	73 07                	jae    802844 <__udivdi3+0xc4>
  80283d:	39 d5                	cmp    %edx,%ebp
  80283f:	75 03                	jne    802844 <__udivdi3+0xc4>
  802841:	83 eb 01             	sub    $0x1,%ebx
  802844:	31 ff                	xor    %edi,%edi
  802846:	89 d8                	mov    %ebx,%eax
  802848:	89 fa                	mov    %edi,%edx
  80284a:	83 c4 1c             	add    $0x1c,%esp
  80284d:	5b                   	pop    %ebx
  80284e:	5e                   	pop    %esi
  80284f:	5f                   	pop    %edi
  802850:	5d                   	pop    %ebp
  802851:	c3                   	ret    
  802852:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802858:	31 ff                	xor    %edi,%edi
  80285a:	31 db                	xor    %ebx,%ebx
  80285c:	89 d8                	mov    %ebx,%eax
  80285e:	89 fa                	mov    %edi,%edx
  802860:	83 c4 1c             	add    $0x1c,%esp
  802863:	5b                   	pop    %ebx
  802864:	5e                   	pop    %esi
  802865:	5f                   	pop    %edi
  802866:	5d                   	pop    %ebp
  802867:	c3                   	ret    
  802868:	90                   	nop
  802869:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802870:	89 d8                	mov    %ebx,%eax
  802872:	f7 f7                	div    %edi
  802874:	31 ff                	xor    %edi,%edi
  802876:	89 c3                	mov    %eax,%ebx
  802878:	89 d8                	mov    %ebx,%eax
  80287a:	89 fa                	mov    %edi,%edx
  80287c:	83 c4 1c             	add    $0x1c,%esp
  80287f:	5b                   	pop    %ebx
  802880:	5e                   	pop    %esi
  802881:	5f                   	pop    %edi
  802882:	5d                   	pop    %ebp
  802883:	c3                   	ret    
  802884:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802888:	39 ce                	cmp    %ecx,%esi
  80288a:	72 0c                	jb     802898 <__udivdi3+0x118>
  80288c:	31 db                	xor    %ebx,%ebx
  80288e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802892:	0f 87 34 ff ff ff    	ja     8027cc <__udivdi3+0x4c>
  802898:	bb 01 00 00 00       	mov    $0x1,%ebx
  80289d:	e9 2a ff ff ff       	jmp    8027cc <__udivdi3+0x4c>
  8028a2:	66 90                	xchg   %ax,%ax
  8028a4:	66 90                	xchg   %ax,%ax
  8028a6:	66 90                	xchg   %ax,%ax
  8028a8:	66 90                	xchg   %ax,%ax
  8028aa:	66 90                	xchg   %ax,%ax
  8028ac:	66 90                	xchg   %ax,%ax
  8028ae:	66 90                	xchg   %ax,%ax

008028b0 <__umoddi3>:
  8028b0:	55                   	push   %ebp
  8028b1:	57                   	push   %edi
  8028b2:	56                   	push   %esi
  8028b3:	53                   	push   %ebx
  8028b4:	83 ec 1c             	sub    $0x1c,%esp
  8028b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8028bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8028bf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8028c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8028c7:	85 d2                	test   %edx,%edx
  8028c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8028cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8028d1:	89 f3                	mov    %esi,%ebx
  8028d3:	89 3c 24             	mov    %edi,(%esp)
  8028d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8028da:	75 1c                	jne    8028f8 <__umoddi3+0x48>
  8028dc:	39 f7                	cmp    %esi,%edi
  8028de:	76 50                	jbe    802930 <__umoddi3+0x80>
  8028e0:	89 c8                	mov    %ecx,%eax
  8028e2:	89 f2                	mov    %esi,%edx
  8028e4:	f7 f7                	div    %edi
  8028e6:	89 d0                	mov    %edx,%eax
  8028e8:	31 d2                	xor    %edx,%edx
  8028ea:	83 c4 1c             	add    $0x1c,%esp
  8028ed:	5b                   	pop    %ebx
  8028ee:	5e                   	pop    %esi
  8028ef:	5f                   	pop    %edi
  8028f0:	5d                   	pop    %ebp
  8028f1:	c3                   	ret    
  8028f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8028f8:	39 f2                	cmp    %esi,%edx
  8028fa:	89 d0                	mov    %edx,%eax
  8028fc:	77 52                	ja     802950 <__umoddi3+0xa0>
  8028fe:	0f bd ea             	bsr    %edx,%ebp
  802901:	83 f5 1f             	xor    $0x1f,%ebp
  802904:	75 5a                	jne    802960 <__umoddi3+0xb0>
  802906:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80290a:	0f 82 e0 00 00 00    	jb     8029f0 <__umoddi3+0x140>
  802910:	39 0c 24             	cmp    %ecx,(%esp)
  802913:	0f 86 d7 00 00 00    	jbe    8029f0 <__umoddi3+0x140>
  802919:	8b 44 24 08          	mov    0x8(%esp),%eax
  80291d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802921:	83 c4 1c             	add    $0x1c,%esp
  802924:	5b                   	pop    %ebx
  802925:	5e                   	pop    %esi
  802926:	5f                   	pop    %edi
  802927:	5d                   	pop    %ebp
  802928:	c3                   	ret    
  802929:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802930:	85 ff                	test   %edi,%edi
  802932:	89 fd                	mov    %edi,%ebp
  802934:	75 0b                	jne    802941 <__umoddi3+0x91>
  802936:	b8 01 00 00 00       	mov    $0x1,%eax
  80293b:	31 d2                	xor    %edx,%edx
  80293d:	f7 f7                	div    %edi
  80293f:	89 c5                	mov    %eax,%ebp
  802941:	89 f0                	mov    %esi,%eax
  802943:	31 d2                	xor    %edx,%edx
  802945:	f7 f5                	div    %ebp
  802947:	89 c8                	mov    %ecx,%eax
  802949:	f7 f5                	div    %ebp
  80294b:	89 d0                	mov    %edx,%eax
  80294d:	eb 99                	jmp    8028e8 <__umoddi3+0x38>
  80294f:	90                   	nop
  802950:	89 c8                	mov    %ecx,%eax
  802952:	89 f2                	mov    %esi,%edx
  802954:	83 c4 1c             	add    $0x1c,%esp
  802957:	5b                   	pop    %ebx
  802958:	5e                   	pop    %esi
  802959:	5f                   	pop    %edi
  80295a:	5d                   	pop    %ebp
  80295b:	c3                   	ret    
  80295c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802960:	8b 34 24             	mov    (%esp),%esi
  802963:	bf 20 00 00 00       	mov    $0x20,%edi
  802968:	89 e9                	mov    %ebp,%ecx
  80296a:	29 ef                	sub    %ebp,%edi
  80296c:	d3 e0                	shl    %cl,%eax
  80296e:	89 f9                	mov    %edi,%ecx
  802970:	89 f2                	mov    %esi,%edx
  802972:	d3 ea                	shr    %cl,%edx
  802974:	89 e9                	mov    %ebp,%ecx
  802976:	09 c2                	or     %eax,%edx
  802978:	89 d8                	mov    %ebx,%eax
  80297a:	89 14 24             	mov    %edx,(%esp)
  80297d:	89 f2                	mov    %esi,%edx
  80297f:	d3 e2                	shl    %cl,%edx
  802981:	89 f9                	mov    %edi,%ecx
  802983:	89 54 24 04          	mov    %edx,0x4(%esp)
  802987:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80298b:	d3 e8                	shr    %cl,%eax
  80298d:	89 e9                	mov    %ebp,%ecx
  80298f:	89 c6                	mov    %eax,%esi
  802991:	d3 e3                	shl    %cl,%ebx
  802993:	89 f9                	mov    %edi,%ecx
  802995:	89 d0                	mov    %edx,%eax
  802997:	d3 e8                	shr    %cl,%eax
  802999:	89 e9                	mov    %ebp,%ecx
  80299b:	09 d8                	or     %ebx,%eax
  80299d:	89 d3                	mov    %edx,%ebx
  80299f:	89 f2                	mov    %esi,%edx
  8029a1:	f7 34 24             	divl   (%esp)
  8029a4:	89 d6                	mov    %edx,%esi
  8029a6:	d3 e3                	shl    %cl,%ebx
  8029a8:	f7 64 24 04          	mull   0x4(%esp)
  8029ac:	39 d6                	cmp    %edx,%esi
  8029ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8029b2:	89 d1                	mov    %edx,%ecx
  8029b4:	89 c3                	mov    %eax,%ebx
  8029b6:	72 08                	jb     8029c0 <__umoddi3+0x110>
  8029b8:	75 11                	jne    8029cb <__umoddi3+0x11b>
  8029ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8029be:	73 0b                	jae    8029cb <__umoddi3+0x11b>
  8029c0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8029c4:	1b 14 24             	sbb    (%esp),%edx
  8029c7:	89 d1                	mov    %edx,%ecx
  8029c9:	89 c3                	mov    %eax,%ebx
  8029cb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8029cf:	29 da                	sub    %ebx,%edx
  8029d1:	19 ce                	sbb    %ecx,%esi
  8029d3:	89 f9                	mov    %edi,%ecx
  8029d5:	89 f0                	mov    %esi,%eax
  8029d7:	d3 e0                	shl    %cl,%eax
  8029d9:	89 e9                	mov    %ebp,%ecx
  8029db:	d3 ea                	shr    %cl,%edx
  8029dd:	89 e9                	mov    %ebp,%ecx
  8029df:	d3 ee                	shr    %cl,%esi
  8029e1:	09 d0                	or     %edx,%eax
  8029e3:	89 f2                	mov    %esi,%edx
  8029e5:	83 c4 1c             	add    $0x1c,%esp
  8029e8:	5b                   	pop    %ebx
  8029e9:	5e                   	pop    %esi
  8029ea:	5f                   	pop    %edi
  8029eb:	5d                   	pop    %ebp
  8029ec:	c3                   	ret    
  8029ed:	8d 76 00             	lea    0x0(%esi),%esi
  8029f0:	29 f9                	sub    %edi,%ecx
  8029f2:	19 d6                	sbb    %edx,%esi
  8029f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8029f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8029fc:	e9 18 ff ff ff       	jmp    802919 <__umoddi3+0x69>
