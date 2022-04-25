
obj/user/faultnostack.debug:     file format elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  800039:	68 61 03 80 00       	push   $0x800361
  80003e:	6a 00                	push   $0x0
  800040:	e8 76 02 00 00       	call   8002bb <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800045:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80004c:	00 00 00 
}
  80004f:	83 c4 10             	add    $0x10,%esp
  800052:	c9                   	leave  
  800053:	c3                   	ret    

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	56                   	push   %esi
  800058:	53                   	push   %ebx
  800059:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  80005f:	e8 ce 00 00 00       	call   800132 <sys_getenvid>
  800064:	25 ff 03 00 00       	and    $0x3ff,%eax
  800069:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800071:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800076:	85 db                	test   %ebx,%ebx
  800078:	7e 07                	jle    800081 <libmain+0x2d>
		binaryname = argv[0];
  80007a:	8b 06                	mov    (%esi),%eax
  80007c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800081:	83 ec 08             	sub    $0x8,%esp
  800084:	56                   	push   %esi
  800085:	53                   	push   %ebx
  800086:	e8 a8 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008b:	e8 0a 00 00 00       	call   80009a <exit>
}
  800090:	83 c4 10             	add    $0x10,%esp
  800093:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800096:	5b                   	pop    %ebx
  800097:	5e                   	pop    %esi
  800098:	5d                   	pop    %ebp
  800099:	c3                   	ret    

0080009a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000a0:	e8 ab 04 00 00       	call   800550 <close_all>
	sys_env_destroy(0);
  8000a5:	83 ec 0c             	sub    $0xc,%esp
  8000a8:	6a 00                	push   $0x0
  8000aa:	e8 42 00 00 00       	call   8000f1 <sys_env_destroy>
}
  8000af:	83 c4 10             	add    $0x10,%esp
  8000b2:	c9                   	leave  
  8000b3:	c3                   	ret    

008000b4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	57                   	push   %edi
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8000bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c5:	89 c3                	mov    %eax,%ebx
  8000c7:	89 c7                	mov    %eax,%edi
  8000c9:	89 c6                	mov    %eax,%esi
  8000cb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000cd:	5b                   	pop    %ebx
  8000ce:	5e                   	pop    %esi
  8000cf:	5f                   	pop    %edi
  8000d0:	5d                   	pop    %ebp
  8000d1:	c3                   	ret    

008000d2 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d2:	55                   	push   %ebp
  8000d3:	89 e5                	mov    %esp,%ebp
  8000d5:	57                   	push   %edi
  8000d6:	56                   	push   %esi
  8000d7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8000dd:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e2:	89 d1                	mov    %edx,%ecx
  8000e4:	89 d3                	mov    %edx,%ebx
  8000e6:	89 d7                	mov    %edx,%edi
  8000e8:	89 d6                	mov    %edx,%esi
  8000ea:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ec:	5b                   	pop    %ebx
  8000ed:	5e                   	pop    %esi
  8000ee:	5f                   	pop    %edi
  8000ef:	5d                   	pop    %ebp
  8000f0:	c3                   	ret    

008000f1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f1:	55                   	push   %ebp
  8000f2:	89 e5                	mov    %esp,%ebp
  8000f4:	57                   	push   %edi
  8000f5:	56                   	push   %esi
  8000f6:	53                   	push   %ebx
  8000f7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ff:	b8 03 00 00 00       	mov    $0x3,%eax
  800104:	8b 55 08             	mov    0x8(%ebp),%edx
  800107:	89 cb                	mov    %ecx,%ebx
  800109:	89 cf                	mov    %ecx,%edi
  80010b:	89 ce                	mov    %ecx,%esi
  80010d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80010f:	85 c0                	test   %eax,%eax
  800111:	7e 17                	jle    80012a <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800113:	83 ec 0c             	sub    $0xc,%esp
  800116:	50                   	push   %eax
  800117:	6a 03                	push   $0x3
  800119:	68 6a 1e 80 00       	push   $0x801e6a
  80011e:	6a 23                	push   $0x23
  800120:	68 87 1e 80 00       	push   $0x801e87
  800125:	e8 45 0f 00 00       	call   80106f <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80012a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80012d:	5b                   	pop    %ebx
  80012e:	5e                   	pop    %esi
  80012f:	5f                   	pop    %edi
  800130:	5d                   	pop    %ebp
  800131:	c3                   	ret    

00800132 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800132:	55                   	push   %ebp
  800133:	89 e5                	mov    %esp,%ebp
  800135:	57                   	push   %edi
  800136:	56                   	push   %esi
  800137:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800138:	ba 00 00 00 00       	mov    $0x0,%edx
  80013d:	b8 02 00 00 00       	mov    $0x2,%eax
  800142:	89 d1                	mov    %edx,%ecx
  800144:	89 d3                	mov    %edx,%ebx
  800146:	89 d7                	mov    %edx,%edi
  800148:	89 d6                	mov    %edx,%esi
  80014a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80014c:	5b                   	pop    %ebx
  80014d:	5e                   	pop    %esi
  80014e:	5f                   	pop    %edi
  80014f:	5d                   	pop    %ebp
  800150:	c3                   	ret    

00800151 <sys_yield>:

void
sys_yield(void)
{
  800151:	55                   	push   %ebp
  800152:	89 e5                	mov    %esp,%ebp
  800154:	57                   	push   %edi
  800155:	56                   	push   %esi
  800156:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800157:	ba 00 00 00 00       	mov    $0x0,%edx
  80015c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800161:	89 d1                	mov    %edx,%ecx
  800163:	89 d3                	mov    %edx,%ebx
  800165:	89 d7                	mov    %edx,%edi
  800167:	89 d6                	mov    %edx,%esi
  800169:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80016b:	5b                   	pop    %ebx
  80016c:	5e                   	pop    %esi
  80016d:	5f                   	pop    %edi
  80016e:	5d                   	pop    %ebp
  80016f:	c3                   	ret    

00800170 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	57                   	push   %edi
  800174:	56                   	push   %esi
  800175:	53                   	push   %ebx
  800176:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800179:	be 00 00 00 00       	mov    $0x0,%esi
  80017e:	b8 04 00 00 00       	mov    $0x4,%eax
  800183:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800186:	8b 55 08             	mov    0x8(%ebp),%edx
  800189:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80018c:	89 f7                	mov    %esi,%edi
  80018e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800190:	85 c0                	test   %eax,%eax
  800192:	7e 17                	jle    8001ab <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800194:	83 ec 0c             	sub    $0xc,%esp
  800197:	50                   	push   %eax
  800198:	6a 04                	push   $0x4
  80019a:	68 6a 1e 80 00       	push   $0x801e6a
  80019f:	6a 23                	push   $0x23
  8001a1:	68 87 1e 80 00       	push   $0x801e87
  8001a6:	e8 c4 0e 00 00       	call   80106f <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ae:	5b                   	pop    %ebx
  8001af:	5e                   	pop    %esi
  8001b0:	5f                   	pop    %edi
  8001b1:	5d                   	pop    %ebp
  8001b2:	c3                   	ret    

008001b3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001b3:	55                   	push   %ebp
  8001b4:	89 e5                	mov    %esp,%ebp
  8001b6:	57                   	push   %edi
  8001b7:	56                   	push   %esi
  8001b8:	53                   	push   %ebx
  8001b9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001bc:	b8 05 00 00 00       	mov    $0x5,%eax
  8001c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ca:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001cd:	8b 75 18             	mov    0x18(%ebp),%esi
  8001d0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001d2:	85 c0                	test   %eax,%eax
  8001d4:	7e 17                	jle    8001ed <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d6:	83 ec 0c             	sub    $0xc,%esp
  8001d9:	50                   	push   %eax
  8001da:	6a 05                	push   $0x5
  8001dc:	68 6a 1e 80 00       	push   $0x801e6a
  8001e1:	6a 23                	push   $0x23
  8001e3:	68 87 1e 80 00       	push   $0x801e87
  8001e8:	e8 82 0e 00 00       	call   80106f <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001f0:	5b                   	pop    %ebx
  8001f1:	5e                   	pop    %esi
  8001f2:	5f                   	pop    %edi
  8001f3:	5d                   	pop    %ebp
  8001f4:	c3                   	ret    

008001f5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001f5:	55                   	push   %ebp
  8001f6:	89 e5                	mov    %esp,%ebp
  8001f8:	57                   	push   %edi
  8001f9:	56                   	push   %esi
  8001fa:	53                   	push   %ebx
  8001fb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001fe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800203:	b8 06 00 00 00       	mov    $0x6,%eax
  800208:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80020b:	8b 55 08             	mov    0x8(%ebp),%edx
  80020e:	89 df                	mov    %ebx,%edi
  800210:	89 de                	mov    %ebx,%esi
  800212:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800214:	85 c0                	test   %eax,%eax
  800216:	7e 17                	jle    80022f <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800218:	83 ec 0c             	sub    $0xc,%esp
  80021b:	50                   	push   %eax
  80021c:	6a 06                	push   $0x6
  80021e:	68 6a 1e 80 00       	push   $0x801e6a
  800223:	6a 23                	push   $0x23
  800225:	68 87 1e 80 00       	push   $0x801e87
  80022a:	e8 40 0e 00 00       	call   80106f <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80022f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800232:	5b                   	pop    %ebx
  800233:	5e                   	pop    %esi
  800234:	5f                   	pop    %edi
  800235:	5d                   	pop    %ebp
  800236:	c3                   	ret    

00800237 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800237:	55                   	push   %ebp
  800238:	89 e5                	mov    %esp,%ebp
  80023a:	57                   	push   %edi
  80023b:	56                   	push   %esi
  80023c:	53                   	push   %ebx
  80023d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800240:	bb 00 00 00 00       	mov    $0x0,%ebx
  800245:	b8 08 00 00 00       	mov    $0x8,%eax
  80024a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80024d:	8b 55 08             	mov    0x8(%ebp),%edx
  800250:	89 df                	mov    %ebx,%edi
  800252:	89 de                	mov    %ebx,%esi
  800254:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800256:	85 c0                	test   %eax,%eax
  800258:	7e 17                	jle    800271 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80025a:	83 ec 0c             	sub    $0xc,%esp
  80025d:	50                   	push   %eax
  80025e:	6a 08                	push   $0x8
  800260:	68 6a 1e 80 00       	push   $0x801e6a
  800265:	6a 23                	push   $0x23
  800267:	68 87 1e 80 00       	push   $0x801e87
  80026c:	e8 fe 0d 00 00       	call   80106f <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800271:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800274:	5b                   	pop    %ebx
  800275:	5e                   	pop    %esi
  800276:	5f                   	pop    %edi
  800277:	5d                   	pop    %ebp
  800278:	c3                   	ret    

00800279 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800279:	55                   	push   %ebp
  80027a:	89 e5                	mov    %esp,%ebp
  80027c:	57                   	push   %edi
  80027d:	56                   	push   %esi
  80027e:	53                   	push   %ebx
  80027f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800282:	bb 00 00 00 00       	mov    $0x0,%ebx
  800287:	b8 09 00 00 00       	mov    $0x9,%eax
  80028c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80028f:	8b 55 08             	mov    0x8(%ebp),%edx
  800292:	89 df                	mov    %ebx,%edi
  800294:	89 de                	mov    %ebx,%esi
  800296:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800298:	85 c0                	test   %eax,%eax
  80029a:	7e 17                	jle    8002b3 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80029c:	83 ec 0c             	sub    $0xc,%esp
  80029f:	50                   	push   %eax
  8002a0:	6a 09                	push   $0x9
  8002a2:	68 6a 1e 80 00       	push   $0x801e6a
  8002a7:	6a 23                	push   $0x23
  8002a9:	68 87 1e 80 00       	push   $0x801e87
  8002ae:	e8 bc 0d 00 00       	call   80106f <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b6:	5b                   	pop    %ebx
  8002b7:	5e                   	pop    %esi
  8002b8:	5f                   	pop    %edi
  8002b9:	5d                   	pop    %ebp
  8002ba:	c3                   	ret    

008002bb <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002bb:	55                   	push   %ebp
  8002bc:	89 e5                	mov    %esp,%ebp
  8002be:	57                   	push   %edi
  8002bf:	56                   	push   %esi
  8002c0:	53                   	push   %ebx
  8002c1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002c4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002d1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d4:	89 df                	mov    %ebx,%edi
  8002d6:	89 de                	mov    %ebx,%esi
  8002d8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002da:	85 c0                	test   %eax,%eax
  8002dc:	7e 17                	jle    8002f5 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002de:	83 ec 0c             	sub    $0xc,%esp
  8002e1:	50                   	push   %eax
  8002e2:	6a 0a                	push   $0xa
  8002e4:	68 6a 1e 80 00       	push   $0x801e6a
  8002e9:	6a 23                	push   $0x23
  8002eb:	68 87 1e 80 00       	push   $0x801e87
  8002f0:	e8 7a 0d 00 00       	call   80106f <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f8:	5b                   	pop    %ebx
  8002f9:	5e                   	pop    %esi
  8002fa:	5f                   	pop    %edi
  8002fb:	5d                   	pop    %ebp
  8002fc:	c3                   	ret    

008002fd <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002fd:	55                   	push   %ebp
  8002fe:	89 e5                	mov    %esp,%ebp
  800300:	57                   	push   %edi
  800301:	56                   	push   %esi
  800302:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800303:	be 00 00 00 00       	mov    $0x0,%esi
  800308:	b8 0c 00 00 00       	mov    $0xc,%eax
  80030d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800310:	8b 55 08             	mov    0x8(%ebp),%edx
  800313:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800316:	8b 7d 14             	mov    0x14(%ebp),%edi
  800319:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80031b:	5b                   	pop    %ebx
  80031c:	5e                   	pop    %esi
  80031d:	5f                   	pop    %edi
  80031e:	5d                   	pop    %ebp
  80031f:	c3                   	ret    

00800320 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	57                   	push   %edi
  800324:	56                   	push   %esi
  800325:	53                   	push   %ebx
  800326:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800329:	b9 00 00 00 00       	mov    $0x0,%ecx
  80032e:	b8 0d 00 00 00       	mov    $0xd,%eax
  800333:	8b 55 08             	mov    0x8(%ebp),%edx
  800336:	89 cb                	mov    %ecx,%ebx
  800338:	89 cf                	mov    %ecx,%edi
  80033a:	89 ce                	mov    %ecx,%esi
  80033c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80033e:	85 c0                	test   %eax,%eax
  800340:	7e 17                	jle    800359 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800342:	83 ec 0c             	sub    $0xc,%esp
  800345:	50                   	push   %eax
  800346:	6a 0d                	push   $0xd
  800348:	68 6a 1e 80 00       	push   $0x801e6a
  80034d:	6a 23                	push   $0x23
  80034f:	68 87 1e 80 00       	push   $0x801e87
  800354:	e8 16 0d 00 00       	call   80106f <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800359:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80035c:	5b                   	pop    %ebx
  80035d:	5e                   	pop    %esi
  80035e:	5f                   	pop    %edi
  80035f:	5d                   	pop    %ebp
  800360:	c3                   	ret    

00800361 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800361:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800362:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  800367:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800369:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 0x28(%esp), %ebx  # trap-time eip
  80036c:	8b 5c 24 28          	mov    0x28(%esp),%ebx
        subl $0x4, 0x30(%esp)  # trap-time esp minus 4
  800370:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax 
  800375:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl %ebx, (%eax)      # trap-time esp store trap-time eip
  800379:	89 18                	mov    %ebx,(%eax)
        addl $0x8, %esp
  80037b:	83 c4 08             	add    $0x8,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  80037e:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  80037f:	83 c4 04             	add    $0x4,%esp
        popfl
  800382:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  800383:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  800384:	c3                   	ret    

00800385 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800385:	55                   	push   %ebp
  800386:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800388:	8b 45 08             	mov    0x8(%ebp),%eax
  80038b:	05 00 00 00 30       	add    $0x30000000,%eax
  800390:	c1 e8 0c             	shr    $0xc,%eax
}
  800393:	5d                   	pop    %ebp
  800394:	c3                   	ret    

00800395 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800395:	55                   	push   %ebp
  800396:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800398:	8b 45 08             	mov    0x8(%ebp),%eax
  80039b:	05 00 00 00 30       	add    $0x30000000,%eax
  8003a0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003a5:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003aa:	5d                   	pop    %ebp
  8003ab:	c3                   	ret    

008003ac <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003ac:	55                   	push   %ebp
  8003ad:	89 e5                	mov    %esp,%ebp
  8003af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003b2:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003b7:	89 c2                	mov    %eax,%edx
  8003b9:	c1 ea 16             	shr    $0x16,%edx
  8003bc:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003c3:	f6 c2 01             	test   $0x1,%dl
  8003c6:	74 11                	je     8003d9 <fd_alloc+0x2d>
  8003c8:	89 c2                	mov    %eax,%edx
  8003ca:	c1 ea 0c             	shr    $0xc,%edx
  8003cd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003d4:	f6 c2 01             	test   $0x1,%dl
  8003d7:	75 09                	jne    8003e2 <fd_alloc+0x36>
			*fd_store = fd;
  8003d9:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003db:	b8 00 00 00 00       	mov    $0x0,%eax
  8003e0:	eb 17                	jmp    8003f9 <fd_alloc+0x4d>
  8003e2:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003e7:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003ec:	75 c9                	jne    8003b7 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003ee:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003f4:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003f9:	5d                   	pop    %ebp
  8003fa:	c3                   	ret    

008003fb <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003fb:	55                   	push   %ebp
  8003fc:	89 e5                	mov    %esp,%ebp
  8003fe:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800401:	83 f8 1f             	cmp    $0x1f,%eax
  800404:	77 36                	ja     80043c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800406:	c1 e0 0c             	shl    $0xc,%eax
  800409:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80040e:	89 c2                	mov    %eax,%edx
  800410:	c1 ea 16             	shr    $0x16,%edx
  800413:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80041a:	f6 c2 01             	test   $0x1,%dl
  80041d:	74 24                	je     800443 <fd_lookup+0x48>
  80041f:	89 c2                	mov    %eax,%edx
  800421:	c1 ea 0c             	shr    $0xc,%edx
  800424:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80042b:	f6 c2 01             	test   $0x1,%dl
  80042e:	74 1a                	je     80044a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800430:	8b 55 0c             	mov    0xc(%ebp),%edx
  800433:	89 02                	mov    %eax,(%edx)
	return 0;
  800435:	b8 00 00 00 00       	mov    $0x0,%eax
  80043a:	eb 13                	jmp    80044f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80043c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800441:	eb 0c                	jmp    80044f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800443:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800448:	eb 05                	jmp    80044f <fd_lookup+0x54>
  80044a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80044f:	5d                   	pop    %ebp
  800450:	c3                   	ret    

00800451 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800451:	55                   	push   %ebp
  800452:	89 e5                	mov    %esp,%ebp
  800454:	83 ec 08             	sub    $0x8,%esp
  800457:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80045a:	ba 14 1f 80 00       	mov    $0x801f14,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80045f:	eb 13                	jmp    800474 <dev_lookup+0x23>
  800461:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800464:	39 08                	cmp    %ecx,(%eax)
  800466:	75 0c                	jne    800474 <dev_lookup+0x23>
			*dev = devtab[i];
  800468:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80046b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80046d:	b8 00 00 00 00       	mov    $0x0,%eax
  800472:	eb 2e                	jmp    8004a2 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800474:	8b 02                	mov    (%edx),%eax
  800476:	85 c0                	test   %eax,%eax
  800478:	75 e7                	jne    800461 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80047a:	a1 04 40 80 00       	mov    0x804004,%eax
  80047f:	8b 40 48             	mov    0x48(%eax),%eax
  800482:	83 ec 04             	sub    $0x4,%esp
  800485:	51                   	push   %ecx
  800486:	50                   	push   %eax
  800487:	68 98 1e 80 00       	push   $0x801e98
  80048c:	e8 b7 0c 00 00       	call   801148 <cprintf>
	*dev = 0;
  800491:	8b 45 0c             	mov    0xc(%ebp),%eax
  800494:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80049a:	83 c4 10             	add    $0x10,%esp
  80049d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004a2:	c9                   	leave  
  8004a3:	c3                   	ret    

008004a4 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004a4:	55                   	push   %ebp
  8004a5:	89 e5                	mov    %esp,%ebp
  8004a7:	56                   	push   %esi
  8004a8:	53                   	push   %ebx
  8004a9:	83 ec 10             	sub    $0x10,%esp
  8004ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8004af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004b5:	50                   	push   %eax
  8004b6:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004bc:	c1 e8 0c             	shr    $0xc,%eax
  8004bf:	50                   	push   %eax
  8004c0:	e8 36 ff ff ff       	call   8003fb <fd_lookup>
  8004c5:	83 c4 08             	add    $0x8,%esp
  8004c8:	85 c0                	test   %eax,%eax
  8004ca:	78 05                	js     8004d1 <fd_close+0x2d>
	    || fd != fd2)
  8004cc:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004cf:	74 0c                	je     8004dd <fd_close+0x39>
		return (must_exist ? r : 0);
  8004d1:	84 db                	test   %bl,%bl
  8004d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8004d8:	0f 44 c2             	cmove  %edx,%eax
  8004db:	eb 41                	jmp    80051e <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004dd:	83 ec 08             	sub    $0x8,%esp
  8004e0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004e3:	50                   	push   %eax
  8004e4:	ff 36                	pushl  (%esi)
  8004e6:	e8 66 ff ff ff       	call   800451 <dev_lookup>
  8004eb:	89 c3                	mov    %eax,%ebx
  8004ed:	83 c4 10             	add    $0x10,%esp
  8004f0:	85 c0                	test   %eax,%eax
  8004f2:	78 1a                	js     80050e <fd_close+0x6a>
		if (dev->dev_close)
  8004f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004f7:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004fa:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004ff:	85 c0                	test   %eax,%eax
  800501:	74 0b                	je     80050e <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800503:	83 ec 0c             	sub    $0xc,%esp
  800506:	56                   	push   %esi
  800507:	ff d0                	call   *%eax
  800509:	89 c3                	mov    %eax,%ebx
  80050b:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80050e:	83 ec 08             	sub    $0x8,%esp
  800511:	56                   	push   %esi
  800512:	6a 00                	push   $0x0
  800514:	e8 dc fc ff ff       	call   8001f5 <sys_page_unmap>
	return r;
  800519:	83 c4 10             	add    $0x10,%esp
  80051c:	89 d8                	mov    %ebx,%eax
}
  80051e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800521:	5b                   	pop    %ebx
  800522:	5e                   	pop    %esi
  800523:	5d                   	pop    %ebp
  800524:	c3                   	ret    

00800525 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800525:	55                   	push   %ebp
  800526:	89 e5                	mov    %esp,%ebp
  800528:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80052b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80052e:	50                   	push   %eax
  80052f:	ff 75 08             	pushl  0x8(%ebp)
  800532:	e8 c4 fe ff ff       	call   8003fb <fd_lookup>
  800537:	83 c4 08             	add    $0x8,%esp
  80053a:	85 c0                	test   %eax,%eax
  80053c:	78 10                	js     80054e <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80053e:	83 ec 08             	sub    $0x8,%esp
  800541:	6a 01                	push   $0x1
  800543:	ff 75 f4             	pushl  -0xc(%ebp)
  800546:	e8 59 ff ff ff       	call   8004a4 <fd_close>
  80054b:	83 c4 10             	add    $0x10,%esp
}
  80054e:	c9                   	leave  
  80054f:	c3                   	ret    

00800550 <close_all>:

void
close_all(void)
{
  800550:	55                   	push   %ebp
  800551:	89 e5                	mov    %esp,%ebp
  800553:	53                   	push   %ebx
  800554:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800557:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80055c:	83 ec 0c             	sub    $0xc,%esp
  80055f:	53                   	push   %ebx
  800560:	e8 c0 ff ff ff       	call   800525 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800565:	83 c3 01             	add    $0x1,%ebx
  800568:	83 c4 10             	add    $0x10,%esp
  80056b:	83 fb 20             	cmp    $0x20,%ebx
  80056e:	75 ec                	jne    80055c <close_all+0xc>
		close(i);
}
  800570:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800573:	c9                   	leave  
  800574:	c3                   	ret    

00800575 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800575:	55                   	push   %ebp
  800576:	89 e5                	mov    %esp,%ebp
  800578:	57                   	push   %edi
  800579:	56                   	push   %esi
  80057a:	53                   	push   %ebx
  80057b:	83 ec 2c             	sub    $0x2c,%esp
  80057e:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800581:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800584:	50                   	push   %eax
  800585:	ff 75 08             	pushl  0x8(%ebp)
  800588:	e8 6e fe ff ff       	call   8003fb <fd_lookup>
  80058d:	83 c4 08             	add    $0x8,%esp
  800590:	85 c0                	test   %eax,%eax
  800592:	0f 88 c1 00 00 00    	js     800659 <dup+0xe4>
		return r;
	close(newfdnum);
  800598:	83 ec 0c             	sub    $0xc,%esp
  80059b:	56                   	push   %esi
  80059c:	e8 84 ff ff ff       	call   800525 <close>

	newfd = INDEX2FD(newfdnum);
  8005a1:	89 f3                	mov    %esi,%ebx
  8005a3:	c1 e3 0c             	shl    $0xc,%ebx
  8005a6:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005ac:	83 c4 04             	add    $0x4,%esp
  8005af:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005b2:	e8 de fd ff ff       	call   800395 <fd2data>
  8005b7:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005b9:	89 1c 24             	mov    %ebx,(%esp)
  8005bc:	e8 d4 fd ff ff       	call   800395 <fd2data>
  8005c1:	83 c4 10             	add    $0x10,%esp
  8005c4:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005c7:	89 f8                	mov    %edi,%eax
  8005c9:	c1 e8 16             	shr    $0x16,%eax
  8005cc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005d3:	a8 01                	test   $0x1,%al
  8005d5:	74 37                	je     80060e <dup+0x99>
  8005d7:	89 f8                	mov    %edi,%eax
  8005d9:	c1 e8 0c             	shr    $0xc,%eax
  8005dc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005e3:	f6 c2 01             	test   $0x1,%dl
  8005e6:	74 26                	je     80060e <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005e8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005ef:	83 ec 0c             	sub    $0xc,%esp
  8005f2:	25 07 0e 00 00       	and    $0xe07,%eax
  8005f7:	50                   	push   %eax
  8005f8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005fb:	6a 00                	push   $0x0
  8005fd:	57                   	push   %edi
  8005fe:	6a 00                	push   $0x0
  800600:	e8 ae fb ff ff       	call   8001b3 <sys_page_map>
  800605:	89 c7                	mov    %eax,%edi
  800607:	83 c4 20             	add    $0x20,%esp
  80060a:	85 c0                	test   %eax,%eax
  80060c:	78 2e                	js     80063c <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80060e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800611:	89 d0                	mov    %edx,%eax
  800613:	c1 e8 0c             	shr    $0xc,%eax
  800616:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80061d:	83 ec 0c             	sub    $0xc,%esp
  800620:	25 07 0e 00 00       	and    $0xe07,%eax
  800625:	50                   	push   %eax
  800626:	53                   	push   %ebx
  800627:	6a 00                	push   $0x0
  800629:	52                   	push   %edx
  80062a:	6a 00                	push   $0x0
  80062c:	e8 82 fb ff ff       	call   8001b3 <sys_page_map>
  800631:	89 c7                	mov    %eax,%edi
  800633:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800636:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800638:	85 ff                	test   %edi,%edi
  80063a:	79 1d                	jns    800659 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80063c:	83 ec 08             	sub    $0x8,%esp
  80063f:	53                   	push   %ebx
  800640:	6a 00                	push   $0x0
  800642:	e8 ae fb ff ff       	call   8001f5 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800647:	83 c4 08             	add    $0x8,%esp
  80064a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80064d:	6a 00                	push   $0x0
  80064f:	e8 a1 fb ff ff       	call   8001f5 <sys_page_unmap>
	return r;
  800654:	83 c4 10             	add    $0x10,%esp
  800657:	89 f8                	mov    %edi,%eax
}
  800659:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80065c:	5b                   	pop    %ebx
  80065d:	5e                   	pop    %esi
  80065e:	5f                   	pop    %edi
  80065f:	5d                   	pop    %ebp
  800660:	c3                   	ret    

00800661 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800661:	55                   	push   %ebp
  800662:	89 e5                	mov    %esp,%ebp
  800664:	53                   	push   %ebx
  800665:	83 ec 14             	sub    $0x14,%esp
  800668:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80066b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80066e:	50                   	push   %eax
  80066f:	53                   	push   %ebx
  800670:	e8 86 fd ff ff       	call   8003fb <fd_lookup>
  800675:	83 c4 08             	add    $0x8,%esp
  800678:	89 c2                	mov    %eax,%edx
  80067a:	85 c0                	test   %eax,%eax
  80067c:	78 6d                	js     8006eb <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80067e:	83 ec 08             	sub    $0x8,%esp
  800681:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800684:	50                   	push   %eax
  800685:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800688:	ff 30                	pushl  (%eax)
  80068a:	e8 c2 fd ff ff       	call   800451 <dev_lookup>
  80068f:	83 c4 10             	add    $0x10,%esp
  800692:	85 c0                	test   %eax,%eax
  800694:	78 4c                	js     8006e2 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800696:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800699:	8b 42 08             	mov    0x8(%edx),%eax
  80069c:	83 e0 03             	and    $0x3,%eax
  80069f:	83 f8 01             	cmp    $0x1,%eax
  8006a2:	75 21                	jne    8006c5 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006a4:	a1 04 40 80 00       	mov    0x804004,%eax
  8006a9:	8b 40 48             	mov    0x48(%eax),%eax
  8006ac:	83 ec 04             	sub    $0x4,%esp
  8006af:	53                   	push   %ebx
  8006b0:	50                   	push   %eax
  8006b1:	68 d9 1e 80 00       	push   $0x801ed9
  8006b6:	e8 8d 0a 00 00       	call   801148 <cprintf>
		return -E_INVAL;
  8006bb:	83 c4 10             	add    $0x10,%esp
  8006be:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006c3:	eb 26                	jmp    8006eb <read+0x8a>
	}
	if (!dev->dev_read)
  8006c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006c8:	8b 40 08             	mov    0x8(%eax),%eax
  8006cb:	85 c0                	test   %eax,%eax
  8006cd:	74 17                	je     8006e6 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006cf:	83 ec 04             	sub    $0x4,%esp
  8006d2:	ff 75 10             	pushl  0x10(%ebp)
  8006d5:	ff 75 0c             	pushl  0xc(%ebp)
  8006d8:	52                   	push   %edx
  8006d9:	ff d0                	call   *%eax
  8006db:	89 c2                	mov    %eax,%edx
  8006dd:	83 c4 10             	add    $0x10,%esp
  8006e0:	eb 09                	jmp    8006eb <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006e2:	89 c2                	mov    %eax,%edx
  8006e4:	eb 05                	jmp    8006eb <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006e6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006eb:	89 d0                	mov    %edx,%eax
  8006ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006f0:	c9                   	leave  
  8006f1:	c3                   	ret    

008006f2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006f2:	55                   	push   %ebp
  8006f3:	89 e5                	mov    %esp,%ebp
  8006f5:	57                   	push   %edi
  8006f6:	56                   	push   %esi
  8006f7:	53                   	push   %ebx
  8006f8:	83 ec 0c             	sub    $0xc,%esp
  8006fb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006fe:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800701:	bb 00 00 00 00       	mov    $0x0,%ebx
  800706:	eb 21                	jmp    800729 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800708:	83 ec 04             	sub    $0x4,%esp
  80070b:	89 f0                	mov    %esi,%eax
  80070d:	29 d8                	sub    %ebx,%eax
  80070f:	50                   	push   %eax
  800710:	89 d8                	mov    %ebx,%eax
  800712:	03 45 0c             	add    0xc(%ebp),%eax
  800715:	50                   	push   %eax
  800716:	57                   	push   %edi
  800717:	e8 45 ff ff ff       	call   800661 <read>
		if (m < 0)
  80071c:	83 c4 10             	add    $0x10,%esp
  80071f:	85 c0                	test   %eax,%eax
  800721:	78 10                	js     800733 <readn+0x41>
			return m;
		if (m == 0)
  800723:	85 c0                	test   %eax,%eax
  800725:	74 0a                	je     800731 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800727:	01 c3                	add    %eax,%ebx
  800729:	39 f3                	cmp    %esi,%ebx
  80072b:	72 db                	jb     800708 <readn+0x16>
  80072d:	89 d8                	mov    %ebx,%eax
  80072f:	eb 02                	jmp    800733 <readn+0x41>
  800731:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800733:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800736:	5b                   	pop    %ebx
  800737:	5e                   	pop    %esi
  800738:	5f                   	pop    %edi
  800739:	5d                   	pop    %ebp
  80073a:	c3                   	ret    

0080073b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80073b:	55                   	push   %ebp
  80073c:	89 e5                	mov    %esp,%ebp
  80073e:	53                   	push   %ebx
  80073f:	83 ec 14             	sub    $0x14,%esp
  800742:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800745:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800748:	50                   	push   %eax
  800749:	53                   	push   %ebx
  80074a:	e8 ac fc ff ff       	call   8003fb <fd_lookup>
  80074f:	83 c4 08             	add    $0x8,%esp
  800752:	89 c2                	mov    %eax,%edx
  800754:	85 c0                	test   %eax,%eax
  800756:	78 68                	js     8007c0 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800758:	83 ec 08             	sub    $0x8,%esp
  80075b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80075e:	50                   	push   %eax
  80075f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800762:	ff 30                	pushl  (%eax)
  800764:	e8 e8 fc ff ff       	call   800451 <dev_lookup>
  800769:	83 c4 10             	add    $0x10,%esp
  80076c:	85 c0                	test   %eax,%eax
  80076e:	78 47                	js     8007b7 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800770:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800773:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800777:	75 21                	jne    80079a <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800779:	a1 04 40 80 00       	mov    0x804004,%eax
  80077e:	8b 40 48             	mov    0x48(%eax),%eax
  800781:	83 ec 04             	sub    $0x4,%esp
  800784:	53                   	push   %ebx
  800785:	50                   	push   %eax
  800786:	68 f5 1e 80 00       	push   $0x801ef5
  80078b:	e8 b8 09 00 00       	call   801148 <cprintf>
		return -E_INVAL;
  800790:	83 c4 10             	add    $0x10,%esp
  800793:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800798:	eb 26                	jmp    8007c0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80079a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80079d:	8b 52 0c             	mov    0xc(%edx),%edx
  8007a0:	85 d2                	test   %edx,%edx
  8007a2:	74 17                	je     8007bb <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007a4:	83 ec 04             	sub    $0x4,%esp
  8007a7:	ff 75 10             	pushl  0x10(%ebp)
  8007aa:	ff 75 0c             	pushl  0xc(%ebp)
  8007ad:	50                   	push   %eax
  8007ae:	ff d2                	call   *%edx
  8007b0:	89 c2                	mov    %eax,%edx
  8007b2:	83 c4 10             	add    $0x10,%esp
  8007b5:	eb 09                	jmp    8007c0 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007b7:	89 c2                	mov    %eax,%edx
  8007b9:	eb 05                	jmp    8007c0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007bb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007c0:	89 d0                	mov    %edx,%eax
  8007c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007c5:	c9                   	leave  
  8007c6:	c3                   	ret    

008007c7 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007c7:	55                   	push   %ebp
  8007c8:	89 e5                	mov    %esp,%ebp
  8007ca:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007cd:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007d0:	50                   	push   %eax
  8007d1:	ff 75 08             	pushl  0x8(%ebp)
  8007d4:	e8 22 fc ff ff       	call   8003fb <fd_lookup>
  8007d9:	83 c4 08             	add    $0x8,%esp
  8007dc:	85 c0                	test   %eax,%eax
  8007de:	78 0e                	js     8007ee <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007e6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007ee:	c9                   	leave  
  8007ef:	c3                   	ret    

008007f0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	53                   	push   %ebx
  8007f4:	83 ec 14             	sub    $0x14,%esp
  8007f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007fa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007fd:	50                   	push   %eax
  8007fe:	53                   	push   %ebx
  8007ff:	e8 f7 fb ff ff       	call   8003fb <fd_lookup>
  800804:	83 c4 08             	add    $0x8,%esp
  800807:	89 c2                	mov    %eax,%edx
  800809:	85 c0                	test   %eax,%eax
  80080b:	78 65                	js     800872 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80080d:	83 ec 08             	sub    $0x8,%esp
  800810:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800813:	50                   	push   %eax
  800814:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800817:	ff 30                	pushl  (%eax)
  800819:	e8 33 fc ff ff       	call   800451 <dev_lookup>
  80081e:	83 c4 10             	add    $0x10,%esp
  800821:	85 c0                	test   %eax,%eax
  800823:	78 44                	js     800869 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800825:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800828:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80082c:	75 21                	jne    80084f <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80082e:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800833:	8b 40 48             	mov    0x48(%eax),%eax
  800836:	83 ec 04             	sub    $0x4,%esp
  800839:	53                   	push   %ebx
  80083a:	50                   	push   %eax
  80083b:	68 b8 1e 80 00       	push   $0x801eb8
  800840:	e8 03 09 00 00       	call   801148 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800845:	83 c4 10             	add    $0x10,%esp
  800848:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80084d:	eb 23                	jmp    800872 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80084f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800852:	8b 52 18             	mov    0x18(%edx),%edx
  800855:	85 d2                	test   %edx,%edx
  800857:	74 14                	je     80086d <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800859:	83 ec 08             	sub    $0x8,%esp
  80085c:	ff 75 0c             	pushl  0xc(%ebp)
  80085f:	50                   	push   %eax
  800860:	ff d2                	call   *%edx
  800862:	89 c2                	mov    %eax,%edx
  800864:	83 c4 10             	add    $0x10,%esp
  800867:	eb 09                	jmp    800872 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800869:	89 c2                	mov    %eax,%edx
  80086b:	eb 05                	jmp    800872 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80086d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800872:	89 d0                	mov    %edx,%eax
  800874:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800877:	c9                   	leave  
  800878:	c3                   	ret    

00800879 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800879:	55                   	push   %ebp
  80087a:	89 e5                	mov    %esp,%ebp
  80087c:	53                   	push   %ebx
  80087d:	83 ec 14             	sub    $0x14,%esp
  800880:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800883:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800886:	50                   	push   %eax
  800887:	ff 75 08             	pushl  0x8(%ebp)
  80088a:	e8 6c fb ff ff       	call   8003fb <fd_lookup>
  80088f:	83 c4 08             	add    $0x8,%esp
  800892:	89 c2                	mov    %eax,%edx
  800894:	85 c0                	test   %eax,%eax
  800896:	78 58                	js     8008f0 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800898:	83 ec 08             	sub    $0x8,%esp
  80089b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80089e:	50                   	push   %eax
  80089f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008a2:	ff 30                	pushl  (%eax)
  8008a4:	e8 a8 fb ff ff       	call   800451 <dev_lookup>
  8008a9:	83 c4 10             	add    $0x10,%esp
  8008ac:	85 c0                	test   %eax,%eax
  8008ae:	78 37                	js     8008e7 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8008b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008b3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008b7:	74 32                	je     8008eb <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008b9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008bc:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008c3:	00 00 00 
	stat->st_isdir = 0;
  8008c6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008cd:	00 00 00 
	stat->st_dev = dev;
  8008d0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008d6:	83 ec 08             	sub    $0x8,%esp
  8008d9:	53                   	push   %ebx
  8008da:	ff 75 f0             	pushl  -0x10(%ebp)
  8008dd:	ff 50 14             	call   *0x14(%eax)
  8008e0:	89 c2                	mov    %eax,%edx
  8008e2:	83 c4 10             	add    $0x10,%esp
  8008e5:	eb 09                	jmp    8008f0 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008e7:	89 c2                	mov    %eax,%edx
  8008e9:	eb 05                	jmp    8008f0 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008eb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008f0:	89 d0                	mov    %edx,%eax
  8008f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008f5:	c9                   	leave  
  8008f6:	c3                   	ret    

008008f7 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008f7:	55                   	push   %ebp
  8008f8:	89 e5                	mov    %esp,%ebp
  8008fa:	56                   	push   %esi
  8008fb:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008fc:	83 ec 08             	sub    $0x8,%esp
  8008ff:	6a 00                	push   $0x0
  800901:	ff 75 08             	pushl  0x8(%ebp)
  800904:	e8 e3 01 00 00       	call   800aec <open>
  800909:	89 c3                	mov    %eax,%ebx
  80090b:	83 c4 10             	add    $0x10,%esp
  80090e:	85 c0                	test   %eax,%eax
  800910:	78 1b                	js     80092d <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800912:	83 ec 08             	sub    $0x8,%esp
  800915:	ff 75 0c             	pushl  0xc(%ebp)
  800918:	50                   	push   %eax
  800919:	e8 5b ff ff ff       	call   800879 <fstat>
  80091e:	89 c6                	mov    %eax,%esi
	close(fd);
  800920:	89 1c 24             	mov    %ebx,(%esp)
  800923:	e8 fd fb ff ff       	call   800525 <close>
	return r;
  800928:	83 c4 10             	add    $0x10,%esp
  80092b:	89 f0                	mov    %esi,%eax
}
  80092d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800930:	5b                   	pop    %ebx
  800931:	5e                   	pop    %esi
  800932:	5d                   	pop    %ebp
  800933:	c3                   	ret    

00800934 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800934:	55                   	push   %ebp
  800935:	89 e5                	mov    %esp,%ebp
  800937:	56                   	push   %esi
  800938:	53                   	push   %ebx
  800939:	89 c6                	mov    %eax,%esi
  80093b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80093d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800944:	75 12                	jne    800958 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800946:	83 ec 0c             	sub    $0xc,%esp
  800949:	6a 01                	push   $0x1
  80094b:	e8 f3 11 00 00       	call   801b43 <ipc_find_env>
  800950:	a3 00 40 80 00       	mov    %eax,0x804000
  800955:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800958:	6a 07                	push   $0x7
  80095a:	68 00 50 80 00       	push   $0x805000
  80095f:	56                   	push   %esi
  800960:	ff 35 00 40 80 00    	pushl  0x804000
  800966:	e8 84 11 00 00       	call   801aef <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80096b:	83 c4 0c             	add    $0xc,%esp
  80096e:	6a 00                	push   $0x0
  800970:	53                   	push   %ebx
  800971:	6a 00                	push   $0x0
  800973:	e8 22 11 00 00       	call   801a9a <ipc_recv>
}
  800978:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80097b:	5b                   	pop    %ebx
  80097c:	5e                   	pop    %esi
  80097d:	5d                   	pop    %ebp
  80097e:	c3                   	ret    

0080097f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800985:	8b 45 08             	mov    0x8(%ebp),%eax
  800988:	8b 40 0c             	mov    0xc(%eax),%eax
  80098b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800990:	8b 45 0c             	mov    0xc(%ebp),%eax
  800993:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800998:	ba 00 00 00 00       	mov    $0x0,%edx
  80099d:	b8 02 00 00 00       	mov    $0x2,%eax
  8009a2:	e8 8d ff ff ff       	call   800934 <fsipc>
}
  8009a7:	c9                   	leave  
  8009a8:	c3                   	ret    

008009a9 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009a9:	55                   	push   %ebp
  8009aa:	89 e5                	mov    %esp,%ebp
  8009ac:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009af:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b2:	8b 40 0c             	mov    0xc(%eax),%eax
  8009b5:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8009bf:	b8 06 00 00 00       	mov    $0x6,%eax
  8009c4:	e8 6b ff ff ff       	call   800934 <fsipc>
}
  8009c9:	c9                   	leave  
  8009ca:	c3                   	ret    

008009cb <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	53                   	push   %ebx
  8009cf:	83 ec 04             	sub    $0x4,%esp
  8009d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d8:	8b 40 0c             	mov    0xc(%eax),%eax
  8009db:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8009e5:	b8 05 00 00 00       	mov    $0x5,%eax
  8009ea:	e8 45 ff ff ff       	call   800934 <fsipc>
  8009ef:	85 c0                	test   %eax,%eax
  8009f1:	78 2c                	js     800a1f <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009f3:	83 ec 08             	sub    $0x8,%esp
  8009f6:	68 00 50 80 00       	push   $0x805000
  8009fb:	53                   	push   %ebx
  8009fc:	e8 ea 0c 00 00       	call   8016eb <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a01:	a1 80 50 80 00       	mov    0x805080,%eax
  800a06:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a0c:	a1 84 50 80 00       	mov    0x805084,%eax
  800a11:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a17:	83 c4 10             	add    $0x10,%esp
  800a1a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a1f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a22:	c9                   	leave  
  800a23:	c3                   	ret    

00800a24 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a24:	55                   	push   %ebp
  800a25:	89 e5                	mov    %esp,%ebp
  800a27:	83 ec 0c             	sub    $0xc,%esp
  800a2a:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
    
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800a30:	8b 52 0c             	mov    0xc(%edx),%edx
  800a33:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = MIN(n, PGSIZE);
  800a39:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a3e:	ba 00 10 00 00       	mov    $0x1000,%edx
  800a43:	0f 47 c2             	cmova  %edx,%eax
  800a46:	a3 04 50 80 00       	mov    %eax,0x805004
    memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  800a4b:	50                   	push   %eax
  800a4c:	ff 75 0c             	pushl  0xc(%ebp)
  800a4f:	68 08 50 80 00       	push   $0x805008
  800a54:	e8 24 0e 00 00       	call   80187d <memmove>
    int r = fsipc(FSREQ_WRITE, NULL);
  800a59:	ba 00 00 00 00       	mov    $0x0,%edx
  800a5e:	b8 04 00 00 00       	mov    $0x4,%eax
  800a63:	e8 cc fe ff ff       	call   800934 <fsipc>
    return r;
}
  800a68:	c9                   	leave  
  800a69:	c3                   	ret    

00800a6a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a6a:	55                   	push   %ebp
  800a6b:	89 e5                	mov    %esp,%ebp
  800a6d:	56                   	push   %esi
  800a6e:	53                   	push   %ebx
  800a6f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a72:	8b 45 08             	mov    0x8(%ebp),%eax
  800a75:	8b 40 0c             	mov    0xc(%eax),%eax
  800a78:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a7d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a83:	ba 00 00 00 00       	mov    $0x0,%edx
  800a88:	b8 03 00 00 00       	mov    $0x3,%eax
  800a8d:	e8 a2 fe ff ff       	call   800934 <fsipc>
  800a92:	89 c3                	mov    %eax,%ebx
  800a94:	85 c0                	test   %eax,%eax
  800a96:	78 4b                	js     800ae3 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a98:	39 c6                	cmp    %eax,%esi
  800a9a:	73 16                	jae    800ab2 <devfile_read+0x48>
  800a9c:	68 24 1f 80 00       	push   $0x801f24
  800aa1:	68 2b 1f 80 00       	push   $0x801f2b
  800aa6:	6a 7c                	push   $0x7c
  800aa8:	68 40 1f 80 00       	push   $0x801f40
  800aad:	e8 bd 05 00 00       	call   80106f <_panic>
	assert(r <= PGSIZE);
  800ab2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ab7:	7e 16                	jle    800acf <devfile_read+0x65>
  800ab9:	68 4b 1f 80 00       	push   $0x801f4b
  800abe:	68 2b 1f 80 00       	push   $0x801f2b
  800ac3:	6a 7d                	push   $0x7d
  800ac5:	68 40 1f 80 00       	push   $0x801f40
  800aca:	e8 a0 05 00 00       	call   80106f <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800acf:	83 ec 04             	sub    $0x4,%esp
  800ad2:	50                   	push   %eax
  800ad3:	68 00 50 80 00       	push   $0x805000
  800ad8:	ff 75 0c             	pushl  0xc(%ebp)
  800adb:	e8 9d 0d 00 00       	call   80187d <memmove>
	return r;
  800ae0:	83 c4 10             	add    $0x10,%esp
}
  800ae3:	89 d8                	mov    %ebx,%eax
  800ae5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ae8:	5b                   	pop    %ebx
  800ae9:	5e                   	pop    %esi
  800aea:	5d                   	pop    %ebp
  800aeb:	c3                   	ret    

00800aec <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800aec:	55                   	push   %ebp
  800aed:	89 e5                	mov    %esp,%ebp
  800aef:	53                   	push   %ebx
  800af0:	83 ec 20             	sub    $0x20,%esp
  800af3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800af6:	53                   	push   %ebx
  800af7:	e8 b6 0b 00 00       	call   8016b2 <strlen>
  800afc:	83 c4 10             	add    $0x10,%esp
  800aff:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b04:	7f 67                	jg     800b6d <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b06:	83 ec 0c             	sub    $0xc,%esp
  800b09:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b0c:	50                   	push   %eax
  800b0d:	e8 9a f8 ff ff       	call   8003ac <fd_alloc>
  800b12:	83 c4 10             	add    $0x10,%esp
		return r;
  800b15:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b17:	85 c0                	test   %eax,%eax
  800b19:	78 57                	js     800b72 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b1b:	83 ec 08             	sub    $0x8,%esp
  800b1e:	53                   	push   %ebx
  800b1f:	68 00 50 80 00       	push   $0x805000
  800b24:	e8 c2 0b 00 00       	call   8016eb <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b29:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b2c:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b31:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b34:	b8 01 00 00 00       	mov    $0x1,%eax
  800b39:	e8 f6 fd ff ff       	call   800934 <fsipc>
  800b3e:	89 c3                	mov    %eax,%ebx
  800b40:	83 c4 10             	add    $0x10,%esp
  800b43:	85 c0                	test   %eax,%eax
  800b45:	79 14                	jns    800b5b <open+0x6f>
		fd_close(fd, 0);
  800b47:	83 ec 08             	sub    $0x8,%esp
  800b4a:	6a 00                	push   $0x0
  800b4c:	ff 75 f4             	pushl  -0xc(%ebp)
  800b4f:	e8 50 f9 ff ff       	call   8004a4 <fd_close>
		return r;
  800b54:	83 c4 10             	add    $0x10,%esp
  800b57:	89 da                	mov    %ebx,%edx
  800b59:	eb 17                	jmp    800b72 <open+0x86>
	}

	return fd2num(fd);
  800b5b:	83 ec 0c             	sub    $0xc,%esp
  800b5e:	ff 75 f4             	pushl  -0xc(%ebp)
  800b61:	e8 1f f8 ff ff       	call   800385 <fd2num>
  800b66:	89 c2                	mov    %eax,%edx
  800b68:	83 c4 10             	add    $0x10,%esp
  800b6b:	eb 05                	jmp    800b72 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b6d:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b72:	89 d0                	mov    %edx,%eax
  800b74:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b77:	c9                   	leave  
  800b78:	c3                   	ret    

00800b79 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b79:	55                   	push   %ebp
  800b7a:	89 e5                	mov    %esp,%ebp
  800b7c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b7f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b84:	b8 08 00 00 00       	mov    $0x8,%eax
  800b89:	e8 a6 fd ff ff       	call   800934 <fsipc>
}
  800b8e:	c9                   	leave  
  800b8f:	c3                   	ret    

00800b90 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b90:	55                   	push   %ebp
  800b91:	89 e5                	mov    %esp,%ebp
  800b93:	56                   	push   %esi
  800b94:	53                   	push   %ebx
  800b95:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b98:	83 ec 0c             	sub    $0xc,%esp
  800b9b:	ff 75 08             	pushl  0x8(%ebp)
  800b9e:	e8 f2 f7 ff ff       	call   800395 <fd2data>
  800ba3:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800ba5:	83 c4 08             	add    $0x8,%esp
  800ba8:	68 57 1f 80 00       	push   $0x801f57
  800bad:	53                   	push   %ebx
  800bae:	e8 38 0b 00 00       	call   8016eb <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800bb3:	8b 46 04             	mov    0x4(%esi),%eax
  800bb6:	2b 06                	sub    (%esi),%eax
  800bb8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bbe:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bc5:	00 00 00 
	stat->st_dev = &devpipe;
  800bc8:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bcf:	30 80 00 
	return 0;
}
  800bd2:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bda:	5b                   	pop    %ebx
  800bdb:	5e                   	pop    %esi
  800bdc:	5d                   	pop    %ebp
  800bdd:	c3                   	ret    

00800bde <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bde:	55                   	push   %ebp
  800bdf:	89 e5                	mov    %esp,%ebp
  800be1:	53                   	push   %ebx
  800be2:	83 ec 0c             	sub    $0xc,%esp
  800be5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800be8:	53                   	push   %ebx
  800be9:	6a 00                	push   $0x0
  800beb:	e8 05 f6 ff ff       	call   8001f5 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bf0:	89 1c 24             	mov    %ebx,(%esp)
  800bf3:	e8 9d f7 ff ff       	call   800395 <fd2data>
  800bf8:	83 c4 08             	add    $0x8,%esp
  800bfb:	50                   	push   %eax
  800bfc:	6a 00                	push   $0x0
  800bfe:	e8 f2 f5 ff ff       	call   8001f5 <sys_page_unmap>
}
  800c03:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c06:	c9                   	leave  
  800c07:	c3                   	ret    

00800c08 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800c08:	55                   	push   %ebp
  800c09:	89 e5                	mov    %esp,%ebp
  800c0b:	57                   	push   %edi
  800c0c:	56                   	push   %esi
  800c0d:	53                   	push   %ebx
  800c0e:	83 ec 1c             	sub    $0x1c,%esp
  800c11:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c14:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c16:	a1 04 40 80 00       	mov    0x804004,%eax
  800c1b:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800c1e:	83 ec 0c             	sub    $0xc,%esp
  800c21:	ff 75 e0             	pushl  -0x20(%ebp)
  800c24:	e8 53 0f 00 00       	call   801b7c <pageref>
  800c29:	89 c3                	mov    %eax,%ebx
  800c2b:	89 3c 24             	mov    %edi,(%esp)
  800c2e:	e8 49 0f 00 00       	call   801b7c <pageref>
  800c33:	83 c4 10             	add    $0x10,%esp
  800c36:	39 c3                	cmp    %eax,%ebx
  800c38:	0f 94 c1             	sete   %cl
  800c3b:	0f b6 c9             	movzbl %cl,%ecx
  800c3e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c41:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c47:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c4a:	39 ce                	cmp    %ecx,%esi
  800c4c:	74 1b                	je     800c69 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c4e:	39 c3                	cmp    %eax,%ebx
  800c50:	75 c4                	jne    800c16 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c52:	8b 42 58             	mov    0x58(%edx),%eax
  800c55:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c58:	50                   	push   %eax
  800c59:	56                   	push   %esi
  800c5a:	68 5e 1f 80 00       	push   $0x801f5e
  800c5f:	e8 e4 04 00 00       	call   801148 <cprintf>
  800c64:	83 c4 10             	add    $0x10,%esp
  800c67:	eb ad                	jmp    800c16 <_pipeisclosed+0xe>
	}
}
  800c69:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6f:	5b                   	pop    %ebx
  800c70:	5e                   	pop    %esi
  800c71:	5f                   	pop    %edi
  800c72:	5d                   	pop    %ebp
  800c73:	c3                   	ret    

00800c74 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c74:	55                   	push   %ebp
  800c75:	89 e5                	mov    %esp,%ebp
  800c77:	57                   	push   %edi
  800c78:	56                   	push   %esi
  800c79:	53                   	push   %ebx
  800c7a:	83 ec 28             	sub    $0x28,%esp
  800c7d:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c80:	56                   	push   %esi
  800c81:	e8 0f f7 ff ff       	call   800395 <fd2data>
  800c86:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c88:	83 c4 10             	add    $0x10,%esp
  800c8b:	bf 00 00 00 00       	mov    $0x0,%edi
  800c90:	eb 4b                	jmp    800cdd <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c92:	89 da                	mov    %ebx,%edx
  800c94:	89 f0                	mov    %esi,%eax
  800c96:	e8 6d ff ff ff       	call   800c08 <_pipeisclosed>
  800c9b:	85 c0                	test   %eax,%eax
  800c9d:	75 48                	jne    800ce7 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c9f:	e8 ad f4 ff ff       	call   800151 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800ca4:	8b 43 04             	mov    0x4(%ebx),%eax
  800ca7:	8b 0b                	mov    (%ebx),%ecx
  800ca9:	8d 51 20             	lea    0x20(%ecx),%edx
  800cac:	39 d0                	cmp    %edx,%eax
  800cae:	73 e2                	jae    800c92 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800cb0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb3:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800cb7:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800cba:	89 c2                	mov    %eax,%edx
  800cbc:	c1 fa 1f             	sar    $0x1f,%edx
  800cbf:	89 d1                	mov    %edx,%ecx
  800cc1:	c1 e9 1b             	shr    $0x1b,%ecx
  800cc4:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cc7:	83 e2 1f             	and    $0x1f,%edx
  800cca:	29 ca                	sub    %ecx,%edx
  800ccc:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cd0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cd4:	83 c0 01             	add    $0x1,%eax
  800cd7:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cda:	83 c7 01             	add    $0x1,%edi
  800cdd:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800ce0:	75 c2                	jne    800ca4 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800ce2:	8b 45 10             	mov    0x10(%ebp),%eax
  800ce5:	eb 05                	jmp    800cec <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800ce7:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cef:	5b                   	pop    %ebx
  800cf0:	5e                   	pop    %esi
  800cf1:	5f                   	pop    %edi
  800cf2:	5d                   	pop    %ebp
  800cf3:	c3                   	ret    

00800cf4 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cf4:	55                   	push   %ebp
  800cf5:	89 e5                	mov    %esp,%ebp
  800cf7:	57                   	push   %edi
  800cf8:	56                   	push   %esi
  800cf9:	53                   	push   %ebx
  800cfa:	83 ec 18             	sub    $0x18,%esp
  800cfd:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800d00:	57                   	push   %edi
  800d01:	e8 8f f6 ff ff       	call   800395 <fd2data>
  800d06:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d08:	83 c4 10             	add    $0x10,%esp
  800d0b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d10:	eb 3d                	jmp    800d4f <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800d12:	85 db                	test   %ebx,%ebx
  800d14:	74 04                	je     800d1a <devpipe_read+0x26>
				return i;
  800d16:	89 d8                	mov    %ebx,%eax
  800d18:	eb 44                	jmp    800d5e <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d1a:	89 f2                	mov    %esi,%edx
  800d1c:	89 f8                	mov    %edi,%eax
  800d1e:	e8 e5 fe ff ff       	call   800c08 <_pipeisclosed>
  800d23:	85 c0                	test   %eax,%eax
  800d25:	75 32                	jne    800d59 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d27:	e8 25 f4 ff ff       	call   800151 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d2c:	8b 06                	mov    (%esi),%eax
  800d2e:	3b 46 04             	cmp    0x4(%esi),%eax
  800d31:	74 df                	je     800d12 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d33:	99                   	cltd   
  800d34:	c1 ea 1b             	shr    $0x1b,%edx
  800d37:	01 d0                	add    %edx,%eax
  800d39:	83 e0 1f             	and    $0x1f,%eax
  800d3c:	29 d0                	sub    %edx,%eax
  800d3e:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d46:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d49:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d4c:	83 c3 01             	add    $0x1,%ebx
  800d4f:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d52:	75 d8                	jne    800d2c <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d54:	8b 45 10             	mov    0x10(%ebp),%eax
  800d57:	eb 05                	jmp    800d5e <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d59:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d61:	5b                   	pop    %ebx
  800d62:	5e                   	pop    %esi
  800d63:	5f                   	pop    %edi
  800d64:	5d                   	pop    %ebp
  800d65:	c3                   	ret    

00800d66 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d66:	55                   	push   %ebp
  800d67:	89 e5                	mov    %esp,%ebp
  800d69:	56                   	push   %esi
  800d6a:	53                   	push   %ebx
  800d6b:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d6e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d71:	50                   	push   %eax
  800d72:	e8 35 f6 ff ff       	call   8003ac <fd_alloc>
  800d77:	83 c4 10             	add    $0x10,%esp
  800d7a:	89 c2                	mov    %eax,%edx
  800d7c:	85 c0                	test   %eax,%eax
  800d7e:	0f 88 2c 01 00 00    	js     800eb0 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d84:	83 ec 04             	sub    $0x4,%esp
  800d87:	68 07 04 00 00       	push   $0x407
  800d8c:	ff 75 f4             	pushl  -0xc(%ebp)
  800d8f:	6a 00                	push   $0x0
  800d91:	e8 da f3 ff ff       	call   800170 <sys_page_alloc>
  800d96:	83 c4 10             	add    $0x10,%esp
  800d99:	89 c2                	mov    %eax,%edx
  800d9b:	85 c0                	test   %eax,%eax
  800d9d:	0f 88 0d 01 00 00    	js     800eb0 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800da3:	83 ec 0c             	sub    $0xc,%esp
  800da6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800da9:	50                   	push   %eax
  800daa:	e8 fd f5 ff ff       	call   8003ac <fd_alloc>
  800daf:	89 c3                	mov    %eax,%ebx
  800db1:	83 c4 10             	add    $0x10,%esp
  800db4:	85 c0                	test   %eax,%eax
  800db6:	0f 88 e2 00 00 00    	js     800e9e <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dbc:	83 ec 04             	sub    $0x4,%esp
  800dbf:	68 07 04 00 00       	push   $0x407
  800dc4:	ff 75 f0             	pushl  -0x10(%ebp)
  800dc7:	6a 00                	push   $0x0
  800dc9:	e8 a2 f3 ff ff       	call   800170 <sys_page_alloc>
  800dce:	89 c3                	mov    %eax,%ebx
  800dd0:	83 c4 10             	add    $0x10,%esp
  800dd3:	85 c0                	test   %eax,%eax
  800dd5:	0f 88 c3 00 00 00    	js     800e9e <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800ddb:	83 ec 0c             	sub    $0xc,%esp
  800dde:	ff 75 f4             	pushl  -0xc(%ebp)
  800de1:	e8 af f5 ff ff       	call   800395 <fd2data>
  800de6:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800de8:	83 c4 0c             	add    $0xc,%esp
  800deb:	68 07 04 00 00       	push   $0x407
  800df0:	50                   	push   %eax
  800df1:	6a 00                	push   $0x0
  800df3:	e8 78 f3 ff ff       	call   800170 <sys_page_alloc>
  800df8:	89 c3                	mov    %eax,%ebx
  800dfa:	83 c4 10             	add    $0x10,%esp
  800dfd:	85 c0                	test   %eax,%eax
  800dff:	0f 88 89 00 00 00    	js     800e8e <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e05:	83 ec 0c             	sub    $0xc,%esp
  800e08:	ff 75 f0             	pushl  -0x10(%ebp)
  800e0b:	e8 85 f5 ff ff       	call   800395 <fd2data>
  800e10:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e17:	50                   	push   %eax
  800e18:	6a 00                	push   $0x0
  800e1a:	56                   	push   %esi
  800e1b:	6a 00                	push   $0x0
  800e1d:	e8 91 f3 ff ff       	call   8001b3 <sys_page_map>
  800e22:	89 c3                	mov    %eax,%ebx
  800e24:	83 c4 20             	add    $0x20,%esp
  800e27:	85 c0                	test   %eax,%eax
  800e29:	78 55                	js     800e80 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e2b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e31:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e34:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e36:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e39:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e40:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e46:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e49:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e4e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e55:	83 ec 0c             	sub    $0xc,%esp
  800e58:	ff 75 f4             	pushl  -0xc(%ebp)
  800e5b:	e8 25 f5 ff ff       	call   800385 <fd2num>
  800e60:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e63:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e65:	83 c4 04             	add    $0x4,%esp
  800e68:	ff 75 f0             	pushl  -0x10(%ebp)
  800e6b:	e8 15 f5 ff ff       	call   800385 <fd2num>
  800e70:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e73:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e76:	83 c4 10             	add    $0x10,%esp
  800e79:	ba 00 00 00 00       	mov    $0x0,%edx
  800e7e:	eb 30                	jmp    800eb0 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e80:	83 ec 08             	sub    $0x8,%esp
  800e83:	56                   	push   %esi
  800e84:	6a 00                	push   $0x0
  800e86:	e8 6a f3 ff ff       	call   8001f5 <sys_page_unmap>
  800e8b:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e8e:	83 ec 08             	sub    $0x8,%esp
  800e91:	ff 75 f0             	pushl  -0x10(%ebp)
  800e94:	6a 00                	push   $0x0
  800e96:	e8 5a f3 ff ff       	call   8001f5 <sys_page_unmap>
  800e9b:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e9e:	83 ec 08             	sub    $0x8,%esp
  800ea1:	ff 75 f4             	pushl  -0xc(%ebp)
  800ea4:	6a 00                	push   $0x0
  800ea6:	e8 4a f3 ff ff       	call   8001f5 <sys_page_unmap>
  800eab:	83 c4 10             	add    $0x10,%esp
  800eae:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800eb0:	89 d0                	mov    %edx,%eax
  800eb2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800eb5:	5b                   	pop    %ebx
  800eb6:	5e                   	pop    %esi
  800eb7:	5d                   	pop    %ebp
  800eb8:	c3                   	ret    

00800eb9 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800eb9:	55                   	push   %ebp
  800eba:	89 e5                	mov    %esp,%ebp
  800ebc:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ebf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ec2:	50                   	push   %eax
  800ec3:	ff 75 08             	pushl  0x8(%ebp)
  800ec6:	e8 30 f5 ff ff       	call   8003fb <fd_lookup>
  800ecb:	83 c4 10             	add    $0x10,%esp
  800ece:	85 c0                	test   %eax,%eax
  800ed0:	78 18                	js     800eea <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800ed2:	83 ec 0c             	sub    $0xc,%esp
  800ed5:	ff 75 f4             	pushl  -0xc(%ebp)
  800ed8:	e8 b8 f4 ff ff       	call   800395 <fd2data>
	return _pipeisclosed(fd, p);
  800edd:	89 c2                	mov    %eax,%edx
  800edf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ee2:	e8 21 fd ff ff       	call   800c08 <_pipeisclosed>
  800ee7:	83 c4 10             	add    $0x10,%esp
}
  800eea:	c9                   	leave  
  800eeb:	c3                   	ret    

00800eec <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800eec:	55                   	push   %ebp
  800eed:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800eef:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef4:	5d                   	pop    %ebp
  800ef5:	c3                   	ret    

00800ef6 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ef6:	55                   	push   %ebp
  800ef7:	89 e5                	mov    %esp,%ebp
  800ef9:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800efc:	68 76 1f 80 00       	push   $0x801f76
  800f01:	ff 75 0c             	pushl  0xc(%ebp)
  800f04:	e8 e2 07 00 00       	call   8016eb <strcpy>
	return 0;
}
  800f09:	b8 00 00 00 00       	mov    $0x0,%eax
  800f0e:	c9                   	leave  
  800f0f:	c3                   	ret    

00800f10 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800f10:	55                   	push   %ebp
  800f11:	89 e5                	mov    %esp,%ebp
  800f13:	57                   	push   %edi
  800f14:	56                   	push   %esi
  800f15:	53                   	push   %ebx
  800f16:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f1c:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f21:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f27:	eb 2d                	jmp    800f56 <devcons_write+0x46>
		m = n - tot;
  800f29:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f2c:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800f2e:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f31:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f36:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f39:	83 ec 04             	sub    $0x4,%esp
  800f3c:	53                   	push   %ebx
  800f3d:	03 45 0c             	add    0xc(%ebp),%eax
  800f40:	50                   	push   %eax
  800f41:	57                   	push   %edi
  800f42:	e8 36 09 00 00       	call   80187d <memmove>
		sys_cputs(buf, m);
  800f47:	83 c4 08             	add    $0x8,%esp
  800f4a:	53                   	push   %ebx
  800f4b:	57                   	push   %edi
  800f4c:	e8 63 f1 ff ff       	call   8000b4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f51:	01 de                	add    %ebx,%esi
  800f53:	83 c4 10             	add    $0x10,%esp
  800f56:	89 f0                	mov    %esi,%eax
  800f58:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f5b:	72 cc                	jb     800f29 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f60:	5b                   	pop    %ebx
  800f61:	5e                   	pop    %esi
  800f62:	5f                   	pop    %edi
  800f63:	5d                   	pop    %ebp
  800f64:	c3                   	ret    

00800f65 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f65:	55                   	push   %ebp
  800f66:	89 e5                	mov    %esp,%ebp
  800f68:	83 ec 08             	sub    $0x8,%esp
  800f6b:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f70:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f74:	74 2a                	je     800fa0 <devcons_read+0x3b>
  800f76:	eb 05                	jmp    800f7d <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f78:	e8 d4 f1 ff ff       	call   800151 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f7d:	e8 50 f1 ff ff       	call   8000d2 <sys_cgetc>
  800f82:	85 c0                	test   %eax,%eax
  800f84:	74 f2                	je     800f78 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f86:	85 c0                	test   %eax,%eax
  800f88:	78 16                	js     800fa0 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f8a:	83 f8 04             	cmp    $0x4,%eax
  800f8d:	74 0c                	je     800f9b <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f8f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f92:	88 02                	mov    %al,(%edx)
	return 1;
  800f94:	b8 01 00 00 00       	mov    $0x1,%eax
  800f99:	eb 05                	jmp    800fa0 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f9b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800fa0:	c9                   	leave  
  800fa1:	c3                   	ret    

00800fa2 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800fa2:	55                   	push   %ebp
  800fa3:	89 e5                	mov    %esp,%ebp
  800fa5:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800fa8:	8b 45 08             	mov    0x8(%ebp),%eax
  800fab:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800fae:	6a 01                	push   $0x1
  800fb0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fb3:	50                   	push   %eax
  800fb4:	e8 fb f0 ff ff       	call   8000b4 <sys_cputs>
}
  800fb9:	83 c4 10             	add    $0x10,%esp
  800fbc:	c9                   	leave  
  800fbd:	c3                   	ret    

00800fbe <getchar>:

int
getchar(void)
{
  800fbe:	55                   	push   %ebp
  800fbf:	89 e5                	mov    %esp,%ebp
  800fc1:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800fc4:	6a 01                	push   $0x1
  800fc6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fc9:	50                   	push   %eax
  800fca:	6a 00                	push   $0x0
  800fcc:	e8 90 f6 ff ff       	call   800661 <read>
	if (r < 0)
  800fd1:	83 c4 10             	add    $0x10,%esp
  800fd4:	85 c0                	test   %eax,%eax
  800fd6:	78 0f                	js     800fe7 <getchar+0x29>
		return r;
	if (r < 1)
  800fd8:	85 c0                	test   %eax,%eax
  800fda:	7e 06                	jle    800fe2 <getchar+0x24>
		return -E_EOF;
	return c;
  800fdc:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fe0:	eb 05                	jmp    800fe7 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fe2:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fe7:	c9                   	leave  
  800fe8:	c3                   	ret    

00800fe9 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800fe9:	55                   	push   %ebp
  800fea:	89 e5                	mov    %esp,%ebp
  800fec:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ff2:	50                   	push   %eax
  800ff3:	ff 75 08             	pushl  0x8(%ebp)
  800ff6:	e8 00 f4 ff ff       	call   8003fb <fd_lookup>
  800ffb:	83 c4 10             	add    $0x10,%esp
  800ffe:	85 c0                	test   %eax,%eax
  801000:	78 11                	js     801013 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801002:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801005:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80100b:	39 10                	cmp    %edx,(%eax)
  80100d:	0f 94 c0             	sete   %al
  801010:	0f b6 c0             	movzbl %al,%eax
}
  801013:	c9                   	leave  
  801014:	c3                   	ret    

00801015 <opencons>:

int
opencons(void)
{
  801015:	55                   	push   %ebp
  801016:	89 e5                	mov    %esp,%ebp
  801018:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80101b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80101e:	50                   	push   %eax
  80101f:	e8 88 f3 ff ff       	call   8003ac <fd_alloc>
  801024:	83 c4 10             	add    $0x10,%esp
		return r;
  801027:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801029:	85 c0                	test   %eax,%eax
  80102b:	78 3e                	js     80106b <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80102d:	83 ec 04             	sub    $0x4,%esp
  801030:	68 07 04 00 00       	push   $0x407
  801035:	ff 75 f4             	pushl  -0xc(%ebp)
  801038:	6a 00                	push   $0x0
  80103a:	e8 31 f1 ff ff       	call   800170 <sys_page_alloc>
  80103f:	83 c4 10             	add    $0x10,%esp
		return r;
  801042:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801044:	85 c0                	test   %eax,%eax
  801046:	78 23                	js     80106b <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801048:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80104e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801051:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801053:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801056:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80105d:	83 ec 0c             	sub    $0xc,%esp
  801060:	50                   	push   %eax
  801061:	e8 1f f3 ff ff       	call   800385 <fd2num>
  801066:	89 c2                	mov    %eax,%edx
  801068:	83 c4 10             	add    $0x10,%esp
}
  80106b:	89 d0                	mov    %edx,%eax
  80106d:	c9                   	leave  
  80106e:	c3                   	ret    

0080106f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80106f:	55                   	push   %ebp
  801070:	89 e5                	mov    %esp,%ebp
  801072:	56                   	push   %esi
  801073:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801074:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801077:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80107d:	e8 b0 f0 ff ff       	call   800132 <sys_getenvid>
  801082:	83 ec 0c             	sub    $0xc,%esp
  801085:	ff 75 0c             	pushl  0xc(%ebp)
  801088:	ff 75 08             	pushl  0x8(%ebp)
  80108b:	56                   	push   %esi
  80108c:	50                   	push   %eax
  80108d:	68 84 1f 80 00       	push   $0x801f84
  801092:	e8 b1 00 00 00       	call   801148 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801097:	83 c4 18             	add    $0x18,%esp
  80109a:	53                   	push   %ebx
  80109b:	ff 75 10             	pushl  0x10(%ebp)
  80109e:	e8 54 00 00 00       	call   8010f7 <vcprintf>
	cprintf("\n");
  8010a3:	c7 04 24 6f 1f 80 00 	movl   $0x801f6f,(%esp)
  8010aa:	e8 99 00 00 00       	call   801148 <cprintf>
  8010af:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010b2:	cc                   	int3   
  8010b3:	eb fd                	jmp    8010b2 <_panic+0x43>

008010b5 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010b5:	55                   	push   %ebp
  8010b6:	89 e5                	mov    %esp,%ebp
  8010b8:	53                   	push   %ebx
  8010b9:	83 ec 04             	sub    $0x4,%esp
  8010bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010bf:	8b 13                	mov    (%ebx),%edx
  8010c1:	8d 42 01             	lea    0x1(%edx),%eax
  8010c4:	89 03                	mov    %eax,(%ebx)
  8010c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010c9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010cd:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010d2:	75 1a                	jne    8010ee <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010d4:	83 ec 08             	sub    $0x8,%esp
  8010d7:	68 ff 00 00 00       	push   $0xff
  8010dc:	8d 43 08             	lea    0x8(%ebx),%eax
  8010df:	50                   	push   %eax
  8010e0:	e8 cf ef ff ff       	call   8000b4 <sys_cputs>
		b->idx = 0;
  8010e5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010eb:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010ee:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010f5:	c9                   	leave  
  8010f6:	c3                   	ret    

008010f7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010f7:	55                   	push   %ebp
  8010f8:	89 e5                	mov    %esp,%ebp
  8010fa:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801100:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801107:	00 00 00 
	b.cnt = 0;
  80110a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801111:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801114:	ff 75 0c             	pushl  0xc(%ebp)
  801117:	ff 75 08             	pushl  0x8(%ebp)
  80111a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801120:	50                   	push   %eax
  801121:	68 b5 10 80 00       	push   $0x8010b5
  801126:	e8 54 01 00 00       	call   80127f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80112b:	83 c4 08             	add    $0x8,%esp
  80112e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801134:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80113a:	50                   	push   %eax
  80113b:	e8 74 ef ff ff       	call   8000b4 <sys_cputs>

	return b.cnt;
}
  801140:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801146:	c9                   	leave  
  801147:	c3                   	ret    

00801148 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801148:	55                   	push   %ebp
  801149:	89 e5                	mov    %esp,%ebp
  80114b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80114e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801151:	50                   	push   %eax
  801152:	ff 75 08             	pushl  0x8(%ebp)
  801155:	e8 9d ff ff ff       	call   8010f7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80115a:	c9                   	leave  
  80115b:	c3                   	ret    

0080115c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80115c:	55                   	push   %ebp
  80115d:	89 e5                	mov    %esp,%ebp
  80115f:	57                   	push   %edi
  801160:	56                   	push   %esi
  801161:	53                   	push   %ebx
  801162:	83 ec 1c             	sub    $0x1c,%esp
  801165:	89 c7                	mov    %eax,%edi
  801167:	89 d6                	mov    %edx,%esi
  801169:	8b 45 08             	mov    0x8(%ebp),%eax
  80116c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80116f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801172:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801175:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801178:	bb 00 00 00 00       	mov    $0x0,%ebx
  80117d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801180:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801183:	39 d3                	cmp    %edx,%ebx
  801185:	72 05                	jb     80118c <printnum+0x30>
  801187:	39 45 10             	cmp    %eax,0x10(%ebp)
  80118a:	77 45                	ja     8011d1 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80118c:	83 ec 0c             	sub    $0xc,%esp
  80118f:	ff 75 18             	pushl  0x18(%ebp)
  801192:	8b 45 14             	mov    0x14(%ebp),%eax
  801195:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801198:	53                   	push   %ebx
  801199:	ff 75 10             	pushl  0x10(%ebp)
  80119c:	83 ec 08             	sub    $0x8,%esp
  80119f:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011a2:	ff 75 e0             	pushl  -0x20(%ebp)
  8011a5:	ff 75 dc             	pushl  -0x24(%ebp)
  8011a8:	ff 75 d8             	pushl  -0x28(%ebp)
  8011ab:	e8 10 0a 00 00       	call   801bc0 <__udivdi3>
  8011b0:	83 c4 18             	add    $0x18,%esp
  8011b3:	52                   	push   %edx
  8011b4:	50                   	push   %eax
  8011b5:	89 f2                	mov    %esi,%edx
  8011b7:	89 f8                	mov    %edi,%eax
  8011b9:	e8 9e ff ff ff       	call   80115c <printnum>
  8011be:	83 c4 20             	add    $0x20,%esp
  8011c1:	eb 18                	jmp    8011db <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011c3:	83 ec 08             	sub    $0x8,%esp
  8011c6:	56                   	push   %esi
  8011c7:	ff 75 18             	pushl  0x18(%ebp)
  8011ca:	ff d7                	call   *%edi
  8011cc:	83 c4 10             	add    $0x10,%esp
  8011cf:	eb 03                	jmp    8011d4 <printnum+0x78>
  8011d1:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011d4:	83 eb 01             	sub    $0x1,%ebx
  8011d7:	85 db                	test   %ebx,%ebx
  8011d9:	7f e8                	jg     8011c3 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011db:	83 ec 08             	sub    $0x8,%esp
  8011de:	56                   	push   %esi
  8011df:	83 ec 04             	sub    $0x4,%esp
  8011e2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011e5:	ff 75 e0             	pushl  -0x20(%ebp)
  8011e8:	ff 75 dc             	pushl  -0x24(%ebp)
  8011eb:	ff 75 d8             	pushl  -0x28(%ebp)
  8011ee:	e8 fd 0a 00 00       	call   801cf0 <__umoddi3>
  8011f3:	83 c4 14             	add    $0x14,%esp
  8011f6:	0f be 80 a7 1f 80 00 	movsbl 0x801fa7(%eax),%eax
  8011fd:	50                   	push   %eax
  8011fe:	ff d7                	call   *%edi
}
  801200:	83 c4 10             	add    $0x10,%esp
  801203:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801206:	5b                   	pop    %ebx
  801207:	5e                   	pop    %esi
  801208:	5f                   	pop    %edi
  801209:	5d                   	pop    %ebp
  80120a:	c3                   	ret    

0080120b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80120b:	55                   	push   %ebp
  80120c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80120e:	83 fa 01             	cmp    $0x1,%edx
  801211:	7e 0e                	jle    801221 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801213:	8b 10                	mov    (%eax),%edx
  801215:	8d 4a 08             	lea    0x8(%edx),%ecx
  801218:	89 08                	mov    %ecx,(%eax)
  80121a:	8b 02                	mov    (%edx),%eax
  80121c:	8b 52 04             	mov    0x4(%edx),%edx
  80121f:	eb 22                	jmp    801243 <getuint+0x38>
	else if (lflag)
  801221:	85 d2                	test   %edx,%edx
  801223:	74 10                	je     801235 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801225:	8b 10                	mov    (%eax),%edx
  801227:	8d 4a 04             	lea    0x4(%edx),%ecx
  80122a:	89 08                	mov    %ecx,(%eax)
  80122c:	8b 02                	mov    (%edx),%eax
  80122e:	ba 00 00 00 00       	mov    $0x0,%edx
  801233:	eb 0e                	jmp    801243 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801235:	8b 10                	mov    (%eax),%edx
  801237:	8d 4a 04             	lea    0x4(%edx),%ecx
  80123a:	89 08                	mov    %ecx,(%eax)
  80123c:	8b 02                	mov    (%edx),%eax
  80123e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801243:	5d                   	pop    %ebp
  801244:	c3                   	ret    

00801245 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801245:	55                   	push   %ebp
  801246:	89 e5                	mov    %esp,%ebp
  801248:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80124b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80124f:	8b 10                	mov    (%eax),%edx
  801251:	3b 50 04             	cmp    0x4(%eax),%edx
  801254:	73 0a                	jae    801260 <sprintputch+0x1b>
		*b->buf++ = ch;
  801256:	8d 4a 01             	lea    0x1(%edx),%ecx
  801259:	89 08                	mov    %ecx,(%eax)
  80125b:	8b 45 08             	mov    0x8(%ebp),%eax
  80125e:	88 02                	mov    %al,(%edx)
}
  801260:	5d                   	pop    %ebp
  801261:	c3                   	ret    

00801262 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801262:	55                   	push   %ebp
  801263:	89 e5                	mov    %esp,%ebp
  801265:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801268:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80126b:	50                   	push   %eax
  80126c:	ff 75 10             	pushl  0x10(%ebp)
  80126f:	ff 75 0c             	pushl  0xc(%ebp)
  801272:	ff 75 08             	pushl  0x8(%ebp)
  801275:	e8 05 00 00 00       	call   80127f <vprintfmt>
	va_end(ap);
}
  80127a:	83 c4 10             	add    $0x10,%esp
  80127d:	c9                   	leave  
  80127e:	c3                   	ret    

0080127f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80127f:	55                   	push   %ebp
  801280:	89 e5                	mov    %esp,%ebp
  801282:	57                   	push   %edi
  801283:	56                   	push   %esi
  801284:	53                   	push   %ebx
  801285:	83 ec 2c             	sub    $0x2c,%esp
  801288:	8b 75 08             	mov    0x8(%ebp),%esi
  80128b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80128e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801291:	eb 12                	jmp    8012a5 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801293:	85 c0                	test   %eax,%eax
  801295:	0f 84 a7 03 00 00    	je     801642 <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
  80129b:	83 ec 08             	sub    $0x8,%esp
  80129e:	53                   	push   %ebx
  80129f:	50                   	push   %eax
  8012a0:	ff d6                	call   *%esi
  8012a2:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8012a5:	83 c7 01             	add    $0x1,%edi
  8012a8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8012ac:	83 f8 25             	cmp    $0x25,%eax
  8012af:	75 e2                	jne    801293 <vprintfmt+0x14>
  8012b1:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8012b5:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8012bc:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8012c3:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8012ca:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8012d1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012d6:	eb 07                	jmp    8012df <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8012db:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012df:	8d 47 01             	lea    0x1(%edi),%eax
  8012e2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012e5:	0f b6 07             	movzbl (%edi),%eax
  8012e8:	0f b6 d0             	movzbl %al,%edx
  8012eb:	83 e8 23             	sub    $0x23,%eax
  8012ee:	3c 55                	cmp    $0x55,%al
  8012f0:	0f 87 31 03 00 00    	ja     801627 <vprintfmt+0x3a8>
  8012f6:	0f b6 c0             	movzbl %al,%eax
  8012f9:	ff 24 85 e0 20 80 00 	jmp    *0x8020e0(,%eax,4)
  801300:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801303:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801307:	eb d6                	jmp    8012df <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801309:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80130c:	b8 00 00 00 00       	mov    $0x0,%eax
  801311:	89 75 08             	mov    %esi,0x8(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801314:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801317:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80131b:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80131e:	8d 72 d0             	lea    -0x30(%edx),%esi
  801321:	83 fe 09             	cmp    $0x9,%esi
  801324:	77 34                	ja     80135a <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801326:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801329:	eb e9                	jmp    801314 <vprintfmt+0x95>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80132b:	8b 45 14             	mov    0x14(%ebp),%eax
  80132e:	8d 50 04             	lea    0x4(%eax),%edx
  801331:	89 55 14             	mov    %edx,0x14(%ebp)
  801334:	8b 00                	mov    (%eax),%eax
  801336:	89 45 cc             	mov    %eax,-0x34(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801339:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80133c:	eb 22                	jmp    801360 <vprintfmt+0xe1>
  80133e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801341:	85 c0                	test   %eax,%eax
  801343:	0f 48 c1             	cmovs  %ecx,%eax
  801346:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801349:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80134c:	eb 91                	jmp    8012df <vprintfmt+0x60>
  80134e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801351:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801358:	eb 85                	jmp    8012df <vprintfmt+0x60>
  80135a:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80135d:	8b 75 08             	mov    0x8(%ebp),%esi

		process_precision:
			if (width < 0)
  801360:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801364:	0f 89 75 ff ff ff    	jns    8012df <vprintfmt+0x60>
				width = precision, precision = -1;
  80136a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80136d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801370:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  801377:	e9 63 ff ff ff       	jmp    8012df <vprintfmt+0x60>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80137c:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801380:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801383:	e9 57 ff ff ff       	jmp    8012df <vprintfmt+0x60>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801388:	8b 45 14             	mov    0x14(%ebp),%eax
  80138b:	8d 50 04             	lea    0x4(%eax),%edx
  80138e:	89 55 14             	mov    %edx,0x14(%ebp)
  801391:	83 ec 08             	sub    $0x8,%esp
  801394:	53                   	push   %ebx
  801395:	ff 30                	pushl  (%eax)
  801397:	ff d6                	call   *%esi
			break;
  801399:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80139c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80139f:	e9 01 ff ff ff       	jmp    8012a5 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8013a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8013a7:	8d 50 04             	lea    0x4(%eax),%edx
  8013aa:	89 55 14             	mov    %edx,0x14(%ebp)
  8013ad:	8b 00                	mov    (%eax),%eax
  8013af:	99                   	cltd   
  8013b0:	31 d0                	xor    %edx,%eax
  8013b2:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013b4:	83 f8 0f             	cmp    $0xf,%eax
  8013b7:	7f 0b                	jg     8013c4 <vprintfmt+0x145>
  8013b9:	8b 14 85 40 22 80 00 	mov    0x802240(,%eax,4),%edx
  8013c0:	85 d2                	test   %edx,%edx
  8013c2:	75 18                	jne    8013dc <vprintfmt+0x15d>
				printfmt(putch, putdat, "error %d", err);
  8013c4:	50                   	push   %eax
  8013c5:	68 bf 1f 80 00       	push   $0x801fbf
  8013ca:	53                   	push   %ebx
  8013cb:	56                   	push   %esi
  8013cc:	e8 91 fe ff ff       	call   801262 <printfmt>
  8013d1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8013d7:	e9 c9 fe ff ff       	jmp    8012a5 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8013dc:	52                   	push   %edx
  8013dd:	68 3d 1f 80 00       	push   $0x801f3d
  8013e2:	53                   	push   %ebx
  8013e3:	56                   	push   %esi
  8013e4:	e8 79 fe ff ff       	call   801262 <printfmt>
  8013e9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013ef:	e9 b1 fe ff ff       	jmp    8012a5 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8013f7:	8d 50 04             	lea    0x4(%eax),%edx
  8013fa:	89 55 14             	mov    %edx,0x14(%ebp)
  8013fd:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8013ff:	85 ff                	test   %edi,%edi
  801401:	b8 b8 1f 80 00       	mov    $0x801fb8,%eax
  801406:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801409:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80140d:	0f 8e 94 00 00 00    	jle    8014a7 <vprintfmt+0x228>
  801413:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801417:	0f 84 98 00 00 00    	je     8014b5 <vprintfmt+0x236>
				for (width -= strnlen(p, precision); width > 0; width--)
  80141d:	83 ec 08             	sub    $0x8,%esp
  801420:	ff 75 cc             	pushl  -0x34(%ebp)
  801423:	57                   	push   %edi
  801424:	e8 a1 02 00 00       	call   8016ca <strnlen>
  801429:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80142c:	29 c1                	sub    %eax,%ecx
  80142e:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  801431:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801434:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801438:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80143b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80143e:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801440:	eb 0f                	jmp    801451 <vprintfmt+0x1d2>
					putch(padc, putdat);
  801442:	83 ec 08             	sub    $0x8,%esp
  801445:	53                   	push   %ebx
  801446:	ff 75 e0             	pushl  -0x20(%ebp)
  801449:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80144b:	83 ef 01             	sub    $0x1,%edi
  80144e:	83 c4 10             	add    $0x10,%esp
  801451:	85 ff                	test   %edi,%edi
  801453:	7f ed                	jg     801442 <vprintfmt+0x1c3>
  801455:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801458:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80145b:	85 c9                	test   %ecx,%ecx
  80145d:	b8 00 00 00 00       	mov    $0x0,%eax
  801462:	0f 49 c1             	cmovns %ecx,%eax
  801465:	29 c1                	sub    %eax,%ecx
  801467:	89 75 08             	mov    %esi,0x8(%ebp)
  80146a:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80146d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801470:	89 cb                	mov    %ecx,%ebx
  801472:	eb 4d                	jmp    8014c1 <vprintfmt+0x242>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801474:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801478:	74 1b                	je     801495 <vprintfmt+0x216>
  80147a:	0f be c0             	movsbl %al,%eax
  80147d:	83 e8 20             	sub    $0x20,%eax
  801480:	83 f8 5e             	cmp    $0x5e,%eax
  801483:	76 10                	jbe    801495 <vprintfmt+0x216>
					putch('?', putdat);
  801485:	83 ec 08             	sub    $0x8,%esp
  801488:	ff 75 0c             	pushl  0xc(%ebp)
  80148b:	6a 3f                	push   $0x3f
  80148d:	ff 55 08             	call   *0x8(%ebp)
  801490:	83 c4 10             	add    $0x10,%esp
  801493:	eb 0d                	jmp    8014a2 <vprintfmt+0x223>
				else
					putch(ch, putdat);
  801495:	83 ec 08             	sub    $0x8,%esp
  801498:	ff 75 0c             	pushl  0xc(%ebp)
  80149b:	52                   	push   %edx
  80149c:	ff 55 08             	call   *0x8(%ebp)
  80149f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8014a2:	83 eb 01             	sub    $0x1,%ebx
  8014a5:	eb 1a                	jmp    8014c1 <vprintfmt+0x242>
  8014a7:	89 75 08             	mov    %esi,0x8(%ebp)
  8014aa:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8014ad:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014b0:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014b3:	eb 0c                	jmp    8014c1 <vprintfmt+0x242>
  8014b5:	89 75 08             	mov    %esi,0x8(%ebp)
  8014b8:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8014bb:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014be:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014c1:	83 c7 01             	add    $0x1,%edi
  8014c4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8014c8:	0f be d0             	movsbl %al,%edx
  8014cb:	85 d2                	test   %edx,%edx
  8014cd:	74 23                	je     8014f2 <vprintfmt+0x273>
  8014cf:	85 f6                	test   %esi,%esi
  8014d1:	78 a1                	js     801474 <vprintfmt+0x1f5>
  8014d3:	83 ee 01             	sub    $0x1,%esi
  8014d6:	79 9c                	jns    801474 <vprintfmt+0x1f5>
  8014d8:	89 df                	mov    %ebx,%edi
  8014da:	8b 75 08             	mov    0x8(%ebp),%esi
  8014dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014e0:	eb 18                	jmp    8014fa <vprintfmt+0x27b>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014e2:	83 ec 08             	sub    $0x8,%esp
  8014e5:	53                   	push   %ebx
  8014e6:	6a 20                	push   $0x20
  8014e8:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014ea:	83 ef 01             	sub    $0x1,%edi
  8014ed:	83 c4 10             	add    $0x10,%esp
  8014f0:	eb 08                	jmp    8014fa <vprintfmt+0x27b>
  8014f2:	89 df                	mov    %ebx,%edi
  8014f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8014f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014fa:	85 ff                	test   %edi,%edi
  8014fc:	7f e4                	jg     8014e2 <vprintfmt+0x263>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801501:	e9 9f fd ff ff       	jmp    8012a5 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801506:	83 7d d0 01          	cmpl   $0x1,-0x30(%ebp)
  80150a:	7e 16                	jle    801522 <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  80150c:	8b 45 14             	mov    0x14(%ebp),%eax
  80150f:	8d 50 08             	lea    0x8(%eax),%edx
  801512:	89 55 14             	mov    %edx,0x14(%ebp)
  801515:	8b 50 04             	mov    0x4(%eax),%edx
  801518:	8b 00                	mov    (%eax),%eax
  80151a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80151d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801520:	eb 34                	jmp    801556 <vprintfmt+0x2d7>
	else if (lflag)
  801522:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  801526:	74 18                	je     801540 <vprintfmt+0x2c1>
		return va_arg(*ap, long);
  801528:	8b 45 14             	mov    0x14(%ebp),%eax
  80152b:	8d 50 04             	lea    0x4(%eax),%edx
  80152e:	89 55 14             	mov    %edx,0x14(%ebp)
  801531:	8b 00                	mov    (%eax),%eax
  801533:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801536:	89 c1                	mov    %eax,%ecx
  801538:	c1 f9 1f             	sar    $0x1f,%ecx
  80153b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80153e:	eb 16                	jmp    801556 <vprintfmt+0x2d7>
	else
		return va_arg(*ap, int);
  801540:	8b 45 14             	mov    0x14(%ebp),%eax
  801543:	8d 50 04             	lea    0x4(%eax),%edx
  801546:	89 55 14             	mov    %edx,0x14(%ebp)
  801549:	8b 00                	mov    (%eax),%eax
  80154b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80154e:	89 c1                	mov    %eax,%ecx
  801550:	c1 f9 1f             	sar    $0x1f,%ecx
  801553:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801556:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801559:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80155c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801561:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801565:	0f 89 88 00 00 00    	jns    8015f3 <vprintfmt+0x374>
				putch('-', putdat);
  80156b:	83 ec 08             	sub    $0x8,%esp
  80156e:	53                   	push   %ebx
  80156f:	6a 2d                	push   $0x2d
  801571:	ff d6                	call   *%esi
				num = -(long long) num;
  801573:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801576:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801579:	f7 d8                	neg    %eax
  80157b:	83 d2 00             	adc    $0x0,%edx
  80157e:	f7 da                	neg    %edx
  801580:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801583:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801588:	eb 69                	jmp    8015f3 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80158a:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80158d:	8d 45 14             	lea    0x14(%ebp),%eax
  801590:	e8 76 fc ff ff       	call   80120b <getuint>
			base = 10;
  801595:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80159a:	eb 57                	jmp    8015f3 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  80159c:	83 ec 08             	sub    $0x8,%esp
  80159f:	53                   	push   %ebx
  8015a0:	6a 30                	push   $0x30
  8015a2:	ff d6                	call   *%esi
			num = getuint(&ap, lflag);
  8015a4:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8015a7:	8d 45 14             	lea    0x14(%ebp),%eax
  8015aa:	e8 5c fc ff ff       	call   80120b <getuint>
			base = 8;
			goto number;
  8015af:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  8015b2:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8015b7:	eb 3a                	jmp    8015f3 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  8015b9:	83 ec 08             	sub    $0x8,%esp
  8015bc:	53                   	push   %ebx
  8015bd:	6a 30                	push   $0x30
  8015bf:	ff d6                	call   *%esi
			putch('x', putdat);
  8015c1:	83 c4 08             	add    $0x8,%esp
  8015c4:	53                   	push   %ebx
  8015c5:	6a 78                	push   $0x78
  8015c7:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8015c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8015cc:	8d 50 04             	lea    0x4(%eax),%edx
  8015cf:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8015d2:	8b 00                	mov    (%eax),%eax
  8015d4:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015d9:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8015dc:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8015e1:	eb 10                	jmp    8015f3 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8015e3:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8015e6:	8d 45 14             	lea    0x14(%ebp),%eax
  8015e9:	e8 1d fc ff ff       	call   80120b <getuint>
			base = 16;
  8015ee:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8015f3:	83 ec 0c             	sub    $0xc,%esp
  8015f6:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015fa:	57                   	push   %edi
  8015fb:	ff 75 e0             	pushl  -0x20(%ebp)
  8015fe:	51                   	push   %ecx
  8015ff:	52                   	push   %edx
  801600:	50                   	push   %eax
  801601:	89 da                	mov    %ebx,%edx
  801603:	89 f0                	mov    %esi,%eax
  801605:	e8 52 fb ff ff       	call   80115c <printnum>
			break;
  80160a:	83 c4 20             	add    $0x20,%esp
  80160d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801610:	e9 90 fc ff ff       	jmp    8012a5 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801615:	83 ec 08             	sub    $0x8,%esp
  801618:	53                   	push   %ebx
  801619:	52                   	push   %edx
  80161a:	ff d6                	call   *%esi
			break;
  80161c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80161f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801622:	e9 7e fc ff ff       	jmp    8012a5 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801627:	83 ec 08             	sub    $0x8,%esp
  80162a:	53                   	push   %ebx
  80162b:	6a 25                	push   $0x25
  80162d:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80162f:	83 c4 10             	add    $0x10,%esp
  801632:	eb 03                	jmp    801637 <vprintfmt+0x3b8>
  801634:	83 ef 01             	sub    $0x1,%edi
  801637:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80163b:	75 f7                	jne    801634 <vprintfmt+0x3b5>
  80163d:	e9 63 fc ff ff       	jmp    8012a5 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801642:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801645:	5b                   	pop    %ebx
  801646:	5e                   	pop    %esi
  801647:	5f                   	pop    %edi
  801648:	5d                   	pop    %ebp
  801649:	c3                   	ret    

0080164a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80164a:	55                   	push   %ebp
  80164b:	89 e5                	mov    %esp,%ebp
  80164d:	83 ec 18             	sub    $0x18,%esp
  801650:	8b 45 08             	mov    0x8(%ebp),%eax
  801653:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801656:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801659:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80165d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801660:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801667:	85 c0                	test   %eax,%eax
  801669:	74 26                	je     801691 <vsnprintf+0x47>
  80166b:	85 d2                	test   %edx,%edx
  80166d:	7e 22                	jle    801691 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80166f:	ff 75 14             	pushl  0x14(%ebp)
  801672:	ff 75 10             	pushl  0x10(%ebp)
  801675:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801678:	50                   	push   %eax
  801679:	68 45 12 80 00       	push   $0x801245
  80167e:	e8 fc fb ff ff       	call   80127f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801683:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801686:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801689:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80168c:	83 c4 10             	add    $0x10,%esp
  80168f:	eb 05                	jmp    801696 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801691:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801696:	c9                   	leave  
  801697:	c3                   	ret    

00801698 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801698:	55                   	push   %ebp
  801699:	89 e5                	mov    %esp,%ebp
  80169b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80169e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8016a1:	50                   	push   %eax
  8016a2:	ff 75 10             	pushl  0x10(%ebp)
  8016a5:	ff 75 0c             	pushl  0xc(%ebp)
  8016a8:	ff 75 08             	pushl  0x8(%ebp)
  8016ab:	e8 9a ff ff ff       	call   80164a <vsnprintf>
	va_end(ap);

	return rc;
}
  8016b0:	c9                   	leave  
  8016b1:	c3                   	ret    

008016b2 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016b2:	55                   	push   %ebp
  8016b3:	89 e5                	mov    %esp,%ebp
  8016b5:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8016bd:	eb 03                	jmp    8016c2 <strlen+0x10>
		n++;
  8016bf:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8016c2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016c6:	75 f7                	jne    8016bf <strlen+0xd>
		n++;
	return n;
}
  8016c8:	5d                   	pop    %ebp
  8016c9:	c3                   	ret    

008016ca <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016ca:	55                   	push   %ebp
  8016cb:	89 e5                	mov    %esp,%ebp
  8016cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016d0:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8016d8:	eb 03                	jmp    8016dd <strnlen+0x13>
		n++;
  8016da:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016dd:	39 c2                	cmp    %eax,%edx
  8016df:	74 08                	je     8016e9 <strnlen+0x1f>
  8016e1:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8016e5:	75 f3                	jne    8016da <strnlen+0x10>
  8016e7:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8016e9:	5d                   	pop    %ebp
  8016ea:	c3                   	ret    

008016eb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016eb:	55                   	push   %ebp
  8016ec:	89 e5                	mov    %esp,%ebp
  8016ee:	53                   	push   %ebx
  8016ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016f5:	89 c2                	mov    %eax,%edx
  8016f7:	83 c2 01             	add    $0x1,%edx
  8016fa:	83 c1 01             	add    $0x1,%ecx
  8016fd:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801701:	88 5a ff             	mov    %bl,-0x1(%edx)
  801704:	84 db                	test   %bl,%bl
  801706:	75 ef                	jne    8016f7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801708:	5b                   	pop    %ebx
  801709:	5d                   	pop    %ebp
  80170a:	c3                   	ret    

0080170b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80170b:	55                   	push   %ebp
  80170c:	89 e5                	mov    %esp,%ebp
  80170e:	53                   	push   %ebx
  80170f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801712:	53                   	push   %ebx
  801713:	e8 9a ff ff ff       	call   8016b2 <strlen>
  801718:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80171b:	ff 75 0c             	pushl  0xc(%ebp)
  80171e:	01 d8                	add    %ebx,%eax
  801720:	50                   	push   %eax
  801721:	e8 c5 ff ff ff       	call   8016eb <strcpy>
	return dst;
}
  801726:	89 d8                	mov    %ebx,%eax
  801728:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80172b:	c9                   	leave  
  80172c:	c3                   	ret    

0080172d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80172d:	55                   	push   %ebp
  80172e:	89 e5                	mov    %esp,%ebp
  801730:	56                   	push   %esi
  801731:	53                   	push   %ebx
  801732:	8b 75 08             	mov    0x8(%ebp),%esi
  801735:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801738:	89 f3                	mov    %esi,%ebx
  80173a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80173d:	89 f2                	mov    %esi,%edx
  80173f:	eb 0f                	jmp    801750 <strncpy+0x23>
		*dst++ = *src;
  801741:	83 c2 01             	add    $0x1,%edx
  801744:	0f b6 01             	movzbl (%ecx),%eax
  801747:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80174a:	80 39 01             	cmpb   $0x1,(%ecx)
  80174d:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801750:	39 da                	cmp    %ebx,%edx
  801752:	75 ed                	jne    801741 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801754:	89 f0                	mov    %esi,%eax
  801756:	5b                   	pop    %ebx
  801757:	5e                   	pop    %esi
  801758:	5d                   	pop    %ebp
  801759:	c3                   	ret    

0080175a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80175a:	55                   	push   %ebp
  80175b:	89 e5                	mov    %esp,%ebp
  80175d:	56                   	push   %esi
  80175e:	53                   	push   %ebx
  80175f:	8b 75 08             	mov    0x8(%ebp),%esi
  801762:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801765:	8b 55 10             	mov    0x10(%ebp),%edx
  801768:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80176a:	85 d2                	test   %edx,%edx
  80176c:	74 21                	je     80178f <strlcpy+0x35>
  80176e:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801772:	89 f2                	mov    %esi,%edx
  801774:	eb 09                	jmp    80177f <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801776:	83 c2 01             	add    $0x1,%edx
  801779:	83 c1 01             	add    $0x1,%ecx
  80177c:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80177f:	39 c2                	cmp    %eax,%edx
  801781:	74 09                	je     80178c <strlcpy+0x32>
  801783:	0f b6 19             	movzbl (%ecx),%ebx
  801786:	84 db                	test   %bl,%bl
  801788:	75 ec                	jne    801776 <strlcpy+0x1c>
  80178a:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80178c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80178f:	29 f0                	sub    %esi,%eax
}
  801791:	5b                   	pop    %ebx
  801792:	5e                   	pop    %esi
  801793:	5d                   	pop    %ebp
  801794:	c3                   	ret    

00801795 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801795:	55                   	push   %ebp
  801796:	89 e5                	mov    %esp,%ebp
  801798:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80179b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80179e:	eb 06                	jmp    8017a6 <strcmp+0x11>
		p++, q++;
  8017a0:	83 c1 01             	add    $0x1,%ecx
  8017a3:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8017a6:	0f b6 01             	movzbl (%ecx),%eax
  8017a9:	84 c0                	test   %al,%al
  8017ab:	74 04                	je     8017b1 <strcmp+0x1c>
  8017ad:	3a 02                	cmp    (%edx),%al
  8017af:	74 ef                	je     8017a0 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017b1:	0f b6 c0             	movzbl %al,%eax
  8017b4:	0f b6 12             	movzbl (%edx),%edx
  8017b7:	29 d0                	sub    %edx,%eax
}
  8017b9:	5d                   	pop    %ebp
  8017ba:	c3                   	ret    

008017bb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017bb:	55                   	push   %ebp
  8017bc:	89 e5                	mov    %esp,%ebp
  8017be:	53                   	push   %ebx
  8017bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017c5:	89 c3                	mov    %eax,%ebx
  8017c7:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017ca:	eb 06                	jmp    8017d2 <strncmp+0x17>
		n--, p++, q++;
  8017cc:	83 c0 01             	add    $0x1,%eax
  8017cf:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017d2:	39 d8                	cmp    %ebx,%eax
  8017d4:	74 15                	je     8017eb <strncmp+0x30>
  8017d6:	0f b6 08             	movzbl (%eax),%ecx
  8017d9:	84 c9                	test   %cl,%cl
  8017db:	74 04                	je     8017e1 <strncmp+0x26>
  8017dd:	3a 0a                	cmp    (%edx),%cl
  8017df:	74 eb                	je     8017cc <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017e1:	0f b6 00             	movzbl (%eax),%eax
  8017e4:	0f b6 12             	movzbl (%edx),%edx
  8017e7:	29 d0                	sub    %edx,%eax
  8017e9:	eb 05                	jmp    8017f0 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017eb:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8017f0:	5b                   	pop    %ebx
  8017f1:	5d                   	pop    %ebp
  8017f2:	c3                   	ret    

008017f3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017f3:	55                   	push   %ebp
  8017f4:	89 e5                	mov    %esp,%ebp
  8017f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017fd:	eb 07                	jmp    801806 <strchr+0x13>
		if (*s == c)
  8017ff:	38 ca                	cmp    %cl,%dl
  801801:	74 0f                	je     801812 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801803:	83 c0 01             	add    $0x1,%eax
  801806:	0f b6 10             	movzbl (%eax),%edx
  801809:	84 d2                	test   %dl,%dl
  80180b:	75 f2                	jne    8017ff <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80180d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801812:	5d                   	pop    %ebp
  801813:	c3                   	ret    

00801814 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801814:	55                   	push   %ebp
  801815:	89 e5                	mov    %esp,%ebp
  801817:	8b 45 08             	mov    0x8(%ebp),%eax
  80181a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80181e:	eb 03                	jmp    801823 <strfind+0xf>
  801820:	83 c0 01             	add    $0x1,%eax
  801823:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801826:	38 ca                	cmp    %cl,%dl
  801828:	74 04                	je     80182e <strfind+0x1a>
  80182a:	84 d2                	test   %dl,%dl
  80182c:	75 f2                	jne    801820 <strfind+0xc>
			break;
	return (char *) s;
}
  80182e:	5d                   	pop    %ebp
  80182f:	c3                   	ret    

00801830 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801830:	55                   	push   %ebp
  801831:	89 e5                	mov    %esp,%ebp
  801833:	57                   	push   %edi
  801834:	56                   	push   %esi
  801835:	53                   	push   %ebx
  801836:	8b 7d 08             	mov    0x8(%ebp),%edi
  801839:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80183c:	85 c9                	test   %ecx,%ecx
  80183e:	74 36                	je     801876 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801840:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801846:	75 28                	jne    801870 <memset+0x40>
  801848:	f6 c1 03             	test   $0x3,%cl
  80184b:	75 23                	jne    801870 <memset+0x40>
		c &= 0xFF;
  80184d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801851:	89 d3                	mov    %edx,%ebx
  801853:	c1 e3 08             	shl    $0x8,%ebx
  801856:	89 d6                	mov    %edx,%esi
  801858:	c1 e6 18             	shl    $0x18,%esi
  80185b:	89 d0                	mov    %edx,%eax
  80185d:	c1 e0 10             	shl    $0x10,%eax
  801860:	09 f0                	or     %esi,%eax
  801862:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801864:	89 d8                	mov    %ebx,%eax
  801866:	09 d0                	or     %edx,%eax
  801868:	c1 e9 02             	shr    $0x2,%ecx
  80186b:	fc                   	cld    
  80186c:	f3 ab                	rep stos %eax,%es:(%edi)
  80186e:	eb 06                	jmp    801876 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801870:	8b 45 0c             	mov    0xc(%ebp),%eax
  801873:	fc                   	cld    
  801874:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801876:	89 f8                	mov    %edi,%eax
  801878:	5b                   	pop    %ebx
  801879:	5e                   	pop    %esi
  80187a:	5f                   	pop    %edi
  80187b:	5d                   	pop    %ebp
  80187c:	c3                   	ret    

0080187d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80187d:	55                   	push   %ebp
  80187e:	89 e5                	mov    %esp,%ebp
  801880:	57                   	push   %edi
  801881:	56                   	push   %esi
  801882:	8b 45 08             	mov    0x8(%ebp),%eax
  801885:	8b 75 0c             	mov    0xc(%ebp),%esi
  801888:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80188b:	39 c6                	cmp    %eax,%esi
  80188d:	73 35                	jae    8018c4 <memmove+0x47>
  80188f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801892:	39 d0                	cmp    %edx,%eax
  801894:	73 2e                	jae    8018c4 <memmove+0x47>
		s += n;
		d += n;
  801896:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801899:	89 d6                	mov    %edx,%esi
  80189b:	09 fe                	or     %edi,%esi
  80189d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018a3:	75 13                	jne    8018b8 <memmove+0x3b>
  8018a5:	f6 c1 03             	test   $0x3,%cl
  8018a8:	75 0e                	jne    8018b8 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8018aa:	83 ef 04             	sub    $0x4,%edi
  8018ad:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018b0:	c1 e9 02             	shr    $0x2,%ecx
  8018b3:	fd                   	std    
  8018b4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018b6:	eb 09                	jmp    8018c1 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018b8:	83 ef 01             	sub    $0x1,%edi
  8018bb:	8d 72 ff             	lea    -0x1(%edx),%esi
  8018be:	fd                   	std    
  8018bf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018c1:	fc                   	cld    
  8018c2:	eb 1d                	jmp    8018e1 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018c4:	89 f2                	mov    %esi,%edx
  8018c6:	09 c2                	or     %eax,%edx
  8018c8:	f6 c2 03             	test   $0x3,%dl
  8018cb:	75 0f                	jne    8018dc <memmove+0x5f>
  8018cd:	f6 c1 03             	test   $0x3,%cl
  8018d0:	75 0a                	jne    8018dc <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8018d2:	c1 e9 02             	shr    $0x2,%ecx
  8018d5:	89 c7                	mov    %eax,%edi
  8018d7:	fc                   	cld    
  8018d8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018da:	eb 05                	jmp    8018e1 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018dc:	89 c7                	mov    %eax,%edi
  8018de:	fc                   	cld    
  8018df:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018e1:	5e                   	pop    %esi
  8018e2:	5f                   	pop    %edi
  8018e3:	5d                   	pop    %ebp
  8018e4:	c3                   	ret    

008018e5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018e5:	55                   	push   %ebp
  8018e6:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018e8:	ff 75 10             	pushl  0x10(%ebp)
  8018eb:	ff 75 0c             	pushl  0xc(%ebp)
  8018ee:	ff 75 08             	pushl  0x8(%ebp)
  8018f1:	e8 87 ff ff ff       	call   80187d <memmove>
}
  8018f6:	c9                   	leave  
  8018f7:	c3                   	ret    

008018f8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018f8:	55                   	push   %ebp
  8018f9:	89 e5                	mov    %esp,%ebp
  8018fb:	56                   	push   %esi
  8018fc:	53                   	push   %ebx
  8018fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801900:	8b 55 0c             	mov    0xc(%ebp),%edx
  801903:	89 c6                	mov    %eax,%esi
  801905:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801908:	eb 1a                	jmp    801924 <memcmp+0x2c>
		if (*s1 != *s2)
  80190a:	0f b6 08             	movzbl (%eax),%ecx
  80190d:	0f b6 1a             	movzbl (%edx),%ebx
  801910:	38 d9                	cmp    %bl,%cl
  801912:	74 0a                	je     80191e <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801914:	0f b6 c1             	movzbl %cl,%eax
  801917:	0f b6 db             	movzbl %bl,%ebx
  80191a:	29 d8                	sub    %ebx,%eax
  80191c:	eb 0f                	jmp    80192d <memcmp+0x35>
		s1++, s2++;
  80191e:	83 c0 01             	add    $0x1,%eax
  801921:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801924:	39 f0                	cmp    %esi,%eax
  801926:	75 e2                	jne    80190a <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801928:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80192d:	5b                   	pop    %ebx
  80192e:	5e                   	pop    %esi
  80192f:	5d                   	pop    %ebp
  801930:	c3                   	ret    

00801931 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801931:	55                   	push   %ebp
  801932:	89 e5                	mov    %esp,%ebp
  801934:	53                   	push   %ebx
  801935:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801938:	89 c1                	mov    %eax,%ecx
  80193a:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80193d:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801941:	eb 0a                	jmp    80194d <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801943:	0f b6 10             	movzbl (%eax),%edx
  801946:	39 da                	cmp    %ebx,%edx
  801948:	74 07                	je     801951 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80194a:	83 c0 01             	add    $0x1,%eax
  80194d:	39 c8                	cmp    %ecx,%eax
  80194f:	72 f2                	jb     801943 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801951:	5b                   	pop    %ebx
  801952:	5d                   	pop    %ebp
  801953:	c3                   	ret    

00801954 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801954:	55                   	push   %ebp
  801955:	89 e5                	mov    %esp,%ebp
  801957:	57                   	push   %edi
  801958:	56                   	push   %esi
  801959:	53                   	push   %ebx
  80195a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80195d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801960:	eb 03                	jmp    801965 <strtol+0x11>
		s++;
  801962:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801965:	0f b6 01             	movzbl (%ecx),%eax
  801968:	3c 20                	cmp    $0x20,%al
  80196a:	74 f6                	je     801962 <strtol+0xe>
  80196c:	3c 09                	cmp    $0x9,%al
  80196e:	74 f2                	je     801962 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801970:	3c 2b                	cmp    $0x2b,%al
  801972:	75 0a                	jne    80197e <strtol+0x2a>
		s++;
  801974:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801977:	bf 00 00 00 00       	mov    $0x0,%edi
  80197c:	eb 11                	jmp    80198f <strtol+0x3b>
  80197e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801983:	3c 2d                	cmp    $0x2d,%al
  801985:	75 08                	jne    80198f <strtol+0x3b>
		s++, neg = 1;
  801987:	83 c1 01             	add    $0x1,%ecx
  80198a:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80198f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801995:	75 15                	jne    8019ac <strtol+0x58>
  801997:	80 39 30             	cmpb   $0x30,(%ecx)
  80199a:	75 10                	jne    8019ac <strtol+0x58>
  80199c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019a0:	75 7c                	jne    801a1e <strtol+0xca>
		s += 2, base = 16;
  8019a2:	83 c1 02             	add    $0x2,%ecx
  8019a5:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019aa:	eb 16                	jmp    8019c2 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8019ac:	85 db                	test   %ebx,%ebx
  8019ae:	75 12                	jne    8019c2 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8019b0:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019b5:	80 39 30             	cmpb   $0x30,(%ecx)
  8019b8:	75 08                	jne    8019c2 <strtol+0x6e>
		s++, base = 8;
  8019ba:	83 c1 01             	add    $0x1,%ecx
  8019bd:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8019c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8019c7:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019ca:	0f b6 11             	movzbl (%ecx),%edx
  8019cd:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019d0:	89 f3                	mov    %esi,%ebx
  8019d2:	80 fb 09             	cmp    $0x9,%bl
  8019d5:	77 08                	ja     8019df <strtol+0x8b>
			dig = *s - '0';
  8019d7:	0f be d2             	movsbl %dl,%edx
  8019da:	83 ea 30             	sub    $0x30,%edx
  8019dd:	eb 22                	jmp    801a01 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8019df:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019e2:	89 f3                	mov    %esi,%ebx
  8019e4:	80 fb 19             	cmp    $0x19,%bl
  8019e7:	77 08                	ja     8019f1 <strtol+0x9d>
			dig = *s - 'a' + 10;
  8019e9:	0f be d2             	movsbl %dl,%edx
  8019ec:	83 ea 57             	sub    $0x57,%edx
  8019ef:	eb 10                	jmp    801a01 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8019f1:	8d 72 bf             	lea    -0x41(%edx),%esi
  8019f4:	89 f3                	mov    %esi,%ebx
  8019f6:	80 fb 19             	cmp    $0x19,%bl
  8019f9:	77 16                	ja     801a11 <strtol+0xbd>
			dig = *s - 'A' + 10;
  8019fb:	0f be d2             	movsbl %dl,%edx
  8019fe:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801a01:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a04:	7d 0b                	jge    801a11 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801a06:	83 c1 01             	add    $0x1,%ecx
  801a09:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a0d:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801a0f:	eb b9                	jmp    8019ca <strtol+0x76>

	if (endptr)
  801a11:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a15:	74 0d                	je     801a24 <strtol+0xd0>
		*endptr = (char *) s;
  801a17:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a1a:	89 0e                	mov    %ecx,(%esi)
  801a1c:	eb 06                	jmp    801a24 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a1e:	85 db                	test   %ebx,%ebx
  801a20:	74 98                	je     8019ba <strtol+0x66>
  801a22:	eb 9e                	jmp    8019c2 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801a24:	89 c2                	mov    %eax,%edx
  801a26:	f7 da                	neg    %edx
  801a28:	85 ff                	test   %edi,%edi
  801a2a:	0f 45 c2             	cmovne %edx,%eax
}
  801a2d:	5b                   	pop    %ebx
  801a2e:	5e                   	pop    %esi
  801a2f:	5f                   	pop    %edi
  801a30:	5d                   	pop    %ebp
  801a31:	c3                   	ret    

00801a32 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801a32:	55                   	push   %ebp
  801a33:	89 e5                	mov    %esp,%ebp
  801a35:	83 ec 08             	sub    $0x8,%esp
	int r;
	int ret;
	if (_pgfault_handler == 0) {
  801a38:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801a3f:	75 36                	jne    801a77 <set_pgfault_handler+0x45>
		// First time through!
		// LAB 4: Your code here.
        
        	ret = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  801a41:	a1 04 40 80 00       	mov    0x804004,%eax
  801a46:	8b 40 48             	mov    0x48(%eax),%eax
  801a49:	83 ec 04             	sub    $0x4,%esp
  801a4c:	68 07 0e 00 00       	push   $0xe07
  801a51:	68 00 f0 bf ee       	push   $0xeebff000
  801a56:	50                   	push   %eax
  801a57:	e8 14 e7 ff ff       	call   800170 <sys_page_alloc>
		if (ret < 0) {
  801a5c:	83 c4 10             	add    $0x10,%esp
  801a5f:	85 c0                	test   %eax,%eax
  801a61:	79 14                	jns    801a77 <set_pgfault_handler+0x45>
		    panic("Allocate user exception stack failed!\n");
  801a63:	83 ec 04             	sub    $0x4,%esp
  801a66:	68 a0 22 80 00       	push   $0x8022a0
  801a6b:	6a 23                	push   $0x23
  801a6d:	68 c8 22 80 00       	push   $0x8022c8
  801a72:	e8 f8 f5 ff ff       	call   80106f <_panic>
		}
	}
	sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  801a77:	a1 04 40 80 00       	mov    0x804004,%eax
  801a7c:	8b 40 48             	mov    0x48(%eax),%eax
  801a7f:	83 ec 08             	sub    $0x8,%esp
  801a82:	68 61 03 80 00       	push   $0x800361
  801a87:	50                   	push   %eax
  801a88:	e8 2e e8 ff ff       	call   8002bb <sys_env_set_pgfault_upcall>
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801a8d:	8b 45 08             	mov    0x8(%ebp),%eax
  801a90:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801a95:	83 c4 10             	add    $0x10,%esp
  801a98:	c9                   	leave  
  801a99:	c3                   	ret    

00801a9a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a9a:	55                   	push   %ebp
  801a9b:	89 e5                	mov    %esp,%ebp
  801a9d:	56                   	push   %esi
  801a9e:	53                   	push   %ebx
  801a9f:	8b 75 08             	mov    0x8(%ebp),%esi
  801aa2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aa5:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_recv not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  801aa8:	85 c0                	test   %eax,%eax
  801aaa:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801aaf:	0f 44 c2             	cmove  %edx,%eax

    int r = sys_ipc_recv(pg);
  801ab2:	83 ec 0c             	sub    $0xc,%esp
  801ab5:	50                   	push   %eax
  801ab6:	e8 65 e8 ff ff       	call   800320 <sys_ipc_recv>
    int from_env = 0, perm = 0;
    if (r == 0) {
  801abb:	83 c4 10             	add    $0x10,%esp
  801abe:	85 c0                	test   %eax,%eax
  801ac0:	75 10                	jne    801ad2 <ipc_recv+0x38>
        from_env = thisenv->env_ipc_from;
  801ac2:	a1 04 40 80 00       	mov    0x804004,%eax
  801ac7:	8b 48 74             	mov    0x74(%eax),%ecx
        perm = thisenv->env_ipc_perm;
  801aca:	8b 50 78             	mov    0x78(%eax),%edx
        r = thisenv->env_ipc_value;
  801acd:	8b 40 70             	mov    0x70(%eax),%eax
  801ad0:	eb 0a                	jmp    801adc <ipc_recv+0x42>
    } else {
        from_env = 0;
        perm = 0;
  801ad2:	ba 00 00 00 00       	mov    $0x0,%edx
    if (r == 0) {
        from_env = thisenv->env_ipc_from;
        perm = thisenv->env_ipc_perm;
        r = thisenv->env_ipc_value;
    } else {
        from_env = 0;
  801ad7:	b9 00 00 00 00       	mov    $0x0,%ecx
        perm = 0;
    }

    if (from_env_store) *from_env_store = from_env;
  801adc:	85 f6                	test   %esi,%esi
  801ade:	74 02                	je     801ae2 <ipc_recv+0x48>
  801ae0:	89 0e                	mov    %ecx,(%esi)
    if (perm_store) *perm_store = perm;
  801ae2:	85 db                	test   %ebx,%ebx
  801ae4:	74 02                	je     801ae8 <ipc_recv+0x4e>
  801ae6:	89 13                	mov    %edx,(%ebx)

    return r;
}
  801ae8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aeb:	5b                   	pop    %ebx
  801aec:	5e                   	pop    %esi
  801aed:	5d                   	pop    %ebp
  801aee:	c3                   	ret    

00801aef <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801aef:	55                   	push   %ebp
  801af0:	89 e5                	mov    %esp,%ebp
  801af2:	57                   	push   %edi
  801af3:	56                   	push   %esi
  801af4:	53                   	push   %ebx
  801af5:	83 ec 0c             	sub    $0xc,%esp
  801af8:	8b 7d 08             	mov    0x8(%ebp),%edi
  801afb:	8b 75 0c             	mov    0xc(%ebp),%esi
  801afe:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  801b01:	85 db                	test   %ebx,%ebx
  801b03:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801b08:	0f 44 d8             	cmove  %eax,%ebx
  801b0b:	eb 1c                	jmp    801b29 <ipc_send+0x3a>

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        if (ret != -E_IPC_NOT_RECV)
  801b0d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b10:	74 12                	je     801b24 <ipc_send+0x35>
            panic("ipc_send error %e", ret);
  801b12:	50                   	push   %eax
  801b13:	68 d6 22 80 00       	push   $0x8022d6
  801b18:	6a 40                	push   $0x40
  801b1a:	68 e8 22 80 00       	push   $0x8022e8
  801b1f:	e8 4b f5 ff ff       	call   80106f <_panic>
        sys_yield();
  801b24:	e8 28 e6 ff ff       	call   800151 <sys_yield>
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801b29:	ff 75 14             	pushl  0x14(%ebp)
  801b2c:	53                   	push   %ebx
  801b2d:	56                   	push   %esi
  801b2e:	57                   	push   %edi
  801b2f:	e8 c9 e7 ff ff       	call   8002fd <sys_ipc_try_send>
  801b34:	83 c4 10             	add    $0x10,%esp
  801b37:	85 c0                	test   %eax,%eax
  801b39:	75 d2                	jne    801b0d <ipc_send+0x1e>
        if (ret != -E_IPC_NOT_RECV)
            panic("ipc_send error %e", ret);
        sys_yield();
    }
}
  801b3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b3e:	5b                   	pop    %ebx
  801b3f:	5e                   	pop    %esi
  801b40:	5f                   	pop    %edi
  801b41:	5d                   	pop    %ebp
  801b42:	c3                   	ret    

00801b43 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b43:	55                   	push   %ebp
  801b44:	89 e5                	mov    %esp,%ebp
  801b46:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b49:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b4e:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b51:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b57:	8b 52 50             	mov    0x50(%edx),%edx
  801b5a:	39 ca                	cmp    %ecx,%edx
  801b5c:	75 0d                	jne    801b6b <ipc_find_env+0x28>
			return envs[i].env_id;
  801b5e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b61:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b66:	8b 40 48             	mov    0x48(%eax),%eax
  801b69:	eb 0f                	jmp    801b7a <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b6b:	83 c0 01             	add    $0x1,%eax
  801b6e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b73:	75 d9                	jne    801b4e <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b75:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b7a:	5d                   	pop    %ebp
  801b7b:	c3                   	ret    

00801b7c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b7c:	55                   	push   %ebp
  801b7d:	89 e5                	mov    %esp,%ebp
  801b7f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b82:	89 d0                	mov    %edx,%eax
  801b84:	c1 e8 16             	shr    $0x16,%eax
  801b87:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b8e:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b93:	f6 c1 01             	test   $0x1,%cl
  801b96:	74 1d                	je     801bb5 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b98:	c1 ea 0c             	shr    $0xc,%edx
  801b9b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801ba2:	f6 c2 01             	test   $0x1,%dl
  801ba5:	74 0e                	je     801bb5 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ba7:	c1 ea 0c             	shr    $0xc,%edx
  801baa:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801bb1:	ef 
  801bb2:	0f b7 c0             	movzwl %ax,%eax
}
  801bb5:	5d                   	pop    %ebp
  801bb6:	c3                   	ret    
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
