
obj/user/idle.debug:     file format elf32-i386


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
  80002c:	e8 19 00 00 00       	call   80004a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/x86.h>
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 08             	sub    $0x8,%esp
	binaryname = "idle";
  800039:	c7 05 00 30 80 00 c0 	movl   $0x801dc0,0x803000
  800040:	1d 80 00 
	// Instead of busy-waiting like this,
	// a better way would be to use the processor's HLT instruction
	// to cause the processor to stop executing until the next interrupt -
	// doing so allows the processor to conserve power more effectively.
	while (1) {
		sys_yield();
  800043:	e8 ff 00 00 00       	call   800147 <sys_yield>
  800048:	eb f9                	jmp    800043 <umain+0x10>

0080004a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004a:	55                   	push   %ebp
  80004b:	89 e5                	mov    %esp,%ebp
  80004d:	56                   	push   %esi
  80004e:	53                   	push   %ebx
  80004f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800052:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  800055:	e8 ce 00 00 00       	call   800128 <sys_getenvid>
  80005a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800062:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800067:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006c:	85 db                	test   %ebx,%ebx
  80006e:	7e 07                	jle    800077 <libmain+0x2d>
		binaryname = argv[0];
  800070:	8b 06                	mov    (%esi),%eax
  800072:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800077:	83 ec 08             	sub    $0x8,%esp
  80007a:	56                   	push   %esi
  80007b:	53                   	push   %ebx
  80007c:	e8 b2 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800081:	e8 0a 00 00 00       	call   800090 <exit>
}
  800086:	83 c4 10             	add    $0x10,%esp
  800089:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008c:	5b                   	pop    %ebx
  80008d:	5e                   	pop    %esi
  80008e:	5d                   	pop    %ebp
  80008f:	c3                   	ret    

00800090 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800090:	55                   	push   %ebp
  800091:	89 e5                	mov    %esp,%ebp
  800093:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800096:	e8 87 04 00 00       	call   800522 <close_all>
	sys_env_destroy(0);
  80009b:	83 ec 0c             	sub    $0xc,%esp
  80009e:	6a 00                	push   $0x0
  8000a0:	e8 42 00 00 00       	call   8000e7 <sys_env_destroy>
}
  8000a5:	83 c4 10             	add    $0x10,%esp
  8000a8:	c9                   	leave  
  8000a9:	c3                   	ret    

008000aa <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000aa:	55                   	push   %ebp
  8000ab:	89 e5                	mov    %esp,%ebp
  8000ad:	57                   	push   %edi
  8000ae:	56                   	push   %esi
  8000af:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bb:	89 c3                	mov    %eax,%ebx
  8000bd:	89 c7                	mov    %eax,%edi
  8000bf:	89 c6                	mov    %eax,%esi
  8000c1:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c3:	5b                   	pop    %ebx
  8000c4:	5e                   	pop    %esi
  8000c5:	5f                   	pop    %edi
  8000c6:	5d                   	pop    %ebp
  8000c7:	c3                   	ret    

008000c8 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	57                   	push   %edi
  8000cc:	56                   	push   %esi
  8000cd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d8:	89 d1                	mov    %edx,%ecx
  8000da:	89 d3                	mov    %edx,%ebx
  8000dc:	89 d7                	mov    %edx,%edi
  8000de:	89 d6                	mov    %edx,%esi
  8000e0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e2:	5b                   	pop    %ebx
  8000e3:	5e                   	pop    %esi
  8000e4:	5f                   	pop    %edi
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    

008000e7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	57                   	push   %edi
  8000eb:	56                   	push   %esi
  8000ec:	53                   	push   %ebx
  8000ed:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f5:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fd:	89 cb                	mov    %ecx,%ebx
  8000ff:	89 cf                	mov    %ecx,%edi
  800101:	89 ce                	mov    %ecx,%esi
  800103:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800105:	85 c0                	test   %eax,%eax
  800107:	7e 17                	jle    800120 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800109:	83 ec 0c             	sub    $0xc,%esp
  80010c:	50                   	push   %eax
  80010d:	6a 03                	push   $0x3
  80010f:	68 cf 1d 80 00       	push   $0x801dcf
  800114:	6a 23                	push   $0x23
  800116:	68 ec 1d 80 00       	push   $0x801dec
  80011b:	e8 21 0f 00 00       	call   801041 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800120:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800123:	5b                   	pop    %ebx
  800124:	5e                   	pop    %esi
  800125:	5f                   	pop    %edi
  800126:	5d                   	pop    %ebp
  800127:	c3                   	ret    

00800128 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800128:	55                   	push   %ebp
  800129:	89 e5                	mov    %esp,%ebp
  80012b:	57                   	push   %edi
  80012c:	56                   	push   %esi
  80012d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80012e:	ba 00 00 00 00       	mov    $0x0,%edx
  800133:	b8 02 00 00 00       	mov    $0x2,%eax
  800138:	89 d1                	mov    %edx,%ecx
  80013a:	89 d3                	mov    %edx,%ebx
  80013c:	89 d7                	mov    %edx,%edi
  80013e:	89 d6                	mov    %edx,%esi
  800140:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800142:	5b                   	pop    %ebx
  800143:	5e                   	pop    %esi
  800144:	5f                   	pop    %edi
  800145:	5d                   	pop    %ebp
  800146:	c3                   	ret    

00800147 <sys_yield>:

void
sys_yield(void)
{
  800147:	55                   	push   %ebp
  800148:	89 e5                	mov    %esp,%ebp
  80014a:	57                   	push   %edi
  80014b:	56                   	push   %esi
  80014c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014d:	ba 00 00 00 00       	mov    $0x0,%edx
  800152:	b8 0b 00 00 00       	mov    $0xb,%eax
  800157:	89 d1                	mov    %edx,%ecx
  800159:	89 d3                	mov    %edx,%ebx
  80015b:	89 d7                	mov    %edx,%edi
  80015d:	89 d6                	mov    %edx,%esi
  80015f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800161:	5b                   	pop    %ebx
  800162:	5e                   	pop    %esi
  800163:	5f                   	pop    %edi
  800164:	5d                   	pop    %ebp
  800165:	c3                   	ret    

00800166 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800166:	55                   	push   %ebp
  800167:	89 e5                	mov    %esp,%ebp
  800169:	57                   	push   %edi
  80016a:	56                   	push   %esi
  80016b:	53                   	push   %ebx
  80016c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016f:	be 00 00 00 00       	mov    $0x0,%esi
  800174:	b8 04 00 00 00       	mov    $0x4,%eax
  800179:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80017c:	8b 55 08             	mov    0x8(%ebp),%edx
  80017f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800182:	89 f7                	mov    %esi,%edi
  800184:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800186:	85 c0                	test   %eax,%eax
  800188:	7e 17                	jle    8001a1 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80018a:	83 ec 0c             	sub    $0xc,%esp
  80018d:	50                   	push   %eax
  80018e:	6a 04                	push   $0x4
  800190:	68 cf 1d 80 00       	push   $0x801dcf
  800195:	6a 23                	push   $0x23
  800197:	68 ec 1d 80 00       	push   $0x801dec
  80019c:	e8 a0 0e 00 00       	call   801041 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a4:	5b                   	pop    %ebx
  8001a5:	5e                   	pop    %esi
  8001a6:	5f                   	pop    %edi
  8001a7:	5d                   	pop    %ebp
  8001a8:	c3                   	ret    

008001a9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a9:	55                   	push   %ebp
  8001aa:	89 e5                	mov    %esp,%ebp
  8001ac:	57                   	push   %edi
  8001ad:	56                   	push   %esi
  8001ae:	53                   	push   %ebx
  8001af:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b2:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c3:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001c8:	85 c0                	test   %eax,%eax
  8001ca:	7e 17                	jle    8001e3 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001cc:	83 ec 0c             	sub    $0xc,%esp
  8001cf:	50                   	push   %eax
  8001d0:	6a 05                	push   $0x5
  8001d2:	68 cf 1d 80 00       	push   $0x801dcf
  8001d7:	6a 23                	push   $0x23
  8001d9:	68 ec 1d 80 00       	push   $0x801dec
  8001de:	e8 5e 0e 00 00       	call   801041 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e6:	5b                   	pop    %ebx
  8001e7:	5e                   	pop    %esi
  8001e8:	5f                   	pop    %edi
  8001e9:	5d                   	pop    %ebp
  8001ea:	c3                   	ret    

008001eb <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001eb:	55                   	push   %ebp
  8001ec:	89 e5                	mov    %esp,%ebp
  8001ee:	57                   	push   %edi
  8001ef:	56                   	push   %esi
  8001f0:	53                   	push   %ebx
  8001f1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f9:	b8 06 00 00 00       	mov    $0x6,%eax
  8001fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800201:	8b 55 08             	mov    0x8(%ebp),%edx
  800204:	89 df                	mov    %ebx,%edi
  800206:	89 de                	mov    %ebx,%esi
  800208:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80020a:	85 c0                	test   %eax,%eax
  80020c:	7e 17                	jle    800225 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80020e:	83 ec 0c             	sub    $0xc,%esp
  800211:	50                   	push   %eax
  800212:	6a 06                	push   $0x6
  800214:	68 cf 1d 80 00       	push   $0x801dcf
  800219:	6a 23                	push   $0x23
  80021b:	68 ec 1d 80 00       	push   $0x801dec
  800220:	e8 1c 0e 00 00       	call   801041 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800225:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800228:	5b                   	pop    %ebx
  800229:	5e                   	pop    %esi
  80022a:	5f                   	pop    %edi
  80022b:	5d                   	pop    %ebp
  80022c:	c3                   	ret    

0080022d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022d:	55                   	push   %ebp
  80022e:	89 e5                	mov    %esp,%ebp
  800230:	57                   	push   %edi
  800231:	56                   	push   %esi
  800232:	53                   	push   %ebx
  800233:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800236:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023b:	b8 08 00 00 00       	mov    $0x8,%eax
  800240:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800243:	8b 55 08             	mov    0x8(%ebp),%edx
  800246:	89 df                	mov    %ebx,%edi
  800248:	89 de                	mov    %ebx,%esi
  80024a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80024c:	85 c0                	test   %eax,%eax
  80024e:	7e 17                	jle    800267 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800250:	83 ec 0c             	sub    $0xc,%esp
  800253:	50                   	push   %eax
  800254:	6a 08                	push   $0x8
  800256:	68 cf 1d 80 00       	push   $0x801dcf
  80025b:	6a 23                	push   $0x23
  80025d:	68 ec 1d 80 00       	push   $0x801dec
  800262:	e8 da 0d 00 00       	call   801041 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800267:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026a:	5b                   	pop    %ebx
  80026b:	5e                   	pop    %esi
  80026c:	5f                   	pop    %edi
  80026d:	5d                   	pop    %ebp
  80026e:	c3                   	ret    

0080026f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80026f:	55                   	push   %ebp
  800270:	89 e5                	mov    %esp,%ebp
  800272:	57                   	push   %edi
  800273:	56                   	push   %esi
  800274:	53                   	push   %ebx
  800275:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800278:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027d:	b8 09 00 00 00       	mov    $0x9,%eax
  800282:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800285:	8b 55 08             	mov    0x8(%ebp),%edx
  800288:	89 df                	mov    %ebx,%edi
  80028a:	89 de                	mov    %ebx,%esi
  80028c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80028e:	85 c0                	test   %eax,%eax
  800290:	7e 17                	jle    8002a9 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800292:	83 ec 0c             	sub    $0xc,%esp
  800295:	50                   	push   %eax
  800296:	6a 09                	push   $0x9
  800298:	68 cf 1d 80 00       	push   $0x801dcf
  80029d:	6a 23                	push   $0x23
  80029f:	68 ec 1d 80 00       	push   $0x801dec
  8002a4:	e8 98 0d 00 00       	call   801041 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ac:	5b                   	pop    %ebx
  8002ad:	5e                   	pop    %esi
  8002ae:	5f                   	pop    %edi
  8002af:	5d                   	pop    %ebp
  8002b0:	c3                   	ret    

008002b1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	57                   	push   %edi
  8002b5:	56                   	push   %esi
  8002b6:	53                   	push   %ebx
  8002b7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ba:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002bf:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ca:	89 df                	mov    %ebx,%edi
  8002cc:	89 de                	mov    %ebx,%esi
  8002ce:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002d0:	85 c0                	test   %eax,%eax
  8002d2:	7e 17                	jle    8002eb <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d4:	83 ec 0c             	sub    $0xc,%esp
  8002d7:	50                   	push   %eax
  8002d8:	6a 0a                	push   $0xa
  8002da:	68 cf 1d 80 00       	push   $0x801dcf
  8002df:	6a 23                	push   $0x23
  8002e1:	68 ec 1d 80 00       	push   $0x801dec
  8002e6:	e8 56 0d 00 00       	call   801041 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ee:	5b                   	pop    %ebx
  8002ef:	5e                   	pop    %esi
  8002f0:	5f                   	pop    %edi
  8002f1:	5d                   	pop    %ebp
  8002f2:	c3                   	ret    

008002f3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f3:	55                   	push   %ebp
  8002f4:	89 e5                	mov    %esp,%ebp
  8002f6:	57                   	push   %edi
  8002f7:	56                   	push   %esi
  8002f8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f9:	be 00 00 00 00       	mov    $0x0,%esi
  8002fe:	b8 0c 00 00 00       	mov    $0xc,%eax
  800303:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800306:	8b 55 08             	mov    0x8(%ebp),%edx
  800309:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80030c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80030f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800311:	5b                   	pop    %ebx
  800312:	5e                   	pop    %esi
  800313:	5f                   	pop    %edi
  800314:	5d                   	pop    %ebp
  800315:	c3                   	ret    

00800316 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800316:	55                   	push   %ebp
  800317:	89 e5                	mov    %esp,%ebp
  800319:	57                   	push   %edi
  80031a:	56                   	push   %esi
  80031b:	53                   	push   %ebx
  80031c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80031f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800324:	b8 0d 00 00 00       	mov    $0xd,%eax
  800329:	8b 55 08             	mov    0x8(%ebp),%edx
  80032c:	89 cb                	mov    %ecx,%ebx
  80032e:	89 cf                	mov    %ecx,%edi
  800330:	89 ce                	mov    %ecx,%esi
  800332:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800334:	85 c0                	test   %eax,%eax
  800336:	7e 17                	jle    80034f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800338:	83 ec 0c             	sub    $0xc,%esp
  80033b:	50                   	push   %eax
  80033c:	6a 0d                	push   $0xd
  80033e:	68 cf 1d 80 00       	push   $0x801dcf
  800343:	6a 23                	push   $0x23
  800345:	68 ec 1d 80 00       	push   $0x801dec
  80034a:	e8 f2 0c 00 00       	call   801041 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80034f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800352:	5b                   	pop    %ebx
  800353:	5e                   	pop    %esi
  800354:	5f                   	pop    %edi
  800355:	5d                   	pop    %ebp
  800356:	c3                   	ret    

00800357 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800357:	55                   	push   %ebp
  800358:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80035a:	8b 45 08             	mov    0x8(%ebp),%eax
  80035d:	05 00 00 00 30       	add    $0x30000000,%eax
  800362:	c1 e8 0c             	shr    $0xc,%eax
}
  800365:	5d                   	pop    %ebp
  800366:	c3                   	ret    

00800367 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800367:	55                   	push   %ebp
  800368:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80036a:	8b 45 08             	mov    0x8(%ebp),%eax
  80036d:	05 00 00 00 30       	add    $0x30000000,%eax
  800372:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800377:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80037c:	5d                   	pop    %ebp
  80037d:	c3                   	ret    

0080037e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80037e:	55                   	push   %ebp
  80037f:	89 e5                	mov    %esp,%ebp
  800381:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800384:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800389:	89 c2                	mov    %eax,%edx
  80038b:	c1 ea 16             	shr    $0x16,%edx
  80038e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800395:	f6 c2 01             	test   $0x1,%dl
  800398:	74 11                	je     8003ab <fd_alloc+0x2d>
  80039a:	89 c2                	mov    %eax,%edx
  80039c:	c1 ea 0c             	shr    $0xc,%edx
  80039f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003a6:	f6 c2 01             	test   $0x1,%dl
  8003a9:	75 09                	jne    8003b4 <fd_alloc+0x36>
			*fd_store = fd;
  8003ab:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b2:	eb 17                	jmp    8003cb <fd_alloc+0x4d>
  8003b4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003b9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003be:	75 c9                	jne    800389 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003c0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003c6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003cb:	5d                   	pop    %ebp
  8003cc:	c3                   	ret    

008003cd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003cd:	55                   	push   %ebp
  8003ce:	89 e5                	mov    %esp,%ebp
  8003d0:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003d3:	83 f8 1f             	cmp    $0x1f,%eax
  8003d6:	77 36                	ja     80040e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003d8:	c1 e0 0c             	shl    $0xc,%eax
  8003db:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003e0:	89 c2                	mov    %eax,%edx
  8003e2:	c1 ea 16             	shr    $0x16,%edx
  8003e5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003ec:	f6 c2 01             	test   $0x1,%dl
  8003ef:	74 24                	je     800415 <fd_lookup+0x48>
  8003f1:	89 c2                	mov    %eax,%edx
  8003f3:	c1 ea 0c             	shr    $0xc,%edx
  8003f6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003fd:	f6 c2 01             	test   $0x1,%dl
  800400:	74 1a                	je     80041c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800402:	8b 55 0c             	mov    0xc(%ebp),%edx
  800405:	89 02                	mov    %eax,(%edx)
	return 0;
  800407:	b8 00 00 00 00       	mov    $0x0,%eax
  80040c:	eb 13                	jmp    800421 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80040e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800413:	eb 0c                	jmp    800421 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800415:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80041a:	eb 05                	jmp    800421 <fd_lookup+0x54>
  80041c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800421:	5d                   	pop    %ebp
  800422:	c3                   	ret    

00800423 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800423:	55                   	push   %ebp
  800424:	89 e5                	mov    %esp,%ebp
  800426:	83 ec 08             	sub    $0x8,%esp
  800429:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80042c:	ba 78 1e 80 00       	mov    $0x801e78,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800431:	eb 13                	jmp    800446 <dev_lookup+0x23>
  800433:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800436:	39 08                	cmp    %ecx,(%eax)
  800438:	75 0c                	jne    800446 <dev_lookup+0x23>
			*dev = devtab[i];
  80043a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80043d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80043f:	b8 00 00 00 00       	mov    $0x0,%eax
  800444:	eb 2e                	jmp    800474 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800446:	8b 02                	mov    (%edx),%eax
  800448:	85 c0                	test   %eax,%eax
  80044a:	75 e7                	jne    800433 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80044c:	a1 04 40 80 00       	mov    0x804004,%eax
  800451:	8b 40 48             	mov    0x48(%eax),%eax
  800454:	83 ec 04             	sub    $0x4,%esp
  800457:	51                   	push   %ecx
  800458:	50                   	push   %eax
  800459:	68 fc 1d 80 00       	push   $0x801dfc
  80045e:	e8 b7 0c 00 00       	call   80111a <cprintf>
	*dev = 0;
  800463:	8b 45 0c             	mov    0xc(%ebp),%eax
  800466:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80046c:	83 c4 10             	add    $0x10,%esp
  80046f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800474:	c9                   	leave  
  800475:	c3                   	ret    

00800476 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800476:	55                   	push   %ebp
  800477:	89 e5                	mov    %esp,%ebp
  800479:	56                   	push   %esi
  80047a:	53                   	push   %ebx
  80047b:	83 ec 10             	sub    $0x10,%esp
  80047e:	8b 75 08             	mov    0x8(%ebp),%esi
  800481:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800484:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800487:	50                   	push   %eax
  800488:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80048e:	c1 e8 0c             	shr    $0xc,%eax
  800491:	50                   	push   %eax
  800492:	e8 36 ff ff ff       	call   8003cd <fd_lookup>
  800497:	83 c4 08             	add    $0x8,%esp
  80049a:	85 c0                	test   %eax,%eax
  80049c:	78 05                	js     8004a3 <fd_close+0x2d>
	    || fd != fd2)
  80049e:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004a1:	74 0c                	je     8004af <fd_close+0x39>
		return (must_exist ? r : 0);
  8004a3:	84 db                	test   %bl,%bl
  8004a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8004aa:	0f 44 c2             	cmove  %edx,%eax
  8004ad:	eb 41                	jmp    8004f0 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004af:	83 ec 08             	sub    $0x8,%esp
  8004b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004b5:	50                   	push   %eax
  8004b6:	ff 36                	pushl  (%esi)
  8004b8:	e8 66 ff ff ff       	call   800423 <dev_lookup>
  8004bd:	89 c3                	mov    %eax,%ebx
  8004bf:	83 c4 10             	add    $0x10,%esp
  8004c2:	85 c0                	test   %eax,%eax
  8004c4:	78 1a                	js     8004e0 <fd_close+0x6a>
		if (dev->dev_close)
  8004c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004c9:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004cc:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004d1:	85 c0                	test   %eax,%eax
  8004d3:	74 0b                	je     8004e0 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004d5:	83 ec 0c             	sub    $0xc,%esp
  8004d8:	56                   	push   %esi
  8004d9:	ff d0                	call   *%eax
  8004db:	89 c3                	mov    %eax,%ebx
  8004dd:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004e0:	83 ec 08             	sub    $0x8,%esp
  8004e3:	56                   	push   %esi
  8004e4:	6a 00                	push   $0x0
  8004e6:	e8 00 fd ff ff       	call   8001eb <sys_page_unmap>
	return r;
  8004eb:	83 c4 10             	add    $0x10,%esp
  8004ee:	89 d8                	mov    %ebx,%eax
}
  8004f0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004f3:	5b                   	pop    %ebx
  8004f4:	5e                   	pop    %esi
  8004f5:	5d                   	pop    %ebp
  8004f6:	c3                   	ret    

008004f7 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004f7:	55                   	push   %ebp
  8004f8:	89 e5                	mov    %esp,%ebp
  8004fa:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800500:	50                   	push   %eax
  800501:	ff 75 08             	pushl  0x8(%ebp)
  800504:	e8 c4 fe ff ff       	call   8003cd <fd_lookup>
  800509:	83 c4 08             	add    $0x8,%esp
  80050c:	85 c0                	test   %eax,%eax
  80050e:	78 10                	js     800520 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800510:	83 ec 08             	sub    $0x8,%esp
  800513:	6a 01                	push   $0x1
  800515:	ff 75 f4             	pushl  -0xc(%ebp)
  800518:	e8 59 ff ff ff       	call   800476 <fd_close>
  80051d:	83 c4 10             	add    $0x10,%esp
}
  800520:	c9                   	leave  
  800521:	c3                   	ret    

00800522 <close_all>:

void
close_all(void)
{
  800522:	55                   	push   %ebp
  800523:	89 e5                	mov    %esp,%ebp
  800525:	53                   	push   %ebx
  800526:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800529:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80052e:	83 ec 0c             	sub    $0xc,%esp
  800531:	53                   	push   %ebx
  800532:	e8 c0 ff ff ff       	call   8004f7 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800537:	83 c3 01             	add    $0x1,%ebx
  80053a:	83 c4 10             	add    $0x10,%esp
  80053d:	83 fb 20             	cmp    $0x20,%ebx
  800540:	75 ec                	jne    80052e <close_all+0xc>
		close(i);
}
  800542:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800545:	c9                   	leave  
  800546:	c3                   	ret    

00800547 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800547:	55                   	push   %ebp
  800548:	89 e5                	mov    %esp,%ebp
  80054a:	57                   	push   %edi
  80054b:	56                   	push   %esi
  80054c:	53                   	push   %ebx
  80054d:	83 ec 2c             	sub    $0x2c,%esp
  800550:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800553:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800556:	50                   	push   %eax
  800557:	ff 75 08             	pushl  0x8(%ebp)
  80055a:	e8 6e fe ff ff       	call   8003cd <fd_lookup>
  80055f:	83 c4 08             	add    $0x8,%esp
  800562:	85 c0                	test   %eax,%eax
  800564:	0f 88 c1 00 00 00    	js     80062b <dup+0xe4>
		return r;
	close(newfdnum);
  80056a:	83 ec 0c             	sub    $0xc,%esp
  80056d:	56                   	push   %esi
  80056e:	e8 84 ff ff ff       	call   8004f7 <close>

	newfd = INDEX2FD(newfdnum);
  800573:	89 f3                	mov    %esi,%ebx
  800575:	c1 e3 0c             	shl    $0xc,%ebx
  800578:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80057e:	83 c4 04             	add    $0x4,%esp
  800581:	ff 75 e4             	pushl  -0x1c(%ebp)
  800584:	e8 de fd ff ff       	call   800367 <fd2data>
  800589:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80058b:	89 1c 24             	mov    %ebx,(%esp)
  80058e:	e8 d4 fd ff ff       	call   800367 <fd2data>
  800593:	83 c4 10             	add    $0x10,%esp
  800596:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800599:	89 f8                	mov    %edi,%eax
  80059b:	c1 e8 16             	shr    $0x16,%eax
  80059e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005a5:	a8 01                	test   $0x1,%al
  8005a7:	74 37                	je     8005e0 <dup+0x99>
  8005a9:	89 f8                	mov    %edi,%eax
  8005ab:	c1 e8 0c             	shr    $0xc,%eax
  8005ae:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005b5:	f6 c2 01             	test   $0x1,%dl
  8005b8:	74 26                	je     8005e0 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005ba:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005c1:	83 ec 0c             	sub    $0xc,%esp
  8005c4:	25 07 0e 00 00       	and    $0xe07,%eax
  8005c9:	50                   	push   %eax
  8005ca:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005cd:	6a 00                	push   $0x0
  8005cf:	57                   	push   %edi
  8005d0:	6a 00                	push   $0x0
  8005d2:	e8 d2 fb ff ff       	call   8001a9 <sys_page_map>
  8005d7:	89 c7                	mov    %eax,%edi
  8005d9:	83 c4 20             	add    $0x20,%esp
  8005dc:	85 c0                	test   %eax,%eax
  8005de:	78 2e                	js     80060e <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005e0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005e3:	89 d0                	mov    %edx,%eax
  8005e5:	c1 e8 0c             	shr    $0xc,%eax
  8005e8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005ef:	83 ec 0c             	sub    $0xc,%esp
  8005f2:	25 07 0e 00 00       	and    $0xe07,%eax
  8005f7:	50                   	push   %eax
  8005f8:	53                   	push   %ebx
  8005f9:	6a 00                	push   $0x0
  8005fb:	52                   	push   %edx
  8005fc:	6a 00                	push   $0x0
  8005fe:	e8 a6 fb ff ff       	call   8001a9 <sys_page_map>
  800603:	89 c7                	mov    %eax,%edi
  800605:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800608:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80060a:	85 ff                	test   %edi,%edi
  80060c:	79 1d                	jns    80062b <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80060e:	83 ec 08             	sub    $0x8,%esp
  800611:	53                   	push   %ebx
  800612:	6a 00                	push   $0x0
  800614:	e8 d2 fb ff ff       	call   8001eb <sys_page_unmap>
	sys_page_unmap(0, nva);
  800619:	83 c4 08             	add    $0x8,%esp
  80061c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80061f:	6a 00                	push   $0x0
  800621:	e8 c5 fb ff ff       	call   8001eb <sys_page_unmap>
	return r;
  800626:	83 c4 10             	add    $0x10,%esp
  800629:	89 f8                	mov    %edi,%eax
}
  80062b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80062e:	5b                   	pop    %ebx
  80062f:	5e                   	pop    %esi
  800630:	5f                   	pop    %edi
  800631:	5d                   	pop    %ebp
  800632:	c3                   	ret    

00800633 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800633:	55                   	push   %ebp
  800634:	89 e5                	mov    %esp,%ebp
  800636:	53                   	push   %ebx
  800637:	83 ec 14             	sub    $0x14,%esp
  80063a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80063d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800640:	50                   	push   %eax
  800641:	53                   	push   %ebx
  800642:	e8 86 fd ff ff       	call   8003cd <fd_lookup>
  800647:	83 c4 08             	add    $0x8,%esp
  80064a:	89 c2                	mov    %eax,%edx
  80064c:	85 c0                	test   %eax,%eax
  80064e:	78 6d                	js     8006bd <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800650:	83 ec 08             	sub    $0x8,%esp
  800653:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800656:	50                   	push   %eax
  800657:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80065a:	ff 30                	pushl  (%eax)
  80065c:	e8 c2 fd ff ff       	call   800423 <dev_lookup>
  800661:	83 c4 10             	add    $0x10,%esp
  800664:	85 c0                	test   %eax,%eax
  800666:	78 4c                	js     8006b4 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800668:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80066b:	8b 42 08             	mov    0x8(%edx),%eax
  80066e:	83 e0 03             	and    $0x3,%eax
  800671:	83 f8 01             	cmp    $0x1,%eax
  800674:	75 21                	jne    800697 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800676:	a1 04 40 80 00       	mov    0x804004,%eax
  80067b:	8b 40 48             	mov    0x48(%eax),%eax
  80067e:	83 ec 04             	sub    $0x4,%esp
  800681:	53                   	push   %ebx
  800682:	50                   	push   %eax
  800683:	68 3d 1e 80 00       	push   $0x801e3d
  800688:	e8 8d 0a 00 00       	call   80111a <cprintf>
		return -E_INVAL;
  80068d:	83 c4 10             	add    $0x10,%esp
  800690:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800695:	eb 26                	jmp    8006bd <read+0x8a>
	}
	if (!dev->dev_read)
  800697:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80069a:	8b 40 08             	mov    0x8(%eax),%eax
  80069d:	85 c0                	test   %eax,%eax
  80069f:	74 17                	je     8006b8 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006a1:	83 ec 04             	sub    $0x4,%esp
  8006a4:	ff 75 10             	pushl  0x10(%ebp)
  8006a7:	ff 75 0c             	pushl  0xc(%ebp)
  8006aa:	52                   	push   %edx
  8006ab:	ff d0                	call   *%eax
  8006ad:	89 c2                	mov    %eax,%edx
  8006af:	83 c4 10             	add    $0x10,%esp
  8006b2:	eb 09                	jmp    8006bd <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006b4:	89 c2                	mov    %eax,%edx
  8006b6:	eb 05                	jmp    8006bd <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006b8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006bd:	89 d0                	mov    %edx,%eax
  8006bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006c2:	c9                   	leave  
  8006c3:	c3                   	ret    

008006c4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006c4:	55                   	push   %ebp
  8006c5:	89 e5                	mov    %esp,%ebp
  8006c7:	57                   	push   %edi
  8006c8:	56                   	push   %esi
  8006c9:	53                   	push   %ebx
  8006ca:	83 ec 0c             	sub    $0xc,%esp
  8006cd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006d0:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006d3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d8:	eb 21                	jmp    8006fb <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006da:	83 ec 04             	sub    $0x4,%esp
  8006dd:	89 f0                	mov    %esi,%eax
  8006df:	29 d8                	sub    %ebx,%eax
  8006e1:	50                   	push   %eax
  8006e2:	89 d8                	mov    %ebx,%eax
  8006e4:	03 45 0c             	add    0xc(%ebp),%eax
  8006e7:	50                   	push   %eax
  8006e8:	57                   	push   %edi
  8006e9:	e8 45 ff ff ff       	call   800633 <read>
		if (m < 0)
  8006ee:	83 c4 10             	add    $0x10,%esp
  8006f1:	85 c0                	test   %eax,%eax
  8006f3:	78 10                	js     800705 <readn+0x41>
			return m;
		if (m == 0)
  8006f5:	85 c0                	test   %eax,%eax
  8006f7:	74 0a                	je     800703 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006f9:	01 c3                	add    %eax,%ebx
  8006fb:	39 f3                	cmp    %esi,%ebx
  8006fd:	72 db                	jb     8006da <readn+0x16>
  8006ff:	89 d8                	mov    %ebx,%eax
  800701:	eb 02                	jmp    800705 <readn+0x41>
  800703:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800705:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800708:	5b                   	pop    %ebx
  800709:	5e                   	pop    %esi
  80070a:	5f                   	pop    %edi
  80070b:	5d                   	pop    %ebp
  80070c:	c3                   	ret    

0080070d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80070d:	55                   	push   %ebp
  80070e:	89 e5                	mov    %esp,%ebp
  800710:	53                   	push   %ebx
  800711:	83 ec 14             	sub    $0x14,%esp
  800714:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800717:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80071a:	50                   	push   %eax
  80071b:	53                   	push   %ebx
  80071c:	e8 ac fc ff ff       	call   8003cd <fd_lookup>
  800721:	83 c4 08             	add    $0x8,%esp
  800724:	89 c2                	mov    %eax,%edx
  800726:	85 c0                	test   %eax,%eax
  800728:	78 68                	js     800792 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80072a:	83 ec 08             	sub    $0x8,%esp
  80072d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800730:	50                   	push   %eax
  800731:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800734:	ff 30                	pushl  (%eax)
  800736:	e8 e8 fc ff ff       	call   800423 <dev_lookup>
  80073b:	83 c4 10             	add    $0x10,%esp
  80073e:	85 c0                	test   %eax,%eax
  800740:	78 47                	js     800789 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800742:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800745:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800749:	75 21                	jne    80076c <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80074b:	a1 04 40 80 00       	mov    0x804004,%eax
  800750:	8b 40 48             	mov    0x48(%eax),%eax
  800753:	83 ec 04             	sub    $0x4,%esp
  800756:	53                   	push   %ebx
  800757:	50                   	push   %eax
  800758:	68 59 1e 80 00       	push   $0x801e59
  80075d:	e8 b8 09 00 00       	call   80111a <cprintf>
		return -E_INVAL;
  800762:	83 c4 10             	add    $0x10,%esp
  800765:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80076a:	eb 26                	jmp    800792 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80076c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80076f:	8b 52 0c             	mov    0xc(%edx),%edx
  800772:	85 d2                	test   %edx,%edx
  800774:	74 17                	je     80078d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800776:	83 ec 04             	sub    $0x4,%esp
  800779:	ff 75 10             	pushl  0x10(%ebp)
  80077c:	ff 75 0c             	pushl  0xc(%ebp)
  80077f:	50                   	push   %eax
  800780:	ff d2                	call   *%edx
  800782:	89 c2                	mov    %eax,%edx
  800784:	83 c4 10             	add    $0x10,%esp
  800787:	eb 09                	jmp    800792 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800789:	89 c2                	mov    %eax,%edx
  80078b:	eb 05                	jmp    800792 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80078d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800792:	89 d0                	mov    %edx,%eax
  800794:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800797:	c9                   	leave  
  800798:	c3                   	ret    

00800799 <seek>:

int
seek(int fdnum, off_t offset)
{
  800799:	55                   	push   %ebp
  80079a:	89 e5                	mov    %esp,%ebp
  80079c:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80079f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007a2:	50                   	push   %eax
  8007a3:	ff 75 08             	pushl  0x8(%ebp)
  8007a6:	e8 22 fc ff ff       	call   8003cd <fd_lookup>
  8007ab:	83 c4 08             	add    $0x8,%esp
  8007ae:	85 c0                	test   %eax,%eax
  8007b0:	78 0e                	js     8007c0 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007b5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007c0:	c9                   	leave  
  8007c1:	c3                   	ret    

008007c2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007c2:	55                   	push   %ebp
  8007c3:	89 e5                	mov    %esp,%ebp
  8007c5:	53                   	push   %ebx
  8007c6:	83 ec 14             	sub    $0x14,%esp
  8007c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007cf:	50                   	push   %eax
  8007d0:	53                   	push   %ebx
  8007d1:	e8 f7 fb ff ff       	call   8003cd <fd_lookup>
  8007d6:	83 c4 08             	add    $0x8,%esp
  8007d9:	89 c2                	mov    %eax,%edx
  8007db:	85 c0                	test   %eax,%eax
  8007dd:	78 65                	js     800844 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007df:	83 ec 08             	sub    $0x8,%esp
  8007e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007e5:	50                   	push   %eax
  8007e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e9:	ff 30                	pushl  (%eax)
  8007eb:	e8 33 fc ff ff       	call   800423 <dev_lookup>
  8007f0:	83 c4 10             	add    $0x10,%esp
  8007f3:	85 c0                	test   %eax,%eax
  8007f5:	78 44                	js     80083b <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007fa:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007fe:	75 21                	jne    800821 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800800:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800805:	8b 40 48             	mov    0x48(%eax),%eax
  800808:	83 ec 04             	sub    $0x4,%esp
  80080b:	53                   	push   %ebx
  80080c:	50                   	push   %eax
  80080d:	68 1c 1e 80 00       	push   $0x801e1c
  800812:	e8 03 09 00 00       	call   80111a <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800817:	83 c4 10             	add    $0x10,%esp
  80081a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80081f:	eb 23                	jmp    800844 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800821:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800824:	8b 52 18             	mov    0x18(%edx),%edx
  800827:	85 d2                	test   %edx,%edx
  800829:	74 14                	je     80083f <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80082b:	83 ec 08             	sub    $0x8,%esp
  80082e:	ff 75 0c             	pushl  0xc(%ebp)
  800831:	50                   	push   %eax
  800832:	ff d2                	call   *%edx
  800834:	89 c2                	mov    %eax,%edx
  800836:	83 c4 10             	add    $0x10,%esp
  800839:	eb 09                	jmp    800844 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80083b:	89 c2                	mov    %eax,%edx
  80083d:	eb 05                	jmp    800844 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80083f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800844:	89 d0                	mov    %edx,%eax
  800846:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800849:	c9                   	leave  
  80084a:	c3                   	ret    

0080084b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80084b:	55                   	push   %ebp
  80084c:	89 e5                	mov    %esp,%ebp
  80084e:	53                   	push   %ebx
  80084f:	83 ec 14             	sub    $0x14,%esp
  800852:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800855:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800858:	50                   	push   %eax
  800859:	ff 75 08             	pushl  0x8(%ebp)
  80085c:	e8 6c fb ff ff       	call   8003cd <fd_lookup>
  800861:	83 c4 08             	add    $0x8,%esp
  800864:	89 c2                	mov    %eax,%edx
  800866:	85 c0                	test   %eax,%eax
  800868:	78 58                	js     8008c2 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80086a:	83 ec 08             	sub    $0x8,%esp
  80086d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800870:	50                   	push   %eax
  800871:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800874:	ff 30                	pushl  (%eax)
  800876:	e8 a8 fb ff ff       	call   800423 <dev_lookup>
  80087b:	83 c4 10             	add    $0x10,%esp
  80087e:	85 c0                	test   %eax,%eax
  800880:	78 37                	js     8008b9 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800882:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800885:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800889:	74 32                	je     8008bd <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80088b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80088e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800895:	00 00 00 
	stat->st_isdir = 0;
  800898:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80089f:	00 00 00 
	stat->st_dev = dev;
  8008a2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008a8:	83 ec 08             	sub    $0x8,%esp
  8008ab:	53                   	push   %ebx
  8008ac:	ff 75 f0             	pushl  -0x10(%ebp)
  8008af:	ff 50 14             	call   *0x14(%eax)
  8008b2:	89 c2                	mov    %eax,%edx
  8008b4:	83 c4 10             	add    $0x10,%esp
  8008b7:	eb 09                	jmp    8008c2 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008b9:	89 c2                	mov    %eax,%edx
  8008bb:	eb 05                	jmp    8008c2 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008bd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008c2:	89 d0                	mov    %edx,%eax
  8008c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008c7:	c9                   	leave  
  8008c8:	c3                   	ret    

008008c9 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008c9:	55                   	push   %ebp
  8008ca:	89 e5                	mov    %esp,%ebp
  8008cc:	56                   	push   %esi
  8008cd:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008ce:	83 ec 08             	sub    $0x8,%esp
  8008d1:	6a 00                	push   $0x0
  8008d3:	ff 75 08             	pushl  0x8(%ebp)
  8008d6:	e8 e3 01 00 00       	call   800abe <open>
  8008db:	89 c3                	mov    %eax,%ebx
  8008dd:	83 c4 10             	add    $0x10,%esp
  8008e0:	85 c0                	test   %eax,%eax
  8008e2:	78 1b                	js     8008ff <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008e4:	83 ec 08             	sub    $0x8,%esp
  8008e7:	ff 75 0c             	pushl  0xc(%ebp)
  8008ea:	50                   	push   %eax
  8008eb:	e8 5b ff ff ff       	call   80084b <fstat>
  8008f0:	89 c6                	mov    %eax,%esi
	close(fd);
  8008f2:	89 1c 24             	mov    %ebx,(%esp)
  8008f5:	e8 fd fb ff ff       	call   8004f7 <close>
	return r;
  8008fa:	83 c4 10             	add    $0x10,%esp
  8008fd:	89 f0                	mov    %esi,%eax
}
  8008ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800902:	5b                   	pop    %ebx
  800903:	5e                   	pop    %esi
  800904:	5d                   	pop    %ebp
  800905:	c3                   	ret    

00800906 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800906:	55                   	push   %ebp
  800907:	89 e5                	mov    %esp,%ebp
  800909:	56                   	push   %esi
  80090a:	53                   	push   %ebx
  80090b:	89 c6                	mov    %eax,%esi
  80090d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80090f:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800916:	75 12                	jne    80092a <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800918:	83 ec 0c             	sub    $0xc,%esp
  80091b:	6a 01                	push   $0x1
  80091d:	e8 8b 11 00 00       	call   801aad <ipc_find_env>
  800922:	a3 00 40 80 00       	mov    %eax,0x804000
  800927:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80092a:	6a 07                	push   $0x7
  80092c:	68 00 50 80 00       	push   $0x805000
  800931:	56                   	push   %esi
  800932:	ff 35 00 40 80 00    	pushl  0x804000
  800938:	e8 1c 11 00 00       	call   801a59 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80093d:	83 c4 0c             	add    $0xc,%esp
  800940:	6a 00                	push   $0x0
  800942:	53                   	push   %ebx
  800943:	6a 00                	push   $0x0
  800945:	e8 ba 10 00 00       	call   801a04 <ipc_recv>
}
  80094a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80094d:	5b                   	pop    %ebx
  80094e:	5e                   	pop    %esi
  80094f:	5d                   	pop    %ebp
  800950:	c3                   	ret    

00800951 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800951:	55                   	push   %ebp
  800952:	89 e5                	mov    %esp,%ebp
  800954:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800957:	8b 45 08             	mov    0x8(%ebp),%eax
  80095a:	8b 40 0c             	mov    0xc(%eax),%eax
  80095d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800962:	8b 45 0c             	mov    0xc(%ebp),%eax
  800965:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80096a:	ba 00 00 00 00       	mov    $0x0,%edx
  80096f:	b8 02 00 00 00       	mov    $0x2,%eax
  800974:	e8 8d ff ff ff       	call   800906 <fsipc>
}
  800979:	c9                   	leave  
  80097a:	c3                   	ret    

0080097b <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800981:	8b 45 08             	mov    0x8(%ebp),%eax
  800984:	8b 40 0c             	mov    0xc(%eax),%eax
  800987:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80098c:	ba 00 00 00 00       	mov    $0x0,%edx
  800991:	b8 06 00 00 00       	mov    $0x6,%eax
  800996:	e8 6b ff ff ff       	call   800906 <fsipc>
}
  80099b:	c9                   	leave  
  80099c:	c3                   	ret    

0080099d <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80099d:	55                   	push   %ebp
  80099e:	89 e5                	mov    %esp,%ebp
  8009a0:	53                   	push   %ebx
  8009a1:	83 ec 04             	sub    $0x4,%esp
  8009a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009aa:	8b 40 0c             	mov    0xc(%eax),%eax
  8009ad:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b7:	b8 05 00 00 00       	mov    $0x5,%eax
  8009bc:	e8 45 ff ff ff       	call   800906 <fsipc>
  8009c1:	85 c0                	test   %eax,%eax
  8009c3:	78 2c                	js     8009f1 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009c5:	83 ec 08             	sub    $0x8,%esp
  8009c8:	68 00 50 80 00       	push   $0x805000
  8009cd:	53                   	push   %ebx
  8009ce:	e8 ea 0c 00 00       	call   8016bd <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009d3:	a1 80 50 80 00       	mov    0x805080,%eax
  8009d8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009de:	a1 84 50 80 00       	mov    0x805084,%eax
  8009e3:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009e9:	83 c4 10             	add    $0x10,%esp
  8009ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009f4:	c9                   	leave  
  8009f5:	c3                   	ret    

008009f6 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
  8009f9:	83 ec 0c             	sub    $0xc,%esp
  8009fc:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
    
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009ff:	8b 55 08             	mov    0x8(%ebp),%edx
  800a02:	8b 52 0c             	mov    0xc(%edx),%edx
  800a05:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = MIN(n, PGSIZE);
  800a0b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a10:	ba 00 10 00 00       	mov    $0x1000,%edx
  800a15:	0f 47 c2             	cmova  %edx,%eax
  800a18:	a3 04 50 80 00       	mov    %eax,0x805004
    memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  800a1d:	50                   	push   %eax
  800a1e:	ff 75 0c             	pushl  0xc(%ebp)
  800a21:	68 08 50 80 00       	push   $0x805008
  800a26:	e8 24 0e 00 00       	call   80184f <memmove>
    int r = fsipc(FSREQ_WRITE, NULL);
  800a2b:	ba 00 00 00 00       	mov    $0x0,%edx
  800a30:	b8 04 00 00 00       	mov    $0x4,%eax
  800a35:	e8 cc fe ff ff       	call   800906 <fsipc>
    return r;
}
  800a3a:	c9                   	leave  
  800a3b:	c3                   	ret    

00800a3c <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a3c:	55                   	push   %ebp
  800a3d:	89 e5                	mov    %esp,%ebp
  800a3f:	56                   	push   %esi
  800a40:	53                   	push   %ebx
  800a41:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a44:	8b 45 08             	mov    0x8(%ebp),%eax
  800a47:	8b 40 0c             	mov    0xc(%eax),%eax
  800a4a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a4f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a55:	ba 00 00 00 00       	mov    $0x0,%edx
  800a5a:	b8 03 00 00 00       	mov    $0x3,%eax
  800a5f:	e8 a2 fe ff ff       	call   800906 <fsipc>
  800a64:	89 c3                	mov    %eax,%ebx
  800a66:	85 c0                	test   %eax,%eax
  800a68:	78 4b                	js     800ab5 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a6a:	39 c6                	cmp    %eax,%esi
  800a6c:	73 16                	jae    800a84 <devfile_read+0x48>
  800a6e:	68 88 1e 80 00       	push   $0x801e88
  800a73:	68 8f 1e 80 00       	push   $0x801e8f
  800a78:	6a 7c                	push   $0x7c
  800a7a:	68 a4 1e 80 00       	push   $0x801ea4
  800a7f:	e8 bd 05 00 00       	call   801041 <_panic>
	assert(r <= PGSIZE);
  800a84:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a89:	7e 16                	jle    800aa1 <devfile_read+0x65>
  800a8b:	68 af 1e 80 00       	push   $0x801eaf
  800a90:	68 8f 1e 80 00       	push   $0x801e8f
  800a95:	6a 7d                	push   $0x7d
  800a97:	68 a4 1e 80 00       	push   $0x801ea4
  800a9c:	e8 a0 05 00 00       	call   801041 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800aa1:	83 ec 04             	sub    $0x4,%esp
  800aa4:	50                   	push   %eax
  800aa5:	68 00 50 80 00       	push   $0x805000
  800aaa:	ff 75 0c             	pushl  0xc(%ebp)
  800aad:	e8 9d 0d 00 00       	call   80184f <memmove>
	return r;
  800ab2:	83 c4 10             	add    $0x10,%esp
}
  800ab5:	89 d8                	mov    %ebx,%eax
  800ab7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800aba:	5b                   	pop    %ebx
  800abb:	5e                   	pop    %esi
  800abc:	5d                   	pop    %ebp
  800abd:	c3                   	ret    

00800abe <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800abe:	55                   	push   %ebp
  800abf:	89 e5                	mov    %esp,%ebp
  800ac1:	53                   	push   %ebx
  800ac2:	83 ec 20             	sub    $0x20,%esp
  800ac5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800ac8:	53                   	push   %ebx
  800ac9:	e8 b6 0b 00 00       	call   801684 <strlen>
  800ace:	83 c4 10             	add    $0x10,%esp
  800ad1:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ad6:	7f 67                	jg     800b3f <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ad8:	83 ec 0c             	sub    $0xc,%esp
  800adb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ade:	50                   	push   %eax
  800adf:	e8 9a f8 ff ff       	call   80037e <fd_alloc>
  800ae4:	83 c4 10             	add    $0x10,%esp
		return r;
  800ae7:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ae9:	85 c0                	test   %eax,%eax
  800aeb:	78 57                	js     800b44 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800aed:	83 ec 08             	sub    $0x8,%esp
  800af0:	53                   	push   %ebx
  800af1:	68 00 50 80 00       	push   $0x805000
  800af6:	e8 c2 0b 00 00       	call   8016bd <strcpy>
	fsipcbuf.open.req_omode = mode;
  800afb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800afe:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b03:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b06:	b8 01 00 00 00       	mov    $0x1,%eax
  800b0b:	e8 f6 fd ff ff       	call   800906 <fsipc>
  800b10:	89 c3                	mov    %eax,%ebx
  800b12:	83 c4 10             	add    $0x10,%esp
  800b15:	85 c0                	test   %eax,%eax
  800b17:	79 14                	jns    800b2d <open+0x6f>
		fd_close(fd, 0);
  800b19:	83 ec 08             	sub    $0x8,%esp
  800b1c:	6a 00                	push   $0x0
  800b1e:	ff 75 f4             	pushl  -0xc(%ebp)
  800b21:	e8 50 f9 ff ff       	call   800476 <fd_close>
		return r;
  800b26:	83 c4 10             	add    $0x10,%esp
  800b29:	89 da                	mov    %ebx,%edx
  800b2b:	eb 17                	jmp    800b44 <open+0x86>
	}

	return fd2num(fd);
  800b2d:	83 ec 0c             	sub    $0xc,%esp
  800b30:	ff 75 f4             	pushl  -0xc(%ebp)
  800b33:	e8 1f f8 ff ff       	call   800357 <fd2num>
  800b38:	89 c2                	mov    %eax,%edx
  800b3a:	83 c4 10             	add    $0x10,%esp
  800b3d:	eb 05                	jmp    800b44 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b3f:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b44:	89 d0                	mov    %edx,%eax
  800b46:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b49:	c9                   	leave  
  800b4a:	c3                   	ret    

00800b4b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b4b:	55                   	push   %ebp
  800b4c:	89 e5                	mov    %esp,%ebp
  800b4e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b51:	ba 00 00 00 00       	mov    $0x0,%edx
  800b56:	b8 08 00 00 00       	mov    $0x8,%eax
  800b5b:	e8 a6 fd ff ff       	call   800906 <fsipc>
}
  800b60:	c9                   	leave  
  800b61:	c3                   	ret    

00800b62 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b62:	55                   	push   %ebp
  800b63:	89 e5                	mov    %esp,%ebp
  800b65:	56                   	push   %esi
  800b66:	53                   	push   %ebx
  800b67:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b6a:	83 ec 0c             	sub    $0xc,%esp
  800b6d:	ff 75 08             	pushl  0x8(%ebp)
  800b70:	e8 f2 f7 ff ff       	call   800367 <fd2data>
  800b75:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b77:	83 c4 08             	add    $0x8,%esp
  800b7a:	68 bb 1e 80 00       	push   $0x801ebb
  800b7f:	53                   	push   %ebx
  800b80:	e8 38 0b 00 00       	call   8016bd <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b85:	8b 46 04             	mov    0x4(%esi),%eax
  800b88:	2b 06                	sub    (%esi),%eax
  800b8a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b90:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b97:	00 00 00 
	stat->st_dev = &devpipe;
  800b9a:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800ba1:	30 80 00 
	return 0;
}
  800ba4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bac:	5b                   	pop    %ebx
  800bad:	5e                   	pop    %esi
  800bae:	5d                   	pop    %ebp
  800baf:	c3                   	ret    

00800bb0 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bb0:	55                   	push   %ebp
  800bb1:	89 e5                	mov    %esp,%ebp
  800bb3:	53                   	push   %ebx
  800bb4:	83 ec 0c             	sub    $0xc,%esp
  800bb7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bba:	53                   	push   %ebx
  800bbb:	6a 00                	push   $0x0
  800bbd:	e8 29 f6 ff ff       	call   8001eb <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bc2:	89 1c 24             	mov    %ebx,(%esp)
  800bc5:	e8 9d f7 ff ff       	call   800367 <fd2data>
  800bca:	83 c4 08             	add    $0x8,%esp
  800bcd:	50                   	push   %eax
  800bce:	6a 00                	push   $0x0
  800bd0:	e8 16 f6 ff ff       	call   8001eb <sys_page_unmap>
}
  800bd5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bd8:	c9                   	leave  
  800bd9:	c3                   	ret    

00800bda <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bda:	55                   	push   %ebp
  800bdb:	89 e5                	mov    %esp,%ebp
  800bdd:	57                   	push   %edi
  800bde:	56                   	push   %esi
  800bdf:	53                   	push   %ebx
  800be0:	83 ec 1c             	sub    $0x1c,%esp
  800be3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800be6:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800be8:	a1 04 40 80 00       	mov    0x804004,%eax
  800bed:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800bf0:	83 ec 0c             	sub    $0xc,%esp
  800bf3:	ff 75 e0             	pushl  -0x20(%ebp)
  800bf6:	e8 eb 0e 00 00       	call   801ae6 <pageref>
  800bfb:	89 c3                	mov    %eax,%ebx
  800bfd:	89 3c 24             	mov    %edi,(%esp)
  800c00:	e8 e1 0e 00 00       	call   801ae6 <pageref>
  800c05:	83 c4 10             	add    $0x10,%esp
  800c08:	39 c3                	cmp    %eax,%ebx
  800c0a:	0f 94 c1             	sete   %cl
  800c0d:	0f b6 c9             	movzbl %cl,%ecx
  800c10:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c13:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c19:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c1c:	39 ce                	cmp    %ecx,%esi
  800c1e:	74 1b                	je     800c3b <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c20:	39 c3                	cmp    %eax,%ebx
  800c22:	75 c4                	jne    800be8 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c24:	8b 42 58             	mov    0x58(%edx),%eax
  800c27:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c2a:	50                   	push   %eax
  800c2b:	56                   	push   %esi
  800c2c:	68 c2 1e 80 00       	push   $0x801ec2
  800c31:	e8 e4 04 00 00       	call   80111a <cprintf>
  800c36:	83 c4 10             	add    $0x10,%esp
  800c39:	eb ad                	jmp    800be8 <_pipeisclosed+0xe>
	}
}
  800c3b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c41:	5b                   	pop    %ebx
  800c42:	5e                   	pop    %esi
  800c43:	5f                   	pop    %edi
  800c44:	5d                   	pop    %ebp
  800c45:	c3                   	ret    

00800c46 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c46:	55                   	push   %ebp
  800c47:	89 e5                	mov    %esp,%ebp
  800c49:	57                   	push   %edi
  800c4a:	56                   	push   %esi
  800c4b:	53                   	push   %ebx
  800c4c:	83 ec 28             	sub    $0x28,%esp
  800c4f:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c52:	56                   	push   %esi
  800c53:	e8 0f f7 ff ff       	call   800367 <fd2data>
  800c58:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c5a:	83 c4 10             	add    $0x10,%esp
  800c5d:	bf 00 00 00 00       	mov    $0x0,%edi
  800c62:	eb 4b                	jmp    800caf <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c64:	89 da                	mov    %ebx,%edx
  800c66:	89 f0                	mov    %esi,%eax
  800c68:	e8 6d ff ff ff       	call   800bda <_pipeisclosed>
  800c6d:	85 c0                	test   %eax,%eax
  800c6f:	75 48                	jne    800cb9 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c71:	e8 d1 f4 ff ff       	call   800147 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c76:	8b 43 04             	mov    0x4(%ebx),%eax
  800c79:	8b 0b                	mov    (%ebx),%ecx
  800c7b:	8d 51 20             	lea    0x20(%ecx),%edx
  800c7e:	39 d0                	cmp    %edx,%eax
  800c80:	73 e2                	jae    800c64 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c85:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c89:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c8c:	89 c2                	mov    %eax,%edx
  800c8e:	c1 fa 1f             	sar    $0x1f,%edx
  800c91:	89 d1                	mov    %edx,%ecx
  800c93:	c1 e9 1b             	shr    $0x1b,%ecx
  800c96:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c99:	83 e2 1f             	and    $0x1f,%edx
  800c9c:	29 ca                	sub    %ecx,%edx
  800c9e:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800ca2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800ca6:	83 c0 01             	add    $0x1,%eax
  800ca9:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cac:	83 c7 01             	add    $0x1,%edi
  800caf:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cb2:	75 c2                	jne    800c76 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cb4:	8b 45 10             	mov    0x10(%ebp),%eax
  800cb7:	eb 05                	jmp    800cbe <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cb9:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc1:	5b                   	pop    %ebx
  800cc2:	5e                   	pop    %esi
  800cc3:	5f                   	pop    %edi
  800cc4:	5d                   	pop    %ebp
  800cc5:	c3                   	ret    

00800cc6 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cc6:	55                   	push   %ebp
  800cc7:	89 e5                	mov    %esp,%ebp
  800cc9:	57                   	push   %edi
  800cca:	56                   	push   %esi
  800ccb:	53                   	push   %ebx
  800ccc:	83 ec 18             	sub    $0x18,%esp
  800ccf:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800cd2:	57                   	push   %edi
  800cd3:	e8 8f f6 ff ff       	call   800367 <fd2data>
  800cd8:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cda:	83 c4 10             	add    $0x10,%esp
  800cdd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce2:	eb 3d                	jmp    800d21 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800ce4:	85 db                	test   %ebx,%ebx
  800ce6:	74 04                	je     800cec <devpipe_read+0x26>
				return i;
  800ce8:	89 d8                	mov    %ebx,%eax
  800cea:	eb 44                	jmp    800d30 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800cec:	89 f2                	mov    %esi,%edx
  800cee:	89 f8                	mov    %edi,%eax
  800cf0:	e8 e5 fe ff ff       	call   800bda <_pipeisclosed>
  800cf5:	85 c0                	test   %eax,%eax
  800cf7:	75 32                	jne    800d2b <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800cf9:	e8 49 f4 ff ff       	call   800147 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800cfe:	8b 06                	mov    (%esi),%eax
  800d00:	3b 46 04             	cmp    0x4(%esi),%eax
  800d03:	74 df                	je     800ce4 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d05:	99                   	cltd   
  800d06:	c1 ea 1b             	shr    $0x1b,%edx
  800d09:	01 d0                	add    %edx,%eax
  800d0b:	83 e0 1f             	and    $0x1f,%eax
  800d0e:	29 d0                	sub    %edx,%eax
  800d10:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d18:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d1b:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d1e:	83 c3 01             	add    $0x1,%ebx
  800d21:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d24:	75 d8                	jne    800cfe <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d26:	8b 45 10             	mov    0x10(%ebp),%eax
  800d29:	eb 05                	jmp    800d30 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d2b:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d30:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d33:	5b                   	pop    %ebx
  800d34:	5e                   	pop    %esi
  800d35:	5f                   	pop    %edi
  800d36:	5d                   	pop    %ebp
  800d37:	c3                   	ret    

00800d38 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d38:	55                   	push   %ebp
  800d39:	89 e5                	mov    %esp,%ebp
  800d3b:	56                   	push   %esi
  800d3c:	53                   	push   %ebx
  800d3d:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d40:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d43:	50                   	push   %eax
  800d44:	e8 35 f6 ff ff       	call   80037e <fd_alloc>
  800d49:	83 c4 10             	add    $0x10,%esp
  800d4c:	89 c2                	mov    %eax,%edx
  800d4e:	85 c0                	test   %eax,%eax
  800d50:	0f 88 2c 01 00 00    	js     800e82 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d56:	83 ec 04             	sub    $0x4,%esp
  800d59:	68 07 04 00 00       	push   $0x407
  800d5e:	ff 75 f4             	pushl  -0xc(%ebp)
  800d61:	6a 00                	push   $0x0
  800d63:	e8 fe f3 ff ff       	call   800166 <sys_page_alloc>
  800d68:	83 c4 10             	add    $0x10,%esp
  800d6b:	89 c2                	mov    %eax,%edx
  800d6d:	85 c0                	test   %eax,%eax
  800d6f:	0f 88 0d 01 00 00    	js     800e82 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d75:	83 ec 0c             	sub    $0xc,%esp
  800d78:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d7b:	50                   	push   %eax
  800d7c:	e8 fd f5 ff ff       	call   80037e <fd_alloc>
  800d81:	89 c3                	mov    %eax,%ebx
  800d83:	83 c4 10             	add    $0x10,%esp
  800d86:	85 c0                	test   %eax,%eax
  800d88:	0f 88 e2 00 00 00    	js     800e70 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d8e:	83 ec 04             	sub    $0x4,%esp
  800d91:	68 07 04 00 00       	push   $0x407
  800d96:	ff 75 f0             	pushl  -0x10(%ebp)
  800d99:	6a 00                	push   $0x0
  800d9b:	e8 c6 f3 ff ff       	call   800166 <sys_page_alloc>
  800da0:	89 c3                	mov    %eax,%ebx
  800da2:	83 c4 10             	add    $0x10,%esp
  800da5:	85 c0                	test   %eax,%eax
  800da7:	0f 88 c3 00 00 00    	js     800e70 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800dad:	83 ec 0c             	sub    $0xc,%esp
  800db0:	ff 75 f4             	pushl  -0xc(%ebp)
  800db3:	e8 af f5 ff ff       	call   800367 <fd2data>
  800db8:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dba:	83 c4 0c             	add    $0xc,%esp
  800dbd:	68 07 04 00 00       	push   $0x407
  800dc2:	50                   	push   %eax
  800dc3:	6a 00                	push   $0x0
  800dc5:	e8 9c f3 ff ff       	call   800166 <sys_page_alloc>
  800dca:	89 c3                	mov    %eax,%ebx
  800dcc:	83 c4 10             	add    $0x10,%esp
  800dcf:	85 c0                	test   %eax,%eax
  800dd1:	0f 88 89 00 00 00    	js     800e60 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dd7:	83 ec 0c             	sub    $0xc,%esp
  800dda:	ff 75 f0             	pushl  -0x10(%ebp)
  800ddd:	e8 85 f5 ff ff       	call   800367 <fd2data>
  800de2:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800de9:	50                   	push   %eax
  800dea:	6a 00                	push   $0x0
  800dec:	56                   	push   %esi
  800ded:	6a 00                	push   $0x0
  800def:	e8 b5 f3 ff ff       	call   8001a9 <sys_page_map>
  800df4:	89 c3                	mov    %eax,%ebx
  800df6:	83 c4 20             	add    $0x20,%esp
  800df9:	85 c0                	test   %eax,%eax
  800dfb:	78 55                	js     800e52 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800dfd:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e03:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e06:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e0b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e12:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e18:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e1b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e20:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e27:	83 ec 0c             	sub    $0xc,%esp
  800e2a:	ff 75 f4             	pushl  -0xc(%ebp)
  800e2d:	e8 25 f5 ff ff       	call   800357 <fd2num>
  800e32:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e35:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e37:	83 c4 04             	add    $0x4,%esp
  800e3a:	ff 75 f0             	pushl  -0x10(%ebp)
  800e3d:	e8 15 f5 ff ff       	call   800357 <fd2num>
  800e42:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e45:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e48:	83 c4 10             	add    $0x10,%esp
  800e4b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e50:	eb 30                	jmp    800e82 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e52:	83 ec 08             	sub    $0x8,%esp
  800e55:	56                   	push   %esi
  800e56:	6a 00                	push   $0x0
  800e58:	e8 8e f3 ff ff       	call   8001eb <sys_page_unmap>
  800e5d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e60:	83 ec 08             	sub    $0x8,%esp
  800e63:	ff 75 f0             	pushl  -0x10(%ebp)
  800e66:	6a 00                	push   $0x0
  800e68:	e8 7e f3 ff ff       	call   8001eb <sys_page_unmap>
  800e6d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e70:	83 ec 08             	sub    $0x8,%esp
  800e73:	ff 75 f4             	pushl  -0xc(%ebp)
  800e76:	6a 00                	push   $0x0
  800e78:	e8 6e f3 ff ff       	call   8001eb <sys_page_unmap>
  800e7d:	83 c4 10             	add    $0x10,%esp
  800e80:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e82:	89 d0                	mov    %edx,%eax
  800e84:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e87:	5b                   	pop    %ebx
  800e88:	5e                   	pop    %esi
  800e89:	5d                   	pop    %ebp
  800e8a:	c3                   	ret    

00800e8b <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e8b:	55                   	push   %ebp
  800e8c:	89 e5                	mov    %esp,%ebp
  800e8e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e91:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e94:	50                   	push   %eax
  800e95:	ff 75 08             	pushl  0x8(%ebp)
  800e98:	e8 30 f5 ff ff       	call   8003cd <fd_lookup>
  800e9d:	83 c4 10             	add    $0x10,%esp
  800ea0:	85 c0                	test   %eax,%eax
  800ea2:	78 18                	js     800ebc <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800ea4:	83 ec 0c             	sub    $0xc,%esp
  800ea7:	ff 75 f4             	pushl  -0xc(%ebp)
  800eaa:	e8 b8 f4 ff ff       	call   800367 <fd2data>
	return _pipeisclosed(fd, p);
  800eaf:	89 c2                	mov    %eax,%edx
  800eb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eb4:	e8 21 fd ff ff       	call   800bda <_pipeisclosed>
  800eb9:	83 c4 10             	add    $0x10,%esp
}
  800ebc:	c9                   	leave  
  800ebd:	c3                   	ret    

00800ebe <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ebe:	55                   	push   %ebp
  800ebf:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800ec1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec6:	5d                   	pop    %ebp
  800ec7:	c3                   	ret    

00800ec8 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ec8:	55                   	push   %ebp
  800ec9:	89 e5                	mov    %esp,%ebp
  800ecb:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ece:	68 da 1e 80 00       	push   $0x801eda
  800ed3:	ff 75 0c             	pushl  0xc(%ebp)
  800ed6:	e8 e2 07 00 00       	call   8016bd <strcpy>
	return 0;
}
  800edb:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee0:	c9                   	leave  
  800ee1:	c3                   	ret    

00800ee2 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800ee2:	55                   	push   %ebp
  800ee3:	89 e5                	mov    %esp,%ebp
  800ee5:	57                   	push   %edi
  800ee6:	56                   	push   %esi
  800ee7:	53                   	push   %ebx
  800ee8:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800eee:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800ef3:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ef9:	eb 2d                	jmp    800f28 <devcons_write+0x46>
		m = n - tot;
  800efb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800efe:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800f00:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f03:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f08:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f0b:	83 ec 04             	sub    $0x4,%esp
  800f0e:	53                   	push   %ebx
  800f0f:	03 45 0c             	add    0xc(%ebp),%eax
  800f12:	50                   	push   %eax
  800f13:	57                   	push   %edi
  800f14:	e8 36 09 00 00       	call   80184f <memmove>
		sys_cputs(buf, m);
  800f19:	83 c4 08             	add    $0x8,%esp
  800f1c:	53                   	push   %ebx
  800f1d:	57                   	push   %edi
  800f1e:	e8 87 f1 ff ff       	call   8000aa <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f23:	01 de                	add    %ebx,%esi
  800f25:	83 c4 10             	add    $0x10,%esp
  800f28:	89 f0                	mov    %esi,%eax
  800f2a:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f2d:	72 cc                	jb     800efb <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f2f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f32:	5b                   	pop    %ebx
  800f33:	5e                   	pop    %esi
  800f34:	5f                   	pop    %edi
  800f35:	5d                   	pop    %ebp
  800f36:	c3                   	ret    

00800f37 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f37:	55                   	push   %ebp
  800f38:	89 e5                	mov    %esp,%ebp
  800f3a:	83 ec 08             	sub    $0x8,%esp
  800f3d:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f42:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f46:	74 2a                	je     800f72 <devcons_read+0x3b>
  800f48:	eb 05                	jmp    800f4f <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f4a:	e8 f8 f1 ff ff       	call   800147 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f4f:	e8 74 f1 ff ff       	call   8000c8 <sys_cgetc>
  800f54:	85 c0                	test   %eax,%eax
  800f56:	74 f2                	je     800f4a <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f58:	85 c0                	test   %eax,%eax
  800f5a:	78 16                	js     800f72 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f5c:	83 f8 04             	cmp    $0x4,%eax
  800f5f:	74 0c                	je     800f6d <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f61:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f64:	88 02                	mov    %al,(%edx)
	return 1;
  800f66:	b8 01 00 00 00       	mov    $0x1,%eax
  800f6b:	eb 05                	jmp    800f72 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f6d:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f72:	c9                   	leave  
  800f73:	c3                   	ret    

00800f74 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f74:	55                   	push   %ebp
  800f75:	89 e5                	mov    %esp,%ebp
  800f77:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f7d:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f80:	6a 01                	push   $0x1
  800f82:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f85:	50                   	push   %eax
  800f86:	e8 1f f1 ff ff       	call   8000aa <sys_cputs>
}
  800f8b:	83 c4 10             	add    $0x10,%esp
  800f8e:	c9                   	leave  
  800f8f:	c3                   	ret    

00800f90 <getchar>:

int
getchar(void)
{
  800f90:	55                   	push   %ebp
  800f91:	89 e5                	mov    %esp,%ebp
  800f93:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f96:	6a 01                	push   $0x1
  800f98:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f9b:	50                   	push   %eax
  800f9c:	6a 00                	push   $0x0
  800f9e:	e8 90 f6 ff ff       	call   800633 <read>
	if (r < 0)
  800fa3:	83 c4 10             	add    $0x10,%esp
  800fa6:	85 c0                	test   %eax,%eax
  800fa8:	78 0f                	js     800fb9 <getchar+0x29>
		return r;
	if (r < 1)
  800faa:	85 c0                	test   %eax,%eax
  800fac:	7e 06                	jle    800fb4 <getchar+0x24>
		return -E_EOF;
	return c;
  800fae:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fb2:	eb 05                	jmp    800fb9 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fb4:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fb9:	c9                   	leave  
  800fba:	c3                   	ret    

00800fbb <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800fbb:	55                   	push   %ebp
  800fbc:	89 e5                	mov    %esp,%ebp
  800fbe:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fc1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fc4:	50                   	push   %eax
  800fc5:	ff 75 08             	pushl  0x8(%ebp)
  800fc8:	e8 00 f4 ff ff       	call   8003cd <fd_lookup>
  800fcd:	83 c4 10             	add    $0x10,%esp
  800fd0:	85 c0                	test   %eax,%eax
  800fd2:	78 11                	js     800fe5 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800fd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fd7:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fdd:	39 10                	cmp    %edx,(%eax)
  800fdf:	0f 94 c0             	sete   %al
  800fe2:	0f b6 c0             	movzbl %al,%eax
}
  800fe5:	c9                   	leave  
  800fe6:	c3                   	ret    

00800fe7 <opencons>:

int
opencons(void)
{
  800fe7:	55                   	push   %ebp
  800fe8:	89 e5                	mov    %esp,%ebp
  800fea:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ff0:	50                   	push   %eax
  800ff1:	e8 88 f3 ff ff       	call   80037e <fd_alloc>
  800ff6:	83 c4 10             	add    $0x10,%esp
		return r;
  800ff9:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800ffb:	85 c0                	test   %eax,%eax
  800ffd:	78 3e                	js     80103d <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fff:	83 ec 04             	sub    $0x4,%esp
  801002:	68 07 04 00 00       	push   $0x407
  801007:	ff 75 f4             	pushl  -0xc(%ebp)
  80100a:	6a 00                	push   $0x0
  80100c:	e8 55 f1 ff ff       	call   800166 <sys_page_alloc>
  801011:	83 c4 10             	add    $0x10,%esp
		return r;
  801014:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801016:	85 c0                	test   %eax,%eax
  801018:	78 23                	js     80103d <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80101a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801020:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801023:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801025:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801028:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80102f:	83 ec 0c             	sub    $0xc,%esp
  801032:	50                   	push   %eax
  801033:	e8 1f f3 ff ff       	call   800357 <fd2num>
  801038:	89 c2                	mov    %eax,%edx
  80103a:	83 c4 10             	add    $0x10,%esp
}
  80103d:	89 d0                	mov    %edx,%eax
  80103f:	c9                   	leave  
  801040:	c3                   	ret    

00801041 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801041:	55                   	push   %ebp
  801042:	89 e5                	mov    %esp,%ebp
  801044:	56                   	push   %esi
  801045:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801046:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801049:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80104f:	e8 d4 f0 ff ff       	call   800128 <sys_getenvid>
  801054:	83 ec 0c             	sub    $0xc,%esp
  801057:	ff 75 0c             	pushl  0xc(%ebp)
  80105a:	ff 75 08             	pushl  0x8(%ebp)
  80105d:	56                   	push   %esi
  80105e:	50                   	push   %eax
  80105f:	68 e8 1e 80 00       	push   $0x801ee8
  801064:	e8 b1 00 00 00       	call   80111a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801069:	83 c4 18             	add    $0x18,%esp
  80106c:	53                   	push   %ebx
  80106d:	ff 75 10             	pushl  0x10(%ebp)
  801070:	e8 54 00 00 00       	call   8010c9 <vcprintf>
	cprintf("\n");
  801075:	c7 04 24 d3 1e 80 00 	movl   $0x801ed3,(%esp)
  80107c:	e8 99 00 00 00       	call   80111a <cprintf>
  801081:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801084:	cc                   	int3   
  801085:	eb fd                	jmp    801084 <_panic+0x43>

00801087 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801087:	55                   	push   %ebp
  801088:	89 e5                	mov    %esp,%ebp
  80108a:	53                   	push   %ebx
  80108b:	83 ec 04             	sub    $0x4,%esp
  80108e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801091:	8b 13                	mov    (%ebx),%edx
  801093:	8d 42 01             	lea    0x1(%edx),%eax
  801096:	89 03                	mov    %eax,(%ebx)
  801098:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80109b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80109f:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010a4:	75 1a                	jne    8010c0 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010a6:	83 ec 08             	sub    $0x8,%esp
  8010a9:	68 ff 00 00 00       	push   $0xff
  8010ae:	8d 43 08             	lea    0x8(%ebx),%eax
  8010b1:	50                   	push   %eax
  8010b2:	e8 f3 ef ff ff       	call   8000aa <sys_cputs>
		b->idx = 0;
  8010b7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010bd:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010c0:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010c7:	c9                   	leave  
  8010c8:	c3                   	ret    

008010c9 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010c9:	55                   	push   %ebp
  8010ca:	89 e5                	mov    %esp,%ebp
  8010cc:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010d2:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010d9:	00 00 00 
	b.cnt = 0;
  8010dc:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010e3:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010e6:	ff 75 0c             	pushl  0xc(%ebp)
  8010e9:	ff 75 08             	pushl  0x8(%ebp)
  8010ec:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010f2:	50                   	push   %eax
  8010f3:	68 87 10 80 00       	push   $0x801087
  8010f8:	e8 54 01 00 00       	call   801251 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010fd:	83 c4 08             	add    $0x8,%esp
  801100:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801106:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80110c:	50                   	push   %eax
  80110d:	e8 98 ef ff ff       	call   8000aa <sys_cputs>

	return b.cnt;
}
  801112:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801118:	c9                   	leave  
  801119:	c3                   	ret    

0080111a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80111a:	55                   	push   %ebp
  80111b:	89 e5                	mov    %esp,%ebp
  80111d:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801120:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801123:	50                   	push   %eax
  801124:	ff 75 08             	pushl  0x8(%ebp)
  801127:	e8 9d ff ff ff       	call   8010c9 <vcprintf>
	va_end(ap);

	return cnt;
}
  80112c:	c9                   	leave  
  80112d:	c3                   	ret    

0080112e <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80112e:	55                   	push   %ebp
  80112f:	89 e5                	mov    %esp,%ebp
  801131:	57                   	push   %edi
  801132:	56                   	push   %esi
  801133:	53                   	push   %ebx
  801134:	83 ec 1c             	sub    $0x1c,%esp
  801137:	89 c7                	mov    %eax,%edi
  801139:	89 d6                	mov    %edx,%esi
  80113b:	8b 45 08             	mov    0x8(%ebp),%eax
  80113e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801141:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801144:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801147:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80114a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80114f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801152:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801155:	39 d3                	cmp    %edx,%ebx
  801157:	72 05                	jb     80115e <printnum+0x30>
  801159:	39 45 10             	cmp    %eax,0x10(%ebp)
  80115c:	77 45                	ja     8011a3 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80115e:	83 ec 0c             	sub    $0xc,%esp
  801161:	ff 75 18             	pushl  0x18(%ebp)
  801164:	8b 45 14             	mov    0x14(%ebp),%eax
  801167:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80116a:	53                   	push   %ebx
  80116b:	ff 75 10             	pushl  0x10(%ebp)
  80116e:	83 ec 08             	sub    $0x8,%esp
  801171:	ff 75 e4             	pushl  -0x1c(%ebp)
  801174:	ff 75 e0             	pushl  -0x20(%ebp)
  801177:	ff 75 dc             	pushl  -0x24(%ebp)
  80117a:	ff 75 d8             	pushl  -0x28(%ebp)
  80117d:	e8 ae 09 00 00       	call   801b30 <__udivdi3>
  801182:	83 c4 18             	add    $0x18,%esp
  801185:	52                   	push   %edx
  801186:	50                   	push   %eax
  801187:	89 f2                	mov    %esi,%edx
  801189:	89 f8                	mov    %edi,%eax
  80118b:	e8 9e ff ff ff       	call   80112e <printnum>
  801190:	83 c4 20             	add    $0x20,%esp
  801193:	eb 18                	jmp    8011ad <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801195:	83 ec 08             	sub    $0x8,%esp
  801198:	56                   	push   %esi
  801199:	ff 75 18             	pushl  0x18(%ebp)
  80119c:	ff d7                	call   *%edi
  80119e:	83 c4 10             	add    $0x10,%esp
  8011a1:	eb 03                	jmp    8011a6 <printnum+0x78>
  8011a3:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011a6:	83 eb 01             	sub    $0x1,%ebx
  8011a9:	85 db                	test   %ebx,%ebx
  8011ab:	7f e8                	jg     801195 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011ad:	83 ec 08             	sub    $0x8,%esp
  8011b0:	56                   	push   %esi
  8011b1:	83 ec 04             	sub    $0x4,%esp
  8011b4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011b7:	ff 75 e0             	pushl  -0x20(%ebp)
  8011ba:	ff 75 dc             	pushl  -0x24(%ebp)
  8011bd:	ff 75 d8             	pushl  -0x28(%ebp)
  8011c0:	e8 9b 0a 00 00       	call   801c60 <__umoddi3>
  8011c5:	83 c4 14             	add    $0x14,%esp
  8011c8:	0f be 80 0b 1f 80 00 	movsbl 0x801f0b(%eax),%eax
  8011cf:	50                   	push   %eax
  8011d0:	ff d7                	call   *%edi
}
  8011d2:	83 c4 10             	add    $0x10,%esp
  8011d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011d8:	5b                   	pop    %ebx
  8011d9:	5e                   	pop    %esi
  8011da:	5f                   	pop    %edi
  8011db:	5d                   	pop    %ebp
  8011dc:	c3                   	ret    

008011dd <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8011dd:	55                   	push   %ebp
  8011de:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011e0:	83 fa 01             	cmp    $0x1,%edx
  8011e3:	7e 0e                	jle    8011f3 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8011e5:	8b 10                	mov    (%eax),%edx
  8011e7:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011ea:	89 08                	mov    %ecx,(%eax)
  8011ec:	8b 02                	mov    (%edx),%eax
  8011ee:	8b 52 04             	mov    0x4(%edx),%edx
  8011f1:	eb 22                	jmp    801215 <getuint+0x38>
	else if (lflag)
  8011f3:	85 d2                	test   %edx,%edx
  8011f5:	74 10                	je     801207 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8011f7:	8b 10                	mov    (%eax),%edx
  8011f9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011fc:	89 08                	mov    %ecx,(%eax)
  8011fe:	8b 02                	mov    (%edx),%eax
  801200:	ba 00 00 00 00       	mov    $0x0,%edx
  801205:	eb 0e                	jmp    801215 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801207:	8b 10                	mov    (%eax),%edx
  801209:	8d 4a 04             	lea    0x4(%edx),%ecx
  80120c:	89 08                	mov    %ecx,(%eax)
  80120e:	8b 02                	mov    (%edx),%eax
  801210:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801215:	5d                   	pop    %ebp
  801216:	c3                   	ret    

00801217 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801217:	55                   	push   %ebp
  801218:	89 e5                	mov    %esp,%ebp
  80121a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80121d:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801221:	8b 10                	mov    (%eax),%edx
  801223:	3b 50 04             	cmp    0x4(%eax),%edx
  801226:	73 0a                	jae    801232 <sprintputch+0x1b>
		*b->buf++ = ch;
  801228:	8d 4a 01             	lea    0x1(%edx),%ecx
  80122b:	89 08                	mov    %ecx,(%eax)
  80122d:	8b 45 08             	mov    0x8(%ebp),%eax
  801230:	88 02                	mov    %al,(%edx)
}
  801232:	5d                   	pop    %ebp
  801233:	c3                   	ret    

00801234 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801234:	55                   	push   %ebp
  801235:	89 e5                	mov    %esp,%ebp
  801237:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80123a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80123d:	50                   	push   %eax
  80123e:	ff 75 10             	pushl  0x10(%ebp)
  801241:	ff 75 0c             	pushl  0xc(%ebp)
  801244:	ff 75 08             	pushl  0x8(%ebp)
  801247:	e8 05 00 00 00       	call   801251 <vprintfmt>
	va_end(ap);
}
  80124c:	83 c4 10             	add    $0x10,%esp
  80124f:	c9                   	leave  
  801250:	c3                   	ret    

00801251 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801251:	55                   	push   %ebp
  801252:	89 e5                	mov    %esp,%ebp
  801254:	57                   	push   %edi
  801255:	56                   	push   %esi
  801256:	53                   	push   %ebx
  801257:	83 ec 2c             	sub    $0x2c,%esp
  80125a:	8b 75 08             	mov    0x8(%ebp),%esi
  80125d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801260:	8b 7d 10             	mov    0x10(%ebp),%edi
  801263:	eb 12                	jmp    801277 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801265:	85 c0                	test   %eax,%eax
  801267:	0f 84 a7 03 00 00    	je     801614 <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
  80126d:	83 ec 08             	sub    $0x8,%esp
  801270:	53                   	push   %ebx
  801271:	50                   	push   %eax
  801272:	ff d6                	call   *%esi
  801274:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801277:	83 c7 01             	add    $0x1,%edi
  80127a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80127e:	83 f8 25             	cmp    $0x25,%eax
  801281:	75 e2                	jne    801265 <vprintfmt+0x14>
  801283:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801287:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80128e:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  801295:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80129c:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8012a3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012a8:	eb 07                	jmp    8012b1 <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8012ad:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012b1:	8d 47 01             	lea    0x1(%edi),%eax
  8012b4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012b7:	0f b6 07             	movzbl (%edi),%eax
  8012ba:	0f b6 d0             	movzbl %al,%edx
  8012bd:	83 e8 23             	sub    $0x23,%eax
  8012c0:	3c 55                	cmp    $0x55,%al
  8012c2:	0f 87 31 03 00 00    	ja     8015f9 <vprintfmt+0x3a8>
  8012c8:	0f b6 c0             	movzbl %al,%eax
  8012cb:	ff 24 85 40 20 80 00 	jmp    *0x802040(,%eax,4)
  8012d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8012d5:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8012d9:	eb d6                	jmp    8012b1 <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012de:	b8 00 00 00 00       	mov    $0x0,%eax
  8012e3:	89 75 08             	mov    %esi,0x8(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012e6:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8012e9:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8012ed:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8012f0:	8d 72 d0             	lea    -0x30(%edx),%esi
  8012f3:	83 fe 09             	cmp    $0x9,%esi
  8012f6:	77 34                	ja     80132c <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012f8:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8012fb:	eb e9                	jmp    8012e6 <vprintfmt+0x95>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012fd:	8b 45 14             	mov    0x14(%ebp),%eax
  801300:	8d 50 04             	lea    0x4(%eax),%edx
  801303:	89 55 14             	mov    %edx,0x14(%ebp)
  801306:	8b 00                	mov    (%eax),%eax
  801308:	89 45 cc             	mov    %eax,-0x34(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80130b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80130e:	eb 22                	jmp    801332 <vprintfmt+0xe1>
  801310:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801313:	85 c0                	test   %eax,%eax
  801315:	0f 48 c1             	cmovs  %ecx,%eax
  801318:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80131b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80131e:	eb 91                	jmp    8012b1 <vprintfmt+0x60>
  801320:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801323:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80132a:	eb 85                	jmp    8012b1 <vprintfmt+0x60>
  80132c:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80132f:	8b 75 08             	mov    0x8(%ebp),%esi

		process_precision:
			if (width < 0)
  801332:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801336:	0f 89 75 ff ff ff    	jns    8012b1 <vprintfmt+0x60>
				width = precision, precision = -1;
  80133c:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80133f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801342:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  801349:	e9 63 ff ff ff       	jmp    8012b1 <vprintfmt+0x60>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80134e:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801352:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801355:	e9 57 ff ff ff       	jmp    8012b1 <vprintfmt+0x60>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80135a:	8b 45 14             	mov    0x14(%ebp),%eax
  80135d:	8d 50 04             	lea    0x4(%eax),%edx
  801360:	89 55 14             	mov    %edx,0x14(%ebp)
  801363:	83 ec 08             	sub    $0x8,%esp
  801366:	53                   	push   %ebx
  801367:	ff 30                	pushl  (%eax)
  801369:	ff d6                	call   *%esi
			break;
  80136b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80136e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801371:	e9 01 ff ff ff       	jmp    801277 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801376:	8b 45 14             	mov    0x14(%ebp),%eax
  801379:	8d 50 04             	lea    0x4(%eax),%edx
  80137c:	89 55 14             	mov    %edx,0x14(%ebp)
  80137f:	8b 00                	mov    (%eax),%eax
  801381:	99                   	cltd   
  801382:	31 d0                	xor    %edx,%eax
  801384:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801386:	83 f8 0f             	cmp    $0xf,%eax
  801389:	7f 0b                	jg     801396 <vprintfmt+0x145>
  80138b:	8b 14 85 a0 21 80 00 	mov    0x8021a0(,%eax,4),%edx
  801392:	85 d2                	test   %edx,%edx
  801394:	75 18                	jne    8013ae <vprintfmt+0x15d>
				printfmt(putch, putdat, "error %d", err);
  801396:	50                   	push   %eax
  801397:	68 23 1f 80 00       	push   $0x801f23
  80139c:	53                   	push   %ebx
  80139d:	56                   	push   %esi
  80139e:	e8 91 fe ff ff       	call   801234 <printfmt>
  8013a3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8013a9:	e9 c9 fe ff ff       	jmp    801277 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8013ae:	52                   	push   %edx
  8013af:	68 a1 1e 80 00       	push   $0x801ea1
  8013b4:	53                   	push   %ebx
  8013b5:	56                   	push   %esi
  8013b6:	e8 79 fe ff ff       	call   801234 <printfmt>
  8013bb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013c1:	e9 b1 fe ff ff       	jmp    801277 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8013c9:	8d 50 04             	lea    0x4(%eax),%edx
  8013cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8013cf:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8013d1:	85 ff                	test   %edi,%edi
  8013d3:	b8 1c 1f 80 00       	mov    $0x801f1c,%eax
  8013d8:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8013db:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013df:	0f 8e 94 00 00 00    	jle    801479 <vprintfmt+0x228>
  8013e5:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8013e9:	0f 84 98 00 00 00    	je     801487 <vprintfmt+0x236>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013ef:	83 ec 08             	sub    $0x8,%esp
  8013f2:	ff 75 cc             	pushl  -0x34(%ebp)
  8013f5:	57                   	push   %edi
  8013f6:	e8 a1 02 00 00       	call   80169c <strnlen>
  8013fb:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013fe:	29 c1                	sub    %eax,%ecx
  801400:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  801403:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801406:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80140a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80140d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801410:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801412:	eb 0f                	jmp    801423 <vprintfmt+0x1d2>
					putch(padc, putdat);
  801414:	83 ec 08             	sub    $0x8,%esp
  801417:	53                   	push   %ebx
  801418:	ff 75 e0             	pushl  -0x20(%ebp)
  80141b:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80141d:	83 ef 01             	sub    $0x1,%edi
  801420:	83 c4 10             	add    $0x10,%esp
  801423:	85 ff                	test   %edi,%edi
  801425:	7f ed                	jg     801414 <vprintfmt+0x1c3>
  801427:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80142a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80142d:	85 c9                	test   %ecx,%ecx
  80142f:	b8 00 00 00 00       	mov    $0x0,%eax
  801434:	0f 49 c1             	cmovns %ecx,%eax
  801437:	29 c1                	sub    %eax,%ecx
  801439:	89 75 08             	mov    %esi,0x8(%ebp)
  80143c:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80143f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801442:	89 cb                	mov    %ecx,%ebx
  801444:	eb 4d                	jmp    801493 <vprintfmt+0x242>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801446:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80144a:	74 1b                	je     801467 <vprintfmt+0x216>
  80144c:	0f be c0             	movsbl %al,%eax
  80144f:	83 e8 20             	sub    $0x20,%eax
  801452:	83 f8 5e             	cmp    $0x5e,%eax
  801455:	76 10                	jbe    801467 <vprintfmt+0x216>
					putch('?', putdat);
  801457:	83 ec 08             	sub    $0x8,%esp
  80145a:	ff 75 0c             	pushl  0xc(%ebp)
  80145d:	6a 3f                	push   $0x3f
  80145f:	ff 55 08             	call   *0x8(%ebp)
  801462:	83 c4 10             	add    $0x10,%esp
  801465:	eb 0d                	jmp    801474 <vprintfmt+0x223>
				else
					putch(ch, putdat);
  801467:	83 ec 08             	sub    $0x8,%esp
  80146a:	ff 75 0c             	pushl  0xc(%ebp)
  80146d:	52                   	push   %edx
  80146e:	ff 55 08             	call   *0x8(%ebp)
  801471:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801474:	83 eb 01             	sub    $0x1,%ebx
  801477:	eb 1a                	jmp    801493 <vprintfmt+0x242>
  801479:	89 75 08             	mov    %esi,0x8(%ebp)
  80147c:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80147f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801482:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801485:	eb 0c                	jmp    801493 <vprintfmt+0x242>
  801487:	89 75 08             	mov    %esi,0x8(%ebp)
  80148a:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80148d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801490:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801493:	83 c7 01             	add    $0x1,%edi
  801496:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80149a:	0f be d0             	movsbl %al,%edx
  80149d:	85 d2                	test   %edx,%edx
  80149f:	74 23                	je     8014c4 <vprintfmt+0x273>
  8014a1:	85 f6                	test   %esi,%esi
  8014a3:	78 a1                	js     801446 <vprintfmt+0x1f5>
  8014a5:	83 ee 01             	sub    $0x1,%esi
  8014a8:	79 9c                	jns    801446 <vprintfmt+0x1f5>
  8014aa:	89 df                	mov    %ebx,%edi
  8014ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8014af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014b2:	eb 18                	jmp    8014cc <vprintfmt+0x27b>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014b4:	83 ec 08             	sub    $0x8,%esp
  8014b7:	53                   	push   %ebx
  8014b8:	6a 20                	push   $0x20
  8014ba:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014bc:	83 ef 01             	sub    $0x1,%edi
  8014bf:	83 c4 10             	add    $0x10,%esp
  8014c2:	eb 08                	jmp    8014cc <vprintfmt+0x27b>
  8014c4:	89 df                	mov    %ebx,%edi
  8014c6:	8b 75 08             	mov    0x8(%ebp),%esi
  8014c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014cc:	85 ff                	test   %edi,%edi
  8014ce:	7f e4                	jg     8014b4 <vprintfmt+0x263>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014d3:	e9 9f fd ff ff       	jmp    801277 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014d8:	83 7d d0 01          	cmpl   $0x1,-0x30(%ebp)
  8014dc:	7e 16                	jle    8014f4 <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  8014de:	8b 45 14             	mov    0x14(%ebp),%eax
  8014e1:	8d 50 08             	lea    0x8(%eax),%edx
  8014e4:	89 55 14             	mov    %edx,0x14(%ebp)
  8014e7:	8b 50 04             	mov    0x4(%eax),%edx
  8014ea:	8b 00                	mov    (%eax),%eax
  8014ec:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014ef:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8014f2:	eb 34                	jmp    801528 <vprintfmt+0x2d7>
	else if (lflag)
  8014f4:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8014f8:	74 18                	je     801512 <vprintfmt+0x2c1>
		return va_arg(*ap, long);
  8014fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8014fd:	8d 50 04             	lea    0x4(%eax),%edx
  801500:	89 55 14             	mov    %edx,0x14(%ebp)
  801503:	8b 00                	mov    (%eax),%eax
  801505:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801508:	89 c1                	mov    %eax,%ecx
  80150a:	c1 f9 1f             	sar    $0x1f,%ecx
  80150d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801510:	eb 16                	jmp    801528 <vprintfmt+0x2d7>
	else
		return va_arg(*ap, int);
  801512:	8b 45 14             	mov    0x14(%ebp),%eax
  801515:	8d 50 04             	lea    0x4(%eax),%edx
  801518:	89 55 14             	mov    %edx,0x14(%ebp)
  80151b:	8b 00                	mov    (%eax),%eax
  80151d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801520:	89 c1                	mov    %eax,%ecx
  801522:	c1 f9 1f             	sar    $0x1f,%ecx
  801525:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801528:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80152b:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80152e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801533:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801537:	0f 89 88 00 00 00    	jns    8015c5 <vprintfmt+0x374>
				putch('-', putdat);
  80153d:	83 ec 08             	sub    $0x8,%esp
  801540:	53                   	push   %ebx
  801541:	6a 2d                	push   $0x2d
  801543:	ff d6                	call   *%esi
				num = -(long long) num;
  801545:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801548:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80154b:	f7 d8                	neg    %eax
  80154d:	83 d2 00             	adc    $0x0,%edx
  801550:	f7 da                	neg    %edx
  801552:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801555:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80155a:	eb 69                	jmp    8015c5 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80155c:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80155f:	8d 45 14             	lea    0x14(%ebp),%eax
  801562:	e8 76 fc ff ff       	call   8011dd <getuint>
			base = 10;
  801567:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80156c:	eb 57                	jmp    8015c5 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  80156e:	83 ec 08             	sub    $0x8,%esp
  801571:	53                   	push   %ebx
  801572:	6a 30                	push   $0x30
  801574:	ff d6                	call   *%esi
			num = getuint(&ap, lflag);
  801576:	8b 55 d0             	mov    -0x30(%ebp),%edx
  801579:	8d 45 14             	lea    0x14(%ebp),%eax
  80157c:	e8 5c fc ff ff       	call   8011dd <getuint>
			base = 8;
			goto number;
  801581:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  801584:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801589:	eb 3a                	jmp    8015c5 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  80158b:	83 ec 08             	sub    $0x8,%esp
  80158e:	53                   	push   %ebx
  80158f:	6a 30                	push   $0x30
  801591:	ff d6                	call   *%esi
			putch('x', putdat);
  801593:	83 c4 08             	add    $0x8,%esp
  801596:	53                   	push   %ebx
  801597:	6a 78                	push   $0x78
  801599:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80159b:	8b 45 14             	mov    0x14(%ebp),%eax
  80159e:	8d 50 04             	lea    0x4(%eax),%edx
  8015a1:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8015a4:	8b 00                	mov    (%eax),%eax
  8015a6:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015ab:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8015ae:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8015b3:	eb 10                	jmp    8015c5 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8015b5:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8015b8:	8d 45 14             	lea    0x14(%ebp),%eax
  8015bb:	e8 1d fc ff ff       	call   8011dd <getuint>
			base = 16;
  8015c0:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8015c5:	83 ec 0c             	sub    $0xc,%esp
  8015c8:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015cc:	57                   	push   %edi
  8015cd:	ff 75 e0             	pushl  -0x20(%ebp)
  8015d0:	51                   	push   %ecx
  8015d1:	52                   	push   %edx
  8015d2:	50                   	push   %eax
  8015d3:	89 da                	mov    %ebx,%edx
  8015d5:	89 f0                	mov    %esi,%eax
  8015d7:	e8 52 fb ff ff       	call   80112e <printnum>
			break;
  8015dc:	83 c4 20             	add    $0x20,%esp
  8015df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015e2:	e9 90 fc ff ff       	jmp    801277 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8015e7:	83 ec 08             	sub    $0x8,%esp
  8015ea:	53                   	push   %ebx
  8015eb:	52                   	push   %edx
  8015ec:	ff d6                	call   *%esi
			break;
  8015ee:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8015f4:	e9 7e fc ff ff       	jmp    801277 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8015f9:	83 ec 08             	sub    $0x8,%esp
  8015fc:	53                   	push   %ebx
  8015fd:	6a 25                	push   $0x25
  8015ff:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801601:	83 c4 10             	add    $0x10,%esp
  801604:	eb 03                	jmp    801609 <vprintfmt+0x3b8>
  801606:	83 ef 01             	sub    $0x1,%edi
  801609:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80160d:	75 f7                	jne    801606 <vprintfmt+0x3b5>
  80160f:	e9 63 fc ff ff       	jmp    801277 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801614:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801617:	5b                   	pop    %ebx
  801618:	5e                   	pop    %esi
  801619:	5f                   	pop    %edi
  80161a:	5d                   	pop    %ebp
  80161b:	c3                   	ret    

0080161c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80161c:	55                   	push   %ebp
  80161d:	89 e5                	mov    %esp,%ebp
  80161f:	83 ec 18             	sub    $0x18,%esp
  801622:	8b 45 08             	mov    0x8(%ebp),%eax
  801625:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801628:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80162b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80162f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801632:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801639:	85 c0                	test   %eax,%eax
  80163b:	74 26                	je     801663 <vsnprintf+0x47>
  80163d:	85 d2                	test   %edx,%edx
  80163f:	7e 22                	jle    801663 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801641:	ff 75 14             	pushl  0x14(%ebp)
  801644:	ff 75 10             	pushl  0x10(%ebp)
  801647:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80164a:	50                   	push   %eax
  80164b:	68 17 12 80 00       	push   $0x801217
  801650:	e8 fc fb ff ff       	call   801251 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801655:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801658:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80165b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80165e:	83 c4 10             	add    $0x10,%esp
  801661:	eb 05                	jmp    801668 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801663:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801668:	c9                   	leave  
  801669:	c3                   	ret    

0080166a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80166a:	55                   	push   %ebp
  80166b:	89 e5                	mov    %esp,%ebp
  80166d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801670:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801673:	50                   	push   %eax
  801674:	ff 75 10             	pushl  0x10(%ebp)
  801677:	ff 75 0c             	pushl  0xc(%ebp)
  80167a:	ff 75 08             	pushl  0x8(%ebp)
  80167d:	e8 9a ff ff ff       	call   80161c <vsnprintf>
	va_end(ap);

	return rc;
}
  801682:	c9                   	leave  
  801683:	c3                   	ret    

00801684 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801684:	55                   	push   %ebp
  801685:	89 e5                	mov    %esp,%ebp
  801687:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80168a:	b8 00 00 00 00       	mov    $0x0,%eax
  80168f:	eb 03                	jmp    801694 <strlen+0x10>
		n++;
  801691:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801694:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801698:	75 f7                	jne    801691 <strlen+0xd>
		n++;
	return n;
}
  80169a:	5d                   	pop    %ebp
  80169b:	c3                   	ret    

0080169c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80169c:	55                   	push   %ebp
  80169d:	89 e5                	mov    %esp,%ebp
  80169f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016a2:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8016aa:	eb 03                	jmp    8016af <strnlen+0x13>
		n++;
  8016ac:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016af:	39 c2                	cmp    %eax,%edx
  8016b1:	74 08                	je     8016bb <strnlen+0x1f>
  8016b3:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8016b7:	75 f3                	jne    8016ac <strnlen+0x10>
  8016b9:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8016bb:	5d                   	pop    %ebp
  8016bc:	c3                   	ret    

008016bd <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016bd:	55                   	push   %ebp
  8016be:	89 e5                	mov    %esp,%ebp
  8016c0:	53                   	push   %ebx
  8016c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016c7:	89 c2                	mov    %eax,%edx
  8016c9:	83 c2 01             	add    $0x1,%edx
  8016cc:	83 c1 01             	add    $0x1,%ecx
  8016cf:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8016d3:	88 5a ff             	mov    %bl,-0x1(%edx)
  8016d6:	84 db                	test   %bl,%bl
  8016d8:	75 ef                	jne    8016c9 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8016da:	5b                   	pop    %ebx
  8016db:	5d                   	pop    %ebp
  8016dc:	c3                   	ret    

008016dd <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016dd:	55                   	push   %ebp
  8016de:	89 e5                	mov    %esp,%ebp
  8016e0:	53                   	push   %ebx
  8016e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016e4:	53                   	push   %ebx
  8016e5:	e8 9a ff ff ff       	call   801684 <strlen>
  8016ea:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8016ed:	ff 75 0c             	pushl  0xc(%ebp)
  8016f0:	01 d8                	add    %ebx,%eax
  8016f2:	50                   	push   %eax
  8016f3:	e8 c5 ff ff ff       	call   8016bd <strcpy>
	return dst;
}
  8016f8:	89 d8                	mov    %ebx,%eax
  8016fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016fd:	c9                   	leave  
  8016fe:	c3                   	ret    

008016ff <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016ff:	55                   	push   %ebp
  801700:	89 e5                	mov    %esp,%ebp
  801702:	56                   	push   %esi
  801703:	53                   	push   %ebx
  801704:	8b 75 08             	mov    0x8(%ebp),%esi
  801707:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80170a:	89 f3                	mov    %esi,%ebx
  80170c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80170f:	89 f2                	mov    %esi,%edx
  801711:	eb 0f                	jmp    801722 <strncpy+0x23>
		*dst++ = *src;
  801713:	83 c2 01             	add    $0x1,%edx
  801716:	0f b6 01             	movzbl (%ecx),%eax
  801719:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80171c:	80 39 01             	cmpb   $0x1,(%ecx)
  80171f:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801722:	39 da                	cmp    %ebx,%edx
  801724:	75 ed                	jne    801713 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801726:	89 f0                	mov    %esi,%eax
  801728:	5b                   	pop    %ebx
  801729:	5e                   	pop    %esi
  80172a:	5d                   	pop    %ebp
  80172b:	c3                   	ret    

0080172c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80172c:	55                   	push   %ebp
  80172d:	89 e5                	mov    %esp,%ebp
  80172f:	56                   	push   %esi
  801730:	53                   	push   %ebx
  801731:	8b 75 08             	mov    0x8(%ebp),%esi
  801734:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801737:	8b 55 10             	mov    0x10(%ebp),%edx
  80173a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80173c:	85 d2                	test   %edx,%edx
  80173e:	74 21                	je     801761 <strlcpy+0x35>
  801740:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801744:	89 f2                	mov    %esi,%edx
  801746:	eb 09                	jmp    801751 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801748:	83 c2 01             	add    $0x1,%edx
  80174b:	83 c1 01             	add    $0x1,%ecx
  80174e:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801751:	39 c2                	cmp    %eax,%edx
  801753:	74 09                	je     80175e <strlcpy+0x32>
  801755:	0f b6 19             	movzbl (%ecx),%ebx
  801758:	84 db                	test   %bl,%bl
  80175a:	75 ec                	jne    801748 <strlcpy+0x1c>
  80175c:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80175e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801761:	29 f0                	sub    %esi,%eax
}
  801763:	5b                   	pop    %ebx
  801764:	5e                   	pop    %esi
  801765:	5d                   	pop    %ebp
  801766:	c3                   	ret    

00801767 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801767:	55                   	push   %ebp
  801768:	89 e5                	mov    %esp,%ebp
  80176a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80176d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801770:	eb 06                	jmp    801778 <strcmp+0x11>
		p++, q++;
  801772:	83 c1 01             	add    $0x1,%ecx
  801775:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801778:	0f b6 01             	movzbl (%ecx),%eax
  80177b:	84 c0                	test   %al,%al
  80177d:	74 04                	je     801783 <strcmp+0x1c>
  80177f:	3a 02                	cmp    (%edx),%al
  801781:	74 ef                	je     801772 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801783:	0f b6 c0             	movzbl %al,%eax
  801786:	0f b6 12             	movzbl (%edx),%edx
  801789:	29 d0                	sub    %edx,%eax
}
  80178b:	5d                   	pop    %ebp
  80178c:	c3                   	ret    

0080178d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80178d:	55                   	push   %ebp
  80178e:	89 e5                	mov    %esp,%ebp
  801790:	53                   	push   %ebx
  801791:	8b 45 08             	mov    0x8(%ebp),%eax
  801794:	8b 55 0c             	mov    0xc(%ebp),%edx
  801797:	89 c3                	mov    %eax,%ebx
  801799:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80179c:	eb 06                	jmp    8017a4 <strncmp+0x17>
		n--, p++, q++;
  80179e:	83 c0 01             	add    $0x1,%eax
  8017a1:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017a4:	39 d8                	cmp    %ebx,%eax
  8017a6:	74 15                	je     8017bd <strncmp+0x30>
  8017a8:	0f b6 08             	movzbl (%eax),%ecx
  8017ab:	84 c9                	test   %cl,%cl
  8017ad:	74 04                	je     8017b3 <strncmp+0x26>
  8017af:	3a 0a                	cmp    (%edx),%cl
  8017b1:	74 eb                	je     80179e <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017b3:	0f b6 00             	movzbl (%eax),%eax
  8017b6:	0f b6 12             	movzbl (%edx),%edx
  8017b9:	29 d0                	sub    %edx,%eax
  8017bb:	eb 05                	jmp    8017c2 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017bd:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8017c2:	5b                   	pop    %ebx
  8017c3:	5d                   	pop    %ebp
  8017c4:	c3                   	ret    

008017c5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017c5:	55                   	push   %ebp
  8017c6:	89 e5                	mov    %esp,%ebp
  8017c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017cb:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017cf:	eb 07                	jmp    8017d8 <strchr+0x13>
		if (*s == c)
  8017d1:	38 ca                	cmp    %cl,%dl
  8017d3:	74 0f                	je     8017e4 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017d5:	83 c0 01             	add    $0x1,%eax
  8017d8:	0f b6 10             	movzbl (%eax),%edx
  8017db:	84 d2                	test   %dl,%dl
  8017dd:	75 f2                	jne    8017d1 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8017df:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017e4:	5d                   	pop    %ebp
  8017e5:	c3                   	ret    

008017e6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017e6:	55                   	push   %ebp
  8017e7:	89 e5                	mov    %esp,%ebp
  8017e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ec:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017f0:	eb 03                	jmp    8017f5 <strfind+0xf>
  8017f2:	83 c0 01             	add    $0x1,%eax
  8017f5:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8017f8:	38 ca                	cmp    %cl,%dl
  8017fa:	74 04                	je     801800 <strfind+0x1a>
  8017fc:	84 d2                	test   %dl,%dl
  8017fe:	75 f2                	jne    8017f2 <strfind+0xc>
			break;
	return (char *) s;
}
  801800:	5d                   	pop    %ebp
  801801:	c3                   	ret    

00801802 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801802:	55                   	push   %ebp
  801803:	89 e5                	mov    %esp,%ebp
  801805:	57                   	push   %edi
  801806:	56                   	push   %esi
  801807:	53                   	push   %ebx
  801808:	8b 7d 08             	mov    0x8(%ebp),%edi
  80180b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80180e:	85 c9                	test   %ecx,%ecx
  801810:	74 36                	je     801848 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801812:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801818:	75 28                	jne    801842 <memset+0x40>
  80181a:	f6 c1 03             	test   $0x3,%cl
  80181d:	75 23                	jne    801842 <memset+0x40>
		c &= 0xFF;
  80181f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801823:	89 d3                	mov    %edx,%ebx
  801825:	c1 e3 08             	shl    $0x8,%ebx
  801828:	89 d6                	mov    %edx,%esi
  80182a:	c1 e6 18             	shl    $0x18,%esi
  80182d:	89 d0                	mov    %edx,%eax
  80182f:	c1 e0 10             	shl    $0x10,%eax
  801832:	09 f0                	or     %esi,%eax
  801834:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801836:	89 d8                	mov    %ebx,%eax
  801838:	09 d0                	or     %edx,%eax
  80183a:	c1 e9 02             	shr    $0x2,%ecx
  80183d:	fc                   	cld    
  80183e:	f3 ab                	rep stos %eax,%es:(%edi)
  801840:	eb 06                	jmp    801848 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801842:	8b 45 0c             	mov    0xc(%ebp),%eax
  801845:	fc                   	cld    
  801846:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801848:	89 f8                	mov    %edi,%eax
  80184a:	5b                   	pop    %ebx
  80184b:	5e                   	pop    %esi
  80184c:	5f                   	pop    %edi
  80184d:	5d                   	pop    %ebp
  80184e:	c3                   	ret    

0080184f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80184f:	55                   	push   %ebp
  801850:	89 e5                	mov    %esp,%ebp
  801852:	57                   	push   %edi
  801853:	56                   	push   %esi
  801854:	8b 45 08             	mov    0x8(%ebp),%eax
  801857:	8b 75 0c             	mov    0xc(%ebp),%esi
  80185a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80185d:	39 c6                	cmp    %eax,%esi
  80185f:	73 35                	jae    801896 <memmove+0x47>
  801861:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801864:	39 d0                	cmp    %edx,%eax
  801866:	73 2e                	jae    801896 <memmove+0x47>
		s += n;
		d += n;
  801868:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80186b:	89 d6                	mov    %edx,%esi
  80186d:	09 fe                	or     %edi,%esi
  80186f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801875:	75 13                	jne    80188a <memmove+0x3b>
  801877:	f6 c1 03             	test   $0x3,%cl
  80187a:	75 0e                	jne    80188a <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80187c:	83 ef 04             	sub    $0x4,%edi
  80187f:	8d 72 fc             	lea    -0x4(%edx),%esi
  801882:	c1 e9 02             	shr    $0x2,%ecx
  801885:	fd                   	std    
  801886:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801888:	eb 09                	jmp    801893 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80188a:	83 ef 01             	sub    $0x1,%edi
  80188d:	8d 72 ff             	lea    -0x1(%edx),%esi
  801890:	fd                   	std    
  801891:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801893:	fc                   	cld    
  801894:	eb 1d                	jmp    8018b3 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801896:	89 f2                	mov    %esi,%edx
  801898:	09 c2                	or     %eax,%edx
  80189a:	f6 c2 03             	test   $0x3,%dl
  80189d:	75 0f                	jne    8018ae <memmove+0x5f>
  80189f:	f6 c1 03             	test   $0x3,%cl
  8018a2:	75 0a                	jne    8018ae <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8018a4:	c1 e9 02             	shr    $0x2,%ecx
  8018a7:	89 c7                	mov    %eax,%edi
  8018a9:	fc                   	cld    
  8018aa:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018ac:	eb 05                	jmp    8018b3 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018ae:	89 c7                	mov    %eax,%edi
  8018b0:	fc                   	cld    
  8018b1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018b3:	5e                   	pop    %esi
  8018b4:	5f                   	pop    %edi
  8018b5:	5d                   	pop    %ebp
  8018b6:	c3                   	ret    

008018b7 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018b7:	55                   	push   %ebp
  8018b8:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018ba:	ff 75 10             	pushl  0x10(%ebp)
  8018bd:	ff 75 0c             	pushl  0xc(%ebp)
  8018c0:	ff 75 08             	pushl  0x8(%ebp)
  8018c3:	e8 87 ff ff ff       	call   80184f <memmove>
}
  8018c8:	c9                   	leave  
  8018c9:	c3                   	ret    

008018ca <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018ca:	55                   	push   %ebp
  8018cb:	89 e5                	mov    %esp,%ebp
  8018cd:	56                   	push   %esi
  8018ce:	53                   	push   %ebx
  8018cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018d5:	89 c6                	mov    %eax,%esi
  8018d7:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018da:	eb 1a                	jmp    8018f6 <memcmp+0x2c>
		if (*s1 != *s2)
  8018dc:	0f b6 08             	movzbl (%eax),%ecx
  8018df:	0f b6 1a             	movzbl (%edx),%ebx
  8018e2:	38 d9                	cmp    %bl,%cl
  8018e4:	74 0a                	je     8018f0 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8018e6:	0f b6 c1             	movzbl %cl,%eax
  8018e9:	0f b6 db             	movzbl %bl,%ebx
  8018ec:	29 d8                	sub    %ebx,%eax
  8018ee:	eb 0f                	jmp    8018ff <memcmp+0x35>
		s1++, s2++;
  8018f0:	83 c0 01             	add    $0x1,%eax
  8018f3:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018f6:	39 f0                	cmp    %esi,%eax
  8018f8:	75 e2                	jne    8018dc <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8018fa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018ff:	5b                   	pop    %ebx
  801900:	5e                   	pop    %esi
  801901:	5d                   	pop    %ebp
  801902:	c3                   	ret    

00801903 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801903:	55                   	push   %ebp
  801904:	89 e5                	mov    %esp,%ebp
  801906:	53                   	push   %ebx
  801907:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80190a:	89 c1                	mov    %eax,%ecx
  80190c:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80190f:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801913:	eb 0a                	jmp    80191f <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801915:	0f b6 10             	movzbl (%eax),%edx
  801918:	39 da                	cmp    %ebx,%edx
  80191a:	74 07                	je     801923 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80191c:	83 c0 01             	add    $0x1,%eax
  80191f:	39 c8                	cmp    %ecx,%eax
  801921:	72 f2                	jb     801915 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801923:	5b                   	pop    %ebx
  801924:	5d                   	pop    %ebp
  801925:	c3                   	ret    

00801926 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801926:	55                   	push   %ebp
  801927:	89 e5                	mov    %esp,%ebp
  801929:	57                   	push   %edi
  80192a:	56                   	push   %esi
  80192b:	53                   	push   %ebx
  80192c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80192f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801932:	eb 03                	jmp    801937 <strtol+0x11>
		s++;
  801934:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801937:	0f b6 01             	movzbl (%ecx),%eax
  80193a:	3c 20                	cmp    $0x20,%al
  80193c:	74 f6                	je     801934 <strtol+0xe>
  80193e:	3c 09                	cmp    $0x9,%al
  801940:	74 f2                	je     801934 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801942:	3c 2b                	cmp    $0x2b,%al
  801944:	75 0a                	jne    801950 <strtol+0x2a>
		s++;
  801946:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801949:	bf 00 00 00 00       	mov    $0x0,%edi
  80194e:	eb 11                	jmp    801961 <strtol+0x3b>
  801950:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801955:	3c 2d                	cmp    $0x2d,%al
  801957:	75 08                	jne    801961 <strtol+0x3b>
		s++, neg = 1;
  801959:	83 c1 01             	add    $0x1,%ecx
  80195c:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801961:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801967:	75 15                	jne    80197e <strtol+0x58>
  801969:	80 39 30             	cmpb   $0x30,(%ecx)
  80196c:	75 10                	jne    80197e <strtol+0x58>
  80196e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801972:	75 7c                	jne    8019f0 <strtol+0xca>
		s += 2, base = 16;
  801974:	83 c1 02             	add    $0x2,%ecx
  801977:	bb 10 00 00 00       	mov    $0x10,%ebx
  80197c:	eb 16                	jmp    801994 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  80197e:	85 db                	test   %ebx,%ebx
  801980:	75 12                	jne    801994 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801982:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801987:	80 39 30             	cmpb   $0x30,(%ecx)
  80198a:	75 08                	jne    801994 <strtol+0x6e>
		s++, base = 8;
  80198c:	83 c1 01             	add    $0x1,%ecx
  80198f:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801994:	b8 00 00 00 00       	mov    $0x0,%eax
  801999:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80199c:	0f b6 11             	movzbl (%ecx),%edx
  80199f:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019a2:	89 f3                	mov    %esi,%ebx
  8019a4:	80 fb 09             	cmp    $0x9,%bl
  8019a7:	77 08                	ja     8019b1 <strtol+0x8b>
			dig = *s - '0';
  8019a9:	0f be d2             	movsbl %dl,%edx
  8019ac:	83 ea 30             	sub    $0x30,%edx
  8019af:	eb 22                	jmp    8019d3 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8019b1:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019b4:	89 f3                	mov    %esi,%ebx
  8019b6:	80 fb 19             	cmp    $0x19,%bl
  8019b9:	77 08                	ja     8019c3 <strtol+0x9d>
			dig = *s - 'a' + 10;
  8019bb:	0f be d2             	movsbl %dl,%edx
  8019be:	83 ea 57             	sub    $0x57,%edx
  8019c1:	eb 10                	jmp    8019d3 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8019c3:	8d 72 bf             	lea    -0x41(%edx),%esi
  8019c6:	89 f3                	mov    %esi,%ebx
  8019c8:	80 fb 19             	cmp    $0x19,%bl
  8019cb:	77 16                	ja     8019e3 <strtol+0xbd>
			dig = *s - 'A' + 10;
  8019cd:	0f be d2             	movsbl %dl,%edx
  8019d0:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8019d3:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019d6:	7d 0b                	jge    8019e3 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8019d8:	83 c1 01             	add    $0x1,%ecx
  8019db:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019df:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8019e1:	eb b9                	jmp    80199c <strtol+0x76>

	if (endptr)
  8019e3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019e7:	74 0d                	je     8019f6 <strtol+0xd0>
		*endptr = (char *) s;
  8019e9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8019ec:	89 0e                	mov    %ecx,(%esi)
  8019ee:	eb 06                	jmp    8019f6 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019f0:	85 db                	test   %ebx,%ebx
  8019f2:	74 98                	je     80198c <strtol+0x66>
  8019f4:	eb 9e                	jmp    801994 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8019f6:	89 c2                	mov    %eax,%edx
  8019f8:	f7 da                	neg    %edx
  8019fa:	85 ff                	test   %edi,%edi
  8019fc:	0f 45 c2             	cmovne %edx,%eax
}
  8019ff:	5b                   	pop    %ebx
  801a00:	5e                   	pop    %esi
  801a01:	5f                   	pop    %edi
  801a02:	5d                   	pop    %ebp
  801a03:	c3                   	ret    

00801a04 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a04:	55                   	push   %ebp
  801a05:	89 e5                	mov    %esp,%ebp
  801a07:	56                   	push   %esi
  801a08:	53                   	push   %ebx
  801a09:	8b 75 08             	mov    0x8(%ebp),%esi
  801a0c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a0f:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_recv not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  801a12:	85 c0                	test   %eax,%eax
  801a14:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a19:	0f 44 c2             	cmove  %edx,%eax

    int r = sys_ipc_recv(pg);
  801a1c:	83 ec 0c             	sub    $0xc,%esp
  801a1f:	50                   	push   %eax
  801a20:	e8 f1 e8 ff ff       	call   800316 <sys_ipc_recv>
    int from_env = 0, perm = 0;
    if (r == 0) {
  801a25:	83 c4 10             	add    $0x10,%esp
  801a28:	85 c0                	test   %eax,%eax
  801a2a:	75 10                	jne    801a3c <ipc_recv+0x38>
        from_env = thisenv->env_ipc_from;
  801a2c:	a1 04 40 80 00       	mov    0x804004,%eax
  801a31:	8b 48 74             	mov    0x74(%eax),%ecx
        perm = thisenv->env_ipc_perm;
  801a34:	8b 50 78             	mov    0x78(%eax),%edx
        r = thisenv->env_ipc_value;
  801a37:	8b 40 70             	mov    0x70(%eax),%eax
  801a3a:	eb 0a                	jmp    801a46 <ipc_recv+0x42>
    } else {
        from_env = 0;
        perm = 0;
  801a3c:	ba 00 00 00 00       	mov    $0x0,%edx
    if (r == 0) {
        from_env = thisenv->env_ipc_from;
        perm = thisenv->env_ipc_perm;
        r = thisenv->env_ipc_value;
    } else {
        from_env = 0;
  801a41:	b9 00 00 00 00       	mov    $0x0,%ecx
        perm = 0;
    }

    if (from_env_store) *from_env_store = from_env;
  801a46:	85 f6                	test   %esi,%esi
  801a48:	74 02                	je     801a4c <ipc_recv+0x48>
  801a4a:	89 0e                	mov    %ecx,(%esi)
    if (perm_store) *perm_store = perm;
  801a4c:	85 db                	test   %ebx,%ebx
  801a4e:	74 02                	je     801a52 <ipc_recv+0x4e>
  801a50:	89 13                	mov    %edx,(%ebx)

    return r;
}
  801a52:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a55:	5b                   	pop    %ebx
  801a56:	5e                   	pop    %esi
  801a57:	5d                   	pop    %ebp
  801a58:	c3                   	ret    

00801a59 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a59:	55                   	push   %ebp
  801a5a:	89 e5                	mov    %esp,%ebp
  801a5c:	57                   	push   %edi
  801a5d:	56                   	push   %esi
  801a5e:	53                   	push   %ebx
  801a5f:	83 ec 0c             	sub    $0xc,%esp
  801a62:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a65:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a68:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  801a6b:	85 db                	test   %ebx,%ebx
  801a6d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801a72:	0f 44 d8             	cmove  %eax,%ebx
  801a75:	eb 1c                	jmp    801a93 <ipc_send+0x3a>

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        if (ret != -E_IPC_NOT_RECV)
  801a77:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a7a:	74 12                	je     801a8e <ipc_send+0x35>
            panic("ipc_send error %e", ret);
  801a7c:	50                   	push   %eax
  801a7d:	68 00 22 80 00       	push   $0x802200
  801a82:	6a 40                	push   $0x40
  801a84:	68 12 22 80 00       	push   $0x802212
  801a89:	e8 b3 f5 ff ff       	call   801041 <_panic>
        sys_yield();
  801a8e:	e8 b4 e6 ff ff       	call   800147 <sys_yield>
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801a93:	ff 75 14             	pushl  0x14(%ebp)
  801a96:	53                   	push   %ebx
  801a97:	56                   	push   %esi
  801a98:	57                   	push   %edi
  801a99:	e8 55 e8 ff ff       	call   8002f3 <sys_ipc_try_send>
  801a9e:	83 c4 10             	add    $0x10,%esp
  801aa1:	85 c0                	test   %eax,%eax
  801aa3:	75 d2                	jne    801a77 <ipc_send+0x1e>
        if (ret != -E_IPC_NOT_RECV)
            panic("ipc_send error %e", ret);
        sys_yield();
    }
}
  801aa5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aa8:	5b                   	pop    %ebx
  801aa9:	5e                   	pop    %esi
  801aaa:	5f                   	pop    %edi
  801aab:	5d                   	pop    %ebp
  801aac:	c3                   	ret    

00801aad <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801aad:	55                   	push   %ebp
  801aae:	89 e5                	mov    %esp,%ebp
  801ab0:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ab3:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ab8:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801abb:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ac1:	8b 52 50             	mov    0x50(%edx),%edx
  801ac4:	39 ca                	cmp    %ecx,%edx
  801ac6:	75 0d                	jne    801ad5 <ipc_find_env+0x28>
			return envs[i].env_id;
  801ac8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801acb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ad0:	8b 40 48             	mov    0x48(%eax),%eax
  801ad3:	eb 0f                	jmp    801ae4 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ad5:	83 c0 01             	add    $0x1,%eax
  801ad8:	3d 00 04 00 00       	cmp    $0x400,%eax
  801add:	75 d9                	jne    801ab8 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801adf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ae4:	5d                   	pop    %ebp
  801ae5:	c3                   	ret    

00801ae6 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ae6:	55                   	push   %ebp
  801ae7:	89 e5                	mov    %esp,%ebp
  801ae9:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801aec:	89 d0                	mov    %edx,%eax
  801aee:	c1 e8 16             	shr    $0x16,%eax
  801af1:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801af8:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801afd:	f6 c1 01             	test   $0x1,%cl
  801b00:	74 1d                	je     801b1f <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b02:	c1 ea 0c             	shr    $0xc,%edx
  801b05:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b0c:	f6 c2 01             	test   $0x1,%dl
  801b0f:	74 0e                	je     801b1f <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b11:	c1 ea 0c             	shr    $0xc,%edx
  801b14:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b1b:	ef 
  801b1c:	0f b7 c0             	movzwl %ax,%eax
}
  801b1f:	5d                   	pop    %ebp
  801b20:	c3                   	ret    
  801b21:	66 90                	xchg   %ax,%ax
  801b23:	66 90                	xchg   %ax,%ax
  801b25:	66 90                	xchg   %ax,%ax
  801b27:	66 90                	xchg   %ax,%ax
  801b29:	66 90                	xchg   %ax,%ax
  801b2b:	66 90                	xchg   %ax,%ax
  801b2d:	66 90                	xchg   %ax,%ax
  801b2f:	90                   	nop

00801b30 <__udivdi3>:
  801b30:	55                   	push   %ebp
  801b31:	57                   	push   %edi
  801b32:	56                   	push   %esi
  801b33:	53                   	push   %ebx
  801b34:	83 ec 1c             	sub    $0x1c,%esp
  801b37:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801b3b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801b3f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801b43:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801b47:	85 f6                	test   %esi,%esi
  801b49:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b4d:	89 ca                	mov    %ecx,%edx
  801b4f:	89 f8                	mov    %edi,%eax
  801b51:	75 3d                	jne    801b90 <__udivdi3+0x60>
  801b53:	39 cf                	cmp    %ecx,%edi
  801b55:	0f 87 c5 00 00 00    	ja     801c20 <__udivdi3+0xf0>
  801b5b:	85 ff                	test   %edi,%edi
  801b5d:	89 fd                	mov    %edi,%ebp
  801b5f:	75 0b                	jne    801b6c <__udivdi3+0x3c>
  801b61:	b8 01 00 00 00       	mov    $0x1,%eax
  801b66:	31 d2                	xor    %edx,%edx
  801b68:	f7 f7                	div    %edi
  801b6a:	89 c5                	mov    %eax,%ebp
  801b6c:	89 c8                	mov    %ecx,%eax
  801b6e:	31 d2                	xor    %edx,%edx
  801b70:	f7 f5                	div    %ebp
  801b72:	89 c1                	mov    %eax,%ecx
  801b74:	89 d8                	mov    %ebx,%eax
  801b76:	89 cf                	mov    %ecx,%edi
  801b78:	f7 f5                	div    %ebp
  801b7a:	89 c3                	mov    %eax,%ebx
  801b7c:	89 d8                	mov    %ebx,%eax
  801b7e:	89 fa                	mov    %edi,%edx
  801b80:	83 c4 1c             	add    $0x1c,%esp
  801b83:	5b                   	pop    %ebx
  801b84:	5e                   	pop    %esi
  801b85:	5f                   	pop    %edi
  801b86:	5d                   	pop    %ebp
  801b87:	c3                   	ret    
  801b88:	90                   	nop
  801b89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801b90:	39 ce                	cmp    %ecx,%esi
  801b92:	77 74                	ja     801c08 <__udivdi3+0xd8>
  801b94:	0f bd fe             	bsr    %esi,%edi
  801b97:	83 f7 1f             	xor    $0x1f,%edi
  801b9a:	0f 84 98 00 00 00    	je     801c38 <__udivdi3+0x108>
  801ba0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801ba5:	89 f9                	mov    %edi,%ecx
  801ba7:	89 c5                	mov    %eax,%ebp
  801ba9:	29 fb                	sub    %edi,%ebx
  801bab:	d3 e6                	shl    %cl,%esi
  801bad:	89 d9                	mov    %ebx,%ecx
  801baf:	d3 ed                	shr    %cl,%ebp
  801bb1:	89 f9                	mov    %edi,%ecx
  801bb3:	d3 e0                	shl    %cl,%eax
  801bb5:	09 ee                	or     %ebp,%esi
  801bb7:	89 d9                	mov    %ebx,%ecx
  801bb9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bbd:	89 d5                	mov    %edx,%ebp
  801bbf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801bc3:	d3 ed                	shr    %cl,%ebp
  801bc5:	89 f9                	mov    %edi,%ecx
  801bc7:	d3 e2                	shl    %cl,%edx
  801bc9:	89 d9                	mov    %ebx,%ecx
  801bcb:	d3 e8                	shr    %cl,%eax
  801bcd:	09 c2                	or     %eax,%edx
  801bcf:	89 d0                	mov    %edx,%eax
  801bd1:	89 ea                	mov    %ebp,%edx
  801bd3:	f7 f6                	div    %esi
  801bd5:	89 d5                	mov    %edx,%ebp
  801bd7:	89 c3                	mov    %eax,%ebx
  801bd9:	f7 64 24 0c          	mull   0xc(%esp)
  801bdd:	39 d5                	cmp    %edx,%ebp
  801bdf:	72 10                	jb     801bf1 <__udivdi3+0xc1>
  801be1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801be5:	89 f9                	mov    %edi,%ecx
  801be7:	d3 e6                	shl    %cl,%esi
  801be9:	39 c6                	cmp    %eax,%esi
  801beb:	73 07                	jae    801bf4 <__udivdi3+0xc4>
  801bed:	39 d5                	cmp    %edx,%ebp
  801bef:	75 03                	jne    801bf4 <__udivdi3+0xc4>
  801bf1:	83 eb 01             	sub    $0x1,%ebx
  801bf4:	31 ff                	xor    %edi,%edi
  801bf6:	89 d8                	mov    %ebx,%eax
  801bf8:	89 fa                	mov    %edi,%edx
  801bfa:	83 c4 1c             	add    $0x1c,%esp
  801bfd:	5b                   	pop    %ebx
  801bfe:	5e                   	pop    %esi
  801bff:	5f                   	pop    %edi
  801c00:	5d                   	pop    %ebp
  801c01:	c3                   	ret    
  801c02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c08:	31 ff                	xor    %edi,%edi
  801c0a:	31 db                	xor    %ebx,%ebx
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
  801c20:	89 d8                	mov    %ebx,%eax
  801c22:	f7 f7                	div    %edi
  801c24:	31 ff                	xor    %edi,%edi
  801c26:	89 c3                	mov    %eax,%ebx
  801c28:	89 d8                	mov    %ebx,%eax
  801c2a:	89 fa                	mov    %edi,%edx
  801c2c:	83 c4 1c             	add    $0x1c,%esp
  801c2f:	5b                   	pop    %ebx
  801c30:	5e                   	pop    %esi
  801c31:	5f                   	pop    %edi
  801c32:	5d                   	pop    %ebp
  801c33:	c3                   	ret    
  801c34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c38:	39 ce                	cmp    %ecx,%esi
  801c3a:	72 0c                	jb     801c48 <__udivdi3+0x118>
  801c3c:	31 db                	xor    %ebx,%ebx
  801c3e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801c42:	0f 87 34 ff ff ff    	ja     801b7c <__udivdi3+0x4c>
  801c48:	bb 01 00 00 00       	mov    $0x1,%ebx
  801c4d:	e9 2a ff ff ff       	jmp    801b7c <__udivdi3+0x4c>
  801c52:	66 90                	xchg   %ax,%ax
  801c54:	66 90                	xchg   %ax,%ax
  801c56:	66 90                	xchg   %ax,%ax
  801c58:	66 90                	xchg   %ax,%ax
  801c5a:	66 90                	xchg   %ax,%ax
  801c5c:	66 90                	xchg   %ax,%ax
  801c5e:	66 90                	xchg   %ax,%ax

00801c60 <__umoddi3>:
  801c60:	55                   	push   %ebp
  801c61:	57                   	push   %edi
  801c62:	56                   	push   %esi
  801c63:	53                   	push   %ebx
  801c64:	83 ec 1c             	sub    $0x1c,%esp
  801c67:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801c6b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801c6f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801c73:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c77:	85 d2                	test   %edx,%edx
  801c79:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801c7d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c81:	89 f3                	mov    %esi,%ebx
  801c83:	89 3c 24             	mov    %edi,(%esp)
  801c86:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c8a:	75 1c                	jne    801ca8 <__umoddi3+0x48>
  801c8c:	39 f7                	cmp    %esi,%edi
  801c8e:	76 50                	jbe    801ce0 <__umoddi3+0x80>
  801c90:	89 c8                	mov    %ecx,%eax
  801c92:	89 f2                	mov    %esi,%edx
  801c94:	f7 f7                	div    %edi
  801c96:	89 d0                	mov    %edx,%eax
  801c98:	31 d2                	xor    %edx,%edx
  801c9a:	83 c4 1c             	add    $0x1c,%esp
  801c9d:	5b                   	pop    %ebx
  801c9e:	5e                   	pop    %esi
  801c9f:	5f                   	pop    %edi
  801ca0:	5d                   	pop    %ebp
  801ca1:	c3                   	ret    
  801ca2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ca8:	39 f2                	cmp    %esi,%edx
  801caa:	89 d0                	mov    %edx,%eax
  801cac:	77 52                	ja     801d00 <__umoddi3+0xa0>
  801cae:	0f bd ea             	bsr    %edx,%ebp
  801cb1:	83 f5 1f             	xor    $0x1f,%ebp
  801cb4:	75 5a                	jne    801d10 <__umoddi3+0xb0>
  801cb6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801cba:	0f 82 e0 00 00 00    	jb     801da0 <__umoddi3+0x140>
  801cc0:	39 0c 24             	cmp    %ecx,(%esp)
  801cc3:	0f 86 d7 00 00 00    	jbe    801da0 <__umoddi3+0x140>
  801cc9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ccd:	8b 54 24 04          	mov    0x4(%esp),%edx
  801cd1:	83 c4 1c             	add    $0x1c,%esp
  801cd4:	5b                   	pop    %ebx
  801cd5:	5e                   	pop    %esi
  801cd6:	5f                   	pop    %edi
  801cd7:	5d                   	pop    %ebp
  801cd8:	c3                   	ret    
  801cd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ce0:	85 ff                	test   %edi,%edi
  801ce2:	89 fd                	mov    %edi,%ebp
  801ce4:	75 0b                	jne    801cf1 <__umoddi3+0x91>
  801ce6:	b8 01 00 00 00       	mov    $0x1,%eax
  801ceb:	31 d2                	xor    %edx,%edx
  801ced:	f7 f7                	div    %edi
  801cef:	89 c5                	mov    %eax,%ebp
  801cf1:	89 f0                	mov    %esi,%eax
  801cf3:	31 d2                	xor    %edx,%edx
  801cf5:	f7 f5                	div    %ebp
  801cf7:	89 c8                	mov    %ecx,%eax
  801cf9:	f7 f5                	div    %ebp
  801cfb:	89 d0                	mov    %edx,%eax
  801cfd:	eb 99                	jmp    801c98 <__umoddi3+0x38>
  801cff:	90                   	nop
  801d00:	89 c8                	mov    %ecx,%eax
  801d02:	89 f2                	mov    %esi,%edx
  801d04:	83 c4 1c             	add    $0x1c,%esp
  801d07:	5b                   	pop    %ebx
  801d08:	5e                   	pop    %esi
  801d09:	5f                   	pop    %edi
  801d0a:	5d                   	pop    %ebp
  801d0b:	c3                   	ret    
  801d0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d10:	8b 34 24             	mov    (%esp),%esi
  801d13:	bf 20 00 00 00       	mov    $0x20,%edi
  801d18:	89 e9                	mov    %ebp,%ecx
  801d1a:	29 ef                	sub    %ebp,%edi
  801d1c:	d3 e0                	shl    %cl,%eax
  801d1e:	89 f9                	mov    %edi,%ecx
  801d20:	89 f2                	mov    %esi,%edx
  801d22:	d3 ea                	shr    %cl,%edx
  801d24:	89 e9                	mov    %ebp,%ecx
  801d26:	09 c2                	or     %eax,%edx
  801d28:	89 d8                	mov    %ebx,%eax
  801d2a:	89 14 24             	mov    %edx,(%esp)
  801d2d:	89 f2                	mov    %esi,%edx
  801d2f:	d3 e2                	shl    %cl,%edx
  801d31:	89 f9                	mov    %edi,%ecx
  801d33:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d37:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801d3b:	d3 e8                	shr    %cl,%eax
  801d3d:	89 e9                	mov    %ebp,%ecx
  801d3f:	89 c6                	mov    %eax,%esi
  801d41:	d3 e3                	shl    %cl,%ebx
  801d43:	89 f9                	mov    %edi,%ecx
  801d45:	89 d0                	mov    %edx,%eax
  801d47:	d3 e8                	shr    %cl,%eax
  801d49:	89 e9                	mov    %ebp,%ecx
  801d4b:	09 d8                	or     %ebx,%eax
  801d4d:	89 d3                	mov    %edx,%ebx
  801d4f:	89 f2                	mov    %esi,%edx
  801d51:	f7 34 24             	divl   (%esp)
  801d54:	89 d6                	mov    %edx,%esi
  801d56:	d3 e3                	shl    %cl,%ebx
  801d58:	f7 64 24 04          	mull   0x4(%esp)
  801d5c:	39 d6                	cmp    %edx,%esi
  801d5e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d62:	89 d1                	mov    %edx,%ecx
  801d64:	89 c3                	mov    %eax,%ebx
  801d66:	72 08                	jb     801d70 <__umoddi3+0x110>
  801d68:	75 11                	jne    801d7b <__umoddi3+0x11b>
  801d6a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801d6e:	73 0b                	jae    801d7b <__umoddi3+0x11b>
  801d70:	2b 44 24 04          	sub    0x4(%esp),%eax
  801d74:	1b 14 24             	sbb    (%esp),%edx
  801d77:	89 d1                	mov    %edx,%ecx
  801d79:	89 c3                	mov    %eax,%ebx
  801d7b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801d7f:	29 da                	sub    %ebx,%edx
  801d81:	19 ce                	sbb    %ecx,%esi
  801d83:	89 f9                	mov    %edi,%ecx
  801d85:	89 f0                	mov    %esi,%eax
  801d87:	d3 e0                	shl    %cl,%eax
  801d89:	89 e9                	mov    %ebp,%ecx
  801d8b:	d3 ea                	shr    %cl,%edx
  801d8d:	89 e9                	mov    %ebp,%ecx
  801d8f:	d3 ee                	shr    %cl,%esi
  801d91:	09 d0                	or     %edx,%eax
  801d93:	89 f2                	mov    %esi,%edx
  801d95:	83 c4 1c             	add    $0x1c,%esp
  801d98:	5b                   	pop    %ebx
  801d99:	5e                   	pop    %esi
  801d9a:	5f                   	pop    %edi
  801d9b:	5d                   	pop    %ebp
  801d9c:	c3                   	ret    
  801d9d:	8d 76 00             	lea    0x0(%esi),%esi
  801da0:	29 f9                	sub    %edi,%ecx
  801da2:	19 d6                	sbb    %edx,%esi
  801da4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801da8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801dac:	e9 18 ff ff ff       	jmp    801cc9 <__umoddi3+0x69>
