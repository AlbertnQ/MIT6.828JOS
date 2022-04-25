
obj/user/breakpoint.debug:     file format elf32-i386


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
  80002c:	e8 08 00 00 00       	call   800039 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $3");
  800036:	cc                   	int3   
}
  800037:	5d                   	pop    %ebp
  800038:	c3                   	ret    

00800039 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800039:	55                   	push   %ebp
  80003a:	89 e5                	mov    %esp,%ebp
  80003c:	56                   	push   %esi
  80003d:	53                   	push   %ebx
  80003e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800041:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  800044:	e8 ce 00 00 00       	call   800117 <sys_getenvid>
  800049:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800051:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800056:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005b:	85 db                	test   %ebx,%ebx
  80005d:	7e 07                	jle    800066 <libmain+0x2d>
		binaryname = argv[0];
  80005f:	8b 06                	mov    (%esi),%eax
  800061:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800066:	83 ec 08             	sub    $0x8,%esp
  800069:	56                   	push   %esi
  80006a:	53                   	push   %ebx
  80006b:	e8 c3 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800070:	e8 0a 00 00 00       	call   80007f <exit>
}
  800075:	83 c4 10             	add    $0x10,%esp
  800078:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80007b:	5b                   	pop    %ebx
  80007c:	5e                   	pop    %esi
  80007d:	5d                   	pop    %ebp
  80007e:	c3                   	ret    

0080007f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80007f:	55                   	push   %ebp
  800080:	89 e5                	mov    %esp,%ebp
  800082:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800085:	e8 87 04 00 00       	call   800511 <close_all>
	sys_env_destroy(0);
  80008a:	83 ec 0c             	sub    $0xc,%esp
  80008d:	6a 00                	push   $0x0
  80008f:	e8 42 00 00 00       	call   8000d6 <sys_env_destroy>
}
  800094:	83 c4 10             	add    $0x10,%esp
  800097:	c9                   	leave  
  800098:	c3                   	ret    

00800099 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800099:	55                   	push   %ebp
  80009a:	89 e5                	mov    %esp,%ebp
  80009c:	57                   	push   %edi
  80009d:	56                   	push   %esi
  80009e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80009f:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000aa:	89 c3                	mov    %eax,%ebx
  8000ac:	89 c7                	mov    %eax,%edi
  8000ae:	89 c6                	mov    %eax,%esi
  8000b0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b2:	5b                   	pop    %ebx
  8000b3:	5e                   	pop    %esi
  8000b4:	5f                   	pop    %edi
  8000b5:	5d                   	pop    %ebp
  8000b6:	c3                   	ret    

008000b7 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b7:	55                   	push   %ebp
  8000b8:	89 e5                	mov    %esp,%ebp
  8000ba:	57                   	push   %edi
  8000bb:	56                   	push   %esi
  8000bc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c2:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c7:	89 d1                	mov    %edx,%ecx
  8000c9:	89 d3                	mov    %edx,%ebx
  8000cb:	89 d7                	mov    %edx,%edi
  8000cd:	89 d6                	mov    %edx,%esi
  8000cf:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d1:	5b                   	pop    %ebx
  8000d2:	5e                   	pop    %esi
  8000d3:	5f                   	pop    %edi
  8000d4:	5d                   	pop    %ebp
  8000d5:	c3                   	ret    

008000d6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d6:	55                   	push   %ebp
  8000d7:	89 e5                	mov    %esp,%ebp
  8000d9:	57                   	push   %edi
  8000da:	56                   	push   %esi
  8000db:	53                   	push   %ebx
  8000dc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e4:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ec:	89 cb                	mov    %ecx,%ebx
  8000ee:	89 cf                	mov    %ecx,%edi
  8000f0:	89 ce                	mov    %ecx,%esi
  8000f2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000f4:	85 c0                	test   %eax,%eax
  8000f6:	7e 17                	jle    80010f <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f8:	83 ec 0c             	sub    $0xc,%esp
  8000fb:	50                   	push   %eax
  8000fc:	6a 03                	push   $0x3
  8000fe:	68 aa 1d 80 00       	push   $0x801daa
  800103:	6a 23                	push   $0x23
  800105:	68 c7 1d 80 00       	push   $0x801dc7
  80010a:	e8 21 0f 00 00       	call   801030 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800112:	5b                   	pop    %ebx
  800113:	5e                   	pop    %esi
  800114:	5f                   	pop    %edi
  800115:	5d                   	pop    %ebp
  800116:	c3                   	ret    

00800117 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800117:	55                   	push   %ebp
  800118:	89 e5                	mov    %esp,%ebp
  80011a:	57                   	push   %edi
  80011b:	56                   	push   %esi
  80011c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011d:	ba 00 00 00 00       	mov    $0x0,%edx
  800122:	b8 02 00 00 00       	mov    $0x2,%eax
  800127:	89 d1                	mov    %edx,%ecx
  800129:	89 d3                	mov    %edx,%ebx
  80012b:	89 d7                	mov    %edx,%edi
  80012d:	89 d6                	mov    %edx,%esi
  80012f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800131:	5b                   	pop    %ebx
  800132:	5e                   	pop    %esi
  800133:	5f                   	pop    %edi
  800134:	5d                   	pop    %ebp
  800135:	c3                   	ret    

00800136 <sys_yield>:

void
sys_yield(void)
{
  800136:	55                   	push   %ebp
  800137:	89 e5                	mov    %esp,%ebp
  800139:	57                   	push   %edi
  80013a:	56                   	push   %esi
  80013b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80013c:	ba 00 00 00 00       	mov    $0x0,%edx
  800141:	b8 0b 00 00 00       	mov    $0xb,%eax
  800146:	89 d1                	mov    %edx,%ecx
  800148:	89 d3                	mov    %edx,%ebx
  80014a:	89 d7                	mov    %edx,%edi
  80014c:	89 d6                	mov    %edx,%esi
  80014e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800150:	5b                   	pop    %ebx
  800151:	5e                   	pop    %esi
  800152:	5f                   	pop    %edi
  800153:	5d                   	pop    %ebp
  800154:	c3                   	ret    

00800155 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800155:	55                   	push   %ebp
  800156:	89 e5                	mov    %esp,%ebp
  800158:	57                   	push   %edi
  800159:	56                   	push   %esi
  80015a:	53                   	push   %ebx
  80015b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80015e:	be 00 00 00 00       	mov    $0x0,%esi
  800163:	b8 04 00 00 00       	mov    $0x4,%eax
  800168:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80016b:	8b 55 08             	mov    0x8(%ebp),%edx
  80016e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800171:	89 f7                	mov    %esi,%edi
  800173:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800175:	85 c0                	test   %eax,%eax
  800177:	7e 17                	jle    800190 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800179:	83 ec 0c             	sub    $0xc,%esp
  80017c:	50                   	push   %eax
  80017d:	6a 04                	push   $0x4
  80017f:	68 aa 1d 80 00       	push   $0x801daa
  800184:	6a 23                	push   $0x23
  800186:	68 c7 1d 80 00       	push   $0x801dc7
  80018b:	e8 a0 0e 00 00       	call   801030 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800190:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800193:	5b                   	pop    %ebx
  800194:	5e                   	pop    %esi
  800195:	5f                   	pop    %edi
  800196:	5d                   	pop    %ebp
  800197:	c3                   	ret    

00800198 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800198:	55                   	push   %ebp
  800199:	89 e5                	mov    %esp,%ebp
  80019b:	57                   	push   %edi
  80019c:	56                   	push   %esi
  80019d:	53                   	push   %ebx
  80019e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a1:	b8 05 00 00 00       	mov    $0x5,%eax
  8001a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001af:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b2:	8b 75 18             	mov    0x18(%ebp),%esi
  8001b5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001b7:	85 c0                	test   %eax,%eax
  8001b9:	7e 17                	jle    8001d2 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001bb:	83 ec 0c             	sub    $0xc,%esp
  8001be:	50                   	push   %eax
  8001bf:	6a 05                	push   $0x5
  8001c1:	68 aa 1d 80 00       	push   $0x801daa
  8001c6:	6a 23                	push   $0x23
  8001c8:	68 c7 1d 80 00       	push   $0x801dc7
  8001cd:	e8 5e 0e 00 00       	call   801030 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d5:	5b                   	pop    %ebx
  8001d6:	5e                   	pop    %esi
  8001d7:	5f                   	pop    %edi
  8001d8:	5d                   	pop    %ebp
  8001d9:	c3                   	ret    

008001da <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001da:	55                   	push   %ebp
  8001db:	89 e5                	mov    %esp,%ebp
  8001dd:	57                   	push   %edi
  8001de:	56                   	push   %esi
  8001df:	53                   	push   %ebx
  8001e0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e8:	b8 06 00 00 00       	mov    $0x6,%eax
  8001ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f3:	89 df                	mov    %ebx,%edi
  8001f5:	89 de                	mov    %ebx,%esi
  8001f7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001f9:	85 c0                	test   %eax,%eax
  8001fb:	7e 17                	jle    800214 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fd:	83 ec 0c             	sub    $0xc,%esp
  800200:	50                   	push   %eax
  800201:	6a 06                	push   $0x6
  800203:	68 aa 1d 80 00       	push   $0x801daa
  800208:	6a 23                	push   $0x23
  80020a:	68 c7 1d 80 00       	push   $0x801dc7
  80020f:	e8 1c 0e 00 00       	call   801030 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800214:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800217:	5b                   	pop    %ebx
  800218:	5e                   	pop    %esi
  800219:	5f                   	pop    %edi
  80021a:	5d                   	pop    %ebp
  80021b:	c3                   	ret    

0080021c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	57                   	push   %edi
  800220:	56                   	push   %esi
  800221:	53                   	push   %ebx
  800222:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800225:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022a:	b8 08 00 00 00       	mov    $0x8,%eax
  80022f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800232:	8b 55 08             	mov    0x8(%ebp),%edx
  800235:	89 df                	mov    %ebx,%edi
  800237:	89 de                	mov    %ebx,%esi
  800239:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80023b:	85 c0                	test   %eax,%eax
  80023d:	7e 17                	jle    800256 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80023f:	83 ec 0c             	sub    $0xc,%esp
  800242:	50                   	push   %eax
  800243:	6a 08                	push   $0x8
  800245:	68 aa 1d 80 00       	push   $0x801daa
  80024a:	6a 23                	push   $0x23
  80024c:	68 c7 1d 80 00       	push   $0x801dc7
  800251:	e8 da 0d 00 00       	call   801030 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800256:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800259:	5b                   	pop    %ebx
  80025a:	5e                   	pop    %esi
  80025b:	5f                   	pop    %edi
  80025c:	5d                   	pop    %ebp
  80025d:	c3                   	ret    

0080025e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80025e:	55                   	push   %ebp
  80025f:	89 e5                	mov    %esp,%ebp
  800261:	57                   	push   %edi
  800262:	56                   	push   %esi
  800263:	53                   	push   %ebx
  800264:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800267:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026c:	b8 09 00 00 00       	mov    $0x9,%eax
  800271:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800274:	8b 55 08             	mov    0x8(%ebp),%edx
  800277:	89 df                	mov    %ebx,%edi
  800279:	89 de                	mov    %ebx,%esi
  80027b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80027d:	85 c0                	test   %eax,%eax
  80027f:	7e 17                	jle    800298 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800281:	83 ec 0c             	sub    $0xc,%esp
  800284:	50                   	push   %eax
  800285:	6a 09                	push   $0x9
  800287:	68 aa 1d 80 00       	push   $0x801daa
  80028c:	6a 23                	push   $0x23
  80028e:	68 c7 1d 80 00       	push   $0x801dc7
  800293:	e8 98 0d 00 00       	call   801030 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800298:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80029b:	5b                   	pop    %ebx
  80029c:	5e                   	pop    %esi
  80029d:	5f                   	pop    %edi
  80029e:	5d                   	pop    %ebp
  80029f:	c3                   	ret    

008002a0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	57                   	push   %edi
  8002a4:	56                   	push   %esi
  8002a5:	53                   	push   %ebx
  8002a6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002a9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ae:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b9:	89 df                	mov    %ebx,%edi
  8002bb:	89 de                	mov    %ebx,%esi
  8002bd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002bf:	85 c0                	test   %eax,%eax
  8002c1:	7e 17                	jle    8002da <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c3:	83 ec 0c             	sub    $0xc,%esp
  8002c6:	50                   	push   %eax
  8002c7:	6a 0a                	push   $0xa
  8002c9:	68 aa 1d 80 00       	push   $0x801daa
  8002ce:	6a 23                	push   $0x23
  8002d0:	68 c7 1d 80 00       	push   $0x801dc7
  8002d5:	e8 56 0d 00 00       	call   801030 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002dd:	5b                   	pop    %ebx
  8002de:	5e                   	pop    %esi
  8002df:	5f                   	pop    %edi
  8002e0:	5d                   	pop    %ebp
  8002e1:	c3                   	ret    

008002e2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002e2:	55                   	push   %ebp
  8002e3:	89 e5                	mov    %esp,%ebp
  8002e5:	57                   	push   %edi
  8002e6:	56                   	push   %esi
  8002e7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002e8:	be 00 00 00 00       	mov    $0x0,%esi
  8002ed:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002fb:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002fe:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800300:	5b                   	pop    %ebx
  800301:	5e                   	pop    %esi
  800302:	5f                   	pop    %edi
  800303:	5d                   	pop    %ebp
  800304:	c3                   	ret    

00800305 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
  800308:	57                   	push   %edi
  800309:	56                   	push   %esi
  80030a:	53                   	push   %ebx
  80030b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80030e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800313:	b8 0d 00 00 00       	mov    $0xd,%eax
  800318:	8b 55 08             	mov    0x8(%ebp),%edx
  80031b:	89 cb                	mov    %ecx,%ebx
  80031d:	89 cf                	mov    %ecx,%edi
  80031f:	89 ce                	mov    %ecx,%esi
  800321:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800323:	85 c0                	test   %eax,%eax
  800325:	7e 17                	jle    80033e <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800327:	83 ec 0c             	sub    $0xc,%esp
  80032a:	50                   	push   %eax
  80032b:	6a 0d                	push   $0xd
  80032d:	68 aa 1d 80 00       	push   $0x801daa
  800332:	6a 23                	push   $0x23
  800334:	68 c7 1d 80 00       	push   $0x801dc7
  800339:	e8 f2 0c 00 00       	call   801030 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80033e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800341:	5b                   	pop    %ebx
  800342:	5e                   	pop    %esi
  800343:	5f                   	pop    %edi
  800344:	5d                   	pop    %ebp
  800345:	c3                   	ret    

00800346 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800346:	55                   	push   %ebp
  800347:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800349:	8b 45 08             	mov    0x8(%ebp),%eax
  80034c:	05 00 00 00 30       	add    $0x30000000,%eax
  800351:	c1 e8 0c             	shr    $0xc,%eax
}
  800354:	5d                   	pop    %ebp
  800355:	c3                   	ret    

00800356 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800356:	55                   	push   %ebp
  800357:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800359:	8b 45 08             	mov    0x8(%ebp),%eax
  80035c:	05 00 00 00 30       	add    $0x30000000,%eax
  800361:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800366:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80036b:	5d                   	pop    %ebp
  80036c:	c3                   	ret    

0080036d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80036d:	55                   	push   %ebp
  80036e:	89 e5                	mov    %esp,%ebp
  800370:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800373:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800378:	89 c2                	mov    %eax,%edx
  80037a:	c1 ea 16             	shr    $0x16,%edx
  80037d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800384:	f6 c2 01             	test   $0x1,%dl
  800387:	74 11                	je     80039a <fd_alloc+0x2d>
  800389:	89 c2                	mov    %eax,%edx
  80038b:	c1 ea 0c             	shr    $0xc,%edx
  80038e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800395:	f6 c2 01             	test   $0x1,%dl
  800398:	75 09                	jne    8003a3 <fd_alloc+0x36>
			*fd_store = fd;
  80039a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80039c:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a1:	eb 17                	jmp    8003ba <fd_alloc+0x4d>
  8003a3:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003a8:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003ad:	75 c9                	jne    800378 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003af:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003b5:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003ba:	5d                   	pop    %ebp
  8003bb:	c3                   	ret    

008003bc <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003bc:	55                   	push   %ebp
  8003bd:	89 e5                	mov    %esp,%ebp
  8003bf:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003c2:	83 f8 1f             	cmp    $0x1f,%eax
  8003c5:	77 36                	ja     8003fd <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003c7:	c1 e0 0c             	shl    $0xc,%eax
  8003ca:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003cf:	89 c2                	mov    %eax,%edx
  8003d1:	c1 ea 16             	shr    $0x16,%edx
  8003d4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003db:	f6 c2 01             	test   $0x1,%dl
  8003de:	74 24                	je     800404 <fd_lookup+0x48>
  8003e0:	89 c2                	mov    %eax,%edx
  8003e2:	c1 ea 0c             	shr    $0xc,%edx
  8003e5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003ec:	f6 c2 01             	test   $0x1,%dl
  8003ef:	74 1a                	je     80040b <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003f1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003f4:	89 02                	mov    %eax,(%edx)
	return 0;
  8003f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8003fb:	eb 13                	jmp    800410 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8003fd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800402:	eb 0c                	jmp    800410 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800404:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800409:	eb 05                	jmp    800410 <fd_lookup+0x54>
  80040b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800410:	5d                   	pop    %ebp
  800411:	c3                   	ret    

00800412 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800412:	55                   	push   %ebp
  800413:	89 e5                	mov    %esp,%ebp
  800415:	83 ec 08             	sub    $0x8,%esp
  800418:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80041b:	ba 54 1e 80 00       	mov    $0x801e54,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800420:	eb 13                	jmp    800435 <dev_lookup+0x23>
  800422:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800425:	39 08                	cmp    %ecx,(%eax)
  800427:	75 0c                	jne    800435 <dev_lookup+0x23>
			*dev = devtab[i];
  800429:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80042c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80042e:	b8 00 00 00 00       	mov    $0x0,%eax
  800433:	eb 2e                	jmp    800463 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800435:	8b 02                	mov    (%edx),%eax
  800437:	85 c0                	test   %eax,%eax
  800439:	75 e7                	jne    800422 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80043b:	a1 04 40 80 00       	mov    0x804004,%eax
  800440:	8b 40 48             	mov    0x48(%eax),%eax
  800443:	83 ec 04             	sub    $0x4,%esp
  800446:	51                   	push   %ecx
  800447:	50                   	push   %eax
  800448:	68 d8 1d 80 00       	push   $0x801dd8
  80044d:	e8 b7 0c 00 00       	call   801109 <cprintf>
	*dev = 0;
  800452:	8b 45 0c             	mov    0xc(%ebp),%eax
  800455:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80045b:	83 c4 10             	add    $0x10,%esp
  80045e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800463:	c9                   	leave  
  800464:	c3                   	ret    

00800465 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800465:	55                   	push   %ebp
  800466:	89 e5                	mov    %esp,%ebp
  800468:	56                   	push   %esi
  800469:	53                   	push   %ebx
  80046a:	83 ec 10             	sub    $0x10,%esp
  80046d:	8b 75 08             	mov    0x8(%ebp),%esi
  800470:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800473:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800476:	50                   	push   %eax
  800477:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80047d:	c1 e8 0c             	shr    $0xc,%eax
  800480:	50                   	push   %eax
  800481:	e8 36 ff ff ff       	call   8003bc <fd_lookup>
  800486:	83 c4 08             	add    $0x8,%esp
  800489:	85 c0                	test   %eax,%eax
  80048b:	78 05                	js     800492 <fd_close+0x2d>
	    || fd != fd2)
  80048d:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800490:	74 0c                	je     80049e <fd_close+0x39>
		return (must_exist ? r : 0);
  800492:	84 db                	test   %bl,%bl
  800494:	ba 00 00 00 00       	mov    $0x0,%edx
  800499:	0f 44 c2             	cmove  %edx,%eax
  80049c:	eb 41                	jmp    8004df <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80049e:	83 ec 08             	sub    $0x8,%esp
  8004a1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004a4:	50                   	push   %eax
  8004a5:	ff 36                	pushl  (%esi)
  8004a7:	e8 66 ff ff ff       	call   800412 <dev_lookup>
  8004ac:	89 c3                	mov    %eax,%ebx
  8004ae:	83 c4 10             	add    $0x10,%esp
  8004b1:	85 c0                	test   %eax,%eax
  8004b3:	78 1a                	js     8004cf <fd_close+0x6a>
		if (dev->dev_close)
  8004b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004b8:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004bb:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004c0:	85 c0                	test   %eax,%eax
  8004c2:	74 0b                	je     8004cf <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004c4:	83 ec 0c             	sub    $0xc,%esp
  8004c7:	56                   	push   %esi
  8004c8:	ff d0                	call   *%eax
  8004ca:	89 c3                	mov    %eax,%ebx
  8004cc:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004cf:	83 ec 08             	sub    $0x8,%esp
  8004d2:	56                   	push   %esi
  8004d3:	6a 00                	push   $0x0
  8004d5:	e8 00 fd ff ff       	call   8001da <sys_page_unmap>
	return r;
  8004da:	83 c4 10             	add    $0x10,%esp
  8004dd:	89 d8                	mov    %ebx,%eax
}
  8004df:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004e2:	5b                   	pop    %ebx
  8004e3:	5e                   	pop    %esi
  8004e4:	5d                   	pop    %ebp
  8004e5:	c3                   	ret    

008004e6 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004e6:	55                   	push   %ebp
  8004e7:	89 e5                	mov    %esp,%ebp
  8004e9:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004ef:	50                   	push   %eax
  8004f0:	ff 75 08             	pushl  0x8(%ebp)
  8004f3:	e8 c4 fe ff ff       	call   8003bc <fd_lookup>
  8004f8:	83 c4 08             	add    $0x8,%esp
  8004fb:	85 c0                	test   %eax,%eax
  8004fd:	78 10                	js     80050f <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8004ff:	83 ec 08             	sub    $0x8,%esp
  800502:	6a 01                	push   $0x1
  800504:	ff 75 f4             	pushl  -0xc(%ebp)
  800507:	e8 59 ff ff ff       	call   800465 <fd_close>
  80050c:	83 c4 10             	add    $0x10,%esp
}
  80050f:	c9                   	leave  
  800510:	c3                   	ret    

00800511 <close_all>:

void
close_all(void)
{
  800511:	55                   	push   %ebp
  800512:	89 e5                	mov    %esp,%ebp
  800514:	53                   	push   %ebx
  800515:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800518:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80051d:	83 ec 0c             	sub    $0xc,%esp
  800520:	53                   	push   %ebx
  800521:	e8 c0 ff ff ff       	call   8004e6 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800526:	83 c3 01             	add    $0x1,%ebx
  800529:	83 c4 10             	add    $0x10,%esp
  80052c:	83 fb 20             	cmp    $0x20,%ebx
  80052f:	75 ec                	jne    80051d <close_all+0xc>
		close(i);
}
  800531:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800534:	c9                   	leave  
  800535:	c3                   	ret    

00800536 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800536:	55                   	push   %ebp
  800537:	89 e5                	mov    %esp,%ebp
  800539:	57                   	push   %edi
  80053a:	56                   	push   %esi
  80053b:	53                   	push   %ebx
  80053c:	83 ec 2c             	sub    $0x2c,%esp
  80053f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800542:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800545:	50                   	push   %eax
  800546:	ff 75 08             	pushl  0x8(%ebp)
  800549:	e8 6e fe ff ff       	call   8003bc <fd_lookup>
  80054e:	83 c4 08             	add    $0x8,%esp
  800551:	85 c0                	test   %eax,%eax
  800553:	0f 88 c1 00 00 00    	js     80061a <dup+0xe4>
		return r;
	close(newfdnum);
  800559:	83 ec 0c             	sub    $0xc,%esp
  80055c:	56                   	push   %esi
  80055d:	e8 84 ff ff ff       	call   8004e6 <close>

	newfd = INDEX2FD(newfdnum);
  800562:	89 f3                	mov    %esi,%ebx
  800564:	c1 e3 0c             	shl    $0xc,%ebx
  800567:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80056d:	83 c4 04             	add    $0x4,%esp
  800570:	ff 75 e4             	pushl  -0x1c(%ebp)
  800573:	e8 de fd ff ff       	call   800356 <fd2data>
  800578:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80057a:	89 1c 24             	mov    %ebx,(%esp)
  80057d:	e8 d4 fd ff ff       	call   800356 <fd2data>
  800582:	83 c4 10             	add    $0x10,%esp
  800585:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800588:	89 f8                	mov    %edi,%eax
  80058a:	c1 e8 16             	shr    $0x16,%eax
  80058d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800594:	a8 01                	test   $0x1,%al
  800596:	74 37                	je     8005cf <dup+0x99>
  800598:	89 f8                	mov    %edi,%eax
  80059a:	c1 e8 0c             	shr    $0xc,%eax
  80059d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005a4:	f6 c2 01             	test   $0x1,%dl
  8005a7:	74 26                	je     8005cf <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005a9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005b0:	83 ec 0c             	sub    $0xc,%esp
  8005b3:	25 07 0e 00 00       	and    $0xe07,%eax
  8005b8:	50                   	push   %eax
  8005b9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005bc:	6a 00                	push   $0x0
  8005be:	57                   	push   %edi
  8005bf:	6a 00                	push   $0x0
  8005c1:	e8 d2 fb ff ff       	call   800198 <sys_page_map>
  8005c6:	89 c7                	mov    %eax,%edi
  8005c8:	83 c4 20             	add    $0x20,%esp
  8005cb:	85 c0                	test   %eax,%eax
  8005cd:	78 2e                	js     8005fd <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005cf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005d2:	89 d0                	mov    %edx,%eax
  8005d4:	c1 e8 0c             	shr    $0xc,%eax
  8005d7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005de:	83 ec 0c             	sub    $0xc,%esp
  8005e1:	25 07 0e 00 00       	and    $0xe07,%eax
  8005e6:	50                   	push   %eax
  8005e7:	53                   	push   %ebx
  8005e8:	6a 00                	push   $0x0
  8005ea:	52                   	push   %edx
  8005eb:	6a 00                	push   $0x0
  8005ed:	e8 a6 fb ff ff       	call   800198 <sys_page_map>
  8005f2:	89 c7                	mov    %eax,%edi
  8005f4:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8005f7:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005f9:	85 ff                	test   %edi,%edi
  8005fb:	79 1d                	jns    80061a <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8005fd:	83 ec 08             	sub    $0x8,%esp
  800600:	53                   	push   %ebx
  800601:	6a 00                	push   $0x0
  800603:	e8 d2 fb ff ff       	call   8001da <sys_page_unmap>
	sys_page_unmap(0, nva);
  800608:	83 c4 08             	add    $0x8,%esp
  80060b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80060e:	6a 00                	push   $0x0
  800610:	e8 c5 fb ff ff       	call   8001da <sys_page_unmap>
	return r;
  800615:	83 c4 10             	add    $0x10,%esp
  800618:	89 f8                	mov    %edi,%eax
}
  80061a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80061d:	5b                   	pop    %ebx
  80061e:	5e                   	pop    %esi
  80061f:	5f                   	pop    %edi
  800620:	5d                   	pop    %ebp
  800621:	c3                   	ret    

00800622 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800622:	55                   	push   %ebp
  800623:	89 e5                	mov    %esp,%ebp
  800625:	53                   	push   %ebx
  800626:	83 ec 14             	sub    $0x14,%esp
  800629:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80062c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80062f:	50                   	push   %eax
  800630:	53                   	push   %ebx
  800631:	e8 86 fd ff ff       	call   8003bc <fd_lookup>
  800636:	83 c4 08             	add    $0x8,%esp
  800639:	89 c2                	mov    %eax,%edx
  80063b:	85 c0                	test   %eax,%eax
  80063d:	78 6d                	js     8006ac <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80063f:	83 ec 08             	sub    $0x8,%esp
  800642:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800645:	50                   	push   %eax
  800646:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800649:	ff 30                	pushl  (%eax)
  80064b:	e8 c2 fd ff ff       	call   800412 <dev_lookup>
  800650:	83 c4 10             	add    $0x10,%esp
  800653:	85 c0                	test   %eax,%eax
  800655:	78 4c                	js     8006a3 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800657:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80065a:	8b 42 08             	mov    0x8(%edx),%eax
  80065d:	83 e0 03             	and    $0x3,%eax
  800660:	83 f8 01             	cmp    $0x1,%eax
  800663:	75 21                	jne    800686 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800665:	a1 04 40 80 00       	mov    0x804004,%eax
  80066a:	8b 40 48             	mov    0x48(%eax),%eax
  80066d:	83 ec 04             	sub    $0x4,%esp
  800670:	53                   	push   %ebx
  800671:	50                   	push   %eax
  800672:	68 19 1e 80 00       	push   $0x801e19
  800677:	e8 8d 0a 00 00       	call   801109 <cprintf>
		return -E_INVAL;
  80067c:	83 c4 10             	add    $0x10,%esp
  80067f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800684:	eb 26                	jmp    8006ac <read+0x8a>
	}
	if (!dev->dev_read)
  800686:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800689:	8b 40 08             	mov    0x8(%eax),%eax
  80068c:	85 c0                	test   %eax,%eax
  80068e:	74 17                	je     8006a7 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800690:	83 ec 04             	sub    $0x4,%esp
  800693:	ff 75 10             	pushl  0x10(%ebp)
  800696:	ff 75 0c             	pushl  0xc(%ebp)
  800699:	52                   	push   %edx
  80069a:	ff d0                	call   *%eax
  80069c:	89 c2                	mov    %eax,%edx
  80069e:	83 c4 10             	add    $0x10,%esp
  8006a1:	eb 09                	jmp    8006ac <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006a3:	89 c2                	mov    %eax,%edx
  8006a5:	eb 05                	jmp    8006ac <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006a7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006ac:	89 d0                	mov    %edx,%eax
  8006ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006b1:	c9                   	leave  
  8006b2:	c3                   	ret    

008006b3 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006b3:	55                   	push   %ebp
  8006b4:	89 e5                	mov    %esp,%ebp
  8006b6:	57                   	push   %edi
  8006b7:	56                   	push   %esi
  8006b8:	53                   	push   %ebx
  8006b9:	83 ec 0c             	sub    $0xc,%esp
  8006bc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006bf:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006c2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006c7:	eb 21                	jmp    8006ea <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006c9:	83 ec 04             	sub    $0x4,%esp
  8006cc:	89 f0                	mov    %esi,%eax
  8006ce:	29 d8                	sub    %ebx,%eax
  8006d0:	50                   	push   %eax
  8006d1:	89 d8                	mov    %ebx,%eax
  8006d3:	03 45 0c             	add    0xc(%ebp),%eax
  8006d6:	50                   	push   %eax
  8006d7:	57                   	push   %edi
  8006d8:	e8 45 ff ff ff       	call   800622 <read>
		if (m < 0)
  8006dd:	83 c4 10             	add    $0x10,%esp
  8006e0:	85 c0                	test   %eax,%eax
  8006e2:	78 10                	js     8006f4 <readn+0x41>
			return m;
		if (m == 0)
  8006e4:	85 c0                	test   %eax,%eax
  8006e6:	74 0a                	je     8006f2 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006e8:	01 c3                	add    %eax,%ebx
  8006ea:	39 f3                	cmp    %esi,%ebx
  8006ec:	72 db                	jb     8006c9 <readn+0x16>
  8006ee:	89 d8                	mov    %ebx,%eax
  8006f0:	eb 02                	jmp    8006f4 <readn+0x41>
  8006f2:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8006f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f7:	5b                   	pop    %ebx
  8006f8:	5e                   	pop    %esi
  8006f9:	5f                   	pop    %edi
  8006fa:	5d                   	pop    %ebp
  8006fb:	c3                   	ret    

008006fc <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8006fc:	55                   	push   %ebp
  8006fd:	89 e5                	mov    %esp,%ebp
  8006ff:	53                   	push   %ebx
  800700:	83 ec 14             	sub    $0x14,%esp
  800703:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800706:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800709:	50                   	push   %eax
  80070a:	53                   	push   %ebx
  80070b:	e8 ac fc ff ff       	call   8003bc <fd_lookup>
  800710:	83 c4 08             	add    $0x8,%esp
  800713:	89 c2                	mov    %eax,%edx
  800715:	85 c0                	test   %eax,%eax
  800717:	78 68                	js     800781 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800719:	83 ec 08             	sub    $0x8,%esp
  80071c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80071f:	50                   	push   %eax
  800720:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800723:	ff 30                	pushl  (%eax)
  800725:	e8 e8 fc ff ff       	call   800412 <dev_lookup>
  80072a:	83 c4 10             	add    $0x10,%esp
  80072d:	85 c0                	test   %eax,%eax
  80072f:	78 47                	js     800778 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800731:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800734:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800738:	75 21                	jne    80075b <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80073a:	a1 04 40 80 00       	mov    0x804004,%eax
  80073f:	8b 40 48             	mov    0x48(%eax),%eax
  800742:	83 ec 04             	sub    $0x4,%esp
  800745:	53                   	push   %ebx
  800746:	50                   	push   %eax
  800747:	68 35 1e 80 00       	push   $0x801e35
  80074c:	e8 b8 09 00 00       	call   801109 <cprintf>
		return -E_INVAL;
  800751:	83 c4 10             	add    $0x10,%esp
  800754:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800759:	eb 26                	jmp    800781 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80075b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80075e:	8b 52 0c             	mov    0xc(%edx),%edx
  800761:	85 d2                	test   %edx,%edx
  800763:	74 17                	je     80077c <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800765:	83 ec 04             	sub    $0x4,%esp
  800768:	ff 75 10             	pushl  0x10(%ebp)
  80076b:	ff 75 0c             	pushl  0xc(%ebp)
  80076e:	50                   	push   %eax
  80076f:	ff d2                	call   *%edx
  800771:	89 c2                	mov    %eax,%edx
  800773:	83 c4 10             	add    $0x10,%esp
  800776:	eb 09                	jmp    800781 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800778:	89 c2                	mov    %eax,%edx
  80077a:	eb 05                	jmp    800781 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80077c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800781:	89 d0                	mov    %edx,%eax
  800783:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800786:	c9                   	leave  
  800787:	c3                   	ret    

00800788 <seek>:

int
seek(int fdnum, off_t offset)
{
  800788:	55                   	push   %ebp
  800789:	89 e5                	mov    %esp,%ebp
  80078b:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80078e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800791:	50                   	push   %eax
  800792:	ff 75 08             	pushl  0x8(%ebp)
  800795:	e8 22 fc ff ff       	call   8003bc <fd_lookup>
  80079a:	83 c4 08             	add    $0x8,%esp
  80079d:	85 c0                	test   %eax,%eax
  80079f:	78 0e                	js     8007af <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007a7:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007aa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007af:	c9                   	leave  
  8007b0:	c3                   	ret    

008007b1 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007b1:	55                   	push   %ebp
  8007b2:	89 e5                	mov    %esp,%ebp
  8007b4:	53                   	push   %ebx
  8007b5:	83 ec 14             	sub    $0x14,%esp
  8007b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007bb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007be:	50                   	push   %eax
  8007bf:	53                   	push   %ebx
  8007c0:	e8 f7 fb ff ff       	call   8003bc <fd_lookup>
  8007c5:	83 c4 08             	add    $0x8,%esp
  8007c8:	89 c2                	mov    %eax,%edx
  8007ca:	85 c0                	test   %eax,%eax
  8007cc:	78 65                	js     800833 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007ce:	83 ec 08             	sub    $0x8,%esp
  8007d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007d4:	50                   	push   %eax
  8007d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007d8:	ff 30                	pushl  (%eax)
  8007da:	e8 33 fc ff ff       	call   800412 <dev_lookup>
  8007df:	83 c4 10             	add    $0x10,%esp
  8007e2:	85 c0                	test   %eax,%eax
  8007e4:	78 44                	js     80082a <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007ed:	75 21                	jne    800810 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8007ef:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007f4:	8b 40 48             	mov    0x48(%eax),%eax
  8007f7:	83 ec 04             	sub    $0x4,%esp
  8007fa:	53                   	push   %ebx
  8007fb:	50                   	push   %eax
  8007fc:	68 f8 1d 80 00       	push   $0x801df8
  800801:	e8 03 09 00 00       	call   801109 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800806:	83 c4 10             	add    $0x10,%esp
  800809:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80080e:	eb 23                	jmp    800833 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800810:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800813:	8b 52 18             	mov    0x18(%edx),%edx
  800816:	85 d2                	test   %edx,%edx
  800818:	74 14                	je     80082e <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80081a:	83 ec 08             	sub    $0x8,%esp
  80081d:	ff 75 0c             	pushl  0xc(%ebp)
  800820:	50                   	push   %eax
  800821:	ff d2                	call   *%edx
  800823:	89 c2                	mov    %eax,%edx
  800825:	83 c4 10             	add    $0x10,%esp
  800828:	eb 09                	jmp    800833 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80082a:	89 c2                	mov    %eax,%edx
  80082c:	eb 05                	jmp    800833 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80082e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800833:	89 d0                	mov    %edx,%eax
  800835:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800838:	c9                   	leave  
  800839:	c3                   	ret    

0080083a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80083a:	55                   	push   %ebp
  80083b:	89 e5                	mov    %esp,%ebp
  80083d:	53                   	push   %ebx
  80083e:	83 ec 14             	sub    $0x14,%esp
  800841:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800844:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800847:	50                   	push   %eax
  800848:	ff 75 08             	pushl  0x8(%ebp)
  80084b:	e8 6c fb ff ff       	call   8003bc <fd_lookup>
  800850:	83 c4 08             	add    $0x8,%esp
  800853:	89 c2                	mov    %eax,%edx
  800855:	85 c0                	test   %eax,%eax
  800857:	78 58                	js     8008b1 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800859:	83 ec 08             	sub    $0x8,%esp
  80085c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80085f:	50                   	push   %eax
  800860:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800863:	ff 30                	pushl  (%eax)
  800865:	e8 a8 fb ff ff       	call   800412 <dev_lookup>
  80086a:	83 c4 10             	add    $0x10,%esp
  80086d:	85 c0                	test   %eax,%eax
  80086f:	78 37                	js     8008a8 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800871:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800874:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800878:	74 32                	je     8008ac <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80087a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80087d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800884:	00 00 00 
	stat->st_isdir = 0;
  800887:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80088e:	00 00 00 
	stat->st_dev = dev;
  800891:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800897:	83 ec 08             	sub    $0x8,%esp
  80089a:	53                   	push   %ebx
  80089b:	ff 75 f0             	pushl  -0x10(%ebp)
  80089e:	ff 50 14             	call   *0x14(%eax)
  8008a1:	89 c2                	mov    %eax,%edx
  8008a3:	83 c4 10             	add    $0x10,%esp
  8008a6:	eb 09                	jmp    8008b1 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008a8:	89 c2                	mov    %eax,%edx
  8008aa:	eb 05                	jmp    8008b1 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008ac:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008b1:	89 d0                	mov    %edx,%eax
  8008b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008b6:	c9                   	leave  
  8008b7:	c3                   	ret    

008008b8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008b8:	55                   	push   %ebp
  8008b9:	89 e5                	mov    %esp,%ebp
  8008bb:	56                   	push   %esi
  8008bc:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008bd:	83 ec 08             	sub    $0x8,%esp
  8008c0:	6a 00                	push   $0x0
  8008c2:	ff 75 08             	pushl  0x8(%ebp)
  8008c5:	e8 e3 01 00 00       	call   800aad <open>
  8008ca:	89 c3                	mov    %eax,%ebx
  8008cc:	83 c4 10             	add    $0x10,%esp
  8008cf:	85 c0                	test   %eax,%eax
  8008d1:	78 1b                	js     8008ee <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008d3:	83 ec 08             	sub    $0x8,%esp
  8008d6:	ff 75 0c             	pushl  0xc(%ebp)
  8008d9:	50                   	push   %eax
  8008da:	e8 5b ff ff ff       	call   80083a <fstat>
  8008df:	89 c6                	mov    %eax,%esi
	close(fd);
  8008e1:	89 1c 24             	mov    %ebx,(%esp)
  8008e4:	e8 fd fb ff ff       	call   8004e6 <close>
	return r;
  8008e9:	83 c4 10             	add    $0x10,%esp
  8008ec:	89 f0                	mov    %esi,%eax
}
  8008ee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008f1:	5b                   	pop    %ebx
  8008f2:	5e                   	pop    %esi
  8008f3:	5d                   	pop    %ebp
  8008f4:	c3                   	ret    

008008f5 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008f5:	55                   	push   %ebp
  8008f6:	89 e5                	mov    %esp,%ebp
  8008f8:	56                   	push   %esi
  8008f9:	53                   	push   %ebx
  8008fa:	89 c6                	mov    %eax,%esi
  8008fc:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8008fe:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800905:	75 12                	jne    800919 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800907:	83 ec 0c             	sub    $0xc,%esp
  80090a:	6a 01                	push   $0x1
  80090c:	e8 8b 11 00 00       	call   801a9c <ipc_find_env>
  800911:	a3 00 40 80 00       	mov    %eax,0x804000
  800916:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800919:	6a 07                	push   $0x7
  80091b:	68 00 50 80 00       	push   $0x805000
  800920:	56                   	push   %esi
  800921:	ff 35 00 40 80 00    	pushl  0x804000
  800927:	e8 1c 11 00 00       	call   801a48 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80092c:	83 c4 0c             	add    $0xc,%esp
  80092f:	6a 00                	push   $0x0
  800931:	53                   	push   %ebx
  800932:	6a 00                	push   $0x0
  800934:	e8 ba 10 00 00       	call   8019f3 <ipc_recv>
}
  800939:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80093c:	5b                   	pop    %ebx
  80093d:	5e                   	pop    %esi
  80093e:	5d                   	pop    %ebp
  80093f:	c3                   	ret    

00800940 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800940:	55                   	push   %ebp
  800941:	89 e5                	mov    %esp,%ebp
  800943:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800946:	8b 45 08             	mov    0x8(%ebp),%eax
  800949:	8b 40 0c             	mov    0xc(%eax),%eax
  80094c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800951:	8b 45 0c             	mov    0xc(%ebp),%eax
  800954:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800959:	ba 00 00 00 00       	mov    $0x0,%edx
  80095e:	b8 02 00 00 00       	mov    $0x2,%eax
  800963:	e8 8d ff ff ff       	call   8008f5 <fsipc>
}
  800968:	c9                   	leave  
  800969:	c3                   	ret    

0080096a <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
  80096d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800970:	8b 45 08             	mov    0x8(%ebp),%eax
  800973:	8b 40 0c             	mov    0xc(%eax),%eax
  800976:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80097b:	ba 00 00 00 00       	mov    $0x0,%edx
  800980:	b8 06 00 00 00       	mov    $0x6,%eax
  800985:	e8 6b ff ff ff       	call   8008f5 <fsipc>
}
  80098a:	c9                   	leave  
  80098b:	c3                   	ret    

0080098c <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80098c:	55                   	push   %ebp
  80098d:	89 e5                	mov    %esp,%ebp
  80098f:	53                   	push   %ebx
  800990:	83 ec 04             	sub    $0x4,%esp
  800993:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800996:	8b 45 08             	mov    0x8(%ebp),%eax
  800999:	8b 40 0c             	mov    0xc(%eax),%eax
  80099c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a6:	b8 05 00 00 00       	mov    $0x5,%eax
  8009ab:	e8 45 ff ff ff       	call   8008f5 <fsipc>
  8009b0:	85 c0                	test   %eax,%eax
  8009b2:	78 2c                	js     8009e0 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009b4:	83 ec 08             	sub    $0x8,%esp
  8009b7:	68 00 50 80 00       	push   $0x805000
  8009bc:	53                   	push   %ebx
  8009bd:	e8 ea 0c 00 00       	call   8016ac <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009c2:	a1 80 50 80 00       	mov    0x805080,%eax
  8009c7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009cd:	a1 84 50 80 00       	mov    0x805084,%eax
  8009d2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009d8:	83 c4 10             	add    $0x10,%esp
  8009db:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009e3:	c9                   	leave  
  8009e4:	c3                   	ret    

008009e5 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009e5:	55                   	push   %ebp
  8009e6:	89 e5                	mov    %esp,%ebp
  8009e8:	83 ec 0c             	sub    $0xc,%esp
  8009eb:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
    
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8009f1:	8b 52 0c             	mov    0xc(%edx),%edx
  8009f4:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = MIN(n, PGSIZE);
  8009fa:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8009ff:	ba 00 10 00 00       	mov    $0x1000,%edx
  800a04:	0f 47 c2             	cmova  %edx,%eax
  800a07:	a3 04 50 80 00       	mov    %eax,0x805004
    memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  800a0c:	50                   	push   %eax
  800a0d:	ff 75 0c             	pushl  0xc(%ebp)
  800a10:	68 08 50 80 00       	push   $0x805008
  800a15:	e8 24 0e 00 00       	call   80183e <memmove>
    int r = fsipc(FSREQ_WRITE, NULL);
  800a1a:	ba 00 00 00 00       	mov    $0x0,%edx
  800a1f:	b8 04 00 00 00       	mov    $0x4,%eax
  800a24:	e8 cc fe ff ff       	call   8008f5 <fsipc>
    return r;
}
  800a29:	c9                   	leave  
  800a2a:	c3                   	ret    

00800a2b <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a2b:	55                   	push   %ebp
  800a2c:	89 e5                	mov    %esp,%ebp
  800a2e:	56                   	push   %esi
  800a2f:	53                   	push   %ebx
  800a30:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a33:	8b 45 08             	mov    0x8(%ebp),%eax
  800a36:	8b 40 0c             	mov    0xc(%eax),%eax
  800a39:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a3e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a44:	ba 00 00 00 00       	mov    $0x0,%edx
  800a49:	b8 03 00 00 00       	mov    $0x3,%eax
  800a4e:	e8 a2 fe ff ff       	call   8008f5 <fsipc>
  800a53:	89 c3                	mov    %eax,%ebx
  800a55:	85 c0                	test   %eax,%eax
  800a57:	78 4b                	js     800aa4 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a59:	39 c6                	cmp    %eax,%esi
  800a5b:	73 16                	jae    800a73 <devfile_read+0x48>
  800a5d:	68 64 1e 80 00       	push   $0x801e64
  800a62:	68 6b 1e 80 00       	push   $0x801e6b
  800a67:	6a 7c                	push   $0x7c
  800a69:	68 80 1e 80 00       	push   $0x801e80
  800a6e:	e8 bd 05 00 00       	call   801030 <_panic>
	assert(r <= PGSIZE);
  800a73:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a78:	7e 16                	jle    800a90 <devfile_read+0x65>
  800a7a:	68 8b 1e 80 00       	push   $0x801e8b
  800a7f:	68 6b 1e 80 00       	push   $0x801e6b
  800a84:	6a 7d                	push   $0x7d
  800a86:	68 80 1e 80 00       	push   $0x801e80
  800a8b:	e8 a0 05 00 00       	call   801030 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a90:	83 ec 04             	sub    $0x4,%esp
  800a93:	50                   	push   %eax
  800a94:	68 00 50 80 00       	push   $0x805000
  800a99:	ff 75 0c             	pushl  0xc(%ebp)
  800a9c:	e8 9d 0d 00 00       	call   80183e <memmove>
	return r;
  800aa1:	83 c4 10             	add    $0x10,%esp
}
  800aa4:	89 d8                	mov    %ebx,%eax
  800aa6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800aa9:	5b                   	pop    %ebx
  800aaa:	5e                   	pop    %esi
  800aab:	5d                   	pop    %ebp
  800aac:	c3                   	ret    

00800aad <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800aad:	55                   	push   %ebp
  800aae:	89 e5                	mov    %esp,%ebp
  800ab0:	53                   	push   %ebx
  800ab1:	83 ec 20             	sub    $0x20,%esp
  800ab4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800ab7:	53                   	push   %ebx
  800ab8:	e8 b6 0b 00 00       	call   801673 <strlen>
  800abd:	83 c4 10             	add    $0x10,%esp
  800ac0:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ac5:	7f 67                	jg     800b2e <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ac7:	83 ec 0c             	sub    $0xc,%esp
  800aca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800acd:	50                   	push   %eax
  800ace:	e8 9a f8 ff ff       	call   80036d <fd_alloc>
  800ad3:	83 c4 10             	add    $0x10,%esp
		return r;
  800ad6:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ad8:	85 c0                	test   %eax,%eax
  800ada:	78 57                	js     800b33 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800adc:	83 ec 08             	sub    $0x8,%esp
  800adf:	53                   	push   %ebx
  800ae0:	68 00 50 80 00       	push   $0x805000
  800ae5:	e8 c2 0b 00 00       	call   8016ac <strcpy>
	fsipcbuf.open.req_omode = mode;
  800aea:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aed:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800af2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800af5:	b8 01 00 00 00       	mov    $0x1,%eax
  800afa:	e8 f6 fd ff ff       	call   8008f5 <fsipc>
  800aff:	89 c3                	mov    %eax,%ebx
  800b01:	83 c4 10             	add    $0x10,%esp
  800b04:	85 c0                	test   %eax,%eax
  800b06:	79 14                	jns    800b1c <open+0x6f>
		fd_close(fd, 0);
  800b08:	83 ec 08             	sub    $0x8,%esp
  800b0b:	6a 00                	push   $0x0
  800b0d:	ff 75 f4             	pushl  -0xc(%ebp)
  800b10:	e8 50 f9 ff ff       	call   800465 <fd_close>
		return r;
  800b15:	83 c4 10             	add    $0x10,%esp
  800b18:	89 da                	mov    %ebx,%edx
  800b1a:	eb 17                	jmp    800b33 <open+0x86>
	}

	return fd2num(fd);
  800b1c:	83 ec 0c             	sub    $0xc,%esp
  800b1f:	ff 75 f4             	pushl  -0xc(%ebp)
  800b22:	e8 1f f8 ff ff       	call   800346 <fd2num>
  800b27:	89 c2                	mov    %eax,%edx
  800b29:	83 c4 10             	add    $0x10,%esp
  800b2c:	eb 05                	jmp    800b33 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b2e:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b33:	89 d0                	mov    %edx,%eax
  800b35:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b38:	c9                   	leave  
  800b39:	c3                   	ret    

00800b3a <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b3a:	55                   	push   %ebp
  800b3b:	89 e5                	mov    %esp,%ebp
  800b3d:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b40:	ba 00 00 00 00       	mov    $0x0,%edx
  800b45:	b8 08 00 00 00       	mov    $0x8,%eax
  800b4a:	e8 a6 fd ff ff       	call   8008f5 <fsipc>
}
  800b4f:	c9                   	leave  
  800b50:	c3                   	ret    

00800b51 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b51:	55                   	push   %ebp
  800b52:	89 e5                	mov    %esp,%ebp
  800b54:	56                   	push   %esi
  800b55:	53                   	push   %ebx
  800b56:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b59:	83 ec 0c             	sub    $0xc,%esp
  800b5c:	ff 75 08             	pushl  0x8(%ebp)
  800b5f:	e8 f2 f7 ff ff       	call   800356 <fd2data>
  800b64:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b66:	83 c4 08             	add    $0x8,%esp
  800b69:	68 97 1e 80 00       	push   $0x801e97
  800b6e:	53                   	push   %ebx
  800b6f:	e8 38 0b 00 00       	call   8016ac <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b74:	8b 46 04             	mov    0x4(%esi),%eax
  800b77:	2b 06                	sub    (%esi),%eax
  800b79:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b7f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b86:	00 00 00 
	stat->st_dev = &devpipe;
  800b89:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b90:	30 80 00 
	return 0;
}
  800b93:	b8 00 00 00 00       	mov    $0x0,%eax
  800b98:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b9b:	5b                   	pop    %ebx
  800b9c:	5e                   	pop    %esi
  800b9d:	5d                   	pop    %ebp
  800b9e:	c3                   	ret    

00800b9f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b9f:	55                   	push   %ebp
  800ba0:	89 e5                	mov    %esp,%ebp
  800ba2:	53                   	push   %ebx
  800ba3:	83 ec 0c             	sub    $0xc,%esp
  800ba6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800ba9:	53                   	push   %ebx
  800baa:	6a 00                	push   $0x0
  800bac:	e8 29 f6 ff ff       	call   8001da <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bb1:	89 1c 24             	mov    %ebx,(%esp)
  800bb4:	e8 9d f7 ff ff       	call   800356 <fd2data>
  800bb9:	83 c4 08             	add    $0x8,%esp
  800bbc:	50                   	push   %eax
  800bbd:	6a 00                	push   $0x0
  800bbf:	e8 16 f6 ff ff       	call   8001da <sys_page_unmap>
}
  800bc4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bc7:	c9                   	leave  
  800bc8:	c3                   	ret    

00800bc9 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bc9:	55                   	push   %ebp
  800bca:	89 e5                	mov    %esp,%ebp
  800bcc:	57                   	push   %edi
  800bcd:	56                   	push   %esi
  800bce:	53                   	push   %ebx
  800bcf:	83 ec 1c             	sub    $0x1c,%esp
  800bd2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800bd5:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800bd7:	a1 04 40 80 00       	mov    0x804004,%eax
  800bdc:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800bdf:	83 ec 0c             	sub    $0xc,%esp
  800be2:	ff 75 e0             	pushl  -0x20(%ebp)
  800be5:	e8 eb 0e 00 00       	call   801ad5 <pageref>
  800bea:	89 c3                	mov    %eax,%ebx
  800bec:	89 3c 24             	mov    %edi,(%esp)
  800bef:	e8 e1 0e 00 00       	call   801ad5 <pageref>
  800bf4:	83 c4 10             	add    $0x10,%esp
  800bf7:	39 c3                	cmp    %eax,%ebx
  800bf9:	0f 94 c1             	sete   %cl
  800bfc:	0f b6 c9             	movzbl %cl,%ecx
  800bff:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c02:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c08:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c0b:	39 ce                	cmp    %ecx,%esi
  800c0d:	74 1b                	je     800c2a <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c0f:	39 c3                	cmp    %eax,%ebx
  800c11:	75 c4                	jne    800bd7 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c13:	8b 42 58             	mov    0x58(%edx),%eax
  800c16:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c19:	50                   	push   %eax
  800c1a:	56                   	push   %esi
  800c1b:	68 9e 1e 80 00       	push   $0x801e9e
  800c20:	e8 e4 04 00 00       	call   801109 <cprintf>
  800c25:	83 c4 10             	add    $0x10,%esp
  800c28:	eb ad                	jmp    800bd7 <_pipeisclosed+0xe>
	}
}
  800c2a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c30:	5b                   	pop    %ebx
  800c31:	5e                   	pop    %esi
  800c32:	5f                   	pop    %edi
  800c33:	5d                   	pop    %ebp
  800c34:	c3                   	ret    

00800c35 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c35:	55                   	push   %ebp
  800c36:	89 e5                	mov    %esp,%ebp
  800c38:	57                   	push   %edi
  800c39:	56                   	push   %esi
  800c3a:	53                   	push   %ebx
  800c3b:	83 ec 28             	sub    $0x28,%esp
  800c3e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c41:	56                   	push   %esi
  800c42:	e8 0f f7 ff ff       	call   800356 <fd2data>
  800c47:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c49:	83 c4 10             	add    $0x10,%esp
  800c4c:	bf 00 00 00 00       	mov    $0x0,%edi
  800c51:	eb 4b                	jmp    800c9e <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c53:	89 da                	mov    %ebx,%edx
  800c55:	89 f0                	mov    %esi,%eax
  800c57:	e8 6d ff ff ff       	call   800bc9 <_pipeisclosed>
  800c5c:	85 c0                	test   %eax,%eax
  800c5e:	75 48                	jne    800ca8 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c60:	e8 d1 f4 ff ff       	call   800136 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c65:	8b 43 04             	mov    0x4(%ebx),%eax
  800c68:	8b 0b                	mov    (%ebx),%ecx
  800c6a:	8d 51 20             	lea    0x20(%ecx),%edx
  800c6d:	39 d0                	cmp    %edx,%eax
  800c6f:	73 e2                	jae    800c53 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c74:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c78:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c7b:	89 c2                	mov    %eax,%edx
  800c7d:	c1 fa 1f             	sar    $0x1f,%edx
  800c80:	89 d1                	mov    %edx,%ecx
  800c82:	c1 e9 1b             	shr    $0x1b,%ecx
  800c85:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c88:	83 e2 1f             	and    $0x1f,%edx
  800c8b:	29 ca                	sub    %ecx,%edx
  800c8d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800c91:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c95:	83 c0 01             	add    $0x1,%eax
  800c98:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c9b:	83 c7 01             	add    $0x1,%edi
  800c9e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800ca1:	75 c2                	jne    800c65 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800ca3:	8b 45 10             	mov    0x10(%ebp),%eax
  800ca6:	eb 05                	jmp    800cad <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800ca8:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb0:	5b                   	pop    %ebx
  800cb1:	5e                   	pop    %esi
  800cb2:	5f                   	pop    %edi
  800cb3:	5d                   	pop    %ebp
  800cb4:	c3                   	ret    

00800cb5 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cb5:	55                   	push   %ebp
  800cb6:	89 e5                	mov    %esp,%ebp
  800cb8:	57                   	push   %edi
  800cb9:	56                   	push   %esi
  800cba:	53                   	push   %ebx
  800cbb:	83 ec 18             	sub    $0x18,%esp
  800cbe:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800cc1:	57                   	push   %edi
  800cc2:	e8 8f f6 ff ff       	call   800356 <fd2data>
  800cc7:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cc9:	83 c4 10             	add    $0x10,%esp
  800ccc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd1:	eb 3d                	jmp    800d10 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800cd3:	85 db                	test   %ebx,%ebx
  800cd5:	74 04                	je     800cdb <devpipe_read+0x26>
				return i;
  800cd7:	89 d8                	mov    %ebx,%eax
  800cd9:	eb 44                	jmp    800d1f <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800cdb:	89 f2                	mov    %esi,%edx
  800cdd:	89 f8                	mov    %edi,%eax
  800cdf:	e8 e5 fe ff ff       	call   800bc9 <_pipeisclosed>
  800ce4:	85 c0                	test   %eax,%eax
  800ce6:	75 32                	jne    800d1a <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800ce8:	e8 49 f4 ff ff       	call   800136 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800ced:	8b 06                	mov    (%esi),%eax
  800cef:	3b 46 04             	cmp    0x4(%esi),%eax
  800cf2:	74 df                	je     800cd3 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800cf4:	99                   	cltd   
  800cf5:	c1 ea 1b             	shr    $0x1b,%edx
  800cf8:	01 d0                	add    %edx,%eax
  800cfa:	83 e0 1f             	and    $0x1f,%eax
  800cfd:	29 d0                	sub    %edx,%eax
  800cff:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d07:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d0a:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d0d:	83 c3 01             	add    $0x1,%ebx
  800d10:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d13:	75 d8                	jne    800ced <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d15:	8b 45 10             	mov    0x10(%ebp),%eax
  800d18:	eb 05                	jmp    800d1f <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d1a:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d1f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d22:	5b                   	pop    %ebx
  800d23:	5e                   	pop    %esi
  800d24:	5f                   	pop    %edi
  800d25:	5d                   	pop    %ebp
  800d26:	c3                   	ret    

00800d27 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d27:	55                   	push   %ebp
  800d28:	89 e5                	mov    %esp,%ebp
  800d2a:	56                   	push   %esi
  800d2b:	53                   	push   %ebx
  800d2c:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d2f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d32:	50                   	push   %eax
  800d33:	e8 35 f6 ff ff       	call   80036d <fd_alloc>
  800d38:	83 c4 10             	add    $0x10,%esp
  800d3b:	89 c2                	mov    %eax,%edx
  800d3d:	85 c0                	test   %eax,%eax
  800d3f:	0f 88 2c 01 00 00    	js     800e71 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d45:	83 ec 04             	sub    $0x4,%esp
  800d48:	68 07 04 00 00       	push   $0x407
  800d4d:	ff 75 f4             	pushl  -0xc(%ebp)
  800d50:	6a 00                	push   $0x0
  800d52:	e8 fe f3 ff ff       	call   800155 <sys_page_alloc>
  800d57:	83 c4 10             	add    $0x10,%esp
  800d5a:	89 c2                	mov    %eax,%edx
  800d5c:	85 c0                	test   %eax,%eax
  800d5e:	0f 88 0d 01 00 00    	js     800e71 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d64:	83 ec 0c             	sub    $0xc,%esp
  800d67:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d6a:	50                   	push   %eax
  800d6b:	e8 fd f5 ff ff       	call   80036d <fd_alloc>
  800d70:	89 c3                	mov    %eax,%ebx
  800d72:	83 c4 10             	add    $0x10,%esp
  800d75:	85 c0                	test   %eax,%eax
  800d77:	0f 88 e2 00 00 00    	js     800e5f <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d7d:	83 ec 04             	sub    $0x4,%esp
  800d80:	68 07 04 00 00       	push   $0x407
  800d85:	ff 75 f0             	pushl  -0x10(%ebp)
  800d88:	6a 00                	push   $0x0
  800d8a:	e8 c6 f3 ff ff       	call   800155 <sys_page_alloc>
  800d8f:	89 c3                	mov    %eax,%ebx
  800d91:	83 c4 10             	add    $0x10,%esp
  800d94:	85 c0                	test   %eax,%eax
  800d96:	0f 88 c3 00 00 00    	js     800e5f <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800d9c:	83 ec 0c             	sub    $0xc,%esp
  800d9f:	ff 75 f4             	pushl  -0xc(%ebp)
  800da2:	e8 af f5 ff ff       	call   800356 <fd2data>
  800da7:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800da9:	83 c4 0c             	add    $0xc,%esp
  800dac:	68 07 04 00 00       	push   $0x407
  800db1:	50                   	push   %eax
  800db2:	6a 00                	push   $0x0
  800db4:	e8 9c f3 ff ff       	call   800155 <sys_page_alloc>
  800db9:	89 c3                	mov    %eax,%ebx
  800dbb:	83 c4 10             	add    $0x10,%esp
  800dbe:	85 c0                	test   %eax,%eax
  800dc0:	0f 88 89 00 00 00    	js     800e4f <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dc6:	83 ec 0c             	sub    $0xc,%esp
  800dc9:	ff 75 f0             	pushl  -0x10(%ebp)
  800dcc:	e8 85 f5 ff ff       	call   800356 <fd2data>
  800dd1:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800dd8:	50                   	push   %eax
  800dd9:	6a 00                	push   $0x0
  800ddb:	56                   	push   %esi
  800ddc:	6a 00                	push   $0x0
  800dde:	e8 b5 f3 ff ff       	call   800198 <sys_page_map>
  800de3:	89 c3                	mov    %eax,%ebx
  800de5:	83 c4 20             	add    $0x20,%esp
  800de8:	85 c0                	test   %eax,%eax
  800dea:	78 55                	js     800e41 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800dec:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800df2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800df5:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800df7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dfa:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e01:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e07:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e0a:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e0f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e16:	83 ec 0c             	sub    $0xc,%esp
  800e19:	ff 75 f4             	pushl  -0xc(%ebp)
  800e1c:	e8 25 f5 ff ff       	call   800346 <fd2num>
  800e21:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e24:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e26:	83 c4 04             	add    $0x4,%esp
  800e29:	ff 75 f0             	pushl  -0x10(%ebp)
  800e2c:	e8 15 f5 ff ff       	call   800346 <fd2num>
  800e31:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e34:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e37:	83 c4 10             	add    $0x10,%esp
  800e3a:	ba 00 00 00 00       	mov    $0x0,%edx
  800e3f:	eb 30                	jmp    800e71 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e41:	83 ec 08             	sub    $0x8,%esp
  800e44:	56                   	push   %esi
  800e45:	6a 00                	push   $0x0
  800e47:	e8 8e f3 ff ff       	call   8001da <sys_page_unmap>
  800e4c:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e4f:	83 ec 08             	sub    $0x8,%esp
  800e52:	ff 75 f0             	pushl  -0x10(%ebp)
  800e55:	6a 00                	push   $0x0
  800e57:	e8 7e f3 ff ff       	call   8001da <sys_page_unmap>
  800e5c:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e5f:	83 ec 08             	sub    $0x8,%esp
  800e62:	ff 75 f4             	pushl  -0xc(%ebp)
  800e65:	6a 00                	push   $0x0
  800e67:	e8 6e f3 ff ff       	call   8001da <sys_page_unmap>
  800e6c:	83 c4 10             	add    $0x10,%esp
  800e6f:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e71:	89 d0                	mov    %edx,%eax
  800e73:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e76:	5b                   	pop    %ebx
  800e77:	5e                   	pop    %esi
  800e78:	5d                   	pop    %ebp
  800e79:	c3                   	ret    

00800e7a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e7a:	55                   	push   %ebp
  800e7b:	89 e5                	mov    %esp,%ebp
  800e7d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e80:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e83:	50                   	push   %eax
  800e84:	ff 75 08             	pushl  0x8(%ebp)
  800e87:	e8 30 f5 ff ff       	call   8003bc <fd_lookup>
  800e8c:	83 c4 10             	add    $0x10,%esp
  800e8f:	85 c0                	test   %eax,%eax
  800e91:	78 18                	js     800eab <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e93:	83 ec 0c             	sub    $0xc,%esp
  800e96:	ff 75 f4             	pushl  -0xc(%ebp)
  800e99:	e8 b8 f4 ff ff       	call   800356 <fd2data>
	return _pipeisclosed(fd, p);
  800e9e:	89 c2                	mov    %eax,%edx
  800ea0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ea3:	e8 21 fd ff ff       	call   800bc9 <_pipeisclosed>
  800ea8:	83 c4 10             	add    $0x10,%esp
}
  800eab:	c9                   	leave  
  800eac:	c3                   	ret    

00800ead <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ead:	55                   	push   %ebp
  800eae:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800eb0:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb5:	5d                   	pop    %ebp
  800eb6:	c3                   	ret    

00800eb7 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800eb7:	55                   	push   %ebp
  800eb8:	89 e5                	mov    %esp,%ebp
  800eba:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ebd:	68 b6 1e 80 00       	push   $0x801eb6
  800ec2:	ff 75 0c             	pushl  0xc(%ebp)
  800ec5:	e8 e2 07 00 00       	call   8016ac <strcpy>
	return 0;
}
  800eca:	b8 00 00 00 00       	mov    $0x0,%eax
  800ecf:	c9                   	leave  
  800ed0:	c3                   	ret    

00800ed1 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800ed1:	55                   	push   %ebp
  800ed2:	89 e5                	mov    %esp,%ebp
  800ed4:	57                   	push   %edi
  800ed5:	56                   	push   %esi
  800ed6:	53                   	push   %ebx
  800ed7:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800edd:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800ee2:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ee8:	eb 2d                	jmp    800f17 <devcons_write+0x46>
		m = n - tot;
  800eea:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eed:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800eef:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800ef2:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800ef7:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800efa:	83 ec 04             	sub    $0x4,%esp
  800efd:	53                   	push   %ebx
  800efe:	03 45 0c             	add    0xc(%ebp),%eax
  800f01:	50                   	push   %eax
  800f02:	57                   	push   %edi
  800f03:	e8 36 09 00 00       	call   80183e <memmove>
		sys_cputs(buf, m);
  800f08:	83 c4 08             	add    $0x8,%esp
  800f0b:	53                   	push   %ebx
  800f0c:	57                   	push   %edi
  800f0d:	e8 87 f1 ff ff       	call   800099 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f12:	01 de                	add    %ebx,%esi
  800f14:	83 c4 10             	add    $0x10,%esp
  800f17:	89 f0                	mov    %esi,%eax
  800f19:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f1c:	72 cc                	jb     800eea <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f21:	5b                   	pop    %ebx
  800f22:	5e                   	pop    %esi
  800f23:	5f                   	pop    %edi
  800f24:	5d                   	pop    %ebp
  800f25:	c3                   	ret    

00800f26 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f26:	55                   	push   %ebp
  800f27:	89 e5                	mov    %esp,%ebp
  800f29:	83 ec 08             	sub    $0x8,%esp
  800f2c:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f31:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f35:	74 2a                	je     800f61 <devcons_read+0x3b>
  800f37:	eb 05                	jmp    800f3e <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f39:	e8 f8 f1 ff ff       	call   800136 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f3e:	e8 74 f1 ff ff       	call   8000b7 <sys_cgetc>
  800f43:	85 c0                	test   %eax,%eax
  800f45:	74 f2                	je     800f39 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f47:	85 c0                	test   %eax,%eax
  800f49:	78 16                	js     800f61 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f4b:	83 f8 04             	cmp    $0x4,%eax
  800f4e:	74 0c                	je     800f5c <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f50:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f53:	88 02                	mov    %al,(%edx)
	return 1;
  800f55:	b8 01 00 00 00       	mov    $0x1,%eax
  800f5a:	eb 05                	jmp    800f61 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f5c:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f61:	c9                   	leave  
  800f62:	c3                   	ret    

00800f63 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f63:	55                   	push   %ebp
  800f64:	89 e5                	mov    %esp,%ebp
  800f66:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f69:	8b 45 08             	mov    0x8(%ebp),%eax
  800f6c:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f6f:	6a 01                	push   $0x1
  800f71:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f74:	50                   	push   %eax
  800f75:	e8 1f f1 ff ff       	call   800099 <sys_cputs>
}
  800f7a:	83 c4 10             	add    $0x10,%esp
  800f7d:	c9                   	leave  
  800f7e:	c3                   	ret    

00800f7f <getchar>:

int
getchar(void)
{
  800f7f:	55                   	push   %ebp
  800f80:	89 e5                	mov    %esp,%ebp
  800f82:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f85:	6a 01                	push   $0x1
  800f87:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f8a:	50                   	push   %eax
  800f8b:	6a 00                	push   $0x0
  800f8d:	e8 90 f6 ff ff       	call   800622 <read>
	if (r < 0)
  800f92:	83 c4 10             	add    $0x10,%esp
  800f95:	85 c0                	test   %eax,%eax
  800f97:	78 0f                	js     800fa8 <getchar+0x29>
		return r;
	if (r < 1)
  800f99:	85 c0                	test   %eax,%eax
  800f9b:	7e 06                	jle    800fa3 <getchar+0x24>
		return -E_EOF;
	return c;
  800f9d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fa1:	eb 05                	jmp    800fa8 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fa3:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fa8:	c9                   	leave  
  800fa9:	c3                   	ret    

00800faa <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800faa:	55                   	push   %ebp
  800fab:	89 e5                	mov    %esp,%ebp
  800fad:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fb0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fb3:	50                   	push   %eax
  800fb4:	ff 75 08             	pushl  0x8(%ebp)
  800fb7:	e8 00 f4 ff ff       	call   8003bc <fd_lookup>
  800fbc:	83 c4 10             	add    $0x10,%esp
  800fbf:	85 c0                	test   %eax,%eax
  800fc1:	78 11                	js     800fd4 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800fc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fc6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fcc:	39 10                	cmp    %edx,(%eax)
  800fce:	0f 94 c0             	sete   %al
  800fd1:	0f b6 c0             	movzbl %al,%eax
}
  800fd4:	c9                   	leave  
  800fd5:	c3                   	ret    

00800fd6 <opencons>:

int
opencons(void)
{
  800fd6:	55                   	push   %ebp
  800fd7:	89 e5                	mov    %esp,%ebp
  800fd9:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fdc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fdf:	50                   	push   %eax
  800fe0:	e8 88 f3 ff ff       	call   80036d <fd_alloc>
  800fe5:	83 c4 10             	add    $0x10,%esp
		return r;
  800fe8:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fea:	85 c0                	test   %eax,%eax
  800fec:	78 3e                	js     80102c <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fee:	83 ec 04             	sub    $0x4,%esp
  800ff1:	68 07 04 00 00       	push   $0x407
  800ff6:	ff 75 f4             	pushl  -0xc(%ebp)
  800ff9:	6a 00                	push   $0x0
  800ffb:	e8 55 f1 ff ff       	call   800155 <sys_page_alloc>
  801000:	83 c4 10             	add    $0x10,%esp
		return r;
  801003:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801005:	85 c0                	test   %eax,%eax
  801007:	78 23                	js     80102c <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801009:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80100f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801012:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801014:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801017:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80101e:	83 ec 0c             	sub    $0xc,%esp
  801021:	50                   	push   %eax
  801022:	e8 1f f3 ff ff       	call   800346 <fd2num>
  801027:	89 c2                	mov    %eax,%edx
  801029:	83 c4 10             	add    $0x10,%esp
}
  80102c:	89 d0                	mov    %edx,%eax
  80102e:	c9                   	leave  
  80102f:	c3                   	ret    

00801030 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801030:	55                   	push   %ebp
  801031:	89 e5                	mov    %esp,%ebp
  801033:	56                   	push   %esi
  801034:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801035:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801038:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80103e:	e8 d4 f0 ff ff       	call   800117 <sys_getenvid>
  801043:	83 ec 0c             	sub    $0xc,%esp
  801046:	ff 75 0c             	pushl  0xc(%ebp)
  801049:	ff 75 08             	pushl  0x8(%ebp)
  80104c:	56                   	push   %esi
  80104d:	50                   	push   %eax
  80104e:	68 c4 1e 80 00       	push   $0x801ec4
  801053:	e8 b1 00 00 00       	call   801109 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801058:	83 c4 18             	add    $0x18,%esp
  80105b:	53                   	push   %ebx
  80105c:	ff 75 10             	pushl  0x10(%ebp)
  80105f:	e8 54 00 00 00       	call   8010b8 <vcprintf>
	cprintf("\n");
  801064:	c7 04 24 af 1e 80 00 	movl   $0x801eaf,(%esp)
  80106b:	e8 99 00 00 00       	call   801109 <cprintf>
  801070:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801073:	cc                   	int3   
  801074:	eb fd                	jmp    801073 <_panic+0x43>

00801076 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801076:	55                   	push   %ebp
  801077:	89 e5                	mov    %esp,%ebp
  801079:	53                   	push   %ebx
  80107a:	83 ec 04             	sub    $0x4,%esp
  80107d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801080:	8b 13                	mov    (%ebx),%edx
  801082:	8d 42 01             	lea    0x1(%edx),%eax
  801085:	89 03                	mov    %eax,(%ebx)
  801087:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80108a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80108e:	3d ff 00 00 00       	cmp    $0xff,%eax
  801093:	75 1a                	jne    8010af <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801095:	83 ec 08             	sub    $0x8,%esp
  801098:	68 ff 00 00 00       	push   $0xff
  80109d:	8d 43 08             	lea    0x8(%ebx),%eax
  8010a0:	50                   	push   %eax
  8010a1:	e8 f3 ef ff ff       	call   800099 <sys_cputs>
		b->idx = 0;
  8010a6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010ac:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010af:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010b6:	c9                   	leave  
  8010b7:	c3                   	ret    

008010b8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010b8:	55                   	push   %ebp
  8010b9:	89 e5                	mov    %esp,%ebp
  8010bb:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010c1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010c8:	00 00 00 
	b.cnt = 0;
  8010cb:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010d2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010d5:	ff 75 0c             	pushl  0xc(%ebp)
  8010d8:	ff 75 08             	pushl  0x8(%ebp)
  8010db:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010e1:	50                   	push   %eax
  8010e2:	68 76 10 80 00       	push   $0x801076
  8010e7:	e8 54 01 00 00       	call   801240 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010ec:	83 c4 08             	add    $0x8,%esp
  8010ef:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010f5:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010fb:	50                   	push   %eax
  8010fc:	e8 98 ef ff ff       	call   800099 <sys_cputs>

	return b.cnt;
}
  801101:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801107:	c9                   	leave  
  801108:	c3                   	ret    

00801109 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801109:	55                   	push   %ebp
  80110a:	89 e5                	mov    %esp,%ebp
  80110c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80110f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801112:	50                   	push   %eax
  801113:	ff 75 08             	pushl  0x8(%ebp)
  801116:	e8 9d ff ff ff       	call   8010b8 <vcprintf>
	va_end(ap);

	return cnt;
}
  80111b:	c9                   	leave  
  80111c:	c3                   	ret    

0080111d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80111d:	55                   	push   %ebp
  80111e:	89 e5                	mov    %esp,%ebp
  801120:	57                   	push   %edi
  801121:	56                   	push   %esi
  801122:	53                   	push   %ebx
  801123:	83 ec 1c             	sub    $0x1c,%esp
  801126:	89 c7                	mov    %eax,%edi
  801128:	89 d6                	mov    %edx,%esi
  80112a:	8b 45 08             	mov    0x8(%ebp),%eax
  80112d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801130:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801133:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801136:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801139:	bb 00 00 00 00       	mov    $0x0,%ebx
  80113e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801141:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801144:	39 d3                	cmp    %edx,%ebx
  801146:	72 05                	jb     80114d <printnum+0x30>
  801148:	39 45 10             	cmp    %eax,0x10(%ebp)
  80114b:	77 45                	ja     801192 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80114d:	83 ec 0c             	sub    $0xc,%esp
  801150:	ff 75 18             	pushl  0x18(%ebp)
  801153:	8b 45 14             	mov    0x14(%ebp),%eax
  801156:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801159:	53                   	push   %ebx
  80115a:	ff 75 10             	pushl  0x10(%ebp)
  80115d:	83 ec 08             	sub    $0x8,%esp
  801160:	ff 75 e4             	pushl  -0x1c(%ebp)
  801163:	ff 75 e0             	pushl  -0x20(%ebp)
  801166:	ff 75 dc             	pushl  -0x24(%ebp)
  801169:	ff 75 d8             	pushl  -0x28(%ebp)
  80116c:	e8 9f 09 00 00       	call   801b10 <__udivdi3>
  801171:	83 c4 18             	add    $0x18,%esp
  801174:	52                   	push   %edx
  801175:	50                   	push   %eax
  801176:	89 f2                	mov    %esi,%edx
  801178:	89 f8                	mov    %edi,%eax
  80117a:	e8 9e ff ff ff       	call   80111d <printnum>
  80117f:	83 c4 20             	add    $0x20,%esp
  801182:	eb 18                	jmp    80119c <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801184:	83 ec 08             	sub    $0x8,%esp
  801187:	56                   	push   %esi
  801188:	ff 75 18             	pushl  0x18(%ebp)
  80118b:	ff d7                	call   *%edi
  80118d:	83 c4 10             	add    $0x10,%esp
  801190:	eb 03                	jmp    801195 <printnum+0x78>
  801192:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801195:	83 eb 01             	sub    $0x1,%ebx
  801198:	85 db                	test   %ebx,%ebx
  80119a:	7f e8                	jg     801184 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80119c:	83 ec 08             	sub    $0x8,%esp
  80119f:	56                   	push   %esi
  8011a0:	83 ec 04             	sub    $0x4,%esp
  8011a3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011a6:	ff 75 e0             	pushl  -0x20(%ebp)
  8011a9:	ff 75 dc             	pushl  -0x24(%ebp)
  8011ac:	ff 75 d8             	pushl  -0x28(%ebp)
  8011af:	e8 8c 0a 00 00       	call   801c40 <__umoddi3>
  8011b4:	83 c4 14             	add    $0x14,%esp
  8011b7:	0f be 80 e7 1e 80 00 	movsbl 0x801ee7(%eax),%eax
  8011be:	50                   	push   %eax
  8011bf:	ff d7                	call   *%edi
}
  8011c1:	83 c4 10             	add    $0x10,%esp
  8011c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011c7:	5b                   	pop    %ebx
  8011c8:	5e                   	pop    %esi
  8011c9:	5f                   	pop    %edi
  8011ca:	5d                   	pop    %ebp
  8011cb:	c3                   	ret    

008011cc <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8011cc:	55                   	push   %ebp
  8011cd:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011cf:	83 fa 01             	cmp    $0x1,%edx
  8011d2:	7e 0e                	jle    8011e2 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8011d4:	8b 10                	mov    (%eax),%edx
  8011d6:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011d9:	89 08                	mov    %ecx,(%eax)
  8011db:	8b 02                	mov    (%edx),%eax
  8011dd:	8b 52 04             	mov    0x4(%edx),%edx
  8011e0:	eb 22                	jmp    801204 <getuint+0x38>
	else if (lflag)
  8011e2:	85 d2                	test   %edx,%edx
  8011e4:	74 10                	je     8011f6 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8011e6:	8b 10                	mov    (%eax),%edx
  8011e8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011eb:	89 08                	mov    %ecx,(%eax)
  8011ed:	8b 02                	mov    (%edx),%eax
  8011ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8011f4:	eb 0e                	jmp    801204 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8011f6:	8b 10                	mov    (%eax),%edx
  8011f8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011fb:	89 08                	mov    %ecx,(%eax)
  8011fd:	8b 02                	mov    (%edx),%eax
  8011ff:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801204:	5d                   	pop    %ebp
  801205:	c3                   	ret    

00801206 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801206:	55                   	push   %ebp
  801207:	89 e5                	mov    %esp,%ebp
  801209:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80120c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801210:	8b 10                	mov    (%eax),%edx
  801212:	3b 50 04             	cmp    0x4(%eax),%edx
  801215:	73 0a                	jae    801221 <sprintputch+0x1b>
		*b->buf++ = ch;
  801217:	8d 4a 01             	lea    0x1(%edx),%ecx
  80121a:	89 08                	mov    %ecx,(%eax)
  80121c:	8b 45 08             	mov    0x8(%ebp),%eax
  80121f:	88 02                	mov    %al,(%edx)
}
  801221:	5d                   	pop    %ebp
  801222:	c3                   	ret    

00801223 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801223:	55                   	push   %ebp
  801224:	89 e5                	mov    %esp,%ebp
  801226:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801229:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80122c:	50                   	push   %eax
  80122d:	ff 75 10             	pushl  0x10(%ebp)
  801230:	ff 75 0c             	pushl  0xc(%ebp)
  801233:	ff 75 08             	pushl  0x8(%ebp)
  801236:	e8 05 00 00 00       	call   801240 <vprintfmt>
	va_end(ap);
}
  80123b:	83 c4 10             	add    $0x10,%esp
  80123e:	c9                   	leave  
  80123f:	c3                   	ret    

00801240 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801240:	55                   	push   %ebp
  801241:	89 e5                	mov    %esp,%ebp
  801243:	57                   	push   %edi
  801244:	56                   	push   %esi
  801245:	53                   	push   %ebx
  801246:	83 ec 2c             	sub    $0x2c,%esp
  801249:	8b 75 08             	mov    0x8(%ebp),%esi
  80124c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80124f:	8b 7d 10             	mov    0x10(%ebp),%edi
  801252:	eb 12                	jmp    801266 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801254:	85 c0                	test   %eax,%eax
  801256:	0f 84 a7 03 00 00    	je     801603 <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
  80125c:	83 ec 08             	sub    $0x8,%esp
  80125f:	53                   	push   %ebx
  801260:	50                   	push   %eax
  801261:	ff d6                	call   *%esi
  801263:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801266:	83 c7 01             	add    $0x1,%edi
  801269:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80126d:	83 f8 25             	cmp    $0x25,%eax
  801270:	75 e2                	jne    801254 <vprintfmt+0x14>
  801272:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801276:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80127d:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  801284:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80128b:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  801292:	b9 00 00 00 00       	mov    $0x0,%ecx
  801297:	eb 07                	jmp    8012a0 <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801299:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80129c:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012a0:	8d 47 01             	lea    0x1(%edi),%eax
  8012a3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012a6:	0f b6 07             	movzbl (%edi),%eax
  8012a9:	0f b6 d0             	movzbl %al,%edx
  8012ac:	83 e8 23             	sub    $0x23,%eax
  8012af:	3c 55                	cmp    $0x55,%al
  8012b1:	0f 87 31 03 00 00    	ja     8015e8 <vprintfmt+0x3a8>
  8012b7:	0f b6 c0             	movzbl %al,%eax
  8012ba:	ff 24 85 20 20 80 00 	jmp    *0x802020(,%eax,4)
  8012c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8012c4:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8012c8:	eb d6                	jmp    8012a0 <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8012d2:	89 75 08             	mov    %esi,0x8(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012d5:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8012d8:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8012dc:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8012df:	8d 72 d0             	lea    -0x30(%edx),%esi
  8012e2:	83 fe 09             	cmp    $0x9,%esi
  8012e5:	77 34                	ja     80131b <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012e7:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8012ea:	eb e9                	jmp    8012d5 <vprintfmt+0x95>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8012ef:	8d 50 04             	lea    0x4(%eax),%edx
  8012f2:	89 55 14             	mov    %edx,0x14(%ebp)
  8012f5:	8b 00                	mov    (%eax),%eax
  8012f7:	89 45 cc             	mov    %eax,-0x34(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8012fd:	eb 22                	jmp    801321 <vprintfmt+0xe1>
  8012ff:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801302:	85 c0                	test   %eax,%eax
  801304:	0f 48 c1             	cmovs  %ecx,%eax
  801307:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80130a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80130d:	eb 91                	jmp    8012a0 <vprintfmt+0x60>
  80130f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801312:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801319:	eb 85                	jmp    8012a0 <vprintfmt+0x60>
  80131b:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80131e:	8b 75 08             	mov    0x8(%ebp),%esi

		process_precision:
			if (width < 0)
  801321:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801325:	0f 89 75 ff ff ff    	jns    8012a0 <vprintfmt+0x60>
				width = precision, precision = -1;
  80132b:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80132e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801331:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  801338:	e9 63 ff ff ff       	jmp    8012a0 <vprintfmt+0x60>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80133d:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801341:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801344:	e9 57 ff ff ff       	jmp    8012a0 <vprintfmt+0x60>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801349:	8b 45 14             	mov    0x14(%ebp),%eax
  80134c:	8d 50 04             	lea    0x4(%eax),%edx
  80134f:	89 55 14             	mov    %edx,0x14(%ebp)
  801352:	83 ec 08             	sub    $0x8,%esp
  801355:	53                   	push   %ebx
  801356:	ff 30                	pushl  (%eax)
  801358:	ff d6                	call   *%esi
			break;
  80135a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80135d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801360:	e9 01 ff ff ff       	jmp    801266 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801365:	8b 45 14             	mov    0x14(%ebp),%eax
  801368:	8d 50 04             	lea    0x4(%eax),%edx
  80136b:	89 55 14             	mov    %edx,0x14(%ebp)
  80136e:	8b 00                	mov    (%eax),%eax
  801370:	99                   	cltd   
  801371:	31 d0                	xor    %edx,%eax
  801373:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801375:	83 f8 0f             	cmp    $0xf,%eax
  801378:	7f 0b                	jg     801385 <vprintfmt+0x145>
  80137a:	8b 14 85 80 21 80 00 	mov    0x802180(,%eax,4),%edx
  801381:	85 d2                	test   %edx,%edx
  801383:	75 18                	jne    80139d <vprintfmt+0x15d>
				printfmt(putch, putdat, "error %d", err);
  801385:	50                   	push   %eax
  801386:	68 ff 1e 80 00       	push   $0x801eff
  80138b:	53                   	push   %ebx
  80138c:	56                   	push   %esi
  80138d:	e8 91 fe ff ff       	call   801223 <printfmt>
  801392:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801395:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801398:	e9 c9 fe ff ff       	jmp    801266 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80139d:	52                   	push   %edx
  80139e:	68 7d 1e 80 00       	push   $0x801e7d
  8013a3:	53                   	push   %ebx
  8013a4:	56                   	push   %esi
  8013a5:	e8 79 fe ff ff       	call   801223 <printfmt>
  8013aa:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013b0:	e9 b1 fe ff ff       	jmp    801266 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8013b8:	8d 50 04             	lea    0x4(%eax),%edx
  8013bb:	89 55 14             	mov    %edx,0x14(%ebp)
  8013be:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8013c0:	85 ff                	test   %edi,%edi
  8013c2:	b8 f8 1e 80 00       	mov    $0x801ef8,%eax
  8013c7:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8013ca:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013ce:	0f 8e 94 00 00 00    	jle    801468 <vprintfmt+0x228>
  8013d4:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8013d8:	0f 84 98 00 00 00    	je     801476 <vprintfmt+0x236>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013de:	83 ec 08             	sub    $0x8,%esp
  8013e1:	ff 75 cc             	pushl  -0x34(%ebp)
  8013e4:	57                   	push   %edi
  8013e5:	e8 a1 02 00 00       	call   80168b <strnlen>
  8013ea:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013ed:	29 c1                	sub    %eax,%ecx
  8013ef:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8013f2:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8013f5:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8013f9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8013fc:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8013ff:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801401:	eb 0f                	jmp    801412 <vprintfmt+0x1d2>
					putch(padc, putdat);
  801403:	83 ec 08             	sub    $0x8,%esp
  801406:	53                   	push   %ebx
  801407:	ff 75 e0             	pushl  -0x20(%ebp)
  80140a:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80140c:	83 ef 01             	sub    $0x1,%edi
  80140f:	83 c4 10             	add    $0x10,%esp
  801412:	85 ff                	test   %edi,%edi
  801414:	7f ed                	jg     801403 <vprintfmt+0x1c3>
  801416:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801419:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80141c:	85 c9                	test   %ecx,%ecx
  80141e:	b8 00 00 00 00       	mov    $0x0,%eax
  801423:	0f 49 c1             	cmovns %ecx,%eax
  801426:	29 c1                	sub    %eax,%ecx
  801428:	89 75 08             	mov    %esi,0x8(%ebp)
  80142b:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80142e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801431:	89 cb                	mov    %ecx,%ebx
  801433:	eb 4d                	jmp    801482 <vprintfmt+0x242>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801435:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801439:	74 1b                	je     801456 <vprintfmt+0x216>
  80143b:	0f be c0             	movsbl %al,%eax
  80143e:	83 e8 20             	sub    $0x20,%eax
  801441:	83 f8 5e             	cmp    $0x5e,%eax
  801444:	76 10                	jbe    801456 <vprintfmt+0x216>
					putch('?', putdat);
  801446:	83 ec 08             	sub    $0x8,%esp
  801449:	ff 75 0c             	pushl  0xc(%ebp)
  80144c:	6a 3f                	push   $0x3f
  80144e:	ff 55 08             	call   *0x8(%ebp)
  801451:	83 c4 10             	add    $0x10,%esp
  801454:	eb 0d                	jmp    801463 <vprintfmt+0x223>
				else
					putch(ch, putdat);
  801456:	83 ec 08             	sub    $0x8,%esp
  801459:	ff 75 0c             	pushl  0xc(%ebp)
  80145c:	52                   	push   %edx
  80145d:	ff 55 08             	call   *0x8(%ebp)
  801460:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801463:	83 eb 01             	sub    $0x1,%ebx
  801466:	eb 1a                	jmp    801482 <vprintfmt+0x242>
  801468:	89 75 08             	mov    %esi,0x8(%ebp)
  80146b:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80146e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801471:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801474:	eb 0c                	jmp    801482 <vprintfmt+0x242>
  801476:	89 75 08             	mov    %esi,0x8(%ebp)
  801479:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80147c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80147f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801482:	83 c7 01             	add    $0x1,%edi
  801485:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801489:	0f be d0             	movsbl %al,%edx
  80148c:	85 d2                	test   %edx,%edx
  80148e:	74 23                	je     8014b3 <vprintfmt+0x273>
  801490:	85 f6                	test   %esi,%esi
  801492:	78 a1                	js     801435 <vprintfmt+0x1f5>
  801494:	83 ee 01             	sub    $0x1,%esi
  801497:	79 9c                	jns    801435 <vprintfmt+0x1f5>
  801499:	89 df                	mov    %ebx,%edi
  80149b:	8b 75 08             	mov    0x8(%ebp),%esi
  80149e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014a1:	eb 18                	jmp    8014bb <vprintfmt+0x27b>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014a3:	83 ec 08             	sub    $0x8,%esp
  8014a6:	53                   	push   %ebx
  8014a7:	6a 20                	push   $0x20
  8014a9:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014ab:	83 ef 01             	sub    $0x1,%edi
  8014ae:	83 c4 10             	add    $0x10,%esp
  8014b1:	eb 08                	jmp    8014bb <vprintfmt+0x27b>
  8014b3:	89 df                	mov    %ebx,%edi
  8014b5:	8b 75 08             	mov    0x8(%ebp),%esi
  8014b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014bb:	85 ff                	test   %edi,%edi
  8014bd:	7f e4                	jg     8014a3 <vprintfmt+0x263>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014c2:	e9 9f fd ff ff       	jmp    801266 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014c7:	83 7d d0 01          	cmpl   $0x1,-0x30(%ebp)
  8014cb:	7e 16                	jle    8014e3 <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  8014cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8014d0:	8d 50 08             	lea    0x8(%eax),%edx
  8014d3:	89 55 14             	mov    %edx,0x14(%ebp)
  8014d6:	8b 50 04             	mov    0x4(%eax),%edx
  8014d9:	8b 00                	mov    (%eax),%eax
  8014db:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014de:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8014e1:	eb 34                	jmp    801517 <vprintfmt+0x2d7>
	else if (lflag)
  8014e3:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8014e7:	74 18                	je     801501 <vprintfmt+0x2c1>
		return va_arg(*ap, long);
  8014e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ec:	8d 50 04             	lea    0x4(%eax),%edx
  8014ef:	89 55 14             	mov    %edx,0x14(%ebp)
  8014f2:	8b 00                	mov    (%eax),%eax
  8014f4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014f7:	89 c1                	mov    %eax,%ecx
  8014f9:	c1 f9 1f             	sar    $0x1f,%ecx
  8014fc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014ff:	eb 16                	jmp    801517 <vprintfmt+0x2d7>
	else
		return va_arg(*ap, int);
  801501:	8b 45 14             	mov    0x14(%ebp),%eax
  801504:	8d 50 04             	lea    0x4(%eax),%edx
  801507:	89 55 14             	mov    %edx,0x14(%ebp)
  80150a:	8b 00                	mov    (%eax),%eax
  80150c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80150f:	89 c1                	mov    %eax,%ecx
  801511:	c1 f9 1f             	sar    $0x1f,%ecx
  801514:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801517:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80151a:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80151d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801522:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801526:	0f 89 88 00 00 00    	jns    8015b4 <vprintfmt+0x374>
				putch('-', putdat);
  80152c:	83 ec 08             	sub    $0x8,%esp
  80152f:	53                   	push   %ebx
  801530:	6a 2d                	push   $0x2d
  801532:	ff d6                	call   *%esi
				num = -(long long) num;
  801534:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801537:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80153a:	f7 d8                	neg    %eax
  80153c:	83 d2 00             	adc    $0x0,%edx
  80153f:	f7 da                	neg    %edx
  801541:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801544:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801549:	eb 69                	jmp    8015b4 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80154b:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80154e:	8d 45 14             	lea    0x14(%ebp),%eax
  801551:	e8 76 fc ff ff       	call   8011cc <getuint>
			base = 10;
  801556:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80155b:	eb 57                	jmp    8015b4 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  80155d:	83 ec 08             	sub    $0x8,%esp
  801560:	53                   	push   %ebx
  801561:	6a 30                	push   $0x30
  801563:	ff d6                	call   *%esi
			num = getuint(&ap, lflag);
  801565:	8b 55 d0             	mov    -0x30(%ebp),%edx
  801568:	8d 45 14             	lea    0x14(%ebp),%eax
  80156b:	e8 5c fc ff ff       	call   8011cc <getuint>
			base = 8;
			goto number;
  801570:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  801573:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801578:	eb 3a                	jmp    8015b4 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  80157a:	83 ec 08             	sub    $0x8,%esp
  80157d:	53                   	push   %ebx
  80157e:	6a 30                	push   $0x30
  801580:	ff d6                	call   *%esi
			putch('x', putdat);
  801582:	83 c4 08             	add    $0x8,%esp
  801585:	53                   	push   %ebx
  801586:	6a 78                	push   $0x78
  801588:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80158a:	8b 45 14             	mov    0x14(%ebp),%eax
  80158d:	8d 50 04             	lea    0x4(%eax),%edx
  801590:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801593:	8b 00                	mov    (%eax),%eax
  801595:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80159a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80159d:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8015a2:	eb 10                	jmp    8015b4 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8015a4:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8015a7:	8d 45 14             	lea    0x14(%ebp),%eax
  8015aa:	e8 1d fc ff ff       	call   8011cc <getuint>
			base = 16;
  8015af:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8015b4:	83 ec 0c             	sub    $0xc,%esp
  8015b7:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015bb:	57                   	push   %edi
  8015bc:	ff 75 e0             	pushl  -0x20(%ebp)
  8015bf:	51                   	push   %ecx
  8015c0:	52                   	push   %edx
  8015c1:	50                   	push   %eax
  8015c2:	89 da                	mov    %ebx,%edx
  8015c4:	89 f0                	mov    %esi,%eax
  8015c6:	e8 52 fb ff ff       	call   80111d <printnum>
			break;
  8015cb:	83 c4 20             	add    $0x20,%esp
  8015ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015d1:	e9 90 fc ff ff       	jmp    801266 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8015d6:	83 ec 08             	sub    $0x8,%esp
  8015d9:	53                   	push   %ebx
  8015da:	52                   	push   %edx
  8015db:	ff d6                	call   *%esi
			break;
  8015dd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8015e3:	e9 7e fc ff ff       	jmp    801266 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8015e8:	83 ec 08             	sub    $0x8,%esp
  8015eb:	53                   	push   %ebx
  8015ec:	6a 25                	push   $0x25
  8015ee:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015f0:	83 c4 10             	add    $0x10,%esp
  8015f3:	eb 03                	jmp    8015f8 <vprintfmt+0x3b8>
  8015f5:	83 ef 01             	sub    $0x1,%edi
  8015f8:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8015fc:	75 f7                	jne    8015f5 <vprintfmt+0x3b5>
  8015fe:	e9 63 fc ff ff       	jmp    801266 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801603:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801606:	5b                   	pop    %ebx
  801607:	5e                   	pop    %esi
  801608:	5f                   	pop    %edi
  801609:	5d                   	pop    %ebp
  80160a:	c3                   	ret    

0080160b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80160b:	55                   	push   %ebp
  80160c:	89 e5                	mov    %esp,%ebp
  80160e:	83 ec 18             	sub    $0x18,%esp
  801611:	8b 45 08             	mov    0x8(%ebp),%eax
  801614:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801617:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80161a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80161e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801621:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801628:	85 c0                	test   %eax,%eax
  80162a:	74 26                	je     801652 <vsnprintf+0x47>
  80162c:	85 d2                	test   %edx,%edx
  80162e:	7e 22                	jle    801652 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801630:	ff 75 14             	pushl  0x14(%ebp)
  801633:	ff 75 10             	pushl  0x10(%ebp)
  801636:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801639:	50                   	push   %eax
  80163a:	68 06 12 80 00       	push   $0x801206
  80163f:	e8 fc fb ff ff       	call   801240 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801644:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801647:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80164a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80164d:	83 c4 10             	add    $0x10,%esp
  801650:	eb 05                	jmp    801657 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801652:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801657:	c9                   	leave  
  801658:	c3                   	ret    

00801659 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801659:	55                   	push   %ebp
  80165a:	89 e5                	mov    %esp,%ebp
  80165c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80165f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801662:	50                   	push   %eax
  801663:	ff 75 10             	pushl  0x10(%ebp)
  801666:	ff 75 0c             	pushl  0xc(%ebp)
  801669:	ff 75 08             	pushl  0x8(%ebp)
  80166c:	e8 9a ff ff ff       	call   80160b <vsnprintf>
	va_end(ap);

	return rc;
}
  801671:	c9                   	leave  
  801672:	c3                   	ret    

00801673 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801673:	55                   	push   %ebp
  801674:	89 e5                	mov    %esp,%ebp
  801676:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801679:	b8 00 00 00 00       	mov    $0x0,%eax
  80167e:	eb 03                	jmp    801683 <strlen+0x10>
		n++;
  801680:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801683:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801687:	75 f7                	jne    801680 <strlen+0xd>
		n++;
	return n;
}
  801689:	5d                   	pop    %ebp
  80168a:	c3                   	ret    

0080168b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80168b:	55                   	push   %ebp
  80168c:	89 e5                	mov    %esp,%ebp
  80168e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801691:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801694:	ba 00 00 00 00       	mov    $0x0,%edx
  801699:	eb 03                	jmp    80169e <strnlen+0x13>
		n++;
  80169b:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80169e:	39 c2                	cmp    %eax,%edx
  8016a0:	74 08                	je     8016aa <strnlen+0x1f>
  8016a2:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8016a6:	75 f3                	jne    80169b <strnlen+0x10>
  8016a8:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8016aa:	5d                   	pop    %ebp
  8016ab:	c3                   	ret    

008016ac <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016ac:	55                   	push   %ebp
  8016ad:	89 e5                	mov    %esp,%ebp
  8016af:	53                   	push   %ebx
  8016b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016b6:	89 c2                	mov    %eax,%edx
  8016b8:	83 c2 01             	add    $0x1,%edx
  8016bb:	83 c1 01             	add    $0x1,%ecx
  8016be:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8016c2:	88 5a ff             	mov    %bl,-0x1(%edx)
  8016c5:	84 db                	test   %bl,%bl
  8016c7:	75 ef                	jne    8016b8 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8016c9:	5b                   	pop    %ebx
  8016ca:	5d                   	pop    %ebp
  8016cb:	c3                   	ret    

008016cc <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016cc:	55                   	push   %ebp
  8016cd:	89 e5                	mov    %esp,%ebp
  8016cf:	53                   	push   %ebx
  8016d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016d3:	53                   	push   %ebx
  8016d4:	e8 9a ff ff ff       	call   801673 <strlen>
  8016d9:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8016dc:	ff 75 0c             	pushl  0xc(%ebp)
  8016df:	01 d8                	add    %ebx,%eax
  8016e1:	50                   	push   %eax
  8016e2:	e8 c5 ff ff ff       	call   8016ac <strcpy>
	return dst;
}
  8016e7:	89 d8                	mov    %ebx,%eax
  8016e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ec:	c9                   	leave  
  8016ed:	c3                   	ret    

008016ee <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016ee:	55                   	push   %ebp
  8016ef:	89 e5                	mov    %esp,%ebp
  8016f1:	56                   	push   %esi
  8016f2:	53                   	push   %ebx
  8016f3:	8b 75 08             	mov    0x8(%ebp),%esi
  8016f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016f9:	89 f3                	mov    %esi,%ebx
  8016fb:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016fe:	89 f2                	mov    %esi,%edx
  801700:	eb 0f                	jmp    801711 <strncpy+0x23>
		*dst++ = *src;
  801702:	83 c2 01             	add    $0x1,%edx
  801705:	0f b6 01             	movzbl (%ecx),%eax
  801708:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80170b:	80 39 01             	cmpb   $0x1,(%ecx)
  80170e:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801711:	39 da                	cmp    %ebx,%edx
  801713:	75 ed                	jne    801702 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801715:	89 f0                	mov    %esi,%eax
  801717:	5b                   	pop    %ebx
  801718:	5e                   	pop    %esi
  801719:	5d                   	pop    %ebp
  80171a:	c3                   	ret    

0080171b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80171b:	55                   	push   %ebp
  80171c:	89 e5                	mov    %esp,%ebp
  80171e:	56                   	push   %esi
  80171f:	53                   	push   %ebx
  801720:	8b 75 08             	mov    0x8(%ebp),%esi
  801723:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801726:	8b 55 10             	mov    0x10(%ebp),%edx
  801729:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80172b:	85 d2                	test   %edx,%edx
  80172d:	74 21                	je     801750 <strlcpy+0x35>
  80172f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801733:	89 f2                	mov    %esi,%edx
  801735:	eb 09                	jmp    801740 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801737:	83 c2 01             	add    $0x1,%edx
  80173a:	83 c1 01             	add    $0x1,%ecx
  80173d:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801740:	39 c2                	cmp    %eax,%edx
  801742:	74 09                	je     80174d <strlcpy+0x32>
  801744:	0f b6 19             	movzbl (%ecx),%ebx
  801747:	84 db                	test   %bl,%bl
  801749:	75 ec                	jne    801737 <strlcpy+0x1c>
  80174b:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80174d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801750:	29 f0                	sub    %esi,%eax
}
  801752:	5b                   	pop    %ebx
  801753:	5e                   	pop    %esi
  801754:	5d                   	pop    %ebp
  801755:	c3                   	ret    

00801756 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801756:	55                   	push   %ebp
  801757:	89 e5                	mov    %esp,%ebp
  801759:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80175c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80175f:	eb 06                	jmp    801767 <strcmp+0x11>
		p++, q++;
  801761:	83 c1 01             	add    $0x1,%ecx
  801764:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801767:	0f b6 01             	movzbl (%ecx),%eax
  80176a:	84 c0                	test   %al,%al
  80176c:	74 04                	je     801772 <strcmp+0x1c>
  80176e:	3a 02                	cmp    (%edx),%al
  801770:	74 ef                	je     801761 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801772:	0f b6 c0             	movzbl %al,%eax
  801775:	0f b6 12             	movzbl (%edx),%edx
  801778:	29 d0                	sub    %edx,%eax
}
  80177a:	5d                   	pop    %ebp
  80177b:	c3                   	ret    

0080177c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80177c:	55                   	push   %ebp
  80177d:	89 e5                	mov    %esp,%ebp
  80177f:	53                   	push   %ebx
  801780:	8b 45 08             	mov    0x8(%ebp),%eax
  801783:	8b 55 0c             	mov    0xc(%ebp),%edx
  801786:	89 c3                	mov    %eax,%ebx
  801788:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80178b:	eb 06                	jmp    801793 <strncmp+0x17>
		n--, p++, q++;
  80178d:	83 c0 01             	add    $0x1,%eax
  801790:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801793:	39 d8                	cmp    %ebx,%eax
  801795:	74 15                	je     8017ac <strncmp+0x30>
  801797:	0f b6 08             	movzbl (%eax),%ecx
  80179a:	84 c9                	test   %cl,%cl
  80179c:	74 04                	je     8017a2 <strncmp+0x26>
  80179e:	3a 0a                	cmp    (%edx),%cl
  8017a0:	74 eb                	je     80178d <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017a2:	0f b6 00             	movzbl (%eax),%eax
  8017a5:	0f b6 12             	movzbl (%edx),%edx
  8017a8:	29 d0                	sub    %edx,%eax
  8017aa:	eb 05                	jmp    8017b1 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017ac:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8017b1:	5b                   	pop    %ebx
  8017b2:	5d                   	pop    %ebp
  8017b3:	c3                   	ret    

008017b4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017b4:	55                   	push   %ebp
  8017b5:	89 e5                	mov    %esp,%ebp
  8017b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ba:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017be:	eb 07                	jmp    8017c7 <strchr+0x13>
		if (*s == c)
  8017c0:	38 ca                	cmp    %cl,%dl
  8017c2:	74 0f                	je     8017d3 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017c4:	83 c0 01             	add    $0x1,%eax
  8017c7:	0f b6 10             	movzbl (%eax),%edx
  8017ca:	84 d2                	test   %dl,%dl
  8017cc:	75 f2                	jne    8017c0 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8017ce:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017d3:	5d                   	pop    %ebp
  8017d4:	c3                   	ret    

008017d5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017d5:	55                   	push   %ebp
  8017d6:	89 e5                	mov    %esp,%ebp
  8017d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017db:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017df:	eb 03                	jmp    8017e4 <strfind+0xf>
  8017e1:	83 c0 01             	add    $0x1,%eax
  8017e4:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8017e7:	38 ca                	cmp    %cl,%dl
  8017e9:	74 04                	je     8017ef <strfind+0x1a>
  8017eb:	84 d2                	test   %dl,%dl
  8017ed:	75 f2                	jne    8017e1 <strfind+0xc>
			break;
	return (char *) s;
}
  8017ef:	5d                   	pop    %ebp
  8017f0:	c3                   	ret    

008017f1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8017f1:	55                   	push   %ebp
  8017f2:	89 e5                	mov    %esp,%ebp
  8017f4:	57                   	push   %edi
  8017f5:	56                   	push   %esi
  8017f6:	53                   	push   %ebx
  8017f7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017fa:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8017fd:	85 c9                	test   %ecx,%ecx
  8017ff:	74 36                	je     801837 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801801:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801807:	75 28                	jne    801831 <memset+0x40>
  801809:	f6 c1 03             	test   $0x3,%cl
  80180c:	75 23                	jne    801831 <memset+0x40>
		c &= 0xFF;
  80180e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801812:	89 d3                	mov    %edx,%ebx
  801814:	c1 e3 08             	shl    $0x8,%ebx
  801817:	89 d6                	mov    %edx,%esi
  801819:	c1 e6 18             	shl    $0x18,%esi
  80181c:	89 d0                	mov    %edx,%eax
  80181e:	c1 e0 10             	shl    $0x10,%eax
  801821:	09 f0                	or     %esi,%eax
  801823:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801825:	89 d8                	mov    %ebx,%eax
  801827:	09 d0                	or     %edx,%eax
  801829:	c1 e9 02             	shr    $0x2,%ecx
  80182c:	fc                   	cld    
  80182d:	f3 ab                	rep stos %eax,%es:(%edi)
  80182f:	eb 06                	jmp    801837 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801831:	8b 45 0c             	mov    0xc(%ebp),%eax
  801834:	fc                   	cld    
  801835:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801837:	89 f8                	mov    %edi,%eax
  801839:	5b                   	pop    %ebx
  80183a:	5e                   	pop    %esi
  80183b:	5f                   	pop    %edi
  80183c:	5d                   	pop    %ebp
  80183d:	c3                   	ret    

0080183e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80183e:	55                   	push   %ebp
  80183f:	89 e5                	mov    %esp,%ebp
  801841:	57                   	push   %edi
  801842:	56                   	push   %esi
  801843:	8b 45 08             	mov    0x8(%ebp),%eax
  801846:	8b 75 0c             	mov    0xc(%ebp),%esi
  801849:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80184c:	39 c6                	cmp    %eax,%esi
  80184e:	73 35                	jae    801885 <memmove+0x47>
  801850:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801853:	39 d0                	cmp    %edx,%eax
  801855:	73 2e                	jae    801885 <memmove+0x47>
		s += n;
		d += n;
  801857:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80185a:	89 d6                	mov    %edx,%esi
  80185c:	09 fe                	or     %edi,%esi
  80185e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801864:	75 13                	jne    801879 <memmove+0x3b>
  801866:	f6 c1 03             	test   $0x3,%cl
  801869:	75 0e                	jne    801879 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80186b:	83 ef 04             	sub    $0x4,%edi
  80186e:	8d 72 fc             	lea    -0x4(%edx),%esi
  801871:	c1 e9 02             	shr    $0x2,%ecx
  801874:	fd                   	std    
  801875:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801877:	eb 09                	jmp    801882 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801879:	83 ef 01             	sub    $0x1,%edi
  80187c:	8d 72 ff             	lea    -0x1(%edx),%esi
  80187f:	fd                   	std    
  801880:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801882:	fc                   	cld    
  801883:	eb 1d                	jmp    8018a2 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801885:	89 f2                	mov    %esi,%edx
  801887:	09 c2                	or     %eax,%edx
  801889:	f6 c2 03             	test   $0x3,%dl
  80188c:	75 0f                	jne    80189d <memmove+0x5f>
  80188e:	f6 c1 03             	test   $0x3,%cl
  801891:	75 0a                	jne    80189d <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801893:	c1 e9 02             	shr    $0x2,%ecx
  801896:	89 c7                	mov    %eax,%edi
  801898:	fc                   	cld    
  801899:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80189b:	eb 05                	jmp    8018a2 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80189d:	89 c7                	mov    %eax,%edi
  80189f:	fc                   	cld    
  8018a0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018a2:	5e                   	pop    %esi
  8018a3:	5f                   	pop    %edi
  8018a4:	5d                   	pop    %ebp
  8018a5:	c3                   	ret    

008018a6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018a6:	55                   	push   %ebp
  8018a7:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018a9:	ff 75 10             	pushl  0x10(%ebp)
  8018ac:	ff 75 0c             	pushl  0xc(%ebp)
  8018af:	ff 75 08             	pushl  0x8(%ebp)
  8018b2:	e8 87 ff ff ff       	call   80183e <memmove>
}
  8018b7:	c9                   	leave  
  8018b8:	c3                   	ret    

008018b9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018b9:	55                   	push   %ebp
  8018ba:	89 e5                	mov    %esp,%ebp
  8018bc:	56                   	push   %esi
  8018bd:	53                   	push   %ebx
  8018be:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018c4:	89 c6                	mov    %eax,%esi
  8018c6:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018c9:	eb 1a                	jmp    8018e5 <memcmp+0x2c>
		if (*s1 != *s2)
  8018cb:	0f b6 08             	movzbl (%eax),%ecx
  8018ce:	0f b6 1a             	movzbl (%edx),%ebx
  8018d1:	38 d9                	cmp    %bl,%cl
  8018d3:	74 0a                	je     8018df <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8018d5:	0f b6 c1             	movzbl %cl,%eax
  8018d8:	0f b6 db             	movzbl %bl,%ebx
  8018db:	29 d8                	sub    %ebx,%eax
  8018dd:	eb 0f                	jmp    8018ee <memcmp+0x35>
		s1++, s2++;
  8018df:	83 c0 01             	add    $0x1,%eax
  8018e2:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018e5:	39 f0                	cmp    %esi,%eax
  8018e7:	75 e2                	jne    8018cb <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8018e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018ee:	5b                   	pop    %ebx
  8018ef:	5e                   	pop    %esi
  8018f0:	5d                   	pop    %ebp
  8018f1:	c3                   	ret    

008018f2 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8018f2:	55                   	push   %ebp
  8018f3:	89 e5                	mov    %esp,%ebp
  8018f5:	53                   	push   %ebx
  8018f6:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8018f9:	89 c1                	mov    %eax,%ecx
  8018fb:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8018fe:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801902:	eb 0a                	jmp    80190e <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801904:	0f b6 10             	movzbl (%eax),%edx
  801907:	39 da                	cmp    %ebx,%edx
  801909:	74 07                	je     801912 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80190b:	83 c0 01             	add    $0x1,%eax
  80190e:	39 c8                	cmp    %ecx,%eax
  801910:	72 f2                	jb     801904 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801912:	5b                   	pop    %ebx
  801913:	5d                   	pop    %ebp
  801914:	c3                   	ret    

00801915 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801915:	55                   	push   %ebp
  801916:	89 e5                	mov    %esp,%ebp
  801918:	57                   	push   %edi
  801919:	56                   	push   %esi
  80191a:	53                   	push   %ebx
  80191b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80191e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801921:	eb 03                	jmp    801926 <strtol+0x11>
		s++;
  801923:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801926:	0f b6 01             	movzbl (%ecx),%eax
  801929:	3c 20                	cmp    $0x20,%al
  80192b:	74 f6                	je     801923 <strtol+0xe>
  80192d:	3c 09                	cmp    $0x9,%al
  80192f:	74 f2                	je     801923 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801931:	3c 2b                	cmp    $0x2b,%al
  801933:	75 0a                	jne    80193f <strtol+0x2a>
		s++;
  801935:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801938:	bf 00 00 00 00       	mov    $0x0,%edi
  80193d:	eb 11                	jmp    801950 <strtol+0x3b>
  80193f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801944:	3c 2d                	cmp    $0x2d,%al
  801946:	75 08                	jne    801950 <strtol+0x3b>
		s++, neg = 1;
  801948:	83 c1 01             	add    $0x1,%ecx
  80194b:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801950:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801956:	75 15                	jne    80196d <strtol+0x58>
  801958:	80 39 30             	cmpb   $0x30,(%ecx)
  80195b:	75 10                	jne    80196d <strtol+0x58>
  80195d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801961:	75 7c                	jne    8019df <strtol+0xca>
		s += 2, base = 16;
  801963:	83 c1 02             	add    $0x2,%ecx
  801966:	bb 10 00 00 00       	mov    $0x10,%ebx
  80196b:	eb 16                	jmp    801983 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  80196d:	85 db                	test   %ebx,%ebx
  80196f:	75 12                	jne    801983 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801971:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801976:	80 39 30             	cmpb   $0x30,(%ecx)
  801979:	75 08                	jne    801983 <strtol+0x6e>
		s++, base = 8;
  80197b:	83 c1 01             	add    $0x1,%ecx
  80197e:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801983:	b8 00 00 00 00       	mov    $0x0,%eax
  801988:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80198b:	0f b6 11             	movzbl (%ecx),%edx
  80198e:	8d 72 d0             	lea    -0x30(%edx),%esi
  801991:	89 f3                	mov    %esi,%ebx
  801993:	80 fb 09             	cmp    $0x9,%bl
  801996:	77 08                	ja     8019a0 <strtol+0x8b>
			dig = *s - '0';
  801998:	0f be d2             	movsbl %dl,%edx
  80199b:	83 ea 30             	sub    $0x30,%edx
  80199e:	eb 22                	jmp    8019c2 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8019a0:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019a3:	89 f3                	mov    %esi,%ebx
  8019a5:	80 fb 19             	cmp    $0x19,%bl
  8019a8:	77 08                	ja     8019b2 <strtol+0x9d>
			dig = *s - 'a' + 10;
  8019aa:	0f be d2             	movsbl %dl,%edx
  8019ad:	83 ea 57             	sub    $0x57,%edx
  8019b0:	eb 10                	jmp    8019c2 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8019b2:	8d 72 bf             	lea    -0x41(%edx),%esi
  8019b5:	89 f3                	mov    %esi,%ebx
  8019b7:	80 fb 19             	cmp    $0x19,%bl
  8019ba:	77 16                	ja     8019d2 <strtol+0xbd>
			dig = *s - 'A' + 10;
  8019bc:	0f be d2             	movsbl %dl,%edx
  8019bf:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8019c2:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019c5:	7d 0b                	jge    8019d2 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8019c7:	83 c1 01             	add    $0x1,%ecx
  8019ca:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019ce:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8019d0:	eb b9                	jmp    80198b <strtol+0x76>

	if (endptr)
  8019d2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019d6:	74 0d                	je     8019e5 <strtol+0xd0>
		*endptr = (char *) s;
  8019d8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8019db:	89 0e                	mov    %ecx,(%esi)
  8019dd:	eb 06                	jmp    8019e5 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019df:	85 db                	test   %ebx,%ebx
  8019e1:	74 98                	je     80197b <strtol+0x66>
  8019e3:	eb 9e                	jmp    801983 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8019e5:	89 c2                	mov    %eax,%edx
  8019e7:	f7 da                	neg    %edx
  8019e9:	85 ff                	test   %edi,%edi
  8019eb:	0f 45 c2             	cmovne %edx,%eax
}
  8019ee:	5b                   	pop    %ebx
  8019ef:	5e                   	pop    %esi
  8019f0:	5f                   	pop    %edi
  8019f1:	5d                   	pop    %ebp
  8019f2:	c3                   	ret    

008019f3 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019f3:	55                   	push   %ebp
  8019f4:	89 e5                	mov    %esp,%ebp
  8019f6:	56                   	push   %esi
  8019f7:	53                   	push   %ebx
  8019f8:	8b 75 08             	mov    0x8(%ebp),%esi
  8019fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019fe:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_recv not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  801a01:	85 c0                	test   %eax,%eax
  801a03:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a08:	0f 44 c2             	cmove  %edx,%eax

    int r = sys_ipc_recv(pg);
  801a0b:	83 ec 0c             	sub    $0xc,%esp
  801a0e:	50                   	push   %eax
  801a0f:	e8 f1 e8 ff ff       	call   800305 <sys_ipc_recv>
    int from_env = 0, perm = 0;
    if (r == 0) {
  801a14:	83 c4 10             	add    $0x10,%esp
  801a17:	85 c0                	test   %eax,%eax
  801a19:	75 10                	jne    801a2b <ipc_recv+0x38>
        from_env = thisenv->env_ipc_from;
  801a1b:	a1 04 40 80 00       	mov    0x804004,%eax
  801a20:	8b 48 74             	mov    0x74(%eax),%ecx
        perm = thisenv->env_ipc_perm;
  801a23:	8b 50 78             	mov    0x78(%eax),%edx
        r = thisenv->env_ipc_value;
  801a26:	8b 40 70             	mov    0x70(%eax),%eax
  801a29:	eb 0a                	jmp    801a35 <ipc_recv+0x42>
    } else {
        from_env = 0;
        perm = 0;
  801a2b:	ba 00 00 00 00       	mov    $0x0,%edx
    if (r == 0) {
        from_env = thisenv->env_ipc_from;
        perm = thisenv->env_ipc_perm;
        r = thisenv->env_ipc_value;
    } else {
        from_env = 0;
  801a30:	b9 00 00 00 00       	mov    $0x0,%ecx
        perm = 0;
    }

    if (from_env_store) *from_env_store = from_env;
  801a35:	85 f6                	test   %esi,%esi
  801a37:	74 02                	je     801a3b <ipc_recv+0x48>
  801a39:	89 0e                	mov    %ecx,(%esi)
    if (perm_store) *perm_store = perm;
  801a3b:	85 db                	test   %ebx,%ebx
  801a3d:	74 02                	je     801a41 <ipc_recv+0x4e>
  801a3f:	89 13                	mov    %edx,(%ebx)

    return r;
}
  801a41:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a44:	5b                   	pop    %ebx
  801a45:	5e                   	pop    %esi
  801a46:	5d                   	pop    %ebp
  801a47:	c3                   	ret    

00801a48 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a48:	55                   	push   %ebp
  801a49:	89 e5                	mov    %esp,%ebp
  801a4b:	57                   	push   %edi
  801a4c:	56                   	push   %esi
  801a4d:	53                   	push   %ebx
  801a4e:	83 ec 0c             	sub    $0xc,%esp
  801a51:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a54:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a57:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  801a5a:	85 db                	test   %ebx,%ebx
  801a5c:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801a61:	0f 44 d8             	cmove  %eax,%ebx
  801a64:	eb 1c                	jmp    801a82 <ipc_send+0x3a>

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        if (ret != -E_IPC_NOT_RECV)
  801a66:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a69:	74 12                	je     801a7d <ipc_send+0x35>
            panic("ipc_send error %e", ret);
  801a6b:	50                   	push   %eax
  801a6c:	68 e0 21 80 00       	push   $0x8021e0
  801a71:	6a 40                	push   $0x40
  801a73:	68 f2 21 80 00       	push   $0x8021f2
  801a78:	e8 b3 f5 ff ff       	call   801030 <_panic>
        sys_yield();
  801a7d:	e8 b4 e6 ff ff       	call   800136 <sys_yield>
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801a82:	ff 75 14             	pushl  0x14(%ebp)
  801a85:	53                   	push   %ebx
  801a86:	56                   	push   %esi
  801a87:	57                   	push   %edi
  801a88:	e8 55 e8 ff ff       	call   8002e2 <sys_ipc_try_send>
  801a8d:	83 c4 10             	add    $0x10,%esp
  801a90:	85 c0                	test   %eax,%eax
  801a92:	75 d2                	jne    801a66 <ipc_send+0x1e>
        if (ret != -E_IPC_NOT_RECV)
            panic("ipc_send error %e", ret);
        sys_yield();
    }
}
  801a94:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a97:	5b                   	pop    %ebx
  801a98:	5e                   	pop    %esi
  801a99:	5f                   	pop    %edi
  801a9a:	5d                   	pop    %ebp
  801a9b:	c3                   	ret    

00801a9c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801a9c:	55                   	push   %ebp
  801a9d:	89 e5                	mov    %esp,%ebp
  801a9f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801aa2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801aa7:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801aaa:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ab0:	8b 52 50             	mov    0x50(%edx),%edx
  801ab3:	39 ca                	cmp    %ecx,%edx
  801ab5:	75 0d                	jne    801ac4 <ipc_find_env+0x28>
			return envs[i].env_id;
  801ab7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801aba:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801abf:	8b 40 48             	mov    0x48(%eax),%eax
  801ac2:	eb 0f                	jmp    801ad3 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ac4:	83 c0 01             	add    $0x1,%eax
  801ac7:	3d 00 04 00 00       	cmp    $0x400,%eax
  801acc:	75 d9                	jne    801aa7 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ace:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ad3:	5d                   	pop    %ebp
  801ad4:	c3                   	ret    

00801ad5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ad5:	55                   	push   %ebp
  801ad6:	89 e5                	mov    %esp,%ebp
  801ad8:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801adb:	89 d0                	mov    %edx,%eax
  801add:	c1 e8 16             	shr    $0x16,%eax
  801ae0:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801ae7:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801aec:	f6 c1 01             	test   $0x1,%cl
  801aef:	74 1d                	je     801b0e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801af1:	c1 ea 0c             	shr    $0xc,%edx
  801af4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801afb:	f6 c2 01             	test   $0x1,%dl
  801afe:	74 0e                	je     801b0e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b00:	c1 ea 0c             	shr    $0xc,%edx
  801b03:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b0a:	ef 
  801b0b:	0f b7 c0             	movzwl %ax,%eax
}
  801b0e:	5d                   	pop    %ebp
  801b0f:	c3                   	ret    

00801b10 <__udivdi3>:
  801b10:	55                   	push   %ebp
  801b11:	57                   	push   %edi
  801b12:	56                   	push   %esi
  801b13:	53                   	push   %ebx
  801b14:	83 ec 1c             	sub    $0x1c,%esp
  801b17:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801b1b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801b1f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801b23:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801b27:	85 f6                	test   %esi,%esi
  801b29:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b2d:	89 ca                	mov    %ecx,%edx
  801b2f:	89 f8                	mov    %edi,%eax
  801b31:	75 3d                	jne    801b70 <__udivdi3+0x60>
  801b33:	39 cf                	cmp    %ecx,%edi
  801b35:	0f 87 c5 00 00 00    	ja     801c00 <__udivdi3+0xf0>
  801b3b:	85 ff                	test   %edi,%edi
  801b3d:	89 fd                	mov    %edi,%ebp
  801b3f:	75 0b                	jne    801b4c <__udivdi3+0x3c>
  801b41:	b8 01 00 00 00       	mov    $0x1,%eax
  801b46:	31 d2                	xor    %edx,%edx
  801b48:	f7 f7                	div    %edi
  801b4a:	89 c5                	mov    %eax,%ebp
  801b4c:	89 c8                	mov    %ecx,%eax
  801b4e:	31 d2                	xor    %edx,%edx
  801b50:	f7 f5                	div    %ebp
  801b52:	89 c1                	mov    %eax,%ecx
  801b54:	89 d8                	mov    %ebx,%eax
  801b56:	89 cf                	mov    %ecx,%edi
  801b58:	f7 f5                	div    %ebp
  801b5a:	89 c3                	mov    %eax,%ebx
  801b5c:	89 d8                	mov    %ebx,%eax
  801b5e:	89 fa                	mov    %edi,%edx
  801b60:	83 c4 1c             	add    $0x1c,%esp
  801b63:	5b                   	pop    %ebx
  801b64:	5e                   	pop    %esi
  801b65:	5f                   	pop    %edi
  801b66:	5d                   	pop    %ebp
  801b67:	c3                   	ret    
  801b68:	90                   	nop
  801b69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801b70:	39 ce                	cmp    %ecx,%esi
  801b72:	77 74                	ja     801be8 <__udivdi3+0xd8>
  801b74:	0f bd fe             	bsr    %esi,%edi
  801b77:	83 f7 1f             	xor    $0x1f,%edi
  801b7a:	0f 84 98 00 00 00    	je     801c18 <__udivdi3+0x108>
  801b80:	bb 20 00 00 00       	mov    $0x20,%ebx
  801b85:	89 f9                	mov    %edi,%ecx
  801b87:	89 c5                	mov    %eax,%ebp
  801b89:	29 fb                	sub    %edi,%ebx
  801b8b:	d3 e6                	shl    %cl,%esi
  801b8d:	89 d9                	mov    %ebx,%ecx
  801b8f:	d3 ed                	shr    %cl,%ebp
  801b91:	89 f9                	mov    %edi,%ecx
  801b93:	d3 e0                	shl    %cl,%eax
  801b95:	09 ee                	or     %ebp,%esi
  801b97:	89 d9                	mov    %ebx,%ecx
  801b99:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b9d:	89 d5                	mov    %edx,%ebp
  801b9f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ba3:	d3 ed                	shr    %cl,%ebp
  801ba5:	89 f9                	mov    %edi,%ecx
  801ba7:	d3 e2                	shl    %cl,%edx
  801ba9:	89 d9                	mov    %ebx,%ecx
  801bab:	d3 e8                	shr    %cl,%eax
  801bad:	09 c2                	or     %eax,%edx
  801baf:	89 d0                	mov    %edx,%eax
  801bb1:	89 ea                	mov    %ebp,%edx
  801bb3:	f7 f6                	div    %esi
  801bb5:	89 d5                	mov    %edx,%ebp
  801bb7:	89 c3                	mov    %eax,%ebx
  801bb9:	f7 64 24 0c          	mull   0xc(%esp)
  801bbd:	39 d5                	cmp    %edx,%ebp
  801bbf:	72 10                	jb     801bd1 <__udivdi3+0xc1>
  801bc1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801bc5:	89 f9                	mov    %edi,%ecx
  801bc7:	d3 e6                	shl    %cl,%esi
  801bc9:	39 c6                	cmp    %eax,%esi
  801bcb:	73 07                	jae    801bd4 <__udivdi3+0xc4>
  801bcd:	39 d5                	cmp    %edx,%ebp
  801bcf:	75 03                	jne    801bd4 <__udivdi3+0xc4>
  801bd1:	83 eb 01             	sub    $0x1,%ebx
  801bd4:	31 ff                	xor    %edi,%edi
  801bd6:	89 d8                	mov    %ebx,%eax
  801bd8:	89 fa                	mov    %edi,%edx
  801bda:	83 c4 1c             	add    $0x1c,%esp
  801bdd:	5b                   	pop    %ebx
  801bde:	5e                   	pop    %esi
  801bdf:	5f                   	pop    %edi
  801be0:	5d                   	pop    %ebp
  801be1:	c3                   	ret    
  801be2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801be8:	31 ff                	xor    %edi,%edi
  801bea:	31 db                	xor    %ebx,%ebx
  801bec:	89 d8                	mov    %ebx,%eax
  801bee:	89 fa                	mov    %edi,%edx
  801bf0:	83 c4 1c             	add    $0x1c,%esp
  801bf3:	5b                   	pop    %ebx
  801bf4:	5e                   	pop    %esi
  801bf5:	5f                   	pop    %edi
  801bf6:	5d                   	pop    %ebp
  801bf7:	c3                   	ret    
  801bf8:	90                   	nop
  801bf9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c00:	89 d8                	mov    %ebx,%eax
  801c02:	f7 f7                	div    %edi
  801c04:	31 ff                	xor    %edi,%edi
  801c06:	89 c3                	mov    %eax,%ebx
  801c08:	89 d8                	mov    %ebx,%eax
  801c0a:	89 fa                	mov    %edi,%edx
  801c0c:	83 c4 1c             	add    $0x1c,%esp
  801c0f:	5b                   	pop    %ebx
  801c10:	5e                   	pop    %esi
  801c11:	5f                   	pop    %edi
  801c12:	5d                   	pop    %ebp
  801c13:	c3                   	ret    
  801c14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c18:	39 ce                	cmp    %ecx,%esi
  801c1a:	72 0c                	jb     801c28 <__udivdi3+0x118>
  801c1c:	31 db                	xor    %ebx,%ebx
  801c1e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801c22:	0f 87 34 ff ff ff    	ja     801b5c <__udivdi3+0x4c>
  801c28:	bb 01 00 00 00       	mov    $0x1,%ebx
  801c2d:	e9 2a ff ff ff       	jmp    801b5c <__udivdi3+0x4c>
  801c32:	66 90                	xchg   %ax,%ax
  801c34:	66 90                	xchg   %ax,%ax
  801c36:	66 90                	xchg   %ax,%ax
  801c38:	66 90                	xchg   %ax,%ax
  801c3a:	66 90                	xchg   %ax,%ax
  801c3c:	66 90                	xchg   %ax,%ax
  801c3e:	66 90                	xchg   %ax,%ax

00801c40 <__umoddi3>:
  801c40:	55                   	push   %ebp
  801c41:	57                   	push   %edi
  801c42:	56                   	push   %esi
  801c43:	53                   	push   %ebx
  801c44:	83 ec 1c             	sub    $0x1c,%esp
  801c47:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801c4b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801c4f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801c53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c57:	85 d2                	test   %edx,%edx
  801c59:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801c5d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c61:	89 f3                	mov    %esi,%ebx
  801c63:	89 3c 24             	mov    %edi,(%esp)
  801c66:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c6a:	75 1c                	jne    801c88 <__umoddi3+0x48>
  801c6c:	39 f7                	cmp    %esi,%edi
  801c6e:	76 50                	jbe    801cc0 <__umoddi3+0x80>
  801c70:	89 c8                	mov    %ecx,%eax
  801c72:	89 f2                	mov    %esi,%edx
  801c74:	f7 f7                	div    %edi
  801c76:	89 d0                	mov    %edx,%eax
  801c78:	31 d2                	xor    %edx,%edx
  801c7a:	83 c4 1c             	add    $0x1c,%esp
  801c7d:	5b                   	pop    %ebx
  801c7e:	5e                   	pop    %esi
  801c7f:	5f                   	pop    %edi
  801c80:	5d                   	pop    %ebp
  801c81:	c3                   	ret    
  801c82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c88:	39 f2                	cmp    %esi,%edx
  801c8a:	89 d0                	mov    %edx,%eax
  801c8c:	77 52                	ja     801ce0 <__umoddi3+0xa0>
  801c8e:	0f bd ea             	bsr    %edx,%ebp
  801c91:	83 f5 1f             	xor    $0x1f,%ebp
  801c94:	75 5a                	jne    801cf0 <__umoddi3+0xb0>
  801c96:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801c9a:	0f 82 e0 00 00 00    	jb     801d80 <__umoddi3+0x140>
  801ca0:	39 0c 24             	cmp    %ecx,(%esp)
  801ca3:	0f 86 d7 00 00 00    	jbe    801d80 <__umoddi3+0x140>
  801ca9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801cad:	8b 54 24 04          	mov    0x4(%esp),%edx
  801cb1:	83 c4 1c             	add    $0x1c,%esp
  801cb4:	5b                   	pop    %ebx
  801cb5:	5e                   	pop    %esi
  801cb6:	5f                   	pop    %edi
  801cb7:	5d                   	pop    %ebp
  801cb8:	c3                   	ret    
  801cb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cc0:	85 ff                	test   %edi,%edi
  801cc2:	89 fd                	mov    %edi,%ebp
  801cc4:	75 0b                	jne    801cd1 <__umoddi3+0x91>
  801cc6:	b8 01 00 00 00       	mov    $0x1,%eax
  801ccb:	31 d2                	xor    %edx,%edx
  801ccd:	f7 f7                	div    %edi
  801ccf:	89 c5                	mov    %eax,%ebp
  801cd1:	89 f0                	mov    %esi,%eax
  801cd3:	31 d2                	xor    %edx,%edx
  801cd5:	f7 f5                	div    %ebp
  801cd7:	89 c8                	mov    %ecx,%eax
  801cd9:	f7 f5                	div    %ebp
  801cdb:	89 d0                	mov    %edx,%eax
  801cdd:	eb 99                	jmp    801c78 <__umoddi3+0x38>
  801cdf:	90                   	nop
  801ce0:	89 c8                	mov    %ecx,%eax
  801ce2:	89 f2                	mov    %esi,%edx
  801ce4:	83 c4 1c             	add    $0x1c,%esp
  801ce7:	5b                   	pop    %ebx
  801ce8:	5e                   	pop    %esi
  801ce9:	5f                   	pop    %edi
  801cea:	5d                   	pop    %ebp
  801ceb:	c3                   	ret    
  801cec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cf0:	8b 34 24             	mov    (%esp),%esi
  801cf3:	bf 20 00 00 00       	mov    $0x20,%edi
  801cf8:	89 e9                	mov    %ebp,%ecx
  801cfa:	29 ef                	sub    %ebp,%edi
  801cfc:	d3 e0                	shl    %cl,%eax
  801cfe:	89 f9                	mov    %edi,%ecx
  801d00:	89 f2                	mov    %esi,%edx
  801d02:	d3 ea                	shr    %cl,%edx
  801d04:	89 e9                	mov    %ebp,%ecx
  801d06:	09 c2                	or     %eax,%edx
  801d08:	89 d8                	mov    %ebx,%eax
  801d0a:	89 14 24             	mov    %edx,(%esp)
  801d0d:	89 f2                	mov    %esi,%edx
  801d0f:	d3 e2                	shl    %cl,%edx
  801d11:	89 f9                	mov    %edi,%ecx
  801d13:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d17:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801d1b:	d3 e8                	shr    %cl,%eax
  801d1d:	89 e9                	mov    %ebp,%ecx
  801d1f:	89 c6                	mov    %eax,%esi
  801d21:	d3 e3                	shl    %cl,%ebx
  801d23:	89 f9                	mov    %edi,%ecx
  801d25:	89 d0                	mov    %edx,%eax
  801d27:	d3 e8                	shr    %cl,%eax
  801d29:	89 e9                	mov    %ebp,%ecx
  801d2b:	09 d8                	or     %ebx,%eax
  801d2d:	89 d3                	mov    %edx,%ebx
  801d2f:	89 f2                	mov    %esi,%edx
  801d31:	f7 34 24             	divl   (%esp)
  801d34:	89 d6                	mov    %edx,%esi
  801d36:	d3 e3                	shl    %cl,%ebx
  801d38:	f7 64 24 04          	mull   0x4(%esp)
  801d3c:	39 d6                	cmp    %edx,%esi
  801d3e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d42:	89 d1                	mov    %edx,%ecx
  801d44:	89 c3                	mov    %eax,%ebx
  801d46:	72 08                	jb     801d50 <__umoddi3+0x110>
  801d48:	75 11                	jne    801d5b <__umoddi3+0x11b>
  801d4a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801d4e:	73 0b                	jae    801d5b <__umoddi3+0x11b>
  801d50:	2b 44 24 04          	sub    0x4(%esp),%eax
  801d54:	1b 14 24             	sbb    (%esp),%edx
  801d57:	89 d1                	mov    %edx,%ecx
  801d59:	89 c3                	mov    %eax,%ebx
  801d5b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801d5f:	29 da                	sub    %ebx,%edx
  801d61:	19 ce                	sbb    %ecx,%esi
  801d63:	89 f9                	mov    %edi,%ecx
  801d65:	89 f0                	mov    %esi,%eax
  801d67:	d3 e0                	shl    %cl,%eax
  801d69:	89 e9                	mov    %ebp,%ecx
  801d6b:	d3 ea                	shr    %cl,%edx
  801d6d:	89 e9                	mov    %ebp,%ecx
  801d6f:	d3 ee                	shr    %cl,%esi
  801d71:	09 d0                	or     %edx,%eax
  801d73:	89 f2                	mov    %esi,%edx
  801d75:	83 c4 1c             	add    $0x1c,%esp
  801d78:	5b                   	pop    %ebx
  801d79:	5e                   	pop    %esi
  801d7a:	5f                   	pop    %edi
  801d7b:	5d                   	pop    %ebp
  801d7c:	c3                   	ret    
  801d7d:	8d 76 00             	lea    0x0(%esi),%esi
  801d80:	29 f9                	sub    %edi,%ecx
  801d82:	19 d6                	sbb    %edx,%esi
  801d84:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d88:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d8c:	e9 18 ff ff ff       	jmp    801ca9 <__umoddi3+0x69>
