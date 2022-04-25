
obj/user/faultregs.debug:     file format elf32-i386


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
  80002c:	e8 66 05 00 00       	call   800597 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <check_regs>:
static struct regs before, during, after;

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 0c             	sub    $0xc,%esp
  80003c:	89 c6                	mov    %eax,%esi
  80003e:	89 cb                	mov    %ecx,%ebx
	int mismatch = 0;

	cprintf("%-6s %-8s %-8s\n", "", an, bn);
  800040:	ff 75 08             	pushl  0x8(%ebp)
  800043:	52                   	push   %edx
  800044:	68 d1 23 80 00       	push   $0x8023d1
  800049:	68 a0 23 80 00       	push   $0x8023a0
  80004e:	e8 7d 06 00 00       	call   8006d0 <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800053:	ff 33                	pushl  (%ebx)
  800055:	ff 36                	pushl  (%esi)
  800057:	68 b0 23 80 00       	push   $0x8023b0
  80005c:	68 b4 23 80 00       	push   $0x8023b4
  800061:	e8 6a 06 00 00       	call   8006d0 <cprintf>
  800066:	83 c4 20             	add    $0x20,%esp
  800069:	8b 03                	mov    (%ebx),%eax
  80006b:	39 06                	cmp    %eax,(%esi)
  80006d:	75 17                	jne    800086 <check_regs+0x53>
  80006f:	83 ec 0c             	sub    $0xc,%esp
  800072:	68 c4 23 80 00       	push   $0x8023c4
  800077:	e8 54 06 00 00       	call   8006d0 <cprintf>
  80007c:	83 c4 10             	add    $0x10,%esp

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
	int mismatch = 0;
  80007f:	bf 00 00 00 00       	mov    $0x0,%edi
  800084:	eb 15                	jmp    80009b <check_regs+0x68>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800086:	83 ec 0c             	sub    $0xc,%esp
  800089:	68 c8 23 80 00       	push   $0x8023c8
  80008e:	e8 3d 06 00 00       	call   8006d0 <cprintf>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  80009b:	ff 73 04             	pushl  0x4(%ebx)
  80009e:	ff 76 04             	pushl  0x4(%esi)
  8000a1:	68 d2 23 80 00       	push   $0x8023d2
  8000a6:	68 b4 23 80 00       	push   $0x8023b4
  8000ab:	e8 20 06 00 00       	call   8006d0 <cprintf>
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	8b 43 04             	mov    0x4(%ebx),%eax
  8000b6:	39 46 04             	cmp    %eax,0x4(%esi)
  8000b9:	75 12                	jne    8000cd <check_regs+0x9a>
  8000bb:	83 ec 0c             	sub    $0xc,%esp
  8000be:	68 c4 23 80 00       	push   $0x8023c4
  8000c3:	e8 08 06 00 00       	call   8006d0 <cprintf>
  8000c8:	83 c4 10             	add    $0x10,%esp
  8000cb:	eb 15                	jmp    8000e2 <check_regs+0xaf>
  8000cd:	83 ec 0c             	sub    $0xc,%esp
  8000d0:	68 c8 23 80 00       	push   $0x8023c8
  8000d5:	e8 f6 05 00 00       	call   8006d0 <cprintf>
  8000da:	83 c4 10             	add    $0x10,%esp
  8000dd:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000e2:	ff 73 08             	pushl  0x8(%ebx)
  8000e5:	ff 76 08             	pushl  0x8(%esi)
  8000e8:	68 d6 23 80 00       	push   $0x8023d6
  8000ed:	68 b4 23 80 00       	push   $0x8023b4
  8000f2:	e8 d9 05 00 00       	call   8006d0 <cprintf>
  8000f7:	83 c4 10             	add    $0x10,%esp
  8000fa:	8b 43 08             	mov    0x8(%ebx),%eax
  8000fd:	39 46 08             	cmp    %eax,0x8(%esi)
  800100:	75 12                	jne    800114 <check_regs+0xe1>
  800102:	83 ec 0c             	sub    $0xc,%esp
  800105:	68 c4 23 80 00       	push   $0x8023c4
  80010a:	e8 c1 05 00 00       	call   8006d0 <cprintf>
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	eb 15                	jmp    800129 <check_regs+0xf6>
  800114:	83 ec 0c             	sub    $0xc,%esp
  800117:	68 c8 23 80 00       	push   $0x8023c8
  80011c:	e8 af 05 00 00       	call   8006d0 <cprintf>
  800121:	83 c4 10             	add    $0x10,%esp
  800124:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  800129:	ff 73 10             	pushl  0x10(%ebx)
  80012c:	ff 76 10             	pushl  0x10(%esi)
  80012f:	68 da 23 80 00       	push   $0x8023da
  800134:	68 b4 23 80 00       	push   $0x8023b4
  800139:	e8 92 05 00 00       	call   8006d0 <cprintf>
  80013e:	83 c4 10             	add    $0x10,%esp
  800141:	8b 43 10             	mov    0x10(%ebx),%eax
  800144:	39 46 10             	cmp    %eax,0x10(%esi)
  800147:	75 12                	jne    80015b <check_regs+0x128>
  800149:	83 ec 0c             	sub    $0xc,%esp
  80014c:	68 c4 23 80 00       	push   $0x8023c4
  800151:	e8 7a 05 00 00       	call   8006d0 <cprintf>
  800156:	83 c4 10             	add    $0x10,%esp
  800159:	eb 15                	jmp    800170 <check_regs+0x13d>
  80015b:	83 ec 0c             	sub    $0xc,%esp
  80015e:	68 c8 23 80 00       	push   $0x8023c8
  800163:	e8 68 05 00 00       	call   8006d0 <cprintf>
  800168:	83 c4 10             	add    $0x10,%esp
  80016b:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800170:	ff 73 14             	pushl  0x14(%ebx)
  800173:	ff 76 14             	pushl  0x14(%esi)
  800176:	68 de 23 80 00       	push   $0x8023de
  80017b:	68 b4 23 80 00       	push   $0x8023b4
  800180:	e8 4b 05 00 00       	call   8006d0 <cprintf>
  800185:	83 c4 10             	add    $0x10,%esp
  800188:	8b 43 14             	mov    0x14(%ebx),%eax
  80018b:	39 46 14             	cmp    %eax,0x14(%esi)
  80018e:	75 12                	jne    8001a2 <check_regs+0x16f>
  800190:	83 ec 0c             	sub    $0xc,%esp
  800193:	68 c4 23 80 00       	push   $0x8023c4
  800198:	e8 33 05 00 00       	call   8006d0 <cprintf>
  80019d:	83 c4 10             	add    $0x10,%esp
  8001a0:	eb 15                	jmp    8001b7 <check_regs+0x184>
  8001a2:	83 ec 0c             	sub    $0xc,%esp
  8001a5:	68 c8 23 80 00       	push   $0x8023c8
  8001aa:	e8 21 05 00 00       	call   8006d0 <cprintf>
  8001af:	83 c4 10             	add    $0x10,%esp
  8001b2:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001b7:	ff 73 18             	pushl  0x18(%ebx)
  8001ba:	ff 76 18             	pushl  0x18(%esi)
  8001bd:	68 e2 23 80 00       	push   $0x8023e2
  8001c2:	68 b4 23 80 00       	push   $0x8023b4
  8001c7:	e8 04 05 00 00       	call   8006d0 <cprintf>
  8001cc:	83 c4 10             	add    $0x10,%esp
  8001cf:	8b 43 18             	mov    0x18(%ebx),%eax
  8001d2:	39 46 18             	cmp    %eax,0x18(%esi)
  8001d5:	75 12                	jne    8001e9 <check_regs+0x1b6>
  8001d7:	83 ec 0c             	sub    $0xc,%esp
  8001da:	68 c4 23 80 00       	push   $0x8023c4
  8001df:	e8 ec 04 00 00       	call   8006d0 <cprintf>
  8001e4:	83 c4 10             	add    $0x10,%esp
  8001e7:	eb 15                	jmp    8001fe <check_regs+0x1cb>
  8001e9:	83 ec 0c             	sub    $0xc,%esp
  8001ec:	68 c8 23 80 00       	push   $0x8023c8
  8001f1:	e8 da 04 00 00       	call   8006d0 <cprintf>
  8001f6:	83 c4 10             	add    $0x10,%esp
  8001f9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  8001fe:	ff 73 1c             	pushl  0x1c(%ebx)
  800201:	ff 76 1c             	pushl  0x1c(%esi)
  800204:	68 e6 23 80 00       	push   $0x8023e6
  800209:	68 b4 23 80 00       	push   $0x8023b4
  80020e:	e8 bd 04 00 00       	call   8006d0 <cprintf>
  800213:	83 c4 10             	add    $0x10,%esp
  800216:	8b 43 1c             	mov    0x1c(%ebx),%eax
  800219:	39 46 1c             	cmp    %eax,0x1c(%esi)
  80021c:	75 12                	jne    800230 <check_regs+0x1fd>
  80021e:	83 ec 0c             	sub    $0xc,%esp
  800221:	68 c4 23 80 00       	push   $0x8023c4
  800226:	e8 a5 04 00 00       	call   8006d0 <cprintf>
  80022b:	83 c4 10             	add    $0x10,%esp
  80022e:	eb 15                	jmp    800245 <check_regs+0x212>
  800230:	83 ec 0c             	sub    $0xc,%esp
  800233:	68 c8 23 80 00       	push   $0x8023c8
  800238:	e8 93 04 00 00       	call   8006d0 <cprintf>
  80023d:	83 c4 10             	add    $0x10,%esp
  800240:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  800245:	ff 73 20             	pushl  0x20(%ebx)
  800248:	ff 76 20             	pushl  0x20(%esi)
  80024b:	68 ea 23 80 00       	push   $0x8023ea
  800250:	68 b4 23 80 00       	push   $0x8023b4
  800255:	e8 76 04 00 00       	call   8006d0 <cprintf>
  80025a:	83 c4 10             	add    $0x10,%esp
  80025d:	8b 43 20             	mov    0x20(%ebx),%eax
  800260:	39 46 20             	cmp    %eax,0x20(%esi)
  800263:	75 12                	jne    800277 <check_regs+0x244>
  800265:	83 ec 0c             	sub    $0xc,%esp
  800268:	68 c4 23 80 00       	push   $0x8023c4
  80026d:	e8 5e 04 00 00       	call   8006d0 <cprintf>
  800272:	83 c4 10             	add    $0x10,%esp
  800275:	eb 15                	jmp    80028c <check_regs+0x259>
  800277:	83 ec 0c             	sub    $0xc,%esp
  80027a:	68 c8 23 80 00       	push   $0x8023c8
  80027f:	e8 4c 04 00 00       	call   8006d0 <cprintf>
  800284:	83 c4 10             	add    $0x10,%esp
  800287:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  80028c:	ff 73 24             	pushl  0x24(%ebx)
  80028f:	ff 76 24             	pushl  0x24(%esi)
  800292:	68 ee 23 80 00       	push   $0x8023ee
  800297:	68 b4 23 80 00       	push   $0x8023b4
  80029c:	e8 2f 04 00 00       	call   8006d0 <cprintf>
  8002a1:	83 c4 10             	add    $0x10,%esp
  8002a4:	8b 43 24             	mov    0x24(%ebx),%eax
  8002a7:	39 46 24             	cmp    %eax,0x24(%esi)
  8002aa:	75 2f                	jne    8002db <check_regs+0x2a8>
  8002ac:	83 ec 0c             	sub    $0xc,%esp
  8002af:	68 c4 23 80 00       	push   $0x8023c4
  8002b4:	e8 17 04 00 00       	call   8006d0 <cprintf>
	CHECK(esp, esp);
  8002b9:	ff 73 28             	pushl  0x28(%ebx)
  8002bc:	ff 76 28             	pushl  0x28(%esi)
  8002bf:	68 f5 23 80 00       	push   $0x8023f5
  8002c4:	68 b4 23 80 00       	push   $0x8023b4
  8002c9:	e8 02 04 00 00       	call   8006d0 <cprintf>
  8002ce:	83 c4 20             	add    $0x20,%esp
  8002d1:	8b 43 28             	mov    0x28(%ebx),%eax
  8002d4:	39 46 28             	cmp    %eax,0x28(%esi)
  8002d7:	74 31                	je     80030a <check_regs+0x2d7>
  8002d9:	eb 55                	jmp    800330 <check_regs+0x2fd>
	CHECK(ebx, regs.reg_ebx);
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
  8002db:	83 ec 0c             	sub    $0xc,%esp
  8002de:	68 c8 23 80 00       	push   $0x8023c8
  8002e3:	e8 e8 03 00 00       	call   8006d0 <cprintf>
	CHECK(esp, esp);
  8002e8:	ff 73 28             	pushl  0x28(%ebx)
  8002eb:	ff 76 28             	pushl  0x28(%esi)
  8002ee:	68 f5 23 80 00       	push   $0x8023f5
  8002f3:	68 b4 23 80 00       	push   $0x8023b4
  8002f8:	e8 d3 03 00 00       	call   8006d0 <cprintf>
  8002fd:	83 c4 20             	add    $0x20,%esp
  800300:	8b 43 28             	mov    0x28(%ebx),%eax
  800303:	39 46 28             	cmp    %eax,0x28(%esi)
  800306:	75 28                	jne    800330 <check_regs+0x2fd>
  800308:	eb 6c                	jmp    800376 <check_regs+0x343>
  80030a:	83 ec 0c             	sub    $0xc,%esp
  80030d:	68 c4 23 80 00       	push   $0x8023c4
  800312:	e8 b9 03 00 00       	call   8006d0 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800317:	83 c4 08             	add    $0x8,%esp
  80031a:	ff 75 0c             	pushl  0xc(%ebp)
  80031d:	68 f9 23 80 00       	push   $0x8023f9
  800322:	e8 a9 03 00 00       	call   8006d0 <cprintf>
	if (!mismatch)
  800327:	83 c4 10             	add    $0x10,%esp
  80032a:	85 ff                	test   %edi,%edi
  80032c:	74 24                	je     800352 <check_regs+0x31f>
  80032e:	eb 34                	jmp    800364 <check_regs+0x331>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  800330:	83 ec 0c             	sub    $0xc,%esp
  800333:	68 c8 23 80 00       	push   $0x8023c8
  800338:	e8 93 03 00 00       	call   8006d0 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  80033d:	83 c4 08             	add    $0x8,%esp
  800340:	ff 75 0c             	pushl  0xc(%ebp)
  800343:	68 f9 23 80 00       	push   $0x8023f9
  800348:	e8 83 03 00 00       	call   8006d0 <cprintf>
  80034d:	83 c4 10             	add    $0x10,%esp
  800350:	eb 12                	jmp    800364 <check_regs+0x331>
	if (!mismatch)
		cprintf("OK\n");
  800352:	83 ec 0c             	sub    $0xc,%esp
  800355:	68 c4 23 80 00       	push   $0x8023c4
  80035a:	e8 71 03 00 00       	call   8006d0 <cprintf>
  80035f:	83 c4 10             	add    $0x10,%esp
  800362:	eb 34                	jmp    800398 <check_regs+0x365>
	else
		cprintf("MISMATCH\n");
  800364:	83 ec 0c             	sub    $0xc,%esp
  800367:	68 c8 23 80 00       	push   $0x8023c8
  80036c:	e8 5f 03 00 00       	call   8006d0 <cprintf>
  800371:	83 c4 10             	add    $0x10,%esp
}
  800374:	eb 22                	jmp    800398 <check_regs+0x365>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  800376:	83 ec 0c             	sub    $0xc,%esp
  800379:	68 c4 23 80 00       	push   $0x8023c4
  80037e:	e8 4d 03 00 00       	call   8006d0 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800383:	83 c4 08             	add    $0x8,%esp
  800386:	ff 75 0c             	pushl  0xc(%ebp)
  800389:	68 f9 23 80 00       	push   $0x8023f9
  80038e:	e8 3d 03 00 00       	call   8006d0 <cprintf>
  800393:	83 c4 10             	add    $0x10,%esp
  800396:	eb cc                	jmp    800364 <check_regs+0x331>
	if (!mismatch)
		cprintf("OK\n");
	else
		cprintf("MISMATCH\n");
}
  800398:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80039b:	5b                   	pop    %ebx
  80039c:	5e                   	pop    %esi
  80039d:	5f                   	pop    %edi
  80039e:	5d                   	pop    %ebp
  80039f:	c3                   	ret    

008003a0 <pgfault>:

static void
pgfault(struct UTrapframe *utf)
{
  8003a0:	55                   	push   %ebp
  8003a1:	89 e5                	mov    %esp,%ebp
  8003a3:	83 ec 08             	sub    $0x8,%esp
  8003a6:	8b 45 08             	mov    0x8(%ebp),%eax
	int r;

	if (utf->utf_fault_va != (uint32_t)UTEMP)
  8003a9:	8b 10                	mov    (%eax),%edx
  8003ab:	81 fa 00 00 40 00    	cmp    $0x400000,%edx
  8003b1:	74 18                	je     8003cb <pgfault+0x2b>
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
  8003b3:	83 ec 0c             	sub    $0xc,%esp
  8003b6:	ff 70 28             	pushl  0x28(%eax)
  8003b9:	52                   	push   %edx
  8003ba:	68 60 24 80 00       	push   $0x802460
  8003bf:	6a 51                	push   $0x51
  8003c1:	68 07 24 80 00       	push   $0x802407
  8003c6:	e8 2c 02 00 00       	call   8005f7 <_panic>
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8003cb:	8b 50 08             	mov    0x8(%eax),%edx
  8003ce:	89 15 40 40 80 00    	mov    %edx,0x804040
  8003d4:	8b 50 0c             	mov    0xc(%eax),%edx
  8003d7:	89 15 44 40 80 00    	mov    %edx,0x804044
  8003dd:	8b 50 10             	mov    0x10(%eax),%edx
  8003e0:	89 15 48 40 80 00    	mov    %edx,0x804048
  8003e6:	8b 50 14             	mov    0x14(%eax),%edx
  8003e9:	89 15 4c 40 80 00    	mov    %edx,0x80404c
  8003ef:	8b 50 18             	mov    0x18(%eax),%edx
  8003f2:	89 15 50 40 80 00    	mov    %edx,0x804050
  8003f8:	8b 50 1c             	mov    0x1c(%eax),%edx
  8003fb:	89 15 54 40 80 00    	mov    %edx,0x804054
  800401:	8b 50 20             	mov    0x20(%eax),%edx
  800404:	89 15 58 40 80 00    	mov    %edx,0x804058
  80040a:	8b 50 24             	mov    0x24(%eax),%edx
  80040d:	89 15 5c 40 80 00    	mov    %edx,0x80405c
	during.eip = utf->utf_eip;
  800413:	8b 50 28             	mov    0x28(%eax),%edx
  800416:	89 15 60 40 80 00    	mov    %edx,0x804060
	during.eflags = utf->utf_eflags & ~FL_RF;
  80041c:	8b 50 2c             	mov    0x2c(%eax),%edx
  80041f:	81 e2 ff ff fe ff    	and    $0xfffeffff,%edx
  800425:	89 15 64 40 80 00    	mov    %edx,0x804064
	during.esp = utf->utf_esp;
  80042b:	8b 40 30             	mov    0x30(%eax),%eax
  80042e:	a3 68 40 80 00       	mov    %eax,0x804068
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  800433:	83 ec 08             	sub    $0x8,%esp
  800436:	68 1f 24 80 00       	push   $0x80241f
  80043b:	68 2d 24 80 00       	push   $0x80242d
  800440:	b9 40 40 80 00       	mov    $0x804040,%ecx
  800445:	ba 18 24 80 00       	mov    $0x802418,%edx
  80044a:	b8 80 40 80 00       	mov    $0x804080,%eax
  80044f:	e8 df fb ff ff       	call   800033 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800454:	83 c4 0c             	add    $0xc,%esp
  800457:	6a 07                	push   $0x7
  800459:	68 00 00 40 00       	push   $0x400000
  80045e:	6a 00                	push   $0x0
  800460:	e8 11 0c 00 00       	call   801076 <sys_page_alloc>
  800465:	83 c4 10             	add    $0x10,%esp
  800468:	85 c0                	test   %eax,%eax
  80046a:	79 12                	jns    80047e <pgfault+0xde>
		panic("sys_page_alloc: %e", r);
  80046c:	50                   	push   %eax
  80046d:	68 34 24 80 00       	push   $0x802434
  800472:	6a 5c                	push   $0x5c
  800474:	68 07 24 80 00       	push   $0x802407
  800479:	e8 79 01 00 00       	call   8005f7 <_panic>
}
  80047e:	c9                   	leave  
  80047f:	c3                   	ret    

00800480 <umain>:

void
umain(int argc, char **argv)
{
  800480:	55                   	push   %ebp
  800481:	89 e5                	mov    %esp,%ebp
  800483:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(pgfault);
  800486:	68 a0 03 80 00       	push   $0x8003a0
  80048b:	e8 d7 0d 00 00       	call   801267 <set_pgfault_handler>

	asm volatile(
  800490:	50                   	push   %eax
  800491:	9c                   	pushf  
  800492:	58                   	pop    %eax
  800493:	0d d5 08 00 00       	or     $0x8d5,%eax
  800498:	50                   	push   %eax
  800499:	9d                   	popf   
  80049a:	a3 a4 40 80 00       	mov    %eax,0x8040a4
  80049f:	8d 05 da 04 80 00    	lea    0x8004da,%eax
  8004a5:	a3 a0 40 80 00       	mov    %eax,0x8040a0
  8004aa:	58                   	pop    %eax
  8004ab:	89 3d 80 40 80 00    	mov    %edi,0x804080
  8004b1:	89 35 84 40 80 00    	mov    %esi,0x804084
  8004b7:	89 2d 88 40 80 00    	mov    %ebp,0x804088
  8004bd:	89 1d 90 40 80 00    	mov    %ebx,0x804090
  8004c3:	89 15 94 40 80 00    	mov    %edx,0x804094
  8004c9:	89 0d 98 40 80 00    	mov    %ecx,0x804098
  8004cf:	a3 9c 40 80 00       	mov    %eax,0x80409c
  8004d4:	89 25 a8 40 80 00    	mov    %esp,0x8040a8
  8004da:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  8004e1:	00 00 00 
  8004e4:	89 3d 00 40 80 00    	mov    %edi,0x804000
  8004ea:	89 35 04 40 80 00    	mov    %esi,0x804004
  8004f0:	89 2d 08 40 80 00    	mov    %ebp,0x804008
  8004f6:	89 1d 10 40 80 00    	mov    %ebx,0x804010
  8004fc:	89 15 14 40 80 00    	mov    %edx,0x804014
  800502:	89 0d 18 40 80 00    	mov    %ecx,0x804018
  800508:	a3 1c 40 80 00       	mov    %eax,0x80401c
  80050d:	89 25 28 40 80 00    	mov    %esp,0x804028
  800513:	8b 3d 80 40 80 00    	mov    0x804080,%edi
  800519:	8b 35 84 40 80 00    	mov    0x804084,%esi
  80051f:	8b 2d 88 40 80 00    	mov    0x804088,%ebp
  800525:	8b 1d 90 40 80 00    	mov    0x804090,%ebx
  80052b:	8b 15 94 40 80 00    	mov    0x804094,%edx
  800531:	8b 0d 98 40 80 00    	mov    0x804098,%ecx
  800537:	a1 9c 40 80 00       	mov    0x80409c,%eax
  80053c:	8b 25 a8 40 80 00    	mov    0x8040a8,%esp
  800542:	50                   	push   %eax
  800543:	9c                   	pushf  
  800544:	58                   	pop    %eax
  800545:	a3 24 40 80 00       	mov    %eax,0x804024
  80054a:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  80054b:	83 c4 10             	add    $0x10,%esp
  80054e:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  800555:	74 10                	je     800567 <umain+0xe7>
		cprintf("EIP after page-fault MISMATCH\n");
  800557:	83 ec 0c             	sub    $0xc,%esp
  80055a:	68 94 24 80 00       	push   $0x802494
  80055f:	e8 6c 01 00 00       	call   8006d0 <cprintf>
  800564:	83 c4 10             	add    $0x10,%esp
	after.eip = before.eip;
  800567:	a1 a0 40 80 00       	mov    0x8040a0,%eax
  80056c:	a3 20 40 80 00       	mov    %eax,0x804020

	check_regs(&before, "before", &after, "after", "after page-fault");
  800571:	83 ec 08             	sub    $0x8,%esp
  800574:	68 47 24 80 00       	push   $0x802447
  800579:	68 58 24 80 00       	push   $0x802458
  80057e:	b9 00 40 80 00       	mov    $0x804000,%ecx
  800583:	ba 18 24 80 00       	mov    $0x802418,%edx
  800588:	b8 80 40 80 00       	mov    $0x804080,%eax
  80058d:	e8 a1 fa ff ff       	call   800033 <check_regs>
}
  800592:	83 c4 10             	add    $0x10,%esp
  800595:	c9                   	leave  
  800596:	c3                   	ret    

00800597 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800597:	55                   	push   %ebp
  800598:	89 e5                	mov    %esp,%ebp
  80059a:	56                   	push   %esi
  80059b:	53                   	push   %ebx
  80059c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80059f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  8005a2:	e8 91 0a 00 00       	call   801038 <sys_getenvid>
  8005a7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8005ac:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8005af:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8005b4:	a3 b0 40 80 00       	mov    %eax,0x8040b0
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8005b9:	85 db                	test   %ebx,%ebx
  8005bb:	7e 07                	jle    8005c4 <libmain+0x2d>
		binaryname = argv[0];
  8005bd:	8b 06                	mov    (%esi),%eax
  8005bf:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8005c4:	83 ec 08             	sub    $0x8,%esp
  8005c7:	56                   	push   %esi
  8005c8:	53                   	push   %ebx
  8005c9:	e8 b2 fe ff ff       	call   800480 <umain>

	// exit gracefully
	exit();
  8005ce:	e8 0a 00 00 00       	call   8005dd <exit>
}
  8005d3:	83 c4 10             	add    $0x10,%esp
  8005d6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8005d9:	5b                   	pop    %ebx
  8005da:	5e                   	pop    %esi
  8005db:	5d                   	pop    %ebp
  8005dc:	c3                   	ret    

008005dd <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8005dd:	55                   	push   %ebp
  8005de:	89 e5                	mov    %esp,%ebp
  8005e0:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8005e3:	e8 d6 0e 00 00       	call   8014be <close_all>
	sys_env_destroy(0);
  8005e8:	83 ec 0c             	sub    $0xc,%esp
  8005eb:	6a 00                	push   $0x0
  8005ed:	e8 05 0a 00 00       	call   800ff7 <sys_env_destroy>
}
  8005f2:	83 c4 10             	add    $0x10,%esp
  8005f5:	c9                   	leave  
  8005f6:	c3                   	ret    

008005f7 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8005f7:	55                   	push   %ebp
  8005f8:	89 e5                	mov    %esp,%ebp
  8005fa:	56                   	push   %esi
  8005fb:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8005fc:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8005ff:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800605:	e8 2e 0a 00 00       	call   801038 <sys_getenvid>
  80060a:	83 ec 0c             	sub    $0xc,%esp
  80060d:	ff 75 0c             	pushl  0xc(%ebp)
  800610:	ff 75 08             	pushl  0x8(%ebp)
  800613:	56                   	push   %esi
  800614:	50                   	push   %eax
  800615:	68 c0 24 80 00       	push   $0x8024c0
  80061a:	e8 b1 00 00 00       	call   8006d0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80061f:	83 c4 18             	add    $0x18,%esp
  800622:	53                   	push   %ebx
  800623:	ff 75 10             	pushl  0x10(%ebp)
  800626:	e8 54 00 00 00       	call   80067f <vcprintf>
	cprintf("\n");
  80062b:	c7 04 24 d0 23 80 00 	movl   $0x8023d0,(%esp)
  800632:	e8 99 00 00 00       	call   8006d0 <cprintf>
  800637:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80063a:	cc                   	int3   
  80063b:	eb fd                	jmp    80063a <_panic+0x43>

0080063d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80063d:	55                   	push   %ebp
  80063e:	89 e5                	mov    %esp,%ebp
  800640:	53                   	push   %ebx
  800641:	83 ec 04             	sub    $0x4,%esp
  800644:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800647:	8b 13                	mov    (%ebx),%edx
  800649:	8d 42 01             	lea    0x1(%edx),%eax
  80064c:	89 03                	mov    %eax,(%ebx)
  80064e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800651:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800655:	3d ff 00 00 00       	cmp    $0xff,%eax
  80065a:	75 1a                	jne    800676 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80065c:	83 ec 08             	sub    $0x8,%esp
  80065f:	68 ff 00 00 00       	push   $0xff
  800664:	8d 43 08             	lea    0x8(%ebx),%eax
  800667:	50                   	push   %eax
  800668:	e8 4d 09 00 00       	call   800fba <sys_cputs>
		b->idx = 0;
  80066d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800673:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800676:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80067a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80067d:	c9                   	leave  
  80067e:	c3                   	ret    

0080067f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80067f:	55                   	push   %ebp
  800680:	89 e5                	mov    %esp,%ebp
  800682:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800688:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80068f:	00 00 00 
	b.cnt = 0;
  800692:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800699:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80069c:	ff 75 0c             	pushl  0xc(%ebp)
  80069f:	ff 75 08             	pushl  0x8(%ebp)
  8006a2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8006a8:	50                   	push   %eax
  8006a9:	68 3d 06 80 00       	push   $0x80063d
  8006ae:	e8 54 01 00 00       	call   800807 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006b3:	83 c4 08             	add    $0x8,%esp
  8006b6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8006bc:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8006c2:	50                   	push   %eax
  8006c3:	e8 f2 08 00 00       	call   800fba <sys_cputs>

	return b.cnt;
}
  8006c8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8006ce:	c9                   	leave  
  8006cf:	c3                   	ret    

008006d0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006d0:	55                   	push   %ebp
  8006d1:	89 e5                	mov    %esp,%ebp
  8006d3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8006d6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8006d9:	50                   	push   %eax
  8006da:	ff 75 08             	pushl  0x8(%ebp)
  8006dd:	e8 9d ff ff ff       	call   80067f <vcprintf>
	va_end(ap);

	return cnt;
}
  8006e2:	c9                   	leave  
  8006e3:	c3                   	ret    

008006e4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8006e4:	55                   	push   %ebp
  8006e5:	89 e5                	mov    %esp,%ebp
  8006e7:	57                   	push   %edi
  8006e8:	56                   	push   %esi
  8006e9:	53                   	push   %ebx
  8006ea:	83 ec 1c             	sub    $0x1c,%esp
  8006ed:	89 c7                	mov    %eax,%edi
  8006ef:	89 d6                	mov    %edx,%esi
  8006f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006f7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006fa:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8006fd:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800700:	bb 00 00 00 00       	mov    $0x0,%ebx
  800705:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800708:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80070b:	39 d3                	cmp    %edx,%ebx
  80070d:	72 05                	jb     800714 <printnum+0x30>
  80070f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800712:	77 45                	ja     800759 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800714:	83 ec 0c             	sub    $0xc,%esp
  800717:	ff 75 18             	pushl  0x18(%ebp)
  80071a:	8b 45 14             	mov    0x14(%ebp),%eax
  80071d:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800720:	53                   	push   %ebx
  800721:	ff 75 10             	pushl  0x10(%ebp)
  800724:	83 ec 08             	sub    $0x8,%esp
  800727:	ff 75 e4             	pushl  -0x1c(%ebp)
  80072a:	ff 75 e0             	pushl  -0x20(%ebp)
  80072d:	ff 75 dc             	pushl  -0x24(%ebp)
  800730:	ff 75 d8             	pushl  -0x28(%ebp)
  800733:	e8 c8 19 00 00       	call   802100 <__udivdi3>
  800738:	83 c4 18             	add    $0x18,%esp
  80073b:	52                   	push   %edx
  80073c:	50                   	push   %eax
  80073d:	89 f2                	mov    %esi,%edx
  80073f:	89 f8                	mov    %edi,%eax
  800741:	e8 9e ff ff ff       	call   8006e4 <printnum>
  800746:	83 c4 20             	add    $0x20,%esp
  800749:	eb 18                	jmp    800763 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80074b:	83 ec 08             	sub    $0x8,%esp
  80074e:	56                   	push   %esi
  80074f:	ff 75 18             	pushl  0x18(%ebp)
  800752:	ff d7                	call   *%edi
  800754:	83 c4 10             	add    $0x10,%esp
  800757:	eb 03                	jmp    80075c <printnum+0x78>
  800759:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80075c:	83 eb 01             	sub    $0x1,%ebx
  80075f:	85 db                	test   %ebx,%ebx
  800761:	7f e8                	jg     80074b <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800763:	83 ec 08             	sub    $0x8,%esp
  800766:	56                   	push   %esi
  800767:	83 ec 04             	sub    $0x4,%esp
  80076a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80076d:	ff 75 e0             	pushl  -0x20(%ebp)
  800770:	ff 75 dc             	pushl  -0x24(%ebp)
  800773:	ff 75 d8             	pushl  -0x28(%ebp)
  800776:	e8 b5 1a 00 00       	call   802230 <__umoddi3>
  80077b:	83 c4 14             	add    $0x14,%esp
  80077e:	0f be 80 e3 24 80 00 	movsbl 0x8024e3(%eax),%eax
  800785:	50                   	push   %eax
  800786:	ff d7                	call   *%edi
}
  800788:	83 c4 10             	add    $0x10,%esp
  80078b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80078e:	5b                   	pop    %ebx
  80078f:	5e                   	pop    %esi
  800790:	5f                   	pop    %edi
  800791:	5d                   	pop    %ebp
  800792:	c3                   	ret    

00800793 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800793:	55                   	push   %ebp
  800794:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800796:	83 fa 01             	cmp    $0x1,%edx
  800799:	7e 0e                	jle    8007a9 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80079b:	8b 10                	mov    (%eax),%edx
  80079d:	8d 4a 08             	lea    0x8(%edx),%ecx
  8007a0:	89 08                	mov    %ecx,(%eax)
  8007a2:	8b 02                	mov    (%edx),%eax
  8007a4:	8b 52 04             	mov    0x4(%edx),%edx
  8007a7:	eb 22                	jmp    8007cb <getuint+0x38>
	else if (lflag)
  8007a9:	85 d2                	test   %edx,%edx
  8007ab:	74 10                	je     8007bd <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8007ad:	8b 10                	mov    (%eax),%edx
  8007af:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007b2:	89 08                	mov    %ecx,(%eax)
  8007b4:	8b 02                	mov    (%edx),%eax
  8007b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8007bb:	eb 0e                	jmp    8007cb <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8007bd:	8b 10                	mov    (%eax),%edx
  8007bf:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007c2:	89 08                	mov    %ecx,(%eax)
  8007c4:	8b 02                	mov    (%edx),%eax
  8007c6:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8007cb:	5d                   	pop    %ebp
  8007cc:	c3                   	ret    

008007cd <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007cd:	55                   	push   %ebp
  8007ce:	89 e5                	mov    %esp,%ebp
  8007d0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8007d3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8007d7:	8b 10                	mov    (%eax),%edx
  8007d9:	3b 50 04             	cmp    0x4(%eax),%edx
  8007dc:	73 0a                	jae    8007e8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8007de:	8d 4a 01             	lea    0x1(%edx),%ecx
  8007e1:	89 08                	mov    %ecx,(%eax)
  8007e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e6:	88 02                	mov    %al,(%edx)
}
  8007e8:	5d                   	pop    %ebp
  8007e9:	c3                   	ret    

008007ea <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007ea:	55                   	push   %ebp
  8007eb:	89 e5                	mov    %esp,%ebp
  8007ed:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8007f0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8007f3:	50                   	push   %eax
  8007f4:	ff 75 10             	pushl  0x10(%ebp)
  8007f7:	ff 75 0c             	pushl  0xc(%ebp)
  8007fa:	ff 75 08             	pushl  0x8(%ebp)
  8007fd:	e8 05 00 00 00       	call   800807 <vprintfmt>
	va_end(ap);
}
  800802:	83 c4 10             	add    $0x10,%esp
  800805:	c9                   	leave  
  800806:	c3                   	ret    

00800807 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800807:	55                   	push   %ebp
  800808:	89 e5                	mov    %esp,%ebp
  80080a:	57                   	push   %edi
  80080b:	56                   	push   %esi
  80080c:	53                   	push   %ebx
  80080d:	83 ec 2c             	sub    $0x2c,%esp
  800810:	8b 75 08             	mov    0x8(%ebp),%esi
  800813:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800816:	8b 7d 10             	mov    0x10(%ebp),%edi
  800819:	eb 12                	jmp    80082d <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80081b:	85 c0                	test   %eax,%eax
  80081d:	0f 84 a7 03 00 00    	je     800bca <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
  800823:	83 ec 08             	sub    $0x8,%esp
  800826:	53                   	push   %ebx
  800827:	50                   	push   %eax
  800828:	ff d6                	call   *%esi
  80082a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80082d:	83 c7 01             	add    $0x1,%edi
  800830:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800834:	83 f8 25             	cmp    $0x25,%eax
  800837:	75 e2                	jne    80081b <vprintfmt+0x14>
  800839:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80083d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800844:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80084b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800852:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800859:	b9 00 00 00 00       	mov    $0x0,%ecx
  80085e:	eb 07                	jmp    800867 <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800860:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800863:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800867:	8d 47 01             	lea    0x1(%edi),%eax
  80086a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80086d:	0f b6 07             	movzbl (%edi),%eax
  800870:	0f b6 d0             	movzbl %al,%edx
  800873:	83 e8 23             	sub    $0x23,%eax
  800876:	3c 55                	cmp    $0x55,%al
  800878:	0f 87 31 03 00 00    	ja     800baf <vprintfmt+0x3a8>
  80087e:	0f b6 c0             	movzbl %al,%eax
  800881:	ff 24 85 20 26 80 00 	jmp    *0x802620(,%eax,4)
  800888:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80088b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80088f:	eb d6                	jmp    800867 <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800891:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800894:	b8 00 00 00 00       	mov    $0x0,%eax
  800899:	89 75 08             	mov    %esi,0x8(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80089c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80089f:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8008a3:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8008a6:	8d 72 d0             	lea    -0x30(%edx),%esi
  8008a9:	83 fe 09             	cmp    $0x9,%esi
  8008ac:	77 34                	ja     8008e2 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8008ae:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8008b1:	eb e9                	jmp    80089c <vprintfmt+0x95>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8008b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b6:	8d 50 04             	lea    0x4(%eax),%edx
  8008b9:	89 55 14             	mov    %edx,0x14(%ebp)
  8008bc:	8b 00                	mov    (%eax),%eax
  8008be:	89 45 cc             	mov    %eax,-0x34(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8008c4:	eb 22                	jmp    8008e8 <vprintfmt+0xe1>
  8008c6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008c9:	85 c0                	test   %eax,%eax
  8008cb:	0f 48 c1             	cmovs  %ecx,%eax
  8008ce:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008d4:	eb 91                	jmp    800867 <vprintfmt+0x60>
  8008d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8008d9:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8008e0:	eb 85                	jmp    800867 <vprintfmt+0x60>
  8008e2:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8008e5:	8b 75 08             	mov    0x8(%ebp),%esi

		process_precision:
			if (width < 0)
  8008e8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8008ec:	0f 89 75 ff ff ff    	jns    800867 <vprintfmt+0x60>
				width = precision, precision = -1;
  8008f2:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8008f5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008f8:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8008ff:	e9 63 ff ff ff       	jmp    800867 <vprintfmt+0x60>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800904:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800908:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80090b:	e9 57 ff ff ff       	jmp    800867 <vprintfmt+0x60>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800910:	8b 45 14             	mov    0x14(%ebp),%eax
  800913:	8d 50 04             	lea    0x4(%eax),%edx
  800916:	89 55 14             	mov    %edx,0x14(%ebp)
  800919:	83 ec 08             	sub    $0x8,%esp
  80091c:	53                   	push   %ebx
  80091d:	ff 30                	pushl  (%eax)
  80091f:	ff d6                	call   *%esi
			break;
  800921:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800924:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800927:	e9 01 ff ff ff       	jmp    80082d <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80092c:	8b 45 14             	mov    0x14(%ebp),%eax
  80092f:	8d 50 04             	lea    0x4(%eax),%edx
  800932:	89 55 14             	mov    %edx,0x14(%ebp)
  800935:	8b 00                	mov    (%eax),%eax
  800937:	99                   	cltd   
  800938:	31 d0                	xor    %edx,%eax
  80093a:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80093c:	83 f8 0f             	cmp    $0xf,%eax
  80093f:	7f 0b                	jg     80094c <vprintfmt+0x145>
  800941:	8b 14 85 80 27 80 00 	mov    0x802780(,%eax,4),%edx
  800948:	85 d2                	test   %edx,%edx
  80094a:	75 18                	jne    800964 <vprintfmt+0x15d>
				printfmt(putch, putdat, "error %d", err);
  80094c:	50                   	push   %eax
  80094d:	68 fb 24 80 00       	push   $0x8024fb
  800952:	53                   	push   %ebx
  800953:	56                   	push   %esi
  800954:	e8 91 fe ff ff       	call   8007ea <printfmt>
  800959:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80095c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80095f:	e9 c9 fe ff ff       	jmp    80082d <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800964:	52                   	push   %edx
  800965:	68 ed 28 80 00       	push   $0x8028ed
  80096a:	53                   	push   %ebx
  80096b:	56                   	push   %esi
  80096c:	e8 79 fe ff ff       	call   8007ea <printfmt>
  800971:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800974:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800977:	e9 b1 fe ff ff       	jmp    80082d <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80097c:	8b 45 14             	mov    0x14(%ebp),%eax
  80097f:	8d 50 04             	lea    0x4(%eax),%edx
  800982:	89 55 14             	mov    %edx,0x14(%ebp)
  800985:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800987:	85 ff                	test   %edi,%edi
  800989:	b8 f4 24 80 00       	mov    $0x8024f4,%eax
  80098e:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800991:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800995:	0f 8e 94 00 00 00    	jle    800a2f <vprintfmt+0x228>
  80099b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80099f:	0f 84 98 00 00 00    	je     800a3d <vprintfmt+0x236>
				for (width -= strnlen(p, precision); width > 0; width--)
  8009a5:	83 ec 08             	sub    $0x8,%esp
  8009a8:	ff 75 cc             	pushl  -0x34(%ebp)
  8009ab:	57                   	push   %edi
  8009ac:	e8 a1 02 00 00       	call   800c52 <strnlen>
  8009b1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8009b4:	29 c1                	sub    %eax,%ecx
  8009b6:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8009b9:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8009bc:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8009c0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8009c3:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8009c6:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009c8:	eb 0f                	jmp    8009d9 <vprintfmt+0x1d2>
					putch(padc, putdat);
  8009ca:	83 ec 08             	sub    $0x8,%esp
  8009cd:	53                   	push   %ebx
  8009ce:	ff 75 e0             	pushl  -0x20(%ebp)
  8009d1:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009d3:	83 ef 01             	sub    $0x1,%edi
  8009d6:	83 c4 10             	add    $0x10,%esp
  8009d9:	85 ff                	test   %edi,%edi
  8009db:	7f ed                	jg     8009ca <vprintfmt+0x1c3>
  8009dd:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8009e0:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8009e3:	85 c9                	test   %ecx,%ecx
  8009e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ea:	0f 49 c1             	cmovns %ecx,%eax
  8009ed:	29 c1                	sub    %eax,%ecx
  8009ef:	89 75 08             	mov    %esi,0x8(%ebp)
  8009f2:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8009f5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8009f8:	89 cb                	mov    %ecx,%ebx
  8009fa:	eb 4d                	jmp    800a49 <vprintfmt+0x242>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8009fc:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800a00:	74 1b                	je     800a1d <vprintfmt+0x216>
  800a02:	0f be c0             	movsbl %al,%eax
  800a05:	83 e8 20             	sub    $0x20,%eax
  800a08:	83 f8 5e             	cmp    $0x5e,%eax
  800a0b:	76 10                	jbe    800a1d <vprintfmt+0x216>
					putch('?', putdat);
  800a0d:	83 ec 08             	sub    $0x8,%esp
  800a10:	ff 75 0c             	pushl  0xc(%ebp)
  800a13:	6a 3f                	push   $0x3f
  800a15:	ff 55 08             	call   *0x8(%ebp)
  800a18:	83 c4 10             	add    $0x10,%esp
  800a1b:	eb 0d                	jmp    800a2a <vprintfmt+0x223>
				else
					putch(ch, putdat);
  800a1d:	83 ec 08             	sub    $0x8,%esp
  800a20:	ff 75 0c             	pushl  0xc(%ebp)
  800a23:	52                   	push   %edx
  800a24:	ff 55 08             	call   *0x8(%ebp)
  800a27:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a2a:	83 eb 01             	sub    $0x1,%ebx
  800a2d:	eb 1a                	jmp    800a49 <vprintfmt+0x242>
  800a2f:	89 75 08             	mov    %esi,0x8(%ebp)
  800a32:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800a35:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a38:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a3b:	eb 0c                	jmp    800a49 <vprintfmt+0x242>
  800a3d:	89 75 08             	mov    %esi,0x8(%ebp)
  800a40:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800a43:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a46:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a49:	83 c7 01             	add    $0x1,%edi
  800a4c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800a50:	0f be d0             	movsbl %al,%edx
  800a53:	85 d2                	test   %edx,%edx
  800a55:	74 23                	je     800a7a <vprintfmt+0x273>
  800a57:	85 f6                	test   %esi,%esi
  800a59:	78 a1                	js     8009fc <vprintfmt+0x1f5>
  800a5b:	83 ee 01             	sub    $0x1,%esi
  800a5e:	79 9c                	jns    8009fc <vprintfmt+0x1f5>
  800a60:	89 df                	mov    %ebx,%edi
  800a62:	8b 75 08             	mov    0x8(%ebp),%esi
  800a65:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a68:	eb 18                	jmp    800a82 <vprintfmt+0x27b>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a6a:	83 ec 08             	sub    $0x8,%esp
  800a6d:	53                   	push   %ebx
  800a6e:	6a 20                	push   $0x20
  800a70:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a72:	83 ef 01             	sub    $0x1,%edi
  800a75:	83 c4 10             	add    $0x10,%esp
  800a78:	eb 08                	jmp    800a82 <vprintfmt+0x27b>
  800a7a:	89 df                	mov    %ebx,%edi
  800a7c:	8b 75 08             	mov    0x8(%ebp),%esi
  800a7f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a82:	85 ff                	test   %edi,%edi
  800a84:	7f e4                	jg     800a6a <vprintfmt+0x263>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a86:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a89:	e9 9f fd ff ff       	jmp    80082d <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a8e:	83 7d d0 01          	cmpl   $0x1,-0x30(%ebp)
  800a92:	7e 16                	jle    800aaa <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  800a94:	8b 45 14             	mov    0x14(%ebp),%eax
  800a97:	8d 50 08             	lea    0x8(%eax),%edx
  800a9a:	89 55 14             	mov    %edx,0x14(%ebp)
  800a9d:	8b 50 04             	mov    0x4(%eax),%edx
  800aa0:	8b 00                	mov    (%eax),%eax
  800aa2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800aa5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800aa8:	eb 34                	jmp    800ade <vprintfmt+0x2d7>
	else if (lflag)
  800aaa:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800aae:	74 18                	je     800ac8 <vprintfmt+0x2c1>
		return va_arg(*ap, long);
  800ab0:	8b 45 14             	mov    0x14(%ebp),%eax
  800ab3:	8d 50 04             	lea    0x4(%eax),%edx
  800ab6:	89 55 14             	mov    %edx,0x14(%ebp)
  800ab9:	8b 00                	mov    (%eax),%eax
  800abb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800abe:	89 c1                	mov    %eax,%ecx
  800ac0:	c1 f9 1f             	sar    $0x1f,%ecx
  800ac3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800ac6:	eb 16                	jmp    800ade <vprintfmt+0x2d7>
	else
		return va_arg(*ap, int);
  800ac8:	8b 45 14             	mov    0x14(%ebp),%eax
  800acb:	8d 50 04             	lea    0x4(%eax),%edx
  800ace:	89 55 14             	mov    %edx,0x14(%ebp)
  800ad1:	8b 00                	mov    (%eax),%eax
  800ad3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ad6:	89 c1                	mov    %eax,%ecx
  800ad8:	c1 f9 1f             	sar    $0x1f,%ecx
  800adb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800ade:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800ae1:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800ae4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800ae9:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800aed:	0f 89 88 00 00 00    	jns    800b7b <vprintfmt+0x374>
				putch('-', putdat);
  800af3:	83 ec 08             	sub    $0x8,%esp
  800af6:	53                   	push   %ebx
  800af7:	6a 2d                	push   $0x2d
  800af9:	ff d6                	call   *%esi
				num = -(long long) num;
  800afb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800afe:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800b01:	f7 d8                	neg    %eax
  800b03:	83 d2 00             	adc    $0x0,%edx
  800b06:	f7 da                	neg    %edx
  800b08:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800b0b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800b10:	eb 69                	jmp    800b7b <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800b12:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800b15:	8d 45 14             	lea    0x14(%ebp),%eax
  800b18:	e8 76 fc ff ff       	call   800793 <getuint>
			base = 10;
  800b1d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800b22:	eb 57                	jmp    800b7b <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  800b24:	83 ec 08             	sub    $0x8,%esp
  800b27:	53                   	push   %ebx
  800b28:	6a 30                	push   $0x30
  800b2a:	ff d6                	call   *%esi
			num = getuint(&ap, lflag);
  800b2c:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800b2f:	8d 45 14             	lea    0x14(%ebp),%eax
  800b32:	e8 5c fc ff ff       	call   800793 <getuint>
			base = 8;
			goto number;
  800b37:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800b3a:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800b3f:	eb 3a                	jmp    800b7b <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  800b41:	83 ec 08             	sub    $0x8,%esp
  800b44:	53                   	push   %ebx
  800b45:	6a 30                	push   $0x30
  800b47:	ff d6                	call   *%esi
			putch('x', putdat);
  800b49:	83 c4 08             	add    $0x8,%esp
  800b4c:	53                   	push   %ebx
  800b4d:	6a 78                	push   $0x78
  800b4f:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800b51:	8b 45 14             	mov    0x14(%ebp),%eax
  800b54:	8d 50 04             	lea    0x4(%eax),%edx
  800b57:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800b5a:	8b 00                	mov    (%eax),%eax
  800b5c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800b61:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800b64:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800b69:	eb 10                	jmp    800b7b <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800b6b:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800b6e:	8d 45 14             	lea    0x14(%ebp),%eax
  800b71:	e8 1d fc ff ff       	call   800793 <getuint>
			base = 16;
  800b76:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800b7b:	83 ec 0c             	sub    $0xc,%esp
  800b7e:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800b82:	57                   	push   %edi
  800b83:	ff 75 e0             	pushl  -0x20(%ebp)
  800b86:	51                   	push   %ecx
  800b87:	52                   	push   %edx
  800b88:	50                   	push   %eax
  800b89:	89 da                	mov    %ebx,%edx
  800b8b:	89 f0                	mov    %esi,%eax
  800b8d:	e8 52 fb ff ff       	call   8006e4 <printnum>
			break;
  800b92:	83 c4 20             	add    $0x20,%esp
  800b95:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800b98:	e9 90 fc ff ff       	jmp    80082d <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800b9d:	83 ec 08             	sub    $0x8,%esp
  800ba0:	53                   	push   %ebx
  800ba1:	52                   	push   %edx
  800ba2:	ff d6                	call   *%esi
			break;
  800ba4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ba7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800baa:	e9 7e fc ff ff       	jmp    80082d <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800baf:	83 ec 08             	sub    $0x8,%esp
  800bb2:	53                   	push   %ebx
  800bb3:	6a 25                	push   $0x25
  800bb5:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800bb7:	83 c4 10             	add    $0x10,%esp
  800bba:	eb 03                	jmp    800bbf <vprintfmt+0x3b8>
  800bbc:	83 ef 01             	sub    $0x1,%edi
  800bbf:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800bc3:	75 f7                	jne    800bbc <vprintfmt+0x3b5>
  800bc5:	e9 63 fc ff ff       	jmp    80082d <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800bca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bcd:	5b                   	pop    %ebx
  800bce:	5e                   	pop    %esi
  800bcf:	5f                   	pop    %edi
  800bd0:	5d                   	pop    %ebp
  800bd1:	c3                   	ret    

00800bd2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800bd2:	55                   	push   %ebp
  800bd3:	89 e5                	mov    %esp,%ebp
  800bd5:	83 ec 18             	sub    $0x18,%esp
  800bd8:	8b 45 08             	mov    0x8(%ebp),%eax
  800bdb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800bde:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800be1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800be5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800be8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800bef:	85 c0                	test   %eax,%eax
  800bf1:	74 26                	je     800c19 <vsnprintf+0x47>
  800bf3:	85 d2                	test   %edx,%edx
  800bf5:	7e 22                	jle    800c19 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800bf7:	ff 75 14             	pushl  0x14(%ebp)
  800bfa:	ff 75 10             	pushl  0x10(%ebp)
  800bfd:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c00:	50                   	push   %eax
  800c01:	68 cd 07 80 00       	push   $0x8007cd
  800c06:	e8 fc fb ff ff       	call   800807 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c0b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c0e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c11:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c14:	83 c4 10             	add    $0x10,%esp
  800c17:	eb 05                	jmp    800c1e <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800c19:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800c1e:	c9                   	leave  
  800c1f:	c3                   	ret    

00800c20 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c20:	55                   	push   %ebp
  800c21:	89 e5                	mov    %esp,%ebp
  800c23:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c26:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c29:	50                   	push   %eax
  800c2a:	ff 75 10             	pushl  0x10(%ebp)
  800c2d:	ff 75 0c             	pushl  0xc(%ebp)
  800c30:	ff 75 08             	pushl  0x8(%ebp)
  800c33:	e8 9a ff ff ff       	call   800bd2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800c38:	c9                   	leave  
  800c39:	c3                   	ret    

00800c3a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c3a:	55                   	push   %ebp
  800c3b:	89 e5                	mov    %esp,%ebp
  800c3d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c40:	b8 00 00 00 00       	mov    $0x0,%eax
  800c45:	eb 03                	jmp    800c4a <strlen+0x10>
		n++;
  800c47:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c4a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800c4e:	75 f7                	jne    800c47 <strlen+0xd>
		n++;
	return n;
}
  800c50:	5d                   	pop    %ebp
  800c51:	c3                   	ret    

00800c52 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c52:	55                   	push   %ebp
  800c53:	89 e5                	mov    %esp,%ebp
  800c55:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c58:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c5b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c60:	eb 03                	jmp    800c65 <strnlen+0x13>
		n++;
  800c62:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c65:	39 c2                	cmp    %eax,%edx
  800c67:	74 08                	je     800c71 <strnlen+0x1f>
  800c69:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800c6d:	75 f3                	jne    800c62 <strnlen+0x10>
  800c6f:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800c71:	5d                   	pop    %ebp
  800c72:	c3                   	ret    

00800c73 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c73:	55                   	push   %ebp
  800c74:	89 e5                	mov    %esp,%ebp
  800c76:	53                   	push   %ebx
  800c77:	8b 45 08             	mov    0x8(%ebp),%eax
  800c7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800c7d:	89 c2                	mov    %eax,%edx
  800c7f:	83 c2 01             	add    $0x1,%edx
  800c82:	83 c1 01             	add    $0x1,%ecx
  800c85:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800c89:	88 5a ff             	mov    %bl,-0x1(%edx)
  800c8c:	84 db                	test   %bl,%bl
  800c8e:	75 ef                	jne    800c7f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800c90:	5b                   	pop    %ebx
  800c91:	5d                   	pop    %ebp
  800c92:	c3                   	ret    

00800c93 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c93:	55                   	push   %ebp
  800c94:	89 e5                	mov    %esp,%ebp
  800c96:	53                   	push   %ebx
  800c97:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800c9a:	53                   	push   %ebx
  800c9b:	e8 9a ff ff ff       	call   800c3a <strlen>
  800ca0:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800ca3:	ff 75 0c             	pushl  0xc(%ebp)
  800ca6:	01 d8                	add    %ebx,%eax
  800ca8:	50                   	push   %eax
  800ca9:	e8 c5 ff ff ff       	call   800c73 <strcpy>
	return dst;
}
  800cae:	89 d8                	mov    %ebx,%eax
  800cb0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800cb3:	c9                   	leave  
  800cb4:	c3                   	ret    

00800cb5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800cb5:	55                   	push   %ebp
  800cb6:	89 e5                	mov    %esp,%ebp
  800cb8:	56                   	push   %esi
  800cb9:	53                   	push   %ebx
  800cba:	8b 75 08             	mov    0x8(%ebp),%esi
  800cbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc0:	89 f3                	mov    %esi,%ebx
  800cc2:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800cc5:	89 f2                	mov    %esi,%edx
  800cc7:	eb 0f                	jmp    800cd8 <strncpy+0x23>
		*dst++ = *src;
  800cc9:	83 c2 01             	add    $0x1,%edx
  800ccc:	0f b6 01             	movzbl (%ecx),%eax
  800ccf:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800cd2:	80 39 01             	cmpb   $0x1,(%ecx)
  800cd5:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800cd8:	39 da                	cmp    %ebx,%edx
  800cda:	75 ed                	jne    800cc9 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800cdc:	89 f0                	mov    %esi,%eax
  800cde:	5b                   	pop    %ebx
  800cdf:	5e                   	pop    %esi
  800ce0:	5d                   	pop    %ebp
  800ce1:	c3                   	ret    

00800ce2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ce2:	55                   	push   %ebp
  800ce3:	89 e5                	mov    %esp,%ebp
  800ce5:	56                   	push   %esi
  800ce6:	53                   	push   %ebx
  800ce7:	8b 75 08             	mov    0x8(%ebp),%esi
  800cea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ced:	8b 55 10             	mov    0x10(%ebp),%edx
  800cf0:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800cf2:	85 d2                	test   %edx,%edx
  800cf4:	74 21                	je     800d17 <strlcpy+0x35>
  800cf6:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800cfa:	89 f2                	mov    %esi,%edx
  800cfc:	eb 09                	jmp    800d07 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800cfe:	83 c2 01             	add    $0x1,%edx
  800d01:	83 c1 01             	add    $0x1,%ecx
  800d04:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d07:	39 c2                	cmp    %eax,%edx
  800d09:	74 09                	je     800d14 <strlcpy+0x32>
  800d0b:	0f b6 19             	movzbl (%ecx),%ebx
  800d0e:	84 db                	test   %bl,%bl
  800d10:	75 ec                	jne    800cfe <strlcpy+0x1c>
  800d12:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800d14:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d17:	29 f0                	sub    %esi,%eax
}
  800d19:	5b                   	pop    %ebx
  800d1a:	5e                   	pop    %esi
  800d1b:	5d                   	pop    %ebp
  800d1c:	c3                   	ret    

00800d1d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d1d:	55                   	push   %ebp
  800d1e:	89 e5                	mov    %esp,%ebp
  800d20:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d23:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800d26:	eb 06                	jmp    800d2e <strcmp+0x11>
		p++, q++;
  800d28:	83 c1 01             	add    $0x1,%ecx
  800d2b:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d2e:	0f b6 01             	movzbl (%ecx),%eax
  800d31:	84 c0                	test   %al,%al
  800d33:	74 04                	je     800d39 <strcmp+0x1c>
  800d35:	3a 02                	cmp    (%edx),%al
  800d37:	74 ef                	je     800d28 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d39:	0f b6 c0             	movzbl %al,%eax
  800d3c:	0f b6 12             	movzbl (%edx),%edx
  800d3f:	29 d0                	sub    %edx,%eax
}
  800d41:	5d                   	pop    %ebp
  800d42:	c3                   	ret    

00800d43 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d43:	55                   	push   %ebp
  800d44:	89 e5                	mov    %esp,%ebp
  800d46:	53                   	push   %ebx
  800d47:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d4d:	89 c3                	mov    %eax,%ebx
  800d4f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800d52:	eb 06                	jmp    800d5a <strncmp+0x17>
		n--, p++, q++;
  800d54:	83 c0 01             	add    $0x1,%eax
  800d57:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d5a:	39 d8                	cmp    %ebx,%eax
  800d5c:	74 15                	je     800d73 <strncmp+0x30>
  800d5e:	0f b6 08             	movzbl (%eax),%ecx
  800d61:	84 c9                	test   %cl,%cl
  800d63:	74 04                	je     800d69 <strncmp+0x26>
  800d65:	3a 0a                	cmp    (%edx),%cl
  800d67:	74 eb                	je     800d54 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d69:	0f b6 00             	movzbl (%eax),%eax
  800d6c:	0f b6 12             	movzbl (%edx),%edx
  800d6f:	29 d0                	sub    %edx,%eax
  800d71:	eb 05                	jmp    800d78 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800d73:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800d78:	5b                   	pop    %ebx
  800d79:	5d                   	pop    %ebp
  800d7a:	c3                   	ret    

00800d7b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d7b:	55                   	push   %ebp
  800d7c:	89 e5                	mov    %esp,%ebp
  800d7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d81:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d85:	eb 07                	jmp    800d8e <strchr+0x13>
		if (*s == c)
  800d87:	38 ca                	cmp    %cl,%dl
  800d89:	74 0f                	je     800d9a <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d8b:	83 c0 01             	add    $0x1,%eax
  800d8e:	0f b6 10             	movzbl (%eax),%edx
  800d91:	84 d2                	test   %dl,%dl
  800d93:	75 f2                	jne    800d87 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800d95:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d9a:	5d                   	pop    %ebp
  800d9b:	c3                   	ret    

00800d9c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d9c:	55                   	push   %ebp
  800d9d:	89 e5                	mov    %esp,%ebp
  800d9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800da2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800da6:	eb 03                	jmp    800dab <strfind+0xf>
  800da8:	83 c0 01             	add    $0x1,%eax
  800dab:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800dae:	38 ca                	cmp    %cl,%dl
  800db0:	74 04                	je     800db6 <strfind+0x1a>
  800db2:	84 d2                	test   %dl,%dl
  800db4:	75 f2                	jne    800da8 <strfind+0xc>
			break;
	return (char *) s;
}
  800db6:	5d                   	pop    %ebp
  800db7:	c3                   	ret    

00800db8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800db8:	55                   	push   %ebp
  800db9:	89 e5                	mov    %esp,%ebp
  800dbb:	57                   	push   %edi
  800dbc:	56                   	push   %esi
  800dbd:	53                   	push   %ebx
  800dbe:	8b 7d 08             	mov    0x8(%ebp),%edi
  800dc1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800dc4:	85 c9                	test   %ecx,%ecx
  800dc6:	74 36                	je     800dfe <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800dc8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800dce:	75 28                	jne    800df8 <memset+0x40>
  800dd0:	f6 c1 03             	test   $0x3,%cl
  800dd3:	75 23                	jne    800df8 <memset+0x40>
		c &= 0xFF;
  800dd5:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800dd9:	89 d3                	mov    %edx,%ebx
  800ddb:	c1 e3 08             	shl    $0x8,%ebx
  800dde:	89 d6                	mov    %edx,%esi
  800de0:	c1 e6 18             	shl    $0x18,%esi
  800de3:	89 d0                	mov    %edx,%eax
  800de5:	c1 e0 10             	shl    $0x10,%eax
  800de8:	09 f0                	or     %esi,%eax
  800dea:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800dec:	89 d8                	mov    %ebx,%eax
  800dee:	09 d0                	or     %edx,%eax
  800df0:	c1 e9 02             	shr    $0x2,%ecx
  800df3:	fc                   	cld    
  800df4:	f3 ab                	rep stos %eax,%es:(%edi)
  800df6:	eb 06                	jmp    800dfe <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800df8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dfb:	fc                   	cld    
  800dfc:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800dfe:	89 f8                	mov    %edi,%eax
  800e00:	5b                   	pop    %ebx
  800e01:	5e                   	pop    %esi
  800e02:	5f                   	pop    %edi
  800e03:	5d                   	pop    %ebp
  800e04:	c3                   	ret    

00800e05 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e05:	55                   	push   %ebp
  800e06:	89 e5                	mov    %esp,%ebp
  800e08:	57                   	push   %edi
  800e09:	56                   	push   %esi
  800e0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e0d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e10:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800e13:	39 c6                	cmp    %eax,%esi
  800e15:	73 35                	jae    800e4c <memmove+0x47>
  800e17:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800e1a:	39 d0                	cmp    %edx,%eax
  800e1c:	73 2e                	jae    800e4c <memmove+0x47>
		s += n;
		d += n;
  800e1e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e21:	89 d6                	mov    %edx,%esi
  800e23:	09 fe                	or     %edi,%esi
  800e25:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e2b:	75 13                	jne    800e40 <memmove+0x3b>
  800e2d:	f6 c1 03             	test   $0x3,%cl
  800e30:	75 0e                	jne    800e40 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800e32:	83 ef 04             	sub    $0x4,%edi
  800e35:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e38:	c1 e9 02             	shr    $0x2,%ecx
  800e3b:	fd                   	std    
  800e3c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e3e:	eb 09                	jmp    800e49 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800e40:	83 ef 01             	sub    $0x1,%edi
  800e43:	8d 72 ff             	lea    -0x1(%edx),%esi
  800e46:	fd                   	std    
  800e47:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e49:	fc                   	cld    
  800e4a:	eb 1d                	jmp    800e69 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e4c:	89 f2                	mov    %esi,%edx
  800e4e:	09 c2                	or     %eax,%edx
  800e50:	f6 c2 03             	test   $0x3,%dl
  800e53:	75 0f                	jne    800e64 <memmove+0x5f>
  800e55:	f6 c1 03             	test   $0x3,%cl
  800e58:	75 0a                	jne    800e64 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800e5a:	c1 e9 02             	shr    $0x2,%ecx
  800e5d:	89 c7                	mov    %eax,%edi
  800e5f:	fc                   	cld    
  800e60:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e62:	eb 05                	jmp    800e69 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e64:	89 c7                	mov    %eax,%edi
  800e66:	fc                   	cld    
  800e67:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e69:	5e                   	pop    %esi
  800e6a:	5f                   	pop    %edi
  800e6b:	5d                   	pop    %ebp
  800e6c:	c3                   	ret    

00800e6d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800e6d:	55                   	push   %ebp
  800e6e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800e70:	ff 75 10             	pushl  0x10(%ebp)
  800e73:	ff 75 0c             	pushl  0xc(%ebp)
  800e76:	ff 75 08             	pushl  0x8(%ebp)
  800e79:	e8 87 ff ff ff       	call   800e05 <memmove>
}
  800e7e:	c9                   	leave  
  800e7f:	c3                   	ret    

00800e80 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e80:	55                   	push   %ebp
  800e81:	89 e5                	mov    %esp,%ebp
  800e83:	56                   	push   %esi
  800e84:	53                   	push   %ebx
  800e85:	8b 45 08             	mov    0x8(%ebp),%eax
  800e88:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e8b:	89 c6                	mov    %eax,%esi
  800e8d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e90:	eb 1a                	jmp    800eac <memcmp+0x2c>
		if (*s1 != *s2)
  800e92:	0f b6 08             	movzbl (%eax),%ecx
  800e95:	0f b6 1a             	movzbl (%edx),%ebx
  800e98:	38 d9                	cmp    %bl,%cl
  800e9a:	74 0a                	je     800ea6 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800e9c:	0f b6 c1             	movzbl %cl,%eax
  800e9f:	0f b6 db             	movzbl %bl,%ebx
  800ea2:	29 d8                	sub    %ebx,%eax
  800ea4:	eb 0f                	jmp    800eb5 <memcmp+0x35>
		s1++, s2++;
  800ea6:	83 c0 01             	add    $0x1,%eax
  800ea9:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800eac:	39 f0                	cmp    %esi,%eax
  800eae:	75 e2                	jne    800e92 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800eb0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800eb5:	5b                   	pop    %ebx
  800eb6:	5e                   	pop    %esi
  800eb7:	5d                   	pop    %ebp
  800eb8:	c3                   	ret    

00800eb9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800eb9:	55                   	push   %ebp
  800eba:	89 e5                	mov    %esp,%ebp
  800ebc:	53                   	push   %ebx
  800ebd:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ec0:	89 c1                	mov    %eax,%ecx
  800ec2:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800ec5:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ec9:	eb 0a                	jmp    800ed5 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ecb:	0f b6 10             	movzbl (%eax),%edx
  800ece:	39 da                	cmp    %ebx,%edx
  800ed0:	74 07                	je     800ed9 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ed2:	83 c0 01             	add    $0x1,%eax
  800ed5:	39 c8                	cmp    %ecx,%eax
  800ed7:	72 f2                	jb     800ecb <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ed9:	5b                   	pop    %ebx
  800eda:	5d                   	pop    %ebp
  800edb:	c3                   	ret    

00800edc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800edc:	55                   	push   %ebp
  800edd:	89 e5                	mov    %esp,%ebp
  800edf:	57                   	push   %edi
  800ee0:	56                   	push   %esi
  800ee1:	53                   	push   %ebx
  800ee2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ee5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ee8:	eb 03                	jmp    800eed <strtol+0x11>
		s++;
  800eea:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800eed:	0f b6 01             	movzbl (%ecx),%eax
  800ef0:	3c 20                	cmp    $0x20,%al
  800ef2:	74 f6                	je     800eea <strtol+0xe>
  800ef4:	3c 09                	cmp    $0x9,%al
  800ef6:	74 f2                	je     800eea <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ef8:	3c 2b                	cmp    $0x2b,%al
  800efa:	75 0a                	jne    800f06 <strtol+0x2a>
		s++;
  800efc:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800eff:	bf 00 00 00 00       	mov    $0x0,%edi
  800f04:	eb 11                	jmp    800f17 <strtol+0x3b>
  800f06:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800f0b:	3c 2d                	cmp    $0x2d,%al
  800f0d:	75 08                	jne    800f17 <strtol+0x3b>
		s++, neg = 1;
  800f0f:	83 c1 01             	add    $0x1,%ecx
  800f12:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f17:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800f1d:	75 15                	jne    800f34 <strtol+0x58>
  800f1f:	80 39 30             	cmpb   $0x30,(%ecx)
  800f22:	75 10                	jne    800f34 <strtol+0x58>
  800f24:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800f28:	75 7c                	jne    800fa6 <strtol+0xca>
		s += 2, base = 16;
  800f2a:	83 c1 02             	add    $0x2,%ecx
  800f2d:	bb 10 00 00 00       	mov    $0x10,%ebx
  800f32:	eb 16                	jmp    800f4a <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800f34:	85 db                	test   %ebx,%ebx
  800f36:	75 12                	jne    800f4a <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800f38:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f3d:	80 39 30             	cmpb   $0x30,(%ecx)
  800f40:	75 08                	jne    800f4a <strtol+0x6e>
		s++, base = 8;
  800f42:	83 c1 01             	add    $0x1,%ecx
  800f45:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800f4a:	b8 00 00 00 00       	mov    $0x0,%eax
  800f4f:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f52:	0f b6 11             	movzbl (%ecx),%edx
  800f55:	8d 72 d0             	lea    -0x30(%edx),%esi
  800f58:	89 f3                	mov    %esi,%ebx
  800f5a:	80 fb 09             	cmp    $0x9,%bl
  800f5d:	77 08                	ja     800f67 <strtol+0x8b>
			dig = *s - '0';
  800f5f:	0f be d2             	movsbl %dl,%edx
  800f62:	83 ea 30             	sub    $0x30,%edx
  800f65:	eb 22                	jmp    800f89 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800f67:	8d 72 9f             	lea    -0x61(%edx),%esi
  800f6a:	89 f3                	mov    %esi,%ebx
  800f6c:	80 fb 19             	cmp    $0x19,%bl
  800f6f:	77 08                	ja     800f79 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800f71:	0f be d2             	movsbl %dl,%edx
  800f74:	83 ea 57             	sub    $0x57,%edx
  800f77:	eb 10                	jmp    800f89 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800f79:	8d 72 bf             	lea    -0x41(%edx),%esi
  800f7c:	89 f3                	mov    %esi,%ebx
  800f7e:	80 fb 19             	cmp    $0x19,%bl
  800f81:	77 16                	ja     800f99 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800f83:	0f be d2             	movsbl %dl,%edx
  800f86:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800f89:	3b 55 10             	cmp    0x10(%ebp),%edx
  800f8c:	7d 0b                	jge    800f99 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800f8e:	83 c1 01             	add    $0x1,%ecx
  800f91:	0f af 45 10          	imul   0x10(%ebp),%eax
  800f95:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800f97:	eb b9                	jmp    800f52 <strtol+0x76>

	if (endptr)
  800f99:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f9d:	74 0d                	je     800fac <strtol+0xd0>
		*endptr = (char *) s;
  800f9f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800fa2:	89 0e                	mov    %ecx,(%esi)
  800fa4:	eb 06                	jmp    800fac <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800fa6:	85 db                	test   %ebx,%ebx
  800fa8:	74 98                	je     800f42 <strtol+0x66>
  800faa:	eb 9e                	jmp    800f4a <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800fac:	89 c2                	mov    %eax,%edx
  800fae:	f7 da                	neg    %edx
  800fb0:	85 ff                	test   %edi,%edi
  800fb2:	0f 45 c2             	cmovne %edx,%eax
}
  800fb5:	5b                   	pop    %ebx
  800fb6:	5e                   	pop    %esi
  800fb7:	5f                   	pop    %edi
  800fb8:	5d                   	pop    %ebp
  800fb9:	c3                   	ret    

00800fba <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800fba:	55                   	push   %ebp
  800fbb:	89 e5                	mov    %esp,%ebp
  800fbd:	57                   	push   %edi
  800fbe:	56                   	push   %esi
  800fbf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fc0:	b8 00 00 00 00       	mov    $0x0,%eax
  800fc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc8:	8b 55 08             	mov    0x8(%ebp),%edx
  800fcb:	89 c3                	mov    %eax,%ebx
  800fcd:	89 c7                	mov    %eax,%edi
  800fcf:	89 c6                	mov    %eax,%esi
  800fd1:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800fd3:	5b                   	pop    %ebx
  800fd4:	5e                   	pop    %esi
  800fd5:	5f                   	pop    %edi
  800fd6:	5d                   	pop    %ebp
  800fd7:	c3                   	ret    

00800fd8 <sys_cgetc>:

int
sys_cgetc(void)
{
  800fd8:	55                   	push   %ebp
  800fd9:	89 e5                	mov    %esp,%ebp
  800fdb:	57                   	push   %edi
  800fdc:	56                   	push   %esi
  800fdd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fde:	ba 00 00 00 00       	mov    $0x0,%edx
  800fe3:	b8 01 00 00 00       	mov    $0x1,%eax
  800fe8:	89 d1                	mov    %edx,%ecx
  800fea:	89 d3                	mov    %edx,%ebx
  800fec:	89 d7                	mov    %edx,%edi
  800fee:	89 d6                	mov    %edx,%esi
  800ff0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ff2:	5b                   	pop    %ebx
  800ff3:	5e                   	pop    %esi
  800ff4:	5f                   	pop    %edi
  800ff5:	5d                   	pop    %ebp
  800ff6:	c3                   	ret    

00800ff7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ff7:	55                   	push   %ebp
  800ff8:	89 e5                	mov    %esp,%ebp
  800ffa:	57                   	push   %edi
  800ffb:	56                   	push   %esi
  800ffc:	53                   	push   %ebx
  800ffd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801000:	b9 00 00 00 00       	mov    $0x0,%ecx
  801005:	b8 03 00 00 00       	mov    $0x3,%eax
  80100a:	8b 55 08             	mov    0x8(%ebp),%edx
  80100d:	89 cb                	mov    %ecx,%ebx
  80100f:	89 cf                	mov    %ecx,%edi
  801011:	89 ce                	mov    %ecx,%esi
  801013:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801015:	85 c0                	test   %eax,%eax
  801017:	7e 17                	jle    801030 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801019:	83 ec 0c             	sub    $0xc,%esp
  80101c:	50                   	push   %eax
  80101d:	6a 03                	push   $0x3
  80101f:	68 df 27 80 00       	push   $0x8027df
  801024:	6a 23                	push   $0x23
  801026:	68 fc 27 80 00       	push   $0x8027fc
  80102b:	e8 c7 f5 ff ff       	call   8005f7 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801030:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801033:	5b                   	pop    %ebx
  801034:	5e                   	pop    %esi
  801035:	5f                   	pop    %edi
  801036:	5d                   	pop    %ebp
  801037:	c3                   	ret    

00801038 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801038:	55                   	push   %ebp
  801039:	89 e5                	mov    %esp,%ebp
  80103b:	57                   	push   %edi
  80103c:	56                   	push   %esi
  80103d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80103e:	ba 00 00 00 00       	mov    $0x0,%edx
  801043:	b8 02 00 00 00       	mov    $0x2,%eax
  801048:	89 d1                	mov    %edx,%ecx
  80104a:	89 d3                	mov    %edx,%ebx
  80104c:	89 d7                	mov    %edx,%edi
  80104e:	89 d6                	mov    %edx,%esi
  801050:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801052:	5b                   	pop    %ebx
  801053:	5e                   	pop    %esi
  801054:	5f                   	pop    %edi
  801055:	5d                   	pop    %ebp
  801056:	c3                   	ret    

00801057 <sys_yield>:

void
sys_yield(void)
{
  801057:	55                   	push   %ebp
  801058:	89 e5                	mov    %esp,%ebp
  80105a:	57                   	push   %edi
  80105b:	56                   	push   %esi
  80105c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80105d:	ba 00 00 00 00       	mov    $0x0,%edx
  801062:	b8 0b 00 00 00       	mov    $0xb,%eax
  801067:	89 d1                	mov    %edx,%ecx
  801069:	89 d3                	mov    %edx,%ebx
  80106b:	89 d7                	mov    %edx,%edi
  80106d:	89 d6                	mov    %edx,%esi
  80106f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801071:	5b                   	pop    %ebx
  801072:	5e                   	pop    %esi
  801073:	5f                   	pop    %edi
  801074:	5d                   	pop    %ebp
  801075:	c3                   	ret    

00801076 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801076:	55                   	push   %ebp
  801077:	89 e5                	mov    %esp,%ebp
  801079:	57                   	push   %edi
  80107a:	56                   	push   %esi
  80107b:	53                   	push   %ebx
  80107c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80107f:	be 00 00 00 00       	mov    $0x0,%esi
  801084:	b8 04 00 00 00       	mov    $0x4,%eax
  801089:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80108c:	8b 55 08             	mov    0x8(%ebp),%edx
  80108f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801092:	89 f7                	mov    %esi,%edi
  801094:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801096:	85 c0                	test   %eax,%eax
  801098:	7e 17                	jle    8010b1 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80109a:	83 ec 0c             	sub    $0xc,%esp
  80109d:	50                   	push   %eax
  80109e:	6a 04                	push   $0x4
  8010a0:	68 df 27 80 00       	push   $0x8027df
  8010a5:	6a 23                	push   $0x23
  8010a7:	68 fc 27 80 00       	push   $0x8027fc
  8010ac:	e8 46 f5 ff ff       	call   8005f7 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8010b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010b4:	5b                   	pop    %ebx
  8010b5:	5e                   	pop    %esi
  8010b6:	5f                   	pop    %edi
  8010b7:	5d                   	pop    %ebp
  8010b8:	c3                   	ret    

008010b9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8010b9:	55                   	push   %ebp
  8010ba:	89 e5                	mov    %esp,%ebp
  8010bc:	57                   	push   %edi
  8010bd:	56                   	push   %esi
  8010be:	53                   	push   %ebx
  8010bf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010c2:	b8 05 00 00 00       	mov    $0x5,%eax
  8010c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8010cd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010d0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010d3:	8b 75 18             	mov    0x18(%ebp),%esi
  8010d6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010d8:	85 c0                	test   %eax,%eax
  8010da:	7e 17                	jle    8010f3 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010dc:	83 ec 0c             	sub    $0xc,%esp
  8010df:	50                   	push   %eax
  8010e0:	6a 05                	push   $0x5
  8010e2:	68 df 27 80 00       	push   $0x8027df
  8010e7:	6a 23                	push   $0x23
  8010e9:	68 fc 27 80 00       	push   $0x8027fc
  8010ee:	e8 04 f5 ff ff       	call   8005f7 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8010f3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010f6:	5b                   	pop    %ebx
  8010f7:	5e                   	pop    %esi
  8010f8:	5f                   	pop    %edi
  8010f9:	5d                   	pop    %ebp
  8010fa:	c3                   	ret    

008010fb <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8010fb:	55                   	push   %ebp
  8010fc:	89 e5                	mov    %esp,%ebp
  8010fe:	57                   	push   %edi
  8010ff:	56                   	push   %esi
  801100:	53                   	push   %ebx
  801101:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801104:	bb 00 00 00 00       	mov    $0x0,%ebx
  801109:	b8 06 00 00 00       	mov    $0x6,%eax
  80110e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801111:	8b 55 08             	mov    0x8(%ebp),%edx
  801114:	89 df                	mov    %ebx,%edi
  801116:	89 de                	mov    %ebx,%esi
  801118:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80111a:	85 c0                	test   %eax,%eax
  80111c:	7e 17                	jle    801135 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80111e:	83 ec 0c             	sub    $0xc,%esp
  801121:	50                   	push   %eax
  801122:	6a 06                	push   $0x6
  801124:	68 df 27 80 00       	push   $0x8027df
  801129:	6a 23                	push   $0x23
  80112b:	68 fc 27 80 00       	push   $0x8027fc
  801130:	e8 c2 f4 ff ff       	call   8005f7 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801135:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801138:	5b                   	pop    %ebx
  801139:	5e                   	pop    %esi
  80113a:	5f                   	pop    %edi
  80113b:	5d                   	pop    %ebp
  80113c:	c3                   	ret    

0080113d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80113d:	55                   	push   %ebp
  80113e:	89 e5                	mov    %esp,%ebp
  801140:	57                   	push   %edi
  801141:	56                   	push   %esi
  801142:	53                   	push   %ebx
  801143:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801146:	bb 00 00 00 00       	mov    $0x0,%ebx
  80114b:	b8 08 00 00 00       	mov    $0x8,%eax
  801150:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801153:	8b 55 08             	mov    0x8(%ebp),%edx
  801156:	89 df                	mov    %ebx,%edi
  801158:	89 de                	mov    %ebx,%esi
  80115a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80115c:	85 c0                	test   %eax,%eax
  80115e:	7e 17                	jle    801177 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801160:	83 ec 0c             	sub    $0xc,%esp
  801163:	50                   	push   %eax
  801164:	6a 08                	push   $0x8
  801166:	68 df 27 80 00       	push   $0x8027df
  80116b:	6a 23                	push   $0x23
  80116d:	68 fc 27 80 00       	push   $0x8027fc
  801172:	e8 80 f4 ff ff       	call   8005f7 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801177:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80117a:	5b                   	pop    %ebx
  80117b:	5e                   	pop    %esi
  80117c:	5f                   	pop    %edi
  80117d:	5d                   	pop    %ebp
  80117e:	c3                   	ret    

0080117f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80117f:	55                   	push   %ebp
  801180:	89 e5                	mov    %esp,%ebp
  801182:	57                   	push   %edi
  801183:	56                   	push   %esi
  801184:	53                   	push   %ebx
  801185:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801188:	bb 00 00 00 00       	mov    $0x0,%ebx
  80118d:	b8 09 00 00 00       	mov    $0x9,%eax
  801192:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801195:	8b 55 08             	mov    0x8(%ebp),%edx
  801198:	89 df                	mov    %ebx,%edi
  80119a:	89 de                	mov    %ebx,%esi
  80119c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80119e:	85 c0                	test   %eax,%eax
  8011a0:	7e 17                	jle    8011b9 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011a2:	83 ec 0c             	sub    $0xc,%esp
  8011a5:	50                   	push   %eax
  8011a6:	6a 09                	push   $0x9
  8011a8:	68 df 27 80 00       	push   $0x8027df
  8011ad:	6a 23                	push   $0x23
  8011af:	68 fc 27 80 00       	push   $0x8027fc
  8011b4:	e8 3e f4 ff ff       	call   8005f7 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8011b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011bc:	5b                   	pop    %ebx
  8011bd:	5e                   	pop    %esi
  8011be:	5f                   	pop    %edi
  8011bf:	5d                   	pop    %ebp
  8011c0:	c3                   	ret    

008011c1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8011c1:	55                   	push   %ebp
  8011c2:	89 e5                	mov    %esp,%ebp
  8011c4:	57                   	push   %edi
  8011c5:	56                   	push   %esi
  8011c6:	53                   	push   %ebx
  8011c7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011ca:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011cf:	b8 0a 00 00 00       	mov    $0xa,%eax
  8011d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011d7:	8b 55 08             	mov    0x8(%ebp),%edx
  8011da:	89 df                	mov    %ebx,%edi
  8011dc:	89 de                	mov    %ebx,%esi
  8011de:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011e0:	85 c0                	test   %eax,%eax
  8011e2:	7e 17                	jle    8011fb <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011e4:	83 ec 0c             	sub    $0xc,%esp
  8011e7:	50                   	push   %eax
  8011e8:	6a 0a                	push   $0xa
  8011ea:	68 df 27 80 00       	push   $0x8027df
  8011ef:	6a 23                	push   $0x23
  8011f1:	68 fc 27 80 00       	push   $0x8027fc
  8011f6:	e8 fc f3 ff ff       	call   8005f7 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8011fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011fe:	5b                   	pop    %ebx
  8011ff:	5e                   	pop    %esi
  801200:	5f                   	pop    %edi
  801201:	5d                   	pop    %ebp
  801202:	c3                   	ret    

00801203 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801203:	55                   	push   %ebp
  801204:	89 e5                	mov    %esp,%ebp
  801206:	57                   	push   %edi
  801207:	56                   	push   %esi
  801208:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801209:	be 00 00 00 00       	mov    $0x0,%esi
  80120e:	b8 0c 00 00 00       	mov    $0xc,%eax
  801213:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801216:	8b 55 08             	mov    0x8(%ebp),%edx
  801219:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80121c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80121f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801221:	5b                   	pop    %ebx
  801222:	5e                   	pop    %esi
  801223:	5f                   	pop    %edi
  801224:	5d                   	pop    %ebp
  801225:	c3                   	ret    

00801226 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801226:	55                   	push   %ebp
  801227:	89 e5                	mov    %esp,%ebp
  801229:	57                   	push   %edi
  80122a:	56                   	push   %esi
  80122b:	53                   	push   %ebx
  80122c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80122f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801234:	b8 0d 00 00 00       	mov    $0xd,%eax
  801239:	8b 55 08             	mov    0x8(%ebp),%edx
  80123c:	89 cb                	mov    %ecx,%ebx
  80123e:	89 cf                	mov    %ecx,%edi
  801240:	89 ce                	mov    %ecx,%esi
  801242:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801244:	85 c0                	test   %eax,%eax
  801246:	7e 17                	jle    80125f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801248:	83 ec 0c             	sub    $0xc,%esp
  80124b:	50                   	push   %eax
  80124c:	6a 0d                	push   $0xd
  80124e:	68 df 27 80 00       	push   $0x8027df
  801253:	6a 23                	push   $0x23
  801255:	68 fc 27 80 00       	push   $0x8027fc
  80125a:	e8 98 f3 ff ff       	call   8005f7 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80125f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801262:	5b                   	pop    %ebx
  801263:	5e                   	pop    %esi
  801264:	5f                   	pop    %edi
  801265:	5d                   	pop    %ebp
  801266:	c3                   	ret    

00801267 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801267:	55                   	push   %ebp
  801268:	89 e5                	mov    %esp,%ebp
  80126a:	83 ec 08             	sub    $0x8,%esp
	int r;
	int ret;
	if (_pgfault_handler == 0) {
  80126d:	83 3d b4 40 80 00 00 	cmpl   $0x0,0x8040b4
  801274:	75 36                	jne    8012ac <set_pgfault_handler+0x45>
		// First time through!
		// LAB 4: Your code here.
        
        	ret = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  801276:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  80127b:	8b 40 48             	mov    0x48(%eax),%eax
  80127e:	83 ec 04             	sub    $0x4,%esp
  801281:	68 07 0e 00 00       	push   $0xe07
  801286:	68 00 f0 bf ee       	push   $0xeebff000
  80128b:	50                   	push   %eax
  80128c:	e8 e5 fd ff ff       	call   801076 <sys_page_alloc>
		if (ret < 0) {
  801291:	83 c4 10             	add    $0x10,%esp
  801294:	85 c0                	test   %eax,%eax
  801296:	79 14                	jns    8012ac <set_pgfault_handler+0x45>
		    panic("Allocate user exception stack failed!\n");
  801298:	83 ec 04             	sub    $0x4,%esp
  80129b:	68 0c 28 80 00       	push   $0x80280c
  8012a0:	6a 23                	push   $0x23
  8012a2:	68 33 28 80 00       	push   $0x802833
  8012a7:	e8 4b f3 ff ff       	call   8005f7 <_panic>
		}
	}
	sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  8012ac:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  8012b1:	8b 40 48             	mov    0x48(%eax),%eax
  8012b4:	83 ec 08             	sub    $0x8,%esp
  8012b7:	68 cf 12 80 00       	push   $0x8012cf
  8012bc:	50                   	push   %eax
  8012bd:	e8 ff fe ff ff       	call   8011c1 <sys_env_set_pgfault_upcall>
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8012c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8012c5:	a3 b4 40 80 00       	mov    %eax,0x8040b4
}
  8012ca:	83 c4 10             	add    $0x10,%esp
  8012cd:	c9                   	leave  
  8012ce:	c3                   	ret    

008012cf <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8012cf:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8012d0:	a1 b4 40 80 00       	mov    0x8040b4,%eax
	call *%eax
  8012d5:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8012d7:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 0x28(%esp), %ebx  # trap-time eip
  8012da:	8b 5c 24 28          	mov    0x28(%esp),%ebx
        subl $0x4, 0x30(%esp)  # trap-time esp minus 4
  8012de:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax 
  8012e3:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl %ebx, (%eax)      # trap-time esp store trap-time eip
  8012e7:	89 18                	mov    %ebx,(%eax)
        addl $0x8, %esp
  8012e9:	83 c4 08             	add    $0x8,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  8012ec:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  8012ed:	83 c4 04             	add    $0x4,%esp
        popfl
  8012f0:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  8012f1:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  8012f2:	c3                   	ret    

008012f3 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012f3:	55                   	push   %ebp
  8012f4:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8012f9:	05 00 00 00 30       	add    $0x30000000,%eax
  8012fe:	c1 e8 0c             	shr    $0xc,%eax
}
  801301:	5d                   	pop    %ebp
  801302:	c3                   	ret    

00801303 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801303:	55                   	push   %ebp
  801304:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801306:	8b 45 08             	mov    0x8(%ebp),%eax
  801309:	05 00 00 00 30       	add    $0x30000000,%eax
  80130e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801313:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801318:	5d                   	pop    %ebp
  801319:	c3                   	ret    

0080131a <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80131a:	55                   	push   %ebp
  80131b:	89 e5                	mov    %esp,%ebp
  80131d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801320:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801325:	89 c2                	mov    %eax,%edx
  801327:	c1 ea 16             	shr    $0x16,%edx
  80132a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801331:	f6 c2 01             	test   $0x1,%dl
  801334:	74 11                	je     801347 <fd_alloc+0x2d>
  801336:	89 c2                	mov    %eax,%edx
  801338:	c1 ea 0c             	shr    $0xc,%edx
  80133b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801342:	f6 c2 01             	test   $0x1,%dl
  801345:	75 09                	jne    801350 <fd_alloc+0x36>
			*fd_store = fd;
  801347:	89 01                	mov    %eax,(%ecx)
			return 0;
  801349:	b8 00 00 00 00       	mov    $0x0,%eax
  80134e:	eb 17                	jmp    801367 <fd_alloc+0x4d>
  801350:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801355:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80135a:	75 c9                	jne    801325 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80135c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801362:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801367:	5d                   	pop    %ebp
  801368:	c3                   	ret    

00801369 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801369:	55                   	push   %ebp
  80136a:	89 e5                	mov    %esp,%ebp
  80136c:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80136f:	83 f8 1f             	cmp    $0x1f,%eax
  801372:	77 36                	ja     8013aa <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801374:	c1 e0 0c             	shl    $0xc,%eax
  801377:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80137c:	89 c2                	mov    %eax,%edx
  80137e:	c1 ea 16             	shr    $0x16,%edx
  801381:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801388:	f6 c2 01             	test   $0x1,%dl
  80138b:	74 24                	je     8013b1 <fd_lookup+0x48>
  80138d:	89 c2                	mov    %eax,%edx
  80138f:	c1 ea 0c             	shr    $0xc,%edx
  801392:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801399:	f6 c2 01             	test   $0x1,%dl
  80139c:	74 1a                	je     8013b8 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80139e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013a1:	89 02                	mov    %eax,(%edx)
	return 0;
  8013a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8013a8:	eb 13                	jmp    8013bd <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013aa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013af:	eb 0c                	jmp    8013bd <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013b1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013b6:	eb 05                	jmp    8013bd <fd_lookup+0x54>
  8013b8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8013bd:	5d                   	pop    %ebp
  8013be:	c3                   	ret    

008013bf <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8013bf:	55                   	push   %ebp
  8013c0:	89 e5                	mov    %esp,%ebp
  8013c2:	83 ec 08             	sub    $0x8,%esp
  8013c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013c8:	ba c4 28 80 00       	mov    $0x8028c4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8013cd:	eb 13                	jmp    8013e2 <dev_lookup+0x23>
  8013cf:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8013d2:	39 08                	cmp    %ecx,(%eax)
  8013d4:	75 0c                	jne    8013e2 <dev_lookup+0x23>
			*dev = devtab[i];
  8013d6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013d9:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013db:	b8 00 00 00 00       	mov    $0x0,%eax
  8013e0:	eb 2e                	jmp    801410 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8013e2:	8b 02                	mov    (%edx),%eax
  8013e4:	85 c0                	test   %eax,%eax
  8013e6:	75 e7                	jne    8013cf <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013e8:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  8013ed:	8b 40 48             	mov    0x48(%eax),%eax
  8013f0:	83 ec 04             	sub    $0x4,%esp
  8013f3:	51                   	push   %ecx
  8013f4:	50                   	push   %eax
  8013f5:	68 44 28 80 00       	push   $0x802844
  8013fa:	e8 d1 f2 ff ff       	call   8006d0 <cprintf>
	*dev = 0;
  8013ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  801402:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801408:	83 c4 10             	add    $0x10,%esp
  80140b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801410:	c9                   	leave  
  801411:	c3                   	ret    

00801412 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801412:	55                   	push   %ebp
  801413:	89 e5                	mov    %esp,%ebp
  801415:	56                   	push   %esi
  801416:	53                   	push   %ebx
  801417:	83 ec 10             	sub    $0x10,%esp
  80141a:	8b 75 08             	mov    0x8(%ebp),%esi
  80141d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801420:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801423:	50                   	push   %eax
  801424:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80142a:	c1 e8 0c             	shr    $0xc,%eax
  80142d:	50                   	push   %eax
  80142e:	e8 36 ff ff ff       	call   801369 <fd_lookup>
  801433:	83 c4 08             	add    $0x8,%esp
  801436:	85 c0                	test   %eax,%eax
  801438:	78 05                	js     80143f <fd_close+0x2d>
	    || fd != fd2)
  80143a:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80143d:	74 0c                	je     80144b <fd_close+0x39>
		return (must_exist ? r : 0);
  80143f:	84 db                	test   %bl,%bl
  801441:	ba 00 00 00 00       	mov    $0x0,%edx
  801446:	0f 44 c2             	cmove  %edx,%eax
  801449:	eb 41                	jmp    80148c <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80144b:	83 ec 08             	sub    $0x8,%esp
  80144e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801451:	50                   	push   %eax
  801452:	ff 36                	pushl  (%esi)
  801454:	e8 66 ff ff ff       	call   8013bf <dev_lookup>
  801459:	89 c3                	mov    %eax,%ebx
  80145b:	83 c4 10             	add    $0x10,%esp
  80145e:	85 c0                	test   %eax,%eax
  801460:	78 1a                	js     80147c <fd_close+0x6a>
		if (dev->dev_close)
  801462:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801465:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801468:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80146d:	85 c0                	test   %eax,%eax
  80146f:	74 0b                	je     80147c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801471:	83 ec 0c             	sub    $0xc,%esp
  801474:	56                   	push   %esi
  801475:	ff d0                	call   *%eax
  801477:	89 c3                	mov    %eax,%ebx
  801479:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80147c:	83 ec 08             	sub    $0x8,%esp
  80147f:	56                   	push   %esi
  801480:	6a 00                	push   $0x0
  801482:	e8 74 fc ff ff       	call   8010fb <sys_page_unmap>
	return r;
  801487:	83 c4 10             	add    $0x10,%esp
  80148a:	89 d8                	mov    %ebx,%eax
}
  80148c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80148f:	5b                   	pop    %ebx
  801490:	5e                   	pop    %esi
  801491:	5d                   	pop    %ebp
  801492:	c3                   	ret    

00801493 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801493:	55                   	push   %ebp
  801494:	89 e5                	mov    %esp,%ebp
  801496:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801499:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80149c:	50                   	push   %eax
  80149d:	ff 75 08             	pushl  0x8(%ebp)
  8014a0:	e8 c4 fe ff ff       	call   801369 <fd_lookup>
  8014a5:	83 c4 08             	add    $0x8,%esp
  8014a8:	85 c0                	test   %eax,%eax
  8014aa:	78 10                	js     8014bc <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8014ac:	83 ec 08             	sub    $0x8,%esp
  8014af:	6a 01                	push   $0x1
  8014b1:	ff 75 f4             	pushl  -0xc(%ebp)
  8014b4:	e8 59 ff ff ff       	call   801412 <fd_close>
  8014b9:	83 c4 10             	add    $0x10,%esp
}
  8014bc:	c9                   	leave  
  8014bd:	c3                   	ret    

008014be <close_all>:

void
close_all(void)
{
  8014be:	55                   	push   %ebp
  8014bf:	89 e5                	mov    %esp,%ebp
  8014c1:	53                   	push   %ebx
  8014c2:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014c5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014ca:	83 ec 0c             	sub    $0xc,%esp
  8014cd:	53                   	push   %ebx
  8014ce:	e8 c0 ff ff ff       	call   801493 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8014d3:	83 c3 01             	add    $0x1,%ebx
  8014d6:	83 c4 10             	add    $0x10,%esp
  8014d9:	83 fb 20             	cmp    $0x20,%ebx
  8014dc:	75 ec                	jne    8014ca <close_all+0xc>
		close(i);
}
  8014de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014e1:	c9                   	leave  
  8014e2:	c3                   	ret    

008014e3 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014e3:	55                   	push   %ebp
  8014e4:	89 e5                	mov    %esp,%ebp
  8014e6:	57                   	push   %edi
  8014e7:	56                   	push   %esi
  8014e8:	53                   	push   %ebx
  8014e9:	83 ec 2c             	sub    $0x2c,%esp
  8014ec:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014ef:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014f2:	50                   	push   %eax
  8014f3:	ff 75 08             	pushl  0x8(%ebp)
  8014f6:	e8 6e fe ff ff       	call   801369 <fd_lookup>
  8014fb:	83 c4 08             	add    $0x8,%esp
  8014fe:	85 c0                	test   %eax,%eax
  801500:	0f 88 c1 00 00 00    	js     8015c7 <dup+0xe4>
		return r;
	close(newfdnum);
  801506:	83 ec 0c             	sub    $0xc,%esp
  801509:	56                   	push   %esi
  80150a:	e8 84 ff ff ff       	call   801493 <close>

	newfd = INDEX2FD(newfdnum);
  80150f:	89 f3                	mov    %esi,%ebx
  801511:	c1 e3 0c             	shl    $0xc,%ebx
  801514:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80151a:	83 c4 04             	add    $0x4,%esp
  80151d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801520:	e8 de fd ff ff       	call   801303 <fd2data>
  801525:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801527:	89 1c 24             	mov    %ebx,(%esp)
  80152a:	e8 d4 fd ff ff       	call   801303 <fd2data>
  80152f:	83 c4 10             	add    $0x10,%esp
  801532:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801535:	89 f8                	mov    %edi,%eax
  801537:	c1 e8 16             	shr    $0x16,%eax
  80153a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801541:	a8 01                	test   $0x1,%al
  801543:	74 37                	je     80157c <dup+0x99>
  801545:	89 f8                	mov    %edi,%eax
  801547:	c1 e8 0c             	shr    $0xc,%eax
  80154a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801551:	f6 c2 01             	test   $0x1,%dl
  801554:	74 26                	je     80157c <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801556:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80155d:	83 ec 0c             	sub    $0xc,%esp
  801560:	25 07 0e 00 00       	and    $0xe07,%eax
  801565:	50                   	push   %eax
  801566:	ff 75 d4             	pushl  -0x2c(%ebp)
  801569:	6a 00                	push   $0x0
  80156b:	57                   	push   %edi
  80156c:	6a 00                	push   $0x0
  80156e:	e8 46 fb ff ff       	call   8010b9 <sys_page_map>
  801573:	89 c7                	mov    %eax,%edi
  801575:	83 c4 20             	add    $0x20,%esp
  801578:	85 c0                	test   %eax,%eax
  80157a:	78 2e                	js     8015aa <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80157c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80157f:	89 d0                	mov    %edx,%eax
  801581:	c1 e8 0c             	shr    $0xc,%eax
  801584:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80158b:	83 ec 0c             	sub    $0xc,%esp
  80158e:	25 07 0e 00 00       	and    $0xe07,%eax
  801593:	50                   	push   %eax
  801594:	53                   	push   %ebx
  801595:	6a 00                	push   $0x0
  801597:	52                   	push   %edx
  801598:	6a 00                	push   $0x0
  80159a:	e8 1a fb ff ff       	call   8010b9 <sys_page_map>
  80159f:	89 c7                	mov    %eax,%edi
  8015a1:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8015a4:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015a6:	85 ff                	test   %edi,%edi
  8015a8:	79 1d                	jns    8015c7 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8015aa:	83 ec 08             	sub    $0x8,%esp
  8015ad:	53                   	push   %ebx
  8015ae:	6a 00                	push   $0x0
  8015b0:	e8 46 fb ff ff       	call   8010fb <sys_page_unmap>
	sys_page_unmap(0, nva);
  8015b5:	83 c4 08             	add    $0x8,%esp
  8015b8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8015bb:	6a 00                	push   $0x0
  8015bd:	e8 39 fb ff ff       	call   8010fb <sys_page_unmap>
	return r;
  8015c2:	83 c4 10             	add    $0x10,%esp
  8015c5:	89 f8                	mov    %edi,%eax
}
  8015c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015ca:	5b                   	pop    %ebx
  8015cb:	5e                   	pop    %esi
  8015cc:	5f                   	pop    %edi
  8015cd:	5d                   	pop    %ebp
  8015ce:	c3                   	ret    

008015cf <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015cf:	55                   	push   %ebp
  8015d0:	89 e5                	mov    %esp,%ebp
  8015d2:	53                   	push   %ebx
  8015d3:	83 ec 14             	sub    $0x14,%esp
  8015d6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015d9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015dc:	50                   	push   %eax
  8015dd:	53                   	push   %ebx
  8015de:	e8 86 fd ff ff       	call   801369 <fd_lookup>
  8015e3:	83 c4 08             	add    $0x8,%esp
  8015e6:	89 c2                	mov    %eax,%edx
  8015e8:	85 c0                	test   %eax,%eax
  8015ea:	78 6d                	js     801659 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ec:	83 ec 08             	sub    $0x8,%esp
  8015ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015f2:	50                   	push   %eax
  8015f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015f6:	ff 30                	pushl  (%eax)
  8015f8:	e8 c2 fd ff ff       	call   8013bf <dev_lookup>
  8015fd:	83 c4 10             	add    $0x10,%esp
  801600:	85 c0                	test   %eax,%eax
  801602:	78 4c                	js     801650 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801604:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801607:	8b 42 08             	mov    0x8(%edx),%eax
  80160a:	83 e0 03             	and    $0x3,%eax
  80160d:	83 f8 01             	cmp    $0x1,%eax
  801610:	75 21                	jne    801633 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801612:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801617:	8b 40 48             	mov    0x48(%eax),%eax
  80161a:	83 ec 04             	sub    $0x4,%esp
  80161d:	53                   	push   %ebx
  80161e:	50                   	push   %eax
  80161f:	68 88 28 80 00       	push   $0x802888
  801624:	e8 a7 f0 ff ff       	call   8006d0 <cprintf>
		return -E_INVAL;
  801629:	83 c4 10             	add    $0x10,%esp
  80162c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801631:	eb 26                	jmp    801659 <read+0x8a>
	}
	if (!dev->dev_read)
  801633:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801636:	8b 40 08             	mov    0x8(%eax),%eax
  801639:	85 c0                	test   %eax,%eax
  80163b:	74 17                	je     801654 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80163d:	83 ec 04             	sub    $0x4,%esp
  801640:	ff 75 10             	pushl  0x10(%ebp)
  801643:	ff 75 0c             	pushl  0xc(%ebp)
  801646:	52                   	push   %edx
  801647:	ff d0                	call   *%eax
  801649:	89 c2                	mov    %eax,%edx
  80164b:	83 c4 10             	add    $0x10,%esp
  80164e:	eb 09                	jmp    801659 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801650:	89 c2                	mov    %eax,%edx
  801652:	eb 05                	jmp    801659 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801654:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801659:	89 d0                	mov    %edx,%eax
  80165b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80165e:	c9                   	leave  
  80165f:	c3                   	ret    

00801660 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801660:	55                   	push   %ebp
  801661:	89 e5                	mov    %esp,%ebp
  801663:	57                   	push   %edi
  801664:	56                   	push   %esi
  801665:	53                   	push   %ebx
  801666:	83 ec 0c             	sub    $0xc,%esp
  801669:	8b 7d 08             	mov    0x8(%ebp),%edi
  80166c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80166f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801674:	eb 21                	jmp    801697 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801676:	83 ec 04             	sub    $0x4,%esp
  801679:	89 f0                	mov    %esi,%eax
  80167b:	29 d8                	sub    %ebx,%eax
  80167d:	50                   	push   %eax
  80167e:	89 d8                	mov    %ebx,%eax
  801680:	03 45 0c             	add    0xc(%ebp),%eax
  801683:	50                   	push   %eax
  801684:	57                   	push   %edi
  801685:	e8 45 ff ff ff       	call   8015cf <read>
		if (m < 0)
  80168a:	83 c4 10             	add    $0x10,%esp
  80168d:	85 c0                	test   %eax,%eax
  80168f:	78 10                	js     8016a1 <readn+0x41>
			return m;
		if (m == 0)
  801691:	85 c0                	test   %eax,%eax
  801693:	74 0a                	je     80169f <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801695:	01 c3                	add    %eax,%ebx
  801697:	39 f3                	cmp    %esi,%ebx
  801699:	72 db                	jb     801676 <readn+0x16>
  80169b:	89 d8                	mov    %ebx,%eax
  80169d:	eb 02                	jmp    8016a1 <readn+0x41>
  80169f:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8016a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016a4:	5b                   	pop    %ebx
  8016a5:	5e                   	pop    %esi
  8016a6:	5f                   	pop    %edi
  8016a7:	5d                   	pop    %ebp
  8016a8:	c3                   	ret    

008016a9 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8016a9:	55                   	push   %ebp
  8016aa:	89 e5                	mov    %esp,%ebp
  8016ac:	53                   	push   %ebx
  8016ad:	83 ec 14             	sub    $0x14,%esp
  8016b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016b3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016b6:	50                   	push   %eax
  8016b7:	53                   	push   %ebx
  8016b8:	e8 ac fc ff ff       	call   801369 <fd_lookup>
  8016bd:	83 c4 08             	add    $0x8,%esp
  8016c0:	89 c2                	mov    %eax,%edx
  8016c2:	85 c0                	test   %eax,%eax
  8016c4:	78 68                	js     80172e <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016c6:	83 ec 08             	sub    $0x8,%esp
  8016c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016cc:	50                   	push   %eax
  8016cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016d0:	ff 30                	pushl  (%eax)
  8016d2:	e8 e8 fc ff ff       	call   8013bf <dev_lookup>
  8016d7:	83 c4 10             	add    $0x10,%esp
  8016da:	85 c0                	test   %eax,%eax
  8016dc:	78 47                	js     801725 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016e1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016e5:	75 21                	jne    801708 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016e7:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  8016ec:	8b 40 48             	mov    0x48(%eax),%eax
  8016ef:	83 ec 04             	sub    $0x4,%esp
  8016f2:	53                   	push   %ebx
  8016f3:	50                   	push   %eax
  8016f4:	68 a4 28 80 00       	push   $0x8028a4
  8016f9:	e8 d2 ef ff ff       	call   8006d0 <cprintf>
		return -E_INVAL;
  8016fe:	83 c4 10             	add    $0x10,%esp
  801701:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801706:	eb 26                	jmp    80172e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801708:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80170b:	8b 52 0c             	mov    0xc(%edx),%edx
  80170e:	85 d2                	test   %edx,%edx
  801710:	74 17                	je     801729 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801712:	83 ec 04             	sub    $0x4,%esp
  801715:	ff 75 10             	pushl  0x10(%ebp)
  801718:	ff 75 0c             	pushl  0xc(%ebp)
  80171b:	50                   	push   %eax
  80171c:	ff d2                	call   *%edx
  80171e:	89 c2                	mov    %eax,%edx
  801720:	83 c4 10             	add    $0x10,%esp
  801723:	eb 09                	jmp    80172e <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801725:	89 c2                	mov    %eax,%edx
  801727:	eb 05                	jmp    80172e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801729:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80172e:	89 d0                	mov    %edx,%eax
  801730:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801733:	c9                   	leave  
  801734:	c3                   	ret    

00801735 <seek>:

int
seek(int fdnum, off_t offset)
{
  801735:	55                   	push   %ebp
  801736:	89 e5                	mov    %esp,%ebp
  801738:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80173b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80173e:	50                   	push   %eax
  80173f:	ff 75 08             	pushl  0x8(%ebp)
  801742:	e8 22 fc ff ff       	call   801369 <fd_lookup>
  801747:	83 c4 08             	add    $0x8,%esp
  80174a:	85 c0                	test   %eax,%eax
  80174c:	78 0e                	js     80175c <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80174e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801751:	8b 55 0c             	mov    0xc(%ebp),%edx
  801754:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801757:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80175c:	c9                   	leave  
  80175d:	c3                   	ret    

0080175e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80175e:	55                   	push   %ebp
  80175f:	89 e5                	mov    %esp,%ebp
  801761:	53                   	push   %ebx
  801762:	83 ec 14             	sub    $0x14,%esp
  801765:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801768:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80176b:	50                   	push   %eax
  80176c:	53                   	push   %ebx
  80176d:	e8 f7 fb ff ff       	call   801369 <fd_lookup>
  801772:	83 c4 08             	add    $0x8,%esp
  801775:	89 c2                	mov    %eax,%edx
  801777:	85 c0                	test   %eax,%eax
  801779:	78 65                	js     8017e0 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80177b:	83 ec 08             	sub    $0x8,%esp
  80177e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801781:	50                   	push   %eax
  801782:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801785:	ff 30                	pushl  (%eax)
  801787:	e8 33 fc ff ff       	call   8013bf <dev_lookup>
  80178c:	83 c4 10             	add    $0x10,%esp
  80178f:	85 c0                	test   %eax,%eax
  801791:	78 44                	js     8017d7 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801793:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801796:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80179a:	75 21                	jne    8017bd <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80179c:	a1 b0 40 80 00       	mov    0x8040b0,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8017a1:	8b 40 48             	mov    0x48(%eax),%eax
  8017a4:	83 ec 04             	sub    $0x4,%esp
  8017a7:	53                   	push   %ebx
  8017a8:	50                   	push   %eax
  8017a9:	68 64 28 80 00       	push   $0x802864
  8017ae:	e8 1d ef ff ff       	call   8006d0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8017b3:	83 c4 10             	add    $0x10,%esp
  8017b6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017bb:	eb 23                	jmp    8017e0 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8017bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017c0:	8b 52 18             	mov    0x18(%edx),%edx
  8017c3:	85 d2                	test   %edx,%edx
  8017c5:	74 14                	je     8017db <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017c7:	83 ec 08             	sub    $0x8,%esp
  8017ca:	ff 75 0c             	pushl  0xc(%ebp)
  8017cd:	50                   	push   %eax
  8017ce:	ff d2                	call   *%edx
  8017d0:	89 c2                	mov    %eax,%edx
  8017d2:	83 c4 10             	add    $0x10,%esp
  8017d5:	eb 09                	jmp    8017e0 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017d7:	89 c2                	mov    %eax,%edx
  8017d9:	eb 05                	jmp    8017e0 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8017db:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8017e0:	89 d0                	mov    %edx,%eax
  8017e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017e5:	c9                   	leave  
  8017e6:	c3                   	ret    

008017e7 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8017e7:	55                   	push   %ebp
  8017e8:	89 e5                	mov    %esp,%ebp
  8017ea:	53                   	push   %ebx
  8017eb:	83 ec 14             	sub    $0x14,%esp
  8017ee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017f1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017f4:	50                   	push   %eax
  8017f5:	ff 75 08             	pushl  0x8(%ebp)
  8017f8:	e8 6c fb ff ff       	call   801369 <fd_lookup>
  8017fd:	83 c4 08             	add    $0x8,%esp
  801800:	89 c2                	mov    %eax,%edx
  801802:	85 c0                	test   %eax,%eax
  801804:	78 58                	js     80185e <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801806:	83 ec 08             	sub    $0x8,%esp
  801809:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80180c:	50                   	push   %eax
  80180d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801810:	ff 30                	pushl  (%eax)
  801812:	e8 a8 fb ff ff       	call   8013bf <dev_lookup>
  801817:	83 c4 10             	add    $0x10,%esp
  80181a:	85 c0                	test   %eax,%eax
  80181c:	78 37                	js     801855 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80181e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801821:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801825:	74 32                	je     801859 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801827:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80182a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801831:	00 00 00 
	stat->st_isdir = 0;
  801834:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80183b:	00 00 00 
	stat->st_dev = dev;
  80183e:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801844:	83 ec 08             	sub    $0x8,%esp
  801847:	53                   	push   %ebx
  801848:	ff 75 f0             	pushl  -0x10(%ebp)
  80184b:	ff 50 14             	call   *0x14(%eax)
  80184e:	89 c2                	mov    %eax,%edx
  801850:	83 c4 10             	add    $0x10,%esp
  801853:	eb 09                	jmp    80185e <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801855:	89 c2                	mov    %eax,%edx
  801857:	eb 05                	jmp    80185e <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801859:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80185e:	89 d0                	mov    %edx,%eax
  801860:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801863:	c9                   	leave  
  801864:	c3                   	ret    

00801865 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801865:	55                   	push   %ebp
  801866:	89 e5                	mov    %esp,%ebp
  801868:	56                   	push   %esi
  801869:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80186a:	83 ec 08             	sub    $0x8,%esp
  80186d:	6a 00                	push   $0x0
  80186f:	ff 75 08             	pushl  0x8(%ebp)
  801872:	e8 e3 01 00 00       	call   801a5a <open>
  801877:	89 c3                	mov    %eax,%ebx
  801879:	83 c4 10             	add    $0x10,%esp
  80187c:	85 c0                	test   %eax,%eax
  80187e:	78 1b                	js     80189b <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801880:	83 ec 08             	sub    $0x8,%esp
  801883:	ff 75 0c             	pushl  0xc(%ebp)
  801886:	50                   	push   %eax
  801887:	e8 5b ff ff ff       	call   8017e7 <fstat>
  80188c:	89 c6                	mov    %eax,%esi
	close(fd);
  80188e:	89 1c 24             	mov    %ebx,(%esp)
  801891:	e8 fd fb ff ff       	call   801493 <close>
	return r;
  801896:	83 c4 10             	add    $0x10,%esp
  801899:	89 f0                	mov    %esi,%eax
}
  80189b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80189e:	5b                   	pop    %ebx
  80189f:	5e                   	pop    %esi
  8018a0:	5d                   	pop    %ebp
  8018a1:	c3                   	ret    

008018a2 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8018a2:	55                   	push   %ebp
  8018a3:	89 e5                	mov    %esp,%ebp
  8018a5:	56                   	push   %esi
  8018a6:	53                   	push   %ebx
  8018a7:	89 c6                	mov    %eax,%esi
  8018a9:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8018ab:	83 3d ac 40 80 00 00 	cmpl   $0x0,0x8040ac
  8018b2:	75 12                	jne    8018c6 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8018b4:	83 ec 0c             	sub    $0xc,%esp
  8018b7:	6a 01                	push   $0x1
  8018b9:	e8 c8 07 00 00       	call   802086 <ipc_find_env>
  8018be:	a3 ac 40 80 00       	mov    %eax,0x8040ac
  8018c3:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018c6:	6a 07                	push   $0x7
  8018c8:	68 00 50 80 00       	push   $0x805000
  8018cd:	56                   	push   %esi
  8018ce:	ff 35 ac 40 80 00    	pushl  0x8040ac
  8018d4:	e8 59 07 00 00       	call   802032 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8018d9:	83 c4 0c             	add    $0xc,%esp
  8018dc:	6a 00                	push   $0x0
  8018de:	53                   	push   %ebx
  8018df:	6a 00                	push   $0x0
  8018e1:	e8 f7 06 00 00       	call   801fdd <ipc_recv>
}
  8018e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018e9:	5b                   	pop    %ebx
  8018ea:	5e                   	pop    %esi
  8018eb:	5d                   	pop    %ebp
  8018ec:	c3                   	ret    

008018ed <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8018ed:	55                   	push   %ebp
  8018ee:	89 e5                	mov    %esp,%ebp
  8018f0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8018f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f6:	8b 40 0c             	mov    0xc(%eax),%eax
  8018f9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8018fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801901:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801906:	ba 00 00 00 00       	mov    $0x0,%edx
  80190b:	b8 02 00 00 00       	mov    $0x2,%eax
  801910:	e8 8d ff ff ff       	call   8018a2 <fsipc>
}
  801915:	c9                   	leave  
  801916:	c3                   	ret    

00801917 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801917:	55                   	push   %ebp
  801918:	89 e5                	mov    %esp,%ebp
  80191a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80191d:	8b 45 08             	mov    0x8(%ebp),%eax
  801920:	8b 40 0c             	mov    0xc(%eax),%eax
  801923:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801928:	ba 00 00 00 00       	mov    $0x0,%edx
  80192d:	b8 06 00 00 00       	mov    $0x6,%eax
  801932:	e8 6b ff ff ff       	call   8018a2 <fsipc>
}
  801937:	c9                   	leave  
  801938:	c3                   	ret    

00801939 <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801939:	55                   	push   %ebp
  80193a:	89 e5                	mov    %esp,%ebp
  80193c:	53                   	push   %ebx
  80193d:	83 ec 04             	sub    $0x4,%esp
  801940:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801943:	8b 45 08             	mov    0x8(%ebp),%eax
  801946:	8b 40 0c             	mov    0xc(%eax),%eax
  801949:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80194e:	ba 00 00 00 00       	mov    $0x0,%edx
  801953:	b8 05 00 00 00       	mov    $0x5,%eax
  801958:	e8 45 ff ff ff       	call   8018a2 <fsipc>
  80195d:	85 c0                	test   %eax,%eax
  80195f:	78 2c                	js     80198d <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801961:	83 ec 08             	sub    $0x8,%esp
  801964:	68 00 50 80 00       	push   $0x805000
  801969:	53                   	push   %ebx
  80196a:	e8 04 f3 ff ff       	call   800c73 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80196f:	a1 80 50 80 00       	mov    0x805080,%eax
  801974:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80197a:	a1 84 50 80 00       	mov    0x805084,%eax
  80197f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801985:	83 c4 10             	add    $0x10,%esp
  801988:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80198d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801990:	c9                   	leave  
  801991:	c3                   	ret    

00801992 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801992:	55                   	push   %ebp
  801993:	89 e5                	mov    %esp,%ebp
  801995:	83 ec 0c             	sub    $0xc,%esp
  801998:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
    
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  80199b:	8b 55 08             	mov    0x8(%ebp),%edx
  80199e:	8b 52 0c             	mov    0xc(%edx),%edx
  8019a1:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = MIN(n, PGSIZE);
  8019a7:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019ac:	ba 00 10 00 00       	mov    $0x1000,%edx
  8019b1:	0f 47 c2             	cmova  %edx,%eax
  8019b4:	a3 04 50 80 00       	mov    %eax,0x805004
    memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8019b9:	50                   	push   %eax
  8019ba:	ff 75 0c             	pushl  0xc(%ebp)
  8019bd:	68 08 50 80 00       	push   $0x805008
  8019c2:	e8 3e f4 ff ff       	call   800e05 <memmove>
    int r = fsipc(FSREQ_WRITE, NULL);
  8019c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8019cc:	b8 04 00 00 00       	mov    $0x4,%eax
  8019d1:	e8 cc fe ff ff       	call   8018a2 <fsipc>
    return r;
}
  8019d6:	c9                   	leave  
  8019d7:	c3                   	ret    

008019d8 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8019d8:	55                   	push   %ebp
  8019d9:	89 e5                	mov    %esp,%ebp
  8019db:	56                   	push   %esi
  8019dc:	53                   	push   %ebx
  8019dd:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e3:	8b 40 0c             	mov    0xc(%eax),%eax
  8019e6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8019eb:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8019f6:	b8 03 00 00 00       	mov    $0x3,%eax
  8019fb:	e8 a2 fe ff ff       	call   8018a2 <fsipc>
  801a00:	89 c3                	mov    %eax,%ebx
  801a02:	85 c0                	test   %eax,%eax
  801a04:	78 4b                	js     801a51 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801a06:	39 c6                	cmp    %eax,%esi
  801a08:	73 16                	jae    801a20 <devfile_read+0x48>
  801a0a:	68 d4 28 80 00       	push   $0x8028d4
  801a0f:	68 db 28 80 00       	push   $0x8028db
  801a14:	6a 7c                	push   $0x7c
  801a16:	68 f0 28 80 00       	push   $0x8028f0
  801a1b:	e8 d7 eb ff ff       	call   8005f7 <_panic>
	assert(r <= PGSIZE);
  801a20:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a25:	7e 16                	jle    801a3d <devfile_read+0x65>
  801a27:	68 fb 28 80 00       	push   $0x8028fb
  801a2c:	68 db 28 80 00       	push   $0x8028db
  801a31:	6a 7d                	push   $0x7d
  801a33:	68 f0 28 80 00       	push   $0x8028f0
  801a38:	e8 ba eb ff ff       	call   8005f7 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a3d:	83 ec 04             	sub    $0x4,%esp
  801a40:	50                   	push   %eax
  801a41:	68 00 50 80 00       	push   $0x805000
  801a46:	ff 75 0c             	pushl  0xc(%ebp)
  801a49:	e8 b7 f3 ff ff       	call   800e05 <memmove>
	return r;
  801a4e:	83 c4 10             	add    $0x10,%esp
}
  801a51:	89 d8                	mov    %ebx,%eax
  801a53:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a56:	5b                   	pop    %ebx
  801a57:	5e                   	pop    %esi
  801a58:	5d                   	pop    %ebp
  801a59:	c3                   	ret    

00801a5a <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a5a:	55                   	push   %ebp
  801a5b:	89 e5                	mov    %esp,%ebp
  801a5d:	53                   	push   %ebx
  801a5e:	83 ec 20             	sub    $0x20,%esp
  801a61:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a64:	53                   	push   %ebx
  801a65:	e8 d0 f1 ff ff       	call   800c3a <strlen>
  801a6a:	83 c4 10             	add    $0x10,%esp
  801a6d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a72:	7f 67                	jg     801adb <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a74:	83 ec 0c             	sub    $0xc,%esp
  801a77:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a7a:	50                   	push   %eax
  801a7b:	e8 9a f8 ff ff       	call   80131a <fd_alloc>
  801a80:	83 c4 10             	add    $0x10,%esp
		return r;
  801a83:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a85:	85 c0                	test   %eax,%eax
  801a87:	78 57                	js     801ae0 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a89:	83 ec 08             	sub    $0x8,%esp
  801a8c:	53                   	push   %ebx
  801a8d:	68 00 50 80 00       	push   $0x805000
  801a92:	e8 dc f1 ff ff       	call   800c73 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a97:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a9a:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a9f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801aa2:	b8 01 00 00 00       	mov    $0x1,%eax
  801aa7:	e8 f6 fd ff ff       	call   8018a2 <fsipc>
  801aac:	89 c3                	mov    %eax,%ebx
  801aae:	83 c4 10             	add    $0x10,%esp
  801ab1:	85 c0                	test   %eax,%eax
  801ab3:	79 14                	jns    801ac9 <open+0x6f>
		fd_close(fd, 0);
  801ab5:	83 ec 08             	sub    $0x8,%esp
  801ab8:	6a 00                	push   $0x0
  801aba:	ff 75 f4             	pushl  -0xc(%ebp)
  801abd:	e8 50 f9 ff ff       	call   801412 <fd_close>
		return r;
  801ac2:	83 c4 10             	add    $0x10,%esp
  801ac5:	89 da                	mov    %ebx,%edx
  801ac7:	eb 17                	jmp    801ae0 <open+0x86>
	}

	return fd2num(fd);
  801ac9:	83 ec 0c             	sub    $0xc,%esp
  801acc:	ff 75 f4             	pushl  -0xc(%ebp)
  801acf:	e8 1f f8 ff ff       	call   8012f3 <fd2num>
  801ad4:	89 c2                	mov    %eax,%edx
  801ad6:	83 c4 10             	add    $0x10,%esp
  801ad9:	eb 05                	jmp    801ae0 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801adb:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801ae0:	89 d0                	mov    %edx,%eax
  801ae2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ae5:	c9                   	leave  
  801ae6:	c3                   	ret    

00801ae7 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801ae7:	55                   	push   %ebp
  801ae8:	89 e5                	mov    %esp,%ebp
  801aea:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801aed:	ba 00 00 00 00       	mov    $0x0,%edx
  801af2:	b8 08 00 00 00       	mov    $0x8,%eax
  801af7:	e8 a6 fd ff ff       	call   8018a2 <fsipc>
}
  801afc:	c9                   	leave  
  801afd:	c3                   	ret    

00801afe <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801afe:	55                   	push   %ebp
  801aff:	89 e5                	mov    %esp,%ebp
  801b01:	56                   	push   %esi
  801b02:	53                   	push   %ebx
  801b03:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b06:	83 ec 0c             	sub    $0xc,%esp
  801b09:	ff 75 08             	pushl  0x8(%ebp)
  801b0c:	e8 f2 f7 ff ff       	call   801303 <fd2data>
  801b11:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b13:	83 c4 08             	add    $0x8,%esp
  801b16:	68 07 29 80 00       	push   $0x802907
  801b1b:	53                   	push   %ebx
  801b1c:	e8 52 f1 ff ff       	call   800c73 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b21:	8b 46 04             	mov    0x4(%esi),%eax
  801b24:	2b 06                	sub    (%esi),%eax
  801b26:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b2c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b33:	00 00 00 
	stat->st_dev = &devpipe;
  801b36:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801b3d:	30 80 00 
	return 0;
}
  801b40:	b8 00 00 00 00       	mov    $0x0,%eax
  801b45:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b48:	5b                   	pop    %ebx
  801b49:	5e                   	pop    %esi
  801b4a:	5d                   	pop    %ebp
  801b4b:	c3                   	ret    

00801b4c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b4c:	55                   	push   %ebp
  801b4d:	89 e5                	mov    %esp,%ebp
  801b4f:	53                   	push   %ebx
  801b50:	83 ec 0c             	sub    $0xc,%esp
  801b53:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b56:	53                   	push   %ebx
  801b57:	6a 00                	push   $0x0
  801b59:	e8 9d f5 ff ff       	call   8010fb <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b5e:	89 1c 24             	mov    %ebx,(%esp)
  801b61:	e8 9d f7 ff ff       	call   801303 <fd2data>
  801b66:	83 c4 08             	add    $0x8,%esp
  801b69:	50                   	push   %eax
  801b6a:	6a 00                	push   $0x0
  801b6c:	e8 8a f5 ff ff       	call   8010fb <sys_page_unmap>
}
  801b71:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b74:	c9                   	leave  
  801b75:	c3                   	ret    

00801b76 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b76:	55                   	push   %ebp
  801b77:	89 e5                	mov    %esp,%ebp
  801b79:	57                   	push   %edi
  801b7a:	56                   	push   %esi
  801b7b:	53                   	push   %ebx
  801b7c:	83 ec 1c             	sub    $0x1c,%esp
  801b7f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b82:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b84:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801b89:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b8c:	83 ec 0c             	sub    $0xc,%esp
  801b8f:	ff 75 e0             	pushl  -0x20(%ebp)
  801b92:	e8 28 05 00 00       	call   8020bf <pageref>
  801b97:	89 c3                	mov    %eax,%ebx
  801b99:	89 3c 24             	mov    %edi,(%esp)
  801b9c:	e8 1e 05 00 00       	call   8020bf <pageref>
  801ba1:	83 c4 10             	add    $0x10,%esp
  801ba4:	39 c3                	cmp    %eax,%ebx
  801ba6:	0f 94 c1             	sete   %cl
  801ba9:	0f b6 c9             	movzbl %cl,%ecx
  801bac:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801baf:	8b 15 b0 40 80 00    	mov    0x8040b0,%edx
  801bb5:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801bb8:	39 ce                	cmp    %ecx,%esi
  801bba:	74 1b                	je     801bd7 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801bbc:	39 c3                	cmp    %eax,%ebx
  801bbe:	75 c4                	jne    801b84 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801bc0:	8b 42 58             	mov    0x58(%edx),%eax
  801bc3:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bc6:	50                   	push   %eax
  801bc7:	56                   	push   %esi
  801bc8:	68 0e 29 80 00       	push   $0x80290e
  801bcd:	e8 fe ea ff ff       	call   8006d0 <cprintf>
  801bd2:	83 c4 10             	add    $0x10,%esp
  801bd5:	eb ad                	jmp    801b84 <_pipeisclosed+0xe>
	}
}
  801bd7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bdd:	5b                   	pop    %ebx
  801bde:	5e                   	pop    %esi
  801bdf:	5f                   	pop    %edi
  801be0:	5d                   	pop    %ebp
  801be1:	c3                   	ret    

00801be2 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801be2:	55                   	push   %ebp
  801be3:	89 e5                	mov    %esp,%ebp
  801be5:	57                   	push   %edi
  801be6:	56                   	push   %esi
  801be7:	53                   	push   %ebx
  801be8:	83 ec 28             	sub    $0x28,%esp
  801beb:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801bee:	56                   	push   %esi
  801bef:	e8 0f f7 ff ff       	call   801303 <fd2data>
  801bf4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bf6:	83 c4 10             	add    $0x10,%esp
  801bf9:	bf 00 00 00 00       	mov    $0x0,%edi
  801bfe:	eb 4b                	jmp    801c4b <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c00:	89 da                	mov    %ebx,%edx
  801c02:	89 f0                	mov    %esi,%eax
  801c04:	e8 6d ff ff ff       	call   801b76 <_pipeisclosed>
  801c09:	85 c0                	test   %eax,%eax
  801c0b:	75 48                	jne    801c55 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c0d:	e8 45 f4 ff ff       	call   801057 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c12:	8b 43 04             	mov    0x4(%ebx),%eax
  801c15:	8b 0b                	mov    (%ebx),%ecx
  801c17:	8d 51 20             	lea    0x20(%ecx),%edx
  801c1a:	39 d0                	cmp    %edx,%eax
  801c1c:	73 e2                	jae    801c00 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c21:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c25:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c28:	89 c2                	mov    %eax,%edx
  801c2a:	c1 fa 1f             	sar    $0x1f,%edx
  801c2d:	89 d1                	mov    %edx,%ecx
  801c2f:	c1 e9 1b             	shr    $0x1b,%ecx
  801c32:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c35:	83 e2 1f             	and    $0x1f,%edx
  801c38:	29 ca                	sub    %ecx,%edx
  801c3a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c3e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c42:	83 c0 01             	add    $0x1,%eax
  801c45:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c48:	83 c7 01             	add    $0x1,%edi
  801c4b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c4e:	75 c2                	jne    801c12 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c50:	8b 45 10             	mov    0x10(%ebp),%eax
  801c53:	eb 05                	jmp    801c5a <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c55:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c5d:	5b                   	pop    %ebx
  801c5e:	5e                   	pop    %esi
  801c5f:	5f                   	pop    %edi
  801c60:	5d                   	pop    %ebp
  801c61:	c3                   	ret    

00801c62 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c62:	55                   	push   %ebp
  801c63:	89 e5                	mov    %esp,%ebp
  801c65:	57                   	push   %edi
  801c66:	56                   	push   %esi
  801c67:	53                   	push   %ebx
  801c68:	83 ec 18             	sub    $0x18,%esp
  801c6b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c6e:	57                   	push   %edi
  801c6f:	e8 8f f6 ff ff       	call   801303 <fd2data>
  801c74:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c76:	83 c4 10             	add    $0x10,%esp
  801c79:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c7e:	eb 3d                	jmp    801cbd <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c80:	85 db                	test   %ebx,%ebx
  801c82:	74 04                	je     801c88 <devpipe_read+0x26>
				return i;
  801c84:	89 d8                	mov    %ebx,%eax
  801c86:	eb 44                	jmp    801ccc <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c88:	89 f2                	mov    %esi,%edx
  801c8a:	89 f8                	mov    %edi,%eax
  801c8c:	e8 e5 fe ff ff       	call   801b76 <_pipeisclosed>
  801c91:	85 c0                	test   %eax,%eax
  801c93:	75 32                	jne    801cc7 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c95:	e8 bd f3 ff ff       	call   801057 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c9a:	8b 06                	mov    (%esi),%eax
  801c9c:	3b 46 04             	cmp    0x4(%esi),%eax
  801c9f:	74 df                	je     801c80 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ca1:	99                   	cltd   
  801ca2:	c1 ea 1b             	shr    $0x1b,%edx
  801ca5:	01 d0                	add    %edx,%eax
  801ca7:	83 e0 1f             	and    $0x1f,%eax
  801caa:	29 d0                	sub    %edx,%eax
  801cac:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801cb1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cb4:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801cb7:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cba:	83 c3 01             	add    $0x1,%ebx
  801cbd:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801cc0:	75 d8                	jne    801c9a <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801cc2:	8b 45 10             	mov    0x10(%ebp),%eax
  801cc5:	eb 05                	jmp    801ccc <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cc7:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801ccc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ccf:	5b                   	pop    %ebx
  801cd0:	5e                   	pop    %esi
  801cd1:	5f                   	pop    %edi
  801cd2:	5d                   	pop    %ebp
  801cd3:	c3                   	ret    

00801cd4 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801cd4:	55                   	push   %ebp
  801cd5:	89 e5                	mov    %esp,%ebp
  801cd7:	56                   	push   %esi
  801cd8:	53                   	push   %ebx
  801cd9:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801cdc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cdf:	50                   	push   %eax
  801ce0:	e8 35 f6 ff ff       	call   80131a <fd_alloc>
  801ce5:	83 c4 10             	add    $0x10,%esp
  801ce8:	89 c2                	mov    %eax,%edx
  801cea:	85 c0                	test   %eax,%eax
  801cec:	0f 88 2c 01 00 00    	js     801e1e <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cf2:	83 ec 04             	sub    $0x4,%esp
  801cf5:	68 07 04 00 00       	push   $0x407
  801cfa:	ff 75 f4             	pushl  -0xc(%ebp)
  801cfd:	6a 00                	push   $0x0
  801cff:	e8 72 f3 ff ff       	call   801076 <sys_page_alloc>
  801d04:	83 c4 10             	add    $0x10,%esp
  801d07:	89 c2                	mov    %eax,%edx
  801d09:	85 c0                	test   %eax,%eax
  801d0b:	0f 88 0d 01 00 00    	js     801e1e <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d11:	83 ec 0c             	sub    $0xc,%esp
  801d14:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d17:	50                   	push   %eax
  801d18:	e8 fd f5 ff ff       	call   80131a <fd_alloc>
  801d1d:	89 c3                	mov    %eax,%ebx
  801d1f:	83 c4 10             	add    $0x10,%esp
  801d22:	85 c0                	test   %eax,%eax
  801d24:	0f 88 e2 00 00 00    	js     801e0c <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d2a:	83 ec 04             	sub    $0x4,%esp
  801d2d:	68 07 04 00 00       	push   $0x407
  801d32:	ff 75 f0             	pushl  -0x10(%ebp)
  801d35:	6a 00                	push   $0x0
  801d37:	e8 3a f3 ff ff       	call   801076 <sys_page_alloc>
  801d3c:	89 c3                	mov    %eax,%ebx
  801d3e:	83 c4 10             	add    $0x10,%esp
  801d41:	85 c0                	test   %eax,%eax
  801d43:	0f 88 c3 00 00 00    	js     801e0c <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d49:	83 ec 0c             	sub    $0xc,%esp
  801d4c:	ff 75 f4             	pushl  -0xc(%ebp)
  801d4f:	e8 af f5 ff ff       	call   801303 <fd2data>
  801d54:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d56:	83 c4 0c             	add    $0xc,%esp
  801d59:	68 07 04 00 00       	push   $0x407
  801d5e:	50                   	push   %eax
  801d5f:	6a 00                	push   $0x0
  801d61:	e8 10 f3 ff ff       	call   801076 <sys_page_alloc>
  801d66:	89 c3                	mov    %eax,%ebx
  801d68:	83 c4 10             	add    $0x10,%esp
  801d6b:	85 c0                	test   %eax,%eax
  801d6d:	0f 88 89 00 00 00    	js     801dfc <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d73:	83 ec 0c             	sub    $0xc,%esp
  801d76:	ff 75 f0             	pushl  -0x10(%ebp)
  801d79:	e8 85 f5 ff ff       	call   801303 <fd2data>
  801d7e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d85:	50                   	push   %eax
  801d86:	6a 00                	push   $0x0
  801d88:	56                   	push   %esi
  801d89:	6a 00                	push   $0x0
  801d8b:	e8 29 f3 ff ff       	call   8010b9 <sys_page_map>
  801d90:	89 c3                	mov    %eax,%ebx
  801d92:	83 c4 20             	add    $0x20,%esp
  801d95:	85 c0                	test   %eax,%eax
  801d97:	78 55                	js     801dee <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d99:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801da2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801da4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801da7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801dae:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801db4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801db7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801db9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dbc:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801dc3:	83 ec 0c             	sub    $0xc,%esp
  801dc6:	ff 75 f4             	pushl  -0xc(%ebp)
  801dc9:	e8 25 f5 ff ff       	call   8012f3 <fd2num>
  801dce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dd1:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801dd3:	83 c4 04             	add    $0x4,%esp
  801dd6:	ff 75 f0             	pushl  -0x10(%ebp)
  801dd9:	e8 15 f5 ff ff       	call   8012f3 <fd2num>
  801dde:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801de1:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801de4:	83 c4 10             	add    $0x10,%esp
  801de7:	ba 00 00 00 00       	mov    $0x0,%edx
  801dec:	eb 30                	jmp    801e1e <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801dee:	83 ec 08             	sub    $0x8,%esp
  801df1:	56                   	push   %esi
  801df2:	6a 00                	push   $0x0
  801df4:	e8 02 f3 ff ff       	call   8010fb <sys_page_unmap>
  801df9:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801dfc:	83 ec 08             	sub    $0x8,%esp
  801dff:	ff 75 f0             	pushl  -0x10(%ebp)
  801e02:	6a 00                	push   $0x0
  801e04:	e8 f2 f2 ff ff       	call   8010fb <sys_page_unmap>
  801e09:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e0c:	83 ec 08             	sub    $0x8,%esp
  801e0f:	ff 75 f4             	pushl  -0xc(%ebp)
  801e12:	6a 00                	push   $0x0
  801e14:	e8 e2 f2 ff ff       	call   8010fb <sys_page_unmap>
  801e19:	83 c4 10             	add    $0x10,%esp
  801e1c:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e1e:	89 d0                	mov    %edx,%eax
  801e20:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e23:	5b                   	pop    %ebx
  801e24:	5e                   	pop    %esi
  801e25:	5d                   	pop    %ebp
  801e26:	c3                   	ret    

00801e27 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e27:	55                   	push   %ebp
  801e28:	89 e5                	mov    %esp,%ebp
  801e2a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e2d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e30:	50                   	push   %eax
  801e31:	ff 75 08             	pushl  0x8(%ebp)
  801e34:	e8 30 f5 ff ff       	call   801369 <fd_lookup>
  801e39:	83 c4 10             	add    $0x10,%esp
  801e3c:	85 c0                	test   %eax,%eax
  801e3e:	78 18                	js     801e58 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e40:	83 ec 0c             	sub    $0xc,%esp
  801e43:	ff 75 f4             	pushl  -0xc(%ebp)
  801e46:	e8 b8 f4 ff ff       	call   801303 <fd2data>
	return _pipeisclosed(fd, p);
  801e4b:	89 c2                	mov    %eax,%edx
  801e4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e50:	e8 21 fd ff ff       	call   801b76 <_pipeisclosed>
  801e55:	83 c4 10             	add    $0x10,%esp
}
  801e58:	c9                   	leave  
  801e59:	c3                   	ret    

00801e5a <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e5a:	55                   	push   %ebp
  801e5b:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e5d:	b8 00 00 00 00       	mov    $0x0,%eax
  801e62:	5d                   	pop    %ebp
  801e63:	c3                   	ret    

00801e64 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e64:	55                   	push   %ebp
  801e65:	89 e5                	mov    %esp,%ebp
  801e67:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e6a:	68 26 29 80 00       	push   $0x802926
  801e6f:	ff 75 0c             	pushl  0xc(%ebp)
  801e72:	e8 fc ed ff ff       	call   800c73 <strcpy>
	return 0;
}
  801e77:	b8 00 00 00 00       	mov    $0x0,%eax
  801e7c:	c9                   	leave  
  801e7d:	c3                   	ret    

00801e7e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e7e:	55                   	push   %ebp
  801e7f:	89 e5                	mov    %esp,%ebp
  801e81:	57                   	push   %edi
  801e82:	56                   	push   %esi
  801e83:	53                   	push   %ebx
  801e84:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e8a:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e8f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e95:	eb 2d                	jmp    801ec4 <devcons_write+0x46>
		m = n - tot;
  801e97:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e9a:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e9c:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e9f:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801ea4:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ea7:	83 ec 04             	sub    $0x4,%esp
  801eaa:	53                   	push   %ebx
  801eab:	03 45 0c             	add    0xc(%ebp),%eax
  801eae:	50                   	push   %eax
  801eaf:	57                   	push   %edi
  801eb0:	e8 50 ef ff ff       	call   800e05 <memmove>
		sys_cputs(buf, m);
  801eb5:	83 c4 08             	add    $0x8,%esp
  801eb8:	53                   	push   %ebx
  801eb9:	57                   	push   %edi
  801eba:	e8 fb f0 ff ff       	call   800fba <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ebf:	01 de                	add    %ebx,%esi
  801ec1:	83 c4 10             	add    $0x10,%esp
  801ec4:	89 f0                	mov    %esi,%eax
  801ec6:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ec9:	72 cc                	jb     801e97 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ecb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ece:	5b                   	pop    %ebx
  801ecf:	5e                   	pop    %esi
  801ed0:	5f                   	pop    %edi
  801ed1:	5d                   	pop    %ebp
  801ed2:	c3                   	ret    

00801ed3 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ed3:	55                   	push   %ebp
  801ed4:	89 e5                	mov    %esp,%ebp
  801ed6:	83 ec 08             	sub    $0x8,%esp
  801ed9:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801ede:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ee2:	74 2a                	je     801f0e <devcons_read+0x3b>
  801ee4:	eb 05                	jmp    801eeb <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801ee6:	e8 6c f1 ff ff       	call   801057 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801eeb:	e8 e8 f0 ff ff       	call   800fd8 <sys_cgetc>
  801ef0:	85 c0                	test   %eax,%eax
  801ef2:	74 f2                	je     801ee6 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801ef4:	85 c0                	test   %eax,%eax
  801ef6:	78 16                	js     801f0e <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ef8:	83 f8 04             	cmp    $0x4,%eax
  801efb:	74 0c                	je     801f09 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801efd:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f00:	88 02                	mov    %al,(%edx)
	return 1;
  801f02:	b8 01 00 00 00       	mov    $0x1,%eax
  801f07:	eb 05                	jmp    801f0e <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f09:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f0e:	c9                   	leave  
  801f0f:	c3                   	ret    

00801f10 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f10:	55                   	push   %ebp
  801f11:	89 e5                	mov    %esp,%ebp
  801f13:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f16:	8b 45 08             	mov    0x8(%ebp),%eax
  801f19:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f1c:	6a 01                	push   $0x1
  801f1e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f21:	50                   	push   %eax
  801f22:	e8 93 f0 ff ff       	call   800fba <sys_cputs>
}
  801f27:	83 c4 10             	add    $0x10,%esp
  801f2a:	c9                   	leave  
  801f2b:	c3                   	ret    

00801f2c <getchar>:

int
getchar(void)
{
  801f2c:	55                   	push   %ebp
  801f2d:	89 e5                	mov    %esp,%ebp
  801f2f:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f32:	6a 01                	push   $0x1
  801f34:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f37:	50                   	push   %eax
  801f38:	6a 00                	push   $0x0
  801f3a:	e8 90 f6 ff ff       	call   8015cf <read>
	if (r < 0)
  801f3f:	83 c4 10             	add    $0x10,%esp
  801f42:	85 c0                	test   %eax,%eax
  801f44:	78 0f                	js     801f55 <getchar+0x29>
		return r;
	if (r < 1)
  801f46:	85 c0                	test   %eax,%eax
  801f48:	7e 06                	jle    801f50 <getchar+0x24>
		return -E_EOF;
	return c;
  801f4a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f4e:	eb 05                	jmp    801f55 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f50:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f55:	c9                   	leave  
  801f56:	c3                   	ret    

00801f57 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f57:	55                   	push   %ebp
  801f58:	89 e5                	mov    %esp,%ebp
  801f5a:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f5d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f60:	50                   	push   %eax
  801f61:	ff 75 08             	pushl  0x8(%ebp)
  801f64:	e8 00 f4 ff ff       	call   801369 <fd_lookup>
  801f69:	83 c4 10             	add    $0x10,%esp
  801f6c:	85 c0                	test   %eax,%eax
  801f6e:	78 11                	js     801f81 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f70:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f73:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f79:	39 10                	cmp    %edx,(%eax)
  801f7b:	0f 94 c0             	sete   %al
  801f7e:	0f b6 c0             	movzbl %al,%eax
}
  801f81:	c9                   	leave  
  801f82:	c3                   	ret    

00801f83 <opencons>:

int
opencons(void)
{
  801f83:	55                   	push   %ebp
  801f84:	89 e5                	mov    %esp,%ebp
  801f86:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f89:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f8c:	50                   	push   %eax
  801f8d:	e8 88 f3 ff ff       	call   80131a <fd_alloc>
  801f92:	83 c4 10             	add    $0x10,%esp
		return r;
  801f95:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f97:	85 c0                	test   %eax,%eax
  801f99:	78 3e                	js     801fd9 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f9b:	83 ec 04             	sub    $0x4,%esp
  801f9e:	68 07 04 00 00       	push   $0x407
  801fa3:	ff 75 f4             	pushl  -0xc(%ebp)
  801fa6:	6a 00                	push   $0x0
  801fa8:	e8 c9 f0 ff ff       	call   801076 <sys_page_alloc>
  801fad:	83 c4 10             	add    $0x10,%esp
		return r;
  801fb0:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fb2:	85 c0                	test   %eax,%eax
  801fb4:	78 23                	js     801fd9 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801fb6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fbf:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801fc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fc4:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801fcb:	83 ec 0c             	sub    $0xc,%esp
  801fce:	50                   	push   %eax
  801fcf:	e8 1f f3 ff ff       	call   8012f3 <fd2num>
  801fd4:	89 c2                	mov    %eax,%edx
  801fd6:	83 c4 10             	add    $0x10,%esp
}
  801fd9:	89 d0                	mov    %edx,%eax
  801fdb:	c9                   	leave  
  801fdc:	c3                   	ret    

00801fdd <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801fdd:	55                   	push   %ebp
  801fde:	89 e5                	mov    %esp,%ebp
  801fe0:	56                   	push   %esi
  801fe1:	53                   	push   %ebx
  801fe2:	8b 75 08             	mov    0x8(%ebp),%esi
  801fe5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fe8:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_recv not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  801feb:	85 c0                	test   %eax,%eax
  801fed:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801ff2:	0f 44 c2             	cmove  %edx,%eax

    int r = sys_ipc_recv(pg);
  801ff5:	83 ec 0c             	sub    $0xc,%esp
  801ff8:	50                   	push   %eax
  801ff9:	e8 28 f2 ff ff       	call   801226 <sys_ipc_recv>
    int from_env = 0, perm = 0;
    if (r == 0) {
  801ffe:	83 c4 10             	add    $0x10,%esp
  802001:	85 c0                	test   %eax,%eax
  802003:	75 10                	jne    802015 <ipc_recv+0x38>
        from_env = thisenv->env_ipc_from;
  802005:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  80200a:	8b 48 74             	mov    0x74(%eax),%ecx
        perm = thisenv->env_ipc_perm;
  80200d:	8b 50 78             	mov    0x78(%eax),%edx
        r = thisenv->env_ipc_value;
  802010:	8b 40 70             	mov    0x70(%eax),%eax
  802013:	eb 0a                	jmp    80201f <ipc_recv+0x42>
    } else {
        from_env = 0;
        perm = 0;
  802015:	ba 00 00 00 00       	mov    $0x0,%edx
    if (r == 0) {
        from_env = thisenv->env_ipc_from;
        perm = thisenv->env_ipc_perm;
        r = thisenv->env_ipc_value;
    } else {
        from_env = 0;
  80201a:	b9 00 00 00 00       	mov    $0x0,%ecx
        perm = 0;
    }

    if (from_env_store) *from_env_store = from_env;
  80201f:	85 f6                	test   %esi,%esi
  802021:	74 02                	je     802025 <ipc_recv+0x48>
  802023:	89 0e                	mov    %ecx,(%esi)
    if (perm_store) *perm_store = perm;
  802025:	85 db                	test   %ebx,%ebx
  802027:	74 02                	je     80202b <ipc_recv+0x4e>
  802029:	89 13                	mov    %edx,(%ebx)

    return r;
}
  80202b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80202e:	5b                   	pop    %ebx
  80202f:	5e                   	pop    %esi
  802030:	5d                   	pop    %ebp
  802031:	c3                   	ret    

00802032 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802032:	55                   	push   %ebp
  802033:	89 e5                	mov    %esp,%ebp
  802035:	57                   	push   %edi
  802036:	56                   	push   %esi
  802037:	53                   	push   %ebx
  802038:	83 ec 0c             	sub    $0xc,%esp
  80203b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80203e:	8b 75 0c             	mov    0xc(%ebp),%esi
  802041:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  802044:	85 db                	test   %ebx,%ebx
  802046:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80204b:	0f 44 d8             	cmove  %eax,%ebx
  80204e:	eb 1c                	jmp    80206c <ipc_send+0x3a>

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        if (ret != -E_IPC_NOT_RECV)
  802050:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802053:	74 12                	je     802067 <ipc_send+0x35>
            panic("ipc_send error %e", ret);
  802055:	50                   	push   %eax
  802056:	68 32 29 80 00       	push   $0x802932
  80205b:	6a 40                	push   $0x40
  80205d:	68 44 29 80 00       	push   $0x802944
  802062:	e8 90 e5 ff ff       	call   8005f7 <_panic>
        sys_yield();
  802067:	e8 eb ef ff ff       	call   801057 <sys_yield>
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  80206c:	ff 75 14             	pushl  0x14(%ebp)
  80206f:	53                   	push   %ebx
  802070:	56                   	push   %esi
  802071:	57                   	push   %edi
  802072:	e8 8c f1 ff ff       	call   801203 <sys_ipc_try_send>
  802077:	83 c4 10             	add    $0x10,%esp
  80207a:	85 c0                	test   %eax,%eax
  80207c:	75 d2                	jne    802050 <ipc_send+0x1e>
        if (ret != -E_IPC_NOT_RECV)
            panic("ipc_send error %e", ret);
        sys_yield();
    }
}
  80207e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802081:	5b                   	pop    %ebx
  802082:	5e                   	pop    %esi
  802083:	5f                   	pop    %edi
  802084:	5d                   	pop    %ebp
  802085:	c3                   	ret    

00802086 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802086:	55                   	push   %ebp
  802087:	89 e5                	mov    %esp,%ebp
  802089:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80208c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802091:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802094:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80209a:	8b 52 50             	mov    0x50(%edx),%edx
  80209d:	39 ca                	cmp    %ecx,%edx
  80209f:	75 0d                	jne    8020ae <ipc_find_env+0x28>
			return envs[i].env_id;
  8020a1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8020a4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8020a9:	8b 40 48             	mov    0x48(%eax),%eax
  8020ac:	eb 0f                	jmp    8020bd <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8020ae:	83 c0 01             	add    $0x1,%eax
  8020b1:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020b6:	75 d9                	jne    802091 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8020b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8020bd:	5d                   	pop    %ebp
  8020be:	c3                   	ret    

008020bf <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020bf:	55                   	push   %ebp
  8020c0:	89 e5                	mov    %esp,%ebp
  8020c2:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020c5:	89 d0                	mov    %edx,%eax
  8020c7:	c1 e8 16             	shr    $0x16,%eax
  8020ca:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8020d1:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020d6:	f6 c1 01             	test   $0x1,%cl
  8020d9:	74 1d                	je     8020f8 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8020db:	c1 ea 0c             	shr    $0xc,%edx
  8020de:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8020e5:	f6 c2 01             	test   $0x1,%dl
  8020e8:	74 0e                	je     8020f8 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020ea:	c1 ea 0c             	shr    $0xc,%edx
  8020ed:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8020f4:	ef 
  8020f5:	0f b7 c0             	movzwl %ax,%eax
}
  8020f8:	5d                   	pop    %ebp
  8020f9:	c3                   	ret    
  8020fa:	66 90                	xchg   %ax,%ax
  8020fc:	66 90                	xchg   %ax,%ax
  8020fe:	66 90                	xchg   %ax,%ax

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
