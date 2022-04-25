
obj/user/badsegment.debug:     file format elf32-i386


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
  80002c:	e8 0d 00 00 00       	call   80003e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800036:	66 b8 28 00          	mov    $0x28,%ax
  80003a:	8e d8                	mov    %eax,%ds
}
  80003c:	5d                   	pop    %ebp
  80003d:	c3                   	ret    

0080003e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003e:	55                   	push   %ebp
  80003f:	89 e5                	mov    %esp,%ebp
  800041:	56                   	push   %esi
  800042:	53                   	push   %ebx
  800043:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800046:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  800049:	e8 ce 00 00 00       	call   80011c <sys_getenvid>
  80004e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800053:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800056:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005b:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800060:	85 db                	test   %ebx,%ebx
  800062:	7e 07                	jle    80006b <libmain+0x2d>
		binaryname = argv[0];
  800064:	8b 06                	mov    (%esi),%eax
  800066:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80006b:	83 ec 08             	sub    $0x8,%esp
  80006e:	56                   	push   %esi
  80006f:	53                   	push   %ebx
  800070:	e8 be ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800075:	e8 0a 00 00 00       	call   800084 <exit>
}
  80007a:	83 c4 10             	add    $0x10,%esp
  80007d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800080:	5b                   	pop    %ebx
  800081:	5e                   	pop    %esi
  800082:	5d                   	pop    %ebp
  800083:	c3                   	ret    

00800084 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800084:	55                   	push   %ebp
  800085:	89 e5                	mov    %esp,%ebp
  800087:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80008a:	e8 87 04 00 00       	call   800516 <close_all>
	sys_env_destroy(0);
  80008f:	83 ec 0c             	sub    $0xc,%esp
  800092:	6a 00                	push   $0x0
  800094:	e8 42 00 00 00       	call   8000db <sys_env_destroy>
}
  800099:	83 c4 10             	add    $0x10,%esp
  80009c:	c9                   	leave  
  80009d:	c3                   	ret    

0080009e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009e:	55                   	push   %ebp
  80009f:	89 e5                	mov    %esp,%ebp
  8000a1:	57                   	push   %edi
  8000a2:	56                   	push   %esi
  8000a3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8000af:	89 c3                	mov    %eax,%ebx
  8000b1:	89 c7                	mov    %eax,%edi
  8000b3:	89 c6                	mov    %eax,%esi
  8000b5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b7:	5b                   	pop    %ebx
  8000b8:	5e                   	pop    %esi
  8000b9:	5f                   	pop    %edi
  8000ba:	5d                   	pop    %ebp
  8000bb:	c3                   	ret    

008000bc <sys_cgetc>:

int
sys_cgetc(void)
{
  8000bc:	55                   	push   %ebp
  8000bd:	89 e5                	mov    %esp,%ebp
  8000bf:	57                   	push   %edi
  8000c0:	56                   	push   %esi
  8000c1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c7:	b8 01 00 00 00       	mov    $0x1,%eax
  8000cc:	89 d1                	mov    %edx,%ecx
  8000ce:	89 d3                	mov    %edx,%ebx
  8000d0:	89 d7                	mov    %edx,%edi
  8000d2:	89 d6                	mov    %edx,%esi
  8000d4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d6:	5b                   	pop    %ebx
  8000d7:	5e                   	pop    %esi
  8000d8:	5f                   	pop    %edi
  8000d9:	5d                   	pop    %ebp
  8000da:	c3                   	ret    

008000db <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	57                   	push   %edi
  8000df:	56                   	push   %esi
  8000e0:	53                   	push   %ebx
  8000e1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e9:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f1:	89 cb                	mov    %ecx,%ebx
  8000f3:	89 cf                	mov    %ecx,%edi
  8000f5:	89 ce                	mov    %ecx,%esi
  8000f7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000f9:	85 c0                	test   %eax,%eax
  8000fb:	7e 17                	jle    800114 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000fd:	83 ec 0c             	sub    $0xc,%esp
  800100:	50                   	push   %eax
  800101:	6a 03                	push   $0x3
  800103:	68 ca 1d 80 00       	push   $0x801dca
  800108:	6a 23                	push   $0x23
  80010a:	68 e7 1d 80 00       	push   $0x801de7
  80010f:	e8 21 0f 00 00       	call   801035 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800114:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800117:	5b                   	pop    %ebx
  800118:	5e                   	pop    %esi
  800119:	5f                   	pop    %edi
  80011a:	5d                   	pop    %ebp
  80011b:	c3                   	ret    

0080011c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80011c:	55                   	push   %ebp
  80011d:	89 e5                	mov    %esp,%ebp
  80011f:	57                   	push   %edi
  800120:	56                   	push   %esi
  800121:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800122:	ba 00 00 00 00       	mov    $0x0,%edx
  800127:	b8 02 00 00 00       	mov    $0x2,%eax
  80012c:	89 d1                	mov    %edx,%ecx
  80012e:	89 d3                	mov    %edx,%ebx
  800130:	89 d7                	mov    %edx,%edi
  800132:	89 d6                	mov    %edx,%esi
  800134:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800136:	5b                   	pop    %ebx
  800137:	5e                   	pop    %esi
  800138:	5f                   	pop    %edi
  800139:	5d                   	pop    %ebp
  80013a:	c3                   	ret    

0080013b <sys_yield>:

void
sys_yield(void)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	57                   	push   %edi
  80013f:	56                   	push   %esi
  800140:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800141:	ba 00 00 00 00       	mov    $0x0,%edx
  800146:	b8 0b 00 00 00       	mov    $0xb,%eax
  80014b:	89 d1                	mov    %edx,%ecx
  80014d:	89 d3                	mov    %edx,%ebx
  80014f:	89 d7                	mov    %edx,%edi
  800151:	89 d6                	mov    %edx,%esi
  800153:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800155:	5b                   	pop    %ebx
  800156:	5e                   	pop    %esi
  800157:	5f                   	pop    %edi
  800158:	5d                   	pop    %ebp
  800159:	c3                   	ret    

0080015a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80015a:	55                   	push   %ebp
  80015b:	89 e5                	mov    %esp,%ebp
  80015d:	57                   	push   %edi
  80015e:	56                   	push   %esi
  80015f:	53                   	push   %ebx
  800160:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800163:	be 00 00 00 00       	mov    $0x0,%esi
  800168:	b8 04 00 00 00       	mov    $0x4,%eax
  80016d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800170:	8b 55 08             	mov    0x8(%ebp),%edx
  800173:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800176:	89 f7                	mov    %esi,%edi
  800178:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80017a:	85 c0                	test   %eax,%eax
  80017c:	7e 17                	jle    800195 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80017e:	83 ec 0c             	sub    $0xc,%esp
  800181:	50                   	push   %eax
  800182:	6a 04                	push   $0x4
  800184:	68 ca 1d 80 00       	push   $0x801dca
  800189:	6a 23                	push   $0x23
  80018b:	68 e7 1d 80 00       	push   $0x801de7
  800190:	e8 a0 0e 00 00       	call   801035 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800195:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800198:	5b                   	pop    %ebx
  800199:	5e                   	pop    %esi
  80019a:	5f                   	pop    %edi
  80019b:	5d                   	pop    %ebp
  80019c:	c3                   	ret    

0080019d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80019d:	55                   	push   %ebp
  80019e:	89 e5                	mov    %esp,%ebp
  8001a0:	57                   	push   %edi
  8001a1:	56                   	push   %esi
  8001a2:	53                   	push   %ebx
  8001a3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b7:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ba:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001bc:	85 c0                	test   %eax,%eax
  8001be:	7e 17                	jle    8001d7 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c0:	83 ec 0c             	sub    $0xc,%esp
  8001c3:	50                   	push   %eax
  8001c4:	6a 05                	push   $0x5
  8001c6:	68 ca 1d 80 00       	push   $0x801dca
  8001cb:	6a 23                	push   $0x23
  8001cd:	68 e7 1d 80 00       	push   $0x801de7
  8001d2:	e8 5e 0e 00 00       	call   801035 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001da:	5b                   	pop    %ebx
  8001db:	5e                   	pop    %esi
  8001dc:	5f                   	pop    %edi
  8001dd:	5d                   	pop    %ebp
  8001de:	c3                   	ret    

008001df <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001df:	55                   	push   %ebp
  8001e0:	89 e5                	mov    %esp,%ebp
  8001e2:	57                   	push   %edi
  8001e3:	56                   	push   %esi
  8001e4:	53                   	push   %ebx
  8001e5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ed:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f8:	89 df                	mov    %ebx,%edi
  8001fa:	89 de                	mov    %ebx,%esi
  8001fc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001fe:	85 c0                	test   %eax,%eax
  800200:	7e 17                	jle    800219 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800202:	83 ec 0c             	sub    $0xc,%esp
  800205:	50                   	push   %eax
  800206:	6a 06                	push   $0x6
  800208:	68 ca 1d 80 00       	push   $0x801dca
  80020d:	6a 23                	push   $0x23
  80020f:	68 e7 1d 80 00       	push   $0x801de7
  800214:	e8 1c 0e 00 00       	call   801035 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800219:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80021c:	5b                   	pop    %ebx
  80021d:	5e                   	pop    %esi
  80021e:	5f                   	pop    %edi
  80021f:	5d                   	pop    %ebp
  800220:	c3                   	ret    

00800221 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	57                   	push   %edi
  800225:	56                   	push   %esi
  800226:	53                   	push   %ebx
  800227:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80022a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022f:	b8 08 00 00 00       	mov    $0x8,%eax
  800234:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800237:	8b 55 08             	mov    0x8(%ebp),%edx
  80023a:	89 df                	mov    %ebx,%edi
  80023c:	89 de                	mov    %ebx,%esi
  80023e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800240:	85 c0                	test   %eax,%eax
  800242:	7e 17                	jle    80025b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800244:	83 ec 0c             	sub    $0xc,%esp
  800247:	50                   	push   %eax
  800248:	6a 08                	push   $0x8
  80024a:	68 ca 1d 80 00       	push   $0x801dca
  80024f:	6a 23                	push   $0x23
  800251:	68 e7 1d 80 00       	push   $0x801de7
  800256:	e8 da 0d 00 00       	call   801035 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80025b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025e:	5b                   	pop    %ebx
  80025f:	5e                   	pop    %esi
  800260:	5f                   	pop    %edi
  800261:	5d                   	pop    %ebp
  800262:	c3                   	ret    

00800263 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800263:	55                   	push   %ebp
  800264:	89 e5                	mov    %esp,%ebp
  800266:	57                   	push   %edi
  800267:	56                   	push   %esi
  800268:	53                   	push   %ebx
  800269:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80026c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800271:	b8 09 00 00 00       	mov    $0x9,%eax
  800276:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800279:	8b 55 08             	mov    0x8(%ebp),%edx
  80027c:	89 df                	mov    %ebx,%edi
  80027e:	89 de                	mov    %ebx,%esi
  800280:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800282:	85 c0                	test   %eax,%eax
  800284:	7e 17                	jle    80029d <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800286:	83 ec 0c             	sub    $0xc,%esp
  800289:	50                   	push   %eax
  80028a:	6a 09                	push   $0x9
  80028c:	68 ca 1d 80 00       	push   $0x801dca
  800291:	6a 23                	push   $0x23
  800293:	68 e7 1d 80 00       	push   $0x801de7
  800298:	e8 98 0d 00 00       	call   801035 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80029d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a0:	5b                   	pop    %ebx
  8002a1:	5e                   	pop    %esi
  8002a2:	5f                   	pop    %edi
  8002a3:	5d                   	pop    %ebp
  8002a4:	c3                   	ret    

008002a5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a5:	55                   	push   %ebp
  8002a6:	89 e5                	mov    %esp,%ebp
  8002a8:	57                   	push   %edi
  8002a9:	56                   	push   %esi
  8002aa:	53                   	push   %ebx
  8002ab:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ae:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8002be:	89 df                	mov    %ebx,%edi
  8002c0:	89 de                	mov    %ebx,%esi
  8002c2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002c4:	85 c0                	test   %eax,%eax
  8002c6:	7e 17                	jle    8002df <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c8:	83 ec 0c             	sub    $0xc,%esp
  8002cb:	50                   	push   %eax
  8002cc:	6a 0a                	push   $0xa
  8002ce:	68 ca 1d 80 00       	push   $0x801dca
  8002d3:	6a 23                	push   $0x23
  8002d5:	68 e7 1d 80 00       	push   $0x801de7
  8002da:	e8 56 0d 00 00       	call   801035 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e2:	5b                   	pop    %ebx
  8002e3:	5e                   	pop    %esi
  8002e4:	5f                   	pop    %edi
  8002e5:	5d                   	pop    %ebp
  8002e6:	c3                   	ret    

008002e7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002e7:	55                   	push   %ebp
  8002e8:	89 e5                	mov    %esp,%ebp
  8002ea:	57                   	push   %edi
  8002eb:	56                   	push   %esi
  8002ec:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ed:	be 00 00 00 00       	mov    $0x0,%esi
  8002f2:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8002fd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800300:	8b 7d 14             	mov    0x14(%ebp),%edi
  800303:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800305:	5b                   	pop    %ebx
  800306:	5e                   	pop    %esi
  800307:	5f                   	pop    %edi
  800308:	5d                   	pop    %ebp
  800309:	c3                   	ret    

0080030a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80030a:	55                   	push   %ebp
  80030b:	89 e5                	mov    %esp,%ebp
  80030d:	57                   	push   %edi
  80030e:	56                   	push   %esi
  80030f:	53                   	push   %ebx
  800310:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800313:	b9 00 00 00 00       	mov    $0x0,%ecx
  800318:	b8 0d 00 00 00       	mov    $0xd,%eax
  80031d:	8b 55 08             	mov    0x8(%ebp),%edx
  800320:	89 cb                	mov    %ecx,%ebx
  800322:	89 cf                	mov    %ecx,%edi
  800324:	89 ce                	mov    %ecx,%esi
  800326:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800328:	85 c0                	test   %eax,%eax
  80032a:	7e 17                	jle    800343 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80032c:	83 ec 0c             	sub    $0xc,%esp
  80032f:	50                   	push   %eax
  800330:	6a 0d                	push   $0xd
  800332:	68 ca 1d 80 00       	push   $0x801dca
  800337:	6a 23                	push   $0x23
  800339:	68 e7 1d 80 00       	push   $0x801de7
  80033e:	e8 f2 0c 00 00       	call   801035 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800343:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800346:	5b                   	pop    %ebx
  800347:	5e                   	pop    %esi
  800348:	5f                   	pop    %edi
  800349:	5d                   	pop    %ebp
  80034a:	c3                   	ret    

0080034b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80034b:	55                   	push   %ebp
  80034c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80034e:	8b 45 08             	mov    0x8(%ebp),%eax
  800351:	05 00 00 00 30       	add    $0x30000000,%eax
  800356:	c1 e8 0c             	shr    $0xc,%eax
}
  800359:	5d                   	pop    %ebp
  80035a:	c3                   	ret    

0080035b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80035b:	55                   	push   %ebp
  80035c:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80035e:	8b 45 08             	mov    0x8(%ebp),%eax
  800361:	05 00 00 00 30       	add    $0x30000000,%eax
  800366:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80036b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800370:	5d                   	pop    %ebp
  800371:	c3                   	ret    

00800372 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800372:	55                   	push   %ebp
  800373:	89 e5                	mov    %esp,%ebp
  800375:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800378:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80037d:	89 c2                	mov    %eax,%edx
  80037f:	c1 ea 16             	shr    $0x16,%edx
  800382:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800389:	f6 c2 01             	test   $0x1,%dl
  80038c:	74 11                	je     80039f <fd_alloc+0x2d>
  80038e:	89 c2                	mov    %eax,%edx
  800390:	c1 ea 0c             	shr    $0xc,%edx
  800393:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80039a:	f6 c2 01             	test   $0x1,%dl
  80039d:	75 09                	jne    8003a8 <fd_alloc+0x36>
			*fd_store = fd;
  80039f:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a6:	eb 17                	jmp    8003bf <fd_alloc+0x4d>
  8003a8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003ad:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003b2:	75 c9                	jne    80037d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003b4:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003ba:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003bf:	5d                   	pop    %ebp
  8003c0:	c3                   	ret    

008003c1 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003c1:	55                   	push   %ebp
  8003c2:	89 e5                	mov    %esp,%ebp
  8003c4:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003c7:	83 f8 1f             	cmp    $0x1f,%eax
  8003ca:	77 36                	ja     800402 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003cc:	c1 e0 0c             	shl    $0xc,%eax
  8003cf:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003d4:	89 c2                	mov    %eax,%edx
  8003d6:	c1 ea 16             	shr    $0x16,%edx
  8003d9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003e0:	f6 c2 01             	test   $0x1,%dl
  8003e3:	74 24                	je     800409 <fd_lookup+0x48>
  8003e5:	89 c2                	mov    %eax,%edx
  8003e7:	c1 ea 0c             	shr    $0xc,%edx
  8003ea:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003f1:	f6 c2 01             	test   $0x1,%dl
  8003f4:	74 1a                	je     800410 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003f9:	89 02                	mov    %eax,(%edx)
	return 0;
  8003fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800400:	eb 13                	jmp    800415 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800402:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800407:	eb 0c                	jmp    800415 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800409:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80040e:	eb 05                	jmp    800415 <fd_lookup+0x54>
  800410:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800415:	5d                   	pop    %ebp
  800416:	c3                   	ret    

00800417 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800417:	55                   	push   %ebp
  800418:	89 e5                	mov    %esp,%ebp
  80041a:	83 ec 08             	sub    $0x8,%esp
  80041d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800420:	ba 74 1e 80 00       	mov    $0x801e74,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800425:	eb 13                	jmp    80043a <dev_lookup+0x23>
  800427:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80042a:	39 08                	cmp    %ecx,(%eax)
  80042c:	75 0c                	jne    80043a <dev_lookup+0x23>
			*dev = devtab[i];
  80042e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800431:	89 01                	mov    %eax,(%ecx)
			return 0;
  800433:	b8 00 00 00 00       	mov    $0x0,%eax
  800438:	eb 2e                	jmp    800468 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80043a:	8b 02                	mov    (%edx),%eax
  80043c:	85 c0                	test   %eax,%eax
  80043e:	75 e7                	jne    800427 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800440:	a1 04 40 80 00       	mov    0x804004,%eax
  800445:	8b 40 48             	mov    0x48(%eax),%eax
  800448:	83 ec 04             	sub    $0x4,%esp
  80044b:	51                   	push   %ecx
  80044c:	50                   	push   %eax
  80044d:	68 f8 1d 80 00       	push   $0x801df8
  800452:	e8 b7 0c 00 00       	call   80110e <cprintf>
	*dev = 0;
  800457:	8b 45 0c             	mov    0xc(%ebp),%eax
  80045a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800460:	83 c4 10             	add    $0x10,%esp
  800463:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800468:	c9                   	leave  
  800469:	c3                   	ret    

0080046a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80046a:	55                   	push   %ebp
  80046b:	89 e5                	mov    %esp,%ebp
  80046d:	56                   	push   %esi
  80046e:	53                   	push   %ebx
  80046f:	83 ec 10             	sub    $0x10,%esp
  800472:	8b 75 08             	mov    0x8(%ebp),%esi
  800475:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800478:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80047b:	50                   	push   %eax
  80047c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800482:	c1 e8 0c             	shr    $0xc,%eax
  800485:	50                   	push   %eax
  800486:	e8 36 ff ff ff       	call   8003c1 <fd_lookup>
  80048b:	83 c4 08             	add    $0x8,%esp
  80048e:	85 c0                	test   %eax,%eax
  800490:	78 05                	js     800497 <fd_close+0x2d>
	    || fd != fd2)
  800492:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800495:	74 0c                	je     8004a3 <fd_close+0x39>
		return (must_exist ? r : 0);
  800497:	84 db                	test   %bl,%bl
  800499:	ba 00 00 00 00       	mov    $0x0,%edx
  80049e:	0f 44 c2             	cmove  %edx,%eax
  8004a1:	eb 41                	jmp    8004e4 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004a3:	83 ec 08             	sub    $0x8,%esp
  8004a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004a9:	50                   	push   %eax
  8004aa:	ff 36                	pushl  (%esi)
  8004ac:	e8 66 ff ff ff       	call   800417 <dev_lookup>
  8004b1:	89 c3                	mov    %eax,%ebx
  8004b3:	83 c4 10             	add    $0x10,%esp
  8004b6:	85 c0                	test   %eax,%eax
  8004b8:	78 1a                	js     8004d4 <fd_close+0x6a>
		if (dev->dev_close)
  8004ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004bd:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004c0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004c5:	85 c0                	test   %eax,%eax
  8004c7:	74 0b                	je     8004d4 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004c9:	83 ec 0c             	sub    $0xc,%esp
  8004cc:	56                   	push   %esi
  8004cd:	ff d0                	call   *%eax
  8004cf:	89 c3                	mov    %eax,%ebx
  8004d1:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004d4:	83 ec 08             	sub    $0x8,%esp
  8004d7:	56                   	push   %esi
  8004d8:	6a 00                	push   $0x0
  8004da:	e8 00 fd ff ff       	call   8001df <sys_page_unmap>
	return r;
  8004df:	83 c4 10             	add    $0x10,%esp
  8004e2:	89 d8                	mov    %ebx,%eax
}
  8004e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004e7:	5b                   	pop    %ebx
  8004e8:	5e                   	pop    %esi
  8004e9:	5d                   	pop    %ebp
  8004ea:	c3                   	ret    

008004eb <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004eb:	55                   	push   %ebp
  8004ec:	89 e5                	mov    %esp,%ebp
  8004ee:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004f4:	50                   	push   %eax
  8004f5:	ff 75 08             	pushl  0x8(%ebp)
  8004f8:	e8 c4 fe ff ff       	call   8003c1 <fd_lookup>
  8004fd:	83 c4 08             	add    $0x8,%esp
  800500:	85 c0                	test   %eax,%eax
  800502:	78 10                	js     800514 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800504:	83 ec 08             	sub    $0x8,%esp
  800507:	6a 01                	push   $0x1
  800509:	ff 75 f4             	pushl  -0xc(%ebp)
  80050c:	e8 59 ff ff ff       	call   80046a <fd_close>
  800511:	83 c4 10             	add    $0x10,%esp
}
  800514:	c9                   	leave  
  800515:	c3                   	ret    

00800516 <close_all>:

void
close_all(void)
{
  800516:	55                   	push   %ebp
  800517:	89 e5                	mov    %esp,%ebp
  800519:	53                   	push   %ebx
  80051a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80051d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800522:	83 ec 0c             	sub    $0xc,%esp
  800525:	53                   	push   %ebx
  800526:	e8 c0 ff ff ff       	call   8004eb <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80052b:	83 c3 01             	add    $0x1,%ebx
  80052e:	83 c4 10             	add    $0x10,%esp
  800531:	83 fb 20             	cmp    $0x20,%ebx
  800534:	75 ec                	jne    800522 <close_all+0xc>
		close(i);
}
  800536:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800539:	c9                   	leave  
  80053a:	c3                   	ret    

0080053b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80053b:	55                   	push   %ebp
  80053c:	89 e5                	mov    %esp,%ebp
  80053e:	57                   	push   %edi
  80053f:	56                   	push   %esi
  800540:	53                   	push   %ebx
  800541:	83 ec 2c             	sub    $0x2c,%esp
  800544:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800547:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80054a:	50                   	push   %eax
  80054b:	ff 75 08             	pushl  0x8(%ebp)
  80054e:	e8 6e fe ff ff       	call   8003c1 <fd_lookup>
  800553:	83 c4 08             	add    $0x8,%esp
  800556:	85 c0                	test   %eax,%eax
  800558:	0f 88 c1 00 00 00    	js     80061f <dup+0xe4>
		return r;
	close(newfdnum);
  80055e:	83 ec 0c             	sub    $0xc,%esp
  800561:	56                   	push   %esi
  800562:	e8 84 ff ff ff       	call   8004eb <close>

	newfd = INDEX2FD(newfdnum);
  800567:	89 f3                	mov    %esi,%ebx
  800569:	c1 e3 0c             	shl    $0xc,%ebx
  80056c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800572:	83 c4 04             	add    $0x4,%esp
  800575:	ff 75 e4             	pushl  -0x1c(%ebp)
  800578:	e8 de fd ff ff       	call   80035b <fd2data>
  80057d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80057f:	89 1c 24             	mov    %ebx,(%esp)
  800582:	e8 d4 fd ff ff       	call   80035b <fd2data>
  800587:	83 c4 10             	add    $0x10,%esp
  80058a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80058d:	89 f8                	mov    %edi,%eax
  80058f:	c1 e8 16             	shr    $0x16,%eax
  800592:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800599:	a8 01                	test   $0x1,%al
  80059b:	74 37                	je     8005d4 <dup+0x99>
  80059d:	89 f8                	mov    %edi,%eax
  80059f:	c1 e8 0c             	shr    $0xc,%eax
  8005a2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005a9:	f6 c2 01             	test   $0x1,%dl
  8005ac:	74 26                	je     8005d4 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005ae:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005b5:	83 ec 0c             	sub    $0xc,%esp
  8005b8:	25 07 0e 00 00       	and    $0xe07,%eax
  8005bd:	50                   	push   %eax
  8005be:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005c1:	6a 00                	push   $0x0
  8005c3:	57                   	push   %edi
  8005c4:	6a 00                	push   $0x0
  8005c6:	e8 d2 fb ff ff       	call   80019d <sys_page_map>
  8005cb:	89 c7                	mov    %eax,%edi
  8005cd:	83 c4 20             	add    $0x20,%esp
  8005d0:	85 c0                	test   %eax,%eax
  8005d2:	78 2e                	js     800602 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005d4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005d7:	89 d0                	mov    %edx,%eax
  8005d9:	c1 e8 0c             	shr    $0xc,%eax
  8005dc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005e3:	83 ec 0c             	sub    $0xc,%esp
  8005e6:	25 07 0e 00 00       	and    $0xe07,%eax
  8005eb:	50                   	push   %eax
  8005ec:	53                   	push   %ebx
  8005ed:	6a 00                	push   $0x0
  8005ef:	52                   	push   %edx
  8005f0:	6a 00                	push   $0x0
  8005f2:	e8 a6 fb ff ff       	call   80019d <sys_page_map>
  8005f7:	89 c7                	mov    %eax,%edi
  8005f9:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8005fc:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005fe:	85 ff                	test   %edi,%edi
  800600:	79 1d                	jns    80061f <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800602:	83 ec 08             	sub    $0x8,%esp
  800605:	53                   	push   %ebx
  800606:	6a 00                	push   $0x0
  800608:	e8 d2 fb ff ff       	call   8001df <sys_page_unmap>
	sys_page_unmap(0, nva);
  80060d:	83 c4 08             	add    $0x8,%esp
  800610:	ff 75 d4             	pushl  -0x2c(%ebp)
  800613:	6a 00                	push   $0x0
  800615:	e8 c5 fb ff ff       	call   8001df <sys_page_unmap>
	return r;
  80061a:	83 c4 10             	add    $0x10,%esp
  80061d:	89 f8                	mov    %edi,%eax
}
  80061f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800622:	5b                   	pop    %ebx
  800623:	5e                   	pop    %esi
  800624:	5f                   	pop    %edi
  800625:	5d                   	pop    %ebp
  800626:	c3                   	ret    

00800627 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800627:	55                   	push   %ebp
  800628:	89 e5                	mov    %esp,%ebp
  80062a:	53                   	push   %ebx
  80062b:	83 ec 14             	sub    $0x14,%esp
  80062e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800631:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800634:	50                   	push   %eax
  800635:	53                   	push   %ebx
  800636:	e8 86 fd ff ff       	call   8003c1 <fd_lookup>
  80063b:	83 c4 08             	add    $0x8,%esp
  80063e:	89 c2                	mov    %eax,%edx
  800640:	85 c0                	test   %eax,%eax
  800642:	78 6d                	js     8006b1 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800644:	83 ec 08             	sub    $0x8,%esp
  800647:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80064a:	50                   	push   %eax
  80064b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80064e:	ff 30                	pushl  (%eax)
  800650:	e8 c2 fd ff ff       	call   800417 <dev_lookup>
  800655:	83 c4 10             	add    $0x10,%esp
  800658:	85 c0                	test   %eax,%eax
  80065a:	78 4c                	js     8006a8 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80065c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80065f:	8b 42 08             	mov    0x8(%edx),%eax
  800662:	83 e0 03             	and    $0x3,%eax
  800665:	83 f8 01             	cmp    $0x1,%eax
  800668:	75 21                	jne    80068b <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80066a:	a1 04 40 80 00       	mov    0x804004,%eax
  80066f:	8b 40 48             	mov    0x48(%eax),%eax
  800672:	83 ec 04             	sub    $0x4,%esp
  800675:	53                   	push   %ebx
  800676:	50                   	push   %eax
  800677:	68 39 1e 80 00       	push   $0x801e39
  80067c:	e8 8d 0a 00 00       	call   80110e <cprintf>
		return -E_INVAL;
  800681:	83 c4 10             	add    $0x10,%esp
  800684:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800689:	eb 26                	jmp    8006b1 <read+0x8a>
	}
	if (!dev->dev_read)
  80068b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80068e:	8b 40 08             	mov    0x8(%eax),%eax
  800691:	85 c0                	test   %eax,%eax
  800693:	74 17                	je     8006ac <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800695:	83 ec 04             	sub    $0x4,%esp
  800698:	ff 75 10             	pushl  0x10(%ebp)
  80069b:	ff 75 0c             	pushl  0xc(%ebp)
  80069e:	52                   	push   %edx
  80069f:	ff d0                	call   *%eax
  8006a1:	89 c2                	mov    %eax,%edx
  8006a3:	83 c4 10             	add    $0x10,%esp
  8006a6:	eb 09                	jmp    8006b1 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006a8:	89 c2                	mov    %eax,%edx
  8006aa:	eb 05                	jmp    8006b1 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006ac:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006b1:	89 d0                	mov    %edx,%eax
  8006b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006b6:	c9                   	leave  
  8006b7:	c3                   	ret    

008006b8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006b8:	55                   	push   %ebp
  8006b9:	89 e5                	mov    %esp,%ebp
  8006bb:	57                   	push   %edi
  8006bc:	56                   	push   %esi
  8006bd:	53                   	push   %ebx
  8006be:	83 ec 0c             	sub    $0xc,%esp
  8006c1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006c4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006c7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006cc:	eb 21                	jmp    8006ef <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006ce:	83 ec 04             	sub    $0x4,%esp
  8006d1:	89 f0                	mov    %esi,%eax
  8006d3:	29 d8                	sub    %ebx,%eax
  8006d5:	50                   	push   %eax
  8006d6:	89 d8                	mov    %ebx,%eax
  8006d8:	03 45 0c             	add    0xc(%ebp),%eax
  8006db:	50                   	push   %eax
  8006dc:	57                   	push   %edi
  8006dd:	e8 45 ff ff ff       	call   800627 <read>
		if (m < 0)
  8006e2:	83 c4 10             	add    $0x10,%esp
  8006e5:	85 c0                	test   %eax,%eax
  8006e7:	78 10                	js     8006f9 <readn+0x41>
			return m;
		if (m == 0)
  8006e9:	85 c0                	test   %eax,%eax
  8006eb:	74 0a                	je     8006f7 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006ed:	01 c3                	add    %eax,%ebx
  8006ef:	39 f3                	cmp    %esi,%ebx
  8006f1:	72 db                	jb     8006ce <readn+0x16>
  8006f3:	89 d8                	mov    %ebx,%eax
  8006f5:	eb 02                	jmp    8006f9 <readn+0x41>
  8006f7:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8006f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006fc:	5b                   	pop    %ebx
  8006fd:	5e                   	pop    %esi
  8006fe:	5f                   	pop    %edi
  8006ff:	5d                   	pop    %ebp
  800700:	c3                   	ret    

00800701 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800701:	55                   	push   %ebp
  800702:	89 e5                	mov    %esp,%ebp
  800704:	53                   	push   %ebx
  800705:	83 ec 14             	sub    $0x14,%esp
  800708:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80070b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80070e:	50                   	push   %eax
  80070f:	53                   	push   %ebx
  800710:	e8 ac fc ff ff       	call   8003c1 <fd_lookup>
  800715:	83 c4 08             	add    $0x8,%esp
  800718:	89 c2                	mov    %eax,%edx
  80071a:	85 c0                	test   %eax,%eax
  80071c:	78 68                	js     800786 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80071e:	83 ec 08             	sub    $0x8,%esp
  800721:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800724:	50                   	push   %eax
  800725:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800728:	ff 30                	pushl  (%eax)
  80072a:	e8 e8 fc ff ff       	call   800417 <dev_lookup>
  80072f:	83 c4 10             	add    $0x10,%esp
  800732:	85 c0                	test   %eax,%eax
  800734:	78 47                	js     80077d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800736:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800739:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80073d:	75 21                	jne    800760 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80073f:	a1 04 40 80 00       	mov    0x804004,%eax
  800744:	8b 40 48             	mov    0x48(%eax),%eax
  800747:	83 ec 04             	sub    $0x4,%esp
  80074a:	53                   	push   %ebx
  80074b:	50                   	push   %eax
  80074c:	68 55 1e 80 00       	push   $0x801e55
  800751:	e8 b8 09 00 00       	call   80110e <cprintf>
		return -E_INVAL;
  800756:	83 c4 10             	add    $0x10,%esp
  800759:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80075e:	eb 26                	jmp    800786 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800760:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800763:	8b 52 0c             	mov    0xc(%edx),%edx
  800766:	85 d2                	test   %edx,%edx
  800768:	74 17                	je     800781 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80076a:	83 ec 04             	sub    $0x4,%esp
  80076d:	ff 75 10             	pushl  0x10(%ebp)
  800770:	ff 75 0c             	pushl  0xc(%ebp)
  800773:	50                   	push   %eax
  800774:	ff d2                	call   *%edx
  800776:	89 c2                	mov    %eax,%edx
  800778:	83 c4 10             	add    $0x10,%esp
  80077b:	eb 09                	jmp    800786 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80077d:	89 c2                	mov    %eax,%edx
  80077f:	eb 05                	jmp    800786 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800781:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800786:	89 d0                	mov    %edx,%eax
  800788:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80078b:	c9                   	leave  
  80078c:	c3                   	ret    

0080078d <seek>:

int
seek(int fdnum, off_t offset)
{
  80078d:	55                   	push   %ebp
  80078e:	89 e5                	mov    %esp,%ebp
  800790:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800793:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800796:	50                   	push   %eax
  800797:	ff 75 08             	pushl  0x8(%ebp)
  80079a:	e8 22 fc ff ff       	call   8003c1 <fd_lookup>
  80079f:	83 c4 08             	add    $0x8,%esp
  8007a2:	85 c0                	test   %eax,%eax
  8007a4:	78 0e                	js     8007b4 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ac:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007af:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007b4:	c9                   	leave  
  8007b5:	c3                   	ret    

008007b6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007b6:	55                   	push   %ebp
  8007b7:	89 e5                	mov    %esp,%ebp
  8007b9:	53                   	push   %ebx
  8007ba:	83 ec 14             	sub    $0x14,%esp
  8007bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007c0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007c3:	50                   	push   %eax
  8007c4:	53                   	push   %ebx
  8007c5:	e8 f7 fb ff ff       	call   8003c1 <fd_lookup>
  8007ca:	83 c4 08             	add    $0x8,%esp
  8007cd:	89 c2                	mov    %eax,%edx
  8007cf:	85 c0                	test   %eax,%eax
  8007d1:	78 65                	js     800838 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007d3:	83 ec 08             	sub    $0x8,%esp
  8007d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007d9:	50                   	push   %eax
  8007da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007dd:	ff 30                	pushl  (%eax)
  8007df:	e8 33 fc ff ff       	call   800417 <dev_lookup>
  8007e4:	83 c4 10             	add    $0x10,%esp
  8007e7:	85 c0                	test   %eax,%eax
  8007e9:	78 44                	js     80082f <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007ee:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007f2:	75 21                	jne    800815 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8007f4:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007f9:	8b 40 48             	mov    0x48(%eax),%eax
  8007fc:	83 ec 04             	sub    $0x4,%esp
  8007ff:	53                   	push   %ebx
  800800:	50                   	push   %eax
  800801:	68 18 1e 80 00       	push   $0x801e18
  800806:	e8 03 09 00 00       	call   80110e <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80080b:	83 c4 10             	add    $0x10,%esp
  80080e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800813:	eb 23                	jmp    800838 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800815:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800818:	8b 52 18             	mov    0x18(%edx),%edx
  80081b:	85 d2                	test   %edx,%edx
  80081d:	74 14                	je     800833 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80081f:	83 ec 08             	sub    $0x8,%esp
  800822:	ff 75 0c             	pushl  0xc(%ebp)
  800825:	50                   	push   %eax
  800826:	ff d2                	call   *%edx
  800828:	89 c2                	mov    %eax,%edx
  80082a:	83 c4 10             	add    $0x10,%esp
  80082d:	eb 09                	jmp    800838 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80082f:	89 c2                	mov    %eax,%edx
  800831:	eb 05                	jmp    800838 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800833:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800838:	89 d0                	mov    %edx,%eax
  80083a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80083d:	c9                   	leave  
  80083e:	c3                   	ret    

0080083f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80083f:	55                   	push   %ebp
  800840:	89 e5                	mov    %esp,%ebp
  800842:	53                   	push   %ebx
  800843:	83 ec 14             	sub    $0x14,%esp
  800846:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800849:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80084c:	50                   	push   %eax
  80084d:	ff 75 08             	pushl  0x8(%ebp)
  800850:	e8 6c fb ff ff       	call   8003c1 <fd_lookup>
  800855:	83 c4 08             	add    $0x8,%esp
  800858:	89 c2                	mov    %eax,%edx
  80085a:	85 c0                	test   %eax,%eax
  80085c:	78 58                	js     8008b6 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80085e:	83 ec 08             	sub    $0x8,%esp
  800861:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800864:	50                   	push   %eax
  800865:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800868:	ff 30                	pushl  (%eax)
  80086a:	e8 a8 fb ff ff       	call   800417 <dev_lookup>
  80086f:	83 c4 10             	add    $0x10,%esp
  800872:	85 c0                	test   %eax,%eax
  800874:	78 37                	js     8008ad <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800876:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800879:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80087d:	74 32                	je     8008b1 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80087f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800882:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800889:	00 00 00 
	stat->st_isdir = 0;
  80088c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800893:	00 00 00 
	stat->st_dev = dev;
  800896:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80089c:	83 ec 08             	sub    $0x8,%esp
  80089f:	53                   	push   %ebx
  8008a0:	ff 75 f0             	pushl  -0x10(%ebp)
  8008a3:	ff 50 14             	call   *0x14(%eax)
  8008a6:	89 c2                	mov    %eax,%edx
  8008a8:	83 c4 10             	add    $0x10,%esp
  8008ab:	eb 09                	jmp    8008b6 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008ad:	89 c2                	mov    %eax,%edx
  8008af:	eb 05                	jmp    8008b6 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008b1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008b6:	89 d0                	mov    %edx,%eax
  8008b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008bb:	c9                   	leave  
  8008bc:	c3                   	ret    

008008bd <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008bd:	55                   	push   %ebp
  8008be:	89 e5                	mov    %esp,%ebp
  8008c0:	56                   	push   %esi
  8008c1:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008c2:	83 ec 08             	sub    $0x8,%esp
  8008c5:	6a 00                	push   $0x0
  8008c7:	ff 75 08             	pushl  0x8(%ebp)
  8008ca:	e8 e3 01 00 00       	call   800ab2 <open>
  8008cf:	89 c3                	mov    %eax,%ebx
  8008d1:	83 c4 10             	add    $0x10,%esp
  8008d4:	85 c0                	test   %eax,%eax
  8008d6:	78 1b                	js     8008f3 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008d8:	83 ec 08             	sub    $0x8,%esp
  8008db:	ff 75 0c             	pushl  0xc(%ebp)
  8008de:	50                   	push   %eax
  8008df:	e8 5b ff ff ff       	call   80083f <fstat>
  8008e4:	89 c6                	mov    %eax,%esi
	close(fd);
  8008e6:	89 1c 24             	mov    %ebx,(%esp)
  8008e9:	e8 fd fb ff ff       	call   8004eb <close>
	return r;
  8008ee:	83 c4 10             	add    $0x10,%esp
  8008f1:	89 f0                	mov    %esi,%eax
}
  8008f3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008f6:	5b                   	pop    %ebx
  8008f7:	5e                   	pop    %esi
  8008f8:	5d                   	pop    %ebp
  8008f9:	c3                   	ret    

008008fa <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	56                   	push   %esi
  8008fe:	53                   	push   %ebx
  8008ff:	89 c6                	mov    %eax,%esi
  800901:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800903:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80090a:	75 12                	jne    80091e <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80090c:	83 ec 0c             	sub    $0xc,%esp
  80090f:	6a 01                	push   $0x1
  800911:	e8 8b 11 00 00       	call   801aa1 <ipc_find_env>
  800916:	a3 00 40 80 00       	mov    %eax,0x804000
  80091b:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80091e:	6a 07                	push   $0x7
  800920:	68 00 50 80 00       	push   $0x805000
  800925:	56                   	push   %esi
  800926:	ff 35 00 40 80 00    	pushl  0x804000
  80092c:	e8 1c 11 00 00       	call   801a4d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800931:	83 c4 0c             	add    $0xc,%esp
  800934:	6a 00                	push   $0x0
  800936:	53                   	push   %ebx
  800937:	6a 00                	push   $0x0
  800939:	e8 ba 10 00 00       	call   8019f8 <ipc_recv>
}
  80093e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800941:	5b                   	pop    %ebx
  800942:	5e                   	pop    %esi
  800943:	5d                   	pop    %ebp
  800944:	c3                   	ret    

00800945 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800945:	55                   	push   %ebp
  800946:	89 e5                	mov    %esp,%ebp
  800948:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80094b:	8b 45 08             	mov    0x8(%ebp),%eax
  80094e:	8b 40 0c             	mov    0xc(%eax),%eax
  800951:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800956:	8b 45 0c             	mov    0xc(%ebp),%eax
  800959:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80095e:	ba 00 00 00 00       	mov    $0x0,%edx
  800963:	b8 02 00 00 00       	mov    $0x2,%eax
  800968:	e8 8d ff ff ff       	call   8008fa <fsipc>
}
  80096d:	c9                   	leave  
  80096e:	c3                   	ret    

0080096f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80096f:	55                   	push   %ebp
  800970:	89 e5                	mov    %esp,%ebp
  800972:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800975:	8b 45 08             	mov    0x8(%ebp),%eax
  800978:	8b 40 0c             	mov    0xc(%eax),%eax
  80097b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800980:	ba 00 00 00 00       	mov    $0x0,%edx
  800985:	b8 06 00 00 00       	mov    $0x6,%eax
  80098a:	e8 6b ff ff ff       	call   8008fa <fsipc>
}
  80098f:	c9                   	leave  
  800990:	c3                   	ret    

00800991 <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800991:	55                   	push   %ebp
  800992:	89 e5                	mov    %esp,%ebp
  800994:	53                   	push   %ebx
  800995:	83 ec 04             	sub    $0x4,%esp
  800998:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80099b:	8b 45 08             	mov    0x8(%ebp),%eax
  80099e:	8b 40 0c             	mov    0xc(%eax),%eax
  8009a1:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ab:	b8 05 00 00 00       	mov    $0x5,%eax
  8009b0:	e8 45 ff ff ff       	call   8008fa <fsipc>
  8009b5:	85 c0                	test   %eax,%eax
  8009b7:	78 2c                	js     8009e5 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009b9:	83 ec 08             	sub    $0x8,%esp
  8009bc:	68 00 50 80 00       	push   $0x805000
  8009c1:	53                   	push   %ebx
  8009c2:	e8 ea 0c 00 00       	call   8016b1 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009c7:	a1 80 50 80 00       	mov    0x805080,%eax
  8009cc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009d2:	a1 84 50 80 00       	mov    0x805084,%eax
  8009d7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009dd:	83 c4 10             	add    $0x10,%esp
  8009e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009e8:	c9                   	leave  
  8009e9:	c3                   	ret    

008009ea <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009ea:	55                   	push   %ebp
  8009eb:	89 e5                	mov    %esp,%ebp
  8009ed:	83 ec 0c             	sub    $0xc,%esp
  8009f0:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
    
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8009f6:	8b 52 0c             	mov    0xc(%edx),%edx
  8009f9:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = MIN(n, PGSIZE);
  8009ff:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a04:	ba 00 10 00 00       	mov    $0x1000,%edx
  800a09:	0f 47 c2             	cmova  %edx,%eax
  800a0c:	a3 04 50 80 00       	mov    %eax,0x805004
    memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  800a11:	50                   	push   %eax
  800a12:	ff 75 0c             	pushl  0xc(%ebp)
  800a15:	68 08 50 80 00       	push   $0x805008
  800a1a:	e8 24 0e 00 00       	call   801843 <memmove>
    int r = fsipc(FSREQ_WRITE, NULL);
  800a1f:	ba 00 00 00 00       	mov    $0x0,%edx
  800a24:	b8 04 00 00 00       	mov    $0x4,%eax
  800a29:	e8 cc fe ff ff       	call   8008fa <fsipc>
    return r;
}
  800a2e:	c9                   	leave  
  800a2f:	c3                   	ret    

00800a30 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a30:	55                   	push   %ebp
  800a31:	89 e5                	mov    %esp,%ebp
  800a33:	56                   	push   %esi
  800a34:	53                   	push   %ebx
  800a35:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a38:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3b:	8b 40 0c             	mov    0xc(%eax),%eax
  800a3e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a43:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a49:	ba 00 00 00 00       	mov    $0x0,%edx
  800a4e:	b8 03 00 00 00       	mov    $0x3,%eax
  800a53:	e8 a2 fe ff ff       	call   8008fa <fsipc>
  800a58:	89 c3                	mov    %eax,%ebx
  800a5a:	85 c0                	test   %eax,%eax
  800a5c:	78 4b                	js     800aa9 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a5e:	39 c6                	cmp    %eax,%esi
  800a60:	73 16                	jae    800a78 <devfile_read+0x48>
  800a62:	68 84 1e 80 00       	push   $0x801e84
  800a67:	68 8b 1e 80 00       	push   $0x801e8b
  800a6c:	6a 7c                	push   $0x7c
  800a6e:	68 a0 1e 80 00       	push   $0x801ea0
  800a73:	e8 bd 05 00 00       	call   801035 <_panic>
	assert(r <= PGSIZE);
  800a78:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a7d:	7e 16                	jle    800a95 <devfile_read+0x65>
  800a7f:	68 ab 1e 80 00       	push   $0x801eab
  800a84:	68 8b 1e 80 00       	push   $0x801e8b
  800a89:	6a 7d                	push   $0x7d
  800a8b:	68 a0 1e 80 00       	push   $0x801ea0
  800a90:	e8 a0 05 00 00       	call   801035 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a95:	83 ec 04             	sub    $0x4,%esp
  800a98:	50                   	push   %eax
  800a99:	68 00 50 80 00       	push   $0x805000
  800a9e:	ff 75 0c             	pushl  0xc(%ebp)
  800aa1:	e8 9d 0d 00 00       	call   801843 <memmove>
	return r;
  800aa6:	83 c4 10             	add    $0x10,%esp
}
  800aa9:	89 d8                	mov    %ebx,%eax
  800aab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800aae:	5b                   	pop    %ebx
  800aaf:	5e                   	pop    %esi
  800ab0:	5d                   	pop    %ebp
  800ab1:	c3                   	ret    

00800ab2 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800ab2:	55                   	push   %ebp
  800ab3:	89 e5                	mov    %esp,%ebp
  800ab5:	53                   	push   %ebx
  800ab6:	83 ec 20             	sub    $0x20,%esp
  800ab9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800abc:	53                   	push   %ebx
  800abd:	e8 b6 0b 00 00       	call   801678 <strlen>
  800ac2:	83 c4 10             	add    $0x10,%esp
  800ac5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800aca:	7f 67                	jg     800b33 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800acc:	83 ec 0c             	sub    $0xc,%esp
  800acf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ad2:	50                   	push   %eax
  800ad3:	e8 9a f8 ff ff       	call   800372 <fd_alloc>
  800ad8:	83 c4 10             	add    $0x10,%esp
		return r;
  800adb:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800add:	85 c0                	test   %eax,%eax
  800adf:	78 57                	js     800b38 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800ae1:	83 ec 08             	sub    $0x8,%esp
  800ae4:	53                   	push   %ebx
  800ae5:	68 00 50 80 00       	push   $0x805000
  800aea:	e8 c2 0b 00 00       	call   8016b1 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800aef:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af2:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800af7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800afa:	b8 01 00 00 00       	mov    $0x1,%eax
  800aff:	e8 f6 fd ff ff       	call   8008fa <fsipc>
  800b04:	89 c3                	mov    %eax,%ebx
  800b06:	83 c4 10             	add    $0x10,%esp
  800b09:	85 c0                	test   %eax,%eax
  800b0b:	79 14                	jns    800b21 <open+0x6f>
		fd_close(fd, 0);
  800b0d:	83 ec 08             	sub    $0x8,%esp
  800b10:	6a 00                	push   $0x0
  800b12:	ff 75 f4             	pushl  -0xc(%ebp)
  800b15:	e8 50 f9 ff ff       	call   80046a <fd_close>
		return r;
  800b1a:	83 c4 10             	add    $0x10,%esp
  800b1d:	89 da                	mov    %ebx,%edx
  800b1f:	eb 17                	jmp    800b38 <open+0x86>
	}

	return fd2num(fd);
  800b21:	83 ec 0c             	sub    $0xc,%esp
  800b24:	ff 75 f4             	pushl  -0xc(%ebp)
  800b27:	e8 1f f8 ff ff       	call   80034b <fd2num>
  800b2c:	89 c2                	mov    %eax,%edx
  800b2e:	83 c4 10             	add    $0x10,%esp
  800b31:	eb 05                	jmp    800b38 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b33:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b38:	89 d0                	mov    %edx,%eax
  800b3a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b3d:	c9                   	leave  
  800b3e:	c3                   	ret    

00800b3f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b3f:	55                   	push   %ebp
  800b40:	89 e5                	mov    %esp,%ebp
  800b42:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b45:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4a:	b8 08 00 00 00       	mov    $0x8,%eax
  800b4f:	e8 a6 fd ff ff       	call   8008fa <fsipc>
}
  800b54:	c9                   	leave  
  800b55:	c3                   	ret    

00800b56 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b56:	55                   	push   %ebp
  800b57:	89 e5                	mov    %esp,%ebp
  800b59:	56                   	push   %esi
  800b5a:	53                   	push   %ebx
  800b5b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b5e:	83 ec 0c             	sub    $0xc,%esp
  800b61:	ff 75 08             	pushl  0x8(%ebp)
  800b64:	e8 f2 f7 ff ff       	call   80035b <fd2data>
  800b69:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b6b:	83 c4 08             	add    $0x8,%esp
  800b6e:	68 b7 1e 80 00       	push   $0x801eb7
  800b73:	53                   	push   %ebx
  800b74:	e8 38 0b 00 00       	call   8016b1 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b79:	8b 46 04             	mov    0x4(%esi),%eax
  800b7c:	2b 06                	sub    (%esi),%eax
  800b7e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b84:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b8b:	00 00 00 
	stat->st_dev = &devpipe;
  800b8e:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b95:	30 80 00 
	return 0;
}
  800b98:	b8 00 00 00 00       	mov    $0x0,%eax
  800b9d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ba0:	5b                   	pop    %ebx
  800ba1:	5e                   	pop    %esi
  800ba2:	5d                   	pop    %ebp
  800ba3:	c3                   	ret    

00800ba4 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800ba4:	55                   	push   %ebp
  800ba5:	89 e5                	mov    %esp,%ebp
  800ba7:	53                   	push   %ebx
  800ba8:	83 ec 0c             	sub    $0xc,%esp
  800bab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bae:	53                   	push   %ebx
  800baf:	6a 00                	push   $0x0
  800bb1:	e8 29 f6 ff ff       	call   8001df <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bb6:	89 1c 24             	mov    %ebx,(%esp)
  800bb9:	e8 9d f7 ff ff       	call   80035b <fd2data>
  800bbe:	83 c4 08             	add    $0x8,%esp
  800bc1:	50                   	push   %eax
  800bc2:	6a 00                	push   $0x0
  800bc4:	e8 16 f6 ff ff       	call   8001df <sys_page_unmap>
}
  800bc9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bcc:	c9                   	leave  
  800bcd:	c3                   	ret    

00800bce <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bce:	55                   	push   %ebp
  800bcf:	89 e5                	mov    %esp,%ebp
  800bd1:	57                   	push   %edi
  800bd2:	56                   	push   %esi
  800bd3:	53                   	push   %ebx
  800bd4:	83 ec 1c             	sub    $0x1c,%esp
  800bd7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800bda:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800bdc:	a1 04 40 80 00       	mov    0x804004,%eax
  800be1:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800be4:	83 ec 0c             	sub    $0xc,%esp
  800be7:	ff 75 e0             	pushl  -0x20(%ebp)
  800bea:	e8 eb 0e 00 00       	call   801ada <pageref>
  800bef:	89 c3                	mov    %eax,%ebx
  800bf1:	89 3c 24             	mov    %edi,(%esp)
  800bf4:	e8 e1 0e 00 00       	call   801ada <pageref>
  800bf9:	83 c4 10             	add    $0x10,%esp
  800bfc:	39 c3                	cmp    %eax,%ebx
  800bfe:	0f 94 c1             	sete   %cl
  800c01:	0f b6 c9             	movzbl %cl,%ecx
  800c04:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c07:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c0d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c10:	39 ce                	cmp    %ecx,%esi
  800c12:	74 1b                	je     800c2f <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c14:	39 c3                	cmp    %eax,%ebx
  800c16:	75 c4                	jne    800bdc <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c18:	8b 42 58             	mov    0x58(%edx),%eax
  800c1b:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c1e:	50                   	push   %eax
  800c1f:	56                   	push   %esi
  800c20:	68 be 1e 80 00       	push   $0x801ebe
  800c25:	e8 e4 04 00 00       	call   80110e <cprintf>
  800c2a:	83 c4 10             	add    $0x10,%esp
  800c2d:	eb ad                	jmp    800bdc <_pipeisclosed+0xe>
	}
}
  800c2f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c32:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c35:	5b                   	pop    %ebx
  800c36:	5e                   	pop    %esi
  800c37:	5f                   	pop    %edi
  800c38:	5d                   	pop    %ebp
  800c39:	c3                   	ret    

00800c3a <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c3a:	55                   	push   %ebp
  800c3b:	89 e5                	mov    %esp,%ebp
  800c3d:	57                   	push   %edi
  800c3e:	56                   	push   %esi
  800c3f:	53                   	push   %ebx
  800c40:	83 ec 28             	sub    $0x28,%esp
  800c43:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c46:	56                   	push   %esi
  800c47:	e8 0f f7 ff ff       	call   80035b <fd2data>
  800c4c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c4e:	83 c4 10             	add    $0x10,%esp
  800c51:	bf 00 00 00 00       	mov    $0x0,%edi
  800c56:	eb 4b                	jmp    800ca3 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c58:	89 da                	mov    %ebx,%edx
  800c5a:	89 f0                	mov    %esi,%eax
  800c5c:	e8 6d ff ff ff       	call   800bce <_pipeisclosed>
  800c61:	85 c0                	test   %eax,%eax
  800c63:	75 48                	jne    800cad <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c65:	e8 d1 f4 ff ff       	call   80013b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c6a:	8b 43 04             	mov    0x4(%ebx),%eax
  800c6d:	8b 0b                	mov    (%ebx),%ecx
  800c6f:	8d 51 20             	lea    0x20(%ecx),%edx
  800c72:	39 d0                	cmp    %edx,%eax
  800c74:	73 e2                	jae    800c58 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c79:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c7d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c80:	89 c2                	mov    %eax,%edx
  800c82:	c1 fa 1f             	sar    $0x1f,%edx
  800c85:	89 d1                	mov    %edx,%ecx
  800c87:	c1 e9 1b             	shr    $0x1b,%ecx
  800c8a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c8d:	83 e2 1f             	and    $0x1f,%edx
  800c90:	29 ca                	sub    %ecx,%edx
  800c92:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800c96:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c9a:	83 c0 01             	add    $0x1,%eax
  800c9d:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ca0:	83 c7 01             	add    $0x1,%edi
  800ca3:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800ca6:	75 c2                	jne    800c6a <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800ca8:	8b 45 10             	mov    0x10(%ebp),%eax
  800cab:	eb 05                	jmp    800cb2 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cad:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cb2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb5:	5b                   	pop    %ebx
  800cb6:	5e                   	pop    %esi
  800cb7:	5f                   	pop    %edi
  800cb8:	5d                   	pop    %ebp
  800cb9:	c3                   	ret    

00800cba <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cba:	55                   	push   %ebp
  800cbb:	89 e5                	mov    %esp,%ebp
  800cbd:	57                   	push   %edi
  800cbe:	56                   	push   %esi
  800cbf:	53                   	push   %ebx
  800cc0:	83 ec 18             	sub    $0x18,%esp
  800cc3:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800cc6:	57                   	push   %edi
  800cc7:	e8 8f f6 ff ff       	call   80035b <fd2data>
  800ccc:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cce:	83 c4 10             	add    $0x10,%esp
  800cd1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd6:	eb 3d                	jmp    800d15 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800cd8:	85 db                	test   %ebx,%ebx
  800cda:	74 04                	je     800ce0 <devpipe_read+0x26>
				return i;
  800cdc:	89 d8                	mov    %ebx,%eax
  800cde:	eb 44                	jmp    800d24 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800ce0:	89 f2                	mov    %esi,%edx
  800ce2:	89 f8                	mov    %edi,%eax
  800ce4:	e8 e5 fe ff ff       	call   800bce <_pipeisclosed>
  800ce9:	85 c0                	test   %eax,%eax
  800ceb:	75 32                	jne    800d1f <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800ced:	e8 49 f4 ff ff       	call   80013b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800cf2:	8b 06                	mov    (%esi),%eax
  800cf4:	3b 46 04             	cmp    0x4(%esi),%eax
  800cf7:	74 df                	je     800cd8 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800cf9:	99                   	cltd   
  800cfa:	c1 ea 1b             	shr    $0x1b,%edx
  800cfd:	01 d0                	add    %edx,%eax
  800cff:	83 e0 1f             	and    $0x1f,%eax
  800d02:	29 d0                	sub    %edx,%eax
  800d04:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0c:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d0f:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d12:	83 c3 01             	add    $0x1,%ebx
  800d15:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d18:	75 d8                	jne    800cf2 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d1a:	8b 45 10             	mov    0x10(%ebp),%eax
  800d1d:	eb 05                	jmp    800d24 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d1f:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d24:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d27:	5b                   	pop    %ebx
  800d28:	5e                   	pop    %esi
  800d29:	5f                   	pop    %edi
  800d2a:	5d                   	pop    %ebp
  800d2b:	c3                   	ret    

00800d2c <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d2c:	55                   	push   %ebp
  800d2d:	89 e5                	mov    %esp,%ebp
  800d2f:	56                   	push   %esi
  800d30:	53                   	push   %ebx
  800d31:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d34:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d37:	50                   	push   %eax
  800d38:	e8 35 f6 ff ff       	call   800372 <fd_alloc>
  800d3d:	83 c4 10             	add    $0x10,%esp
  800d40:	89 c2                	mov    %eax,%edx
  800d42:	85 c0                	test   %eax,%eax
  800d44:	0f 88 2c 01 00 00    	js     800e76 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d4a:	83 ec 04             	sub    $0x4,%esp
  800d4d:	68 07 04 00 00       	push   $0x407
  800d52:	ff 75 f4             	pushl  -0xc(%ebp)
  800d55:	6a 00                	push   $0x0
  800d57:	e8 fe f3 ff ff       	call   80015a <sys_page_alloc>
  800d5c:	83 c4 10             	add    $0x10,%esp
  800d5f:	89 c2                	mov    %eax,%edx
  800d61:	85 c0                	test   %eax,%eax
  800d63:	0f 88 0d 01 00 00    	js     800e76 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d69:	83 ec 0c             	sub    $0xc,%esp
  800d6c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d6f:	50                   	push   %eax
  800d70:	e8 fd f5 ff ff       	call   800372 <fd_alloc>
  800d75:	89 c3                	mov    %eax,%ebx
  800d77:	83 c4 10             	add    $0x10,%esp
  800d7a:	85 c0                	test   %eax,%eax
  800d7c:	0f 88 e2 00 00 00    	js     800e64 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d82:	83 ec 04             	sub    $0x4,%esp
  800d85:	68 07 04 00 00       	push   $0x407
  800d8a:	ff 75 f0             	pushl  -0x10(%ebp)
  800d8d:	6a 00                	push   $0x0
  800d8f:	e8 c6 f3 ff ff       	call   80015a <sys_page_alloc>
  800d94:	89 c3                	mov    %eax,%ebx
  800d96:	83 c4 10             	add    $0x10,%esp
  800d99:	85 c0                	test   %eax,%eax
  800d9b:	0f 88 c3 00 00 00    	js     800e64 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800da1:	83 ec 0c             	sub    $0xc,%esp
  800da4:	ff 75 f4             	pushl  -0xc(%ebp)
  800da7:	e8 af f5 ff ff       	call   80035b <fd2data>
  800dac:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dae:	83 c4 0c             	add    $0xc,%esp
  800db1:	68 07 04 00 00       	push   $0x407
  800db6:	50                   	push   %eax
  800db7:	6a 00                	push   $0x0
  800db9:	e8 9c f3 ff ff       	call   80015a <sys_page_alloc>
  800dbe:	89 c3                	mov    %eax,%ebx
  800dc0:	83 c4 10             	add    $0x10,%esp
  800dc3:	85 c0                	test   %eax,%eax
  800dc5:	0f 88 89 00 00 00    	js     800e54 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dcb:	83 ec 0c             	sub    $0xc,%esp
  800dce:	ff 75 f0             	pushl  -0x10(%ebp)
  800dd1:	e8 85 f5 ff ff       	call   80035b <fd2data>
  800dd6:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800ddd:	50                   	push   %eax
  800dde:	6a 00                	push   $0x0
  800de0:	56                   	push   %esi
  800de1:	6a 00                	push   $0x0
  800de3:	e8 b5 f3 ff ff       	call   80019d <sys_page_map>
  800de8:	89 c3                	mov    %eax,%ebx
  800dea:	83 c4 20             	add    $0x20,%esp
  800ded:	85 c0                	test   %eax,%eax
  800def:	78 55                	js     800e46 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800df1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800df7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dfa:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800dfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dff:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e06:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e0f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e11:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e14:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e1b:	83 ec 0c             	sub    $0xc,%esp
  800e1e:	ff 75 f4             	pushl  -0xc(%ebp)
  800e21:	e8 25 f5 ff ff       	call   80034b <fd2num>
  800e26:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e29:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e2b:	83 c4 04             	add    $0x4,%esp
  800e2e:	ff 75 f0             	pushl  -0x10(%ebp)
  800e31:	e8 15 f5 ff ff       	call   80034b <fd2num>
  800e36:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e39:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e3c:	83 c4 10             	add    $0x10,%esp
  800e3f:	ba 00 00 00 00       	mov    $0x0,%edx
  800e44:	eb 30                	jmp    800e76 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e46:	83 ec 08             	sub    $0x8,%esp
  800e49:	56                   	push   %esi
  800e4a:	6a 00                	push   $0x0
  800e4c:	e8 8e f3 ff ff       	call   8001df <sys_page_unmap>
  800e51:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e54:	83 ec 08             	sub    $0x8,%esp
  800e57:	ff 75 f0             	pushl  -0x10(%ebp)
  800e5a:	6a 00                	push   $0x0
  800e5c:	e8 7e f3 ff ff       	call   8001df <sys_page_unmap>
  800e61:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e64:	83 ec 08             	sub    $0x8,%esp
  800e67:	ff 75 f4             	pushl  -0xc(%ebp)
  800e6a:	6a 00                	push   $0x0
  800e6c:	e8 6e f3 ff ff       	call   8001df <sys_page_unmap>
  800e71:	83 c4 10             	add    $0x10,%esp
  800e74:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e76:	89 d0                	mov    %edx,%eax
  800e78:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e7b:	5b                   	pop    %ebx
  800e7c:	5e                   	pop    %esi
  800e7d:	5d                   	pop    %ebp
  800e7e:	c3                   	ret    

00800e7f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e7f:	55                   	push   %ebp
  800e80:	89 e5                	mov    %esp,%ebp
  800e82:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e85:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e88:	50                   	push   %eax
  800e89:	ff 75 08             	pushl  0x8(%ebp)
  800e8c:	e8 30 f5 ff ff       	call   8003c1 <fd_lookup>
  800e91:	83 c4 10             	add    $0x10,%esp
  800e94:	85 c0                	test   %eax,%eax
  800e96:	78 18                	js     800eb0 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e98:	83 ec 0c             	sub    $0xc,%esp
  800e9b:	ff 75 f4             	pushl  -0xc(%ebp)
  800e9e:	e8 b8 f4 ff ff       	call   80035b <fd2data>
	return _pipeisclosed(fd, p);
  800ea3:	89 c2                	mov    %eax,%edx
  800ea5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ea8:	e8 21 fd ff ff       	call   800bce <_pipeisclosed>
  800ead:	83 c4 10             	add    $0x10,%esp
}
  800eb0:	c9                   	leave  
  800eb1:	c3                   	ret    

00800eb2 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800eb2:	55                   	push   %ebp
  800eb3:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800eb5:	b8 00 00 00 00       	mov    $0x0,%eax
  800eba:	5d                   	pop    %ebp
  800ebb:	c3                   	ret    

00800ebc <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ebc:	55                   	push   %ebp
  800ebd:	89 e5                	mov    %esp,%ebp
  800ebf:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ec2:	68 d6 1e 80 00       	push   $0x801ed6
  800ec7:	ff 75 0c             	pushl  0xc(%ebp)
  800eca:	e8 e2 07 00 00       	call   8016b1 <strcpy>
	return 0;
}
  800ecf:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed4:	c9                   	leave  
  800ed5:	c3                   	ret    

00800ed6 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800ed6:	55                   	push   %ebp
  800ed7:	89 e5                	mov    %esp,%ebp
  800ed9:	57                   	push   %edi
  800eda:	56                   	push   %esi
  800edb:	53                   	push   %ebx
  800edc:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ee2:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800ee7:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800eed:	eb 2d                	jmp    800f1c <devcons_write+0x46>
		m = n - tot;
  800eef:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ef2:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800ef4:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800ef7:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800efc:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800eff:	83 ec 04             	sub    $0x4,%esp
  800f02:	53                   	push   %ebx
  800f03:	03 45 0c             	add    0xc(%ebp),%eax
  800f06:	50                   	push   %eax
  800f07:	57                   	push   %edi
  800f08:	e8 36 09 00 00       	call   801843 <memmove>
		sys_cputs(buf, m);
  800f0d:	83 c4 08             	add    $0x8,%esp
  800f10:	53                   	push   %ebx
  800f11:	57                   	push   %edi
  800f12:	e8 87 f1 ff ff       	call   80009e <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f17:	01 de                	add    %ebx,%esi
  800f19:	83 c4 10             	add    $0x10,%esp
  800f1c:	89 f0                	mov    %esi,%eax
  800f1e:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f21:	72 cc                	jb     800eef <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f23:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f26:	5b                   	pop    %ebx
  800f27:	5e                   	pop    %esi
  800f28:	5f                   	pop    %edi
  800f29:	5d                   	pop    %ebp
  800f2a:	c3                   	ret    

00800f2b <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f2b:	55                   	push   %ebp
  800f2c:	89 e5                	mov    %esp,%ebp
  800f2e:	83 ec 08             	sub    $0x8,%esp
  800f31:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f36:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f3a:	74 2a                	je     800f66 <devcons_read+0x3b>
  800f3c:	eb 05                	jmp    800f43 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f3e:	e8 f8 f1 ff ff       	call   80013b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f43:	e8 74 f1 ff ff       	call   8000bc <sys_cgetc>
  800f48:	85 c0                	test   %eax,%eax
  800f4a:	74 f2                	je     800f3e <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f4c:	85 c0                	test   %eax,%eax
  800f4e:	78 16                	js     800f66 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f50:	83 f8 04             	cmp    $0x4,%eax
  800f53:	74 0c                	je     800f61 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f55:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f58:	88 02                	mov    %al,(%edx)
	return 1;
  800f5a:	b8 01 00 00 00       	mov    $0x1,%eax
  800f5f:	eb 05                	jmp    800f66 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f61:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f66:	c9                   	leave  
  800f67:	c3                   	ret    

00800f68 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f68:	55                   	push   %ebp
  800f69:	89 e5                	mov    %esp,%ebp
  800f6b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f71:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f74:	6a 01                	push   $0x1
  800f76:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f79:	50                   	push   %eax
  800f7a:	e8 1f f1 ff ff       	call   80009e <sys_cputs>
}
  800f7f:	83 c4 10             	add    $0x10,%esp
  800f82:	c9                   	leave  
  800f83:	c3                   	ret    

00800f84 <getchar>:

int
getchar(void)
{
  800f84:	55                   	push   %ebp
  800f85:	89 e5                	mov    %esp,%ebp
  800f87:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f8a:	6a 01                	push   $0x1
  800f8c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f8f:	50                   	push   %eax
  800f90:	6a 00                	push   $0x0
  800f92:	e8 90 f6 ff ff       	call   800627 <read>
	if (r < 0)
  800f97:	83 c4 10             	add    $0x10,%esp
  800f9a:	85 c0                	test   %eax,%eax
  800f9c:	78 0f                	js     800fad <getchar+0x29>
		return r;
	if (r < 1)
  800f9e:	85 c0                	test   %eax,%eax
  800fa0:	7e 06                	jle    800fa8 <getchar+0x24>
		return -E_EOF;
	return c;
  800fa2:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fa6:	eb 05                	jmp    800fad <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fa8:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fad:	c9                   	leave  
  800fae:	c3                   	ret    

00800faf <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800faf:	55                   	push   %ebp
  800fb0:	89 e5                	mov    %esp,%ebp
  800fb2:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fb5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fb8:	50                   	push   %eax
  800fb9:	ff 75 08             	pushl  0x8(%ebp)
  800fbc:	e8 00 f4 ff ff       	call   8003c1 <fd_lookup>
  800fc1:	83 c4 10             	add    $0x10,%esp
  800fc4:	85 c0                	test   %eax,%eax
  800fc6:	78 11                	js     800fd9 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800fc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fcb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fd1:	39 10                	cmp    %edx,(%eax)
  800fd3:	0f 94 c0             	sete   %al
  800fd6:	0f b6 c0             	movzbl %al,%eax
}
  800fd9:	c9                   	leave  
  800fda:	c3                   	ret    

00800fdb <opencons>:

int
opencons(void)
{
  800fdb:	55                   	push   %ebp
  800fdc:	89 e5                	mov    %esp,%ebp
  800fde:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fe1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fe4:	50                   	push   %eax
  800fe5:	e8 88 f3 ff ff       	call   800372 <fd_alloc>
  800fea:	83 c4 10             	add    $0x10,%esp
		return r;
  800fed:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fef:	85 c0                	test   %eax,%eax
  800ff1:	78 3e                	js     801031 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800ff3:	83 ec 04             	sub    $0x4,%esp
  800ff6:	68 07 04 00 00       	push   $0x407
  800ffb:	ff 75 f4             	pushl  -0xc(%ebp)
  800ffe:	6a 00                	push   $0x0
  801000:	e8 55 f1 ff ff       	call   80015a <sys_page_alloc>
  801005:	83 c4 10             	add    $0x10,%esp
		return r;
  801008:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80100a:	85 c0                	test   %eax,%eax
  80100c:	78 23                	js     801031 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80100e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801014:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801017:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801019:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80101c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801023:	83 ec 0c             	sub    $0xc,%esp
  801026:	50                   	push   %eax
  801027:	e8 1f f3 ff ff       	call   80034b <fd2num>
  80102c:	89 c2                	mov    %eax,%edx
  80102e:	83 c4 10             	add    $0x10,%esp
}
  801031:	89 d0                	mov    %edx,%eax
  801033:	c9                   	leave  
  801034:	c3                   	ret    

00801035 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801035:	55                   	push   %ebp
  801036:	89 e5                	mov    %esp,%ebp
  801038:	56                   	push   %esi
  801039:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80103a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80103d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801043:	e8 d4 f0 ff ff       	call   80011c <sys_getenvid>
  801048:	83 ec 0c             	sub    $0xc,%esp
  80104b:	ff 75 0c             	pushl  0xc(%ebp)
  80104e:	ff 75 08             	pushl  0x8(%ebp)
  801051:	56                   	push   %esi
  801052:	50                   	push   %eax
  801053:	68 e4 1e 80 00       	push   $0x801ee4
  801058:	e8 b1 00 00 00       	call   80110e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80105d:	83 c4 18             	add    $0x18,%esp
  801060:	53                   	push   %ebx
  801061:	ff 75 10             	pushl  0x10(%ebp)
  801064:	e8 54 00 00 00       	call   8010bd <vcprintf>
	cprintf("\n");
  801069:	c7 04 24 cf 1e 80 00 	movl   $0x801ecf,(%esp)
  801070:	e8 99 00 00 00       	call   80110e <cprintf>
  801075:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801078:	cc                   	int3   
  801079:	eb fd                	jmp    801078 <_panic+0x43>

0080107b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80107b:	55                   	push   %ebp
  80107c:	89 e5                	mov    %esp,%ebp
  80107e:	53                   	push   %ebx
  80107f:	83 ec 04             	sub    $0x4,%esp
  801082:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801085:	8b 13                	mov    (%ebx),%edx
  801087:	8d 42 01             	lea    0x1(%edx),%eax
  80108a:	89 03                	mov    %eax,(%ebx)
  80108c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80108f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801093:	3d ff 00 00 00       	cmp    $0xff,%eax
  801098:	75 1a                	jne    8010b4 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80109a:	83 ec 08             	sub    $0x8,%esp
  80109d:	68 ff 00 00 00       	push   $0xff
  8010a2:	8d 43 08             	lea    0x8(%ebx),%eax
  8010a5:	50                   	push   %eax
  8010a6:	e8 f3 ef ff ff       	call   80009e <sys_cputs>
		b->idx = 0;
  8010ab:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010b1:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010b4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010bb:	c9                   	leave  
  8010bc:	c3                   	ret    

008010bd <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010bd:	55                   	push   %ebp
  8010be:	89 e5                	mov    %esp,%ebp
  8010c0:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010c6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010cd:	00 00 00 
	b.cnt = 0;
  8010d0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010d7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010da:	ff 75 0c             	pushl  0xc(%ebp)
  8010dd:	ff 75 08             	pushl  0x8(%ebp)
  8010e0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010e6:	50                   	push   %eax
  8010e7:	68 7b 10 80 00       	push   $0x80107b
  8010ec:	e8 54 01 00 00       	call   801245 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010f1:	83 c4 08             	add    $0x8,%esp
  8010f4:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010fa:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801100:	50                   	push   %eax
  801101:	e8 98 ef ff ff       	call   80009e <sys_cputs>

	return b.cnt;
}
  801106:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80110c:	c9                   	leave  
  80110d:	c3                   	ret    

0080110e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80110e:	55                   	push   %ebp
  80110f:	89 e5                	mov    %esp,%ebp
  801111:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801114:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801117:	50                   	push   %eax
  801118:	ff 75 08             	pushl  0x8(%ebp)
  80111b:	e8 9d ff ff ff       	call   8010bd <vcprintf>
	va_end(ap);

	return cnt;
}
  801120:	c9                   	leave  
  801121:	c3                   	ret    

00801122 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801122:	55                   	push   %ebp
  801123:	89 e5                	mov    %esp,%ebp
  801125:	57                   	push   %edi
  801126:	56                   	push   %esi
  801127:	53                   	push   %ebx
  801128:	83 ec 1c             	sub    $0x1c,%esp
  80112b:	89 c7                	mov    %eax,%edi
  80112d:	89 d6                	mov    %edx,%esi
  80112f:	8b 45 08             	mov    0x8(%ebp),%eax
  801132:	8b 55 0c             	mov    0xc(%ebp),%edx
  801135:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801138:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80113b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80113e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801143:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801146:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801149:	39 d3                	cmp    %edx,%ebx
  80114b:	72 05                	jb     801152 <printnum+0x30>
  80114d:	39 45 10             	cmp    %eax,0x10(%ebp)
  801150:	77 45                	ja     801197 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801152:	83 ec 0c             	sub    $0xc,%esp
  801155:	ff 75 18             	pushl  0x18(%ebp)
  801158:	8b 45 14             	mov    0x14(%ebp),%eax
  80115b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80115e:	53                   	push   %ebx
  80115f:	ff 75 10             	pushl  0x10(%ebp)
  801162:	83 ec 08             	sub    $0x8,%esp
  801165:	ff 75 e4             	pushl  -0x1c(%ebp)
  801168:	ff 75 e0             	pushl  -0x20(%ebp)
  80116b:	ff 75 dc             	pushl  -0x24(%ebp)
  80116e:	ff 75 d8             	pushl  -0x28(%ebp)
  801171:	e8 aa 09 00 00       	call   801b20 <__udivdi3>
  801176:	83 c4 18             	add    $0x18,%esp
  801179:	52                   	push   %edx
  80117a:	50                   	push   %eax
  80117b:	89 f2                	mov    %esi,%edx
  80117d:	89 f8                	mov    %edi,%eax
  80117f:	e8 9e ff ff ff       	call   801122 <printnum>
  801184:	83 c4 20             	add    $0x20,%esp
  801187:	eb 18                	jmp    8011a1 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801189:	83 ec 08             	sub    $0x8,%esp
  80118c:	56                   	push   %esi
  80118d:	ff 75 18             	pushl  0x18(%ebp)
  801190:	ff d7                	call   *%edi
  801192:	83 c4 10             	add    $0x10,%esp
  801195:	eb 03                	jmp    80119a <printnum+0x78>
  801197:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80119a:	83 eb 01             	sub    $0x1,%ebx
  80119d:	85 db                	test   %ebx,%ebx
  80119f:	7f e8                	jg     801189 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011a1:	83 ec 08             	sub    $0x8,%esp
  8011a4:	56                   	push   %esi
  8011a5:	83 ec 04             	sub    $0x4,%esp
  8011a8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011ab:	ff 75 e0             	pushl  -0x20(%ebp)
  8011ae:	ff 75 dc             	pushl  -0x24(%ebp)
  8011b1:	ff 75 d8             	pushl  -0x28(%ebp)
  8011b4:	e8 97 0a 00 00       	call   801c50 <__umoddi3>
  8011b9:	83 c4 14             	add    $0x14,%esp
  8011bc:	0f be 80 07 1f 80 00 	movsbl 0x801f07(%eax),%eax
  8011c3:	50                   	push   %eax
  8011c4:	ff d7                	call   *%edi
}
  8011c6:	83 c4 10             	add    $0x10,%esp
  8011c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011cc:	5b                   	pop    %ebx
  8011cd:	5e                   	pop    %esi
  8011ce:	5f                   	pop    %edi
  8011cf:	5d                   	pop    %ebp
  8011d0:	c3                   	ret    

008011d1 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8011d1:	55                   	push   %ebp
  8011d2:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011d4:	83 fa 01             	cmp    $0x1,%edx
  8011d7:	7e 0e                	jle    8011e7 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8011d9:	8b 10                	mov    (%eax),%edx
  8011db:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011de:	89 08                	mov    %ecx,(%eax)
  8011e0:	8b 02                	mov    (%edx),%eax
  8011e2:	8b 52 04             	mov    0x4(%edx),%edx
  8011e5:	eb 22                	jmp    801209 <getuint+0x38>
	else if (lflag)
  8011e7:	85 d2                	test   %edx,%edx
  8011e9:	74 10                	je     8011fb <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8011eb:	8b 10                	mov    (%eax),%edx
  8011ed:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011f0:	89 08                	mov    %ecx,(%eax)
  8011f2:	8b 02                	mov    (%edx),%eax
  8011f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8011f9:	eb 0e                	jmp    801209 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8011fb:	8b 10                	mov    (%eax),%edx
  8011fd:	8d 4a 04             	lea    0x4(%edx),%ecx
  801200:	89 08                	mov    %ecx,(%eax)
  801202:	8b 02                	mov    (%edx),%eax
  801204:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801209:	5d                   	pop    %ebp
  80120a:	c3                   	ret    

0080120b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80120b:	55                   	push   %ebp
  80120c:	89 e5                	mov    %esp,%ebp
  80120e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801211:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801215:	8b 10                	mov    (%eax),%edx
  801217:	3b 50 04             	cmp    0x4(%eax),%edx
  80121a:	73 0a                	jae    801226 <sprintputch+0x1b>
		*b->buf++ = ch;
  80121c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80121f:	89 08                	mov    %ecx,(%eax)
  801221:	8b 45 08             	mov    0x8(%ebp),%eax
  801224:	88 02                	mov    %al,(%edx)
}
  801226:	5d                   	pop    %ebp
  801227:	c3                   	ret    

00801228 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801228:	55                   	push   %ebp
  801229:	89 e5                	mov    %esp,%ebp
  80122b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80122e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801231:	50                   	push   %eax
  801232:	ff 75 10             	pushl  0x10(%ebp)
  801235:	ff 75 0c             	pushl  0xc(%ebp)
  801238:	ff 75 08             	pushl  0x8(%ebp)
  80123b:	e8 05 00 00 00       	call   801245 <vprintfmt>
	va_end(ap);
}
  801240:	83 c4 10             	add    $0x10,%esp
  801243:	c9                   	leave  
  801244:	c3                   	ret    

00801245 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801245:	55                   	push   %ebp
  801246:	89 e5                	mov    %esp,%ebp
  801248:	57                   	push   %edi
  801249:	56                   	push   %esi
  80124a:	53                   	push   %ebx
  80124b:	83 ec 2c             	sub    $0x2c,%esp
  80124e:	8b 75 08             	mov    0x8(%ebp),%esi
  801251:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801254:	8b 7d 10             	mov    0x10(%ebp),%edi
  801257:	eb 12                	jmp    80126b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801259:	85 c0                	test   %eax,%eax
  80125b:	0f 84 a7 03 00 00    	je     801608 <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
  801261:	83 ec 08             	sub    $0x8,%esp
  801264:	53                   	push   %ebx
  801265:	50                   	push   %eax
  801266:	ff d6                	call   *%esi
  801268:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80126b:	83 c7 01             	add    $0x1,%edi
  80126e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801272:	83 f8 25             	cmp    $0x25,%eax
  801275:	75 e2                	jne    801259 <vprintfmt+0x14>
  801277:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80127b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801282:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  801289:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801290:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  801297:	b9 00 00 00 00       	mov    $0x0,%ecx
  80129c:	eb 07                	jmp    8012a5 <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80129e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8012a1:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012a5:	8d 47 01             	lea    0x1(%edi),%eax
  8012a8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012ab:	0f b6 07             	movzbl (%edi),%eax
  8012ae:	0f b6 d0             	movzbl %al,%edx
  8012b1:	83 e8 23             	sub    $0x23,%eax
  8012b4:	3c 55                	cmp    $0x55,%al
  8012b6:	0f 87 31 03 00 00    	ja     8015ed <vprintfmt+0x3a8>
  8012bc:	0f b6 c0             	movzbl %al,%eax
  8012bf:	ff 24 85 40 20 80 00 	jmp    *0x802040(,%eax,4)
  8012c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8012c9:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8012cd:	eb d6                	jmp    8012a5 <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8012d7:	89 75 08             	mov    %esi,0x8(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012da:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8012dd:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8012e1:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8012e4:	8d 72 d0             	lea    -0x30(%edx),%esi
  8012e7:	83 fe 09             	cmp    $0x9,%esi
  8012ea:	77 34                	ja     801320 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012ec:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8012ef:	eb e9                	jmp    8012da <vprintfmt+0x95>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8012f4:	8d 50 04             	lea    0x4(%eax),%edx
  8012f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8012fa:	8b 00                	mov    (%eax),%eax
  8012fc:	89 45 cc             	mov    %eax,-0x34(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801302:	eb 22                	jmp    801326 <vprintfmt+0xe1>
  801304:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801307:	85 c0                	test   %eax,%eax
  801309:	0f 48 c1             	cmovs  %ecx,%eax
  80130c:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80130f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801312:	eb 91                	jmp    8012a5 <vprintfmt+0x60>
  801314:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801317:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80131e:	eb 85                	jmp    8012a5 <vprintfmt+0x60>
  801320:	89 45 cc             	mov    %eax,-0x34(%ebp)
  801323:	8b 75 08             	mov    0x8(%ebp),%esi

		process_precision:
			if (width < 0)
  801326:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80132a:	0f 89 75 ff ff ff    	jns    8012a5 <vprintfmt+0x60>
				width = precision, precision = -1;
  801330:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801333:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801336:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80133d:	e9 63 ff ff ff       	jmp    8012a5 <vprintfmt+0x60>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801342:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801346:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801349:	e9 57 ff ff ff       	jmp    8012a5 <vprintfmt+0x60>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80134e:	8b 45 14             	mov    0x14(%ebp),%eax
  801351:	8d 50 04             	lea    0x4(%eax),%edx
  801354:	89 55 14             	mov    %edx,0x14(%ebp)
  801357:	83 ec 08             	sub    $0x8,%esp
  80135a:	53                   	push   %ebx
  80135b:	ff 30                	pushl  (%eax)
  80135d:	ff d6                	call   *%esi
			break;
  80135f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801362:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801365:	e9 01 ff ff ff       	jmp    80126b <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80136a:	8b 45 14             	mov    0x14(%ebp),%eax
  80136d:	8d 50 04             	lea    0x4(%eax),%edx
  801370:	89 55 14             	mov    %edx,0x14(%ebp)
  801373:	8b 00                	mov    (%eax),%eax
  801375:	99                   	cltd   
  801376:	31 d0                	xor    %edx,%eax
  801378:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80137a:	83 f8 0f             	cmp    $0xf,%eax
  80137d:	7f 0b                	jg     80138a <vprintfmt+0x145>
  80137f:	8b 14 85 a0 21 80 00 	mov    0x8021a0(,%eax,4),%edx
  801386:	85 d2                	test   %edx,%edx
  801388:	75 18                	jne    8013a2 <vprintfmt+0x15d>
				printfmt(putch, putdat, "error %d", err);
  80138a:	50                   	push   %eax
  80138b:	68 1f 1f 80 00       	push   $0x801f1f
  801390:	53                   	push   %ebx
  801391:	56                   	push   %esi
  801392:	e8 91 fe ff ff       	call   801228 <printfmt>
  801397:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80139a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80139d:	e9 c9 fe ff ff       	jmp    80126b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8013a2:	52                   	push   %edx
  8013a3:	68 9d 1e 80 00       	push   $0x801e9d
  8013a8:	53                   	push   %ebx
  8013a9:	56                   	push   %esi
  8013aa:	e8 79 fe ff ff       	call   801228 <printfmt>
  8013af:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013b5:	e9 b1 fe ff ff       	jmp    80126b <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8013bd:	8d 50 04             	lea    0x4(%eax),%edx
  8013c0:	89 55 14             	mov    %edx,0x14(%ebp)
  8013c3:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8013c5:	85 ff                	test   %edi,%edi
  8013c7:	b8 18 1f 80 00       	mov    $0x801f18,%eax
  8013cc:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8013cf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013d3:	0f 8e 94 00 00 00    	jle    80146d <vprintfmt+0x228>
  8013d9:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8013dd:	0f 84 98 00 00 00    	je     80147b <vprintfmt+0x236>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013e3:	83 ec 08             	sub    $0x8,%esp
  8013e6:	ff 75 cc             	pushl  -0x34(%ebp)
  8013e9:	57                   	push   %edi
  8013ea:	e8 a1 02 00 00       	call   801690 <strnlen>
  8013ef:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013f2:	29 c1                	sub    %eax,%ecx
  8013f4:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8013f7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8013fa:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8013fe:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801401:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801404:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801406:	eb 0f                	jmp    801417 <vprintfmt+0x1d2>
					putch(padc, putdat);
  801408:	83 ec 08             	sub    $0x8,%esp
  80140b:	53                   	push   %ebx
  80140c:	ff 75 e0             	pushl  -0x20(%ebp)
  80140f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801411:	83 ef 01             	sub    $0x1,%edi
  801414:	83 c4 10             	add    $0x10,%esp
  801417:	85 ff                	test   %edi,%edi
  801419:	7f ed                	jg     801408 <vprintfmt+0x1c3>
  80141b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80141e:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  801421:	85 c9                	test   %ecx,%ecx
  801423:	b8 00 00 00 00       	mov    $0x0,%eax
  801428:	0f 49 c1             	cmovns %ecx,%eax
  80142b:	29 c1                	sub    %eax,%ecx
  80142d:	89 75 08             	mov    %esi,0x8(%ebp)
  801430:	8b 75 cc             	mov    -0x34(%ebp),%esi
  801433:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801436:	89 cb                	mov    %ecx,%ebx
  801438:	eb 4d                	jmp    801487 <vprintfmt+0x242>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80143a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80143e:	74 1b                	je     80145b <vprintfmt+0x216>
  801440:	0f be c0             	movsbl %al,%eax
  801443:	83 e8 20             	sub    $0x20,%eax
  801446:	83 f8 5e             	cmp    $0x5e,%eax
  801449:	76 10                	jbe    80145b <vprintfmt+0x216>
					putch('?', putdat);
  80144b:	83 ec 08             	sub    $0x8,%esp
  80144e:	ff 75 0c             	pushl  0xc(%ebp)
  801451:	6a 3f                	push   $0x3f
  801453:	ff 55 08             	call   *0x8(%ebp)
  801456:	83 c4 10             	add    $0x10,%esp
  801459:	eb 0d                	jmp    801468 <vprintfmt+0x223>
				else
					putch(ch, putdat);
  80145b:	83 ec 08             	sub    $0x8,%esp
  80145e:	ff 75 0c             	pushl  0xc(%ebp)
  801461:	52                   	push   %edx
  801462:	ff 55 08             	call   *0x8(%ebp)
  801465:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801468:	83 eb 01             	sub    $0x1,%ebx
  80146b:	eb 1a                	jmp    801487 <vprintfmt+0x242>
  80146d:	89 75 08             	mov    %esi,0x8(%ebp)
  801470:	8b 75 cc             	mov    -0x34(%ebp),%esi
  801473:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801476:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801479:	eb 0c                	jmp    801487 <vprintfmt+0x242>
  80147b:	89 75 08             	mov    %esi,0x8(%ebp)
  80147e:	8b 75 cc             	mov    -0x34(%ebp),%esi
  801481:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801484:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801487:	83 c7 01             	add    $0x1,%edi
  80148a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80148e:	0f be d0             	movsbl %al,%edx
  801491:	85 d2                	test   %edx,%edx
  801493:	74 23                	je     8014b8 <vprintfmt+0x273>
  801495:	85 f6                	test   %esi,%esi
  801497:	78 a1                	js     80143a <vprintfmt+0x1f5>
  801499:	83 ee 01             	sub    $0x1,%esi
  80149c:	79 9c                	jns    80143a <vprintfmt+0x1f5>
  80149e:	89 df                	mov    %ebx,%edi
  8014a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8014a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014a6:	eb 18                	jmp    8014c0 <vprintfmt+0x27b>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014a8:	83 ec 08             	sub    $0x8,%esp
  8014ab:	53                   	push   %ebx
  8014ac:	6a 20                	push   $0x20
  8014ae:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014b0:	83 ef 01             	sub    $0x1,%edi
  8014b3:	83 c4 10             	add    $0x10,%esp
  8014b6:	eb 08                	jmp    8014c0 <vprintfmt+0x27b>
  8014b8:	89 df                	mov    %ebx,%edi
  8014ba:	8b 75 08             	mov    0x8(%ebp),%esi
  8014bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014c0:	85 ff                	test   %edi,%edi
  8014c2:	7f e4                	jg     8014a8 <vprintfmt+0x263>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014c7:	e9 9f fd ff ff       	jmp    80126b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014cc:	83 7d d0 01          	cmpl   $0x1,-0x30(%ebp)
  8014d0:	7e 16                	jle    8014e8 <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  8014d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8014d5:	8d 50 08             	lea    0x8(%eax),%edx
  8014d8:	89 55 14             	mov    %edx,0x14(%ebp)
  8014db:	8b 50 04             	mov    0x4(%eax),%edx
  8014de:	8b 00                	mov    (%eax),%eax
  8014e0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014e3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8014e6:	eb 34                	jmp    80151c <vprintfmt+0x2d7>
	else if (lflag)
  8014e8:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8014ec:	74 18                	je     801506 <vprintfmt+0x2c1>
		return va_arg(*ap, long);
  8014ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8014f1:	8d 50 04             	lea    0x4(%eax),%edx
  8014f4:	89 55 14             	mov    %edx,0x14(%ebp)
  8014f7:	8b 00                	mov    (%eax),%eax
  8014f9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014fc:	89 c1                	mov    %eax,%ecx
  8014fe:	c1 f9 1f             	sar    $0x1f,%ecx
  801501:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801504:	eb 16                	jmp    80151c <vprintfmt+0x2d7>
	else
		return va_arg(*ap, int);
  801506:	8b 45 14             	mov    0x14(%ebp),%eax
  801509:	8d 50 04             	lea    0x4(%eax),%edx
  80150c:	89 55 14             	mov    %edx,0x14(%ebp)
  80150f:	8b 00                	mov    (%eax),%eax
  801511:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801514:	89 c1                	mov    %eax,%ecx
  801516:	c1 f9 1f             	sar    $0x1f,%ecx
  801519:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80151c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80151f:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801522:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801527:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80152b:	0f 89 88 00 00 00    	jns    8015b9 <vprintfmt+0x374>
				putch('-', putdat);
  801531:	83 ec 08             	sub    $0x8,%esp
  801534:	53                   	push   %ebx
  801535:	6a 2d                	push   $0x2d
  801537:	ff d6                	call   *%esi
				num = -(long long) num;
  801539:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80153c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80153f:	f7 d8                	neg    %eax
  801541:	83 d2 00             	adc    $0x0,%edx
  801544:	f7 da                	neg    %edx
  801546:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801549:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80154e:	eb 69                	jmp    8015b9 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801550:	8b 55 d0             	mov    -0x30(%ebp),%edx
  801553:	8d 45 14             	lea    0x14(%ebp),%eax
  801556:	e8 76 fc ff ff       	call   8011d1 <getuint>
			base = 10;
  80155b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801560:	eb 57                	jmp    8015b9 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  801562:	83 ec 08             	sub    $0x8,%esp
  801565:	53                   	push   %ebx
  801566:	6a 30                	push   $0x30
  801568:	ff d6                	call   *%esi
			num = getuint(&ap, lflag);
  80156a:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80156d:	8d 45 14             	lea    0x14(%ebp),%eax
  801570:	e8 5c fc ff ff       	call   8011d1 <getuint>
			base = 8;
			goto number;
  801575:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  801578:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80157d:	eb 3a                	jmp    8015b9 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  80157f:	83 ec 08             	sub    $0x8,%esp
  801582:	53                   	push   %ebx
  801583:	6a 30                	push   $0x30
  801585:	ff d6                	call   *%esi
			putch('x', putdat);
  801587:	83 c4 08             	add    $0x8,%esp
  80158a:	53                   	push   %ebx
  80158b:	6a 78                	push   $0x78
  80158d:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80158f:	8b 45 14             	mov    0x14(%ebp),%eax
  801592:	8d 50 04             	lea    0x4(%eax),%edx
  801595:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801598:	8b 00                	mov    (%eax),%eax
  80159a:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80159f:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8015a2:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8015a7:	eb 10                	jmp    8015b9 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8015a9:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8015ac:	8d 45 14             	lea    0x14(%ebp),%eax
  8015af:	e8 1d fc ff ff       	call   8011d1 <getuint>
			base = 16;
  8015b4:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8015b9:	83 ec 0c             	sub    $0xc,%esp
  8015bc:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015c0:	57                   	push   %edi
  8015c1:	ff 75 e0             	pushl  -0x20(%ebp)
  8015c4:	51                   	push   %ecx
  8015c5:	52                   	push   %edx
  8015c6:	50                   	push   %eax
  8015c7:	89 da                	mov    %ebx,%edx
  8015c9:	89 f0                	mov    %esi,%eax
  8015cb:	e8 52 fb ff ff       	call   801122 <printnum>
			break;
  8015d0:	83 c4 20             	add    $0x20,%esp
  8015d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015d6:	e9 90 fc ff ff       	jmp    80126b <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8015db:	83 ec 08             	sub    $0x8,%esp
  8015de:	53                   	push   %ebx
  8015df:	52                   	push   %edx
  8015e0:	ff d6                	call   *%esi
			break;
  8015e2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8015e8:	e9 7e fc ff ff       	jmp    80126b <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8015ed:	83 ec 08             	sub    $0x8,%esp
  8015f0:	53                   	push   %ebx
  8015f1:	6a 25                	push   $0x25
  8015f3:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015f5:	83 c4 10             	add    $0x10,%esp
  8015f8:	eb 03                	jmp    8015fd <vprintfmt+0x3b8>
  8015fa:	83 ef 01             	sub    $0x1,%edi
  8015fd:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801601:	75 f7                	jne    8015fa <vprintfmt+0x3b5>
  801603:	e9 63 fc ff ff       	jmp    80126b <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801608:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80160b:	5b                   	pop    %ebx
  80160c:	5e                   	pop    %esi
  80160d:	5f                   	pop    %edi
  80160e:	5d                   	pop    %ebp
  80160f:	c3                   	ret    

00801610 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801610:	55                   	push   %ebp
  801611:	89 e5                	mov    %esp,%ebp
  801613:	83 ec 18             	sub    $0x18,%esp
  801616:	8b 45 08             	mov    0x8(%ebp),%eax
  801619:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80161c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80161f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801623:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801626:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80162d:	85 c0                	test   %eax,%eax
  80162f:	74 26                	je     801657 <vsnprintf+0x47>
  801631:	85 d2                	test   %edx,%edx
  801633:	7e 22                	jle    801657 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801635:	ff 75 14             	pushl  0x14(%ebp)
  801638:	ff 75 10             	pushl  0x10(%ebp)
  80163b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80163e:	50                   	push   %eax
  80163f:	68 0b 12 80 00       	push   $0x80120b
  801644:	e8 fc fb ff ff       	call   801245 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801649:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80164c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80164f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801652:	83 c4 10             	add    $0x10,%esp
  801655:	eb 05                	jmp    80165c <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801657:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80165c:	c9                   	leave  
  80165d:	c3                   	ret    

0080165e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80165e:	55                   	push   %ebp
  80165f:	89 e5                	mov    %esp,%ebp
  801661:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801664:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801667:	50                   	push   %eax
  801668:	ff 75 10             	pushl  0x10(%ebp)
  80166b:	ff 75 0c             	pushl  0xc(%ebp)
  80166e:	ff 75 08             	pushl  0x8(%ebp)
  801671:	e8 9a ff ff ff       	call   801610 <vsnprintf>
	va_end(ap);

	return rc;
}
  801676:	c9                   	leave  
  801677:	c3                   	ret    

00801678 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801678:	55                   	push   %ebp
  801679:	89 e5                	mov    %esp,%ebp
  80167b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80167e:	b8 00 00 00 00       	mov    $0x0,%eax
  801683:	eb 03                	jmp    801688 <strlen+0x10>
		n++;
  801685:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801688:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80168c:	75 f7                	jne    801685 <strlen+0xd>
		n++;
	return n;
}
  80168e:	5d                   	pop    %ebp
  80168f:	c3                   	ret    

00801690 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801690:	55                   	push   %ebp
  801691:	89 e5                	mov    %esp,%ebp
  801693:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801696:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801699:	ba 00 00 00 00       	mov    $0x0,%edx
  80169e:	eb 03                	jmp    8016a3 <strnlen+0x13>
		n++;
  8016a0:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016a3:	39 c2                	cmp    %eax,%edx
  8016a5:	74 08                	je     8016af <strnlen+0x1f>
  8016a7:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8016ab:	75 f3                	jne    8016a0 <strnlen+0x10>
  8016ad:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8016af:	5d                   	pop    %ebp
  8016b0:	c3                   	ret    

008016b1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016b1:	55                   	push   %ebp
  8016b2:	89 e5                	mov    %esp,%ebp
  8016b4:	53                   	push   %ebx
  8016b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016bb:	89 c2                	mov    %eax,%edx
  8016bd:	83 c2 01             	add    $0x1,%edx
  8016c0:	83 c1 01             	add    $0x1,%ecx
  8016c3:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8016c7:	88 5a ff             	mov    %bl,-0x1(%edx)
  8016ca:	84 db                	test   %bl,%bl
  8016cc:	75 ef                	jne    8016bd <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8016ce:	5b                   	pop    %ebx
  8016cf:	5d                   	pop    %ebp
  8016d0:	c3                   	ret    

008016d1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016d1:	55                   	push   %ebp
  8016d2:	89 e5                	mov    %esp,%ebp
  8016d4:	53                   	push   %ebx
  8016d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016d8:	53                   	push   %ebx
  8016d9:	e8 9a ff ff ff       	call   801678 <strlen>
  8016de:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8016e1:	ff 75 0c             	pushl  0xc(%ebp)
  8016e4:	01 d8                	add    %ebx,%eax
  8016e6:	50                   	push   %eax
  8016e7:	e8 c5 ff ff ff       	call   8016b1 <strcpy>
	return dst;
}
  8016ec:	89 d8                	mov    %ebx,%eax
  8016ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016f1:	c9                   	leave  
  8016f2:	c3                   	ret    

008016f3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016f3:	55                   	push   %ebp
  8016f4:	89 e5                	mov    %esp,%ebp
  8016f6:	56                   	push   %esi
  8016f7:	53                   	push   %ebx
  8016f8:	8b 75 08             	mov    0x8(%ebp),%esi
  8016fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016fe:	89 f3                	mov    %esi,%ebx
  801700:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801703:	89 f2                	mov    %esi,%edx
  801705:	eb 0f                	jmp    801716 <strncpy+0x23>
		*dst++ = *src;
  801707:	83 c2 01             	add    $0x1,%edx
  80170a:	0f b6 01             	movzbl (%ecx),%eax
  80170d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801710:	80 39 01             	cmpb   $0x1,(%ecx)
  801713:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801716:	39 da                	cmp    %ebx,%edx
  801718:	75 ed                	jne    801707 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80171a:	89 f0                	mov    %esi,%eax
  80171c:	5b                   	pop    %ebx
  80171d:	5e                   	pop    %esi
  80171e:	5d                   	pop    %ebp
  80171f:	c3                   	ret    

00801720 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801720:	55                   	push   %ebp
  801721:	89 e5                	mov    %esp,%ebp
  801723:	56                   	push   %esi
  801724:	53                   	push   %ebx
  801725:	8b 75 08             	mov    0x8(%ebp),%esi
  801728:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80172b:	8b 55 10             	mov    0x10(%ebp),%edx
  80172e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801730:	85 d2                	test   %edx,%edx
  801732:	74 21                	je     801755 <strlcpy+0x35>
  801734:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801738:	89 f2                	mov    %esi,%edx
  80173a:	eb 09                	jmp    801745 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80173c:	83 c2 01             	add    $0x1,%edx
  80173f:	83 c1 01             	add    $0x1,%ecx
  801742:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801745:	39 c2                	cmp    %eax,%edx
  801747:	74 09                	je     801752 <strlcpy+0x32>
  801749:	0f b6 19             	movzbl (%ecx),%ebx
  80174c:	84 db                	test   %bl,%bl
  80174e:	75 ec                	jne    80173c <strlcpy+0x1c>
  801750:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801752:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801755:	29 f0                	sub    %esi,%eax
}
  801757:	5b                   	pop    %ebx
  801758:	5e                   	pop    %esi
  801759:	5d                   	pop    %ebp
  80175a:	c3                   	ret    

0080175b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80175b:	55                   	push   %ebp
  80175c:	89 e5                	mov    %esp,%ebp
  80175e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801761:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801764:	eb 06                	jmp    80176c <strcmp+0x11>
		p++, q++;
  801766:	83 c1 01             	add    $0x1,%ecx
  801769:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80176c:	0f b6 01             	movzbl (%ecx),%eax
  80176f:	84 c0                	test   %al,%al
  801771:	74 04                	je     801777 <strcmp+0x1c>
  801773:	3a 02                	cmp    (%edx),%al
  801775:	74 ef                	je     801766 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801777:	0f b6 c0             	movzbl %al,%eax
  80177a:	0f b6 12             	movzbl (%edx),%edx
  80177d:	29 d0                	sub    %edx,%eax
}
  80177f:	5d                   	pop    %ebp
  801780:	c3                   	ret    

00801781 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801781:	55                   	push   %ebp
  801782:	89 e5                	mov    %esp,%ebp
  801784:	53                   	push   %ebx
  801785:	8b 45 08             	mov    0x8(%ebp),%eax
  801788:	8b 55 0c             	mov    0xc(%ebp),%edx
  80178b:	89 c3                	mov    %eax,%ebx
  80178d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801790:	eb 06                	jmp    801798 <strncmp+0x17>
		n--, p++, q++;
  801792:	83 c0 01             	add    $0x1,%eax
  801795:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801798:	39 d8                	cmp    %ebx,%eax
  80179a:	74 15                	je     8017b1 <strncmp+0x30>
  80179c:	0f b6 08             	movzbl (%eax),%ecx
  80179f:	84 c9                	test   %cl,%cl
  8017a1:	74 04                	je     8017a7 <strncmp+0x26>
  8017a3:	3a 0a                	cmp    (%edx),%cl
  8017a5:	74 eb                	je     801792 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017a7:	0f b6 00             	movzbl (%eax),%eax
  8017aa:	0f b6 12             	movzbl (%edx),%edx
  8017ad:	29 d0                	sub    %edx,%eax
  8017af:	eb 05                	jmp    8017b6 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017b1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8017b6:	5b                   	pop    %ebx
  8017b7:	5d                   	pop    %ebp
  8017b8:	c3                   	ret    

008017b9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017b9:	55                   	push   %ebp
  8017ba:	89 e5                	mov    %esp,%ebp
  8017bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8017bf:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017c3:	eb 07                	jmp    8017cc <strchr+0x13>
		if (*s == c)
  8017c5:	38 ca                	cmp    %cl,%dl
  8017c7:	74 0f                	je     8017d8 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017c9:	83 c0 01             	add    $0x1,%eax
  8017cc:	0f b6 10             	movzbl (%eax),%edx
  8017cf:	84 d2                	test   %dl,%dl
  8017d1:	75 f2                	jne    8017c5 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8017d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017d8:	5d                   	pop    %ebp
  8017d9:	c3                   	ret    

008017da <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017da:	55                   	push   %ebp
  8017db:	89 e5                	mov    %esp,%ebp
  8017dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017e4:	eb 03                	jmp    8017e9 <strfind+0xf>
  8017e6:	83 c0 01             	add    $0x1,%eax
  8017e9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8017ec:	38 ca                	cmp    %cl,%dl
  8017ee:	74 04                	je     8017f4 <strfind+0x1a>
  8017f0:	84 d2                	test   %dl,%dl
  8017f2:	75 f2                	jne    8017e6 <strfind+0xc>
			break;
	return (char *) s;
}
  8017f4:	5d                   	pop    %ebp
  8017f5:	c3                   	ret    

008017f6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8017f6:	55                   	push   %ebp
  8017f7:	89 e5                	mov    %esp,%ebp
  8017f9:	57                   	push   %edi
  8017fa:	56                   	push   %esi
  8017fb:	53                   	push   %ebx
  8017fc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017ff:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801802:	85 c9                	test   %ecx,%ecx
  801804:	74 36                	je     80183c <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801806:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80180c:	75 28                	jne    801836 <memset+0x40>
  80180e:	f6 c1 03             	test   $0x3,%cl
  801811:	75 23                	jne    801836 <memset+0x40>
		c &= 0xFF;
  801813:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801817:	89 d3                	mov    %edx,%ebx
  801819:	c1 e3 08             	shl    $0x8,%ebx
  80181c:	89 d6                	mov    %edx,%esi
  80181e:	c1 e6 18             	shl    $0x18,%esi
  801821:	89 d0                	mov    %edx,%eax
  801823:	c1 e0 10             	shl    $0x10,%eax
  801826:	09 f0                	or     %esi,%eax
  801828:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80182a:	89 d8                	mov    %ebx,%eax
  80182c:	09 d0                	or     %edx,%eax
  80182e:	c1 e9 02             	shr    $0x2,%ecx
  801831:	fc                   	cld    
  801832:	f3 ab                	rep stos %eax,%es:(%edi)
  801834:	eb 06                	jmp    80183c <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801836:	8b 45 0c             	mov    0xc(%ebp),%eax
  801839:	fc                   	cld    
  80183a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80183c:	89 f8                	mov    %edi,%eax
  80183e:	5b                   	pop    %ebx
  80183f:	5e                   	pop    %esi
  801840:	5f                   	pop    %edi
  801841:	5d                   	pop    %ebp
  801842:	c3                   	ret    

00801843 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801843:	55                   	push   %ebp
  801844:	89 e5                	mov    %esp,%ebp
  801846:	57                   	push   %edi
  801847:	56                   	push   %esi
  801848:	8b 45 08             	mov    0x8(%ebp),%eax
  80184b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80184e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801851:	39 c6                	cmp    %eax,%esi
  801853:	73 35                	jae    80188a <memmove+0x47>
  801855:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801858:	39 d0                	cmp    %edx,%eax
  80185a:	73 2e                	jae    80188a <memmove+0x47>
		s += n;
		d += n;
  80185c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80185f:	89 d6                	mov    %edx,%esi
  801861:	09 fe                	or     %edi,%esi
  801863:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801869:	75 13                	jne    80187e <memmove+0x3b>
  80186b:	f6 c1 03             	test   $0x3,%cl
  80186e:	75 0e                	jne    80187e <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801870:	83 ef 04             	sub    $0x4,%edi
  801873:	8d 72 fc             	lea    -0x4(%edx),%esi
  801876:	c1 e9 02             	shr    $0x2,%ecx
  801879:	fd                   	std    
  80187a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80187c:	eb 09                	jmp    801887 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80187e:	83 ef 01             	sub    $0x1,%edi
  801881:	8d 72 ff             	lea    -0x1(%edx),%esi
  801884:	fd                   	std    
  801885:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801887:	fc                   	cld    
  801888:	eb 1d                	jmp    8018a7 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80188a:	89 f2                	mov    %esi,%edx
  80188c:	09 c2                	or     %eax,%edx
  80188e:	f6 c2 03             	test   $0x3,%dl
  801891:	75 0f                	jne    8018a2 <memmove+0x5f>
  801893:	f6 c1 03             	test   $0x3,%cl
  801896:	75 0a                	jne    8018a2 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801898:	c1 e9 02             	shr    $0x2,%ecx
  80189b:	89 c7                	mov    %eax,%edi
  80189d:	fc                   	cld    
  80189e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018a0:	eb 05                	jmp    8018a7 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018a2:	89 c7                	mov    %eax,%edi
  8018a4:	fc                   	cld    
  8018a5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018a7:	5e                   	pop    %esi
  8018a8:	5f                   	pop    %edi
  8018a9:	5d                   	pop    %ebp
  8018aa:	c3                   	ret    

008018ab <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018ab:	55                   	push   %ebp
  8018ac:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018ae:	ff 75 10             	pushl  0x10(%ebp)
  8018b1:	ff 75 0c             	pushl  0xc(%ebp)
  8018b4:	ff 75 08             	pushl  0x8(%ebp)
  8018b7:	e8 87 ff ff ff       	call   801843 <memmove>
}
  8018bc:	c9                   	leave  
  8018bd:	c3                   	ret    

008018be <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018be:	55                   	push   %ebp
  8018bf:	89 e5                	mov    %esp,%ebp
  8018c1:	56                   	push   %esi
  8018c2:	53                   	push   %ebx
  8018c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018c9:	89 c6                	mov    %eax,%esi
  8018cb:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018ce:	eb 1a                	jmp    8018ea <memcmp+0x2c>
		if (*s1 != *s2)
  8018d0:	0f b6 08             	movzbl (%eax),%ecx
  8018d3:	0f b6 1a             	movzbl (%edx),%ebx
  8018d6:	38 d9                	cmp    %bl,%cl
  8018d8:	74 0a                	je     8018e4 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8018da:	0f b6 c1             	movzbl %cl,%eax
  8018dd:	0f b6 db             	movzbl %bl,%ebx
  8018e0:	29 d8                	sub    %ebx,%eax
  8018e2:	eb 0f                	jmp    8018f3 <memcmp+0x35>
		s1++, s2++;
  8018e4:	83 c0 01             	add    $0x1,%eax
  8018e7:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018ea:	39 f0                	cmp    %esi,%eax
  8018ec:	75 e2                	jne    8018d0 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8018ee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018f3:	5b                   	pop    %ebx
  8018f4:	5e                   	pop    %esi
  8018f5:	5d                   	pop    %ebp
  8018f6:	c3                   	ret    

008018f7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8018f7:	55                   	push   %ebp
  8018f8:	89 e5                	mov    %esp,%ebp
  8018fa:	53                   	push   %ebx
  8018fb:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8018fe:	89 c1                	mov    %eax,%ecx
  801900:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801903:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801907:	eb 0a                	jmp    801913 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801909:	0f b6 10             	movzbl (%eax),%edx
  80190c:	39 da                	cmp    %ebx,%edx
  80190e:	74 07                	je     801917 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801910:	83 c0 01             	add    $0x1,%eax
  801913:	39 c8                	cmp    %ecx,%eax
  801915:	72 f2                	jb     801909 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801917:	5b                   	pop    %ebx
  801918:	5d                   	pop    %ebp
  801919:	c3                   	ret    

0080191a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80191a:	55                   	push   %ebp
  80191b:	89 e5                	mov    %esp,%ebp
  80191d:	57                   	push   %edi
  80191e:	56                   	push   %esi
  80191f:	53                   	push   %ebx
  801920:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801923:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801926:	eb 03                	jmp    80192b <strtol+0x11>
		s++;
  801928:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80192b:	0f b6 01             	movzbl (%ecx),%eax
  80192e:	3c 20                	cmp    $0x20,%al
  801930:	74 f6                	je     801928 <strtol+0xe>
  801932:	3c 09                	cmp    $0x9,%al
  801934:	74 f2                	je     801928 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801936:	3c 2b                	cmp    $0x2b,%al
  801938:	75 0a                	jne    801944 <strtol+0x2a>
		s++;
  80193a:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80193d:	bf 00 00 00 00       	mov    $0x0,%edi
  801942:	eb 11                	jmp    801955 <strtol+0x3b>
  801944:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801949:	3c 2d                	cmp    $0x2d,%al
  80194b:	75 08                	jne    801955 <strtol+0x3b>
		s++, neg = 1;
  80194d:	83 c1 01             	add    $0x1,%ecx
  801950:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801955:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80195b:	75 15                	jne    801972 <strtol+0x58>
  80195d:	80 39 30             	cmpb   $0x30,(%ecx)
  801960:	75 10                	jne    801972 <strtol+0x58>
  801962:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801966:	75 7c                	jne    8019e4 <strtol+0xca>
		s += 2, base = 16;
  801968:	83 c1 02             	add    $0x2,%ecx
  80196b:	bb 10 00 00 00       	mov    $0x10,%ebx
  801970:	eb 16                	jmp    801988 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801972:	85 db                	test   %ebx,%ebx
  801974:	75 12                	jne    801988 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801976:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80197b:	80 39 30             	cmpb   $0x30,(%ecx)
  80197e:	75 08                	jne    801988 <strtol+0x6e>
		s++, base = 8;
  801980:	83 c1 01             	add    $0x1,%ecx
  801983:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801988:	b8 00 00 00 00       	mov    $0x0,%eax
  80198d:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801990:	0f b6 11             	movzbl (%ecx),%edx
  801993:	8d 72 d0             	lea    -0x30(%edx),%esi
  801996:	89 f3                	mov    %esi,%ebx
  801998:	80 fb 09             	cmp    $0x9,%bl
  80199b:	77 08                	ja     8019a5 <strtol+0x8b>
			dig = *s - '0';
  80199d:	0f be d2             	movsbl %dl,%edx
  8019a0:	83 ea 30             	sub    $0x30,%edx
  8019a3:	eb 22                	jmp    8019c7 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8019a5:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019a8:	89 f3                	mov    %esi,%ebx
  8019aa:	80 fb 19             	cmp    $0x19,%bl
  8019ad:	77 08                	ja     8019b7 <strtol+0x9d>
			dig = *s - 'a' + 10;
  8019af:	0f be d2             	movsbl %dl,%edx
  8019b2:	83 ea 57             	sub    $0x57,%edx
  8019b5:	eb 10                	jmp    8019c7 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8019b7:	8d 72 bf             	lea    -0x41(%edx),%esi
  8019ba:	89 f3                	mov    %esi,%ebx
  8019bc:	80 fb 19             	cmp    $0x19,%bl
  8019bf:	77 16                	ja     8019d7 <strtol+0xbd>
			dig = *s - 'A' + 10;
  8019c1:	0f be d2             	movsbl %dl,%edx
  8019c4:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8019c7:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019ca:	7d 0b                	jge    8019d7 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8019cc:	83 c1 01             	add    $0x1,%ecx
  8019cf:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019d3:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8019d5:	eb b9                	jmp    801990 <strtol+0x76>

	if (endptr)
  8019d7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019db:	74 0d                	je     8019ea <strtol+0xd0>
		*endptr = (char *) s;
  8019dd:	8b 75 0c             	mov    0xc(%ebp),%esi
  8019e0:	89 0e                	mov    %ecx,(%esi)
  8019e2:	eb 06                	jmp    8019ea <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019e4:	85 db                	test   %ebx,%ebx
  8019e6:	74 98                	je     801980 <strtol+0x66>
  8019e8:	eb 9e                	jmp    801988 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8019ea:	89 c2                	mov    %eax,%edx
  8019ec:	f7 da                	neg    %edx
  8019ee:	85 ff                	test   %edi,%edi
  8019f0:	0f 45 c2             	cmovne %edx,%eax
}
  8019f3:	5b                   	pop    %ebx
  8019f4:	5e                   	pop    %esi
  8019f5:	5f                   	pop    %edi
  8019f6:	5d                   	pop    %ebp
  8019f7:	c3                   	ret    

008019f8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019f8:	55                   	push   %ebp
  8019f9:	89 e5                	mov    %esp,%ebp
  8019fb:	56                   	push   %esi
  8019fc:	53                   	push   %ebx
  8019fd:	8b 75 08             	mov    0x8(%ebp),%esi
  801a00:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a03:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_recv not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  801a06:	85 c0                	test   %eax,%eax
  801a08:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a0d:	0f 44 c2             	cmove  %edx,%eax

    int r = sys_ipc_recv(pg);
  801a10:	83 ec 0c             	sub    $0xc,%esp
  801a13:	50                   	push   %eax
  801a14:	e8 f1 e8 ff ff       	call   80030a <sys_ipc_recv>
    int from_env = 0, perm = 0;
    if (r == 0) {
  801a19:	83 c4 10             	add    $0x10,%esp
  801a1c:	85 c0                	test   %eax,%eax
  801a1e:	75 10                	jne    801a30 <ipc_recv+0x38>
        from_env = thisenv->env_ipc_from;
  801a20:	a1 04 40 80 00       	mov    0x804004,%eax
  801a25:	8b 48 74             	mov    0x74(%eax),%ecx
        perm = thisenv->env_ipc_perm;
  801a28:	8b 50 78             	mov    0x78(%eax),%edx
        r = thisenv->env_ipc_value;
  801a2b:	8b 40 70             	mov    0x70(%eax),%eax
  801a2e:	eb 0a                	jmp    801a3a <ipc_recv+0x42>
    } else {
        from_env = 0;
        perm = 0;
  801a30:	ba 00 00 00 00       	mov    $0x0,%edx
    if (r == 0) {
        from_env = thisenv->env_ipc_from;
        perm = thisenv->env_ipc_perm;
        r = thisenv->env_ipc_value;
    } else {
        from_env = 0;
  801a35:	b9 00 00 00 00       	mov    $0x0,%ecx
        perm = 0;
    }

    if (from_env_store) *from_env_store = from_env;
  801a3a:	85 f6                	test   %esi,%esi
  801a3c:	74 02                	je     801a40 <ipc_recv+0x48>
  801a3e:	89 0e                	mov    %ecx,(%esi)
    if (perm_store) *perm_store = perm;
  801a40:	85 db                	test   %ebx,%ebx
  801a42:	74 02                	je     801a46 <ipc_recv+0x4e>
  801a44:	89 13                	mov    %edx,(%ebx)

    return r;
}
  801a46:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a49:	5b                   	pop    %ebx
  801a4a:	5e                   	pop    %esi
  801a4b:	5d                   	pop    %ebp
  801a4c:	c3                   	ret    

00801a4d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a4d:	55                   	push   %ebp
  801a4e:	89 e5                	mov    %esp,%ebp
  801a50:	57                   	push   %edi
  801a51:	56                   	push   %esi
  801a52:	53                   	push   %ebx
  801a53:	83 ec 0c             	sub    $0xc,%esp
  801a56:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a59:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a5c:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  801a5f:	85 db                	test   %ebx,%ebx
  801a61:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801a66:	0f 44 d8             	cmove  %eax,%ebx
  801a69:	eb 1c                	jmp    801a87 <ipc_send+0x3a>

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        if (ret != -E_IPC_NOT_RECV)
  801a6b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a6e:	74 12                	je     801a82 <ipc_send+0x35>
            panic("ipc_send error %e", ret);
  801a70:	50                   	push   %eax
  801a71:	68 00 22 80 00       	push   $0x802200
  801a76:	6a 40                	push   $0x40
  801a78:	68 12 22 80 00       	push   $0x802212
  801a7d:	e8 b3 f5 ff ff       	call   801035 <_panic>
        sys_yield();
  801a82:	e8 b4 e6 ff ff       	call   80013b <sys_yield>
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801a87:	ff 75 14             	pushl  0x14(%ebp)
  801a8a:	53                   	push   %ebx
  801a8b:	56                   	push   %esi
  801a8c:	57                   	push   %edi
  801a8d:	e8 55 e8 ff ff       	call   8002e7 <sys_ipc_try_send>
  801a92:	83 c4 10             	add    $0x10,%esp
  801a95:	85 c0                	test   %eax,%eax
  801a97:	75 d2                	jne    801a6b <ipc_send+0x1e>
        if (ret != -E_IPC_NOT_RECV)
            panic("ipc_send error %e", ret);
        sys_yield();
    }
}
  801a99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a9c:	5b                   	pop    %ebx
  801a9d:	5e                   	pop    %esi
  801a9e:	5f                   	pop    %edi
  801a9f:	5d                   	pop    %ebp
  801aa0:	c3                   	ret    

00801aa1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801aa1:	55                   	push   %ebp
  801aa2:	89 e5                	mov    %esp,%ebp
  801aa4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801aa7:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801aac:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801aaf:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ab5:	8b 52 50             	mov    0x50(%edx),%edx
  801ab8:	39 ca                	cmp    %ecx,%edx
  801aba:	75 0d                	jne    801ac9 <ipc_find_env+0x28>
			return envs[i].env_id;
  801abc:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801abf:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ac4:	8b 40 48             	mov    0x48(%eax),%eax
  801ac7:	eb 0f                	jmp    801ad8 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ac9:	83 c0 01             	add    $0x1,%eax
  801acc:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ad1:	75 d9                	jne    801aac <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ad3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ad8:	5d                   	pop    %ebp
  801ad9:	c3                   	ret    

00801ada <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ada:	55                   	push   %ebp
  801adb:	89 e5                	mov    %esp,%ebp
  801add:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ae0:	89 d0                	mov    %edx,%eax
  801ae2:	c1 e8 16             	shr    $0x16,%eax
  801ae5:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801aec:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801af1:	f6 c1 01             	test   $0x1,%cl
  801af4:	74 1d                	je     801b13 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801af6:	c1 ea 0c             	shr    $0xc,%edx
  801af9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b00:	f6 c2 01             	test   $0x1,%dl
  801b03:	74 0e                	je     801b13 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b05:	c1 ea 0c             	shr    $0xc,%edx
  801b08:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b0f:	ef 
  801b10:	0f b7 c0             	movzwl %ax,%eax
}
  801b13:	5d                   	pop    %ebp
  801b14:	c3                   	ret    
  801b15:	66 90                	xchg   %ax,%ax
  801b17:	66 90                	xchg   %ax,%ax
  801b19:	66 90                	xchg   %ax,%ax
  801b1b:	66 90                	xchg   %ax,%ax
  801b1d:	66 90                	xchg   %ax,%ax
  801b1f:	90                   	nop

00801b20 <__udivdi3>:
  801b20:	55                   	push   %ebp
  801b21:	57                   	push   %edi
  801b22:	56                   	push   %esi
  801b23:	53                   	push   %ebx
  801b24:	83 ec 1c             	sub    $0x1c,%esp
  801b27:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801b2b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801b2f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801b33:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801b37:	85 f6                	test   %esi,%esi
  801b39:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b3d:	89 ca                	mov    %ecx,%edx
  801b3f:	89 f8                	mov    %edi,%eax
  801b41:	75 3d                	jne    801b80 <__udivdi3+0x60>
  801b43:	39 cf                	cmp    %ecx,%edi
  801b45:	0f 87 c5 00 00 00    	ja     801c10 <__udivdi3+0xf0>
  801b4b:	85 ff                	test   %edi,%edi
  801b4d:	89 fd                	mov    %edi,%ebp
  801b4f:	75 0b                	jne    801b5c <__udivdi3+0x3c>
  801b51:	b8 01 00 00 00       	mov    $0x1,%eax
  801b56:	31 d2                	xor    %edx,%edx
  801b58:	f7 f7                	div    %edi
  801b5a:	89 c5                	mov    %eax,%ebp
  801b5c:	89 c8                	mov    %ecx,%eax
  801b5e:	31 d2                	xor    %edx,%edx
  801b60:	f7 f5                	div    %ebp
  801b62:	89 c1                	mov    %eax,%ecx
  801b64:	89 d8                	mov    %ebx,%eax
  801b66:	89 cf                	mov    %ecx,%edi
  801b68:	f7 f5                	div    %ebp
  801b6a:	89 c3                	mov    %eax,%ebx
  801b6c:	89 d8                	mov    %ebx,%eax
  801b6e:	89 fa                	mov    %edi,%edx
  801b70:	83 c4 1c             	add    $0x1c,%esp
  801b73:	5b                   	pop    %ebx
  801b74:	5e                   	pop    %esi
  801b75:	5f                   	pop    %edi
  801b76:	5d                   	pop    %ebp
  801b77:	c3                   	ret    
  801b78:	90                   	nop
  801b79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801b80:	39 ce                	cmp    %ecx,%esi
  801b82:	77 74                	ja     801bf8 <__udivdi3+0xd8>
  801b84:	0f bd fe             	bsr    %esi,%edi
  801b87:	83 f7 1f             	xor    $0x1f,%edi
  801b8a:	0f 84 98 00 00 00    	je     801c28 <__udivdi3+0x108>
  801b90:	bb 20 00 00 00       	mov    $0x20,%ebx
  801b95:	89 f9                	mov    %edi,%ecx
  801b97:	89 c5                	mov    %eax,%ebp
  801b99:	29 fb                	sub    %edi,%ebx
  801b9b:	d3 e6                	shl    %cl,%esi
  801b9d:	89 d9                	mov    %ebx,%ecx
  801b9f:	d3 ed                	shr    %cl,%ebp
  801ba1:	89 f9                	mov    %edi,%ecx
  801ba3:	d3 e0                	shl    %cl,%eax
  801ba5:	09 ee                	or     %ebp,%esi
  801ba7:	89 d9                	mov    %ebx,%ecx
  801ba9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bad:	89 d5                	mov    %edx,%ebp
  801baf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801bb3:	d3 ed                	shr    %cl,%ebp
  801bb5:	89 f9                	mov    %edi,%ecx
  801bb7:	d3 e2                	shl    %cl,%edx
  801bb9:	89 d9                	mov    %ebx,%ecx
  801bbb:	d3 e8                	shr    %cl,%eax
  801bbd:	09 c2                	or     %eax,%edx
  801bbf:	89 d0                	mov    %edx,%eax
  801bc1:	89 ea                	mov    %ebp,%edx
  801bc3:	f7 f6                	div    %esi
  801bc5:	89 d5                	mov    %edx,%ebp
  801bc7:	89 c3                	mov    %eax,%ebx
  801bc9:	f7 64 24 0c          	mull   0xc(%esp)
  801bcd:	39 d5                	cmp    %edx,%ebp
  801bcf:	72 10                	jb     801be1 <__udivdi3+0xc1>
  801bd1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801bd5:	89 f9                	mov    %edi,%ecx
  801bd7:	d3 e6                	shl    %cl,%esi
  801bd9:	39 c6                	cmp    %eax,%esi
  801bdb:	73 07                	jae    801be4 <__udivdi3+0xc4>
  801bdd:	39 d5                	cmp    %edx,%ebp
  801bdf:	75 03                	jne    801be4 <__udivdi3+0xc4>
  801be1:	83 eb 01             	sub    $0x1,%ebx
  801be4:	31 ff                	xor    %edi,%edi
  801be6:	89 d8                	mov    %ebx,%eax
  801be8:	89 fa                	mov    %edi,%edx
  801bea:	83 c4 1c             	add    $0x1c,%esp
  801bed:	5b                   	pop    %ebx
  801bee:	5e                   	pop    %esi
  801bef:	5f                   	pop    %edi
  801bf0:	5d                   	pop    %ebp
  801bf1:	c3                   	ret    
  801bf2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801bf8:	31 ff                	xor    %edi,%edi
  801bfa:	31 db                	xor    %ebx,%ebx
  801bfc:	89 d8                	mov    %ebx,%eax
  801bfe:	89 fa                	mov    %edi,%edx
  801c00:	83 c4 1c             	add    $0x1c,%esp
  801c03:	5b                   	pop    %ebx
  801c04:	5e                   	pop    %esi
  801c05:	5f                   	pop    %edi
  801c06:	5d                   	pop    %ebp
  801c07:	c3                   	ret    
  801c08:	90                   	nop
  801c09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c10:	89 d8                	mov    %ebx,%eax
  801c12:	f7 f7                	div    %edi
  801c14:	31 ff                	xor    %edi,%edi
  801c16:	89 c3                	mov    %eax,%ebx
  801c18:	89 d8                	mov    %ebx,%eax
  801c1a:	89 fa                	mov    %edi,%edx
  801c1c:	83 c4 1c             	add    $0x1c,%esp
  801c1f:	5b                   	pop    %ebx
  801c20:	5e                   	pop    %esi
  801c21:	5f                   	pop    %edi
  801c22:	5d                   	pop    %ebp
  801c23:	c3                   	ret    
  801c24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c28:	39 ce                	cmp    %ecx,%esi
  801c2a:	72 0c                	jb     801c38 <__udivdi3+0x118>
  801c2c:	31 db                	xor    %ebx,%ebx
  801c2e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801c32:	0f 87 34 ff ff ff    	ja     801b6c <__udivdi3+0x4c>
  801c38:	bb 01 00 00 00       	mov    $0x1,%ebx
  801c3d:	e9 2a ff ff ff       	jmp    801b6c <__udivdi3+0x4c>
  801c42:	66 90                	xchg   %ax,%ax
  801c44:	66 90                	xchg   %ax,%ax
  801c46:	66 90                	xchg   %ax,%ax
  801c48:	66 90                	xchg   %ax,%ax
  801c4a:	66 90                	xchg   %ax,%ax
  801c4c:	66 90                	xchg   %ax,%ax
  801c4e:	66 90                	xchg   %ax,%ax

00801c50 <__umoddi3>:
  801c50:	55                   	push   %ebp
  801c51:	57                   	push   %edi
  801c52:	56                   	push   %esi
  801c53:	53                   	push   %ebx
  801c54:	83 ec 1c             	sub    $0x1c,%esp
  801c57:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801c5b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801c5f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801c63:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c67:	85 d2                	test   %edx,%edx
  801c69:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801c6d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c71:	89 f3                	mov    %esi,%ebx
  801c73:	89 3c 24             	mov    %edi,(%esp)
  801c76:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c7a:	75 1c                	jne    801c98 <__umoddi3+0x48>
  801c7c:	39 f7                	cmp    %esi,%edi
  801c7e:	76 50                	jbe    801cd0 <__umoddi3+0x80>
  801c80:	89 c8                	mov    %ecx,%eax
  801c82:	89 f2                	mov    %esi,%edx
  801c84:	f7 f7                	div    %edi
  801c86:	89 d0                	mov    %edx,%eax
  801c88:	31 d2                	xor    %edx,%edx
  801c8a:	83 c4 1c             	add    $0x1c,%esp
  801c8d:	5b                   	pop    %ebx
  801c8e:	5e                   	pop    %esi
  801c8f:	5f                   	pop    %edi
  801c90:	5d                   	pop    %ebp
  801c91:	c3                   	ret    
  801c92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c98:	39 f2                	cmp    %esi,%edx
  801c9a:	89 d0                	mov    %edx,%eax
  801c9c:	77 52                	ja     801cf0 <__umoddi3+0xa0>
  801c9e:	0f bd ea             	bsr    %edx,%ebp
  801ca1:	83 f5 1f             	xor    $0x1f,%ebp
  801ca4:	75 5a                	jne    801d00 <__umoddi3+0xb0>
  801ca6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801caa:	0f 82 e0 00 00 00    	jb     801d90 <__umoddi3+0x140>
  801cb0:	39 0c 24             	cmp    %ecx,(%esp)
  801cb3:	0f 86 d7 00 00 00    	jbe    801d90 <__umoddi3+0x140>
  801cb9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801cbd:	8b 54 24 04          	mov    0x4(%esp),%edx
  801cc1:	83 c4 1c             	add    $0x1c,%esp
  801cc4:	5b                   	pop    %ebx
  801cc5:	5e                   	pop    %esi
  801cc6:	5f                   	pop    %edi
  801cc7:	5d                   	pop    %ebp
  801cc8:	c3                   	ret    
  801cc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cd0:	85 ff                	test   %edi,%edi
  801cd2:	89 fd                	mov    %edi,%ebp
  801cd4:	75 0b                	jne    801ce1 <__umoddi3+0x91>
  801cd6:	b8 01 00 00 00       	mov    $0x1,%eax
  801cdb:	31 d2                	xor    %edx,%edx
  801cdd:	f7 f7                	div    %edi
  801cdf:	89 c5                	mov    %eax,%ebp
  801ce1:	89 f0                	mov    %esi,%eax
  801ce3:	31 d2                	xor    %edx,%edx
  801ce5:	f7 f5                	div    %ebp
  801ce7:	89 c8                	mov    %ecx,%eax
  801ce9:	f7 f5                	div    %ebp
  801ceb:	89 d0                	mov    %edx,%eax
  801ced:	eb 99                	jmp    801c88 <__umoddi3+0x38>
  801cef:	90                   	nop
  801cf0:	89 c8                	mov    %ecx,%eax
  801cf2:	89 f2                	mov    %esi,%edx
  801cf4:	83 c4 1c             	add    $0x1c,%esp
  801cf7:	5b                   	pop    %ebx
  801cf8:	5e                   	pop    %esi
  801cf9:	5f                   	pop    %edi
  801cfa:	5d                   	pop    %ebp
  801cfb:	c3                   	ret    
  801cfc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d00:	8b 34 24             	mov    (%esp),%esi
  801d03:	bf 20 00 00 00       	mov    $0x20,%edi
  801d08:	89 e9                	mov    %ebp,%ecx
  801d0a:	29 ef                	sub    %ebp,%edi
  801d0c:	d3 e0                	shl    %cl,%eax
  801d0e:	89 f9                	mov    %edi,%ecx
  801d10:	89 f2                	mov    %esi,%edx
  801d12:	d3 ea                	shr    %cl,%edx
  801d14:	89 e9                	mov    %ebp,%ecx
  801d16:	09 c2                	or     %eax,%edx
  801d18:	89 d8                	mov    %ebx,%eax
  801d1a:	89 14 24             	mov    %edx,(%esp)
  801d1d:	89 f2                	mov    %esi,%edx
  801d1f:	d3 e2                	shl    %cl,%edx
  801d21:	89 f9                	mov    %edi,%ecx
  801d23:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d27:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801d2b:	d3 e8                	shr    %cl,%eax
  801d2d:	89 e9                	mov    %ebp,%ecx
  801d2f:	89 c6                	mov    %eax,%esi
  801d31:	d3 e3                	shl    %cl,%ebx
  801d33:	89 f9                	mov    %edi,%ecx
  801d35:	89 d0                	mov    %edx,%eax
  801d37:	d3 e8                	shr    %cl,%eax
  801d39:	89 e9                	mov    %ebp,%ecx
  801d3b:	09 d8                	or     %ebx,%eax
  801d3d:	89 d3                	mov    %edx,%ebx
  801d3f:	89 f2                	mov    %esi,%edx
  801d41:	f7 34 24             	divl   (%esp)
  801d44:	89 d6                	mov    %edx,%esi
  801d46:	d3 e3                	shl    %cl,%ebx
  801d48:	f7 64 24 04          	mull   0x4(%esp)
  801d4c:	39 d6                	cmp    %edx,%esi
  801d4e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d52:	89 d1                	mov    %edx,%ecx
  801d54:	89 c3                	mov    %eax,%ebx
  801d56:	72 08                	jb     801d60 <__umoddi3+0x110>
  801d58:	75 11                	jne    801d6b <__umoddi3+0x11b>
  801d5a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801d5e:	73 0b                	jae    801d6b <__umoddi3+0x11b>
  801d60:	2b 44 24 04          	sub    0x4(%esp),%eax
  801d64:	1b 14 24             	sbb    (%esp),%edx
  801d67:	89 d1                	mov    %edx,%ecx
  801d69:	89 c3                	mov    %eax,%ebx
  801d6b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801d6f:	29 da                	sub    %ebx,%edx
  801d71:	19 ce                	sbb    %ecx,%esi
  801d73:	89 f9                	mov    %edi,%ecx
  801d75:	89 f0                	mov    %esi,%eax
  801d77:	d3 e0                	shl    %cl,%eax
  801d79:	89 e9                	mov    %ebp,%ecx
  801d7b:	d3 ea                	shr    %cl,%edx
  801d7d:	89 e9                	mov    %ebp,%ecx
  801d7f:	d3 ee                	shr    %cl,%esi
  801d81:	09 d0                	or     %edx,%eax
  801d83:	89 f2                	mov    %esi,%edx
  801d85:	83 c4 1c             	add    $0x1c,%esp
  801d88:	5b                   	pop    %ebx
  801d89:	5e                   	pop    %esi
  801d8a:	5f                   	pop    %edi
  801d8b:	5d                   	pop    %ebp
  801d8c:	c3                   	ret    
  801d8d:	8d 76 00             	lea    0x0(%esi),%esi
  801d90:	29 f9                	sub    %edi,%ecx
  801d92:	19 d6                	sbb    %edx,%esi
  801d94:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d98:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d9c:	e9 18 ff ff ff       	jmp    801cb9 <__umoddi3+0x69>
