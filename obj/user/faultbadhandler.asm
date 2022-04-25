
obj/user/faultbadhandler.debug:     file format elf32-i386


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
  80002c:	e8 34 00 00 00       	call   800065 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  800039:	6a 07                	push   $0x7
  80003b:	68 00 f0 bf ee       	push   $0xeebff000
  800040:	6a 00                	push   $0x0
  800042:	e8 3a 01 00 00       	call   800181 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xDeadBeef);
  800047:	83 c4 08             	add    $0x8,%esp
  80004a:	68 ef be ad de       	push   $0xdeadbeef
  80004f:	6a 00                	push   $0x0
  800051:	e8 76 02 00 00       	call   8002cc <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800056:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80005d:	00 00 00 
}
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	c9                   	leave  
  800064:	c3                   	ret    

00800065 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800065:	55                   	push   %ebp
  800066:	89 e5                	mov    %esp,%ebp
  800068:	56                   	push   %esi
  800069:	53                   	push   %ebx
  80006a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80006d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  800070:	e8 ce 00 00 00       	call   800143 <sys_getenvid>
  800075:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80007d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800082:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800087:	85 db                	test   %ebx,%ebx
  800089:	7e 07                	jle    800092 <libmain+0x2d>
		binaryname = argv[0];
  80008b:	8b 06                	mov    (%esi),%eax
  80008d:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800092:	83 ec 08             	sub    $0x8,%esp
  800095:	56                   	push   %esi
  800096:	53                   	push   %ebx
  800097:	e8 97 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80009c:	e8 0a 00 00 00       	call   8000ab <exit>
}
  8000a1:	83 c4 10             	add    $0x10,%esp
  8000a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a7:	5b                   	pop    %ebx
  8000a8:	5e                   	pop    %esi
  8000a9:	5d                   	pop    %ebp
  8000aa:	c3                   	ret    

008000ab <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ab:	55                   	push   %ebp
  8000ac:	89 e5                	mov    %esp,%ebp
  8000ae:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000b1:	e8 87 04 00 00       	call   80053d <close_all>
	sys_env_destroy(0);
  8000b6:	83 ec 0c             	sub    $0xc,%esp
  8000b9:	6a 00                	push   $0x0
  8000bb:	e8 42 00 00 00       	call   800102 <sys_env_destroy>
}
  8000c0:	83 c4 10             	add    $0x10,%esp
  8000c3:	c9                   	leave  
  8000c4:	c3                   	ret    

008000c5 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c5:	55                   	push   %ebp
  8000c6:	89 e5                	mov    %esp,%ebp
  8000c8:	57                   	push   %edi
  8000c9:	56                   	push   %esi
  8000ca:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d6:	89 c3                	mov    %eax,%ebx
  8000d8:	89 c7                	mov    %eax,%edi
  8000da:	89 c6                	mov    %eax,%esi
  8000dc:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000de:	5b                   	pop    %ebx
  8000df:	5e                   	pop    %esi
  8000e0:	5f                   	pop    %edi
  8000e1:	5d                   	pop    %ebp
  8000e2:	c3                   	ret    

008000e3 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e3:	55                   	push   %ebp
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	57                   	push   %edi
  8000e7:	56                   	push   %esi
  8000e8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ee:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f3:	89 d1                	mov    %edx,%ecx
  8000f5:	89 d3                	mov    %edx,%ebx
  8000f7:	89 d7                	mov    %edx,%edi
  8000f9:	89 d6                	mov    %edx,%esi
  8000fb:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000fd:	5b                   	pop    %ebx
  8000fe:	5e                   	pop    %esi
  8000ff:	5f                   	pop    %edi
  800100:	5d                   	pop    %ebp
  800101:	c3                   	ret    

00800102 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800102:	55                   	push   %ebp
  800103:	89 e5                	mov    %esp,%ebp
  800105:	57                   	push   %edi
  800106:	56                   	push   %esi
  800107:	53                   	push   %ebx
  800108:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80010b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800110:	b8 03 00 00 00       	mov    $0x3,%eax
  800115:	8b 55 08             	mov    0x8(%ebp),%edx
  800118:	89 cb                	mov    %ecx,%ebx
  80011a:	89 cf                	mov    %ecx,%edi
  80011c:	89 ce                	mov    %ecx,%esi
  80011e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800120:	85 c0                	test   %eax,%eax
  800122:	7e 17                	jle    80013b <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800124:	83 ec 0c             	sub    $0xc,%esp
  800127:	50                   	push   %eax
  800128:	6a 03                	push   $0x3
  80012a:	68 ea 1d 80 00       	push   $0x801dea
  80012f:	6a 23                	push   $0x23
  800131:	68 07 1e 80 00       	push   $0x801e07
  800136:	e8 21 0f 00 00       	call   80105c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80013b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80013e:	5b                   	pop    %ebx
  80013f:	5e                   	pop    %esi
  800140:	5f                   	pop    %edi
  800141:	5d                   	pop    %ebp
  800142:	c3                   	ret    

00800143 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	57                   	push   %edi
  800147:	56                   	push   %esi
  800148:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800149:	ba 00 00 00 00       	mov    $0x0,%edx
  80014e:	b8 02 00 00 00       	mov    $0x2,%eax
  800153:	89 d1                	mov    %edx,%ecx
  800155:	89 d3                	mov    %edx,%ebx
  800157:	89 d7                	mov    %edx,%edi
  800159:	89 d6                	mov    %edx,%esi
  80015b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80015d:	5b                   	pop    %ebx
  80015e:	5e                   	pop    %esi
  80015f:	5f                   	pop    %edi
  800160:	5d                   	pop    %ebp
  800161:	c3                   	ret    

00800162 <sys_yield>:

void
sys_yield(void)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	57                   	push   %edi
  800166:	56                   	push   %esi
  800167:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800168:	ba 00 00 00 00       	mov    $0x0,%edx
  80016d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800172:	89 d1                	mov    %edx,%ecx
  800174:	89 d3                	mov    %edx,%ebx
  800176:	89 d7                	mov    %edx,%edi
  800178:	89 d6                	mov    %edx,%esi
  80017a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80017c:	5b                   	pop    %ebx
  80017d:	5e                   	pop    %esi
  80017e:	5f                   	pop    %edi
  80017f:	5d                   	pop    %ebp
  800180:	c3                   	ret    

00800181 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800181:	55                   	push   %ebp
  800182:	89 e5                	mov    %esp,%ebp
  800184:	57                   	push   %edi
  800185:	56                   	push   %esi
  800186:	53                   	push   %ebx
  800187:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80018a:	be 00 00 00 00       	mov    $0x0,%esi
  80018f:	b8 04 00 00 00       	mov    $0x4,%eax
  800194:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800197:	8b 55 08             	mov    0x8(%ebp),%edx
  80019a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80019d:	89 f7                	mov    %esi,%edi
  80019f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001a1:	85 c0                	test   %eax,%eax
  8001a3:	7e 17                	jle    8001bc <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001a5:	83 ec 0c             	sub    $0xc,%esp
  8001a8:	50                   	push   %eax
  8001a9:	6a 04                	push   $0x4
  8001ab:	68 ea 1d 80 00       	push   $0x801dea
  8001b0:	6a 23                	push   $0x23
  8001b2:	68 07 1e 80 00       	push   $0x801e07
  8001b7:	e8 a0 0e 00 00       	call   80105c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001bf:	5b                   	pop    %ebx
  8001c0:	5e                   	pop    %esi
  8001c1:	5f                   	pop    %edi
  8001c2:	5d                   	pop    %ebp
  8001c3:	c3                   	ret    

008001c4 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	57                   	push   %edi
  8001c8:	56                   	push   %esi
  8001c9:	53                   	push   %ebx
  8001ca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001cd:	b8 05 00 00 00       	mov    $0x5,%eax
  8001d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001d5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001db:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001de:	8b 75 18             	mov    0x18(%ebp),%esi
  8001e1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001e3:	85 c0                	test   %eax,%eax
  8001e5:	7e 17                	jle    8001fe <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001e7:	83 ec 0c             	sub    $0xc,%esp
  8001ea:	50                   	push   %eax
  8001eb:	6a 05                	push   $0x5
  8001ed:	68 ea 1d 80 00       	push   $0x801dea
  8001f2:	6a 23                	push   $0x23
  8001f4:	68 07 1e 80 00       	push   $0x801e07
  8001f9:	e8 5e 0e 00 00       	call   80105c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800201:	5b                   	pop    %ebx
  800202:	5e                   	pop    %esi
  800203:	5f                   	pop    %edi
  800204:	5d                   	pop    %ebp
  800205:	c3                   	ret    

00800206 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800206:	55                   	push   %ebp
  800207:	89 e5                	mov    %esp,%ebp
  800209:	57                   	push   %edi
  80020a:	56                   	push   %esi
  80020b:	53                   	push   %ebx
  80020c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80020f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800214:	b8 06 00 00 00       	mov    $0x6,%eax
  800219:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80021c:	8b 55 08             	mov    0x8(%ebp),%edx
  80021f:	89 df                	mov    %ebx,%edi
  800221:	89 de                	mov    %ebx,%esi
  800223:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800225:	85 c0                	test   %eax,%eax
  800227:	7e 17                	jle    800240 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800229:	83 ec 0c             	sub    $0xc,%esp
  80022c:	50                   	push   %eax
  80022d:	6a 06                	push   $0x6
  80022f:	68 ea 1d 80 00       	push   $0x801dea
  800234:	6a 23                	push   $0x23
  800236:	68 07 1e 80 00       	push   $0x801e07
  80023b:	e8 1c 0e 00 00       	call   80105c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800240:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800243:	5b                   	pop    %ebx
  800244:	5e                   	pop    %esi
  800245:	5f                   	pop    %edi
  800246:	5d                   	pop    %ebp
  800247:	c3                   	ret    

00800248 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
  80024b:	57                   	push   %edi
  80024c:	56                   	push   %esi
  80024d:	53                   	push   %ebx
  80024e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800251:	bb 00 00 00 00       	mov    $0x0,%ebx
  800256:	b8 08 00 00 00       	mov    $0x8,%eax
  80025b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80025e:	8b 55 08             	mov    0x8(%ebp),%edx
  800261:	89 df                	mov    %ebx,%edi
  800263:	89 de                	mov    %ebx,%esi
  800265:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800267:	85 c0                	test   %eax,%eax
  800269:	7e 17                	jle    800282 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80026b:	83 ec 0c             	sub    $0xc,%esp
  80026e:	50                   	push   %eax
  80026f:	6a 08                	push   $0x8
  800271:	68 ea 1d 80 00       	push   $0x801dea
  800276:	6a 23                	push   $0x23
  800278:	68 07 1e 80 00       	push   $0x801e07
  80027d:	e8 da 0d 00 00       	call   80105c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800282:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800285:	5b                   	pop    %ebx
  800286:	5e                   	pop    %esi
  800287:	5f                   	pop    %edi
  800288:	5d                   	pop    %ebp
  800289:	c3                   	ret    

0080028a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	57                   	push   %edi
  80028e:	56                   	push   %esi
  80028f:	53                   	push   %ebx
  800290:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800293:	bb 00 00 00 00       	mov    $0x0,%ebx
  800298:	b8 09 00 00 00       	mov    $0x9,%eax
  80029d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a3:	89 df                	mov    %ebx,%edi
  8002a5:	89 de                	mov    %ebx,%esi
  8002a7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002a9:	85 c0                	test   %eax,%eax
  8002ab:	7e 17                	jle    8002c4 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ad:	83 ec 0c             	sub    $0xc,%esp
  8002b0:	50                   	push   %eax
  8002b1:	6a 09                	push   $0x9
  8002b3:	68 ea 1d 80 00       	push   $0x801dea
  8002b8:	6a 23                	push   $0x23
  8002ba:	68 07 1e 80 00       	push   $0x801e07
  8002bf:	e8 98 0d 00 00       	call   80105c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c7:	5b                   	pop    %ebx
  8002c8:	5e                   	pop    %esi
  8002c9:	5f                   	pop    %edi
  8002ca:	5d                   	pop    %ebp
  8002cb:	c3                   	ret    

008002cc <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	57                   	push   %edi
  8002d0:	56                   	push   %esi
  8002d1:	53                   	push   %ebx
  8002d2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002d5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002da:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e5:	89 df                	mov    %ebx,%edi
  8002e7:	89 de                	mov    %ebx,%esi
  8002e9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002eb:	85 c0                	test   %eax,%eax
  8002ed:	7e 17                	jle    800306 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ef:	83 ec 0c             	sub    $0xc,%esp
  8002f2:	50                   	push   %eax
  8002f3:	6a 0a                	push   $0xa
  8002f5:	68 ea 1d 80 00       	push   $0x801dea
  8002fa:	6a 23                	push   $0x23
  8002fc:	68 07 1e 80 00       	push   $0x801e07
  800301:	e8 56 0d 00 00       	call   80105c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800306:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800309:	5b                   	pop    %ebx
  80030a:	5e                   	pop    %esi
  80030b:	5f                   	pop    %edi
  80030c:	5d                   	pop    %ebp
  80030d:	c3                   	ret    

0080030e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
  800311:	57                   	push   %edi
  800312:	56                   	push   %esi
  800313:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800314:	be 00 00 00 00       	mov    $0x0,%esi
  800319:	b8 0c 00 00 00       	mov    $0xc,%eax
  80031e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800321:	8b 55 08             	mov    0x8(%ebp),%edx
  800324:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800327:	8b 7d 14             	mov    0x14(%ebp),%edi
  80032a:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80032c:	5b                   	pop    %ebx
  80032d:	5e                   	pop    %esi
  80032e:	5f                   	pop    %edi
  80032f:	5d                   	pop    %ebp
  800330:	c3                   	ret    

00800331 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800331:	55                   	push   %ebp
  800332:	89 e5                	mov    %esp,%ebp
  800334:	57                   	push   %edi
  800335:	56                   	push   %esi
  800336:	53                   	push   %ebx
  800337:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80033a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80033f:	b8 0d 00 00 00       	mov    $0xd,%eax
  800344:	8b 55 08             	mov    0x8(%ebp),%edx
  800347:	89 cb                	mov    %ecx,%ebx
  800349:	89 cf                	mov    %ecx,%edi
  80034b:	89 ce                	mov    %ecx,%esi
  80034d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80034f:	85 c0                	test   %eax,%eax
  800351:	7e 17                	jle    80036a <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800353:	83 ec 0c             	sub    $0xc,%esp
  800356:	50                   	push   %eax
  800357:	6a 0d                	push   $0xd
  800359:	68 ea 1d 80 00       	push   $0x801dea
  80035e:	6a 23                	push   $0x23
  800360:	68 07 1e 80 00       	push   $0x801e07
  800365:	e8 f2 0c 00 00       	call   80105c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80036a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80036d:	5b                   	pop    %ebx
  80036e:	5e                   	pop    %esi
  80036f:	5f                   	pop    %edi
  800370:	5d                   	pop    %ebp
  800371:	c3                   	ret    

00800372 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800372:	55                   	push   %ebp
  800373:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800375:	8b 45 08             	mov    0x8(%ebp),%eax
  800378:	05 00 00 00 30       	add    $0x30000000,%eax
  80037d:	c1 e8 0c             	shr    $0xc,%eax
}
  800380:	5d                   	pop    %ebp
  800381:	c3                   	ret    

00800382 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800382:	55                   	push   %ebp
  800383:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800385:	8b 45 08             	mov    0x8(%ebp),%eax
  800388:	05 00 00 00 30       	add    $0x30000000,%eax
  80038d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800392:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800397:	5d                   	pop    %ebp
  800398:	c3                   	ret    

00800399 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800399:	55                   	push   %ebp
  80039a:	89 e5                	mov    %esp,%ebp
  80039c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80039f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003a4:	89 c2                	mov    %eax,%edx
  8003a6:	c1 ea 16             	shr    $0x16,%edx
  8003a9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003b0:	f6 c2 01             	test   $0x1,%dl
  8003b3:	74 11                	je     8003c6 <fd_alloc+0x2d>
  8003b5:	89 c2                	mov    %eax,%edx
  8003b7:	c1 ea 0c             	shr    $0xc,%edx
  8003ba:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003c1:	f6 c2 01             	test   $0x1,%dl
  8003c4:	75 09                	jne    8003cf <fd_alloc+0x36>
			*fd_store = fd;
  8003c6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8003cd:	eb 17                	jmp    8003e6 <fd_alloc+0x4d>
  8003cf:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003d4:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003d9:	75 c9                	jne    8003a4 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003db:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003e1:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003e6:	5d                   	pop    %ebp
  8003e7:	c3                   	ret    

008003e8 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003e8:	55                   	push   %ebp
  8003e9:	89 e5                	mov    %esp,%ebp
  8003eb:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003ee:	83 f8 1f             	cmp    $0x1f,%eax
  8003f1:	77 36                	ja     800429 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003f3:	c1 e0 0c             	shl    $0xc,%eax
  8003f6:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003fb:	89 c2                	mov    %eax,%edx
  8003fd:	c1 ea 16             	shr    $0x16,%edx
  800400:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800407:	f6 c2 01             	test   $0x1,%dl
  80040a:	74 24                	je     800430 <fd_lookup+0x48>
  80040c:	89 c2                	mov    %eax,%edx
  80040e:	c1 ea 0c             	shr    $0xc,%edx
  800411:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800418:	f6 c2 01             	test   $0x1,%dl
  80041b:	74 1a                	je     800437 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80041d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800420:	89 02                	mov    %eax,(%edx)
	return 0;
  800422:	b8 00 00 00 00       	mov    $0x0,%eax
  800427:	eb 13                	jmp    80043c <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800429:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80042e:	eb 0c                	jmp    80043c <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800430:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800435:	eb 05                	jmp    80043c <fd_lookup+0x54>
  800437:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80043c:	5d                   	pop    %ebp
  80043d:	c3                   	ret    

0080043e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80043e:	55                   	push   %ebp
  80043f:	89 e5                	mov    %esp,%ebp
  800441:	83 ec 08             	sub    $0x8,%esp
  800444:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800447:	ba 94 1e 80 00       	mov    $0x801e94,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80044c:	eb 13                	jmp    800461 <dev_lookup+0x23>
  80044e:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800451:	39 08                	cmp    %ecx,(%eax)
  800453:	75 0c                	jne    800461 <dev_lookup+0x23>
			*dev = devtab[i];
  800455:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800458:	89 01                	mov    %eax,(%ecx)
			return 0;
  80045a:	b8 00 00 00 00       	mov    $0x0,%eax
  80045f:	eb 2e                	jmp    80048f <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800461:	8b 02                	mov    (%edx),%eax
  800463:	85 c0                	test   %eax,%eax
  800465:	75 e7                	jne    80044e <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800467:	a1 04 40 80 00       	mov    0x804004,%eax
  80046c:	8b 40 48             	mov    0x48(%eax),%eax
  80046f:	83 ec 04             	sub    $0x4,%esp
  800472:	51                   	push   %ecx
  800473:	50                   	push   %eax
  800474:	68 18 1e 80 00       	push   $0x801e18
  800479:	e8 b7 0c 00 00       	call   801135 <cprintf>
	*dev = 0;
  80047e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800481:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800487:	83 c4 10             	add    $0x10,%esp
  80048a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80048f:	c9                   	leave  
  800490:	c3                   	ret    

00800491 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800491:	55                   	push   %ebp
  800492:	89 e5                	mov    %esp,%ebp
  800494:	56                   	push   %esi
  800495:	53                   	push   %ebx
  800496:	83 ec 10             	sub    $0x10,%esp
  800499:	8b 75 08             	mov    0x8(%ebp),%esi
  80049c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80049f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004a2:	50                   	push   %eax
  8004a3:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004a9:	c1 e8 0c             	shr    $0xc,%eax
  8004ac:	50                   	push   %eax
  8004ad:	e8 36 ff ff ff       	call   8003e8 <fd_lookup>
  8004b2:	83 c4 08             	add    $0x8,%esp
  8004b5:	85 c0                	test   %eax,%eax
  8004b7:	78 05                	js     8004be <fd_close+0x2d>
	    || fd != fd2)
  8004b9:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004bc:	74 0c                	je     8004ca <fd_close+0x39>
		return (must_exist ? r : 0);
  8004be:	84 db                	test   %bl,%bl
  8004c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8004c5:	0f 44 c2             	cmove  %edx,%eax
  8004c8:	eb 41                	jmp    80050b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004ca:	83 ec 08             	sub    $0x8,%esp
  8004cd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004d0:	50                   	push   %eax
  8004d1:	ff 36                	pushl  (%esi)
  8004d3:	e8 66 ff ff ff       	call   80043e <dev_lookup>
  8004d8:	89 c3                	mov    %eax,%ebx
  8004da:	83 c4 10             	add    $0x10,%esp
  8004dd:	85 c0                	test   %eax,%eax
  8004df:	78 1a                	js     8004fb <fd_close+0x6a>
		if (dev->dev_close)
  8004e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004e4:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004e7:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004ec:	85 c0                	test   %eax,%eax
  8004ee:	74 0b                	je     8004fb <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004f0:	83 ec 0c             	sub    $0xc,%esp
  8004f3:	56                   	push   %esi
  8004f4:	ff d0                	call   *%eax
  8004f6:	89 c3                	mov    %eax,%ebx
  8004f8:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004fb:	83 ec 08             	sub    $0x8,%esp
  8004fe:	56                   	push   %esi
  8004ff:	6a 00                	push   $0x0
  800501:	e8 00 fd ff ff       	call   800206 <sys_page_unmap>
	return r;
  800506:	83 c4 10             	add    $0x10,%esp
  800509:	89 d8                	mov    %ebx,%eax
}
  80050b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80050e:	5b                   	pop    %ebx
  80050f:	5e                   	pop    %esi
  800510:	5d                   	pop    %ebp
  800511:	c3                   	ret    

00800512 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800512:	55                   	push   %ebp
  800513:	89 e5                	mov    %esp,%ebp
  800515:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800518:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80051b:	50                   	push   %eax
  80051c:	ff 75 08             	pushl  0x8(%ebp)
  80051f:	e8 c4 fe ff ff       	call   8003e8 <fd_lookup>
  800524:	83 c4 08             	add    $0x8,%esp
  800527:	85 c0                	test   %eax,%eax
  800529:	78 10                	js     80053b <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80052b:	83 ec 08             	sub    $0x8,%esp
  80052e:	6a 01                	push   $0x1
  800530:	ff 75 f4             	pushl  -0xc(%ebp)
  800533:	e8 59 ff ff ff       	call   800491 <fd_close>
  800538:	83 c4 10             	add    $0x10,%esp
}
  80053b:	c9                   	leave  
  80053c:	c3                   	ret    

0080053d <close_all>:

void
close_all(void)
{
  80053d:	55                   	push   %ebp
  80053e:	89 e5                	mov    %esp,%ebp
  800540:	53                   	push   %ebx
  800541:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800544:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800549:	83 ec 0c             	sub    $0xc,%esp
  80054c:	53                   	push   %ebx
  80054d:	e8 c0 ff ff ff       	call   800512 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800552:	83 c3 01             	add    $0x1,%ebx
  800555:	83 c4 10             	add    $0x10,%esp
  800558:	83 fb 20             	cmp    $0x20,%ebx
  80055b:	75 ec                	jne    800549 <close_all+0xc>
		close(i);
}
  80055d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800560:	c9                   	leave  
  800561:	c3                   	ret    

00800562 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800562:	55                   	push   %ebp
  800563:	89 e5                	mov    %esp,%ebp
  800565:	57                   	push   %edi
  800566:	56                   	push   %esi
  800567:	53                   	push   %ebx
  800568:	83 ec 2c             	sub    $0x2c,%esp
  80056b:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80056e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800571:	50                   	push   %eax
  800572:	ff 75 08             	pushl  0x8(%ebp)
  800575:	e8 6e fe ff ff       	call   8003e8 <fd_lookup>
  80057a:	83 c4 08             	add    $0x8,%esp
  80057d:	85 c0                	test   %eax,%eax
  80057f:	0f 88 c1 00 00 00    	js     800646 <dup+0xe4>
		return r;
	close(newfdnum);
  800585:	83 ec 0c             	sub    $0xc,%esp
  800588:	56                   	push   %esi
  800589:	e8 84 ff ff ff       	call   800512 <close>

	newfd = INDEX2FD(newfdnum);
  80058e:	89 f3                	mov    %esi,%ebx
  800590:	c1 e3 0c             	shl    $0xc,%ebx
  800593:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800599:	83 c4 04             	add    $0x4,%esp
  80059c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80059f:	e8 de fd ff ff       	call   800382 <fd2data>
  8005a4:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005a6:	89 1c 24             	mov    %ebx,(%esp)
  8005a9:	e8 d4 fd ff ff       	call   800382 <fd2data>
  8005ae:	83 c4 10             	add    $0x10,%esp
  8005b1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005b4:	89 f8                	mov    %edi,%eax
  8005b6:	c1 e8 16             	shr    $0x16,%eax
  8005b9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005c0:	a8 01                	test   $0x1,%al
  8005c2:	74 37                	je     8005fb <dup+0x99>
  8005c4:	89 f8                	mov    %edi,%eax
  8005c6:	c1 e8 0c             	shr    $0xc,%eax
  8005c9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005d0:	f6 c2 01             	test   $0x1,%dl
  8005d3:	74 26                	je     8005fb <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005d5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005dc:	83 ec 0c             	sub    $0xc,%esp
  8005df:	25 07 0e 00 00       	and    $0xe07,%eax
  8005e4:	50                   	push   %eax
  8005e5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005e8:	6a 00                	push   $0x0
  8005ea:	57                   	push   %edi
  8005eb:	6a 00                	push   $0x0
  8005ed:	e8 d2 fb ff ff       	call   8001c4 <sys_page_map>
  8005f2:	89 c7                	mov    %eax,%edi
  8005f4:	83 c4 20             	add    $0x20,%esp
  8005f7:	85 c0                	test   %eax,%eax
  8005f9:	78 2e                	js     800629 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005fb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005fe:	89 d0                	mov    %edx,%eax
  800600:	c1 e8 0c             	shr    $0xc,%eax
  800603:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80060a:	83 ec 0c             	sub    $0xc,%esp
  80060d:	25 07 0e 00 00       	and    $0xe07,%eax
  800612:	50                   	push   %eax
  800613:	53                   	push   %ebx
  800614:	6a 00                	push   $0x0
  800616:	52                   	push   %edx
  800617:	6a 00                	push   $0x0
  800619:	e8 a6 fb ff ff       	call   8001c4 <sys_page_map>
  80061e:	89 c7                	mov    %eax,%edi
  800620:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800623:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800625:	85 ff                	test   %edi,%edi
  800627:	79 1d                	jns    800646 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800629:	83 ec 08             	sub    $0x8,%esp
  80062c:	53                   	push   %ebx
  80062d:	6a 00                	push   $0x0
  80062f:	e8 d2 fb ff ff       	call   800206 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800634:	83 c4 08             	add    $0x8,%esp
  800637:	ff 75 d4             	pushl  -0x2c(%ebp)
  80063a:	6a 00                	push   $0x0
  80063c:	e8 c5 fb ff ff       	call   800206 <sys_page_unmap>
	return r;
  800641:	83 c4 10             	add    $0x10,%esp
  800644:	89 f8                	mov    %edi,%eax
}
  800646:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800649:	5b                   	pop    %ebx
  80064a:	5e                   	pop    %esi
  80064b:	5f                   	pop    %edi
  80064c:	5d                   	pop    %ebp
  80064d:	c3                   	ret    

0080064e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80064e:	55                   	push   %ebp
  80064f:	89 e5                	mov    %esp,%ebp
  800651:	53                   	push   %ebx
  800652:	83 ec 14             	sub    $0x14,%esp
  800655:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800658:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80065b:	50                   	push   %eax
  80065c:	53                   	push   %ebx
  80065d:	e8 86 fd ff ff       	call   8003e8 <fd_lookup>
  800662:	83 c4 08             	add    $0x8,%esp
  800665:	89 c2                	mov    %eax,%edx
  800667:	85 c0                	test   %eax,%eax
  800669:	78 6d                	js     8006d8 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80066b:	83 ec 08             	sub    $0x8,%esp
  80066e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800671:	50                   	push   %eax
  800672:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800675:	ff 30                	pushl  (%eax)
  800677:	e8 c2 fd ff ff       	call   80043e <dev_lookup>
  80067c:	83 c4 10             	add    $0x10,%esp
  80067f:	85 c0                	test   %eax,%eax
  800681:	78 4c                	js     8006cf <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800683:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800686:	8b 42 08             	mov    0x8(%edx),%eax
  800689:	83 e0 03             	and    $0x3,%eax
  80068c:	83 f8 01             	cmp    $0x1,%eax
  80068f:	75 21                	jne    8006b2 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800691:	a1 04 40 80 00       	mov    0x804004,%eax
  800696:	8b 40 48             	mov    0x48(%eax),%eax
  800699:	83 ec 04             	sub    $0x4,%esp
  80069c:	53                   	push   %ebx
  80069d:	50                   	push   %eax
  80069e:	68 59 1e 80 00       	push   $0x801e59
  8006a3:	e8 8d 0a 00 00       	call   801135 <cprintf>
		return -E_INVAL;
  8006a8:	83 c4 10             	add    $0x10,%esp
  8006ab:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006b0:	eb 26                	jmp    8006d8 <read+0x8a>
	}
	if (!dev->dev_read)
  8006b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006b5:	8b 40 08             	mov    0x8(%eax),%eax
  8006b8:	85 c0                	test   %eax,%eax
  8006ba:	74 17                	je     8006d3 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006bc:	83 ec 04             	sub    $0x4,%esp
  8006bf:	ff 75 10             	pushl  0x10(%ebp)
  8006c2:	ff 75 0c             	pushl  0xc(%ebp)
  8006c5:	52                   	push   %edx
  8006c6:	ff d0                	call   *%eax
  8006c8:	89 c2                	mov    %eax,%edx
  8006ca:	83 c4 10             	add    $0x10,%esp
  8006cd:	eb 09                	jmp    8006d8 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006cf:	89 c2                	mov    %eax,%edx
  8006d1:	eb 05                	jmp    8006d8 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006d3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006d8:	89 d0                	mov    %edx,%eax
  8006da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006dd:	c9                   	leave  
  8006de:	c3                   	ret    

008006df <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006df:	55                   	push   %ebp
  8006e0:	89 e5                	mov    %esp,%ebp
  8006e2:	57                   	push   %edi
  8006e3:	56                   	push   %esi
  8006e4:	53                   	push   %ebx
  8006e5:	83 ec 0c             	sub    $0xc,%esp
  8006e8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006eb:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006ee:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006f3:	eb 21                	jmp    800716 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006f5:	83 ec 04             	sub    $0x4,%esp
  8006f8:	89 f0                	mov    %esi,%eax
  8006fa:	29 d8                	sub    %ebx,%eax
  8006fc:	50                   	push   %eax
  8006fd:	89 d8                	mov    %ebx,%eax
  8006ff:	03 45 0c             	add    0xc(%ebp),%eax
  800702:	50                   	push   %eax
  800703:	57                   	push   %edi
  800704:	e8 45 ff ff ff       	call   80064e <read>
		if (m < 0)
  800709:	83 c4 10             	add    $0x10,%esp
  80070c:	85 c0                	test   %eax,%eax
  80070e:	78 10                	js     800720 <readn+0x41>
			return m;
		if (m == 0)
  800710:	85 c0                	test   %eax,%eax
  800712:	74 0a                	je     80071e <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800714:	01 c3                	add    %eax,%ebx
  800716:	39 f3                	cmp    %esi,%ebx
  800718:	72 db                	jb     8006f5 <readn+0x16>
  80071a:	89 d8                	mov    %ebx,%eax
  80071c:	eb 02                	jmp    800720 <readn+0x41>
  80071e:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800720:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800723:	5b                   	pop    %ebx
  800724:	5e                   	pop    %esi
  800725:	5f                   	pop    %edi
  800726:	5d                   	pop    %ebp
  800727:	c3                   	ret    

00800728 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800728:	55                   	push   %ebp
  800729:	89 e5                	mov    %esp,%ebp
  80072b:	53                   	push   %ebx
  80072c:	83 ec 14             	sub    $0x14,%esp
  80072f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800732:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800735:	50                   	push   %eax
  800736:	53                   	push   %ebx
  800737:	e8 ac fc ff ff       	call   8003e8 <fd_lookup>
  80073c:	83 c4 08             	add    $0x8,%esp
  80073f:	89 c2                	mov    %eax,%edx
  800741:	85 c0                	test   %eax,%eax
  800743:	78 68                	js     8007ad <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800745:	83 ec 08             	sub    $0x8,%esp
  800748:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80074b:	50                   	push   %eax
  80074c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80074f:	ff 30                	pushl  (%eax)
  800751:	e8 e8 fc ff ff       	call   80043e <dev_lookup>
  800756:	83 c4 10             	add    $0x10,%esp
  800759:	85 c0                	test   %eax,%eax
  80075b:	78 47                	js     8007a4 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80075d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800760:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800764:	75 21                	jne    800787 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800766:	a1 04 40 80 00       	mov    0x804004,%eax
  80076b:	8b 40 48             	mov    0x48(%eax),%eax
  80076e:	83 ec 04             	sub    $0x4,%esp
  800771:	53                   	push   %ebx
  800772:	50                   	push   %eax
  800773:	68 75 1e 80 00       	push   $0x801e75
  800778:	e8 b8 09 00 00       	call   801135 <cprintf>
		return -E_INVAL;
  80077d:	83 c4 10             	add    $0x10,%esp
  800780:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800785:	eb 26                	jmp    8007ad <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800787:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80078a:	8b 52 0c             	mov    0xc(%edx),%edx
  80078d:	85 d2                	test   %edx,%edx
  80078f:	74 17                	je     8007a8 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800791:	83 ec 04             	sub    $0x4,%esp
  800794:	ff 75 10             	pushl  0x10(%ebp)
  800797:	ff 75 0c             	pushl  0xc(%ebp)
  80079a:	50                   	push   %eax
  80079b:	ff d2                	call   *%edx
  80079d:	89 c2                	mov    %eax,%edx
  80079f:	83 c4 10             	add    $0x10,%esp
  8007a2:	eb 09                	jmp    8007ad <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007a4:	89 c2                	mov    %eax,%edx
  8007a6:	eb 05                	jmp    8007ad <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007a8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007ad:	89 d0                	mov    %edx,%eax
  8007af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b2:	c9                   	leave  
  8007b3:	c3                   	ret    

008007b4 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007ba:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007bd:	50                   	push   %eax
  8007be:	ff 75 08             	pushl  0x8(%ebp)
  8007c1:	e8 22 fc ff ff       	call   8003e8 <fd_lookup>
  8007c6:	83 c4 08             	add    $0x8,%esp
  8007c9:	85 c0                	test   %eax,%eax
  8007cb:	78 0e                	js     8007db <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007d0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d3:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007d6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007db:	c9                   	leave  
  8007dc:	c3                   	ret    

008007dd <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007dd:	55                   	push   %ebp
  8007de:	89 e5                	mov    %esp,%ebp
  8007e0:	53                   	push   %ebx
  8007e1:	83 ec 14             	sub    $0x14,%esp
  8007e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007e7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007ea:	50                   	push   %eax
  8007eb:	53                   	push   %ebx
  8007ec:	e8 f7 fb ff ff       	call   8003e8 <fd_lookup>
  8007f1:	83 c4 08             	add    $0x8,%esp
  8007f4:	89 c2                	mov    %eax,%edx
  8007f6:	85 c0                	test   %eax,%eax
  8007f8:	78 65                	js     80085f <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007fa:	83 ec 08             	sub    $0x8,%esp
  8007fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800800:	50                   	push   %eax
  800801:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800804:	ff 30                	pushl  (%eax)
  800806:	e8 33 fc ff ff       	call   80043e <dev_lookup>
  80080b:	83 c4 10             	add    $0x10,%esp
  80080e:	85 c0                	test   %eax,%eax
  800810:	78 44                	js     800856 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800812:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800815:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800819:	75 21                	jne    80083c <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80081b:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800820:	8b 40 48             	mov    0x48(%eax),%eax
  800823:	83 ec 04             	sub    $0x4,%esp
  800826:	53                   	push   %ebx
  800827:	50                   	push   %eax
  800828:	68 38 1e 80 00       	push   $0x801e38
  80082d:	e8 03 09 00 00       	call   801135 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800832:	83 c4 10             	add    $0x10,%esp
  800835:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80083a:	eb 23                	jmp    80085f <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80083c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80083f:	8b 52 18             	mov    0x18(%edx),%edx
  800842:	85 d2                	test   %edx,%edx
  800844:	74 14                	je     80085a <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800846:	83 ec 08             	sub    $0x8,%esp
  800849:	ff 75 0c             	pushl  0xc(%ebp)
  80084c:	50                   	push   %eax
  80084d:	ff d2                	call   *%edx
  80084f:	89 c2                	mov    %eax,%edx
  800851:	83 c4 10             	add    $0x10,%esp
  800854:	eb 09                	jmp    80085f <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800856:	89 c2                	mov    %eax,%edx
  800858:	eb 05                	jmp    80085f <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80085a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80085f:	89 d0                	mov    %edx,%eax
  800861:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800864:	c9                   	leave  
  800865:	c3                   	ret    

00800866 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800866:	55                   	push   %ebp
  800867:	89 e5                	mov    %esp,%ebp
  800869:	53                   	push   %ebx
  80086a:	83 ec 14             	sub    $0x14,%esp
  80086d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800870:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800873:	50                   	push   %eax
  800874:	ff 75 08             	pushl  0x8(%ebp)
  800877:	e8 6c fb ff ff       	call   8003e8 <fd_lookup>
  80087c:	83 c4 08             	add    $0x8,%esp
  80087f:	89 c2                	mov    %eax,%edx
  800881:	85 c0                	test   %eax,%eax
  800883:	78 58                	js     8008dd <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800885:	83 ec 08             	sub    $0x8,%esp
  800888:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80088b:	50                   	push   %eax
  80088c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80088f:	ff 30                	pushl  (%eax)
  800891:	e8 a8 fb ff ff       	call   80043e <dev_lookup>
  800896:	83 c4 10             	add    $0x10,%esp
  800899:	85 c0                	test   %eax,%eax
  80089b:	78 37                	js     8008d4 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80089d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008a0:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008a4:	74 32                	je     8008d8 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008a6:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008a9:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008b0:	00 00 00 
	stat->st_isdir = 0;
  8008b3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008ba:	00 00 00 
	stat->st_dev = dev;
  8008bd:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008c3:	83 ec 08             	sub    $0x8,%esp
  8008c6:	53                   	push   %ebx
  8008c7:	ff 75 f0             	pushl  -0x10(%ebp)
  8008ca:	ff 50 14             	call   *0x14(%eax)
  8008cd:	89 c2                	mov    %eax,%edx
  8008cf:	83 c4 10             	add    $0x10,%esp
  8008d2:	eb 09                	jmp    8008dd <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008d4:	89 c2                	mov    %eax,%edx
  8008d6:	eb 05                	jmp    8008dd <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008d8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008dd:	89 d0                	mov    %edx,%eax
  8008df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008e2:	c9                   	leave  
  8008e3:	c3                   	ret    

008008e4 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	56                   	push   %esi
  8008e8:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008e9:	83 ec 08             	sub    $0x8,%esp
  8008ec:	6a 00                	push   $0x0
  8008ee:	ff 75 08             	pushl  0x8(%ebp)
  8008f1:	e8 e3 01 00 00       	call   800ad9 <open>
  8008f6:	89 c3                	mov    %eax,%ebx
  8008f8:	83 c4 10             	add    $0x10,%esp
  8008fb:	85 c0                	test   %eax,%eax
  8008fd:	78 1b                	js     80091a <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008ff:	83 ec 08             	sub    $0x8,%esp
  800902:	ff 75 0c             	pushl  0xc(%ebp)
  800905:	50                   	push   %eax
  800906:	e8 5b ff ff ff       	call   800866 <fstat>
  80090b:	89 c6                	mov    %eax,%esi
	close(fd);
  80090d:	89 1c 24             	mov    %ebx,(%esp)
  800910:	e8 fd fb ff ff       	call   800512 <close>
	return r;
  800915:	83 c4 10             	add    $0x10,%esp
  800918:	89 f0                	mov    %esi,%eax
}
  80091a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80091d:	5b                   	pop    %ebx
  80091e:	5e                   	pop    %esi
  80091f:	5d                   	pop    %ebp
  800920:	c3                   	ret    

00800921 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800921:	55                   	push   %ebp
  800922:	89 e5                	mov    %esp,%ebp
  800924:	56                   	push   %esi
  800925:	53                   	push   %ebx
  800926:	89 c6                	mov    %eax,%esi
  800928:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80092a:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800931:	75 12                	jne    800945 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800933:	83 ec 0c             	sub    $0xc,%esp
  800936:	6a 01                	push   $0x1
  800938:	e8 8b 11 00 00       	call   801ac8 <ipc_find_env>
  80093d:	a3 00 40 80 00       	mov    %eax,0x804000
  800942:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800945:	6a 07                	push   $0x7
  800947:	68 00 50 80 00       	push   $0x805000
  80094c:	56                   	push   %esi
  80094d:	ff 35 00 40 80 00    	pushl  0x804000
  800953:	e8 1c 11 00 00       	call   801a74 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800958:	83 c4 0c             	add    $0xc,%esp
  80095b:	6a 00                	push   $0x0
  80095d:	53                   	push   %ebx
  80095e:	6a 00                	push   $0x0
  800960:	e8 ba 10 00 00       	call   801a1f <ipc_recv>
}
  800965:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800968:	5b                   	pop    %ebx
  800969:	5e                   	pop    %esi
  80096a:	5d                   	pop    %ebp
  80096b:	c3                   	ret    

0080096c <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80096c:	55                   	push   %ebp
  80096d:	89 e5                	mov    %esp,%ebp
  80096f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800972:	8b 45 08             	mov    0x8(%ebp),%eax
  800975:	8b 40 0c             	mov    0xc(%eax),%eax
  800978:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80097d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800980:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800985:	ba 00 00 00 00       	mov    $0x0,%edx
  80098a:	b8 02 00 00 00       	mov    $0x2,%eax
  80098f:	e8 8d ff ff ff       	call   800921 <fsipc>
}
  800994:	c9                   	leave  
  800995:	c3                   	ret    

00800996 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800996:	55                   	push   %ebp
  800997:	89 e5                	mov    %esp,%ebp
  800999:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80099c:	8b 45 08             	mov    0x8(%ebp),%eax
  80099f:	8b 40 0c             	mov    0xc(%eax),%eax
  8009a2:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ac:	b8 06 00 00 00       	mov    $0x6,%eax
  8009b1:	e8 6b ff ff ff       	call   800921 <fsipc>
}
  8009b6:	c9                   	leave  
  8009b7:	c3                   	ret    

008009b8 <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009b8:	55                   	push   %ebp
  8009b9:	89 e5                	mov    %esp,%ebp
  8009bb:	53                   	push   %ebx
  8009bc:	83 ec 04             	sub    $0x4,%esp
  8009bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c5:	8b 40 0c             	mov    0xc(%eax),%eax
  8009c8:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8009d2:	b8 05 00 00 00       	mov    $0x5,%eax
  8009d7:	e8 45 ff ff ff       	call   800921 <fsipc>
  8009dc:	85 c0                	test   %eax,%eax
  8009de:	78 2c                	js     800a0c <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009e0:	83 ec 08             	sub    $0x8,%esp
  8009e3:	68 00 50 80 00       	push   $0x805000
  8009e8:	53                   	push   %ebx
  8009e9:	e8 ea 0c 00 00       	call   8016d8 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009ee:	a1 80 50 80 00       	mov    0x805080,%eax
  8009f3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009f9:	a1 84 50 80 00       	mov    0x805084,%eax
  8009fe:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a04:	83 c4 10             	add    $0x10,%esp
  800a07:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a0c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a0f:	c9                   	leave  
  800a10:	c3                   	ret    

00800a11 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a11:	55                   	push   %ebp
  800a12:	89 e5                	mov    %esp,%ebp
  800a14:	83 ec 0c             	sub    $0xc,%esp
  800a17:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
    
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a1d:	8b 52 0c             	mov    0xc(%edx),%edx
  800a20:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = MIN(n, PGSIZE);
  800a26:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a2b:	ba 00 10 00 00       	mov    $0x1000,%edx
  800a30:	0f 47 c2             	cmova  %edx,%eax
  800a33:	a3 04 50 80 00       	mov    %eax,0x805004
    memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  800a38:	50                   	push   %eax
  800a39:	ff 75 0c             	pushl  0xc(%ebp)
  800a3c:	68 08 50 80 00       	push   $0x805008
  800a41:	e8 24 0e 00 00       	call   80186a <memmove>
    int r = fsipc(FSREQ_WRITE, NULL);
  800a46:	ba 00 00 00 00       	mov    $0x0,%edx
  800a4b:	b8 04 00 00 00       	mov    $0x4,%eax
  800a50:	e8 cc fe ff ff       	call   800921 <fsipc>
    return r;
}
  800a55:	c9                   	leave  
  800a56:	c3                   	ret    

00800a57 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a57:	55                   	push   %ebp
  800a58:	89 e5                	mov    %esp,%ebp
  800a5a:	56                   	push   %esi
  800a5b:	53                   	push   %ebx
  800a5c:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a62:	8b 40 0c             	mov    0xc(%eax),%eax
  800a65:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a6a:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a70:	ba 00 00 00 00       	mov    $0x0,%edx
  800a75:	b8 03 00 00 00       	mov    $0x3,%eax
  800a7a:	e8 a2 fe ff ff       	call   800921 <fsipc>
  800a7f:	89 c3                	mov    %eax,%ebx
  800a81:	85 c0                	test   %eax,%eax
  800a83:	78 4b                	js     800ad0 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a85:	39 c6                	cmp    %eax,%esi
  800a87:	73 16                	jae    800a9f <devfile_read+0x48>
  800a89:	68 a4 1e 80 00       	push   $0x801ea4
  800a8e:	68 ab 1e 80 00       	push   $0x801eab
  800a93:	6a 7c                	push   $0x7c
  800a95:	68 c0 1e 80 00       	push   $0x801ec0
  800a9a:	e8 bd 05 00 00       	call   80105c <_panic>
	assert(r <= PGSIZE);
  800a9f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800aa4:	7e 16                	jle    800abc <devfile_read+0x65>
  800aa6:	68 cb 1e 80 00       	push   $0x801ecb
  800aab:	68 ab 1e 80 00       	push   $0x801eab
  800ab0:	6a 7d                	push   $0x7d
  800ab2:	68 c0 1e 80 00       	push   $0x801ec0
  800ab7:	e8 a0 05 00 00       	call   80105c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800abc:	83 ec 04             	sub    $0x4,%esp
  800abf:	50                   	push   %eax
  800ac0:	68 00 50 80 00       	push   $0x805000
  800ac5:	ff 75 0c             	pushl  0xc(%ebp)
  800ac8:	e8 9d 0d 00 00       	call   80186a <memmove>
	return r;
  800acd:	83 c4 10             	add    $0x10,%esp
}
  800ad0:	89 d8                	mov    %ebx,%eax
  800ad2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ad5:	5b                   	pop    %ebx
  800ad6:	5e                   	pop    %esi
  800ad7:	5d                   	pop    %ebp
  800ad8:	c3                   	ret    

00800ad9 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800ad9:	55                   	push   %ebp
  800ada:	89 e5                	mov    %esp,%ebp
  800adc:	53                   	push   %ebx
  800add:	83 ec 20             	sub    $0x20,%esp
  800ae0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800ae3:	53                   	push   %ebx
  800ae4:	e8 b6 0b 00 00       	call   80169f <strlen>
  800ae9:	83 c4 10             	add    $0x10,%esp
  800aec:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800af1:	7f 67                	jg     800b5a <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800af3:	83 ec 0c             	sub    $0xc,%esp
  800af6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800af9:	50                   	push   %eax
  800afa:	e8 9a f8 ff ff       	call   800399 <fd_alloc>
  800aff:	83 c4 10             	add    $0x10,%esp
		return r;
  800b02:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b04:	85 c0                	test   %eax,%eax
  800b06:	78 57                	js     800b5f <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b08:	83 ec 08             	sub    $0x8,%esp
  800b0b:	53                   	push   %ebx
  800b0c:	68 00 50 80 00       	push   $0x805000
  800b11:	e8 c2 0b 00 00       	call   8016d8 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b16:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b19:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b1e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b21:	b8 01 00 00 00       	mov    $0x1,%eax
  800b26:	e8 f6 fd ff ff       	call   800921 <fsipc>
  800b2b:	89 c3                	mov    %eax,%ebx
  800b2d:	83 c4 10             	add    $0x10,%esp
  800b30:	85 c0                	test   %eax,%eax
  800b32:	79 14                	jns    800b48 <open+0x6f>
		fd_close(fd, 0);
  800b34:	83 ec 08             	sub    $0x8,%esp
  800b37:	6a 00                	push   $0x0
  800b39:	ff 75 f4             	pushl  -0xc(%ebp)
  800b3c:	e8 50 f9 ff ff       	call   800491 <fd_close>
		return r;
  800b41:	83 c4 10             	add    $0x10,%esp
  800b44:	89 da                	mov    %ebx,%edx
  800b46:	eb 17                	jmp    800b5f <open+0x86>
	}

	return fd2num(fd);
  800b48:	83 ec 0c             	sub    $0xc,%esp
  800b4b:	ff 75 f4             	pushl  -0xc(%ebp)
  800b4e:	e8 1f f8 ff ff       	call   800372 <fd2num>
  800b53:	89 c2                	mov    %eax,%edx
  800b55:	83 c4 10             	add    $0x10,%esp
  800b58:	eb 05                	jmp    800b5f <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b5a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b5f:	89 d0                	mov    %edx,%eax
  800b61:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b64:	c9                   	leave  
  800b65:	c3                   	ret    

00800b66 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b66:	55                   	push   %ebp
  800b67:	89 e5                	mov    %esp,%ebp
  800b69:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b6c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b71:	b8 08 00 00 00       	mov    $0x8,%eax
  800b76:	e8 a6 fd ff ff       	call   800921 <fsipc>
}
  800b7b:	c9                   	leave  
  800b7c:	c3                   	ret    

00800b7d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b7d:	55                   	push   %ebp
  800b7e:	89 e5                	mov    %esp,%ebp
  800b80:	56                   	push   %esi
  800b81:	53                   	push   %ebx
  800b82:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b85:	83 ec 0c             	sub    $0xc,%esp
  800b88:	ff 75 08             	pushl  0x8(%ebp)
  800b8b:	e8 f2 f7 ff ff       	call   800382 <fd2data>
  800b90:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b92:	83 c4 08             	add    $0x8,%esp
  800b95:	68 d7 1e 80 00       	push   $0x801ed7
  800b9a:	53                   	push   %ebx
  800b9b:	e8 38 0b 00 00       	call   8016d8 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800ba0:	8b 46 04             	mov    0x4(%esi),%eax
  800ba3:	2b 06                	sub    (%esi),%eax
  800ba5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bab:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bb2:	00 00 00 
	stat->st_dev = &devpipe;
  800bb5:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bbc:	30 80 00 
	return 0;
}
  800bbf:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bc7:	5b                   	pop    %ebx
  800bc8:	5e                   	pop    %esi
  800bc9:	5d                   	pop    %ebp
  800bca:	c3                   	ret    

00800bcb <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bcb:	55                   	push   %ebp
  800bcc:	89 e5                	mov    %esp,%ebp
  800bce:	53                   	push   %ebx
  800bcf:	83 ec 0c             	sub    $0xc,%esp
  800bd2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bd5:	53                   	push   %ebx
  800bd6:	6a 00                	push   $0x0
  800bd8:	e8 29 f6 ff ff       	call   800206 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bdd:	89 1c 24             	mov    %ebx,(%esp)
  800be0:	e8 9d f7 ff ff       	call   800382 <fd2data>
  800be5:	83 c4 08             	add    $0x8,%esp
  800be8:	50                   	push   %eax
  800be9:	6a 00                	push   $0x0
  800beb:	e8 16 f6 ff ff       	call   800206 <sys_page_unmap>
}
  800bf0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bf3:	c9                   	leave  
  800bf4:	c3                   	ret    

00800bf5 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	57                   	push   %edi
  800bf9:	56                   	push   %esi
  800bfa:	53                   	push   %ebx
  800bfb:	83 ec 1c             	sub    $0x1c,%esp
  800bfe:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c01:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c03:	a1 04 40 80 00       	mov    0x804004,%eax
  800c08:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800c0b:	83 ec 0c             	sub    $0xc,%esp
  800c0e:	ff 75 e0             	pushl  -0x20(%ebp)
  800c11:	e8 eb 0e 00 00       	call   801b01 <pageref>
  800c16:	89 c3                	mov    %eax,%ebx
  800c18:	89 3c 24             	mov    %edi,(%esp)
  800c1b:	e8 e1 0e 00 00       	call   801b01 <pageref>
  800c20:	83 c4 10             	add    $0x10,%esp
  800c23:	39 c3                	cmp    %eax,%ebx
  800c25:	0f 94 c1             	sete   %cl
  800c28:	0f b6 c9             	movzbl %cl,%ecx
  800c2b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c2e:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c34:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c37:	39 ce                	cmp    %ecx,%esi
  800c39:	74 1b                	je     800c56 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c3b:	39 c3                	cmp    %eax,%ebx
  800c3d:	75 c4                	jne    800c03 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c3f:	8b 42 58             	mov    0x58(%edx),%eax
  800c42:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c45:	50                   	push   %eax
  800c46:	56                   	push   %esi
  800c47:	68 de 1e 80 00       	push   $0x801ede
  800c4c:	e8 e4 04 00 00       	call   801135 <cprintf>
  800c51:	83 c4 10             	add    $0x10,%esp
  800c54:	eb ad                	jmp    800c03 <_pipeisclosed+0xe>
	}
}
  800c56:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c59:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5c:	5b                   	pop    %ebx
  800c5d:	5e                   	pop    %esi
  800c5e:	5f                   	pop    %edi
  800c5f:	5d                   	pop    %ebp
  800c60:	c3                   	ret    

00800c61 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c61:	55                   	push   %ebp
  800c62:	89 e5                	mov    %esp,%ebp
  800c64:	57                   	push   %edi
  800c65:	56                   	push   %esi
  800c66:	53                   	push   %ebx
  800c67:	83 ec 28             	sub    $0x28,%esp
  800c6a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c6d:	56                   	push   %esi
  800c6e:	e8 0f f7 ff ff       	call   800382 <fd2data>
  800c73:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c75:	83 c4 10             	add    $0x10,%esp
  800c78:	bf 00 00 00 00       	mov    $0x0,%edi
  800c7d:	eb 4b                	jmp    800cca <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c7f:	89 da                	mov    %ebx,%edx
  800c81:	89 f0                	mov    %esi,%eax
  800c83:	e8 6d ff ff ff       	call   800bf5 <_pipeisclosed>
  800c88:	85 c0                	test   %eax,%eax
  800c8a:	75 48                	jne    800cd4 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c8c:	e8 d1 f4 ff ff       	call   800162 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c91:	8b 43 04             	mov    0x4(%ebx),%eax
  800c94:	8b 0b                	mov    (%ebx),%ecx
  800c96:	8d 51 20             	lea    0x20(%ecx),%edx
  800c99:	39 d0                	cmp    %edx,%eax
  800c9b:	73 e2                	jae    800c7f <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca0:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800ca4:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800ca7:	89 c2                	mov    %eax,%edx
  800ca9:	c1 fa 1f             	sar    $0x1f,%edx
  800cac:	89 d1                	mov    %edx,%ecx
  800cae:	c1 e9 1b             	shr    $0x1b,%ecx
  800cb1:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cb4:	83 e2 1f             	and    $0x1f,%edx
  800cb7:	29 ca                	sub    %ecx,%edx
  800cb9:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cbd:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cc1:	83 c0 01             	add    $0x1,%eax
  800cc4:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cc7:	83 c7 01             	add    $0x1,%edi
  800cca:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800ccd:	75 c2                	jne    800c91 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800ccf:	8b 45 10             	mov    0x10(%ebp),%eax
  800cd2:	eb 05                	jmp    800cd9 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cd4:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cd9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cdc:	5b                   	pop    %ebx
  800cdd:	5e                   	pop    %esi
  800cde:	5f                   	pop    %edi
  800cdf:	5d                   	pop    %ebp
  800ce0:	c3                   	ret    

00800ce1 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800ce1:	55                   	push   %ebp
  800ce2:	89 e5                	mov    %esp,%ebp
  800ce4:	57                   	push   %edi
  800ce5:	56                   	push   %esi
  800ce6:	53                   	push   %ebx
  800ce7:	83 ec 18             	sub    $0x18,%esp
  800cea:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800ced:	57                   	push   %edi
  800cee:	e8 8f f6 ff ff       	call   800382 <fd2data>
  800cf3:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cf5:	83 c4 10             	add    $0x10,%esp
  800cf8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cfd:	eb 3d                	jmp    800d3c <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800cff:	85 db                	test   %ebx,%ebx
  800d01:	74 04                	je     800d07 <devpipe_read+0x26>
				return i;
  800d03:	89 d8                	mov    %ebx,%eax
  800d05:	eb 44                	jmp    800d4b <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d07:	89 f2                	mov    %esi,%edx
  800d09:	89 f8                	mov    %edi,%eax
  800d0b:	e8 e5 fe ff ff       	call   800bf5 <_pipeisclosed>
  800d10:	85 c0                	test   %eax,%eax
  800d12:	75 32                	jne    800d46 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d14:	e8 49 f4 ff ff       	call   800162 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d19:	8b 06                	mov    (%esi),%eax
  800d1b:	3b 46 04             	cmp    0x4(%esi),%eax
  800d1e:	74 df                	je     800cff <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d20:	99                   	cltd   
  800d21:	c1 ea 1b             	shr    $0x1b,%edx
  800d24:	01 d0                	add    %edx,%eax
  800d26:	83 e0 1f             	and    $0x1f,%eax
  800d29:	29 d0                	sub    %edx,%eax
  800d2b:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d33:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d36:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d39:	83 c3 01             	add    $0x1,%ebx
  800d3c:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d3f:	75 d8                	jne    800d19 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d41:	8b 45 10             	mov    0x10(%ebp),%eax
  800d44:	eb 05                	jmp    800d4b <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d46:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4e:	5b                   	pop    %ebx
  800d4f:	5e                   	pop    %esi
  800d50:	5f                   	pop    %edi
  800d51:	5d                   	pop    %ebp
  800d52:	c3                   	ret    

00800d53 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d53:	55                   	push   %ebp
  800d54:	89 e5                	mov    %esp,%ebp
  800d56:	56                   	push   %esi
  800d57:	53                   	push   %ebx
  800d58:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d5b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d5e:	50                   	push   %eax
  800d5f:	e8 35 f6 ff ff       	call   800399 <fd_alloc>
  800d64:	83 c4 10             	add    $0x10,%esp
  800d67:	89 c2                	mov    %eax,%edx
  800d69:	85 c0                	test   %eax,%eax
  800d6b:	0f 88 2c 01 00 00    	js     800e9d <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d71:	83 ec 04             	sub    $0x4,%esp
  800d74:	68 07 04 00 00       	push   $0x407
  800d79:	ff 75 f4             	pushl  -0xc(%ebp)
  800d7c:	6a 00                	push   $0x0
  800d7e:	e8 fe f3 ff ff       	call   800181 <sys_page_alloc>
  800d83:	83 c4 10             	add    $0x10,%esp
  800d86:	89 c2                	mov    %eax,%edx
  800d88:	85 c0                	test   %eax,%eax
  800d8a:	0f 88 0d 01 00 00    	js     800e9d <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d90:	83 ec 0c             	sub    $0xc,%esp
  800d93:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d96:	50                   	push   %eax
  800d97:	e8 fd f5 ff ff       	call   800399 <fd_alloc>
  800d9c:	89 c3                	mov    %eax,%ebx
  800d9e:	83 c4 10             	add    $0x10,%esp
  800da1:	85 c0                	test   %eax,%eax
  800da3:	0f 88 e2 00 00 00    	js     800e8b <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800da9:	83 ec 04             	sub    $0x4,%esp
  800dac:	68 07 04 00 00       	push   $0x407
  800db1:	ff 75 f0             	pushl  -0x10(%ebp)
  800db4:	6a 00                	push   $0x0
  800db6:	e8 c6 f3 ff ff       	call   800181 <sys_page_alloc>
  800dbb:	89 c3                	mov    %eax,%ebx
  800dbd:	83 c4 10             	add    $0x10,%esp
  800dc0:	85 c0                	test   %eax,%eax
  800dc2:	0f 88 c3 00 00 00    	js     800e8b <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800dc8:	83 ec 0c             	sub    $0xc,%esp
  800dcb:	ff 75 f4             	pushl  -0xc(%ebp)
  800dce:	e8 af f5 ff ff       	call   800382 <fd2data>
  800dd3:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dd5:	83 c4 0c             	add    $0xc,%esp
  800dd8:	68 07 04 00 00       	push   $0x407
  800ddd:	50                   	push   %eax
  800dde:	6a 00                	push   $0x0
  800de0:	e8 9c f3 ff ff       	call   800181 <sys_page_alloc>
  800de5:	89 c3                	mov    %eax,%ebx
  800de7:	83 c4 10             	add    $0x10,%esp
  800dea:	85 c0                	test   %eax,%eax
  800dec:	0f 88 89 00 00 00    	js     800e7b <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800df2:	83 ec 0c             	sub    $0xc,%esp
  800df5:	ff 75 f0             	pushl  -0x10(%ebp)
  800df8:	e8 85 f5 ff ff       	call   800382 <fd2data>
  800dfd:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e04:	50                   	push   %eax
  800e05:	6a 00                	push   $0x0
  800e07:	56                   	push   %esi
  800e08:	6a 00                	push   $0x0
  800e0a:	e8 b5 f3 ff ff       	call   8001c4 <sys_page_map>
  800e0f:	89 c3                	mov    %eax,%ebx
  800e11:	83 c4 20             	add    $0x20,%esp
  800e14:	85 c0                	test   %eax,%eax
  800e16:	78 55                	js     800e6d <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e18:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e21:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e23:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e26:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e2d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e33:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e36:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e38:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e3b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e42:	83 ec 0c             	sub    $0xc,%esp
  800e45:	ff 75 f4             	pushl  -0xc(%ebp)
  800e48:	e8 25 f5 ff ff       	call   800372 <fd2num>
  800e4d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e50:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e52:	83 c4 04             	add    $0x4,%esp
  800e55:	ff 75 f0             	pushl  -0x10(%ebp)
  800e58:	e8 15 f5 ff ff       	call   800372 <fd2num>
  800e5d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e60:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e63:	83 c4 10             	add    $0x10,%esp
  800e66:	ba 00 00 00 00       	mov    $0x0,%edx
  800e6b:	eb 30                	jmp    800e9d <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e6d:	83 ec 08             	sub    $0x8,%esp
  800e70:	56                   	push   %esi
  800e71:	6a 00                	push   $0x0
  800e73:	e8 8e f3 ff ff       	call   800206 <sys_page_unmap>
  800e78:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e7b:	83 ec 08             	sub    $0x8,%esp
  800e7e:	ff 75 f0             	pushl  -0x10(%ebp)
  800e81:	6a 00                	push   $0x0
  800e83:	e8 7e f3 ff ff       	call   800206 <sys_page_unmap>
  800e88:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e8b:	83 ec 08             	sub    $0x8,%esp
  800e8e:	ff 75 f4             	pushl  -0xc(%ebp)
  800e91:	6a 00                	push   $0x0
  800e93:	e8 6e f3 ff ff       	call   800206 <sys_page_unmap>
  800e98:	83 c4 10             	add    $0x10,%esp
  800e9b:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e9d:	89 d0                	mov    %edx,%eax
  800e9f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ea2:	5b                   	pop    %ebx
  800ea3:	5e                   	pop    %esi
  800ea4:	5d                   	pop    %ebp
  800ea5:	c3                   	ret    

00800ea6 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800ea6:	55                   	push   %ebp
  800ea7:	89 e5                	mov    %esp,%ebp
  800ea9:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800eac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800eaf:	50                   	push   %eax
  800eb0:	ff 75 08             	pushl  0x8(%ebp)
  800eb3:	e8 30 f5 ff ff       	call   8003e8 <fd_lookup>
  800eb8:	83 c4 10             	add    $0x10,%esp
  800ebb:	85 c0                	test   %eax,%eax
  800ebd:	78 18                	js     800ed7 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800ebf:	83 ec 0c             	sub    $0xc,%esp
  800ec2:	ff 75 f4             	pushl  -0xc(%ebp)
  800ec5:	e8 b8 f4 ff ff       	call   800382 <fd2data>
	return _pipeisclosed(fd, p);
  800eca:	89 c2                	mov    %eax,%edx
  800ecc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ecf:	e8 21 fd ff ff       	call   800bf5 <_pipeisclosed>
  800ed4:	83 c4 10             	add    $0x10,%esp
}
  800ed7:	c9                   	leave  
  800ed8:	c3                   	ret    

00800ed9 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ed9:	55                   	push   %ebp
  800eda:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800edc:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee1:	5d                   	pop    %ebp
  800ee2:	c3                   	ret    

00800ee3 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ee3:	55                   	push   %ebp
  800ee4:	89 e5                	mov    %esp,%ebp
  800ee6:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ee9:	68 f6 1e 80 00       	push   $0x801ef6
  800eee:	ff 75 0c             	pushl  0xc(%ebp)
  800ef1:	e8 e2 07 00 00       	call   8016d8 <strcpy>
	return 0;
}
  800ef6:	b8 00 00 00 00       	mov    $0x0,%eax
  800efb:	c9                   	leave  
  800efc:	c3                   	ret    

00800efd <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800efd:	55                   	push   %ebp
  800efe:	89 e5                	mov    %esp,%ebp
  800f00:	57                   	push   %edi
  800f01:	56                   	push   %esi
  800f02:	53                   	push   %ebx
  800f03:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f09:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f0e:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f14:	eb 2d                	jmp    800f43 <devcons_write+0x46>
		m = n - tot;
  800f16:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f19:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800f1b:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f1e:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f23:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f26:	83 ec 04             	sub    $0x4,%esp
  800f29:	53                   	push   %ebx
  800f2a:	03 45 0c             	add    0xc(%ebp),%eax
  800f2d:	50                   	push   %eax
  800f2e:	57                   	push   %edi
  800f2f:	e8 36 09 00 00       	call   80186a <memmove>
		sys_cputs(buf, m);
  800f34:	83 c4 08             	add    $0x8,%esp
  800f37:	53                   	push   %ebx
  800f38:	57                   	push   %edi
  800f39:	e8 87 f1 ff ff       	call   8000c5 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f3e:	01 de                	add    %ebx,%esi
  800f40:	83 c4 10             	add    $0x10,%esp
  800f43:	89 f0                	mov    %esi,%eax
  800f45:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f48:	72 cc                	jb     800f16 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f4d:	5b                   	pop    %ebx
  800f4e:	5e                   	pop    %esi
  800f4f:	5f                   	pop    %edi
  800f50:	5d                   	pop    %ebp
  800f51:	c3                   	ret    

00800f52 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f52:	55                   	push   %ebp
  800f53:	89 e5                	mov    %esp,%ebp
  800f55:	83 ec 08             	sub    $0x8,%esp
  800f58:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f5d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f61:	74 2a                	je     800f8d <devcons_read+0x3b>
  800f63:	eb 05                	jmp    800f6a <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f65:	e8 f8 f1 ff ff       	call   800162 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f6a:	e8 74 f1 ff ff       	call   8000e3 <sys_cgetc>
  800f6f:	85 c0                	test   %eax,%eax
  800f71:	74 f2                	je     800f65 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f73:	85 c0                	test   %eax,%eax
  800f75:	78 16                	js     800f8d <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f77:	83 f8 04             	cmp    $0x4,%eax
  800f7a:	74 0c                	je     800f88 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f7c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f7f:	88 02                	mov    %al,(%edx)
	return 1;
  800f81:	b8 01 00 00 00       	mov    $0x1,%eax
  800f86:	eb 05                	jmp    800f8d <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f88:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f8d:	c9                   	leave  
  800f8e:	c3                   	ret    

00800f8f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f8f:	55                   	push   %ebp
  800f90:	89 e5                	mov    %esp,%ebp
  800f92:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f95:	8b 45 08             	mov    0x8(%ebp),%eax
  800f98:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f9b:	6a 01                	push   $0x1
  800f9d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fa0:	50                   	push   %eax
  800fa1:	e8 1f f1 ff ff       	call   8000c5 <sys_cputs>
}
  800fa6:	83 c4 10             	add    $0x10,%esp
  800fa9:	c9                   	leave  
  800faa:	c3                   	ret    

00800fab <getchar>:

int
getchar(void)
{
  800fab:	55                   	push   %ebp
  800fac:	89 e5                	mov    %esp,%ebp
  800fae:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800fb1:	6a 01                	push   $0x1
  800fb3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fb6:	50                   	push   %eax
  800fb7:	6a 00                	push   $0x0
  800fb9:	e8 90 f6 ff ff       	call   80064e <read>
	if (r < 0)
  800fbe:	83 c4 10             	add    $0x10,%esp
  800fc1:	85 c0                	test   %eax,%eax
  800fc3:	78 0f                	js     800fd4 <getchar+0x29>
		return r;
	if (r < 1)
  800fc5:	85 c0                	test   %eax,%eax
  800fc7:	7e 06                	jle    800fcf <getchar+0x24>
		return -E_EOF;
	return c;
  800fc9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fcd:	eb 05                	jmp    800fd4 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fcf:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fd4:	c9                   	leave  
  800fd5:	c3                   	ret    

00800fd6 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800fd6:	55                   	push   %ebp
  800fd7:	89 e5                	mov    %esp,%ebp
  800fd9:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fdc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fdf:	50                   	push   %eax
  800fe0:	ff 75 08             	pushl  0x8(%ebp)
  800fe3:	e8 00 f4 ff ff       	call   8003e8 <fd_lookup>
  800fe8:	83 c4 10             	add    $0x10,%esp
  800feb:	85 c0                	test   %eax,%eax
  800fed:	78 11                	js     801000 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800fef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ff2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800ff8:	39 10                	cmp    %edx,(%eax)
  800ffa:	0f 94 c0             	sete   %al
  800ffd:	0f b6 c0             	movzbl %al,%eax
}
  801000:	c9                   	leave  
  801001:	c3                   	ret    

00801002 <opencons>:

int
opencons(void)
{
  801002:	55                   	push   %ebp
  801003:	89 e5                	mov    %esp,%ebp
  801005:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801008:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80100b:	50                   	push   %eax
  80100c:	e8 88 f3 ff ff       	call   800399 <fd_alloc>
  801011:	83 c4 10             	add    $0x10,%esp
		return r;
  801014:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801016:	85 c0                	test   %eax,%eax
  801018:	78 3e                	js     801058 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80101a:	83 ec 04             	sub    $0x4,%esp
  80101d:	68 07 04 00 00       	push   $0x407
  801022:	ff 75 f4             	pushl  -0xc(%ebp)
  801025:	6a 00                	push   $0x0
  801027:	e8 55 f1 ff ff       	call   800181 <sys_page_alloc>
  80102c:	83 c4 10             	add    $0x10,%esp
		return r;
  80102f:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801031:	85 c0                	test   %eax,%eax
  801033:	78 23                	js     801058 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801035:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80103b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80103e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801040:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801043:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80104a:	83 ec 0c             	sub    $0xc,%esp
  80104d:	50                   	push   %eax
  80104e:	e8 1f f3 ff ff       	call   800372 <fd2num>
  801053:	89 c2                	mov    %eax,%edx
  801055:	83 c4 10             	add    $0x10,%esp
}
  801058:	89 d0                	mov    %edx,%eax
  80105a:	c9                   	leave  
  80105b:	c3                   	ret    

0080105c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80105c:	55                   	push   %ebp
  80105d:	89 e5                	mov    %esp,%ebp
  80105f:	56                   	push   %esi
  801060:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801061:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801064:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80106a:	e8 d4 f0 ff ff       	call   800143 <sys_getenvid>
  80106f:	83 ec 0c             	sub    $0xc,%esp
  801072:	ff 75 0c             	pushl  0xc(%ebp)
  801075:	ff 75 08             	pushl  0x8(%ebp)
  801078:	56                   	push   %esi
  801079:	50                   	push   %eax
  80107a:	68 04 1f 80 00       	push   $0x801f04
  80107f:	e8 b1 00 00 00       	call   801135 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801084:	83 c4 18             	add    $0x18,%esp
  801087:	53                   	push   %ebx
  801088:	ff 75 10             	pushl  0x10(%ebp)
  80108b:	e8 54 00 00 00       	call   8010e4 <vcprintf>
	cprintf("\n");
  801090:	c7 04 24 ef 1e 80 00 	movl   $0x801eef,(%esp)
  801097:	e8 99 00 00 00       	call   801135 <cprintf>
  80109c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80109f:	cc                   	int3   
  8010a0:	eb fd                	jmp    80109f <_panic+0x43>

008010a2 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010a2:	55                   	push   %ebp
  8010a3:	89 e5                	mov    %esp,%ebp
  8010a5:	53                   	push   %ebx
  8010a6:	83 ec 04             	sub    $0x4,%esp
  8010a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010ac:	8b 13                	mov    (%ebx),%edx
  8010ae:	8d 42 01             	lea    0x1(%edx),%eax
  8010b1:	89 03                	mov    %eax,(%ebx)
  8010b3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010b6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010ba:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010bf:	75 1a                	jne    8010db <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010c1:	83 ec 08             	sub    $0x8,%esp
  8010c4:	68 ff 00 00 00       	push   $0xff
  8010c9:	8d 43 08             	lea    0x8(%ebx),%eax
  8010cc:	50                   	push   %eax
  8010cd:	e8 f3 ef ff ff       	call   8000c5 <sys_cputs>
		b->idx = 0;
  8010d2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010d8:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010db:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010e2:	c9                   	leave  
  8010e3:	c3                   	ret    

008010e4 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010e4:	55                   	push   %ebp
  8010e5:	89 e5                	mov    %esp,%ebp
  8010e7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010ed:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010f4:	00 00 00 
	b.cnt = 0;
  8010f7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010fe:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801101:	ff 75 0c             	pushl  0xc(%ebp)
  801104:	ff 75 08             	pushl  0x8(%ebp)
  801107:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80110d:	50                   	push   %eax
  80110e:	68 a2 10 80 00       	push   $0x8010a2
  801113:	e8 54 01 00 00       	call   80126c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801118:	83 c4 08             	add    $0x8,%esp
  80111b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801121:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801127:	50                   	push   %eax
  801128:	e8 98 ef ff ff       	call   8000c5 <sys_cputs>

	return b.cnt;
}
  80112d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801133:	c9                   	leave  
  801134:	c3                   	ret    

00801135 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801135:	55                   	push   %ebp
  801136:	89 e5                	mov    %esp,%ebp
  801138:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80113b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80113e:	50                   	push   %eax
  80113f:	ff 75 08             	pushl  0x8(%ebp)
  801142:	e8 9d ff ff ff       	call   8010e4 <vcprintf>
	va_end(ap);

	return cnt;
}
  801147:	c9                   	leave  
  801148:	c3                   	ret    

00801149 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801149:	55                   	push   %ebp
  80114a:	89 e5                	mov    %esp,%ebp
  80114c:	57                   	push   %edi
  80114d:	56                   	push   %esi
  80114e:	53                   	push   %ebx
  80114f:	83 ec 1c             	sub    $0x1c,%esp
  801152:	89 c7                	mov    %eax,%edi
  801154:	89 d6                	mov    %edx,%esi
  801156:	8b 45 08             	mov    0x8(%ebp),%eax
  801159:	8b 55 0c             	mov    0xc(%ebp),%edx
  80115c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80115f:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801162:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801165:	bb 00 00 00 00       	mov    $0x0,%ebx
  80116a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80116d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801170:	39 d3                	cmp    %edx,%ebx
  801172:	72 05                	jb     801179 <printnum+0x30>
  801174:	39 45 10             	cmp    %eax,0x10(%ebp)
  801177:	77 45                	ja     8011be <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801179:	83 ec 0c             	sub    $0xc,%esp
  80117c:	ff 75 18             	pushl  0x18(%ebp)
  80117f:	8b 45 14             	mov    0x14(%ebp),%eax
  801182:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801185:	53                   	push   %ebx
  801186:	ff 75 10             	pushl  0x10(%ebp)
  801189:	83 ec 08             	sub    $0x8,%esp
  80118c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80118f:	ff 75 e0             	pushl  -0x20(%ebp)
  801192:	ff 75 dc             	pushl  -0x24(%ebp)
  801195:	ff 75 d8             	pushl  -0x28(%ebp)
  801198:	e8 a3 09 00 00       	call   801b40 <__udivdi3>
  80119d:	83 c4 18             	add    $0x18,%esp
  8011a0:	52                   	push   %edx
  8011a1:	50                   	push   %eax
  8011a2:	89 f2                	mov    %esi,%edx
  8011a4:	89 f8                	mov    %edi,%eax
  8011a6:	e8 9e ff ff ff       	call   801149 <printnum>
  8011ab:	83 c4 20             	add    $0x20,%esp
  8011ae:	eb 18                	jmp    8011c8 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011b0:	83 ec 08             	sub    $0x8,%esp
  8011b3:	56                   	push   %esi
  8011b4:	ff 75 18             	pushl  0x18(%ebp)
  8011b7:	ff d7                	call   *%edi
  8011b9:	83 c4 10             	add    $0x10,%esp
  8011bc:	eb 03                	jmp    8011c1 <printnum+0x78>
  8011be:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011c1:	83 eb 01             	sub    $0x1,%ebx
  8011c4:	85 db                	test   %ebx,%ebx
  8011c6:	7f e8                	jg     8011b0 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011c8:	83 ec 08             	sub    $0x8,%esp
  8011cb:	56                   	push   %esi
  8011cc:	83 ec 04             	sub    $0x4,%esp
  8011cf:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011d2:	ff 75 e0             	pushl  -0x20(%ebp)
  8011d5:	ff 75 dc             	pushl  -0x24(%ebp)
  8011d8:	ff 75 d8             	pushl  -0x28(%ebp)
  8011db:	e8 90 0a 00 00       	call   801c70 <__umoddi3>
  8011e0:	83 c4 14             	add    $0x14,%esp
  8011e3:	0f be 80 27 1f 80 00 	movsbl 0x801f27(%eax),%eax
  8011ea:	50                   	push   %eax
  8011eb:	ff d7                	call   *%edi
}
  8011ed:	83 c4 10             	add    $0x10,%esp
  8011f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011f3:	5b                   	pop    %ebx
  8011f4:	5e                   	pop    %esi
  8011f5:	5f                   	pop    %edi
  8011f6:	5d                   	pop    %ebp
  8011f7:	c3                   	ret    

008011f8 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8011f8:	55                   	push   %ebp
  8011f9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011fb:	83 fa 01             	cmp    $0x1,%edx
  8011fe:	7e 0e                	jle    80120e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801200:	8b 10                	mov    (%eax),%edx
  801202:	8d 4a 08             	lea    0x8(%edx),%ecx
  801205:	89 08                	mov    %ecx,(%eax)
  801207:	8b 02                	mov    (%edx),%eax
  801209:	8b 52 04             	mov    0x4(%edx),%edx
  80120c:	eb 22                	jmp    801230 <getuint+0x38>
	else if (lflag)
  80120e:	85 d2                	test   %edx,%edx
  801210:	74 10                	je     801222 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801212:	8b 10                	mov    (%eax),%edx
  801214:	8d 4a 04             	lea    0x4(%edx),%ecx
  801217:	89 08                	mov    %ecx,(%eax)
  801219:	8b 02                	mov    (%edx),%eax
  80121b:	ba 00 00 00 00       	mov    $0x0,%edx
  801220:	eb 0e                	jmp    801230 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801222:	8b 10                	mov    (%eax),%edx
  801224:	8d 4a 04             	lea    0x4(%edx),%ecx
  801227:	89 08                	mov    %ecx,(%eax)
  801229:	8b 02                	mov    (%edx),%eax
  80122b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801230:	5d                   	pop    %ebp
  801231:	c3                   	ret    

00801232 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801232:	55                   	push   %ebp
  801233:	89 e5                	mov    %esp,%ebp
  801235:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801238:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80123c:	8b 10                	mov    (%eax),%edx
  80123e:	3b 50 04             	cmp    0x4(%eax),%edx
  801241:	73 0a                	jae    80124d <sprintputch+0x1b>
		*b->buf++ = ch;
  801243:	8d 4a 01             	lea    0x1(%edx),%ecx
  801246:	89 08                	mov    %ecx,(%eax)
  801248:	8b 45 08             	mov    0x8(%ebp),%eax
  80124b:	88 02                	mov    %al,(%edx)
}
  80124d:	5d                   	pop    %ebp
  80124e:	c3                   	ret    

0080124f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80124f:	55                   	push   %ebp
  801250:	89 e5                	mov    %esp,%ebp
  801252:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801255:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801258:	50                   	push   %eax
  801259:	ff 75 10             	pushl  0x10(%ebp)
  80125c:	ff 75 0c             	pushl  0xc(%ebp)
  80125f:	ff 75 08             	pushl  0x8(%ebp)
  801262:	e8 05 00 00 00       	call   80126c <vprintfmt>
	va_end(ap);
}
  801267:	83 c4 10             	add    $0x10,%esp
  80126a:	c9                   	leave  
  80126b:	c3                   	ret    

0080126c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80126c:	55                   	push   %ebp
  80126d:	89 e5                	mov    %esp,%ebp
  80126f:	57                   	push   %edi
  801270:	56                   	push   %esi
  801271:	53                   	push   %ebx
  801272:	83 ec 2c             	sub    $0x2c,%esp
  801275:	8b 75 08             	mov    0x8(%ebp),%esi
  801278:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80127b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80127e:	eb 12                	jmp    801292 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801280:	85 c0                	test   %eax,%eax
  801282:	0f 84 a7 03 00 00    	je     80162f <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
  801288:	83 ec 08             	sub    $0x8,%esp
  80128b:	53                   	push   %ebx
  80128c:	50                   	push   %eax
  80128d:	ff d6                	call   *%esi
  80128f:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801292:	83 c7 01             	add    $0x1,%edi
  801295:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801299:	83 f8 25             	cmp    $0x25,%eax
  80129c:	75 e2                	jne    801280 <vprintfmt+0x14>
  80129e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8012a2:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8012a9:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8012b0:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8012b7:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8012be:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012c3:	eb 07                	jmp    8012cc <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8012c8:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012cc:	8d 47 01             	lea    0x1(%edi),%eax
  8012cf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012d2:	0f b6 07             	movzbl (%edi),%eax
  8012d5:	0f b6 d0             	movzbl %al,%edx
  8012d8:	83 e8 23             	sub    $0x23,%eax
  8012db:	3c 55                	cmp    $0x55,%al
  8012dd:	0f 87 31 03 00 00    	ja     801614 <vprintfmt+0x3a8>
  8012e3:	0f b6 c0             	movzbl %al,%eax
  8012e6:	ff 24 85 60 20 80 00 	jmp    *0x802060(,%eax,4)
  8012ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8012f0:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8012f4:	eb d6                	jmp    8012cc <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8012fe:	89 75 08             	mov    %esi,0x8(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801301:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801304:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801308:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80130b:	8d 72 d0             	lea    -0x30(%edx),%esi
  80130e:	83 fe 09             	cmp    $0x9,%esi
  801311:	77 34                	ja     801347 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801313:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801316:	eb e9                	jmp    801301 <vprintfmt+0x95>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801318:	8b 45 14             	mov    0x14(%ebp),%eax
  80131b:	8d 50 04             	lea    0x4(%eax),%edx
  80131e:	89 55 14             	mov    %edx,0x14(%ebp)
  801321:	8b 00                	mov    (%eax),%eax
  801323:	89 45 cc             	mov    %eax,-0x34(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801326:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801329:	eb 22                	jmp    80134d <vprintfmt+0xe1>
  80132b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80132e:	85 c0                	test   %eax,%eax
  801330:	0f 48 c1             	cmovs  %ecx,%eax
  801333:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801336:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801339:	eb 91                	jmp    8012cc <vprintfmt+0x60>
  80133b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80133e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801345:	eb 85                	jmp    8012cc <vprintfmt+0x60>
  801347:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80134a:	8b 75 08             	mov    0x8(%ebp),%esi

		process_precision:
			if (width < 0)
  80134d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801351:	0f 89 75 ff ff ff    	jns    8012cc <vprintfmt+0x60>
				width = precision, precision = -1;
  801357:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80135a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80135d:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  801364:	e9 63 ff ff ff       	jmp    8012cc <vprintfmt+0x60>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801369:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80136d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801370:	e9 57 ff ff ff       	jmp    8012cc <vprintfmt+0x60>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801375:	8b 45 14             	mov    0x14(%ebp),%eax
  801378:	8d 50 04             	lea    0x4(%eax),%edx
  80137b:	89 55 14             	mov    %edx,0x14(%ebp)
  80137e:	83 ec 08             	sub    $0x8,%esp
  801381:	53                   	push   %ebx
  801382:	ff 30                	pushl  (%eax)
  801384:	ff d6                	call   *%esi
			break;
  801386:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801389:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80138c:	e9 01 ff ff ff       	jmp    801292 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801391:	8b 45 14             	mov    0x14(%ebp),%eax
  801394:	8d 50 04             	lea    0x4(%eax),%edx
  801397:	89 55 14             	mov    %edx,0x14(%ebp)
  80139a:	8b 00                	mov    (%eax),%eax
  80139c:	99                   	cltd   
  80139d:	31 d0                	xor    %edx,%eax
  80139f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013a1:	83 f8 0f             	cmp    $0xf,%eax
  8013a4:	7f 0b                	jg     8013b1 <vprintfmt+0x145>
  8013a6:	8b 14 85 c0 21 80 00 	mov    0x8021c0(,%eax,4),%edx
  8013ad:	85 d2                	test   %edx,%edx
  8013af:	75 18                	jne    8013c9 <vprintfmt+0x15d>
				printfmt(putch, putdat, "error %d", err);
  8013b1:	50                   	push   %eax
  8013b2:	68 3f 1f 80 00       	push   $0x801f3f
  8013b7:	53                   	push   %ebx
  8013b8:	56                   	push   %esi
  8013b9:	e8 91 fe ff ff       	call   80124f <printfmt>
  8013be:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8013c4:	e9 c9 fe ff ff       	jmp    801292 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8013c9:	52                   	push   %edx
  8013ca:	68 bd 1e 80 00       	push   $0x801ebd
  8013cf:	53                   	push   %ebx
  8013d0:	56                   	push   %esi
  8013d1:	e8 79 fe ff ff       	call   80124f <printfmt>
  8013d6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013dc:	e9 b1 fe ff ff       	jmp    801292 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8013e4:	8d 50 04             	lea    0x4(%eax),%edx
  8013e7:	89 55 14             	mov    %edx,0x14(%ebp)
  8013ea:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8013ec:	85 ff                	test   %edi,%edi
  8013ee:	b8 38 1f 80 00       	mov    $0x801f38,%eax
  8013f3:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8013f6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013fa:	0f 8e 94 00 00 00    	jle    801494 <vprintfmt+0x228>
  801400:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801404:	0f 84 98 00 00 00    	je     8014a2 <vprintfmt+0x236>
				for (width -= strnlen(p, precision); width > 0; width--)
  80140a:	83 ec 08             	sub    $0x8,%esp
  80140d:	ff 75 cc             	pushl  -0x34(%ebp)
  801410:	57                   	push   %edi
  801411:	e8 a1 02 00 00       	call   8016b7 <strnlen>
  801416:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801419:	29 c1                	sub    %eax,%ecx
  80141b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80141e:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801421:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801425:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801428:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80142b:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80142d:	eb 0f                	jmp    80143e <vprintfmt+0x1d2>
					putch(padc, putdat);
  80142f:	83 ec 08             	sub    $0x8,%esp
  801432:	53                   	push   %ebx
  801433:	ff 75 e0             	pushl  -0x20(%ebp)
  801436:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801438:	83 ef 01             	sub    $0x1,%edi
  80143b:	83 c4 10             	add    $0x10,%esp
  80143e:	85 ff                	test   %edi,%edi
  801440:	7f ed                	jg     80142f <vprintfmt+0x1c3>
  801442:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801445:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  801448:	85 c9                	test   %ecx,%ecx
  80144a:	b8 00 00 00 00       	mov    $0x0,%eax
  80144f:	0f 49 c1             	cmovns %ecx,%eax
  801452:	29 c1                	sub    %eax,%ecx
  801454:	89 75 08             	mov    %esi,0x8(%ebp)
  801457:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80145a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80145d:	89 cb                	mov    %ecx,%ebx
  80145f:	eb 4d                	jmp    8014ae <vprintfmt+0x242>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801461:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801465:	74 1b                	je     801482 <vprintfmt+0x216>
  801467:	0f be c0             	movsbl %al,%eax
  80146a:	83 e8 20             	sub    $0x20,%eax
  80146d:	83 f8 5e             	cmp    $0x5e,%eax
  801470:	76 10                	jbe    801482 <vprintfmt+0x216>
					putch('?', putdat);
  801472:	83 ec 08             	sub    $0x8,%esp
  801475:	ff 75 0c             	pushl  0xc(%ebp)
  801478:	6a 3f                	push   $0x3f
  80147a:	ff 55 08             	call   *0x8(%ebp)
  80147d:	83 c4 10             	add    $0x10,%esp
  801480:	eb 0d                	jmp    80148f <vprintfmt+0x223>
				else
					putch(ch, putdat);
  801482:	83 ec 08             	sub    $0x8,%esp
  801485:	ff 75 0c             	pushl  0xc(%ebp)
  801488:	52                   	push   %edx
  801489:	ff 55 08             	call   *0x8(%ebp)
  80148c:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80148f:	83 eb 01             	sub    $0x1,%ebx
  801492:	eb 1a                	jmp    8014ae <vprintfmt+0x242>
  801494:	89 75 08             	mov    %esi,0x8(%ebp)
  801497:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80149a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80149d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014a0:	eb 0c                	jmp    8014ae <vprintfmt+0x242>
  8014a2:	89 75 08             	mov    %esi,0x8(%ebp)
  8014a5:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8014a8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014ab:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014ae:	83 c7 01             	add    $0x1,%edi
  8014b1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8014b5:	0f be d0             	movsbl %al,%edx
  8014b8:	85 d2                	test   %edx,%edx
  8014ba:	74 23                	je     8014df <vprintfmt+0x273>
  8014bc:	85 f6                	test   %esi,%esi
  8014be:	78 a1                	js     801461 <vprintfmt+0x1f5>
  8014c0:	83 ee 01             	sub    $0x1,%esi
  8014c3:	79 9c                	jns    801461 <vprintfmt+0x1f5>
  8014c5:	89 df                	mov    %ebx,%edi
  8014c7:	8b 75 08             	mov    0x8(%ebp),%esi
  8014ca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014cd:	eb 18                	jmp    8014e7 <vprintfmt+0x27b>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014cf:	83 ec 08             	sub    $0x8,%esp
  8014d2:	53                   	push   %ebx
  8014d3:	6a 20                	push   $0x20
  8014d5:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014d7:	83 ef 01             	sub    $0x1,%edi
  8014da:	83 c4 10             	add    $0x10,%esp
  8014dd:	eb 08                	jmp    8014e7 <vprintfmt+0x27b>
  8014df:	89 df                	mov    %ebx,%edi
  8014e1:	8b 75 08             	mov    0x8(%ebp),%esi
  8014e4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014e7:	85 ff                	test   %edi,%edi
  8014e9:	7f e4                	jg     8014cf <vprintfmt+0x263>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014ee:	e9 9f fd ff ff       	jmp    801292 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014f3:	83 7d d0 01          	cmpl   $0x1,-0x30(%ebp)
  8014f7:	7e 16                	jle    80150f <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  8014f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8014fc:	8d 50 08             	lea    0x8(%eax),%edx
  8014ff:	89 55 14             	mov    %edx,0x14(%ebp)
  801502:	8b 50 04             	mov    0x4(%eax),%edx
  801505:	8b 00                	mov    (%eax),%eax
  801507:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80150a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80150d:	eb 34                	jmp    801543 <vprintfmt+0x2d7>
	else if (lflag)
  80150f:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  801513:	74 18                	je     80152d <vprintfmt+0x2c1>
		return va_arg(*ap, long);
  801515:	8b 45 14             	mov    0x14(%ebp),%eax
  801518:	8d 50 04             	lea    0x4(%eax),%edx
  80151b:	89 55 14             	mov    %edx,0x14(%ebp)
  80151e:	8b 00                	mov    (%eax),%eax
  801520:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801523:	89 c1                	mov    %eax,%ecx
  801525:	c1 f9 1f             	sar    $0x1f,%ecx
  801528:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80152b:	eb 16                	jmp    801543 <vprintfmt+0x2d7>
	else
		return va_arg(*ap, int);
  80152d:	8b 45 14             	mov    0x14(%ebp),%eax
  801530:	8d 50 04             	lea    0x4(%eax),%edx
  801533:	89 55 14             	mov    %edx,0x14(%ebp)
  801536:	8b 00                	mov    (%eax),%eax
  801538:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80153b:	89 c1                	mov    %eax,%ecx
  80153d:	c1 f9 1f             	sar    $0x1f,%ecx
  801540:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801543:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801546:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801549:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80154e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801552:	0f 89 88 00 00 00    	jns    8015e0 <vprintfmt+0x374>
				putch('-', putdat);
  801558:	83 ec 08             	sub    $0x8,%esp
  80155b:	53                   	push   %ebx
  80155c:	6a 2d                	push   $0x2d
  80155e:	ff d6                	call   *%esi
				num = -(long long) num;
  801560:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801563:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801566:	f7 d8                	neg    %eax
  801568:	83 d2 00             	adc    $0x0,%edx
  80156b:	f7 da                	neg    %edx
  80156d:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801570:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801575:	eb 69                	jmp    8015e0 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801577:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80157a:	8d 45 14             	lea    0x14(%ebp),%eax
  80157d:	e8 76 fc ff ff       	call   8011f8 <getuint>
			base = 10;
  801582:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801587:	eb 57                	jmp    8015e0 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  801589:	83 ec 08             	sub    $0x8,%esp
  80158c:	53                   	push   %ebx
  80158d:	6a 30                	push   $0x30
  80158f:	ff d6                	call   *%esi
			num = getuint(&ap, lflag);
  801591:	8b 55 d0             	mov    -0x30(%ebp),%edx
  801594:	8d 45 14             	lea    0x14(%ebp),%eax
  801597:	e8 5c fc ff ff       	call   8011f8 <getuint>
			base = 8;
			goto number;
  80159c:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  80159f:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8015a4:	eb 3a                	jmp    8015e0 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  8015a6:	83 ec 08             	sub    $0x8,%esp
  8015a9:	53                   	push   %ebx
  8015aa:	6a 30                	push   $0x30
  8015ac:	ff d6                	call   *%esi
			putch('x', putdat);
  8015ae:	83 c4 08             	add    $0x8,%esp
  8015b1:	53                   	push   %ebx
  8015b2:	6a 78                	push   $0x78
  8015b4:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8015b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8015b9:	8d 50 04             	lea    0x4(%eax),%edx
  8015bc:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8015bf:	8b 00                	mov    (%eax),%eax
  8015c1:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015c6:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8015c9:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8015ce:	eb 10                	jmp    8015e0 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8015d0:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8015d3:	8d 45 14             	lea    0x14(%ebp),%eax
  8015d6:	e8 1d fc ff ff       	call   8011f8 <getuint>
			base = 16;
  8015db:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8015e0:	83 ec 0c             	sub    $0xc,%esp
  8015e3:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015e7:	57                   	push   %edi
  8015e8:	ff 75 e0             	pushl  -0x20(%ebp)
  8015eb:	51                   	push   %ecx
  8015ec:	52                   	push   %edx
  8015ed:	50                   	push   %eax
  8015ee:	89 da                	mov    %ebx,%edx
  8015f0:	89 f0                	mov    %esi,%eax
  8015f2:	e8 52 fb ff ff       	call   801149 <printnum>
			break;
  8015f7:	83 c4 20             	add    $0x20,%esp
  8015fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015fd:	e9 90 fc ff ff       	jmp    801292 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801602:	83 ec 08             	sub    $0x8,%esp
  801605:	53                   	push   %ebx
  801606:	52                   	push   %edx
  801607:	ff d6                	call   *%esi
			break;
  801609:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80160c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80160f:	e9 7e fc ff ff       	jmp    801292 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801614:	83 ec 08             	sub    $0x8,%esp
  801617:	53                   	push   %ebx
  801618:	6a 25                	push   $0x25
  80161a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80161c:	83 c4 10             	add    $0x10,%esp
  80161f:	eb 03                	jmp    801624 <vprintfmt+0x3b8>
  801621:	83 ef 01             	sub    $0x1,%edi
  801624:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801628:	75 f7                	jne    801621 <vprintfmt+0x3b5>
  80162a:	e9 63 fc ff ff       	jmp    801292 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80162f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801632:	5b                   	pop    %ebx
  801633:	5e                   	pop    %esi
  801634:	5f                   	pop    %edi
  801635:	5d                   	pop    %ebp
  801636:	c3                   	ret    

00801637 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801637:	55                   	push   %ebp
  801638:	89 e5                	mov    %esp,%ebp
  80163a:	83 ec 18             	sub    $0x18,%esp
  80163d:	8b 45 08             	mov    0x8(%ebp),%eax
  801640:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801643:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801646:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80164a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80164d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801654:	85 c0                	test   %eax,%eax
  801656:	74 26                	je     80167e <vsnprintf+0x47>
  801658:	85 d2                	test   %edx,%edx
  80165a:	7e 22                	jle    80167e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80165c:	ff 75 14             	pushl  0x14(%ebp)
  80165f:	ff 75 10             	pushl  0x10(%ebp)
  801662:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801665:	50                   	push   %eax
  801666:	68 32 12 80 00       	push   $0x801232
  80166b:	e8 fc fb ff ff       	call   80126c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801670:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801673:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801676:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801679:	83 c4 10             	add    $0x10,%esp
  80167c:	eb 05                	jmp    801683 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80167e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801683:	c9                   	leave  
  801684:	c3                   	ret    

00801685 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801685:	55                   	push   %ebp
  801686:	89 e5                	mov    %esp,%ebp
  801688:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80168b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80168e:	50                   	push   %eax
  80168f:	ff 75 10             	pushl  0x10(%ebp)
  801692:	ff 75 0c             	pushl  0xc(%ebp)
  801695:	ff 75 08             	pushl  0x8(%ebp)
  801698:	e8 9a ff ff ff       	call   801637 <vsnprintf>
	va_end(ap);

	return rc;
}
  80169d:	c9                   	leave  
  80169e:	c3                   	ret    

0080169f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80169f:	55                   	push   %ebp
  8016a0:	89 e5                	mov    %esp,%ebp
  8016a2:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8016aa:	eb 03                	jmp    8016af <strlen+0x10>
		n++;
  8016ac:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8016af:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016b3:	75 f7                	jne    8016ac <strlen+0xd>
		n++;
	return n;
}
  8016b5:	5d                   	pop    %ebp
  8016b6:	c3                   	ret    

008016b7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016b7:	55                   	push   %ebp
  8016b8:	89 e5                	mov    %esp,%ebp
  8016ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016bd:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8016c5:	eb 03                	jmp    8016ca <strnlen+0x13>
		n++;
  8016c7:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016ca:	39 c2                	cmp    %eax,%edx
  8016cc:	74 08                	je     8016d6 <strnlen+0x1f>
  8016ce:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8016d2:	75 f3                	jne    8016c7 <strnlen+0x10>
  8016d4:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8016d6:	5d                   	pop    %ebp
  8016d7:	c3                   	ret    

008016d8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016d8:	55                   	push   %ebp
  8016d9:	89 e5                	mov    %esp,%ebp
  8016db:	53                   	push   %ebx
  8016dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8016df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016e2:	89 c2                	mov    %eax,%edx
  8016e4:	83 c2 01             	add    $0x1,%edx
  8016e7:	83 c1 01             	add    $0x1,%ecx
  8016ea:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8016ee:	88 5a ff             	mov    %bl,-0x1(%edx)
  8016f1:	84 db                	test   %bl,%bl
  8016f3:	75 ef                	jne    8016e4 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8016f5:	5b                   	pop    %ebx
  8016f6:	5d                   	pop    %ebp
  8016f7:	c3                   	ret    

008016f8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016f8:	55                   	push   %ebp
  8016f9:	89 e5                	mov    %esp,%ebp
  8016fb:	53                   	push   %ebx
  8016fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016ff:	53                   	push   %ebx
  801700:	e8 9a ff ff ff       	call   80169f <strlen>
  801705:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801708:	ff 75 0c             	pushl  0xc(%ebp)
  80170b:	01 d8                	add    %ebx,%eax
  80170d:	50                   	push   %eax
  80170e:	e8 c5 ff ff ff       	call   8016d8 <strcpy>
	return dst;
}
  801713:	89 d8                	mov    %ebx,%eax
  801715:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801718:	c9                   	leave  
  801719:	c3                   	ret    

0080171a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80171a:	55                   	push   %ebp
  80171b:	89 e5                	mov    %esp,%ebp
  80171d:	56                   	push   %esi
  80171e:	53                   	push   %ebx
  80171f:	8b 75 08             	mov    0x8(%ebp),%esi
  801722:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801725:	89 f3                	mov    %esi,%ebx
  801727:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80172a:	89 f2                	mov    %esi,%edx
  80172c:	eb 0f                	jmp    80173d <strncpy+0x23>
		*dst++ = *src;
  80172e:	83 c2 01             	add    $0x1,%edx
  801731:	0f b6 01             	movzbl (%ecx),%eax
  801734:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801737:	80 39 01             	cmpb   $0x1,(%ecx)
  80173a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80173d:	39 da                	cmp    %ebx,%edx
  80173f:	75 ed                	jne    80172e <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801741:	89 f0                	mov    %esi,%eax
  801743:	5b                   	pop    %ebx
  801744:	5e                   	pop    %esi
  801745:	5d                   	pop    %ebp
  801746:	c3                   	ret    

00801747 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801747:	55                   	push   %ebp
  801748:	89 e5                	mov    %esp,%ebp
  80174a:	56                   	push   %esi
  80174b:	53                   	push   %ebx
  80174c:	8b 75 08             	mov    0x8(%ebp),%esi
  80174f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801752:	8b 55 10             	mov    0x10(%ebp),%edx
  801755:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801757:	85 d2                	test   %edx,%edx
  801759:	74 21                	je     80177c <strlcpy+0x35>
  80175b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80175f:	89 f2                	mov    %esi,%edx
  801761:	eb 09                	jmp    80176c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801763:	83 c2 01             	add    $0x1,%edx
  801766:	83 c1 01             	add    $0x1,%ecx
  801769:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80176c:	39 c2                	cmp    %eax,%edx
  80176e:	74 09                	je     801779 <strlcpy+0x32>
  801770:	0f b6 19             	movzbl (%ecx),%ebx
  801773:	84 db                	test   %bl,%bl
  801775:	75 ec                	jne    801763 <strlcpy+0x1c>
  801777:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801779:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80177c:	29 f0                	sub    %esi,%eax
}
  80177e:	5b                   	pop    %ebx
  80177f:	5e                   	pop    %esi
  801780:	5d                   	pop    %ebp
  801781:	c3                   	ret    

00801782 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801782:	55                   	push   %ebp
  801783:	89 e5                	mov    %esp,%ebp
  801785:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801788:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80178b:	eb 06                	jmp    801793 <strcmp+0x11>
		p++, q++;
  80178d:	83 c1 01             	add    $0x1,%ecx
  801790:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801793:	0f b6 01             	movzbl (%ecx),%eax
  801796:	84 c0                	test   %al,%al
  801798:	74 04                	je     80179e <strcmp+0x1c>
  80179a:	3a 02                	cmp    (%edx),%al
  80179c:	74 ef                	je     80178d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80179e:	0f b6 c0             	movzbl %al,%eax
  8017a1:	0f b6 12             	movzbl (%edx),%edx
  8017a4:	29 d0                	sub    %edx,%eax
}
  8017a6:	5d                   	pop    %ebp
  8017a7:	c3                   	ret    

008017a8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017a8:	55                   	push   %ebp
  8017a9:	89 e5                	mov    %esp,%ebp
  8017ab:	53                   	push   %ebx
  8017ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8017af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017b2:	89 c3                	mov    %eax,%ebx
  8017b4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017b7:	eb 06                	jmp    8017bf <strncmp+0x17>
		n--, p++, q++;
  8017b9:	83 c0 01             	add    $0x1,%eax
  8017bc:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017bf:	39 d8                	cmp    %ebx,%eax
  8017c1:	74 15                	je     8017d8 <strncmp+0x30>
  8017c3:	0f b6 08             	movzbl (%eax),%ecx
  8017c6:	84 c9                	test   %cl,%cl
  8017c8:	74 04                	je     8017ce <strncmp+0x26>
  8017ca:	3a 0a                	cmp    (%edx),%cl
  8017cc:	74 eb                	je     8017b9 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017ce:	0f b6 00             	movzbl (%eax),%eax
  8017d1:	0f b6 12             	movzbl (%edx),%edx
  8017d4:	29 d0                	sub    %edx,%eax
  8017d6:	eb 05                	jmp    8017dd <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017d8:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8017dd:	5b                   	pop    %ebx
  8017de:	5d                   	pop    %ebp
  8017df:	c3                   	ret    

008017e0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017e0:	55                   	push   %ebp
  8017e1:	89 e5                	mov    %esp,%ebp
  8017e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017ea:	eb 07                	jmp    8017f3 <strchr+0x13>
		if (*s == c)
  8017ec:	38 ca                	cmp    %cl,%dl
  8017ee:	74 0f                	je     8017ff <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017f0:	83 c0 01             	add    $0x1,%eax
  8017f3:	0f b6 10             	movzbl (%eax),%edx
  8017f6:	84 d2                	test   %dl,%dl
  8017f8:	75 f2                	jne    8017ec <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8017fa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017ff:	5d                   	pop    %ebp
  801800:	c3                   	ret    

00801801 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801801:	55                   	push   %ebp
  801802:	89 e5                	mov    %esp,%ebp
  801804:	8b 45 08             	mov    0x8(%ebp),%eax
  801807:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80180b:	eb 03                	jmp    801810 <strfind+0xf>
  80180d:	83 c0 01             	add    $0x1,%eax
  801810:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801813:	38 ca                	cmp    %cl,%dl
  801815:	74 04                	je     80181b <strfind+0x1a>
  801817:	84 d2                	test   %dl,%dl
  801819:	75 f2                	jne    80180d <strfind+0xc>
			break;
	return (char *) s;
}
  80181b:	5d                   	pop    %ebp
  80181c:	c3                   	ret    

0080181d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80181d:	55                   	push   %ebp
  80181e:	89 e5                	mov    %esp,%ebp
  801820:	57                   	push   %edi
  801821:	56                   	push   %esi
  801822:	53                   	push   %ebx
  801823:	8b 7d 08             	mov    0x8(%ebp),%edi
  801826:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801829:	85 c9                	test   %ecx,%ecx
  80182b:	74 36                	je     801863 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80182d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801833:	75 28                	jne    80185d <memset+0x40>
  801835:	f6 c1 03             	test   $0x3,%cl
  801838:	75 23                	jne    80185d <memset+0x40>
		c &= 0xFF;
  80183a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80183e:	89 d3                	mov    %edx,%ebx
  801840:	c1 e3 08             	shl    $0x8,%ebx
  801843:	89 d6                	mov    %edx,%esi
  801845:	c1 e6 18             	shl    $0x18,%esi
  801848:	89 d0                	mov    %edx,%eax
  80184a:	c1 e0 10             	shl    $0x10,%eax
  80184d:	09 f0                	or     %esi,%eax
  80184f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801851:	89 d8                	mov    %ebx,%eax
  801853:	09 d0                	or     %edx,%eax
  801855:	c1 e9 02             	shr    $0x2,%ecx
  801858:	fc                   	cld    
  801859:	f3 ab                	rep stos %eax,%es:(%edi)
  80185b:	eb 06                	jmp    801863 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80185d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801860:	fc                   	cld    
  801861:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801863:	89 f8                	mov    %edi,%eax
  801865:	5b                   	pop    %ebx
  801866:	5e                   	pop    %esi
  801867:	5f                   	pop    %edi
  801868:	5d                   	pop    %ebp
  801869:	c3                   	ret    

0080186a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80186a:	55                   	push   %ebp
  80186b:	89 e5                	mov    %esp,%ebp
  80186d:	57                   	push   %edi
  80186e:	56                   	push   %esi
  80186f:	8b 45 08             	mov    0x8(%ebp),%eax
  801872:	8b 75 0c             	mov    0xc(%ebp),%esi
  801875:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801878:	39 c6                	cmp    %eax,%esi
  80187a:	73 35                	jae    8018b1 <memmove+0x47>
  80187c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80187f:	39 d0                	cmp    %edx,%eax
  801881:	73 2e                	jae    8018b1 <memmove+0x47>
		s += n;
		d += n;
  801883:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801886:	89 d6                	mov    %edx,%esi
  801888:	09 fe                	or     %edi,%esi
  80188a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801890:	75 13                	jne    8018a5 <memmove+0x3b>
  801892:	f6 c1 03             	test   $0x3,%cl
  801895:	75 0e                	jne    8018a5 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801897:	83 ef 04             	sub    $0x4,%edi
  80189a:	8d 72 fc             	lea    -0x4(%edx),%esi
  80189d:	c1 e9 02             	shr    $0x2,%ecx
  8018a0:	fd                   	std    
  8018a1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018a3:	eb 09                	jmp    8018ae <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018a5:	83 ef 01             	sub    $0x1,%edi
  8018a8:	8d 72 ff             	lea    -0x1(%edx),%esi
  8018ab:	fd                   	std    
  8018ac:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018ae:	fc                   	cld    
  8018af:	eb 1d                	jmp    8018ce <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018b1:	89 f2                	mov    %esi,%edx
  8018b3:	09 c2                	or     %eax,%edx
  8018b5:	f6 c2 03             	test   $0x3,%dl
  8018b8:	75 0f                	jne    8018c9 <memmove+0x5f>
  8018ba:	f6 c1 03             	test   $0x3,%cl
  8018bd:	75 0a                	jne    8018c9 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8018bf:	c1 e9 02             	shr    $0x2,%ecx
  8018c2:	89 c7                	mov    %eax,%edi
  8018c4:	fc                   	cld    
  8018c5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018c7:	eb 05                	jmp    8018ce <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018c9:	89 c7                	mov    %eax,%edi
  8018cb:	fc                   	cld    
  8018cc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018ce:	5e                   	pop    %esi
  8018cf:	5f                   	pop    %edi
  8018d0:	5d                   	pop    %ebp
  8018d1:	c3                   	ret    

008018d2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018d2:	55                   	push   %ebp
  8018d3:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018d5:	ff 75 10             	pushl  0x10(%ebp)
  8018d8:	ff 75 0c             	pushl  0xc(%ebp)
  8018db:	ff 75 08             	pushl  0x8(%ebp)
  8018de:	e8 87 ff ff ff       	call   80186a <memmove>
}
  8018e3:	c9                   	leave  
  8018e4:	c3                   	ret    

008018e5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018e5:	55                   	push   %ebp
  8018e6:	89 e5                	mov    %esp,%ebp
  8018e8:	56                   	push   %esi
  8018e9:	53                   	push   %ebx
  8018ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ed:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018f0:	89 c6                	mov    %eax,%esi
  8018f2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018f5:	eb 1a                	jmp    801911 <memcmp+0x2c>
		if (*s1 != *s2)
  8018f7:	0f b6 08             	movzbl (%eax),%ecx
  8018fa:	0f b6 1a             	movzbl (%edx),%ebx
  8018fd:	38 d9                	cmp    %bl,%cl
  8018ff:	74 0a                	je     80190b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801901:	0f b6 c1             	movzbl %cl,%eax
  801904:	0f b6 db             	movzbl %bl,%ebx
  801907:	29 d8                	sub    %ebx,%eax
  801909:	eb 0f                	jmp    80191a <memcmp+0x35>
		s1++, s2++;
  80190b:	83 c0 01             	add    $0x1,%eax
  80190e:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801911:	39 f0                	cmp    %esi,%eax
  801913:	75 e2                	jne    8018f7 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801915:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80191a:	5b                   	pop    %ebx
  80191b:	5e                   	pop    %esi
  80191c:	5d                   	pop    %ebp
  80191d:	c3                   	ret    

0080191e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80191e:	55                   	push   %ebp
  80191f:	89 e5                	mov    %esp,%ebp
  801921:	53                   	push   %ebx
  801922:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801925:	89 c1                	mov    %eax,%ecx
  801927:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80192a:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80192e:	eb 0a                	jmp    80193a <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801930:	0f b6 10             	movzbl (%eax),%edx
  801933:	39 da                	cmp    %ebx,%edx
  801935:	74 07                	je     80193e <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801937:	83 c0 01             	add    $0x1,%eax
  80193a:	39 c8                	cmp    %ecx,%eax
  80193c:	72 f2                	jb     801930 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80193e:	5b                   	pop    %ebx
  80193f:	5d                   	pop    %ebp
  801940:	c3                   	ret    

00801941 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801941:	55                   	push   %ebp
  801942:	89 e5                	mov    %esp,%ebp
  801944:	57                   	push   %edi
  801945:	56                   	push   %esi
  801946:	53                   	push   %ebx
  801947:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80194a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80194d:	eb 03                	jmp    801952 <strtol+0x11>
		s++;
  80194f:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801952:	0f b6 01             	movzbl (%ecx),%eax
  801955:	3c 20                	cmp    $0x20,%al
  801957:	74 f6                	je     80194f <strtol+0xe>
  801959:	3c 09                	cmp    $0x9,%al
  80195b:	74 f2                	je     80194f <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80195d:	3c 2b                	cmp    $0x2b,%al
  80195f:	75 0a                	jne    80196b <strtol+0x2a>
		s++;
  801961:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801964:	bf 00 00 00 00       	mov    $0x0,%edi
  801969:	eb 11                	jmp    80197c <strtol+0x3b>
  80196b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801970:	3c 2d                	cmp    $0x2d,%al
  801972:	75 08                	jne    80197c <strtol+0x3b>
		s++, neg = 1;
  801974:	83 c1 01             	add    $0x1,%ecx
  801977:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80197c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801982:	75 15                	jne    801999 <strtol+0x58>
  801984:	80 39 30             	cmpb   $0x30,(%ecx)
  801987:	75 10                	jne    801999 <strtol+0x58>
  801989:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80198d:	75 7c                	jne    801a0b <strtol+0xca>
		s += 2, base = 16;
  80198f:	83 c1 02             	add    $0x2,%ecx
  801992:	bb 10 00 00 00       	mov    $0x10,%ebx
  801997:	eb 16                	jmp    8019af <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801999:	85 db                	test   %ebx,%ebx
  80199b:	75 12                	jne    8019af <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80199d:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019a2:	80 39 30             	cmpb   $0x30,(%ecx)
  8019a5:	75 08                	jne    8019af <strtol+0x6e>
		s++, base = 8;
  8019a7:	83 c1 01             	add    $0x1,%ecx
  8019aa:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8019af:	b8 00 00 00 00       	mov    $0x0,%eax
  8019b4:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019b7:	0f b6 11             	movzbl (%ecx),%edx
  8019ba:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019bd:	89 f3                	mov    %esi,%ebx
  8019bf:	80 fb 09             	cmp    $0x9,%bl
  8019c2:	77 08                	ja     8019cc <strtol+0x8b>
			dig = *s - '0';
  8019c4:	0f be d2             	movsbl %dl,%edx
  8019c7:	83 ea 30             	sub    $0x30,%edx
  8019ca:	eb 22                	jmp    8019ee <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8019cc:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019cf:	89 f3                	mov    %esi,%ebx
  8019d1:	80 fb 19             	cmp    $0x19,%bl
  8019d4:	77 08                	ja     8019de <strtol+0x9d>
			dig = *s - 'a' + 10;
  8019d6:	0f be d2             	movsbl %dl,%edx
  8019d9:	83 ea 57             	sub    $0x57,%edx
  8019dc:	eb 10                	jmp    8019ee <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8019de:	8d 72 bf             	lea    -0x41(%edx),%esi
  8019e1:	89 f3                	mov    %esi,%ebx
  8019e3:	80 fb 19             	cmp    $0x19,%bl
  8019e6:	77 16                	ja     8019fe <strtol+0xbd>
			dig = *s - 'A' + 10;
  8019e8:	0f be d2             	movsbl %dl,%edx
  8019eb:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8019ee:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019f1:	7d 0b                	jge    8019fe <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8019f3:	83 c1 01             	add    $0x1,%ecx
  8019f6:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019fa:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8019fc:	eb b9                	jmp    8019b7 <strtol+0x76>

	if (endptr)
  8019fe:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a02:	74 0d                	je     801a11 <strtol+0xd0>
		*endptr = (char *) s;
  801a04:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a07:	89 0e                	mov    %ecx,(%esi)
  801a09:	eb 06                	jmp    801a11 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a0b:	85 db                	test   %ebx,%ebx
  801a0d:	74 98                	je     8019a7 <strtol+0x66>
  801a0f:	eb 9e                	jmp    8019af <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801a11:	89 c2                	mov    %eax,%edx
  801a13:	f7 da                	neg    %edx
  801a15:	85 ff                	test   %edi,%edi
  801a17:	0f 45 c2             	cmovne %edx,%eax
}
  801a1a:	5b                   	pop    %ebx
  801a1b:	5e                   	pop    %esi
  801a1c:	5f                   	pop    %edi
  801a1d:	5d                   	pop    %ebp
  801a1e:	c3                   	ret    

00801a1f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a1f:	55                   	push   %ebp
  801a20:	89 e5                	mov    %esp,%ebp
  801a22:	56                   	push   %esi
  801a23:	53                   	push   %ebx
  801a24:	8b 75 08             	mov    0x8(%ebp),%esi
  801a27:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a2a:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_recv not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  801a2d:	85 c0                	test   %eax,%eax
  801a2f:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a34:	0f 44 c2             	cmove  %edx,%eax

    int r = sys_ipc_recv(pg);
  801a37:	83 ec 0c             	sub    $0xc,%esp
  801a3a:	50                   	push   %eax
  801a3b:	e8 f1 e8 ff ff       	call   800331 <sys_ipc_recv>
    int from_env = 0, perm = 0;
    if (r == 0) {
  801a40:	83 c4 10             	add    $0x10,%esp
  801a43:	85 c0                	test   %eax,%eax
  801a45:	75 10                	jne    801a57 <ipc_recv+0x38>
        from_env = thisenv->env_ipc_from;
  801a47:	a1 04 40 80 00       	mov    0x804004,%eax
  801a4c:	8b 48 74             	mov    0x74(%eax),%ecx
        perm = thisenv->env_ipc_perm;
  801a4f:	8b 50 78             	mov    0x78(%eax),%edx
        r = thisenv->env_ipc_value;
  801a52:	8b 40 70             	mov    0x70(%eax),%eax
  801a55:	eb 0a                	jmp    801a61 <ipc_recv+0x42>
    } else {
        from_env = 0;
        perm = 0;
  801a57:	ba 00 00 00 00       	mov    $0x0,%edx
    if (r == 0) {
        from_env = thisenv->env_ipc_from;
        perm = thisenv->env_ipc_perm;
        r = thisenv->env_ipc_value;
    } else {
        from_env = 0;
  801a5c:	b9 00 00 00 00       	mov    $0x0,%ecx
        perm = 0;
    }

    if (from_env_store) *from_env_store = from_env;
  801a61:	85 f6                	test   %esi,%esi
  801a63:	74 02                	je     801a67 <ipc_recv+0x48>
  801a65:	89 0e                	mov    %ecx,(%esi)
    if (perm_store) *perm_store = perm;
  801a67:	85 db                	test   %ebx,%ebx
  801a69:	74 02                	je     801a6d <ipc_recv+0x4e>
  801a6b:	89 13                	mov    %edx,(%ebx)

    return r;
}
  801a6d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a70:	5b                   	pop    %ebx
  801a71:	5e                   	pop    %esi
  801a72:	5d                   	pop    %ebp
  801a73:	c3                   	ret    

00801a74 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a74:	55                   	push   %ebp
  801a75:	89 e5                	mov    %esp,%ebp
  801a77:	57                   	push   %edi
  801a78:	56                   	push   %esi
  801a79:	53                   	push   %ebx
  801a7a:	83 ec 0c             	sub    $0xc,%esp
  801a7d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a80:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a83:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  801a86:	85 db                	test   %ebx,%ebx
  801a88:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801a8d:	0f 44 d8             	cmove  %eax,%ebx
  801a90:	eb 1c                	jmp    801aae <ipc_send+0x3a>

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        if (ret != -E_IPC_NOT_RECV)
  801a92:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a95:	74 12                	je     801aa9 <ipc_send+0x35>
            panic("ipc_send error %e", ret);
  801a97:	50                   	push   %eax
  801a98:	68 20 22 80 00       	push   $0x802220
  801a9d:	6a 40                	push   $0x40
  801a9f:	68 32 22 80 00       	push   $0x802232
  801aa4:	e8 b3 f5 ff ff       	call   80105c <_panic>
        sys_yield();
  801aa9:	e8 b4 e6 ff ff       	call   800162 <sys_yield>
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801aae:	ff 75 14             	pushl  0x14(%ebp)
  801ab1:	53                   	push   %ebx
  801ab2:	56                   	push   %esi
  801ab3:	57                   	push   %edi
  801ab4:	e8 55 e8 ff ff       	call   80030e <sys_ipc_try_send>
  801ab9:	83 c4 10             	add    $0x10,%esp
  801abc:	85 c0                	test   %eax,%eax
  801abe:	75 d2                	jne    801a92 <ipc_send+0x1e>
        if (ret != -E_IPC_NOT_RECV)
            panic("ipc_send error %e", ret);
        sys_yield();
    }
}
  801ac0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ac3:	5b                   	pop    %ebx
  801ac4:	5e                   	pop    %esi
  801ac5:	5f                   	pop    %edi
  801ac6:	5d                   	pop    %ebp
  801ac7:	c3                   	ret    

00801ac8 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ac8:	55                   	push   %ebp
  801ac9:	89 e5                	mov    %esp,%ebp
  801acb:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ace:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ad3:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ad6:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801adc:	8b 52 50             	mov    0x50(%edx),%edx
  801adf:	39 ca                	cmp    %ecx,%edx
  801ae1:	75 0d                	jne    801af0 <ipc_find_env+0x28>
			return envs[i].env_id;
  801ae3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ae6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801aeb:	8b 40 48             	mov    0x48(%eax),%eax
  801aee:	eb 0f                	jmp    801aff <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801af0:	83 c0 01             	add    $0x1,%eax
  801af3:	3d 00 04 00 00       	cmp    $0x400,%eax
  801af8:	75 d9                	jne    801ad3 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801afa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801aff:	5d                   	pop    %ebp
  801b00:	c3                   	ret    

00801b01 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b01:	55                   	push   %ebp
  801b02:	89 e5                	mov    %esp,%ebp
  801b04:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b07:	89 d0                	mov    %edx,%eax
  801b09:	c1 e8 16             	shr    $0x16,%eax
  801b0c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b13:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b18:	f6 c1 01             	test   $0x1,%cl
  801b1b:	74 1d                	je     801b3a <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b1d:	c1 ea 0c             	shr    $0xc,%edx
  801b20:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b27:	f6 c2 01             	test   $0x1,%dl
  801b2a:	74 0e                	je     801b3a <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b2c:	c1 ea 0c             	shr    $0xc,%edx
  801b2f:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b36:	ef 
  801b37:	0f b7 c0             	movzwl %ax,%eax
}
  801b3a:	5d                   	pop    %ebp
  801b3b:	c3                   	ret    
  801b3c:	66 90                	xchg   %ax,%ax
  801b3e:	66 90                	xchg   %ax,%ax

00801b40 <__udivdi3>:
  801b40:	55                   	push   %ebp
  801b41:	57                   	push   %edi
  801b42:	56                   	push   %esi
  801b43:	53                   	push   %ebx
  801b44:	83 ec 1c             	sub    $0x1c,%esp
  801b47:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801b4b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801b4f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801b53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801b57:	85 f6                	test   %esi,%esi
  801b59:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b5d:	89 ca                	mov    %ecx,%edx
  801b5f:	89 f8                	mov    %edi,%eax
  801b61:	75 3d                	jne    801ba0 <__udivdi3+0x60>
  801b63:	39 cf                	cmp    %ecx,%edi
  801b65:	0f 87 c5 00 00 00    	ja     801c30 <__udivdi3+0xf0>
  801b6b:	85 ff                	test   %edi,%edi
  801b6d:	89 fd                	mov    %edi,%ebp
  801b6f:	75 0b                	jne    801b7c <__udivdi3+0x3c>
  801b71:	b8 01 00 00 00       	mov    $0x1,%eax
  801b76:	31 d2                	xor    %edx,%edx
  801b78:	f7 f7                	div    %edi
  801b7a:	89 c5                	mov    %eax,%ebp
  801b7c:	89 c8                	mov    %ecx,%eax
  801b7e:	31 d2                	xor    %edx,%edx
  801b80:	f7 f5                	div    %ebp
  801b82:	89 c1                	mov    %eax,%ecx
  801b84:	89 d8                	mov    %ebx,%eax
  801b86:	89 cf                	mov    %ecx,%edi
  801b88:	f7 f5                	div    %ebp
  801b8a:	89 c3                	mov    %eax,%ebx
  801b8c:	89 d8                	mov    %ebx,%eax
  801b8e:	89 fa                	mov    %edi,%edx
  801b90:	83 c4 1c             	add    $0x1c,%esp
  801b93:	5b                   	pop    %ebx
  801b94:	5e                   	pop    %esi
  801b95:	5f                   	pop    %edi
  801b96:	5d                   	pop    %ebp
  801b97:	c3                   	ret    
  801b98:	90                   	nop
  801b99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ba0:	39 ce                	cmp    %ecx,%esi
  801ba2:	77 74                	ja     801c18 <__udivdi3+0xd8>
  801ba4:	0f bd fe             	bsr    %esi,%edi
  801ba7:	83 f7 1f             	xor    $0x1f,%edi
  801baa:	0f 84 98 00 00 00    	je     801c48 <__udivdi3+0x108>
  801bb0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801bb5:	89 f9                	mov    %edi,%ecx
  801bb7:	89 c5                	mov    %eax,%ebp
  801bb9:	29 fb                	sub    %edi,%ebx
  801bbb:	d3 e6                	shl    %cl,%esi
  801bbd:	89 d9                	mov    %ebx,%ecx
  801bbf:	d3 ed                	shr    %cl,%ebp
  801bc1:	89 f9                	mov    %edi,%ecx
  801bc3:	d3 e0                	shl    %cl,%eax
  801bc5:	09 ee                	or     %ebp,%esi
  801bc7:	89 d9                	mov    %ebx,%ecx
  801bc9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bcd:	89 d5                	mov    %edx,%ebp
  801bcf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801bd3:	d3 ed                	shr    %cl,%ebp
  801bd5:	89 f9                	mov    %edi,%ecx
  801bd7:	d3 e2                	shl    %cl,%edx
  801bd9:	89 d9                	mov    %ebx,%ecx
  801bdb:	d3 e8                	shr    %cl,%eax
  801bdd:	09 c2                	or     %eax,%edx
  801bdf:	89 d0                	mov    %edx,%eax
  801be1:	89 ea                	mov    %ebp,%edx
  801be3:	f7 f6                	div    %esi
  801be5:	89 d5                	mov    %edx,%ebp
  801be7:	89 c3                	mov    %eax,%ebx
  801be9:	f7 64 24 0c          	mull   0xc(%esp)
  801bed:	39 d5                	cmp    %edx,%ebp
  801bef:	72 10                	jb     801c01 <__udivdi3+0xc1>
  801bf1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801bf5:	89 f9                	mov    %edi,%ecx
  801bf7:	d3 e6                	shl    %cl,%esi
  801bf9:	39 c6                	cmp    %eax,%esi
  801bfb:	73 07                	jae    801c04 <__udivdi3+0xc4>
  801bfd:	39 d5                	cmp    %edx,%ebp
  801bff:	75 03                	jne    801c04 <__udivdi3+0xc4>
  801c01:	83 eb 01             	sub    $0x1,%ebx
  801c04:	31 ff                	xor    %edi,%edi
  801c06:	89 d8                	mov    %ebx,%eax
  801c08:	89 fa                	mov    %edi,%edx
  801c0a:	83 c4 1c             	add    $0x1c,%esp
  801c0d:	5b                   	pop    %ebx
  801c0e:	5e                   	pop    %esi
  801c0f:	5f                   	pop    %edi
  801c10:	5d                   	pop    %ebp
  801c11:	c3                   	ret    
  801c12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c18:	31 ff                	xor    %edi,%edi
  801c1a:	31 db                	xor    %ebx,%ebx
  801c1c:	89 d8                	mov    %ebx,%eax
  801c1e:	89 fa                	mov    %edi,%edx
  801c20:	83 c4 1c             	add    $0x1c,%esp
  801c23:	5b                   	pop    %ebx
  801c24:	5e                   	pop    %esi
  801c25:	5f                   	pop    %edi
  801c26:	5d                   	pop    %ebp
  801c27:	c3                   	ret    
  801c28:	90                   	nop
  801c29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c30:	89 d8                	mov    %ebx,%eax
  801c32:	f7 f7                	div    %edi
  801c34:	31 ff                	xor    %edi,%edi
  801c36:	89 c3                	mov    %eax,%ebx
  801c38:	89 d8                	mov    %ebx,%eax
  801c3a:	89 fa                	mov    %edi,%edx
  801c3c:	83 c4 1c             	add    $0x1c,%esp
  801c3f:	5b                   	pop    %ebx
  801c40:	5e                   	pop    %esi
  801c41:	5f                   	pop    %edi
  801c42:	5d                   	pop    %ebp
  801c43:	c3                   	ret    
  801c44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c48:	39 ce                	cmp    %ecx,%esi
  801c4a:	72 0c                	jb     801c58 <__udivdi3+0x118>
  801c4c:	31 db                	xor    %ebx,%ebx
  801c4e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801c52:	0f 87 34 ff ff ff    	ja     801b8c <__udivdi3+0x4c>
  801c58:	bb 01 00 00 00       	mov    $0x1,%ebx
  801c5d:	e9 2a ff ff ff       	jmp    801b8c <__udivdi3+0x4c>
  801c62:	66 90                	xchg   %ax,%ax
  801c64:	66 90                	xchg   %ax,%ax
  801c66:	66 90                	xchg   %ax,%ax
  801c68:	66 90                	xchg   %ax,%ax
  801c6a:	66 90                	xchg   %ax,%ax
  801c6c:	66 90                	xchg   %ax,%ax
  801c6e:	66 90                	xchg   %ax,%ax

00801c70 <__umoddi3>:
  801c70:	55                   	push   %ebp
  801c71:	57                   	push   %edi
  801c72:	56                   	push   %esi
  801c73:	53                   	push   %ebx
  801c74:	83 ec 1c             	sub    $0x1c,%esp
  801c77:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801c7b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801c7f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801c83:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c87:	85 d2                	test   %edx,%edx
  801c89:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801c8d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c91:	89 f3                	mov    %esi,%ebx
  801c93:	89 3c 24             	mov    %edi,(%esp)
  801c96:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c9a:	75 1c                	jne    801cb8 <__umoddi3+0x48>
  801c9c:	39 f7                	cmp    %esi,%edi
  801c9e:	76 50                	jbe    801cf0 <__umoddi3+0x80>
  801ca0:	89 c8                	mov    %ecx,%eax
  801ca2:	89 f2                	mov    %esi,%edx
  801ca4:	f7 f7                	div    %edi
  801ca6:	89 d0                	mov    %edx,%eax
  801ca8:	31 d2                	xor    %edx,%edx
  801caa:	83 c4 1c             	add    $0x1c,%esp
  801cad:	5b                   	pop    %ebx
  801cae:	5e                   	pop    %esi
  801caf:	5f                   	pop    %edi
  801cb0:	5d                   	pop    %ebp
  801cb1:	c3                   	ret    
  801cb2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cb8:	39 f2                	cmp    %esi,%edx
  801cba:	89 d0                	mov    %edx,%eax
  801cbc:	77 52                	ja     801d10 <__umoddi3+0xa0>
  801cbe:	0f bd ea             	bsr    %edx,%ebp
  801cc1:	83 f5 1f             	xor    $0x1f,%ebp
  801cc4:	75 5a                	jne    801d20 <__umoddi3+0xb0>
  801cc6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801cca:	0f 82 e0 00 00 00    	jb     801db0 <__umoddi3+0x140>
  801cd0:	39 0c 24             	cmp    %ecx,(%esp)
  801cd3:	0f 86 d7 00 00 00    	jbe    801db0 <__umoddi3+0x140>
  801cd9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801cdd:	8b 54 24 04          	mov    0x4(%esp),%edx
  801ce1:	83 c4 1c             	add    $0x1c,%esp
  801ce4:	5b                   	pop    %ebx
  801ce5:	5e                   	pop    %esi
  801ce6:	5f                   	pop    %edi
  801ce7:	5d                   	pop    %ebp
  801ce8:	c3                   	ret    
  801ce9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cf0:	85 ff                	test   %edi,%edi
  801cf2:	89 fd                	mov    %edi,%ebp
  801cf4:	75 0b                	jne    801d01 <__umoddi3+0x91>
  801cf6:	b8 01 00 00 00       	mov    $0x1,%eax
  801cfb:	31 d2                	xor    %edx,%edx
  801cfd:	f7 f7                	div    %edi
  801cff:	89 c5                	mov    %eax,%ebp
  801d01:	89 f0                	mov    %esi,%eax
  801d03:	31 d2                	xor    %edx,%edx
  801d05:	f7 f5                	div    %ebp
  801d07:	89 c8                	mov    %ecx,%eax
  801d09:	f7 f5                	div    %ebp
  801d0b:	89 d0                	mov    %edx,%eax
  801d0d:	eb 99                	jmp    801ca8 <__umoddi3+0x38>
  801d0f:	90                   	nop
  801d10:	89 c8                	mov    %ecx,%eax
  801d12:	89 f2                	mov    %esi,%edx
  801d14:	83 c4 1c             	add    $0x1c,%esp
  801d17:	5b                   	pop    %ebx
  801d18:	5e                   	pop    %esi
  801d19:	5f                   	pop    %edi
  801d1a:	5d                   	pop    %ebp
  801d1b:	c3                   	ret    
  801d1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d20:	8b 34 24             	mov    (%esp),%esi
  801d23:	bf 20 00 00 00       	mov    $0x20,%edi
  801d28:	89 e9                	mov    %ebp,%ecx
  801d2a:	29 ef                	sub    %ebp,%edi
  801d2c:	d3 e0                	shl    %cl,%eax
  801d2e:	89 f9                	mov    %edi,%ecx
  801d30:	89 f2                	mov    %esi,%edx
  801d32:	d3 ea                	shr    %cl,%edx
  801d34:	89 e9                	mov    %ebp,%ecx
  801d36:	09 c2                	or     %eax,%edx
  801d38:	89 d8                	mov    %ebx,%eax
  801d3a:	89 14 24             	mov    %edx,(%esp)
  801d3d:	89 f2                	mov    %esi,%edx
  801d3f:	d3 e2                	shl    %cl,%edx
  801d41:	89 f9                	mov    %edi,%ecx
  801d43:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d47:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801d4b:	d3 e8                	shr    %cl,%eax
  801d4d:	89 e9                	mov    %ebp,%ecx
  801d4f:	89 c6                	mov    %eax,%esi
  801d51:	d3 e3                	shl    %cl,%ebx
  801d53:	89 f9                	mov    %edi,%ecx
  801d55:	89 d0                	mov    %edx,%eax
  801d57:	d3 e8                	shr    %cl,%eax
  801d59:	89 e9                	mov    %ebp,%ecx
  801d5b:	09 d8                	or     %ebx,%eax
  801d5d:	89 d3                	mov    %edx,%ebx
  801d5f:	89 f2                	mov    %esi,%edx
  801d61:	f7 34 24             	divl   (%esp)
  801d64:	89 d6                	mov    %edx,%esi
  801d66:	d3 e3                	shl    %cl,%ebx
  801d68:	f7 64 24 04          	mull   0x4(%esp)
  801d6c:	39 d6                	cmp    %edx,%esi
  801d6e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d72:	89 d1                	mov    %edx,%ecx
  801d74:	89 c3                	mov    %eax,%ebx
  801d76:	72 08                	jb     801d80 <__umoddi3+0x110>
  801d78:	75 11                	jne    801d8b <__umoddi3+0x11b>
  801d7a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801d7e:	73 0b                	jae    801d8b <__umoddi3+0x11b>
  801d80:	2b 44 24 04          	sub    0x4(%esp),%eax
  801d84:	1b 14 24             	sbb    (%esp),%edx
  801d87:	89 d1                	mov    %edx,%ecx
  801d89:	89 c3                	mov    %eax,%ebx
  801d8b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801d8f:	29 da                	sub    %ebx,%edx
  801d91:	19 ce                	sbb    %ecx,%esi
  801d93:	89 f9                	mov    %edi,%ecx
  801d95:	89 f0                	mov    %esi,%eax
  801d97:	d3 e0                	shl    %cl,%eax
  801d99:	89 e9                	mov    %ebp,%ecx
  801d9b:	d3 ea                	shr    %cl,%edx
  801d9d:	89 e9                	mov    %ebp,%ecx
  801d9f:	d3 ee                	shr    %cl,%esi
  801da1:	09 d0                	or     %edx,%eax
  801da3:	89 f2                	mov    %esi,%edx
  801da5:	83 c4 1c             	add    $0x1c,%esp
  801da8:	5b                   	pop    %ebx
  801da9:	5e                   	pop    %esi
  801daa:	5f                   	pop    %edi
  801dab:	5d                   	pop    %ebp
  801dac:	c3                   	ret    
  801dad:	8d 76 00             	lea    0x0(%esi),%esi
  801db0:	29 f9                	sub    %edi,%ecx
  801db2:	19 d6                	sbb    %edx,%esi
  801db4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801db8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801dbc:	e9 18 ff ff ff       	jmp    801cd9 <__umoddi3+0x69>
