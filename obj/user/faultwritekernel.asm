
obj/user/faultwritekernel.debug:     file format elf32-i386


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
  80002c:	e8 11 00 00 00       	call   800042 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	*(unsigned*)0xf0100000 = 0;
  800036:	c7 05 00 00 10 f0 00 	movl   $0x0,0xf0100000
  80003d:	00 00 00 
}
  800040:	5d                   	pop    %ebp
  800041:	c3                   	ret    

00800042 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800042:	55                   	push   %ebp
  800043:	89 e5                	mov    %esp,%ebp
  800045:	56                   	push   %esi
  800046:	53                   	push   %ebx
  800047:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004a:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  80004d:	e8 ce 00 00 00       	call   800120 <sys_getenvid>
  800052:	25 ff 03 00 00       	and    $0x3ff,%eax
  800057:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005f:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800064:	85 db                	test   %ebx,%ebx
  800066:	7e 07                	jle    80006f <libmain+0x2d>
		binaryname = argv[0];
  800068:	8b 06                	mov    (%esi),%eax
  80006a:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80006f:	83 ec 08             	sub    $0x8,%esp
  800072:	56                   	push   %esi
  800073:	53                   	push   %ebx
  800074:	e8 ba ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800079:	e8 0a 00 00 00       	call   800088 <exit>
}
  80007e:	83 c4 10             	add    $0x10,%esp
  800081:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800084:	5b                   	pop    %ebx
  800085:	5e                   	pop    %esi
  800086:	5d                   	pop    %ebp
  800087:	c3                   	ret    

00800088 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800088:	55                   	push   %ebp
  800089:	89 e5                	mov    %esp,%ebp
  80008b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80008e:	e8 87 04 00 00       	call   80051a <close_all>
	sys_env_destroy(0);
  800093:	83 ec 0c             	sub    $0xc,%esp
  800096:	6a 00                	push   $0x0
  800098:	e8 42 00 00 00       	call   8000df <sys_env_destroy>
}
  80009d:	83 c4 10             	add    $0x10,%esp
  8000a0:	c9                   	leave  
  8000a1:	c3                   	ret    

008000a2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a2:	55                   	push   %ebp
  8000a3:	89 e5                	mov    %esp,%ebp
  8000a5:	57                   	push   %edi
  8000a6:	56                   	push   %esi
  8000a7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b3:	89 c3                	mov    %eax,%ebx
  8000b5:	89 c7                	mov    %eax,%edi
  8000b7:	89 c6                	mov    %eax,%esi
  8000b9:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000bb:	5b                   	pop    %ebx
  8000bc:	5e                   	pop    %esi
  8000bd:	5f                   	pop    %edi
  8000be:	5d                   	pop    %ebp
  8000bf:	c3                   	ret    

008000c0 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	57                   	push   %edi
  8000c4:	56                   	push   %esi
  8000c5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cb:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d0:	89 d1                	mov    %edx,%ecx
  8000d2:	89 d3                	mov    %edx,%ebx
  8000d4:	89 d7                	mov    %edx,%edi
  8000d6:	89 d6                	mov    %edx,%esi
  8000d8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000da:	5b                   	pop    %ebx
  8000db:	5e                   	pop    %esi
  8000dc:	5f                   	pop    %edi
  8000dd:	5d                   	pop    %ebp
  8000de:	c3                   	ret    

008000df <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000df:	55                   	push   %ebp
  8000e0:	89 e5                	mov    %esp,%ebp
  8000e2:	57                   	push   %edi
  8000e3:	56                   	push   %esi
  8000e4:	53                   	push   %ebx
  8000e5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ed:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f5:	89 cb                	mov    %ecx,%ebx
  8000f7:	89 cf                	mov    %ecx,%edi
  8000f9:	89 ce                	mov    %ecx,%esi
  8000fb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000fd:	85 c0                	test   %eax,%eax
  8000ff:	7e 17                	jle    800118 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800101:	83 ec 0c             	sub    $0xc,%esp
  800104:	50                   	push   %eax
  800105:	6a 03                	push   $0x3
  800107:	68 ca 1d 80 00       	push   $0x801dca
  80010c:	6a 23                	push   $0x23
  80010e:	68 e7 1d 80 00       	push   $0x801de7
  800113:	e8 21 0f 00 00       	call   801039 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800118:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80011b:	5b                   	pop    %ebx
  80011c:	5e                   	pop    %esi
  80011d:	5f                   	pop    %edi
  80011e:	5d                   	pop    %ebp
  80011f:	c3                   	ret    

00800120 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	57                   	push   %edi
  800124:	56                   	push   %esi
  800125:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800126:	ba 00 00 00 00       	mov    $0x0,%edx
  80012b:	b8 02 00 00 00       	mov    $0x2,%eax
  800130:	89 d1                	mov    %edx,%ecx
  800132:	89 d3                	mov    %edx,%ebx
  800134:	89 d7                	mov    %edx,%edi
  800136:	89 d6                	mov    %edx,%esi
  800138:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013a:	5b                   	pop    %ebx
  80013b:	5e                   	pop    %esi
  80013c:	5f                   	pop    %edi
  80013d:	5d                   	pop    %ebp
  80013e:	c3                   	ret    

0080013f <sys_yield>:

void
sys_yield(void)
{
  80013f:	55                   	push   %ebp
  800140:	89 e5                	mov    %esp,%ebp
  800142:	57                   	push   %edi
  800143:	56                   	push   %esi
  800144:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800145:	ba 00 00 00 00       	mov    $0x0,%edx
  80014a:	b8 0b 00 00 00       	mov    $0xb,%eax
  80014f:	89 d1                	mov    %edx,%ecx
  800151:	89 d3                	mov    %edx,%ebx
  800153:	89 d7                	mov    %edx,%edi
  800155:	89 d6                	mov    %edx,%esi
  800157:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800159:	5b                   	pop    %ebx
  80015a:	5e                   	pop    %esi
  80015b:	5f                   	pop    %edi
  80015c:	5d                   	pop    %ebp
  80015d:	c3                   	ret    

0080015e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80015e:	55                   	push   %ebp
  80015f:	89 e5                	mov    %esp,%ebp
  800161:	57                   	push   %edi
  800162:	56                   	push   %esi
  800163:	53                   	push   %ebx
  800164:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800167:	be 00 00 00 00       	mov    $0x0,%esi
  80016c:	b8 04 00 00 00       	mov    $0x4,%eax
  800171:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800174:	8b 55 08             	mov    0x8(%ebp),%edx
  800177:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017a:	89 f7                	mov    %esi,%edi
  80017c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80017e:	85 c0                	test   %eax,%eax
  800180:	7e 17                	jle    800199 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800182:	83 ec 0c             	sub    $0xc,%esp
  800185:	50                   	push   %eax
  800186:	6a 04                	push   $0x4
  800188:	68 ca 1d 80 00       	push   $0x801dca
  80018d:	6a 23                	push   $0x23
  80018f:	68 e7 1d 80 00       	push   $0x801de7
  800194:	e8 a0 0e 00 00       	call   801039 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800199:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80019c:	5b                   	pop    %ebx
  80019d:	5e                   	pop    %esi
  80019e:	5f                   	pop    %edi
  80019f:	5d                   	pop    %ebp
  8001a0:	c3                   	ret    

008001a1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a1:	55                   	push   %ebp
  8001a2:	89 e5                	mov    %esp,%ebp
  8001a4:	57                   	push   %edi
  8001a5:	56                   	push   %esi
  8001a6:	53                   	push   %ebx
  8001a7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001aa:	b8 05 00 00 00       	mov    $0x5,%eax
  8001af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001bb:	8b 75 18             	mov    0x18(%ebp),%esi
  8001be:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001c0:	85 c0                	test   %eax,%eax
  8001c2:	7e 17                	jle    8001db <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c4:	83 ec 0c             	sub    $0xc,%esp
  8001c7:	50                   	push   %eax
  8001c8:	6a 05                	push   $0x5
  8001ca:	68 ca 1d 80 00       	push   $0x801dca
  8001cf:	6a 23                	push   $0x23
  8001d1:	68 e7 1d 80 00       	push   $0x801de7
  8001d6:	e8 5e 0e 00 00       	call   801039 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001de:	5b                   	pop    %ebx
  8001df:	5e                   	pop    %esi
  8001e0:	5f                   	pop    %edi
  8001e1:	5d                   	pop    %ebp
  8001e2:	c3                   	ret    

008001e3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e3:	55                   	push   %ebp
  8001e4:	89 e5                	mov    %esp,%ebp
  8001e6:	57                   	push   %edi
  8001e7:	56                   	push   %esi
  8001e8:	53                   	push   %ebx
  8001e9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ec:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f1:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fc:	89 df                	mov    %ebx,%edi
  8001fe:	89 de                	mov    %ebx,%esi
  800200:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800202:	85 c0                	test   %eax,%eax
  800204:	7e 17                	jle    80021d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800206:	83 ec 0c             	sub    $0xc,%esp
  800209:	50                   	push   %eax
  80020a:	6a 06                	push   $0x6
  80020c:	68 ca 1d 80 00       	push   $0x801dca
  800211:	6a 23                	push   $0x23
  800213:	68 e7 1d 80 00       	push   $0x801de7
  800218:	e8 1c 0e 00 00       	call   801039 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80021d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800220:	5b                   	pop    %ebx
  800221:	5e                   	pop    %esi
  800222:	5f                   	pop    %edi
  800223:	5d                   	pop    %ebp
  800224:	c3                   	ret    

00800225 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800225:	55                   	push   %ebp
  800226:	89 e5                	mov    %esp,%ebp
  800228:	57                   	push   %edi
  800229:	56                   	push   %esi
  80022a:	53                   	push   %ebx
  80022b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80022e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800233:	b8 08 00 00 00       	mov    $0x8,%eax
  800238:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023b:	8b 55 08             	mov    0x8(%ebp),%edx
  80023e:	89 df                	mov    %ebx,%edi
  800240:	89 de                	mov    %ebx,%esi
  800242:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800244:	85 c0                	test   %eax,%eax
  800246:	7e 17                	jle    80025f <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800248:	83 ec 0c             	sub    $0xc,%esp
  80024b:	50                   	push   %eax
  80024c:	6a 08                	push   $0x8
  80024e:	68 ca 1d 80 00       	push   $0x801dca
  800253:	6a 23                	push   $0x23
  800255:	68 e7 1d 80 00       	push   $0x801de7
  80025a:	e8 da 0d 00 00       	call   801039 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80025f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800262:	5b                   	pop    %ebx
  800263:	5e                   	pop    %esi
  800264:	5f                   	pop    %edi
  800265:	5d                   	pop    %ebp
  800266:	c3                   	ret    

00800267 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800267:	55                   	push   %ebp
  800268:	89 e5                	mov    %esp,%ebp
  80026a:	57                   	push   %edi
  80026b:	56                   	push   %esi
  80026c:	53                   	push   %ebx
  80026d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800270:	bb 00 00 00 00       	mov    $0x0,%ebx
  800275:	b8 09 00 00 00       	mov    $0x9,%eax
  80027a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80027d:	8b 55 08             	mov    0x8(%ebp),%edx
  800280:	89 df                	mov    %ebx,%edi
  800282:	89 de                	mov    %ebx,%esi
  800284:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800286:	85 c0                	test   %eax,%eax
  800288:	7e 17                	jle    8002a1 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028a:	83 ec 0c             	sub    $0xc,%esp
  80028d:	50                   	push   %eax
  80028e:	6a 09                	push   $0x9
  800290:	68 ca 1d 80 00       	push   $0x801dca
  800295:	6a 23                	push   $0x23
  800297:	68 e7 1d 80 00       	push   $0x801de7
  80029c:	e8 98 0d 00 00       	call   801039 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a4:	5b                   	pop    %ebx
  8002a5:	5e                   	pop    %esi
  8002a6:	5f                   	pop    %edi
  8002a7:	5d                   	pop    %ebp
  8002a8:	c3                   	ret    

008002a9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a9:	55                   	push   %ebp
  8002aa:	89 e5                	mov    %esp,%ebp
  8002ac:	57                   	push   %edi
  8002ad:	56                   	push   %esi
  8002ae:	53                   	push   %ebx
  8002af:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c2:	89 df                	mov    %ebx,%edi
  8002c4:	89 de                	mov    %ebx,%esi
  8002c6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002c8:	85 c0                	test   %eax,%eax
  8002ca:	7e 17                	jle    8002e3 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002cc:	83 ec 0c             	sub    $0xc,%esp
  8002cf:	50                   	push   %eax
  8002d0:	6a 0a                	push   $0xa
  8002d2:	68 ca 1d 80 00       	push   $0x801dca
  8002d7:	6a 23                	push   $0x23
  8002d9:	68 e7 1d 80 00       	push   $0x801de7
  8002de:	e8 56 0d 00 00       	call   801039 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e6:	5b                   	pop    %ebx
  8002e7:	5e                   	pop    %esi
  8002e8:	5f                   	pop    %edi
  8002e9:	5d                   	pop    %ebp
  8002ea:	c3                   	ret    

008002eb <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002eb:	55                   	push   %ebp
  8002ec:	89 e5                	mov    %esp,%ebp
  8002ee:	57                   	push   %edi
  8002ef:	56                   	push   %esi
  8002f0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f1:	be 00 00 00 00       	mov    $0x0,%esi
  8002f6:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800301:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800304:	8b 7d 14             	mov    0x14(%ebp),%edi
  800307:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800309:	5b                   	pop    %ebx
  80030a:	5e                   	pop    %esi
  80030b:	5f                   	pop    %edi
  80030c:	5d                   	pop    %ebp
  80030d:	c3                   	ret    

0080030e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
  800311:	57                   	push   %edi
  800312:	56                   	push   %esi
  800313:	53                   	push   %ebx
  800314:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800317:	b9 00 00 00 00       	mov    $0x0,%ecx
  80031c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800321:	8b 55 08             	mov    0x8(%ebp),%edx
  800324:	89 cb                	mov    %ecx,%ebx
  800326:	89 cf                	mov    %ecx,%edi
  800328:	89 ce                	mov    %ecx,%esi
  80032a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80032c:	85 c0                	test   %eax,%eax
  80032e:	7e 17                	jle    800347 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800330:	83 ec 0c             	sub    $0xc,%esp
  800333:	50                   	push   %eax
  800334:	6a 0d                	push   $0xd
  800336:	68 ca 1d 80 00       	push   $0x801dca
  80033b:	6a 23                	push   $0x23
  80033d:	68 e7 1d 80 00       	push   $0x801de7
  800342:	e8 f2 0c 00 00       	call   801039 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800347:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034a:	5b                   	pop    %ebx
  80034b:	5e                   	pop    %esi
  80034c:	5f                   	pop    %edi
  80034d:	5d                   	pop    %ebp
  80034e:	c3                   	ret    

0080034f <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80034f:	55                   	push   %ebp
  800350:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800352:	8b 45 08             	mov    0x8(%ebp),%eax
  800355:	05 00 00 00 30       	add    $0x30000000,%eax
  80035a:	c1 e8 0c             	shr    $0xc,%eax
}
  80035d:	5d                   	pop    %ebp
  80035e:	c3                   	ret    

0080035f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80035f:	55                   	push   %ebp
  800360:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800362:	8b 45 08             	mov    0x8(%ebp),%eax
  800365:	05 00 00 00 30       	add    $0x30000000,%eax
  80036a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80036f:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800374:	5d                   	pop    %ebp
  800375:	c3                   	ret    

00800376 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800376:	55                   	push   %ebp
  800377:	89 e5                	mov    %esp,%ebp
  800379:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80037c:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800381:	89 c2                	mov    %eax,%edx
  800383:	c1 ea 16             	shr    $0x16,%edx
  800386:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80038d:	f6 c2 01             	test   $0x1,%dl
  800390:	74 11                	je     8003a3 <fd_alloc+0x2d>
  800392:	89 c2                	mov    %eax,%edx
  800394:	c1 ea 0c             	shr    $0xc,%edx
  800397:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80039e:	f6 c2 01             	test   $0x1,%dl
  8003a1:	75 09                	jne    8003ac <fd_alloc+0x36>
			*fd_store = fd;
  8003a3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8003aa:	eb 17                	jmp    8003c3 <fd_alloc+0x4d>
  8003ac:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003b1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003b6:	75 c9                	jne    800381 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003b8:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003be:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003c3:	5d                   	pop    %ebp
  8003c4:	c3                   	ret    

008003c5 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003c5:	55                   	push   %ebp
  8003c6:	89 e5                	mov    %esp,%ebp
  8003c8:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003cb:	83 f8 1f             	cmp    $0x1f,%eax
  8003ce:	77 36                	ja     800406 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003d0:	c1 e0 0c             	shl    $0xc,%eax
  8003d3:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003d8:	89 c2                	mov    %eax,%edx
  8003da:	c1 ea 16             	shr    $0x16,%edx
  8003dd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003e4:	f6 c2 01             	test   $0x1,%dl
  8003e7:	74 24                	je     80040d <fd_lookup+0x48>
  8003e9:	89 c2                	mov    %eax,%edx
  8003eb:	c1 ea 0c             	shr    $0xc,%edx
  8003ee:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003f5:	f6 c2 01             	test   $0x1,%dl
  8003f8:	74 1a                	je     800414 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003fd:	89 02                	mov    %eax,(%edx)
	return 0;
  8003ff:	b8 00 00 00 00       	mov    $0x0,%eax
  800404:	eb 13                	jmp    800419 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800406:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80040b:	eb 0c                	jmp    800419 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80040d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800412:	eb 05                	jmp    800419 <fd_lookup+0x54>
  800414:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800419:	5d                   	pop    %ebp
  80041a:	c3                   	ret    

0080041b <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80041b:	55                   	push   %ebp
  80041c:	89 e5                	mov    %esp,%ebp
  80041e:	83 ec 08             	sub    $0x8,%esp
  800421:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800424:	ba 74 1e 80 00       	mov    $0x801e74,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800429:	eb 13                	jmp    80043e <dev_lookup+0x23>
  80042b:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80042e:	39 08                	cmp    %ecx,(%eax)
  800430:	75 0c                	jne    80043e <dev_lookup+0x23>
			*dev = devtab[i];
  800432:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800435:	89 01                	mov    %eax,(%ecx)
			return 0;
  800437:	b8 00 00 00 00       	mov    $0x0,%eax
  80043c:	eb 2e                	jmp    80046c <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80043e:	8b 02                	mov    (%edx),%eax
  800440:	85 c0                	test   %eax,%eax
  800442:	75 e7                	jne    80042b <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800444:	a1 04 40 80 00       	mov    0x804004,%eax
  800449:	8b 40 48             	mov    0x48(%eax),%eax
  80044c:	83 ec 04             	sub    $0x4,%esp
  80044f:	51                   	push   %ecx
  800450:	50                   	push   %eax
  800451:	68 f8 1d 80 00       	push   $0x801df8
  800456:	e8 b7 0c 00 00       	call   801112 <cprintf>
	*dev = 0;
  80045b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80045e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800464:	83 c4 10             	add    $0x10,%esp
  800467:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80046c:	c9                   	leave  
  80046d:	c3                   	ret    

0080046e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80046e:	55                   	push   %ebp
  80046f:	89 e5                	mov    %esp,%ebp
  800471:	56                   	push   %esi
  800472:	53                   	push   %ebx
  800473:	83 ec 10             	sub    $0x10,%esp
  800476:	8b 75 08             	mov    0x8(%ebp),%esi
  800479:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80047c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80047f:	50                   	push   %eax
  800480:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800486:	c1 e8 0c             	shr    $0xc,%eax
  800489:	50                   	push   %eax
  80048a:	e8 36 ff ff ff       	call   8003c5 <fd_lookup>
  80048f:	83 c4 08             	add    $0x8,%esp
  800492:	85 c0                	test   %eax,%eax
  800494:	78 05                	js     80049b <fd_close+0x2d>
	    || fd != fd2)
  800496:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800499:	74 0c                	je     8004a7 <fd_close+0x39>
		return (must_exist ? r : 0);
  80049b:	84 db                	test   %bl,%bl
  80049d:	ba 00 00 00 00       	mov    $0x0,%edx
  8004a2:	0f 44 c2             	cmove  %edx,%eax
  8004a5:	eb 41                	jmp    8004e8 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004a7:	83 ec 08             	sub    $0x8,%esp
  8004aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004ad:	50                   	push   %eax
  8004ae:	ff 36                	pushl  (%esi)
  8004b0:	e8 66 ff ff ff       	call   80041b <dev_lookup>
  8004b5:	89 c3                	mov    %eax,%ebx
  8004b7:	83 c4 10             	add    $0x10,%esp
  8004ba:	85 c0                	test   %eax,%eax
  8004bc:	78 1a                	js     8004d8 <fd_close+0x6a>
		if (dev->dev_close)
  8004be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004c1:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004c4:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004c9:	85 c0                	test   %eax,%eax
  8004cb:	74 0b                	je     8004d8 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004cd:	83 ec 0c             	sub    $0xc,%esp
  8004d0:	56                   	push   %esi
  8004d1:	ff d0                	call   *%eax
  8004d3:	89 c3                	mov    %eax,%ebx
  8004d5:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004d8:	83 ec 08             	sub    $0x8,%esp
  8004db:	56                   	push   %esi
  8004dc:	6a 00                	push   $0x0
  8004de:	e8 00 fd ff ff       	call   8001e3 <sys_page_unmap>
	return r;
  8004e3:	83 c4 10             	add    $0x10,%esp
  8004e6:	89 d8                	mov    %ebx,%eax
}
  8004e8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004eb:	5b                   	pop    %ebx
  8004ec:	5e                   	pop    %esi
  8004ed:	5d                   	pop    %ebp
  8004ee:	c3                   	ret    

008004ef <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004ef:	55                   	push   %ebp
  8004f0:	89 e5                	mov    %esp,%ebp
  8004f2:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004f8:	50                   	push   %eax
  8004f9:	ff 75 08             	pushl  0x8(%ebp)
  8004fc:	e8 c4 fe ff ff       	call   8003c5 <fd_lookup>
  800501:	83 c4 08             	add    $0x8,%esp
  800504:	85 c0                	test   %eax,%eax
  800506:	78 10                	js     800518 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800508:	83 ec 08             	sub    $0x8,%esp
  80050b:	6a 01                	push   $0x1
  80050d:	ff 75 f4             	pushl  -0xc(%ebp)
  800510:	e8 59 ff ff ff       	call   80046e <fd_close>
  800515:	83 c4 10             	add    $0x10,%esp
}
  800518:	c9                   	leave  
  800519:	c3                   	ret    

0080051a <close_all>:

void
close_all(void)
{
  80051a:	55                   	push   %ebp
  80051b:	89 e5                	mov    %esp,%ebp
  80051d:	53                   	push   %ebx
  80051e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800521:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800526:	83 ec 0c             	sub    $0xc,%esp
  800529:	53                   	push   %ebx
  80052a:	e8 c0 ff ff ff       	call   8004ef <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80052f:	83 c3 01             	add    $0x1,%ebx
  800532:	83 c4 10             	add    $0x10,%esp
  800535:	83 fb 20             	cmp    $0x20,%ebx
  800538:	75 ec                	jne    800526 <close_all+0xc>
		close(i);
}
  80053a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80053d:	c9                   	leave  
  80053e:	c3                   	ret    

0080053f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80053f:	55                   	push   %ebp
  800540:	89 e5                	mov    %esp,%ebp
  800542:	57                   	push   %edi
  800543:	56                   	push   %esi
  800544:	53                   	push   %ebx
  800545:	83 ec 2c             	sub    $0x2c,%esp
  800548:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80054b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80054e:	50                   	push   %eax
  80054f:	ff 75 08             	pushl  0x8(%ebp)
  800552:	e8 6e fe ff ff       	call   8003c5 <fd_lookup>
  800557:	83 c4 08             	add    $0x8,%esp
  80055a:	85 c0                	test   %eax,%eax
  80055c:	0f 88 c1 00 00 00    	js     800623 <dup+0xe4>
		return r;
	close(newfdnum);
  800562:	83 ec 0c             	sub    $0xc,%esp
  800565:	56                   	push   %esi
  800566:	e8 84 ff ff ff       	call   8004ef <close>

	newfd = INDEX2FD(newfdnum);
  80056b:	89 f3                	mov    %esi,%ebx
  80056d:	c1 e3 0c             	shl    $0xc,%ebx
  800570:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800576:	83 c4 04             	add    $0x4,%esp
  800579:	ff 75 e4             	pushl  -0x1c(%ebp)
  80057c:	e8 de fd ff ff       	call   80035f <fd2data>
  800581:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800583:	89 1c 24             	mov    %ebx,(%esp)
  800586:	e8 d4 fd ff ff       	call   80035f <fd2data>
  80058b:	83 c4 10             	add    $0x10,%esp
  80058e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800591:	89 f8                	mov    %edi,%eax
  800593:	c1 e8 16             	shr    $0x16,%eax
  800596:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80059d:	a8 01                	test   $0x1,%al
  80059f:	74 37                	je     8005d8 <dup+0x99>
  8005a1:	89 f8                	mov    %edi,%eax
  8005a3:	c1 e8 0c             	shr    $0xc,%eax
  8005a6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005ad:	f6 c2 01             	test   $0x1,%dl
  8005b0:	74 26                	je     8005d8 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005b2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005b9:	83 ec 0c             	sub    $0xc,%esp
  8005bc:	25 07 0e 00 00       	and    $0xe07,%eax
  8005c1:	50                   	push   %eax
  8005c2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005c5:	6a 00                	push   $0x0
  8005c7:	57                   	push   %edi
  8005c8:	6a 00                	push   $0x0
  8005ca:	e8 d2 fb ff ff       	call   8001a1 <sys_page_map>
  8005cf:	89 c7                	mov    %eax,%edi
  8005d1:	83 c4 20             	add    $0x20,%esp
  8005d4:	85 c0                	test   %eax,%eax
  8005d6:	78 2e                	js     800606 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005d8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005db:	89 d0                	mov    %edx,%eax
  8005dd:	c1 e8 0c             	shr    $0xc,%eax
  8005e0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005e7:	83 ec 0c             	sub    $0xc,%esp
  8005ea:	25 07 0e 00 00       	and    $0xe07,%eax
  8005ef:	50                   	push   %eax
  8005f0:	53                   	push   %ebx
  8005f1:	6a 00                	push   $0x0
  8005f3:	52                   	push   %edx
  8005f4:	6a 00                	push   $0x0
  8005f6:	e8 a6 fb ff ff       	call   8001a1 <sys_page_map>
  8005fb:	89 c7                	mov    %eax,%edi
  8005fd:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800600:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800602:	85 ff                	test   %edi,%edi
  800604:	79 1d                	jns    800623 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800606:	83 ec 08             	sub    $0x8,%esp
  800609:	53                   	push   %ebx
  80060a:	6a 00                	push   $0x0
  80060c:	e8 d2 fb ff ff       	call   8001e3 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800611:	83 c4 08             	add    $0x8,%esp
  800614:	ff 75 d4             	pushl  -0x2c(%ebp)
  800617:	6a 00                	push   $0x0
  800619:	e8 c5 fb ff ff       	call   8001e3 <sys_page_unmap>
	return r;
  80061e:	83 c4 10             	add    $0x10,%esp
  800621:	89 f8                	mov    %edi,%eax
}
  800623:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800626:	5b                   	pop    %ebx
  800627:	5e                   	pop    %esi
  800628:	5f                   	pop    %edi
  800629:	5d                   	pop    %ebp
  80062a:	c3                   	ret    

0080062b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80062b:	55                   	push   %ebp
  80062c:	89 e5                	mov    %esp,%ebp
  80062e:	53                   	push   %ebx
  80062f:	83 ec 14             	sub    $0x14,%esp
  800632:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800635:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800638:	50                   	push   %eax
  800639:	53                   	push   %ebx
  80063a:	e8 86 fd ff ff       	call   8003c5 <fd_lookup>
  80063f:	83 c4 08             	add    $0x8,%esp
  800642:	89 c2                	mov    %eax,%edx
  800644:	85 c0                	test   %eax,%eax
  800646:	78 6d                	js     8006b5 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800648:	83 ec 08             	sub    $0x8,%esp
  80064b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80064e:	50                   	push   %eax
  80064f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800652:	ff 30                	pushl  (%eax)
  800654:	e8 c2 fd ff ff       	call   80041b <dev_lookup>
  800659:	83 c4 10             	add    $0x10,%esp
  80065c:	85 c0                	test   %eax,%eax
  80065e:	78 4c                	js     8006ac <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800660:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800663:	8b 42 08             	mov    0x8(%edx),%eax
  800666:	83 e0 03             	and    $0x3,%eax
  800669:	83 f8 01             	cmp    $0x1,%eax
  80066c:	75 21                	jne    80068f <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80066e:	a1 04 40 80 00       	mov    0x804004,%eax
  800673:	8b 40 48             	mov    0x48(%eax),%eax
  800676:	83 ec 04             	sub    $0x4,%esp
  800679:	53                   	push   %ebx
  80067a:	50                   	push   %eax
  80067b:	68 39 1e 80 00       	push   $0x801e39
  800680:	e8 8d 0a 00 00       	call   801112 <cprintf>
		return -E_INVAL;
  800685:	83 c4 10             	add    $0x10,%esp
  800688:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80068d:	eb 26                	jmp    8006b5 <read+0x8a>
	}
	if (!dev->dev_read)
  80068f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800692:	8b 40 08             	mov    0x8(%eax),%eax
  800695:	85 c0                	test   %eax,%eax
  800697:	74 17                	je     8006b0 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800699:	83 ec 04             	sub    $0x4,%esp
  80069c:	ff 75 10             	pushl  0x10(%ebp)
  80069f:	ff 75 0c             	pushl  0xc(%ebp)
  8006a2:	52                   	push   %edx
  8006a3:	ff d0                	call   *%eax
  8006a5:	89 c2                	mov    %eax,%edx
  8006a7:	83 c4 10             	add    $0x10,%esp
  8006aa:	eb 09                	jmp    8006b5 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006ac:	89 c2                	mov    %eax,%edx
  8006ae:	eb 05                	jmp    8006b5 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006b0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006b5:	89 d0                	mov    %edx,%eax
  8006b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006ba:	c9                   	leave  
  8006bb:	c3                   	ret    

008006bc <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006bc:	55                   	push   %ebp
  8006bd:	89 e5                	mov    %esp,%ebp
  8006bf:	57                   	push   %edi
  8006c0:	56                   	push   %esi
  8006c1:	53                   	push   %ebx
  8006c2:	83 ec 0c             	sub    $0xc,%esp
  8006c5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006c8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006cb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d0:	eb 21                	jmp    8006f3 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006d2:	83 ec 04             	sub    $0x4,%esp
  8006d5:	89 f0                	mov    %esi,%eax
  8006d7:	29 d8                	sub    %ebx,%eax
  8006d9:	50                   	push   %eax
  8006da:	89 d8                	mov    %ebx,%eax
  8006dc:	03 45 0c             	add    0xc(%ebp),%eax
  8006df:	50                   	push   %eax
  8006e0:	57                   	push   %edi
  8006e1:	e8 45 ff ff ff       	call   80062b <read>
		if (m < 0)
  8006e6:	83 c4 10             	add    $0x10,%esp
  8006e9:	85 c0                	test   %eax,%eax
  8006eb:	78 10                	js     8006fd <readn+0x41>
			return m;
		if (m == 0)
  8006ed:	85 c0                	test   %eax,%eax
  8006ef:	74 0a                	je     8006fb <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006f1:	01 c3                	add    %eax,%ebx
  8006f3:	39 f3                	cmp    %esi,%ebx
  8006f5:	72 db                	jb     8006d2 <readn+0x16>
  8006f7:	89 d8                	mov    %ebx,%eax
  8006f9:	eb 02                	jmp    8006fd <readn+0x41>
  8006fb:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8006fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800700:	5b                   	pop    %ebx
  800701:	5e                   	pop    %esi
  800702:	5f                   	pop    %edi
  800703:	5d                   	pop    %ebp
  800704:	c3                   	ret    

00800705 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800705:	55                   	push   %ebp
  800706:	89 e5                	mov    %esp,%ebp
  800708:	53                   	push   %ebx
  800709:	83 ec 14             	sub    $0x14,%esp
  80070c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80070f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800712:	50                   	push   %eax
  800713:	53                   	push   %ebx
  800714:	e8 ac fc ff ff       	call   8003c5 <fd_lookup>
  800719:	83 c4 08             	add    $0x8,%esp
  80071c:	89 c2                	mov    %eax,%edx
  80071e:	85 c0                	test   %eax,%eax
  800720:	78 68                	js     80078a <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800722:	83 ec 08             	sub    $0x8,%esp
  800725:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800728:	50                   	push   %eax
  800729:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80072c:	ff 30                	pushl  (%eax)
  80072e:	e8 e8 fc ff ff       	call   80041b <dev_lookup>
  800733:	83 c4 10             	add    $0x10,%esp
  800736:	85 c0                	test   %eax,%eax
  800738:	78 47                	js     800781 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80073a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80073d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800741:	75 21                	jne    800764 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800743:	a1 04 40 80 00       	mov    0x804004,%eax
  800748:	8b 40 48             	mov    0x48(%eax),%eax
  80074b:	83 ec 04             	sub    $0x4,%esp
  80074e:	53                   	push   %ebx
  80074f:	50                   	push   %eax
  800750:	68 55 1e 80 00       	push   $0x801e55
  800755:	e8 b8 09 00 00       	call   801112 <cprintf>
		return -E_INVAL;
  80075a:	83 c4 10             	add    $0x10,%esp
  80075d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800762:	eb 26                	jmp    80078a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800764:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800767:	8b 52 0c             	mov    0xc(%edx),%edx
  80076a:	85 d2                	test   %edx,%edx
  80076c:	74 17                	je     800785 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80076e:	83 ec 04             	sub    $0x4,%esp
  800771:	ff 75 10             	pushl  0x10(%ebp)
  800774:	ff 75 0c             	pushl  0xc(%ebp)
  800777:	50                   	push   %eax
  800778:	ff d2                	call   *%edx
  80077a:	89 c2                	mov    %eax,%edx
  80077c:	83 c4 10             	add    $0x10,%esp
  80077f:	eb 09                	jmp    80078a <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800781:	89 c2                	mov    %eax,%edx
  800783:	eb 05                	jmp    80078a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800785:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80078a:	89 d0                	mov    %edx,%eax
  80078c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80078f:	c9                   	leave  
  800790:	c3                   	ret    

00800791 <seek>:

int
seek(int fdnum, off_t offset)
{
  800791:	55                   	push   %ebp
  800792:	89 e5                	mov    %esp,%ebp
  800794:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800797:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80079a:	50                   	push   %eax
  80079b:	ff 75 08             	pushl  0x8(%ebp)
  80079e:	e8 22 fc ff ff       	call   8003c5 <fd_lookup>
  8007a3:	83 c4 08             	add    $0x8,%esp
  8007a6:	85 c0                	test   %eax,%eax
  8007a8:	78 0e                	js     8007b8 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007ad:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b0:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007b8:	c9                   	leave  
  8007b9:	c3                   	ret    

008007ba <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007ba:	55                   	push   %ebp
  8007bb:	89 e5                	mov    %esp,%ebp
  8007bd:	53                   	push   %ebx
  8007be:	83 ec 14             	sub    $0x14,%esp
  8007c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007c4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007c7:	50                   	push   %eax
  8007c8:	53                   	push   %ebx
  8007c9:	e8 f7 fb ff ff       	call   8003c5 <fd_lookup>
  8007ce:	83 c4 08             	add    $0x8,%esp
  8007d1:	89 c2                	mov    %eax,%edx
  8007d3:	85 c0                	test   %eax,%eax
  8007d5:	78 65                	js     80083c <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007d7:	83 ec 08             	sub    $0x8,%esp
  8007da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007dd:	50                   	push   %eax
  8007de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e1:	ff 30                	pushl  (%eax)
  8007e3:	e8 33 fc ff ff       	call   80041b <dev_lookup>
  8007e8:	83 c4 10             	add    $0x10,%esp
  8007eb:	85 c0                	test   %eax,%eax
  8007ed:	78 44                	js     800833 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007f2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007f6:	75 21                	jne    800819 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8007f8:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007fd:	8b 40 48             	mov    0x48(%eax),%eax
  800800:	83 ec 04             	sub    $0x4,%esp
  800803:	53                   	push   %ebx
  800804:	50                   	push   %eax
  800805:	68 18 1e 80 00       	push   $0x801e18
  80080a:	e8 03 09 00 00       	call   801112 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80080f:	83 c4 10             	add    $0x10,%esp
  800812:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800817:	eb 23                	jmp    80083c <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800819:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80081c:	8b 52 18             	mov    0x18(%edx),%edx
  80081f:	85 d2                	test   %edx,%edx
  800821:	74 14                	je     800837 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800823:	83 ec 08             	sub    $0x8,%esp
  800826:	ff 75 0c             	pushl  0xc(%ebp)
  800829:	50                   	push   %eax
  80082a:	ff d2                	call   *%edx
  80082c:	89 c2                	mov    %eax,%edx
  80082e:	83 c4 10             	add    $0x10,%esp
  800831:	eb 09                	jmp    80083c <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800833:	89 c2                	mov    %eax,%edx
  800835:	eb 05                	jmp    80083c <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800837:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80083c:	89 d0                	mov    %edx,%eax
  80083e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800841:	c9                   	leave  
  800842:	c3                   	ret    

00800843 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800843:	55                   	push   %ebp
  800844:	89 e5                	mov    %esp,%ebp
  800846:	53                   	push   %ebx
  800847:	83 ec 14             	sub    $0x14,%esp
  80084a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80084d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800850:	50                   	push   %eax
  800851:	ff 75 08             	pushl  0x8(%ebp)
  800854:	e8 6c fb ff ff       	call   8003c5 <fd_lookup>
  800859:	83 c4 08             	add    $0x8,%esp
  80085c:	89 c2                	mov    %eax,%edx
  80085e:	85 c0                	test   %eax,%eax
  800860:	78 58                	js     8008ba <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800862:	83 ec 08             	sub    $0x8,%esp
  800865:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800868:	50                   	push   %eax
  800869:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80086c:	ff 30                	pushl  (%eax)
  80086e:	e8 a8 fb ff ff       	call   80041b <dev_lookup>
  800873:	83 c4 10             	add    $0x10,%esp
  800876:	85 c0                	test   %eax,%eax
  800878:	78 37                	js     8008b1 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80087a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80087d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800881:	74 32                	je     8008b5 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800883:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800886:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80088d:	00 00 00 
	stat->st_isdir = 0;
  800890:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800897:	00 00 00 
	stat->st_dev = dev;
  80089a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008a0:	83 ec 08             	sub    $0x8,%esp
  8008a3:	53                   	push   %ebx
  8008a4:	ff 75 f0             	pushl  -0x10(%ebp)
  8008a7:	ff 50 14             	call   *0x14(%eax)
  8008aa:	89 c2                	mov    %eax,%edx
  8008ac:	83 c4 10             	add    $0x10,%esp
  8008af:	eb 09                	jmp    8008ba <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008b1:	89 c2                	mov    %eax,%edx
  8008b3:	eb 05                	jmp    8008ba <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008b5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008ba:	89 d0                	mov    %edx,%eax
  8008bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008bf:	c9                   	leave  
  8008c0:	c3                   	ret    

008008c1 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008c1:	55                   	push   %ebp
  8008c2:	89 e5                	mov    %esp,%ebp
  8008c4:	56                   	push   %esi
  8008c5:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008c6:	83 ec 08             	sub    $0x8,%esp
  8008c9:	6a 00                	push   $0x0
  8008cb:	ff 75 08             	pushl  0x8(%ebp)
  8008ce:	e8 e3 01 00 00       	call   800ab6 <open>
  8008d3:	89 c3                	mov    %eax,%ebx
  8008d5:	83 c4 10             	add    $0x10,%esp
  8008d8:	85 c0                	test   %eax,%eax
  8008da:	78 1b                	js     8008f7 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008dc:	83 ec 08             	sub    $0x8,%esp
  8008df:	ff 75 0c             	pushl  0xc(%ebp)
  8008e2:	50                   	push   %eax
  8008e3:	e8 5b ff ff ff       	call   800843 <fstat>
  8008e8:	89 c6                	mov    %eax,%esi
	close(fd);
  8008ea:	89 1c 24             	mov    %ebx,(%esp)
  8008ed:	e8 fd fb ff ff       	call   8004ef <close>
	return r;
  8008f2:	83 c4 10             	add    $0x10,%esp
  8008f5:	89 f0                	mov    %esi,%eax
}
  8008f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008fa:	5b                   	pop    %ebx
  8008fb:	5e                   	pop    %esi
  8008fc:	5d                   	pop    %ebp
  8008fd:	c3                   	ret    

008008fe <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008fe:	55                   	push   %ebp
  8008ff:	89 e5                	mov    %esp,%ebp
  800901:	56                   	push   %esi
  800902:	53                   	push   %ebx
  800903:	89 c6                	mov    %eax,%esi
  800905:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800907:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80090e:	75 12                	jne    800922 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800910:	83 ec 0c             	sub    $0xc,%esp
  800913:	6a 01                	push   $0x1
  800915:	e8 8b 11 00 00       	call   801aa5 <ipc_find_env>
  80091a:	a3 00 40 80 00       	mov    %eax,0x804000
  80091f:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800922:	6a 07                	push   $0x7
  800924:	68 00 50 80 00       	push   $0x805000
  800929:	56                   	push   %esi
  80092a:	ff 35 00 40 80 00    	pushl  0x804000
  800930:	e8 1c 11 00 00       	call   801a51 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800935:	83 c4 0c             	add    $0xc,%esp
  800938:	6a 00                	push   $0x0
  80093a:	53                   	push   %ebx
  80093b:	6a 00                	push   $0x0
  80093d:	e8 ba 10 00 00       	call   8019fc <ipc_recv>
}
  800942:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800945:	5b                   	pop    %ebx
  800946:	5e                   	pop    %esi
  800947:	5d                   	pop    %ebp
  800948:	c3                   	ret    

00800949 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800949:	55                   	push   %ebp
  80094a:	89 e5                	mov    %esp,%ebp
  80094c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80094f:	8b 45 08             	mov    0x8(%ebp),%eax
  800952:	8b 40 0c             	mov    0xc(%eax),%eax
  800955:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80095a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80095d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800962:	ba 00 00 00 00       	mov    $0x0,%edx
  800967:	b8 02 00 00 00       	mov    $0x2,%eax
  80096c:	e8 8d ff ff ff       	call   8008fe <fsipc>
}
  800971:	c9                   	leave  
  800972:	c3                   	ret    

00800973 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800973:	55                   	push   %ebp
  800974:	89 e5                	mov    %esp,%ebp
  800976:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800979:	8b 45 08             	mov    0x8(%ebp),%eax
  80097c:	8b 40 0c             	mov    0xc(%eax),%eax
  80097f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800984:	ba 00 00 00 00       	mov    $0x0,%edx
  800989:	b8 06 00 00 00       	mov    $0x6,%eax
  80098e:	e8 6b ff ff ff       	call   8008fe <fsipc>
}
  800993:	c9                   	leave  
  800994:	c3                   	ret    

00800995 <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800995:	55                   	push   %ebp
  800996:	89 e5                	mov    %esp,%ebp
  800998:	53                   	push   %ebx
  800999:	83 ec 04             	sub    $0x4,%esp
  80099c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80099f:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a2:	8b 40 0c             	mov    0xc(%eax),%eax
  8009a5:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8009af:	b8 05 00 00 00       	mov    $0x5,%eax
  8009b4:	e8 45 ff ff ff       	call   8008fe <fsipc>
  8009b9:	85 c0                	test   %eax,%eax
  8009bb:	78 2c                	js     8009e9 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009bd:	83 ec 08             	sub    $0x8,%esp
  8009c0:	68 00 50 80 00       	push   $0x805000
  8009c5:	53                   	push   %ebx
  8009c6:	e8 ea 0c 00 00       	call   8016b5 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009cb:	a1 80 50 80 00       	mov    0x805080,%eax
  8009d0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009d6:	a1 84 50 80 00       	mov    0x805084,%eax
  8009db:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009e1:	83 c4 10             	add    $0x10,%esp
  8009e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009ec:	c9                   	leave  
  8009ed:	c3                   	ret    

008009ee <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009ee:	55                   	push   %ebp
  8009ef:	89 e5                	mov    %esp,%ebp
  8009f1:	83 ec 0c             	sub    $0xc,%esp
  8009f4:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
    
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8009fa:	8b 52 0c             	mov    0xc(%edx),%edx
  8009fd:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = MIN(n, PGSIZE);
  800a03:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a08:	ba 00 10 00 00       	mov    $0x1000,%edx
  800a0d:	0f 47 c2             	cmova  %edx,%eax
  800a10:	a3 04 50 80 00       	mov    %eax,0x805004
    memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  800a15:	50                   	push   %eax
  800a16:	ff 75 0c             	pushl  0xc(%ebp)
  800a19:	68 08 50 80 00       	push   $0x805008
  800a1e:	e8 24 0e 00 00       	call   801847 <memmove>
    int r = fsipc(FSREQ_WRITE, NULL);
  800a23:	ba 00 00 00 00       	mov    $0x0,%edx
  800a28:	b8 04 00 00 00       	mov    $0x4,%eax
  800a2d:	e8 cc fe ff ff       	call   8008fe <fsipc>
    return r;
}
  800a32:	c9                   	leave  
  800a33:	c3                   	ret    

00800a34 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a34:	55                   	push   %ebp
  800a35:	89 e5                	mov    %esp,%ebp
  800a37:	56                   	push   %esi
  800a38:	53                   	push   %ebx
  800a39:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3f:	8b 40 0c             	mov    0xc(%eax),%eax
  800a42:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a47:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a4d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a52:	b8 03 00 00 00       	mov    $0x3,%eax
  800a57:	e8 a2 fe ff ff       	call   8008fe <fsipc>
  800a5c:	89 c3                	mov    %eax,%ebx
  800a5e:	85 c0                	test   %eax,%eax
  800a60:	78 4b                	js     800aad <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a62:	39 c6                	cmp    %eax,%esi
  800a64:	73 16                	jae    800a7c <devfile_read+0x48>
  800a66:	68 84 1e 80 00       	push   $0x801e84
  800a6b:	68 8b 1e 80 00       	push   $0x801e8b
  800a70:	6a 7c                	push   $0x7c
  800a72:	68 a0 1e 80 00       	push   $0x801ea0
  800a77:	e8 bd 05 00 00       	call   801039 <_panic>
	assert(r <= PGSIZE);
  800a7c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a81:	7e 16                	jle    800a99 <devfile_read+0x65>
  800a83:	68 ab 1e 80 00       	push   $0x801eab
  800a88:	68 8b 1e 80 00       	push   $0x801e8b
  800a8d:	6a 7d                	push   $0x7d
  800a8f:	68 a0 1e 80 00       	push   $0x801ea0
  800a94:	e8 a0 05 00 00       	call   801039 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a99:	83 ec 04             	sub    $0x4,%esp
  800a9c:	50                   	push   %eax
  800a9d:	68 00 50 80 00       	push   $0x805000
  800aa2:	ff 75 0c             	pushl  0xc(%ebp)
  800aa5:	e8 9d 0d 00 00       	call   801847 <memmove>
	return r;
  800aaa:	83 c4 10             	add    $0x10,%esp
}
  800aad:	89 d8                	mov    %ebx,%eax
  800aaf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ab2:	5b                   	pop    %ebx
  800ab3:	5e                   	pop    %esi
  800ab4:	5d                   	pop    %ebp
  800ab5:	c3                   	ret    

00800ab6 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800ab6:	55                   	push   %ebp
  800ab7:	89 e5                	mov    %esp,%ebp
  800ab9:	53                   	push   %ebx
  800aba:	83 ec 20             	sub    $0x20,%esp
  800abd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800ac0:	53                   	push   %ebx
  800ac1:	e8 b6 0b 00 00       	call   80167c <strlen>
  800ac6:	83 c4 10             	add    $0x10,%esp
  800ac9:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ace:	7f 67                	jg     800b37 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ad0:	83 ec 0c             	sub    $0xc,%esp
  800ad3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ad6:	50                   	push   %eax
  800ad7:	e8 9a f8 ff ff       	call   800376 <fd_alloc>
  800adc:	83 c4 10             	add    $0x10,%esp
		return r;
  800adf:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ae1:	85 c0                	test   %eax,%eax
  800ae3:	78 57                	js     800b3c <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800ae5:	83 ec 08             	sub    $0x8,%esp
  800ae8:	53                   	push   %ebx
  800ae9:	68 00 50 80 00       	push   $0x805000
  800aee:	e8 c2 0b 00 00       	call   8016b5 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800af3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af6:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800afb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800afe:	b8 01 00 00 00       	mov    $0x1,%eax
  800b03:	e8 f6 fd ff ff       	call   8008fe <fsipc>
  800b08:	89 c3                	mov    %eax,%ebx
  800b0a:	83 c4 10             	add    $0x10,%esp
  800b0d:	85 c0                	test   %eax,%eax
  800b0f:	79 14                	jns    800b25 <open+0x6f>
		fd_close(fd, 0);
  800b11:	83 ec 08             	sub    $0x8,%esp
  800b14:	6a 00                	push   $0x0
  800b16:	ff 75 f4             	pushl  -0xc(%ebp)
  800b19:	e8 50 f9 ff ff       	call   80046e <fd_close>
		return r;
  800b1e:	83 c4 10             	add    $0x10,%esp
  800b21:	89 da                	mov    %ebx,%edx
  800b23:	eb 17                	jmp    800b3c <open+0x86>
	}

	return fd2num(fd);
  800b25:	83 ec 0c             	sub    $0xc,%esp
  800b28:	ff 75 f4             	pushl  -0xc(%ebp)
  800b2b:	e8 1f f8 ff ff       	call   80034f <fd2num>
  800b30:	89 c2                	mov    %eax,%edx
  800b32:	83 c4 10             	add    $0x10,%esp
  800b35:	eb 05                	jmp    800b3c <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b37:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b3c:	89 d0                	mov    %edx,%eax
  800b3e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b41:	c9                   	leave  
  800b42:	c3                   	ret    

00800b43 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b43:	55                   	push   %ebp
  800b44:	89 e5                	mov    %esp,%ebp
  800b46:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b49:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4e:	b8 08 00 00 00       	mov    $0x8,%eax
  800b53:	e8 a6 fd ff ff       	call   8008fe <fsipc>
}
  800b58:	c9                   	leave  
  800b59:	c3                   	ret    

00800b5a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b5a:	55                   	push   %ebp
  800b5b:	89 e5                	mov    %esp,%ebp
  800b5d:	56                   	push   %esi
  800b5e:	53                   	push   %ebx
  800b5f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b62:	83 ec 0c             	sub    $0xc,%esp
  800b65:	ff 75 08             	pushl  0x8(%ebp)
  800b68:	e8 f2 f7 ff ff       	call   80035f <fd2data>
  800b6d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b6f:	83 c4 08             	add    $0x8,%esp
  800b72:	68 b7 1e 80 00       	push   $0x801eb7
  800b77:	53                   	push   %ebx
  800b78:	e8 38 0b 00 00       	call   8016b5 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b7d:	8b 46 04             	mov    0x4(%esi),%eax
  800b80:	2b 06                	sub    (%esi),%eax
  800b82:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b88:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b8f:	00 00 00 
	stat->st_dev = &devpipe;
  800b92:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b99:	30 80 00 
	return 0;
}
  800b9c:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ba4:	5b                   	pop    %ebx
  800ba5:	5e                   	pop    %esi
  800ba6:	5d                   	pop    %ebp
  800ba7:	c3                   	ret    

00800ba8 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800ba8:	55                   	push   %ebp
  800ba9:	89 e5                	mov    %esp,%ebp
  800bab:	53                   	push   %ebx
  800bac:	83 ec 0c             	sub    $0xc,%esp
  800baf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bb2:	53                   	push   %ebx
  800bb3:	6a 00                	push   $0x0
  800bb5:	e8 29 f6 ff ff       	call   8001e3 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bba:	89 1c 24             	mov    %ebx,(%esp)
  800bbd:	e8 9d f7 ff ff       	call   80035f <fd2data>
  800bc2:	83 c4 08             	add    $0x8,%esp
  800bc5:	50                   	push   %eax
  800bc6:	6a 00                	push   $0x0
  800bc8:	e8 16 f6 ff ff       	call   8001e3 <sys_page_unmap>
}
  800bcd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bd0:	c9                   	leave  
  800bd1:	c3                   	ret    

00800bd2 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bd2:	55                   	push   %ebp
  800bd3:	89 e5                	mov    %esp,%ebp
  800bd5:	57                   	push   %edi
  800bd6:	56                   	push   %esi
  800bd7:	53                   	push   %ebx
  800bd8:	83 ec 1c             	sub    $0x1c,%esp
  800bdb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800bde:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800be0:	a1 04 40 80 00       	mov    0x804004,%eax
  800be5:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800be8:	83 ec 0c             	sub    $0xc,%esp
  800beb:	ff 75 e0             	pushl  -0x20(%ebp)
  800bee:	e8 eb 0e 00 00       	call   801ade <pageref>
  800bf3:	89 c3                	mov    %eax,%ebx
  800bf5:	89 3c 24             	mov    %edi,(%esp)
  800bf8:	e8 e1 0e 00 00       	call   801ade <pageref>
  800bfd:	83 c4 10             	add    $0x10,%esp
  800c00:	39 c3                	cmp    %eax,%ebx
  800c02:	0f 94 c1             	sete   %cl
  800c05:	0f b6 c9             	movzbl %cl,%ecx
  800c08:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c0b:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c11:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c14:	39 ce                	cmp    %ecx,%esi
  800c16:	74 1b                	je     800c33 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c18:	39 c3                	cmp    %eax,%ebx
  800c1a:	75 c4                	jne    800be0 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c1c:	8b 42 58             	mov    0x58(%edx),%eax
  800c1f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c22:	50                   	push   %eax
  800c23:	56                   	push   %esi
  800c24:	68 be 1e 80 00       	push   $0x801ebe
  800c29:	e8 e4 04 00 00       	call   801112 <cprintf>
  800c2e:	83 c4 10             	add    $0x10,%esp
  800c31:	eb ad                	jmp    800be0 <_pipeisclosed+0xe>
	}
}
  800c33:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c39:	5b                   	pop    %ebx
  800c3a:	5e                   	pop    %esi
  800c3b:	5f                   	pop    %edi
  800c3c:	5d                   	pop    %ebp
  800c3d:	c3                   	ret    

00800c3e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c3e:	55                   	push   %ebp
  800c3f:	89 e5                	mov    %esp,%ebp
  800c41:	57                   	push   %edi
  800c42:	56                   	push   %esi
  800c43:	53                   	push   %ebx
  800c44:	83 ec 28             	sub    $0x28,%esp
  800c47:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c4a:	56                   	push   %esi
  800c4b:	e8 0f f7 ff ff       	call   80035f <fd2data>
  800c50:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c52:	83 c4 10             	add    $0x10,%esp
  800c55:	bf 00 00 00 00       	mov    $0x0,%edi
  800c5a:	eb 4b                	jmp    800ca7 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c5c:	89 da                	mov    %ebx,%edx
  800c5e:	89 f0                	mov    %esi,%eax
  800c60:	e8 6d ff ff ff       	call   800bd2 <_pipeisclosed>
  800c65:	85 c0                	test   %eax,%eax
  800c67:	75 48                	jne    800cb1 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c69:	e8 d1 f4 ff ff       	call   80013f <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c6e:	8b 43 04             	mov    0x4(%ebx),%eax
  800c71:	8b 0b                	mov    (%ebx),%ecx
  800c73:	8d 51 20             	lea    0x20(%ecx),%edx
  800c76:	39 d0                	cmp    %edx,%eax
  800c78:	73 e2                	jae    800c5c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c81:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c84:	89 c2                	mov    %eax,%edx
  800c86:	c1 fa 1f             	sar    $0x1f,%edx
  800c89:	89 d1                	mov    %edx,%ecx
  800c8b:	c1 e9 1b             	shr    $0x1b,%ecx
  800c8e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c91:	83 e2 1f             	and    $0x1f,%edx
  800c94:	29 ca                	sub    %ecx,%edx
  800c96:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800c9a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c9e:	83 c0 01             	add    $0x1,%eax
  800ca1:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ca4:	83 c7 01             	add    $0x1,%edi
  800ca7:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800caa:	75 c2                	jne    800c6e <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cac:	8b 45 10             	mov    0x10(%ebp),%eax
  800caf:	eb 05                	jmp    800cb6 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cb1:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cb6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb9:	5b                   	pop    %ebx
  800cba:	5e                   	pop    %esi
  800cbb:	5f                   	pop    %edi
  800cbc:	5d                   	pop    %ebp
  800cbd:	c3                   	ret    

00800cbe <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cbe:	55                   	push   %ebp
  800cbf:	89 e5                	mov    %esp,%ebp
  800cc1:	57                   	push   %edi
  800cc2:	56                   	push   %esi
  800cc3:	53                   	push   %ebx
  800cc4:	83 ec 18             	sub    $0x18,%esp
  800cc7:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800cca:	57                   	push   %edi
  800ccb:	e8 8f f6 ff ff       	call   80035f <fd2data>
  800cd0:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cd2:	83 c4 10             	add    $0x10,%esp
  800cd5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cda:	eb 3d                	jmp    800d19 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800cdc:	85 db                	test   %ebx,%ebx
  800cde:	74 04                	je     800ce4 <devpipe_read+0x26>
				return i;
  800ce0:	89 d8                	mov    %ebx,%eax
  800ce2:	eb 44                	jmp    800d28 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800ce4:	89 f2                	mov    %esi,%edx
  800ce6:	89 f8                	mov    %edi,%eax
  800ce8:	e8 e5 fe ff ff       	call   800bd2 <_pipeisclosed>
  800ced:	85 c0                	test   %eax,%eax
  800cef:	75 32                	jne    800d23 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800cf1:	e8 49 f4 ff ff       	call   80013f <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800cf6:	8b 06                	mov    (%esi),%eax
  800cf8:	3b 46 04             	cmp    0x4(%esi),%eax
  800cfb:	74 df                	je     800cdc <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800cfd:	99                   	cltd   
  800cfe:	c1 ea 1b             	shr    $0x1b,%edx
  800d01:	01 d0                	add    %edx,%eax
  800d03:	83 e0 1f             	and    $0x1f,%eax
  800d06:	29 d0                	sub    %edx,%eax
  800d08:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d0d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d10:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d13:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d16:	83 c3 01             	add    $0x1,%ebx
  800d19:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d1c:	75 d8                	jne    800cf6 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d1e:	8b 45 10             	mov    0x10(%ebp),%eax
  800d21:	eb 05                	jmp    800d28 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d23:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d28:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2b:	5b                   	pop    %ebx
  800d2c:	5e                   	pop    %esi
  800d2d:	5f                   	pop    %edi
  800d2e:	5d                   	pop    %ebp
  800d2f:	c3                   	ret    

00800d30 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	56                   	push   %esi
  800d34:	53                   	push   %ebx
  800d35:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d38:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d3b:	50                   	push   %eax
  800d3c:	e8 35 f6 ff ff       	call   800376 <fd_alloc>
  800d41:	83 c4 10             	add    $0x10,%esp
  800d44:	89 c2                	mov    %eax,%edx
  800d46:	85 c0                	test   %eax,%eax
  800d48:	0f 88 2c 01 00 00    	js     800e7a <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d4e:	83 ec 04             	sub    $0x4,%esp
  800d51:	68 07 04 00 00       	push   $0x407
  800d56:	ff 75 f4             	pushl  -0xc(%ebp)
  800d59:	6a 00                	push   $0x0
  800d5b:	e8 fe f3 ff ff       	call   80015e <sys_page_alloc>
  800d60:	83 c4 10             	add    $0x10,%esp
  800d63:	89 c2                	mov    %eax,%edx
  800d65:	85 c0                	test   %eax,%eax
  800d67:	0f 88 0d 01 00 00    	js     800e7a <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d6d:	83 ec 0c             	sub    $0xc,%esp
  800d70:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d73:	50                   	push   %eax
  800d74:	e8 fd f5 ff ff       	call   800376 <fd_alloc>
  800d79:	89 c3                	mov    %eax,%ebx
  800d7b:	83 c4 10             	add    $0x10,%esp
  800d7e:	85 c0                	test   %eax,%eax
  800d80:	0f 88 e2 00 00 00    	js     800e68 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d86:	83 ec 04             	sub    $0x4,%esp
  800d89:	68 07 04 00 00       	push   $0x407
  800d8e:	ff 75 f0             	pushl  -0x10(%ebp)
  800d91:	6a 00                	push   $0x0
  800d93:	e8 c6 f3 ff ff       	call   80015e <sys_page_alloc>
  800d98:	89 c3                	mov    %eax,%ebx
  800d9a:	83 c4 10             	add    $0x10,%esp
  800d9d:	85 c0                	test   %eax,%eax
  800d9f:	0f 88 c3 00 00 00    	js     800e68 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800da5:	83 ec 0c             	sub    $0xc,%esp
  800da8:	ff 75 f4             	pushl  -0xc(%ebp)
  800dab:	e8 af f5 ff ff       	call   80035f <fd2data>
  800db0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800db2:	83 c4 0c             	add    $0xc,%esp
  800db5:	68 07 04 00 00       	push   $0x407
  800dba:	50                   	push   %eax
  800dbb:	6a 00                	push   $0x0
  800dbd:	e8 9c f3 ff ff       	call   80015e <sys_page_alloc>
  800dc2:	89 c3                	mov    %eax,%ebx
  800dc4:	83 c4 10             	add    $0x10,%esp
  800dc7:	85 c0                	test   %eax,%eax
  800dc9:	0f 88 89 00 00 00    	js     800e58 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dcf:	83 ec 0c             	sub    $0xc,%esp
  800dd2:	ff 75 f0             	pushl  -0x10(%ebp)
  800dd5:	e8 85 f5 ff ff       	call   80035f <fd2data>
  800dda:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800de1:	50                   	push   %eax
  800de2:	6a 00                	push   $0x0
  800de4:	56                   	push   %esi
  800de5:	6a 00                	push   $0x0
  800de7:	e8 b5 f3 ff ff       	call   8001a1 <sys_page_map>
  800dec:	89 c3                	mov    %eax,%ebx
  800dee:	83 c4 20             	add    $0x20,%esp
  800df1:	85 c0                	test   %eax,%eax
  800df3:	78 55                	js     800e4a <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800df5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800dfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dfe:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e00:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e03:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e0a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e10:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e13:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e15:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e18:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e1f:	83 ec 0c             	sub    $0xc,%esp
  800e22:	ff 75 f4             	pushl  -0xc(%ebp)
  800e25:	e8 25 f5 ff ff       	call   80034f <fd2num>
  800e2a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e2d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e2f:	83 c4 04             	add    $0x4,%esp
  800e32:	ff 75 f0             	pushl  -0x10(%ebp)
  800e35:	e8 15 f5 ff ff       	call   80034f <fd2num>
  800e3a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e3d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e40:	83 c4 10             	add    $0x10,%esp
  800e43:	ba 00 00 00 00       	mov    $0x0,%edx
  800e48:	eb 30                	jmp    800e7a <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e4a:	83 ec 08             	sub    $0x8,%esp
  800e4d:	56                   	push   %esi
  800e4e:	6a 00                	push   $0x0
  800e50:	e8 8e f3 ff ff       	call   8001e3 <sys_page_unmap>
  800e55:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e58:	83 ec 08             	sub    $0x8,%esp
  800e5b:	ff 75 f0             	pushl  -0x10(%ebp)
  800e5e:	6a 00                	push   $0x0
  800e60:	e8 7e f3 ff ff       	call   8001e3 <sys_page_unmap>
  800e65:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e68:	83 ec 08             	sub    $0x8,%esp
  800e6b:	ff 75 f4             	pushl  -0xc(%ebp)
  800e6e:	6a 00                	push   $0x0
  800e70:	e8 6e f3 ff ff       	call   8001e3 <sys_page_unmap>
  800e75:	83 c4 10             	add    $0x10,%esp
  800e78:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e7a:	89 d0                	mov    %edx,%eax
  800e7c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e7f:	5b                   	pop    %ebx
  800e80:	5e                   	pop    %esi
  800e81:	5d                   	pop    %ebp
  800e82:	c3                   	ret    

00800e83 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e83:	55                   	push   %ebp
  800e84:	89 e5                	mov    %esp,%ebp
  800e86:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e89:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e8c:	50                   	push   %eax
  800e8d:	ff 75 08             	pushl  0x8(%ebp)
  800e90:	e8 30 f5 ff ff       	call   8003c5 <fd_lookup>
  800e95:	83 c4 10             	add    $0x10,%esp
  800e98:	85 c0                	test   %eax,%eax
  800e9a:	78 18                	js     800eb4 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e9c:	83 ec 0c             	sub    $0xc,%esp
  800e9f:	ff 75 f4             	pushl  -0xc(%ebp)
  800ea2:	e8 b8 f4 ff ff       	call   80035f <fd2data>
	return _pipeisclosed(fd, p);
  800ea7:	89 c2                	mov    %eax,%edx
  800ea9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eac:	e8 21 fd ff ff       	call   800bd2 <_pipeisclosed>
  800eb1:	83 c4 10             	add    $0x10,%esp
}
  800eb4:	c9                   	leave  
  800eb5:	c3                   	ret    

00800eb6 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800eb6:	55                   	push   %ebp
  800eb7:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800eb9:	b8 00 00 00 00       	mov    $0x0,%eax
  800ebe:	5d                   	pop    %ebp
  800ebf:	c3                   	ret    

00800ec0 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ec0:	55                   	push   %ebp
  800ec1:	89 e5                	mov    %esp,%ebp
  800ec3:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ec6:	68 d6 1e 80 00       	push   $0x801ed6
  800ecb:	ff 75 0c             	pushl  0xc(%ebp)
  800ece:	e8 e2 07 00 00       	call   8016b5 <strcpy>
	return 0;
}
  800ed3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed8:	c9                   	leave  
  800ed9:	c3                   	ret    

00800eda <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800eda:	55                   	push   %ebp
  800edb:	89 e5                	mov    %esp,%ebp
  800edd:	57                   	push   %edi
  800ede:	56                   	push   %esi
  800edf:	53                   	push   %ebx
  800ee0:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ee6:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800eeb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ef1:	eb 2d                	jmp    800f20 <devcons_write+0x46>
		m = n - tot;
  800ef3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ef6:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800ef8:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800efb:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f00:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f03:	83 ec 04             	sub    $0x4,%esp
  800f06:	53                   	push   %ebx
  800f07:	03 45 0c             	add    0xc(%ebp),%eax
  800f0a:	50                   	push   %eax
  800f0b:	57                   	push   %edi
  800f0c:	e8 36 09 00 00       	call   801847 <memmove>
		sys_cputs(buf, m);
  800f11:	83 c4 08             	add    $0x8,%esp
  800f14:	53                   	push   %ebx
  800f15:	57                   	push   %edi
  800f16:	e8 87 f1 ff ff       	call   8000a2 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f1b:	01 de                	add    %ebx,%esi
  800f1d:	83 c4 10             	add    $0x10,%esp
  800f20:	89 f0                	mov    %esi,%eax
  800f22:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f25:	72 cc                	jb     800ef3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f27:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f2a:	5b                   	pop    %ebx
  800f2b:	5e                   	pop    %esi
  800f2c:	5f                   	pop    %edi
  800f2d:	5d                   	pop    %ebp
  800f2e:	c3                   	ret    

00800f2f <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f2f:	55                   	push   %ebp
  800f30:	89 e5                	mov    %esp,%ebp
  800f32:	83 ec 08             	sub    $0x8,%esp
  800f35:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f3a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f3e:	74 2a                	je     800f6a <devcons_read+0x3b>
  800f40:	eb 05                	jmp    800f47 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f42:	e8 f8 f1 ff ff       	call   80013f <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f47:	e8 74 f1 ff ff       	call   8000c0 <sys_cgetc>
  800f4c:	85 c0                	test   %eax,%eax
  800f4e:	74 f2                	je     800f42 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f50:	85 c0                	test   %eax,%eax
  800f52:	78 16                	js     800f6a <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f54:	83 f8 04             	cmp    $0x4,%eax
  800f57:	74 0c                	je     800f65 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f59:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f5c:	88 02                	mov    %al,(%edx)
	return 1;
  800f5e:	b8 01 00 00 00       	mov    $0x1,%eax
  800f63:	eb 05                	jmp    800f6a <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f65:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f6a:	c9                   	leave  
  800f6b:	c3                   	ret    

00800f6c <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f6c:	55                   	push   %ebp
  800f6d:	89 e5                	mov    %esp,%ebp
  800f6f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f72:	8b 45 08             	mov    0x8(%ebp),%eax
  800f75:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f78:	6a 01                	push   $0x1
  800f7a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f7d:	50                   	push   %eax
  800f7e:	e8 1f f1 ff ff       	call   8000a2 <sys_cputs>
}
  800f83:	83 c4 10             	add    $0x10,%esp
  800f86:	c9                   	leave  
  800f87:	c3                   	ret    

00800f88 <getchar>:

int
getchar(void)
{
  800f88:	55                   	push   %ebp
  800f89:	89 e5                	mov    %esp,%ebp
  800f8b:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f8e:	6a 01                	push   $0x1
  800f90:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f93:	50                   	push   %eax
  800f94:	6a 00                	push   $0x0
  800f96:	e8 90 f6 ff ff       	call   80062b <read>
	if (r < 0)
  800f9b:	83 c4 10             	add    $0x10,%esp
  800f9e:	85 c0                	test   %eax,%eax
  800fa0:	78 0f                	js     800fb1 <getchar+0x29>
		return r;
	if (r < 1)
  800fa2:	85 c0                	test   %eax,%eax
  800fa4:	7e 06                	jle    800fac <getchar+0x24>
		return -E_EOF;
	return c;
  800fa6:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800faa:	eb 05                	jmp    800fb1 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fac:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fb1:	c9                   	leave  
  800fb2:	c3                   	ret    

00800fb3 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800fb3:	55                   	push   %ebp
  800fb4:	89 e5                	mov    %esp,%ebp
  800fb6:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fb9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fbc:	50                   	push   %eax
  800fbd:	ff 75 08             	pushl  0x8(%ebp)
  800fc0:	e8 00 f4 ff ff       	call   8003c5 <fd_lookup>
  800fc5:	83 c4 10             	add    $0x10,%esp
  800fc8:	85 c0                	test   %eax,%eax
  800fca:	78 11                	js     800fdd <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800fcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fcf:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fd5:	39 10                	cmp    %edx,(%eax)
  800fd7:	0f 94 c0             	sete   %al
  800fda:	0f b6 c0             	movzbl %al,%eax
}
  800fdd:	c9                   	leave  
  800fde:	c3                   	ret    

00800fdf <opencons>:

int
opencons(void)
{
  800fdf:	55                   	push   %ebp
  800fe0:	89 e5                	mov    %esp,%ebp
  800fe2:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fe5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fe8:	50                   	push   %eax
  800fe9:	e8 88 f3 ff ff       	call   800376 <fd_alloc>
  800fee:	83 c4 10             	add    $0x10,%esp
		return r;
  800ff1:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800ff3:	85 c0                	test   %eax,%eax
  800ff5:	78 3e                	js     801035 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800ff7:	83 ec 04             	sub    $0x4,%esp
  800ffa:	68 07 04 00 00       	push   $0x407
  800fff:	ff 75 f4             	pushl  -0xc(%ebp)
  801002:	6a 00                	push   $0x0
  801004:	e8 55 f1 ff ff       	call   80015e <sys_page_alloc>
  801009:	83 c4 10             	add    $0x10,%esp
		return r;
  80100c:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80100e:	85 c0                	test   %eax,%eax
  801010:	78 23                	js     801035 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801012:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801018:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80101b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80101d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801020:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801027:	83 ec 0c             	sub    $0xc,%esp
  80102a:	50                   	push   %eax
  80102b:	e8 1f f3 ff ff       	call   80034f <fd2num>
  801030:	89 c2                	mov    %eax,%edx
  801032:	83 c4 10             	add    $0x10,%esp
}
  801035:	89 d0                	mov    %edx,%eax
  801037:	c9                   	leave  
  801038:	c3                   	ret    

00801039 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801039:	55                   	push   %ebp
  80103a:	89 e5                	mov    %esp,%ebp
  80103c:	56                   	push   %esi
  80103d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80103e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801041:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801047:	e8 d4 f0 ff ff       	call   800120 <sys_getenvid>
  80104c:	83 ec 0c             	sub    $0xc,%esp
  80104f:	ff 75 0c             	pushl  0xc(%ebp)
  801052:	ff 75 08             	pushl  0x8(%ebp)
  801055:	56                   	push   %esi
  801056:	50                   	push   %eax
  801057:	68 e4 1e 80 00       	push   $0x801ee4
  80105c:	e8 b1 00 00 00       	call   801112 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801061:	83 c4 18             	add    $0x18,%esp
  801064:	53                   	push   %ebx
  801065:	ff 75 10             	pushl  0x10(%ebp)
  801068:	e8 54 00 00 00       	call   8010c1 <vcprintf>
	cprintf("\n");
  80106d:	c7 04 24 cf 1e 80 00 	movl   $0x801ecf,(%esp)
  801074:	e8 99 00 00 00       	call   801112 <cprintf>
  801079:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80107c:	cc                   	int3   
  80107d:	eb fd                	jmp    80107c <_panic+0x43>

0080107f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80107f:	55                   	push   %ebp
  801080:	89 e5                	mov    %esp,%ebp
  801082:	53                   	push   %ebx
  801083:	83 ec 04             	sub    $0x4,%esp
  801086:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801089:	8b 13                	mov    (%ebx),%edx
  80108b:	8d 42 01             	lea    0x1(%edx),%eax
  80108e:	89 03                	mov    %eax,(%ebx)
  801090:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801093:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801097:	3d ff 00 00 00       	cmp    $0xff,%eax
  80109c:	75 1a                	jne    8010b8 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80109e:	83 ec 08             	sub    $0x8,%esp
  8010a1:	68 ff 00 00 00       	push   $0xff
  8010a6:	8d 43 08             	lea    0x8(%ebx),%eax
  8010a9:	50                   	push   %eax
  8010aa:	e8 f3 ef ff ff       	call   8000a2 <sys_cputs>
		b->idx = 0;
  8010af:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010b5:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010b8:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010bf:	c9                   	leave  
  8010c0:	c3                   	ret    

008010c1 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010c1:	55                   	push   %ebp
  8010c2:	89 e5                	mov    %esp,%ebp
  8010c4:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010ca:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010d1:	00 00 00 
	b.cnt = 0;
  8010d4:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010db:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010de:	ff 75 0c             	pushl  0xc(%ebp)
  8010e1:	ff 75 08             	pushl  0x8(%ebp)
  8010e4:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010ea:	50                   	push   %eax
  8010eb:	68 7f 10 80 00       	push   $0x80107f
  8010f0:	e8 54 01 00 00       	call   801249 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010f5:	83 c4 08             	add    $0x8,%esp
  8010f8:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010fe:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801104:	50                   	push   %eax
  801105:	e8 98 ef ff ff       	call   8000a2 <sys_cputs>

	return b.cnt;
}
  80110a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801110:	c9                   	leave  
  801111:	c3                   	ret    

00801112 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801112:	55                   	push   %ebp
  801113:	89 e5                	mov    %esp,%ebp
  801115:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801118:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80111b:	50                   	push   %eax
  80111c:	ff 75 08             	pushl  0x8(%ebp)
  80111f:	e8 9d ff ff ff       	call   8010c1 <vcprintf>
	va_end(ap);

	return cnt;
}
  801124:	c9                   	leave  
  801125:	c3                   	ret    

00801126 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801126:	55                   	push   %ebp
  801127:	89 e5                	mov    %esp,%ebp
  801129:	57                   	push   %edi
  80112a:	56                   	push   %esi
  80112b:	53                   	push   %ebx
  80112c:	83 ec 1c             	sub    $0x1c,%esp
  80112f:	89 c7                	mov    %eax,%edi
  801131:	89 d6                	mov    %edx,%esi
  801133:	8b 45 08             	mov    0x8(%ebp),%eax
  801136:	8b 55 0c             	mov    0xc(%ebp),%edx
  801139:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80113c:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80113f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801142:	bb 00 00 00 00       	mov    $0x0,%ebx
  801147:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80114a:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80114d:	39 d3                	cmp    %edx,%ebx
  80114f:	72 05                	jb     801156 <printnum+0x30>
  801151:	39 45 10             	cmp    %eax,0x10(%ebp)
  801154:	77 45                	ja     80119b <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801156:	83 ec 0c             	sub    $0xc,%esp
  801159:	ff 75 18             	pushl  0x18(%ebp)
  80115c:	8b 45 14             	mov    0x14(%ebp),%eax
  80115f:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801162:	53                   	push   %ebx
  801163:	ff 75 10             	pushl  0x10(%ebp)
  801166:	83 ec 08             	sub    $0x8,%esp
  801169:	ff 75 e4             	pushl  -0x1c(%ebp)
  80116c:	ff 75 e0             	pushl  -0x20(%ebp)
  80116f:	ff 75 dc             	pushl  -0x24(%ebp)
  801172:	ff 75 d8             	pushl  -0x28(%ebp)
  801175:	e8 a6 09 00 00       	call   801b20 <__udivdi3>
  80117a:	83 c4 18             	add    $0x18,%esp
  80117d:	52                   	push   %edx
  80117e:	50                   	push   %eax
  80117f:	89 f2                	mov    %esi,%edx
  801181:	89 f8                	mov    %edi,%eax
  801183:	e8 9e ff ff ff       	call   801126 <printnum>
  801188:	83 c4 20             	add    $0x20,%esp
  80118b:	eb 18                	jmp    8011a5 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80118d:	83 ec 08             	sub    $0x8,%esp
  801190:	56                   	push   %esi
  801191:	ff 75 18             	pushl  0x18(%ebp)
  801194:	ff d7                	call   *%edi
  801196:	83 c4 10             	add    $0x10,%esp
  801199:	eb 03                	jmp    80119e <printnum+0x78>
  80119b:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80119e:	83 eb 01             	sub    $0x1,%ebx
  8011a1:	85 db                	test   %ebx,%ebx
  8011a3:	7f e8                	jg     80118d <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011a5:	83 ec 08             	sub    $0x8,%esp
  8011a8:	56                   	push   %esi
  8011a9:	83 ec 04             	sub    $0x4,%esp
  8011ac:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011af:	ff 75 e0             	pushl  -0x20(%ebp)
  8011b2:	ff 75 dc             	pushl  -0x24(%ebp)
  8011b5:	ff 75 d8             	pushl  -0x28(%ebp)
  8011b8:	e8 93 0a 00 00       	call   801c50 <__umoddi3>
  8011bd:	83 c4 14             	add    $0x14,%esp
  8011c0:	0f be 80 07 1f 80 00 	movsbl 0x801f07(%eax),%eax
  8011c7:	50                   	push   %eax
  8011c8:	ff d7                	call   *%edi
}
  8011ca:	83 c4 10             	add    $0x10,%esp
  8011cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011d0:	5b                   	pop    %ebx
  8011d1:	5e                   	pop    %esi
  8011d2:	5f                   	pop    %edi
  8011d3:	5d                   	pop    %ebp
  8011d4:	c3                   	ret    

008011d5 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8011d5:	55                   	push   %ebp
  8011d6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011d8:	83 fa 01             	cmp    $0x1,%edx
  8011db:	7e 0e                	jle    8011eb <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8011dd:	8b 10                	mov    (%eax),%edx
  8011df:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011e2:	89 08                	mov    %ecx,(%eax)
  8011e4:	8b 02                	mov    (%edx),%eax
  8011e6:	8b 52 04             	mov    0x4(%edx),%edx
  8011e9:	eb 22                	jmp    80120d <getuint+0x38>
	else if (lflag)
  8011eb:	85 d2                	test   %edx,%edx
  8011ed:	74 10                	je     8011ff <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8011ef:	8b 10                	mov    (%eax),%edx
  8011f1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011f4:	89 08                	mov    %ecx,(%eax)
  8011f6:	8b 02                	mov    (%edx),%eax
  8011f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8011fd:	eb 0e                	jmp    80120d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8011ff:	8b 10                	mov    (%eax),%edx
  801201:	8d 4a 04             	lea    0x4(%edx),%ecx
  801204:	89 08                	mov    %ecx,(%eax)
  801206:	8b 02                	mov    (%edx),%eax
  801208:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80120d:	5d                   	pop    %ebp
  80120e:	c3                   	ret    

0080120f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80120f:	55                   	push   %ebp
  801210:	89 e5                	mov    %esp,%ebp
  801212:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801215:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801219:	8b 10                	mov    (%eax),%edx
  80121b:	3b 50 04             	cmp    0x4(%eax),%edx
  80121e:	73 0a                	jae    80122a <sprintputch+0x1b>
		*b->buf++ = ch;
  801220:	8d 4a 01             	lea    0x1(%edx),%ecx
  801223:	89 08                	mov    %ecx,(%eax)
  801225:	8b 45 08             	mov    0x8(%ebp),%eax
  801228:	88 02                	mov    %al,(%edx)
}
  80122a:	5d                   	pop    %ebp
  80122b:	c3                   	ret    

0080122c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80122c:	55                   	push   %ebp
  80122d:	89 e5                	mov    %esp,%ebp
  80122f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801232:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801235:	50                   	push   %eax
  801236:	ff 75 10             	pushl  0x10(%ebp)
  801239:	ff 75 0c             	pushl  0xc(%ebp)
  80123c:	ff 75 08             	pushl  0x8(%ebp)
  80123f:	e8 05 00 00 00       	call   801249 <vprintfmt>
	va_end(ap);
}
  801244:	83 c4 10             	add    $0x10,%esp
  801247:	c9                   	leave  
  801248:	c3                   	ret    

00801249 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801249:	55                   	push   %ebp
  80124a:	89 e5                	mov    %esp,%ebp
  80124c:	57                   	push   %edi
  80124d:	56                   	push   %esi
  80124e:	53                   	push   %ebx
  80124f:	83 ec 2c             	sub    $0x2c,%esp
  801252:	8b 75 08             	mov    0x8(%ebp),%esi
  801255:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801258:	8b 7d 10             	mov    0x10(%ebp),%edi
  80125b:	eb 12                	jmp    80126f <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80125d:	85 c0                	test   %eax,%eax
  80125f:	0f 84 a7 03 00 00    	je     80160c <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
  801265:	83 ec 08             	sub    $0x8,%esp
  801268:	53                   	push   %ebx
  801269:	50                   	push   %eax
  80126a:	ff d6                	call   *%esi
  80126c:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80126f:	83 c7 01             	add    $0x1,%edi
  801272:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801276:	83 f8 25             	cmp    $0x25,%eax
  801279:	75 e2                	jne    80125d <vprintfmt+0x14>
  80127b:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80127f:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801286:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80128d:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801294:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80129b:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012a0:	eb 07                	jmp    8012a9 <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8012a5:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012a9:	8d 47 01             	lea    0x1(%edi),%eax
  8012ac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012af:	0f b6 07             	movzbl (%edi),%eax
  8012b2:	0f b6 d0             	movzbl %al,%edx
  8012b5:	83 e8 23             	sub    $0x23,%eax
  8012b8:	3c 55                	cmp    $0x55,%al
  8012ba:	0f 87 31 03 00 00    	ja     8015f1 <vprintfmt+0x3a8>
  8012c0:	0f b6 c0             	movzbl %al,%eax
  8012c3:	ff 24 85 40 20 80 00 	jmp    *0x802040(,%eax,4)
  8012ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8012cd:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8012d1:	eb d6                	jmp    8012a9 <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8012db:	89 75 08             	mov    %esi,0x8(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012de:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8012e1:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8012e5:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8012e8:	8d 72 d0             	lea    -0x30(%edx),%esi
  8012eb:	83 fe 09             	cmp    $0x9,%esi
  8012ee:	77 34                	ja     801324 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012f0:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8012f3:	eb e9                	jmp    8012de <vprintfmt+0x95>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8012f8:	8d 50 04             	lea    0x4(%eax),%edx
  8012fb:	89 55 14             	mov    %edx,0x14(%ebp)
  8012fe:	8b 00                	mov    (%eax),%eax
  801300:	89 45 cc             	mov    %eax,-0x34(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801303:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801306:	eb 22                	jmp    80132a <vprintfmt+0xe1>
  801308:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80130b:	85 c0                	test   %eax,%eax
  80130d:	0f 48 c1             	cmovs  %ecx,%eax
  801310:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801313:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801316:	eb 91                	jmp    8012a9 <vprintfmt+0x60>
  801318:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80131b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801322:	eb 85                	jmp    8012a9 <vprintfmt+0x60>
  801324:	89 45 cc             	mov    %eax,-0x34(%ebp)
  801327:	8b 75 08             	mov    0x8(%ebp),%esi

		process_precision:
			if (width < 0)
  80132a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80132e:	0f 89 75 ff ff ff    	jns    8012a9 <vprintfmt+0x60>
				width = precision, precision = -1;
  801334:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801337:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80133a:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  801341:	e9 63 ff ff ff       	jmp    8012a9 <vprintfmt+0x60>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801346:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80134a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80134d:	e9 57 ff ff ff       	jmp    8012a9 <vprintfmt+0x60>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801352:	8b 45 14             	mov    0x14(%ebp),%eax
  801355:	8d 50 04             	lea    0x4(%eax),%edx
  801358:	89 55 14             	mov    %edx,0x14(%ebp)
  80135b:	83 ec 08             	sub    $0x8,%esp
  80135e:	53                   	push   %ebx
  80135f:	ff 30                	pushl  (%eax)
  801361:	ff d6                	call   *%esi
			break;
  801363:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801366:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801369:	e9 01 ff ff ff       	jmp    80126f <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80136e:	8b 45 14             	mov    0x14(%ebp),%eax
  801371:	8d 50 04             	lea    0x4(%eax),%edx
  801374:	89 55 14             	mov    %edx,0x14(%ebp)
  801377:	8b 00                	mov    (%eax),%eax
  801379:	99                   	cltd   
  80137a:	31 d0                	xor    %edx,%eax
  80137c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80137e:	83 f8 0f             	cmp    $0xf,%eax
  801381:	7f 0b                	jg     80138e <vprintfmt+0x145>
  801383:	8b 14 85 a0 21 80 00 	mov    0x8021a0(,%eax,4),%edx
  80138a:	85 d2                	test   %edx,%edx
  80138c:	75 18                	jne    8013a6 <vprintfmt+0x15d>
				printfmt(putch, putdat, "error %d", err);
  80138e:	50                   	push   %eax
  80138f:	68 1f 1f 80 00       	push   $0x801f1f
  801394:	53                   	push   %ebx
  801395:	56                   	push   %esi
  801396:	e8 91 fe ff ff       	call   80122c <printfmt>
  80139b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80139e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8013a1:	e9 c9 fe ff ff       	jmp    80126f <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8013a6:	52                   	push   %edx
  8013a7:	68 9d 1e 80 00       	push   $0x801e9d
  8013ac:	53                   	push   %ebx
  8013ad:	56                   	push   %esi
  8013ae:	e8 79 fe ff ff       	call   80122c <printfmt>
  8013b3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013b9:	e9 b1 fe ff ff       	jmp    80126f <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013be:	8b 45 14             	mov    0x14(%ebp),%eax
  8013c1:	8d 50 04             	lea    0x4(%eax),%edx
  8013c4:	89 55 14             	mov    %edx,0x14(%ebp)
  8013c7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8013c9:	85 ff                	test   %edi,%edi
  8013cb:	b8 18 1f 80 00       	mov    $0x801f18,%eax
  8013d0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8013d3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013d7:	0f 8e 94 00 00 00    	jle    801471 <vprintfmt+0x228>
  8013dd:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8013e1:	0f 84 98 00 00 00    	je     80147f <vprintfmt+0x236>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013e7:	83 ec 08             	sub    $0x8,%esp
  8013ea:	ff 75 cc             	pushl  -0x34(%ebp)
  8013ed:	57                   	push   %edi
  8013ee:	e8 a1 02 00 00       	call   801694 <strnlen>
  8013f3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013f6:	29 c1                	sub    %eax,%ecx
  8013f8:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8013fb:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8013fe:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801402:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801405:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801408:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80140a:	eb 0f                	jmp    80141b <vprintfmt+0x1d2>
					putch(padc, putdat);
  80140c:	83 ec 08             	sub    $0x8,%esp
  80140f:	53                   	push   %ebx
  801410:	ff 75 e0             	pushl  -0x20(%ebp)
  801413:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801415:	83 ef 01             	sub    $0x1,%edi
  801418:	83 c4 10             	add    $0x10,%esp
  80141b:	85 ff                	test   %edi,%edi
  80141d:	7f ed                	jg     80140c <vprintfmt+0x1c3>
  80141f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801422:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  801425:	85 c9                	test   %ecx,%ecx
  801427:	b8 00 00 00 00       	mov    $0x0,%eax
  80142c:	0f 49 c1             	cmovns %ecx,%eax
  80142f:	29 c1                	sub    %eax,%ecx
  801431:	89 75 08             	mov    %esi,0x8(%ebp)
  801434:	8b 75 cc             	mov    -0x34(%ebp),%esi
  801437:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80143a:	89 cb                	mov    %ecx,%ebx
  80143c:	eb 4d                	jmp    80148b <vprintfmt+0x242>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80143e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801442:	74 1b                	je     80145f <vprintfmt+0x216>
  801444:	0f be c0             	movsbl %al,%eax
  801447:	83 e8 20             	sub    $0x20,%eax
  80144a:	83 f8 5e             	cmp    $0x5e,%eax
  80144d:	76 10                	jbe    80145f <vprintfmt+0x216>
					putch('?', putdat);
  80144f:	83 ec 08             	sub    $0x8,%esp
  801452:	ff 75 0c             	pushl  0xc(%ebp)
  801455:	6a 3f                	push   $0x3f
  801457:	ff 55 08             	call   *0x8(%ebp)
  80145a:	83 c4 10             	add    $0x10,%esp
  80145d:	eb 0d                	jmp    80146c <vprintfmt+0x223>
				else
					putch(ch, putdat);
  80145f:	83 ec 08             	sub    $0x8,%esp
  801462:	ff 75 0c             	pushl  0xc(%ebp)
  801465:	52                   	push   %edx
  801466:	ff 55 08             	call   *0x8(%ebp)
  801469:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80146c:	83 eb 01             	sub    $0x1,%ebx
  80146f:	eb 1a                	jmp    80148b <vprintfmt+0x242>
  801471:	89 75 08             	mov    %esi,0x8(%ebp)
  801474:	8b 75 cc             	mov    -0x34(%ebp),%esi
  801477:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80147a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80147d:	eb 0c                	jmp    80148b <vprintfmt+0x242>
  80147f:	89 75 08             	mov    %esi,0x8(%ebp)
  801482:	8b 75 cc             	mov    -0x34(%ebp),%esi
  801485:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801488:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80148b:	83 c7 01             	add    $0x1,%edi
  80148e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801492:	0f be d0             	movsbl %al,%edx
  801495:	85 d2                	test   %edx,%edx
  801497:	74 23                	je     8014bc <vprintfmt+0x273>
  801499:	85 f6                	test   %esi,%esi
  80149b:	78 a1                	js     80143e <vprintfmt+0x1f5>
  80149d:	83 ee 01             	sub    $0x1,%esi
  8014a0:	79 9c                	jns    80143e <vprintfmt+0x1f5>
  8014a2:	89 df                	mov    %ebx,%edi
  8014a4:	8b 75 08             	mov    0x8(%ebp),%esi
  8014a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014aa:	eb 18                	jmp    8014c4 <vprintfmt+0x27b>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014ac:	83 ec 08             	sub    $0x8,%esp
  8014af:	53                   	push   %ebx
  8014b0:	6a 20                	push   $0x20
  8014b2:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014b4:	83 ef 01             	sub    $0x1,%edi
  8014b7:	83 c4 10             	add    $0x10,%esp
  8014ba:	eb 08                	jmp    8014c4 <vprintfmt+0x27b>
  8014bc:	89 df                	mov    %ebx,%edi
  8014be:	8b 75 08             	mov    0x8(%ebp),%esi
  8014c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014c4:	85 ff                	test   %edi,%edi
  8014c6:	7f e4                	jg     8014ac <vprintfmt+0x263>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014cb:	e9 9f fd ff ff       	jmp    80126f <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014d0:	83 7d d0 01          	cmpl   $0x1,-0x30(%ebp)
  8014d4:	7e 16                	jle    8014ec <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  8014d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8014d9:	8d 50 08             	lea    0x8(%eax),%edx
  8014dc:	89 55 14             	mov    %edx,0x14(%ebp)
  8014df:	8b 50 04             	mov    0x4(%eax),%edx
  8014e2:	8b 00                	mov    (%eax),%eax
  8014e4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014e7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8014ea:	eb 34                	jmp    801520 <vprintfmt+0x2d7>
	else if (lflag)
  8014ec:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8014f0:	74 18                	je     80150a <vprintfmt+0x2c1>
		return va_arg(*ap, long);
  8014f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8014f5:	8d 50 04             	lea    0x4(%eax),%edx
  8014f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8014fb:	8b 00                	mov    (%eax),%eax
  8014fd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801500:	89 c1                	mov    %eax,%ecx
  801502:	c1 f9 1f             	sar    $0x1f,%ecx
  801505:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801508:	eb 16                	jmp    801520 <vprintfmt+0x2d7>
	else
		return va_arg(*ap, int);
  80150a:	8b 45 14             	mov    0x14(%ebp),%eax
  80150d:	8d 50 04             	lea    0x4(%eax),%edx
  801510:	89 55 14             	mov    %edx,0x14(%ebp)
  801513:	8b 00                	mov    (%eax),%eax
  801515:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801518:	89 c1                	mov    %eax,%ecx
  80151a:	c1 f9 1f             	sar    $0x1f,%ecx
  80151d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801520:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801523:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801526:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80152b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80152f:	0f 89 88 00 00 00    	jns    8015bd <vprintfmt+0x374>
				putch('-', putdat);
  801535:	83 ec 08             	sub    $0x8,%esp
  801538:	53                   	push   %ebx
  801539:	6a 2d                	push   $0x2d
  80153b:	ff d6                	call   *%esi
				num = -(long long) num;
  80153d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801540:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801543:	f7 d8                	neg    %eax
  801545:	83 d2 00             	adc    $0x0,%edx
  801548:	f7 da                	neg    %edx
  80154a:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80154d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801552:	eb 69                	jmp    8015bd <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801554:	8b 55 d0             	mov    -0x30(%ebp),%edx
  801557:	8d 45 14             	lea    0x14(%ebp),%eax
  80155a:	e8 76 fc ff ff       	call   8011d5 <getuint>
			base = 10;
  80155f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801564:	eb 57                	jmp    8015bd <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  801566:	83 ec 08             	sub    $0x8,%esp
  801569:	53                   	push   %ebx
  80156a:	6a 30                	push   $0x30
  80156c:	ff d6                	call   *%esi
			num = getuint(&ap, lflag);
  80156e:	8b 55 d0             	mov    -0x30(%ebp),%edx
  801571:	8d 45 14             	lea    0x14(%ebp),%eax
  801574:	e8 5c fc ff ff       	call   8011d5 <getuint>
			base = 8;
			goto number;
  801579:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  80157c:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801581:	eb 3a                	jmp    8015bd <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  801583:	83 ec 08             	sub    $0x8,%esp
  801586:	53                   	push   %ebx
  801587:	6a 30                	push   $0x30
  801589:	ff d6                	call   *%esi
			putch('x', putdat);
  80158b:	83 c4 08             	add    $0x8,%esp
  80158e:	53                   	push   %ebx
  80158f:	6a 78                	push   $0x78
  801591:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801593:	8b 45 14             	mov    0x14(%ebp),%eax
  801596:	8d 50 04             	lea    0x4(%eax),%edx
  801599:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80159c:	8b 00                	mov    (%eax),%eax
  80159e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015a3:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8015a6:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8015ab:	eb 10                	jmp    8015bd <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8015ad:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8015b0:	8d 45 14             	lea    0x14(%ebp),%eax
  8015b3:	e8 1d fc ff ff       	call   8011d5 <getuint>
			base = 16;
  8015b8:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8015bd:	83 ec 0c             	sub    $0xc,%esp
  8015c0:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015c4:	57                   	push   %edi
  8015c5:	ff 75 e0             	pushl  -0x20(%ebp)
  8015c8:	51                   	push   %ecx
  8015c9:	52                   	push   %edx
  8015ca:	50                   	push   %eax
  8015cb:	89 da                	mov    %ebx,%edx
  8015cd:	89 f0                	mov    %esi,%eax
  8015cf:	e8 52 fb ff ff       	call   801126 <printnum>
			break;
  8015d4:	83 c4 20             	add    $0x20,%esp
  8015d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015da:	e9 90 fc ff ff       	jmp    80126f <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8015df:	83 ec 08             	sub    $0x8,%esp
  8015e2:	53                   	push   %ebx
  8015e3:	52                   	push   %edx
  8015e4:	ff d6                	call   *%esi
			break;
  8015e6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8015ec:	e9 7e fc ff ff       	jmp    80126f <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8015f1:	83 ec 08             	sub    $0x8,%esp
  8015f4:	53                   	push   %ebx
  8015f5:	6a 25                	push   $0x25
  8015f7:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015f9:	83 c4 10             	add    $0x10,%esp
  8015fc:	eb 03                	jmp    801601 <vprintfmt+0x3b8>
  8015fe:	83 ef 01             	sub    $0x1,%edi
  801601:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801605:	75 f7                	jne    8015fe <vprintfmt+0x3b5>
  801607:	e9 63 fc ff ff       	jmp    80126f <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80160c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80160f:	5b                   	pop    %ebx
  801610:	5e                   	pop    %esi
  801611:	5f                   	pop    %edi
  801612:	5d                   	pop    %ebp
  801613:	c3                   	ret    

00801614 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801614:	55                   	push   %ebp
  801615:	89 e5                	mov    %esp,%ebp
  801617:	83 ec 18             	sub    $0x18,%esp
  80161a:	8b 45 08             	mov    0x8(%ebp),%eax
  80161d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801620:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801623:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801627:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80162a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801631:	85 c0                	test   %eax,%eax
  801633:	74 26                	je     80165b <vsnprintf+0x47>
  801635:	85 d2                	test   %edx,%edx
  801637:	7e 22                	jle    80165b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801639:	ff 75 14             	pushl  0x14(%ebp)
  80163c:	ff 75 10             	pushl  0x10(%ebp)
  80163f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801642:	50                   	push   %eax
  801643:	68 0f 12 80 00       	push   $0x80120f
  801648:	e8 fc fb ff ff       	call   801249 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80164d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801650:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801653:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801656:	83 c4 10             	add    $0x10,%esp
  801659:	eb 05                	jmp    801660 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80165b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801660:	c9                   	leave  
  801661:	c3                   	ret    

00801662 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801662:	55                   	push   %ebp
  801663:	89 e5                	mov    %esp,%ebp
  801665:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801668:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80166b:	50                   	push   %eax
  80166c:	ff 75 10             	pushl  0x10(%ebp)
  80166f:	ff 75 0c             	pushl  0xc(%ebp)
  801672:	ff 75 08             	pushl  0x8(%ebp)
  801675:	e8 9a ff ff ff       	call   801614 <vsnprintf>
	va_end(ap);

	return rc;
}
  80167a:	c9                   	leave  
  80167b:	c3                   	ret    

0080167c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80167c:	55                   	push   %ebp
  80167d:	89 e5                	mov    %esp,%ebp
  80167f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801682:	b8 00 00 00 00       	mov    $0x0,%eax
  801687:	eb 03                	jmp    80168c <strlen+0x10>
		n++;
  801689:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80168c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801690:	75 f7                	jne    801689 <strlen+0xd>
		n++;
	return n;
}
  801692:	5d                   	pop    %ebp
  801693:	c3                   	ret    

00801694 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801694:	55                   	push   %ebp
  801695:	89 e5                	mov    %esp,%ebp
  801697:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80169a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80169d:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a2:	eb 03                	jmp    8016a7 <strnlen+0x13>
		n++;
  8016a4:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016a7:	39 c2                	cmp    %eax,%edx
  8016a9:	74 08                	je     8016b3 <strnlen+0x1f>
  8016ab:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8016af:	75 f3                	jne    8016a4 <strnlen+0x10>
  8016b1:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8016b3:	5d                   	pop    %ebp
  8016b4:	c3                   	ret    

008016b5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016b5:	55                   	push   %ebp
  8016b6:	89 e5                	mov    %esp,%ebp
  8016b8:	53                   	push   %ebx
  8016b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8016bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016bf:	89 c2                	mov    %eax,%edx
  8016c1:	83 c2 01             	add    $0x1,%edx
  8016c4:	83 c1 01             	add    $0x1,%ecx
  8016c7:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8016cb:	88 5a ff             	mov    %bl,-0x1(%edx)
  8016ce:	84 db                	test   %bl,%bl
  8016d0:	75 ef                	jne    8016c1 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8016d2:	5b                   	pop    %ebx
  8016d3:	5d                   	pop    %ebp
  8016d4:	c3                   	ret    

008016d5 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016d5:	55                   	push   %ebp
  8016d6:	89 e5                	mov    %esp,%ebp
  8016d8:	53                   	push   %ebx
  8016d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016dc:	53                   	push   %ebx
  8016dd:	e8 9a ff ff ff       	call   80167c <strlen>
  8016e2:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8016e5:	ff 75 0c             	pushl  0xc(%ebp)
  8016e8:	01 d8                	add    %ebx,%eax
  8016ea:	50                   	push   %eax
  8016eb:	e8 c5 ff ff ff       	call   8016b5 <strcpy>
	return dst;
}
  8016f0:	89 d8                	mov    %ebx,%eax
  8016f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016f5:	c9                   	leave  
  8016f6:	c3                   	ret    

008016f7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016f7:	55                   	push   %ebp
  8016f8:	89 e5                	mov    %esp,%ebp
  8016fa:	56                   	push   %esi
  8016fb:	53                   	push   %ebx
  8016fc:	8b 75 08             	mov    0x8(%ebp),%esi
  8016ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801702:	89 f3                	mov    %esi,%ebx
  801704:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801707:	89 f2                	mov    %esi,%edx
  801709:	eb 0f                	jmp    80171a <strncpy+0x23>
		*dst++ = *src;
  80170b:	83 c2 01             	add    $0x1,%edx
  80170e:	0f b6 01             	movzbl (%ecx),%eax
  801711:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801714:	80 39 01             	cmpb   $0x1,(%ecx)
  801717:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80171a:	39 da                	cmp    %ebx,%edx
  80171c:	75 ed                	jne    80170b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80171e:	89 f0                	mov    %esi,%eax
  801720:	5b                   	pop    %ebx
  801721:	5e                   	pop    %esi
  801722:	5d                   	pop    %ebp
  801723:	c3                   	ret    

00801724 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801724:	55                   	push   %ebp
  801725:	89 e5                	mov    %esp,%ebp
  801727:	56                   	push   %esi
  801728:	53                   	push   %ebx
  801729:	8b 75 08             	mov    0x8(%ebp),%esi
  80172c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80172f:	8b 55 10             	mov    0x10(%ebp),%edx
  801732:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801734:	85 d2                	test   %edx,%edx
  801736:	74 21                	je     801759 <strlcpy+0x35>
  801738:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80173c:	89 f2                	mov    %esi,%edx
  80173e:	eb 09                	jmp    801749 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801740:	83 c2 01             	add    $0x1,%edx
  801743:	83 c1 01             	add    $0x1,%ecx
  801746:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801749:	39 c2                	cmp    %eax,%edx
  80174b:	74 09                	je     801756 <strlcpy+0x32>
  80174d:	0f b6 19             	movzbl (%ecx),%ebx
  801750:	84 db                	test   %bl,%bl
  801752:	75 ec                	jne    801740 <strlcpy+0x1c>
  801754:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801756:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801759:	29 f0                	sub    %esi,%eax
}
  80175b:	5b                   	pop    %ebx
  80175c:	5e                   	pop    %esi
  80175d:	5d                   	pop    %ebp
  80175e:	c3                   	ret    

0080175f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80175f:	55                   	push   %ebp
  801760:	89 e5                	mov    %esp,%ebp
  801762:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801765:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801768:	eb 06                	jmp    801770 <strcmp+0x11>
		p++, q++;
  80176a:	83 c1 01             	add    $0x1,%ecx
  80176d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801770:	0f b6 01             	movzbl (%ecx),%eax
  801773:	84 c0                	test   %al,%al
  801775:	74 04                	je     80177b <strcmp+0x1c>
  801777:	3a 02                	cmp    (%edx),%al
  801779:	74 ef                	je     80176a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80177b:	0f b6 c0             	movzbl %al,%eax
  80177e:	0f b6 12             	movzbl (%edx),%edx
  801781:	29 d0                	sub    %edx,%eax
}
  801783:	5d                   	pop    %ebp
  801784:	c3                   	ret    

00801785 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801785:	55                   	push   %ebp
  801786:	89 e5                	mov    %esp,%ebp
  801788:	53                   	push   %ebx
  801789:	8b 45 08             	mov    0x8(%ebp),%eax
  80178c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80178f:	89 c3                	mov    %eax,%ebx
  801791:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801794:	eb 06                	jmp    80179c <strncmp+0x17>
		n--, p++, q++;
  801796:	83 c0 01             	add    $0x1,%eax
  801799:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80179c:	39 d8                	cmp    %ebx,%eax
  80179e:	74 15                	je     8017b5 <strncmp+0x30>
  8017a0:	0f b6 08             	movzbl (%eax),%ecx
  8017a3:	84 c9                	test   %cl,%cl
  8017a5:	74 04                	je     8017ab <strncmp+0x26>
  8017a7:	3a 0a                	cmp    (%edx),%cl
  8017a9:	74 eb                	je     801796 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017ab:	0f b6 00             	movzbl (%eax),%eax
  8017ae:	0f b6 12             	movzbl (%edx),%edx
  8017b1:	29 d0                	sub    %edx,%eax
  8017b3:	eb 05                	jmp    8017ba <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017b5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8017ba:	5b                   	pop    %ebx
  8017bb:	5d                   	pop    %ebp
  8017bc:	c3                   	ret    

008017bd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017bd:	55                   	push   %ebp
  8017be:	89 e5                	mov    %esp,%ebp
  8017c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017c7:	eb 07                	jmp    8017d0 <strchr+0x13>
		if (*s == c)
  8017c9:	38 ca                	cmp    %cl,%dl
  8017cb:	74 0f                	je     8017dc <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017cd:	83 c0 01             	add    $0x1,%eax
  8017d0:	0f b6 10             	movzbl (%eax),%edx
  8017d3:	84 d2                	test   %dl,%dl
  8017d5:	75 f2                	jne    8017c9 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8017d7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017dc:	5d                   	pop    %ebp
  8017dd:	c3                   	ret    

008017de <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017de:	55                   	push   %ebp
  8017df:	89 e5                	mov    %esp,%ebp
  8017e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017e8:	eb 03                	jmp    8017ed <strfind+0xf>
  8017ea:	83 c0 01             	add    $0x1,%eax
  8017ed:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8017f0:	38 ca                	cmp    %cl,%dl
  8017f2:	74 04                	je     8017f8 <strfind+0x1a>
  8017f4:	84 d2                	test   %dl,%dl
  8017f6:	75 f2                	jne    8017ea <strfind+0xc>
			break;
	return (char *) s;
}
  8017f8:	5d                   	pop    %ebp
  8017f9:	c3                   	ret    

008017fa <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8017fa:	55                   	push   %ebp
  8017fb:	89 e5                	mov    %esp,%ebp
  8017fd:	57                   	push   %edi
  8017fe:	56                   	push   %esi
  8017ff:	53                   	push   %ebx
  801800:	8b 7d 08             	mov    0x8(%ebp),%edi
  801803:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801806:	85 c9                	test   %ecx,%ecx
  801808:	74 36                	je     801840 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80180a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801810:	75 28                	jne    80183a <memset+0x40>
  801812:	f6 c1 03             	test   $0x3,%cl
  801815:	75 23                	jne    80183a <memset+0x40>
		c &= 0xFF;
  801817:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80181b:	89 d3                	mov    %edx,%ebx
  80181d:	c1 e3 08             	shl    $0x8,%ebx
  801820:	89 d6                	mov    %edx,%esi
  801822:	c1 e6 18             	shl    $0x18,%esi
  801825:	89 d0                	mov    %edx,%eax
  801827:	c1 e0 10             	shl    $0x10,%eax
  80182a:	09 f0                	or     %esi,%eax
  80182c:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80182e:	89 d8                	mov    %ebx,%eax
  801830:	09 d0                	or     %edx,%eax
  801832:	c1 e9 02             	shr    $0x2,%ecx
  801835:	fc                   	cld    
  801836:	f3 ab                	rep stos %eax,%es:(%edi)
  801838:	eb 06                	jmp    801840 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80183a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80183d:	fc                   	cld    
  80183e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801840:	89 f8                	mov    %edi,%eax
  801842:	5b                   	pop    %ebx
  801843:	5e                   	pop    %esi
  801844:	5f                   	pop    %edi
  801845:	5d                   	pop    %ebp
  801846:	c3                   	ret    

00801847 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801847:	55                   	push   %ebp
  801848:	89 e5                	mov    %esp,%ebp
  80184a:	57                   	push   %edi
  80184b:	56                   	push   %esi
  80184c:	8b 45 08             	mov    0x8(%ebp),%eax
  80184f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801852:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801855:	39 c6                	cmp    %eax,%esi
  801857:	73 35                	jae    80188e <memmove+0x47>
  801859:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80185c:	39 d0                	cmp    %edx,%eax
  80185e:	73 2e                	jae    80188e <memmove+0x47>
		s += n;
		d += n;
  801860:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801863:	89 d6                	mov    %edx,%esi
  801865:	09 fe                	or     %edi,%esi
  801867:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80186d:	75 13                	jne    801882 <memmove+0x3b>
  80186f:	f6 c1 03             	test   $0x3,%cl
  801872:	75 0e                	jne    801882 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801874:	83 ef 04             	sub    $0x4,%edi
  801877:	8d 72 fc             	lea    -0x4(%edx),%esi
  80187a:	c1 e9 02             	shr    $0x2,%ecx
  80187d:	fd                   	std    
  80187e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801880:	eb 09                	jmp    80188b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801882:	83 ef 01             	sub    $0x1,%edi
  801885:	8d 72 ff             	lea    -0x1(%edx),%esi
  801888:	fd                   	std    
  801889:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80188b:	fc                   	cld    
  80188c:	eb 1d                	jmp    8018ab <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80188e:	89 f2                	mov    %esi,%edx
  801890:	09 c2                	or     %eax,%edx
  801892:	f6 c2 03             	test   $0x3,%dl
  801895:	75 0f                	jne    8018a6 <memmove+0x5f>
  801897:	f6 c1 03             	test   $0x3,%cl
  80189a:	75 0a                	jne    8018a6 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80189c:	c1 e9 02             	shr    $0x2,%ecx
  80189f:	89 c7                	mov    %eax,%edi
  8018a1:	fc                   	cld    
  8018a2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018a4:	eb 05                	jmp    8018ab <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018a6:	89 c7                	mov    %eax,%edi
  8018a8:	fc                   	cld    
  8018a9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018ab:	5e                   	pop    %esi
  8018ac:	5f                   	pop    %edi
  8018ad:	5d                   	pop    %ebp
  8018ae:	c3                   	ret    

008018af <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018af:	55                   	push   %ebp
  8018b0:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018b2:	ff 75 10             	pushl  0x10(%ebp)
  8018b5:	ff 75 0c             	pushl  0xc(%ebp)
  8018b8:	ff 75 08             	pushl  0x8(%ebp)
  8018bb:	e8 87 ff ff ff       	call   801847 <memmove>
}
  8018c0:	c9                   	leave  
  8018c1:	c3                   	ret    

008018c2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018c2:	55                   	push   %ebp
  8018c3:	89 e5                	mov    %esp,%ebp
  8018c5:	56                   	push   %esi
  8018c6:	53                   	push   %ebx
  8018c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018cd:	89 c6                	mov    %eax,%esi
  8018cf:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018d2:	eb 1a                	jmp    8018ee <memcmp+0x2c>
		if (*s1 != *s2)
  8018d4:	0f b6 08             	movzbl (%eax),%ecx
  8018d7:	0f b6 1a             	movzbl (%edx),%ebx
  8018da:	38 d9                	cmp    %bl,%cl
  8018dc:	74 0a                	je     8018e8 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8018de:	0f b6 c1             	movzbl %cl,%eax
  8018e1:	0f b6 db             	movzbl %bl,%ebx
  8018e4:	29 d8                	sub    %ebx,%eax
  8018e6:	eb 0f                	jmp    8018f7 <memcmp+0x35>
		s1++, s2++;
  8018e8:	83 c0 01             	add    $0x1,%eax
  8018eb:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018ee:	39 f0                	cmp    %esi,%eax
  8018f0:	75 e2                	jne    8018d4 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8018f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018f7:	5b                   	pop    %ebx
  8018f8:	5e                   	pop    %esi
  8018f9:	5d                   	pop    %ebp
  8018fa:	c3                   	ret    

008018fb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8018fb:	55                   	push   %ebp
  8018fc:	89 e5                	mov    %esp,%ebp
  8018fe:	53                   	push   %ebx
  8018ff:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801902:	89 c1                	mov    %eax,%ecx
  801904:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801907:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80190b:	eb 0a                	jmp    801917 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80190d:	0f b6 10             	movzbl (%eax),%edx
  801910:	39 da                	cmp    %ebx,%edx
  801912:	74 07                	je     80191b <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801914:	83 c0 01             	add    $0x1,%eax
  801917:	39 c8                	cmp    %ecx,%eax
  801919:	72 f2                	jb     80190d <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80191b:	5b                   	pop    %ebx
  80191c:	5d                   	pop    %ebp
  80191d:	c3                   	ret    

0080191e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80191e:	55                   	push   %ebp
  80191f:	89 e5                	mov    %esp,%ebp
  801921:	57                   	push   %edi
  801922:	56                   	push   %esi
  801923:	53                   	push   %ebx
  801924:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801927:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80192a:	eb 03                	jmp    80192f <strtol+0x11>
		s++;
  80192c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80192f:	0f b6 01             	movzbl (%ecx),%eax
  801932:	3c 20                	cmp    $0x20,%al
  801934:	74 f6                	je     80192c <strtol+0xe>
  801936:	3c 09                	cmp    $0x9,%al
  801938:	74 f2                	je     80192c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80193a:	3c 2b                	cmp    $0x2b,%al
  80193c:	75 0a                	jne    801948 <strtol+0x2a>
		s++;
  80193e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801941:	bf 00 00 00 00       	mov    $0x0,%edi
  801946:	eb 11                	jmp    801959 <strtol+0x3b>
  801948:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80194d:	3c 2d                	cmp    $0x2d,%al
  80194f:	75 08                	jne    801959 <strtol+0x3b>
		s++, neg = 1;
  801951:	83 c1 01             	add    $0x1,%ecx
  801954:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801959:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80195f:	75 15                	jne    801976 <strtol+0x58>
  801961:	80 39 30             	cmpb   $0x30,(%ecx)
  801964:	75 10                	jne    801976 <strtol+0x58>
  801966:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80196a:	75 7c                	jne    8019e8 <strtol+0xca>
		s += 2, base = 16;
  80196c:	83 c1 02             	add    $0x2,%ecx
  80196f:	bb 10 00 00 00       	mov    $0x10,%ebx
  801974:	eb 16                	jmp    80198c <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801976:	85 db                	test   %ebx,%ebx
  801978:	75 12                	jne    80198c <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80197a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80197f:	80 39 30             	cmpb   $0x30,(%ecx)
  801982:	75 08                	jne    80198c <strtol+0x6e>
		s++, base = 8;
  801984:	83 c1 01             	add    $0x1,%ecx
  801987:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  80198c:	b8 00 00 00 00       	mov    $0x0,%eax
  801991:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801994:	0f b6 11             	movzbl (%ecx),%edx
  801997:	8d 72 d0             	lea    -0x30(%edx),%esi
  80199a:	89 f3                	mov    %esi,%ebx
  80199c:	80 fb 09             	cmp    $0x9,%bl
  80199f:	77 08                	ja     8019a9 <strtol+0x8b>
			dig = *s - '0';
  8019a1:	0f be d2             	movsbl %dl,%edx
  8019a4:	83 ea 30             	sub    $0x30,%edx
  8019a7:	eb 22                	jmp    8019cb <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8019a9:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019ac:	89 f3                	mov    %esi,%ebx
  8019ae:	80 fb 19             	cmp    $0x19,%bl
  8019b1:	77 08                	ja     8019bb <strtol+0x9d>
			dig = *s - 'a' + 10;
  8019b3:	0f be d2             	movsbl %dl,%edx
  8019b6:	83 ea 57             	sub    $0x57,%edx
  8019b9:	eb 10                	jmp    8019cb <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8019bb:	8d 72 bf             	lea    -0x41(%edx),%esi
  8019be:	89 f3                	mov    %esi,%ebx
  8019c0:	80 fb 19             	cmp    $0x19,%bl
  8019c3:	77 16                	ja     8019db <strtol+0xbd>
			dig = *s - 'A' + 10;
  8019c5:	0f be d2             	movsbl %dl,%edx
  8019c8:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8019cb:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019ce:	7d 0b                	jge    8019db <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8019d0:	83 c1 01             	add    $0x1,%ecx
  8019d3:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019d7:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8019d9:	eb b9                	jmp    801994 <strtol+0x76>

	if (endptr)
  8019db:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019df:	74 0d                	je     8019ee <strtol+0xd0>
		*endptr = (char *) s;
  8019e1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8019e4:	89 0e                	mov    %ecx,(%esi)
  8019e6:	eb 06                	jmp    8019ee <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019e8:	85 db                	test   %ebx,%ebx
  8019ea:	74 98                	je     801984 <strtol+0x66>
  8019ec:	eb 9e                	jmp    80198c <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8019ee:	89 c2                	mov    %eax,%edx
  8019f0:	f7 da                	neg    %edx
  8019f2:	85 ff                	test   %edi,%edi
  8019f4:	0f 45 c2             	cmovne %edx,%eax
}
  8019f7:	5b                   	pop    %ebx
  8019f8:	5e                   	pop    %esi
  8019f9:	5f                   	pop    %edi
  8019fa:	5d                   	pop    %ebp
  8019fb:	c3                   	ret    

008019fc <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019fc:	55                   	push   %ebp
  8019fd:	89 e5                	mov    %esp,%ebp
  8019ff:	56                   	push   %esi
  801a00:	53                   	push   %ebx
  801a01:	8b 75 08             	mov    0x8(%ebp),%esi
  801a04:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a07:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_recv not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  801a0a:	85 c0                	test   %eax,%eax
  801a0c:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a11:	0f 44 c2             	cmove  %edx,%eax

    int r = sys_ipc_recv(pg);
  801a14:	83 ec 0c             	sub    $0xc,%esp
  801a17:	50                   	push   %eax
  801a18:	e8 f1 e8 ff ff       	call   80030e <sys_ipc_recv>
    int from_env = 0, perm = 0;
    if (r == 0) {
  801a1d:	83 c4 10             	add    $0x10,%esp
  801a20:	85 c0                	test   %eax,%eax
  801a22:	75 10                	jne    801a34 <ipc_recv+0x38>
        from_env = thisenv->env_ipc_from;
  801a24:	a1 04 40 80 00       	mov    0x804004,%eax
  801a29:	8b 48 74             	mov    0x74(%eax),%ecx
        perm = thisenv->env_ipc_perm;
  801a2c:	8b 50 78             	mov    0x78(%eax),%edx
        r = thisenv->env_ipc_value;
  801a2f:	8b 40 70             	mov    0x70(%eax),%eax
  801a32:	eb 0a                	jmp    801a3e <ipc_recv+0x42>
    } else {
        from_env = 0;
        perm = 0;
  801a34:	ba 00 00 00 00       	mov    $0x0,%edx
    if (r == 0) {
        from_env = thisenv->env_ipc_from;
        perm = thisenv->env_ipc_perm;
        r = thisenv->env_ipc_value;
    } else {
        from_env = 0;
  801a39:	b9 00 00 00 00       	mov    $0x0,%ecx
        perm = 0;
    }

    if (from_env_store) *from_env_store = from_env;
  801a3e:	85 f6                	test   %esi,%esi
  801a40:	74 02                	je     801a44 <ipc_recv+0x48>
  801a42:	89 0e                	mov    %ecx,(%esi)
    if (perm_store) *perm_store = perm;
  801a44:	85 db                	test   %ebx,%ebx
  801a46:	74 02                	je     801a4a <ipc_recv+0x4e>
  801a48:	89 13                	mov    %edx,(%ebx)

    return r;
}
  801a4a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a4d:	5b                   	pop    %ebx
  801a4e:	5e                   	pop    %esi
  801a4f:	5d                   	pop    %ebp
  801a50:	c3                   	ret    

00801a51 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a51:	55                   	push   %ebp
  801a52:	89 e5                	mov    %esp,%ebp
  801a54:	57                   	push   %edi
  801a55:	56                   	push   %esi
  801a56:	53                   	push   %ebx
  801a57:	83 ec 0c             	sub    $0xc,%esp
  801a5a:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a5d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a60:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  801a63:	85 db                	test   %ebx,%ebx
  801a65:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801a6a:	0f 44 d8             	cmove  %eax,%ebx
  801a6d:	eb 1c                	jmp    801a8b <ipc_send+0x3a>

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        if (ret != -E_IPC_NOT_RECV)
  801a6f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a72:	74 12                	je     801a86 <ipc_send+0x35>
            panic("ipc_send error %e", ret);
  801a74:	50                   	push   %eax
  801a75:	68 00 22 80 00       	push   $0x802200
  801a7a:	6a 40                	push   $0x40
  801a7c:	68 12 22 80 00       	push   $0x802212
  801a81:	e8 b3 f5 ff ff       	call   801039 <_panic>
        sys_yield();
  801a86:	e8 b4 e6 ff ff       	call   80013f <sys_yield>
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801a8b:	ff 75 14             	pushl  0x14(%ebp)
  801a8e:	53                   	push   %ebx
  801a8f:	56                   	push   %esi
  801a90:	57                   	push   %edi
  801a91:	e8 55 e8 ff ff       	call   8002eb <sys_ipc_try_send>
  801a96:	83 c4 10             	add    $0x10,%esp
  801a99:	85 c0                	test   %eax,%eax
  801a9b:	75 d2                	jne    801a6f <ipc_send+0x1e>
        if (ret != -E_IPC_NOT_RECV)
            panic("ipc_send error %e", ret);
        sys_yield();
    }
}
  801a9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aa0:	5b                   	pop    %ebx
  801aa1:	5e                   	pop    %esi
  801aa2:	5f                   	pop    %edi
  801aa3:	5d                   	pop    %ebp
  801aa4:	c3                   	ret    

00801aa5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801aa5:	55                   	push   %ebp
  801aa6:	89 e5                	mov    %esp,%ebp
  801aa8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801aab:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ab0:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ab3:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ab9:	8b 52 50             	mov    0x50(%edx),%edx
  801abc:	39 ca                	cmp    %ecx,%edx
  801abe:	75 0d                	jne    801acd <ipc_find_env+0x28>
			return envs[i].env_id;
  801ac0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ac3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ac8:	8b 40 48             	mov    0x48(%eax),%eax
  801acb:	eb 0f                	jmp    801adc <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801acd:	83 c0 01             	add    $0x1,%eax
  801ad0:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ad5:	75 d9                	jne    801ab0 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ad7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801adc:	5d                   	pop    %ebp
  801add:	c3                   	ret    

00801ade <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ade:	55                   	push   %ebp
  801adf:	89 e5                	mov    %esp,%ebp
  801ae1:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ae4:	89 d0                	mov    %edx,%eax
  801ae6:	c1 e8 16             	shr    $0x16,%eax
  801ae9:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801af0:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801af5:	f6 c1 01             	test   $0x1,%cl
  801af8:	74 1d                	je     801b17 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801afa:	c1 ea 0c             	shr    $0xc,%edx
  801afd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b04:	f6 c2 01             	test   $0x1,%dl
  801b07:	74 0e                	je     801b17 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b09:	c1 ea 0c             	shr    $0xc,%edx
  801b0c:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b13:	ef 
  801b14:	0f b7 c0             	movzwl %ax,%eax
}
  801b17:	5d                   	pop    %ebp
  801b18:	c3                   	ret    
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
