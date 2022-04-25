
obj/user/testfile.debug:     file format elf32-i386


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
  80002c:	e8 f7 05 00 00       	call   800628 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <xopen>:

#define FVA ((struct Fd*)0xCCCCC000)

static int
xopen(const char *path, int mode)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
  80003a:	89 d3                	mov    %edx,%ebx
	extern union Fsipc fsipcbuf;
	envid_t fsenv;
	
	strcpy(fsipcbuf.open.req_path, path);
  80003c:	50                   	push   %eax
  80003d:	68 00 50 80 00       	push   $0x805000
  800042:	e8 bd 0c 00 00       	call   800d04 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800047:	89 1d 00 54 80 00    	mov    %ebx,0x805400

	fsenv = ipc_find_env(ENV_TYPE_FS);
  80004d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800054:	e8 48 13 00 00       	call   8013a1 <ipc_find_env>
	ipc_send(fsenv, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800059:	6a 07                	push   $0x7
  80005b:	68 00 50 80 00       	push   $0x805000
  800060:	6a 01                	push   $0x1
  800062:	50                   	push   %eax
  800063:	e8 e5 12 00 00       	call   80134d <ipc_send>
	return ipc_recv(NULL, FVA, NULL);
  800068:	83 c4 1c             	add    $0x1c,%esp
  80006b:	6a 00                	push   $0x0
  80006d:	68 00 c0 cc cc       	push   $0xccccc000
  800072:	6a 00                	push   $0x0
  800074:	e8 7f 12 00 00       	call   8012f8 <ipc_recv>
}
  800079:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80007c:	c9                   	leave  
  80007d:	c3                   	ret    

0080007e <umain>:

void
umain(int argc, char **argv)
{
  80007e:	55                   	push   %ebp
  80007f:	89 e5                	mov    %esp,%ebp
  800081:	57                   	push   %edi
  800082:	56                   	push   %esi
  800083:	53                   	push   %ebx
  800084:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	struct Fd fdcopy;
	struct Stat st;
	char buf[512];

	// We open files manually first, to avoid the FD layer
	if ((r = xopen("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  80008a:	ba 00 00 00 00       	mov    $0x0,%edx
  80008f:	b8 a0 23 80 00       	mov    $0x8023a0,%eax
  800094:	e8 9a ff ff ff       	call   800033 <xopen>
  800099:	83 f8 f5             	cmp    $0xfffffff5,%eax
  80009c:	74 1b                	je     8000b9 <umain+0x3b>
  80009e:	89 c2                	mov    %eax,%edx
  8000a0:	c1 ea 1f             	shr    $0x1f,%edx
  8000a3:	84 d2                	test   %dl,%dl
  8000a5:	74 12                	je     8000b9 <umain+0x3b>
		panic("serve_open /not-found: %e", r);
  8000a7:	50                   	push   %eax
  8000a8:	68 ab 23 80 00       	push   $0x8023ab
  8000ad:	6a 20                	push   $0x20
  8000af:	68 c5 23 80 00       	push   $0x8023c5
  8000b4:	e8 cf 05 00 00       	call   800688 <_panic>
	else if (r >= 0)
  8000b9:	85 c0                	test   %eax,%eax
  8000bb:	78 14                	js     8000d1 <umain+0x53>
		panic("serve_open /not-found succeeded!");
  8000bd:	83 ec 04             	sub    $0x4,%esp
  8000c0:	68 60 25 80 00       	push   $0x802560
  8000c5:	6a 22                	push   $0x22
  8000c7:	68 c5 23 80 00       	push   $0x8023c5
  8000cc:	e8 b7 05 00 00       	call   800688 <_panic>

	if ((r = xopen("/newmotd", O_RDONLY)) < 0)
  8000d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d6:	b8 d5 23 80 00       	mov    $0x8023d5,%eax
  8000db:	e8 53 ff ff ff       	call   800033 <xopen>
  8000e0:	85 c0                	test   %eax,%eax
  8000e2:	79 12                	jns    8000f6 <umain+0x78>
		panic("serve_open /newmotd: %e", r);
  8000e4:	50                   	push   %eax
  8000e5:	68 de 23 80 00       	push   $0x8023de
  8000ea:	6a 25                	push   $0x25
  8000ec:	68 c5 23 80 00       	push   $0x8023c5
  8000f1:	e8 92 05 00 00       	call   800688 <_panic>
	if (FVA->fd_dev_id != 'f' || FVA->fd_offset != 0 || FVA->fd_omode != O_RDONLY)
  8000f6:	83 3d 00 c0 cc cc 66 	cmpl   $0x66,0xccccc000
  8000fd:	75 12                	jne    800111 <umain+0x93>
  8000ff:	83 3d 04 c0 cc cc 00 	cmpl   $0x0,0xccccc004
  800106:	75 09                	jne    800111 <umain+0x93>
  800108:	83 3d 08 c0 cc cc 00 	cmpl   $0x0,0xccccc008
  80010f:	74 14                	je     800125 <umain+0xa7>
		panic("serve_open did not fill struct Fd correctly\n");
  800111:	83 ec 04             	sub    $0x4,%esp
  800114:	68 84 25 80 00       	push   $0x802584
  800119:	6a 27                	push   $0x27
  80011b:	68 c5 23 80 00       	push   $0x8023c5
  800120:	e8 63 05 00 00       	call   800688 <_panic>
	cprintf("serve_open is good\n");
  800125:	83 ec 0c             	sub    $0xc,%esp
  800128:	68 f6 23 80 00       	push   $0x8023f6
  80012d:	e8 2f 06 00 00       	call   800761 <cprintf>

	if ((r = devfile.dev_stat(FVA, &st)) < 0)
  800132:	83 c4 08             	add    $0x8,%esp
  800135:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  80013b:	50                   	push   %eax
  80013c:	68 00 c0 cc cc       	push   $0xccccc000
  800141:	ff 15 1c 30 80 00    	call   *0x80301c
  800147:	83 c4 10             	add    $0x10,%esp
  80014a:	85 c0                	test   %eax,%eax
  80014c:	79 12                	jns    800160 <umain+0xe2>
		panic("file_stat: %e", r);
  80014e:	50                   	push   %eax
  80014f:	68 0a 24 80 00       	push   $0x80240a
  800154:	6a 2b                	push   $0x2b
  800156:	68 c5 23 80 00       	push   $0x8023c5
  80015b:	e8 28 05 00 00       	call   800688 <_panic>
	if (strlen(msg) != st.st_size)
  800160:	83 ec 0c             	sub    $0xc,%esp
  800163:	ff 35 00 30 80 00    	pushl  0x803000
  800169:	e8 5d 0b 00 00       	call   800ccb <strlen>
  80016e:	83 c4 10             	add    $0x10,%esp
  800171:	3b 45 cc             	cmp    -0x34(%ebp),%eax
  800174:	74 25                	je     80019b <umain+0x11d>
		panic("file_stat returned size %d wanted %d\n", st.st_size, strlen(msg));
  800176:	83 ec 0c             	sub    $0xc,%esp
  800179:	ff 35 00 30 80 00    	pushl  0x803000
  80017f:	e8 47 0b 00 00       	call   800ccb <strlen>
  800184:	89 04 24             	mov    %eax,(%esp)
  800187:	ff 75 cc             	pushl  -0x34(%ebp)
  80018a:	68 b4 25 80 00       	push   $0x8025b4
  80018f:	6a 2d                	push   $0x2d
  800191:	68 c5 23 80 00       	push   $0x8023c5
  800196:	e8 ed 04 00 00       	call   800688 <_panic>
	cprintf("file_stat is good\n");
  80019b:	83 ec 0c             	sub    $0xc,%esp
  80019e:	68 18 24 80 00       	push   $0x802418
  8001a3:	e8 b9 05 00 00       	call   800761 <cprintf>

	memset(buf, 0, sizeof buf);
  8001a8:	83 c4 0c             	add    $0xc,%esp
  8001ab:	68 00 02 00 00       	push   $0x200
  8001b0:	6a 00                	push   $0x0
  8001b2:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  8001b8:	53                   	push   %ebx
  8001b9:	e8 8b 0c 00 00       	call   800e49 <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  8001be:	83 c4 0c             	add    $0xc,%esp
  8001c1:	68 00 02 00 00       	push   $0x200
  8001c6:	53                   	push   %ebx
  8001c7:	68 00 c0 cc cc       	push   $0xccccc000
  8001cc:	ff 15 10 30 80 00    	call   *0x803010
  8001d2:	83 c4 10             	add    $0x10,%esp
  8001d5:	85 c0                	test   %eax,%eax
  8001d7:	79 12                	jns    8001eb <umain+0x16d>
		panic("file_read: %e", r);
  8001d9:	50                   	push   %eax
  8001da:	68 2b 24 80 00       	push   $0x80242b
  8001df:	6a 32                	push   $0x32
  8001e1:	68 c5 23 80 00       	push   $0x8023c5
  8001e6:	e8 9d 04 00 00       	call   800688 <_panic>
	if (strcmp(buf, msg) != 0)
  8001eb:	83 ec 08             	sub    $0x8,%esp
  8001ee:	ff 35 00 30 80 00    	pushl  0x803000
  8001f4:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8001fa:	50                   	push   %eax
  8001fb:	e8 ae 0b 00 00       	call   800dae <strcmp>
  800200:	83 c4 10             	add    $0x10,%esp
  800203:	85 c0                	test   %eax,%eax
  800205:	74 14                	je     80021b <umain+0x19d>
		panic("file_read returned wrong data");
  800207:	83 ec 04             	sub    $0x4,%esp
  80020a:	68 39 24 80 00       	push   $0x802439
  80020f:	6a 34                	push   $0x34
  800211:	68 c5 23 80 00       	push   $0x8023c5
  800216:	e8 6d 04 00 00       	call   800688 <_panic>
	cprintf("file_read is good\n");
  80021b:	83 ec 0c             	sub    $0xc,%esp
  80021e:	68 57 24 80 00       	push   $0x802457
  800223:	e8 39 05 00 00       	call   800761 <cprintf>

	if ((r = devfile.dev_close(FVA)) < 0)
  800228:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  80022f:	ff 15 18 30 80 00    	call   *0x803018
  800235:	83 c4 10             	add    $0x10,%esp
  800238:	85 c0                	test   %eax,%eax
  80023a:	79 12                	jns    80024e <umain+0x1d0>
		panic("file_close: %e", r);
  80023c:	50                   	push   %eax
  80023d:	68 6a 24 80 00       	push   $0x80246a
  800242:	6a 38                	push   $0x38
  800244:	68 c5 23 80 00       	push   $0x8023c5
  800249:	e8 3a 04 00 00       	call   800688 <_panic>
	cprintf("file_close is good\n");
  80024e:	83 ec 0c             	sub    $0xc,%esp
  800251:	68 79 24 80 00       	push   $0x802479
  800256:	e8 06 05 00 00       	call   800761 <cprintf>

	// We're about to unmap the FD, but still need a way to get
	// the stale filenum to serve_read, so we make a local copy.
	// The file server won't think it's stale until we unmap the
	// FD page.
	fdcopy = *FVA;
  80025b:	a1 00 c0 cc cc       	mov    0xccccc000,%eax
  800260:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800263:	a1 04 c0 cc cc       	mov    0xccccc004,%eax
  800268:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80026b:	a1 08 c0 cc cc       	mov    0xccccc008,%eax
  800270:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800273:	a1 0c c0 cc cc       	mov    0xccccc00c,%eax
  800278:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	sys_page_unmap(0, FVA);
  80027b:	83 c4 08             	add    $0x8,%esp
  80027e:	68 00 c0 cc cc       	push   $0xccccc000
  800283:	6a 00                	push   $0x0
  800285:	e8 02 0f 00 00       	call   80118c <sys_page_unmap>

	if ((r = devfile.dev_read(&fdcopy, buf, sizeof buf)) != -E_INVAL)
  80028a:	83 c4 0c             	add    $0xc,%esp
  80028d:	68 00 02 00 00       	push   $0x200
  800292:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  800298:	50                   	push   %eax
  800299:	8d 45 d8             	lea    -0x28(%ebp),%eax
  80029c:	50                   	push   %eax
  80029d:	ff 15 10 30 80 00    	call   *0x803010
  8002a3:	83 c4 10             	add    $0x10,%esp
  8002a6:	83 f8 fd             	cmp    $0xfffffffd,%eax
  8002a9:	74 12                	je     8002bd <umain+0x23f>
		panic("serve_read does not handle stale fileids correctly: %e", r);
  8002ab:	50                   	push   %eax
  8002ac:	68 dc 25 80 00       	push   $0x8025dc
  8002b1:	6a 43                	push   $0x43
  8002b3:	68 c5 23 80 00       	push   $0x8023c5
  8002b8:	e8 cb 03 00 00       	call   800688 <_panic>
	cprintf("stale fileid is good\n");
  8002bd:	83 ec 0c             	sub    $0xc,%esp
  8002c0:	68 8d 24 80 00       	push   $0x80248d
  8002c5:	e8 97 04 00 00       	call   800761 <cprintf>

	// Try writing
	if ((r = xopen("/new-file", O_RDWR|O_CREAT)) < 0)
  8002ca:	ba 02 01 00 00       	mov    $0x102,%edx
  8002cf:	b8 a3 24 80 00       	mov    $0x8024a3,%eax
  8002d4:	e8 5a fd ff ff       	call   800033 <xopen>
  8002d9:	83 c4 10             	add    $0x10,%esp
  8002dc:	85 c0                	test   %eax,%eax
  8002de:	79 12                	jns    8002f2 <umain+0x274>
		panic("serve_open /new-file: %e", r);
  8002e0:	50                   	push   %eax
  8002e1:	68 ad 24 80 00       	push   $0x8024ad
  8002e6:	6a 48                	push   $0x48
  8002e8:	68 c5 23 80 00       	push   $0x8023c5
  8002ed:	e8 96 03 00 00       	call   800688 <_panic>

	if ((r = devfile.dev_write(FVA, msg, strlen(msg))) != strlen(msg))
  8002f2:	8b 1d 14 30 80 00    	mov    0x803014,%ebx
  8002f8:	83 ec 0c             	sub    $0xc,%esp
  8002fb:	ff 35 00 30 80 00    	pushl  0x803000
  800301:	e8 c5 09 00 00       	call   800ccb <strlen>
  800306:	83 c4 0c             	add    $0xc,%esp
  800309:	50                   	push   %eax
  80030a:	ff 35 00 30 80 00    	pushl  0x803000
  800310:	68 00 c0 cc cc       	push   $0xccccc000
  800315:	ff d3                	call   *%ebx
  800317:	89 c3                	mov    %eax,%ebx
  800319:	83 c4 04             	add    $0x4,%esp
  80031c:	ff 35 00 30 80 00    	pushl  0x803000
  800322:	e8 a4 09 00 00       	call   800ccb <strlen>
  800327:	83 c4 10             	add    $0x10,%esp
  80032a:	39 c3                	cmp    %eax,%ebx
  80032c:	74 12                	je     800340 <umain+0x2c2>
		panic("file_write: %e", r);
  80032e:	53                   	push   %ebx
  80032f:	68 c6 24 80 00       	push   $0x8024c6
  800334:	6a 4b                	push   $0x4b
  800336:	68 c5 23 80 00       	push   $0x8023c5
  80033b:	e8 48 03 00 00       	call   800688 <_panic>
	cprintf("file_write is good\n");
  800340:	83 ec 0c             	sub    $0xc,%esp
  800343:	68 d5 24 80 00       	push   $0x8024d5
  800348:	e8 14 04 00 00       	call   800761 <cprintf>

	FVA->fd_offset = 0;
  80034d:	c7 05 04 c0 cc cc 00 	movl   $0x0,0xccccc004
  800354:	00 00 00 
	memset(buf, 0, sizeof buf);
  800357:	83 c4 0c             	add    $0xc,%esp
  80035a:	68 00 02 00 00       	push   $0x200
  80035f:	6a 00                	push   $0x0
  800361:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  800367:	53                   	push   %ebx
  800368:	e8 dc 0a 00 00       	call   800e49 <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  80036d:	83 c4 0c             	add    $0xc,%esp
  800370:	68 00 02 00 00       	push   $0x200
  800375:	53                   	push   %ebx
  800376:	68 00 c0 cc cc       	push   $0xccccc000
  80037b:	ff 15 10 30 80 00    	call   *0x803010
  800381:	89 c3                	mov    %eax,%ebx
  800383:	83 c4 10             	add    $0x10,%esp
  800386:	85 c0                	test   %eax,%eax
  800388:	79 12                	jns    80039c <umain+0x31e>
		panic("file_read after file_write: %e", r);
  80038a:	50                   	push   %eax
  80038b:	68 14 26 80 00       	push   $0x802614
  800390:	6a 51                	push   $0x51
  800392:	68 c5 23 80 00       	push   $0x8023c5
  800397:	e8 ec 02 00 00       	call   800688 <_panic>
	if (r != strlen(msg))
  80039c:	83 ec 0c             	sub    $0xc,%esp
  80039f:	ff 35 00 30 80 00    	pushl  0x803000
  8003a5:	e8 21 09 00 00       	call   800ccb <strlen>
  8003aa:	83 c4 10             	add    $0x10,%esp
  8003ad:	39 c3                	cmp    %eax,%ebx
  8003af:	74 12                	je     8003c3 <umain+0x345>
		panic("file_read after file_write returned wrong length: %d", r);
  8003b1:	53                   	push   %ebx
  8003b2:	68 34 26 80 00       	push   $0x802634
  8003b7:	6a 53                	push   $0x53
  8003b9:	68 c5 23 80 00       	push   $0x8023c5
  8003be:	e8 c5 02 00 00       	call   800688 <_panic>
	if (strcmp(buf, msg) != 0)
  8003c3:	83 ec 08             	sub    $0x8,%esp
  8003c6:	ff 35 00 30 80 00    	pushl  0x803000
  8003cc:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8003d2:	50                   	push   %eax
  8003d3:	e8 d6 09 00 00       	call   800dae <strcmp>
  8003d8:	83 c4 10             	add    $0x10,%esp
  8003db:	85 c0                	test   %eax,%eax
  8003dd:	74 14                	je     8003f3 <umain+0x375>
		panic("file_read after file_write returned wrong data");
  8003df:	83 ec 04             	sub    $0x4,%esp
  8003e2:	68 6c 26 80 00       	push   $0x80266c
  8003e7:	6a 55                	push   $0x55
  8003e9:	68 c5 23 80 00       	push   $0x8023c5
  8003ee:	e8 95 02 00 00       	call   800688 <_panic>
	cprintf("file_read after file_write is good\n");
  8003f3:	83 ec 0c             	sub    $0xc,%esp
  8003f6:	68 9c 26 80 00       	push   $0x80269c
  8003fb:	e8 61 03 00 00       	call   800761 <cprintf>

	// Now we'll try out open
	if ((r = open("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  800400:	83 c4 08             	add    $0x8,%esp
  800403:	6a 00                	push   $0x0
  800405:	68 a0 23 80 00       	push   $0x8023a0
  80040a:	e8 32 17 00 00       	call   801b41 <open>
  80040f:	83 c4 10             	add    $0x10,%esp
  800412:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800415:	74 1b                	je     800432 <umain+0x3b4>
  800417:	89 c2                	mov    %eax,%edx
  800419:	c1 ea 1f             	shr    $0x1f,%edx
  80041c:	84 d2                	test   %dl,%dl
  80041e:	74 12                	je     800432 <umain+0x3b4>
		panic("open /not-found: %e", r);
  800420:	50                   	push   %eax
  800421:	68 b1 23 80 00       	push   $0x8023b1
  800426:	6a 5a                	push   $0x5a
  800428:	68 c5 23 80 00       	push   $0x8023c5
  80042d:	e8 56 02 00 00       	call   800688 <_panic>
	else if (r >= 0)
  800432:	85 c0                	test   %eax,%eax
  800434:	78 14                	js     80044a <umain+0x3cc>
		panic("open /not-found succeeded!");
  800436:	83 ec 04             	sub    $0x4,%esp
  800439:	68 e9 24 80 00       	push   $0x8024e9
  80043e:	6a 5c                	push   $0x5c
  800440:	68 c5 23 80 00       	push   $0x8023c5
  800445:	e8 3e 02 00 00       	call   800688 <_panic>

	if ((r = open("/newmotd", O_RDONLY)) < 0)
  80044a:	83 ec 08             	sub    $0x8,%esp
  80044d:	6a 00                	push   $0x0
  80044f:	68 d5 23 80 00       	push   $0x8023d5
  800454:	e8 e8 16 00 00       	call   801b41 <open>
  800459:	83 c4 10             	add    $0x10,%esp
  80045c:	85 c0                	test   %eax,%eax
  80045e:	79 12                	jns    800472 <umain+0x3f4>
		panic("open /newmotd: %e", r);
  800460:	50                   	push   %eax
  800461:	68 e4 23 80 00       	push   $0x8023e4
  800466:	6a 5f                	push   $0x5f
  800468:	68 c5 23 80 00       	push   $0x8023c5
  80046d:	e8 16 02 00 00       	call   800688 <_panic>
	fd = (struct Fd*) (0xD0000000 + r*PGSIZE);
  800472:	c1 e0 0c             	shl    $0xc,%eax
	if (fd->fd_dev_id != 'f' || fd->fd_offset != 0 || fd->fd_omode != O_RDONLY)
  800475:	83 b8 00 00 00 d0 66 	cmpl   $0x66,-0x30000000(%eax)
  80047c:	75 12                	jne    800490 <umain+0x412>
  80047e:	83 b8 04 00 00 d0 00 	cmpl   $0x0,-0x2ffffffc(%eax)
  800485:	75 09                	jne    800490 <umain+0x412>
  800487:	83 b8 08 00 00 d0 00 	cmpl   $0x0,-0x2ffffff8(%eax)
  80048e:	74 14                	je     8004a4 <umain+0x426>
		panic("open did not fill struct Fd correctly\n");
  800490:	83 ec 04             	sub    $0x4,%esp
  800493:	68 c0 26 80 00       	push   $0x8026c0
  800498:	6a 62                	push   $0x62
  80049a:	68 c5 23 80 00       	push   $0x8023c5
  80049f:	e8 e4 01 00 00       	call   800688 <_panic>
	cprintf("open is good\n");
  8004a4:	83 ec 0c             	sub    $0xc,%esp
  8004a7:	68 fc 23 80 00       	push   $0x8023fc
  8004ac:	e8 b0 02 00 00       	call   800761 <cprintf>

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
  8004b1:	83 c4 08             	add    $0x8,%esp
  8004b4:	68 01 01 00 00       	push   $0x101
  8004b9:	68 04 25 80 00       	push   $0x802504
  8004be:	e8 7e 16 00 00       	call   801b41 <open>
  8004c3:	89 c6                	mov    %eax,%esi
  8004c5:	83 c4 10             	add    $0x10,%esp
  8004c8:	85 c0                	test   %eax,%eax
  8004ca:	79 12                	jns    8004de <umain+0x460>
		panic("creat /big: %e", f);
  8004cc:	50                   	push   %eax
  8004cd:	68 09 25 80 00       	push   $0x802509
  8004d2:	6a 67                	push   $0x67
  8004d4:	68 c5 23 80 00       	push   $0x8023c5
  8004d9:	e8 aa 01 00 00       	call   800688 <_panic>
	memset(buf, 0, sizeof(buf));
  8004de:	83 ec 04             	sub    $0x4,%esp
  8004e1:	68 00 02 00 00       	push   $0x200
  8004e6:	6a 00                	push   $0x0
  8004e8:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8004ee:	50                   	push   %eax
  8004ef:	e8 55 09 00 00       	call   800e49 <memset>
  8004f4:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  8004f7:	bb 00 00 00 00       	mov    $0x0,%ebx
		*(int*)buf = i;
		if ((r = write(f, buf, sizeof(buf))) < 0)
  8004fc:	8d bd 4c fd ff ff    	lea    -0x2b4(%ebp),%edi
	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
		panic("creat /big: %e", f);
	memset(buf, 0, sizeof(buf));
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
  800502:	89 9d 4c fd ff ff    	mov    %ebx,-0x2b4(%ebp)
		if ((r = write(f, buf, sizeof(buf))) < 0)
  800508:	83 ec 04             	sub    $0x4,%esp
  80050b:	68 00 02 00 00       	push   $0x200
  800510:	57                   	push   %edi
  800511:	56                   	push   %esi
  800512:	e8 79 12 00 00       	call   801790 <write>
  800517:	83 c4 10             	add    $0x10,%esp
  80051a:	85 c0                	test   %eax,%eax
  80051c:	79 16                	jns    800534 <umain+0x4b6>
			panic("write /big@%d: %e", i, r);
  80051e:	83 ec 0c             	sub    $0xc,%esp
  800521:	50                   	push   %eax
  800522:	53                   	push   %ebx
  800523:	68 18 25 80 00       	push   $0x802518
  800528:	6a 6c                	push   $0x6c
  80052a:	68 c5 23 80 00       	push   $0x8023c5
  80052f:	e8 54 01 00 00       	call   800688 <_panic>
  800534:	8d 83 00 02 00 00    	lea    0x200(%ebx),%eax
  80053a:	89 c3                	mov    %eax,%ebx

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
		panic("creat /big: %e", f);
	memset(buf, 0, sizeof(buf));
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  80053c:	3d 00 e0 01 00       	cmp    $0x1e000,%eax
  800541:	75 bf                	jne    800502 <umain+0x484>
		*(int*)buf = i;
		if ((r = write(f, buf, sizeof(buf))) < 0)
			panic("write /big@%d: %e", i, r);
	}
	close(f);
  800543:	83 ec 0c             	sub    $0xc,%esp
  800546:	56                   	push   %esi
  800547:	e8 2e 10 00 00       	call   80157a <close>

	if ((f = open("/big", O_RDONLY)) < 0)
  80054c:	83 c4 08             	add    $0x8,%esp
  80054f:	6a 00                	push   $0x0
  800551:	68 04 25 80 00       	push   $0x802504
  800556:	e8 e6 15 00 00       	call   801b41 <open>
  80055b:	89 c6                	mov    %eax,%esi
  80055d:	83 c4 10             	add    $0x10,%esp
  800560:	85 c0                	test   %eax,%eax
  800562:	79 12                	jns    800576 <umain+0x4f8>
		panic("open /big: %e", f);
  800564:	50                   	push   %eax
  800565:	68 2a 25 80 00       	push   $0x80252a
  80056a:	6a 71                	push   $0x71
  80056c:	68 c5 23 80 00       	push   $0x8023c5
  800571:	e8 12 01 00 00       	call   800688 <_panic>
  800576:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  80057b:	8d bd 4c fd ff ff    	lea    -0x2b4(%ebp),%edi
	close(f);

	if ((f = open("/big", O_RDONLY)) < 0)
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
  800581:	89 9d 4c fd ff ff    	mov    %ebx,-0x2b4(%ebp)
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  800587:	83 ec 04             	sub    $0x4,%esp
  80058a:	68 00 02 00 00       	push   $0x200
  80058f:	57                   	push   %edi
  800590:	56                   	push   %esi
  800591:	e8 b1 11 00 00       	call   801747 <readn>
  800596:	83 c4 10             	add    $0x10,%esp
  800599:	85 c0                	test   %eax,%eax
  80059b:	79 16                	jns    8005b3 <umain+0x535>
			panic("read /big@%d: %e", i, r);
  80059d:	83 ec 0c             	sub    $0xc,%esp
  8005a0:	50                   	push   %eax
  8005a1:	53                   	push   %ebx
  8005a2:	68 38 25 80 00       	push   $0x802538
  8005a7:	6a 75                	push   $0x75
  8005a9:	68 c5 23 80 00       	push   $0x8023c5
  8005ae:	e8 d5 00 00 00       	call   800688 <_panic>
		if (r != sizeof(buf))
  8005b3:	3d 00 02 00 00       	cmp    $0x200,%eax
  8005b8:	74 1b                	je     8005d5 <umain+0x557>
			panic("read /big from %d returned %d < %d bytes",
  8005ba:	83 ec 08             	sub    $0x8,%esp
  8005bd:	68 00 02 00 00       	push   $0x200
  8005c2:	50                   	push   %eax
  8005c3:	53                   	push   %ebx
  8005c4:	68 e8 26 80 00       	push   $0x8026e8
  8005c9:	6a 78                	push   $0x78
  8005cb:	68 c5 23 80 00       	push   $0x8023c5
  8005d0:	e8 b3 00 00 00       	call   800688 <_panic>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
  8005d5:	8b 85 4c fd ff ff    	mov    -0x2b4(%ebp),%eax
  8005db:	39 d8                	cmp    %ebx,%eax
  8005dd:	74 16                	je     8005f5 <umain+0x577>
			panic("read /big from %d returned bad data %d",
  8005df:	83 ec 0c             	sub    $0xc,%esp
  8005e2:	50                   	push   %eax
  8005e3:	53                   	push   %ebx
  8005e4:	68 14 27 80 00       	push   $0x802714
  8005e9:	6a 7b                	push   $0x7b
  8005eb:	68 c5 23 80 00       	push   $0x8023c5
  8005f0:	e8 93 00 00 00       	call   800688 <_panic>
  8005f5:	8d 83 00 02 00 00    	lea    0x200(%ebx),%eax
  8005fb:	89 c3                	mov    %eax,%ebx
	}
	close(f);

	if ((f = open("/big", O_RDONLY)) < 0)
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  8005fd:	3d 00 e0 01 00       	cmp    $0x1e000,%eax
  800602:	0f 85 79 ff ff ff    	jne    800581 <umain+0x503>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
			panic("read /big from %d returned bad data %d",
			      i, *(int*)buf);
	}
	close(f);
  800608:	83 ec 0c             	sub    $0xc,%esp
  80060b:	56                   	push   %esi
  80060c:	e8 69 0f 00 00       	call   80157a <close>
	cprintf("large file is good\n");
  800611:	c7 04 24 49 25 80 00 	movl   $0x802549,(%esp)
  800618:	e8 44 01 00 00       	call   800761 <cprintf>
}
  80061d:	83 c4 10             	add    $0x10,%esp
  800620:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800623:	5b                   	pop    %ebx
  800624:	5e                   	pop    %esi
  800625:	5f                   	pop    %edi
  800626:	5d                   	pop    %ebp
  800627:	c3                   	ret    

00800628 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800628:	55                   	push   %ebp
  800629:	89 e5                	mov    %esp,%ebp
  80062b:	56                   	push   %esi
  80062c:	53                   	push   %ebx
  80062d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800630:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  800633:	e8 91 0a 00 00       	call   8010c9 <sys_getenvid>
  800638:	25 ff 03 00 00       	and    $0x3ff,%eax
  80063d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800640:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800645:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80064a:	85 db                	test   %ebx,%ebx
  80064c:	7e 07                	jle    800655 <libmain+0x2d>
		binaryname = argv[0];
  80064e:	8b 06                	mov    (%esi),%eax
  800650:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  800655:	83 ec 08             	sub    $0x8,%esp
  800658:	56                   	push   %esi
  800659:	53                   	push   %ebx
  80065a:	e8 1f fa ff ff       	call   80007e <umain>

	// exit gracefully
	exit();
  80065f:	e8 0a 00 00 00       	call   80066e <exit>
}
  800664:	83 c4 10             	add    $0x10,%esp
  800667:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80066a:	5b                   	pop    %ebx
  80066b:	5e                   	pop    %esi
  80066c:	5d                   	pop    %ebp
  80066d:	c3                   	ret    

0080066e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80066e:	55                   	push   %ebp
  80066f:	89 e5                	mov    %esp,%ebp
  800671:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800674:	e8 2c 0f 00 00       	call   8015a5 <close_all>
	sys_env_destroy(0);
  800679:	83 ec 0c             	sub    $0xc,%esp
  80067c:	6a 00                	push   $0x0
  80067e:	e8 05 0a 00 00       	call   801088 <sys_env_destroy>
}
  800683:	83 c4 10             	add    $0x10,%esp
  800686:	c9                   	leave  
  800687:	c3                   	ret    

00800688 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800688:	55                   	push   %ebp
  800689:	89 e5                	mov    %esp,%ebp
  80068b:	56                   	push   %esi
  80068c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80068d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800690:	8b 35 04 30 80 00    	mov    0x803004,%esi
  800696:	e8 2e 0a 00 00       	call   8010c9 <sys_getenvid>
  80069b:	83 ec 0c             	sub    $0xc,%esp
  80069e:	ff 75 0c             	pushl  0xc(%ebp)
  8006a1:	ff 75 08             	pushl  0x8(%ebp)
  8006a4:	56                   	push   %esi
  8006a5:	50                   	push   %eax
  8006a6:	68 6c 27 80 00       	push   $0x80276c
  8006ab:	e8 b1 00 00 00       	call   800761 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8006b0:	83 c4 18             	add    $0x18,%esp
  8006b3:	53                   	push   %ebx
  8006b4:	ff 75 10             	pushl  0x10(%ebp)
  8006b7:	e8 54 00 00 00       	call   800710 <vcprintf>
	cprintf("\n");
  8006bc:	c7 04 24 c3 2b 80 00 	movl   $0x802bc3,(%esp)
  8006c3:	e8 99 00 00 00       	call   800761 <cprintf>
  8006c8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8006cb:	cc                   	int3   
  8006cc:	eb fd                	jmp    8006cb <_panic+0x43>

008006ce <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8006ce:	55                   	push   %ebp
  8006cf:	89 e5                	mov    %esp,%ebp
  8006d1:	53                   	push   %ebx
  8006d2:	83 ec 04             	sub    $0x4,%esp
  8006d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8006d8:	8b 13                	mov    (%ebx),%edx
  8006da:	8d 42 01             	lea    0x1(%edx),%eax
  8006dd:	89 03                	mov    %eax,(%ebx)
  8006df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006e2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8006e6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8006eb:	75 1a                	jne    800707 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8006ed:	83 ec 08             	sub    $0x8,%esp
  8006f0:	68 ff 00 00 00       	push   $0xff
  8006f5:	8d 43 08             	lea    0x8(%ebx),%eax
  8006f8:	50                   	push   %eax
  8006f9:	e8 4d 09 00 00       	call   80104b <sys_cputs>
		b->idx = 0;
  8006fe:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800704:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800707:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80070b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80070e:	c9                   	leave  
  80070f:	c3                   	ret    

00800710 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800710:	55                   	push   %ebp
  800711:	89 e5                	mov    %esp,%ebp
  800713:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800719:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800720:	00 00 00 
	b.cnt = 0;
  800723:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80072a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80072d:	ff 75 0c             	pushl  0xc(%ebp)
  800730:	ff 75 08             	pushl  0x8(%ebp)
  800733:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800739:	50                   	push   %eax
  80073a:	68 ce 06 80 00       	push   $0x8006ce
  80073f:	e8 54 01 00 00       	call   800898 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800744:	83 c4 08             	add    $0x8,%esp
  800747:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80074d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800753:	50                   	push   %eax
  800754:	e8 f2 08 00 00       	call   80104b <sys_cputs>

	return b.cnt;
}
  800759:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80075f:	c9                   	leave  
  800760:	c3                   	ret    

00800761 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800761:	55                   	push   %ebp
  800762:	89 e5                	mov    %esp,%ebp
  800764:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800767:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80076a:	50                   	push   %eax
  80076b:	ff 75 08             	pushl  0x8(%ebp)
  80076e:	e8 9d ff ff ff       	call   800710 <vcprintf>
	va_end(ap);

	return cnt;
}
  800773:	c9                   	leave  
  800774:	c3                   	ret    

00800775 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800775:	55                   	push   %ebp
  800776:	89 e5                	mov    %esp,%ebp
  800778:	57                   	push   %edi
  800779:	56                   	push   %esi
  80077a:	53                   	push   %ebx
  80077b:	83 ec 1c             	sub    $0x1c,%esp
  80077e:	89 c7                	mov    %eax,%edi
  800780:	89 d6                	mov    %edx,%esi
  800782:	8b 45 08             	mov    0x8(%ebp),%eax
  800785:	8b 55 0c             	mov    0xc(%ebp),%edx
  800788:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80078b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80078e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800791:	bb 00 00 00 00       	mov    $0x0,%ebx
  800796:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800799:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80079c:	39 d3                	cmp    %edx,%ebx
  80079e:	72 05                	jb     8007a5 <printnum+0x30>
  8007a0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8007a3:	77 45                	ja     8007ea <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8007a5:	83 ec 0c             	sub    $0xc,%esp
  8007a8:	ff 75 18             	pushl  0x18(%ebp)
  8007ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ae:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8007b1:	53                   	push   %ebx
  8007b2:	ff 75 10             	pushl  0x10(%ebp)
  8007b5:	83 ec 08             	sub    $0x8,%esp
  8007b8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007bb:	ff 75 e0             	pushl  -0x20(%ebp)
  8007be:	ff 75 dc             	pushl  -0x24(%ebp)
  8007c1:	ff 75 d8             	pushl  -0x28(%ebp)
  8007c4:	e8 37 19 00 00       	call   802100 <__udivdi3>
  8007c9:	83 c4 18             	add    $0x18,%esp
  8007cc:	52                   	push   %edx
  8007cd:	50                   	push   %eax
  8007ce:	89 f2                	mov    %esi,%edx
  8007d0:	89 f8                	mov    %edi,%eax
  8007d2:	e8 9e ff ff ff       	call   800775 <printnum>
  8007d7:	83 c4 20             	add    $0x20,%esp
  8007da:	eb 18                	jmp    8007f4 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8007dc:	83 ec 08             	sub    $0x8,%esp
  8007df:	56                   	push   %esi
  8007e0:	ff 75 18             	pushl  0x18(%ebp)
  8007e3:	ff d7                	call   *%edi
  8007e5:	83 c4 10             	add    $0x10,%esp
  8007e8:	eb 03                	jmp    8007ed <printnum+0x78>
  8007ea:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8007ed:	83 eb 01             	sub    $0x1,%ebx
  8007f0:	85 db                	test   %ebx,%ebx
  8007f2:	7f e8                	jg     8007dc <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007f4:	83 ec 08             	sub    $0x8,%esp
  8007f7:	56                   	push   %esi
  8007f8:	83 ec 04             	sub    $0x4,%esp
  8007fb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007fe:	ff 75 e0             	pushl  -0x20(%ebp)
  800801:	ff 75 dc             	pushl  -0x24(%ebp)
  800804:	ff 75 d8             	pushl  -0x28(%ebp)
  800807:	e8 24 1a 00 00       	call   802230 <__umoddi3>
  80080c:	83 c4 14             	add    $0x14,%esp
  80080f:	0f be 80 8f 27 80 00 	movsbl 0x80278f(%eax),%eax
  800816:	50                   	push   %eax
  800817:	ff d7                	call   *%edi
}
  800819:	83 c4 10             	add    $0x10,%esp
  80081c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80081f:	5b                   	pop    %ebx
  800820:	5e                   	pop    %esi
  800821:	5f                   	pop    %edi
  800822:	5d                   	pop    %ebp
  800823:	c3                   	ret    

00800824 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800824:	55                   	push   %ebp
  800825:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800827:	83 fa 01             	cmp    $0x1,%edx
  80082a:	7e 0e                	jle    80083a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80082c:	8b 10                	mov    (%eax),%edx
  80082e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800831:	89 08                	mov    %ecx,(%eax)
  800833:	8b 02                	mov    (%edx),%eax
  800835:	8b 52 04             	mov    0x4(%edx),%edx
  800838:	eb 22                	jmp    80085c <getuint+0x38>
	else if (lflag)
  80083a:	85 d2                	test   %edx,%edx
  80083c:	74 10                	je     80084e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80083e:	8b 10                	mov    (%eax),%edx
  800840:	8d 4a 04             	lea    0x4(%edx),%ecx
  800843:	89 08                	mov    %ecx,(%eax)
  800845:	8b 02                	mov    (%edx),%eax
  800847:	ba 00 00 00 00       	mov    $0x0,%edx
  80084c:	eb 0e                	jmp    80085c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80084e:	8b 10                	mov    (%eax),%edx
  800850:	8d 4a 04             	lea    0x4(%edx),%ecx
  800853:	89 08                	mov    %ecx,(%eax)
  800855:	8b 02                	mov    (%edx),%eax
  800857:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80085c:	5d                   	pop    %ebp
  80085d:	c3                   	ret    

0080085e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80085e:	55                   	push   %ebp
  80085f:	89 e5                	mov    %esp,%ebp
  800861:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800864:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800868:	8b 10                	mov    (%eax),%edx
  80086a:	3b 50 04             	cmp    0x4(%eax),%edx
  80086d:	73 0a                	jae    800879 <sprintputch+0x1b>
		*b->buf++ = ch;
  80086f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800872:	89 08                	mov    %ecx,(%eax)
  800874:	8b 45 08             	mov    0x8(%ebp),%eax
  800877:	88 02                	mov    %al,(%edx)
}
  800879:	5d                   	pop    %ebp
  80087a:	c3                   	ret    

0080087b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800881:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800884:	50                   	push   %eax
  800885:	ff 75 10             	pushl  0x10(%ebp)
  800888:	ff 75 0c             	pushl  0xc(%ebp)
  80088b:	ff 75 08             	pushl  0x8(%ebp)
  80088e:	e8 05 00 00 00       	call   800898 <vprintfmt>
	va_end(ap);
}
  800893:	83 c4 10             	add    $0x10,%esp
  800896:	c9                   	leave  
  800897:	c3                   	ret    

00800898 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800898:	55                   	push   %ebp
  800899:	89 e5                	mov    %esp,%ebp
  80089b:	57                   	push   %edi
  80089c:	56                   	push   %esi
  80089d:	53                   	push   %ebx
  80089e:	83 ec 2c             	sub    $0x2c,%esp
  8008a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8008a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008a7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8008aa:	eb 12                	jmp    8008be <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8008ac:	85 c0                	test   %eax,%eax
  8008ae:	0f 84 a7 03 00 00    	je     800c5b <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
  8008b4:	83 ec 08             	sub    $0x8,%esp
  8008b7:	53                   	push   %ebx
  8008b8:	50                   	push   %eax
  8008b9:	ff d6                	call   *%esi
  8008bb:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008be:	83 c7 01             	add    $0x1,%edi
  8008c1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008c5:	83 f8 25             	cmp    $0x25,%eax
  8008c8:	75 e2                	jne    8008ac <vprintfmt+0x14>
  8008ca:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8008ce:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8008d5:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8008dc:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8008e3:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8008ea:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008ef:	eb 07                	jmp    8008f8 <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8008f4:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008f8:	8d 47 01             	lea    0x1(%edi),%eax
  8008fb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8008fe:	0f b6 07             	movzbl (%edi),%eax
  800901:	0f b6 d0             	movzbl %al,%edx
  800904:	83 e8 23             	sub    $0x23,%eax
  800907:	3c 55                	cmp    $0x55,%al
  800909:	0f 87 31 03 00 00    	ja     800c40 <vprintfmt+0x3a8>
  80090f:	0f b6 c0             	movzbl %al,%eax
  800912:	ff 24 85 e0 28 80 00 	jmp    *0x8028e0(,%eax,4)
  800919:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80091c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800920:	eb d6                	jmp    8008f8 <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800922:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800925:	b8 00 00 00 00       	mov    $0x0,%eax
  80092a:	89 75 08             	mov    %esi,0x8(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80092d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800930:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800934:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800937:	8d 72 d0             	lea    -0x30(%edx),%esi
  80093a:	83 fe 09             	cmp    $0x9,%esi
  80093d:	77 34                	ja     800973 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80093f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800942:	eb e9                	jmp    80092d <vprintfmt+0x95>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800944:	8b 45 14             	mov    0x14(%ebp),%eax
  800947:	8d 50 04             	lea    0x4(%eax),%edx
  80094a:	89 55 14             	mov    %edx,0x14(%ebp)
  80094d:	8b 00                	mov    (%eax),%eax
  80094f:	89 45 cc             	mov    %eax,-0x34(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800952:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800955:	eb 22                	jmp    800979 <vprintfmt+0xe1>
  800957:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80095a:	85 c0                	test   %eax,%eax
  80095c:	0f 48 c1             	cmovs  %ecx,%eax
  80095f:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800962:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800965:	eb 91                	jmp    8008f8 <vprintfmt+0x60>
  800967:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80096a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800971:	eb 85                	jmp    8008f8 <vprintfmt+0x60>
  800973:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800976:	8b 75 08             	mov    0x8(%ebp),%esi

		process_precision:
			if (width < 0)
  800979:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80097d:	0f 89 75 ff ff ff    	jns    8008f8 <vprintfmt+0x60>
				width = precision, precision = -1;
  800983:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800986:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800989:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800990:	e9 63 ff ff ff       	jmp    8008f8 <vprintfmt+0x60>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800995:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800999:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80099c:	e9 57 ff ff ff       	jmp    8008f8 <vprintfmt+0x60>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8009a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a4:	8d 50 04             	lea    0x4(%eax),%edx
  8009a7:	89 55 14             	mov    %edx,0x14(%ebp)
  8009aa:	83 ec 08             	sub    $0x8,%esp
  8009ad:	53                   	push   %ebx
  8009ae:	ff 30                	pushl  (%eax)
  8009b0:	ff d6                	call   *%esi
			break;
  8009b2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8009b8:	e9 01 ff ff ff       	jmp    8008be <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8009bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8009c0:	8d 50 04             	lea    0x4(%eax),%edx
  8009c3:	89 55 14             	mov    %edx,0x14(%ebp)
  8009c6:	8b 00                	mov    (%eax),%eax
  8009c8:	99                   	cltd   
  8009c9:	31 d0                	xor    %edx,%eax
  8009cb:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8009cd:	83 f8 0f             	cmp    $0xf,%eax
  8009d0:	7f 0b                	jg     8009dd <vprintfmt+0x145>
  8009d2:	8b 14 85 40 2a 80 00 	mov    0x802a40(,%eax,4),%edx
  8009d9:	85 d2                	test   %edx,%edx
  8009db:	75 18                	jne    8009f5 <vprintfmt+0x15d>
				printfmt(putch, putdat, "error %d", err);
  8009dd:	50                   	push   %eax
  8009de:	68 a7 27 80 00       	push   $0x8027a7
  8009e3:	53                   	push   %ebx
  8009e4:	56                   	push   %esi
  8009e5:	e8 91 fe ff ff       	call   80087b <printfmt>
  8009ea:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8009f0:	e9 c9 fe ff ff       	jmp    8008be <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8009f5:	52                   	push   %edx
  8009f6:	68 91 2b 80 00       	push   $0x802b91
  8009fb:	53                   	push   %ebx
  8009fc:	56                   	push   %esi
  8009fd:	e8 79 fe ff ff       	call   80087b <printfmt>
  800a02:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a05:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a08:	e9 b1 fe ff ff       	jmp    8008be <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800a0d:	8b 45 14             	mov    0x14(%ebp),%eax
  800a10:	8d 50 04             	lea    0x4(%eax),%edx
  800a13:	89 55 14             	mov    %edx,0x14(%ebp)
  800a16:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800a18:	85 ff                	test   %edi,%edi
  800a1a:	b8 a0 27 80 00       	mov    $0x8027a0,%eax
  800a1f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800a22:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800a26:	0f 8e 94 00 00 00    	jle    800ac0 <vprintfmt+0x228>
  800a2c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800a30:	0f 84 98 00 00 00    	je     800ace <vprintfmt+0x236>
				for (width -= strnlen(p, precision); width > 0; width--)
  800a36:	83 ec 08             	sub    $0x8,%esp
  800a39:	ff 75 cc             	pushl  -0x34(%ebp)
  800a3c:	57                   	push   %edi
  800a3d:	e8 a1 02 00 00       	call   800ce3 <strnlen>
  800a42:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800a45:	29 c1                	sub    %eax,%ecx
  800a47:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800a4a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800a4d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800a51:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a54:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800a57:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a59:	eb 0f                	jmp    800a6a <vprintfmt+0x1d2>
					putch(padc, putdat);
  800a5b:	83 ec 08             	sub    $0x8,%esp
  800a5e:	53                   	push   %ebx
  800a5f:	ff 75 e0             	pushl  -0x20(%ebp)
  800a62:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a64:	83 ef 01             	sub    $0x1,%edi
  800a67:	83 c4 10             	add    $0x10,%esp
  800a6a:	85 ff                	test   %edi,%edi
  800a6c:	7f ed                	jg     800a5b <vprintfmt+0x1c3>
  800a6e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800a71:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800a74:	85 c9                	test   %ecx,%ecx
  800a76:	b8 00 00 00 00       	mov    $0x0,%eax
  800a7b:	0f 49 c1             	cmovns %ecx,%eax
  800a7e:	29 c1                	sub    %eax,%ecx
  800a80:	89 75 08             	mov    %esi,0x8(%ebp)
  800a83:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800a86:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a89:	89 cb                	mov    %ecx,%ebx
  800a8b:	eb 4d                	jmp    800ada <vprintfmt+0x242>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a8d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800a91:	74 1b                	je     800aae <vprintfmt+0x216>
  800a93:	0f be c0             	movsbl %al,%eax
  800a96:	83 e8 20             	sub    $0x20,%eax
  800a99:	83 f8 5e             	cmp    $0x5e,%eax
  800a9c:	76 10                	jbe    800aae <vprintfmt+0x216>
					putch('?', putdat);
  800a9e:	83 ec 08             	sub    $0x8,%esp
  800aa1:	ff 75 0c             	pushl  0xc(%ebp)
  800aa4:	6a 3f                	push   $0x3f
  800aa6:	ff 55 08             	call   *0x8(%ebp)
  800aa9:	83 c4 10             	add    $0x10,%esp
  800aac:	eb 0d                	jmp    800abb <vprintfmt+0x223>
				else
					putch(ch, putdat);
  800aae:	83 ec 08             	sub    $0x8,%esp
  800ab1:	ff 75 0c             	pushl  0xc(%ebp)
  800ab4:	52                   	push   %edx
  800ab5:	ff 55 08             	call   *0x8(%ebp)
  800ab8:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800abb:	83 eb 01             	sub    $0x1,%ebx
  800abe:	eb 1a                	jmp    800ada <vprintfmt+0x242>
  800ac0:	89 75 08             	mov    %esi,0x8(%ebp)
  800ac3:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800ac6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800ac9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800acc:	eb 0c                	jmp    800ada <vprintfmt+0x242>
  800ace:	89 75 08             	mov    %esi,0x8(%ebp)
  800ad1:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800ad4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800ad7:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800ada:	83 c7 01             	add    $0x1,%edi
  800add:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800ae1:	0f be d0             	movsbl %al,%edx
  800ae4:	85 d2                	test   %edx,%edx
  800ae6:	74 23                	je     800b0b <vprintfmt+0x273>
  800ae8:	85 f6                	test   %esi,%esi
  800aea:	78 a1                	js     800a8d <vprintfmt+0x1f5>
  800aec:	83 ee 01             	sub    $0x1,%esi
  800aef:	79 9c                	jns    800a8d <vprintfmt+0x1f5>
  800af1:	89 df                	mov    %ebx,%edi
  800af3:	8b 75 08             	mov    0x8(%ebp),%esi
  800af6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800af9:	eb 18                	jmp    800b13 <vprintfmt+0x27b>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800afb:	83 ec 08             	sub    $0x8,%esp
  800afe:	53                   	push   %ebx
  800aff:	6a 20                	push   $0x20
  800b01:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800b03:	83 ef 01             	sub    $0x1,%edi
  800b06:	83 c4 10             	add    $0x10,%esp
  800b09:	eb 08                	jmp    800b13 <vprintfmt+0x27b>
  800b0b:	89 df                	mov    %ebx,%edi
  800b0d:	8b 75 08             	mov    0x8(%ebp),%esi
  800b10:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b13:	85 ff                	test   %edi,%edi
  800b15:	7f e4                	jg     800afb <vprintfmt+0x263>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b17:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800b1a:	e9 9f fd ff ff       	jmp    8008be <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800b1f:	83 7d d0 01          	cmpl   $0x1,-0x30(%ebp)
  800b23:	7e 16                	jle    800b3b <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  800b25:	8b 45 14             	mov    0x14(%ebp),%eax
  800b28:	8d 50 08             	lea    0x8(%eax),%edx
  800b2b:	89 55 14             	mov    %edx,0x14(%ebp)
  800b2e:	8b 50 04             	mov    0x4(%eax),%edx
  800b31:	8b 00                	mov    (%eax),%eax
  800b33:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b36:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800b39:	eb 34                	jmp    800b6f <vprintfmt+0x2d7>
	else if (lflag)
  800b3b:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800b3f:	74 18                	je     800b59 <vprintfmt+0x2c1>
		return va_arg(*ap, long);
  800b41:	8b 45 14             	mov    0x14(%ebp),%eax
  800b44:	8d 50 04             	lea    0x4(%eax),%edx
  800b47:	89 55 14             	mov    %edx,0x14(%ebp)
  800b4a:	8b 00                	mov    (%eax),%eax
  800b4c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b4f:	89 c1                	mov    %eax,%ecx
  800b51:	c1 f9 1f             	sar    $0x1f,%ecx
  800b54:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800b57:	eb 16                	jmp    800b6f <vprintfmt+0x2d7>
	else
		return va_arg(*ap, int);
  800b59:	8b 45 14             	mov    0x14(%ebp),%eax
  800b5c:	8d 50 04             	lea    0x4(%eax),%edx
  800b5f:	89 55 14             	mov    %edx,0x14(%ebp)
  800b62:	8b 00                	mov    (%eax),%eax
  800b64:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b67:	89 c1                	mov    %eax,%ecx
  800b69:	c1 f9 1f             	sar    $0x1f,%ecx
  800b6c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800b6f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800b72:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800b75:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800b7a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800b7e:	0f 89 88 00 00 00    	jns    800c0c <vprintfmt+0x374>
				putch('-', putdat);
  800b84:	83 ec 08             	sub    $0x8,%esp
  800b87:	53                   	push   %ebx
  800b88:	6a 2d                	push   $0x2d
  800b8a:	ff d6                	call   *%esi
				num = -(long long) num;
  800b8c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800b8f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800b92:	f7 d8                	neg    %eax
  800b94:	83 d2 00             	adc    $0x0,%edx
  800b97:	f7 da                	neg    %edx
  800b99:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800b9c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800ba1:	eb 69                	jmp    800c0c <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800ba3:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800ba6:	8d 45 14             	lea    0x14(%ebp),%eax
  800ba9:	e8 76 fc ff ff       	call   800824 <getuint>
			base = 10;
  800bae:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800bb3:	eb 57                	jmp    800c0c <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  800bb5:	83 ec 08             	sub    $0x8,%esp
  800bb8:	53                   	push   %ebx
  800bb9:	6a 30                	push   $0x30
  800bbb:	ff d6                	call   *%esi
			num = getuint(&ap, lflag);
  800bbd:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800bc0:	8d 45 14             	lea    0x14(%ebp),%eax
  800bc3:	e8 5c fc ff ff       	call   800824 <getuint>
			base = 8;
			goto number;
  800bc8:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800bcb:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800bd0:	eb 3a                	jmp    800c0c <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  800bd2:	83 ec 08             	sub    $0x8,%esp
  800bd5:	53                   	push   %ebx
  800bd6:	6a 30                	push   $0x30
  800bd8:	ff d6                	call   *%esi
			putch('x', putdat);
  800bda:	83 c4 08             	add    $0x8,%esp
  800bdd:	53                   	push   %ebx
  800bde:	6a 78                	push   $0x78
  800be0:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800be2:	8b 45 14             	mov    0x14(%ebp),%eax
  800be5:	8d 50 04             	lea    0x4(%eax),%edx
  800be8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800beb:	8b 00                	mov    (%eax),%eax
  800bed:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800bf2:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800bf5:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800bfa:	eb 10                	jmp    800c0c <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800bfc:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800bff:	8d 45 14             	lea    0x14(%ebp),%eax
  800c02:	e8 1d fc ff ff       	call   800824 <getuint>
			base = 16;
  800c07:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800c0c:	83 ec 0c             	sub    $0xc,%esp
  800c0f:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800c13:	57                   	push   %edi
  800c14:	ff 75 e0             	pushl  -0x20(%ebp)
  800c17:	51                   	push   %ecx
  800c18:	52                   	push   %edx
  800c19:	50                   	push   %eax
  800c1a:	89 da                	mov    %ebx,%edx
  800c1c:	89 f0                	mov    %esi,%eax
  800c1e:	e8 52 fb ff ff       	call   800775 <printnum>
			break;
  800c23:	83 c4 20             	add    $0x20,%esp
  800c26:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800c29:	e9 90 fc ff ff       	jmp    8008be <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800c2e:	83 ec 08             	sub    $0x8,%esp
  800c31:	53                   	push   %ebx
  800c32:	52                   	push   %edx
  800c33:	ff d6                	call   *%esi
			break;
  800c35:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c38:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800c3b:	e9 7e fc ff ff       	jmp    8008be <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800c40:	83 ec 08             	sub    $0x8,%esp
  800c43:	53                   	push   %ebx
  800c44:	6a 25                	push   $0x25
  800c46:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c48:	83 c4 10             	add    $0x10,%esp
  800c4b:	eb 03                	jmp    800c50 <vprintfmt+0x3b8>
  800c4d:	83 ef 01             	sub    $0x1,%edi
  800c50:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800c54:	75 f7                	jne    800c4d <vprintfmt+0x3b5>
  800c56:	e9 63 fc ff ff       	jmp    8008be <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800c5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5e:	5b                   	pop    %ebx
  800c5f:	5e                   	pop    %esi
  800c60:	5f                   	pop    %edi
  800c61:	5d                   	pop    %ebp
  800c62:	c3                   	ret    

00800c63 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c63:	55                   	push   %ebp
  800c64:	89 e5                	mov    %esp,%ebp
  800c66:	83 ec 18             	sub    $0x18,%esp
  800c69:	8b 45 08             	mov    0x8(%ebp),%eax
  800c6c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c6f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c72:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800c76:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800c79:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800c80:	85 c0                	test   %eax,%eax
  800c82:	74 26                	je     800caa <vsnprintf+0x47>
  800c84:	85 d2                	test   %edx,%edx
  800c86:	7e 22                	jle    800caa <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c88:	ff 75 14             	pushl  0x14(%ebp)
  800c8b:	ff 75 10             	pushl  0x10(%ebp)
  800c8e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c91:	50                   	push   %eax
  800c92:	68 5e 08 80 00       	push   $0x80085e
  800c97:	e8 fc fb ff ff       	call   800898 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c9c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c9f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800ca2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ca5:	83 c4 10             	add    $0x10,%esp
  800ca8:	eb 05                	jmp    800caf <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800caa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800caf:	c9                   	leave  
  800cb0:	c3                   	ret    

00800cb1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800cb1:	55                   	push   %ebp
  800cb2:	89 e5                	mov    %esp,%ebp
  800cb4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800cb7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800cba:	50                   	push   %eax
  800cbb:	ff 75 10             	pushl  0x10(%ebp)
  800cbe:	ff 75 0c             	pushl  0xc(%ebp)
  800cc1:	ff 75 08             	pushl  0x8(%ebp)
  800cc4:	e8 9a ff ff ff       	call   800c63 <vsnprintf>
	va_end(ap);

	return rc;
}
  800cc9:	c9                   	leave  
  800cca:	c3                   	ret    

00800ccb <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ccb:	55                   	push   %ebp
  800ccc:	89 e5                	mov    %esp,%ebp
  800cce:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800cd1:	b8 00 00 00 00       	mov    $0x0,%eax
  800cd6:	eb 03                	jmp    800cdb <strlen+0x10>
		n++;
  800cd8:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800cdb:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800cdf:	75 f7                	jne    800cd8 <strlen+0xd>
		n++;
	return n;
}
  800ce1:	5d                   	pop    %ebp
  800ce2:	c3                   	ret    

00800ce3 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800ce3:	55                   	push   %ebp
  800ce4:	89 e5                	mov    %esp,%ebp
  800ce6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ce9:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cec:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf1:	eb 03                	jmp    800cf6 <strnlen+0x13>
		n++;
  800cf3:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cf6:	39 c2                	cmp    %eax,%edx
  800cf8:	74 08                	je     800d02 <strnlen+0x1f>
  800cfa:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800cfe:	75 f3                	jne    800cf3 <strnlen+0x10>
  800d00:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800d02:	5d                   	pop    %ebp
  800d03:	c3                   	ret    

00800d04 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d04:	55                   	push   %ebp
  800d05:	89 e5                	mov    %esp,%ebp
  800d07:	53                   	push   %ebx
  800d08:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d0e:	89 c2                	mov    %eax,%edx
  800d10:	83 c2 01             	add    $0x1,%edx
  800d13:	83 c1 01             	add    $0x1,%ecx
  800d16:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800d1a:	88 5a ff             	mov    %bl,-0x1(%edx)
  800d1d:	84 db                	test   %bl,%bl
  800d1f:	75 ef                	jne    800d10 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800d21:	5b                   	pop    %ebx
  800d22:	5d                   	pop    %ebp
  800d23:	c3                   	ret    

00800d24 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d24:	55                   	push   %ebp
  800d25:	89 e5                	mov    %esp,%ebp
  800d27:	53                   	push   %ebx
  800d28:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d2b:	53                   	push   %ebx
  800d2c:	e8 9a ff ff ff       	call   800ccb <strlen>
  800d31:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800d34:	ff 75 0c             	pushl  0xc(%ebp)
  800d37:	01 d8                	add    %ebx,%eax
  800d39:	50                   	push   %eax
  800d3a:	e8 c5 ff ff ff       	call   800d04 <strcpy>
	return dst;
}
  800d3f:	89 d8                	mov    %ebx,%eax
  800d41:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d44:	c9                   	leave  
  800d45:	c3                   	ret    

00800d46 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d46:	55                   	push   %ebp
  800d47:	89 e5                	mov    %esp,%ebp
  800d49:	56                   	push   %esi
  800d4a:	53                   	push   %ebx
  800d4b:	8b 75 08             	mov    0x8(%ebp),%esi
  800d4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d51:	89 f3                	mov    %esi,%ebx
  800d53:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d56:	89 f2                	mov    %esi,%edx
  800d58:	eb 0f                	jmp    800d69 <strncpy+0x23>
		*dst++ = *src;
  800d5a:	83 c2 01             	add    $0x1,%edx
  800d5d:	0f b6 01             	movzbl (%ecx),%eax
  800d60:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800d63:	80 39 01             	cmpb   $0x1,(%ecx)
  800d66:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d69:	39 da                	cmp    %ebx,%edx
  800d6b:	75 ed                	jne    800d5a <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800d6d:	89 f0                	mov    %esi,%eax
  800d6f:	5b                   	pop    %ebx
  800d70:	5e                   	pop    %esi
  800d71:	5d                   	pop    %ebp
  800d72:	c3                   	ret    

00800d73 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d73:	55                   	push   %ebp
  800d74:	89 e5                	mov    %esp,%ebp
  800d76:	56                   	push   %esi
  800d77:	53                   	push   %ebx
  800d78:	8b 75 08             	mov    0x8(%ebp),%esi
  800d7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7e:	8b 55 10             	mov    0x10(%ebp),%edx
  800d81:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d83:	85 d2                	test   %edx,%edx
  800d85:	74 21                	je     800da8 <strlcpy+0x35>
  800d87:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800d8b:	89 f2                	mov    %esi,%edx
  800d8d:	eb 09                	jmp    800d98 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800d8f:	83 c2 01             	add    $0x1,%edx
  800d92:	83 c1 01             	add    $0x1,%ecx
  800d95:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d98:	39 c2                	cmp    %eax,%edx
  800d9a:	74 09                	je     800da5 <strlcpy+0x32>
  800d9c:	0f b6 19             	movzbl (%ecx),%ebx
  800d9f:	84 db                	test   %bl,%bl
  800da1:	75 ec                	jne    800d8f <strlcpy+0x1c>
  800da3:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800da5:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800da8:	29 f0                	sub    %esi,%eax
}
  800daa:	5b                   	pop    %ebx
  800dab:	5e                   	pop    %esi
  800dac:	5d                   	pop    %ebp
  800dad:	c3                   	ret    

00800dae <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800dae:	55                   	push   %ebp
  800daf:	89 e5                	mov    %esp,%ebp
  800db1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800db4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800db7:	eb 06                	jmp    800dbf <strcmp+0x11>
		p++, q++;
  800db9:	83 c1 01             	add    $0x1,%ecx
  800dbc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800dbf:	0f b6 01             	movzbl (%ecx),%eax
  800dc2:	84 c0                	test   %al,%al
  800dc4:	74 04                	je     800dca <strcmp+0x1c>
  800dc6:	3a 02                	cmp    (%edx),%al
  800dc8:	74 ef                	je     800db9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800dca:	0f b6 c0             	movzbl %al,%eax
  800dcd:	0f b6 12             	movzbl (%edx),%edx
  800dd0:	29 d0                	sub    %edx,%eax
}
  800dd2:	5d                   	pop    %ebp
  800dd3:	c3                   	ret    

00800dd4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800dd4:	55                   	push   %ebp
  800dd5:	89 e5                	mov    %esp,%ebp
  800dd7:	53                   	push   %ebx
  800dd8:	8b 45 08             	mov    0x8(%ebp),%eax
  800ddb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dde:	89 c3                	mov    %eax,%ebx
  800de0:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800de3:	eb 06                	jmp    800deb <strncmp+0x17>
		n--, p++, q++;
  800de5:	83 c0 01             	add    $0x1,%eax
  800de8:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800deb:	39 d8                	cmp    %ebx,%eax
  800ded:	74 15                	je     800e04 <strncmp+0x30>
  800def:	0f b6 08             	movzbl (%eax),%ecx
  800df2:	84 c9                	test   %cl,%cl
  800df4:	74 04                	je     800dfa <strncmp+0x26>
  800df6:	3a 0a                	cmp    (%edx),%cl
  800df8:	74 eb                	je     800de5 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800dfa:	0f b6 00             	movzbl (%eax),%eax
  800dfd:	0f b6 12             	movzbl (%edx),%edx
  800e00:	29 d0                	sub    %edx,%eax
  800e02:	eb 05                	jmp    800e09 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800e04:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800e09:	5b                   	pop    %ebx
  800e0a:	5d                   	pop    %ebp
  800e0b:	c3                   	ret    

00800e0c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e0c:	55                   	push   %ebp
  800e0d:	89 e5                	mov    %esp,%ebp
  800e0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e12:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e16:	eb 07                	jmp    800e1f <strchr+0x13>
		if (*s == c)
  800e18:	38 ca                	cmp    %cl,%dl
  800e1a:	74 0f                	je     800e2b <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e1c:	83 c0 01             	add    $0x1,%eax
  800e1f:	0f b6 10             	movzbl (%eax),%edx
  800e22:	84 d2                	test   %dl,%dl
  800e24:	75 f2                	jne    800e18 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800e26:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e2b:	5d                   	pop    %ebp
  800e2c:	c3                   	ret    

00800e2d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e2d:	55                   	push   %ebp
  800e2e:	89 e5                	mov    %esp,%ebp
  800e30:	8b 45 08             	mov    0x8(%ebp),%eax
  800e33:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e37:	eb 03                	jmp    800e3c <strfind+0xf>
  800e39:	83 c0 01             	add    $0x1,%eax
  800e3c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800e3f:	38 ca                	cmp    %cl,%dl
  800e41:	74 04                	je     800e47 <strfind+0x1a>
  800e43:	84 d2                	test   %dl,%dl
  800e45:	75 f2                	jne    800e39 <strfind+0xc>
			break;
	return (char *) s;
}
  800e47:	5d                   	pop    %ebp
  800e48:	c3                   	ret    

00800e49 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e49:	55                   	push   %ebp
  800e4a:	89 e5                	mov    %esp,%ebp
  800e4c:	57                   	push   %edi
  800e4d:	56                   	push   %esi
  800e4e:	53                   	push   %ebx
  800e4f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e52:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800e55:	85 c9                	test   %ecx,%ecx
  800e57:	74 36                	je     800e8f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800e59:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e5f:	75 28                	jne    800e89 <memset+0x40>
  800e61:	f6 c1 03             	test   $0x3,%cl
  800e64:	75 23                	jne    800e89 <memset+0x40>
		c &= 0xFF;
  800e66:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e6a:	89 d3                	mov    %edx,%ebx
  800e6c:	c1 e3 08             	shl    $0x8,%ebx
  800e6f:	89 d6                	mov    %edx,%esi
  800e71:	c1 e6 18             	shl    $0x18,%esi
  800e74:	89 d0                	mov    %edx,%eax
  800e76:	c1 e0 10             	shl    $0x10,%eax
  800e79:	09 f0                	or     %esi,%eax
  800e7b:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800e7d:	89 d8                	mov    %ebx,%eax
  800e7f:	09 d0                	or     %edx,%eax
  800e81:	c1 e9 02             	shr    $0x2,%ecx
  800e84:	fc                   	cld    
  800e85:	f3 ab                	rep stos %eax,%es:(%edi)
  800e87:	eb 06                	jmp    800e8f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e89:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e8c:	fc                   	cld    
  800e8d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800e8f:	89 f8                	mov    %edi,%eax
  800e91:	5b                   	pop    %ebx
  800e92:	5e                   	pop    %esi
  800e93:	5f                   	pop    %edi
  800e94:	5d                   	pop    %ebp
  800e95:	c3                   	ret    

00800e96 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e96:	55                   	push   %ebp
  800e97:	89 e5                	mov    %esp,%ebp
  800e99:	57                   	push   %edi
  800e9a:	56                   	push   %esi
  800e9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ea1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ea4:	39 c6                	cmp    %eax,%esi
  800ea6:	73 35                	jae    800edd <memmove+0x47>
  800ea8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800eab:	39 d0                	cmp    %edx,%eax
  800ead:	73 2e                	jae    800edd <memmove+0x47>
		s += n;
		d += n;
  800eaf:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800eb2:	89 d6                	mov    %edx,%esi
  800eb4:	09 fe                	or     %edi,%esi
  800eb6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ebc:	75 13                	jne    800ed1 <memmove+0x3b>
  800ebe:	f6 c1 03             	test   $0x3,%cl
  800ec1:	75 0e                	jne    800ed1 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800ec3:	83 ef 04             	sub    $0x4,%edi
  800ec6:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ec9:	c1 e9 02             	shr    $0x2,%ecx
  800ecc:	fd                   	std    
  800ecd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ecf:	eb 09                	jmp    800eda <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ed1:	83 ef 01             	sub    $0x1,%edi
  800ed4:	8d 72 ff             	lea    -0x1(%edx),%esi
  800ed7:	fd                   	std    
  800ed8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800eda:	fc                   	cld    
  800edb:	eb 1d                	jmp    800efa <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800edd:	89 f2                	mov    %esi,%edx
  800edf:	09 c2                	or     %eax,%edx
  800ee1:	f6 c2 03             	test   $0x3,%dl
  800ee4:	75 0f                	jne    800ef5 <memmove+0x5f>
  800ee6:	f6 c1 03             	test   $0x3,%cl
  800ee9:	75 0a                	jne    800ef5 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800eeb:	c1 e9 02             	shr    $0x2,%ecx
  800eee:	89 c7                	mov    %eax,%edi
  800ef0:	fc                   	cld    
  800ef1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ef3:	eb 05                	jmp    800efa <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ef5:	89 c7                	mov    %eax,%edi
  800ef7:	fc                   	cld    
  800ef8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800efa:	5e                   	pop    %esi
  800efb:	5f                   	pop    %edi
  800efc:	5d                   	pop    %ebp
  800efd:	c3                   	ret    

00800efe <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800efe:	55                   	push   %ebp
  800eff:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800f01:	ff 75 10             	pushl  0x10(%ebp)
  800f04:	ff 75 0c             	pushl  0xc(%ebp)
  800f07:	ff 75 08             	pushl  0x8(%ebp)
  800f0a:	e8 87 ff ff ff       	call   800e96 <memmove>
}
  800f0f:	c9                   	leave  
  800f10:	c3                   	ret    

00800f11 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f11:	55                   	push   %ebp
  800f12:	89 e5                	mov    %esp,%ebp
  800f14:	56                   	push   %esi
  800f15:	53                   	push   %ebx
  800f16:	8b 45 08             	mov    0x8(%ebp),%eax
  800f19:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f1c:	89 c6                	mov    %eax,%esi
  800f1e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f21:	eb 1a                	jmp    800f3d <memcmp+0x2c>
		if (*s1 != *s2)
  800f23:	0f b6 08             	movzbl (%eax),%ecx
  800f26:	0f b6 1a             	movzbl (%edx),%ebx
  800f29:	38 d9                	cmp    %bl,%cl
  800f2b:	74 0a                	je     800f37 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800f2d:	0f b6 c1             	movzbl %cl,%eax
  800f30:	0f b6 db             	movzbl %bl,%ebx
  800f33:	29 d8                	sub    %ebx,%eax
  800f35:	eb 0f                	jmp    800f46 <memcmp+0x35>
		s1++, s2++;
  800f37:	83 c0 01             	add    $0x1,%eax
  800f3a:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f3d:	39 f0                	cmp    %esi,%eax
  800f3f:	75 e2                	jne    800f23 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800f41:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f46:	5b                   	pop    %ebx
  800f47:	5e                   	pop    %esi
  800f48:	5d                   	pop    %ebp
  800f49:	c3                   	ret    

00800f4a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800f4a:	55                   	push   %ebp
  800f4b:	89 e5                	mov    %esp,%ebp
  800f4d:	53                   	push   %ebx
  800f4e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800f51:	89 c1                	mov    %eax,%ecx
  800f53:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800f56:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f5a:	eb 0a                	jmp    800f66 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800f5c:	0f b6 10             	movzbl (%eax),%edx
  800f5f:	39 da                	cmp    %ebx,%edx
  800f61:	74 07                	je     800f6a <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f63:	83 c0 01             	add    $0x1,%eax
  800f66:	39 c8                	cmp    %ecx,%eax
  800f68:	72 f2                	jb     800f5c <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800f6a:	5b                   	pop    %ebx
  800f6b:	5d                   	pop    %ebp
  800f6c:	c3                   	ret    

00800f6d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800f6d:	55                   	push   %ebp
  800f6e:	89 e5                	mov    %esp,%ebp
  800f70:	57                   	push   %edi
  800f71:	56                   	push   %esi
  800f72:	53                   	push   %ebx
  800f73:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f76:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f79:	eb 03                	jmp    800f7e <strtol+0x11>
		s++;
  800f7b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f7e:	0f b6 01             	movzbl (%ecx),%eax
  800f81:	3c 20                	cmp    $0x20,%al
  800f83:	74 f6                	je     800f7b <strtol+0xe>
  800f85:	3c 09                	cmp    $0x9,%al
  800f87:	74 f2                	je     800f7b <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800f89:	3c 2b                	cmp    $0x2b,%al
  800f8b:	75 0a                	jne    800f97 <strtol+0x2a>
		s++;
  800f8d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800f90:	bf 00 00 00 00       	mov    $0x0,%edi
  800f95:	eb 11                	jmp    800fa8 <strtol+0x3b>
  800f97:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800f9c:	3c 2d                	cmp    $0x2d,%al
  800f9e:	75 08                	jne    800fa8 <strtol+0x3b>
		s++, neg = 1;
  800fa0:	83 c1 01             	add    $0x1,%ecx
  800fa3:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800fa8:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800fae:	75 15                	jne    800fc5 <strtol+0x58>
  800fb0:	80 39 30             	cmpb   $0x30,(%ecx)
  800fb3:	75 10                	jne    800fc5 <strtol+0x58>
  800fb5:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800fb9:	75 7c                	jne    801037 <strtol+0xca>
		s += 2, base = 16;
  800fbb:	83 c1 02             	add    $0x2,%ecx
  800fbe:	bb 10 00 00 00       	mov    $0x10,%ebx
  800fc3:	eb 16                	jmp    800fdb <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800fc5:	85 db                	test   %ebx,%ebx
  800fc7:	75 12                	jne    800fdb <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800fc9:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800fce:	80 39 30             	cmpb   $0x30,(%ecx)
  800fd1:	75 08                	jne    800fdb <strtol+0x6e>
		s++, base = 8;
  800fd3:	83 c1 01             	add    $0x1,%ecx
  800fd6:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800fdb:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe0:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800fe3:	0f b6 11             	movzbl (%ecx),%edx
  800fe6:	8d 72 d0             	lea    -0x30(%edx),%esi
  800fe9:	89 f3                	mov    %esi,%ebx
  800feb:	80 fb 09             	cmp    $0x9,%bl
  800fee:	77 08                	ja     800ff8 <strtol+0x8b>
			dig = *s - '0';
  800ff0:	0f be d2             	movsbl %dl,%edx
  800ff3:	83 ea 30             	sub    $0x30,%edx
  800ff6:	eb 22                	jmp    80101a <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ff8:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ffb:	89 f3                	mov    %esi,%ebx
  800ffd:	80 fb 19             	cmp    $0x19,%bl
  801000:	77 08                	ja     80100a <strtol+0x9d>
			dig = *s - 'a' + 10;
  801002:	0f be d2             	movsbl %dl,%edx
  801005:	83 ea 57             	sub    $0x57,%edx
  801008:	eb 10                	jmp    80101a <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  80100a:	8d 72 bf             	lea    -0x41(%edx),%esi
  80100d:	89 f3                	mov    %esi,%ebx
  80100f:	80 fb 19             	cmp    $0x19,%bl
  801012:	77 16                	ja     80102a <strtol+0xbd>
			dig = *s - 'A' + 10;
  801014:	0f be d2             	movsbl %dl,%edx
  801017:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  80101a:	3b 55 10             	cmp    0x10(%ebp),%edx
  80101d:	7d 0b                	jge    80102a <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  80101f:	83 c1 01             	add    $0x1,%ecx
  801022:	0f af 45 10          	imul   0x10(%ebp),%eax
  801026:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801028:	eb b9                	jmp    800fe3 <strtol+0x76>

	if (endptr)
  80102a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80102e:	74 0d                	je     80103d <strtol+0xd0>
		*endptr = (char *) s;
  801030:	8b 75 0c             	mov    0xc(%ebp),%esi
  801033:	89 0e                	mov    %ecx,(%esi)
  801035:	eb 06                	jmp    80103d <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801037:	85 db                	test   %ebx,%ebx
  801039:	74 98                	je     800fd3 <strtol+0x66>
  80103b:	eb 9e                	jmp    800fdb <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  80103d:	89 c2                	mov    %eax,%edx
  80103f:	f7 da                	neg    %edx
  801041:	85 ff                	test   %edi,%edi
  801043:	0f 45 c2             	cmovne %edx,%eax
}
  801046:	5b                   	pop    %ebx
  801047:	5e                   	pop    %esi
  801048:	5f                   	pop    %edi
  801049:	5d                   	pop    %ebp
  80104a:	c3                   	ret    

0080104b <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80104b:	55                   	push   %ebp
  80104c:	89 e5                	mov    %esp,%ebp
  80104e:	57                   	push   %edi
  80104f:	56                   	push   %esi
  801050:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801051:	b8 00 00 00 00       	mov    $0x0,%eax
  801056:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801059:	8b 55 08             	mov    0x8(%ebp),%edx
  80105c:	89 c3                	mov    %eax,%ebx
  80105e:	89 c7                	mov    %eax,%edi
  801060:	89 c6                	mov    %eax,%esi
  801062:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801064:	5b                   	pop    %ebx
  801065:	5e                   	pop    %esi
  801066:	5f                   	pop    %edi
  801067:	5d                   	pop    %ebp
  801068:	c3                   	ret    

00801069 <sys_cgetc>:

int
sys_cgetc(void)
{
  801069:	55                   	push   %ebp
  80106a:	89 e5                	mov    %esp,%ebp
  80106c:	57                   	push   %edi
  80106d:	56                   	push   %esi
  80106e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80106f:	ba 00 00 00 00       	mov    $0x0,%edx
  801074:	b8 01 00 00 00       	mov    $0x1,%eax
  801079:	89 d1                	mov    %edx,%ecx
  80107b:	89 d3                	mov    %edx,%ebx
  80107d:	89 d7                	mov    %edx,%edi
  80107f:	89 d6                	mov    %edx,%esi
  801081:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801083:	5b                   	pop    %ebx
  801084:	5e                   	pop    %esi
  801085:	5f                   	pop    %edi
  801086:	5d                   	pop    %ebp
  801087:	c3                   	ret    

00801088 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801088:	55                   	push   %ebp
  801089:	89 e5                	mov    %esp,%ebp
  80108b:	57                   	push   %edi
  80108c:	56                   	push   %esi
  80108d:	53                   	push   %ebx
  80108e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801091:	b9 00 00 00 00       	mov    $0x0,%ecx
  801096:	b8 03 00 00 00       	mov    $0x3,%eax
  80109b:	8b 55 08             	mov    0x8(%ebp),%edx
  80109e:	89 cb                	mov    %ecx,%ebx
  8010a0:	89 cf                	mov    %ecx,%edi
  8010a2:	89 ce                	mov    %ecx,%esi
  8010a4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010a6:	85 c0                	test   %eax,%eax
  8010a8:	7e 17                	jle    8010c1 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010aa:	83 ec 0c             	sub    $0xc,%esp
  8010ad:	50                   	push   %eax
  8010ae:	6a 03                	push   $0x3
  8010b0:	68 9f 2a 80 00       	push   $0x802a9f
  8010b5:	6a 23                	push   $0x23
  8010b7:	68 bc 2a 80 00       	push   $0x802abc
  8010bc:	e8 c7 f5 ff ff       	call   800688 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8010c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010c4:	5b                   	pop    %ebx
  8010c5:	5e                   	pop    %esi
  8010c6:	5f                   	pop    %edi
  8010c7:	5d                   	pop    %ebp
  8010c8:	c3                   	ret    

008010c9 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8010c9:	55                   	push   %ebp
  8010ca:	89 e5                	mov    %esp,%ebp
  8010cc:	57                   	push   %edi
  8010cd:	56                   	push   %esi
  8010ce:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8010d4:	b8 02 00 00 00       	mov    $0x2,%eax
  8010d9:	89 d1                	mov    %edx,%ecx
  8010db:	89 d3                	mov    %edx,%ebx
  8010dd:	89 d7                	mov    %edx,%edi
  8010df:	89 d6                	mov    %edx,%esi
  8010e1:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8010e3:	5b                   	pop    %ebx
  8010e4:	5e                   	pop    %esi
  8010e5:	5f                   	pop    %edi
  8010e6:	5d                   	pop    %ebp
  8010e7:	c3                   	ret    

008010e8 <sys_yield>:

void
sys_yield(void)
{
  8010e8:	55                   	push   %ebp
  8010e9:	89 e5                	mov    %esp,%ebp
  8010eb:	57                   	push   %edi
  8010ec:	56                   	push   %esi
  8010ed:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8010f3:	b8 0b 00 00 00       	mov    $0xb,%eax
  8010f8:	89 d1                	mov    %edx,%ecx
  8010fa:	89 d3                	mov    %edx,%ebx
  8010fc:	89 d7                	mov    %edx,%edi
  8010fe:	89 d6                	mov    %edx,%esi
  801100:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801102:	5b                   	pop    %ebx
  801103:	5e                   	pop    %esi
  801104:	5f                   	pop    %edi
  801105:	5d                   	pop    %ebp
  801106:	c3                   	ret    

00801107 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801107:	55                   	push   %ebp
  801108:	89 e5                	mov    %esp,%ebp
  80110a:	57                   	push   %edi
  80110b:	56                   	push   %esi
  80110c:	53                   	push   %ebx
  80110d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801110:	be 00 00 00 00       	mov    $0x0,%esi
  801115:	b8 04 00 00 00       	mov    $0x4,%eax
  80111a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80111d:	8b 55 08             	mov    0x8(%ebp),%edx
  801120:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801123:	89 f7                	mov    %esi,%edi
  801125:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801127:	85 c0                	test   %eax,%eax
  801129:	7e 17                	jle    801142 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80112b:	83 ec 0c             	sub    $0xc,%esp
  80112e:	50                   	push   %eax
  80112f:	6a 04                	push   $0x4
  801131:	68 9f 2a 80 00       	push   $0x802a9f
  801136:	6a 23                	push   $0x23
  801138:	68 bc 2a 80 00       	push   $0x802abc
  80113d:	e8 46 f5 ff ff       	call   800688 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801142:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801145:	5b                   	pop    %ebx
  801146:	5e                   	pop    %esi
  801147:	5f                   	pop    %edi
  801148:	5d                   	pop    %ebp
  801149:	c3                   	ret    

0080114a <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80114a:	55                   	push   %ebp
  80114b:	89 e5                	mov    %esp,%ebp
  80114d:	57                   	push   %edi
  80114e:	56                   	push   %esi
  80114f:	53                   	push   %ebx
  801150:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801153:	b8 05 00 00 00       	mov    $0x5,%eax
  801158:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80115b:	8b 55 08             	mov    0x8(%ebp),%edx
  80115e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801161:	8b 7d 14             	mov    0x14(%ebp),%edi
  801164:	8b 75 18             	mov    0x18(%ebp),%esi
  801167:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801169:	85 c0                	test   %eax,%eax
  80116b:	7e 17                	jle    801184 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80116d:	83 ec 0c             	sub    $0xc,%esp
  801170:	50                   	push   %eax
  801171:	6a 05                	push   $0x5
  801173:	68 9f 2a 80 00       	push   $0x802a9f
  801178:	6a 23                	push   $0x23
  80117a:	68 bc 2a 80 00       	push   $0x802abc
  80117f:	e8 04 f5 ff ff       	call   800688 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801184:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801187:	5b                   	pop    %ebx
  801188:	5e                   	pop    %esi
  801189:	5f                   	pop    %edi
  80118a:	5d                   	pop    %ebp
  80118b:	c3                   	ret    

0080118c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80118c:	55                   	push   %ebp
  80118d:	89 e5                	mov    %esp,%ebp
  80118f:	57                   	push   %edi
  801190:	56                   	push   %esi
  801191:	53                   	push   %ebx
  801192:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801195:	bb 00 00 00 00       	mov    $0x0,%ebx
  80119a:	b8 06 00 00 00       	mov    $0x6,%eax
  80119f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8011a5:	89 df                	mov    %ebx,%edi
  8011a7:	89 de                	mov    %ebx,%esi
  8011a9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011ab:	85 c0                	test   %eax,%eax
  8011ad:	7e 17                	jle    8011c6 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011af:	83 ec 0c             	sub    $0xc,%esp
  8011b2:	50                   	push   %eax
  8011b3:	6a 06                	push   $0x6
  8011b5:	68 9f 2a 80 00       	push   $0x802a9f
  8011ba:	6a 23                	push   $0x23
  8011bc:	68 bc 2a 80 00       	push   $0x802abc
  8011c1:	e8 c2 f4 ff ff       	call   800688 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8011c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011c9:	5b                   	pop    %ebx
  8011ca:	5e                   	pop    %esi
  8011cb:	5f                   	pop    %edi
  8011cc:	5d                   	pop    %ebp
  8011cd:	c3                   	ret    

008011ce <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8011ce:	55                   	push   %ebp
  8011cf:	89 e5                	mov    %esp,%ebp
  8011d1:	57                   	push   %edi
  8011d2:	56                   	push   %esi
  8011d3:	53                   	push   %ebx
  8011d4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011d7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011dc:	b8 08 00 00 00       	mov    $0x8,%eax
  8011e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8011e7:	89 df                	mov    %ebx,%edi
  8011e9:	89 de                	mov    %ebx,%esi
  8011eb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011ed:	85 c0                	test   %eax,%eax
  8011ef:	7e 17                	jle    801208 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011f1:	83 ec 0c             	sub    $0xc,%esp
  8011f4:	50                   	push   %eax
  8011f5:	6a 08                	push   $0x8
  8011f7:	68 9f 2a 80 00       	push   $0x802a9f
  8011fc:	6a 23                	push   $0x23
  8011fe:	68 bc 2a 80 00       	push   $0x802abc
  801203:	e8 80 f4 ff ff       	call   800688 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801208:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80120b:	5b                   	pop    %ebx
  80120c:	5e                   	pop    %esi
  80120d:	5f                   	pop    %edi
  80120e:	5d                   	pop    %ebp
  80120f:	c3                   	ret    

00801210 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801210:	55                   	push   %ebp
  801211:	89 e5                	mov    %esp,%ebp
  801213:	57                   	push   %edi
  801214:	56                   	push   %esi
  801215:	53                   	push   %ebx
  801216:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801219:	bb 00 00 00 00       	mov    $0x0,%ebx
  80121e:	b8 09 00 00 00       	mov    $0x9,%eax
  801223:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801226:	8b 55 08             	mov    0x8(%ebp),%edx
  801229:	89 df                	mov    %ebx,%edi
  80122b:	89 de                	mov    %ebx,%esi
  80122d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80122f:	85 c0                	test   %eax,%eax
  801231:	7e 17                	jle    80124a <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801233:	83 ec 0c             	sub    $0xc,%esp
  801236:	50                   	push   %eax
  801237:	6a 09                	push   $0x9
  801239:	68 9f 2a 80 00       	push   $0x802a9f
  80123e:	6a 23                	push   $0x23
  801240:	68 bc 2a 80 00       	push   $0x802abc
  801245:	e8 3e f4 ff ff       	call   800688 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80124a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80124d:	5b                   	pop    %ebx
  80124e:	5e                   	pop    %esi
  80124f:	5f                   	pop    %edi
  801250:	5d                   	pop    %ebp
  801251:	c3                   	ret    

00801252 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801252:	55                   	push   %ebp
  801253:	89 e5                	mov    %esp,%ebp
  801255:	57                   	push   %edi
  801256:	56                   	push   %esi
  801257:	53                   	push   %ebx
  801258:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80125b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801260:	b8 0a 00 00 00       	mov    $0xa,%eax
  801265:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801268:	8b 55 08             	mov    0x8(%ebp),%edx
  80126b:	89 df                	mov    %ebx,%edi
  80126d:	89 de                	mov    %ebx,%esi
  80126f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801271:	85 c0                	test   %eax,%eax
  801273:	7e 17                	jle    80128c <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801275:	83 ec 0c             	sub    $0xc,%esp
  801278:	50                   	push   %eax
  801279:	6a 0a                	push   $0xa
  80127b:	68 9f 2a 80 00       	push   $0x802a9f
  801280:	6a 23                	push   $0x23
  801282:	68 bc 2a 80 00       	push   $0x802abc
  801287:	e8 fc f3 ff ff       	call   800688 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80128c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80128f:	5b                   	pop    %ebx
  801290:	5e                   	pop    %esi
  801291:	5f                   	pop    %edi
  801292:	5d                   	pop    %ebp
  801293:	c3                   	ret    

00801294 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801294:	55                   	push   %ebp
  801295:	89 e5                	mov    %esp,%ebp
  801297:	57                   	push   %edi
  801298:	56                   	push   %esi
  801299:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80129a:	be 00 00 00 00       	mov    $0x0,%esi
  80129f:	b8 0c 00 00 00       	mov    $0xc,%eax
  8012a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8012aa:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012ad:	8b 7d 14             	mov    0x14(%ebp),%edi
  8012b0:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8012b2:	5b                   	pop    %ebx
  8012b3:	5e                   	pop    %esi
  8012b4:	5f                   	pop    %edi
  8012b5:	5d                   	pop    %ebp
  8012b6:	c3                   	ret    

008012b7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8012b7:	55                   	push   %ebp
  8012b8:	89 e5                	mov    %esp,%ebp
  8012ba:	57                   	push   %edi
  8012bb:	56                   	push   %esi
  8012bc:	53                   	push   %ebx
  8012bd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012c0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012c5:	b8 0d 00 00 00       	mov    $0xd,%eax
  8012ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8012cd:	89 cb                	mov    %ecx,%ebx
  8012cf:	89 cf                	mov    %ecx,%edi
  8012d1:	89 ce                	mov    %ecx,%esi
  8012d3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8012d5:	85 c0                	test   %eax,%eax
  8012d7:	7e 17                	jle    8012f0 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012d9:	83 ec 0c             	sub    $0xc,%esp
  8012dc:	50                   	push   %eax
  8012dd:	6a 0d                	push   $0xd
  8012df:	68 9f 2a 80 00       	push   $0x802a9f
  8012e4:	6a 23                	push   $0x23
  8012e6:	68 bc 2a 80 00       	push   $0x802abc
  8012eb:	e8 98 f3 ff ff       	call   800688 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8012f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012f3:	5b                   	pop    %ebx
  8012f4:	5e                   	pop    %esi
  8012f5:	5f                   	pop    %edi
  8012f6:	5d                   	pop    %ebp
  8012f7:	c3                   	ret    

008012f8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8012f8:	55                   	push   %ebp
  8012f9:	89 e5                	mov    %esp,%ebp
  8012fb:	56                   	push   %esi
  8012fc:	53                   	push   %ebx
  8012fd:	8b 75 08             	mov    0x8(%ebp),%esi
  801300:	8b 45 0c             	mov    0xc(%ebp),%eax
  801303:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_recv not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  801306:	85 c0                	test   %eax,%eax
  801308:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80130d:	0f 44 c2             	cmove  %edx,%eax

    int r = sys_ipc_recv(pg);
  801310:	83 ec 0c             	sub    $0xc,%esp
  801313:	50                   	push   %eax
  801314:	e8 9e ff ff ff       	call   8012b7 <sys_ipc_recv>
    int from_env = 0, perm = 0;
    if (r == 0) {
  801319:	83 c4 10             	add    $0x10,%esp
  80131c:	85 c0                	test   %eax,%eax
  80131e:	75 10                	jne    801330 <ipc_recv+0x38>
        from_env = thisenv->env_ipc_from;
  801320:	a1 04 40 80 00       	mov    0x804004,%eax
  801325:	8b 48 74             	mov    0x74(%eax),%ecx
        perm = thisenv->env_ipc_perm;
  801328:	8b 50 78             	mov    0x78(%eax),%edx
        r = thisenv->env_ipc_value;
  80132b:	8b 40 70             	mov    0x70(%eax),%eax
  80132e:	eb 0a                	jmp    80133a <ipc_recv+0x42>
    } else {
        from_env = 0;
        perm = 0;
  801330:	ba 00 00 00 00       	mov    $0x0,%edx
    if (r == 0) {
        from_env = thisenv->env_ipc_from;
        perm = thisenv->env_ipc_perm;
        r = thisenv->env_ipc_value;
    } else {
        from_env = 0;
  801335:	b9 00 00 00 00       	mov    $0x0,%ecx
        perm = 0;
    }

    if (from_env_store) *from_env_store = from_env;
  80133a:	85 f6                	test   %esi,%esi
  80133c:	74 02                	je     801340 <ipc_recv+0x48>
  80133e:	89 0e                	mov    %ecx,(%esi)
    if (perm_store) *perm_store = perm;
  801340:	85 db                	test   %ebx,%ebx
  801342:	74 02                	je     801346 <ipc_recv+0x4e>
  801344:	89 13                	mov    %edx,(%ebx)

    return r;
}
  801346:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801349:	5b                   	pop    %ebx
  80134a:	5e                   	pop    %esi
  80134b:	5d                   	pop    %ebp
  80134c:	c3                   	ret    

0080134d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80134d:	55                   	push   %ebp
  80134e:	89 e5                	mov    %esp,%ebp
  801350:	57                   	push   %edi
  801351:	56                   	push   %esi
  801352:	53                   	push   %ebx
  801353:	83 ec 0c             	sub    $0xc,%esp
  801356:	8b 7d 08             	mov    0x8(%ebp),%edi
  801359:	8b 75 0c             	mov    0xc(%ebp),%esi
  80135c:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  80135f:	85 db                	test   %ebx,%ebx
  801361:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801366:	0f 44 d8             	cmove  %eax,%ebx
  801369:	eb 1c                	jmp    801387 <ipc_send+0x3a>

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        if (ret != -E_IPC_NOT_RECV)
  80136b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80136e:	74 12                	je     801382 <ipc_send+0x35>
            panic("ipc_send error %e", ret);
  801370:	50                   	push   %eax
  801371:	68 ca 2a 80 00       	push   $0x802aca
  801376:	6a 40                	push   $0x40
  801378:	68 dc 2a 80 00       	push   $0x802adc
  80137d:	e8 06 f3 ff ff       	call   800688 <_panic>
        sys_yield();
  801382:	e8 61 fd ff ff       	call   8010e8 <sys_yield>
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801387:	ff 75 14             	pushl  0x14(%ebp)
  80138a:	53                   	push   %ebx
  80138b:	56                   	push   %esi
  80138c:	57                   	push   %edi
  80138d:	e8 02 ff ff ff       	call   801294 <sys_ipc_try_send>
  801392:	83 c4 10             	add    $0x10,%esp
  801395:	85 c0                	test   %eax,%eax
  801397:	75 d2                	jne    80136b <ipc_send+0x1e>
        if (ret != -E_IPC_NOT_RECV)
            panic("ipc_send error %e", ret);
        sys_yield();
    }
}
  801399:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80139c:	5b                   	pop    %ebx
  80139d:	5e                   	pop    %esi
  80139e:	5f                   	pop    %edi
  80139f:	5d                   	pop    %ebp
  8013a0:	c3                   	ret    

008013a1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8013a1:	55                   	push   %ebp
  8013a2:	89 e5                	mov    %esp,%ebp
  8013a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8013a7:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8013ac:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8013af:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8013b5:	8b 52 50             	mov    0x50(%edx),%edx
  8013b8:	39 ca                	cmp    %ecx,%edx
  8013ba:	75 0d                	jne    8013c9 <ipc_find_env+0x28>
			return envs[i].env_id;
  8013bc:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8013bf:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8013c4:	8b 40 48             	mov    0x48(%eax),%eax
  8013c7:	eb 0f                	jmp    8013d8 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8013c9:	83 c0 01             	add    $0x1,%eax
  8013cc:	3d 00 04 00 00       	cmp    $0x400,%eax
  8013d1:	75 d9                	jne    8013ac <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8013d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013d8:	5d                   	pop    %ebp
  8013d9:	c3                   	ret    

008013da <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8013da:	55                   	push   %ebp
  8013db:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e0:	05 00 00 00 30       	add    $0x30000000,%eax
  8013e5:	c1 e8 0c             	shr    $0xc,%eax
}
  8013e8:	5d                   	pop    %ebp
  8013e9:	c3                   	ret    

008013ea <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8013ea:	55                   	push   %ebp
  8013eb:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8013ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f0:	05 00 00 00 30       	add    $0x30000000,%eax
  8013f5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8013fa:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8013ff:	5d                   	pop    %ebp
  801400:	c3                   	ret    

00801401 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801401:	55                   	push   %ebp
  801402:	89 e5                	mov    %esp,%ebp
  801404:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801407:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80140c:	89 c2                	mov    %eax,%edx
  80140e:	c1 ea 16             	shr    $0x16,%edx
  801411:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801418:	f6 c2 01             	test   $0x1,%dl
  80141b:	74 11                	je     80142e <fd_alloc+0x2d>
  80141d:	89 c2                	mov    %eax,%edx
  80141f:	c1 ea 0c             	shr    $0xc,%edx
  801422:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801429:	f6 c2 01             	test   $0x1,%dl
  80142c:	75 09                	jne    801437 <fd_alloc+0x36>
			*fd_store = fd;
  80142e:	89 01                	mov    %eax,(%ecx)
			return 0;
  801430:	b8 00 00 00 00       	mov    $0x0,%eax
  801435:	eb 17                	jmp    80144e <fd_alloc+0x4d>
  801437:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80143c:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801441:	75 c9                	jne    80140c <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801443:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801449:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80144e:	5d                   	pop    %ebp
  80144f:	c3                   	ret    

00801450 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801450:	55                   	push   %ebp
  801451:	89 e5                	mov    %esp,%ebp
  801453:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801456:	83 f8 1f             	cmp    $0x1f,%eax
  801459:	77 36                	ja     801491 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80145b:	c1 e0 0c             	shl    $0xc,%eax
  80145e:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801463:	89 c2                	mov    %eax,%edx
  801465:	c1 ea 16             	shr    $0x16,%edx
  801468:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80146f:	f6 c2 01             	test   $0x1,%dl
  801472:	74 24                	je     801498 <fd_lookup+0x48>
  801474:	89 c2                	mov    %eax,%edx
  801476:	c1 ea 0c             	shr    $0xc,%edx
  801479:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801480:	f6 c2 01             	test   $0x1,%dl
  801483:	74 1a                	je     80149f <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801485:	8b 55 0c             	mov    0xc(%ebp),%edx
  801488:	89 02                	mov    %eax,(%edx)
	return 0;
  80148a:	b8 00 00 00 00       	mov    $0x0,%eax
  80148f:	eb 13                	jmp    8014a4 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801491:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801496:	eb 0c                	jmp    8014a4 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801498:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80149d:	eb 05                	jmp    8014a4 <fd_lookup+0x54>
  80149f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8014a4:	5d                   	pop    %ebp
  8014a5:	c3                   	ret    

008014a6 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8014a6:	55                   	push   %ebp
  8014a7:	89 e5                	mov    %esp,%ebp
  8014a9:	83 ec 08             	sub    $0x8,%esp
  8014ac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014af:	ba 68 2b 80 00       	mov    $0x802b68,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8014b4:	eb 13                	jmp    8014c9 <dev_lookup+0x23>
  8014b6:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8014b9:	39 08                	cmp    %ecx,(%eax)
  8014bb:	75 0c                	jne    8014c9 <dev_lookup+0x23>
			*dev = devtab[i];
  8014bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014c0:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8014c7:	eb 2e                	jmp    8014f7 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8014c9:	8b 02                	mov    (%edx),%eax
  8014cb:	85 c0                	test   %eax,%eax
  8014cd:	75 e7                	jne    8014b6 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8014cf:	a1 04 40 80 00       	mov    0x804004,%eax
  8014d4:	8b 40 48             	mov    0x48(%eax),%eax
  8014d7:	83 ec 04             	sub    $0x4,%esp
  8014da:	51                   	push   %ecx
  8014db:	50                   	push   %eax
  8014dc:	68 e8 2a 80 00       	push   $0x802ae8
  8014e1:	e8 7b f2 ff ff       	call   800761 <cprintf>
	*dev = 0;
  8014e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014e9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8014ef:	83 c4 10             	add    $0x10,%esp
  8014f2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8014f7:	c9                   	leave  
  8014f8:	c3                   	ret    

008014f9 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8014f9:	55                   	push   %ebp
  8014fa:	89 e5                	mov    %esp,%ebp
  8014fc:	56                   	push   %esi
  8014fd:	53                   	push   %ebx
  8014fe:	83 ec 10             	sub    $0x10,%esp
  801501:	8b 75 08             	mov    0x8(%ebp),%esi
  801504:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801507:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80150a:	50                   	push   %eax
  80150b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801511:	c1 e8 0c             	shr    $0xc,%eax
  801514:	50                   	push   %eax
  801515:	e8 36 ff ff ff       	call   801450 <fd_lookup>
  80151a:	83 c4 08             	add    $0x8,%esp
  80151d:	85 c0                	test   %eax,%eax
  80151f:	78 05                	js     801526 <fd_close+0x2d>
	    || fd != fd2)
  801521:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801524:	74 0c                	je     801532 <fd_close+0x39>
		return (must_exist ? r : 0);
  801526:	84 db                	test   %bl,%bl
  801528:	ba 00 00 00 00       	mov    $0x0,%edx
  80152d:	0f 44 c2             	cmove  %edx,%eax
  801530:	eb 41                	jmp    801573 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801532:	83 ec 08             	sub    $0x8,%esp
  801535:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801538:	50                   	push   %eax
  801539:	ff 36                	pushl  (%esi)
  80153b:	e8 66 ff ff ff       	call   8014a6 <dev_lookup>
  801540:	89 c3                	mov    %eax,%ebx
  801542:	83 c4 10             	add    $0x10,%esp
  801545:	85 c0                	test   %eax,%eax
  801547:	78 1a                	js     801563 <fd_close+0x6a>
		if (dev->dev_close)
  801549:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80154c:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80154f:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801554:	85 c0                	test   %eax,%eax
  801556:	74 0b                	je     801563 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801558:	83 ec 0c             	sub    $0xc,%esp
  80155b:	56                   	push   %esi
  80155c:	ff d0                	call   *%eax
  80155e:	89 c3                	mov    %eax,%ebx
  801560:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801563:	83 ec 08             	sub    $0x8,%esp
  801566:	56                   	push   %esi
  801567:	6a 00                	push   $0x0
  801569:	e8 1e fc ff ff       	call   80118c <sys_page_unmap>
	return r;
  80156e:	83 c4 10             	add    $0x10,%esp
  801571:	89 d8                	mov    %ebx,%eax
}
  801573:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801576:	5b                   	pop    %ebx
  801577:	5e                   	pop    %esi
  801578:	5d                   	pop    %ebp
  801579:	c3                   	ret    

0080157a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80157a:	55                   	push   %ebp
  80157b:	89 e5                	mov    %esp,%ebp
  80157d:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801580:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801583:	50                   	push   %eax
  801584:	ff 75 08             	pushl  0x8(%ebp)
  801587:	e8 c4 fe ff ff       	call   801450 <fd_lookup>
  80158c:	83 c4 08             	add    $0x8,%esp
  80158f:	85 c0                	test   %eax,%eax
  801591:	78 10                	js     8015a3 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801593:	83 ec 08             	sub    $0x8,%esp
  801596:	6a 01                	push   $0x1
  801598:	ff 75 f4             	pushl  -0xc(%ebp)
  80159b:	e8 59 ff ff ff       	call   8014f9 <fd_close>
  8015a0:	83 c4 10             	add    $0x10,%esp
}
  8015a3:	c9                   	leave  
  8015a4:	c3                   	ret    

008015a5 <close_all>:

void
close_all(void)
{
  8015a5:	55                   	push   %ebp
  8015a6:	89 e5                	mov    %esp,%ebp
  8015a8:	53                   	push   %ebx
  8015a9:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8015ac:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8015b1:	83 ec 0c             	sub    $0xc,%esp
  8015b4:	53                   	push   %ebx
  8015b5:	e8 c0 ff ff ff       	call   80157a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8015ba:	83 c3 01             	add    $0x1,%ebx
  8015bd:	83 c4 10             	add    $0x10,%esp
  8015c0:	83 fb 20             	cmp    $0x20,%ebx
  8015c3:	75 ec                	jne    8015b1 <close_all+0xc>
		close(i);
}
  8015c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015c8:	c9                   	leave  
  8015c9:	c3                   	ret    

008015ca <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8015ca:	55                   	push   %ebp
  8015cb:	89 e5                	mov    %esp,%ebp
  8015cd:	57                   	push   %edi
  8015ce:	56                   	push   %esi
  8015cf:	53                   	push   %ebx
  8015d0:	83 ec 2c             	sub    $0x2c,%esp
  8015d3:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8015d6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015d9:	50                   	push   %eax
  8015da:	ff 75 08             	pushl  0x8(%ebp)
  8015dd:	e8 6e fe ff ff       	call   801450 <fd_lookup>
  8015e2:	83 c4 08             	add    $0x8,%esp
  8015e5:	85 c0                	test   %eax,%eax
  8015e7:	0f 88 c1 00 00 00    	js     8016ae <dup+0xe4>
		return r;
	close(newfdnum);
  8015ed:	83 ec 0c             	sub    $0xc,%esp
  8015f0:	56                   	push   %esi
  8015f1:	e8 84 ff ff ff       	call   80157a <close>

	newfd = INDEX2FD(newfdnum);
  8015f6:	89 f3                	mov    %esi,%ebx
  8015f8:	c1 e3 0c             	shl    $0xc,%ebx
  8015fb:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801601:	83 c4 04             	add    $0x4,%esp
  801604:	ff 75 e4             	pushl  -0x1c(%ebp)
  801607:	e8 de fd ff ff       	call   8013ea <fd2data>
  80160c:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80160e:	89 1c 24             	mov    %ebx,(%esp)
  801611:	e8 d4 fd ff ff       	call   8013ea <fd2data>
  801616:	83 c4 10             	add    $0x10,%esp
  801619:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80161c:	89 f8                	mov    %edi,%eax
  80161e:	c1 e8 16             	shr    $0x16,%eax
  801621:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801628:	a8 01                	test   $0x1,%al
  80162a:	74 37                	je     801663 <dup+0x99>
  80162c:	89 f8                	mov    %edi,%eax
  80162e:	c1 e8 0c             	shr    $0xc,%eax
  801631:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801638:	f6 c2 01             	test   $0x1,%dl
  80163b:	74 26                	je     801663 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80163d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801644:	83 ec 0c             	sub    $0xc,%esp
  801647:	25 07 0e 00 00       	and    $0xe07,%eax
  80164c:	50                   	push   %eax
  80164d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801650:	6a 00                	push   $0x0
  801652:	57                   	push   %edi
  801653:	6a 00                	push   $0x0
  801655:	e8 f0 fa ff ff       	call   80114a <sys_page_map>
  80165a:	89 c7                	mov    %eax,%edi
  80165c:	83 c4 20             	add    $0x20,%esp
  80165f:	85 c0                	test   %eax,%eax
  801661:	78 2e                	js     801691 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801663:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801666:	89 d0                	mov    %edx,%eax
  801668:	c1 e8 0c             	shr    $0xc,%eax
  80166b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801672:	83 ec 0c             	sub    $0xc,%esp
  801675:	25 07 0e 00 00       	and    $0xe07,%eax
  80167a:	50                   	push   %eax
  80167b:	53                   	push   %ebx
  80167c:	6a 00                	push   $0x0
  80167e:	52                   	push   %edx
  80167f:	6a 00                	push   $0x0
  801681:	e8 c4 fa ff ff       	call   80114a <sys_page_map>
  801686:	89 c7                	mov    %eax,%edi
  801688:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80168b:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80168d:	85 ff                	test   %edi,%edi
  80168f:	79 1d                	jns    8016ae <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801691:	83 ec 08             	sub    $0x8,%esp
  801694:	53                   	push   %ebx
  801695:	6a 00                	push   $0x0
  801697:	e8 f0 fa ff ff       	call   80118c <sys_page_unmap>
	sys_page_unmap(0, nva);
  80169c:	83 c4 08             	add    $0x8,%esp
  80169f:	ff 75 d4             	pushl  -0x2c(%ebp)
  8016a2:	6a 00                	push   $0x0
  8016a4:	e8 e3 fa ff ff       	call   80118c <sys_page_unmap>
	return r;
  8016a9:	83 c4 10             	add    $0x10,%esp
  8016ac:	89 f8                	mov    %edi,%eax
}
  8016ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016b1:	5b                   	pop    %ebx
  8016b2:	5e                   	pop    %esi
  8016b3:	5f                   	pop    %edi
  8016b4:	5d                   	pop    %ebp
  8016b5:	c3                   	ret    

008016b6 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8016b6:	55                   	push   %ebp
  8016b7:	89 e5                	mov    %esp,%ebp
  8016b9:	53                   	push   %ebx
  8016ba:	83 ec 14             	sub    $0x14,%esp
  8016bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016c0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016c3:	50                   	push   %eax
  8016c4:	53                   	push   %ebx
  8016c5:	e8 86 fd ff ff       	call   801450 <fd_lookup>
  8016ca:	83 c4 08             	add    $0x8,%esp
  8016cd:	89 c2                	mov    %eax,%edx
  8016cf:	85 c0                	test   %eax,%eax
  8016d1:	78 6d                	js     801740 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016d3:	83 ec 08             	sub    $0x8,%esp
  8016d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016d9:	50                   	push   %eax
  8016da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016dd:	ff 30                	pushl  (%eax)
  8016df:	e8 c2 fd ff ff       	call   8014a6 <dev_lookup>
  8016e4:	83 c4 10             	add    $0x10,%esp
  8016e7:	85 c0                	test   %eax,%eax
  8016e9:	78 4c                	js     801737 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8016eb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016ee:	8b 42 08             	mov    0x8(%edx),%eax
  8016f1:	83 e0 03             	and    $0x3,%eax
  8016f4:	83 f8 01             	cmp    $0x1,%eax
  8016f7:	75 21                	jne    80171a <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8016f9:	a1 04 40 80 00       	mov    0x804004,%eax
  8016fe:	8b 40 48             	mov    0x48(%eax),%eax
  801701:	83 ec 04             	sub    $0x4,%esp
  801704:	53                   	push   %ebx
  801705:	50                   	push   %eax
  801706:	68 2c 2b 80 00       	push   $0x802b2c
  80170b:	e8 51 f0 ff ff       	call   800761 <cprintf>
		return -E_INVAL;
  801710:	83 c4 10             	add    $0x10,%esp
  801713:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801718:	eb 26                	jmp    801740 <read+0x8a>
	}
	if (!dev->dev_read)
  80171a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80171d:	8b 40 08             	mov    0x8(%eax),%eax
  801720:	85 c0                	test   %eax,%eax
  801722:	74 17                	je     80173b <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801724:	83 ec 04             	sub    $0x4,%esp
  801727:	ff 75 10             	pushl  0x10(%ebp)
  80172a:	ff 75 0c             	pushl  0xc(%ebp)
  80172d:	52                   	push   %edx
  80172e:	ff d0                	call   *%eax
  801730:	89 c2                	mov    %eax,%edx
  801732:	83 c4 10             	add    $0x10,%esp
  801735:	eb 09                	jmp    801740 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801737:	89 c2                	mov    %eax,%edx
  801739:	eb 05                	jmp    801740 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80173b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801740:	89 d0                	mov    %edx,%eax
  801742:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801745:	c9                   	leave  
  801746:	c3                   	ret    

00801747 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801747:	55                   	push   %ebp
  801748:	89 e5                	mov    %esp,%ebp
  80174a:	57                   	push   %edi
  80174b:	56                   	push   %esi
  80174c:	53                   	push   %ebx
  80174d:	83 ec 0c             	sub    $0xc,%esp
  801750:	8b 7d 08             	mov    0x8(%ebp),%edi
  801753:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801756:	bb 00 00 00 00       	mov    $0x0,%ebx
  80175b:	eb 21                	jmp    80177e <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80175d:	83 ec 04             	sub    $0x4,%esp
  801760:	89 f0                	mov    %esi,%eax
  801762:	29 d8                	sub    %ebx,%eax
  801764:	50                   	push   %eax
  801765:	89 d8                	mov    %ebx,%eax
  801767:	03 45 0c             	add    0xc(%ebp),%eax
  80176a:	50                   	push   %eax
  80176b:	57                   	push   %edi
  80176c:	e8 45 ff ff ff       	call   8016b6 <read>
		if (m < 0)
  801771:	83 c4 10             	add    $0x10,%esp
  801774:	85 c0                	test   %eax,%eax
  801776:	78 10                	js     801788 <readn+0x41>
			return m;
		if (m == 0)
  801778:	85 c0                	test   %eax,%eax
  80177a:	74 0a                	je     801786 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80177c:	01 c3                	add    %eax,%ebx
  80177e:	39 f3                	cmp    %esi,%ebx
  801780:	72 db                	jb     80175d <readn+0x16>
  801782:	89 d8                	mov    %ebx,%eax
  801784:	eb 02                	jmp    801788 <readn+0x41>
  801786:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801788:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80178b:	5b                   	pop    %ebx
  80178c:	5e                   	pop    %esi
  80178d:	5f                   	pop    %edi
  80178e:	5d                   	pop    %ebp
  80178f:	c3                   	ret    

00801790 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801790:	55                   	push   %ebp
  801791:	89 e5                	mov    %esp,%ebp
  801793:	53                   	push   %ebx
  801794:	83 ec 14             	sub    $0x14,%esp
  801797:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80179a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80179d:	50                   	push   %eax
  80179e:	53                   	push   %ebx
  80179f:	e8 ac fc ff ff       	call   801450 <fd_lookup>
  8017a4:	83 c4 08             	add    $0x8,%esp
  8017a7:	89 c2                	mov    %eax,%edx
  8017a9:	85 c0                	test   %eax,%eax
  8017ab:	78 68                	js     801815 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017ad:	83 ec 08             	sub    $0x8,%esp
  8017b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017b3:	50                   	push   %eax
  8017b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017b7:	ff 30                	pushl  (%eax)
  8017b9:	e8 e8 fc ff ff       	call   8014a6 <dev_lookup>
  8017be:	83 c4 10             	add    $0x10,%esp
  8017c1:	85 c0                	test   %eax,%eax
  8017c3:	78 47                	js     80180c <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017c8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017cc:	75 21                	jne    8017ef <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8017ce:	a1 04 40 80 00       	mov    0x804004,%eax
  8017d3:	8b 40 48             	mov    0x48(%eax),%eax
  8017d6:	83 ec 04             	sub    $0x4,%esp
  8017d9:	53                   	push   %ebx
  8017da:	50                   	push   %eax
  8017db:	68 48 2b 80 00       	push   $0x802b48
  8017e0:	e8 7c ef ff ff       	call   800761 <cprintf>
		return -E_INVAL;
  8017e5:	83 c4 10             	add    $0x10,%esp
  8017e8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017ed:	eb 26                	jmp    801815 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8017ef:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017f2:	8b 52 0c             	mov    0xc(%edx),%edx
  8017f5:	85 d2                	test   %edx,%edx
  8017f7:	74 17                	je     801810 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8017f9:	83 ec 04             	sub    $0x4,%esp
  8017fc:	ff 75 10             	pushl  0x10(%ebp)
  8017ff:	ff 75 0c             	pushl  0xc(%ebp)
  801802:	50                   	push   %eax
  801803:	ff d2                	call   *%edx
  801805:	89 c2                	mov    %eax,%edx
  801807:	83 c4 10             	add    $0x10,%esp
  80180a:	eb 09                	jmp    801815 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80180c:	89 c2                	mov    %eax,%edx
  80180e:	eb 05                	jmp    801815 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801810:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801815:	89 d0                	mov    %edx,%eax
  801817:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80181a:	c9                   	leave  
  80181b:	c3                   	ret    

0080181c <seek>:

int
seek(int fdnum, off_t offset)
{
  80181c:	55                   	push   %ebp
  80181d:	89 e5                	mov    %esp,%ebp
  80181f:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801822:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801825:	50                   	push   %eax
  801826:	ff 75 08             	pushl  0x8(%ebp)
  801829:	e8 22 fc ff ff       	call   801450 <fd_lookup>
  80182e:	83 c4 08             	add    $0x8,%esp
  801831:	85 c0                	test   %eax,%eax
  801833:	78 0e                	js     801843 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801835:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801838:	8b 55 0c             	mov    0xc(%ebp),%edx
  80183b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80183e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801843:	c9                   	leave  
  801844:	c3                   	ret    

00801845 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801845:	55                   	push   %ebp
  801846:	89 e5                	mov    %esp,%ebp
  801848:	53                   	push   %ebx
  801849:	83 ec 14             	sub    $0x14,%esp
  80184c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80184f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801852:	50                   	push   %eax
  801853:	53                   	push   %ebx
  801854:	e8 f7 fb ff ff       	call   801450 <fd_lookup>
  801859:	83 c4 08             	add    $0x8,%esp
  80185c:	89 c2                	mov    %eax,%edx
  80185e:	85 c0                	test   %eax,%eax
  801860:	78 65                	js     8018c7 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801862:	83 ec 08             	sub    $0x8,%esp
  801865:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801868:	50                   	push   %eax
  801869:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80186c:	ff 30                	pushl  (%eax)
  80186e:	e8 33 fc ff ff       	call   8014a6 <dev_lookup>
  801873:	83 c4 10             	add    $0x10,%esp
  801876:	85 c0                	test   %eax,%eax
  801878:	78 44                	js     8018be <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80187a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80187d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801881:	75 21                	jne    8018a4 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801883:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801888:	8b 40 48             	mov    0x48(%eax),%eax
  80188b:	83 ec 04             	sub    $0x4,%esp
  80188e:	53                   	push   %ebx
  80188f:	50                   	push   %eax
  801890:	68 08 2b 80 00       	push   $0x802b08
  801895:	e8 c7 ee ff ff       	call   800761 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80189a:	83 c4 10             	add    $0x10,%esp
  80189d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8018a2:	eb 23                	jmp    8018c7 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8018a4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018a7:	8b 52 18             	mov    0x18(%edx),%edx
  8018aa:	85 d2                	test   %edx,%edx
  8018ac:	74 14                	je     8018c2 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018ae:	83 ec 08             	sub    $0x8,%esp
  8018b1:	ff 75 0c             	pushl  0xc(%ebp)
  8018b4:	50                   	push   %eax
  8018b5:	ff d2                	call   *%edx
  8018b7:	89 c2                	mov    %eax,%edx
  8018b9:	83 c4 10             	add    $0x10,%esp
  8018bc:	eb 09                	jmp    8018c7 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018be:	89 c2                	mov    %eax,%edx
  8018c0:	eb 05                	jmp    8018c7 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8018c2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8018c7:	89 d0                	mov    %edx,%eax
  8018c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018cc:	c9                   	leave  
  8018cd:	c3                   	ret    

008018ce <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8018ce:	55                   	push   %ebp
  8018cf:	89 e5                	mov    %esp,%ebp
  8018d1:	53                   	push   %ebx
  8018d2:	83 ec 14             	sub    $0x14,%esp
  8018d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018d8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018db:	50                   	push   %eax
  8018dc:	ff 75 08             	pushl  0x8(%ebp)
  8018df:	e8 6c fb ff ff       	call   801450 <fd_lookup>
  8018e4:	83 c4 08             	add    $0x8,%esp
  8018e7:	89 c2                	mov    %eax,%edx
  8018e9:	85 c0                	test   %eax,%eax
  8018eb:	78 58                	js     801945 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018ed:	83 ec 08             	sub    $0x8,%esp
  8018f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018f3:	50                   	push   %eax
  8018f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018f7:	ff 30                	pushl  (%eax)
  8018f9:	e8 a8 fb ff ff       	call   8014a6 <dev_lookup>
  8018fe:	83 c4 10             	add    $0x10,%esp
  801901:	85 c0                	test   %eax,%eax
  801903:	78 37                	js     80193c <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801905:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801908:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80190c:	74 32                	je     801940 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80190e:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801911:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801918:	00 00 00 
	stat->st_isdir = 0;
  80191b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801922:	00 00 00 
	stat->st_dev = dev;
  801925:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80192b:	83 ec 08             	sub    $0x8,%esp
  80192e:	53                   	push   %ebx
  80192f:	ff 75 f0             	pushl  -0x10(%ebp)
  801932:	ff 50 14             	call   *0x14(%eax)
  801935:	89 c2                	mov    %eax,%edx
  801937:	83 c4 10             	add    $0x10,%esp
  80193a:	eb 09                	jmp    801945 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80193c:	89 c2                	mov    %eax,%edx
  80193e:	eb 05                	jmp    801945 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801940:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801945:	89 d0                	mov    %edx,%eax
  801947:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80194a:	c9                   	leave  
  80194b:	c3                   	ret    

0080194c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80194c:	55                   	push   %ebp
  80194d:	89 e5                	mov    %esp,%ebp
  80194f:	56                   	push   %esi
  801950:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801951:	83 ec 08             	sub    $0x8,%esp
  801954:	6a 00                	push   $0x0
  801956:	ff 75 08             	pushl  0x8(%ebp)
  801959:	e8 e3 01 00 00       	call   801b41 <open>
  80195e:	89 c3                	mov    %eax,%ebx
  801960:	83 c4 10             	add    $0x10,%esp
  801963:	85 c0                	test   %eax,%eax
  801965:	78 1b                	js     801982 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801967:	83 ec 08             	sub    $0x8,%esp
  80196a:	ff 75 0c             	pushl  0xc(%ebp)
  80196d:	50                   	push   %eax
  80196e:	e8 5b ff ff ff       	call   8018ce <fstat>
  801973:	89 c6                	mov    %eax,%esi
	close(fd);
  801975:	89 1c 24             	mov    %ebx,(%esp)
  801978:	e8 fd fb ff ff       	call   80157a <close>
	return r;
  80197d:	83 c4 10             	add    $0x10,%esp
  801980:	89 f0                	mov    %esi,%eax
}
  801982:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801985:	5b                   	pop    %ebx
  801986:	5e                   	pop    %esi
  801987:	5d                   	pop    %ebp
  801988:	c3                   	ret    

00801989 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801989:	55                   	push   %ebp
  80198a:	89 e5                	mov    %esp,%ebp
  80198c:	56                   	push   %esi
  80198d:	53                   	push   %ebx
  80198e:	89 c6                	mov    %eax,%esi
  801990:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801992:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801999:	75 12                	jne    8019ad <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80199b:	83 ec 0c             	sub    $0xc,%esp
  80199e:	6a 01                	push   $0x1
  8019a0:	e8 fc f9 ff ff       	call   8013a1 <ipc_find_env>
  8019a5:	a3 00 40 80 00       	mov    %eax,0x804000
  8019aa:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8019ad:	6a 07                	push   $0x7
  8019af:	68 00 50 80 00       	push   $0x805000
  8019b4:	56                   	push   %esi
  8019b5:	ff 35 00 40 80 00    	pushl  0x804000
  8019bb:	e8 8d f9 ff ff       	call   80134d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8019c0:	83 c4 0c             	add    $0xc,%esp
  8019c3:	6a 00                	push   $0x0
  8019c5:	53                   	push   %ebx
  8019c6:	6a 00                	push   $0x0
  8019c8:	e8 2b f9 ff ff       	call   8012f8 <ipc_recv>
}
  8019cd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019d0:	5b                   	pop    %ebx
  8019d1:	5e                   	pop    %esi
  8019d2:	5d                   	pop    %ebp
  8019d3:	c3                   	ret    

008019d4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8019d4:	55                   	push   %ebp
  8019d5:	89 e5                	mov    %esp,%ebp
  8019d7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8019da:	8b 45 08             	mov    0x8(%ebp),%eax
  8019dd:	8b 40 0c             	mov    0xc(%eax),%eax
  8019e0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8019e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019e8:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8019ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8019f2:	b8 02 00 00 00       	mov    $0x2,%eax
  8019f7:	e8 8d ff ff ff       	call   801989 <fsipc>
}
  8019fc:	c9                   	leave  
  8019fd:	c3                   	ret    

008019fe <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8019fe:	55                   	push   %ebp
  8019ff:	89 e5                	mov    %esp,%ebp
  801a01:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a04:	8b 45 08             	mov    0x8(%ebp),%eax
  801a07:	8b 40 0c             	mov    0xc(%eax),%eax
  801a0a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801a0f:	ba 00 00 00 00       	mov    $0x0,%edx
  801a14:	b8 06 00 00 00       	mov    $0x6,%eax
  801a19:	e8 6b ff ff ff       	call   801989 <fsipc>
}
  801a1e:	c9                   	leave  
  801a1f:	c3                   	ret    

00801a20 <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a20:	55                   	push   %ebp
  801a21:	89 e5                	mov    %esp,%ebp
  801a23:	53                   	push   %ebx
  801a24:	83 ec 04             	sub    $0x4,%esp
  801a27:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a2a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a2d:	8b 40 0c             	mov    0xc(%eax),%eax
  801a30:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a35:	ba 00 00 00 00       	mov    $0x0,%edx
  801a3a:	b8 05 00 00 00       	mov    $0x5,%eax
  801a3f:	e8 45 ff ff ff       	call   801989 <fsipc>
  801a44:	85 c0                	test   %eax,%eax
  801a46:	78 2c                	js     801a74 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a48:	83 ec 08             	sub    $0x8,%esp
  801a4b:	68 00 50 80 00       	push   $0x805000
  801a50:	53                   	push   %ebx
  801a51:	e8 ae f2 ff ff       	call   800d04 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a56:	a1 80 50 80 00       	mov    0x805080,%eax
  801a5b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a61:	a1 84 50 80 00       	mov    0x805084,%eax
  801a66:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a6c:	83 c4 10             	add    $0x10,%esp
  801a6f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a74:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a77:	c9                   	leave  
  801a78:	c3                   	ret    

00801a79 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a79:	55                   	push   %ebp
  801a7a:	89 e5                	mov    %esp,%ebp
  801a7c:	83 ec 0c             	sub    $0xc,%esp
  801a7f:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
    
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  801a82:	8b 55 08             	mov    0x8(%ebp),%edx
  801a85:	8b 52 0c             	mov    0xc(%edx),%edx
  801a88:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = MIN(n, PGSIZE);
  801a8e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a93:	ba 00 10 00 00       	mov    $0x1000,%edx
  801a98:	0f 47 c2             	cmova  %edx,%eax
  801a9b:	a3 04 50 80 00       	mov    %eax,0x805004
    memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801aa0:	50                   	push   %eax
  801aa1:	ff 75 0c             	pushl  0xc(%ebp)
  801aa4:	68 08 50 80 00       	push   $0x805008
  801aa9:	e8 e8 f3 ff ff       	call   800e96 <memmove>
    int r = fsipc(FSREQ_WRITE, NULL);
  801aae:	ba 00 00 00 00       	mov    $0x0,%edx
  801ab3:	b8 04 00 00 00       	mov    $0x4,%eax
  801ab8:	e8 cc fe ff ff       	call   801989 <fsipc>
    return r;
}
  801abd:	c9                   	leave  
  801abe:	c3                   	ret    

00801abf <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801abf:	55                   	push   %ebp
  801ac0:	89 e5                	mov    %esp,%ebp
  801ac2:	56                   	push   %esi
  801ac3:	53                   	push   %ebx
  801ac4:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801ac7:	8b 45 08             	mov    0x8(%ebp),%eax
  801aca:	8b 40 0c             	mov    0xc(%eax),%eax
  801acd:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801ad2:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801ad8:	ba 00 00 00 00       	mov    $0x0,%edx
  801add:	b8 03 00 00 00       	mov    $0x3,%eax
  801ae2:	e8 a2 fe ff ff       	call   801989 <fsipc>
  801ae7:	89 c3                	mov    %eax,%ebx
  801ae9:	85 c0                	test   %eax,%eax
  801aeb:	78 4b                	js     801b38 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801aed:	39 c6                	cmp    %eax,%esi
  801aef:	73 16                	jae    801b07 <devfile_read+0x48>
  801af1:	68 78 2b 80 00       	push   $0x802b78
  801af6:	68 7f 2b 80 00       	push   $0x802b7f
  801afb:	6a 7c                	push   $0x7c
  801afd:	68 94 2b 80 00       	push   $0x802b94
  801b02:	e8 81 eb ff ff       	call   800688 <_panic>
	assert(r <= PGSIZE);
  801b07:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b0c:	7e 16                	jle    801b24 <devfile_read+0x65>
  801b0e:	68 9f 2b 80 00       	push   $0x802b9f
  801b13:	68 7f 2b 80 00       	push   $0x802b7f
  801b18:	6a 7d                	push   $0x7d
  801b1a:	68 94 2b 80 00       	push   $0x802b94
  801b1f:	e8 64 eb ff ff       	call   800688 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b24:	83 ec 04             	sub    $0x4,%esp
  801b27:	50                   	push   %eax
  801b28:	68 00 50 80 00       	push   $0x805000
  801b2d:	ff 75 0c             	pushl  0xc(%ebp)
  801b30:	e8 61 f3 ff ff       	call   800e96 <memmove>
	return r;
  801b35:	83 c4 10             	add    $0x10,%esp
}
  801b38:	89 d8                	mov    %ebx,%eax
  801b3a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b3d:	5b                   	pop    %ebx
  801b3e:	5e                   	pop    %esi
  801b3f:	5d                   	pop    %ebp
  801b40:	c3                   	ret    

00801b41 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b41:	55                   	push   %ebp
  801b42:	89 e5                	mov    %esp,%ebp
  801b44:	53                   	push   %ebx
  801b45:	83 ec 20             	sub    $0x20,%esp
  801b48:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b4b:	53                   	push   %ebx
  801b4c:	e8 7a f1 ff ff       	call   800ccb <strlen>
  801b51:	83 c4 10             	add    $0x10,%esp
  801b54:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b59:	7f 67                	jg     801bc2 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b5b:	83 ec 0c             	sub    $0xc,%esp
  801b5e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b61:	50                   	push   %eax
  801b62:	e8 9a f8 ff ff       	call   801401 <fd_alloc>
  801b67:	83 c4 10             	add    $0x10,%esp
		return r;
  801b6a:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b6c:	85 c0                	test   %eax,%eax
  801b6e:	78 57                	js     801bc7 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801b70:	83 ec 08             	sub    $0x8,%esp
  801b73:	53                   	push   %ebx
  801b74:	68 00 50 80 00       	push   $0x805000
  801b79:	e8 86 f1 ff ff       	call   800d04 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b81:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b86:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b89:	b8 01 00 00 00       	mov    $0x1,%eax
  801b8e:	e8 f6 fd ff ff       	call   801989 <fsipc>
  801b93:	89 c3                	mov    %eax,%ebx
  801b95:	83 c4 10             	add    $0x10,%esp
  801b98:	85 c0                	test   %eax,%eax
  801b9a:	79 14                	jns    801bb0 <open+0x6f>
		fd_close(fd, 0);
  801b9c:	83 ec 08             	sub    $0x8,%esp
  801b9f:	6a 00                	push   $0x0
  801ba1:	ff 75 f4             	pushl  -0xc(%ebp)
  801ba4:	e8 50 f9 ff ff       	call   8014f9 <fd_close>
		return r;
  801ba9:	83 c4 10             	add    $0x10,%esp
  801bac:	89 da                	mov    %ebx,%edx
  801bae:	eb 17                	jmp    801bc7 <open+0x86>
	}

	return fd2num(fd);
  801bb0:	83 ec 0c             	sub    $0xc,%esp
  801bb3:	ff 75 f4             	pushl  -0xc(%ebp)
  801bb6:	e8 1f f8 ff ff       	call   8013da <fd2num>
  801bbb:	89 c2                	mov    %eax,%edx
  801bbd:	83 c4 10             	add    $0x10,%esp
  801bc0:	eb 05                	jmp    801bc7 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801bc2:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801bc7:	89 d0                	mov    %edx,%eax
  801bc9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bcc:	c9                   	leave  
  801bcd:	c3                   	ret    

00801bce <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801bce:	55                   	push   %ebp
  801bcf:	89 e5                	mov    %esp,%ebp
  801bd1:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801bd4:	ba 00 00 00 00       	mov    $0x0,%edx
  801bd9:	b8 08 00 00 00       	mov    $0x8,%eax
  801bde:	e8 a6 fd ff ff       	call   801989 <fsipc>
}
  801be3:	c9                   	leave  
  801be4:	c3                   	ret    

00801be5 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801be5:	55                   	push   %ebp
  801be6:	89 e5                	mov    %esp,%ebp
  801be8:	56                   	push   %esi
  801be9:	53                   	push   %ebx
  801bea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801bed:	83 ec 0c             	sub    $0xc,%esp
  801bf0:	ff 75 08             	pushl  0x8(%ebp)
  801bf3:	e8 f2 f7 ff ff       	call   8013ea <fd2data>
  801bf8:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801bfa:	83 c4 08             	add    $0x8,%esp
  801bfd:	68 ab 2b 80 00       	push   $0x802bab
  801c02:	53                   	push   %ebx
  801c03:	e8 fc f0 ff ff       	call   800d04 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c08:	8b 46 04             	mov    0x4(%esi),%eax
  801c0b:	2b 06                	sub    (%esi),%eax
  801c0d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c13:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c1a:	00 00 00 
	stat->st_dev = &devpipe;
  801c1d:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  801c24:	30 80 00 
	return 0;
}
  801c27:	b8 00 00 00 00       	mov    $0x0,%eax
  801c2c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c2f:	5b                   	pop    %ebx
  801c30:	5e                   	pop    %esi
  801c31:	5d                   	pop    %ebp
  801c32:	c3                   	ret    

00801c33 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c33:	55                   	push   %ebp
  801c34:	89 e5                	mov    %esp,%ebp
  801c36:	53                   	push   %ebx
  801c37:	83 ec 0c             	sub    $0xc,%esp
  801c3a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c3d:	53                   	push   %ebx
  801c3e:	6a 00                	push   $0x0
  801c40:	e8 47 f5 ff ff       	call   80118c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c45:	89 1c 24             	mov    %ebx,(%esp)
  801c48:	e8 9d f7 ff ff       	call   8013ea <fd2data>
  801c4d:	83 c4 08             	add    $0x8,%esp
  801c50:	50                   	push   %eax
  801c51:	6a 00                	push   $0x0
  801c53:	e8 34 f5 ff ff       	call   80118c <sys_page_unmap>
}
  801c58:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c5b:	c9                   	leave  
  801c5c:	c3                   	ret    

00801c5d <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801c5d:	55                   	push   %ebp
  801c5e:	89 e5                	mov    %esp,%ebp
  801c60:	57                   	push   %edi
  801c61:	56                   	push   %esi
  801c62:	53                   	push   %ebx
  801c63:	83 ec 1c             	sub    $0x1c,%esp
  801c66:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801c69:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801c6b:	a1 04 40 80 00       	mov    0x804004,%eax
  801c70:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801c73:	83 ec 0c             	sub    $0xc,%esp
  801c76:	ff 75 e0             	pushl  -0x20(%ebp)
  801c79:	e8 46 04 00 00       	call   8020c4 <pageref>
  801c7e:	89 c3                	mov    %eax,%ebx
  801c80:	89 3c 24             	mov    %edi,(%esp)
  801c83:	e8 3c 04 00 00       	call   8020c4 <pageref>
  801c88:	83 c4 10             	add    $0x10,%esp
  801c8b:	39 c3                	cmp    %eax,%ebx
  801c8d:	0f 94 c1             	sete   %cl
  801c90:	0f b6 c9             	movzbl %cl,%ecx
  801c93:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801c96:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801c9c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c9f:	39 ce                	cmp    %ecx,%esi
  801ca1:	74 1b                	je     801cbe <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801ca3:	39 c3                	cmp    %eax,%ebx
  801ca5:	75 c4                	jne    801c6b <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ca7:	8b 42 58             	mov    0x58(%edx),%eax
  801caa:	ff 75 e4             	pushl  -0x1c(%ebp)
  801cad:	50                   	push   %eax
  801cae:	56                   	push   %esi
  801caf:	68 b2 2b 80 00       	push   $0x802bb2
  801cb4:	e8 a8 ea ff ff       	call   800761 <cprintf>
  801cb9:	83 c4 10             	add    $0x10,%esp
  801cbc:	eb ad                	jmp    801c6b <_pipeisclosed+0xe>
	}
}
  801cbe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801cc1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cc4:	5b                   	pop    %ebx
  801cc5:	5e                   	pop    %esi
  801cc6:	5f                   	pop    %edi
  801cc7:	5d                   	pop    %ebp
  801cc8:	c3                   	ret    

00801cc9 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801cc9:	55                   	push   %ebp
  801cca:	89 e5                	mov    %esp,%ebp
  801ccc:	57                   	push   %edi
  801ccd:	56                   	push   %esi
  801cce:	53                   	push   %ebx
  801ccf:	83 ec 28             	sub    $0x28,%esp
  801cd2:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801cd5:	56                   	push   %esi
  801cd6:	e8 0f f7 ff ff       	call   8013ea <fd2data>
  801cdb:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cdd:	83 c4 10             	add    $0x10,%esp
  801ce0:	bf 00 00 00 00       	mov    $0x0,%edi
  801ce5:	eb 4b                	jmp    801d32 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ce7:	89 da                	mov    %ebx,%edx
  801ce9:	89 f0                	mov    %esi,%eax
  801ceb:	e8 6d ff ff ff       	call   801c5d <_pipeisclosed>
  801cf0:	85 c0                	test   %eax,%eax
  801cf2:	75 48                	jne    801d3c <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801cf4:	e8 ef f3 ff ff       	call   8010e8 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801cf9:	8b 43 04             	mov    0x4(%ebx),%eax
  801cfc:	8b 0b                	mov    (%ebx),%ecx
  801cfe:	8d 51 20             	lea    0x20(%ecx),%edx
  801d01:	39 d0                	cmp    %edx,%eax
  801d03:	73 e2                	jae    801ce7 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d08:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d0c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d0f:	89 c2                	mov    %eax,%edx
  801d11:	c1 fa 1f             	sar    $0x1f,%edx
  801d14:	89 d1                	mov    %edx,%ecx
  801d16:	c1 e9 1b             	shr    $0x1b,%ecx
  801d19:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801d1c:	83 e2 1f             	and    $0x1f,%edx
  801d1f:	29 ca                	sub    %ecx,%edx
  801d21:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801d25:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d29:	83 c0 01             	add    $0x1,%eax
  801d2c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d2f:	83 c7 01             	add    $0x1,%edi
  801d32:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d35:	75 c2                	jne    801cf9 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801d37:	8b 45 10             	mov    0x10(%ebp),%eax
  801d3a:	eb 05                	jmp    801d41 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d3c:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801d41:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d44:	5b                   	pop    %ebx
  801d45:	5e                   	pop    %esi
  801d46:	5f                   	pop    %edi
  801d47:	5d                   	pop    %ebp
  801d48:	c3                   	ret    

00801d49 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d49:	55                   	push   %ebp
  801d4a:	89 e5                	mov    %esp,%ebp
  801d4c:	57                   	push   %edi
  801d4d:	56                   	push   %esi
  801d4e:	53                   	push   %ebx
  801d4f:	83 ec 18             	sub    $0x18,%esp
  801d52:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d55:	57                   	push   %edi
  801d56:	e8 8f f6 ff ff       	call   8013ea <fd2data>
  801d5b:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d5d:	83 c4 10             	add    $0x10,%esp
  801d60:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d65:	eb 3d                	jmp    801da4 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801d67:	85 db                	test   %ebx,%ebx
  801d69:	74 04                	je     801d6f <devpipe_read+0x26>
				return i;
  801d6b:	89 d8                	mov    %ebx,%eax
  801d6d:	eb 44                	jmp    801db3 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801d6f:	89 f2                	mov    %esi,%edx
  801d71:	89 f8                	mov    %edi,%eax
  801d73:	e8 e5 fe ff ff       	call   801c5d <_pipeisclosed>
  801d78:	85 c0                	test   %eax,%eax
  801d7a:	75 32                	jne    801dae <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801d7c:	e8 67 f3 ff ff       	call   8010e8 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801d81:	8b 06                	mov    (%esi),%eax
  801d83:	3b 46 04             	cmp    0x4(%esi),%eax
  801d86:	74 df                	je     801d67 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d88:	99                   	cltd   
  801d89:	c1 ea 1b             	shr    $0x1b,%edx
  801d8c:	01 d0                	add    %edx,%eax
  801d8e:	83 e0 1f             	and    $0x1f,%eax
  801d91:	29 d0                	sub    %edx,%eax
  801d93:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801d98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d9b:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801d9e:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801da1:	83 c3 01             	add    $0x1,%ebx
  801da4:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801da7:	75 d8                	jne    801d81 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801da9:	8b 45 10             	mov    0x10(%ebp),%eax
  801dac:	eb 05                	jmp    801db3 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801dae:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801db3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801db6:	5b                   	pop    %ebx
  801db7:	5e                   	pop    %esi
  801db8:	5f                   	pop    %edi
  801db9:	5d                   	pop    %ebp
  801dba:	c3                   	ret    

00801dbb <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801dbb:	55                   	push   %ebp
  801dbc:	89 e5                	mov    %esp,%ebp
  801dbe:	56                   	push   %esi
  801dbf:	53                   	push   %ebx
  801dc0:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801dc3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dc6:	50                   	push   %eax
  801dc7:	e8 35 f6 ff ff       	call   801401 <fd_alloc>
  801dcc:	83 c4 10             	add    $0x10,%esp
  801dcf:	89 c2                	mov    %eax,%edx
  801dd1:	85 c0                	test   %eax,%eax
  801dd3:	0f 88 2c 01 00 00    	js     801f05 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dd9:	83 ec 04             	sub    $0x4,%esp
  801ddc:	68 07 04 00 00       	push   $0x407
  801de1:	ff 75 f4             	pushl  -0xc(%ebp)
  801de4:	6a 00                	push   $0x0
  801de6:	e8 1c f3 ff ff       	call   801107 <sys_page_alloc>
  801deb:	83 c4 10             	add    $0x10,%esp
  801dee:	89 c2                	mov    %eax,%edx
  801df0:	85 c0                	test   %eax,%eax
  801df2:	0f 88 0d 01 00 00    	js     801f05 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801df8:	83 ec 0c             	sub    $0xc,%esp
  801dfb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801dfe:	50                   	push   %eax
  801dff:	e8 fd f5 ff ff       	call   801401 <fd_alloc>
  801e04:	89 c3                	mov    %eax,%ebx
  801e06:	83 c4 10             	add    $0x10,%esp
  801e09:	85 c0                	test   %eax,%eax
  801e0b:	0f 88 e2 00 00 00    	js     801ef3 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e11:	83 ec 04             	sub    $0x4,%esp
  801e14:	68 07 04 00 00       	push   $0x407
  801e19:	ff 75 f0             	pushl  -0x10(%ebp)
  801e1c:	6a 00                	push   $0x0
  801e1e:	e8 e4 f2 ff ff       	call   801107 <sys_page_alloc>
  801e23:	89 c3                	mov    %eax,%ebx
  801e25:	83 c4 10             	add    $0x10,%esp
  801e28:	85 c0                	test   %eax,%eax
  801e2a:	0f 88 c3 00 00 00    	js     801ef3 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801e30:	83 ec 0c             	sub    $0xc,%esp
  801e33:	ff 75 f4             	pushl  -0xc(%ebp)
  801e36:	e8 af f5 ff ff       	call   8013ea <fd2data>
  801e3b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e3d:	83 c4 0c             	add    $0xc,%esp
  801e40:	68 07 04 00 00       	push   $0x407
  801e45:	50                   	push   %eax
  801e46:	6a 00                	push   $0x0
  801e48:	e8 ba f2 ff ff       	call   801107 <sys_page_alloc>
  801e4d:	89 c3                	mov    %eax,%ebx
  801e4f:	83 c4 10             	add    $0x10,%esp
  801e52:	85 c0                	test   %eax,%eax
  801e54:	0f 88 89 00 00 00    	js     801ee3 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e5a:	83 ec 0c             	sub    $0xc,%esp
  801e5d:	ff 75 f0             	pushl  -0x10(%ebp)
  801e60:	e8 85 f5 ff ff       	call   8013ea <fd2data>
  801e65:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e6c:	50                   	push   %eax
  801e6d:	6a 00                	push   $0x0
  801e6f:	56                   	push   %esi
  801e70:	6a 00                	push   $0x0
  801e72:	e8 d3 f2 ff ff       	call   80114a <sys_page_map>
  801e77:	89 c3                	mov    %eax,%ebx
  801e79:	83 c4 20             	add    $0x20,%esp
  801e7c:	85 c0                	test   %eax,%eax
  801e7e:	78 55                	js     801ed5 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801e80:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801e86:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e89:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e8e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801e95:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801e9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e9e:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ea0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ea3:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801eaa:	83 ec 0c             	sub    $0xc,%esp
  801ead:	ff 75 f4             	pushl  -0xc(%ebp)
  801eb0:	e8 25 f5 ff ff       	call   8013da <fd2num>
  801eb5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801eb8:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801eba:	83 c4 04             	add    $0x4,%esp
  801ebd:	ff 75 f0             	pushl  -0x10(%ebp)
  801ec0:	e8 15 f5 ff ff       	call   8013da <fd2num>
  801ec5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ec8:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ecb:	83 c4 10             	add    $0x10,%esp
  801ece:	ba 00 00 00 00       	mov    $0x0,%edx
  801ed3:	eb 30                	jmp    801f05 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801ed5:	83 ec 08             	sub    $0x8,%esp
  801ed8:	56                   	push   %esi
  801ed9:	6a 00                	push   $0x0
  801edb:	e8 ac f2 ff ff       	call   80118c <sys_page_unmap>
  801ee0:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801ee3:	83 ec 08             	sub    $0x8,%esp
  801ee6:	ff 75 f0             	pushl  -0x10(%ebp)
  801ee9:	6a 00                	push   $0x0
  801eeb:	e8 9c f2 ff ff       	call   80118c <sys_page_unmap>
  801ef0:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ef3:	83 ec 08             	sub    $0x8,%esp
  801ef6:	ff 75 f4             	pushl  -0xc(%ebp)
  801ef9:	6a 00                	push   $0x0
  801efb:	e8 8c f2 ff ff       	call   80118c <sys_page_unmap>
  801f00:	83 c4 10             	add    $0x10,%esp
  801f03:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801f05:	89 d0                	mov    %edx,%eax
  801f07:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f0a:	5b                   	pop    %ebx
  801f0b:	5e                   	pop    %esi
  801f0c:	5d                   	pop    %ebp
  801f0d:	c3                   	ret    

00801f0e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801f0e:	55                   	push   %ebp
  801f0f:	89 e5                	mov    %esp,%ebp
  801f11:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f14:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f17:	50                   	push   %eax
  801f18:	ff 75 08             	pushl  0x8(%ebp)
  801f1b:	e8 30 f5 ff ff       	call   801450 <fd_lookup>
  801f20:	83 c4 10             	add    $0x10,%esp
  801f23:	85 c0                	test   %eax,%eax
  801f25:	78 18                	js     801f3f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801f27:	83 ec 0c             	sub    $0xc,%esp
  801f2a:	ff 75 f4             	pushl  -0xc(%ebp)
  801f2d:	e8 b8 f4 ff ff       	call   8013ea <fd2data>
	return _pipeisclosed(fd, p);
  801f32:	89 c2                	mov    %eax,%edx
  801f34:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f37:	e8 21 fd ff ff       	call   801c5d <_pipeisclosed>
  801f3c:	83 c4 10             	add    $0x10,%esp
}
  801f3f:	c9                   	leave  
  801f40:	c3                   	ret    

00801f41 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f41:	55                   	push   %ebp
  801f42:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f44:	b8 00 00 00 00       	mov    $0x0,%eax
  801f49:	5d                   	pop    %ebp
  801f4a:	c3                   	ret    

00801f4b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f4b:	55                   	push   %ebp
  801f4c:	89 e5                	mov    %esp,%ebp
  801f4e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f51:	68 ca 2b 80 00       	push   $0x802bca
  801f56:	ff 75 0c             	pushl  0xc(%ebp)
  801f59:	e8 a6 ed ff ff       	call   800d04 <strcpy>
	return 0;
}
  801f5e:	b8 00 00 00 00       	mov    $0x0,%eax
  801f63:	c9                   	leave  
  801f64:	c3                   	ret    

00801f65 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f65:	55                   	push   %ebp
  801f66:	89 e5                	mov    %esp,%ebp
  801f68:	57                   	push   %edi
  801f69:	56                   	push   %esi
  801f6a:	53                   	push   %ebx
  801f6b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f71:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f76:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f7c:	eb 2d                	jmp    801fab <devcons_write+0x46>
		m = n - tot;
  801f7e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f81:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801f83:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801f86:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801f8b:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f8e:	83 ec 04             	sub    $0x4,%esp
  801f91:	53                   	push   %ebx
  801f92:	03 45 0c             	add    0xc(%ebp),%eax
  801f95:	50                   	push   %eax
  801f96:	57                   	push   %edi
  801f97:	e8 fa ee ff ff       	call   800e96 <memmove>
		sys_cputs(buf, m);
  801f9c:	83 c4 08             	add    $0x8,%esp
  801f9f:	53                   	push   %ebx
  801fa0:	57                   	push   %edi
  801fa1:	e8 a5 f0 ff ff       	call   80104b <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fa6:	01 de                	add    %ebx,%esi
  801fa8:	83 c4 10             	add    $0x10,%esp
  801fab:	89 f0                	mov    %esi,%eax
  801fad:	3b 75 10             	cmp    0x10(%ebp),%esi
  801fb0:	72 cc                	jb     801f7e <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801fb2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fb5:	5b                   	pop    %ebx
  801fb6:	5e                   	pop    %esi
  801fb7:	5f                   	pop    %edi
  801fb8:	5d                   	pop    %ebp
  801fb9:	c3                   	ret    

00801fba <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801fba:	55                   	push   %ebp
  801fbb:	89 e5                	mov    %esp,%ebp
  801fbd:	83 ec 08             	sub    $0x8,%esp
  801fc0:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801fc5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801fc9:	74 2a                	je     801ff5 <devcons_read+0x3b>
  801fcb:	eb 05                	jmp    801fd2 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801fcd:	e8 16 f1 ff ff       	call   8010e8 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801fd2:	e8 92 f0 ff ff       	call   801069 <sys_cgetc>
  801fd7:	85 c0                	test   %eax,%eax
  801fd9:	74 f2                	je     801fcd <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801fdb:	85 c0                	test   %eax,%eax
  801fdd:	78 16                	js     801ff5 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801fdf:	83 f8 04             	cmp    $0x4,%eax
  801fe2:	74 0c                	je     801ff0 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801fe4:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fe7:	88 02                	mov    %al,(%edx)
	return 1;
  801fe9:	b8 01 00 00 00       	mov    $0x1,%eax
  801fee:	eb 05                	jmp    801ff5 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ff0:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801ff5:	c9                   	leave  
  801ff6:	c3                   	ret    

00801ff7 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801ff7:	55                   	push   %ebp
  801ff8:	89 e5                	mov    %esp,%ebp
  801ffa:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ffd:	8b 45 08             	mov    0x8(%ebp),%eax
  802000:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802003:	6a 01                	push   $0x1
  802005:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802008:	50                   	push   %eax
  802009:	e8 3d f0 ff ff       	call   80104b <sys_cputs>
}
  80200e:	83 c4 10             	add    $0x10,%esp
  802011:	c9                   	leave  
  802012:	c3                   	ret    

00802013 <getchar>:

int
getchar(void)
{
  802013:	55                   	push   %ebp
  802014:	89 e5                	mov    %esp,%ebp
  802016:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802019:	6a 01                	push   $0x1
  80201b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80201e:	50                   	push   %eax
  80201f:	6a 00                	push   $0x0
  802021:	e8 90 f6 ff ff       	call   8016b6 <read>
	if (r < 0)
  802026:	83 c4 10             	add    $0x10,%esp
  802029:	85 c0                	test   %eax,%eax
  80202b:	78 0f                	js     80203c <getchar+0x29>
		return r;
	if (r < 1)
  80202d:	85 c0                	test   %eax,%eax
  80202f:	7e 06                	jle    802037 <getchar+0x24>
		return -E_EOF;
	return c;
  802031:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802035:	eb 05                	jmp    80203c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802037:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80203c:	c9                   	leave  
  80203d:	c3                   	ret    

0080203e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80203e:	55                   	push   %ebp
  80203f:	89 e5                	mov    %esp,%ebp
  802041:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802044:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802047:	50                   	push   %eax
  802048:	ff 75 08             	pushl  0x8(%ebp)
  80204b:	e8 00 f4 ff ff       	call   801450 <fd_lookup>
  802050:	83 c4 10             	add    $0x10,%esp
  802053:	85 c0                	test   %eax,%eax
  802055:	78 11                	js     802068 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802057:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80205a:	8b 15 40 30 80 00    	mov    0x803040,%edx
  802060:	39 10                	cmp    %edx,(%eax)
  802062:	0f 94 c0             	sete   %al
  802065:	0f b6 c0             	movzbl %al,%eax
}
  802068:	c9                   	leave  
  802069:	c3                   	ret    

0080206a <opencons>:

int
opencons(void)
{
  80206a:	55                   	push   %ebp
  80206b:	89 e5                	mov    %esp,%ebp
  80206d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802070:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802073:	50                   	push   %eax
  802074:	e8 88 f3 ff ff       	call   801401 <fd_alloc>
  802079:	83 c4 10             	add    $0x10,%esp
		return r;
  80207c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80207e:	85 c0                	test   %eax,%eax
  802080:	78 3e                	js     8020c0 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802082:	83 ec 04             	sub    $0x4,%esp
  802085:	68 07 04 00 00       	push   $0x407
  80208a:	ff 75 f4             	pushl  -0xc(%ebp)
  80208d:	6a 00                	push   $0x0
  80208f:	e8 73 f0 ff ff       	call   801107 <sys_page_alloc>
  802094:	83 c4 10             	add    $0x10,%esp
		return r;
  802097:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802099:	85 c0                	test   %eax,%eax
  80209b:	78 23                	js     8020c0 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80209d:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8020a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020a6:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8020a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020ab:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8020b2:	83 ec 0c             	sub    $0xc,%esp
  8020b5:	50                   	push   %eax
  8020b6:	e8 1f f3 ff ff       	call   8013da <fd2num>
  8020bb:	89 c2                	mov    %eax,%edx
  8020bd:	83 c4 10             	add    $0x10,%esp
}
  8020c0:	89 d0                	mov    %edx,%eax
  8020c2:	c9                   	leave  
  8020c3:	c3                   	ret    

008020c4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020c4:	55                   	push   %ebp
  8020c5:	89 e5                	mov    %esp,%ebp
  8020c7:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020ca:	89 d0                	mov    %edx,%eax
  8020cc:	c1 e8 16             	shr    $0x16,%eax
  8020cf:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8020d6:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020db:	f6 c1 01             	test   $0x1,%cl
  8020de:	74 1d                	je     8020fd <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8020e0:	c1 ea 0c             	shr    $0xc,%edx
  8020e3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8020ea:	f6 c2 01             	test   $0x1,%dl
  8020ed:	74 0e                	je     8020fd <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020ef:	c1 ea 0c             	shr    $0xc,%edx
  8020f2:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8020f9:	ef 
  8020fa:	0f b7 c0             	movzwl %ax,%eax
}
  8020fd:	5d                   	pop    %ebp
  8020fe:	c3                   	ret    
  8020ff:	90                   	nop

00802100 <__udivdi3>:
  802100:	55                   	push   %ebp
  802101:	57                   	push   %edi
  802102:	56                   	push   %esi
  802103:	53                   	push   %ebx
  802104:	83 ec 1c             	sub    $0x1c,%esp
  802107:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80210b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80210f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802113:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802117:	85 f6                	test   %esi,%esi
  802119:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80211d:	89 ca                	mov    %ecx,%edx
  80211f:	89 f8                	mov    %edi,%eax
  802121:	75 3d                	jne    802160 <__udivdi3+0x60>
  802123:	39 cf                	cmp    %ecx,%edi
  802125:	0f 87 c5 00 00 00    	ja     8021f0 <__udivdi3+0xf0>
  80212b:	85 ff                	test   %edi,%edi
  80212d:	89 fd                	mov    %edi,%ebp
  80212f:	75 0b                	jne    80213c <__udivdi3+0x3c>
  802131:	b8 01 00 00 00       	mov    $0x1,%eax
  802136:	31 d2                	xor    %edx,%edx
  802138:	f7 f7                	div    %edi
  80213a:	89 c5                	mov    %eax,%ebp
  80213c:	89 c8                	mov    %ecx,%eax
  80213e:	31 d2                	xor    %edx,%edx
  802140:	f7 f5                	div    %ebp
  802142:	89 c1                	mov    %eax,%ecx
  802144:	89 d8                	mov    %ebx,%eax
  802146:	89 cf                	mov    %ecx,%edi
  802148:	f7 f5                	div    %ebp
  80214a:	89 c3                	mov    %eax,%ebx
  80214c:	89 d8                	mov    %ebx,%eax
  80214e:	89 fa                	mov    %edi,%edx
  802150:	83 c4 1c             	add    $0x1c,%esp
  802153:	5b                   	pop    %ebx
  802154:	5e                   	pop    %esi
  802155:	5f                   	pop    %edi
  802156:	5d                   	pop    %ebp
  802157:	c3                   	ret    
  802158:	90                   	nop
  802159:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802160:	39 ce                	cmp    %ecx,%esi
  802162:	77 74                	ja     8021d8 <__udivdi3+0xd8>
  802164:	0f bd fe             	bsr    %esi,%edi
  802167:	83 f7 1f             	xor    $0x1f,%edi
  80216a:	0f 84 98 00 00 00    	je     802208 <__udivdi3+0x108>
  802170:	bb 20 00 00 00       	mov    $0x20,%ebx
  802175:	89 f9                	mov    %edi,%ecx
  802177:	89 c5                	mov    %eax,%ebp
  802179:	29 fb                	sub    %edi,%ebx
  80217b:	d3 e6                	shl    %cl,%esi
  80217d:	89 d9                	mov    %ebx,%ecx
  80217f:	d3 ed                	shr    %cl,%ebp
  802181:	89 f9                	mov    %edi,%ecx
  802183:	d3 e0                	shl    %cl,%eax
  802185:	09 ee                	or     %ebp,%esi
  802187:	89 d9                	mov    %ebx,%ecx
  802189:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80218d:	89 d5                	mov    %edx,%ebp
  80218f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802193:	d3 ed                	shr    %cl,%ebp
  802195:	89 f9                	mov    %edi,%ecx
  802197:	d3 e2                	shl    %cl,%edx
  802199:	89 d9                	mov    %ebx,%ecx
  80219b:	d3 e8                	shr    %cl,%eax
  80219d:	09 c2                	or     %eax,%edx
  80219f:	89 d0                	mov    %edx,%eax
  8021a1:	89 ea                	mov    %ebp,%edx
  8021a3:	f7 f6                	div    %esi
  8021a5:	89 d5                	mov    %edx,%ebp
  8021a7:	89 c3                	mov    %eax,%ebx
  8021a9:	f7 64 24 0c          	mull   0xc(%esp)
  8021ad:	39 d5                	cmp    %edx,%ebp
  8021af:	72 10                	jb     8021c1 <__udivdi3+0xc1>
  8021b1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8021b5:	89 f9                	mov    %edi,%ecx
  8021b7:	d3 e6                	shl    %cl,%esi
  8021b9:	39 c6                	cmp    %eax,%esi
  8021bb:	73 07                	jae    8021c4 <__udivdi3+0xc4>
  8021bd:	39 d5                	cmp    %edx,%ebp
  8021bf:	75 03                	jne    8021c4 <__udivdi3+0xc4>
  8021c1:	83 eb 01             	sub    $0x1,%ebx
  8021c4:	31 ff                	xor    %edi,%edi
  8021c6:	89 d8                	mov    %ebx,%eax
  8021c8:	89 fa                	mov    %edi,%edx
  8021ca:	83 c4 1c             	add    $0x1c,%esp
  8021cd:	5b                   	pop    %ebx
  8021ce:	5e                   	pop    %esi
  8021cf:	5f                   	pop    %edi
  8021d0:	5d                   	pop    %ebp
  8021d1:	c3                   	ret    
  8021d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021d8:	31 ff                	xor    %edi,%edi
  8021da:	31 db                	xor    %ebx,%ebx
  8021dc:	89 d8                	mov    %ebx,%eax
  8021de:	89 fa                	mov    %edi,%edx
  8021e0:	83 c4 1c             	add    $0x1c,%esp
  8021e3:	5b                   	pop    %ebx
  8021e4:	5e                   	pop    %esi
  8021e5:	5f                   	pop    %edi
  8021e6:	5d                   	pop    %ebp
  8021e7:	c3                   	ret    
  8021e8:	90                   	nop
  8021e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021f0:	89 d8                	mov    %ebx,%eax
  8021f2:	f7 f7                	div    %edi
  8021f4:	31 ff                	xor    %edi,%edi
  8021f6:	89 c3                	mov    %eax,%ebx
  8021f8:	89 d8                	mov    %ebx,%eax
  8021fa:	89 fa                	mov    %edi,%edx
  8021fc:	83 c4 1c             	add    $0x1c,%esp
  8021ff:	5b                   	pop    %ebx
  802200:	5e                   	pop    %esi
  802201:	5f                   	pop    %edi
  802202:	5d                   	pop    %ebp
  802203:	c3                   	ret    
  802204:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802208:	39 ce                	cmp    %ecx,%esi
  80220a:	72 0c                	jb     802218 <__udivdi3+0x118>
  80220c:	31 db                	xor    %ebx,%ebx
  80220e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802212:	0f 87 34 ff ff ff    	ja     80214c <__udivdi3+0x4c>
  802218:	bb 01 00 00 00       	mov    $0x1,%ebx
  80221d:	e9 2a ff ff ff       	jmp    80214c <__udivdi3+0x4c>
  802222:	66 90                	xchg   %ax,%ax
  802224:	66 90                	xchg   %ax,%ax
  802226:	66 90                	xchg   %ax,%ax
  802228:	66 90                	xchg   %ax,%ax
  80222a:	66 90                	xchg   %ax,%ax
  80222c:	66 90                	xchg   %ax,%ax
  80222e:	66 90                	xchg   %ax,%ax

00802230 <__umoddi3>:
  802230:	55                   	push   %ebp
  802231:	57                   	push   %edi
  802232:	56                   	push   %esi
  802233:	53                   	push   %ebx
  802234:	83 ec 1c             	sub    $0x1c,%esp
  802237:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80223b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80223f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802243:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802247:	85 d2                	test   %edx,%edx
  802249:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80224d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802251:	89 f3                	mov    %esi,%ebx
  802253:	89 3c 24             	mov    %edi,(%esp)
  802256:	89 74 24 04          	mov    %esi,0x4(%esp)
  80225a:	75 1c                	jne    802278 <__umoddi3+0x48>
  80225c:	39 f7                	cmp    %esi,%edi
  80225e:	76 50                	jbe    8022b0 <__umoddi3+0x80>
  802260:	89 c8                	mov    %ecx,%eax
  802262:	89 f2                	mov    %esi,%edx
  802264:	f7 f7                	div    %edi
  802266:	89 d0                	mov    %edx,%eax
  802268:	31 d2                	xor    %edx,%edx
  80226a:	83 c4 1c             	add    $0x1c,%esp
  80226d:	5b                   	pop    %ebx
  80226e:	5e                   	pop    %esi
  80226f:	5f                   	pop    %edi
  802270:	5d                   	pop    %ebp
  802271:	c3                   	ret    
  802272:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802278:	39 f2                	cmp    %esi,%edx
  80227a:	89 d0                	mov    %edx,%eax
  80227c:	77 52                	ja     8022d0 <__umoddi3+0xa0>
  80227e:	0f bd ea             	bsr    %edx,%ebp
  802281:	83 f5 1f             	xor    $0x1f,%ebp
  802284:	75 5a                	jne    8022e0 <__umoddi3+0xb0>
  802286:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80228a:	0f 82 e0 00 00 00    	jb     802370 <__umoddi3+0x140>
  802290:	39 0c 24             	cmp    %ecx,(%esp)
  802293:	0f 86 d7 00 00 00    	jbe    802370 <__umoddi3+0x140>
  802299:	8b 44 24 08          	mov    0x8(%esp),%eax
  80229d:	8b 54 24 04          	mov    0x4(%esp),%edx
  8022a1:	83 c4 1c             	add    $0x1c,%esp
  8022a4:	5b                   	pop    %ebx
  8022a5:	5e                   	pop    %esi
  8022a6:	5f                   	pop    %edi
  8022a7:	5d                   	pop    %ebp
  8022a8:	c3                   	ret    
  8022a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022b0:	85 ff                	test   %edi,%edi
  8022b2:	89 fd                	mov    %edi,%ebp
  8022b4:	75 0b                	jne    8022c1 <__umoddi3+0x91>
  8022b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8022bb:	31 d2                	xor    %edx,%edx
  8022bd:	f7 f7                	div    %edi
  8022bf:	89 c5                	mov    %eax,%ebp
  8022c1:	89 f0                	mov    %esi,%eax
  8022c3:	31 d2                	xor    %edx,%edx
  8022c5:	f7 f5                	div    %ebp
  8022c7:	89 c8                	mov    %ecx,%eax
  8022c9:	f7 f5                	div    %ebp
  8022cb:	89 d0                	mov    %edx,%eax
  8022cd:	eb 99                	jmp    802268 <__umoddi3+0x38>
  8022cf:	90                   	nop
  8022d0:	89 c8                	mov    %ecx,%eax
  8022d2:	89 f2                	mov    %esi,%edx
  8022d4:	83 c4 1c             	add    $0x1c,%esp
  8022d7:	5b                   	pop    %ebx
  8022d8:	5e                   	pop    %esi
  8022d9:	5f                   	pop    %edi
  8022da:	5d                   	pop    %ebp
  8022db:	c3                   	ret    
  8022dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022e0:	8b 34 24             	mov    (%esp),%esi
  8022e3:	bf 20 00 00 00       	mov    $0x20,%edi
  8022e8:	89 e9                	mov    %ebp,%ecx
  8022ea:	29 ef                	sub    %ebp,%edi
  8022ec:	d3 e0                	shl    %cl,%eax
  8022ee:	89 f9                	mov    %edi,%ecx
  8022f0:	89 f2                	mov    %esi,%edx
  8022f2:	d3 ea                	shr    %cl,%edx
  8022f4:	89 e9                	mov    %ebp,%ecx
  8022f6:	09 c2                	or     %eax,%edx
  8022f8:	89 d8                	mov    %ebx,%eax
  8022fa:	89 14 24             	mov    %edx,(%esp)
  8022fd:	89 f2                	mov    %esi,%edx
  8022ff:	d3 e2                	shl    %cl,%edx
  802301:	89 f9                	mov    %edi,%ecx
  802303:	89 54 24 04          	mov    %edx,0x4(%esp)
  802307:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80230b:	d3 e8                	shr    %cl,%eax
  80230d:	89 e9                	mov    %ebp,%ecx
  80230f:	89 c6                	mov    %eax,%esi
  802311:	d3 e3                	shl    %cl,%ebx
  802313:	89 f9                	mov    %edi,%ecx
  802315:	89 d0                	mov    %edx,%eax
  802317:	d3 e8                	shr    %cl,%eax
  802319:	89 e9                	mov    %ebp,%ecx
  80231b:	09 d8                	or     %ebx,%eax
  80231d:	89 d3                	mov    %edx,%ebx
  80231f:	89 f2                	mov    %esi,%edx
  802321:	f7 34 24             	divl   (%esp)
  802324:	89 d6                	mov    %edx,%esi
  802326:	d3 e3                	shl    %cl,%ebx
  802328:	f7 64 24 04          	mull   0x4(%esp)
  80232c:	39 d6                	cmp    %edx,%esi
  80232e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802332:	89 d1                	mov    %edx,%ecx
  802334:	89 c3                	mov    %eax,%ebx
  802336:	72 08                	jb     802340 <__umoddi3+0x110>
  802338:	75 11                	jne    80234b <__umoddi3+0x11b>
  80233a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80233e:	73 0b                	jae    80234b <__umoddi3+0x11b>
  802340:	2b 44 24 04          	sub    0x4(%esp),%eax
  802344:	1b 14 24             	sbb    (%esp),%edx
  802347:	89 d1                	mov    %edx,%ecx
  802349:	89 c3                	mov    %eax,%ebx
  80234b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80234f:	29 da                	sub    %ebx,%edx
  802351:	19 ce                	sbb    %ecx,%esi
  802353:	89 f9                	mov    %edi,%ecx
  802355:	89 f0                	mov    %esi,%eax
  802357:	d3 e0                	shl    %cl,%eax
  802359:	89 e9                	mov    %ebp,%ecx
  80235b:	d3 ea                	shr    %cl,%edx
  80235d:	89 e9                	mov    %ebp,%ecx
  80235f:	d3 ee                	shr    %cl,%esi
  802361:	09 d0                	or     %edx,%eax
  802363:	89 f2                	mov    %esi,%edx
  802365:	83 c4 1c             	add    $0x1c,%esp
  802368:	5b                   	pop    %ebx
  802369:	5e                   	pop    %esi
  80236a:	5f                   	pop    %edi
  80236b:	5d                   	pop    %ebp
  80236c:	c3                   	ret    
  80236d:	8d 76 00             	lea    0x0(%esi),%esi
  802370:	29 f9                	sub    %edi,%ecx
  802372:	19 d6                	sbb    %edx,%esi
  802374:	89 74 24 04          	mov    %esi,0x4(%esp)
  802378:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80237c:	e9 18 ff ff ff       	jmp    802299 <__umoddi3+0x69>
