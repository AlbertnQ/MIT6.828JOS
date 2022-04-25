
obj/user/ls.debug:     file format elf32-i386


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
  80002c:	e8 93 02 00 00       	call   8002c4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <ls1>:
		panic("error reading directory %s: %e", path, n);
}

void
ls1(const char *prefix, bool isdir, off_t size, const char *name)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80003b:	8b 75 0c             	mov    0xc(%ebp),%esi
	const char *sep;

	if(flag['l'])
  80003e:	83 3d d0 41 80 00 00 	cmpl   $0x0,0x8041d0
  800045:	74 20                	je     800067 <ls1+0x34>
		printf("%11d %c ", size, isdir ? 'd' : '-');
  800047:	89 f0                	mov    %esi,%eax
  800049:	3c 01                	cmp    $0x1,%al
  80004b:	19 c0                	sbb    %eax,%eax
  80004d:	83 e0 c9             	and    $0xffffffc9,%eax
  800050:	83 c0 64             	add    $0x64,%eax
  800053:	83 ec 04             	sub    $0x4,%esp
  800056:	50                   	push   %eax
  800057:	ff 75 10             	pushl  0x10(%ebp)
  80005a:	68 a2 22 80 00       	push   $0x8022a2
  80005f:	e8 89 19 00 00       	call   8019ed <printf>
  800064:	83 c4 10             	add    $0x10,%esp
	if(prefix) {
  800067:	85 db                	test   %ebx,%ebx
  800069:	74 3a                	je     8000a5 <ls1+0x72>
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
			sep = "/";
		else
			sep = "";
  80006b:	b8 08 23 80 00       	mov    $0x802308,%eax
	const char *sep;

	if(flag['l'])
		printf("%11d %c ", size, isdir ? 'd' : '-');
	if(prefix) {
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
  800070:	80 3b 00             	cmpb   $0x0,(%ebx)
  800073:	74 1e                	je     800093 <ls1+0x60>
  800075:	83 ec 0c             	sub    $0xc,%esp
  800078:	53                   	push   %ebx
  800079:	e8 e9 08 00 00       	call   800967 <strlen>
  80007e:	83 c4 10             	add    $0x10,%esp
			sep = "/";
		else
			sep = "";
  800081:	80 7c 03 ff 2f       	cmpb   $0x2f,-0x1(%ebx,%eax,1)
  800086:	ba 08 23 80 00       	mov    $0x802308,%edx
  80008b:	b8 a0 22 80 00       	mov    $0x8022a0,%eax
  800090:	0f 44 c2             	cmove  %edx,%eax
		printf("%s%s", prefix, sep);
  800093:	83 ec 04             	sub    $0x4,%esp
  800096:	50                   	push   %eax
  800097:	53                   	push   %ebx
  800098:	68 ab 22 80 00       	push   $0x8022ab
  80009d:	e8 4b 19 00 00       	call   8019ed <printf>
  8000a2:	83 c4 10             	add    $0x10,%esp
	}
	printf("%s", name);
  8000a5:	83 ec 08             	sub    $0x8,%esp
  8000a8:	ff 75 14             	pushl  0x14(%ebp)
  8000ab:	68 35 27 80 00       	push   $0x802735
  8000b0:	e8 38 19 00 00       	call   8019ed <printf>
	if(flag['F'] && isdir)
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	83 3d 38 41 80 00 00 	cmpl   $0x0,0x804138
  8000bf:	74 16                	je     8000d7 <ls1+0xa4>
  8000c1:	89 f0                	mov    %esi,%eax
  8000c3:	84 c0                	test   %al,%al
  8000c5:	74 10                	je     8000d7 <ls1+0xa4>
		printf("/");
  8000c7:	83 ec 0c             	sub    $0xc,%esp
  8000ca:	68 a0 22 80 00       	push   $0x8022a0
  8000cf:	e8 19 19 00 00       	call   8019ed <printf>
  8000d4:	83 c4 10             	add    $0x10,%esp
	printf("\n");
  8000d7:	83 ec 0c             	sub    $0xc,%esp
  8000da:	68 07 23 80 00       	push   $0x802307
  8000df:	e8 09 19 00 00       	call   8019ed <printf>
}
  8000e4:	83 c4 10             	add    $0x10,%esp
  8000e7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000ea:	5b                   	pop    %ebx
  8000eb:	5e                   	pop    %esi
  8000ec:	5d                   	pop    %ebp
  8000ed:	c3                   	ret    

008000ee <lsdir>:
		ls1(0, st.st_isdir, st.st_size, path);
}

void
lsdir(const char *path, const char *prefix)
{
  8000ee:	55                   	push   %ebp
  8000ef:	89 e5                	mov    %esp,%ebp
  8000f1:	57                   	push   %edi
  8000f2:	56                   	push   %esi
  8000f3:	53                   	push   %ebx
  8000f4:	81 ec 14 01 00 00    	sub    $0x114,%esp
  8000fa:	8b 7d 08             	mov    0x8(%ebp),%edi
	int fd, n;
	struct File f;

	if ((fd = open(path, O_RDONLY)) < 0)
  8000fd:	6a 00                	push   $0x0
  8000ff:	57                   	push   %edi
  800100:	e8 4a 17 00 00       	call   80184f <open>
  800105:	89 c3                	mov    %eax,%ebx
  800107:	83 c4 10             	add    $0x10,%esp
  80010a:	85 c0                	test   %eax,%eax
  80010c:	79 41                	jns    80014f <lsdir+0x61>
		panic("open %s: %e", path, fd);
  80010e:	83 ec 0c             	sub    $0xc,%esp
  800111:	50                   	push   %eax
  800112:	57                   	push   %edi
  800113:	68 b0 22 80 00       	push   $0x8022b0
  800118:	6a 1d                	push   $0x1d
  80011a:	68 bc 22 80 00       	push   $0x8022bc
  80011f:	e8 00 02 00 00       	call   800324 <_panic>
	while ((n = readn(fd, &f, sizeof f)) == sizeof f)
		if (f.f_name[0])
  800124:	80 bd e8 fe ff ff 00 	cmpb   $0x0,-0x118(%ebp)
  80012b:	74 28                	je     800155 <lsdir+0x67>
			ls1(prefix, f.f_type==FTYPE_DIR, f.f_size, f.f_name);
  80012d:	56                   	push   %esi
  80012e:	ff b5 68 ff ff ff    	pushl  -0x98(%ebp)
  800134:	83 bd 6c ff ff ff 01 	cmpl   $0x1,-0x94(%ebp)
  80013b:	0f 94 c0             	sete   %al
  80013e:	0f b6 c0             	movzbl %al,%eax
  800141:	50                   	push   %eax
  800142:	ff 75 0c             	pushl  0xc(%ebp)
  800145:	e8 e9 fe ff ff       	call   800033 <ls1>
  80014a:	83 c4 10             	add    $0x10,%esp
  80014d:	eb 06                	jmp    800155 <lsdir+0x67>
	int fd, n;
	struct File f;

	if ((fd = open(path, O_RDONLY)) < 0)
		panic("open %s: %e", path, fd);
	while ((n = readn(fd, &f, sizeof f)) == sizeof f)
  80014f:	8d b5 e8 fe ff ff    	lea    -0x118(%ebp),%esi
  800155:	83 ec 04             	sub    $0x4,%esp
  800158:	68 00 01 00 00       	push   $0x100
  80015d:	56                   	push   %esi
  80015e:	53                   	push   %ebx
  80015f:	e8 f1 12 00 00       	call   801455 <readn>
  800164:	83 c4 10             	add    $0x10,%esp
  800167:	3d 00 01 00 00       	cmp    $0x100,%eax
  80016c:	74 b6                	je     800124 <lsdir+0x36>
		if (f.f_name[0])
			ls1(prefix, f.f_type==FTYPE_DIR, f.f_size, f.f_name);
	if (n > 0)
  80016e:	85 c0                	test   %eax,%eax
  800170:	7e 12                	jle    800184 <lsdir+0x96>
		panic("short read in directory %s", path);
  800172:	57                   	push   %edi
  800173:	68 c6 22 80 00       	push   $0x8022c6
  800178:	6a 22                	push   $0x22
  80017a:	68 bc 22 80 00       	push   $0x8022bc
  80017f:	e8 a0 01 00 00       	call   800324 <_panic>
	if (n < 0)
  800184:	85 c0                	test   %eax,%eax
  800186:	79 16                	jns    80019e <lsdir+0xb0>
		panic("error reading directory %s: %e", path, n);
  800188:	83 ec 0c             	sub    $0xc,%esp
  80018b:	50                   	push   %eax
  80018c:	57                   	push   %edi
  80018d:	68 0c 23 80 00       	push   $0x80230c
  800192:	6a 24                	push   $0x24
  800194:	68 bc 22 80 00       	push   $0x8022bc
  800199:	e8 86 01 00 00       	call   800324 <_panic>
}
  80019e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a1:	5b                   	pop    %ebx
  8001a2:	5e                   	pop    %esi
  8001a3:	5f                   	pop    %edi
  8001a4:	5d                   	pop    %ebp
  8001a5:	c3                   	ret    

008001a6 <ls>:
void lsdir(const char*, const char*);
void ls1(const char*, bool, off_t, const char*);

void
ls(const char *path, const char *prefix)
{
  8001a6:	55                   	push   %ebp
  8001a7:	89 e5                	mov    %esp,%ebp
  8001a9:	53                   	push   %ebx
  8001aa:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  8001b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Stat st;

	if ((r = stat(path, &st)) < 0)
  8001b3:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
  8001b9:	50                   	push   %eax
  8001ba:	53                   	push   %ebx
  8001bb:	e8 9a 14 00 00       	call   80165a <stat>
  8001c0:	83 c4 10             	add    $0x10,%esp
  8001c3:	85 c0                	test   %eax,%eax
  8001c5:	79 16                	jns    8001dd <ls+0x37>
		panic("stat %s: %e", path, r);
  8001c7:	83 ec 0c             	sub    $0xc,%esp
  8001ca:	50                   	push   %eax
  8001cb:	53                   	push   %ebx
  8001cc:	68 e1 22 80 00       	push   $0x8022e1
  8001d1:	6a 0f                	push   $0xf
  8001d3:	68 bc 22 80 00       	push   $0x8022bc
  8001d8:	e8 47 01 00 00       	call   800324 <_panic>
	if (st.st_isdir && !flag['d'])
  8001dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8001e0:	85 c0                	test   %eax,%eax
  8001e2:	74 1a                	je     8001fe <ls+0x58>
  8001e4:	83 3d b0 41 80 00 00 	cmpl   $0x0,0x8041b0
  8001eb:	75 11                	jne    8001fe <ls+0x58>
		lsdir(path, prefix);
  8001ed:	83 ec 08             	sub    $0x8,%esp
  8001f0:	ff 75 0c             	pushl  0xc(%ebp)
  8001f3:	53                   	push   %ebx
  8001f4:	e8 f5 fe ff ff       	call   8000ee <lsdir>
  8001f9:	83 c4 10             	add    $0x10,%esp
  8001fc:	eb 17                	jmp    800215 <ls+0x6f>
	else
		ls1(0, st.st_isdir, st.st_size, path);
  8001fe:	53                   	push   %ebx
  8001ff:	ff 75 ec             	pushl  -0x14(%ebp)
  800202:	85 c0                	test   %eax,%eax
  800204:	0f 95 c0             	setne  %al
  800207:	0f b6 c0             	movzbl %al,%eax
  80020a:	50                   	push   %eax
  80020b:	6a 00                	push   $0x0
  80020d:	e8 21 fe ff ff       	call   800033 <ls1>
  800212:	83 c4 10             	add    $0x10,%esp
}
  800215:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800218:	c9                   	leave  
  800219:	c3                   	ret    

0080021a <usage>:
	printf("\n");
}

void
usage(void)
{
  80021a:	55                   	push   %ebp
  80021b:	89 e5                	mov    %esp,%ebp
  80021d:	83 ec 14             	sub    $0x14,%esp
	printf("usage: ls [-dFl] [file...]\n");
  800220:	68 ed 22 80 00       	push   $0x8022ed
  800225:	e8 c3 17 00 00       	call   8019ed <printf>
	exit();
  80022a:	e8 db 00 00 00       	call   80030a <exit>
}
  80022f:	83 c4 10             	add    $0x10,%esp
  800232:	c9                   	leave  
  800233:	c3                   	ret    

00800234 <umain>:

void
umain(int argc, char **argv)
{
  800234:	55                   	push   %ebp
  800235:	89 e5                	mov    %esp,%ebp
  800237:	56                   	push   %esi
  800238:	53                   	push   %ebx
  800239:	83 ec 14             	sub    $0x14,%esp
  80023c:	8b 75 0c             	mov    0xc(%ebp),%esi
	int i;
	struct Argstate args;

	argstart(&argc, argv, &args);
  80023f:	8d 45 e8             	lea    -0x18(%ebp),%eax
  800242:	50                   	push   %eax
  800243:	56                   	push   %esi
  800244:	8d 45 08             	lea    0x8(%ebp),%eax
  800247:	50                   	push   %eax
  800248:	e8 47 0d 00 00       	call   800f94 <argstart>
	while ((i = argnext(&args)) >= 0)
  80024d:	83 c4 10             	add    $0x10,%esp
  800250:	8d 5d e8             	lea    -0x18(%ebp),%ebx
  800253:	eb 1e                	jmp    800273 <umain+0x3f>
		switch (i) {
  800255:	83 f8 64             	cmp    $0x64,%eax
  800258:	74 0a                	je     800264 <umain+0x30>
  80025a:	83 f8 6c             	cmp    $0x6c,%eax
  80025d:	74 05                	je     800264 <umain+0x30>
  80025f:	83 f8 46             	cmp    $0x46,%eax
  800262:	75 0a                	jne    80026e <umain+0x3a>
		case 'd':
		case 'F':
		case 'l':
			flag[i]++;
  800264:	83 04 85 20 40 80 00 	addl   $0x1,0x804020(,%eax,4)
  80026b:	01 
			break;
  80026c:	eb 05                	jmp    800273 <umain+0x3f>
		default:
			usage();
  80026e:	e8 a7 ff ff ff       	call   80021a <usage>
{
	int i;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  800273:	83 ec 0c             	sub    $0xc,%esp
  800276:	53                   	push   %ebx
  800277:	e8 48 0d 00 00       	call   800fc4 <argnext>
  80027c:	83 c4 10             	add    $0x10,%esp
  80027f:	85 c0                	test   %eax,%eax
  800281:	79 d2                	jns    800255 <umain+0x21>
  800283:	bb 01 00 00 00       	mov    $0x1,%ebx
			break;
		default:
			usage();
		}

	if (argc == 1)
  800288:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  80028c:	75 2a                	jne    8002b8 <umain+0x84>
		ls("/", "");
  80028e:	83 ec 08             	sub    $0x8,%esp
  800291:	68 08 23 80 00       	push   $0x802308
  800296:	68 a0 22 80 00       	push   $0x8022a0
  80029b:	e8 06 ff ff ff       	call   8001a6 <ls>
  8002a0:	83 c4 10             	add    $0x10,%esp
  8002a3:	eb 18                	jmp    8002bd <umain+0x89>
	else {
		for (i = 1; i < argc; i++)
			ls(argv[i], argv[i]);
  8002a5:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  8002a8:	83 ec 08             	sub    $0x8,%esp
  8002ab:	50                   	push   %eax
  8002ac:	50                   	push   %eax
  8002ad:	e8 f4 fe ff ff       	call   8001a6 <ls>
		}

	if (argc == 1)
		ls("/", "");
	else {
		for (i = 1; i < argc; i++)
  8002b2:	83 c3 01             	add    $0x1,%ebx
  8002b5:	83 c4 10             	add    $0x10,%esp
  8002b8:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  8002bb:	7c e8                	jl     8002a5 <umain+0x71>
			ls(argv[i], argv[i]);
	}
}
  8002bd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002c0:	5b                   	pop    %ebx
  8002c1:	5e                   	pop    %esi
  8002c2:	5d                   	pop    %ebp
  8002c3:	c3                   	ret    

008002c4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	56                   	push   %esi
  8002c8:	53                   	push   %ebx
  8002c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002cc:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  8002cf:	e8 91 0a 00 00       	call   800d65 <sys_getenvid>
  8002d4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002d9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8002dc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002e1:	a3 20 44 80 00       	mov    %eax,0x804420
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002e6:	85 db                	test   %ebx,%ebx
  8002e8:	7e 07                	jle    8002f1 <libmain+0x2d>
		binaryname = argv[0];
  8002ea:	8b 06                	mov    (%esi),%eax
  8002ec:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8002f1:	83 ec 08             	sub    $0x8,%esp
  8002f4:	56                   	push   %esi
  8002f5:	53                   	push   %ebx
  8002f6:	e8 39 ff ff ff       	call   800234 <umain>

	// exit gracefully
	exit();
  8002fb:	e8 0a 00 00 00       	call   80030a <exit>
}
  800300:	83 c4 10             	add    $0x10,%esp
  800303:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800306:	5b                   	pop    %ebx
  800307:	5e                   	pop    %esi
  800308:	5d                   	pop    %ebp
  800309:	c3                   	ret    

0080030a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80030a:	55                   	push   %ebp
  80030b:	89 e5                	mov    %esp,%ebp
  80030d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800310:	e8 9e 0f 00 00       	call   8012b3 <close_all>
	sys_env_destroy(0);
  800315:	83 ec 0c             	sub    $0xc,%esp
  800318:	6a 00                	push   $0x0
  80031a:	e8 05 0a 00 00       	call   800d24 <sys_env_destroy>
}
  80031f:	83 c4 10             	add    $0x10,%esp
  800322:	c9                   	leave  
  800323:	c3                   	ret    

00800324 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800324:	55                   	push   %ebp
  800325:	89 e5                	mov    %esp,%ebp
  800327:	56                   	push   %esi
  800328:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800329:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80032c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800332:	e8 2e 0a 00 00       	call   800d65 <sys_getenvid>
  800337:	83 ec 0c             	sub    $0xc,%esp
  80033a:	ff 75 0c             	pushl  0xc(%ebp)
  80033d:	ff 75 08             	pushl  0x8(%ebp)
  800340:	56                   	push   %esi
  800341:	50                   	push   %eax
  800342:	68 38 23 80 00       	push   $0x802338
  800347:	e8 b1 00 00 00       	call   8003fd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80034c:	83 c4 18             	add    $0x18,%esp
  80034f:	53                   	push   %ebx
  800350:	ff 75 10             	pushl  0x10(%ebp)
  800353:	e8 54 00 00 00       	call   8003ac <vcprintf>
	cprintf("\n");
  800358:	c7 04 24 07 23 80 00 	movl   $0x802307,(%esp)
  80035f:	e8 99 00 00 00       	call   8003fd <cprintf>
  800364:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800367:	cc                   	int3   
  800368:	eb fd                	jmp    800367 <_panic+0x43>

0080036a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80036a:	55                   	push   %ebp
  80036b:	89 e5                	mov    %esp,%ebp
  80036d:	53                   	push   %ebx
  80036e:	83 ec 04             	sub    $0x4,%esp
  800371:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800374:	8b 13                	mov    (%ebx),%edx
  800376:	8d 42 01             	lea    0x1(%edx),%eax
  800379:	89 03                	mov    %eax,(%ebx)
  80037b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80037e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800382:	3d ff 00 00 00       	cmp    $0xff,%eax
  800387:	75 1a                	jne    8003a3 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800389:	83 ec 08             	sub    $0x8,%esp
  80038c:	68 ff 00 00 00       	push   $0xff
  800391:	8d 43 08             	lea    0x8(%ebx),%eax
  800394:	50                   	push   %eax
  800395:	e8 4d 09 00 00       	call   800ce7 <sys_cputs>
		b->idx = 0;
  80039a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003a0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003a3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003aa:	c9                   	leave  
  8003ab:	c3                   	ret    

008003ac <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003ac:	55                   	push   %ebp
  8003ad:	89 e5                	mov    %esp,%ebp
  8003af:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003b5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003bc:	00 00 00 
	b.cnt = 0;
  8003bf:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003c6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003c9:	ff 75 0c             	pushl  0xc(%ebp)
  8003cc:	ff 75 08             	pushl  0x8(%ebp)
  8003cf:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003d5:	50                   	push   %eax
  8003d6:	68 6a 03 80 00       	push   $0x80036a
  8003db:	e8 54 01 00 00       	call   800534 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003e0:	83 c4 08             	add    $0x8,%esp
  8003e3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003e9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003ef:	50                   	push   %eax
  8003f0:	e8 f2 08 00 00       	call   800ce7 <sys_cputs>

	return b.cnt;
}
  8003f5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003fb:	c9                   	leave  
  8003fc:	c3                   	ret    

008003fd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003fd:	55                   	push   %ebp
  8003fe:	89 e5                	mov    %esp,%ebp
  800400:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800403:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800406:	50                   	push   %eax
  800407:	ff 75 08             	pushl  0x8(%ebp)
  80040a:	e8 9d ff ff ff       	call   8003ac <vcprintf>
	va_end(ap);

	return cnt;
}
  80040f:	c9                   	leave  
  800410:	c3                   	ret    

00800411 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800411:	55                   	push   %ebp
  800412:	89 e5                	mov    %esp,%ebp
  800414:	57                   	push   %edi
  800415:	56                   	push   %esi
  800416:	53                   	push   %ebx
  800417:	83 ec 1c             	sub    $0x1c,%esp
  80041a:	89 c7                	mov    %eax,%edi
  80041c:	89 d6                	mov    %edx,%esi
  80041e:	8b 45 08             	mov    0x8(%ebp),%eax
  800421:	8b 55 0c             	mov    0xc(%ebp),%edx
  800424:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800427:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80042a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80042d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800432:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800435:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800438:	39 d3                	cmp    %edx,%ebx
  80043a:	72 05                	jb     800441 <printnum+0x30>
  80043c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80043f:	77 45                	ja     800486 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800441:	83 ec 0c             	sub    $0xc,%esp
  800444:	ff 75 18             	pushl  0x18(%ebp)
  800447:	8b 45 14             	mov    0x14(%ebp),%eax
  80044a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80044d:	53                   	push   %ebx
  80044e:	ff 75 10             	pushl  0x10(%ebp)
  800451:	83 ec 08             	sub    $0x8,%esp
  800454:	ff 75 e4             	pushl  -0x1c(%ebp)
  800457:	ff 75 e0             	pushl  -0x20(%ebp)
  80045a:	ff 75 dc             	pushl  -0x24(%ebp)
  80045d:	ff 75 d8             	pushl  -0x28(%ebp)
  800460:	e8 9b 1b 00 00       	call   802000 <__udivdi3>
  800465:	83 c4 18             	add    $0x18,%esp
  800468:	52                   	push   %edx
  800469:	50                   	push   %eax
  80046a:	89 f2                	mov    %esi,%edx
  80046c:	89 f8                	mov    %edi,%eax
  80046e:	e8 9e ff ff ff       	call   800411 <printnum>
  800473:	83 c4 20             	add    $0x20,%esp
  800476:	eb 18                	jmp    800490 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800478:	83 ec 08             	sub    $0x8,%esp
  80047b:	56                   	push   %esi
  80047c:	ff 75 18             	pushl  0x18(%ebp)
  80047f:	ff d7                	call   *%edi
  800481:	83 c4 10             	add    $0x10,%esp
  800484:	eb 03                	jmp    800489 <printnum+0x78>
  800486:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800489:	83 eb 01             	sub    $0x1,%ebx
  80048c:	85 db                	test   %ebx,%ebx
  80048e:	7f e8                	jg     800478 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800490:	83 ec 08             	sub    $0x8,%esp
  800493:	56                   	push   %esi
  800494:	83 ec 04             	sub    $0x4,%esp
  800497:	ff 75 e4             	pushl  -0x1c(%ebp)
  80049a:	ff 75 e0             	pushl  -0x20(%ebp)
  80049d:	ff 75 dc             	pushl  -0x24(%ebp)
  8004a0:	ff 75 d8             	pushl  -0x28(%ebp)
  8004a3:	e8 88 1c 00 00       	call   802130 <__umoddi3>
  8004a8:	83 c4 14             	add    $0x14,%esp
  8004ab:	0f be 80 5b 23 80 00 	movsbl 0x80235b(%eax),%eax
  8004b2:	50                   	push   %eax
  8004b3:	ff d7                	call   *%edi
}
  8004b5:	83 c4 10             	add    $0x10,%esp
  8004b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004bb:	5b                   	pop    %ebx
  8004bc:	5e                   	pop    %esi
  8004bd:	5f                   	pop    %edi
  8004be:	5d                   	pop    %ebp
  8004bf:	c3                   	ret    

008004c0 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004c0:	55                   	push   %ebp
  8004c1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004c3:	83 fa 01             	cmp    $0x1,%edx
  8004c6:	7e 0e                	jle    8004d6 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004c8:	8b 10                	mov    (%eax),%edx
  8004ca:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004cd:	89 08                	mov    %ecx,(%eax)
  8004cf:	8b 02                	mov    (%edx),%eax
  8004d1:	8b 52 04             	mov    0x4(%edx),%edx
  8004d4:	eb 22                	jmp    8004f8 <getuint+0x38>
	else if (lflag)
  8004d6:	85 d2                	test   %edx,%edx
  8004d8:	74 10                	je     8004ea <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004da:	8b 10                	mov    (%eax),%edx
  8004dc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004df:	89 08                	mov    %ecx,(%eax)
  8004e1:	8b 02                	mov    (%edx),%eax
  8004e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8004e8:	eb 0e                	jmp    8004f8 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004ea:	8b 10                	mov    (%eax),%edx
  8004ec:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004ef:	89 08                	mov    %ecx,(%eax)
  8004f1:	8b 02                	mov    (%edx),%eax
  8004f3:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004f8:	5d                   	pop    %ebp
  8004f9:	c3                   	ret    

008004fa <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004fa:	55                   	push   %ebp
  8004fb:	89 e5                	mov    %esp,%ebp
  8004fd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800500:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800504:	8b 10                	mov    (%eax),%edx
  800506:	3b 50 04             	cmp    0x4(%eax),%edx
  800509:	73 0a                	jae    800515 <sprintputch+0x1b>
		*b->buf++ = ch;
  80050b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80050e:	89 08                	mov    %ecx,(%eax)
  800510:	8b 45 08             	mov    0x8(%ebp),%eax
  800513:	88 02                	mov    %al,(%edx)
}
  800515:	5d                   	pop    %ebp
  800516:	c3                   	ret    

00800517 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800517:	55                   	push   %ebp
  800518:	89 e5                	mov    %esp,%ebp
  80051a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80051d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800520:	50                   	push   %eax
  800521:	ff 75 10             	pushl  0x10(%ebp)
  800524:	ff 75 0c             	pushl  0xc(%ebp)
  800527:	ff 75 08             	pushl  0x8(%ebp)
  80052a:	e8 05 00 00 00       	call   800534 <vprintfmt>
	va_end(ap);
}
  80052f:	83 c4 10             	add    $0x10,%esp
  800532:	c9                   	leave  
  800533:	c3                   	ret    

00800534 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800534:	55                   	push   %ebp
  800535:	89 e5                	mov    %esp,%ebp
  800537:	57                   	push   %edi
  800538:	56                   	push   %esi
  800539:	53                   	push   %ebx
  80053a:	83 ec 2c             	sub    $0x2c,%esp
  80053d:	8b 75 08             	mov    0x8(%ebp),%esi
  800540:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800543:	8b 7d 10             	mov    0x10(%ebp),%edi
  800546:	eb 12                	jmp    80055a <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800548:	85 c0                	test   %eax,%eax
  80054a:	0f 84 a7 03 00 00    	je     8008f7 <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
  800550:	83 ec 08             	sub    $0x8,%esp
  800553:	53                   	push   %ebx
  800554:	50                   	push   %eax
  800555:	ff d6                	call   *%esi
  800557:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80055a:	83 c7 01             	add    $0x1,%edi
  80055d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800561:	83 f8 25             	cmp    $0x25,%eax
  800564:	75 e2                	jne    800548 <vprintfmt+0x14>
  800566:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80056a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800571:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800578:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80057f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800586:	b9 00 00 00 00       	mov    $0x0,%ecx
  80058b:	eb 07                	jmp    800594 <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800590:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800594:	8d 47 01             	lea    0x1(%edi),%eax
  800597:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80059a:	0f b6 07             	movzbl (%edi),%eax
  80059d:	0f b6 d0             	movzbl %al,%edx
  8005a0:	83 e8 23             	sub    $0x23,%eax
  8005a3:	3c 55                	cmp    $0x55,%al
  8005a5:	0f 87 31 03 00 00    	ja     8008dc <vprintfmt+0x3a8>
  8005ab:	0f b6 c0             	movzbl %al,%eax
  8005ae:	ff 24 85 a0 24 80 00 	jmp    *0x8024a0(,%eax,4)
  8005b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005b8:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005bc:	eb d6                	jmp    800594 <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8005c6:	89 75 08             	mov    %esi,0x8(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005c9:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005cc:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8005d0:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8005d3:	8d 72 d0             	lea    -0x30(%edx),%esi
  8005d6:	83 fe 09             	cmp    $0x9,%esi
  8005d9:	77 34                	ja     80060f <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005db:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005de:	eb e9                	jmp    8005c9 <vprintfmt+0x95>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e3:	8d 50 04             	lea    0x4(%eax),%edx
  8005e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e9:	8b 00                	mov    (%eax),%eax
  8005eb:	89 45 cc             	mov    %eax,-0x34(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005f1:	eb 22                	jmp    800615 <vprintfmt+0xe1>
  8005f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005f6:	85 c0                	test   %eax,%eax
  8005f8:	0f 48 c1             	cmovs  %ecx,%eax
  8005fb:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800601:	eb 91                	jmp    800594 <vprintfmt+0x60>
  800603:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800606:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80060d:	eb 85                	jmp    800594 <vprintfmt+0x60>
  80060f:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800612:	8b 75 08             	mov    0x8(%ebp),%esi

		process_precision:
			if (width < 0)
  800615:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800619:	0f 89 75 ff ff ff    	jns    800594 <vprintfmt+0x60>
				width = precision, precision = -1;
  80061f:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800622:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800625:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80062c:	e9 63 ff ff ff       	jmp    800594 <vprintfmt+0x60>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800631:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800635:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800638:	e9 57 ff ff ff       	jmp    800594 <vprintfmt+0x60>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80063d:	8b 45 14             	mov    0x14(%ebp),%eax
  800640:	8d 50 04             	lea    0x4(%eax),%edx
  800643:	89 55 14             	mov    %edx,0x14(%ebp)
  800646:	83 ec 08             	sub    $0x8,%esp
  800649:	53                   	push   %ebx
  80064a:	ff 30                	pushl  (%eax)
  80064c:	ff d6                	call   *%esi
			break;
  80064e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800651:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800654:	e9 01 ff ff ff       	jmp    80055a <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800659:	8b 45 14             	mov    0x14(%ebp),%eax
  80065c:	8d 50 04             	lea    0x4(%eax),%edx
  80065f:	89 55 14             	mov    %edx,0x14(%ebp)
  800662:	8b 00                	mov    (%eax),%eax
  800664:	99                   	cltd   
  800665:	31 d0                	xor    %edx,%eax
  800667:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800669:	83 f8 0f             	cmp    $0xf,%eax
  80066c:	7f 0b                	jg     800679 <vprintfmt+0x145>
  80066e:	8b 14 85 00 26 80 00 	mov    0x802600(,%eax,4),%edx
  800675:	85 d2                	test   %edx,%edx
  800677:	75 18                	jne    800691 <vprintfmt+0x15d>
				printfmt(putch, putdat, "error %d", err);
  800679:	50                   	push   %eax
  80067a:	68 73 23 80 00       	push   $0x802373
  80067f:	53                   	push   %ebx
  800680:	56                   	push   %esi
  800681:	e8 91 fe ff ff       	call   800517 <printfmt>
  800686:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800689:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80068c:	e9 c9 fe ff ff       	jmp    80055a <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800691:	52                   	push   %edx
  800692:	68 35 27 80 00       	push   $0x802735
  800697:	53                   	push   %ebx
  800698:	56                   	push   %esi
  800699:	e8 79 fe ff ff       	call   800517 <printfmt>
  80069e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006a4:	e9 b1 fe ff ff       	jmp    80055a <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ac:	8d 50 04             	lea    0x4(%eax),%edx
  8006af:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b2:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006b4:	85 ff                	test   %edi,%edi
  8006b6:	b8 6c 23 80 00       	mov    $0x80236c,%eax
  8006bb:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006be:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006c2:	0f 8e 94 00 00 00    	jle    80075c <vprintfmt+0x228>
  8006c8:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006cc:	0f 84 98 00 00 00    	je     80076a <vprintfmt+0x236>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d2:	83 ec 08             	sub    $0x8,%esp
  8006d5:	ff 75 cc             	pushl  -0x34(%ebp)
  8006d8:	57                   	push   %edi
  8006d9:	e8 a1 02 00 00       	call   80097f <strnlen>
  8006de:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006e1:	29 c1                	sub    %eax,%ecx
  8006e3:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8006e6:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006e9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006ed:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006f0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006f3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006f5:	eb 0f                	jmp    800706 <vprintfmt+0x1d2>
					putch(padc, putdat);
  8006f7:	83 ec 08             	sub    $0x8,%esp
  8006fa:	53                   	push   %ebx
  8006fb:	ff 75 e0             	pushl  -0x20(%ebp)
  8006fe:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800700:	83 ef 01             	sub    $0x1,%edi
  800703:	83 c4 10             	add    $0x10,%esp
  800706:	85 ff                	test   %edi,%edi
  800708:	7f ed                	jg     8006f7 <vprintfmt+0x1c3>
  80070a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80070d:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800710:	85 c9                	test   %ecx,%ecx
  800712:	b8 00 00 00 00       	mov    $0x0,%eax
  800717:	0f 49 c1             	cmovns %ecx,%eax
  80071a:	29 c1                	sub    %eax,%ecx
  80071c:	89 75 08             	mov    %esi,0x8(%ebp)
  80071f:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800722:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800725:	89 cb                	mov    %ecx,%ebx
  800727:	eb 4d                	jmp    800776 <vprintfmt+0x242>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800729:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80072d:	74 1b                	je     80074a <vprintfmt+0x216>
  80072f:	0f be c0             	movsbl %al,%eax
  800732:	83 e8 20             	sub    $0x20,%eax
  800735:	83 f8 5e             	cmp    $0x5e,%eax
  800738:	76 10                	jbe    80074a <vprintfmt+0x216>
					putch('?', putdat);
  80073a:	83 ec 08             	sub    $0x8,%esp
  80073d:	ff 75 0c             	pushl  0xc(%ebp)
  800740:	6a 3f                	push   $0x3f
  800742:	ff 55 08             	call   *0x8(%ebp)
  800745:	83 c4 10             	add    $0x10,%esp
  800748:	eb 0d                	jmp    800757 <vprintfmt+0x223>
				else
					putch(ch, putdat);
  80074a:	83 ec 08             	sub    $0x8,%esp
  80074d:	ff 75 0c             	pushl  0xc(%ebp)
  800750:	52                   	push   %edx
  800751:	ff 55 08             	call   *0x8(%ebp)
  800754:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800757:	83 eb 01             	sub    $0x1,%ebx
  80075a:	eb 1a                	jmp    800776 <vprintfmt+0x242>
  80075c:	89 75 08             	mov    %esi,0x8(%ebp)
  80075f:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800762:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800765:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800768:	eb 0c                	jmp    800776 <vprintfmt+0x242>
  80076a:	89 75 08             	mov    %esi,0x8(%ebp)
  80076d:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800770:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800773:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800776:	83 c7 01             	add    $0x1,%edi
  800779:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80077d:	0f be d0             	movsbl %al,%edx
  800780:	85 d2                	test   %edx,%edx
  800782:	74 23                	je     8007a7 <vprintfmt+0x273>
  800784:	85 f6                	test   %esi,%esi
  800786:	78 a1                	js     800729 <vprintfmt+0x1f5>
  800788:	83 ee 01             	sub    $0x1,%esi
  80078b:	79 9c                	jns    800729 <vprintfmt+0x1f5>
  80078d:	89 df                	mov    %ebx,%edi
  80078f:	8b 75 08             	mov    0x8(%ebp),%esi
  800792:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800795:	eb 18                	jmp    8007af <vprintfmt+0x27b>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800797:	83 ec 08             	sub    $0x8,%esp
  80079a:	53                   	push   %ebx
  80079b:	6a 20                	push   $0x20
  80079d:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80079f:	83 ef 01             	sub    $0x1,%edi
  8007a2:	83 c4 10             	add    $0x10,%esp
  8007a5:	eb 08                	jmp    8007af <vprintfmt+0x27b>
  8007a7:	89 df                	mov    %ebx,%edi
  8007a9:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007af:	85 ff                	test   %edi,%edi
  8007b1:	7f e4                	jg     800797 <vprintfmt+0x263>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007b6:	e9 9f fd ff ff       	jmp    80055a <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007bb:	83 7d d0 01          	cmpl   $0x1,-0x30(%ebp)
  8007bf:	7e 16                	jle    8007d7 <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  8007c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c4:	8d 50 08             	lea    0x8(%eax),%edx
  8007c7:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ca:	8b 50 04             	mov    0x4(%eax),%edx
  8007cd:	8b 00                	mov    (%eax),%eax
  8007cf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007d2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007d5:	eb 34                	jmp    80080b <vprintfmt+0x2d7>
	else if (lflag)
  8007d7:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8007db:	74 18                	je     8007f5 <vprintfmt+0x2c1>
		return va_arg(*ap, long);
  8007dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e0:	8d 50 04             	lea    0x4(%eax),%edx
  8007e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e6:	8b 00                	mov    (%eax),%eax
  8007e8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007eb:	89 c1                	mov    %eax,%ecx
  8007ed:	c1 f9 1f             	sar    $0x1f,%ecx
  8007f0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007f3:	eb 16                	jmp    80080b <vprintfmt+0x2d7>
	else
		return va_arg(*ap, int);
  8007f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f8:	8d 50 04             	lea    0x4(%eax),%edx
  8007fb:	89 55 14             	mov    %edx,0x14(%ebp)
  8007fe:	8b 00                	mov    (%eax),%eax
  800800:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800803:	89 c1                	mov    %eax,%ecx
  800805:	c1 f9 1f             	sar    $0x1f,%ecx
  800808:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80080b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80080e:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800811:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800816:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80081a:	0f 89 88 00 00 00    	jns    8008a8 <vprintfmt+0x374>
				putch('-', putdat);
  800820:	83 ec 08             	sub    $0x8,%esp
  800823:	53                   	push   %ebx
  800824:	6a 2d                	push   $0x2d
  800826:	ff d6                	call   *%esi
				num = -(long long) num;
  800828:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80082b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80082e:	f7 d8                	neg    %eax
  800830:	83 d2 00             	adc    $0x0,%edx
  800833:	f7 da                	neg    %edx
  800835:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800838:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80083d:	eb 69                	jmp    8008a8 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80083f:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800842:	8d 45 14             	lea    0x14(%ebp),%eax
  800845:	e8 76 fc ff ff       	call   8004c0 <getuint>
			base = 10;
  80084a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80084f:	eb 57                	jmp    8008a8 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  800851:	83 ec 08             	sub    $0x8,%esp
  800854:	53                   	push   %ebx
  800855:	6a 30                	push   $0x30
  800857:	ff d6                	call   *%esi
			num = getuint(&ap, lflag);
  800859:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80085c:	8d 45 14             	lea    0x14(%ebp),%eax
  80085f:	e8 5c fc ff ff       	call   8004c0 <getuint>
			base = 8;
			goto number;
  800864:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800867:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80086c:	eb 3a                	jmp    8008a8 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  80086e:	83 ec 08             	sub    $0x8,%esp
  800871:	53                   	push   %ebx
  800872:	6a 30                	push   $0x30
  800874:	ff d6                	call   *%esi
			putch('x', putdat);
  800876:	83 c4 08             	add    $0x8,%esp
  800879:	53                   	push   %ebx
  80087a:	6a 78                	push   $0x78
  80087c:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80087e:	8b 45 14             	mov    0x14(%ebp),%eax
  800881:	8d 50 04             	lea    0x4(%eax),%edx
  800884:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800887:	8b 00                	mov    (%eax),%eax
  800889:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80088e:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800891:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800896:	eb 10                	jmp    8008a8 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800898:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80089b:	8d 45 14             	lea    0x14(%ebp),%eax
  80089e:	e8 1d fc ff ff       	call   8004c0 <getuint>
			base = 16;
  8008a3:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008a8:	83 ec 0c             	sub    $0xc,%esp
  8008ab:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8008af:	57                   	push   %edi
  8008b0:	ff 75 e0             	pushl  -0x20(%ebp)
  8008b3:	51                   	push   %ecx
  8008b4:	52                   	push   %edx
  8008b5:	50                   	push   %eax
  8008b6:	89 da                	mov    %ebx,%edx
  8008b8:	89 f0                	mov    %esi,%eax
  8008ba:	e8 52 fb ff ff       	call   800411 <printnum>
			break;
  8008bf:	83 c4 20             	add    $0x20,%esp
  8008c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008c5:	e9 90 fc ff ff       	jmp    80055a <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008ca:	83 ec 08             	sub    $0x8,%esp
  8008cd:	53                   	push   %ebx
  8008ce:	52                   	push   %edx
  8008cf:	ff d6                	call   *%esi
			break;
  8008d1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008d7:	e9 7e fc ff ff       	jmp    80055a <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008dc:	83 ec 08             	sub    $0x8,%esp
  8008df:	53                   	push   %ebx
  8008e0:	6a 25                	push   $0x25
  8008e2:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008e4:	83 c4 10             	add    $0x10,%esp
  8008e7:	eb 03                	jmp    8008ec <vprintfmt+0x3b8>
  8008e9:	83 ef 01             	sub    $0x1,%edi
  8008ec:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008f0:	75 f7                	jne    8008e9 <vprintfmt+0x3b5>
  8008f2:	e9 63 fc ff ff       	jmp    80055a <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8008f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008fa:	5b                   	pop    %ebx
  8008fb:	5e                   	pop    %esi
  8008fc:	5f                   	pop    %edi
  8008fd:	5d                   	pop    %ebp
  8008fe:	c3                   	ret    

008008ff <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008ff:	55                   	push   %ebp
  800900:	89 e5                	mov    %esp,%ebp
  800902:	83 ec 18             	sub    $0x18,%esp
  800905:	8b 45 08             	mov    0x8(%ebp),%eax
  800908:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80090b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80090e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800912:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800915:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80091c:	85 c0                	test   %eax,%eax
  80091e:	74 26                	je     800946 <vsnprintf+0x47>
  800920:	85 d2                	test   %edx,%edx
  800922:	7e 22                	jle    800946 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800924:	ff 75 14             	pushl  0x14(%ebp)
  800927:	ff 75 10             	pushl  0x10(%ebp)
  80092a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80092d:	50                   	push   %eax
  80092e:	68 fa 04 80 00       	push   $0x8004fa
  800933:	e8 fc fb ff ff       	call   800534 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800938:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80093b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80093e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800941:	83 c4 10             	add    $0x10,%esp
  800944:	eb 05                	jmp    80094b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800946:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80094b:	c9                   	leave  
  80094c:	c3                   	ret    

0080094d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80094d:	55                   	push   %ebp
  80094e:	89 e5                	mov    %esp,%ebp
  800950:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800953:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800956:	50                   	push   %eax
  800957:	ff 75 10             	pushl  0x10(%ebp)
  80095a:	ff 75 0c             	pushl  0xc(%ebp)
  80095d:	ff 75 08             	pushl  0x8(%ebp)
  800960:	e8 9a ff ff ff       	call   8008ff <vsnprintf>
	va_end(ap);

	return rc;
}
  800965:	c9                   	leave  
  800966:	c3                   	ret    

00800967 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800967:	55                   	push   %ebp
  800968:	89 e5                	mov    %esp,%ebp
  80096a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80096d:	b8 00 00 00 00       	mov    $0x0,%eax
  800972:	eb 03                	jmp    800977 <strlen+0x10>
		n++;
  800974:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800977:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80097b:	75 f7                	jne    800974 <strlen+0xd>
		n++;
	return n;
}
  80097d:	5d                   	pop    %ebp
  80097e:	c3                   	ret    

0080097f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800985:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800988:	ba 00 00 00 00       	mov    $0x0,%edx
  80098d:	eb 03                	jmp    800992 <strnlen+0x13>
		n++;
  80098f:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800992:	39 c2                	cmp    %eax,%edx
  800994:	74 08                	je     80099e <strnlen+0x1f>
  800996:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80099a:	75 f3                	jne    80098f <strnlen+0x10>
  80099c:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80099e:	5d                   	pop    %ebp
  80099f:	c3                   	ret    

008009a0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009a0:	55                   	push   %ebp
  8009a1:	89 e5                	mov    %esp,%ebp
  8009a3:	53                   	push   %ebx
  8009a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009aa:	89 c2                	mov    %eax,%edx
  8009ac:	83 c2 01             	add    $0x1,%edx
  8009af:	83 c1 01             	add    $0x1,%ecx
  8009b2:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009b6:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009b9:	84 db                	test   %bl,%bl
  8009bb:	75 ef                	jne    8009ac <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009bd:	5b                   	pop    %ebx
  8009be:	5d                   	pop    %ebp
  8009bf:	c3                   	ret    

008009c0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009c0:	55                   	push   %ebp
  8009c1:	89 e5                	mov    %esp,%ebp
  8009c3:	53                   	push   %ebx
  8009c4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009c7:	53                   	push   %ebx
  8009c8:	e8 9a ff ff ff       	call   800967 <strlen>
  8009cd:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009d0:	ff 75 0c             	pushl  0xc(%ebp)
  8009d3:	01 d8                	add    %ebx,%eax
  8009d5:	50                   	push   %eax
  8009d6:	e8 c5 ff ff ff       	call   8009a0 <strcpy>
	return dst;
}
  8009db:	89 d8                	mov    %ebx,%eax
  8009dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009e0:	c9                   	leave  
  8009e1:	c3                   	ret    

008009e2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009e2:	55                   	push   %ebp
  8009e3:	89 e5                	mov    %esp,%ebp
  8009e5:	56                   	push   %esi
  8009e6:	53                   	push   %ebx
  8009e7:	8b 75 08             	mov    0x8(%ebp),%esi
  8009ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009ed:	89 f3                	mov    %esi,%ebx
  8009ef:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009f2:	89 f2                	mov    %esi,%edx
  8009f4:	eb 0f                	jmp    800a05 <strncpy+0x23>
		*dst++ = *src;
  8009f6:	83 c2 01             	add    $0x1,%edx
  8009f9:	0f b6 01             	movzbl (%ecx),%eax
  8009fc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009ff:	80 39 01             	cmpb   $0x1,(%ecx)
  800a02:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a05:	39 da                	cmp    %ebx,%edx
  800a07:	75 ed                	jne    8009f6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a09:	89 f0                	mov    %esi,%eax
  800a0b:	5b                   	pop    %ebx
  800a0c:	5e                   	pop    %esi
  800a0d:	5d                   	pop    %ebp
  800a0e:	c3                   	ret    

00800a0f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a0f:	55                   	push   %ebp
  800a10:	89 e5                	mov    %esp,%ebp
  800a12:	56                   	push   %esi
  800a13:	53                   	push   %ebx
  800a14:	8b 75 08             	mov    0x8(%ebp),%esi
  800a17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a1a:	8b 55 10             	mov    0x10(%ebp),%edx
  800a1d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a1f:	85 d2                	test   %edx,%edx
  800a21:	74 21                	je     800a44 <strlcpy+0x35>
  800a23:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a27:	89 f2                	mov    %esi,%edx
  800a29:	eb 09                	jmp    800a34 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a2b:	83 c2 01             	add    $0x1,%edx
  800a2e:	83 c1 01             	add    $0x1,%ecx
  800a31:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a34:	39 c2                	cmp    %eax,%edx
  800a36:	74 09                	je     800a41 <strlcpy+0x32>
  800a38:	0f b6 19             	movzbl (%ecx),%ebx
  800a3b:	84 db                	test   %bl,%bl
  800a3d:	75 ec                	jne    800a2b <strlcpy+0x1c>
  800a3f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a41:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a44:	29 f0                	sub    %esi,%eax
}
  800a46:	5b                   	pop    %ebx
  800a47:	5e                   	pop    %esi
  800a48:	5d                   	pop    %ebp
  800a49:	c3                   	ret    

00800a4a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a4a:	55                   	push   %ebp
  800a4b:	89 e5                	mov    %esp,%ebp
  800a4d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a50:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a53:	eb 06                	jmp    800a5b <strcmp+0x11>
		p++, q++;
  800a55:	83 c1 01             	add    $0x1,%ecx
  800a58:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a5b:	0f b6 01             	movzbl (%ecx),%eax
  800a5e:	84 c0                	test   %al,%al
  800a60:	74 04                	je     800a66 <strcmp+0x1c>
  800a62:	3a 02                	cmp    (%edx),%al
  800a64:	74 ef                	je     800a55 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a66:	0f b6 c0             	movzbl %al,%eax
  800a69:	0f b6 12             	movzbl (%edx),%edx
  800a6c:	29 d0                	sub    %edx,%eax
}
  800a6e:	5d                   	pop    %ebp
  800a6f:	c3                   	ret    

00800a70 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a70:	55                   	push   %ebp
  800a71:	89 e5                	mov    %esp,%ebp
  800a73:	53                   	push   %ebx
  800a74:	8b 45 08             	mov    0x8(%ebp),%eax
  800a77:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a7a:	89 c3                	mov    %eax,%ebx
  800a7c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a7f:	eb 06                	jmp    800a87 <strncmp+0x17>
		n--, p++, q++;
  800a81:	83 c0 01             	add    $0x1,%eax
  800a84:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a87:	39 d8                	cmp    %ebx,%eax
  800a89:	74 15                	je     800aa0 <strncmp+0x30>
  800a8b:	0f b6 08             	movzbl (%eax),%ecx
  800a8e:	84 c9                	test   %cl,%cl
  800a90:	74 04                	je     800a96 <strncmp+0x26>
  800a92:	3a 0a                	cmp    (%edx),%cl
  800a94:	74 eb                	je     800a81 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a96:	0f b6 00             	movzbl (%eax),%eax
  800a99:	0f b6 12             	movzbl (%edx),%edx
  800a9c:	29 d0                	sub    %edx,%eax
  800a9e:	eb 05                	jmp    800aa5 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800aa0:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800aa5:	5b                   	pop    %ebx
  800aa6:	5d                   	pop    %ebp
  800aa7:	c3                   	ret    

00800aa8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800aa8:	55                   	push   %ebp
  800aa9:	89 e5                	mov    %esp,%ebp
  800aab:	8b 45 08             	mov    0x8(%ebp),%eax
  800aae:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ab2:	eb 07                	jmp    800abb <strchr+0x13>
		if (*s == c)
  800ab4:	38 ca                	cmp    %cl,%dl
  800ab6:	74 0f                	je     800ac7 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ab8:	83 c0 01             	add    $0x1,%eax
  800abb:	0f b6 10             	movzbl (%eax),%edx
  800abe:	84 d2                	test   %dl,%dl
  800ac0:	75 f2                	jne    800ab4 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800ac2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ac7:	5d                   	pop    %ebp
  800ac8:	c3                   	ret    

00800ac9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ac9:	55                   	push   %ebp
  800aca:	89 e5                	mov    %esp,%ebp
  800acc:	8b 45 08             	mov    0x8(%ebp),%eax
  800acf:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ad3:	eb 03                	jmp    800ad8 <strfind+0xf>
  800ad5:	83 c0 01             	add    $0x1,%eax
  800ad8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800adb:	38 ca                	cmp    %cl,%dl
  800add:	74 04                	je     800ae3 <strfind+0x1a>
  800adf:	84 d2                	test   %dl,%dl
  800ae1:	75 f2                	jne    800ad5 <strfind+0xc>
			break;
	return (char *) s;
}
  800ae3:	5d                   	pop    %ebp
  800ae4:	c3                   	ret    

00800ae5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ae5:	55                   	push   %ebp
  800ae6:	89 e5                	mov    %esp,%ebp
  800ae8:	57                   	push   %edi
  800ae9:	56                   	push   %esi
  800aea:	53                   	push   %ebx
  800aeb:	8b 7d 08             	mov    0x8(%ebp),%edi
  800aee:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800af1:	85 c9                	test   %ecx,%ecx
  800af3:	74 36                	je     800b2b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800af5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800afb:	75 28                	jne    800b25 <memset+0x40>
  800afd:	f6 c1 03             	test   $0x3,%cl
  800b00:	75 23                	jne    800b25 <memset+0x40>
		c &= 0xFF;
  800b02:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b06:	89 d3                	mov    %edx,%ebx
  800b08:	c1 e3 08             	shl    $0x8,%ebx
  800b0b:	89 d6                	mov    %edx,%esi
  800b0d:	c1 e6 18             	shl    $0x18,%esi
  800b10:	89 d0                	mov    %edx,%eax
  800b12:	c1 e0 10             	shl    $0x10,%eax
  800b15:	09 f0                	or     %esi,%eax
  800b17:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b19:	89 d8                	mov    %ebx,%eax
  800b1b:	09 d0                	or     %edx,%eax
  800b1d:	c1 e9 02             	shr    $0x2,%ecx
  800b20:	fc                   	cld    
  800b21:	f3 ab                	rep stos %eax,%es:(%edi)
  800b23:	eb 06                	jmp    800b2b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b25:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b28:	fc                   	cld    
  800b29:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b2b:	89 f8                	mov    %edi,%eax
  800b2d:	5b                   	pop    %ebx
  800b2e:	5e                   	pop    %esi
  800b2f:	5f                   	pop    %edi
  800b30:	5d                   	pop    %ebp
  800b31:	c3                   	ret    

00800b32 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b32:	55                   	push   %ebp
  800b33:	89 e5                	mov    %esp,%ebp
  800b35:	57                   	push   %edi
  800b36:	56                   	push   %esi
  800b37:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b3d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b40:	39 c6                	cmp    %eax,%esi
  800b42:	73 35                	jae    800b79 <memmove+0x47>
  800b44:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b47:	39 d0                	cmp    %edx,%eax
  800b49:	73 2e                	jae    800b79 <memmove+0x47>
		s += n;
		d += n;
  800b4b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b4e:	89 d6                	mov    %edx,%esi
  800b50:	09 fe                	or     %edi,%esi
  800b52:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b58:	75 13                	jne    800b6d <memmove+0x3b>
  800b5a:	f6 c1 03             	test   $0x3,%cl
  800b5d:	75 0e                	jne    800b6d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b5f:	83 ef 04             	sub    $0x4,%edi
  800b62:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b65:	c1 e9 02             	shr    $0x2,%ecx
  800b68:	fd                   	std    
  800b69:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b6b:	eb 09                	jmp    800b76 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b6d:	83 ef 01             	sub    $0x1,%edi
  800b70:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b73:	fd                   	std    
  800b74:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b76:	fc                   	cld    
  800b77:	eb 1d                	jmp    800b96 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b79:	89 f2                	mov    %esi,%edx
  800b7b:	09 c2                	or     %eax,%edx
  800b7d:	f6 c2 03             	test   $0x3,%dl
  800b80:	75 0f                	jne    800b91 <memmove+0x5f>
  800b82:	f6 c1 03             	test   $0x3,%cl
  800b85:	75 0a                	jne    800b91 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b87:	c1 e9 02             	shr    $0x2,%ecx
  800b8a:	89 c7                	mov    %eax,%edi
  800b8c:	fc                   	cld    
  800b8d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b8f:	eb 05                	jmp    800b96 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b91:	89 c7                	mov    %eax,%edi
  800b93:	fc                   	cld    
  800b94:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b96:	5e                   	pop    %esi
  800b97:	5f                   	pop    %edi
  800b98:	5d                   	pop    %ebp
  800b99:	c3                   	ret    

00800b9a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b9a:	55                   	push   %ebp
  800b9b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b9d:	ff 75 10             	pushl  0x10(%ebp)
  800ba0:	ff 75 0c             	pushl  0xc(%ebp)
  800ba3:	ff 75 08             	pushl  0x8(%ebp)
  800ba6:	e8 87 ff ff ff       	call   800b32 <memmove>
}
  800bab:	c9                   	leave  
  800bac:	c3                   	ret    

00800bad <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bad:	55                   	push   %ebp
  800bae:	89 e5                	mov    %esp,%ebp
  800bb0:	56                   	push   %esi
  800bb1:	53                   	push   %ebx
  800bb2:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bb8:	89 c6                	mov    %eax,%esi
  800bba:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bbd:	eb 1a                	jmp    800bd9 <memcmp+0x2c>
		if (*s1 != *s2)
  800bbf:	0f b6 08             	movzbl (%eax),%ecx
  800bc2:	0f b6 1a             	movzbl (%edx),%ebx
  800bc5:	38 d9                	cmp    %bl,%cl
  800bc7:	74 0a                	je     800bd3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800bc9:	0f b6 c1             	movzbl %cl,%eax
  800bcc:	0f b6 db             	movzbl %bl,%ebx
  800bcf:	29 d8                	sub    %ebx,%eax
  800bd1:	eb 0f                	jmp    800be2 <memcmp+0x35>
		s1++, s2++;
  800bd3:	83 c0 01             	add    $0x1,%eax
  800bd6:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bd9:	39 f0                	cmp    %esi,%eax
  800bdb:	75 e2                	jne    800bbf <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bdd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800be2:	5b                   	pop    %ebx
  800be3:	5e                   	pop    %esi
  800be4:	5d                   	pop    %ebp
  800be5:	c3                   	ret    

00800be6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800be6:	55                   	push   %ebp
  800be7:	89 e5                	mov    %esp,%ebp
  800be9:	53                   	push   %ebx
  800bea:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bed:	89 c1                	mov    %eax,%ecx
  800bef:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800bf2:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bf6:	eb 0a                	jmp    800c02 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bf8:	0f b6 10             	movzbl (%eax),%edx
  800bfb:	39 da                	cmp    %ebx,%edx
  800bfd:	74 07                	je     800c06 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bff:	83 c0 01             	add    $0x1,%eax
  800c02:	39 c8                	cmp    %ecx,%eax
  800c04:	72 f2                	jb     800bf8 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c06:	5b                   	pop    %ebx
  800c07:	5d                   	pop    %ebp
  800c08:	c3                   	ret    

00800c09 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c09:	55                   	push   %ebp
  800c0a:	89 e5                	mov    %esp,%ebp
  800c0c:	57                   	push   %edi
  800c0d:	56                   	push   %esi
  800c0e:	53                   	push   %ebx
  800c0f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c12:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c15:	eb 03                	jmp    800c1a <strtol+0x11>
		s++;
  800c17:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c1a:	0f b6 01             	movzbl (%ecx),%eax
  800c1d:	3c 20                	cmp    $0x20,%al
  800c1f:	74 f6                	je     800c17 <strtol+0xe>
  800c21:	3c 09                	cmp    $0x9,%al
  800c23:	74 f2                	je     800c17 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c25:	3c 2b                	cmp    $0x2b,%al
  800c27:	75 0a                	jne    800c33 <strtol+0x2a>
		s++;
  800c29:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c2c:	bf 00 00 00 00       	mov    $0x0,%edi
  800c31:	eb 11                	jmp    800c44 <strtol+0x3b>
  800c33:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c38:	3c 2d                	cmp    $0x2d,%al
  800c3a:	75 08                	jne    800c44 <strtol+0x3b>
		s++, neg = 1;
  800c3c:	83 c1 01             	add    $0x1,%ecx
  800c3f:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c44:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c4a:	75 15                	jne    800c61 <strtol+0x58>
  800c4c:	80 39 30             	cmpb   $0x30,(%ecx)
  800c4f:	75 10                	jne    800c61 <strtol+0x58>
  800c51:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c55:	75 7c                	jne    800cd3 <strtol+0xca>
		s += 2, base = 16;
  800c57:	83 c1 02             	add    $0x2,%ecx
  800c5a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c5f:	eb 16                	jmp    800c77 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c61:	85 db                	test   %ebx,%ebx
  800c63:	75 12                	jne    800c77 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c65:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c6a:	80 39 30             	cmpb   $0x30,(%ecx)
  800c6d:	75 08                	jne    800c77 <strtol+0x6e>
		s++, base = 8;
  800c6f:	83 c1 01             	add    $0x1,%ecx
  800c72:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c77:	b8 00 00 00 00       	mov    $0x0,%eax
  800c7c:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c7f:	0f b6 11             	movzbl (%ecx),%edx
  800c82:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c85:	89 f3                	mov    %esi,%ebx
  800c87:	80 fb 09             	cmp    $0x9,%bl
  800c8a:	77 08                	ja     800c94 <strtol+0x8b>
			dig = *s - '0';
  800c8c:	0f be d2             	movsbl %dl,%edx
  800c8f:	83 ea 30             	sub    $0x30,%edx
  800c92:	eb 22                	jmp    800cb6 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c94:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c97:	89 f3                	mov    %esi,%ebx
  800c99:	80 fb 19             	cmp    $0x19,%bl
  800c9c:	77 08                	ja     800ca6 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c9e:	0f be d2             	movsbl %dl,%edx
  800ca1:	83 ea 57             	sub    $0x57,%edx
  800ca4:	eb 10                	jmp    800cb6 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ca6:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ca9:	89 f3                	mov    %esi,%ebx
  800cab:	80 fb 19             	cmp    $0x19,%bl
  800cae:	77 16                	ja     800cc6 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800cb0:	0f be d2             	movsbl %dl,%edx
  800cb3:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800cb6:	3b 55 10             	cmp    0x10(%ebp),%edx
  800cb9:	7d 0b                	jge    800cc6 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800cbb:	83 c1 01             	add    $0x1,%ecx
  800cbe:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cc2:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800cc4:	eb b9                	jmp    800c7f <strtol+0x76>

	if (endptr)
  800cc6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cca:	74 0d                	je     800cd9 <strtol+0xd0>
		*endptr = (char *) s;
  800ccc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ccf:	89 0e                	mov    %ecx,(%esi)
  800cd1:	eb 06                	jmp    800cd9 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cd3:	85 db                	test   %ebx,%ebx
  800cd5:	74 98                	je     800c6f <strtol+0x66>
  800cd7:	eb 9e                	jmp    800c77 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800cd9:	89 c2                	mov    %eax,%edx
  800cdb:	f7 da                	neg    %edx
  800cdd:	85 ff                	test   %edi,%edi
  800cdf:	0f 45 c2             	cmovne %edx,%eax
}
  800ce2:	5b                   	pop    %ebx
  800ce3:	5e                   	pop    %esi
  800ce4:	5f                   	pop    %edi
  800ce5:	5d                   	pop    %ebp
  800ce6:	c3                   	ret    

00800ce7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	57                   	push   %edi
  800ceb:	56                   	push   %esi
  800cec:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ced:	b8 00 00 00 00       	mov    $0x0,%eax
  800cf2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf8:	89 c3                	mov    %eax,%ebx
  800cfa:	89 c7                	mov    %eax,%edi
  800cfc:	89 c6                	mov    %eax,%esi
  800cfe:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d00:	5b                   	pop    %ebx
  800d01:	5e                   	pop    %esi
  800d02:	5f                   	pop    %edi
  800d03:	5d                   	pop    %ebp
  800d04:	c3                   	ret    

00800d05 <sys_cgetc>:

int
sys_cgetc(void)
{
  800d05:	55                   	push   %ebp
  800d06:	89 e5                	mov    %esp,%ebp
  800d08:	57                   	push   %edi
  800d09:	56                   	push   %esi
  800d0a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d10:	b8 01 00 00 00       	mov    $0x1,%eax
  800d15:	89 d1                	mov    %edx,%ecx
  800d17:	89 d3                	mov    %edx,%ebx
  800d19:	89 d7                	mov    %edx,%edi
  800d1b:	89 d6                	mov    %edx,%esi
  800d1d:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d1f:	5b                   	pop    %ebx
  800d20:	5e                   	pop    %esi
  800d21:	5f                   	pop    %edi
  800d22:	5d                   	pop    %ebp
  800d23:	c3                   	ret    

00800d24 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d24:	55                   	push   %ebp
  800d25:	89 e5                	mov    %esp,%ebp
  800d27:	57                   	push   %edi
  800d28:	56                   	push   %esi
  800d29:	53                   	push   %ebx
  800d2a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d32:	b8 03 00 00 00       	mov    $0x3,%eax
  800d37:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3a:	89 cb                	mov    %ecx,%ebx
  800d3c:	89 cf                	mov    %ecx,%edi
  800d3e:	89 ce                	mov    %ecx,%esi
  800d40:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d42:	85 c0                	test   %eax,%eax
  800d44:	7e 17                	jle    800d5d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d46:	83 ec 0c             	sub    $0xc,%esp
  800d49:	50                   	push   %eax
  800d4a:	6a 03                	push   $0x3
  800d4c:	68 5f 26 80 00       	push   $0x80265f
  800d51:	6a 23                	push   $0x23
  800d53:	68 7c 26 80 00       	push   $0x80267c
  800d58:	e8 c7 f5 ff ff       	call   800324 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d60:	5b                   	pop    %ebx
  800d61:	5e                   	pop    %esi
  800d62:	5f                   	pop    %edi
  800d63:	5d                   	pop    %ebp
  800d64:	c3                   	ret    

00800d65 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d65:	55                   	push   %ebp
  800d66:	89 e5                	mov    %esp,%ebp
  800d68:	57                   	push   %edi
  800d69:	56                   	push   %esi
  800d6a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d70:	b8 02 00 00 00       	mov    $0x2,%eax
  800d75:	89 d1                	mov    %edx,%ecx
  800d77:	89 d3                	mov    %edx,%ebx
  800d79:	89 d7                	mov    %edx,%edi
  800d7b:	89 d6                	mov    %edx,%esi
  800d7d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d7f:	5b                   	pop    %ebx
  800d80:	5e                   	pop    %esi
  800d81:	5f                   	pop    %edi
  800d82:	5d                   	pop    %ebp
  800d83:	c3                   	ret    

00800d84 <sys_yield>:

void
sys_yield(void)
{
  800d84:	55                   	push   %ebp
  800d85:	89 e5                	mov    %esp,%ebp
  800d87:	57                   	push   %edi
  800d88:	56                   	push   %esi
  800d89:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d8f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d94:	89 d1                	mov    %edx,%ecx
  800d96:	89 d3                	mov    %edx,%ebx
  800d98:	89 d7                	mov    %edx,%edi
  800d9a:	89 d6                	mov    %edx,%esi
  800d9c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d9e:	5b                   	pop    %ebx
  800d9f:	5e                   	pop    %esi
  800da0:	5f                   	pop    %edi
  800da1:	5d                   	pop    %ebp
  800da2:	c3                   	ret    

00800da3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800da3:	55                   	push   %ebp
  800da4:	89 e5                	mov    %esp,%ebp
  800da6:	57                   	push   %edi
  800da7:	56                   	push   %esi
  800da8:	53                   	push   %ebx
  800da9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dac:	be 00 00 00 00       	mov    $0x0,%esi
  800db1:	b8 04 00 00 00       	mov    $0x4,%eax
  800db6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dbf:	89 f7                	mov    %esi,%edi
  800dc1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dc3:	85 c0                	test   %eax,%eax
  800dc5:	7e 17                	jle    800dde <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc7:	83 ec 0c             	sub    $0xc,%esp
  800dca:	50                   	push   %eax
  800dcb:	6a 04                	push   $0x4
  800dcd:	68 5f 26 80 00       	push   $0x80265f
  800dd2:	6a 23                	push   $0x23
  800dd4:	68 7c 26 80 00       	push   $0x80267c
  800dd9:	e8 46 f5 ff ff       	call   800324 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800dde:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de1:	5b                   	pop    %ebx
  800de2:	5e                   	pop    %esi
  800de3:	5f                   	pop    %edi
  800de4:	5d                   	pop    %ebp
  800de5:	c3                   	ret    

00800de6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800de6:	55                   	push   %ebp
  800de7:	89 e5                	mov    %esp,%ebp
  800de9:	57                   	push   %edi
  800dea:	56                   	push   %esi
  800deb:	53                   	push   %ebx
  800dec:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800def:	b8 05 00 00 00       	mov    $0x5,%eax
  800df4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfa:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dfd:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e00:	8b 75 18             	mov    0x18(%ebp),%esi
  800e03:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e05:	85 c0                	test   %eax,%eax
  800e07:	7e 17                	jle    800e20 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e09:	83 ec 0c             	sub    $0xc,%esp
  800e0c:	50                   	push   %eax
  800e0d:	6a 05                	push   $0x5
  800e0f:	68 5f 26 80 00       	push   $0x80265f
  800e14:	6a 23                	push   $0x23
  800e16:	68 7c 26 80 00       	push   $0x80267c
  800e1b:	e8 04 f5 ff ff       	call   800324 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e20:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e23:	5b                   	pop    %ebx
  800e24:	5e                   	pop    %esi
  800e25:	5f                   	pop    %edi
  800e26:	5d                   	pop    %ebp
  800e27:	c3                   	ret    

00800e28 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e28:	55                   	push   %ebp
  800e29:	89 e5                	mov    %esp,%ebp
  800e2b:	57                   	push   %edi
  800e2c:	56                   	push   %esi
  800e2d:	53                   	push   %ebx
  800e2e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e31:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e36:	b8 06 00 00 00       	mov    $0x6,%eax
  800e3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e41:	89 df                	mov    %ebx,%edi
  800e43:	89 de                	mov    %ebx,%esi
  800e45:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e47:	85 c0                	test   %eax,%eax
  800e49:	7e 17                	jle    800e62 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e4b:	83 ec 0c             	sub    $0xc,%esp
  800e4e:	50                   	push   %eax
  800e4f:	6a 06                	push   $0x6
  800e51:	68 5f 26 80 00       	push   $0x80265f
  800e56:	6a 23                	push   $0x23
  800e58:	68 7c 26 80 00       	push   $0x80267c
  800e5d:	e8 c2 f4 ff ff       	call   800324 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e62:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e65:	5b                   	pop    %ebx
  800e66:	5e                   	pop    %esi
  800e67:	5f                   	pop    %edi
  800e68:	5d                   	pop    %ebp
  800e69:	c3                   	ret    

00800e6a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e6a:	55                   	push   %ebp
  800e6b:	89 e5                	mov    %esp,%ebp
  800e6d:	57                   	push   %edi
  800e6e:	56                   	push   %esi
  800e6f:	53                   	push   %ebx
  800e70:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e73:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e78:	b8 08 00 00 00       	mov    $0x8,%eax
  800e7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e80:	8b 55 08             	mov    0x8(%ebp),%edx
  800e83:	89 df                	mov    %ebx,%edi
  800e85:	89 de                	mov    %ebx,%esi
  800e87:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e89:	85 c0                	test   %eax,%eax
  800e8b:	7e 17                	jle    800ea4 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e8d:	83 ec 0c             	sub    $0xc,%esp
  800e90:	50                   	push   %eax
  800e91:	6a 08                	push   $0x8
  800e93:	68 5f 26 80 00       	push   $0x80265f
  800e98:	6a 23                	push   $0x23
  800e9a:	68 7c 26 80 00       	push   $0x80267c
  800e9f:	e8 80 f4 ff ff       	call   800324 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ea4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ea7:	5b                   	pop    %ebx
  800ea8:	5e                   	pop    %esi
  800ea9:	5f                   	pop    %edi
  800eaa:	5d                   	pop    %ebp
  800eab:	c3                   	ret    

00800eac <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800eac:	55                   	push   %ebp
  800ead:	89 e5                	mov    %esp,%ebp
  800eaf:	57                   	push   %edi
  800eb0:	56                   	push   %esi
  800eb1:	53                   	push   %ebx
  800eb2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eba:	b8 09 00 00 00       	mov    $0x9,%eax
  800ebf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec5:	89 df                	mov    %ebx,%edi
  800ec7:	89 de                	mov    %ebx,%esi
  800ec9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ecb:	85 c0                	test   %eax,%eax
  800ecd:	7e 17                	jle    800ee6 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ecf:	83 ec 0c             	sub    $0xc,%esp
  800ed2:	50                   	push   %eax
  800ed3:	6a 09                	push   $0x9
  800ed5:	68 5f 26 80 00       	push   $0x80265f
  800eda:	6a 23                	push   $0x23
  800edc:	68 7c 26 80 00       	push   $0x80267c
  800ee1:	e8 3e f4 ff ff       	call   800324 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ee6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ee9:	5b                   	pop    %ebx
  800eea:	5e                   	pop    %esi
  800eeb:	5f                   	pop    %edi
  800eec:	5d                   	pop    %ebp
  800eed:	c3                   	ret    

00800eee <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800eee:	55                   	push   %ebp
  800eef:	89 e5                	mov    %esp,%ebp
  800ef1:	57                   	push   %edi
  800ef2:	56                   	push   %esi
  800ef3:	53                   	push   %ebx
  800ef4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ef7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800efc:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f04:	8b 55 08             	mov    0x8(%ebp),%edx
  800f07:	89 df                	mov    %ebx,%edi
  800f09:	89 de                	mov    %ebx,%esi
  800f0b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f0d:	85 c0                	test   %eax,%eax
  800f0f:	7e 17                	jle    800f28 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f11:	83 ec 0c             	sub    $0xc,%esp
  800f14:	50                   	push   %eax
  800f15:	6a 0a                	push   $0xa
  800f17:	68 5f 26 80 00       	push   $0x80265f
  800f1c:	6a 23                	push   $0x23
  800f1e:	68 7c 26 80 00       	push   $0x80267c
  800f23:	e8 fc f3 ff ff       	call   800324 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f28:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f2b:	5b                   	pop    %ebx
  800f2c:	5e                   	pop    %esi
  800f2d:	5f                   	pop    %edi
  800f2e:	5d                   	pop    %ebp
  800f2f:	c3                   	ret    

00800f30 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f30:	55                   	push   %ebp
  800f31:	89 e5                	mov    %esp,%ebp
  800f33:	57                   	push   %edi
  800f34:	56                   	push   %esi
  800f35:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f36:	be 00 00 00 00       	mov    $0x0,%esi
  800f3b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f43:	8b 55 08             	mov    0x8(%ebp),%edx
  800f46:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f49:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f4c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f4e:	5b                   	pop    %ebx
  800f4f:	5e                   	pop    %esi
  800f50:	5f                   	pop    %edi
  800f51:	5d                   	pop    %ebp
  800f52:	c3                   	ret    

00800f53 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f53:	55                   	push   %ebp
  800f54:	89 e5                	mov    %esp,%ebp
  800f56:	57                   	push   %edi
  800f57:	56                   	push   %esi
  800f58:	53                   	push   %ebx
  800f59:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f5c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f61:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f66:	8b 55 08             	mov    0x8(%ebp),%edx
  800f69:	89 cb                	mov    %ecx,%ebx
  800f6b:	89 cf                	mov    %ecx,%edi
  800f6d:	89 ce                	mov    %ecx,%esi
  800f6f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f71:	85 c0                	test   %eax,%eax
  800f73:	7e 17                	jle    800f8c <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f75:	83 ec 0c             	sub    $0xc,%esp
  800f78:	50                   	push   %eax
  800f79:	6a 0d                	push   $0xd
  800f7b:	68 5f 26 80 00       	push   $0x80265f
  800f80:	6a 23                	push   $0x23
  800f82:	68 7c 26 80 00       	push   $0x80267c
  800f87:	e8 98 f3 ff ff       	call   800324 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f8c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f8f:	5b                   	pop    %ebx
  800f90:	5e                   	pop    %esi
  800f91:	5f                   	pop    %edi
  800f92:	5d                   	pop    %ebp
  800f93:	c3                   	ret    

00800f94 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  800f94:	55                   	push   %ebp
  800f95:	89 e5                	mov    %esp,%ebp
  800f97:	8b 55 08             	mov    0x8(%ebp),%edx
  800f9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f9d:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  800fa0:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  800fa2:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  800fa5:	83 3a 01             	cmpl   $0x1,(%edx)
  800fa8:	7e 09                	jle    800fb3 <argstart+0x1f>
  800faa:	ba 08 23 80 00       	mov    $0x802308,%edx
  800faf:	85 c9                	test   %ecx,%ecx
  800fb1:	75 05                	jne    800fb8 <argstart+0x24>
  800fb3:	ba 00 00 00 00       	mov    $0x0,%edx
  800fb8:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  800fbb:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  800fc2:	5d                   	pop    %ebp
  800fc3:	c3                   	ret    

00800fc4 <argnext>:

int
argnext(struct Argstate *args)
{
  800fc4:	55                   	push   %ebp
  800fc5:	89 e5                	mov    %esp,%ebp
  800fc7:	53                   	push   %ebx
  800fc8:	83 ec 04             	sub    $0x4,%esp
  800fcb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  800fce:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  800fd5:	8b 43 08             	mov    0x8(%ebx),%eax
  800fd8:	85 c0                	test   %eax,%eax
  800fda:	74 6f                	je     80104b <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  800fdc:	80 38 00             	cmpb   $0x0,(%eax)
  800fdf:	75 4e                	jne    80102f <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  800fe1:	8b 0b                	mov    (%ebx),%ecx
  800fe3:	83 39 01             	cmpl   $0x1,(%ecx)
  800fe6:	74 55                	je     80103d <argnext+0x79>
		    || args->argv[1][0] != '-'
  800fe8:	8b 53 04             	mov    0x4(%ebx),%edx
  800feb:	8b 42 04             	mov    0x4(%edx),%eax
  800fee:	80 38 2d             	cmpb   $0x2d,(%eax)
  800ff1:	75 4a                	jne    80103d <argnext+0x79>
		    || args->argv[1][1] == '\0')
  800ff3:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800ff7:	74 44                	je     80103d <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  800ff9:	83 c0 01             	add    $0x1,%eax
  800ffc:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800fff:	83 ec 04             	sub    $0x4,%esp
  801002:	8b 01                	mov    (%ecx),%eax
  801004:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  80100b:	50                   	push   %eax
  80100c:	8d 42 08             	lea    0x8(%edx),%eax
  80100f:	50                   	push   %eax
  801010:	83 c2 04             	add    $0x4,%edx
  801013:	52                   	push   %edx
  801014:	e8 19 fb ff ff       	call   800b32 <memmove>
		(*args->argc)--;
  801019:	8b 03                	mov    (%ebx),%eax
  80101b:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  80101e:	8b 43 08             	mov    0x8(%ebx),%eax
  801021:	83 c4 10             	add    $0x10,%esp
  801024:	80 38 2d             	cmpb   $0x2d,(%eax)
  801027:	75 06                	jne    80102f <argnext+0x6b>
  801029:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  80102d:	74 0e                	je     80103d <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  80102f:	8b 53 08             	mov    0x8(%ebx),%edx
  801032:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801035:	83 c2 01             	add    $0x1,%edx
  801038:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  80103b:	eb 13                	jmp    801050 <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  80103d:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801044:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801049:	eb 05                	jmp    801050 <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  80104b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801050:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801053:	c9                   	leave  
  801054:	c3                   	ret    

00801055 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801055:	55                   	push   %ebp
  801056:	89 e5                	mov    %esp,%ebp
  801058:	53                   	push   %ebx
  801059:	83 ec 04             	sub    $0x4,%esp
  80105c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  80105f:	8b 43 08             	mov    0x8(%ebx),%eax
  801062:	85 c0                	test   %eax,%eax
  801064:	74 58                	je     8010be <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  801066:	80 38 00             	cmpb   $0x0,(%eax)
  801069:	74 0c                	je     801077 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  80106b:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  80106e:	c7 43 08 08 23 80 00 	movl   $0x802308,0x8(%ebx)
  801075:	eb 42                	jmp    8010b9 <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  801077:	8b 13                	mov    (%ebx),%edx
  801079:	83 3a 01             	cmpl   $0x1,(%edx)
  80107c:	7e 2d                	jle    8010ab <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  80107e:	8b 43 04             	mov    0x4(%ebx),%eax
  801081:	8b 48 04             	mov    0x4(%eax),%ecx
  801084:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801087:	83 ec 04             	sub    $0x4,%esp
  80108a:	8b 12                	mov    (%edx),%edx
  80108c:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  801093:	52                   	push   %edx
  801094:	8d 50 08             	lea    0x8(%eax),%edx
  801097:	52                   	push   %edx
  801098:	83 c0 04             	add    $0x4,%eax
  80109b:	50                   	push   %eax
  80109c:	e8 91 fa ff ff       	call   800b32 <memmove>
		(*args->argc)--;
  8010a1:	8b 03                	mov    (%ebx),%eax
  8010a3:	83 28 01             	subl   $0x1,(%eax)
  8010a6:	83 c4 10             	add    $0x10,%esp
  8010a9:	eb 0e                	jmp    8010b9 <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  8010ab:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  8010b2:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  8010b9:	8b 43 0c             	mov    0xc(%ebx),%eax
  8010bc:	eb 05                	jmp    8010c3 <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  8010be:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  8010c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010c6:	c9                   	leave  
  8010c7:	c3                   	ret    

008010c8 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  8010c8:	55                   	push   %ebp
  8010c9:	89 e5                	mov    %esp,%ebp
  8010cb:	83 ec 08             	sub    $0x8,%esp
  8010ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  8010d1:	8b 51 0c             	mov    0xc(%ecx),%edx
  8010d4:	89 d0                	mov    %edx,%eax
  8010d6:	85 d2                	test   %edx,%edx
  8010d8:	75 0c                	jne    8010e6 <argvalue+0x1e>
  8010da:	83 ec 0c             	sub    $0xc,%esp
  8010dd:	51                   	push   %ecx
  8010de:	e8 72 ff ff ff       	call   801055 <argnextvalue>
  8010e3:	83 c4 10             	add    $0x10,%esp
}
  8010e6:	c9                   	leave  
  8010e7:	c3                   	ret    

008010e8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010e8:	55                   	push   %ebp
  8010e9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ee:	05 00 00 00 30       	add    $0x30000000,%eax
  8010f3:	c1 e8 0c             	shr    $0xc,%eax
}
  8010f6:	5d                   	pop    %ebp
  8010f7:	c3                   	ret    

008010f8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010f8:	55                   	push   %ebp
  8010f9:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8010fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8010fe:	05 00 00 00 30       	add    $0x30000000,%eax
  801103:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801108:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80110d:	5d                   	pop    %ebp
  80110e:	c3                   	ret    

0080110f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80110f:	55                   	push   %ebp
  801110:	89 e5                	mov    %esp,%ebp
  801112:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801115:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80111a:	89 c2                	mov    %eax,%edx
  80111c:	c1 ea 16             	shr    $0x16,%edx
  80111f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801126:	f6 c2 01             	test   $0x1,%dl
  801129:	74 11                	je     80113c <fd_alloc+0x2d>
  80112b:	89 c2                	mov    %eax,%edx
  80112d:	c1 ea 0c             	shr    $0xc,%edx
  801130:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801137:	f6 c2 01             	test   $0x1,%dl
  80113a:	75 09                	jne    801145 <fd_alloc+0x36>
			*fd_store = fd;
  80113c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80113e:	b8 00 00 00 00       	mov    $0x0,%eax
  801143:	eb 17                	jmp    80115c <fd_alloc+0x4d>
  801145:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80114a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80114f:	75 c9                	jne    80111a <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801151:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801157:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80115c:	5d                   	pop    %ebp
  80115d:	c3                   	ret    

0080115e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80115e:	55                   	push   %ebp
  80115f:	89 e5                	mov    %esp,%ebp
  801161:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801164:	83 f8 1f             	cmp    $0x1f,%eax
  801167:	77 36                	ja     80119f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801169:	c1 e0 0c             	shl    $0xc,%eax
  80116c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801171:	89 c2                	mov    %eax,%edx
  801173:	c1 ea 16             	shr    $0x16,%edx
  801176:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80117d:	f6 c2 01             	test   $0x1,%dl
  801180:	74 24                	je     8011a6 <fd_lookup+0x48>
  801182:	89 c2                	mov    %eax,%edx
  801184:	c1 ea 0c             	shr    $0xc,%edx
  801187:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80118e:	f6 c2 01             	test   $0x1,%dl
  801191:	74 1a                	je     8011ad <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801193:	8b 55 0c             	mov    0xc(%ebp),%edx
  801196:	89 02                	mov    %eax,(%edx)
	return 0;
  801198:	b8 00 00 00 00       	mov    $0x0,%eax
  80119d:	eb 13                	jmp    8011b2 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80119f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011a4:	eb 0c                	jmp    8011b2 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011a6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011ab:	eb 05                	jmp    8011b2 <fd_lookup+0x54>
  8011ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8011b2:	5d                   	pop    %ebp
  8011b3:	c3                   	ret    

008011b4 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011b4:	55                   	push   %ebp
  8011b5:	89 e5                	mov    %esp,%ebp
  8011b7:	83 ec 08             	sub    $0x8,%esp
  8011ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011bd:	ba 0c 27 80 00       	mov    $0x80270c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8011c2:	eb 13                	jmp    8011d7 <dev_lookup+0x23>
  8011c4:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8011c7:	39 08                	cmp    %ecx,(%eax)
  8011c9:	75 0c                	jne    8011d7 <dev_lookup+0x23>
			*dev = devtab[i];
  8011cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011ce:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8011d5:	eb 2e                	jmp    801205 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011d7:	8b 02                	mov    (%edx),%eax
  8011d9:	85 c0                	test   %eax,%eax
  8011db:	75 e7                	jne    8011c4 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011dd:	a1 20 44 80 00       	mov    0x804420,%eax
  8011e2:	8b 40 48             	mov    0x48(%eax),%eax
  8011e5:	83 ec 04             	sub    $0x4,%esp
  8011e8:	51                   	push   %ecx
  8011e9:	50                   	push   %eax
  8011ea:	68 8c 26 80 00       	push   $0x80268c
  8011ef:	e8 09 f2 ff ff       	call   8003fd <cprintf>
	*dev = 0;
  8011f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011f7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011fd:	83 c4 10             	add    $0x10,%esp
  801200:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801205:	c9                   	leave  
  801206:	c3                   	ret    

00801207 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801207:	55                   	push   %ebp
  801208:	89 e5                	mov    %esp,%ebp
  80120a:	56                   	push   %esi
  80120b:	53                   	push   %ebx
  80120c:	83 ec 10             	sub    $0x10,%esp
  80120f:	8b 75 08             	mov    0x8(%ebp),%esi
  801212:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801215:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801218:	50                   	push   %eax
  801219:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80121f:	c1 e8 0c             	shr    $0xc,%eax
  801222:	50                   	push   %eax
  801223:	e8 36 ff ff ff       	call   80115e <fd_lookup>
  801228:	83 c4 08             	add    $0x8,%esp
  80122b:	85 c0                	test   %eax,%eax
  80122d:	78 05                	js     801234 <fd_close+0x2d>
	    || fd != fd2)
  80122f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801232:	74 0c                	je     801240 <fd_close+0x39>
		return (must_exist ? r : 0);
  801234:	84 db                	test   %bl,%bl
  801236:	ba 00 00 00 00       	mov    $0x0,%edx
  80123b:	0f 44 c2             	cmove  %edx,%eax
  80123e:	eb 41                	jmp    801281 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801240:	83 ec 08             	sub    $0x8,%esp
  801243:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801246:	50                   	push   %eax
  801247:	ff 36                	pushl  (%esi)
  801249:	e8 66 ff ff ff       	call   8011b4 <dev_lookup>
  80124e:	89 c3                	mov    %eax,%ebx
  801250:	83 c4 10             	add    $0x10,%esp
  801253:	85 c0                	test   %eax,%eax
  801255:	78 1a                	js     801271 <fd_close+0x6a>
		if (dev->dev_close)
  801257:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80125a:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80125d:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801262:	85 c0                	test   %eax,%eax
  801264:	74 0b                	je     801271 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801266:	83 ec 0c             	sub    $0xc,%esp
  801269:	56                   	push   %esi
  80126a:	ff d0                	call   *%eax
  80126c:	89 c3                	mov    %eax,%ebx
  80126e:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801271:	83 ec 08             	sub    $0x8,%esp
  801274:	56                   	push   %esi
  801275:	6a 00                	push   $0x0
  801277:	e8 ac fb ff ff       	call   800e28 <sys_page_unmap>
	return r;
  80127c:	83 c4 10             	add    $0x10,%esp
  80127f:	89 d8                	mov    %ebx,%eax
}
  801281:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801284:	5b                   	pop    %ebx
  801285:	5e                   	pop    %esi
  801286:	5d                   	pop    %ebp
  801287:	c3                   	ret    

00801288 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801288:	55                   	push   %ebp
  801289:	89 e5                	mov    %esp,%ebp
  80128b:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80128e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801291:	50                   	push   %eax
  801292:	ff 75 08             	pushl  0x8(%ebp)
  801295:	e8 c4 fe ff ff       	call   80115e <fd_lookup>
  80129a:	83 c4 08             	add    $0x8,%esp
  80129d:	85 c0                	test   %eax,%eax
  80129f:	78 10                	js     8012b1 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012a1:	83 ec 08             	sub    $0x8,%esp
  8012a4:	6a 01                	push   $0x1
  8012a6:	ff 75 f4             	pushl  -0xc(%ebp)
  8012a9:	e8 59 ff ff ff       	call   801207 <fd_close>
  8012ae:	83 c4 10             	add    $0x10,%esp
}
  8012b1:	c9                   	leave  
  8012b2:	c3                   	ret    

008012b3 <close_all>:

void
close_all(void)
{
  8012b3:	55                   	push   %ebp
  8012b4:	89 e5                	mov    %esp,%ebp
  8012b6:	53                   	push   %ebx
  8012b7:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012ba:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012bf:	83 ec 0c             	sub    $0xc,%esp
  8012c2:	53                   	push   %ebx
  8012c3:	e8 c0 ff ff ff       	call   801288 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012c8:	83 c3 01             	add    $0x1,%ebx
  8012cb:	83 c4 10             	add    $0x10,%esp
  8012ce:	83 fb 20             	cmp    $0x20,%ebx
  8012d1:	75 ec                	jne    8012bf <close_all+0xc>
		close(i);
}
  8012d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012d6:	c9                   	leave  
  8012d7:	c3                   	ret    

008012d8 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012d8:	55                   	push   %ebp
  8012d9:	89 e5                	mov    %esp,%ebp
  8012db:	57                   	push   %edi
  8012dc:	56                   	push   %esi
  8012dd:	53                   	push   %ebx
  8012de:	83 ec 2c             	sub    $0x2c,%esp
  8012e1:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012e4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012e7:	50                   	push   %eax
  8012e8:	ff 75 08             	pushl  0x8(%ebp)
  8012eb:	e8 6e fe ff ff       	call   80115e <fd_lookup>
  8012f0:	83 c4 08             	add    $0x8,%esp
  8012f3:	85 c0                	test   %eax,%eax
  8012f5:	0f 88 c1 00 00 00    	js     8013bc <dup+0xe4>
		return r;
	close(newfdnum);
  8012fb:	83 ec 0c             	sub    $0xc,%esp
  8012fe:	56                   	push   %esi
  8012ff:	e8 84 ff ff ff       	call   801288 <close>

	newfd = INDEX2FD(newfdnum);
  801304:	89 f3                	mov    %esi,%ebx
  801306:	c1 e3 0c             	shl    $0xc,%ebx
  801309:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80130f:	83 c4 04             	add    $0x4,%esp
  801312:	ff 75 e4             	pushl  -0x1c(%ebp)
  801315:	e8 de fd ff ff       	call   8010f8 <fd2data>
  80131a:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80131c:	89 1c 24             	mov    %ebx,(%esp)
  80131f:	e8 d4 fd ff ff       	call   8010f8 <fd2data>
  801324:	83 c4 10             	add    $0x10,%esp
  801327:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80132a:	89 f8                	mov    %edi,%eax
  80132c:	c1 e8 16             	shr    $0x16,%eax
  80132f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801336:	a8 01                	test   $0x1,%al
  801338:	74 37                	je     801371 <dup+0x99>
  80133a:	89 f8                	mov    %edi,%eax
  80133c:	c1 e8 0c             	shr    $0xc,%eax
  80133f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801346:	f6 c2 01             	test   $0x1,%dl
  801349:	74 26                	je     801371 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80134b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801352:	83 ec 0c             	sub    $0xc,%esp
  801355:	25 07 0e 00 00       	and    $0xe07,%eax
  80135a:	50                   	push   %eax
  80135b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80135e:	6a 00                	push   $0x0
  801360:	57                   	push   %edi
  801361:	6a 00                	push   $0x0
  801363:	e8 7e fa ff ff       	call   800de6 <sys_page_map>
  801368:	89 c7                	mov    %eax,%edi
  80136a:	83 c4 20             	add    $0x20,%esp
  80136d:	85 c0                	test   %eax,%eax
  80136f:	78 2e                	js     80139f <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801371:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801374:	89 d0                	mov    %edx,%eax
  801376:	c1 e8 0c             	shr    $0xc,%eax
  801379:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801380:	83 ec 0c             	sub    $0xc,%esp
  801383:	25 07 0e 00 00       	and    $0xe07,%eax
  801388:	50                   	push   %eax
  801389:	53                   	push   %ebx
  80138a:	6a 00                	push   $0x0
  80138c:	52                   	push   %edx
  80138d:	6a 00                	push   $0x0
  80138f:	e8 52 fa ff ff       	call   800de6 <sys_page_map>
  801394:	89 c7                	mov    %eax,%edi
  801396:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801399:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80139b:	85 ff                	test   %edi,%edi
  80139d:	79 1d                	jns    8013bc <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80139f:	83 ec 08             	sub    $0x8,%esp
  8013a2:	53                   	push   %ebx
  8013a3:	6a 00                	push   $0x0
  8013a5:	e8 7e fa ff ff       	call   800e28 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013aa:	83 c4 08             	add    $0x8,%esp
  8013ad:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013b0:	6a 00                	push   $0x0
  8013b2:	e8 71 fa ff ff       	call   800e28 <sys_page_unmap>
	return r;
  8013b7:	83 c4 10             	add    $0x10,%esp
  8013ba:	89 f8                	mov    %edi,%eax
}
  8013bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013bf:	5b                   	pop    %ebx
  8013c0:	5e                   	pop    %esi
  8013c1:	5f                   	pop    %edi
  8013c2:	5d                   	pop    %ebp
  8013c3:	c3                   	ret    

008013c4 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013c4:	55                   	push   %ebp
  8013c5:	89 e5                	mov    %esp,%ebp
  8013c7:	53                   	push   %ebx
  8013c8:	83 ec 14             	sub    $0x14,%esp
  8013cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013ce:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013d1:	50                   	push   %eax
  8013d2:	53                   	push   %ebx
  8013d3:	e8 86 fd ff ff       	call   80115e <fd_lookup>
  8013d8:	83 c4 08             	add    $0x8,%esp
  8013db:	89 c2                	mov    %eax,%edx
  8013dd:	85 c0                	test   %eax,%eax
  8013df:	78 6d                	js     80144e <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013e1:	83 ec 08             	sub    $0x8,%esp
  8013e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013e7:	50                   	push   %eax
  8013e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013eb:	ff 30                	pushl  (%eax)
  8013ed:	e8 c2 fd ff ff       	call   8011b4 <dev_lookup>
  8013f2:	83 c4 10             	add    $0x10,%esp
  8013f5:	85 c0                	test   %eax,%eax
  8013f7:	78 4c                	js     801445 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013f9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013fc:	8b 42 08             	mov    0x8(%edx),%eax
  8013ff:	83 e0 03             	and    $0x3,%eax
  801402:	83 f8 01             	cmp    $0x1,%eax
  801405:	75 21                	jne    801428 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801407:	a1 20 44 80 00       	mov    0x804420,%eax
  80140c:	8b 40 48             	mov    0x48(%eax),%eax
  80140f:	83 ec 04             	sub    $0x4,%esp
  801412:	53                   	push   %ebx
  801413:	50                   	push   %eax
  801414:	68 d0 26 80 00       	push   $0x8026d0
  801419:	e8 df ef ff ff       	call   8003fd <cprintf>
		return -E_INVAL;
  80141e:	83 c4 10             	add    $0x10,%esp
  801421:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801426:	eb 26                	jmp    80144e <read+0x8a>
	}
	if (!dev->dev_read)
  801428:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80142b:	8b 40 08             	mov    0x8(%eax),%eax
  80142e:	85 c0                	test   %eax,%eax
  801430:	74 17                	je     801449 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801432:	83 ec 04             	sub    $0x4,%esp
  801435:	ff 75 10             	pushl  0x10(%ebp)
  801438:	ff 75 0c             	pushl  0xc(%ebp)
  80143b:	52                   	push   %edx
  80143c:	ff d0                	call   *%eax
  80143e:	89 c2                	mov    %eax,%edx
  801440:	83 c4 10             	add    $0x10,%esp
  801443:	eb 09                	jmp    80144e <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801445:	89 c2                	mov    %eax,%edx
  801447:	eb 05                	jmp    80144e <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801449:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80144e:	89 d0                	mov    %edx,%eax
  801450:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801453:	c9                   	leave  
  801454:	c3                   	ret    

00801455 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801455:	55                   	push   %ebp
  801456:	89 e5                	mov    %esp,%ebp
  801458:	57                   	push   %edi
  801459:	56                   	push   %esi
  80145a:	53                   	push   %ebx
  80145b:	83 ec 0c             	sub    $0xc,%esp
  80145e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801461:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801464:	bb 00 00 00 00       	mov    $0x0,%ebx
  801469:	eb 21                	jmp    80148c <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80146b:	83 ec 04             	sub    $0x4,%esp
  80146e:	89 f0                	mov    %esi,%eax
  801470:	29 d8                	sub    %ebx,%eax
  801472:	50                   	push   %eax
  801473:	89 d8                	mov    %ebx,%eax
  801475:	03 45 0c             	add    0xc(%ebp),%eax
  801478:	50                   	push   %eax
  801479:	57                   	push   %edi
  80147a:	e8 45 ff ff ff       	call   8013c4 <read>
		if (m < 0)
  80147f:	83 c4 10             	add    $0x10,%esp
  801482:	85 c0                	test   %eax,%eax
  801484:	78 10                	js     801496 <readn+0x41>
			return m;
		if (m == 0)
  801486:	85 c0                	test   %eax,%eax
  801488:	74 0a                	je     801494 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80148a:	01 c3                	add    %eax,%ebx
  80148c:	39 f3                	cmp    %esi,%ebx
  80148e:	72 db                	jb     80146b <readn+0x16>
  801490:	89 d8                	mov    %ebx,%eax
  801492:	eb 02                	jmp    801496 <readn+0x41>
  801494:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801496:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801499:	5b                   	pop    %ebx
  80149a:	5e                   	pop    %esi
  80149b:	5f                   	pop    %edi
  80149c:	5d                   	pop    %ebp
  80149d:	c3                   	ret    

0080149e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80149e:	55                   	push   %ebp
  80149f:	89 e5                	mov    %esp,%ebp
  8014a1:	53                   	push   %ebx
  8014a2:	83 ec 14             	sub    $0x14,%esp
  8014a5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014a8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014ab:	50                   	push   %eax
  8014ac:	53                   	push   %ebx
  8014ad:	e8 ac fc ff ff       	call   80115e <fd_lookup>
  8014b2:	83 c4 08             	add    $0x8,%esp
  8014b5:	89 c2                	mov    %eax,%edx
  8014b7:	85 c0                	test   %eax,%eax
  8014b9:	78 68                	js     801523 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014bb:	83 ec 08             	sub    $0x8,%esp
  8014be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014c1:	50                   	push   %eax
  8014c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014c5:	ff 30                	pushl  (%eax)
  8014c7:	e8 e8 fc ff ff       	call   8011b4 <dev_lookup>
  8014cc:	83 c4 10             	add    $0x10,%esp
  8014cf:	85 c0                	test   %eax,%eax
  8014d1:	78 47                	js     80151a <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014d6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014da:	75 21                	jne    8014fd <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014dc:	a1 20 44 80 00       	mov    0x804420,%eax
  8014e1:	8b 40 48             	mov    0x48(%eax),%eax
  8014e4:	83 ec 04             	sub    $0x4,%esp
  8014e7:	53                   	push   %ebx
  8014e8:	50                   	push   %eax
  8014e9:	68 ec 26 80 00       	push   $0x8026ec
  8014ee:	e8 0a ef ff ff       	call   8003fd <cprintf>
		return -E_INVAL;
  8014f3:	83 c4 10             	add    $0x10,%esp
  8014f6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014fb:	eb 26                	jmp    801523 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801500:	8b 52 0c             	mov    0xc(%edx),%edx
  801503:	85 d2                	test   %edx,%edx
  801505:	74 17                	je     80151e <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801507:	83 ec 04             	sub    $0x4,%esp
  80150a:	ff 75 10             	pushl  0x10(%ebp)
  80150d:	ff 75 0c             	pushl  0xc(%ebp)
  801510:	50                   	push   %eax
  801511:	ff d2                	call   *%edx
  801513:	89 c2                	mov    %eax,%edx
  801515:	83 c4 10             	add    $0x10,%esp
  801518:	eb 09                	jmp    801523 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80151a:	89 c2                	mov    %eax,%edx
  80151c:	eb 05                	jmp    801523 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80151e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801523:	89 d0                	mov    %edx,%eax
  801525:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801528:	c9                   	leave  
  801529:	c3                   	ret    

0080152a <seek>:

int
seek(int fdnum, off_t offset)
{
  80152a:	55                   	push   %ebp
  80152b:	89 e5                	mov    %esp,%ebp
  80152d:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801530:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801533:	50                   	push   %eax
  801534:	ff 75 08             	pushl  0x8(%ebp)
  801537:	e8 22 fc ff ff       	call   80115e <fd_lookup>
  80153c:	83 c4 08             	add    $0x8,%esp
  80153f:	85 c0                	test   %eax,%eax
  801541:	78 0e                	js     801551 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801543:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801546:	8b 55 0c             	mov    0xc(%ebp),%edx
  801549:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80154c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801551:	c9                   	leave  
  801552:	c3                   	ret    

00801553 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801553:	55                   	push   %ebp
  801554:	89 e5                	mov    %esp,%ebp
  801556:	53                   	push   %ebx
  801557:	83 ec 14             	sub    $0x14,%esp
  80155a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80155d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801560:	50                   	push   %eax
  801561:	53                   	push   %ebx
  801562:	e8 f7 fb ff ff       	call   80115e <fd_lookup>
  801567:	83 c4 08             	add    $0x8,%esp
  80156a:	89 c2                	mov    %eax,%edx
  80156c:	85 c0                	test   %eax,%eax
  80156e:	78 65                	js     8015d5 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801570:	83 ec 08             	sub    $0x8,%esp
  801573:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801576:	50                   	push   %eax
  801577:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80157a:	ff 30                	pushl  (%eax)
  80157c:	e8 33 fc ff ff       	call   8011b4 <dev_lookup>
  801581:	83 c4 10             	add    $0x10,%esp
  801584:	85 c0                	test   %eax,%eax
  801586:	78 44                	js     8015cc <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801588:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80158b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80158f:	75 21                	jne    8015b2 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801591:	a1 20 44 80 00       	mov    0x804420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801596:	8b 40 48             	mov    0x48(%eax),%eax
  801599:	83 ec 04             	sub    $0x4,%esp
  80159c:	53                   	push   %ebx
  80159d:	50                   	push   %eax
  80159e:	68 ac 26 80 00       	push   $0x8026ac
  8015a3:	e8 55 ee ff ff       	call   8003fd <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015a8:	83 c4 10             	add    $0x10,%esp
  8015ab:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015b0:	eb 23                	jmp    8015d5 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8015b2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015b5:	8b 52 18             	mov    0x18(%edx),%edx
  8015b8:	85 d2                	test   %edx,%edx
  8015ba:	74 14                	je     8015d0 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015bc:	83 ec 08             	sub    $0x8,%esp
  8015bf:	ff 75 0c             	pushl  0xc(%ebp)
  8015c2:	50                   	push   %eax
  8015c3:	ff d2                	call   *%edx
  8015c5:	89 c2                	mov    %eax,%edx
  8015c7:	83 c4 10             	add    $0x10,%esp
  8015ca:	eb 09                	jmp    8015d5 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015cc:	89 c2                	mov    %eax,%edx
  8015ce:	eb 05                	jmp    8015d5 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015d0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8015d5:	89 d0                	mov    %edx,%eax
  8015d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015da:	c9                   	leave  
  8015db:	c3                   	ret    

008015dc <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015dc:	55                   	push   %ebp
  8015dd:	89 e5                	mov    %esp,%ebp
  8015df:	53                   	push   %ebx
  8015e0:	83 ec 14             	sub    $0x14,%esp
  8015e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015e6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015e9:	50                   	push   %eax
  8015ea:	ff 75 08             	pushl  0x8(%ebp)
  8015ed:	e8 6c fb ff ff       	call   80115e <fd_lookup>
  8015f2:	83 c4 08             	add    $0x8,%esp
  8015f5:	89 c2                	mov    %eax,%edx
  8015f7:	85 c0                	test   %eax,%eax
  8015f9:	78 58                	js     801653 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015fb:	83 ec 08             	sub    $0x8,%esp
  8015fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801601:	50                   	push   %eax
  801602:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801605:	ff 30                	pushl  (%eax)
  801607:	e8 a8 fb ff ff       	call   8011b4 <dev_lookup>
  80160c:	83 c4 10             	add    $0x10,%esp
  80160f:	85 c0                	test   %eax,%eax
  801611:	78 37                	js     80164a <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801613:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801616:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80161a:	74 32                	je     80164e <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80161c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80161f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801626:	00 00 00 
	stat->st_isdir = 0;
  801629:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801630:	00 00 00 
	stat->st_dev = dev;
  801633:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801639:	83 ec 08             	sub    $0x8,%esp
  80163c:	53                   	push   %ebx
  80163d:	ff 75 f0             	pushl  -0x10(%ebp)
  801640:	ff 50 14             	call   *0x14(%eax)
  801643:	89 c2                	mov    %eax,%edx
  801645:	83 c4 10             	add    $0x10,%esp
  801648:	eb 09                	jmp    801653 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80164a:	89 c2                	mov    %eax,%edx
  80164c:	eb 05                	jmp    801653 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80164e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801653:	89 d0                	mov    %edx,%eax
  801655:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801658:	c9                   	leave  
  801659:	c3                   	ret    

0080165a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80165a:	55                   	push   %ebp
  80165b:	89 e5                	mov    %esp,%ebp
  80165d:	56                   	push   %esi
  80165e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80165f:	83 ec 08             	sub    $0x8,%esp
  801662:	6a 00                	push   $0x0
  801664:	ff 75 08             	pushl  0x8(%ebp)
  801667:	e8 e3 01 00 00       	call   80184f <open>
  80166c:	89 c3                	mov    %eax,%ebx
  80166e:	83 c4 10             	add    $0x10,%esp
  801671:	85 c0                	test   %eax,%eax
  801673:	78 1b                	js     801690 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801675:	83 ec 08             	sub    $0x8,%esp
  801678:	ff 75 0c             	pushl  0xc(%ebp)
  80167b:	50                   	push   %eax
  80167c:	e8 5b ff ff ff       	call   8015dc <fstat>
  801681:	89 c6                	mov    %eax,%esi
	close(fd);
  801683:	89 1c 24             	mov    %ebx,(%esp)
  801686:	e8 fd fb ff ff       	call   801288 <close>
	return r;
  80168b:	83 c4 10             	add    $0x10,%esp
  80168e:	89 f0                	mov    %esi,%eax
}
  801690:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801693:	5b                   	pop    %ebx
  801694:	5e                   	pop    %esi
  801695:	5d                   	pop    %ebp
  801696:	c3                   	ret    

00801697 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801697:	55                   	push   %ebp
  801698:	89 e5                	mov    %esp,%ebp
  80169a:	56                   	push   %esi
  80169b:	53                   	push   %ebx
  80169c:	89 c6                	mov    %eax,%esi
  80169e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016a0:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016a7:	75 12                	jne    8016bb <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016a9:	83 ec 0c             	sub    $0xc,%esp
  8016ac:	6a 01                	push   $0x1
  8016ae:	e8 d8 08 00 00       	call   801f8b <ipc_find_env>
  8016b3:	a3 00 40 80 00       	mov    %eax,0x804000
  8016b8:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016bb:	6a 07                	push   $0x7
  8016bd:	68 00 50 80 00       	push   $0x805000
  8016c2:	56                   	push   %esi
  8016c3:	ff 35 00 40 80 00    	pushl  0x804000
  8016c9:	e8 69 08 00 00       	call   801f37 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016ce:	83 c4 0c             	add    $0xc,%esp
  8016d1:	6a 00                	push   $0x0
  8016d3:	53                   	push   %ebx
  8016d4:	6a 00                	push   $0x0
  8016d6:	e8 07 08 00 00       	call   801ee2 <ipc_recv>
}
  8016db:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016de:	5b                   	pop    %ebx
  8016df:	5e                   	pop    %esi
  8016e0:	5d                   	pop    %ebp
  8016e1:	c3                   	ret    

008016e2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016e2:	55                   	push   %ebp
  8016e3:	89 e5                	mov    %esp,%ebp
  8016e5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8016eb:	8b 40 0c             	mov    0xc(%eax),%eax
  8016ee:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016f6:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016fb:	ba 00 00 00 00       	mov    $0x0,%edx
  801700:	b8 02 00 00 00       	mov    $0x2,%eax
  801705:	e8 8d ff ff ff       	call   801697 <fsipc>
}
  80170a:	c9                   	leave  
  80170b:	c3                   	ret    

0080170c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80170c:	55                   	push   %ebp
  80170d:	89 e5                	mov    %esp,%ebp
  80170f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801712:	8b 45 08             	mov    0x8(%ebp),%eax
  801715:	8b 40 0c             	mov    0xc(%eax),%eax
  801718:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80171d:	ba 00 00 00 00       	mov    $0x0,%edx
  801722:	b8 06 00 00 00       	mov    $0x6,%eax
  801727:	e8 6b ff ff ff       	call   801697 <fsipc>
}
  80172c:	c9                   	leave  
  80172d:	c3                   	ret    

0080172e <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80172e:	55                   	push   %ebp
  80172f:	89 e5                	mov    %esp,%ebp
  801731:	53                   	push   %ebx
  801732:	83 ec 04             	sub    $0x4,%esp
  801735:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801738:	8b 45 08             	mov    0x8(%ebp),%eax
  80173b:	8b 40 0c             	mov    0xc(%eax),%eax
  80173e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801743:	ba 00 00 00 00       	mov    $0x0,%edx
  801748:	b8 05 00 00 00       	mov    $0x5,%eax
  80174d:	e8 45 ff ff ff       	call   801697 <fsipc>
  801752:	85 c0                	test   %eax,%eax
  801754:	78 2c                	js     801782 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801756:	83 ec 08             	sub    $0x8,%esp
  801759:	68 00 50 80 00       	push   $0x805000
  80175e:	53                   	push   %ebx
  80175f:	e8 3c f2 ff ff       	call   8009a0 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801764:	a1 80 50 80 00       	mov    0x805080,%eax
  801769:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80176f:	a1 84 50 80 00       	mov    0x805084,%eax
  801774:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80177a:	83 c4 10             	add    $0x10,%esp
  80177d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801782:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801785:	c9                   	leave  
  801786:	c3                   	ret    

00801787 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801787:	55                   	push   %ebp
  801788:	89 e5                	mov    %esp,%ebp
  80178a:	83 ec 0c             	sub    $0xc,%esp
  80178d:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
    
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  801790:	8b 55 08             	mov    0x8(%ebp),%edx
  801793:	8b 52 0c             	mov    0xc(%edx),%edx
  801796:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = MIN(n, PGSIZE);
  80179c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017a1:	ba 00 10 00 00       	mov    $0x1000,%edx
  8017a6:	0f 47 c2             	cmova  %edx,%eax
  8017a9:	a3 04 50 80 00       	mov    %eax,0x805004
    memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8017ae:	50                   	push   %eax
  8017af:	ff 75 0c             	pushl  0xc(%ebp)
  8017b2:	68 08 50 80 00       	push   $0x805008
  8017b7:	e8 76 f3 ff ff       	call   800b32 <memmove>
    int r = fsipc(FSREQ_WRITE, NULL);
  8017bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c1:	b8 04 00 00 00       	mov    $0x4,%eax
  8017c6:	e8 cc fe ff ff       	call   801697 <fsipc>
    return r;
}
  8017cb:	c9                   	leave  
  8017cc:	c3                   	ret    

008017cd <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017cd:	55                   	push   %ebp
  8017ce:	89 e5                	mov    %esp,%ebp
  8017d0:	56                   	push   %esi
  8017d1:	53                   	push   %ebx
  8017d2:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d8:	8b 40 0c             	mov    0xc(%eax),%eax
  8017db:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8017e0:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8017eb:	b8 03 00 00 00       	mov    $0x3,%eax
  8017f0:	e8 a2 fe ff ff       	call   801697 <fsipc>
  8017f5:	89 c3                	mov    %eax,%ebx
  8017f7:	85 c0                	test   %eax,%eax
  8017f9:	78 4b                	js     801846 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8017fb:	39 c6                	cmp    %eax,%esi
  8017fd:	73 16                	jae    801815 <devfile_read+0x48>
  8017ff:	68 1c 27 80 00       	push   $0x80271c
  801804:	68 23 27 80 00       	push   $0x802723
  801809:	6a 7c                	push   $0x7c
  80180b:	68 38 27 80 00       	push   $0x802738
  801810:	e8 0f eb ff ff       	call   800324 <_panic>
	assert(r <= PGSIZE);
  801815:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80181a:	7e 16                	jle    801832 <devfile_read+0x65>
  80181c:	68 43 27 80 00       	push   $0x802743
  801821:	68 23 27 80 00       	push   $0x802723
  801826:	6a 7d                	push   $0x7d
  801828:	68 38 27 80 00       	push   $0x802738
  80182d:	e8 f2 ea ff ff       	call   800324 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801832:	83 ec 04             	sub    $0x4,%esp
  801835:	50                   	push   %eax
  801836:	68 00 50 80 00       	push   $0x805000
  80183b:	ff 75 0c             	pushl  0xc(%ebp)
  80183e:	e8 ef f2 ff ff       	call   800b32 <memmove>
	return r;
  801843:	83 c4 10             	add    $0x10,%esp
}
  801846:	89 d8                	mov    %ebx,%eax
  801848:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80184b:	5b                   	pop    %ebx
  80184c:	5e                   	pop    %esi
  80184d:	5d                   	pop    %ebp
  80184e:	c3                   	ret    

0080184f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80184f:	55                   	push   %ebp
  801850:	89 e5                	mov    %esp,%ebp
  801852:	53                   	push   %ebx
  801853:	83 ec 20             	sub    $0x20,%esp
  801856:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801859:	53                   	push   %ebx
  80185a:	e8 08 f1 ff ff       	call   800967 <strlen>
  80185f:	83 c4 10             	add    $0x10,%esp
  801862:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801867:	7f 67                	jg     8018d0 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801869:	83 ec 0c             	sub    $0xc,%esp
  80186c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80186f:	50                   	push   %eax
  801870:	e8 9a f8 ff ff       	call   80110f <fd_alloc>
  801875:	83 c4 10             	add    $0x10,%esp
		return r;
  801878:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80187a:	85 c0                	test   %eax,%eax
  80187c:	78 57                	js     8018d5 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80187e:	83 ec 08             	sub    $0x8,%esp
  801881:	53                   	push   %ebx
  801882:	68 00 50 80 00       	push   $0x805000
  801887:	e8 14 f1 ff ff       	call   8009a0 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80188c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80188f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801894:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801897:	b8 01 00 00 00       	mov    $0x1,%eax
  80189c:	e8 f6 fd ff ff       	call   801697 <fsipc>
  8018a1:	89 c3                	mov    %eax,%ebx
  8018a3:	83 c4 10             	add    $0x10,%esp
  8018a6:	85 c0                	test   %eax,%eax
  8018a8:	79 14                	jns    8018be <open+0x6f>
		fd_close(fd, 0);
  8018aa:	83 ec 08             	sub    $0x8,%esp
  8018ad:	6a 00                	push   $0x0
  8018af:	ff 75 f4             	pushl  -0xc(%ebp)
  8018b2:	e8 50 f9 ff ff       	call   801207 <fd_close>
		return r;
  8018b7:	83 c4 10             	add    $0x10,%esp
  8018ba:	89 da                	mov    %ebx,%edx
  8018bc:	eb 17                	jmp    8018d5 <open+0x86>
	}

	return fd2num(fd);
  8018be:	83 ec 0c             	sub    $0xc,%esp
  8018c1:	ff 75 f4             	pushl  -0xc(%ebp)
  8018c4:	e8 1f f8 ff ff       	call   8010e8 <fd2num>
  8018c9:	89 c2                	mov    %eax,%edx
  8018cb:	83 c4 10             	add    $0x10,%esp
  8018ce:	eb 05                	jmp    8018d5 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8018d0:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8018d5:	89 d0                	mov    %edx,%eax
  8018d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018da:	c9                   	leave  
  8018db:	c3                   	ret    

008018dc <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8018dc:	55                   	push   %ebp
  8018dd:	89 e5                	mov    %esp,%ebp
  8018df:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8018e7:	b8 08 00 00 00       	mov    $0x8,%eax
  8018ec:	e8 a6 fd ff ff       	call   801697 <fsipc>
}
  8018f1:	c9                   	leave  
  8018f2:	c3                   	ret    

008018f3 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  8018f3:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8018f7:	7e 37                	jle    801930 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  8018f9:	55                   	push   %ebp
  8018fa:	89 e5                	mov    %esp,%ebp
  8018fc:	53                   	push   %ebx
  8018fd:	83 ec 08             	sub    $0x8,%esp
  801900:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  801902:	ff 70 04             	pushl  0x4(%eax)
  801905:	8d 40 10             	lea    0x10(%eax),%eax
  801908:	50                   	push   %eax
  801909:	ff 33                	pushl  (%ebx)
  80190b:	e8 8e fb ff ff       	call   80149e <write>
		if (result > 0)
  801910:	83 c4 10             	add    $0x10,%esp
  801913:	85 c0                	test   %eax,%eax
  801915:	7e 03                	jle    80191a <writebuf+0x27>
			b->result += result;
  801917:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  80191a:	3b 43 04             	cmp    0x4(%ebx),%eax
  80191d:	74 0d                	je     80192c <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  80191f:	85 c0                	test   %eax,%eax
  801921:	ba 00 00 00 00       	mov    $0x0,%edx
  801926:	0f 4f c2             	cmovg  %edx,%eax
  801929:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  80192c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80192f:	c9                   	leave  
  801930:	f3 c3                	repz ret 

00801932 <putch>:

static void
putch(int ch, void *thunk)
{
  801932:	55                   	push   %ebp
  801933:	89 e5                	mov    %esp,%ebp
  801935:	53                   	push   %ebx
  801936:	83 ec 04             	sub    $0x4,%esp
  801939:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  80193c:	8b 53 04             	mov    0x4(%ebx),%edx
  80193f:	8d 42 01             	lea    0x1(%edx),%eax
  801942:	89 43 04             	mov    %eax,0x4(%ebx)
  801945:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801948:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  80194c:	3d 00 01 00 00       	cmp    $0x100,%eax
  801951:	75 0e                	jne    801961 <putch+0x2f>
		writebuf(b);
  801953:	89 d8                	mov    %ebx,%eax
  801955:	e8 99 ff ff ff       	call   8018f3 <writebuf>
		b->idx = 0;
  80195a:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801961:	83 c4 04             	add    $0x4,%esp
  801964:	5b                   	pop    %ebx
  801965:	5d                   	pop    %ebp
  801966:	c3                   	ret    

00801967 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801967:	55                   	push   %ebp
  801968:	89 e5                	mov    %esp,%ebp
  80196a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801970:	8b 45 08             	mov    0x8(%ebp),%eax
  801973:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801979:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801980:	00 00 00 
	b.result = 0;
  801983:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80198a:	00 00 00 
	b.error = 1;
  80198d:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801994:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801997:	ff 75 10             	pushl  0x10(%ebp)
  80199a:	ff 75 0c             	pushl  0xc(%ebp)
  80199d:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8019a3:	50                   	push   %eax
  8019a4:	68 32 19 80 00       	push   $0x801932
  8019a9:	e8 86 eb ff ff       	call   800534 <vprintfmt>
	if (b.idx > 0)
  8019ae:	83 c4 10             	add    $0x10,%esp
  8019b1:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8019b8:	7e 0b                	jle    8019c5 <vfprintf+0x5e>
		writebuf(&b);
  8019ba:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8019c0:	e8 2e ff ff ff       	call   8018f3 <writebuf>

	return (b.result ? b.result : b.error);
  8019c5:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8019cb:	85 c0                	test   %eax,%eax
  8019cd:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  8019d4:	c9                   	leave  
  8019d5:	c3                   	ret    

008019d6 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8019d6:	55                   	push   %ebp
  8019d7:	89 e5                	mov    %esp,%ebp
  8019d9:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8019dc:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  8019df:	50                   	push   %eax
  8019e0:	ff 75 0c             	pushl  0xc(%ebp)
  8019e3:	ff 75 08             	pushl  0x8(%ebp)
  8019e6:	e8 7c ff ff ff       	call   801967 <vfprintf>
	va_end(ap);

	return cnt;
}
  8019eb:	c9                   	leave  
  8019ec:	c3                   	ret    

008019ed <printf>:

int
printf(const char *fmt, ...)
{
  8019ed:	55                   	push   %ebp
  8019ee:	89 e5                	mov    %esp,%ebp
  8019f0:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8019f3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  8019f6:	50                   	push   %eax
  8019f7:	ff 75 08             	pushl  0x8(%ebp)
  8019fa:	6a 01                	push   $0x1
  8019fc:	e8 66 ff ff ff       	call   801967 <vfprintf>
	va_end(ap);

	return cnt;
}
  801a01:	c9                   	leave  
  801a02:	c3                   	ret    

00801a03 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a03:	55                   	push   %ebp
  801a04:	89 e5                	mov    %esp,%ebp
  801a06:	56                   	push   %esi
  801a07:	53                   	push   %ebx
  801a08:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a0b:	83 ec 0c             	sub    $0xc,%esp
  801a0e:	ff 75 08             	pushl  0x8(%ebp)
  801a11:	e8 e2 f6 ff ff       	call   8010f8 <fd2data>
  801a16:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a18:	83 c4 08             	add    $0x8,%esp
  801a1b:	68 4f 27 80 00       	push   $0x80274f
  801a20:	53                   	push   %ebx
  801a21:	e8 7a ef ff ff       	call   8009a0 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a26:	8b 46 04             	mov    0x4(%esi),%eax
  801a29:	2b 06                	sub    (%esi),%eax
  801a2b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a31:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a38:	00 00 00 
	stat->st_dev = &devpipe;
  801a3b:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a42:	30 80 00 
	return 0;
}
  801a45:	b8 00 00 00 00       	mov    $0x0,%eax
  801a4a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a4d:	5b                   	pop    %ebx
  801a4e:	5e                   	pop    %esi
  801a4f:	5d                   	pop    %ebp
  801a50:	c3                   	ret    

00801a51 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a51:	55                   	push   %ebp
  801a52:	89 e5                	mov    %esp,%ebp
  801a54:	53                   	push   %ebx
  801a55:	83 ec 0c             	sub    $0xc,%esp
  801a58:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a5b:	53                   	push   %ebx
  801a5c:	6a 00                	push   $0x0
  801a5e:	e8 c5 f3 ff ff       	call   800e28 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a63:	89 1c 24             	mov    %ebx,(%esp)
  801a66:	e8 8d f6 ff ff       	call   8010f8 <fd2data>
  801a6b:	83 c4 08             	add    $0x8,%esp
  801a6e:	50                   	push   %eax
  801a6f:	6a 00                	push   $0x0
  801a71:	e8 b2 f3 ff ff       	call   800e28 <sys_page_unmap>
}
  801a76:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a79:	c9                   	leave  
  801a7a:	c3                   	ret    

00801a7b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a7b:	55                   	push   %ebp
  801a7c:	89 e5                	mov    %esp,%ebp
  801a7e:	57                   	push   %edi
  801a7f:	56                   	push   %esi
  801a80:	53                   	push   %ebx
  801a81:	83 ec 1c             	sub    $0x1c,%esp
  801a84:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a87:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a89:	a1 20 44 80 00       	mov    0x804420,%eax
  801a8e:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a91:	83 ec 0c             	sub    $0xc,%esp
  801a94:	ff 75 e0             	pushl  -0x20(%ebp)
  801a97:	e8 28 05 00 00       	call   801fc4 <pageref>
  801a9c:	89 c3                	mov    %eax,%ebx
  801a9e:	89 3c 24             	mov    %edi,(%esp)
  801aa1:	e8 1e 05 00 00       	call   801fc4 <pageref>
  801aa6:	83 c4 10             	add    $0x10,%esp
  801aa9:	39 c3                	cmp    %eax,%ebx
  801aab:	0f 94 c1             	sete   %cl
  801aae:	0f b6 c9             	movzbl %cl,%ecx
  801ab1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801ab4:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801aba:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801abd:	39 ce                	cmp    %ecx,%esi
  801abf:	74 1b                	je     801adc <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801ac1:	39 c3                	cmp    %eax,%ebx
  801ac3:	75 c4                	jne    801a89 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ac5:	8b 42 58             	mov    0x58(%edx),%eax
  801ac8:	ff 75 e4             	pushl  -0x1c(%ebp)
  801acb:	50                   	push   %eax
  801acc:	56                   	push   %esi
  801acd:	68 56 27 80 00       	push   $0x802756
  801ad2:	e8 26 e9 ff ff       	call   8003fd <cprintf>
  801ad7:	83 c4 10             	add    $0x10,%esp
  801ada:	eb ad                	jmp    801a89 <_pipeisclosed+0xe>
	}
}
  801adc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801adf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ae2:	5b                   	pop    %ebx
  801ae3:	5e                   	pop    %esi
  801ae4:	5f                   	pop    %edi
  801ae5:	5d                   	pop    %ebp
  801ae6:	c3                   	ret    

00801ae7 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ae7:	55                   	push   %ebp
  801ae8:	89 e5                	mov    %esp,%ebp
  801aea:	57                   	push   %edi
  801aeb:	56                   	push   %esi
  801aec:	53                   	push   %ebx
  801aed:	83 ec 28             	sub    $0x28,%esp
  801af0:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801af3:	56                   	push   %esi
  801af4:	e8 ff f5 ff ff       	call   8010f8 <fd2data>
  801af9:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801afb:	83 c4 10             	add    $0x10,%esp
  801afe:	bf 00 00 00 00       	mov    $0x0,%edi
  801b03:	eb 4b                	jmp    801b50 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b05:	89 da                	mov    %ebx,%edx
  801b07:	89 f0                	mov    %esi,%eax
  801b09:	e8 6d ff ff ff       	call   801a7b <_pipeisclosed>
  801b0e:	85 c0                	test   %eax,%eax
  801b10:	75 48                	jne    801b5a <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b12:	e8 6d f2 ff ff       	call   800d84 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b17:	8b 43 04             	mov    0x4(%ebx),%eax
  801b1a:	8b 0b                	mov    (%ebx),%ecx
  801b1c:	8d 51 20             	lea    0x20(%ecx),%edx
  801b1f:	39 d0                	cmp    %edx,%eax
  801b21:	73 e2                	jae    801b05 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b26:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b2a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b2d:	89 c2                	mov    %eax,%edx
  801b2f:	c1 fa 1f             	sar    $0x1f,%edx
  801b32:	89 d1                	mov    %edx,%ecx
  801b34:	c1 e9 1b             	shr    $0x1b,%ecx
  801b37:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b3a:	83 e2 1f             	and    $0x1f,%edx
  801b3d:	29 ca                	sub    %ecx,%edx
  801b3f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b43:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b47:	83 c0 01             	add    $0x1,%eax
  801b4a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b4d:	83 c7 01             	add    $0x1,%edi
  801b50:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b53:	75 c2                	jne    801b17 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b55:	8b 45 10             	mov    0x10(%ebp),%eax
  801b58:	eb 05                	jmp    801b5f <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b5a:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b62:	5b                   	pop    %ebx
  801b63:	5e                   	pop    %esi
  801b64:	5f                   	pop    %edi
  801b65:	5d                   	pop    %ebp
  801b66:	c3                   	ret    

00801b67 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b67:	55                   	push   %ebp
  801b68:	89 e5                	mov    %esp,%ebp
  801b6a:	57                   	push   %edi
  801b6b:	56                   	push   %esi
  801b6c:	53                   	push   %ebx
  801b6d:	83 ec 18             	sub    $0x18,%esp
  801b70:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b73:	57                   	push   %edi
  801b74:	e8 7f f5 ff ff       	call   8010f8 <fd2data>
  801b79:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b7b:	83 c4 10             	add    $0x10,%esp
  801b7e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b83:	eb 3d                	jmp    801bc2 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b85:	85 db                	test   %ebx,%ebx
  801b87:	74 04                	je     801b8d <devpipe_read+0x26>
				return i;
  801b89:	89 d8                	mov    %ebx,%eax
  801b8b:	eb 44                	jmp    801bd1 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b8d:	89 f2                	mov    %esi,%edx
  801b8f:	89 f8                	mov    %edi,%eax
  801b91:	e8 e5 fe ff ff       	call   801a7b <_pipeisclosed>
  801b96:	85 c0                	test   %eax,%eax
  801b98:	75 32                	jne    801bcc <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b9a:	e8 e5 f1 ff ff       	call   800d84 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b9f:	8b 06                	mov    (%esi),%eax
  801ba1:	3b 46 04             	cmp    0x4(%esi),%eax
  801ba4:	74 df                	je     801b85 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ba6:	99                   	cltd   
  801ba7:	c1 ea 1b             	shr    $0x1b,%edx
  801baa:	01 d0                	add    %edx,%eax
  801bac:	83 e0 1f             	and    $0x1f,%eax
  801baf:	29 d0                	sub    %edx,%eax
  801bb1:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801bb6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bb9:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801bbc:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bbf:	83 c3 01             	add    $0x1,%ebx
  801bc2:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801bc5:	75 d8                	jne    801b9f <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801bc7:	8b 45 10             	mov    0x10(%ebp),%eax
  801bca:	eb 05                	jmp    801bd1 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bcc:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801bd1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bd4:	5b                   	pop    %ebx
  801bd5:	5e                   	pop    %esi
  801bd6:	5f                   	pop    %edi
  801bd7:	5d                   	pop    %ebp
  801bd8:	c3                   	ret    

00801bd9 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801bd9:	55                   	push   %ebp
  801bda:	89 e5                	mov    %esp,%ebp
  801bdc:	56                   	push   %esi
  801bdd:	53                   	push   %ebx
  801bde:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801be1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801be4:	50                   	push   %eax
  801be5:	e8 25 f5 ff ff       	call   80110f <fd_alloc>
  801bea:	83 c4 10             	add    $0x10,%esp
  801bed:	89 c2                	mov    %eax,%edx
  801bef:	85 c0                	test   %eax,%eax
  801bf1:	0f 88 2c 01 00 00    	js     801d23 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bf7:	83 ec 04             	sub    $0x4,%esp
  801bfa:	68 07 04 00 00       	push   $0x407
  801bff:	ff 75 f4             	pushl  -0xc(%ebp)
  801c02:	6a 00                	push   $0x0
  801c04:	e8 9a f1 ff ff       	call   800da3 <sys_page_alloc>
  801c09:	83 c4 10             	add    $0x10,%esp
  801c0c:	89 c2                	mov    %eax,%edx
  801c0e:	85 c0                	test   %eax,%eax
  801c10:	0f 88 0d 01 00 00    	js     801d23 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c16:	83 ec 0c             	sub    $0xc,%esp
  801c19:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c1c:	50                   	push   %eax
  801c1d:	e8 ed f4 ff ff       	call   80110f <fd_alloc>
  801c22:	89 c3                	mov    %eax,%ebx
  801c24:	83 c4 10             	add    $0x10,%esp
  801c27:	85 c0                	test   %eax,%eax
  801c29:	0f 88 e2 00 00 00    	js     801d11 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c2f:	83 ec 04             	sub    $0x4,%esp
  801c32:	68 07 04 00 00       	push   $0x407
  801c37:	ff 75 f0             	pushl  -0x10(%ebp)
  801c3a:	6a 00                	push   $0x0
  801c3c:	e8 62 f1 ff ff       	call   800da3 <sys_page_alloc>
  801c41:	89 c3                	mov    %eax,%ebx
  801c43:	83 c4 10             	add    $0x10,%esp
  801c46:	85 c0                	test   %eax,%eax
  801c48:	0f 88 c3 00 00 00    	js     801d11 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c4e:	83 ec 0c             	sub    $0xc,%esp
  801c51:	ff 75 f4             	pushl  -0xc(%ebp)
  801c54:	e8 9f f4 ff ff       	call   8010f8 <fd2data>
  801c59:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c5b:	83 c4 0c             	add    $0xc,%esp
  801c5e:	68 07 04 00 00       	push   $0x407
  801c63:	50                   	push   %eax
  801c64:	6a 00                	push   $0x0
  801c66:	e8 38 f1 ff ff       	call   800da3 <sys_page_alloc>
  801c6b:	89 c3                	mov    %eax,%ebx
  801c6d:	83 c4 10             	add    $0x10,%esp
  801c70:	85 c0                	test   %eax,%eax
  801c72:	0f 88 89 00 00 00    	js     801d01 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c78:	83 ec 0c             	sub    $0xc,%esp
  801c7b:	ff 75 f0             	pushl  -0x10(%ebp)
  801c7e:	e8 75 f4 ff ff       	call   8010f8 <fd2data>
  801c83:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c8a:	50                   	push   %eax
  801c8b:	6a 00                	push   $0x0
  801c8d:	56                   	push   %esi
  801c8e:	6a 00                	push   $0x0
  801c90:	e8 51 f1 ff ff       	call   800de6 <sys_page_map>
  801c95:	89 c3                	mov    %eax,%ebx
  801c97:	83 c4 20             	add    $0x20,%esp
  801c9a:	85 c0                	test   %eax,%eax
  801c9c:	78 55                	js     801cf3 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c9e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ca4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ca7:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ca9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cac:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801cb3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cbc:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801cbe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cc1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801cc8:	83 ec 0c             	sub    $0xc,%esp
  801ccb:	ff 75 f4             	pushl  -0xc(%ebp)
  801cce:	e8 15 f4 ff ff       	call   8010e8 <fd2num>
  801cd3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cd6:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801cd8:	83 c4 04             	add    $0x4,%esp
  801cdb:	ff 75 f0             	pushl  -0x10(%ebp)
  801cde:	e8 05 f4 ff ff       	call   8010e8 <fd2num>
  801ce3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ce6:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ce9:	83 c4 10             	add    $0x10,%esp
  801cec:	ba 00 00 00 00       	mov    $0x0,%edx
  801cf1:	eb 30                	jmp    801d23 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801cf3:	83 ec 08             	sub    $0x8,%esp
  801cf6:	56                   	push   %esi
  801cf7:	6a 00                	push   $0x0
  801cf9:	e8 2a f1 ff ff       	call   800e28 <sys_page_unmap>
  801cfe:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d01:	83 ec 08             	sub    $0x8,%esp
  801d04:	ff 75 f0             	pushl  -0x10(%ebp)
  801d07:	6a 00                	push   $0x0
  801d09:	e8 1a f1 ff ff       	call   800e28 <sys_page_unmap>
  801d0e:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d11:	83 ec 08             	sub    $0x8,%esp
  801d14:	ff 75 f4             	pushl  -0xc(%ebp)
  801d17:	6a 00                	push   $0x0
  801d19:	e8 0a f1 ff ff       	call   800e28 <sys_page_unmap>
  801d1e:	83 c4 10             	add    $0x10,%esp
  801d21:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d23:	89 d0                	mov    %edx,%eax
  801d25:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d28:	5b                   	pop    %ebx
  801d29:	5e                   	pop    %esi
  801d2a:	5d                   	pop    %ebp
  801d2b:	c3                   	ret    

00801d2c <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d2c:	55                   	push   %ebp
  801d2d:	89 e5                	mov    %esp,%ebp
  801d2f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d32:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d35:	50                   	push   %eax
  801d36:	ff 75 08             	pushl  0x8(%ebp)
  801d39:	e8 20 f4 ff ff       	call   80115e <fd_lookup>
  801d3e:	83 c4 10             	add    $0x10,%esp
  801d41:	85 c0                	test   %eax,%eax
  801d43:	78 18                	js     801d5d <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d45:	83 ec 0c             	sub    $0xc,%esp
  801d48:	ff 75 f4             	pushl  -0xc(%ebp)
  801d4b:	e8 a8 f3 ff ff       	call   8010f8 <fd2data>
	return _pipeisclosed(fd, p);
  801d50:	89 c2                	mov    %eax,%edx
  801d52:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d55:	e8 21 fd ff ff       	call   801a7b <_pipeisclosed>
  801d5a:	83 c4 10             	add    $0x10,%esp
}
  801d5d:	c9                   	leave  
  801d5e:	c3                   	ret    

00801d5f <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d5f:	55                   	push   %ebp
  801d60:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d62:	b8 00 00 00 00       	mov    $0x0,%eax
  801d67:	5d                   	pop    %ebp
  801d68:	c3                   	ret    

00801d69 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d69:	55                   	push   %ebp
  801d6a:	89 e5                	mov    %esp,%ebp
  801d6c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d6f:	68 6e 27 80 00       	push   $0x80276e
  801d74:	ff 75 0c             	pushl  0xc(%ebp)
  801d77:	e8 24 ec ff ff       	call   8009a0 <strcpy>
	return 0;
}
  801d7c:	b8 00 00 00 00       	mov    $0x0,%eax
  801d81:	c9                   	leave  
  801d82:	c3                   	ret    

00801d83 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d83:	55                   	push   %ebp
  801d84:	89 e5                	mov    %esp,%ebp
  801d86:	57                   	push   %edi
  801d87:	56                   	push   %esi
  801d88:	53                   	push   %ebx
  801d89:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d8f:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d94:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d9a:	eb 2d                	jmp    801dc9 <devcons_write+0x46>
		m = n - tot;
  801d9c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d9f:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801da1:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801da4:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801da9:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801dac:	83 ec 04             	sub    $0x4,%esp
  801daf:	53                   	push   %ebx
  801db0:	03 45 0c             	add    0xc(%ebp),%eax
  801db3:	50                   	push   %eax
  801db4:	57                   	push   %edi
  801db5:	e8 78 ed ff ff       	call   800b32 <memmove>
		sys_cputs(buf, m);
  801dba:	83 c4 08             	add    $0x8,%esp
  801dbd:	53                   	push   %ebx
  801dbe:	57                   	push   %edi
  801dbf:	e8 23 ef ff ff       	call   800ce7 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dc4:	01 de                	add    %ebx,%esi
  801dc6:	83 c4 10             	add    $0x10,%esp
  801dc9:	89 f0                	mov    %esi,%eax
  801dcb:	3b 75 10             	cmp    0x10(%ebp),%esi
  801dce:	72 cc                	jb     801d9c <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801dd0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dd3:	5b                   	pop    %ebx
  801dd4:	5e                   	pop    %esi
  801dd5:	5f                   	pop    %edi
  801dd6:	5d                   	pop    %ebp
  801dd7:	c3                   	ret    

00801dd8 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801dd8:	55                   	push   %ebp
  801dd9:	89 e5                	mov    %esp,%ebp
  801ddb:	83 ec 08             	sub    $0x8,%esp
  801dde:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801de3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801de7:	74 2a                	je     801e13 <devcons_read+0x3b>
  801de9:	eb 05                	jmp    801df0 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801deb:	e8 94 ef ff ff       	call   800d84 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801df0:	e8 10 ef ff ff       	call   800d05 <sys_cgetc>
  801df5:	85 c0                	test   %eax,%eax
  801df7:	74 f2                	je     801deb <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801df9:	85 c0                	test   %eax,%eax
  801dfb:	78 16                	js     801e13 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801dfd:	83 f8 04             	cmp    $0x4,%eax
  801e00:	74 0c                	je     801e0e <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e02:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e05:	88 02                	mov    %al,(%edx)
	return 1;
  801e07:	b8 01 00 00 00       	mov    $0x1,%eax
  801e0c:	eb 05                	jmp    801e13 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e0e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e13:	c9                   	leave  
  801e14:	c3                   	ret    

00801e15 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e15:	55                   	push   %ebp
  801e16:	89 e5                	mov    %esp,%ebp
  801e18:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e1b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e1e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e21:	6a 01                	push   $0x1
  801e23:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e26:	50                   	push   %eax
  801e27:	e8 bb ee ff ff       	call   800ce7 <sys_cputs>
}
  801e2c:	83 c4 10             	add    $0x10,%esp
  801e2f:	c9                   	leave  
  801e30:	c3                   	ret    

00801e31 <getchar>:

int
getchar(void)
{
  801e31:	55                   	push   %ebp
  801e32:	89 e5                	mov    %esp,%ebp
  801e34:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e37:	6a 01                	push   $0x1
  801e39:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e3c:	50                   	push   %eax
  801e3d:	6a 00                	push   $0x0
  801e3f:	e8 80 f5 ff ff       	call   8013c4 <read>
	if (r < 0)
  801e44:	83 c4 10             	add    $0x10,%esp
  801e47:	85 c0                	test   %eax,%eax
  801e49:	78 0f                	js     801e5a <getchar+0x29>
		return r;
	if (r < 1)
  801e4b:	85 c0                	test   %eax,%eax
  801e4d:	7e 06                	jle    801e55 <getchar+0x24>
		return -E_EOF;
	return c;
  801e4f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e53:	eb 05                	jmp    801e5a <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e55:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e5a:	c9                   	leave  
  801e5b:	c3                   	ret    

00801e5c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e5c:	55                   	push   %ebp
  801e5d:	89 e5                	mov    %esp,%ebp
  801e5f:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e62:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e65:	50                   	push   %eax
  801e66:	ff 75 08             	pushl  0x8(%ebp)
  801e69:	e8 f0 f2 ff ff       	call   80115e <fd_lookup>
  801e6e:	83 c4 10             	add    $0x10,%esp
  801e71:	85 c0                	test   %eax,%eax
  801e73:	78 11                	js     801e86 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e75:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e78:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e7e:	39 10                	cmp    %edx,(%eax)
  801e80:	0f 94 c0             	sete   %al
  801e83:	0f b6 c0             	movzbl %al,%eax
}
  801e86:	c9                   	leave  
  801e87:	c3                   	ret    

00801e88 <opencons>:

int
opencons(void)
{
  801e88:	55                   	push   %ebp
  801e89:	89 e5                	mov    %esp,%ebp
  801e8b:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e8e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e91:	50                   	push   %eax
  801e92:	e8 78 f2 ff ff       	call   80110f <fd_alloc>
  801e97:	83 c4 10             	add    $0x10,%esp
		return r;
  801e9a:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e9c:	85 c0                	test   %eax,%eax
  801e9e:	78 3e                	js     801ede <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ea0:	83 ec 04             	sub    $0x4,%esp
  801ea3:	68 07 04 00 00       	push   $0x407
  801ea8:	ff 75 f4             	pushl  -0xc(%ebp)
  801eab:	6a 00                	push   $0x0
  801ead:	e8 f1 ee ff ff       	call   800da3 <sys_page_alloc>
  801eb2:	83 c4 10             	add    $0x10,%esp
		return r;
  801eb5:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801eb7:	85 c0                	test   %eax,%eax
  801eb9:	78 23                	js     801ede <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ebb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ec1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ec4:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ec6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ec9:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ed0:	83 ec 0c             	sub    $0xc,%esp
  801ed3:	50                   	push   %eax
  801ed4:	e8 0f f2 ff ff       	call   8010e8 <fd2num>
  801ed9:	89 c2                	mov    %eax,%edx
  801edb:	83 c4 10             	add    $0x10,%esp
}
  801ede:	89 d0                	mov    %edx,%eax
  801ee0:	c9                   	leave  
  801ee1:	c3                   	ret    

00801ee2 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ee2:	55                   	push   %ebp
  801ee3:	89 e5                	mov    %esp,%ebp
  801ee5:	56                   	push   %esi
  801ee6:	53                   	push   %ebx
  801ee7:	8b 75 08             	mov    0x8(%ebp),%esi
  801eea:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eed:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_recv not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  801ef0:	85 c0                	test   %eax,%eax
  801ef2:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801ef7:	0f 44 c2             	cmove  %edx,%eax

    int r = sys_ipc_recv(pg);
  801efa:	83 ec 0c             	sub    $0xc,%esp
  801efd:	50                   	push   %eax
  801efe:	e8 50 f0 ff ff       	call   800f53 <sys_ipc_recv>
    int from_env = 0, perm = 0;
    if (r == 0) {
  801f03:	83 c4 10             	add    $0x10,%esp
  801f06:	85 c0                	test   %eax,%eax
  801f08:	75 10                	jne    801f1a <ipc_recv+0x38>
        from_env = thisenv->env_ipc_from;
  801f0a:	a1 20 44 80 00       	mov    0x804420,%eax
  801f0f:	8b 48 74             	mov    0x74(%eax),%ecx
        perm = thisenv->env_ipc_perm;
  801f12:	8b 50 78             	mov    0x78(%eax),%edx
        r = thisenv->env_ipc_value;
  801f15:	8b 40 70             	mov    0x70(%eax),%eax
  801f18:	eb 0a                	jmp    801f24 <ipc_recv+0x42>
    } else {
        from_env = 0;
        perm = 0;
  801f1a:	ba 00 00 00 00       	mov    $0x0,%edx
    if (r == 0) {
        from_env = thisenv->env_ipc_from;
        perm = thisenv->env_ipc_perm;
        r = thisenv->env_ipc_value;
    } else {
        from_env = 0;
  801f1f:	b9 00 00 00 00       	mov    $0x0,%ecx
        perm = 0;
    }

    if (from_env_store) *from_env_store = from_env;
  801f24:	85 f6                	test   %esi,%esi
  801f26:	74 02                	je     801f2a <ipc_recv+0x48>
  801f28:	89 0e                	mov    %ecx,(%esi)
    if (perm_store) *perm_store = perm;
  801f2a:	85 db                	test   %ebx,%ebx
  801f2c:	74 02                	je     801f30 <ipc_recv+0x4e>
  801f2e:	89 13                	mov    %edx,(%ebx)

    return r;
}
  801f30:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f33:	5b                   	pop    %ebx
  801f34:	5e                   	pop    %esi
  801f35:	5d                   	pop    %ebp
  801f36:	c3                   	ret    

00801f37 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f37:	55                   	push   %ebp
  801f38:	89 e5                	mov    %esp,%ebp
  801f3a:	57                   	push   %edi
  801f3b:	56                   	push   %esi
  801f3c:	53                   	push   %ebx
  801f3d:	83 ec 0c             	sub    $0xc,%esp
  801f40:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f43:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f46:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  801f49:	85 db                	test   %ebx,%ebx
  801f4b:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f50:	0f 44 d8             	cmove  %eax,%ebx
  801f53:	eb 1c                	jmp    801f71 <ipc_send+0x3a>

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        if (ret != -E_IPC_NOT_RECV)
  801f55:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f58:	74 12                	je     801f6c <ipc_send+0x35>
            panic("ipc_send error %e", ret);
  801f5a:	50                   	push   %eax
  801f5b:	68 7a 27 80 00       	push   $0x80277a
  801f60:	6a 40                	push   $0x40
  801f62:	68 8c 27 80 00       	push   $0x80278c
  801f67:	e8 b8 e3 ff ff       	call   800324 <_panic>
        sys_yield();
  801f6c:	e8 13 ee ff ff       	call   800d84 <sys_yield>
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801f71:	ff 75 14             	pushl  0x14(%ebp)
  801f74:	53                   	push   %ebx
  801f75:	56                   	push   %esi
  801f76:	57                   	push   %edi
  801f77:	e8 b4 ef ff ff       	call   800f30 <sys_ipc_try_send>
  801f7c:	83 c4 10             	add    $0x10,%esp
  801f7f:	85 c0                	test   %eax,%eax
  801f81:	75 d2                	jne    801f55 <ipc_send+0x1e>
        if (ret != -E_IPC_NOT_RECV)
            panic("ipc_send error %e", ret);
        sys_yield();
    }
}
  801f83:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f86:	5b                   	pop    %ebx
  801f87:	5e                   	pop    %esi
  801f88:	5f                   	pop    %edi
  801f89:	5d                   	pop    %ebp
  801f8a:	c3                   	ret    

00801f8b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f8b:	55                   	push   %ebp
  801f8c:	89 e5                	mov    %esp,%ebp
  801f8e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f91:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f96:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f99:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f9f:	8b 52 50             	mov    0x50(%edx),%edx
  801fa2:	39 ca                	cmp    %ecx,%edx
  801fa4:	75 0d                	jne    801fb3 <ipc_find_env+0x28>
			return envs[i].env_id;
  801fa6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801fa9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fae:	8b 40 48             	mov    0x48(%eax),%eax
  801fb1:	eb 0f                	jmp    801fc2 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801fb3:	83 c0 01             	add    $0x1,%eax
  801fb6:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fbb:	75 d9                	jne    801f96 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801fbd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fc2:	5d                   	pop    %ebp
  801fc3:	c3                   	ret    

00801fc4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fc4:	55                   	push   %ebp
  801fc5:	89 e5                	mov    %esp,%ebp
  801fc7:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fca:	89 d0                	mov    %edx,%eax
  801fcc:	c1 e8 16             	shr    $0x16,%eax
  801fcf:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fd6:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fdb:	f6 c1 01             	test   $0x1,%cl
  801fde:	74 1d                	je     801ffd <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fe0:	c1 ea 0c             	shr    $0xc,%edx
  801fe3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fea:	f6 c2 01             	test   $0x1,%dl
  801fed:	74 0e                	je     801ffd <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fef:	c1 ea 0c             	shr    $0xc,%edx
  801ff2:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801ff9:	ef 
  801ffa:	0f b7 c0             	movzwl %ax,%eax
}
  801ffd:	5d                   	pop    %ebp
  801ffe:	c3                   	ret    
  801fff:	90                   	nop

00802000 <__udivdi3>:
  802000:	55                   	push   %ebp
  802001:	57                   	push   %edi
  802002:	56                   	push   %esi
  802003:	53                   	push   %ebx
  802004:	83 ec 1c             	sub    $0x1c,%esp
  802007:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80200b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80200f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802013:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802017:	85 f6                	test   %esi,%esi
  802019:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80201d:	89 ca                	mov    %ecx,%edx
  80201f:	89 f8                	mov    %edi,%eax
  802021:	75 3d                	jne    802060 <__udivdi3+0x60>
  802023:	39 cf                	cmp    %ecx,%edi
  802025:	0f 87 c5 00 00 00    	ja     8020f0 <__udivdi3+0xf0>
  80202b:	85 ff                	test   %edi,%edi
  80202d:	89 fd                	mov    %edi,%ebp
  80202f:	75 0b                	jne    80203c <__udivdi3+0x3c>
  802031:	b8 01 00 00 00       	mov    $0x1,%eax
  802036:	31 d2                	xor    %edx,%edx
  802038:	f7 f7                	div    %edi
  80203a:	89 c5                	mov    %eax,%ebp
  80203c:	89 c8                	mov    %ecx,%eax
  80203e:	31 d2                	xor    %edx,%edx
  802040:	f7 f5                	div    %ebp
  802042:	89 c1                	mov    %eax,%ecx
  802044:	89 d8                	mov    %ebx,%eax
  802046:	89 cf                	mov    %ecx,%edi
  802048:	f7 f5                	div    %ebp
  80204a:	89 c3                	mov    %eax,%ebx
  80204c:	89 d8                	mov    %ebx,%eax
  80204e:	89 fa                	mov    %edi,%edx
  802050:	83 c4 1c             	add    $0x1c,%esp
  802053:	5b                   	pop    %ebx
  802054:	5e                   	pop    %esi
  802055:	5f                   	pop    %edi
  802056:	5d                   	pop    %ebp
  802057:	c3                   	ret    
  802058:	90                   	nop
  802059:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802060:	39 ce                	cmp    %ecx,%esi
  802062:	77 74                	ja     8020d8 <__udivdi3+0xd8>
  802064:	0f bd fe             	bsr    %esi,%edi
  802067:	83 f7 1f             	xor    $0x1f,%edi
  80206a:	0f 84 98 00 00 00    	je     802108 <__udivdi3+0x108>
  802070:	bb 20 00 00 00       	mov    $0x20,%ebx
  802075:	89 f9                	mov    %edi,%ecx
  802077:	89 c5                	mov    %eax,%ebp
  802079:	29 fb                	sub    %edi,%ebx
  80207b:	d3 e6                	shl    %cl,%esi
  80207d:	89 d9                	mov    %ebx,%ecx
  80207f:	d3 ed                	shr    %cl,%ebp
  802081:	89 f9                	mov    %edi,%ecx
  802083:	d3 e0                	shl    %cl,%eax
  802085:	09 ee                	or     %ebp,%esi
  802087:	89 d9                	mov    %ebx,%ecx
  802089:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80208d:	89 d5                	mov    %edx,%ebp
  80208f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802093:	d3 ed                	shr    %cl,%ebp
  802095:	89 f9                	mov    %edi,%ecx
  802097:	d3 e2                	shl    %cl,%edx
  802099:	89 d9                	mov    %ebx,%ecx
  80209b:	d3 e8                	shr    %cl,%eax
  80209d:	09 c2                	or     %eax,%edx
  80209f:	89 d0                	mov    %edx,%eax
  8020a1:	89 ea                	mov    %ebp,%edx
  8020a3:	f7 f6                	div    %esi
  8020a5:	89 d5                	mov    %edx,%ebp
  8020a7:	89 c3                	mov    %eax,%ebx
  8020a9:	f7 64 24 0c          	mull   0xc(%esp)
  8020ad:	39 d5                	cmp    %edx,%ebp
  8020af:	72 10                	jb     8020c1 <__udivdi3+0xc1>
  8020b1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8020b5:	89 f9                	mov    %edi,%ecx
  8020b7:	d3 e6                	shl    %cl,%esi
  8020b9:	39 c6                	cmp    %eax,%esi
  8020bb:	73 07                	jae    8020c4 <__udivdi3+0xc4>
  8020bd:	39 d5                	cmp    %edx,%ebp
  8020bf:	75 03                	jne    8020c4 <__udivdi3+0xc4>
  8020c1:	83 eb 01             	sub    $0x1,%ebx
  8020c4:	31 ff                	xor    %edi,%edi
  8020c6:	89 d8                	mov    %ebx,%eax
  8020c8:	89 fa                	mov    %edi,%edx
  8020ca:	83 c4 1c             	add    $0x1c,%esp
  8020cd:	5b                   	pop    %ebx
  8020ce:	5e                   	pop    %esi
  8020cf:	5f                   	pop    %edi
  8020d0:	5d                   	pop    %ebp
  8020d1:	c3                   	ret    
  8020d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020d8:	31 ff                	xor    %edi,%edi
  8020da:	31 db                	xor    %ebx,%ebx
  8020dc:	89 d8                	mov    %ebx,%eax
  8020de:	89 fa                	mov    %edi,%edx
  8020e0:	83 c4 1c             	add    $0x1c,%esp
  8020e3:	5b                   	pop    %ebx
  8020e4:	5e                   	pop    %esi
  8020e5:	5f                   	pop    %edi
  8020e6:	5d                   	pop    %ebp
  8020e7:	c3                   	ret    
  8020e8:	90                   	nop
  8020e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020f0:	89 d8                	mov    %ebx,%eax
  8020f2:	f7 f7                	div    %edi
  8020f4:	31 ff                	xor    %edi,%edi
  8020f6:	89 c3                	mov    %eax,%ebx
  8020f8:	89 d8                	mov    %ebx,%eax
  8020fa:	89 fa                	mov    %edi,%edx
  8020fc:	83 c4 1c             	add    $0x1c,%esp
  8020ff:	5b                   	pop    %ebx
  802100:	5e                   	pop    %esi
  802101:	5f                   	pop    %edi
  802102:	5d                   	pop    %ebp
  802103:	c3                   	ret    
  802104:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802108:	39 ce                	cmp    %ecx,%esi
  80210a:	72 0c                	jb     802118 <__udivdi3+0x118>
  80210c:	31 db                	xor    %ebx,%ebx
  80210e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802112:	0f 87 34 ff ff ff    	ja     80204c <__udivdi3+0x4c>
  802118:	bb 01 00 00 00       	mov    $0x1,%ebx
  80211d:	e9 2a ff ff ff       	jmp    80204c <__udivdi3+0x4c>
  802122:	66 90                	xchg   %ax,%ax
  802124:	66 90                	xchg   %ax,%ax
  802126:	66 90                	xchg   %ax,%ax
  802128:	66 90                	xchg   %ax,%ax
  80212a:	66 90                	xchg   %ax,%ax
  80212c:	66 90                	xchg   %ax,%ax
  80212e:	66 90                	xchg   %ax,%ax

00802130 <__umoddi3>:
  802130:	55                   	push   %ebp
  802131:	57                   	push   %edi
  802132:	56                   	push   %esi
  802133:	53                   	push   %ebx
  802134:	83 ec 1c             	sub    $0x1c,%esp
  802137:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80213b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80213f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802143:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802147:	85 d2                	test   %edx,%edx
  802149:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80214d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802151:	89 f3                	mov    %esi,%ebx
  802153:	89 3c 24             	mov    %edi,(%esp)
  802156:	89 74 24 04          	mov    %esi,0x4(%esp)
  80215a:	75 1c                	jne    802178 <__umoddi3+0x48>
  80215c:	39 f7                	cmp    %esi,%edi
  80215e:	76 50                	jbe    8021b0 <__umoddi3+0x80>
  802160:	89 c8                	mov    %ecx,%eax
  802162:	89 f2                	mov    %esi,%edx
  802164:	f7 f7                	div    %edi
  802166:	89 d0                	mov    %edx,%eax
  802168:	31 d2                	xor    %edx,%edx
  80216a:	83 c4 1c             	add    $0x1c,%esp
  80216d:	5b                   	pop    %ebx
  80216e:	5e                   	pop    %esi
  80216f:	5f                   	pop    %edi
  802170:	5d                   	pop    %ebp
  802171:	c3                   	ret    
  802172:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802178:	39 f2                	cmp    %esi,%edx
  80217a:	89 d0                	mov    %edx,%eax
  80217c:	77 52                	ja     8021d0 <__umoddi3+0xa0>
  80217e:	0f bd ea             	bsr    %edx,%ebp
  802181:	83 f5 1f             	xor    $0x1f,%ebp
  802184:	75 5a                	jne    8021e0 <__umoddi3+0xb0>
  802186:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80218a:	0f 82 e0 00 00 00    	jb     802270 <__umoddi3+0x140>
  802190:	39 0c 24             	cmp    %ecx,(%esp)
  802193:	0f 86 d7 00 00 00    	jbe    802270 <__umoddi3+0x140>
  802199:	8b 44 24 08          	mov    0x8(%esp),%eax
  80219d:	8b 54 24 04          	mov    0x4(%esp),%edx
  8021a1:	83 c4 1c             	add    $0x1c,%esp
  8021a4:	5b                   	pop    %ebx
  8021a5:	5e                   	pop    %esi
  8021a6:	5f                   	pop    %edi
  8021a7:	5d                   	pop    %ebp
  8021a8:	c3                   	ret    
  8021a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021b0:	85 ff                	test   %edi,%edi
  8021b2:	89 fd                	mov    %edi,%ebp
  8021b4:	75 0b                	jne    8021c1 <__umoddi3+0x91>
  8021b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021bb:	31 d2                	xor    %edx,%edx
  8021bd:	f7 f7                	div    %edi
  8021bf:	89 c5                	mov    %eax,%ebp
  8021c1:	89 f0                	mov    %esi,%eax
  8021c3:	31 d2                	xor    %edx,%edx
  8021c5:	f7 f5                	div    %ebp
  8021c7:	89 c8                	mov    %ecx,%eax
  8021c9:	f7 f5                	div    %ebp
  8021cb:	89 d0                	mov    %edx,%eax
  8021cd:	eb 99                	jmp    802168 <__umoddi3+0x38>
  8021cf:	90                   	nop
  8021d0:	89 c8                	mov    %ecx,%eax
  8021d2:	89 f2                	mov    %esi,%edx
  8021d4:	83 c4 1c             	add    $0x1c,%esp
  8021d7:	5b                   	pop    %ebx
  8021d8:	5e                   	pop    %esi
  8021d9:	5f                   	pop    %edi
  8021da:	5d                   	pop    %ebp
  8021db:	c3                   	ret    
  8021dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021e0:	8b 34 24             	mov    (%esp),%esi
  8021e3:	bf 20 00 00 00       	mov    $0x20,%edi
  8021e8:	89 e9                	mov    %ebp,%ecx
  8021ea:	29 ef                	sub    %ebp,%edi
  8021ec:	d3 e0                	shl    %cl,%eax
  8021ee:	89 f9                	mov    %edi,%ecx
  8021f0:	89 f2                	mov    %esi,%edx
  8021f2:	d3 ea                	shr    %cl,%edx
  8021f4:	89 e9                	mov    %ebp,%ecx
  8021f6:	09 c2                	or     %eax,%edx
  8021f8:	89 d8                	mov    %ebx,%eax
  8021fa:	89 14 24             	mov    %edx,(%esp)
  8021fd:	89 f2                	mov    %esi,%edx
  8021ff:	d3 e2                	shl    %cl,%edx
  802201:	89 f9                	mov    %edi,%ecx
  802203:	89 54 24 04          	mov    %edx,0x4(%esp)
  802207:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80220b:	d3 e8                	shr    %cl,%eax
  80220d:	89 e9                	mov    %ebp,%ecx
  80220f:	89 c6                	mov    %eax,%esi
  802211:	d3 e3                	shl    %cl,%ebx
  802213:	89 f9                	mov    %edi,%ecx
  802215:	89 d0                	mov    %edx,%eax
  802217:	d3 e8                	shr    %cl,%eax
  802219:	89 e9                	mov    %ebp,%ecx
  80221b:	09 d8                	or     %ebx,%eax
  80221d:	89 d3                	mov    %edx,%ebx
  80221f:	89 f2                	mov    %esi,%edx
  802221:	f7 34 24             	divl   (%esp)
  802224:	89 d6                	mov    %edx,%esi
  802226:	d3 e3                	shl    %cl,%ebx
  802228:	f7 64 24 04          	mull   0x4(%esp)
  80222c:	39 d6                	cmp    %edx,%esi
  80222e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802232:	89 d1                	mov    %edx,%ecx
  802234:	89 c3                	mov    %eax,%ebx
  802236:	72 08                	jb     802240 <__umoddi3+0x110>
  802238:	75 11                	jne    80224b <__umoddi3+0x11b>
  80223a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80223e:	73 0b                	jae    80224b <__umoddi3+0x11b>
  802240:	2b 44 24 04          	sub    0x4(%esp),%eax
  802244:	1b 14 24             	sbb    (%esp),%edx
  802247:	89 d1                	mov    %edx,%ecx
  802249:	89 c3                	mov    %eax,%ebx
  80224b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80224f:	29 da                	sub    %ebx,%edx
  802251:	19 ce                	sbb    %ecx,%esi
  802253:	89 f9                	mov    %edi,%ecx
  802255:	89 f0                	mov    %esi,%eax
  802257:	d3 e0                	shl    %cl,%eax
  802259:	89 e9                	mov    %ebp,%ecx
  80225b:	d3 ea                	shr    %cl,%edx
  80225d:	89 e9                	mov    %ebp,%ecx
  80225f:	d3 ee                	shr    %cl,%esi
  802261:	09 d0                	or     %edx,%eax
  802263:	89 f2                	mov    %esi,%edx
  802265:	83 c4 1c             	add    $0x1c,%esp
  802268:	5b                   	pop    %ebx
  802269:	5e                   	pop    %esi
  80226a:	5f                   	pop    %edi
  80226b:	5d                   	pop    %ebp
  80226c:	c3                   	ret    
  80226d:	8d 76 00             	lea    0x0(%esi),%esi
  802270:	29 f9                	sub    %edi,%ecx
  802272:	19 d6                	sbb    %edx,%esi
  802274:	89 74 24 04          	mov    %esi,0x4(%esp)
  802278:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80227c:	e9 18 ff ff ff       	jmp    802199 <__umoddi3+0x69>
